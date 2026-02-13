/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { audio, systemSoundManager } from '@kit.AudioKit';
import { HiLog, StringUtil } from '../../../../../../common';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { RingtoneInfo, RingtoneType, ToneAttrs } from '../../model/ringTone/toneTypes';
import { RingtoneItem, RingtoneSelectionUtil } from '../../util/RingtoneSelectionUtil';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import { FontScaleState } from '../../util/fontScaleState';
import ResourceAudioManager from '../../presenter/ringtone/ResourceAudioManager';
import {
  ContactsGlobalThisHelper
} from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { DynamicLoader } from '../../../../../../common';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import EmitterConstant from '../../data/EmitterConstant';
import { JSON } from '@kit.ArkTS';
import { i18n } from '@kit.LocalizationKit';
import RingTonePresenter from '../../presenter/ringtone/RingTonePresenter';
import fs from '@ohos.file.fs';
import { DISABLED_OPACITY_STRING, showToast, SystemModeController } from '../../util/SystemModeController';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavDestination, HdsNavDestinationAttribute,
//   HdsNavigationTitleMode, HdsNavigationBadgeIconOptions} from '@kit.UIDesignKit'
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'RingtoneSelection ';
const NO_RING: string = 'N';
const NO_RING_TONE: string = '-1';
const LOCAL_PAGE_TYPE = 'localMusic';
// 在线铃声
const ONLINE_PAGE_TYPE = 'onlineRingtone'

let audioManager = audio.getAudioManager();
// 创建音频会话管理器
let audioSessionManager: audio.AudioSessionManager = audioManager.getSessionManager();

@Builder
function dummyFunction(): void {

}

/**
 * Ringtone Selection page
 *
 * @since 2022-04-10
 */
@Component
export default struct RingtoneSelection {
  @State mRingTonePresenter: RingTonePresenter = RingTonePresenter.getInstance();
  // path parameter
  @Provide('contactsRingtonePathInfo') contactsRingtonePathInfo: NavPathStack = new NavPathStack();
  // 记录该联系人之前的铃音uri
  private originalContactRingtoneInfo: string = '';
  @State isMusicExist: boolean = false;
  // 详情页拉起选择铃声需要传的此联系人对应的铃声title
  @Link private ringtoneInfo: RingtoneInfo;
  @Link private isRingToneShow: boolean;
  @State ringtonesFull: ToneAttrs[] = [];
  @State ringtoneFullDataList: SystemRingtoneSource = new SystemRingtoneSource([]);
  @State contactId: string = '';
  @State ringtonePlay: systemSoundManager.RingtonePlayer | undefined = undefined;
  @State systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined =
    systemSoundManager.getSystemSoundManager();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State isChecked: boolean = true;
  private mainScroller: Scroller = new Scroller();

  loaderMap: Map<String, ($$: Params) => void> = new Map<String, ($$: Params) => void>();
  @BuilderParam localMusicLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam videoMusicLoader: ($$: Params) => void = dummyFunction;
  private mSystemModeController = SystemModeController.getInstance();

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  backFromLocalMusic = () => {
    HiLog.i(TAG, 'backFromLocalMusic');
    this.ringtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
  }

  backOnClick = () => {
    HiLog.i(TAG, 'backOnClick');
    this.isRingToneShow = false;
    ResourceAudioManager.releaseRing();
    // 获取用户点击的铃声URI，并保存到数据库中
    this.mRingTonePresenter.saveRingToneToContact(getContext(this));
  }

  cancelOnClick = () => {
    HiLog.i(TAG, 'cancelOnClick');
    this.isRingToneShow = false;
    ResourceAudioManager.releaseRing();
    // 获取用户点击的铃声URI，并保存到数据库中
    this.mRingTonePresenter.saveRingToneToContact(getContext(this));
  }

