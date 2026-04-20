/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import SpeedDialPresenter from '../../presenter/speeddial/SpeedDialPresenter';
import { CustomizedParams, SpeedDialItem } from '../../model/type/index';
import { sharedPreferencesUtils, StringUtil } from '../../../../../../feature/call/oh_modules/common';
import VoiceMail from './VoiceMail';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import DotUtil from '../../util/DotUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { LengthMetrics, SymbolGlyphModifier, TextModifier, window } from '@kit.ArkUI';
import { FontScaleState } from '../../util/fontScaleState';
import Want from '@ohos.app.ability.Want';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import contact from '@ohos.contact';
import { BusinessError } from '@ohos.base';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit'
import { i18n } from '@kit.LocalizationKit';
import { numFormat } from '../../util/NumFormat';

const TAG = 'SpeedDial ';
const SPEED_DIAL_SET_EVENT = 'SPEED_DIAL_SET_EVENT';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}


@Entry
@Component
export default struct SpeedDial {
  speedDialPresenter: SpeedDialPresenter = SpeedDialPresenter.getInstance();
  // 路径信息
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @State speedDialArray: Array<SpeedDialItem> = [];
  @State pressStateArray: Array<Boolean> = [];
  selectedIndex: number = -1;
  @StorageLink('speedDialFromContact') @Watch('setSpeedDial') speedDialFromContact: SpeedDialItem | null = null;
  @StorageLink('toVoicemailFromSetting') toVoicemailFromSetting: boolean = false;
  @StorageLink('voicemailParam') @Watch('toVoicemailPageAction') voicemailParam: Object | null = null;
  @StorageLink('isGoSpeedHome') @Watch('toHomeAction') isGoSpeedHome: boolean = false;
  @State isDot: boolean = true;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPaddingSpeedDial') fullScreenPadding: Padding = {};
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('languageConfig') private language: string = 'zh-CN';
  @State isShowSheet: boolean = false;
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  private isPC: boolean = EnvironmentProp.isPC();
  want: Want = {};
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  navTitle?: string = '';
  speedDialResultParams: CustomizedParams = {
    SETNUM: 0
  };
  speedDialDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.modify_speed_dial'),
      contentBuilder: () => {
        this.SpeedDialDialogBuilder();
      },
      buttons: [{
        value: $r('app.string.cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.speedDialDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      }]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })

  @Builder
  myRouter(name: string) {
    if (name === 'VoiceMail') {
      VoiceMail();
    }
  }

  toVoicemailPageAction() {
    HiLog.w(TAG, 'toVoicemailPageAction');
    if (this.voicemailParam) {
      let voicemailParam: Object | undefined = AppStorage.get('voicemailParam');
      this.pathInfos.pushPathByName('VoiceMail', voicemailParam, false);
      AppStorage.setOrCreate('voicemailParam', null);
    }
  }

  toHomeAction() {
    HiLog.w(TAG, 'toHomeAction')
    let size = this.pathInfos.size();
    if (size !== 0) {
      this.pathInfos.popToIndex(0);
      this.pathInfos.pop();
    }
  }

  async onPageShow() {
    // 重新加载快速拨号信息
    HiLog.i(TAG, 'onPageShow');
    await sharedPreferencesUtils.removePreferencesFromCache('speedDialObjString');
    const objString: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
    this.speedDialArray = this.speedDialPresenter.initSpeedList(objString);
  }

  async aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    this.speedDialPresenter.pathInfos = this.pathInfos;
    sharedPreferencesUtils.init(ContactsGlobalThisHelper.GetGlobalThis().getSpeedDialContext());
    if (this.toVoicemailFromSetting) {
      this.toVoicemailPageAction();
    } else {
      const objString: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
      this.speedDialArray = this.speedDialPresenter.initSpeedList(objString);
      this.speedDialArray.forEach(() => {
        this.pressStateArray.push(false);
      })
    }

    this.speedDialPresenter.noSimCardDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.voicemail'),
        contentBuilder: () => {
          this.NoSimCardDialogBuilder();
        },
        buttons: [
          {
            value: $r('app.string.confirm'),
            fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
            action: () => {
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              HiLog.w(TAG, 'alert confirm btn click');
            }
          }
        ]
      }),
      autoCancel: false,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      gridCount: 5,
    });

    this.speedDialPresenter.airplaneVoiceAlertDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.voicemail'),
        contentBuilder: () => {
          this.AirplaneVoiceAlertDialogBuilder();
        },
        buttons: [{
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.w(TAG, 'alert confirm btn click')
          }
        }]
      }),
      autoCancel: false,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      gridCount: 5,
    });

  }

  aboutToDisappear() {
    this.speedDialDialog = null;
  }

  setSpeedDial() {
    if (this.speedDialFromContact && this.speedDialArray.length > this.selectedIndex) {
      HiLog.w(TAG, 'setSpeedDial');
      let speedDialFromContact = this.speedDialFromContact;
      if (speedDialFromContact.number) {
        this.selectedIndex = speedDialFromContact.number - 1;
      }
      this.speedDialArray.splice(this.selectedIndex, 1, speedDialFromContact);
      this.speedDialDot();
    }
    AppStorage.setOrCreate('speedDialArray', this.speedDialArray)
    AppStorage.setOrCreate('speedDialFromContact', null);
  }

  // 联系人打点
  speedDialDot() {
    // 联系人打点--快速拨号页面设置快速拨号
    if (this.isDot) {
      let num = 0;
      for (let index = 0; index < this.speedDialArray.length; index++) {
        if (this.speedDialArray[index].contactName !== '') {
          num++;
        }
      }
      this.speedDialResultParams.SETNUM = num;
      DotUtil.getInstance().contactDot(this.speedDialResultParams, SPEED_DIAL_SET_EVENT);
      this.isDot = false;
    }
  }

  async deleteSpeedDial() {
    HiLog.w(TAG, 'deleteSpeedDial');
    if (this.speedDialArray.length > this.selectedIndex) {
      let item: SpeedDialItem = this.speedDialArray[this.selectedIndex];
      item.contactName = '';
      item.contactTelephone = '';
      this.speedDialArray.splice(this.selectedIndex, 1, item);
      let speedDials: Array<SpeedDialItem> = JSON.parse(await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string);
      speedDials[String(this.selectedIndex + 1)] = null;
      sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedDials));
    }
  }

  build() {
   Navigation(this.pathInfos) {
      Column() {
        Blank().height($r('app.float.id_item_height_large'))
        Scroll() {
          GridRow({ columns: { xs: 6, sm: 6, md: 8, lg: 12 } }) {
            GridCol({ span: { xs: 6, sm: 6, md: 6, lg: 8 }, offset: { xs: 1, sm: 1, md: 1, lg: 2 } }) {
              GridRow({
                columns: 3,
                gutter: { x: this.curBp === 'sm' ? '8vp' : this.curBp === 'lg' ? '16vp' : '12vp', y: 0 }
              }) {
                ForEach(this.speedDialArray, (item: SpeedDialItem, index: number) => {
                  GridCol({ span: 1, offset: 0, order: 0 }) {
                    RelativeContainer() {
                      if (item.number !== undefined) {
                        Text(numFormat(item.number))
                          .width($r('app.float.id_card_text_margin_bottom'))
                          .height($r('app.float.dialer_common_small_margin'))
                          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                          .fontSize(FontScaleState.isSmallerThirdGeer(this.fontSizeScale) ? $r('sys.float.Body_S') :
                            '14vp')
                          .margin({
                            bottom: '33vp',
                            right: i18n.isRTL(i18n.System.getSystemLanguage()) ? 0 : '31vp', //维语布局方向和正常布局相反，因此需要将边距倒转
                            left: i18n.isRTL(i18n.System.getSystemLanguage()) ? '31vp' : 0
                          })
                          .alignRules({
                            bottom: { anchor: '__container__', align: VerticalAlign.Center },
                            right: { anchor: '__container__', align: HorizontalAlign.Center }
                          })
                      }
                      Column() {
                        Row() {
                          Stack({ alignContent: Alignment.Center }) {
                            if (index !== 0 && item.contactName !== '') {
                              Avatar({ item: item })
                            } else {
                              Button({ type: ButtonType.Circle }) {
                                SymbolGlyph(index === 0 ? $r('sys.symbol.recordingtape') : $r('sys.symbol.plus'))
                                  .fontSize($r('app.float.id_card_image_height'))
                                  .fontColor([$r('app.color.skin_icon_primary')])
                              }
                              .width($r('app.float.id_item_height_max'))
                              .height($r('app.float.id_item_height_max'))
                              .borderColor($r('app.color.skin_ohos_id_color_primary_contrary'))
                              .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
                            }
                          }
                        }
                        .width('100%')
                        .justifyContent(FlexAlign.Center)

                        Row() {
                          Text(index === 0 ? $r('app.string.voicemail')
                            : (item.contactName !== '' ? item.contactName : $r('app.string.add')))
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                            .fontSize(FontScaleState.isSmallerThirdGeer(this.fontSizeScale) ?
                            $r('sys.float.ohos_id_text_size_body2') : '14vp')
                            .fontWeight(FontWeight.Regular)
                            .wordBreak(WordBreak.BREAK_ALL)
                        }
                        .alignItems(VerticalAlign.Center)
                        .height($r('app.float.id_groupList_lineHeight_xl'))
                        .constraintSize({ maxWidth: $r('app.float.id_speedDial_maxWidth') })
                        .margin({
                          top: $r('app.float.id_card_margin_mid')
                        })
                      }
                      .height($r('app.float.account_ItemList_select_width'))
                      .justifyContent(FlexAlign.Center)
                      .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
                    }

                  }
                  .id('speed_dial_grid_col')
                  .width('100%')
                  .height($r('app.float.account_ItemList_select_width'))
                  .onClick(() => {
                    if (index === 0) {
                      this.speedDialPresenter.clickVoiceMailEvent();
                    } else {
                      this.selectedIndex = index ? index : -1;
                      if (item.contactName == '' && this.selectedIndex !== -1) {
                        this.isDot = true;
                        this.speedDialPresenter.speedDialToContact(this.selectedIndex);
                        contact.selectContacts({
                          isMultiSelect: false
                        }, (err: BusinessError, data) => {
                          this.speedDialPresenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL).then(() => {
                          })
                        })
                      } else {
                        this.speedDialDialog?.open();
                        DialogControllerManager.getInstance().addDialogController(this.speedDialDialog);
                      }
                    }
                  })
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      this.pressStateArray[index] = true;
                    } else if (event.type === TouchType.Move) {
                      return;
                    } else {
                      this.pressStateArray[index] = false;
                    }
                    return;
                  })
                  .focusBox({ margin: LengthMetrics.vp(-2) })
                })
              }
            }
          }
        }
      }
      .padding({
        left: this.curBp !== 'sm' ? $r('sys.float.padding_level16') : $r('sys.float.padding_level8'),
        right: this.curBp !== 'sm' ? $r('sys.float.padding_level16') : $r('sys.float.padding_level8')
      })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    // .titleBar({
    //   avoidLayoutSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.speed_dial'),
    //     },
    //     backIcon: {
    //       icon: $r('sys.symbol.chevron_backward')
    //     }
    //   }
    // })
    .title($r('app.string.speed_dial'))
    .height('100%')
    .padding({
       top: this.isPC ?  0:px2vp(this.fullScreenPadding.top as number) ,
       bottom: px2vp(this.fullScreenPadding.bottom as number),
     })
    .mode(NavigationMode.Stack)
    .hideTitleBar(this.isPC)
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(this.myRouter)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor($r('app.color.skin_background_secondary'))
  }

  @Builder
  SpeedDialDialogBuilder() {
    Scroll() {
      Column() {
        Row() {
          Text($r('app.string.delete_number_settings'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.skin_font_primary'))
        }
        .margin({
          top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
          bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
        })
        .alignItems(VerticalAlign.Center)
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_sm') : $r('app.float.id_item_height_mid')
        })
        .width('100%')
        .onClick(() => {
          this.speedDialDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.deleteSpeedDial();
        })
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })

        Divider()
          .height(0.5)
          .width('100%')
          .backgroundColor($r('app.color.skin_comp_divider'))

        Row() {
          Text($r('app.string.modifying_settings_number'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.skin_font_primary'))
        }
        .margin({
          top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
          bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
        })
        .alignItems(VerticalAlign.Center)
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_sm') : $r('app.float.id_item_height_mid')
        })
        .width('100%')
        .onClick(() => {
          this.speedDialDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.speedDialPresenter.speedDialToContact(this.selectedIndex);
          contact.selectContacts({
            isMultiSelect: false
          }, (err: BusinessError, data) => {
            this.speedDialPresenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL).then(() => {
            })
          })
          this.isShowSheet = true;
        })
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
      }
      .width('100%')
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  @Builder
  NoSimCardDialogBuilder() {
    Column() {
      Text($r('app.string.not_found_sim_card'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  AirplaneVoiceAlertDialogBuilder() {
    Column() {
      Text($r('app.string.turn_off_airplane_mode'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(this.isPC ? TextAlign.Center : TextAlign.Start)
        .width('100%')
    }
    .width('100%')
  }
}

@Component
export struct Avatar {
  item?: SpeedDialItem;
  @State photoPixelMap: PixelMap | null = null;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  aboutToAppear() {
    if (this.item?.contactId) {
      getPixelMapFromFile(this.item?.contactId, (res: PixelMap | null) => {
        this.photoPixelMap = res;
      })
    }
  }

  build() {
    Row() {
      if (this.photoPixelMap) {
        Image(this.photoPixelMap)
          .width($r('app.float.id_item_height_max'))
          .height($r('app.float.id_item_height_max'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_margin_xxxxl'))
          .backgroundColor(this.item?.portraitColor)
      } else if (this.item?.nameSuffix && !StringUtil.isEmpty(this.item?.nameSuffix)) {
        Text(this.item?.nameSuffix.toUpperCase())
          .fontSize('30vp')
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary_contrary') : Color.White)
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .height($r('app.float.id_item_height_max'))
          .width($r('app.float.id_item_height_max'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_margin_xxxxl'))
      } else {
        Image($r('app.media.ic_user_portrait'))
          .width($r('app.float.id_item_height_max'))
          .height($r('app.float.id_item_height_max'))
          .objectFit(ImageFit.Contain)
          .borderRadius($r('app.float.id_card_margin_xxxxl'))
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
      }
    }
    .height($r('app.float.id_item_height_max'))
    .width($r('app.float.id_item_height_max'))
  }
}