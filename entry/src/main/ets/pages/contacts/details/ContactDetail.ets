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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import TraceConstants from '../../../../../../../common/src/main/ets/TraceConstants';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import StringFormatUtil from '../../../util/StringFormatUtil';
import { Controller, SelectDialogBuilder, SelectSimIdDialog } from '../../dialog/SelectSimIdDialog';
import FavoriteListPresenter from '../../../presenter/favorite/FavoriteListPresenter';
import LooseObject from '../../../model/type/LooseObject';
import call from '@ohos.telephony.call';
import curves from '@ohos.curves';
import {
  getHeadChar,
  getImagePackingData,
  getPixelMapFromFile,
  PixelMapManager,
  saveImageToFile
} from '../../../util/UserPhoto';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { CustomTransition } from '../../../util/CustomNavigationUtil';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import dotCommon, { contactParams, customParams } from '../../../util/DotCommon';
import { ObjectUtil } from '../../../../../../../feature/call/oh_modules/common';
import EmitterConstant from '../../../data/EmitterConstant';
import emitter from '@ohos.events.emitter';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { sharedPreferencesUtils } from '../../../../../../../common';
import ArrangeContactsPresenter from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import { AccountVo } from '../../../model/bean/AccountVo';
import { BlockType } from '../../../../../../../feature/contact/src/main/ets/contract/BlockList';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import MarkAsDetailDialog from '../../dialog/MarkAsDetailDialog';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import { i18n } from '@kit.LocalizationKit';
import { settings } from '@kit.BasicServicesKit';
import { componentSnapshot, SymbolGlyphModifier, window } from '@kit.ArkUI';
import { ComponentContent, LengthMetrics } from '@ohos.arkui.node';
import { FontScaleState } from '../../../util/fontScaleState';
import { TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { ContactDetailContent } from '../details/ContactDetailContent';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import buffer from '@ohos.buffer';
import { SplitStatus, DisplaySplitUtil } from '../../../util/DisplaySplitUtil';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import effectKit from '@ohos.effectKit';
import { BusinessError } from '@ohos.base';
import {  hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { VisionGlassConstants } from '../../../data/VisionGlassConstants';
import CustomButtons from '../../dialog/CustomButtons';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { UiExtentionParam } from '../../../uiExtentionAbility/ContactUiExtentionAbility';
// import { PickerMaskLayer } from '@hw-hmos/pickersheet';
import { Constants } from '../../../data/Constants';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { SystemModeController } from '../../../util/SystemModeController';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions,
//   HdsNavigationMenuContentOptions, ScrollEffectType } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { ContactRepository, Data } from '../../../../../../../feature/contact';
import { RawContacts } from '../../../../../../../feature/contact/src/main/ets/contract/RawContacts';
import { DataShareResultSet } from '@kit.ArkData';
import common from '@ohos.app.ability.common';

const TAG = 'ContactDetail';
const DELETE_CONTACT_EVENT = 'DELETE_CONTACT_EVENT';
const DELETE_CONTACT_DIALOG_EVENT = 'DELETE_CONTACT_DIALOG_EVENT';
const CONTACT_ADD_EVENT = 'CONTACT_ADD_EVENT';
const CLICK_EDIT_CONTACT_EVENT = 'CLICK_EDIT_CONTACT_EVENT';
const CONTACT_DETAILS_MENU_EVENT = 'CONTACT_DETAILS_MENU_EVENT';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';
const FAVORITE_CONTACT_DETAILS_EVENT = 'FAVORITE_CONTACT_DETAILS_EVENT';
const CLICK_SAVE_EXIST_EVENT = 'CLICK_SAVE_EXIST_EVENT';
const NUMBER_IDENTITY_SWITCH = 'settings.telephony.number_identity_switch';
const NUMBER_IDENTITY_SWITCH_ON = '1';
const lineBreakRegExp = new RegExp('\r?\n|(?<!\n)\r', 'g');
const TITLE_NAME_OPACITY = 0.3;
const LIGHT_CARD_COMMON_COLOR = '#E5000000';
const LIGHT_CARD_BACK_COLOR = '#0C000000';
const DARK_CARD_TITLE_COLOR = '#E5FFFFFF';
const DARK_CARD_BUTTON_COLOR = '#FFFFFF';
const DARK_CARD_BACK_COLOR = '#19FFFFFF';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

interface ParamsInterface {
  mPresenter: LooseObject,
  canBeShared: boolean,
  isFromMeetime: boolean,
  hasPhonesToBlock: boolean,
  isPrivateAccount: boolean,
  isInBlock: boolean,
  isOnCallSharingValue: boolean,
  maintenanceMode: boolean,
  blockFunction: Function,
  deleteContact: Function,
  saveExistingContacts: Function,
  markFunction: Function,
  copyFunction: Function,
}

export class MMoreMenuObj {
  public value: string = ''
  public action: () => void = () => {
  };
}

@Builder
export function ContactDetailLoader($$: Params): void {
  ContactDetail();
}

@Component
export default struct ContactDetail {
  @State pageFlag: string = '';
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  //Listen to changes in the favorites list.
  @State mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @State mPresenter: DetailPresenter = new DetailPresenter();
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('params') params: LooseObject = {};
  @StorageLink('updateContactInfo') @Watch('updateContact') updateContactInfo: LooseObject = {};
  // 监听storage的 newContactInfo 信息，联系人新增，存入数据库后会设置
  @StorageLink('newContactInfo') @Watch('onNewContact') newContactInfo: LooseObject = {};
  // 监听长按头像设置头像 完成后刷新this.mPresenter.cardPhotoPixelMap
  @State @Watch('onPixelMapWriteFinished') pixelMapWriteFinished: boolean = false;
  @State pathInfosParams: LooseObject = {};
  //Listen to whether to save contacts
  @StorageLink('isSaveContact') isSaveCon: number = 0;
  //Listen to whether to showDialBtn
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @State private index: number = -1;
  // titleNameOpacity
  @State titleNameOpacity: number = 0;
  // clear_detail_call_log
  @State clearDetailCallLog: boolean = false;
  @State hasPhonesToBlock: boolean = false;
  @State isInBlock: boolean = false;
  // block Phones
  @State blockPhones: string[] = [];
  @State @Watch('onMarkedChanged') isMarked: boolean = false;
  @State translateTitle: number | string = 0;
  @State backOpacity: number = 1;
  private pageId: number = 0;
  // markType
  @State markType: string = '';
  // markCustom
  @State markCustom: string = '';
  @State markContent: string = '';
  @State markCount: number = 0;
  @State markSource: string = '';
  @State isCloud: boolean = true;
  @State markDetails: string = '';
  @State accountName: string = ResourceUtil.getStringByResource($r('app.string.phone'));
  @State isConfirmChecked: boolean = false;
  @State isFromCallLog: boolean = false;
  //选择联系人颜色id
  @StorageLink('selectContactId') selectContactId: string = '';
  @StorageLink('deleteContactItemId') @Watch('deleteContactDetail') deleteContactItemId: string = '';
  @StorageLink('contactCount') @Watch('updateFavoriteList') contactCount: number = -1;
  @StorageLink('mainTabsIndex') mainTabsIndex: number = 0;
  @StorageLink('updateFavoriteDetailId') @Watch('updateIsFavorited') updateFavoriteDetailId: number = -1;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  // contact search status
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @StorageLink('activeCallId') activeCallId: number = -1;
  @State canBeShared: boolean = false;
  // 控制联系人编辑半模态展示
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @State isDeleteChecked: boolean = false;
  // titleDisplayName
  @State titleDisplayName: string = '';
  @State isPageOnShown: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageLink('blockListChanged') @Watch('onBlockListChanged') blockListChanged: boolean = false;
  @StorageProp('isMainAbilityForeground') @Watch('onForegroundChange') isMainAbilityForeground: boolean = true;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageProp('isFromExternalApp') isFromExternalApp: boolean = false;
  @StorageProp('isPrivateAccount') isPrivateAccount: boolean = false;
  @StorageLink('isShowPickerMaskLayer') isShowPickerMaskLayer: boolean = false;
  @StorageLink('isNavigationModeSplit') isNavigationModeSplit: boolean = false;
  @StorageLink('windowStatus') windowStatus: window.WindowStatusType =
    window.WindowStatusType.UNDEFINED;
  // 返回按钮可见性
  @State isBackBtnShow: boolean = true;
  @State callLogTotal: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();
  // PC需要使用window接口修改系统按钮颜色，必须使用主窗口调用
  private mainWindowObjOnPC: window.Window | null | undefined;
  private uiExtentionParam = ContactsGlobalThisHelper.GetGlobalThis()
    .getValue<UiExtentionParam>(ContactsGlobalThisHelper.UiExtentionAbilityParams);
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageProp('notePadJump') notePadJump: boolean = false;
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  cardBtnBackEffect: BackgroundEffectOptions =
    { radius: 0, color: !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF' };
  normalBtnBackEffect: BackgroundEffectOptions = {
    radius: 100,
    color: EnvironmentProp.isPC() ? Color.Transparent :
      !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF'
  };
  contactParams: CustomizedParams = {
    ENC: 0,
  };
  customParams: CustomizedParams = {};
  clickEditParams: CustomizedParams = {
    ENC: 0
  };
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };
  favoriteDetailsParams: CustomizedParams = {
    ISFAVORITE: 0
  };
  // parameters in the dialog box for deleting a contact
  deleteDialogContactParams: CustomizedParams = {
    ISPOP: 0,
    ISDELETE: 0
  };
  saveExistParams: CustomizedParams = {
    ENC: 0
  };
  @State hasFavorited: boolean = false;
  @State isShow: number = 0;
  @State builder: SelectDialogBuilder = {
    title: '',
    multiSimCardItems: [{
      name: '',
      img: $r('sys.symbol.phone_badge_1'),
    }, {
      name: '',
      img: $r('sys.symbol.phone_badge_2'),
    }],
  };
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State @Watch('selectLanguageChange') selectLanguage:string = 'zh-Hans';
  @StorageProp('currentColorMode') @Watch('onColorModeChanged') currentColorMode: number = 0;
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimePC') isMeetimePC: boolean = false;
  @StorageProp('isShowJumpButton') isShowJumpButton: boolean = false;
  @StorageLink('isOnCallSharingValue') isOnCallSharingValue: boolean = false;
  mSystemModeController = SystemModeController.getInstance();

  private scroller: ListScroller = new ListScroller();

  selectLanguageChange() {
    this.mPresenter.refresh();
    HiLog.i(TAG, 'selectLanguageChange:' + this.selectLanguage);
  }

  onBlockListChanged() {
    if (this.blockListChanged) {
      this.initBlockListParam();
    }
  }

  onForegroundChange() {
    HiLog.i(TAG, `onForegroundChange isOnForeground:${this.isMainAbilityForeground}`);
    if (!this.isMainAbilityForeground) {
      this.mPresenter.sourceHasParam = false;
    }
  }

  // 正常状态下颜色
  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
  }

  mSelectSlotIdDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      contentAreaPadding: {
        right: $r('sys.float.padding_level6'),
        left: $r('sys.float.padding_level6'),
      },
      primaryTitle: this.builder.title,
      contentBuilder: () => {
        this.SelectSlotIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.callDialogParams.ITEM = -1;
            this.callDialogParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.mSelectSlotIdDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    cancel: () => {
      this.callDialogParams.ITEM = -1;
      this.callDialogParams.ISCANCEL = 1;
      DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
    },
    autoCancel: true,
    alignment: DialogAlignment.Center,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    cornerRadius: {
      topLeft: $r('app.float.rounded_corners_width_32'),
      topRight: $r('app.float.rounded_corners_width_32'),
      bottomLeft: $r('app.float.rounded_corners_width_32'),
      bottomRight: $r('app.float.rounded_corners_width_32')
    }
  })

  // Marked Changed
  onMarkedChanged() {
    HiLog.i(TAG, 'onMarkedChanged');
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let numberIdentitySwitch: string = '';
    try {
      numberIdentitySwitch = settings.getValueSync(context, NUMBER_IDENTITY_SWITCH, NUMBER_IDENTITY_SWITCH_ON);
    } catch (error) {
      HiLog.e(TAG, `failed to get numberIdentitySwitch, error: ${error?.message}`);
      return;
    }
    HiLog.i(TAG, `numberIdentitySwitch : ${numberIdentitySwitch}`);
    if (numberIdentitySwitch === NUMBER_IDENTITY_SWITCH_ON) {
      CallRecordPresenter.getInstance().isPhoneNumberMarkedOrNot(this.mPresenter.phoneNumberShow,
        context, (result: LooseObject) => {
          this.isMarked = result?.isMarked;
          this.markType = result?.markType;
          this.markCustom = result?.markContent;
          this.markCount = result?.markCount;
          this.markSource = result?.markSource;
          this.isCloud = result?.isCloud ? true : false;
          this.markContent = result?.markContent;
          this.markDetails = result?.markDetails;

          this.mPresenter.markType = this.markType;
          this.mPresenter.markContent = this.markContent;
          this.mPresenter.markSource = this.markSource;
          this.mPresenter.markCount = this.markCount;
        });
    }
  }

  // update isFavorited
  updateIsFavorited() {
    if (this.mPresenter.contactId == this.updateFavoriteDetailId) {
      HiLog.w(TAG, 'updateIsFavorited02')
      this.mPresenter.isFavorited = '0';
      this.updateFavoriteDetailId = -1;
    }
  }

  /**
   * 详情页之间跳转
   * sourceHasId——当联系人应用后台打开页面为详情页时点击服务卡片触发
   * sourceHasPhone——当联系人应用后台打开页面为详情页时外部应用跳转详情时触发（如短信点击联系人头像）
   * 其余触发方式待补充
   */
  updateContact() {
    let brackets: LooseObject = {};
    this.isFromCallLog = false;
    if (this.updateContactInfo.sourceHasId) {
      HiLog.w(TAG, 'updateContact sourceHasId');
      this.mPresenter.isNewDetail = false;
      this.mPresenter.detailsColor = $r('sys.color.ohos_id_color_special1');
      this.mPresenter.newNumberBgColor = $r('sys.color.ohos_id_color_special1');
      this.mPresenter.sourceHasId = this.updateContactInfo.sourceHasId;
      this.mPresenter.contactId = this.updateContactInfo.contactId;
      this.mPresenter.sourceHasParam = this.updateContactInfo.sourceHasParam;
      this.mPresenter.markType = this.markType;
      this.mPresenter.markContent = this.markContent;
      this.mPresenter.markSource = this.markSource;
      this.mPresenter.markCount = this.markCount;
      AppStorage.setOrCreate('updateContactInfo', brackets);
      setTimeout(() => {
        this.mPresenter.aboutToAppear();
      }, 2)
      this.mPresenter.filterContactId();
      this.initBlockListParam();
    } else if (this.updateContactInfo.sourceHasPhone) {
      HiLog.w(TAG, 'updateContact sourceHasPhone');
      this.mPresenter.isNewDetail = false;
      this.mPresenter.sourceHasId = false;
      this.mPresenter.isNewNumber = true;
      this.mPresenter.displayName = '';
      this.mPresenter.detailsColor = $r('sys.color.ohos_id_color_special1');
      this.mPresenter.newNumberBgColor = $r('sys.color.ohos_id_color_special1');
      this.mPresenter.contactId = this.updateContactInfo.contactId;
      this.mPresenter.sourceHasPhone = this.updateContactInfo.sourceHasPhone;
      this.mPresenter.phoneNumberShow = this.updateContactInfo.phoneNumberShow;
      this.mPresenter.fromSmsList = this.updateContactInfo.fromSmsList;
      this.mPresenter.sourceHasParam = this.updateContactInfo.sourceHasParam;
      this.mPresenter.markType = this.markType;
      this.mPresenter.markContent = this.markContent;
      this.mPresenter.markSource = this.markSource;
      this.mPresenter.markCount = this.markCount;
      this.pathInfosParams.sourceHasParam = this.updateContactInfo.sourceHasParam;
      AppStorage.setOrCreate('updateContactInfo', brackets);
      setTimeout(() => {
        this.mPresenter.aboutToAppear();
      }, 2)
      this.mPresenter.filterContactId();
      this.initBlockListParam();
    }
    HiLog.i(TAG, `updateContactInfo: ${this.mPresenter.contactId}, ${this.index}`);
  }

  updateFavoriteList() {
    if (this.mainTabsIndex === IndexPresenter.getInstance().favoriteIndex) {
      FavoriteListPresenter.getInstance().setPageShow(true, px2vp(this.fullScreenPadding.bottom as number));
    }
  }

  /**
   * 设置新的联系人后触发（新建联系人保存后跳转触发）
   */
  onNewContact() {
    HiLog.w(TAG, `onNewContact, contactId: ${this.newContactInfo.contactId
    }, rawContactId: ${this.newContactInfo.rawContactId}, isMyCard: ${this.newContactInfo.isMyCard}`);
    let brackets: LooseObject = {};
    // 新建联系人跳转的详情页 index 需要置为-1
    this.index = -1;
    if (this.newContactInfo.sourceHasRawId && this.newContactInfo.rawContactId) {
      this.mPresenter.sourceHasRawId = this.newContactInfo.sourceHasRawId;
      this.mPresenter.rawContactId = this.newContactInfo.rawContactId;
      this.mPresenter.sourceHasParam = this.newContactInfo.sourceHasParam;
      AppStorage.setOrCreate('newContactInfo', brackets);
      setTimeout(() => {
        this.mPresenter.aboutToAppear();
      }, 2)
      this.initBlockListParam();
      this.mPresenter.isMyCard = this.newContactInfo.isMyCard ?? false;
    } else if (this.newContactInfo.sourceHasId && this.newContactInfo.contactId) {
      this.mPresenter.sourceHasId = this.newContactInfo.sourceHasId;
      this.mPresenter.contactId = this.newContactInfo.contactId;
      this.mPresenter.sourceHasParam = this.newContactInfo.sourceHasParam;
      this.mPresenter.isMyCard = this.newContactInfo.isMyCard ?? false;
      setTimeout(() => {
        this.mPresenter.aboutToAppear();
      }, 2)
      this.initBlockListParam();
    }
  }

  // 手势回退触发
  onBackPress() {
    this.pathInfos.pop();
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear:');
    // 关闭选择铃声半模态窗口
    AppStorage.setOrCreate('isRingToneShow', false);
    hiTraceMeter.startTrace(TraceConstants.TRACE_DETAIL_APPEAR, TraceConstants.TRACE_DETAIL_APPEAR_ID);
    this.resetStatus();
    this.mPresenter.pathInfos = this.pathInfos;
    let navParam: LooseObject = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as LooseObject;
    this.pathInfosParams = navParam;
    // 参数处理
    this.transmitParam(navParam);
    if (!this.mPresenter.skipInitContact) {
      hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_APPEAR, TraceConstants.TRACE_DETAIL_APPEAR_ID);
      // 解决pc端showLogTitleFlagRefreshFun调用的时序问题
      this.mPresenter.showLogTitleFlagRefreshFun = (callLogTotal: number) => {
        this.callLogTotal = callLogTotal;
        HiLog.i(TAG, `showLogTitleFlagRefreshFun: ${this.callLogTotal}`);
      };
      this.mPresenter.aboutToAppear();
    }
    this.mPresenter.refreshSystemBar = () => {
      this.updateSystemBar();
    };
    this.initDialogController();
    this.mPresenter.addRecorderDataHelperListener();
    this.mPresenter.filterContactId();
    if (this.curBp === 'sm') {
      this.addNavtinationHeaderAnimation();
    }
    let accountInnerEventSearchs: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EMITTER_ID,
      priority: emitter.EventPriority.HIGH,
    };
    emitter.on(accountInnerEventSearchs, (data) => {
      this.destinationPageShow();
    });
    this.accountName = this.curBp === 'sm' ? ResourceUtil.getStringByResource($r('app.string.phone')) :
    ResourceUtil.getStringByResource($r('app.string.tablet'));
    AppStorage.setOrCreate('selectFavoriteContact', this.mPresenter.contactId);
    AppStorage.setOrCreate('sysTime', Number.parseInt(StringFormatUtil.judgeSysTime()));
    this.queryingBlockListSwitch();
    if (this.isPC) {
      // 当前窗口对象可以更新系统按钮颜色，需要获取当前窗口对象并保存
      window.getLastWindow(getContext(this)).then((window) => {
        this.mainWindowObjOnPC = window;
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `Error getting window object: ${error?.message}`)
      })
    }
  }

  resetStatus() {
    this.titleNameOpacity = 0;
    this.mPresenter.skipInitContact = false;
  }

  initDialogController() {
    let that = this;
    const controller: Controller = new Controller();
    controller.open = () => {
      that.mSelectSlotIdDialog?.open();
      DialogControllerManager.getInstance().addDialogController(this.mSelectSlotIdDialog);
    };
    controller.close = () => {
      that.mSelectSlotIdDialog?.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    };
    this.builder.controller = controller;
  }

  private addNavtinationHeaderAnimation() {
    this.pageId = this.pathInfos.getAllPathName().length - 1;
    CustomTransition.getInstance().registerNavParam(this.pageId, {
      transitionAnimation: {
        finish: (isPop: boolean, isExit) => {
          if (isPop) {
            this.titleNameOpacity = 0;
            if (isExit) {
              this.translateTitle = '40%';
            } else {
              this.translateTitle = 0
            }
          } else {
            if (isExit) {
              this.translateTitle = '2%'
            } else {
              this.translateTitle = 0;
            }
          }
        },
        onFinish: (isPop: boolean, isExit: boolean) => {
          if (!isPop) {
            this.translateTitle = 0;
          }
          this.backOpacity = 1;
        },
        start: (isPop: boolean, isExit: boolean) => {
          if (isPop) {
            if (isExit) {
              this.translateTitle = 0;
            }
          } else {
            if (isExit) {
              this.translateTitle = 0;
            } else {
              this.translateTitle = '70%'
            }
          }
        }
      },
      titleAnimation: {
        finish: (isPop: boolean, isExit: boolean) => {
          if (isExit) {
            this.titleNameOpacity = 0;
          }
        },
        onFinish: (isPop: boolean, isExit: boolean) => {
          if (isExit) {
            this.titleNameOpacity = 0;
          }
        },
        start: (isPop: boolean, isExit: boolean) => {
        }
      },
      opacityAnimation: {
        finish: (isPop: boolean, isExit: boolean) => {
          if (isExit) {
            this.backOpacity = 0;
            this.titleNameOpacity = 0;
          } else {
            this.backOpacity = 1;
          }
        },
        onFinish: () => {
        },
        start: (isPop: boolean, isExit: boolean) => {
          if (isExit) {
            this.backOpacity = 1;
          } else {
            this.backOpacity = 0;
          }
        }
      }
    });
  }

  private initBlockListParam() {
    setTimeout(() => {
      HiLog.i(TAG, 'initBlockListParam');
      let blockPhones: string[] = [];
      if (this.mPresenter.sourceHasPhone) {
        blockPhones.push(this.mPresenter.phoneNumberShow);
      }
      for (let i = 0; i < this.mPresenter.contactForm.phones.length; i++) {
        blockPhones.push(this.mPresenter.contactForm.phones[i].num as string);
      }
      // 号码全在
      CallRecordPresenter.getInstance().isInBlockOrAccessList(blockPhones, BlockType.BLOCK,
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
          this.blockListChanged = false;
          if (result) {
            this.isInBlock = result;
          } else if (!this.mPresenter.contactId) {
            CallRecordPresenter.getInstance().isInStartWithBlock(blockPhones[0],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              (result: boolean) => {
                this.isInBlock = result;
              });
          } else {
            this.isInBlock = result;
            HiLog.i(TAG, `isInBlock3 : ${result}`)
          }
        });

      let numberIdentitySwitch: string = NUMBER_IDENTITY_SWITCH_ON;
      try {
        numberIdentitySwitch = settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          NUMBER_IDENTITY_SWITCH, NUMBER_IDENTITY_SWITCH_ON);
      } catch (error) {
        HiLog.e(TAG, `Error getting number identity switch: ${error?.message}`);
      }
      HiLog.i(TAG, `numberIdentitySwitch : ${numberIdentitySwitch}, isFromCallLog: ${this.isFromCallLog}`);
      if (!this.isFromCallLog && (numberIdentitySwitch === NUMBER_IDENTITY_SWITCH_ON ||
        (!StringUtil.isEmpty(this.markType) && this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC))) {
        CallRecordPresenter.getInstance().isPhoneNumberMarkedOrNot(this.mPresenter.phoneNumberShow,
          ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: LooseObject) => {
            this.isMarked = result?.isMarked;
            this.markType = result?.markType;
            this.markCustom = result?.markContent;
            this.markCount = result?.markCount;
            this.markSource = result?.markSource;
            this.isCloud = result?.isCloud ? true : false;
            this.markContent = result?.markContent;
            this.markDetails = result?.markDetails;

            this.mPresenter.markType = this.markType;
            this.mPresenter.markContent = this.markContent;
            this.mPresenter.markSource = this.markSource;
            this.mPresenter.markCount = this.markCount;
          });
      }
    }, 50);
  }

  transmitParam(navParam: LooseObject) {
    // 跳转参数不为空
    if (!ObjectUtil.isEmpty(navParam)) {
      this.mPresenter.isPrivateNumber = navParam.isPrivateNumber ?? false;
      this.selectContactId = navParam.contactId;
      this.isFromCallLog = navParam?.isFromCallLog ?? false;
      // 保存联系人或更新联系人跳转详情
      if (navParam.addNewContact) {
        if (this.newContactInfo.sourceHasId) {
          this.mPresenter.sourceHasId = this.newContactInfo.sourceHasId;
          this.mPresenter.contactId = this.newContactInfo.contactId;
          this.mPresenter.sourceHasParam = this.newContactInfo.sourceHasParam;
        } else {
          this.mPresenter.skipInitContact = true;
          HiLog.w(TAG, 'skip init contact as add new contact');
        }
        HiLog.i(TAG, `param info: ${this.mPresenter.contactId}, ${this.index}, ${navParam.itemIndex}`);
      } else {
        this.mPresenter.sourceHasId = navParam.sourceHasId;
        this.mPresenter.contactId = navParam.contactId;
        this.mPresenter.nameRawContactId = navParam.nameRawContactId;
        this.mPresenter.sourceHasPhone = navParam.sourceHasPhone;
        this.mPresenter.phoneNumberShow = navParam.phoneNumberShow;
        if (navParam.isMyCard !== undefined) {
          this.mPresenter.initIsMyCardFlag(navParam.isMyCard);
        }
        this.index = navParam.itemIndex;
        this.pageFlag = navParam.pageFlag;
        this.mPresenter.pageFlag = navParam.pageFlag;
        HiLog.i(TAG, `param info: ${navParam.contactId}, ${navParam.nameRawContactId}, ${navParam.itemIndex}`);
      }
      if (navParam.markType != undefined) {
        HiLog.i(TAG, `navParam.markType=${navParam.markType}`);

        this.isMarked = navParam.isMarked;
        this.markType = navParam.markType;
        this.markCustom = navParam.markContent;
        this.markCount = navParam.markCount;
        this.markSource = navParam.markSource;
        this.isCloud = navParam.isCloud;
        this.markContent = navParam.markContent;
        this.markDetails = navParam.markDetails;

        this.mPresenter.markType = this.markType;
        this.mPresenter.markContent = this.markContent;
        this.mPresenter.markSource = this.markSource;
        this.mPresenter.markCount = this.markCount;
      }
      if (navParam.isCnap) {
        HiLog.i(TAG, `navParam.isCnap=${navParam.isCnap}, ${this.index}`);
        this.mPresenter.isCnap = true;
        this.mPresenter.displayName = navParam.displayName;
      }
      if (navParam.isYellowPage) {
        HiLog.i(TAG, `navParam.isYellowPage=${navParam.isYellowPage}, ${this.index}`);
        this.mPresenter.isYellowPage = navParam.isYellowPage;
      } else {
        HiLog.w(TAG, 'queryIsInYellowPage');
        CallRecordPresenter.getInstance().queryIsInYellowPage(this.mPresenter.phoneNumberShow,
          ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
            this.mPresenter.isYellowPage = result;
          });
      }
      if (!StringUtil.isEmpty(navParam.quickSearchKey)) {
        this.mPresenter.quickSearchKey = Number(navParam.quickSearchKey);
        HiLog.w(TAG, `quickSearchKey: ${this.mPresenter.quickSearchKey}`);
      }
      // 跳转参数为空，判断其他参数
    } else if (this.params && (this.params.sourceHasId || this.params.sourceHasPhone)) {
      this.mPresenter.sourceHasId = this.params.sourceHasId;
      this.mPresenter.contactId = this.params.contactId;
      this.mPresenter.sourceHasPhone = this.params.sourceHasPhone;
      this.mPresenter.phoneNumberShow = this.params.phoneNumberShow;
      this.mPresenter.fromSmsList = this.params.fromSmsList;
      this.mPresenter.sourceHasParam = this.params.sourceHasParam;
      HiLog.i(TAG, `this.params: ${this.params.contactId}, ${this.index}`);
      this.params = {}
    } else if (this.uiExtentionParam && (this.uiExtentionParam.contactId || this.uiExtentionParam.phoneNumber)) {
      this.mPresenter.sourceHasId = !ObjectUtil.isEmpty(this.uiExtentionParam.contactId);
      this.mPresenter.contactId = this.uiExtentionParam.contactId;
      this.mPresenter.sourceHasPhone = !ObjectUtil.isEmpty(this.uiExtentionParam.phoneNumber);
      this.mPresenter.phoneNumberShow = this.uiExtentionParam.phoneNumber;
      this.mPresenter.fromSmsList = true;
      this.mPresenter.sourceHasParam = true;
      this.initBlockListParam();
      HiLog.i(TAG, `this.uiExtentionParam: ${this.uiExtentionParam.contactId}, ${this.index}`);
      CallRecordPresenter.getInstance().queryIsInYellowPage(this.mPresenter.phoneNumberShow,
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
          this.mPresenter.isYellowPage = result;
        });
    } else if (this.updateContactInfo) {
      this.mPresenter.sourceHasId = this.updateContactInfo.sourceHasId;
      this.mPresenter.contactId = this.updateContactInfo.contactId;
      this.mPresenter.sourceHasPhone = this.updateContactInfo.sourceHasPhone;
      this.mPresenter.phoneNumberShow = this.updateContactInfo.phoneNumberShow;
      this.mPresenter.fromSmsList = this.updateContactInfo.fromSmsList;
      this.mPresenter.sourceHasParam = this.updateContactInfo.sourceHasParam;
      HiLog.i(TAG, `this.updateContactInfo: ${this.mPresenter.contactId}, ${this.index}`);
      let brackets: LooseObject = {};
      AppStorage.setOrCreate('updateContactInfo', brackets);
    }
  }

  // delete contact detail
  deleteContactDetail() {
    let contactItemId = '';
    contactItemId = this.mPresenter.contactId.toString();
    if ((this.deleteContactItemId === contactItemId) && (!StringUtil.isEmpty(this.selectContactId))) {
      HiLog.w(TAG, 'pathInfos deleteContactDetail: ContactDefaultPage');
      ContactListPresenter.getInstance().toDefaultPage();
    }
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.mSelectSlotIdDialog = null;
    this.mPresenter.aboutToDisappear();
    if (this.mPresenter.sourceHasParam) {
      this.mPresenter.cancel();
    }
    emitter.off(EmitterConstant.EMITTER_ACCOUNTANTS_EMITTER_ID);
    this.mPresenter.removeRecorderDataHelperListener();
    if (!this.isPC) {
      this.resetSystemBarProperties();
    }
  }

  // 碰一碰分享场景，监听pixelMapFinished变化为true时刷新this.mPresenter.cardPhotoPixelMap，避免为空分享失败
  onPixelMapWriteFinished() {
    if (this.pixelMapWriteFinished) {
      this.destinationPageShow();
      setTimeout(() => {
        this.pixelMapWriteFinished = false;
      }, 3000);
    }
  }

  destinationPageShow() {
    this.selectLanguage = i18n.System.getSystemLanguage()
    HiLog.w(TAG, 'onPageShow');
    this.clearDetailCallLog = false;
    let sysTime = StringFormatUtil.judgeSysTime();
    HiLog.w(TAG, `sysTime:${sysTime}`);
    // 判断小时类型，不同的类型的话，重新查询次头像
    if (this.pixelMapWriteFinished ||
      Number.parseInt(StringFormatUtil.judgeSysTime()) !== AppStorage.Get<number>('sysTime')) {
      HiLog.w(TAG, 'DO refresh detailCallLog');
      this.mPresenter.refresh();
      AppStorage.SetOrCreate('sysTime', Number.parseInt(StringFormatUtil.judgeSysTime()));
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let needPosterImg = true;
      getPixelMapFromFile(this.mPresenter.contactId?.toString(), (res: PixelMap | null) => {
        this.mPresenter.photoPixelMap = res;
        let blobSource = PixelMapManager.getInstance().getBlobSourceById(this.mPresenter.contactId?.toString());
        if (blobSource === 3) {
          this.mPresenter.cardPhotoPixelMap = res;
          this.mPresenter.updateLightColor();
        }
      }, context, needPosterImg);
    }
    this.initBlockListParam();
    this.refreshSystemMenuBarStyleOnPC();
  }

  private refreshSystemMenuBarStyleOnPC() {
    // 在PC显示联系人海报时更新系统按钮颜色
    if (this.isPC && this.mSystemModeController.getIsEnablePosterAvatar()) {
      HiLog.i(TAG, `Update system menubar style.`);
      // 联系人头像没获取就提前获取
      if (this.mPresenter.cardPhotoPixelMap) {
        let blobSource = PixelMapManager.getInstance().getBlobSourceById(this.mPresenter.contactId?.toString());
        // blobSource为3时，表示该联系人头像显示海报
        blobSource === 3 ? this.updateSystemBar() : this.resetSystemBarProperties();
      } else {
        let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
        let needPosterImg = true;
        getPixelMapFromFile(this.mPresenter.contactId?.toString(), (res: PixelMap | null) => {
          let blobSource = PixelMapManager.getInstance().getBlobSourceById(this.mPresenter.contactId?.toString());
          if (blobSource === 3) {
            this.mPresenter.cardPhotoPixelMap = res;
            this.updateSystemBar();
          } else {
            this.resetSystemBarProperties();
          }
        }, context, needPosterImg);
      }
    }
  }

  onBackPressDetail() {
    if (this.curBp === 'sm' || this.isShowSmartWindow || AppStorage.get('splitStatus') === SplitStatus.VERTICAL_SPLIT) {
      this.selectContactId = '';
      this.pathInfos.clear();
    } else {
      this.activeCallId = -1;
      if (this.mainTabsIndex === IndexPresenter.getInstance().callIndex) {
        this.isShowDial = false;
        this.pathInfos.clear();
        this.pathInfos.pushPathByName('DialerPad', '', false);
      } else if (this.isContactSearch) {
        IndexPresenter.getInstance().onBackPressIsContactSearch();
      } else {
        this.mPresenter.returnDesktopToBackground();
      }
    }
  }

  getBlockDisplayName(): string {
    // 有对应联系人，使用名字；或黄页名字，使用名字
    if (this.mPresenter.contactId > 0 || this.mPresenter.displayNameQueryByYellowPageFlag) {
      return this.mPresenter.displayName as string;
    }

    return '';
  }

  // editContactMenu: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.edit_contact'),
  //     icon: $r('sys.symbol.square_and_pencil'),
  //     componentId: 'detail_edit_menu',
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       this.clickContactButton();
  //     }
  //   }
  // }
  //
  // createContactMenu: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.create_contact'),
  //     icon: $r('sys.symbol.plus'),
  //     componentId: 'detail_edit_menu',
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       this.clickContactButton();
  //     }
  //   }
  // }
  //
  // cancelFavorite: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.cancel_favorite'),
  //     icon: new SymbolGlyphModifier($r('sys.symbol.star_fill')).fontSize($r('app.float.id_card_margin_max'))
  //       .fontColor([$r('app.color.skin_font_emphasize')]),
  //     componentId: 'add_favorite_info',
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       this.clickFavorite();
  //     }
  //   }
  // }
  //
  // favoriteMenu: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.accessibility_new_collect'),
  //     icon: $r('sys.symbol.star'),
  //     componentId: 'add_favorite_info',
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       this.clickFavorite();
  //     }
  //   }
  // }
  //
  // moreMenu: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.mores'),
  //     icon: $r('sys.symbol.dot_grid_2x2'),
  //     componentId: 'contactDetailMore',
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       this.clickMore();
  //       let uiContext = this.getUIContext();
  //       let promptAction = uiContext.getPromptAction();
  //       let contentNode = new ComponentContent<ParamsInterface>(uiContext,
  //         wrapBuilder<[ParamsInterface]>(hdsMenuBuilder),
  //         {
  //           mPresenter: this.mPresenter,
  //           canBeShared: this.canBeShared,
  //           isFromMeetime: this.isFromMeetime,
  //           hasPhonesToBlock: this.hasPhonesToBlock,
  //           isPrivateAccount: this.isPrivateAccount,
  //           isInBlock: this.isInBlock,
  //           isOnCallSharingValue: this.isOnCallSharingValue,
  //           maintenanceMode: this.maintenanceMode,
  //           blockFunction: () => {
  //             let blockPhones = this.getBlockPhones(this.blockPhones);
  //             if (this.isInBlock) {
  //               // 联系人打点-从黑名单中移除-联系人详情和通话记录详情页-菜单（未知联系人）
  //               contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
  //               DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.REMOVE_BLOCKLIST_EVENT);
  //               CallRecordPresenter.getInstance().cancelBlockList(blockPhones,
  //                 ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
  //                   HiLog.i(TAG, 'cancelBlockList result:' + result);
  //                 });
  //             } else {
  //               // 联系人打点-加入黑名单-联系人详情和通话记录详情页-菜单（未知联系人）
  //               contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
  //               DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.ADD_BLOCKLIST_EVENT);
  //               CallRecordPresenter.getInstance().addToBlockList(blockPhones,
  //                 this.getBlockDisplayName(), (result: boolean) => {
  //                   HiLog.i(TAG, 'addToBlockList result:' + result);
  //                 });
  //             }
  //           },
  //           deleteContact: () => {
  //             if (this.mPresenter.isMyCard) {
  //               DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.DELETE_MYCARD_EVENT);
  //             } else {
  //               this.contactParams.ENC = 1;
  //               DotUtil.getInstance().contactDot(this.contactParams, DELETE_CONTACT_EVENT);
  //             }
  //
  //             this.deleteDialogControler?.open();
  //             DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
  //           },
  //           saveExistingContacts: () => {
  //             this.saveExistParams.ENC = 3;
  //             DotUtil.getInstance().contactDot(this.saveExistParams, CLICK_SAVE_EXIST_EVENT);
  //             this.mPresenter.saveExistingContact()
  //           },
  //           markFunction: () => {
  //             contactParams.ENC = dotCommon.eventParam.DETAIL_MENU;
  //             // 联系人打点-号码标记入口-陌生联系人通话记录长按
  //             DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.NUMBER_TAG_EVENT);
  //             this.markAsDialogController?.open();
  //             DialogControllerManager.getInstance().addDialogController(this.markAsDialogController);
  //           },
  //           copyFunction: () => {
  //             this.mPresenter.updateContact();
  //             AppStorage.setOrCreate('accountantParams', this.mPresenter.params);
  //             this.isShowAccountants = true;
  //           }
  //         });
  //       try {
  //         promptAction.openMenu(
  //           contentNode,
  //           { id: 'contactDetailMore' },
  //           { placement:Placement.BottomRight,
  //             onDisappear: () => {
  //             this.initBlockListParam();
  //           }})
  //       } catch (error) {
  //         let err = error as BusinessError;
  //         HiLog.e(TAG, 'menuItems openMenu fail error message: ' + err.message + ', error code: ' + err.code);
  //       }
  //     }
  //   }
  // }

  private getBlockPhones(blockPhones: string[]): string[] {
    let blockPhoneData: string[] = [];
    for (let i = 0; i < blockPhones.length; i++) {
      blockPhoneData.push(blockPhones[i]);
    }
    return blockPhoneData;
  }

  private clickMore() {
    let count: number = this.mPresenter.contactForm.phones.length;
    this.hasPhonesToBlock = count > 0 ? true : false;
    if (count > 0) {
      this.blockPhones = [];
      let blockPhoneData: string[] = [];
      if (this.mPresenter.sourceHasPhone) {
        this.blockPhones.push(this.mPresenter.phoneNumberShow);
      }
      for (let i = 0; i < this.mPresenter.contactForm.phones.length; i++) {
        this.blockPhones.push(this.mPresenter.contactForm.phones[i].num as string);
        blockPhoneData.push(this.mPresenter.contactForm.phones[i].num as string);
      }
      CallRecordPresenter.getInstance().isInBlockOrAccessList(
        blockPhoneData,
        BlockType.BLOCK,
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        (result: boolean) => {
          if (result) {
            this.isInBlock = result;
          } else if (!this.mPresenter.contactId) {
            CallRecordPresenter.getInstance().isInStartWithBlock(blockPhoneData[0],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              (result: boolean) => {
                this.isInBlock = result;
              });
          } else {
            this.isInBlock = result;
          }
        }
      );
    }
    if (this.mPresenter.isMyCard) {
      //联系人打点-我的名片详情点击更多
      DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.CLICK_MYCARD_MENU_EVENT);
    } else {
      // 联系人打点-联系人详情点击菜单
      DotUtil.getInstance().contactDot(this.customParams, CONTACT_DETAILS_MENU_EVENT);
    }
  }

  private clickFavorite() {
    if ('0' === this.mPresenter.isFavorited) {
      // 联系人打点--收藏
      FavoriteListPresenter.getInstance().favoriteDataSource.favoriteContactIdList.push(this.selectContactId);
      this.favoriteDetailsParams.ISFAVORITE = 1;
      this.mPresenter.isFavorited = '1';
      this.mFavoriteListPresenter.addFavoriteInfo(
        [this.mPresenter.contactId?.toString()],
        px2vp(this.fullScreenPadding.bottom as number), this.getUIContext());
    } else {
      // 联系人打点--取消收藏
      FavoriteListPresenter.getInstance().favoriteDataSource.deleteFavoriteContactId(this.selectContactId);
      this.favoriteDetailsParams.ISFAVORITE = 0;
      this.mPresenter.isFavorited = '0';
      if ((this.mainTabsIndex === IndexPresenter.getInstance().favoriteIndex) && (this.curBp !== 'sm')) {
        HiLog.w(TAG, 'emitFavoriteDefaultSelectedContact, value is: ' + this.mainTabsIndex);
        this.pathInfos.pop(false);
      }
      // 点击取消收藏主动播报
      AccessibilityUtil.getInstance()
        .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId($r('app.string.cancel_favorite').id));
      this.mPresenter.updateFavorite(Number.parseInt(this.mPresenter.isFavorited));
    }
    AccessibilityUtil.getInstance()
      .sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'add_favorite_info');
    DotUtil.getInstance().contactDot(this.favoriteDetailsParams, FAVORITE_CONTACT_DETAILS_EVENT);
  }

  private clickContactButton() {
    HiLog.w(TAG, 'Menu Edit/New Contact Button onClick');
    if (this.mPresenter.isMyCard) {
      //联系人打点-我的名片详情点击编辑
      contactParams.ENC = 1;
      DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.EDIT_MYCARD_EVENT);
    } else if (this.mPresenter.contactId != undefined) {
      //联系人打点-联系人详情点击编辑联系人
      DotUtil.getInstance().contactDot(this.clickEditParams, CLICK_EDIT_CONTACT_EVENT);
    } else {
      // 新建联系人打点-通话记录详情页处
      this.contactParams.ENC = 3;
      DotUtil.getInstance().contactDot(this.contactParams, CONTACT_ADD_EVENT);
    }
    this.mPresenter.updateContact();
    AppStorage.setOrCreate('accountantParams', this.mPresenter.params);
    this.isShowAccountants = true;
  }

  // getMenuBar(): HdsNavigationBadgeIconOptions[] {
  //   let value: HdsNavigationBadgeIconOptions[] = [];
  //   if (!this.isVerde) {
  //     if ((this.mPresenter.contactId != undefined || !this.mPresenter.isYellowPage) && !this.maintenanceMode) {
  //       if (this.mPresenter.contactId != undefined) {
  //         value.push(this.editContactMenu);
  //       } else {
  //         value.push(this.createContactMenu);
  //       }
  //     }
  //     if (!this.isFromMeetime) {
  //       if (!this.mPresenter.isMyCard) {
  //         if (this.mPresenter.contactId != undefined) {
  //           if (this.mPresenter.isFavorited === '1') {
  //             value.push(this.cancelFavorite);
  //           } else {
  //             value.push(this.favoriteMenu);
  //           }
  //         }
  //       }
  //     }
  //     value.push(this.moreMenu);
  //   } else {
  //     if (!this.isFromMeetime){
  //       if (!this.mPresenter.isMyCard) {
  //         if (this.mPresenter.contactId != undefined) {
  //           if (this.mPresenter.isFavorited === '1') {
  //             value.push(this.cancelFavorite);
  //           } else {
  //             value.push(this.favoriteMenu);
  //           }
  //         }
  //       }
  //     }
  //   }
  //   return value;
  // }

  build() {
    if (this.isPC) {
      NavDestination() {
        Column() {
          Row() {
            Row({ space: 8 }) {
              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.chevron_backward'))
                  .key('ContactDetail_Navigation_Flex_Button_Image')
                  .fontSize('24vp')
                  .draggable(false)
                  .fontColor((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                    [$r('app.color.skin_ohos_id_color_primary_contrary')] :
                    [$r('app.color.skin_icon_primary')])
              }
              .key('ContactDetail_DetailNavigation_Flex_Button')
              .width('40vp')
              .height('40vp')
              .transition(TransitionEffect.asymmetric(
                TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp, delay: 150 }),
                TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Sharp })))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onAreaChange(() => {
                if (DisplaySplitUtil.isSmStatus() || !this.isNavigationModeSplit) {
                  this.isBackBtnShow = true;
                } else {
                  this.isBackBtnShow = false;
                }
              })
              .onClick(() => {
                if (this.backPreview()) {
                  HiLog.w(TAG, 'back success');
                }
              })
              .backgroundEffect(
                (this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                this.cardBtnBackEffect : this.normalBtnBackEffect
              )
              .visibility(this.isBackBtnShow ? Visibility.Visible : Visibility.None)
              .backgroundColor(this.isPC ? Color.Transparent :
                !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF')
              .accessibilityText(AccessibilityUtil.getInstance()
                .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_back')))


              Text(typeof this.titleDisplayName === 'string'
                ? this.titleDisplayName.replace(lineBreakRegExp, '') : this.titleDisplayName)
                .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ?
                $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') :
                  ((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                  $r('app.color.skin_font_on_primary') :
                    undefined))
                .textShadow((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ? {
                  radius: 10,
                  color: '#333333'
                } : {
                  radius: 0,
                  color: '#ffffff'
                })
                .opacity(this.isVerde ? 1 : this.titleNameOpacity)
                .accessibilityLevel(this.titleNameOpacity < 0.2 ? 'no' : 'auto')
                .height($r('app.float.id_card_image_small'))
                .maxLines(1)
                .wordBreak(WordBreak.BREAK_ALL)
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                .direction(Direction.Ltr)
                .margin({ start: this.isInVisionGlass ? LengthMetrics.vp(24) :
                LengthMetrics.resource($r('sys.float.padding_level4')),
                  end: LengthMetrics.resource($r('sys.float.padding_level4'))
                })
                // 216除去左右边距以及返回按钮和menu按钮的宽度
                .width(this.isVerde ? '100%' : `calc(100% - 216vp)`)
            }
            .layoutWeight(1)
            .margin({ start: this.isPC ? LengthMetrics.vp(144) : LengthMetrics.resource($r('sys.float.padding_level8')) })

            Row({ space: 8 }) {
              this.MenuBar();
            }
          }
          .zIndex(1)
          .transition(DisplaySplitUtil.isFoldStatus() ? TransitionEffect.IDENTITY : TransitionEffect.asymmetric(
            TransitionEffect.move(TransitionEdge.END).combine(TransitionEffect.OPACITY)
              .animation({ curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0) }),
            TransitionEffect.IDENTITY))

          this.ContactDetailBuilder()
        }
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true)
      .focusable(this.isPageOnShown)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
      $r('app.color.skin_ohos_id_color_sub_background'))
      .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
      .backgroundImageSize(this.isThemeActive ? { width: '100%', height: '100%' } : undefined)
      .onShown(() => {
        this.isPageOnShown = true;
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.isPageOnShown = false;
        HiLog.i(TAG, `page hidden.`)
        this.resetSystemBarProperties();
      })
      .onBackPressed(() => {
        return this.backPreview();
      })
      .id('detail_onBack')
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
      })
    } else {
      NavDestination() {
        Stack() {
          Column() {
            Row() {
              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.chevron_backward'))
                  .key('ContactDetail_Navigation_Flex_Button_Image')
                  .fontSize('24vp')
                  .draggable(false)
                  .fontColor((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                    [$r('app.color.skin_ohos_id_color_primary_contrary')] :
                    [$r('app.color.skin_icon_primary')])
              }
              .key('ContactDetail_DetailNavigation_Flex_Button')
              .width('40vp')
              .height('40vp')
              .transition(TransitionEffect.asymmetric(
                TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp, delay: 150 }),
                TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Sharp })))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                if (this.backPreview()) {
                  HiLog.w(TAG, 'back success');
                }
              })
              .backgroundEffect(
                (this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                this.cardBtnBackEffect : this.normalBtnBackEffect
              )
              .visibility(this.curBp === 'sm' ? Visibility.Visible : Visibility.None)
              .backgroundColor(!this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF')
              .accessibilityText(AccessibilityUtil.getInstance()
                .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_back')))

              Text(typeof this.titleDisplayName === 'string'
                ? this.titleDisplayName.replace(lineBreakRegExp, '') : this.titleDisplayName)
                .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ?
                $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') :
                  ((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
                  $r('app.color.skin_font_on_primary') :
                    undefined))
                .textShadow((this.mPresenter.cardPhotoPixelMap && !this.isVerde) ? {
                  radius: 10,
                  color: '#333333'
                } : {
                  radius: 0,
                  color: '#ffffff'
                })
                .opacity(this.isVerde ? 1 : this.titleNameOpacity)
                .accessibilityLevel(this.titleNameOpacity < 0.2 ? 'no' : 'auto')
                .height($r('app.float.id_card_image_small'))
                .maxLines(1)
                .wordBreak(WordBreak.BREAK_ALL)
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                .direction(Direction.Ltr)
                .margin({ start: LengthMetrics.resource($r('sys.float.padding_level4')),
                  end: LengthMetrics.resource($r('sys.float.padding_level4')) })

              Row({ space: 8 }) {
                this.MenuBar();
              }
            }
            .padding({ start: LengthMetrics.resource($r('sys.float.padding_level8')),
              end: LengthMetrics.resource($r('sys.float.padding_level8')),
              top: px2vp(this.fullScreenPadding.top as number) })
            .zIndex(1)

            Scroll(this.scroller) {
              this.ContactDetailBuilder()
            }
          }
        }
      }
      .bindToScrollable([this.scroller])
      .width('100%')
      .height('100%')
      .focusable(this.isPageOnShown)
      .padding({ top: this.fullScreenPaddingTop })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
      $r('app.color.skin_ohos_id_color_sub_background'))
      .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
      .backgroundImageSize(this.isThemeActive ? { width: '100%', height: '100%' } : undefined)
      .hideBackButton(true) // 隐藏默认返回按钮，使用自定义返回按钮
      .onShown(() => {
        this.isPageOnShown = true;
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.isPageOnShown = false;
      })
      .onBackPressed(() => {
        return this.backPreview();
      })
      .id('detail_onBack')
    }
  }

  @Builder
  ContactDetailBuilder() {
    if (this.mPresenter.isContactDataReady) {
      ContactDetailContent({
        mPresenter: $mPresenter,
        selectSimBuilder: $builder,
        clearDetailCallLog: $clearDetailCallLog,
        isInBlock: this.isInBlock,
        isMarked: this.isMarked,
        markContent: this.markContent,
        markCustom: this.markCustom,
        markCount: this.markCount,
        markDetails: this.markDetails,
        isCloud: this.isCloud,
        markType: this.markType,
        markSource: this.markSource,
        canBeShared: this.canBeShared,
        titleDisplayName: this.titleDisplayName,
        titleNameOpacity: this.titleNameOpacity,
        callLogTotal: this.callLogTotal,
        scroller: this.scroller
      })
    }

    // UEC方式加载联系人页面 应用锁
    if (this.isShowPickerMaskLayer) {
      // PickerMaskLayer({
      //   onclose: () => {
      //     HiLog.w(TAG, `PickerMaskLayer onclose`);
      //   },
      //   appInfos: [{ bundleName: Constants.CONTACT_BUNDLE_NAME, appIndex: 0 }],
      //   unlockProxy: true,
      //   maskShow: this.isShowPickerMaskLayer
      // });
    }
  }

  private backPreview(): boolean {
    HiLog.w(TAG, 'onBackPressed');
    let noted: boolean = AppStorage.get('notePadJump') as boolean
    if (noted) {
      HiLog.i(TAG, 'backPreview notepad');
      AppStorage.setOrCreate<boolean>('notePadJump', false);
      return true;
    }
    this.resetSystemBarProperties();
    if ((this.pathInfosParams.pageTag && this.pathInfosParams.pageTag === 'groupListDetail') ||
    this.pathInfosParams.isCardSharing || this.pathInfosParams.pageTag === Constants.FROM_PAGE_INTELLIGENCE_GROUPD) {
      this.pathInfos?.pop();
      return true;
    }
    if (this.isFromExternalApp || this.pageFlag === 'page_flag_contact_details' ||
      (!this.isFromMeetime && AppStorage.get('startAbilityCallerBundleName') === 'com.ohos.meetime')) {
      this.mPresenter.returnDesktop();
      return true;
    }
    // 回退按钮，如果使用uiExtension方式进入页面，回退不管用，需要调用方自行回退; 给调用方发送回退消息
    HiLog.w(TAG, 'BackTo-ContactList');
    if (this.pathInfos.size() == 0) {
      HiLog.w(TAG, 'BackTo-ContactList pathInfo.size zero cancel');
      this.mPresenter.cancel();
      return true;
    } else {
      if (this.pathInfosParams?.sourceHasParam) {
        HiLog.w(TAG, 'BackTo-ContactList cancel');
        this.mPresenter.cancel();
        return true;
      } else {
        HiLog.w(TAG, 'BackTo-ContactList clear');
        this.onBackPressDetail();
        focusControl.requestFocus('accessibility_new_contact_id');
        return true;
      }
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: this.mPresenter.blobSource === 3 && this.mPresenter.cardPhotoPixelMap && !this.isVerde ? {
  //       scrollEffectOpts:
  //       {
  //         blurEffectiveStartOffset: LengthMetrics.vp(0),
  //         blurEffectiveEndOffset: LengthMetrics.vp(112),
  //         scrollEffectType: ScrollEffectType.GRADIENT_BLUR
  //       },
  //       originalStyle: {
  //         contentStyle: {
  //           titleStyle: {
  //             mainTitleColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_TITLE_COLOR
  //           },
  //           menuStyle: {
  //             backgroundColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_BACK_COLOR : DARK_CARD_BACK_COLOR,
  //             iconColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_BUTTON_COLOR
  //           },
  //           backIconStyle: {
  //             backgroundColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_BACK_COLOR : DARK_CARD_BACK_COLOR,
  //             iconColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_BUTTON_COLOR
  //           }
  //         },
  //       },
  //       scrollEffectStyle: {
  //         contentStyle: {
  //           titleStyle: {
  //             mainTitleColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_TITLE_COLOR
  //           },
  //           menuStyle: {
  //             iconColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_BUTTON_COLOR
  //           },
  //           backIconStyle: {
  //             iconColor: this.mPresenter.isTitleBarLightColor ? LIGHT_CARD_COMMON_COLOR : DARK_CARD_BUTTON_COLOR
  //           }
  //         },
  //       }
  //     } :
  //       {
  //         originalStyle: {
  //           contentStyle: {
  //             titleStyle: {
  //               mainTitleColor: $r('app.color.skin_icon_primary')
  //             },
  //             menuStyle: {
  //               iconColor: $r('app.color.skin_icon_primary')
  //             },
  //             backIconStyle: {
  //               iconColor: $r('app.color.skin_icon_primary')
  //             }
  //           }
  //         },
  //         scrollEffectStyle: {
  //           contentStyle: {
  //             titleStyle: {
  //               mainTitleColor: $r('app.color.skin_icon_primary')
  //             },
  //             menuStyle: {
  //               iconColor: $r('app.color.skin_icon_primary')
  //             },
  //             backIconStyle: {
  //               iconColor: $r('app.color.skin_icon_primary')
  //             }
  //           },
  //         }
  //       },
  //     avoidLayoutSafeArea: true,
  //     padding: {
  //       start: this.isInVisionGlass || !DisplaySplitUtil.isSmStatus() ? LengthMetrics.vp(24) :
  //         LengthMetrics.resource($r('sys.float.padding_level8')),
  //       end: LengthMetrics.resource($r('sys.float.padding_level8'))
  //     },
  //     title: {
  //       title: !this.isVerde && this.titleNameOpacity < TITLE_NAME_OPACITY ? '' :
  //         typeof this.titleDisplayName === 'string' ? this.titleDisplayName.replace(lineBreakRegExp, '') :
  //           this.titleDisplayName
  //     },
  //     backIcon: { backIcon: true }
  //   };
  // }

  @Builder
  SelectSlotIdDialogBuilder() {
    Column() {
      SelectSimIdDialog({
        builder: this.builder,
        controller: this.mSelectSlotIdDialog as CustomDialogController
      })
    }
    .width('100%')
  }

  @Builder
  MenuBar() {
    if (!this.mPresenter.isPrivateNumber) {
      // v小折叠外屏，只显示 收藏 按钮
      Row({ space: 8 }) {
        if ((this.mPresenter.contactId != undefined || !this.mPresenter.isYellowPage) && !this.maintenanceMode) {
          Button() {
            SymbolGlyph(this.mPresenter.contactId != undefined ? $r('sys.symbol.square_and_pencil') :
            $r('sys.symbol.plus'))
              .fontSize($r('app.float.id_card_margin_max'))
              .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                !this.isVerde) ? [$r('app.color.skin_ohos_id_color_primary_contrary')] :
                [$r('app.color.skin_icon_primary')])
          }
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility,
              this.mPresenter.contactId != undefined ? $r('app.string.edit_contact') : $r('app.string.create_contact')))
          .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .id('detail_edit_menu')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .backgroundEffect(
            (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
              !this.isVerde) ? this.cardBtnBackEffect : this.normalBtnBackEffect
          )
          .backgroundColor(this.isPC ? Color.Transparent :
            !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF')
          .visibility(this.isVerde || this.isShowJumpButton ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            HiLog.w(TAG, 'Menu Edit/New Contact Button onClick');
            if (this.mPresenter.isMyCard) {
              //联系人打点-我的名片详情点击编辑
              contactParams.ENC = 1;
              DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.EDIT_MYCARD_EVENT);
            } else if (this.mPresenter.contactId != undefined) {
              //联系人打点-联系人详情点击编辑联系人
              DotUtil.getInstance().contactDot(this.clickEditParams, CLICK_EDIT_CONTACT_EVENT);
            } else {
              // 新建联系人打点-通话记录详情页处
              this.contactParams.ENC = 3;
              DotUtil.getInstance().contactDot(this.contactParams, CONTACT_ADD_EVENT);
            }
            this.mPresenter.updateContact();
            AppStorage.setOrCreate('accountantParams', this.mPresenter.params);
            this.isShowAccountants = true;
          })
          .enabled(!this.isShowPickerMaskLayer)
        }
        // 畅连隐藏收藏、分享能力
        if (!this.isFromMeetime) {
          if (!this.mPresenter.isMyCard) {
            Button() {
              SymbolGlyph(this.mPresenter.isFavorited === '1' ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
                .fontSize($r('app.float.id_card_margin_max'))
                .fontColor([this.mPresenter.isFavorited === '1' ? $r('app.color.skin_font_emphasize') :
                  ((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                    !this.isVerde) ? $r('app.color.skin_ohos_id_color_primary_contrary') :
                  $r('app.color.skin_icon_primary'))])
            }
            .id('add_favorite_info')
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility,
                '1' === this.mPresenter.isFavorited.toString() ? $r('app.string.cancel_favorite') :
                $r('app.string.accessibility_new_collect')))
            .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
            .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
            .width($r('app.float.id_card_image_mid'))
            .height($r('app.float.id_card_image_mid'))
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .backgroundEffect(
              (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
                !this.isVerde) ? this.cardBtnBackEffect : this.normalBtnBackEffect
            )
            .backgroundColor(this.isPC ? Color.Transparent :
              !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF')
            .visibility(this.mPresenter.contactId != undefined ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              if ('0' === this.mPresenter.isFavorited) {
                FavoriteListPresenter.getInstance().favoriteDataSource.favoriteContactIdList.push(this.selectContactId);
                // 联系人打点--收藏
                this.favoriteDetailsParams.ISFAVORITE = 1;
                this.mPresenter.isFavorited = '1';
                this.mFavoriteListPresenter.addFavoriteInfo(
                  [this.mPresenter.contactId?.toString()],
                  px2vp(this.fullScreenPadding.bottom as number), this.getUIContext());
              } else {
                FavoriteListPresenter.getInstance().favoriteDataSource.deleteFavoriteContactId(this.selectContactId);
                // 联系人打点--取消收藏
                this.favoriteDetailsParams.ISFAVORITE = 0;
                this.mPresenter.isFavorited = '0';
                if ((this.mainTabsIndex === IndexPresenter.getInstance().favoriteIndex) && (this.curBp !== 'sm')) {
                  HiLog.w(TAG, 'emitFavoriteDefaultSelectedContact, value is: ' + this.mainTabsIndex)
                  this.pathInfos.pop(false);
                }
                // 点击取消收藏主动播报
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId($r('app.string.cancel_favorite').id));
                this.mPresenter.updateFavorite(Number.parseInt(this.mPresenter.isFavorited));
              }
              AccessibilityUtil.getInstance()
                .sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'add_favorite_info');
              DotUtil.getInstance().contactDot(this.favoriteDetailsParams, FAVORITE_CONTACT_DETAILS_EVENT);
            })
            .enabled(!this.isShowPickerMaskLayer)
          }
        }