  async removeLocalRingtone(selectedRingtoneInfo: RingtoneInfo) {
    HiLog.i(TAG, `removeLocalRingtone, this.isFromLocalMusic: ${this.mRingTonePresenter.isFromLocalMusic},
     selectedRingtoneInfo: {ringtoneName: ${StringUtil.maskSensitiveInfo(selectedRingtoneInfo?.ringtoneName)},
      ringtoneType: ${selectedRingtoneInfo?.ringtoneType}}`);

    if (this.mRingTonePresenter.isFromLocalMusic && selectedRingtoneInfo &&
      selectedRingtoneInfo.ringtoneType == RingtoneType.LOCAL_TYPE) {
      HiLog.i(TAG, `need remove LocalMusic`);
      try {
        if (!this.systemSoundManagerInstance) {
          this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
        }
        this.systemSoundManagerInstance.removeCustomizedTone(getContext(this), selectedRingtoneInfo.ringtonePath);
      } catch (error) {
        HiLog.e(TAG, 'queryLocalRingToneUsedTimes error: ' + error?.message + ', stack: ' + error?.stack);
        return;
      }
    } else if (this.mRingTonePresenter.isFromVideoMusic && selectedRingtoneInfo &&
      selectedRingtoneInfo.ringtoneType == RingtoneType.LOCAL_VIDEO_TYPE) {
      HiLog.i(TAG, `need remove VideoMusic`);

      try {
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('queryLocalRingToneUsedTimes', {
            id: this.contactId,
            uri: selectedRingtoneInfo.ringtonePath
          }, (result: number) => {
            HiLog.w(TAG, 'queryLocalRingToneUsedTimes succ: ' + result);
            if (result < 1) {
              if (!this.systemSoundManagerInstance) {
                this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
              }
              this.systemSoundManagerInstance.removeCustomizedTone(getContext(this), selectedRingtoneInfo.ringtonePath);
            }
          });
      } catch (error) {
        HiLog.e(TAG, 'removeCustomizedTone error: ' + error?.message + ', stack: ' + error?.stack);
        return;
      }
    }
  }

  async aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    HiLog.i(TAG, 'this.contactId: ' + this.contactId);
    this.mRingTonePresenter.contactId = this.contactId;
    this.mRingTonePresenter.selectedRingtoneInfo = this.ringtoneInfo;
    let tmpRingtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
    HiLog.i(TAG, 'selectedRingtonePath: ' + tmpRingtoneInfo.ringtoneType);
    this.mRingTonePresenter.originalContactRingtoneInfo = this.ringtoneInfo.ringtonePath;
    HiLog.i(TAG, 'selectedRingtonePath: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtonePath));
    HiLog.i(TAG, 'selectedRingtoneName: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtoneName));
    HiLog.i(TAG, 'selectedRingtoneFilePath: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtoneFilePath));

    // 注册 选择铃声半模态音乐播放 返回方法监听
    let ringToneInnerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_RING_TONE_PLAY,
      priority: emitter.EventPriority.HIGH,
    }
    emitter.on(ringToneInnerEvent, () => {
      // 获取用户点击的铃声URI，并保存到数据库中
      this.mRingTonePresenter.saveRingToneToContact(getContext(this));
    })
    this.getSystemSoundManagerInstance();
    this.getRingToneList();

    // 判断音乐App是否已安装场景
    this.mRingTonePresenter.isMusicAppSupportLocalMusic().then((value) => {
      HiLog.w(TAG, `getMusicInstallInfo value: ${value}`);
      this.isMusicExist = value;
    }).catch((err: BusinessError) => {
      HiLog.e(TAG + 'getMusicInstallInfo err', err?.message + ', stack: ' + err?.stack);
    })

    // 注册标题需要的方法类
    titleMethodClass.backOnClick = this.backOnClick;
    titleMethodClass.cancelOnClick = this.cancelOnClick;

    this.mRingTonePresenter.backFromLocalMusic = this.backFromLocalMusic;

    // 注册回调方法; 动态加载方式，加载页面时，需要首先await import('xxx')方式，引入页面
    DynamicLoader.getInstance().registerRingTone(async (str: string): Promise<boolean> => {
      return await this.dynamicLoadCallBack(str);
    });
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, `aboutToDisappear`);
    this.mRingTonePresenter.isFromLocalMusic = false;
    this.mRingTonePresenter.isFromVideoMusic = false;
    emitter.off(EmitterConstant.EVENT_LIST_RING_TONE_PLAY);
    ResourceAudioManager.releaseRing();
  }

