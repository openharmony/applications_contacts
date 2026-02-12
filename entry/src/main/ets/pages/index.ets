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
import { common } from '@kit.AbilityKit';
import CallRecord from './dialer/callRecord/CallRecord';
import DialerTablet from './dialer/DialerTablet';
import GroupList from './group/GroupList';
import contactPage from './contacts/ContactList';
import favoritePage from './favorites/favoriteList';
import callPage from './phone/dialer/Dialer';
import IndexPresenter from '../presenter/IndexPresenter';
import { DynamicLoader, HiLog, StringUtil, sharedPreferencesUtils } from '../../../../../common';
import { PermissionManager } from '../../../../../common/src/main/ets/permission/PermissionManager';
import DialerPresenter from '../presenter/dialer/DialerPresenter';
import call from '@ohos.telephony.call';
import ContactListPresenter from '../presenter/contact/ContactListPresenter';
import CallRecordPresenter from '../presenter/dialer/callRecord/CallRecordPresenter';
import HiCarCallRecordPresenter from '../presenter/dialer/callRecord/HiCarCallRecordPresenter';
import FavoriteListPresenter from '../presenter/favorite/FavoriteListPresenter';
import device from '@system.device';
import emitter from '@ohos.events.emitter';
import EmitterConstant from '../data/EmitterConstant';
import hiTraceMeter from '@ohos.hiTraceMeter';
import { CustomizedParams, RecorderLog, TargetPageInter } from '../model/type';
import { CustomTransition, TitleAnimation } from '../util/CustomNavigationUtil'
import simIccDiallingNumbers from '../../ets/feature/sim/SimIccDiallingNumbers';
import telephonySim from '@ohos.telephony.sim';
import curves from '@ohos.curves';
import DialerPad from './dialer/dialerPad/DialerPad';
import ContactDefaultPage from './contacts/defaultpages/ContactDefaultPage';
import FavoriteDefaultPage from './contacts/defaultpages/FavoriteDefaultPage';
import BatchDeleteContacts from './contacts/settings/BatchDeleteContacts';
import { removeAirPlaneModeListener } from '../model/AirplaneModel';
import { Params } from '../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import DotUtil from '../util/DotUtil';
import dotCommon, { importContactParams } from '../util/DotCommon';
import { TaskUtil } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/TaskUtil';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomProgressContent from './dialog/CustomProgressContent';
import { PhoneNumber } from '../../../../../feature/phonenumber';
import HarassmentFilter from './dialer/harassmentfilter/HarassmentFilter';
import mediaquery from '@ohos.mediaquery';
import Accountants, { AccountantTitleClass, NavDestinationHeaderView } from './contacts/accountants/Accountants';
import { display, LengthMetrics, performanceMonitor, router, SymbolGlyphModifier, window } from '@kit.ArkUI';
import DialerConstant from '../data/DialerConstant';
import { defaultCustomTheme } from '../data/ThemeColorConstant';
import { HiCarIndex } from './hicar/HiCarIndex';
import { HiCarConstants } from '../data/HiCarConstants';
import { isVoiceAppEnabled } from '../util/CallAssistantUtil';
import { inputMethod } from '@kit.IMEKit';
import AccessibilityUtil from '../util/AccessibilityUtil';
import VDialPad from './dialer/dialerPad/VDialerPad';
import { SearchUtil } from '../util/SearchUtil';
import { DisplaySplitUtil, SplitStatus } from '../util/DisplaySplitUtil';
import Settings from './contacts/settings/Settings';
import { removeSettingModeListener } from '../model/CallSharingModel';
import { CallSharingClass } from '../card/data/commonData';
import { CallLogRepository } from '../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { DialogControllerManager } from '../MainAbility/ControllerManager';
import { AppStorageConstant } from '../../../../../common/src/main/ets/AppStorageConstant';
import EnvironmentProp from '../feature/EnvironmentProp';
import { queryUserDpiValue, addUserDpiValueListener, removeUserDpiValueListener } from '../model/GetDpiZoomSize';
import { settings } from '@kit.BasicServicesKit';
// import { CloudSyncCardService } from '@hms-paf/ui-widget-cloudsync';
import { FoldedAndContinuedType } from '../util/ScreenFormUtil';
import prompt from '@ohos.promptAction';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { SystemModeController, terminateUIAbilitySelf, ModeType } from '../util/SystemModeController';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';
// import {
//   BlurStrategy,
//   DividerMode,
//   HdsNavigation,
//   HdsNavigationAttribute,
//   HdsNavigationTitleMode,
//   HdsTabs,
//   HdsTabsAttribute,
//   HdsTabsController
// } from '@kit.UIDesignKit'
import { sim } from '@kit.TelephonyKit';
import { TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND } from '../data/Constants';
import SideBarButton from './SideBarButton';
import { NewCallUtils } from '../util/NewCallUtils'

const TAG = 'Index ';
const AIRPLANE_MODE = 1;
export const CALL_LOG_DATA='datashare:///com.ohos.calllogability';
export const CALL_LOG_URI='datashare:///com.ohos.calllogability/calls/calllog';

let storage = LocalStorage.GetShared()
const EMITTER_ID_TAB_INDEX_CHANGE = 200;
const emitterIdAddAccountants = 210;
const CONTACTS_TAB_SWITCH_EVENT = 'CONTACTS_TAB_SWITCH_EVENT';
let reapplyTimeoutId:number = 0;
let deleteCalender:number = 0;
PersistentStorage.persistProp(AppStorageConstant.MYCARD_CONTACT_ID, '');

@Builder
function dummyFunction(): void {

}