// 更多按钮
        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor((this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap &&
              !this.isVerde) ? [$r('app.color.skin_ohos_id_color_primary_contrary')] :
              [$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.mores')))
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .id('more_btn')
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .backgroundEffect(
          (this.mSystemModeController.getIsEnablePosterAvatar() && this.mPresenter.cardPhotoPixelMap && !this.isVerde) ?
          this.cardBtnBackEffect : this.normalBtnBackEffect
        )
        .backgroundColor(this.isPC ? Color.Transparent :
          !this.mPresenter.photoPixelMap ? $r('sys.color.comp_background_tertiary') : '#19FFFFFF')
        .bindMenu(this.MenuBuilder, {
          placement: Placement.BottomRight,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
          onDisappear: () => {
            this.initBlockListParam()
          }
        })
        .visibility(this.isVerde || this.isShowJumpButton ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          let count: number = this.mPresenter.contactForm.phones.length;
          this.hasPhonesToBlock = count > 0 ? true : false;
          if (count > 0) {
            this.blockPhones = [];
            if (this.mPresenter.sourceHasPhone) {
              this.blockPhones.push(this.mPresenter.phoneNumberShow);
            }
            for (let i = 0; i < this.mPresenter.contactForm.phones.length; i++) {
              this.blockPhones.push(this.mPresenter.contactForm.phones[i].num as string);
            }
            CallRecordPresenter.getInstance().isInBlockOrAccessList(
              this.blockPhones,
              BlockType.BLOCK,
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              (result: boolean) => {
                if (result) {
                  this.isInBlock = result;
                } else if (!this.mPresenter.contactId) {
                  CallRecordPresenter.getInstance().isInStartWithBlock(this.blockPhones[0],
                    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
                    (result: boolean) => {
                      this.isInBlock = result;

                    });
                } else {
                  this.isInBlock = result;
                }
              }
            );
          }

          if (this.mPresenter.isMyCard) {
            //联系人打点-我的名片详情点击更多
            DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.CLICK_MYCARD_MENU_EVENT);
          } else {
            // 联系人打点-联系人详情点击菜单
            DotUtil.getInstance().contactDot(this.customParams, CONTACT_DETAILS_MENU_EVENT);
          }
        })
        .enabled(!this.isShowPickerMaskLayer)
      }
      .margin({ end: this.isPC ? LengthMetrics.vp(144) : LengthMetrics.resource($r('sys.float.padding_level8')) })
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .height($r('app.float.id_item_height_large'))
    }
  }

  @Styles
  menusItem() {
    .width($r('app.float.id_card_image_mid'))
    .height($r('app.float.id_card_image_mid'))
    .borderRadius($r('app.float.rounded_corners_width_20'))
    .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
  }

  onDeleteConfirm: Function = () => {
    HiLog.i(TAG, `onDeleteConfirm this.index=${this.index},contactId=${this.selectContactId}`);
    // 删除联系人
    this.mPresenter.doDeleteContact(this.mPresenter.isMyCard ? -1 : this.index);
    // 删除联系人对话框 保存情况下打点
    this.deleteDialogContactParams.ISPOP = 1;
    this.deleteDialogContactParams.ISDELETE = 1;
    DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
  }
  onDeleteCancel: Function = () => {
    this.deleteDialogContactParams.ISPOP = 1;
    this.deleteDialogContactParams.ISDELETE = 0;
    DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
  }
  deleteDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.delete_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.onDeleteCancel?.();
          this.deleteDialogControler?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          this.onDeleteConfirm?.();
          this.deleteDialogControler?.close();
          if (this.pageFlag === 'page_flag_contact_details') {
            setTimeout(() => {
              this.mPresenter.returnDesktop();
            }, 200);
          }
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          if (this.curBp === 'md' || this.curBp === 'lg') {
            if (this.isFromCallLog){
            CallRecordPresenter.getInstance().toDefaultPage();
            }
          }
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    closeAnimation: { duration: 100 }
  });

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .strokeWidth('1px')
      .width('100%')
      .alignSelf(ItemAlign.Stretch)
      .visibility(Visibility.Visible)
      .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      if (this.mPresenter.contactId !== undefined) {
        if (!this.mPresenter.isMyCard) {
          if (this.hasPhonesToBlock && call.hasVoiceCapability() && !this.isPrivateAccount) {
            MenuItem({
              content: (this.isInBlock ? $r('app.string.delete_from_block_list') : $r('app.string.add_to_blocklist'))
            })
              .enabled(this.isOnCallSharingValue)
              .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
              .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
              .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
              .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .margin({
                top: this.isPC ? $r('sys.float.padding_level1') : 0
              })
              .onChange(() => {
                if (this.isInBlock) {

                  contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
                  DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.REMOVE_BLOCKLIST_EVENT);
                  CallRecordPresenter.getInstance().cancelBlockList(this.blockPhones,
                    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                      HiLog.i(TAG, 'cancelBlockList result:' + result);
                    });
                } else {
                  contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
                  DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.ADD_BLOCKLIST_EVENT);
                  CallRecordPresenter.getInstance().addToBlockList(this.blockPhones,
                    this.getBlockDisplayName(), (result: boolean) => {
                    HiLog.i(TAG, 'addToBlockList result:' + result);
                  });
                }
              })
              .onClick(() => {
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId((!this.isInBlock ?
                  $r('app.string.already_in_block') : $r('app.string.delete_from_block_list')).id));
              })
            if (!this.isPC) {
              this.MenuDivider()
            }
          }
        }
        MenuItem({ content: ($r('app.string.delete_contact')) })
          .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .margin({
            top: this.isPC ? $r('sys.float.padding_level1') : 0
          })
          .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
          .onChange(() => {
            if (this.mPresenter.isMyCard) {
              DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.DELETE_MYCARD_EVENT);
            } else {
              this.contactParams.ENC = 1;
              DotUtil.getInstance().contactDot(this.contactParams, DELETE_CONTACT_EVENT);
            }

            this.deleteDialogControler?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
          })
      } else {

        if (!this.mPresenter.isYellowPage) {
          if (!this.maintenanceMode) {
            MenuItem({ content: ($r('app.string.save_to_existing_contacts')) })
              .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
              .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
              .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .margin({
                top: this.isPC ? $r('sys.float.padding_level1') : 0
              })
              .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
              .onChange(() => {
                this.saveExistParams.ENC = 3;
                DotUtil.getInstance().contactDot(this.saveExistParams, CLICK_SAVE_EXIST_EVENT);
                this.mPresenter.saveExistingContact()
              })
            if (call.hasVoiceCapability() || !this.isPC) {
              this.MenuDivider();
            }
          }
          if (call.hasVoiceCapability() && !this.isPrivateAccount) {
            MenuItem({ content: ($r('app.string.menu_mark_as')) })
              .enabled(this.isOnCallSharingValue)
              .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
              .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
              .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .margin({
                top: this.isPC ? $r('sys.float.padding_level1') : 0
              })
              .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
              .onChange(() => {
                contactParams.ENC = dotCommon.eventParam.DETAIL_MENU;
                // 联系人打点-号码标记入口-陌生联系人通话记录长按
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.NUMBER_TAG_EVENT);
                this.markAsDialogController?.open();
                DialogControllerManager.getInstance().addDialogController(this.markAsDialogController);
              })
            if (!this.isPC) {
              this.MenuDivider()
            }
          }
        }
        if (this.hasPhonesToBlock && call.hasVoiceCapability() && !this.isPrivateAccount) {
          MenuItem({
            content: (this.isInBlock ? $r('app.string.delete_from_block_list') : $r('app.string.add_to_blocklist'))
          })
            .enabled(this.isOnCallSharingValue)
            .margin({
              top: this.isPC ? $r('sys.float.padding_level1') : 0
            })
            .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
            .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .margin({
              top: this.isPC ? $r('sys.float.padding_level1') : 0
            })
            .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
            .onChange(() => {
              if (this.isInBlock) {
                // 联系人打点-从黑名单中移除-联系人详情和通话记录详情页-菜单（已保存联系人）
                contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.REMOVE_BLOCKLIST_EVENT);
                CallRecordPresenter.getInstance().cancelBlockList(this.blockPhones,
                  ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                    HiLog.i(TAG, 'cancelBlockList result:' + result);
                  });
              } else {
                // 联系人打点-加入黑名单-联系人详情和通话记录详情页-菜单（已保存联系人）
                contactParams.ENC = dotCommon.eventParam.CLICK_CONTACT_CALL_HISTORY_DETAIL;
                DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.ADD_BLOCKLIST_EVENT);
                CallRecordPresenter.getInstance().addToBlockList(this.blockPhones,
                  this.getBlockDisplayName(), (result: boolean) => {
                  HiLog.i(TAG, 'addToBlockList result:' + result);
                });
              }
            })
            .onClick(() => {
              AccessibilityUtil.getInstance()
                .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId((!this.isInBlock ?
                $r('app.string.already_in_block') : $r('app.string.delete_from_block_list')).id));
            })
        }
        if (this.mPresenter.isYellowPage) {
          if (call.hasVoiceCapability()) {
            this.MenuDivider()
          }
          MenuItem({
            content: ($r('app.string.copy_to_account',
              EnvironmentProp.isDeviceTypeTablet() ? ResourceUtil.getStringByResource($r('app.string.tablet')) :
                EnvironmentProp.isPC() ? ResourceUtil.getStringByResource($r('app.string.computer')) :
                ResourceUtil.getStringByResource($r('app.string.phone'))))
          })
            .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .onChange(() => {
              this.mPresenter.updateContact();
              AppStorage.setOrCreate('accountantParams', this.mPresenter.params);
              this.isShowAccountants = true;
            })
        }
      }
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .padding({
      left: $r('app.float.id_card_margin_mid'),
      right: $r('app.float.id_card_margin_mid'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid')
    })
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
    .radius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
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
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'markAsDialogController !!!');
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
        phoneNumber: this.mPresenter.phoneNumberShow,
        isMarked: this.isMarked,
        markType: this.markType,
        markCustom: this.markCustom,
        isInBlock: this.isInBlock,
        markAsDialogController: this.markAsDialogController as CustomDialogController
      })
    }
    .padding({ left: '12vp', right: '12vp' })
  }

  queryingBlockListSwitch() {
    let count: number = this.mPresenter.contactForm.phones.length;
    this.hasPhonesToBlock = count > 0 ? true : false;
    if (count > 0) {
      this.blockPhones = [];
      if (this.mPresenter.sourceHasPhone) {
        this.blockPhones.push(this.mPresenter.phoneNumberShow);
      }
      for (let i = 0; i < this.mPresenter.contactForm.phones.length; i++) {
        this.blockPhones.push(this.mPresenter.contactForm.phones[i].num as string);
      }
      CallRecordPresenter.getInstance().isInBlockOrAccessList(
        this.blockPhones,
        BlockType.BLOCK,
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        (result: boolean) => {

          if (result) {
            this.isInBlock = result;
          } else if (!this.mPresenter.contactId) {
            CallRecordPresenter.getInstance().isInStartWithBlock(this.blockPhones[0],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              (result: boolean) => {
                this.isInBlock = result;

              });
          } else {
            this.isInBlock = result;

          }
        }
      );
    }
  }

  clearTmpFiles(filePath: string, tmpImgPath: string) {
    try {
      fs.rmdirSync(filePath);
      fs.rmdirSync(tmpImgPath);
      HiLog.i(TAG, `share tmp files cleared`);
    } catch (error) {
      HiLog.e(TAG, `clearTmpFiles error:${error?.message}, stack: ${error?.stack}`);
    }
  }

  private async getBlobSourceDataFromId(contactId: number): Promise<number> {
    HiLog.w(TAG, `getBlobDataFromId contactId:${contactId}`);

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('contact_id', contactId);
      conditionArgs.equalTo('type_id', 8);
      let dataShareHelper = await ContactRepository.getInstance()
        .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext())
        .getDataAbilityHelper();
      resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs,
        [RawContacts.CONTACT_ID, Data.BLOB_SOURCE, Data.RAW_CONTACT_ID, Data.DETAIL_INFO, Data.BLOB_DATA]);
      if (resultSet.rowCount === 0) {
        return 0;
      }
      resultSet.goToFirstRow();
      let blobSource: number = resultSet.getLong(resultSet.getColumnIndex(Data.BLOB_SOURCE));
      return blobSource;
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  writeImgIntoFile(filePath: string, callback: () => void) {
    if (!this.mPresenter.cardPhotoPixelMap) {
      callback?.();
      return;
    }
    let imgBytesNum = this.mPresenter.cardPhotoPixelMap.getPixelBytesNumber();
    let imgBuf = new ArrayBuffer(imgBytesNum);
    this.mPresenter.cardPhotoPixelMap.readPixelsToBufferSync(imgBuf);
    let base64Helper = new util.Base64Helper();
    getImagePackingData(this.mPresenter.cardPhotoPixelMap, (data: ArrayBuffer | null) => {
      let buf = buffer.from(data);
      let bufStr = buf.toString('base64', 0, buf.length);
      HiLog.i(TAG, `bufstr.length:${bufStr.length}`)
      let f: fs.File | undefined = undefined;
      try {
        f = fs.openSync(filePath, fs.OpenMode.APPEND | fs.OpenMode.READ_WRITE);
        HiLog.i(TAG, `vcf file fd:${f.fd}`);
        fs.writeSync(f.fd, 'contactImg:\n', {
          encoding: 'utf-8'
        });
        fs.writeSync(f.fd, bufStr);
      } catch (error) {
        HiLog.e(TAG, `write Img into file error:${error?.message}, stack: ${error?.stack}`);
      } finally {
        fs.closeSync(f);
      }

      callback?.();
    })
  }

  @Builder
  deleteDialogCloudDialog() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.contact_will_be_deleted'))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Regular)
              .width('100%')
              .fontColor($r('app.color.skin_font_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 3 : 10)
              .textAlign(TextAlign.Start);
          }
          .constraintSize({ minHeight: $r('app.float.id_setting_22') })

          Row() {
            Column() {
              Checkbox()
                .height($r('app.float.id_card_margin_max'))
                .width($r('app.float.id_card_margin_max'))
                .select(false)
                .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
                .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                .margin($r('sys.float.padding_level0'))
                .padding($r('sys.float.padding_level1'))
                .selectedColor($r('app.color.skin_comp_background_emphasize'))
                .onChange((value: boolean) => {
                  this.isConfirmChecked = value;
                })
            }
            .padding({
              end: LengthMetrics.resource($r('sys.float.padding_level6'))
            })

            Column() {
              Text($r('app.string.read_and_understand'))
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_card_title_margin_top') })
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Subtitle_S'))
                .fontWeight(FontWeight.Regular)
            }
            .layoutWeight(1)
          }
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        }
        .width('100%')
      }
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .margin({
        bottom: 56 + 8
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)

      CustomButtons({
        confirmButtonEnabled: this.isConfirmChecked,
        isErrorConfirmButton: true,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.dialog_delete'),
        onCancel: () => {
          this.onDeleteCancel?.();
          this.isDeleteChecked = false;
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.isConfirmChecked = false;
        },
        onConfirm: () => {
          this.onDeleteConfirm?.();
          this.isDeleteChecked = false;
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          if (this.pageFlag === 'page_flag_contact_details') {
            this.mPresenter.returnDesktop()
          }
          this.isConfirmChecked = false;
        }
      })
        .flexShrink(0)
    }
    .width('100%')
  }

  resBgColor(color: effectKit.Color) {
    let flag = 0.213 * color.red + 0.715 * color.green + 0.072 * color.blue > 255 / 2;
    HiLog.i(TAG, `resBgColor flag:${flag}`);
    return flag ? '#ff000000' : '#ffffffff';
  }
  updateSystemBar() {
    let photo: PixelMap | null = this.mPresenter.cardPhotoPixelMap;
    HiLog.i(TAG, `updateSystemBar cardPhoto: ${photo?.getPixelBytesNumber()}`)
    if (!photo?.getPixelBytesNumber()) {
      HiLog.i(TAG, `updateSystemBar cardPhoto empty`);
      return;
    }
    effectKit.createColorPicker(photo, [0, 0, 1, 0.1])
      .then(async colorPicker => {
        const color = colorPicker.getLargestProportionColor();
        const colorStr = this.resBgColor(color);
        let systemBarProperties: window.SystemBarProperties = {
          statusBarContentColor: colorStr
        }
        let windowObj: window.Window | null | undefined = await window.getLastWindow(getContext(this));
        try {
          if (this.mainTabsIndex === IndexPresenter.getInstance().contactIndex || this.isPC) {
            windowObj.setWindowSystemBarProperties(systemBarProperties);
            if (this.isPC && this.mainWindowObjOnPC !== null && this.mainWindowObjOnPC !== undefined) {
              HiLog.i(TAG, `updateSystemBar on PC.`)
              this.mainWindowObjOnPC.setDecorButtonStyle({ colorMode: colorStr === '#ffffffff'
                ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT })
            }
          }
        } catch (err) {
          HiLog.e(TAG, `setWindowSystemBarProperties, err: ${err.message}`)
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `createColorPicker, error: ${error.message}`)
      });
  }

  async resetSystemBarProperties() {
    try {
      let windowObj: window.Window | null | undefined = await window.getLastWindow(getContext(this));
      if (windowObj) {
        let systemBarProperties: window.SystemBarProperties = {
          statusBarContentColor: this.currentColorMode ? '#ff000000' : '#ffffffff'
        }
        windowObj.setWindowSystemBarProperties(systemBarProperties);
        if (this.isPC && this.mainWindowObjOnPC !== null && this.mainWindowObjOnPC !== undefined) {
          // 使用主窗口更新系统按钮颜色
          this.mainWindowObjOnPC.setDecorButtonStyle({ colorMode: this.currentColorMode
            ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT : ConfigurationConstant.ColorMode.COLOR_MODE_DARK })
        }
      }
    } catch (e) {
      HiLog.e(TAG, `resetSystemBarProperties error:${e?.message}, stack: ${e?.stack}`);
    }
  }

  onColorModeChanged() {
    if (this.mPresenter.cardPhotoPixelMap) {
      this.updateSystemBar();
    }
  }
}

