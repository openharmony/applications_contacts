/**
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

/**
 * DialerSearchList
 */

import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { SelectDialogBuilder, SelectSimIdDialog } from '../../dialog/SelectSimIdDialog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { CallLog } from '../../../../../../../feature/call';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import common from '@ohos.app.ability.common';
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { getDialDirectlyAccountId } from '../../../model/CallStateModel';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { BlockType } from '../../../../../../../feature/contact/src/main/ets/contract/BlockList';
import MarkAsDetailDialog from '../../dialog/MarkAsDetailDialog';
import LooseObject from '../../../model/type/LooseObject';
import { CallLogRepository } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { RoamingManager } from '../../../feature/roaming/RoamingManager';
import EmitterConstant from '../../../data/EmitterConstant';
import emitter from '@ohos.events.emitter';
import { CallLogTemp } from '../../../../../../../feature/call/src/main/ets/entity/CallLogTemp';
import dotCommon, { contactParams } from '../../../util/DotCommon';
import { getHeadChar } from '../../../util/UserPhoto';
import { FontScaleState } from '../../../util/fontScaleState';
import DialerConstant from '../../../data/DialerConstant';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { DialerSearchListItem } from './DialerSearchListItem';
import { display, LengthMetrics } from '@kit.ArkUI';
import { SplitStatus } from '../../../util/DisplaySplitUtil';
import { call } from '@kit.TelephonyKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import VibrationUtils from '../../../util/VibrationUtils';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import { VisionGlassConstants } from '../../../data/VisionGlassConstants';
import { i18n } from '@kit.LocalizationKit';
import { DISABLED_OPACITY_STRING, showToast, SystemModeController } from '../../../util/SystemModeController';

const TAG = 'DialerSearchList';
const DIALER_SEARCH_EVENT = 'DIALER_SEARCH_EVENT';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';
const DEFAULT_INDEX = -1;

export enum MenuType {
  MarkAs, blockList
}