@Entry(storage)
@Component
struct Index {
  private favoritePageScroller: ListScroller = new ListScroller();
  private contactListScroller: ListScroller = new ListScroller();
  private bottomTabsController: TabsController = new TabsController();
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @State mPermissionManager: PermissionManager = PermissionManager.getInstance();
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @StorageLink('mainTabsIndex') @Watch('onIndexChanged') mainTabsIndex: number = 0;
  // 三方应用跳转呼叫前编辑，会设置此值，触发电话号号码变更
  @StorageLink('teleNumber') @Watch('teleNumberChange') teleNumber: string = '';
  // 拨号盘电话号码变更触发通过话记录和联系人搜索
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) @Watch('onTeleNumberChanged') tele_number: string = '';
  mDialerPresenter: DialerPresenter = DialerPresenter.getInstance();
  mContactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  mCallRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @State @Watch('onBottomTabIndexChange') bottomTabIndex: number = 0;
  @State hiCarTabIndex: number = 0;
  // 监听targetPage 属性变化；
  // （1）外部应用跳转联系人，PageManager.onRequest 会设置目标页面，触发这里跳转
  @StorageLink('targetPage') @Watch('targetPageChange') targetPage: TargetPageInter = {};
  @StorageLink('breakpoint') @Watch('updateConListPage') curBp: string = '';
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @StorageLink('contactsList_y') contactsList_y: number = 0;
  @StorageProp(HiCarConstants.KEY_IS_IN_HICAR) isInHiCar: boolean = false;
  exportEmitterId: number = 106;
  @State percent: number = 0;
  isProgressDiaShow: boolean = false;
  isExportDiaShow: boolean = false;
  isCancelExportContactsDiaShow: boolean = false;
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('selectContactId') selectContactId: string = '';
  @State isPortraitDisplay: boolean = false;
  @StorageLink('dialerVisible') dialerVisible: boolean = true;
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @StorageProp('accountantTitleClass') accountantTitleClass: AccountantTitleClass = new AccountantTitleClass();
  // 判断是否显示设置
  @State isShowContactsSettings: boolean = false;
  // 判断是否加载通话设置
  @Provide('isShowCallSetting') isShowCallSetting: boolean = false;
  @Provide('scrollToCardOne') scrollToCardOne: boolean = false; // 打开通话设置后滚动到卡1
  @Provide('showNewCallTip') showNewCallTip: boolean = false; // 是否显示通话设置
  @StorageLink('isShowPicker') isShowPicker: boolean = false;
  private isContactMultiSelect: boolean = false;
  private callSettingProxy: UIExtensionProxy | undefined = undefined;
  @StorageLink('FoldStatus') @Watch('foldStatusChange') foldStatus: display.FoldStatus = 0;
  @StorageLink('isShowSmartWindow') @Watch('onShowSmartWindowChange') isShowSmartWindow: boolean = false;
  @State isPortraitDisplayCarMachine: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('isRingingDialog') isRingingDialog: boolean = false;
  @StorageLink('isNoRingingDialog') isNoRingingDialog: boolean = false;
  @StorageLink('showDialBtn') showDialBtn: boolean = true;
  @StorageProp('isVerde') @Watch('onVerdeChange') isVerde: boolean = false;
  @StorageLink('hideIndexTitleTabBar') @Watch('onHideIndexTitleTabBarChange') hideIndexTitleTabBar: boolean = false;
  @StorageLink('verdeDialerPadMoveY') verdeDialerPadMoveY: number = 0;
  @StorageLink('smartIdentitySwitch') smartIdentitySwitch: string = '';
  @StorageLink('showFraudBanners') showFraudBanners: boolean = false;
  @StorageLink('isShowSwitchPage') isShowSwitchPage: boolean = false;
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @State isShowMaintenanceModeDialog: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  showBirthdayDialog: boolean = false;
  downY: number = 0;
  @StorageLink('isDistributedModemState') @Watch('callCapChange') isDistributedModemState: boolean = false;
  @StorageLink('isDistributedCallPhoneSharing') @Watch('callCapChange') isDistributedCallPhoneSharing: boolean = false;
  @StorageLink('isDistributedCallSourcePhone') @Watch('callCapChange') isDistributedCallSourcePhone: boolean = false;
  @StorageLink('tabContactCall') TABCONTACTCALL: string = call.hasVoiceCapability() ? 'tab_item_1' : 'tab_item_0';
  @StorageLink('tabContactList') TABCONTACTLIST: string = call.hasVoiceCapability() ? 'tab_item_2' : 'tab_item_1';
  @StorageLink('tabContactFavorite') TABCONTACTFAVORITE: string =
    call.hasVoiceCapability() ? 'tab_item_3' : 'tab_item_2';
  @StorageLink('isNavigationModeSplit') @Watch('onNavigationModeChange') isNavigationModeSplit: boolean = false;
  @StorageLink('activeCallId') activeCallId: number = -1;
  @State tabsHeight: string = `100%`
  @State columnHeight: string = `100%`
  @State hasCallCap: boolean = false; // 只用来刷新通话能力，无实际业务作用
  @StorageLink('isShowHarassmentPop') isShowHarassmentPop: boolean = false;
  @StorageLink('isPrimaryAccount') localAccountId: boolean = false;
  @State phoneStatusCurBp: string = '';
  @StorageLink('showSideBar') @Watch('onSideBarStatusChanged') showSideBar: boolean = true;
  @StorageLink('currentColorMode') currentColorMode: number = 1;
  @StorageProp('isMainAbilityForeground') @Watch('onForegroundChange') isMainAbilityForeground: boolean = true;
  @StorageProp('isFromExternalApp') isFromExternalApp: boolean = false;
  @StorageLink('foldedAndContinuedType') foldedAndContinuedType: FoldedAndContinuedType = FoldedAndContinuedType.NULL;
  @StorageLink('foldedAndContinuedTaskId') foldedAndContinuedTaskId: number = -1;
  @StorageLink('foldedAndContinuedToastId') foldedAndContinuedToastId: number = -1;
  @StorageProp(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';
  @StorageLink('windowStatus') @Watch('onWindowStatusChange') windowStatus: window.WindowStatusType =
    window.WindowStatusType.UNDEFINED;
  @StorageProp('NotePadAppEnabled') isNotePadAppEnabledFlag: boolean = true;
  @State message: Record<string, number | string | Resource | RecorderLog[]> = {};
  private listScroller: ListScroller = new ListScroller();
  private isFirstAboutToAppear: boolean = true;
  private isAddedEventListener: boolean = false;  // 只需要冷启动应用后，添加一次SIM卡监听
  private isClickImport = false; // sim导入弹窗点击导入
  private isClickCancel = false; // sim导入弹窗点击暂不导入
  private notesStatus: string = '-1'; // 备忘录不存在笔记条目时状态为-1
  private absCode: string = '-1'; // 未使用通话摘要时状态码为-1
  @StorageLink('isPcMinWindowWidth') isPcMinWindowWidth: boolean = false; // 当前窗口是否是PC的最小化窗口
  @StorageLink('maskOpacity') maskOpacity: number = 0; // mask初始值
  @StorageLink('isNeedExpandSideBar') isNeedExpandSideBar: boolean = false; // PC的侧边栏是否需要拉伸
  @StorageLink('isNeedMask') isNeedMask: boolean = false;
  @StorageProp('notePadJump') notePadJump: boolean = false;
  @StorageProp('notePadId') notePadId: string = '';

  private onWindowStatusChange(): void {
    HiLog.i(TAG, `onWindowStatusChange, windowStatus: ${this.windowStatus}`);
    this.callSettingProxy?.send({'windowStatus': this.windowStatus});
  }

  private isFirstLoadDefaultPage: boolean = true;
  listener = mediaquery.matchMediaSync('(orientation: landscape)');
  tabSwitchParams: CustomizedParams = {
    FLAG: 0,
    ACTION: 0
  };
  exportDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.import_sim_contact_title'),
      contentBuilder: () => {
        this.ExportDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.not_importing_for_now'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'Import SIM contacts Prompt Later');
            this.isClickCancel = true;
            // 联系人打点-导入SIM卡联系人-稍后提示
            importContactParams.IMPORT = dotCommon.eventParam.PROMPT_LATER;
            DotUtil.getInstance().contactDot(importContactParams, dotCommon.eventName.SIM_GUIDE_DIALOG_EVENT);
            this.isExportDiaShow = false;
            simIccDiallingNumbers.savePromptSimIccIds();
            simIccDiallingNumbers.saveSimContactMark();
            simIccDiallingNumbers.clearContactData();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        },
        {
          value: $r('app.string.Import'),
          action: () => {
            HiLog.i(TAG, 'Confirm SIM Contact Import');
            this.isClickImport = true;
            // 联系人打点-导入SIM卡联系人-导入
            importContactParams.IMPORT = dotCommon.eventParam.IMPORT;
            DotUtil.getInstance().contactDot(importContactParams, dotCommon.eventName.SIM_GUIDE_DIALOG_EVENT);
            simIccDiallingNumbers.confirmExport();
            this.exportDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.isExportDiaShow = false;
          },
          buttonStyle: ButtonStyleMode.EMPHASIZED
        }
      ]
    }),
    onDidDisappear: () => {
      // sim卡导入弹窗，侧滑退出后，需要将查询到的sim卡联系人数据清空
      if (!this.isClickCancel && !this.isClickImport) {
        HiLog.w(TAG, `SIM dialog onDidDisappear, clear contactData`);
        this.isExportDiaShow = false;
        simIccDiallingNumbers.savePromptSimIccIds();
        simIccDiallingNumbers.saveSimContactMark();
        simIccDiallingNumbers.clearContactData();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
        this.isClickImport = false;
        this.isClickCancel = false;
      }
    },
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  exportContactsProgressDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.importing_contacts'),
      contentBuilder: () => {
        this.ExportContactsProgressDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.hide'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.exportContactsProgressDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  cancelExportContactsDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.is_stop_import_contact'),
      primaryButton: {
        value: $r('app.string.cancel_stop_import'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.isCancelExportContactsDiaShow = false;
        }
      },
      secondaryButton: {
        value: $r('app.string.cancel_stop_import'),
        action: () => {
          simIccDiallingNumbers.sureCancelImport();
          this.isCancelExportContactsDiaShow = false;
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  private getSimCardState() {
    const maxSimCount = telephonySim.getMaxSimCount();
    let processedCount = 0;  // 已处理sim卡数量
    let isEmit = false; // 根据卡中有无联系人，决定是否通知
    let exportEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EXPORT_EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    };

    for (let i = 0; i < maxSimCount; i++) {
      telephonySim.isSimActive(i, (err, value) => {
        if (err) {
          HiLog.e(TAG, `isSimActive, ${i} error: ${err?.message}`);
          processedCount++;
          if (processedCount === maxSimCount && isEmit) {
            emitter.emit(exportEvent);
          }
        } else {
          HiLog.i(TAG, `isSimActive, ${i} value: ${value} isFirstCall: ${this.isFirstAboutToAppear}`);
          if (value) {
            simIccDiallingNumbers.getNumbersBySlotId(i, 1, (isHasNumbers) => {
              processedCount++;
              if (isHasNumbers) {
                isEmit = true;
              }
              if (processedCount === maxSimCount && isEmit) {
                // 所有SIM卡数据处理完毕，触发通知
                HiLog.i(TAG, 'getNumbers onComplete emitter');
                emitter.emit(exportEvent);
              }
            });
          } else {
            processedCount++;
            if (processedCount === maxSimCount && isEmit) {
              emitter.emit(exportEvent);
            }
          }
        }
      });
    }
  }

  onBottomTabIndexChange() {
    IndexPresenter.getInstance().updateCurIndex(this.bottomTabIndex)
  }

  onVerdeChange() {
    if (this.isVerde) {
      // 内屏切外屏
      HiLog.i(TAG, `onVChange`);
      if (!this.isFromExternalApp && this.pathInfos.size() > 0 &&
        this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] !== 'ContactDetail') {
        // 清除外屏不支持页面
        HiLog.w(TAG, `isVChange clear pathInfos!`);
        this.pathInfos.clear(false);
      }
    }
    this.hideIndexTitleTabBar = false;
  }

  callCapChange() {
    this.hasCallCap = this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
    this.isDistributedCallSourcePhone;
  }

  loaderMap: Map<String, ($$: Params) => void> = new Map<String, ($$: Params) => void>();
  @BuilderParam pageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam contactDetailLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam batchSelectContactsPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam SingleSelectContactPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam editFavoriteListLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam BatchDeleteRecordLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam batchDeleteGroupPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam groupListDetailPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam intelligenceGroupSingleCategoryDetailLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam intelligenceGroupSingleGroupDetailLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam intelligenceGroupSelectMemSendMsgLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam removeMemberPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam selectMemberSendMessageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam addFavoriteListPageLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam batchDeleteContactsLoader: ($$: Params) => void = dummyFunction;

  @Builder
  myRouter(name: string, param?: Object) {
    if (name === 'CallRecord') {
      CallRecord({ controller: this.bottomTabsController, listScroller: this.listScroller });
    } else if (name === 'ContactDetail') {
      this.contactDetailLoader(param as Params);
    } else if (name === 'DialerTablet') {
      DialerTablet();
    } else if (name === 'BatchSelectContactsPage') {
      this.batchSelectContactsPageLoader(param as Params);
    } else if (name === 'SingleSelectContactPage') {
      this.SingleSelectContactPageLoader(param as Params);
    } else if (name === 'editFavoriteList') {
      this.editFavoriteListLoader(param as Params);
    } else if (name === 'BatchDeleteRecord') {
      this.BatchDeleteRecordLoader(param as Params);
    } else if (name === 'GroupList') {
      GroupList();
    } else if (name === DynamicLoader.BATCH_DELETE_GROUP) {
      this.batchDeleteGroupPageLoader(param as Params);
    } else if (name === 'HarassmentFilter') {
      HarassmentFilter();
    } else if (name === DynamicLoader.GROUP_LIST_DETAIL) {
      this.groupListDetailPageLoader(param as Params);
    } else if (name === DynamicLoader.REMOVE_MEMBER) {
      this.removeMemberPageLoader(param as Params);
    } else if (name === DynamicLoader.SELECT_MEMBER_SEND_MESSAGE) {
      this.selectMemberSendMessageLoader(param as Params);
    } else if (name === 'addFavoriteList') {
      this.addFavoriteListPageLoader(param as Params);
    } else if (name === 'DialerPad') {
      DialerPad();
    } else if (name === 'ContactDefaultPage') {
      ContactDefaultPage();
    } else if (name === 'FavoriteDefaultPage') {
      FavoriteDefaultPage();
    } else if (name === DynamicLoader.INTELLIGENCE_GROUP_SINGLE_CATEGORY_DETAIL) {
      this.intelligenceGroupSingleCategoryDetailLoader(param as Params);
    } else if (name === DynamicLoader.INTELLIGENCE_GROUP_SINGLE_GROUP_DETAIL) {
      this.intelligenceGroupSingleGroupDetailLoader(param as Params);
    } else if (name === DynamicLoader.INTELLIGENCE_GROUP_SELECT_MEM_SEND_MSG) {
      this.intelligenceGroupSelectMemSendMsgLoader(param as Params);
    } else if (name === DynamicLoader.BATCH_DELETE_CONTACTS) {
      BatchDeleteContacts();
    }
  }

  async dynamicLoadCallBack(key: string): Promise<boolean> {
    HiLog.i(TAG, 'dynamicLoadCallBack page :  ' + key);
    if (key === DynamicLoader.BATCH_SELECT_CONTACTS_PAGE) {
      let batchSelectContactsPageLoader = await import('./contacts/batchselectcontacts/ContactsPickerPage');
      this.batchSelectContactsPageLoader = batchSelectContactsPageLoader.ContactsPickerPageLoader;
      this.loaderMap.set(DynamicLoader.BATCH_SELECT_CONTACTS_PAGE, this.batchSelectContactsPageLoader)
    } else if (key === DynamicLoader.CONTACT_DETAIL_PAGE) {
      let pageLoader = await import('./contacts/details/ContactDetail');
      this.contactDetailLoader = pageLoader.ContactDetailLoader;
      this.loaderMap.set(DynamicLoader.CONTACT_DETAIL_PAGE, this.contactDetailLoader);
    } else if (key === DynamicLoader.EDIT_FAVORITE_LIST_PAGE) {
      let pageLoader = await import('./favorites/editFavoriteList');
      this.editFavoriteListLoader = pageLoader.EditFavoriteListLoader;
      this.loaderMap.set(DynamicLoader.EDIT_FAVORITE_LIST_PAGE, this.editFavoriteListLoader);
    } else if (key === DynamicLoader.BATCH_DELETE_RECORD_PAGE) {
      let pageLoader = await import('./dialer/batchdelete/BatchDeleteRecord');
      this.BatchDeleteRecordLoader = pageLoader.BatchDeleteRecordLoader;
      this.loaderMap.set(DynamicLoader.BATCH_DELETE_RECORD_PAGE, this.BatchDeleteRecordLoader);
    } else if (key === DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE) {
      let batchSelectContactsPageLoader = await import('./contacts/batchselectcontacts/ContactsPickerPage');
      this.SingleSelectContactPageLoader = batchSelectContactsPageLoader.ContactsPickerSinglePageLoader;
      this.loaderMap.set(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE, this.SingleSelectContactPageLoader)
    } else if (key === DynamicLoader.BATCH_DELETE_GROUP) {
      let pageLoader = await import('./group/BatchDeleteGroup');
      this.batchDeleteGroupPageLoader = pageLoader.BatchDeleteGroupLoader;
      this.loaderMap.set('BatchDeleteGroup', this.batchDeleteGroupPageLoader);
    } else if (key === DynamicLoader.GROUP_LIST_DETAIL) {
      let pageLoader = await import('./group/GroupListDetail');
      this.groupListDetailPageLoader = pageLoader.GroupListDetailLoader;
      this.loaderMap.set('GroupListDetail', this.groupListDetailPageLoader);
    } else if (key === DynamicLoader.REMOVE_MEMBER) {
      let pageLoader = await import('./group/RemoveMember');
      this.removeMemberPageLoader = pageLoader.RemoveMemberLoader;
      this.loaderMap.set('RemoveMember', this.removeMemberPageLoader);
    } else if (key === DynamicLoader.SELECT_MEMBER_SEND_MESSAGE) {
      let pageLoader = await import('./group/SelectMemberSendMessage');
      this.selectMemberSendMessageLoader = pageLoader.SelectMemberSendMessageLoader;
      this.loaderMap.set('SelectMemberSendMessage', this.selectMemberSendMessageLoader);
    } else if (key === DynamicLoader.ADD_FAVORITE_LIST_PAGE) {
      let pageLoader = await import('./favorites/addFavoriteList');
      this.addFavoriteListPageLoader = pageLoader.AddFavoriteListLoader;
      this.loaderMap.set(DynamicLoader.ADD_FAVORITE_LIST_PAGE, this.addFavoriteListPageLoader);
    } else if (key === DynamicLoader.INTELLIGENCE_GROUP_SINGLE_CATEGORY_DETAIL) {
      let pageLoader = await import('./intelligencegroup/IntelligenceGroupSingleCategoryDetail');
      this.intelligenceGroupSingleCategoryDetailLoader = pageLoader.IntelligenceGroupSingleCategoryDetailLoader;
      this.loaderMap.set('IntelligenceGroupSingleCategoryDetail', this.intelligenceGroupSingleCategoryDetailLoader);
    } else if (key === DynamicLoader.INTELLIGENCE_GROUP_SINGLE_GROUP_DETAIL) {
      let pageLoader = await import('./intelligencegroup/IntelligenceGroupSingleGroupDetail');
      this.intelligenceGroupSingleGroupDetailLoader = pageLoader.IntelligenceGroupSingleGroupDetailLoader;
      this.loaderMap.set('IntelligenceGroupSingleGroupDetail', this.intelligenceGroupSingleGroupDetailLoader);
    } else if (key === DynamicLoader.INTELLIGENCE_GROUP_SELECT_MEM_SEND_MSG) {
      let pageLoader = await import('./intelligencegroup/IntelligenceGroupSelectMemSendMsg');
      this.intelligenceGroupSelectMemSendMsgLoader = pageLoader.IntelligenceGroupSelectMemSendMsgLoader;
      this.loaderMap.set('IntelligenceGroupSelectMemSendMsg', this.intelligenceGroupSelectMemSendMsgLoader);
    } else if (key === DynamicLoader.BATCH_DELETE_CONTACTS) {
      let pageLoader = await import('./contacts/settings/BatchDeleteContacts');
      this.batchDeleteContactsLoader = pageLoader.batchDeleteContactsLoader;
      this.loaderMap.set(DynamicLoader.BATCH_DELETE_CONTACTS, this.batchDeleteContactsLoader);
    }

    let pageLoader = (this.loaderMap.get(key) as ($$: Params) => void)
    HiLog.i(TAG, 'dymic load page: ' + key + '--' + (pageLoader === undefined))
    return pageLoader === undefined
  }

  onNavigationModeChange() {
    if (this.isNavigationModeSplit) {
      // 平板分屏状态下 第一次加载默认页面，因isNavigationModeSplit还未刷新，导致分屏状态下默认页面没有加载，需要在此处进行一次加载
      if (this.isFirstLoadDefaultPage && this.bottomTabIndex == this.mIndexPresenter.callIndex) {
        HiLog.i(TAG, `onNavigationModeChange load default page`)
        this.isFirstLoadDefaultPage = false;
      }
    } else {
      HiLog.i(TAG, `onNavigationModeChange clear pathInfos`)
      }
  }

  initPhoneNumberAlertDialog() {
    PhoneNumber.isRingingDialogController = new CustomDialogController({
      builder: AlertDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        content: $r('app.string.AnswerorDeclineIncomingCall_beforeNewCall'),
        primaryButton: {
          value: $r('app.string.got_it'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'click cancel');
          },
        }
      }),
      autoCancel: true,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });

    PhoneNumber.isNoRingingDialogController = new CustomDialogController({
      builder: AlertDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        content: $r('app.string.cannot_start_a_new_call'),
        primaryButton: {
          value: $r('app.string.got_it'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'click cancel');
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      }),
      autoCancel: true,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });
  }

  teleNumberChange() {
    if (!StringUtil.isEmpty(this.teleNumber)) {
      this.mDialerPresenter.editPhoneNumber(this.teleNumber);
      AppStorage.SetOrCreate('showDialBtn', true);
      this.teleNumber = '';
    }
  }

  maintenanceModeDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.contacts_maintenancemode'),
      primaryButton: {
        value: $r('app.string.got_it'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          router.back();
          setTimeout(() => {
            this.mainTabsIndex = 0;
            this.maintenanceModeDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.isShowMaintenanceModeDialog = false;
            if (call.hasVoiceCapability()) {
              this.mCallRecordPresenter.toDefaultPage();
            }
          }, 50)
        }
      }
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      dismissDialogAction.reason == DismissReason.PRESS_BACK
    },
    autoCancel: false,
  });

  async onTeleNumberChanged() {
    if (this.maintenanceMode) {
      HiLog.i(TAG, `this.maintenanceMode onTeleNumberChanged, value is ${this.maintenanceMode}`);
      return;
    }

    if (!StringUtil.isEmpty(this.tele_number)) {
      await SearchUtil.getInstance().initSearchSession();
      this.mDialerPresenter.dialerSearch();
    }
  }

  maintenanceModeTabClick() {
    if (this.maintenanceMode) {
      this.maintenanceModeDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.maintenanceModeDialogController);
      this.isShowMaintenanceModeDialog = true;
      return;
    }
  }

  onHideIndexTitleTabBarChange() {
    if (this.isVerde) {
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        if (this.hideIndexTitleTabBar) {
          this.tabsHeight = `calc(100% + 52vp)`;
          this.columnHeight = `calc(100% + 56vp)`;
        } else {
          this.tabsHeight = `100%`;
          this.columnHeight = `100%`;
        }
      });
    } else {
      this.tabsHeight = `100%`;
      this.columnHeight = `100%`;
    }
  }

  @Builder
  ShowAccountantsView() {
    Column() {
      Accountants({ isShowAccountants: $isShowAccountants })
    }.width('100%').height('100%')
  }

  @Builder
  ShowContactsSettings() {
    Column() {
      Settings()
    }.width('100%').height('100%')
  }

  @Builder
  PickerDataBuilder() {
    Column() {
      UIExtensionComponent(
        {
          bundleName: 'com.ohos.contacts',
          abilityName: 'ContactUiExtentionAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'targetUrl': 'BatchSelectContactsPage',
            'isContactMultiSelect': this.isContactMultiSelect,
          }
        })
        .id('picker_extension_id')
        .onRemoteReady((proxy: UIExtensionProxy) => {
          focusControl.requestFocus('picker_extension_id');
        })
        .onTerminated((data) => {
          HiLog.i(TAG, `onResult : ${data?.code}`);
          this.isShowPicker = false;
          if (this.isShowCallSetting) {
            focusControl.requestFocus('call_setting_extension_id');
          }
        })
        .onError(() => {
          HiLog.e(TAG, 'picker onError');
          this.isShowPicker = false;
        })
        .gesture(
          PanGesture().onActionStart(() => {

          })
        )
        .onReceive((data) => {
          HiLog.i(TAG, `onReceive :  ${data?.message}`);
          if (data && data.want) {
            const want = data.want as Want;
            if (want.parameters && want.parameters.contactObjects) {
              this.callSettingProxy?.send({
                'pickerData': want.parameters.contactObjects,
                'isContactMultiSelect': this.isContactMultiSelect,
              });
            }
          }
          this.isShowPicker = false;
        })
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
    }.width('100%').height('100%')
  }

  postMessage() {
    let event: emitter.InnerEvent = {
      eventId: emitterIdAddAccountants,
      priority: emitter.EventPriority.HIGH
    };
    let exportData: emitter.EventData = {
      data: {
        'params': this.targetPage.params
      }
    }
    emitter.emit(event, exportData);
  }

  targetPageChange() {
    if (this.targetPage && this.targetPage.url) {
      HiLog.w(TAG, `targetPageChange, urlName: ${this.targetPage.url}`);
      // 外部跳转联系人应用，首先清空路由信息
      this.pathInfos.clear(false);
      // 分屏加载默认页面
      if (this.pathInfos.size() === 0 && this.curBp != 'sm') {
        switch (this.bottomTabIndex) {
          case this.mIndexPresenter.callIndex:
            this.mCallRecordPresenter.toDefaultPageWhenOnNewWant();
            break
          case this.mIndexPresenter.contactIndex:
            this.mContactListPresenter.toDefaultPage();
            if (this.targetPage.url === 'pages/index' || this.targetPage.url === 'Accountants' ||
              this.targetPage.url === 'Settings') {
              this.mIndexPresenter.emitDefaultSelectedContact();
            }
            break
          case this.mIndexPresenter.favoriteIndex:
            this.mFavoriteListPresenter.toDefaultPage();
            break
        }
      }
      // 外部跳转至新建联系人
      if (this.targetPage.url === 'Accountants') {
        AppStorage.setOrCreate('accountantParams', this.targetPage.params);
        setTimeout(() => {
          HiLog.w(TAG, 'from external accountants');
          this.isShowAccountants = true;
        }, 50)
        return;
      // 外部跳转至设置页面
      } else if (this.targetPage.url === 'Settings') {
        let isShowContactsSettings: boolean | undefined = AppStorage.get<boolean>('isShowContactsSettings');
        !isShowContactsSettings && (this.isShowContactsSettings = true);
        return;
      } else {
        // 再跳转至指定页面
        this.mIndexPresenter.goToPage(this.targetPage.url, this.targetPage.pageIndex, this.targetPage.params)
        this.targetPage = {};
      }
    }
  }

  changeTabBarIndex() {
    let event: emitter.InnerEvent = {
      eventId: EMITTER_ID_TAB_INDEX_CHANGE,
      priority: emitter.EventPriority.HIGH
    };
    let exportData: emitter.EventData = {
      data: {
        'mainTabsIndex': this.mainTabsIndex
      }
    }
    emitter.emit(event, exportData);
  }

  onIndexChanged(): void {
    if (this.mainTabsIndex != this.bottomTabIndex) {
      HiLog.w(TAG, 'uriTabIndex change:' + this.mainTabsIndex);
      this.bottomTabIndex = this.mainTabsIndex;
      this.changeTabBarIndex();
      // 进入通话，联系人，收藏  某个tab
      this.mCallRecordPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.callIndex);
      this.mContactListPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.contactIndex);
      this.mFavoriteListPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.favoriteIndex);
    }
  }

  /**
   *
   * 折叠屏展开时, 如果底部Tab是联系人时, 则默认选中第一个联系人
   */
  foldScreenDefaultSelectedContact() {
    try {
      if (this.mainTabsIndex === this.mIndexPresenter.contactIndex) {
        this.mIndexPresenter.emitDefaultSelectedContact();
      } else if (this.mainTabsIndex === this.mIndexPresenter.favoriteIndex) {
        this.mFavoriteListPresenter.emitFavoriteDefaultSelectedContact();
      }
    } catch (err) {
      HiLog.e(TAG, `on foldStatus change err: ${err?.message}`);
    }
  }

  foldStatusChange() {
    this.foldScreenDefaultSelectedContact();
    setTimeout(() => {
      if (this.isShowPicker) {
        focusControl.requestFocus('picker_extension_id');
      } else if (this.isShowCallSetting) {
        focusControl.requestFocus('call_setting_extension_id');
      }
    }, 260)
  }

  /**
   * 监听isShowSmartWindow值变化触发拨号盘页面刷新
   * isShowSmartWindow的改变晚于curBp值得改变，导致DialerPad页面不加载，需要监听isShowSmartWindow触发DialerPad页面刷新
   */
  private onShowSmartWindowChange(): void {
    HiLog.i(TAG, `onShowSmartWindowChange isShowSmartWindow: ${this.isShowSmartWindow}, curBp: ${this.curBp}`);
    if (!this.isShowSmartWindow && this.curBp === 'lg') {
      this.updateConListPage();
    } else {
      this.updateSmartWindowContactDetail();
    }
  }

  updateSmartWindowContactDetail() {
    if (!this.isShowSmartWindow && (this.mainTabsIndex === this.mIndexPresenter.contactIndex)) {
      this.mIndexPresenter.emitDefaultSelectedContact();
    } else if (!this.isShowSmartWindow && (this.mainTabsIndex === this.mIndexPresenter.favoriteIndex)) {
      this.mFavoriteListPresenter.emitFavoriteDefaultSelectedContact();
    }
  }

  updateConListPage() {
    HiLog.w(TAG, 'updateConListPage  curBp == ' + this.curBp + '  ---  isShowSmartWindow ==' + this.isShowSmartWindow);
    // 检测手机形态变化
    if (this.curBp === '') {
      return;
    }

    if ((this.curBp === 'sm') && (this.activeCallId !== -1)) {
      this.activeCallId = -1;
    }

    if ((this.curBp === 'sm')) {
      if (this.isContactSearch && (this.mainTabsIndex === this.mIndexPresenter.contactIndex) &&
        !this.isShowSmartWindow) {
        this.pathInfos.clear(false);
        setTimeout(() => {
          let inputMethodController = inputMethod.getController();
          inputMethodController.showTextInput();
          focusControl.requestFocus('contactList_contacts_valueChange_search');
        }, 50)
        return;
      }

      // 直板机 移除默认页面
      let defaultPage = 'DialerPad';
      switch (this.bottomTabIndex) {
        case this.mIndexPresenter.callIndex:
          defaultPage = 'DialerPad';
          break;
        case this.mIndexPresenter.contactIndex:
          defaultPage = 'ContactDefaultPage';
          break;
        case this.mIndexPresenter.favoriteIndex:
          defaultPage = 'FavoriteDefaultPage';
          break;
        default:
          break;
      }
      let pathArr = this.pathInfos.getAllPathName();
      if (pathArr.length === 1 && pathArr[0] === defaultPage) {
        this.pathInfos.pop(false);
      } else {
        this.pathInfos.removeByName(defaultPage);
      }
    } else {
      // 非直板机 添加默认页面
      let navPathInfos: NavPathInfo[] = [];
      while (this.pathInfos.size() > 0) {
        navPathInfos.unshift(this.pathInfos.pop() as NavPathInfo);
      }
      HiLog.w(TAG, 'this.bottomTabIndex: ' + this.bottomTabIndex);
      if (navPathInfos.length > 0) {
        while (navPathInfos.length > 0) {
          this.pathInfos.pushDestination(navPathInfos.shift(), false);
        }
      } else {
        switch (this.bottomTabIndex) {
          case this.mIndexPresenter.callIndex:
            this.pathInfos.pushPathByName('DialerPad', '', false);
            this.isShowDial = (navPathInfos.length > 0);
            break;
          case this.mIndexPresenter.contactIndex:
            break;
          case this.mIndexPresenter.favoriteIndex:
            this.pathInfos?.pushPathByName('FavoriteDefaultPage', '', false);
            break;
          default:
            break;
        }
      }
      try {
        if ((this.curBp === 'lg') || (this.curBp === 'md' && !display.isFoldable())) {
          HiLog.w(TAG, 'updateSmartWindowContactDetail the current device is:' + display.isFoldable());
          this.updateSmartWindowContactDetail();
        }
      } catch {
        HiLog.e(TAG, 'The device is incorrectly determined.');
      }
    }

    if (EnvironmentProp.isPhone()) {
      HiLog.i(TAG, 'this is phone');
      if ((this.phoneStatusCurBp === 'sm' || this.phoneStatusCurBp === 'md') && this.curBp === 'lg') {
        setTimeout(() => {
          HiLog.i(TAG, 'sm or md -> lg');
          this.onTeleNumberChanged();
          this.phoneStatusCurBp = this.curBp;
        }, 100);

        if (AppStorage.get('defaultSettingApi') === undefined) {
          let context: Context = getContext(this) as Context;
          this.getDefDisplayDpi(context);
        } else {
          queryUserDpiValue();
          addUserDpiValueListener();
        }
      } else if (this.phoneStatusCurBp === 'lg' && (this.curBp === 'sm' || this.curBp === 'md')) {
        setTimeout(() => {
          HiLog.i(TAG, 'lg -> sm or md');
          this.onTeleNumberChanged();
          this.phoneStatusCurBp = this.curBp;
        }, 100);

        removeUserDpiValueListener();
      }
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 100 })
    PageTransitionExit({ duration: 100 })
  }

  onForegroundChange() {
    // v小折叠 拨号盘未输入号码时，拨号盘默认收起
    if (this.isVerde && StringUtil.isEmpty(this.telNumberWithSpace)) {
      this.showDialBtn = false;
    }
    this.hideIndexTitleTabBar = false;

    if (this.foldedAndContinuedTaskId > 0) {
      HiLog.w(TAG, `onForegroundChange isMainAbilityForeground: ${this.isMainAbilityForeground
      }, clear foldedAndContinued, foldedAndContinuedTaskId: ${this.foldedAndContinuedTaskId
      }, foldedAndContinuedType: ${this.foldedAndContinuedType
      }, foldedAndContinuedToastId: ${this.foldedAndContinuedToastId}`);
      clearTimeout(this.foldedAndContinuedTaskId);
      this.foldedAndContinuedTaskId = -1;
      this.foldedAndContinuedType = FoldedAndContinuedType.NULL;
      if (this.foldedAndContinuedToastId > 0) {
        prompt.closeToast(this.foldedAndContinuedToastId);
        this.foldedAndContinuedToastId = -1;
      }
    }
  }

  async updateCallLogNotesStatus(dataShareHelper: dataShare.DataShareHelper, beginTime: string) {
    HiLog.i(TAG, `update calllog notes_status begin`)
    //查询条件dataPredicates
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('begin_time', beginTime);
    //更新字段
    let updateValues: Record<string, string | number> = {
      'notes_status': this.notesStatus,
      'notes_status_updater': 'com.ohos.calllogability',
      'notes_status_update_time': Math.floor(Date.now() / 1000)
    };
    try {
      await dataShareHelper.update(CALL_LOG_URI, conditionArgs, updateValues);
      HiLog.i(TAG, `update calllog notes_status success`)
    } catch (err) {
      HiLog.e(TAG, `update calllog notes_status err:${err?.code}`)
    }
  }

  async queryCallLogData(context: common.Context) {
    HiLog.i(TAG, `query notesId update calllog`)
    //查询条件dataPredicates
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, CALL_LOG_DATA)
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.notEqualTo('notes_status', '-1');
    let resultColumns = ['begin_time']
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      resultSet = await dataShareHelper.query(CALL_LOG_URI, conditionArgs, resultColumns);
      if (resultSet.goToFirstRow()) {
        do {
          let beginTime = resultSet.getString(resultSet.getColumnIndex('begin_time'));
          this.updateCallLogNotesStatus(dataShareHelper, beginTime)
        } while (resultSet.goToNextRow());
      } else {
        HiLog.i(TAG, 'query notesId data not exist')
      }
    } catch (err) {
      HiLog.e(TAG, `query notesId err:${err?.code}`)
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  // 备忘录不存在时更新数据库状态
  async updateCallLogData() {
    let context = getContext(this) as common.UIAbilityContext;
    HiLog.i(TAG, `query calllog begin ${this.isNotePadAppEnabledFlag}`)
    if (!this.isNotePadAppEnabledFlag) {
      await this.queryCallLogData(context);
      HiLog.i(TAG, 'query calllog update finish')
    }
  }

  onPageShow() {
    if (!this.isAddedEventListener) {
      HiLog.w(TAG, 'onPageShow addEventListener');
      this.addEventListener();
      this.isAddedEventListener = true;
    } else {
      HiLog.i(TAG, `onPageShow has already addEventListener`)
    }
    // v小折叠 拨号盘未输入号码时，拨号盘默认收起
    if (this.isVerde && StringUtil.isEmpty(this.telNumberWithSpace)) {
      this.showDialBtn = false;
    }
    this.mIndexPresenter.onPageShow();
    this.mIndexPresenter.setDarkThemeColor();
    if (this.isInHiCar) {
      HiLog.i(TAG, `onPageShow  this.hiCarTabIndex == ${this.hiCarTabIndex}`);
      HiCarCallRecordPresenter.getInstance().setPageShow(this.hiCarTabIndex == this.mIndexPresenter.callIndex, true);
      if (HiCarCallRecordPresenter.getInstance().getAllCallsError) {
        HiLog.i(TAG, 'hicar getAllCalls error, requestItem again!');
        HiCarCallRecordPresenter.getInstance().getAllCallsError = false;
        HiCarCallRecordPresenter.getInstance().requestItem();
      }
    } else {
      if (this.maintenanceMode && (this.bottomTabIndex !== this.mIndexPresenter.callIndex)) {
        if (!this.isShowMaintenanceModeDialog) {
          this.maintenanceModeDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.maintenanceModeDialogController);
          this.isShowMaintenanceModeDialog = true;
        }
        return;
      }

      HiLog.i(TAG, `onPageShow  this.bottomTabIndex == ${this.bottomTabIndex}`);
      this.isShowFraudBanners();
      this.updateShowNewCallTip();
      this.mCallRecordPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.callIndex, true);
      this.mContactListPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.contactIndex);
      this.mFavoriteListPresenter.setPageShow(this.bottomTabIndex == this.mIndexPresenter.favoriteIndex);
      if (this.mCallRecordPresenter.getAllCallsError) {
        HiLog.w(TAG, 'phone getAllCalls error, requestItem again!');
        this.mCallRecordPresenter.getAllCallsError = false;
        this.mCallRecordPresenter.requestItem('getAllCallsError');
      }
    }
    // 搜索联系人
    // this.mContactListPresenter.getSearchContactResult(this.mContactListPresenter.inputKeyword);
    this.mContactListPresenter.getSearchContactResultFromDb(this.mContactListPresenter.inputKeyword);
    this.onTeleNumberChanged();
    if (this.mContactListPresenter.getAllContactsError) {
      HiLog.w(TAG, 'getAllContacts error, requestItem again!');
      this.mContactListPresenter.getAllContactsError = false;
      this.mContactListPresenter.requestItem();
    }
    this.upDateIsContactSearch();
    isVoiceAppEnabled().then((value) => {
      AppStorage.setOrCreate<boolean>('VoiceAppEnabled', value);
    })
    if (!(AppStorage.get('callLogDataChange') ?? false)) {
      HiLog.w(TAG, 'callLogDataChange null, register again!');
      CallLogRepository.getInstance().registerCallLogDataChangeRetry()
    }
    emitter.emit({ eventId: EmitterConstant.CONTACT_LIST_CACHE_UPDATE });
    this.updateCallLogData();
  }

  isShowFraudBanners() {
    if (this.localAccountId && call.hasVoiceCapability()) {
      CallLogRepository.getInstance().setSwitchState(
        async (value: number) => {
          this.smartIdentitySwitch = value.toString();
          if (this.smartIdentitySwitch === '0') {
            this.showFraudBanners = true;
          } else if (this.smartIdentitySwitch === '1') {
            this.showFraudBanners = false;
          }
        });
    }
  }

  async updateShowNewCallTip() {
    try {
      const next = await sharedPreferencesUtils.getFromPreferences('nextShowNewCallTip', 0) as number;
      if (Date.now() < next) {
        HiLog.i(TAG, `notified, nextShowNewCallTip[${next}]`);
        this.showNewCallTip = false;
        return;
      }
      const numbers: string[] = [];
      const simCount = sim.getMaxSimCount();
      let isSupportNewCall: boolean = false;
      for (let i = 0; i < simCount; ++i) {
        try {
          numbers.push(encodeURIComponent(await sim.getShowNumber(i)));
          isSupportNewCall = isSupportNewCall ||
            (await NewCallUtils.checkNewCallSwitchConfigsBySlotId(i, this.getUIContext().getHostContext()!));
        } catch (err) {
          HiLog.e(TAG, `getShowNumber failed, slot[${i}], code[${err.code}], message[${err.message}]`);
        }
      }
      if (numbers.length === 0 || isSupportNewCall === false) {
        HiLog.i(TAG, 'no available sim card or not support new call');
        this.showNewCallTip = false;
        return;
      }
      const uri = 'datashare:///com.ohos.newcallingdcsdk';
      const helper = await dataShare.createDataShareHelper(this.getUIContext().getHostContext()!, uri);
      let result: DataShareResultSet | undefined = undefined;
      try {
        result = await helper.query(`${uri}?number=${numbers.join('_')}`,
          new dataSharePredicates.DataSharePredicates(), []);
        let flag = false;
        while (result.goToNextRow()) {
          if (result.getLong(1) === 0) {
            flag = true;
            break;
          }
        }
        this.showNewCallTip = flag;
      } finally {
        helper.close();
        ObjectUtil.closeResultSet(result);
      }
    } catch (err) {
      HiLog.e(TAG, `updateShowNewCallTip failed, code[${err.code}], message[${err.message}]`);
    }
  }

  @Builder
  PopupBuilder() {
    UIExtensionComponent(
      {
        bundleName: 'com.ohos.spamshield',
        abilityName: 'LiveDetectionSettingsAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'isSheetPage': true,
          'topAreaHeightExt': 8
        }
      })
      .id('spam_shield_extension_id')
      .onRemoteReady(() => {
        HiLog.i(TAG, 'onRemoteReady enter');
      })
      .onTerminated((data) => {
        HiLog.i(TAG, `onResult : ${data?.code}`);
        this.isShowSwitchPage = false;
      })
      .onError(() => {
        HiLog.e(TAG, 'spamshield onError');
        this.isShowSwitchPage = false;
      })
      .onReceive((data) => {
        HiLog.i(TAG, `onReceive : ${data}`);
        if (data?.action === 'exit' || data?.isClose) {
          this.isShowSwitchPage = false;
        }
      })
      .gesture(
        PanGesture().onActionStart(() => {
          // 阻止事件透传
          HiLog.i(TAG, `PanGesture onActionStart`);
        })
      )
      .width('100%')
      .height(`calc(100% - 48vp)`)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor('#00000000')
      .zIndex(3)
  }

  upDateIsContactSearch() {
    HiLog.i(TAG,
      `isPortraitDisplay value is: ${this.isPortraitDisplay},
       isPortraitDisplayCarMachine value is: ${this.isPortraitDisplayCarMachine},
       isContactSearch value is: ${this.isContactSearch}
       mainTabsIndex value is: ${this.mainTabsIndex}`)
    if (this.isContactSearch && (this.mainTabsIndex !== this.mIndexPresenter.contactIndex)) {
      this.isContactSearch = false;
    }
    if ((this.mainTabsIndex === this.mIndexPresenter.callIndex) && this.isShowMaintenanceModeDialog === true) {
      this.maintenanceModeDialogController?.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
      this.isShowMaintenanceModeDialog = false;
    }
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageCover  this.bottomTabIndex == ' + this.bottomTabIndex);
    this.mContactListPresenter.setPageShow(false);
    if (this.isInHiCar) {
      HiCarCallRecordPresenter.getInstance().setPageShow(false);
    } else {
      this.mCallRecordPresenter.setPageShow(false);
    }
    this.mFavoriteListPresenter.setPageShow(false);
    // 判断通话弹窗是否开启，如果开启隐藏页面的时候关闭
    if (this.isNoRingingDialog) {
      PhoneNumber.isNoRingingDialogController?.close();
      this.isNoRingingDialog = false;
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    }
    if (this.isRingingDialog) {
      PhoneNumber.isRingingDialogController?.close();
      this.isRingingDialog = false;
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    }
    // 关闭铃声
    emitter.emit({
      eventId: EmitterConstant.EVENT_LIST_RING_TONE_PLAY,
      priority: emitter.EventPriority.HIGH
    })
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.phoneStatusCurBp = this.curBp;
    // 监听屏幕是否横屏显示
    let spaceLR: Resource = $r('sys.float.padding_level8');
    this.listener.on('change', (mediaQueryResult) => {
      if (mediaQueryResult.matches) {
        this.isPortraitDisplay = false;
      } else {
        // 是竖屏情况下
        this.isPortraitDisplay = true;
      }
      if (!this.isPortraitDisplay && this.curBp === 'lg') {
        spaceLR = $r('sys.float.padding_level12');
      } else {
        spaceLR = $r('sys.float.padding_level8');
      }
      AppStorage.setOrCreate('spaceLR', spaceLR);
      AppStorage.setOrCreate('isTabletLandscape', !this.isPortraitDisplay && this.curBp === 'lg');

      if (this.isPortraitDisplay) {
        let windowWidthPX: number = AppStorage.get('windowWidthPX') as number;
        let windowHeightPX: number = AppStorage.get('windowHeightPx') as number;
        this.isPortraitDisplayCarMachine = (windowWidthPX > windowHeightPX);
      } else {
        this.isPortraitDisplayCarMachine = false;
      }
    })
    this.mPermissionManager.initPermissions();
    // 注册回调方法; 动态加载方式，加载页面时，需要首先await import('xxx')方式，引入页面
    DynamicLoader.getInstance().register(async (str: string): Promise<boolean> => {
      return await this.dynamicLoadCallBack(str);
    });

    this.mIndexPresenter.isSysColor();
    this.mIndexPresenter.aboutToAppear();
    this.getInfo();
    this.onIndexChanged();
    this.mDialerPresenter.pathInfos = this.pathInfos;
    this.mContactListPresenter.pathInfos = this.pathInfos;
    this.mCallRecordPresenter.pathInfos = this.pathInfos;
    this.mFavoriteListPresenter.pathInfos = this.pathInfos;
    this.mIndexPresenter.pathInfos = this.pathInfos;
    this.teleNumberChange();
    this.mIndexPresenter.initAirPlaneMode();
    this.initHarassmentPop();
    this.initPhoneNumberAlertDialog();
    this.mIndexPresenter.targetPageChange();
    if (!EnvironmentProp.isDeviceTypeTablet()) {
      this.updateConListPage();
    }
    this.onBottomTabIndexChange();
    if (EnvironmentProp.isTabletOrPC()) {
      this.mIndexPresenter.initCallPhoneSharingMode();
      this.mIndexPresenter.initDistributedModemState();
      this.mIndexPresenter.initCallSMSSharingMode();
    } else {
      this.mIndexPresenter.isOnCallSharing();
    }
    // 注册关于页面退出监听
    emitter.on({
      eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID,
    }, () => {
      this.isShowContactsSettings = false;
      this.isShowCallSetting = false;
    })
    // 延迟600ms执行，提前初始化联系人列表第一页数据，使切换联系人页面，满足加载时延
    reapplyTimeoutId = setTimeout(() => {
      HiLog.i(TAG, 'setTimeout invoke startPreInit');
      this.mContactListPresenter.startPreInit();
    }, 600);

    let context: Context = getContext(this) as Context;
    setTimeout(() => {
      if (this.curBp === 'lg') {
        this.getDefDisplayDpi(context);
      }
    }, 50)
    if (this.isVerde) {
      // v小折叠 拨号盘默认收起, btnShow 需要初始化为 false
      this.mDialerPresenter.btnShow = false
    }
    this.isFirstAboutToAppear = false;
    // this.bottomTabsController.bindScroller(1, this.contactListScroller);
    // this.bottomTabsController.bindScroller(2, this.favoritePageScroller);
  }

  getDefDisplayDpi(context: Context) {
    if (context === undefined) {
      HiLog.e(TAG, 'getDefDisplayDpi failed to get context');
      return;
    }
    try {
      settings.getValue(context, 'default_display_dpi')
        .then((value: string) => {
          HiLog.i(TAG, 'default_display_dpi value is ' + value);
          AppStorage.setOrCreate('defaultSettingApi', value);
          queryUserDpiValue();
          addUserDpiValueListener();
        })
    } catch (err) {
      HiLog.e(TAG, 'getDefDisplayDpi failed err' + err.code);
    }
  }

  aboutToDisappear() {
    if (this.isPC) {
      return;
    }
    HiLog.i(TAG, 'aboutToDisappear');
    emitter.off(this.exportEmitterId);
    emitter.off(EmitterConstant.GET_ALL_CALLS_EMITTER_ID);
    emitter.off(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
    this.exportDialogController = null;
    this.exportContactsProgressDialogController = null;
    this.cancelExportContactsDialogController = null;
    removeAirPlaneModeListener();
    TaskUtil.cancelAll();
    this.mContactListPresenter.unSubscriber();
    // 注销关于页面退出监听
    emitter.off(EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID);
    this.listener?.off('change');
    if (reapplyTimeoutId > 0) {
      clearTimeout(reapplyTimeoutId);
      reapplyTimeoutId = -1;
      HiLog.i(TAG, 'reapply Timeout clear');
    }
    if (deleteCalender > 0) {
      clearTimeout(deleteCalender);
      deleteCalender = -1;
      HiLog.i(TAG, 'deleteCalender Timeout clear');
    }
    removeSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING);
    removeSettingModeListener(CallSharingClass.DISTRIBUTED_MODEM_STATE);
    removeSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING);
    removeUserDpiValueListener();
  }

  initHarassmentPop() {
    // no call capability、privacy Space not show
    if (!call.hasVoiceCapability() || !this.localAccountId) {
      HiLog.w(TAG, 'no message is displayed when the private space does not have the call capability.');
      return;
    }
    sharedPreferencesUtils.getFromPreferences('isShowHarassmentPop', true).then(value => {
      HiLog.w(TAG, 'getFromPreferences isShowHarassmentPop: ' + value +
        ' current isShowHarassmentPop: ' + this.isShowHarassmentPop)
      if (Boolean(value)) {
        this.isShowHarassmentPop = Boolean(value);
      }
    });
  }

  addEventListener() {
    let exportEvent: emitter.InnerEvent = {
      eventId: this.exportEmitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(exportEvent, (data: emitter.EventData) => {
      HiLog.i(TAG, 'emitter receive');
      if (data.data === undefined || data.data!['percent'] === undefined) {
        if (!this.isExportDiaShow && !this.maintenanceMode) {
          this.isExportDiaShow = true;
          if (this.exportDialogController) {
            HiLog.i(TAG, 'exportDialogController open');
            // sim 卡导入弹窗
            this.exportDialogController.open();
            DialogControllerManager.getInstance().addDialogController(this.exportDialogController);
          }
        }
      } else {
        this.percent = data.data!['percent'];
        if (!this.isProgressDiaShow) {
          this.isProgressDiaShow = true;
          if (this.exportContactsProgressDialogController) {
            this.exportContactsProgressDialogController.open();
            DialogControllerManager.getInstance().addDialogController(this.exportContactsProgressDialogController);
          }
        }
        if (this.percent === 100 || data.data!['cancelImport']) {
          this.isProgressDiaShow = false;
          if (this.exportContactsProgressDialogController) {
            this.exportContactsProgressDialogController.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
          if (this.isCancelExportContactsDiaShow) {
            if (this.cancelExportContactsDialogController) {
              this.cancelExportContactsDialogController.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
            }
            this.isCancelExportContactsDiaShow = false;
          }
        }
      }
    })
    emitter.on(EmitterConstant.GET_ALL_CALLS_EMITTER_ID, () => {
      HiLog.i(TAG, 'emitter on, getAllCalls error!');
      if (!this.isInHiCar) {
        this.mCallRecordPresenter.getAllCallsError = true;
      } else {
        HiCarCallRecordPresenter.getInstance().getAllCallsError = true;
      }
    });
    emitter.on(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID, () => {
      HiLog.i(TAG, 'emitter on, getAllContacts error!');
      this.mContactListPresenter.getAllContactsError = true;
    });
    this.getSimCardState();
  }

  onBackPress() {
    HiLog.w(TAG, 'onBackPress');
    if (this.isContactSearch) {
      this.mIndexPresenter.onBackPressIsContactSearch();
      return true;
    }
    if ((this.tele_number !== '') && (this.mainTabsIndex === 0)) {
      this.mDialerPresenter.resetTelNumber();
      return true;
    }
    if (SystemModeController.getInstance().getCurrentMode() === ModeType.PENG_LAI_MODE) {
      // 蓬莱模式下主页的后台管控定时器，当在应用主页屏幕侧滑退出应用时，500ms后销毁应用的UIAbility
      let timerId = setTimeout(() => {
        AppStorage.setOrCreate(TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND, null);
        terminateUIAbilitySelf(getContext() as common.UIAbilityContext);
        HiLog.i(TAG, 'contactIndex onBackPress: terminateUIAbilitySelf in penglai');
      }, 500);
      AppStorage.setOrCreate(TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND, timerId);
    }
    return false;
  }

  getInfo() {
    device.getInfo({
      success: (data) => {
        AppStorage.SetOrCreate('windowHeight', data.windowHeight / data.screenDensity)
      },
      fail: (data: Record<string, number>, code) => {
        HiLog.i(TAG, 'Failed to obtain device information. Error code:' + code + '; Error information: ' + data);
      },
    });
  }

  getTabBarHeight(): ResourceStr | number {
    if (this.isVerde && this.showDialBtn && this.bottomTabIndex === this.mIndexPresenter.callIndex) {
      return 0;
    } else if (DisplaySplitUtil.isHorizonSplit()) {
      return $r('app.float.id_item_height_mid');
    } else if (this.curBp === 'lg' && !this.isPortraitDisplay) {
      return '100%';
    } else if (this.isPortraitDisplay && this.isPortraitDisplayCarMachine) {
      return '100%';
    } else if (this.isContactSearch) {
      return 0;
    } else {
      return $r('app.float.id_item_height_mid');
    }
  }

  @Builder
  ButtonBuilder(symbol: Resource, name: Resource, index: number) {
    Button({ type: ButtonType.Normal }) {
      Row() {
        SymbolGlyph(symbol)
          .fontColor(this.bottomTabIndex === index ?
            [$r('app.color.skin_font_emphasize'), $r('app.color.skin_font_emphasize')] :
            [$r('sys.color.ohos_id_color_bottom_tab_icon_auxcolor_off01'),
              $r('sys.color.ohos_id_color_bottom_tab_icon_auxcolor_off02')])
          .fontSize(24)
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)

        Text(name)
          .fontColor($r('app.color.skin_font_primary'))
          .fontSize('16vp')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .margin({ start: LengthMetrics.vp(8) })
      }
      .width('100%')
      .height(40)
      .padding({ start: LengthMetrics.vp(8) })
    }
    .margin({
       bottom: $r('sys.float.padding_level1')
    })
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor(this.bottomTabIndex === index ? $r('app.color.color_select_list_bg') : Color.Transparent)
    .focusOnTouch(true)
    .onClick(() => {
      this.bottomTabIndex = index;
      this.onTabIndexChange(index);
    })

  }

  private onTabIndexChange(item: number): void {
    setTimeout(() => {
      AppStorage.setOrCreate('mainTabsIndex', item);
      // tab切换打点
      this.tabSwitchParams.FLAG = item;
      DotUtil.getInstance().contactDot(this.tabSwitchParams, CONTACTS_TAB_SWITCH_EVENT)
      if (item == this.mIndexPresenter.callIndex) {
        this.selectContactId = '';
        this.isContactSearch = false;
        this.mCallRecordPresenter.toDefaultPage();
        this.mContactListPresenter.setPageShow(false);
        this.mCallRecordPresenter.setPageShow(true);
        this.mFavoriteListPresenter.setPageShow(false);
      } else if (item == this.mIndexPresenter.contactIndex) {
        this.isShowDial = false;
        this.selectContactId = '';
        this.mContactListPresenter.toDefaultPage();
        this.maintenanceModeTabClick();
        this.mCallRecordPresenter.setPageShow(false);
        this.mContactListPresenter.setPageShow(true);
        this.mFavoriteListPresenter.setPageShow(false);
        this.mIndexPresenter.emitDefaultSelectedContact();
      } else if (item == this.mIndexPresenter.favoriteIndex) {
        this.isShowDial = false;
        this.selectContactId = '';
        this.isContactSearch = false;
        this.mFavoriteListPresenter.toDefaultPage();
        this.maintenanceModeTabClick();
        this.mCallRecordPresenter.setPageShow(false);
        this.mContactListPresenter.setPageShow(false);
        this.mFavoriteListPresenter.setPageShow(true);
        this.mFavoriteListPresenter.emitFavoriteDefaultSelectedContact();
      }
    }, 10);
  }

  /**
   * 专用于PC联系人应用最小化窗口下导航栏打开时的蒙层
   */
  @Builder
  OverlayNode() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.mask_fourth'))
    .opacity(this.maskOpacity)
    .onClick(() => {
      // 点击该遮罩，左侧分栏隐藏
      if (this.isNeedMask && this.isPC) {
        animateTo({
          curve: curves.interpolatingSpring(0, 1, 300, 35)
        }, () => {
          this.showSideBar = false;
          this.maskOpacity = 0;
        });
        this.isNeedMask = false;
      }
    })
  }

  build() {
    Stack(){
      if (this.isInHiCar) {
        HiCarIndex({ hiCarTabIndex: this.hiCarTabIndex, bottomTabIndex: this.bottomTabIndex });
      } else if (this.isPC) {
        SideBarContainer(this.isPcMinWindowWidth ? SideBarContainerType.Overlay : SideBarContainerType.Embed) {
          // 左边导航区
          Column() {
            Row() {
              Image($r('app.media.ic_contact_icon'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
                .borderRadius($r('sys.float.padding_level3'))

              Text($r('app.string.contact'))
                .fontSize('16vp')
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Medium)
                .margin({ start: LengthMetrics.vp(8) })
              if (this.showSideBar) {
                SideBarButton()
                  .margin({ start: LengthMetrics.vp(24) })
              }
            }
            .width('100%')
            .height(56)
            .padding({ start: LengthMetrics.vp(8) })
            .focusable(false)

            if (this.isDistributedCallPhoneSharing && this.isDistributedModemState &&
              this.isDistributedCallSourcePhone) {
              this.ButtonBuilder($r('sys.symbol.phone_fill'), $r('app.string.dialer'), 0)
              this.ButtonBuilder($r('sys.symbol.person_2_fill'), $r('app.string.contact'), 1)
              this.ButtonBuilder($r('sys.symbol.star_fill'), $r('app.string.favorite'), 2)
            } else {
              this.ButtonBuilder($r('sys.symbol.person_2_fill'), $r('app.string.contact'), 0)
              this.ButtonBuilder($r('sys.symbol.star_fill'), $r('app.string.favorite'), 1)
            }
          }
          .padding({
            start: LengthMetrics.vp(16),
            end: LengthMetrics.vp(16)
          })
          .backgroundColor($r('app.color.skin_ohos_id_color_panel_bg'))

          // 右边内容区
          Navigation(this.pathInfos) {
            if (this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
            this.isDistributedCallSourcePhone && this.bottomTabIndex === 0) {
              DialerTablet()
            }

            if ((this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
            this.isDistributedCallSourcePhone && this.bottomTabIndex === 1) ||
              (!(this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
              this.isDistributedCallSourcePhone) && this.bottomTabIndex === 0)) {
              contactPage()
            }

            if ((this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
            this.isDistributedCallSourcePhone && this.bottomTabIndex === 2) ||
              (!(this.isDistributedModemState && this.isDistributedCallPhoneSharing &&
              this.isDistributedCallSourcePhone) && this.bottomTabIndex === 1)) {
              favoritePage()
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') : undefined)
          .zIndex(1)
          .navBarWidth('40%')
          .hideTitleBar(true)
          .navDestination(this.myRouter)
          .bindSheet(this.isShowAccountants, this.ShowAccountantsView(), {
            title: NavDestinationHeaderView({
              isThemeActive: this.accountantTitleClass.isThemeActive,
              isOpenAccessibility: this.accountantTitleClass.isOpenAccessibility,
              fontSizeScale: this.accountantTitleClass.fontSizeScale,
              pageTitle: this.accountantTitleClass.pageTitle,
              isSave: this.accountantTitleClass.isSave,
              cancelOnClick: this.accountantTitleClass.cancelOnClick,
              savelOnClick: this.accountantTitleClass.savelOnClick,
            }),
            dragBar: true,
            showClose: false,
            preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
            shouldDismiss: (sheetDismiss: SheetDismiss) => {
              emitter.emit({
                eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EVENT_ID_HIDE,
                priority: emitter.EventPriority.HIGH
              })
            }
          })
          // 当导航栏的可见性更改时触发回调
          .onNavBarStateChange((value: boolean) => {
            HiLog.i(TAG,
              'onNavBarStateChange:' + value + '  this.curBp:' + this.curBp + ' this.bottomTabIndex: ' +
              this.bottomTabIndex);
            if (this.curBp === 'sm') {
              if (value) {
                this.onPageShow();
              } else {
                this.onPageHide();
              }
            }
          })
          .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
            hiTraceMeter.startTrace('navDestinationAnimation', 101);
            if (from.mode == NavDestinationMode.DIALOG || to.mode == NavDestinationMode.DIALOG) {
              hiTraceMeter.finishTrace('navDestinationAnimation', 101);
              // 非页面push的情况在此 return
              return undefined;
            }
            let fromAnimation: TitleAnimation | undefined = CustomTransition.getInstance().getAnimateParam(from.index);
            let toAnimation: TitleAnimation | undefined = CustomTransition.getInstance().getAnimateParam(to.index);
            if (fromAnimation == undefined && toAnimation == undefined) {
              hiTraceMeter.finishTrace('navDestinationAnimation', 101);
              // 没有使用自定义导航的页面 在此会 return
              return undefined;
            }
            let isPop: boolean = NavigationOperation.POP == operation;

            //  from页面的动画 （pop时）
            if (fromAnimation != undefined) {
              if (fromAnimation?.transitionAnimation?.start) {
                fromAnimation.transitionAnimation.start(isPop, true);
              }
              animateTo({
                duration: 400, curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0), onFinish: () => {
                  if (fromAnimation?.transitionAnimation?.onFinish) {
                    fromAnimation.transitionAnimation.onFinish(isPop, true);
                  }
                }
              }, () => {
                if (fromAnimation?.transitionAnimation?.finish) {
                  fromAnimation.transitionAnimation.finish(isPop, true);
                }
              })

              animateTo({
                duration: 1050,
                delay: 17,
                curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0),
                onFinish: () => {
                }
              }, () => {
                if (fromAnimation?.titleAnimation?.finish) {
                  fromAnimation.titleAnimation.finish(isPop, true);
                }
              })

              if (fromAnimation?.opacityAnimation.start) {
                fromAnimation.opacityAnimation.start(isPop, true);
              }
              animateTo({
                duration: 67, curve: Curve.Sharp, onFinish: () => {
                }
              }, () => {
                if (fromAnimation?.opacityAnimation.finish) {
                  fromAnimation.opacityAnimation.finish(isPop, true);
                }
              })
            }

            //  to页面的动画 （push时）
            if (toAnimation != undefined) {
              if (toAnimation?.transitionAnimation?.start) {
                toAnimation.transitionAnimation.start(isPop, false);
              }
              animateTo({
                duration: 400, curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0), onFinish: () => {
                  if (toAnimation?.transitionAnimation?.onFinish) {
                    toAnimation.transitionAnimation.onFinish(isPop, false);
                  }
                }
              }, () => {
                if (toAnimation?.transitionAnimation?.finish) {
                  toAnimation.transitionAnimation.finish(isPop, false);
                }
              })
              if (toAnimation?.opacityAnimation.start) {
                toAnimation.opacityAnimation.start(isPop, false);
              }
              animateTo({
                duration: 200,
                delay: 150,
                curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0),
                onFinish: () => {
                }
              }, () => {
                if (toAnimation?.opacityAnimation.finish) {
                  toAnimation?.opacityAnimation.finish(isPop, false);
                }
              })
            }
            hiTraceMeter.finishTrace('navDestinationAnimation', 101);
            return undefined;
          })
          // PC上最小窗口拉出侧边栏时右侧页面需要遮罩
          .overlay(this.isPC && this.isNeedMask ? this.OverlayNode() : undefined,
            { align: Alignment.Center })
        }
        .divider({ strokeWidth: 0 })
        .showControlButton(false)
        .minSideBarWidth(180)
        .maxSideBarWidth(180)
        .sideBarWidth(180)
        .showSideBar(this.showSideBar)
      } else {
        Navigation(this.pathInfos) {
          if (this.mPermissionManager.isAllPermissionsGranted()) {
            Stack({ alignContent: Alignment.Bottom }) {
              Column() {
                Tabs({ barPosition: DisplaySplitUtil.isHorizonSplit() ? BarPosition.End : this.curBp === 'lg' &&
                  !this.isPortraitDisplay ? BarPosition.Start :
                  (this.isPortraitDisplay && this.isPortraitDisplayCarMachine ? BarPosition.Start : BarPosition.End),
                  index: this.bottomTabIndex,
                  controller: this.bottomTabsController
                }) {
                  // 通话tab
                  if (call.hasVoiceCapability() ||
                    (this.isDistributedCallPhoneSharing && this.isDistributedModemState &&
                    this.isDistributedCallSourcePhone)) {
                    TabContent() {
                      if (this.curBp === 'sm' || this.curBp === 'md') {
                        callPage()    //双屏调用入口
                      } else if (this.curBp === 'lg') {
                        DialerTablet()
                      }
                    }
                    .onAppear(() => {
                      HiLog.w(TAG, `Call and Dialer appear...`);
                    })
                    .id(this.TABCONTACTCALL)
                    .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') : undefined)
                    .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
                    .backgroundImageSize(this.isThemeActive ? { width: '100%', height: '100%' } : undefined)
                    .align(Alignment.TopStart)
                    .tabBar(new BottomTabBarStyle(this.isThemeActive ? {
                      normal: new SymbolGlyphModifier($r('sys.symbol.phone_fill')).fontColor([$r('app.color.skin_icon_fourth')]),
                      selected: new SymbolGlyphModifier($r('sys.symbol.phone_fill')).fontColor([$r('app.color.skin_font_emphasize')])
                    } :
                      { normal: new SymbolGlyphModifier($r('sys.symbol.phone_fill')) },
                      $r('app.string.dialer'),
                    )
                      .labelStyle(this.isThemeActive ? {
                        selectedColor: $r('app.color.skin_font_emphasize'),
                        unselectedColor: $r('app.color.skin_ohos_id_color_text_secondary')
                      } : undefined)
                    )
                  }
                  // 联系人tab
                  TabContent() {
                    contactPage({
                      scroller: this.contactListScroller
                    })
                  }
                  .id(this.TABCONTACTLIST)
                  .align(Alignment.TopStart)
                  .tabBar(new BottomTabBarStyle(this.isThemeActive ? {
                    normal: new SymbolGlyphModifier($r('sys.symbol.person_2_fill')).fontColor([$r('app.color.skin_icon_fourth')]),
                    selected: new SymbolGlyphModifier($r('sys.symbol.person_2_fill')).fontColor([$r('app.color.skin_font_emphasize')])
                  } : { normal: new SymbolGlyphModifier($r('sys.symbol.person_2_fill')) },
                    $r('app.string.contact')
                  )
                    .labelStyle(this.isThemeActive ? {
                      selectedColor: $r('app.color.skin_font_emphasize'),
                      unselectedColor: $r('app.color.skin_ohos_id_color_text_secondary')
                    } : undefined)
                  )


                  // 收藏tab
                  TabContent() {
                    favoritePage({
                      listScroller: this.favoritePageScroller
                    })
                  }
                  .id(this.TABCONTACTFAVORITE)
                  .align(Alignment.TopStart)
                  .tabBar(new BottomTabBarStyle(this.isThemeActive ? {
                    normal: new SymbolGlyphModifier($r('sys.symbol.star_fill')).fontColor([$r('app.color.skin_icon_fourth')]),
                    selected: new SymbolGlyphModifier($r('sys.symbol.star_fill')).fontColor([$r('app.color.skin_font_emphasize')])
                  } :
                    { normal: new SymbolGlyphModifier($r('sys.symbol.star_fill')) },
                    $r('app.string.favorite')
                  )
                    .labelStyle(this.isThemeActive ? {
                      selectedColor: $r('app.color.skin_font_emphasize'),
                      unselectedColor: $r('app.color.skin_ohos_id_color_text_secondary')
                    } : undefined)
                  )
                }
                .barOverlap(DisplaySplitUtil.isHorizonSplit() ? true : this.curBp === 'lg' &&
                  !this.isPortraitDisplay ? false :
                  (this.isPortraitDisplay && this.isPortraitDisplayCarMachine ? false : true))
                .barBackgroundBlurStyle(this.showDialBtn && this.bottomTabIndex === 0 ? BlurStyle.NONE :
                  BlurStyle.Thick)
                .height(this.isVerde ? this.tabsHeight : 'auto')
                .width('100%')
                .vertical(DisplaySplitUtil.isHorizonSplit() ? false :
                  (this.curBp === 'lg' && !this.isPortraitDisplay) ||
                    (this.isPortraitDisplay && this.isPortraitDisplayCarMachine))
                .barMode(BarMode.Fixed)
                .barWidth(DisplaySplitUtil.isHorizonSplit() ? '100%' : this.curBp === 'lg' && !this.isPortraitDisplay ?
                  '96vp' : (this.isPortraitDisplay && this.isPortraitDisplayCarMachine ? '96vp' : '100%'))
                .barHeight(this.getTabBarHeight())
                .scrollable(false)
                .animationDuration(0)
                // 拨号盘出现时底部无分割线、无模糊效果
                // .divider({
                //   mode: this.showDialBtn && this.bottomTabIndex === 0 ? DividerMode.NONE : DividerMode.FOLLOW_SCROLL
                // })
                .barBackgroundColor(this.showDialBtn && this.bottomTabIndex === 0 ?
                  $r('app.color.skin_comp_background_primary') : Color.Transparent)
                .backgroundColor($r('app.color.skin_comp_background_primary'))
                .onTabBarClick((item: number) => {
                  // 这里的如果有耗时操作，会影响页面切换响应时延
                  // 切换tab
                  HiLog.w(TAG, 'index onTabBarClick: ' + item);
                  setTimeout(() => {
                    AppStorage.SetOrCreate('mainTabsIndex', item);
                    // tab切换打点
                    this.tabSwitchParams.FLAG = item;
                    DotUtil.getInstance().contactDot(this.tabSwitchParams, CONTACTS_TAB_SWITCH_EVENT)
                    if (item == this.mIndexPresenter.callIndex) {
                      this.selectContactId = '';
                      this.isContactSearch = false;
                      this.mCallRecordPresenter.toDefaultPage();
                      this.mContactListPresenter.setPageShow(false);
                      this.mCallRecordPresenter.setPageShow(true);
                      this.mFavoriteListPresenter.setPageShow(false);
                      this.resetSystemBarProperties();
                    } else if (item == this.mIndexPresenter.contactIndex) {
                      this.activeCallId = -1;
                      this.isShowDial = false;
                      this.selectContactId = '';
                      this.mContactListPresenter.toDefaultPage();
                      this.maintenanceModeTabClick();
                      this.mCallRecordPresenter.setPageShow(false);
                      this.mContactListPresenter.setPageShow(true);
                      this.mFavoriteListPresenter.setPageShow(false);
                      this.mIndexPresenter.emitDefaultSelectedContact();
                      this.resetSystemBarProperties();
                    } else if (item == this.mIndexPresenter.favoriteIndex) {
                      this.activeCallId = -1;
                      this.isShowDial = false;
                      this.selectContactId = '';
                      this.isContactSearch = false;
                      this.mFavoriteListPresenter.toDefaultPage();
                      this.maintenanceModeTabClick();
                      this.mCallRecordPresenter.setPageShow(false);
                      this.mContactListPresenter.setPageShow(false);
                      this.mFavoriteListPresenter.setPageShow(true);
                      this.mFavoriteListPresenter.emitFavoriteDefaultSelectedContact();
                      this.resetSystemBarProperties();
                    }
                    let isClickShowPaste: boolean | undefined = AppStorage.get('isClickShowPaste');
                    HiLog.w(TAG, `isClickShowPate: ${isClickShowPaste} `);
                    if (isClickShowPaste || isClickShowPaste === undefined) {
                      if (this.pasteStatus) {
                        HiLog.w(TAG, 'tabBar onChange pasteStatus disappear');
                        this.pasteStatus = false;
                      }
                    } else if (!isClickShowPaste && item === this.mIndexPresenter.callIndex) {
                      HiLog.w(TAG, 'contactList to callIndex for the first time');
                      AppStorage.setOrCreate('isClickShowPaste', true);
                    }
                  }, 10);
                })
                .onChange((index: number) => {
                  HiLog.i(TAG, 'Tabs onChange, index == ' + index);
                })
                .safeAreaPadding({
                  bottom: DisplaySplitUtil.isHorizonSplit() ? px2vp(this.fullScreenPadding.bottom as number) :
                    !this.isContactSearch ? (this.curBp !== 'lg' || (this.curBp === 'lg' && this.isPortraitDisplay) ?
                      (this.isPortraitDisplay && this.isPortraitDisplayCarMachine ? $r('sys.float.padding_level0') :
                      px2vp(this.fullScreenPadding.bottom as number)) : $r('sys.float.padding_level0')) :
                    $r('sys.float.padding_level0')
                })
                .zIndex(1)
              }
              .height(this.isVerde ? this.columnHeight : 'auto')

              if (this.mainTabsIndex === this.mIndexPresenter.callIndex && this.isVerde) {
                VDialPad()
                  .width('100%')
                  .offset({ y: this.verdeDialerPadMoveY })
                  .animation({
                    curve: this.showDialBtn ? curves.interpolatingSpring(0, 1, 342, 37)
                      : curves.interpolatingSpring(4, 1, 342, 37),
                    onFinish: () => {
                      HiLog.w(TAG, `animation complete ${this.showDialBtn} btnShow is ${this.mDialerPresenter.btnShow}`);
                      if (this.showDialBtn) {
                        performanceMonitor.end('CONTACTS_DIALER_SHOW');
                      } else {
                        performanceMonitor.end('CONTACTS_DIALER_HIDE');
                      }
                    }
                  })
                  .gesture(
                    PanGesture({ fingers: 1, direction: PanDirection.Down, distance: 5 })
                      .onActionStart(() => {
                        this.verdeDialerPadMoveY = 0
                      })
                  )
                  .onTouch((event: TouchEvent) => {
                    switch (event.type) {
                    // touch down
                      case TouchType.Down:
                        this.downY = -1;
                        break;
                    // touch move
                      case TouchType.Move:
                        if (this.downY === -1) {
                          this.downY = event.touches[0].y;
                        }
                        break;
                    // touch up
                      case TouchType.Up:
                      case TouchType.Cancel:
                        const upY: number = event.touches[0].y;
                        if (this.downY != -1 && upY - this.downY > 100) {
                          this.showDialBtn = false;
                        }
                        break;
                    }
                  })
                  .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
                  .zIndex(2)
              }
            }
          }
        }
        .onNavigationModeChange((mode) => {
          if (mode === NavigationMode.Split) {
            this.isNavigationModeSplit = true;
          } else if (mode === NavigationMode.Stack) {
            this.isNavigationModeSplit = false;
          }
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') : Color.Transparent)
        .zIndex(1)
        .navBarWidth(this.curBp === 'lg' && !this.isPortraitDisplay ? '44%' : '50%')
        .hideTitleBar(true)
        .navDestination(this.myRouter)
        .bindSheet(this.isShowAccountants, this.ShowAccountantsView(), {
          title: NavDestinationHeaderView({
            isThemeActive: this.accountantTitleClass.isThemeActive,
            isOpenAccessibility: this.accountantTitleClass.isOpenAccessibility,
            fontSizeScale: this.accountantTitleClass.fontSizeScale,
            pageTitle: this.accountantTitleClass.pageTitle,
            isSave: this.accountantTitleClass.isSave,
            cancelOnClick: this.accountantTitleClass.cancelOnClick,
            savelOnClick: this.accountantTitleClass.savelOnClick,
          }),
          dragBar: true,
          showClose: false,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            emitter.emit({
              eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EVENT_ID_HIDE,
              priority: emitter.EventPriority.HIGH
            })
          },
          onWillSpringBackWhenDismiss: () => {
            // 如果注册该回调函数，则不会回弹，由开发者控制下滑关闭时是否回弹。
            // 在回调函数中可以通过调用springBack来实现回弹效果。
          }
        })
        // 当导航栏的可见性更改时触发回调
        .onNavBarStateChange((value: boolean) => {
          HiLog.i(TAG,
            'onNavBarStateChange:' + value + '  this.curBp:' + this.curBp + ' this.bottomTabIndex: ' +
            this.bottomTabIndex);
          if (this.curBp === 'sm') {
            if (value) {
              this.onPageShow();
            } else {
              this.onPageHide();
            }
          }
        })
        .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
          hiTraceMeter.startTrace('navDestinationAnimation', 101);
          if (from.mode == NavDestinationMode.DIALOG || to.mode == NavDestinationMode.DIALOG) {
            hiTraceMeter.finishTrace('navDestinationAnimation', 101);
            // 非页面push的情况在此 return
            return undefined;
          }
          let fromAnimation: TitleAnimation | undefined = CustomTransition.getInstance().getAnimateParam(from.index);
          let toAnimation: TitleAnimation | undefined = CustomTransition.getInstance().getAnimateParam(to.index);
          if (fromAnimation == undefined && toAnimation == undefined) {
            hiTraceMeter.finishTrace('navDestinationAnimation', 101);
            // 没有使用自定义导航的页面 在此会 return
            return undefined;
          }
          let isPop: boolean = NavigationOperation.POP == operation;

            //  from页面的动画 （pop时）
            if (fromAnimation != undefined) {
              if (fromAnimation?.transitionAnimation?.start) {
                fromAnimation.transitionAnimation.start(isPop, true);
              }
              animateTo({
                duration: 400, curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0), onFinish: () => {
                  if (fromAnimation?.transitionAnimation?.onFinish) {
                    fromAnimation.transitionAnimation.onFinish(isPop, true);
                  }
                }
              }, () => {
                if (fromAnimation?.transitionAnimation?.finish) {
                  fromAnimation.transitionAnimation.finish(isPop, true);
                }
              })

              animateTo({
                duration: 1050,
                delay: 17,
                curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0),
                onFinish: () => {
                }
              }, () => {
                if (fromAnimation?.titleAnimation?.finish) {
                  fromAnimation.titleAnimation.finish(isPop, true);
                }
              })

              if (fromAnimation?.opacityAnimation.start) {
                fromAnimation.opacityAnimation.start(isPop, true);
              }
              animateTo({
                duration: 67, curve: Curve.Sharp, onFinish: () => {
                }
              }, () => {
                if (fromAnimation?.opacityAnimation.finish) {
                  fromAnimation.opacityAnimation.finish(isPop, true);
                }
              })
            }

            //  to页面的动画 （push时）
            if (toAnimation != undefined) {
              if (toAnimation?.transitionAnimation?.start) {
                toAnimation.transitionAnimation.start(isPop, false);
              }
              animateTo({
                duration: 400, curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0), onFinish: () => {
                  if (toAnimation?.transitionAnimation?.onFinish) {
                    toAnimation.transitionAnimation.onFinish(isPop, false);
                  }
                }
              }, () => {
                if (toAnimation?.transitionAnimation?.finish) {
                  toAnimation.transitionAnimation.finish(isPop, false);
                }
              })
              if (toAnimation?.opacityAnimation.start) {
                toAnimation.opacityAnimation.start(isPop, false);
              }
              animateTo({
                duration: 200,
                delay: 150,
                curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0),
                onFinish: () => {
                }
              }, () => {
                if (toAnimation?.opacityAnimation.finish) {
                  toAnimation?.opacityAnimation.finish(isPop, false);
                }
              })
            }
            hiTraceMeter.finishTrace('navDestinationAnimation', 101);
            return undefined;
          })
        .onTouch(() => {
          if (this.foldedAndContinuedTaskId > 0) {
            HiLog.w(TAG, `clear foldedAndContinued, foldedAndContinuedTaskId: ${this.foldedAndContinuedTaskId
            }, foldedAndContinuedType: ${this.foldedAndContinuedType
            }, foldedAndContinuedToastId: ${this.foldedAndContinuedToastId}`);
            clearTimeout(this.foldedAndContinuedTaskId);
            this.foldedAndContinuedTaskId = -1;
            this.foldedAndContinuedType = FoldedAndContinuedType.NULL;
            if (this.foldedAndContinuedToastId > 0) {
              prompt.closeToast(this.foldedAndContinuedToastId);
              this.foldedAndContinuedToastId = -1;
            }
          }
        })
      }

      // 新增通话设置模态窗口
      if (this.isShowCallSetting) {
        UIExtensionComponent(
          {
            bundleName: 'com.ohos.callsetting',
            abilityName: 'com.ohos.callsetting.CallSettingUIExtAbility',
            type:'sys/commonUI',
            parameters: {
              'ability.want.params.uiExtensionType': 'sys/commonUI',
              'scrollToCardOne': this.scrollToCardOne,
              'windowStatus': this.windowStatus
            }
          })
          .id('call_setting_extension_id')
          .onRemoteReady((proxy: UIExtensionProxy) => {
            HiLog.i(TAG, 'onRemoteReady enter');
            this.callSettingProxy = proxy
            AppStorage.setOrCreate('callSettingProxy', proxy);
            focusControl.requestFocus('call_setting_extension_id');
            this.callSettingProxy?.send({'windowStatus': this.windowStatus});
          })
          .onTerminated((data) => {
            HiLog.i(TAG, `onResult : ${data?.code}`);
            this.isShowCallSetting = false;
          })
          .onError((error: Error) => {
            HiLog.e(TAG, 'CallSetting onError：'+JSON.stringify(error));
            this.isShowCallSetting = false;
          })
          .onReceive((data) => {
            HiLog.i(TAG, `onReceive : ${data}`);
            this.isShowFraudBanners();
            if (data?.isClose) {
              this.updateShowNewCallTip();
              this.scrollToCardOne = false;
              this.isShowCallSetting = false;
            }
            if (data?.getPickerData) {
              if (data?.getPickerData === 'getMultiPickerData') {
                this.isContactMultiSelect = true;
              } else if (data?.getPickerData === 'getSinglePickerData') {
                this.isContactMultiSelect = false;
              }
              this.isShowPicker = true;
            }
          })
          .width('100%')
          .height('100%')
          .backgroundColor('#00000000')
          .zIndex(3)
      }

      if (this.notePadJump) {
        UIExtensionComponent({
          bundleName: 'com.ohos.notepad',
          abilityName: 'CallNoteAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'noteUuid': this.notePadId,
            'sheetTitle': '通话摘要',
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(3)
          .onTerminated((info: TerminationInfo) => {
            HiLog.i(TAG, `notePadJump end` + info?.code);
            AppStorage.setOrCreate<boolean>('notePadJump', false);
            AppStorage.setOrCreate<boolean>('isNfcJump', false);
          })
          .onError(() => {
            HiLog.e(TAG, `onError notePadJump end`);
            AppStorage.setOrCreate<boolean>('notePadJump', false);
            AppStorage.setOrCreate<boolean>('isNfcJump', false);
          })
          .onRelease(() => {
            HiLog.e(TAG, `onRelease notePadJump end`);
            AppStorage.setOrCreate<boolean>('notePadJump', false);
            AppStorage.setOrCreate<boolean>('isNfcJump', false);
          })
      }

      if (this.isShowSwitchPage) {
        // 通话风险识别开关页半模态窗口
        Column() {
        }.backgroundColor('#0000000')
        .height(0).width(0).zIndex(0)
        .bindSheet($$this.isShowSwitchPage, this.PopupBuilder(), {
          dragBar: true,
          showClose: true,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          onDisappear: () => {
            this.isShowSwitchPage = false;
          },
          borderWidth: { top: 8 },
          borderColor: { top: '#00000000' }
        })
      }

      if (this.isShowContactsSettings) {
        // 新增联系人设置模态窗口
        Column() {
        }.backgroundColor('#0000000')
        .height(0).width(0).zIndex(0)
        .bindSheet($$this.isShowContactsSettings, this.ShowContactsSettings(), {
          dragBar: true,
          showClose: true,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          onDisappear: () => {
            this.isShowContactsSettings = false;
          },
          borderWidth: { top: 8 },
          borderColor: { top: '#00000000' }
        })
      }

      if (this.isShowPicker) {
        // 新增联系人选择模态窗口
        Column() {
        }.backgroundColor('#0000000')
        .height(0).width(0).zIndex(0)
        .bindSheet($$this.isShowPicker, this.PickerDataBuilder(), {
          dragBar: true,
          showClose: true,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          borderWidth: { top: 8 },
          borderColor: { top: '#00000000' },
          onWillDisappear: () => {
            if (this.isShowCallSetting) {
              focusControl.requestFocus('call_setting_extension_id');
            }
          }
        })
      }

    }
  }

  onDidBuild(): void {
    HiLog.w(TAG, `Index onDidBuild`);
  }

  @Builder
  ExportDialogBuilder() {
    Column() {
      Text($r('app.string.import_sim_contact_msg'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(TextAlign.Start)
    }
    .width('100%')
  }

  async resetSystemBarProperties() {
    if (this.curBp === 'sm') {
      return;
    }
    HiLog.i(TAG, 'resetSystemBarProperties status')
    try {
      let windowObj: window.Window | null | undefined = await window.getLastWindow(getContext(this));
      if (windowObj) {
        let systemBarProperties: window.SystemBarProperties = {
          statusBarContentColor: this.currentColorMode ? '#ff000000' : '#ffffffff'
        }
        windowObj.setWindowSystemBarProperties(systemBarProperties);
      }
    } catch (e) {
      HiLog.e(TAG, `resetSystemBarProperties error:${e?.message}`);
    }
  }

  @Builder
  ExportContactsProgressDialogBuilder() {
    Column() {
      CustomProgressContent({
        percent: this.percent,
        progressText: $r('app.string.importing_contacts'),
        isShowProgressInfo: false,
      })
    }
    .width('100%')
  }

  // PC上左侧A栏显隐状态变化时判断是否显示蒙层
  onSideBarStatusChanged(): void {
    if (!this.isPC) {
      return;
    }
    if (this.isNeedExpandSideBar && this.showSideBar) {
      AppStorage.setOrCreate('isNeedMask', true);
      if (this.isPcMinWindowWidth) {
        // 只有最小窗口下才需要蒙层
        animateTo({
          duration: 400,
          curve: Curve.Sharp,
        }, () => {
          this.maskOpacity = 1;
        });
      }

    } else {
      AppStorage.setOrCreate('isNeedMask', false);
    }
  }
}