  // 注册路由页面
  async dynamicLoadCallBack(key: string): Promise<boolean> {
    if (key === 'LocalMusicSelection') {
      let localMusicLoader = await import('./LocalMusicSelection');
      this.localMusicLoader = localMusicLoader.LocalMusicSelectionLoader;
      this.loaderMap.set('LocalMusicSelection', this.localMusicLoader)
    } else if (key === 'VideoMusicSelection') {
      let videoMusicLoader = await import('./VideoMusicSelection');
      this.videoMusicLoader = videoMusicLoader.VideoMusicSelectionLoader;
      this.loaderMap.set('VideoMusicSelection', this.videoMusicLoader)
    }
    let pageLoader = (this.loaderMap.get(key) as ($$: Params) => void)
    HiLog.i(TAG, 'dymic load page: ' + key + '--' + (pageLoader === undefined))
    return pageLoader === undefined
  }

  async getRingToneList(): Promise<void> {
    let toneAttrsArr: systemSoundManager.ToneAttrsArray = [];
    toneAttrsArr = await this.getRingToneAttrList();
    this.ringtonesFull = [];
    if (toneAttrsArr && toneAttrsArr.length > 0) {
      this.getPreSystemToneAttrs(toneAttrsArr);
    }
    if (this.ringtonesFull.length > 0) {
      this.ringtoneFullDataList.pushDataList(this.ringtonesFull);
    }
  }

  getPreSystemToneAttrs(toneAttrsArr: systemSoundManager.ToneAttrsArray) {
    toneAttrsArr && toneAttrsArr.forEach((ele, index) => {
      try {
        if (ele.getCustomizedType() === systemSoundManager.ToneCustomizedType.PRE_INSTALLED) {
          let item: ToneAttrs = {
            title: ele.getTitle(),
            fileName: ele.getFileName(),
            uri: ele.getUri(),
            customizedType: ele.getCustomizedType()
          }
          this.ringtonesFull.push(item);
        }
      } catch (err) {
        let message = (err as BusinessError).message;
        let errCode = (err as BusinessError).code;
        HiLog.e(TAG, `getPreSystemToneAttrs foreach: code: ${errCode}, message: ${message}`);
        return;
      }
    })
  }

  /**
   * 查询所有系统来电铃声列表
   *
   * @param isForce 是否强制查询列表
   * @returns 铃声列表
   */
  async getRingToneAttrList(): Promise<systemSoundManager.ToneAttrsArray> {
    let toneAttrsArr: systemSoundManager.ToneAttrsArray = [];
    HiLog.w(TAG, `getRingToneAttrList.`);
    try {
      const ringToneAttrList: systemSoundManager.ToneAttrsArray | undefined =
        await RingtoneSelectionUtil.getRingToneAttrList();
      if (ringToneAttrList !== undefined) {
        toneAttrsArr = ringToneAttrList;
      }

    } catch (err) {
      HiLog.e(TAG, `getringToneAttrList  err :${err}`);
      return toneAttrsArr;
    }
    HiLog.i(TAG, `toneAttrsArr :${toneAttrsArr.length}`);
    return toneAttrsArr;
  }

