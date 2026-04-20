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
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { SelectDialogBuilder } from '../../dialog/SelectSimIdDialog';
import LooseObject from '../../../model/type/LooseObject';
import { settings } from '@kit.BasicServicesKit';
import call from '@ohos.telephony.call';
import {
  delFileById,
  getHeadChar,
  getImagePackingData,
  getPixelMapFromFile,
  saveImageToFile,
  PixelMapManager
} from '../../../util/UserPhoto';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { BusinessError } from '@ohos.base';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import common from '@ohos.app.ability.common';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { dealContactPhoto } from '../../../model/ContactAbilityModel';
import { ContactStrInterface, CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import dotCommon, { videoCallParams } from '../../../util/DotCommon';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import display from '@ohos.display';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { ContackPhoneSubInfoModel } from '../../../model/type/ContactParams';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { sharedPreferencesUtils } from '../../../../../../../common';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import DetailInfoTelList from '../../../component/contactdetail/DetailInfoTelList';
import DetailInfoRemarks from '../../../component/contactdetail/DetailInfoRemarks';
import DetailInfoMeeTing from '../../../component/contactdetail/DetailInfoMeeTing';
import { JSON } from '@kit.ArkTS';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import measure from '@ohos.measure';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { CallLogSearchBo } from '../../../model/bean/CallLogSearchBo';
import { getDialDirectlyAccountId } from '../../../model/CallStateModel';
import { RoamingManager } from '../../../feature/roaming/RoamingManager';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { EditAvatar } from '../../../component/avatar/AvaterCutout';
import cameraPicker from '@ohos.multimedia.cameraPicker';
import camera from '@ohos.multimedia.camera';
import image from '@ohos.multimedia.image';
import { ComposeListItem, curves, MeasureText, OperationType, SubHeader } from '@kit.ArkUI';
import { LengthMetrics } from '@ohos.arkui.node';
import CallLogListItem from '../../../component/contactdetail/DetailCalllog';
import componentUtils from '@ohos.arkui.componentUtils';
import PhoneAccountType from '../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { ContactDetailMenuItem } from './ContactDeatilMenuItem';
import { CustomTheme, CustomColors } from '@ohos.arkui.theme';
import { TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { RoamingUtils } from '../../../../../../../common/src/main/ets/util/RoamingUtils';
import { SpeedDialDataType, UpdateToCardType } from '../../../card/type/speedDial';
import SpeedDialEditCommon from '../../../card/common/SpeedDialEditCommon';
import { FormCardController } from '../../../card/common/FormCardController'
import formBindingData from '@ohos.app.form.formBindingData';
import Constants from '../../../../../../../common/src/main/ets/Constants'
import window from '@ohos.window';
import ContactCardPhoto from './ContactCardPhoto';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp, { DeviceUtil } from '../../../feature/EnvironmentProp';
import { VisionGlassConstants } from '../../../data/VisionGlassConstants';
import RingtoneSelection from '../../ringtoneSelection/RingtoneIndex';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../../data/EmitterConstant';
import { RingtoneInfo } from '../../../model/ringTone/toneTypes';
import ResourceAudioManager from '../../../presenter/ringtone/ResourceAudioManager';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import { SystemModeController, showToast } from '../../../util/SystemModeController';
// import { HdsListItem } from '@hms.hds.HdsStyle';
// import { hdsEffect } from '@kit.UIDesignKit';
import { uiEffect } from '@kit.ArkGraphics2D';
import { bundleManager } from '@kit.AbilityKit';

const TAG = 'ContactDetailContent';


const cardTextShadowOpt: ShadowOptions = {
  radius: 6,
  color: '#3f3f3f'
};
const normalTextShadowOpt: ShadowOptions = {
  radius: 0
};
const brightLevel1 = 0;
const brightLevel2 = 0;
// const brightLevel1 = uiEffect.createBrightnessBlender(hdsEffect.getBrightnessParam({
//   scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
//   level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
//   fraction: 0,
// }))
// const brightLevel2 = uiEffect.createBrightnessBlender(hdsEffect.getBrightnessParam({
//   scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
//   level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_2,
//   fraction: 0,
// }))
const MIN_RESOLUTION = 409600;
const MAX_HEAD_ANGLE: number = 17;
const DELETE_SWIPE_HEAD_WIDTH: number = 64;
const ACTION_AREA_DISTANCE: number = 56;
const ANGLE_RADIO: number = 12;
const MAX_BODY_ANGLE: number = 10;
const DELETE_SWIPE_BODY_WIDTH: number = 120;
const MAX_SCALE_RATIO: number = 1.1;
const lineBreakRegExp = new RegExp('\r?\n|(?<!\n)\r', 'g');
const ANTIFRAUD_CENTER_SWITCH = 'settings.telephony.antifraud_center_switch';
const ANTIFRAUD_BESTMIND_SWITCH = 'settings.telephony.antifraud_bestmind_switch';
const BESTMIND_BUNDLE_NAME = 'com.bestmind.antifraud.hmy';
const CENTER_BUNDLE_NAME = 'com.hicorenational.antifraud.hmy';
const FOLD_DISPLAY_MODE_ALL_EXPANDED = 5;
const LIGHT_CARD_COLOR = '#E5000000';
const DARK_CARD_COLOR = '#E5FFFFFF';

interface BlankHeightParams {
  nameMarkBottom: number;
  multiButtonHeight: number;
  phoneNumbersHeight: number;
  threePartyListHeight: number;
  configurationInformationHeight: number;
  ringtoneHeight: number;
  callRecordsTitleHeight: number;
  callRecordsListHeight: number;
}

@Component
export struct ContactDetailContent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link @Watch('mPresenterWatch') private mPresenter: LooseObject;
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @Link selectSimBuilder: SelectDialogBuilder;
  @Link clearDetailCallLog: boolean;
  @Link isInBlock: boolean;
  @State displayNameTextAlign: TextAlign = TextAlign.Center;
  @Link isMarked: boolean;
  @Link markType: string;
  @Link @Watch('updateContactDetailDisplayNameText') markContent: string;
  @Link markCustom: string;
  @Link markSource: string;
  @Link markCount: number;
  @Link @Watch('updateContactDetailDisplayNameText') isCloud: boolean;
  @Link markDetails: string;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('isRouterBack') @Watch('onBackIndex') isRouterBack: boolean = false;
  @StorageLink('fullScreenPadding') @Watch('updateColumnHeight') fullScreenPadding: Padding = {};
  @StorageProp('windowRect') @Watch('onWindowRectChange') windowRect?: window.RectChangeOptions = undefined;
  private curMoveHeight: number = 0;
  private scroller: ListScroller = new ListScroller();
  cardTelListScroller: Scroller = new Scroller();
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('updateContactInfo') @Watch('updateContactInfoChange') updateContactInfo: LooseObject = {};
  @StorageProp('isVerde') @Watch('onVerdeChange') isVerde: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 联系人详情 选择铃声半模态页面显示/关闭
  @StorageLink('isRingToneShow') isRingToneShow: boolean = false;
  @StorageProp('isShowJumpButton') isShowJumpButton: boolean = false;
  @State @Watch('onRingtoneInfoChange') ringtoneInfo: RingtoneInfo = {
    ringtoneName: '',
    ringtoneFilePath: '',
    ringtonePath: ''
  };
  private dustbinAnimationEnabled: boolean = true;
  recordType: number = 0;
  // 畅联能力是否刷新
  @StorageLink('isMeeTimeAbility') isMeeTimeAbility: boolean = false;
  @State isShow: boolean = false;
  @State isAvtarMenuShown: boolean = false
  @State maximum: number = 3;
  @Link callLogTotal: number;
  @State telephoneTotal: number = 0;
  // 畅联信息显示数量
  @State meettingTotal: number = 0;
  @State otherTotal: number = 0;
  @State ringtoneTotal: number = 1;
  @State moreOptionsFlag: boolean = false;
  @State formatNumber: string = '';
  @State avatarImageUrl: string = '';
  @State isPhoneMenuShow: boolean = false;
  @State isVideoMenuShow: boolean = false;
  @State isMessageMenuShow: boolean = false;
  @State headAngle: number = 0;
  @State bodyAngle: number = 0;
  @State swipeScale: number = 1;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageProp('windowHeightPx') @Watch('updateColumnHeight') windowHeightPx: number = 0;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @Link canBeShared: boolean;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  sendMsgParams: CustomizedParams = {
    ENC: 1,
    ISKNOW: 0
  };
  // 详情页滑动相关参数
  @State isSwipe: boolean = false;
  isAdsorb: boolean = false; // 页面是否吸附
  willReset: boolean = false; // 页面将要复位
  @State headerScale: number = 1; // 控制头像缩放
  @State nameScale: number = 1; // 控制姓名缩放
  @State scrollAnimationOpacity: number = 1; // 控制头像、姓名、公司透明度
  @Link titleNameOpacity: number;
  columnHeight: number = 0;
  @Link titleDisplayName: string;
  @StorageProp('isInDetailLongPress') isInDetailLongPress: boolean = false;
  @StorageProp('voicemailNumbers') @Watch('updateContactDetailDisplayNameText') voicemailNumbers: string[] = ['', ''];
  @StorageLink('isDistributedModemState') isDistributedModemState: boolean = false;
  @StorageLink('isDistributedCallPhoneSharing') isDistributedCallPhoneSharing: boolean = false;
  @StorageLink('isDistributedCallSMSSharing') isDistributedCallSMSSharing: boolean = false;
  @StorageLink('isDistributedCallSourcePhone') isDistributedCallSourcePhone: boolean = false;
  @State message: Record<string, number | string | Resource> = {};
  @State abstractProfile: string = ''; // 数据库无摘要内容时默认摘要字段值

  SCROLL_LIMIT: number = 42; // 上滑位移阈值
  BACKGROUND_YOFFSET: number = 186; // 头像上边距（42）+头像高度（120）+姓名上边距（24）
  PULL_DISTANCE: number = 180;
  PULL_LIMIT: number = px2vp(this.PULL_DISTANCE); // 下拉阈值
  INITIAL_VALUE: number = 1;
  NAME_SCALE_PULL_LIMIT: number = 1.05;
  HEADER_SCALE_PULL_LIMIT: number = 1.1;
  NAME_SCALE_PULL_CHANGE: number = 0.05;
  HEADER_SCALE_PULL_CHANGE: number = 0.1;
  SCALE_LIMIT: number = 0.9;
  SCALE_LIMIT_OTHER: number = 0.10;
  OPACITY_MAX: number = 1;
  OPACITY_MIN: number = 0;
  adsorbHeight: number = 0;
  displayNameHeight: number = 0;
  cardPhotoYPosInitValue: number = 0;
  @State cardPhotoYPos: number = 0;
  private speedDialEditCommon: SpeedDialEditCommon = new SpeedDialEditCommon();
  private isPC: boolean = EnvironmentProp.isPC();
  @State blankHeight: number = 0;
  @State titleBarHeight: number = 56;
  @State @Watch('updateBlankHeight') blankHeightParams: BlankHeightParams = {
    nameMarkBottom: 24,
    multiButtonHeight: 0,
    phoneNumbersHeight: 0,
    threePartyListHeight: 0,
    configurationInformationHeight: 0,
    ringtoneHeight: 0,
    callRecordsTitleHeight: 0,
    callRecordsListHeight: 0
  }
  mSystemModeController = SystemModeController.getInstance();
  // 缩放值 (0.9到1.0之间)
  @State scaleValue: number = 1;
  // 畅联能力刷新时高度布局变化值
  @State translateY: number = 0;
  // 透明度 (0到1之间)
  @State opacityValue: number = 0;
  @State cardPhotoInitValue: number = 0;

  @Provide('isNewCallingShow') isNewCallingShow: boolean = true;
  private isFoldStatusSatisfyNewCallingShow: boolean = true;
  private isWindowStatusSatisfyNewCallingShow: boolean = true;
  @StorageLink('windowStatus') @Watch('onWindowStatusChange') windowStatus: window.WindowStatusType =
    window.WindowStatusType.UNDEFINED;
  @StorageLink('foldDisplayMode') @Watch('onFoldDisplayModeChange') foldDisplayMode: display.FoldDisplayMode =
    display.FoldDisplayMode.FOLD_DISPLAY_MODE_UNKNOWN;
  @StorageLink('isDistributeSink') @Watch('onDistributeSinkChange') isDistributeSink: boolean = false;

  private initNewCallingShow(): void {
    if (DeviceUtil.isFoldable()) {
      this.onFoldDisplayModeChange();
    }
    this.onWindowStatusChange();
    this.onDistributeSinkChange();
  }

  private onDistributeSinkChange(): void {
    HiLog.i(TAG, `onDistributeSinkChange isDistributeSink: ${this.isDistributeSink}`);
    this.updateNewCallingShow();
  }

  private onFoldDisplayModeChange(): void {
    HiLog.i(TAG, `onFoldDisplayModeChange foldDisplayMode: ${this.foldDisplayMode}`);
    switch (this.foldDisplayMode) {
      case display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL:
      case display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN:
      case FOLD_DISPLAY_MODE_ALL_EXPANDED:
        this.isFoldStatusSatisfyNewCallingShow = true;
        break;
      default:
        this.isFoldStatusSatisfyNewCallingShow = false;
        break;
    }
    this.updateNewCallingShow();
  }

  private onWindowStatusChange() {
    HiLog.i(TAG, `onWindowStatusChange, windowStatus: ${this.windowStatus}`);
    switch (this.windowStatus) {
      case window.WindowStatusType.FLOATING:
      case window.WindowStatusType.SPLIT_SCREEN:
        this.isWindowStatusSatisfyNewCallingShow = false;
        break;
      default:
        this.isWindowStatusSatisfyNewCallingShow = true;
        break;
    }
    this.updateNewCallingShow();
  }

  private updateNewCallingShow(): void {
    // 折叠屏小屏/分屏/小窗/通信共享时不支持显示新通话
    this.isNewCallingShow =
      this.isFoldStatusSatisfyNewCallingShow && this.isWindowStatusSatisfyNewCallingShow && (!this.isDistributeSink);
    HiLog.i(TAG, `updateNewCallingShow, isNewCallingShow: ${this.isNewCallingShow}`);
  }

  queryAntiFraudApp(bundleName: string) {
    try {
      const bundleInfo =
        bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
      if (bundleInfo.signatureInfo) {
        return true;
      }
    } catch (err) {
      HiLog.i(TAG, 'anti fraud app not found.');
    }
    return false;
  }

  onWindowRectChange() {
    HiLog.i(TAG,
      `onWindowRectChange windowRect:${this.windowRect?.rect.height}, curBp:${this.curBp}, curMoveHeight:${this.curMoveHeight}, isAdsorb:${this.isAdsorb}`)
    setTimeout(() => {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: this.curMoveHeight >= this.BACKGROUND_YOFFSET + this.adsorbHeight ? this.curMoveHeight :
            this.isAdsorb ?
            this.BACKGROUND_YOFFSET + this.adsorbHeight : 0,
      })
      this.titleNameOpacity =
        this.curMoveHeight >= this.BACKGROUND_YOFFSET + this.adsorbHeight || this.isAdsorb ? 1 : 0;
    }, 100)
  }

  updateColumnHeight() {
    try {
      let paddingTop: number = 0;
      if (typeof this.fullScreenPadding.top === 'number') {
        paddingTop = this.fullScreenPadding.top;
      }
      // 初始空白为屏幕高度 - (上下组件高度 + 详情信息的外边距)
      let deviceHeight = px2vp(display.getDefaultDisplaySync().height);
      // 减去标题栏+状态栏
      this.columnHeight = deviceHeight - (56 + px2vp(paddingTop));
      if (this.isPC) {
        this.columnHeight = px2vp(this.windowHeightPx) - this.titleBarHeight - px2vp(paddingTop);
      }
      HiLog.w(TAG, `updateColumnHeight columnHeight: ${this.columnHeight}`)
      this.updateBlankHeight();
    } catch (err) {
      HiLog.e(TAG, `updateColumnHeight err: ${err?.message}`);
    }
  }

  updateBlankHeight() {
    let paddingBottom: number = 0;
    if (typeof this.fullScreenPadding.bottom === 'number') {
      paddingBottom = this.fullScreenPadding.bottom;
    }
    let blankHeight = this.columnHeight - this.blankHeightParams.nameMarkBottom -
    this.blankHeightParams.multiButtonHeight - this.blankHeightParams.phoneNumbersHeight -
    this.blankHeightParams.threePartyListHeight - this.blankHeightParams.configurationInformationHeight -
    this.blankHeightParams.ringtoneHeight - this.blankHeightParams.callRecordsTitleHeight -
    this.blankHeightParams.callRecordsListHeight - (px2vp(paddingBottom) + 16)

    this.blankHeight = blankHeight > 0 ? blankHeight : 0;
    HiLog.w(TAG, `updateBlankHeight blankHeight: ${this.blankHeight}`)
  }

  @State textShowType: number = -1;
  @State companyTextWidth: number = 0;
  @State positionTextWidth: number = 0;
  @State companyPositionDivWidth: number = 0;
  @State photoHeight: number = 0;
  @State nameAndMarkHeight: number = 0;
  @State callBtnHeight: number = 0;
  @StorageProp('currentColorMode') @Watch('onDarkModeChanged') currentColorMode: boolean = false;
  @StorageLink('isOnCallSharingValue') isOnCallSharingValue: boolean = false;
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @State cardBtnBackEffect: BackgroundEffectOptions = {
    radius: 10,
    color: this.currentColorMode ? '#33ffffff' : '#33000000',
  };
  normalBtnBackEffect: BackgroundEffectOptions = {
    radius: 100,
    color: $r('sys.color.icon_fourth')
  };
  @State customBtnBackEffect: BackgroundEffectOptions = {
    radius: 10,
    color: $r('sys.color.icon_fourth')
  };
  customNormalBtnBackEffect: BackgroundEffectOptions = {
    radius: 100,
    color: $r('sys.color.icon_fourth')
  };

  mPresenterWatch() {
    this.telephoneTotal = this.mPresenter.contactForm.phones.length;
    // 存在不是家庭设备的设备，才可以拨打畅联手机电话和视频；否则不可以拨打
    // 显示内容数量里 是否显示畅联手机电话和视频，根据标志位判断
    let meetimePhoneShowCount = 0;
    if (this.mPresenter.isHasNotFamilyDeviceFlag) {
      meetimePhoneShowCount = 1;
    }
    this.meettingTotal = (this.mPresenter.isMeeTimeLoginFlag && this.mPresenter.isHasMeeTimeAbilityFlag) ?
      meetimePhoneShowCount + this.mPresenter.meeTimeDeviceList.totalCount() : 0;
    this.otherTotal =
      this.mPresenter.contactForm.emails.length +
      this.mPresenter.contactForm.aims.length +
      this.mPresenter.contactForm.websites.length +
      this.mPresenter.contactForm.houses.length +
      this.mPresenter.contactForm.events.length +
      this.mPresenter.contactForm.relationships.length
    this.canBeShared = this.mPresenter.canBeShared;
    let photo: PixelMap = this.mPresenter.cardPhotoPixelMap;
    HiLog.i(TAG, `cardPhoto: ${photo?.getPixelBytesNumber()}`)
  }

  updateTextWidth() {
    if (!StringUtil.isEmpty(this.mPresenter.contactForm.company)) {
      this.companyTextWidth = px2vp(MeasureText.measureText({
        textContent: this.mPresenter.contactForm.company,
        fontSize: $r('sys.float.ohos_id_text_size_body2'),
        fontWeight: FontWeight.Regular,
        fontFamily: 'HarmonyHeiTi',
        maxLines: 1
      }))
    } else {
      this.companyTextWidth = 0;
    }
    if (!StringUtil.isEmpty(this.mPresenter.contactForm.position)) {
      this.positionTextWidth = px2vp(MeasureText.measureText({
        textContent: this.mPresenter.contactForm.position,
        fontSize: $r('sys.float.ohos_id_text_size_body2'),
        fontWeight: FontWeight.Regular,
        fontFamily: 'HarmonyHeiTi',
        maxLines: 1
      }))
    } else {
      this.positionTextWidth = 0;
    }
  }

  @Styles
  toolBar() {
    .width(this.isVerde ? '48vp' : '56vp')
    .height(this.isVerde ? '48vp' : '56vp')
    .borderRadius('48vp')
    .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
  }

  @Styles
  card() {
    .width('100%')
    .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') :
      $r('app.float.rounded_corners_width_20'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .padding({
      top: $r('app.float.item_margin_width_4'),
      bottom: $r('app.float.item_margin_width_4'),
      left: $r('app.float.item_margin_width_4'),
      right: $r('app.float.id_card_margin_mid'),
    })
  }

  @Styles
  buttonStyle(){
    .borderRadius(20)
    .height($r('app.float.id_item_height_sm'))
    .width($r('app.float.id_item_height_sm'))
    .margin($r('app.float.id_card_margin_xl'))
  }

  @Builder
  simCardListDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .strokeWidth('1px')
      .width('100%')
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
      .visibility(Visibility.Visible)
  }

  // 获取sim卡数量
  getSimCardNumber() {
    this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
    let spnList = AppStorage.get<Array<string | Resource>>('spnList');
    if (spnList && this.selectSimBuilder.multiSimCardItems) {
      for (let index = 0; index < spnList.length; index++) {
        this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
      }
    }
    return this.selectSimBuilder
  }

  isPrimaryIndex(): number {
    return this.mPresenter.contactForm.phones.findIndex((item: LooseObject) => {
      return item.primary == true
    });
  }

  getText(phoneNumInfo: ContackPhoneSubInfoModel) {
    let labelStr = ''

    //黄页只显示电话类型
    if (this.mPresenter.contactId === undefined && this.mPresenter.isYellowPage) {
      labelStr += phoneNumInfo.labelName;
      return labelStr;
    }

    // 陌生人进入详情页，不显示电话类型前缀
    if (this.mPresenter.contactId > 0 && phoneNumInfo.labelName != undefined) {
      if (Number.parseInt(phoneNumInfo.type as string) == PhoneAccountType.TYPE_ID_CUSTOM) {
        labelStr += phoneNumInfo.labelName
      } else {
        labelStr += ResourceUtil.getStringByResourceId((phoneNumInfo.labelName as Resource).id)
      }
    }

    return labelStr
  }

  @Builder
  simCardListBuilder(callType: string) {
    if (this.mPresenter.contactForm.phones.length > 1 && this.isPrimaryIndex() == -1) {
      Menu() {
        ForEach(this.mPresenter.phoneDataSources.getAllData(), (item: ContackPhoneSubInfoModel, index: number) => {
          ContactDetailMenuItem({
            phone: item?.num,
            labelInfo: this.getText(item),
            callType: callType,
            item: item,
            selectSimBuilder: $selectSimBuilder,
            mPresenter: $mPresenter,
          })
            .width('100%')
          if ((index + 1) !== this.mPresenter.phoneDataSources.totalCount()) {
            this.MenuDivider();
          }
        }, (item: ContactStrInterface) => JSON.stringify(item))
      }
      .width($r('app.float.account_MenuBuilder_width_xl'))
    }
  }

  public getDisplayNameForAutoSize(name: ResourceStr | undefined, curBp: string): number {
    let fontSize = 38;
    let size = 16;
    let widthVp =
      curBp === 'sm' ?
        (px2vp(display.getDefaultDisplaySync().width) - size * 2) * 0.8 :
        (px2vp(display.getDefaultDisplaySync().width) - size * 2) * 0.8
    do {
      let num = px2vp(measure.measureText({
        textContent: name,
        fontSize: fontSize,
        fontWeight: 600
      }));
      if (num < widthVp) {
        break;
      }
    } while (--fontSize > 24);
    return fontSize;
  }

  public getCallTextHeight(name: ResourceStr | undefined, curBp: string): number {
    let size: number = curBp === 'sm' ? 16 : curBp === 'md' ? 24 : 32;
    let widthVp = (px2vp(display.getDefaultDisplaySync().width) - size * 2);
    let num = px2vp(measure.measureText({
      textContent: name,
      fontSize: 24,
      fontWeight: 600
    }));
    if (num > widthVp) {
      return 64;
    }
    return 50;
  }

  // 清空通话记录
  clearCallLogDialogController?: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.clear_calllog_sure'),
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
          this.callLogTotal = 0;
          this.mPresenter.clearAllCallLog();
          this.clearDetailCallLog = true;
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  onBackIndex() {
    if (this.isRouterBack) {
      AppStorage.SetOrCreate('mainTabsIndex', this.mIndexPresenter.callIndex);
      if (this.curBp === 'sm') {
        this.pathInfos.pop();
      } else {
        HiLog.w(TAG, 'pathInfos onBackIndex: ContactDefaultPage');
        CallRecordPresenter.getInstance().toDefaultPage();
      }
    }
    this.isRouterBack = false;
  }

  // 删除通话记录
  @State deleteCallLogId: number = -1
  deleteCallLogDialogController?: CustomDialogController = new CustomDialogController({
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
          CallRecordPresenter.getInstance().deleteCallLog([this.deleteCallLogId], []);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  onVerdeChange() {
    // 内外屏切换，详情页接续，部分变量需要初始化
    this.adsorbHeight = 0;
    this.displayNameHeight = 0;
    this.cardPhotoYPosInitValue = 0;
    this.initCardPhotoYPos();
    this.updateColumnHeight();
  }

  async initCardPhotoYPos() {
    try {
      let windowClass: window.Window = await window.getLastWindow(getContext(this));
      if (windowClass) {
        let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let statusBarHeight = avoidArea.topRect.height;
        this.cardPhotoYPos = this.isPC ? (-px2vp(statusBarHeight) - ACTION_AREA_DISTANCE) : 0;
        this.cardPhotoYPosInitValue = this.isPC ? (-px2vp(statusBarHeight) - ACTION_AREA_DISTANCE) : 0;
        this.cardPhotoInitValue = -px2vp(statusBarHeight) - ACTION_AREA_DISTANCE;
        HiLog.i(TAG, `initCardPhotoYPos: ${this.cardPhotoYPos}`)
      }
    } catch (exception) {
      HiLog.e(TAG, 'Failed to obtain the top window. Cause: ' + (exception as BusinessError).message);
    }
  }

  onDarkModeChanged() {
    HiLog.i(TAG, `onDarkModeChanged colorMode:${this.currentColorMode}`);
    this.cardBtnBackEffect = {
      radius: 10,
      color: this.currentColorMode ? '#33ffffff' : '#33000000',
    }
  }

  onRingtoneInfoChange() {
    HiLog.i(TAG, `onRingtoneInfoChange`);
    this.mPresenter.contactForm.personalNotificationRingtone = this.ringtoneInfo.ringtoneName;
    this.mPresenter.contactForm.personalRingtone = this.ringtoneInfo.ringtonePath;
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'aboutToAppear...');
    this.updateColumnHeight();
    this.initCardPhotoYPos();
    let ringtone: RingtoneInfo = {
      ringtoneName: this.mPresenter.contactForm.personalNotificationRingtone,
      ringtoneFilePath: this.mPresenter.contactForm.personalRingtonePath,
      ringtonePath: this.mPresenter.contactForm.personalRingtone,
    }
    this.ringtoneInfo = ringtone;
    this.mPresenter.refreshDetailUI = () => {
      HiLog.i(TAG, 'refreshDetailUI');
      this.updateContactDetailDisplayNameText();
      this.updateTextWidth();
      let ringtoneNew: RingtoneInfo = {
        ringtoneName: this.mPresenter.contactForm.personalNotificationRingtone,
        ringtoneFilePath: this.mPresenter.contactForm.personalRingtonePath,
        ringtonePath: this.mPresenter.contactForm.personalRingtone,
      }
      if (ringtoneNew.ringtoneName != this.ringtoneInfo.ringtoneName ||
        ringtoneNew.ringtonePath != this.ringtoneInfo.ringtonePath) {
        this.ringtoneInfo = ringtoneNew;
      }
    }
    this.mPresenterWatch()
    this.mPresenter.showLogTitleFlagRefreshFun = (callLogTotal: number) => {
      this.callLogTotal = callLogTotal
      HiLog.i(TAG, `showLogTitleFlagRefreshFun:${this.callLogTotal}`)
    };
    this.mPresenter.updatePhoneNums = () => {
      HiLog.i(TAG, 'updatePhoneNums');
      this.telephoneTotal = this.mPresenter.contactForm.phones.length;
    }
    this.formatNumber = PhoneNumber.fromString(this.mPresenter.contactForm.phones[0]?.data).dynamicPhoneFormat();
    this.updateContactDetailDisplayNameText();
    this.ringtoneTotal = (this.isFromMeetime || this.mPresenter.isMyCard || !call.hasVoiceCapability()) ? 0 : 1;
    this.updateTextWidth();
    this.initNewCallingShow();
  }

  updateContactInfoChange() {
    HiLog.i(TAG, 'updateContactInfoChange');
    this.scrollAnimationOpacity = 1;
    this.nameScale = 1;
    this.headerScale = 1;
  }

  aboutToDisappear() {
    this.deleteCallLogDialogController = undefined;
    this.ringtoneInfo.ringtoneName = '';
    this.ringtoneInfo.ringtonePath = '';
  }

  toPoint(percent: string) {
    let str = percent.replace('%', '');
    let num = Number(str) / 100;
    return num;
  }

  toPercent(point: number) {
    let percent = Number(point * 100).toFixed(4);
    percent += '%';
    return percent;
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .strokeWidth('1px')
      .width('100%')
      .alignSelf(ItemAlign.Stretch)
      .visibility(Visibility.Visible)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  @Builder
  doClickAvatar() {
    Menu() {
      if (this.mPresenter.photoPixelMap) {
        MenuItem({ content: $r('app.string.delete_picture') })
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onChange(() => {
            this.mPresenter.photoPixelMap = null;
            this.mPresenter.blobSource = -1;
            delFileById(this.mPresenter.contactId.toString(), true);
            let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
            // 处理头像
            dealContactPhoto(this.mPresenter.contactId.toString(), context, null, false, false, true, 3);
            // 更新2*2快速拨号卡片头像
            this.updateToCardInfo();
          })
        this.MenuDivider();
      }
      if (!this.isInVisionGlass) {
        MenuItem({ content: $r('app.string.take_photo') })
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .onChange(async () => {
            HiLog.i(TAG, 'take_photo');
            this.doTakePhoto();
          })
        if (!this.isShowJumpButton) {
          this.MenuDivider();
        }
      }
      MenuItem({ content: $r('app.string.select_picture') })
        .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onChange(async () => {
          try {
            let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
            photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;
            let photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              if (photoSelectResult) {
                HiLog.i(TAG, 'PhotoViewPicker.select successfully');
                this.avatarImageUrl = photoSelectResult.photoUris[0];
                if (!StringUtil.isEmpty(this.avatarImageUrl)) {
                  this.isShow = true;
                }
              }
            }).catch((err: BusinessError) => {
              HiLog.e(TAG, 'PhotoViewPicker.select failed with err: ' + err?.message + ', stack: ' + err?.stack);
            });
          } catch (err) {
            HiLog.e(TAG, 'PhotoViewPicker failed with err: ' + err);
          }
        })
        .visibility(this.isShowJumpButton ? Visibility.None : Visibility.Visible)
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2')
    })
    .radius($r('sys.float.corner_radius_level10'))
    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }

  // take photo
  async doTakePhoto() {
    try {
      let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      const photoProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
      }
      let pickerResult: cameraPicker.PickerResult =
        await cameraPicker.pick(context, [cameraPicker.PickerMediaType.PHOTO], photoProfile);
      if (pickerResult.resultCode === 0) {
        this.avatarImageUrl = pickerResult.resultUri;
        if (!StringUtil.isEmpty(this.avatarImageUrl)) {
          this.isShow = true;
        }
      } else {
        HiLog.e(TAG, 'camerapicker error,error code is: ' + pickerResult.resultCode);
      }
    } catch (err) {
      HiLog.e(TAG, 'selected imageList error ' + err?.message + ', stack: ' + err?.stack);
    }
  }

  // 滑动动效
  headerAnimation(scroller: Scroller, scrollOffset: number): void {
    const currentOffset = scroller.currentOffset();
    const yOffset = Math.floor(currentOffset.yOffset);
    if (this.displayNameHeight === 0) {
      let contactName: componentUtils.ComponentInfo = componentUtils.getRectangleById('ContactDetail_displayNameText');
      this.displayNameHeight = px2vp(contactName.size.height);
    }
    if (yOffset > 0) {
      this.cardPhotoYPos = this.cardPhotoYPosInitValue - yOffset;
    }
    if (yOffset < this.SCROLL_LIMIT && yOffset >= 0) {
      // 上滑距离未超过阈值
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 300, 35)
      }, () => {
        this.headerScale = this.INITIAL_VALUE - (this.SCALE_LIMIT_OTHER * (yOffset / this.SCROLL_LIMIT));
        this.nameScale = this.INITIAL_VALUE - (this.SCALE_LIMIT_OTHER * (yOffset / this.SCROLL_LIMIT));
      })
      this.scrollAnimationOpacity = this.OPACITY_MAX;
      this.titleNameOpacity = this.OPACITY_MIN;
    } else if (yOffset >= this.SCROLL_LIMIT && yOffset < this.BACKGROUND_YOFFSET + this.displayNameHeight) {
      if (scrollOffset < 0 && this.isAdsorb && !this.willReset) {
        HiLog.i(TAG, `headerAnimation willReset`);
        this.willReset = true;
      }
      // 上滑距离超过阈值，姓名与标题栏姓名变化
      this.titleNameOpacity = this.INITIAL_VALUE -
        ((this.BACKGROUND_YOFFSET + this.displayNameHeight - yOffset) / this.displayNameHeight);
      this.scrollAnimationOpacity = this.INITIAL_VALUE - this.titleNameOpacity;
    } else if (yOffset < 0) {
      // 下拉联动
      if (-yOffset <= this.PULL_LIMIT) {
        animateTo({
          curve: curves.interpolatingSpring(0, 1, 228, 30)
        }, () => {
          this.nameScale = (-yOffset / this.PULL_LIMIT * this.NAME_SCALE_PULL_CHANGE) + this.INITIAL_VALUE;
          this.headerScale = (-yOffset / this.PULL_LIMIT * this.HEADER_SCALE_PULL_CHANGE) + this.INITIAL_VALUE;
        })
      } else {
        if (this.nameScale !== this.NAME_SCALE_PULL_LIMIT) {
          this.nameScale = this.NAME_SCALE_PULL_LIMIT;
          this.headerScale = this.HEADER_SCALE_PULL_LIMIT;
        }
      }
    } else {
      this.titleNameOpacity = this.OPACITY_MAX;
    }
  }

  //stopAnimation
  stopAnimation(scroller: Scroller): void {
    const currentOffset = scroller.currentOffset();
    const yOffset = Math.floor(currentOffset?.yOffset);
    this.curMoveHeight = yOffset;
    // 详情页长按不触发复位及吸附动效
    if (this.isInDetailLongPress) {
      HiLog.i(TAG, 'stopAnimation isInDetailLongPress return');
      return;
    }
    if ((yOffset < this.SCROLL_LIMIT && yOffset >= 0) || (this.isAdsorb && this.willReset &&
      yOffset >= this.SCROLL_LIMIT && yOffset < this.BACKGROUND_YOFFSET + this.adsorbHeight)) {
      HiLog.i(TAG, 'header reset ');
      // 上滑复位: 1.上滑的时候没达到阈值回弹; 2.已吸附的前提下，再下拉要回弹
      this.isAdsorb = false;
      this.willReset = false;
      scroller.scrollTo({
        xOffset: 0,
        yOffset: 0,
        animation: {
          curve: curves.interpolatingSpring(0, 1, 300, 35)
        }
      })
    } else if (yOffset >= this.SCROLL_LIMIT && yOffset < this.BACKGROUND_YOFFSET + this.adsorbHeight) {
      HiLog.i(TAG, 'header adsorb ');
      // 上滑吸附位置需要根据姓名、公司、职位的高度变化
      scroller.scrollTo({
        xOffset: 0,
        yOffset: this.BACKGROUND_YOFFSET + this.adsorbHeight,
        animation: {
          curve: curves.interpolatingSpring(0, 1, 300, 35)
        }
      })
      this.isAdsorb = true;
    }
  }

  getEditAvtarSubTitleStr() {
    let subTitleStr: string | undefined = '';
    if (this.mPresenter.contactForm.remarks) {
      subTitleStr = this.mPresenter.contactForm.remarks;
    } else if (this.mPresenter.contactForm.phones.length > 0) {
      let phoneNum = this.mPresenter.contactForm.phones[0].num as string;
      subTitleStr = PhoneNumber.fromString(phoneNum).phoneNumFormat();
    }
    return subTitleStr;
  }

  @Builder
  CutoutAvatar() {
    Column() {
      EditAvatar({
        isShow: $isShow,
        uri: this.avatarImageUrl,
        onFinish: (pixelMap: image.PixelMap, scaledPixelMap: image.PixelMap) => {
          HiLog.w(TAG, `CutoutAvatarFinish`)
          if (pixelMap && scaledPixelMap) {
            let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
            let hasPhoto: boolean = this.mPresenter.photoPixelMap ? true : false;
            getImagePackingData(scaledPixelMap, async (data: ArrayBuffer | null) => {
              if (data != null) {
                let photoUpdate: Uint8Array | null = new Uint8Array(data);
                // 大头像信息一起入库
                let imageInfo = await pixelMap.getImageInfo();
                let height = imageInfo.size.height;
                let width = imageInfo.size.width;
                let blobSource = 3;
                if (height * width <= MIN_RESOLUTION) {
                  blobSource = 1;
                }
                if (hasPhoto) {
                  dealContactPhoto(this.mPresenter.contactId.toString(), context, photoUpdate, false, true, false,
                    blobSource);
                  // 更新2*2快速拨号卡片头像
                  this.updateToCardInfo();
                } else {
                  dealContactPhoto(this.mPresenter.contactId.toString(), context, photoUpdate, true, false, false,
                    blobSource);
                  // 更新2*2快速拨号卡片头像
                  this.updateToCardInfo();
                }
                // 清理对应联系人的头像缓存，防止取到旧头像
                PixelMapManager.getInstance().deleteContactListIdMiniPixelMap(this.mPresenter.contactId.toString());
              } else {
                HiLog.w(TAG, 'getImagePackingData: data null');
              }
            })
            pixelMap.getImageInfo().then((imageInfo) => {
              let height = imageInfo.size.height;
              let width = imageInfo.size.width;
              HiLog.w(TAG, `height: ${height}, width: ${width}`)
              if (height * width <= MIN_RESOLUTION) {
                this.mPresenter.blobSource = 1;
                this.mPresenter.photoPixelMap = scaledPixelMap;
              } else {
                this.mPresenter.blobSource = 3;
                this.mPresenter.cardPhotoPixelMap = pixelMap;
                this.mPresenter.updateLightColor();
              }
            })
            saveImageToFile(pixelMap, this.mPresenter.contactId.toString());
          }
        },
        displayTitle: this.titleDisplayName,
        displaySubTitle: this.getEditAvtarSubTitleStr()
      })
    }
    .width('100%')
    .height('100%')
  }

  // 编辑联系人头像之后，需要更新快速拨号卡片中的联系人头像信息
  async updateToCardInfo() {
    // 从首选项中获取所有2*2快速拨号卡片ID集合
    let context: Context = getContext(this)
    sharedPreferencesUtils.init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    await sharedPreferencesUtils.removePreferencesFromCache('speedDialCardIdList');
    let speedDialCardIdList: string[] =
      await sharedPreferencesUtils.getFromPreferences('speedDialCardIdList', []) as string[];
    if (speedDialCardIdList && speedDialCardIdList.length > 0) {
      speedDialCardIdList.forEach(async (formId) => {
        // 通过formId获取保存在数据库中的2*2快速拨号卡片联系人信息
        let speedDialData: SpeedDialDataType[] = await this.speedDialEditCommon.queryContactByFormId(formId, context);
        if (speedDialData != null) {
          //更新卡片
          let randomData = await FormCardController.getInstance().createRandom();
          let obj: UpdateToCardType = {
            title: 'update',
            formId: formId,
            editContacts: JSON.stringify(speedDialData),
            random: randomData
          };
          let formBinding = formBindingData.createFormBindingData(obj);
          this.speedDialEditCommon.updateToCard(formId.toString(), formBinding);
        }
      })
    }
  }

  // 视频呼叫打点
  detailVideoCallDot(slot: number, isMultiSIMCard: number, hasDefaultSIMCard: number, registeredVoLTECard: number) {
    videoCallParams.ENC = 1;
    videoCallParams.SLOT = slot;
    videoCallParams.ISMULTISIMCARD = isMultiSIMCard;
    videoCallParams.HAS_DEFAULT_SIM_CARD = hasDefaultSIMCard;
    videoCallParams.REGISTERED_VOLTE_CARD = registeredVoLTECard;
    DotUtil.getInstance().contactDot(videoCallParams, dotCommon.eventName.VIDEO_CALLING_EVENT);
  }

  SIMCardSelection(phoneNum: string) {
    this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
    this.selectSimBuilder.callback = (value) => {
      // 联系人打点-视频呼叫-联系人详情页-双卡注册两张VoLTE卡
      this.detailVideoCallDot(value, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_FALSE,
        dotCommon.eventParam.CARD_NUMBER_TWO);
      const optionsObj: call.DialOptions = {
        accountId: value,
        videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
      }
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, optionsObj);
    }
    this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
    let spnList = AppStorage.get<Array<string | Resource>>('spnList');
    if (spnList && this.selectSimBuilder.multiSimCardItems) {
      for (let index = 0; index < spnList.length; index++) {
        this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
      }
    }
    this.selectSimBuilder.controller?.open();
  }

  videoCalling(item: ContackPhoneSubInfoModel) {
    let phoneNum = item.num;
    const isAllRegvoLteStates = this.voLteRegStates[0] && this.voLteRegStates[1];
    if (this.haveMultiSimCard) {
      if (!isAllRegvoLteStates) {
        let accountId: number = this.voLteRegStates[0] ? 0 : 1;
        // 联系人打点-视频呼叫-联系人详情页-双卡只注册一个VoLTE卡
        this.detailVideoCallDot(accountId, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_FALSE,
          dotCommon.eventParam.CARD_NUMBER_ONE);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: accountId,
          videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
        });
        return;
      }
      // 双卡模式下都具备视频通话能力并且设置了默认卡号
      if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
        HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: this.defaultSlot,
          videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
        });
        return;
      } else {
        HiLog.w(TAG, 'videoCalling: no defaultSlot');
      }
      this.SIMCardSelection(phoneNum as string);
    } else {
      let accountId: number = AppStorage.Get<number>('defaultSlot') as number;
      // 联系人打点-视频呼叫-联系人详情页-单卡
      this.detailVideoCallDot(accountId, dotCommon.eventParam.SELECT_FALSE, dotCommon.eventParam.SELECT_FALSE,
        dotCommon.eventParam.CARD_NUMBER_ONE);
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
        accountId: accountId,
        videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
      });
    }
  }

  async voiceCalling(item: ContackPhoneSubInfoModel) {
    let phoneNum = item.num;
    if (call.hasVoiceCapability() ||
      (AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState') &&
      AppStorage.get('isDistributedCallSourcePhone'))) {
      CallLogSearchBo.getInstance().refreshCallChangeFlag();
      if (this.haveMultiSimCard) {
        // 双卡下设置默认卡号直接拨打电话
        if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
          HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: this.defaultSlot });
          return;
        } else {
          HiLog.w(TAG, 'voiceCalling no defaultSlot');
        }
        const directAccountId = getDialDirectlyAccountId(this.mPresenter.dsdsMode)
        if (directAccountId !== undefined) {
          // 3.0 case!
          HiLog.i(TAG, 'Call directly through sim ' + directAccountId);
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: directAccountId });
          return;
        }
        this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
        this.selectSimBuilder.callback = (value) => {
          const accountIdObj: call.DialOptions = {
            accountId: value,
          }
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, accountIdObj);
        }
        this.selectSimBuilder.gotoDialer = () => {
          AppStorage.SetOrCreate('isRouterBack', true);
          DialerPresenter.getInstance().editPhoneNumber(phoneNum as string);
          AppStorage.SetOrCreate<boolean>('showDialBtn', true);
        }
        this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
        let spnList = AppStorage.get<Array<string | Resource>>('spnList');
        if (spnList && this.selectSimBuilder.multiSimCardItems) {
          for (let index = 0; index < spnList.length; index++) {
            this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
          }
        }
        this.selectSimBuilder.controller?.open();
      } else {
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum);
      }
    }
  }

  detailSendMsg(item: ContackPhoneSubInfoModel) {
    if (this.mPresenter.contactId != undefined) {
      this.sendMsgParams.ISKNOW = 1;
    } else {
      this.sendMsgParams.ISKNOW = 0;
    }
    this.mPresenter.sendMessage(
      item.num,
      item.data,
      this.mPresenter.contactForm.displayName.toString(),
      this.mPresenter.contactId
    );
  }

  detailInfoTelListCard(): Visibility {
    let cardVisibility: Visibility = Visibility.None;
    if (this.mPresenter.isPrivateNumber) {
      return cardVisibility;
    }
    if (this.telephoneTotal > 0) {
      cardVisibility = Visibility.Visible
    } else {
      cardVisibility = Visibility.None
    }
    return cardVisibility
  }

  detailInfoTelListMore(): Visibility {
    let moreVisibility: Visibility = Visibility.None;
    if (this.mPresenter.isPrivateNumber) {
      return moreVisibility;
    }
    if (!this.moreOptionsFlag && this.detailInfoTelListCard() === Visibility.Visible &&
      ((this.telephoneTotal === this.maximum && this.meettingTotal + this.otherTotal + this.ringtoneTotal > 0) ||
        this.telephoneTotal > this.maximum)) {
      moreVisibility = Visibility.Visible;
    } else {
      moreVisibility = Visibility.None;
    }
    return moreVisibility;
  }

  detailInfoMeeTingCard(): Visibility {
    let cardVisibility: Visibility = Visibility.None;
    if (this.mPresenter.isPrivateNumber) {
      return cardVisibility;
    }
    if (this.meettingTotal > 0 && (this.telephoneTotal < this.maximum || this.moreOptionsFlag)) {
      cardVisibility = Visibility.Visible;
    } else {
      cardVisibility = Visibility.None;
    }
    return cardVisibility;
  }

  detailInfoMeeTingMore(): Visibility {
    let moreVisibility: Visibility = Visibility.None;
    if (!this.moreOptionsFlag && this.detailInfoMeeTingCard() === Visibility.Visible &&
      ((this.telephoneTotal + this.meettingTotal === this.maximum && this.otherTotal + this.ringtoneTotal > 0) ||
        this.telephoneTotal + this.meettingTotal > this.maximum)) {
      moreVisibility = Visibility.Visible;
    } else {
      moreVisibility = Visibility.None;
    }
    return moreVisibility;
  }

  detailInfoRemarksCard(): Visibility {
    let cardVisibility: Visibility = Visibility.None;
    if (this.otherTotal > 0 && (this.telephoneTotal + this.meettingTotal < this.maximum || this.moreOptionsFlag)) {
      cardVisibility = Visibility.Visible;
    } else {
      cardVisibility = Visibility.None;
    }
    return cardVisibility;
  }

  detailInfoRemarksMore(): Visibility {
    let moreVisibility: Visibility = Visibility.None;
    if (!this.moreOptionsFlag && this.detailInfoRemarksCard() === Visibility.Visible &&
      ((this.telephoneTotal + this.meettingTotal + this.otherTotal === this.maximum && this.ringtoneTotal > 0) ||
        this.telephoneTotal + this.meettingTotal + this.otherTotal > this.maximum)) {
      moreVisibility = Visibility.Visible;
    } else {
      moreVisibility = Visibility.None;
    }
    return moreVisibility;
  }

  detailInfoRingtoneListCard(): Visibility {
    let cardVisibility: Visibility = Visibility.None;
    if (!this.isFromMeetime && !this.mPresenter.isMyCard && this.mPresenter.contactId > 0 &&
      (this.telephoneTotal + this.meettingTotal + this.otherTotal < this.maximum || this.moreOptionsFlag)) {
      cardVisibility = Visibility.Visible;
    }
    return cardVisibility;
  }

  detailInfoCallLogListCard(): Visibility {
    let cardVisibility: Visibility = Visibility.None;
    if (this.mPresenter.isPrivateNumber) {
      return cardVisibility;
    }
    if (((this.isDistributedCallPhoneSharing && this.isDistributedModemState) || call.hasVoiceCapability()) &&
      this.telephoneTotal > 0 && this.callLogTotal > 0) {
      cardVisibility = Visibility.Visible;
    }
    HiLog.i(TAG,
      `detail info CallLogs show: ${cardVisibility}， telephoneTotal： ${this.telephoneTotal}, callLogTotal: ${this.callLogTotal}`)
    return cardVisibility;
  }

  isVoiceCapability(): boolean {
    let hasVoiceCapability = true;
    if (call.hasVoiceCapability()) {
      hasVoiceCapability = true
    } else {
      hasVoiceCapability = false
    }
    return hasVoiceCapability
  }

  isVideoCapability(): boolean {
    let hasVideoCapability = true;
    if ((this.haveSimCard && !this.isAirplaneMode && this.haveVoLteReg)) {
      hasVideoCapability = true
    } else {
      hasVideoCapability = false
    }
    return hasVideoCapability
  }

  @Builder
  callLogTitle() {
    SubHeader({
      secondaryTitle: $r('app.string.dialer_calllog'),
      secondaryTitleModifier: this.isThemeActive ? new TextModifier().fontColor($r('app.color.skin_font_secondary')) :
        undefined,
      operationType: OperationType.BUTTON,
      contentMargin: { start: LengthMetrics.vp(0), end: LengthMetrics.vp(0) },
      operationItem: [{
        value: $r('app.string.clear'),
        action: () => {
          this.clearCallLogDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.clearCallLogDialogController);
        }
      }]
    })
  }

  @Builder
  callLogTitleWithTheme() {
    WithTheme({
      theme: { colors: { fontEmphasize: $r('app.color.skin_font_emphasize') } as CustomColors } as CustomTheme
    }) {
      this.callLogTitle()
    }
  }

  // 联系人头像
  @Builder
  contactAvtar() {
    // 头像
    Column() {
      if (this.mPresenter.contactId != undefined && this.mPresenter.blobSource >= 0 && this.mPresenter.photoPixelMap) {
        Image(this.mPresenter.photoPixelMap)
          .height($r('app.float.id_card_image_large'))
          .width($r('app.float.id_card_image_large'))
          .objectFit(ImageFit.Auto)
          .focusable(true)
          .draggable(false)
          .borderRadius($r('app.float.id_card_image_large'))
          .onError((err: ImageError) => {
            HiLog.e(TAG, 'photoPixelMap Image onError !! err == ' + err.message);
          })
          .onComplete(() => {
            HiLog.i(TAG, 'photoPixelMap Image onComplete !!');
          })
      } else if (
        (this.mPresenter.isYellowPage || this.mPresenter.isCnap) &&
          (!StringUtil.isEmpty(getHeadChar(this.titleDisplayName)))
      ) {
        Text(getHeadChar(this.titleDisplayName))
          .fontSize('40vp')
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .focusable(true)
          .height($r('app.float.id_card_image_large'))
          .width($r('app.float.id_card_image_large'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_image_large'))
          .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .accessibilityLevel(this.mPresenter.contactId ? 'no' : 'yes')
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_avatar')))
      } else if (
        this.mPresenter.isNewNumber ||
        StringUtil.isEmpty(getHeadChar(this.titleDisplayName))
      ) {
        Image($r('app.media.ic_user_portrait'))
          .height($r('app.float.id_card_image_large'))
          .width($r('app.float.id_card_image_large'))
          .focusable(true)
          .draggable(false)
          .borderRadius($r('app.float.id_card_image_large'))
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .onError((err: ImageError) => {
            HiLog.e(TAG, 'ic_user_portrait_morandi Image onError !! err == ' + err.message);
          })
          .onComplete(() => {
            HiLog.i(TAG, 'ic_user_portrait_morandi Image onComplete !!');
          })
          .accessibilityRole(AccessibilityRoleType.TEXT)
          .accessibilityLevel(this.mPresenter.contactId ? 'no' : 'yes')
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_avatar')))
      } else {
        Column(){
          Text(getHeadChar(this.titleDisplayName))
            .fontSize($r('sys.float.ohos_id_text_size_headline4'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
            .textAlign(TextAlign.Center)
            .focusable(true)
            .accessibilityLevel(this.mPresenter.contactId ? 'no' : 'yes')
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_avatar')))
        }
        .height($r('app.float.id_card_image_large'))
        .width($r('app.float.id_card_image_large'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .borderRadius($r('app.float.id_card_image_large'))
        .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
      }
    }
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .accessibilityLevel(this.mPresenter.contactId ? 'yes' : 'no')
    .accessibilityText(AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_avatar')))
    .opacity(this.scrollAnimationOpacity)
    .scale({ x: this.headerScale, y: this.headerScale })
    .bindContentCover($$this.isShow, this.CutoutAvatar(), {
      modalTransition: ModalTransition.NONE,
    })
    .bindContextMenu(this.isAvtarMenuShown, this.doClickAvatar, {
      placement: Placement.Bottom,
      onDisappear: () => {
        this.isAvtarMenuShown = false;
      },
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
    })
    .gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
        .onAction((event: GestureEvent) => {
          if (this.mSystemModeController.getIsEnableEditAvatar()) {
            this.isAvtarMenuShown = true;
          }
        })
    ))
    .onMouse((event: MouseEvent) => {
      if (this.mSystemModeController.getIsEnableEditAvatar() &&
        event.button === MouseButton.Right && event.action === MouseAction.Release) {
        this.isAvtarMenuShown = true;
      }
    })
    .width($r('app.float.id_card_image_large'))
    .height($r('app.float.id_card_image_large'))
    .margin({ top: 42 })
    .focusable(true)
    .hitTestBehavior(this.mPresenter.contactId ? HitTestMode.Default : HitTestMode.None)
    .visibility(this.isVerde ? Visibility.None
      : (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 && this.mPresenter.cardPhotoPixelMap) ?
        Visibility.Hidden : Visibility.Visible)
  }

  // 联系人姓名与标记备注
  @Builder
  contactNameAndMark() {
    Column() {
      Column() {
        // 姓名
        Text(this.titleDisplayName)
          .key('ContactDetail_displayNameText')
          .fontSize(this.getDisplayNameForAutoSize(this.titleDisplayName, this.curBp))
          .fontFamily('HarmonyHeiTi')
          .fontWeight((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
            !this.isVerde && this.mPresenter.cardPhotoPixelMap) ? FontWeight.Bold : 600)
          .fontColor(
            (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
              !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
              this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
              $r('app.color.skin_ohos_id_color_text_secondary')
          )
          .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
            ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
              !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
              cardTextShadowOpt : normalTextShadowOpt)
          )
          .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
            brightLevel1 : undefined)
          .maxLines(2)
          .maxFontScale(2.25)
          .textAlign(this.displayNameTextAlign)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .opacity(this.scrollAnimationOpacity)
          .scale({ x: this.nameScale, y: this.nameScale })
          .width('auto')
          .visibility(this.scrollAnimationOpacity === 0 ? Visibility.Hidden : Visibility.Visible)
          .direction(Direction.Ltr)
      }
      .constraintSize({
        minHeight: this.getCallTextHeight(
          (this.mPresenter.contactId != undefined ? this.mPresenter.displayName : this.formatNumber),
          'sm'
        )
      })
      .justifyContent(FlexAlign.Center)

      Column() {
        // 标记
        Row() {
          if (this.mPresenter.contactForm.phones.length > 0 && this.isInBlock) {
            Text($r('app.string.already_in_block'))
              .id('already_in_block')
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                $r('app.color.skin_ohos_id_color_text_secondary')
              )
              .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  cardTextShadowOpt : normalTextShadowOpt)
              )
              .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                brightLevel2 : undefined)
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .width('auto')
          } else if (this.mPresenter.isNewNumber && (!StringUtil.isEmpty(this.markType)) &&
            this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
            Text(this.getContactDetailSecondaryText())
              .fontSize($r('sys.float.Body_M'))
              .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                $r('app.color.skin_ohos_id_color_text_secondary')
              )
              .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  cardTextShadowOpt : normalTextShadowOpt)
              )
              .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                brightLevel2 : undefined)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('auto')
              .textAlign(TextAlign.Center)
          } else if (!StringUtil.isEmpty(this.mPresenter.contactForm.company) ||
            !StringUtil.isEmpty(this.mPresenter.contactForm.position)) {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Baseline }) {
              Text(this.mPresenter.contactForm.company)
                .constraintSize(this.textShowType === 3
                  ? { maxWidth: `calc(50% - ${this.companyPositionDivWidth / 2}vp)` } : null)
                .width('auto')
                .flexShrink(this.textShowType === 2 ? 0 : 1)
                .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                  ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                    !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                    cardTextShadowOpt : normalTextShadowOpt)
                )
                .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                  brightLevel2 : undefined)
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                  $r('app.color.skin_ohos_id_color_text_secondary')
                )
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(1)
                .visibility(!StringUtil.isEmpty(this.mPresenter.contactForm.company)
                  ? Visibility.Visible : Visibility.None)

              Text('  |  ')
                .flexShrink(0)
                .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                  ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                    !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                    cardTextShadowOpt : normalTextShadowOpt)
                )
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                  $r('app.color.skin_ohos_id_color_text_secondary')
                )
                .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                  brightLevel2 : undefined)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(1)
                .width('auto')
                .onAreaChange((oldValue: Area, newValue: Area) => {
                  this.companyPositionDivWidth = Number(newValue.width)
                })
                .visibility(!StringUtil.isEmpty(this.mPresenter.contactForm.company) &&
                  !StringUtil.isEmpty(this.mPresenter.contactForm.position) ? Visibility.Visible : Visibility.None)

              Text(this.mPresenter.contactForm.position)
                .constraintSize(this.textShowType === 3
                  ? { maxWidth: `calc(50% - ${this.companyPositionDivWidth / 2}vp)` } : null)
                .width('auto')
                .flexShrink(this.textShowType === 1 ? 0 : 1)
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                  $r('app.color.skin_ohos_id_color_text_secondary')
                )
                .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                  ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                    !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                    cardTextShadowOpt : normalTextShadowOpt)
                )
                .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                  brightLevel2 : undefined)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(1)
                .visibility(!StringUtil.isEmpty(this.mPresenter.contactForm.position)
                  ? Visibility.Visible : Visibility.None)
            }
          } else if (!StringUtil.isEmpty(this.markType) && this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE &&
            !this.mPresenter.isYellowPage && StringUtil.isEmpty(this.mPresenter.contactId)) {
            Text(this.getContactDetailMark())
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                $r('app.color.skin_ohos_id_color_text_secondary')
              )
              .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  cardTextShadowOpt : normalTextShadowOpt)
              )
              .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                brightLevel2 : undefined)
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
              .maxLines(1)
              .width('auto')
          }
        }
        .opacity(this.scrollAnimationOpacity)
        .visibility(
            this.isShowSmartWindow ?
            Visibility.None : (this.scrollAnimationOpacity === 0) ? Visibility.Hidden : Visibility.Visible
        )

        // 备注
        Row() {
          if (!StringUtil.isEmpty(this.mPresenter.contactForm.remarks)) {
            // 备注显示的时候 去掉换行符
            Text((this.mPresenter.contactForm.remarks as string).replace(lineBreakRegExp, ' '))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                this.mPresenter?.isNameRegionLight ? LIGHT_CARD_COLOR : DARK_CARD_COLOR :
                $r('app.color.skin_ohos_id_color_text_secondary')
              )
              .textShadow(this.mPresenter?.isNameRegionLight ? undefined :
                ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
                  !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
                  cardTextShadowOpt : normalTextShadowOpt)
              )
              .advancedBlendMode(this.mPresenter?.isNameRegionLight ?
                brightLevel2 : undefined)
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
              .maxLines(1)
              .width('auto')
              .margin({ top: $r('app.float.id_card_margin_mid') })
          }
        }
        .opacity(this.scrollAnimationOpacity)
        .visibility(
            this.isShowSmartWindow ?
            Visibility.None : (this.scrollAnimationOpacity === 0) ? Visibility.Hidden : Visibility.Visible
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        top: (this.getContactDetailSecondaryText() ||
          !StringUtil.isEmpty(this.mPresenter.contactForm.company) ||
          !StringUtil.isEmpty(this.mPresenter.contactForm.position)
        ) ? $r('app.float.id_card_margin_mid') : 0
      })
    }
    .margin({
      top: (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
        !this.isVerde && this.mPresenter.cardPhotoPixelMap) ?
        this.photoHeight * 0.7 + this.cardPhotoInitValue : $r('app.float.id_width_24'),
      bottom: (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
        !this.isVerde) && this.mPresenter.cardPhotoPixelMap ? this.getCallBtnPos() : $r('app.float.id_width_24'),
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6'),
    })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      let nameAndMarkWidth = Number(newValue.width);
      let nameOrMarkExtraLongWidth = (nameAndMarkWidth - this.companyPositionDivWidth) / 2;
      if (this.companyTextWidth < nameOrMarkExtraLongWidth &&
        this.positionTextWidth < nameOrMarkExtraLongWidth) {
        // 单位 和 职位 宽度均小于整体宽度的一半
        this.textShowType = 0;
      } else if (this.companyTextWidth >= nameOrMarkExtraLongWidth &&
        this.positionTextWidth < nameOrMarkExtraLongWidth) {
        // 单位大于整体宽度的一半
        this.textShowType = 1;
      } else if (this.companyTextWidth < nameOrMarkExtraLongWidth &&
        this.positionTextWidth >= nameOrMarkExtraLongWidth) {
        // 职位大于整体宽度的一半
        this.textShowType = 2;
      } else if (this.companyTextWidth >= nameOrMarkExtraLongWidth &&
        this.positionTextWidth >= nameOrMarkExtraLongWidth) {
        // 单位 和 职位 宽度均大于整体宽度的一半
        this.textShowType = 3;
      } else {
        this.textShowType = -1;
      }

      this.nameAndMarkHeight = Number(newValue.height);

      let oldHeight = Number(oldValue.height);
      let newHeight = Number(newValue.height);
      if (oldHeight !== newHeight) {
        // 姓名公司等共同高度 + 按钮组件上边距
        this.adsorbHeight = newHeight;
      }
    })
    .visibility(this.isVerde ? Visibility.None : Visibility.Visible)
  }

  getCallBtnPos() {
    let marginBottom = this.photoHeight * 0.3 - this.nameAndMarkHeight - this.callBtnHeight;
    if (marginBottom < 24) {
      marginBottom = 24;
    }
    HiLog.i(TAG, `getCallBtnPos:${marginBottom}`)
    return marginBottom;
  }

  // 呼叫按钮
  @Builder
  callButtons() {
    Column() {
      if (!this.mPresenter.isPrivateNumber &&
        !ArrayUtil.isEmpty<ContackPhoneSubInfoModel>(this.mPresenter.contactForm.phones)) {
        GridRow({ columns: this.isTabletLandscape ? 8 : 6 }) {
          GridCol({ span: 6, offset: this.isTabletLandscape ? 1 : 0 }) {
            Row() {
              Row() {
                if (this.isVoiceCapability() || (this.isDistributedCallSMSSharing && this.isDistributedModemState &&
                this.isDistributedCallPhoneSharing)) {
                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    SymbolGlyph($r('sys.symbol.phone_fill'))
                      .fontSize(this.isVerde ? $r('app.float.id_card_image_small') :
                        $r('app.float.id_card_image_height'))
                      .fontColor([$r('app.color.skin_icon_on_primary')])
                  }
                  .id('phone_fill')
                  .backgroundEffect(
                    (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                      !this.isVerde) ? this.customBtnBackEffect : this.customNormalBtnBackEffect
                  )
                  .accessibilityText(AccessibilityUtil.getInstance()
                    .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_make_call')))
                  .toolBar()
                  .bindMenu(this.isPhoneMenuShow, this.simCardListBuilder('voiceCalling'), {
                    placement: Placement.BottomLeft,
                    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
                    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK,
                    aboutToDisappear: () => {
                      this.isPhoneMenuShow = false;
                    }
                  })
                  .onClick(() => {
                    if (this.mPresenter.contactForm.phones.length === 1) {
                      this.voiceCalling(this.mPresenter.contactForm.phones[0])
                    } else if (this.isPrimaryIndex() != -1) {
                      this.voiceCalling(this.mPresenter.contactForm.phones[this.isPrimaryIndex()])
                    } else {
                      this.isPhoneMenuShow = true;
                    }
                  })
                }

                if (this.isVideoCapability() && !this.isInVisionGlass) {
                  Row() {
                    Button({ type: ButtonType.Normal, stateEffect: true }) {
                      SymbolGlyph($r('sys.symbol.video_fill'))
                        .fontSize(this.isVerde ? $r('app.float.id_card_image_small') :
                          $r('app.float.id_card_image_height'))
                        .fontColor([$r('app.color.skin_icon_on_primary')])
                    }
                    .enabled(this.mSystemModeController.getIsEnableVideoCall() && this.isOnCallSharingValue)
                    .id('video_fill')
                    .backgroundEffect(
                      (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                        !this.isVerde) ? this.customBtnBackEffect : this.customNormalBtnBackEffect
                    )
                    .toolBar()
                    .bindMenu(this.isVideoMenuShow, this.simCardListBuilder('videoCalling'), {
                      placement: Placement.Bottom,
                      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
                      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK,
                      aboutToDisappear: () => {
                        this.isVideoMenuShow = false;
                      }
                    })
                  }
                  .accessibilityRole(AccessibilityRoleType.BUTTON)
                  .accessibilityText(AccessibilityUtil.getInstance()
                    .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_video_call')))
                  .onClick(() => {
                    if (!this.mSystemModeController.getIsEnableVideoCall()) {
                      showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
                    } else {
                      if (this.mPresenter.contactForm.phones.length === 1) {
                        this.videoCalling(this.mPresenter.contactForm.phones[0])
                      } else if (this.isPrimaryIndex() != -1) {
                        this.videoCalling(this.mPresenter.contactForm.phones[this.isPrimaryIndex()])
                      } else {
                        this.isVideoMenuShow = true;
                      }
                    }
                  })
                }

                if (this.isVoiceCapability() || (this.isDistributedCallSMSSharing && this.isDistributedModemState &&
                this.isDistributedCallPhoneSharing)) {
                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    SymbolGlyph($r('sys.symbol.message_fill'))
                      .fontSize(this.isVerde ? $r('app.float.id_card_image_small') :
                        $r('app.float.id_card_image_height'))
                      .fontColor([$r('app.color.skin_icon_on_primary')])
                  }
                  .id('message_fill')
                  .backgroundEffect(
                    (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                      !this.isVerde) ? this.customBtnBackEffect : this.customNormalBtnBackEffect
                  )
                  .accessibilityText(AccessibilityUtil.getInstance()
                    .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_send_sms')))
                  .toolBar()
                  .bindMenu(this.isMessageMenuShow, this.simCardListBuilder('detailSendMsg'), {
                    placement: Placement.BottomRight,
                    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
                    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK,
                    aboutToDisappear: () => {
                      this.isMessageMenuShow = false;
                    }
                  })
                  .onClick(() => {
                    if (this.mPresenter.contactForm.phones.length === 1) {
                      this.detailSendMsg(this.mPresenter.contactForm.phones[0]);
                    } else if (this.isPrimaryIndex() != -1) {
                      this.detailSendMsg(this.mPresenter.contactForm.phones[this.isPrimaryIndex()])
                    } else {
                      this.isMessageMenuShow = true;
                    }
                  })
                }
              }
              .justifyContent(FlexAlign.SpaceAround)
              .width(!this.isVideoCapability() && this.isVoiceCapability() ? '208vp' : '100%')
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(this.isTabletLandscape ? '100%' : '312vp')
          }
        }
        .margin({ top: this.isVerde ? $r('app.float.id_width_16') : 0, bottom: $r('app.float.id_width_24') })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let oldHeight = Number(oldValue.height);
          let newHeight = Number(newValue.height);
          if (oldHeight !== newHeight) {
            if (newHeight > 0) {
              this.blankHeightParams.multiButtonHeight = newHeight + 24;
            } else {
              this.blankHeightParams.multiButtonHeight = 0;
            }
          }
        })
      }
    }.width('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.callBtnHeight = Number(newValue.height) - 24
    })
  }

  // 手机号码列表
  @Builder
  telList() {
    Column() {

      DetailInfoTelList({
        mPresenter: $mPresenter,
        selectSimBuilder: $selectSimBuilder,
        maximum: $maximum,
        moreOptionsFlag: $moreOptionsFlag,
        telephoneTotal: this.telephoneTotal,
        meettingTotal: this.meettingTotal,
        otherTotal: this.otherTotal,
      })

      Row() {
        Text($r('app.string.More'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('app.color.skin_ohos_id_color_text_tertiary'))
          .constraintSize({ maxWidth: `calc(100% - 29vp)` })
        // Image($r('app.media.ic_public_arrow_down'))
        Image($r('app.media.ic_empty_page_no_call_records'))
          .width(24)
          .fillColor($r('app.color.skin_ohos_id_color_fourth'))
          .margin({
            start: LengthMetrics.resource($r('app.float.id_card_margin_sm'))
          })
      }
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.moreOptionsFlag = !this.moreOptionsFlag;
      })
      .visibility(this.detailInfoTelListMore())
    }
    .card()
  }

  // 三方列表（畅连）
  @Builder
  meeTingList() {
    Column() {
      DetailInfoMeeTing({
        mPresenter: $mPresenter,
        selectSimBuilder: $selectSimBuilder,
        maximum: $maximum,
        moreOptionsFlag: $moreOptionsFlag,
        telephoneTotal: this.telephoneTotal,
        meettingTotal: this.meettingTotal,
        otherTotal: this.otherTotal,
      })

      Row() {
        Text($r('app.string.More'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('app.color.skin_ohos_id_color_text_tertiary'))
          .constraintSize({ maxWidth: `calc(100% - 29vp)` })
        // Image($r('app.media.ic_public_arrow_down'))
        Image($r('app.media.ic_empty_page_no_call_records'))
          .width(24)
          .fillColor($r('app.color.skin_ohos_id_color_fourth'))
      }
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.moreOptionsFlag = !this.moreOptionsFlag;
      })
      .visibility(this.detailInfoMeeTingMore())
    }
    .card()
  }

  // 配置信息
  @Builder
  detailInfoList() {
    Column() {
      // 其余信息
      DetailInfoRemarks({
        mPresenter: $mPresenter,
        selectSimBuilder: $selectSimBuilder,
        maximum: $maximum,
        moreOptionsFlag: $moreOptionsFlag,
        telephoneTotal: this.telephoneTotal,
        meettingTotal: this.meettingTotal,
        otherTotal: this.otherTotal,
      })
      // 更多按钮
      Button() {
        Row() {
          Text($r('app.string.More'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.skin_ohos_id_color_text_tertiary'))
            .constraintSize({ maxWidth: `calc(100% - 29vp)` })
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontSize(24)
            .fontColor([$r('app.color.skin_ohos_id_color_fourth')])
        }
        .width('100%')
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Normal)
      .stateEffect(false)
      .onClick(() => {
        this.moreOptionsFlag = !this.moreOptionsFlag;
      })
      .visibility(this.detailInfoRemarksMore())
    }
    .card()
  }

  @Builder
  cardBackPhoto() {
    ContactCardPhoto({
      mPresenter: this.mPresenter,
      cardPhotoYPos: this.cardPhotoYPos,
      updatePhotoHeight: (photoHeight: number) => {
        this.photoHeight = photoHeight;
      }
    })
  }

  // 畅联能力刷新时透明度动效
  onMeeTimeAbilityChangeAboutOpacity() {
    this.opacityValue = 0;
    this.getUIContext()?.animateTo({ duration: 250, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1) }, () => {
      this.opacityValue = 1;
    })
  }

  // 畅联能力刷新时缩放动效
  onMeeTimeAbilityChangeAboutScale() {
    this.scaleValue = 0.9;
    this.getUIContext()?.animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 22) }, () => {
      this.scaleValue = 1;
    })
  }

  // 畅联能力刷新时高度变化动效
  onMeeTimeAbilityChangeAboutCallLog() {
    if (this.isMeeTimeAbility) {
      this.translateY = -this.blankHeightParams.threePartyListHeight;
      this.getUIContext()?.animateTo({ curve: curves.interpolatingSpring(0, 1, 410, 40) }, () => {
        this.translateY = 0;
        this.isMeeTimeAbility = false;
        this.opacityValue = 0;
      })
    }
  }

  build() {
    Column() {
      // 海报头像 v小折叠 不展示海报
      if (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.blobSource === 3 &&
        !this.isVerde && this.mPresenter.cardPhotoPixelMap) {
        this.cardBackPhoto()
      }
      List({ scroller: this.scroller }) {
        // 头像、手机号、三个图标
        ListItem() {
          Column() {
            if (!this.mSystemModeController.getIsEnablePosterAvatar() || this.mPresenter.blobSource !== 3 || !this.mPresenter.cardPhotoPixelMap) {
              this.contactAvtar()
            }

            this.contactNameAndMark()

            if (this.isVideoCapability() || this.isVoiceCapability() || (this.isDistributedCallSMSSharing &&
            this.isDistributedModemState && this.isDistributedCallPhoneSharing)) {
              this.callButtons()
            }
          }
          .width('100%')
        }

        // 手机号码列表
        ListItem() {
          this.telList()
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let oldHeight = Number(oldValue.height);
          let newHeight = Number(newValue.height);
          if (oldHeight !== newHeight) {
            if (newHeight > 0) {
              this.blankHeightParams.phoneNumbersHeight = newHeight;
            } else {
              this.blankHeightParams.phoneNumbersHeight = 0;
            }
          }
        })
        .padding({ bottom: $r('app.float.id_card_margin_xl') })
        .visibility(this.detailInfoTelListCard())

        // 三方列表（畅连）
        ListItem() {
          this.meeTingList()
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let oldHeight = Number(oldValue.height);
          let newHeight = Number(newValue.height);
          if (oldHeight !== newHeight) {
            if (newHeight > 0) {
              this.blankHeightParams.threePartyListHeight = newHeight;
              if (this.isMeeTimeAbility) {
                this.onMeeTimeAbilityChangeAboutCallLog();
                this.onMeeTimeAbilityChangeAboutScale();
                this.onMeeTimeAbilityChangeAboutOpacity();
              }
            } else {
              this.blankHeightParams.threePartyListHeight = 0;
            }
          }
        })
        .opacity(this.opacityValue)
        .scale({ x: this.scaleValue, y: this.scaleValue })
        .padding({ bottom: $r('app.float.id_card_margin_xl') })
        .visibility(this.detailInfoMeeTingCard())

        // 配置信息
        ListItem() {
          this.detailInfoList()
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let oldHeight = Number(oldValue.height);
          let newHeight = Number(newValue.height);
          if (oldHeight !== newHeight) {
            if (newHeight > 0) {
              this.blankHeightParams.configurationInformationHeight = newHeight;
            } else {
              this.blankHeightParams.configurationInformationHeight = 0;
            }
          }
        })
        .padding({ bottom: $r('app.float.id_card_margin_xl') })
        .visibility(this.detailInfoRemarksCard())

        // 电话铃声
        if (!this.isFromMeetime && call.hasVoiceCapability()) {
          ListItem() {
            Row({ space: 8 }) {
              Column({ space: 2 }) {
                Text(!StringUtil.isEmpty(this.ringtoneInfo.ringtoneName) ?
                  (this.ringtoneInfo.ringtoneName == 'N' ? $r('app.string.ringtones_mute') :
                    this.ringtoneInfo.ringtoneName.replace(/(.*).mp4/, '$1')) : $r('app.string.default_value'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))

                Text($r('app.string.phone_ringtone'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              }
              .flexShrink(1)
              .alignItems(HorizontalAlign.Start)

              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize($r('app.float.id_card_image_small'))
                .fontColor([$r('app.color.skin_icon_fourth')])
                .flexShrink(0)
            }
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles
            })
            .justifyContent(FlexAlign.SpaceBetween)
            .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
            .width('100%')
            .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
          }
          .card()
          .onClick(() => {
            this.isRingToneShow = true;
          })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            let oldHeight = Number(oldValue.height);
            let newHeight = Number(newValue.height);
            if (oldHeight !== newHeight) {
              if (newHeight > 0) {
                this.blankHeightParams.ringtoneHeight = newHeight;
              } else {
                this.blankHeightParams.ringtoneHeight = 0;
              }
            }
          })
          .translate({ y: this.translateY })
          .visibility(this.detailInfoRingtoneListCard())
        }

        // 通话记录标题
        ListItem() {
          if (this.isThemeActive) {
            this.callLogTitleWithTheme()
          } else {
            this.callLogTitle()
          }
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let oldHeight = Number(oldValue.height);
          let newHeight = Number(newValue.height);
          if (oldHeight !== newHeight) {
            HiLog.i(TAG, `newHeight: ${newHeight}`);
            if (newHeight > 0) {
              this.blankHeightParams.callRecordsTitleHeight = newHeight;
            } else {
              this.blankHeightParams.callRecordsTitleHeight = 0;
            }
          }
        })
        .translate({ y: this.translateY })
        .visibility(this.detailInfoCallLogListCard())

          // 通话记录
          ListItemGroup() {
            LazyForEach(this.mPresenter.detailCallLogDataSource, (item: LooseObject, index: number) => {
              ListItem() {
                this.CallLogListBuilder(item, index)
              }
              .swipeAction({
                end:{
                  builder: () => {
                    this.itemEnd(() => {
                      this.deleteAction(item, index);
                    })
                  },
                  onAction:()=>{
                    animateTo({
                      duration: 400,
                    }, () => {
                      this.deleteAction(item, index);
                    })
                  },
                }
              })
              // HdsListItem({
              //   customItemBuilder: this.CallLogListBuilder(item, index),
              //   swipeActionOptions: {
              //     deleteIconOptions: {
              //       onAction: () => {
              //         this.deleteAction(item, index);
              //       }
              //     },
              //     fullDeleteOptions: {
              //       isFullDelete: true,
              //       onFullDeleteAction: () => {
              //         animateTo({
              //           duration: 350,
              //         }, () => {
              //             this.deleteAction(item, index);
              //         })
              //       }
              //     }
              //   }
              // })
            }, (item: LooseObject) => JSON.stringify(item))
          }
          .onAreaChange((oldValue: Area, newValue: Area) => {
            let oldHeight = Number(oldValue.height);
            let newHeight = Number(newValue.height);
            if (oldHeight !== newHeight) {
              if (newHeight > 0) {
                this.blankHeightParams.callRecordsListHeight = newHeight;
              } else {
                this.blankHeightParams.callRecordsListHeight = 0;
              }
            }
          })
          .card()
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') : $r('app.float.rounded_corners_width_20'))
          .translate({ y: this.translateY })
          .visibility(this.detailInfoCallLogListCard())

        ListItem() {
          Column() {
          }
          .height(this.blankHeight + this.titleBarHeight)
          .width('100%')
        }
      }
      .height('100%')
      .contentEndOffset(this.isVerde ? 0 : px2vp(this.fullScreenPadding.bottom as number) + 16)
      .padding({
        left: this.spaceLR,
        right: this.spaceLR
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .clipContent(ContentClipMode.SAFE_AREA)
      .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
      .onScroll((scrollOffset: number) => {
        this.headerAnimation(this.scroller, scrollOffset);
      })
      .onTouch((event?: TouchEvent) => {
        if (event?.type === TouchType.Up && !this.isVerde) {
          this.stopAnimation(this.scroller);
        }
      })
    }
    .bindSheet(this.isRingToneShow, this.ShowRingtoneSelectionView(), {
      dragBar: true,
      showClose: false,
      preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_background_secondary') : undefined,
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        ResourceAudioManager.releaseRing();
        emitter.emit({
          eventId: EmitterConstant.EVENT_LIST_RING_TONE_PLAY,
          priority: emitter.EventPriority.HIGH
        })
        this.isRingToneShow = !this.isRingToneShow;
      },
      onWillSpringBackWhenDismiss: () => {
        // 如果注册该回调函数，则不会回弹，由开发者控制下滑关闭时是否回弹。
        // 在回调函数中可以通过调用springBack来实现回弹效果。
      },
      shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_MD : undefined
    })
    .width('100%')
    .focusable(!this.isPC) // PC设备详情页不走焦点
  }

  @Builder
  CallLogListBuilder(item: LooseObject, index: number) {
    CallLogListItem({
      detailPresenter: $mPresenter,
      message: item.callLog,
      selectSimBuilder: $selectSimBuilder,
      item: item,
      index: index,
      callLogTotal: $callLogTotal,
    })
      .id('allDetailRecord_listItem')
  }

  @Builder
  itemEnd(onDeleteBtn: () => void) {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_delete_head'))
          .height(5)
          .width(20)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '100%',
            centerY: '100%',
            angle: this.headAngle,
          })
        Image($r('app.media.ic_delete_body'))
          .height(16)
          .width(16)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '100%',
            centerY: 0,
            angle: this.bodyAngle,
          })
      }
      .width($r('app.float.id_item_height_sm'))
      .height($r('app.float.id_item_height_sm'))
      .borderRadius(20)
      .scale({ x: this.swipeScale, y: this.swipeScale })
      .backgroundColor($r('app.color.skin_ohos_id_color_warning'))
      .onClick(onDeleteBtn)
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
    }
    .draggable(false)
    .backgroundColor($r('app.color.skin_ohos_id_color_sub_background'))
    .onAreaChange((oldValue: Area, newValue: Area) => {
      if (this.dustbinAnimationEnabled) {
        let wid: Length = newValue.width;
        this.headAngle = Math.min(MAX_HEAD_ANGLE,
          Math.max((Number(wid) - DELETE_SWIPE_HEAD_WIDTH) / ACTION_AREA_DISTANCE * ANGLE_RADIO, 0.0));
        this.bodyAngle = Math.min(MAX_BODY_ANGLE,
          Math.max((Number(wid) - DELETE_SWIPE_BODY_WIDTH) / ACTION_AREA_DISTANCE * 24.35, 0.0));
        this.swipeScale = Math.min(MAX_SCALE_RATIO,
          (Number(wid) - DELETE_SWIPE_HEAD_WIDTH) / ACTION_AREA_DISTANCE * 0.05 + 1.0);
        this.bodyAngle = (-1) * this.bodyAngle;
      }
    })
    .height('100%')
    .margin({ left: $r('sys.float.padding_level6') })
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .constraintSize({ minWidth: '72vp' })
  }

  deleteAction(item: LooseObject, index: number) {
    this.dustbinAnimationEnabled = false;
    animateTo({
      duration: 400,
      curve: Curve.Friction,
      onFinish: () => {
        this.isSwipe = false;
        this.dustbinAnimationEnabled = true
        this.scroller?.closeAllSwipeActions()
      }
    }, () => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('deleteCallLogsById', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          ids: [item.callLog.id]
        }, () => {
          HiLog.i(TAG, 'deleteCallLog Success');
          // 刷新通话记录列表
          CallRecordPresenter.getInstance().onCallsChange();
        });
      this.mPresenter.detailCallLogDataSource.removeById(item.callLog.id);
    })
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('app.color.skin_ohos_id_color_list_card_bg')
  }

  @Builder
  ShowRingtoneSelectionView() {
    Column() {
      RingtoneSelection({
        contactId: this.mPresenter.contactId,
        ringtoneInfo: this.ringtoneInfo,
        isRingToneShow: this.isRingToneShow
      })
    }.width('100%').height('100%')
  }

  updateContactDetailDisplayNameText() {
    if (this.mPresenter.isPrivateNumber) {
      HiLog.w(TAG, 'getContactDetailDisplayNameText isPrivateNumber');
      this.titleDisplayName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.unknown_phonenumber').id);
    } else if (this.mPresenter.contactId) {
      HiLog.w(TAG, 'getContactDetailDisplayNameText displayName');
      this.titleDisplayName = this.mPresenter.displayName;
    } else if (this.checkVoicemailNumber()) {
      HiLog.w(TAG, 'getContactDetailDisplayNameText VoicemailNumber');
      this.titleDisplayName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.voicemail').id);
    } else if (this.isCloud && this.markType === NumberMarkUtil.PRE_FRAUD_PHONE_DESC &&
      this.markSource === NumberMarkUtil.ANTI_FRAUD_CENTER) {
      HiLog.w(TAG, 'getContactDetailDisplayNameText nationalAntiFraudCenter');
      this.titleDisplayName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.suspected_fraud').id);
    } else if (this.mPresenter.isYellowPage || this.mPresenter.isCnap) {
      HiLog.w(TAG, `getContactDetailDisplayNameText isYellowPage: ${this.mPresenter.isYellowPage}`);
      this.titleDisplayName = this.mPresenter.displayName;
    } else if (this.isCloud && !StringUtil.isEmpty(this.markType) &&
      (this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
        this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE)) {
      HiLog.w(TAG, 'getContactDetailDisplayNameText mark');
      this.titleDisplayName = this.markContent;
    } else {
      HiLog.w(TAG, 'getContactDetailDisplayNameText formatNumber');
      this.titleDisplayName = this.formatNumber;
    }
  }

  checkVoicemailNumber(): boolean {
    let number: string = this.mPresenter.phoneNumberShow;
    let formatPhoneNumber = RoamingUtils.getFormatNumberBySystemRegion(number);
    number = !StringUtil.isEmpty(formatPhoneNumber) ? formatPhoneNumber as string : number;
    if (!StringUtil.isEmpty(number) && this.voicemailNumbers.indexOf(number) >= 0) {
      return true;
    } else {
      return false;
    }
  }

  getContactDetailSecondaryText(): string | Resource {
    if (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
      return $r('app.string.number_mark_fraud_smart_identify');
    }
    // 用户手动标记
    HiLog.w(TAG, `getContactDetailSecondaryText, isCloud: ${this.isCloud}, markType: ${this.markType
    }, markSource: ${this.markSource}`);
    if (this.isCloud && this.markType == NumberMarkUtil.PRE_FRAUD_PHONE_DESC) {
      if (this.markSource == NumberMarkUtil.ANTI_FRAUD_CENTER) {
        // 国家反诈中心
        let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
        if (settings.getValueSync(context, ANTIFRAUD_CENTER_SWITCH, '') === '1' &&
        this.queryAntiFraudApp(CENTER_BUNDLE_NAME)) {
          return ContactsGlobalThisHelper.GetGlobalThis()
            .getDefaultUIContext()
            .resourceManager
            .getStringSync($r('app.string.national_anti_fraud_center').id);
        } else if (settings.getValueSync(context, ANTIFRAUD_BESTMIND_SWITCH, '') === '1' &&
        this.queryAntiFraudApp(BESTMIND_BUNDLE_NAME)) {
          return ContactsGlobalThisHelper.GetGlobalThis()
            .getDefaultUIContext()
            .resourceManager
            .getStringSync($r('app.string.all_people_anti_fraud_center').id);
        } else {
          HiLog.w(TAG, 'markSource is 5 but antifraud is not open');
          return '';
        }
      } else {
        // 高风险电话
        if (this.markSource == NumberMarkUtil.ANTIFRAUD_CENTER_MARK_SOURCE) {
          let markType = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id);
          return `${markType}`;
        } else {
          return (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id)) + '  |  ' +
            (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
            ?.resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
              this.markCount));
        }
      }
    } else if (!this.isCloud && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        HiLog.w(TAG, 'getContactDetailSecondaryText PRE_CUSTOM_PHONE_DESC');
        return $r('app.string.number_marked',
          this.markCustom);
      }
      HiLog.w(TAG, 'getContactDetailSecondaryText !PRE_CUSTOM_PHONE_DESC');
      return $r('app.string.number_marked',
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id));
    } else if (this.isCloud && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC) {
        HiLog.w(TAG, 'getContactDetailSecondaryText OTHER_PHONE_DESC');
        return (this.markContent) + (this.markCount ? '  |  ' +
          (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
            .resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
              this.markCount)) : '');
      }
      //yellow page phone dest
      if (this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC) {
        HiLog.w(TAG, 'getContactDetailSecondaryText YELLOW_PAGE_PHONE_DESC');
        return this.formatNumber;
      }
      HiLog.w(TAG, 'getContactDetailSecondaryText mark');
      return (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id)) + '  |  ' +
        (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
            this.markCount));
    } else {
      HiLog.w(TAG, 'getContactDetailSecondaryText empty');
      return '';
    }
  }

  getContactDetailMark(): string {
    // check markDetails and markSource is true
    if (this.markDetails && this.markSource) {
      return this.markDetails + ' | ' + this.markSource;
    }
    // check markDetails or markSource is true
    if (this.markDetails || this.markSource) {
      return this.markDetails || this.markSource;
    }
    return '';
  }
}