export class ContactDetailForCard {
  public cardPhotoPixelMap: null | PixelMap = null;
  public photoPixelMap: null | PixelMap = null;
  public isYellowPage: boolean = false;
  public titleDisplayName: string = '';
  public isNewNumber: boolean = false;
}

@Builder
function menuDivider() {
  Divider()
    .color($r('app.color.skin_ohos_id_color_list_separator'))
    .strokeWidth('1px')
    .width('100%')
    .alignSelf(ItemAlign.Stretch)
    .visibility(Visibility.Visible)
    .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
}

@Builder
function hdsMenuBuilder(params: ParamsInterface) {
  Menu() {
    if (params.mPresenter.contactId !== undefined) {
      if (!params.mPresenter.isMyCard) {
        if (params.hasPhonesToBlock && call.hasVoiceCapability() && !params.isPrivateAccount) {
          MenuItem({
            content: (params.isInBlock ? $r('app.string.delete_from_block_list') : $r('app.string.add_to_blocklist'))
          })
            .enabled(params.isOnCallSharingValue)
            .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
            .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .margin({
              top: EnvironmentProp.isPC()? $r('sys.float.padding_level1') : 0
            })
            .onChange(() => {
            })
            .onClick(() => {
              params.blockFunction();
              AccessibilityUtil.getInstance()
                .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId((!params.isInBlock ?
                $r('app.string.already_in_block') : $r('app.string.delete_from_block_list')).id));
            })
          if (!EnvironmentProp.isPC()) {
            menuDivider()
          }
        }
      }
      MenuItem({ content: ($r('app.string.delete_contact')) })
        .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .margin({
          top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
        })
        .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
        .onChange(() => {
          params.deleteContact();
        })
    } else {
      if (!params.mPresenter.isYellowPage) {
        if (!params.maintenanceMode) {
          MenuItem({ content: ($r('app.string.save_to_existing_contacts')) })
            .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .margin({
              top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
            })
            .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
            .onChange(() => {
              params.saveExistingContacts();
            })
          if (call.hasVoiceCapability() || !EnvironmentProp.isPC()) {
            menuDivider()
          }
        }
        if (call.hasVoiceCapability() && !params.isPrivateAccount) {
          MenuItem({ content: ($r('app.string.menu_mark_as')) })
            .enabled(params.isOnCallSharingValue)
            .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
            .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
            .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .margin({
              top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
            })
            .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
            .onChange(() => {
              params.markFunction();
            })
          if (!EnvironmentProp.isPC()) {
            menuDivider()
          }
        }
      }
      if (params.hasPhonesToBlock && call.hasVoiceCapability() && !params.isPrivateAccount) {
        MenuItem({
          content: (params.isInBlock ? $r('app.string.delete_from_block_list') : $r('app.string.add_to_blocklist'))
        })
          .enabled(params.isOnCallSharingValue)
          .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .margin({
            top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
          })
          .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
          .onChange(() => {
            params.blockFunction();
          })
          .onClick(() => {
            AccessibilityUtil.getInstance()
              .sendAccessibilityEventInfo(ResourceUtil.getStringByResourceId((!params.isInBlock ?
              $r('app.string.already_in_block') : $r('app.string.delete_from_block_list')).id));
          })
      }
      if (params.mPresenter.isYellowPage) {
        if (call.hasVoiceCapability()) {
          menuDivider()
        }
        MenuItem({
          content: ($r('app.string.copy_to_account',
            EnvironmentProp.isDeviceTypeTablet() ? ResourceUtil.getStringByResource($r('app.string.tablet')) :
              EnvironmentProp.isPC() ? ResourceUtil.getStringByResource($r('app.string.computer')) :
              ResourceUtil.getStringByResource($r('app.string.phone'))))
        })
          .margin({
            top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
          })
          .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
          .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onChange(() => {
            params.copyFunction();
          })
      }
    }
  }
  .width($r('app.float.account_MenuBuilder_width_xl'))
  .padding({
    left: $r('app.float.id_card_margin_mid'),
    right: $r('app.float.id_card_margin_mid'),
    top: $r('app.float.id_card_margin_mid'),
    bottom: $r('app.float.id_card_margin_mid')
  })
  .backgroundBlurStyle(EnvironmentProp.isPC() ? BlurStyle.COMPONENT_REGULAR : undefined)
  .shadow({
    radius: EnvironmentProp.isPC() ? $r('sys.float.ohos_id_default_shadow_s') : 0
  })
  .radius(EnvironmentProp.isPC() ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
}