/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
 * Call Log Empty Call View
 */
import CallRecordPresenter from './../../../presenter/dialer/callRecord/CallRecordPresenter';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { HiLog } from '../../../../../../../common'
import VibrationUtils from '../../../util/VibrationUtils';
import DeviceTypeUtil from '../../../util/DeviceTypeUtil';
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallLogCnap } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { CallType, FeaturesType, FeaturesUtil } from '../../../../../../../feature/call';
import LooseObject from '../../../model/type/LooseObject';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import call from '@ohos.telephony.call';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { getPixelMapFromFile, getHeadChar } from '../../../util/UserPhoto';
import { BlockType } from '../../../../../../../feature/contact/src/main/ets/contract/BlockList';
import { RoamingManager } from '../../../feature/roaming/RoamingManager';
import MarkAsDetailDialog from '../../dialog/MarkAsDetailDialog';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import { showVideoChangeToVoiceToast } from './AllRecord';
import dotCommon, { contactParams } from '../../../util/DotCommon';
import { FontScaleState } from '../../../util/fontScaleState';
import { LengthMetrics } from '@kit.ArkUI';
import { CALL_TYPE_CELIA } from '../../../util/CallAssistantUtil';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { i18n } from '@kit.LocalizationKit';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { SystemModeController } from '../../../util/SystemModeController';
import { intelligentAbstractSwitch } from '../../../MainAbility/MainAbility';

const TAG = 'RecordViewItem ';
const PRECALL_EDIT_EVENT = 'PRECALL_EDIT_EVENT';
const VIEW_CONTACT_DETAILS_EVENT = 'VIEW_CONTACT_DETAILS_EVENT';
const CALL_EVENT = 'CALL_EVENT';
const CLICK_CALL_LOG_EVENT = 'CLICK_CALL_LOG_EVENT';
const CLICK_MISSED_LOG_EVENT = 'CLICK_MISSED_LOG_EVENT';
const PRESS_CALL_LOG_EVENT = 'PRESS_CALL_LOG_EVENT';
const MESSAGE_SENDING_EVENT = 'MESSAGE_SENDING_EVENT';
const PRESS_CHOOSE_EVENT = 'PRESS_CHOOSE_EVENT';
const CLICK_SAVE_EXIST_EVENT = 'CLICK_SAVE_EXIST_EVENT';
const CONTACT_ADD_EVENT = 'CONTACT_ADD_EVENT';
const NOT_SAVED_CONTACT_MENU_HEIGHT = 450;
const SAVED_CONTACT_MENU_HEIGHT = 300;
// 当对端设置匿名呼叫时，来电号码会为空，名称为 Anonymous, 协议侧在收到号码为空名称不为空时，会把号码用名称填充
const ANONYMOUS = 'Anonymous';
const NOTE_STATE: string = '-1' // 通话摘要存在但无备忘录数据为-1
const ABSCODE: string = '-1' // 未使用通话摘要时状态码为-1

/**
 * Call Record Item
 */
@Reusable
@Component
export default struct CallRecordItem {
  @State dialerPresenter: DialerPresenter = DialerPresenter.getInstance()
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @Link mPresenter: CallRecordPresenter;
  @Link contactItemTouchable: boolean;
  @Prop item: MergedCallLog;
  index: number = 0;
  recordType: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @StorageProp('fontSizeScale') @Watch('updateContentFontSize') fontSizeScale: number = 0;
  @StorageProp('languageConfig') @Watch('languageChange') private language: string = '';
  @State isInBlock: boolean = false;
  //Determine whether the tag has been changed
  @State isMarked: boolean = false;
  @State markType: string = this.item.markType;
  @State markCustom: string = this.item.markContent;
  @State markDetails: string = this.item.markDetails;
  @State markSource: string = this.item.markSource;
  @State showName: string = '';
  @State photoPixelMap: PixelMap | null = null;
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @State isPrivateNumber: boolean = false; // 私人号码、未知号码
  @State headChar: string = '';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageLink('activeCallId') @Watch('updateGetCallLogBgColor') activeCallId: number = -1;
  @StorageProp('voicemailNumbers') @Watch('checkVoicemailNumber') voicemailNumbers: string[] = ['', ''];
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('VoiceAppEnabled') @Watch('initImageRes') isVoiceAppEnabled: boolean = true;
  @State pressedBackgroundColor: ResourceColor = this.getCallLogBgColor();
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @State isMenuShown: boolean = false;
  @StorageLink('isNavigationModeSplit') isNavigationModeSplit: boolean = false;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageLink('isOnCallSharingValue') isOnCallSharingValue: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageProp('isPrivateAccount') isPrivateAccount: boolean = false;
  @State contentFontSize: Resource | string = $r('sys.float.ohos_id_text_size_body1');
  @State createTimeWidth: number = 0;
  @StorageProp(intelligentAbstractSwitch) intelligentAbstractSwitch: boolean = true;
  @StorageProp('isDarkMode') isDarkMode: boolean = true;
  @StorageProp('NotePadAppEnabled') isNotePadAppEnabledFlag: boolean = true;