// 拨号盘搜索，搜索出的通话记录列表
@Component
export default struct DialerSearchList {
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @Link mPresenter: DialerPresenter;
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) tele_number: string = '';
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) telNumber: string = '';
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @State isEmergencyNum: boolean = false;
  // Number home area
  @State numberLocation: string = '';
  @State isInBlock: boolean = false;
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('isShowBtn') isShowBtn: boolean = true;
  @StorageLink('dialerSearchNumber') dialerSearchNumber: number = -1;
  @State mItem: CallLogTemp = new CallLogTemp('', '', '', '', '', '', '', 0, 0, 0);
  @State mName: string = '';
  @State mPhoneNumber: string = '';
  @State isMarked: boolean = false;
  @State markType: string = '';
  @State markCustom: string = '';
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @State isMenuShown: boolean = false;
  @State selectIndex: number = -1;
  @State previewCardVisible: boolean = true; // 预览卡片的显隐性控制
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // isVerde
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('windowWidthPX') windowWidthPX: number = 0;
  @StorageProp('windowHeightPx') windowHeightPx: number = 0;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  dis: display.Display = display.getDefaultDisplaySync();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('isOnCallSharingValue') isOnCallSharingValue: boolean = false;
  //天通和风信子的初始状态
  @StorageLink('isSatelliteMode') isSatelliteMode: boolean = false;
  @StorageLink('isHyacinthMode') isHyacinthMode: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @Link isSearch: boolean;
  mSystemModeController: SystemModeController = SystemModeController.getInstance();
  // 点击搜索出的通话记录列表的内容区域回调，会拨打电话
  onClickContentCallBack = (name: string, phoneNumber: string) => {
    let formatPhoneNumber = phoneNumber.replace(this.regex, '');
    // 联系人打点--拨号盘搜索点击已知和未知联系人
    if (name) {
      this.dialerSearchParams.RESULT = 1;
    } else {
      this.dialerSearchParams.RESULT = 2;
    }
    DotUtil.getInstance().contactDot(this.dialerSearchParams, DIALER_SEARCH_EVENT);
    if (this.haveMultiSimCard) {
      const directAccountId = getDialDirectlyAccountId(this.mPresenter.dsdsMode)
      if (directAccountId !== undefined) {
        // 3.0 case!
        HiLog.w(TAG, 'Call directly through sim ' + directAccountId);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), formatPhoneNumber, {
          accountId: directAccountId
        });
        this.mPresenter.resetTelNumber();
        return;
      }
      // 如果双卡设置了默认卡号
      if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
        HiLog.w(TAG, 'defaultSlot: ' + this.defaultSlot);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), formatPhoneNumber, {
          accountId: this.defaultSlot
        });
        this.mPresenter.resetTelNumber();
        return;
      }
      this.selectSimBuilder.title = $r('app.string.contacts_call_number', formatPhoneNumber);
      this.selectSimBuilder.callback = (value) => {
        HiLog.w(TAG, 'selectSimBuilder callback: ' + value);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), formatPhoneNumber, {
          accountId: value
        });
        this.mPresenter.resetTelNumber();
      }
      const findByNumberInData: Record<string, common.UIAbilityContext | string> = {
        'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        'numbers': formatPhoneNumber
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('findByNumberIn', {
          actionData: {
            context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
            numbers: formatPhoneNumber,
            limit: 1,
            page: 1
          }
        }, (resultList: CallLog[]) => {
          /* Encapsulate the attributes required on the
           detail page based on the obtained raw call record data.
           */
          if (!ArrayUtil.isEmpty(resultList)) {
            this.selectSimBuilder.lastSimId = resultList[0].simId;
          } else {
            this.selectSimBuilder.lastSimId = -1;
          }
          let spnList = AppStorage.Get<Array<string | Resource>>('spnList') as (string | Resource)[] ?? [];
          for (let index = 0; index < spnList.length; index++) {
            this.selectSimBuilder.multiSimCardItems![index].name = spnList[index];
          }
          this.mSelectSimIdDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.mSelectSimIdDialog);
        });
    } else {
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), formatPhoneNumber);
      this.mPresenter.resetTelNumber();
    }
  };

  // 点击搜索出的通话记录列表的叹号回调，会进入详情
  onClickIntoDetailCallBack = (detailParam: Record<string, boolean | string>) => {
    if (this.pasteStatus) {
      HiLog.w(TAG, 'onClickIntoDetailCallBack pasteStatus disappear');
      this.pasteStatus = false;
    }
    this.isShowDial = true;
    this.mPresenter.jumpToContactDetail(detailParam);
  }

  regex: RegExp = new RegExp('<\/?.+?>', 'g');
  // searchDotParams
  dialerSearchParams: CustomizedParams = {
    RESULT: 1
  }
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  @State selectSimBuilder: SelectDialogBuilder = {
    title: '',
    multiSimCardItems: [{
      name: '',
      img: $r('sys.symbol.phone_badge_1'),
    }, {
      name: '',
      img: $r('sys.symbol.phone_badge_2'),
    }],
  };
  mSelectSimIdDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      contentAreaPadding: {
        right: $r('sys.float.padding_level6'),
        left: $r('sys.float.padding_level6'),
      },
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.selectSimBuilder.title,
      contentBuilder: () => {
        this.SelectSimIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.callDialogParams.ITEM = -1;
            this.callDialogParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.mSelectSimIdDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    this.isSearch = true;
    if (!EnvironmentProp.isDeviceTypeTablet() && !this.isPC) {
      AppStorage.setOrCreate('dialerSearchNumber', -1);
    }
    CallLogRepository.getInstance().registerDataChangeObserver(this.mPresenter.onCallsChange);
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.isSearch = false;
    if (this.isPC) {
      return;
    }
    this.mSelectSimIdDialog = null;
    if (!EnvironmentProp.isDeviceTypeTablet()) {
      this.mPresenter.mAllCallRecordListDataSource.refreshAll([]);
    }
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.mPresenter.onCallsChange);
  }

  formatSearchNumber(phoneNumber: string): string {
    if (!StringUtil.isEmpty(phoneNumber)) {
      return PhoneNumber.fromString(phoneNumber.replace(new RegExp('<\/?.+?>', 'g'), '')).dynamicPhoneFormat();
    }
    return '';
  }

  @Styles
  itemPressedStyles() {
    .backgroundColor($r('app.color.skin_ohos_id_color_click_effect'))
  }

  @Styles
  itemNormalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  private disabledStyles() {
    .opacity($r(DISABLED_OPACITY_STRING))
  }

  build() {
    Column() {
      if (!this.isShowBtn && !this.isVerde) {
          List({scroller: this.scroller}) {
            ListItem() {
              Row() {
                SymbolGlyph($r('sys.symbol.plus'))
                  .fontSize($r('app.float.id_card_margin_max'))
                  .fontColor([$r('app.color.skin_icon_primary')])
                  .margin({
                    left: this.spaceLR,
                    right: this.isPC ? $r('sys.float.padding_level4') : $r('app.float.id_card_margin_xxl')
                  })

                Text($r('app.string.new_contact'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                  .width(`calc(100% - ${this.isTabletLandscape ? '64vp' : '56vp'} - ${this.spaceLR})`)
                  .maxFontScale(2)
                  .margin({
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                  })
              }
              .stateStyles({
                pressed: this.itemPressedStyles,
                normal: this.itemNormalStyles
              })
              .width('100%')
              .constraintSize({
                minHeight: this.isPC ? $r('app.float.id_item_height_sm') :
                $r('app.float.id_item_height_large')
              })
              .onClick(() => {
                this.mPresenter.creatAccountantsObj(AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string)
                AppStorage.setOrCreate('accountantParams', this.mPresenter.myAccountantsModel);
                this.isShowAccountants = true;
                if (this.pasteStatus) {
                  HiLog.w(TAG, 'onClickNewCreate pasteStatus disappear');
                  this.pasteStatus = false;
                }
              })
              .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
              .id('dialerSearchList_contacts_addContact_row')
            }

            ListItem() {
              Row() {
                SymbolGlyph($r('sys.symbol.person_2'))
                  .fontSize($r('app.float.id_card_margin_max'))
                  .fontColor([$r('app.color.skin_icon_primary')])
                  .margin({
                    left: this.spaceLR,
                    right: this.isPC ? $r('sys.float.padding_level4') : $r('app.float.id_card_margin_xxl')
                  })

                Text($r('app.string.save_to_existing_contacts'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                  .width(`calc(100% - ${this.isTabletLandscape ? '64vp' : '56vp'} - ${this.spaceLR})`)
                  .maxFontScale(2)
                  .margin({
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                  })
              }
              .stateStyles({
                pressed: this.itemPressedStyles,
                normal: this.itemNormalStyles
              })
              .width('100%')
              .constraintSize({
                minHeight: this.isPC ? $r('app.float.id_item_height_sm') :
                $r('app.float.id_item_height_large')
              })
              .onClick(() => {
                let teleNum: string = DialerConstant.DIALER_TEL_NUMBER_NO_SPACE;
                this.mPresenter.saveCallRecordExistingContact(AppStorage.get(teleNum) as string);
                if (this.pasteStatus) {
                  HiLog.w(TAG, 'saveToExisting pasteStatus disappear');
                  this.pasteStatus = false;
                }
              })
              .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
              .id('dialerSearchList_contacts_addContact_row')
            }

            ListItem() {
              Row() {
                SymbolGlyph($r('sys.symbol.message'))
                  .fontSize($r('app.float.id_card_margin_max'))
                  .fontColor([$r('app.color.skin_icon_primary')])
                  .margin({
                    left: this.spaceLR,
                    right: this.isPC ? $r('sys.float.padding_level4') : $r('app.float.id_card_margin_xxl')
                  })

                Text($r('app.string.send_messages'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                  .maxFontScale(2)
                  .width(`calc(100% - ${this.isTabletLandscape ? '64vp' : '56vp'} - ${this.spaceLR})`)
                  .margin({
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_title_margin_bottom')),
                  })
              }
              .stateStyles({
                pressed: this.itemPressedStyles,
                normal: this.itemNormalStyles
              })
              .id('dialerSearchList_contacts_message_row')
              .width('100%')
              .constraintSize({
                minHeight: this.isPC ? $r('app.float.id_item_height_sm') :
                $r('app.float.id_item_height_large')
              })
              .onClick(() => {
                this.mPresenter.sendMessage();
              })
              .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
            }

            if (this.haveSimCard && !this.isAirplaneMode && this.haveVoLteReg && !this.isInVisionGlass) {
              if (!this.isSatelliteMode && !this.isHyacinthMode) { //天通和风信子状态下屏蔽视频通话图标
                ListItem() {
                  Row() {
                    SymbolGlyph($r('sys.symbol.video'))
                      .fontSize($r('app.float.id_card_margin_max'))
                      .fontColor([$r('app.color.skin_icon_primary')])
                      .margin({
                        left: this.spaceLR,
                        right: this.isPC ? $r('sys.float.padding_level4') :
                        $r('app.float.id_card_margin_xxl')
                      })

                    Text($r('app.string.video_call'))
                      .fontFamily('HarmonyHeiTi')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                      .maxFontScale(2)
                      .width(`calc(100% - ${this.isTabletLandscape ? '64vp' : '56vp'} - ${this.spaceLR})`)
                      .margin({
                        top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.id_card_title_margin_bottom')),
                        bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.id_card_title_margin_bottom')),
                      })
                  }
                  .stateStyles({
                    pressed: this.itemPressedStyles,
                    normal: this.itemNormalStyles,
                    disabled: this.disabledStyles
                  })
                  .enabled(this.mSystemModeController.getIsEnableVideoCall())
                  .id('dialerSearchList_contacts_video_row')
                  .width('100%')
                  .constraintSize({
                    minHeight: this.isPC ? $r('app.float.id_item_height_sm') :
                    $r('app.float.id_item_height_large')
                  })
                  .onClick(() => {
                    if (this.haveMultiSimCard) {
                      this.mPresenter.multiSimCardVideoDialing(this.getUIContext());
                    } else {
                      let accountId: number = AppStorage.Get<number>('defaultSlot') as number;
                      // 联系人打点-视频呼叫-拨号盘-单卡
                      this.mPresenter.dialerVideoCall(accountId, dotCommon.eventParam.SELECT_FALSE,
                        dotCommon.eventParam.SELECT_FALSE, dotCommon.eventParam.CARD_NUMBER_ONE);
                      this.mPresenter.videoDialing(this.getUIContext(), this.mPresenter.all_number, {
                        accountId: accountId
                      })
                    }
                    AppStorage.setOrCreate('isVideoDialing', true);
                  })
                  .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
                }
                .onClick(() => {
                  if (!this.mSystemModeController.getIsEnableVideoCall()) {
                    showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
                  }
                })
              }
            }
          }
          .clip(this.curBp === 'sm' || this.isPC ? true : false)
          .accessibilityScrollTriggerable(false)
          .divider({
            strokeWidth: '1px',
            color: $r('app.color.skin_ohos_id_color_list_separator'),
            startMargin: this.isTabletLandscape ? $r('app.float.id_item_height_max') :
            $r('app.float.id_item_height_large'),
            endMargin: this.spaceLR
          })
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .visibility(this.dialerSearchNumber === 0 ? Visibility.Visible : Visibility.Hidden)
          .padding({top:this.curBp === 'lg' ? this.fullScreenPadding.top : 0})

      } else {
        List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
          // 拨号盘搜索的联系人列表
          LazyForEach(this.mPresenter.mAllCallRecordListDataSource, (item: CallLogTemp, index: number) => {
            if (!call.hasVoiceCapability() && !StringUtil.isEmpty(item.name)) {
              ListItem() {
                DialerSearchListItem({
                  onClickContentCallBack: this.onClickContentCallBack,
                  displayName: item.name,
                  phoneNumberWithHighLight: item.phoneNumber,
                  markType: item.markType,
                  markCustom: item.markContent,
                  isCloudMark: item.isCloudMark,
                  markCount: item.markCount,
                  numberLocation: item.numberLocation,
                  organization: item.organization,
                  entityId: item.entityId,
                  dataType: item.dataType,
                  curIndex: index,
                  selectIndex: this.selectIndex,
                  onClickIntoDetailCallBack: this.onClickIntoDetailCallBack,
                  formatNumber: this.formatSearchNumber(item.phoneNumber),
                  highlight: item.phoneNumber.includes('<em>') ? PhoneNumber.formatDisplayPhoneNumber(
                    this.formatSearchNumber(item.phoneNumber), this.telNumber) : [DEFAULT_INDEX, DEFAULT_INDEX]
                });
              }
              .id('dialerSearchList_contacts_pad_itemList')
              .padding({
                left: this.spaceLR,
                right: this.spaceLR,
              })
              .stateStyles({
                pressed: this.pressedStyles,
                normal: { .backgroundColor(this.isPC && (this.selectIndex === index) ? 'rgba(10,88,246,0.1)' :
                  Color.Transparent) }
              })
              // .height($r('app.float.id_item_height_max'))
              .constraintSize({
                minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                $r('app.float.id_item_height_max')
              })
            } else {
              ListItem() {
                DialerSearchListItem({
                  onClickContentCallBack: this.onClickContentCallBack,
                  displayName: item.name,
                  phoneNumberWithHighLight: item.phoneNumber,
                  markType: item.markType,
                  markCustom: item.markContent,
                  isCloudMark: item.isCloudMark,
                  markCount: item.markCount,
                  numberLocation: item.numberLocation,
                  organization: item.organization,
                  entityId: item.entityId,
                  dataType: item.dataType,
                  curIndex: index,
                  selectIndex: this.selectIndex,
                  onClickIntoDetailCallBack: this.onClickIntoDetailCallBack,
                  formatNumber: this.formatSearchNumber(item.phoneNumber),
                  highlight: item.phoneNumber.includes('<em>') ? PhoneNumber.formatDisplayPhoneNumber(
                    this.formatSearchNumber(item.phoneNumber), this.telNumber) : [DEFAULT_INDEX, DEFAULT_INDEX]
                });
              }
              .id('dialerSearchList_contacts_pad_itemList')
              .bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
                preview: this.MenuPreview,
                previewAnimationOptions: { scale: [1, 1] },
                placement: Placement.BottomLeft,
                offset: {
                  x: 0,
                  y: $r('sys.float.padding_level4')
                },
                backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
                backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
                aboutToAppear: () => {
                  VibrationUtils.onceVibration(VibrationEffect.LongPressLight);

                  let formatPhoneNumber = item.phoneNumber.replace(this.regex, '');
                  this.mItem = item;
                  this.mName = item.name;
                  this.mPhoneNumber = formatPhoneNumber;
                  CallRecordPresenter.getInstance().isInBlockOrAccessList([this.mPhoneNumber], BlockType.BLOCK,
                    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                      this.isInBlock = result;
                    });
                  CallRecordPresenter.getInstance().isPhoneNumberMarkedOrNot(this.mPhoneNumber,
                    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: LooseObject) => {
                      this.isMarked = result?.isMarked;
                      this.markType = result?.markType;
                      this.markCustom = result?.markContent;
                    });
                  if (this.pasteStatus) {
                    HiLog.w(TAG, 'dialerSearchListPress pasteStatus disappear');
                    this.pasteStatus = false;
                  }
                },
                onDisappear: () => {
                  this.isMenuShown = false;
                }
              })
              .gesture(GestureGroup(GestureMode.Exclusive,
                LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
                  .onAction((event: GestureEvent) => {
                    this.isMenuShown = false;
                  })
              ))
              .onMouse((event: MouseEvent) => {
                if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
                  this.isMenuShown = true
                }
              })
              .padding({
                left: this.spaceLR,
                right: this.spaceLR,
              })
              .stateStyles({
                pressed: this.pressedStyles,
                normal: { .backgroundColor(this.isPC && (this.selectIndex === index) ? 'rgba(10,88,246,0.1)' :
                  Color.Transparent) }
              })
              // .height($r('app.float.id_item_height_max'))
              .constraintSize({ minHeight: this.isVerde ? 56 : $r('app.float.id_item_height_max') })
            }
          }, (item: MergedCallLog, index: number) => JSON.stringify(item) + this.tele_number + index.toString())
        }
        .clip(this.curBp === 'sm' || this.isPC ? true : false)
        .divider({
          strokeWidth: '1px',
          color: $r('app.color.skin_comp_divider'),
          startMargin: this.spaceLR,
          endMargin: this.spaceLR
        })
        .accessibilityScrollTriggerable(false)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .height('100%')
        .width('100%')
        .padding({top:this.curBp === 'lg' ? this.fullScreenPadding.top : 0})
        .margin({ bottom: this.curBp === 'lg' ? '110vp' : 0 })
        .flexShrink(1)
        .listDirection(Axis.Vertical)
        .contentEndOffset(104)
      }
    }
  }

  @Builder
  MenuPreview() {
    Row() {
      Row() {
        if (getHeadChar(this.mItem.name) !== '') {
          Text(getHeadChar(this.mItem.name))
            .fontSize('16vp')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .width($r('app.float.id_card_image_mid'))
            .height($r('app.float.id_card_image_mid'))
            .textAlign(TextAlign.Center)
            .clip(new Circle({ width: '40vp', height: '40vp' }))
            .backgroundColor($r('app.color.skin_background_fourth'))
        } else {
          Image($r('app.media.ic_user_portrait'))
            .width($r('app.float.id_card_image_mid'))
            .height($r('app.float.id_card_image_mid'))
            .objectFit(ImageFit.Contain)
            .borderRadius($r('app.float.id_card_image_mid'))
            .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
            .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
            .draggable(false)
        }
      }
      .height($r('app.float.id_card_image_mid'))
      .width($r('app.float.id_card_image_mid'))

      List() {
        ListItem() {
          Text(this.mName ? this.mName.replace(/<\/?[^>]+>/ig, '') : this.mPhoneNumber as string)
            .textAlign(TextAlign.Start)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .height($r('app.float.id_item_height_large'))
            .direction(Direction.Ltr)
        }
        .align(i18n.isRTL(i18n.System.getSystemLanguage()) ? Alignment.End : Alignment.Start)
        .width($r('app.float.listItem_width_xl'))
      }
      .margin({
        start: LengthMetrics.resource( $r('sys.float.padding_level8'))
      })
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_sm'),
      bottom: $r('app.float.id_card_margin_sm')
    })
    .visibility(this.previewCardVisible ? Visibility.Visible : Visibility.None)
    .align(Alignment.Start)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width('100%')
    .height($r('app.float.id_item_height_max'))
    .accessibilityLevel('no-hide-descendants')
  }

  @Builder
  MenuBuilder() {
    Menu() {
      if (StringUtil.isEmpty(this.mItem.name)) {
        //复制号码
        MenuItem({ content: $r('app.string.copy_phoneNumber') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
          .padding({
            left: $r('app.float.id_card_margin_xxl')
          })
          .onClick(async () => {
            this.mIndexPresenter.getCopy(this.mPhoneNumber as string);
            this.previewCardVisible = false;
          })
        this.MenuDivider()
        ////新建联系人
        MenuItem({ content: $r('app.string.new_contact') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
          .padding({
            left: $r('app.float.id_card_margin_xxl')
          })
          .onClick(async () => {
            this.previewCardVisible = false;
            this.mPresenter.creatAccountantsObj(this.mPhoneNumber as string);
            AppStorage.setOrCreate('accountantParams', this.mPresenter.myAccountantsModel);
            this.isShowAccountants = true;
          })
        this.MenuDivider()
        // 保存至已有联系人
        MenuItem({ content: $r('app.string.save_to_existing_contacts') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
          .padding({
            left: $r('app.float.id_card_margin_xxl')
          })
          .onClick(async () => {
            this.mPresenter.saveCallRecordExistingContact(this.mPhoneNumber as string);
          })
        if (call.hasVoiceCapability()) {
          this.MenuDivider()
        }
        if (call.hasVoiceCapability()) {
          //标记为
          MenuItem({ content: $r('app.string.menu_mark_as') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
            .padding({
              left: $r('app.float.id_card_margin_xxl')
            })
            .enabled(this.isOnCallSharingValue)
            .onClick(() => {
              this.previewCardVisible = false;
              setTimeout(() => {
                contactParams.ENC = dotCommon.eventParam.DIALER_SEARCH_MENU;
                // 联系人打点-号码标记入口-陌生联系人通话记录长按
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.NUMBER_TAG_EVENT);
                this.markAsDialogController?.open();
                DialogControllerManager.getInstance().addDialogController(this.markAsDialogController);
              }, 200)
            })
          this.MenuDivider()
        }
      }
      if (call.hasVoiceCapability()) {
        if (this.isInBlock) {
          //从黑名单中移除
          MenuItem({ content: $r('app.string.delete_from_block_list') })
            .enabled(this.isOnCallSharingValue)
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
            .padding({
              left: $r('app.float.id_card_margin_xxl')
            })
            .onClick(async () => {
              // 联系人打点-从黑名单中移除-通话记录搜索长按
              this.previewCardVisible = false;
              contactParams.ENC = dotCommon.eventParam.CLICK_CALL_HISTORY_SEARCH;
              DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.REMOVE_BLOCKLIST_EVENT);
              CallRecordPresenter.getInstance().cancelBlockList([this.mPhoneNumber],
                ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                  HiLog.w(TAG, 'cancelBlockList result:' + result);
                });
            })
        } else {
          //加入黑名单
          MenuItem({ content: $r('app.string.add_to_blocklist') })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .padding({
              left: $r('app.float.id_card_margin_xxl')
            })
            .enabled(this.isOnCallSharingValue)
            .onClick(async () => {
              // 联系人打点-加入黑名单-通话记录搜索长按
              this.previewCardVisible = false;
              contactParams.ENC = dotCommon.eventParam.CLICK_CALL_HISTORY_SEARCH;
              DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.ADD_BLOCKLIST_EVENT);
              CallRecordPresenter.getInstance().addToBlockList([this.mPhoneNumber],
                this.mName ? this.mName.replace(/<\/?[^>]+>/ig, '') : '', (result: boolean) => {
                HiLog.w(TAG, 'addToBlockList result:' + result);
              });
            })
        }
      }
    }
    .onAppear(() => {
      this.previewCardVisible = true;
    })
    .radius($r('sys.float.corner_radius_level10'))
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
  }

  markAsDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.dialog_title_mark_as'),
      secondaryTitle: $r('app.string.dialog_mark_as_to_cloud'),
      contentBuilder: () => {
        this.markAsDialog();
      },
      contentAreaPadding: ({ left: '0vp', right: '0vp' }),
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.w(TAG, 'markAsDialogController !!!');
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    alignment: DialogAlignment.Center,
    closeAnimation: { duration: 100 },
  });

  @Builder
  markAsDialog() {
    Column() {
      MarkAsDetailDialog({
        phoneNumber: this.mPhoneNumber,
        isMarked: this.isMarked,
        markType: this.markType,
        markCustom: this.markCustom,
        isInBlock: this.isInBlock,
        markAsDialogController: this.markAsDialogController as CustomDialogController
      })
    }
    .padding({ left: '12vp', right: '12vp' })
  }

  @Builder
  SelectSimIdDialogBuilder() {
    Column() {
      SelectSimIdDialog({
        builder: this.selectSimBuilder,
        controller: this.mSelectSimIdDialog as CustomDialogController
      })
    }
    .width('100%')
  }
}