  @Builder
  ringToneItem(item: ToneAttrs, index: number): void {
    Flex({
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Text(this.getRingToneItemTitle(index, item))
        .fontFamily('HarmonyHeiTi')
        .constraintSize({ minHeight: $r('app.float.id_card_image_small') })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.comp_foreground_primary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
        .margin({ end: LengthMetrics.vp(8) })
        .width(`calc(100% - 32vp)`)
      if (item.uri === this.ringtoneInfo.ringtonePath) {
        Radio({ value: item.title, group: 'radioGroup' })
          .width($r('app.float.radio_button_width_24'))
          .constraintSize({ minHeight: $r('app.float.radio_button_width_24') })
          .margin(0)
          .padding({
            top: '2vp',
            bottom: '2vp',
            left: '2vp',
            right: '2vp',
          })
          .checked(true)
          .onChange((isChecked: boolean) => {
          })
          .onClick((event) => {
            HiLog.i(TAG, `onClick`);
            this.onClickRingTone(item);
          });
      }
    }
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .onClick(async () => await this.onClickRingTone(item))
    .accessibilityGroup(true)
    .accessibilityRole(AccessibilityRoleType.RADIO)
    .accessibilityText(this.getRingToneItemTitle(index, item))
    .accessibilityDescription(ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_deselected')))
    .accessibilityChecked(item.uri === this.ringtoneInfo.ringtonePath)
  }

  private getRingToneItemTitle(index: number, item: ToneAttrs) {
    return item.title;
  }

  private async onClickRingTone(item: ToneAttrs): Promise<void> {
    HiLog.w(TAG, `onClick Ringtone, title: ${item.title}`);
    let ringtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
    this.removeLocalRingtone(ringtoneInfo);
    let newRingtoneInfo: RingtoneInfo = {
      ringtoneName: item.title,
      ringtoneFilePath: '',
      ringtonePath: item.uri,
      ringtoneType: '0',
    }
    this.mRingTonePresenter.selectedRingtoneInfo = newRingtoneInfo;
    this.ringtoneInfo = newRingtoneInfo;
    // 播放铃声
    await this.playRingTone(item.uri);
  }

  // 播放铃声
  private async playRingTone(uri: string): Promise<void> {
    try {
      ResourceAudioManager.playFromFileOnce(uri);
      HiLog.w(TAG, `ringtonePlayer stop success`);
    } catch (err) {
      HiLog.e(TAG, ` ringtonePlayer stop failed:${err?.code} ${err?.message}`);
    }
  }

  private async getSystemSoundManagerInstance(): Promise<void> {
    try {
      if (this.systemSoundManagerInstance) {
        return;
      }
      this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      HiLog.i(TAG, ` systemSoundManagerInstance success`);
    } catch (err) {
      HiLog.e(TAG, ` systemSoundManagerInstance errorCode ${err?.code} errorMessage ${err?.message}`);
    }
  }

  // Navigation路由表
  @Builder
  RingToneRouter(name: string, param?: Object) {
    NavDestination() {
      if (name === 'LocalMusicSelection') {
        this.localMusicLoader(param as Params);
      } else if (name === 'VideoMusicSelection') {
        this.videoMusicLoader(param as Params);
      }

    }
    .hideTitleBar((this.isMusicExist || name == 'VideoMusicSelection') ? true : false)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(false), undefined, () => {
    //   HiLog.i(TAG, 'onBackPressed !!');
    //   this.contactsRingtonePathInfo.pop();
    //   this.ringtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
    // }))
    .title(ResourceUtil.getStringByResource($r('app.string.local_music')))
    .onBackPressed(()=>{
      HiLog.i(TAG, 'onBackPressed !!');
      this.contactsRingtonePathInfo.pop();
      this.ringtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
      return true;
    })
    .padding({
      top: (this.isMusicExist || name == 'VideoMusicSelection') ?
        undefined : LengthMetrics.resource($r('sys.float.padding_level4'))
    })
    .backgroundColor($r('app.color.color_bind_sheet_background'))
  }

  // private getTitleParam(isSelectRing: boolean): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: false,
  //     enableComponentSafeArea: true,
  //     title: { title: isSelectRing ? ResourceUtil.getStringByResource($r('app.string.select_ringtone')) :
  //     ResourceUtil.getStringByResource($r('app.string.local_music')) },
  //   };
  // }

  jumpToVideoMusicSelection() {
    HiLog.i(TAG, '' +
      'VideoMusicSelection !!');
    const params: Record<string, RingtoneInfo | boolean | string> = {
      'selectedRingtoneInfo': this.mRingTonePresenter.selectedRingtoneInfo,
      'contactId': this.contactId ? this.contactId : '0'
    };
    DynamicLoader.getInstance().fire(DynamicLoader.VIDEO_RING_TONE_SELECTION_PAGE, false, true).then(() => {
      this.contactsRingtonePathInfo?.pushPathByName('VideoMusicSelection', params);
    });
  }

  jumpToLocalMusicSelection(isMusicExist: boolean, pageType: string) {
    HiLog.i(TAG, 'LocalMusicSelection !!');
    const params: Record<string, RingtoneInfo | boolean | string> = {
      'selectedRingtoneInfo': this.mRingTonePresenter.selectedRingtoneInfo,
      'isMusicExist': isMusicExist,
      'pageType': pageType,
    };
    DynamicLoader.getInstance().fire(DynamicLoader.RING_TONE_SELECTION_PAGE, false, true).then(() => {
      this.contactsRingtonePathInfo?.pushPathByName('LocalMusicSelection', params);
    });
  }

  // menuItem: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.shut_down'),
  //       icon: $r('sys.symbol.xmark'),
  //       isEnabled: true,
  //       action: () => {
  //         titleMethodClass.cancelOnClick();
  //       }
  //     }
  //   }
  // ]

  build() {
    Navigation(this.contactsRingtonePathInfo) {
      Column() {
        Stack({ alignContent: Alignment.TopEnd }) {
          Scroll(this.mainScroller) {
            List() {
              ListItemGroup() {
                ListItem() {
                  // 选择本地音乐
                  this.SelectRingtoneBuilder();
                }

                ListItem() {
                  // 系统来电铃声
                  this.SysRingtoneBuilder();
                }

                ListItem() {
                  // 系统铃声
                  this.SysRingtoneTextBuilder();
                }

                LazyForEach(this.ringtoneFullDataList, (item: ToneAttrs, index: number) => {
                  ListItem() {
                    Column() {
                      this.ringToneItem(item, index);

                      if (index !== (this.ringtoneFullDataList?.ringtoneArray.length - 1)) {
                        Divider()
                          .alignSelf(ItemAlign.Stretch)
                          .strokeWidth('1px')
                          .height($r('app.float.account_Divider_height'))
                          .color($r('sys.color.comp_divider'))
                          .lineCap(LineCapStyle.Square)
                          .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
                      }
                    }
                    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                    .padding({
                      top: index === 0 ? $r('sys.float.padding_level2') : 0,
                      bottom: index === (this.ringtoneFullDataList?.ringtoneArray.length - 1) ? $r('sys.float.padding_level2') :
                        0,
                      left: $r('sys.float.padding_level2'),
                      right: $r('sys.float.padding_level2'),
                    })
                  }
                  .borderRadius({
                    topLeft: index === 0 ? $r('sys.float.corner_radius_level10') : undefined,
                    topRight: index === 0 ? $r('sys.float.corner_radius_level10') : undefined,
                    bottomLeft: (index === this.ringtoneFullDataList?.ringtoneArray.length - 1) ?
                    $r('sys.float.corner_radius_level10') : undefined,
                    bottomRight: (index === this.ringtoneFullDataList?.ringtoneArray.length - 1) ?
                    $r('sys.float.corner_radius_level10') : undefined
                  })
                  .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
                }, (item: ToneAttrs) => item?.title)

                ListItem() {
                  this.NoRingToneBuilder()
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

              ListItem() {
              }
              .padding({
                bottom: '16vp'
              })
            }
          }
          .align(Alignment.TopStart)
          .scrollBar(BarState.Off)
          .padding({
            left: EnvironmentProp.isTabletOrPC() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
            right: EnvironmentProp.isTabletOrPC() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring, {
            alwaysEnabled: true
          })

          ScrollBar({
            scroller: this.mainScroller,
            direction: ScrollBarDirection.Vertical,
            state: BarState.Auto
          })
          .margin({
            bottom: '16vp'
          })
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.Start)
      .height('100%')
    }
    .navDestination(this.RingToneRouter)
    .title(ResourceUtil.getStringByResource($r('app.string.select_ringtone')))
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(true), this.menuItem, () => {
    //   titleMethodClass.backOnClick();
    // }))
    .titleMode(NavigationTitleMode.Mini)
  }

  @Styles
  private disabledStyles() {
    .opacity($r(DISABLED_OPACITY_STRING))
  }

  @Builder
  SelectRingtoneBuilder() {
    Column() {
      // Row() {
      //   Row() {
      //     Text($r('app.string.select_local_music'))
      //       .fontFamily('HarmonyHeiTi')
      //       .fontWeight(FontWeight.Medium)
      //       .fontSize($r('sys.float.Body_L'))
      //       .fontColor($r('sys.color.comp_foreground_primary'))
      //       .textAlign(TextAlign.Start)
      //       .margin({ end: LengthMetrics.vp(8) })
      //       .width(`calc(100% - 20vp)`)
      //     SymbolGlyph($r('sys.symbol.chevron_right'))
      //       .fontSize($r('app.float.id_card_image_small'))
      //       .fontColor([$r('app.color.skin_icon_fourth')])
      //       .flexShrink(0)
      //   }
      //   .padding({
      //     left: '8vp',
      //     right: '8vp',
      //     top: '4vp',
      //     bottom: '4vp'
      //   })
      //   .justifyContent(FlexAlign.SpaceBetween)
      //   .constraintSize({
      //     minHeight: 48,
      //   })
      //   .width('100%')
      //   .margin({
      //     top: '4vp'
      //   })
      //   .stateStyles({
      //     pressed: this.pressedStyles,
      //     normal: this.normalStyles,
      //     disabled: this.disabledStyles
      //   })
      //   .enabled(this.mSystemModeController.getIsEnableJumpToMusicApp())
      // }
      // .accessibilityGroup(true)
      // .onClick(() => {
      //   if (!this.mSystemModeController.getIsEnableJumpToMusicApp()) {
      //     showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
      //   } else {
      //     HiLog.w(TAG, ` select_local_music, onClick`);
      //     ResourceAudioManager.releaseRing();
      //     this.mRingTonePresenter.isMusicAppSupportLocalMusic().then((value) => {
      //       HiLog.w(TAG, `getMusicInstallInfo value: ${value}`);
      //       this.isMusicExist = value;
      //       this.jumpToLocalMusicSelection(value as boolean, LOCAL_PAGE_TYPE);
      //     }).catch((err: BusinessError) => {
      //       HiLog.e(TAG + 'getMusicInstallInfo err', err?.message + ', stack: ' + err?.stack);
      //     })
      //
      //     this.entryClick();
      //   }
      // })

       // Divider()
       //  .alignSelf(ItemAlign.Stretch)
       //  .strokeWidth('1px')
       //  .height($r('app.float.account_Divider_height'))
       //  .color($r('sys.color.comp_divider'))
       //  .lineCap(LineCapStyle.Square)
       //  .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
       Row() {
        Text($r('app.string.select_video_music'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_foreground_primary'))
          .textAlign(TextAlign.Start)
          .margin({ end: LengthMetrics.vp(8) })
          .width(`calc(100% - 20vp)`)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
      }
      .onClick(() => {
        HiLog.e(TAG, ` select_local_music, onClick`);
        ResourceAudioManager.releaseRing();
        this.jumpToVideoMusicSelection();

        this.entryClick();
      })
      .padding({
        left: '8vp',
        right: '8vp',
        top: '4vp',
        bottom: '4vp'
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({
        minHeight: 48,
      })
      .width('100%')
      .margin({ bottom: '4vp'})
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
    }
    .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
    .margin({
      top: '8vp',
      bottom: '12vp'})
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  // 跳转本地音乐
  private entryClick() {
    HiLog.e(TAG, ` entryClick`);
  }

  @Builder
  SysRingtoneBuilder() {
    Column() {
      Row() {
        Text($r('app.string.system_incoming_call_ringtone'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_foreground_primary'))
          .textAlign(TextAlign.Start)
          .margin({ end: LengthMetrics.vp(8) })
          .width(`calc(100% - 32vp)`)
        if (StringUtil.isEmpty(this.ringtoneInfo.ringtonePath)) {
          Radio({ value: '', group: 'radioGroup' })
            .width($r('app.float.radio_button_width_24'))
            .constraintSize({ minHeight: $r('app.float.radio_button_width_24') })
            .checked(true)
            .margin(0)
            .padding({
              top: '2vp',
              bottom: '2vp',
              left: '2vp',
              right: '2vp',
            })
        }
      }
      .onClick(async () => {
        HiLog.e(TAG, ` SysRingtoneBuilder, onClick`);
        ResourceAudioManager.releaseRing();
        let ringtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
        this.removeLocalRingtone(ringtoneInfo);
        let newRingtoneInfo: RingtoneInfo = {
          ringtoneName: '',
          ringtoneFilePath: '',
          ringtonePath: '',
          ringtoneType: '0',
        }
        this.mRingTonePresenter.selectedRingtoneInfo = newRingtoneInfo;
        this.ringtoneInfo = newRingtoneInfo;
      })
      .padding({
        left: '8vp',
        right: '8vp',
        top: '4vp',
        bottom: '4vp'
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.RADIO)
      .accessibilityDescription(ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_deselected')))
      .accessibilityChecked(StringUtil.isEmpty(this.ringtoneInfo.ringtonePath))
      .constraintSize({
        minHeight: 48,
      })
      .width('100%')
      .margin({
        top: '4vp',
        bottom: '4vp'})
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
    }
    .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  @Builder
  SysRingtoneTextBuilder() {
    Column() {
      Text($r('app.string.system_ringtone'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .padding( {top: '28vp', bottom: '8vp', left: '12vp'} )
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
    }
    .width('100%')
    .constraintSize({
      minHeight: 56,
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  NoRingToneBuilder() {

    Column() {
      Row() {
        Text($r('app.string.no_ringtone'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_foreground_primary'))
          .textAlign(TextAlign.Start)
          .margin({ end: LengthMetrics.vp(8) })
          .width(`calc(100% - 32vp)`)
        if (NO_RING_TONE === this.mRingTonePresenter.selectedRingtoneInfo.ringtonePath) {
          Radio({ value: '', group: 'radioGroup' })
            .width($r('app.float.radio_button_width_24'))
            .constraintSize({ minHeight: $r('app.float.radio_button_width_24') })
            .margin(0)
            .padding({
              top: '2vp',
              bottom: '2vp',
              left: '2vp',
              right: '2vp',
            })
            .checked(true)
        }
      }
      .onClick(() => {
        HiLog.e(TAG, ` NoRing, onClick`);
        ResourceAudioManager.releaseRing();
        let ringtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
        this.removeLocalRingtone(ringtoneInfo);
        let newRingtoneInfo: RingtoneInfo = {
          ringtoneName: NO_RING,
          ringtoneFilePath: '',
          ringtonePath: NO_RING_TONE,
          ringtoneType: '0',
        }
        this.mRingTonePresenter.selectedRingtoneInfo = newRingtoneInfo;
        this.ringtoneInfo = newRingtoneInfo;
      })
      .padding({
        left: '8vp',
        right: '8vp',
        top: '4vp',
        bottom: '4vp'
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.RADIO)
      .accessibilityDescription(ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_deselected')))
      .accessibilityChecked(NO_RING_TONE === this.mRingTonePresenter.selectedRingtoneInfo.ringtonePath)
      .constraintSize({
        minHeight: 48,
      })
      .width('100%')
      .margin({
        top: '4vp',
        bottom: '4vp'})
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
    }
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
    .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
    .margin({ top: '12vp'})
    .borderRadius($r('sys.float.corner_radius_level10'))
  }
}

@Extend(Button)
function buttonStyles() {
  .type(EnvironmentProp.isPC() ? ButtonType.Normal : ButtonType.Circle)
  .height(EnvironmentProp.isPC() ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_image_mid'))
  .width(EnvironmentProp.isPC() ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_image_mid'))
  .borderRadius(EnvironmentProp.isPC() ? $r('sys.float.corner_radius_level2') : $r('sys.float.corner_radius_level4'))
  .buttonStyle(EnvironmentProp.isPC() ? ButtonStyleMode.TEXTUAL : ButtonStyleMode.NORMAL)
  .stateEffect(true)
}

//标题需要的变量类
class TitleVariableClass {
  // 是否启动主题
  public isThemeActive: boolean = false;
  // 是否启动无障碍
  public isOpenAccessibility: boolean = false;
  public fontSizeScale: number = 0;
  public pageTitle: Resource = $r('app.string.select_ringtone')
}

//标题需要的方法类
class TitleMethodClass {
  //返回按钮操作
  public backOnClick = () => {
  }
  //取消按钮操作
  public cancelOnClick = () => {
  }
}

let titleMethodClass = new TitleMethodClass()

@Builder
export function RingToneNavDestinationHeaderView($$: TitleVariableClass) {
  Row() {
    Row() {
      WithTheme($$.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_ohos_id_color_primary')])
        }
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
        .buttonStyles()
        .id('cancel_btn')
        .onClick(() => {
          titleMethodClass.backOnClick();
        })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText($$.isOpenAccessibility, $r('app.string.accessibility_cancel')))
      }

      Text(ResourceUtil.getStringByResource($$.pageTitle))
        .fontSize(FontScaleState.isStandardGeer($$.fontSizeScale) ?
        $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
        .fontColor($r('app.color.skin_font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({
          start: EnvironmentProp.isPC() ? LengthMetrics.resource($r('sys.float.padding_level8')) :
          LengthMetrics.resource($r('sys.float.padding_level4'))
        })
    }

    WithTheme($$.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize($r('app.float.id_card_margin_xxxl'))
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      }
      .id('save_click_btn')
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
      .buttonStyles()
      .onClick(() => {
        titleMethodClass.cancelOnClick();
      })
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText($$.isOpenAccessibility, $r('app.string.accessibility_done')))
    }
  }
  .padding({
    left: '16vp',
    right: '16vp'
  })

  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .constraintSize({
    minHeight: $r('app.float.id_item_height_large')
  })
  .flexShrink(0)
  .width('100%')
}

class SystemRingtoneSource implements IDataSource {
  public ringtoneArray: Array<ToneAttrs> = [];
  private listeners: DataChangeListener[] = [];

  constructor(ringtoneArray: Array<ToneAttrs>) {
    this.ringtoneArray = ringtoneArray;
  }

  public totalCount(): number {
    return this.ringtoneArray.length;
  }

  public getData(index: number): ToneAttrs {
    return this.ringtoneArray[index];
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const position = this.listeners.indexOf(listener);
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  public pushDataList(data: Array<ToneAttrs>): void {
    if (data) {
      for (let element of data) {
        if (this.ringtoneArray.indexOf(element) > -1) {
          continue;
        }
        this.ringtoneArray.push(element);
      }
      this.notifyDataAdd(this.ringtoneArray.length - 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }
}