  // pressCallLogParams
  pressCallLogParams: CustomizedParams = {
    ENC: 0
  };
  editBeforeCallParams: CustomizedParams = {
    ENC: 0
  };
  viewContactDetailParams: CustomizedParams = {
    LEVELONE: 1,
    LEVELTWO: 0,
    ISSAVE: 0,
    MARKTYPE: 0,
    MARKSOURCE: ''
  };
  // callDotParams
  callParams: CustomizedParams = {
    ENC: 2,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  customizedParams: CustomizedParams = {};
  sendMsgParams: CustomizedParams = {
    ENC: 2,
    ISKNOW: 0
  };
  pressChooseParams: CustomizedParams = {
    ITEM: 0,
    ENC: 0
  };
  contactParams: CustomizedParams = {
    ENC: 0,
  };
  saveExistParams: CustomizedParams = {
    ENC: 0,
  };
  @State imgRes?: Resource = undefined;
  @State imgAccessibilityDesc: Resource = $r('app.string.accessibility_dialed_phone');
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  mSystemModeController = SystemModeController.getInstance();
  deleteDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.deleteCallLog_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          this.mPresenter.deleteCallLog(this.item.ids, [this.item.phoneNumber], this.index);
          this.mPresenter.deleteCallLogItemPage(this.item.ids);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    closeAnimation: { duration: 100 }
  });

  languageChange() {
    this.initShowName();
  }

  aboutToAppear() {
    this.initImageRes();
    // 设置显示的名称
    this.initShowName();
    this.isMarked = this.item.isCloudMark !== 1 &&
      this.item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC;
    this.headChar = getHeadChar(this.showName);
    this.updateGetCallLogBgColor();
    this.updateContentFontSize();
  }

  aboutToDisappear() {
    this.deleteDialogController = null;
    this.updateGetCallLogBgColor()
    this.photoPixelMap?.release();
  }

  aboutToReuse(params: LooseObject) {
    this.item = params.item;
    this.markType = this.item.markType;
    this.markCustom = this.item.markContent;
    this.markDetails = this.item.markDetails;
    this.markSource = this.item.markSource;
    this.index = params.index;
    this.initImageRes();
    this.initShowName();
    this.isMarked = this.item.isCloudMark !== 1 &&
      this.item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC;
    this.headChar = getHeadChar(this.showName);
    this.updateGetCallLogBgColor();
  }

  initShowName() {
    this.isPrivateNumber = false;
    if (this.checkVoicemailNumber()) {
      return;
    }
    if (!StringUtil.isEmpty(this.item.displayName)) {
      this.showName = this.item.displayName;
    } else if (this.markType === NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
      this.markType === NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      // 黄页号码 或者 号码标记
      this.showName = this.item.markContent;
    } else if (this.item.isCloudMark === 1 && this.item.markType === NumberMarkUtil.PRE_FRAUD_PHONE_DESC &&
      this.item.markSource === NumberMarkUtil.ANTI_FRAUD_CENTER) {
      // 国家反诈中心
      this.showName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.suspected_fraud').id);
    } else if (!StringUtil.isEmpty(this.item.formattedNumber)) {
      this.showName = this.item.formattedNumber;
    } else if (!StringUtil.isEmpty(this.item.phoneNumber) && this.item.phoneNumber !== ANONYMOUS) {
      this.showName = this.item.phoneNumber;
    } else {
      this.isPrivateNumber = true;
      this.showName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.unknown_phonenumber').id);
    }
  }

  initImageRes() {
    if (this.item.celiaCallType === CALL_TYPE_CELIA && this.isVoiceAppEnabled) {
      this.imgRes = $r('sys.symbol.AI_phone_fill');
      this.imgAccessibilityDesc = $r('app.string.call_assistant_setting_title');
      return;
    }
    switch (this.item.callType) {
      case CallType.IN:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_answered_phone');
        break;
      case CallType.MISSED:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_missed_call');
        break;
      case CallType.OUT:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.arrow_up_right_video_fill') : $r('sys.symbol.phone_arrow_up_right_fill');
        this.imgAccessibilityDesc = $r('app.string.accessibility_dialed_phone');
        break;
      case CallType.REJECTED:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.xmark_video') : $r('sys.symbol.phone_below_xmark');
        this.imgAccessibilityDesc = $r('app.string.accessibility_rejected_phone');
        break;
      default:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_dialed_phone');
        break;
    }
  }

  checkVoicemailNumber(): boolean {
    let number: string =
      !StringUtil.isEmpty(this.item.formatPhoneNumber) ? this.item.formatPhoneNumber : this.item.phoneNumber;
    if (!StringUtil.isEmpty(number) && this.voicemailNumbers.indexOf(number) >= 0) {
      this.showName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.voicemail').id);
      return true;
    } else {
      return false;
    }
  }

  multiCardDot() {
    //联系人打点--双卡设置默认卡号
    if (this.recordType === 0) {
      this.callParams.ENC = 2;
    } else {
      this.callParams.ENC = 3;
    }
    this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
    this.callParams.ISMULTISIMCARD = 1;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  updateGetCallLogBgColor() {
    this.pressedBackgroundColor = this.getCallLogBgColor();
  }

  clickCallLogDot() {
    // 联系人打点--在双卡状态下未设置默认卡号点击通话记录点位
    if (this.recordType === 0) {
      DotUtil.getInstance().contactDot(this.customizedParams, CLICK_CALL_LOG_EVENT);
    } else {
      DotUtil.getInstance().contactDot(this.customizedParams, CLICK_MISSED_LOG_EVENT);
    }
  }

  singleCardDot() {
    //联系人打点--单卡拨打电话
    if (this.recordType === 0) {
      this.callParams.ENC = 2;
    } else {
      this.callParams.ENC = 3;
    }
    this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
    this.callParams.ISMULTISIMCARD = 0;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  deleteCallLogsDot() {
    // 联系人打点--长按通话记录/未接来电删除通话记录
    if (this.recordType === 0) {
      this.pressChooseParams.ENC = 0;
    } else {
      this.pressChooseParams.ENC = 1;
    }
    this.pressChooseParams.ITEM = 1;
    DotUtil.getInstance().contactDot(this.pressChooseParams, PRESS_CHOOSE_EVENT);
  }

  copyDot() {
    // 联系人打点--长按通话记录/未接来电复制
    if (this.recordType === 0) {
      this.pressChooseParams.ENC = 0;
    } else {
      this.pressChooseParams.ENC = 1;
    }
    this.pressChooseParams.ITEM = 0;
    DotUtil.getInstance().contactDot(this.pressChooseParams, PRESS_CHOOSE_EVENT);
  }

  saveExistingContactsDot() {
    // 联系人打点--长按通话记录/未接来电保存至已有联系人
    if (this.recordType === 0) {
      this.saveExistParams.ENC = 0;
    } else {
      this.saveExistParams.ENC = 1;
    }
    DotUtil.getInstance().contactDot(this.saveExistParams, CLICK_SAVE_EXIST_EVENT);
  }

  createNewContactDot() {
    // 联系人打点--长按通话记录/未接来电新建联系人
    if (this.recordType === 0) {
      this.contactParams.ENC = 4;
    } else {
      this.contactParams.ENC = 5;
    }
    DotUtil.getInstance().contactDot(this.contactParams, CONTACT_ADD_EVENT);
  }

  getCallLogBgColor() {
    if (this.isThemeActive) {
      return Color.Transparent;
    }
    if (this.activeCallId !== this.item.id) {
      return $r('app.color.skin_background_primary');
    }
    if (DeviceTypeUtil.isMaxFoldAbleExpanded(this.curBp) || DeviceTypeUtil.isTablet(this.curBp)) {
      return $r('app.color.color_select_list_bg');
    }
    return $r('app.color.skin_background_primary');
  }

  isUpdateActiveCallId() {
    // 直板机不需要更新
    if (DeviceTypeUtil.isStraightBoard(this.curBp)) {
      return false;
    }
    // 如果当前通话记录的id和已经打开通话记录详情对应的id相等，则不需要更新
    if (this.item.id === this.activeCallId) {
      return false;
    }
    return true;
  }

  updateActiveCallId() {
    if (this.isUpdateActiveCallId()) {
      AppStorage.setOrCreate('activeCallId', this.item.id);
    }
  }

  build() {
    Row() {
      RelativeContainer() {
        Row() {
          SymbolGlyph(this.imgRes == undefined ?
          $r('sys.symbol.xmark_video') : this.imgRes)
            .visibility(this.imgRes == undefined ? Visibility.Hidden : Visibility.Visible)
            .fontSize($r('app.float.dialer_common_small_margin'))
            .fontColor([$r('app.color.skin_icon_tertiary')])
            .width($r('app.float.dialer_common_small_margin'))
            .margin({
              end: LengthMetrics.resource($r('sys.float.padding_level4'))
            })
            .flexShrink(0)
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, this.imgAccessibilityDesc))

          Text(this.showName)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
            $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)
            .maxLines(this.fontSizeScale >= 2 ? null : 1)
            .direction(Direction.Ltr)

          if (this.item.count != 1) {
            Text('(' + this.item.count + ')')
              .fontSize($r('sys.float.Body_L'))
              .fontColor((this.item.callType == 3 || this.item.callType == 5) ?
              $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
              .fontWeight(FontWeight.Medium)
              .padding({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })
              .maxLines(1)
              .flexShrink(0)
          }
        }
        .width('100%')
        .flexShrink(1)
        .constraintSize({
          minHeight: $r('app.float.id_groupList_lineHeight_xxl'),
          maxWidth: this.fontSizeScale >= 2 ? null : `calc(100% - ${this.createTimeWidth}vp - 16vp)`
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .id('infoOne')

        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          if (this.haveMultiSimCard) {
            SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .margin({ right: $r('app.float.id_card_margin_mid') })
              .flexShrink(0)
          }
          if (this.item.isSatellite === 1) { //通话记录中天通图标
            SymbolGlyph($r('sys.symbol.satellite'))   //已修改
              .fontSize(10)
              .maxFontScale(1)  //不放大
              .fontColor([$r('app.color.skin_white')])
              .padding({
                left: 2,
                top: 1,
                right: 1,
                bottom: 2
              })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .margin({
                end: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .flexShrink(0)
              .borderRadius($r('sys.float.Body_S'))
          }
          if (this.item.isSatellite === 2) { //风信子通话记录中图标
            Image($r('app.media.hyacinth_call_log'))
              .margin({
                end: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .size({ width: 12, height: 12 })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundImageSize({ width: 12, height: 12 })
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .borderRadius($r('sys.float.Body_S'))
          }
          if (StringUtil.isEmpty(this.item.displayName)) {
            Text(this.getCallLogItemSecondaryText())
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_font_secondary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(this.fontSizeScale >= 2 ? null : 2)
              .flexShrink(1)
          } else {
            Text(FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
            $r('app.string.video') : (this.item.numberLocation && this.item.numberLocation !== 'N') ?
                this.item.numberLocation as string : this.item.phoneNumber as string)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_font_secondary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(this.fontSizeScale >= 2 ? null : 2)
              .flexShrink(1)
          }
        }
        .constraintSize({
          minHeight: $r('app.float.id_groupList_lineHeight_xl'),
          maxWidth: this.fontSizeScale >= 2 ? null : `calc(100% - ${this.createTimeWidth}vp - 8vp)`
        })
        .margin(
          i18n.isRTL(i18n.System.getSystemLanguage()) ? {
            top: $r('sys.float.padding_level1'),
            right: $r('sys.float.padding_level12')
          } : {
            left: $r('sys.float.padding_level12'),
            top: $r('sys.float.padding_level1')
          } )
        .alignRules({
          top: { anchor: 'infoOne', align: VerticalAlign.Bottom },
          start: { anchor: 'infoOne', align: HorizontalAlign.Start }
        })
        .id('infoTwo')

        Text(this.item.createTime as string)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('app.color.skin_font_secondary'))
          .textAlign(TextAlign.End)
          .margin({
            top: this.fontSizeScale >= 2 ? $r('sys.float.padding_level1') : 15
          })
          .flexShrink(0)
          .alignRules(this.fontSizeScale >= 2 ? {
            top: { anchor: 'infoTwo', align: VerticalAlign.Bottom },
            left: { anchor: 'infoTwo', align: HorizontalAlign.Start }
          } : { right: { anchor: '__container__', align: HorizontalAlign.End } })
          .id('createTime')
          .width(this.fontSizeScale >= 2 ? 'cale(100% - 48vp)' : 'auto')
          .accessibilityText(this.item.createTimeAccessibilityText)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            let oldWidth = Number(oldValue.width);
            let newWidth = Number(newValue.width);
            if (oldWidth !== newWidth) {
              this.createTimeWidth = newWidth;
            }
          })
      }
      .id('callRecord' + this.index)
      .width('100%')
      .height('auto')
      .flexShrink(1)
      .margin({ right: this.isPC ? $r('sys.float.padding_level8') : $r('sys.float.padding_level2') })
      .onClick((event: ClickEvent) => {
        HiLog.w(TAG, `ContactItem onClick!`);
        if (this.isPrivateNumber) {
          HiLog.w(TAG, `isPrivateNumber`);
          return;
        }
        if (this.haveMultiSimCard) {
          HiLog.w(TAG, `haveMultiSimCard, defaultSlot: ${this.defaultSlot}`);
          // 双卡状态下设置了默认卡号,点击通话记录直接拉起通话
          if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
            // 双卡设置默认卡 拨打视频通话
            if (this.mSystemModeController.getIsEnableVideoCall() &&
            FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features)) {
              let voLteRegStates = AppStorage.get<boolean[]>('voLteRegStates') ?? [false, false];
              HiLog.w(TAG, `haveMultiSimCard, voLteRegStates: ${voLteRegStates}`);
              if (voLteRegStates[this.defaultSlot]) {
                let options: call.DialOptions = {
                  accountId: this.defaultSlot,
                  videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
                }
                RoamingManager.getInstance().handleRoaming(
                  this.getUIContext(), this.item.phoneNumber as string, options, (isSuccess: boolean) => {
                  HiLog.w(TAG,
                    `dial video isSuccess ${isSuccess} with single sim in contacts detail pages call log item`);
                });
                return;
              }
              showVideoChangeToVoiceToast();
            }
            // 双卡设置默认卡 拨打语音通话
            let options: call.DialOptions = {
              accountId: this.defaultSlot
            }
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.item.phoneNumber as string, options,
              (isSuccess: boolean) => {
                HiLog.w(TAG, `dial isSuccess ${isSuccess} with multi sim in contacts detail pages call log item`);
              });
            this.multiCardDot();
          } else {
            DialerPresenter.getInstance().editPhoneNumber(this.item.phoneNumber as string);
            this.hideIndexTitleTabBar = false;
            if (this.curBp === 'sm' || (this.isShowSmartWindow && !this.isNavigationModeSplit)) {
              AppStorage.SetOrCreate<boolean>('showDialBtn', true);
            } else {
              this.isShowDial = false;
              this.mPresenter.toDefaultPage();
            }
            this.clickCallLogDot();
          }
        } else {
          HiLog.w(TAG, `haveSingleSimCard`);
          if (FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) && this.haveSimCard) {
            if (this.mSystemModeController.getIsEnableVideoCall() && this.haveVoLteReg) {
              let options: call.DialOptions = {
                accountId: AppStorage.Get<number>('defaultSlot'),
                videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
              }
              RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.item.phoneNumber as string, options,
                (isSuccess: boolean) => {
                  HiLog.w(TAG,
                    `dial video isSuccess ${isSuccess} with single sim in contacts detail pages call log item`);
                });
              return;
            }
            showVideoChangeToVoiceToast();
          }
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.item.phoneNumber as string);
          this.singleCardDot();
        }
      })
      .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
        preview: this.MenuPreview,
        previewAnimationOptions: { scale: [1, 1] },
        placement: Placement.BottomLeft,
        offset: {
          x: 0,
          y: $r('sys.float.padding_level4')
        },
        onDisappear: () => {
          this.isMenuShown = false;
        },
        backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
        backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
        aboutToAppear: () => {
          CallRecordPresenter.getInstance().isInBlockOrAccessList([this.item.phoneNumber], BlockType.BLOCK,
            ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
              this.isInBlock = result;
            });

          getPixelMapFromFile(this.item.quickSearchKey, (res: PixelMap | null) => {
            HiLog.w(TAG, `longPress callLog getPixelMapFromFile. quickSearchKey: ${this.item?.quickSearchKey}`);
            this.photoPixelMap = res;
          })
        }
      })
      .gesture(GestureGroup(GestureMode.Exclusive,
        LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
          .onAction((event: GestureEvent) => {
            // 联系人打点--长按通话记录/未接来电
            if (this.recordType === 0) {
              this.pressCallLogParams.ENC = 0;
            } else {
              this.pressCallLogParams.ENC = 1;
            }
            this.isMenuShown = true;
            DotUtil.getInstance().contactDot(this.pressCallLogParams, PRESS_CALL_LOG_EVENT);
            VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
            if (this.pasteStatus) {
              HiLog.w(TAG, 'callLogLongPress pasteStatus disappear');
              this.pasteStatus = false;
            }
            this.updateGetCallLogBgColor();
          })
      ))
      .onTouch((event: TouchEvent) => {
        switch (event.type) {
          case TouchType.Up:
          case TouchType.Cancel:
            HiLog.w(TAG, StringUtil.maskSensitiveInfo(this.showName) + ' onTouch up or cancel!');
            this.pressedBackgroundColor = this.getCallLogBgColor();
            break;
        }
      })
      .onMouse((event: MouseEvent) => {
        if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
          this.isMenuShown = true;
        }
      })
      .onHover((isHover: boolean) => {
        if (isHover) {
          this.pressedBackgroundColor = $r('app.color.skin_interactive_click');
        } else {
          this.pressedBackgroundColor = this.getCallLogBgColor();
        }
      })

      Button() {
        if (this.intelligentAbstractSwitch && this.item.absCode !== ABSCODE && this.isNotePadAppEnabledFlag &&
          (this.item.noteState !== NOTE_STATE && this.item.noteState !== '')) {
          if (this.isDarkMode) {
            Image($r('app.media.dark'))
              .width(24)
          } else {
            Image($r('app.media.light'))
              .width(24)
          }
        } else {
          SymbolGlyph($r('sys.symbol.info_circle'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_icon_primary')]
            )
        }
      }
      .flexShrink(0)
      .id('tel_detail_bnt')
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_detail')))
      .type(ButtonType.Normal)
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .backgroundColor(Color.Transparent)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .width($r('app.float.id_item_height_mid'))
      .height($r('app.float.id_item_height_mid'))
      .margin({
        end: LengthMetrics.resource($r('app.float.Dialog_bottom'))
      })
      .key('CallLOG_DETAIL')
      .onClick(() => {
        HiLog.w(TAG, `ContactItem callLogDetailOnClick! item markType: ${this.item?.markType
        }, markContent: ${StringUtil.maskSensitiveInfo(this.item?.markContent)}, markCount: ${this.item?.markCount}`);
        // 联系人打点-通话记录查看联系人详情(全部通话/未接来电)
        this.updateActiveCallId();
        if (this.recordType === 0) {
          this.viewContactDetailParams.LEVELTWO = 0;
        } else {
          this.viewContactDetailParams.LEVELTWO = 1;
        }
        if (this.item.displayName) {
          this.viewContactDetailParams.ISSAVE = 1;
        } else {
          this.viewContactDetailParams.ISSAVE = 0;
        }
        this.viewContactDetailParams.MARKTYPE = Number(this.item.markType)
        this.viewContactDetailParams.MARKSOURCE = this.item.markSource
        DotUtil.getInstance().contactDot(this.viewContactDetailParams, VIEW_CONTACT_DETAILS_EVENT);
        this.isShowDial = true;
        if (this.pasteStatus) {
          HiLog.w(TAG, 'callLogDetailOnClick pasteStatus disappear');
          this.pasteStatus = false;
        }
        this.mPresenter.deleteCallLogItemID = this.item.id;
        let cnap: CallLogCnap = new CallLogCnap(this.item.isCnap, this.item.displayName);

        CallRecordPresenter.getInstance().queryIsInYellowPage(this.item.phoneNumber,
          ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
            this.mPresenter.jumpToContactDetail(this.item.phoneNumber as string, this.item.isCloudMark === 0,
              this.item.markType, this.item.markCount, this.item.markSource, this.item.isCloudMark === 1,
              this.item.markContent, this.item.markDetails, result, this.isPrivateNumber, cnap,
              this.item.quickSearchKey);
          });
      })
    }
    .backgroundColor(this.pressedBackgroundColor)
    .stateStyles({
      clicked:{
        .backgroundColor($r('app.color.skin_interactive_click'))
      }
    })
    .justifyContent(FlexAlign.Center)
    .borderRadius(this.isPC ? $r('sys.float.padding_level4') : 0)
    .padding({
      left: this.isPC ? $r('sys.float.padding_level4') : this.spaceLR,
      right: this.isPC ? $r('sys.float.padding_level4') : this.spaceLR,
      top: this.fontSizeScale >= 2
        ? FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
        : $r('sys.float.padding_level4'),
      bottom: this.fontSizeScale >= 2
        ? FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
        : $r('sys.float.padding_level4')
    })
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .width('100%')
    .translate({ y: this.item.offsetY })
    .hitTestBehavior(this.contactItemTouchable ? HitTestMode.Default : HitTestMode.None)
  }

  @Builder
  MenuPreview() {
    Row() {
      Row() {
        if (this.photoPixelMap) {
          Image(this.photoPixelMap)
            .width($r('app.float.id_card_image_mid'))
            .height($r('app.float.id_card_image_mid'))
            .objectFit(ImageFit.Auto)
            .borderRadius($r('app.float.id_card_image_mid'))
            .draggable(false)
            .onError((err: ImageError) => {
              HiLog.e(TAG, 'photoPixelMap err == ' + err.message)
            })
        } else if (!StringUtil.isEmpty(this.headChar)) {
          Text(this.headChar)
            .fontSize('16vp')
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary_contrary') : Color.White)
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
      .layoutWeight(0)

      List() {
        ListItem() {
          Text(this.showName as string)
            .textAlign(TextAlign.Start)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .maxFontScale(2)
            .height($r('app.float.id_item_height_large'))
            .direction(Direction.Ltr)
            .padding({ right: this.isVerde ? 56 : 0 })
        }
        .align(i18n.isRTL(i18n.System.getSystemLanguage()) ? Alignment.End : Alignment.Start)
        .width('100%')
      }
      .height($r('app.float.id_item_height_large'))
      .width($r('app.float.listItem_width_xl'))
      .margin({
        start: LengthMetrics.resource($r('sys.float.padding_level8'))
      })
      .layoutWeight(1)
    }
    .accessibilityLevel('no-hide-descendants')
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid'),
    })
    .borderRadius($r('sys.float.ohos_id_corner_radius_menu'))
    .align(Alignment.Start)
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width('100%')
    .height($r('app.float.id_item_height_max'))
  }

  @Styles
  MenuItemStyles() {
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
    })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      if (!this.isPrivateNumber) {
        //多选
        if (!this.isVerde) {
          // v小折叠外屏 不支持 批量删除通话记录页面
          MenuItem({ content: $r('app.string.multiple_choices') })
            .MenuItemStyles()
            .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .onClick(async () => {
              this.isMenuShown = false;
              this.dialerPresenter.jumpBatchDeleteView();
            })
          this.MenuDivider(MenuType.Copy, this.item.displayName as string)
        }
        //复制号码
        MenuItem({ content: $r('app.string.copy_phoneNumber') })
          .MenuItemStyles()
          .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onClick(async () => {
            this.copyDot();
            this.mIndexPresenter.getCopy(this.item.phoneNumber as string);
          })
        this.MenuDivider(MenuType.Copy, this.item.displayName as string)
        //新建联系人
        if ((this.item.displayName as string === '') && !this.maintenanceMode && !this.isVerde) {
          // v小折叠外屏 不支持 新建联系人页面
          MenuItem({ content: $r('app.string.new_contact') })
            .MenuItemStyles()
            .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .onClick(() => {
              this.createNewContactDot();
              this.mPresenter.creatAccountantsObj(this.item.phoneNumber as string, this.getCallLogDisplayNameText());
              AppStorage.setOrCreate('accountantParams', this.mPresenter.myAccountantsModel);
              this.isShowAccountants = true;
            })
          this.MenuDivider(MenuType.CreateNewContact, this.item.displayName as string)

          MenuItem({ content: $r('app.string.save_to_existing_contacts') })
            .MenuItemStyles()
            .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .onClick(() => {
              HiLog.i(TAG, 'save to existing contacts onClick');
              this.saveExistingContactsDot();
              this.mPresenter.saveExistingContacts(this.item.phoneNumber);
            })
          this.MenuDivider(MenuType.CreateNewContact, this.item.displayName as string)
        }
        //标记为
        if ('' === this.item.displayName && call.hasVoiceCapability() && !this.isPrivateAccount) {
          MenuItem({ content: $r('app.string.menu_mark_as') })
            .enabled(this.isOnCallSharingValue)
            .MenuItemStyles()
            .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .onClick(() => {
              setTimeout(() => {
                contactParams.ENC = dotCommon.eventParam.CALL_RECORD_MENU;
                // 联系人打点-号码标记入口-陌生联系人通话记录长按
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.NUMBER_TAG_EVENT);
                this.markAsDialogController?.open();
                DialogControllerManager.getInstance().addDialogController(this.markAsDialogController);
              }, 200)
            })
          this.MenuDivider(MenuType.MarkAs, this.item.displayName as string)
        }
        if (call.hasVoiceCapability() && !this.isPrivateAccount) {
          // 加入黑名单还是从黑名单移除菜单
          if (this.isInBlock) {
            //从黑名单中移除
            MenuItem({ content: $r('app.string.delete_from_block_list') })
              .enabled(this.isOnCallSharingValue)
              .MenuItemStyles()
              .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
              .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .onClick(async () => {
                // 联系人打点-从黑名单中移除-长按通话记录
                contactParams.ENC = dotCommon.eventParam.CLICK_CALL_HISTORY;
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.REMOVE_BLOCKLIST_EVENT);
                CallRecordPresenter.getInstance().cancelBlockList([this.item.phoneNumber as string],
                  ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                    HiLog.w(TAG, 'cancelBlockList result:' + result);
                  });
              })
          } else {
            //加入黑名单
            MenuItem({ content: $r('app.string.add_to_blocklist') })
              .enabled(this.isOnCallSharingValue)
              .MenuItemStyles()
              .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
              .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .onClick(async () => {
                // 联系人打点-加入黑名单-长按通话记录
                contactParams.ENC = dotCommon.eventParam.CLICK_CALL_HISTORY;
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.ADD_BLOCKLIST_EVENT);
                CallRecordPresenter.getInstance()
                  .addToBlockList([this.item.phoneNumber as string], this.item.displayName, (result: boolean) => {
                    HiLog.w(TAG, 'addToBlockList result:' + result);
                  });
              })
          }
          this.MenuDivider(MenuType.EditBeforeCall, this.item.displayName as string)
        }
      }
      //删除通话记录
      MenuItem({ content: $r('app.string.delete_call_logs') })
        .MenuItemStyles()
        .contentFont({ size: this.contentFontSize, weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onClick(() => {
          setTimeout(() => {
            this.deleteCallLogsDot();
            this.deleteDialogController?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
          }, 200)
        })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  // 长按通话记录 新建联系人选项携带标记的信息作为姓名字段的值
  getCallLogDisplayNameText(): string {
    try {
      HiLog.w(TAG, `getCallLogDisplayNameText markType: ${this.markType}`);
      // 用户手动标记
      if (this.item.isCloudMark === 0 && !StringUtil.isEmpty(this.markType) &&
        this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
        this.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
        this.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
        this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE &&
        this.markType != NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
        if (this.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
          return this.markCustom;
        }
        return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id);
      } else if (this.item.isCloudMark === 1 && !StringUtil.isEmpty(this.markType) &&
        this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
        this.markType != NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC ||
          this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
          this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
          return this.item.markContent;
        }
        return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id)
      } else if (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
        return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync($r('app.string.number_mark_fraud'));
      } else {
        return '';
      }
    } catch (err) {
      HiLog.e(TAG, `getCallLogDisplayNameTexterr: ${err.message}`);
      return '';
    }
  }

  private updateContentFontSize() {
    if (this.fontSizeScale > 2) {
      this.contentFontSize = '20vp';
    } else {
      this.contentFontSize = $r('sys.float.ohos_id_text_size_body1');
    }
    HiLog.i(TAG, `updateMaxFontScale, fontSizeScale: ${this.fontSizeScale}`);
  }

  getCallLogItemSecondaryText(): string | Resource {
    if (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
      return $r('app.string.number_mark_fraud_smart_identify');
    }
    // 用户手动标记
    if (this.item.isCloudMark === 1 && this.item.markType == NumberMarkUtil.PRE_FRAUD_PHONE_DESC) {
      if (this.item.markSource == NumberMarkUtil.ANTI_FRAUD_CENTER) {
        // 国家反诈中心
        let phoneNumber: string =
          !StringUtil.isEmpty(this.item.formattedNumber) ? this.item.formattedNumber : this.item.phoneNumber;
        let numberLocation: string =
          (this.item.numberLocation && this.item.numberLocation !== 'N') ? this.item.numberLocation : ''
        return `${phoneNumber} ${numberLocation}`;
      } else {
        // 高风险电话
        if (this.item.markSource == NumberMarkUtil.ANTIFRAUD_CENTER_MARK_SOURCE) {
          let markType = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id);
          return `${markType}`;
        } else {
          return (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id)) + '  |  ' +
            (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
            ?.resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
              this.item.markCount));
        }
      }
    } else if (this.item.isCloudMark === 0 && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        return $r('app.string.number_marked',
          this.markCustom);
      }
      return $r('app.string.number_marked',
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id));
    } else if (this.item.isCloudMark === 0 && this.markType === NumberMarkUtil.YELLOW_PAGE_PHONE_DESC) {
      return (!StringUtil.isEmpty(this.item.formattedNumber)) ? this.item.formattedNumber : this.item.phoneNumber;
    } else if (this.item.isCloudMark === 1 && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC) {
      if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC) {
        return this.item.markContent;
      }
      if (this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
        if (this.markDetails) {
          return this.markSource ? (this.markDetails + ' | ' + this.markSource) : this.markDetails;
        } else {
          return this.markSource ? (this.item.numberLocation + ' | ' + this.markSource) :
            this.item.numberLocation as string;
        }
      }
      if (this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC) {
        return (!StringUtil.isEmpty(this.item.formattedNumber)) ?
        this.item.formattedNumber : this.item.phoneNumber;
      }
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id) + ' | ' +
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
        this.item.markCount);
    } else if (FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features)) {
      return $r('app.string.video');
    } else if (this.item.numberLocation && this.item.numberLocation !== 'N') {
      return this.item.numberLocation as string;
    } else {
      return $r('app.string.unknown');
    }
  }

  @Builder
  MenuDivider(itemType: number, displayName: string) {
    if ((itemType !== MenuType.SaveExistingContacts || itemType === MenuType.SaveExistingContacts &&
      '' === displayName) && (itemType !== MenuType.CreateNewContact || itemType === MenuType.CreateNewContact &&
      '' === displayName) && (itemType !== MenuType.MarkAs || itemType === MenuType.MarkAs &&
      '' === displayName)) {
      Divider()
        .color($r('app.color.skin_comp_divider'))
        .lineCap(LineCapStyle.Square)
        .width(0)
        .alignSelf(ItemAlign.Stretch)
        .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xxl') })
    }
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
        phoneNumber: this.item.phoneNumber,
        isMarked: this.isMarked,
        markType: this.markType,
        markCustom: this.markCustom,
        isInBlock: this.isInBlock,
        markAsDialogController: this.markAsDialogController as CustomDialogController
      })
    }
    .padding({ left: '12vp', right: '12vp' })
  }
}

export enum MenuType {
  sendMessage, Copy, EditBeforeCall, BlockList, DeleteCallLogs, SaveExistingContacts, CreateNewContact, MarkAs
}