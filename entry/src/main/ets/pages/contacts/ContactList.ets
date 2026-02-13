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

import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { HiLog, sharedPreferencesUtils, StringUtil } from '../../../../../../common';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import EmitterConstant from '../../data/EmitterConstant';
import { ContactContentByRefresh } from '../../component/contact/contactlist/ContactContentByRefresh';
// import { ContactEmptyPage } from '../../component/contact/contactlist/ContactEmptyPage';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { mergeDuplicateContactsByUrl } from '../../task/TaskService';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { curves, LengthMetrics, TextModifier, SymbolGlyphModifier, ComponentContent } from '@kit.ArkUI';
import { AlphabetIndexerPage } from '../../pages/contacts/alphabetindex/AlphabetIndexerPage';
import BigPhotoCopyUtil from '../../util/BigPhotoCopyUtil';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import Settings from './settings/Settings';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ArrowBack } from '../../component/contact/contactlist/ArrowBack';
import { common, UIExtensionContentSession } from '@kit.AbilityKit';
import VcardImportUtil from '../../util/VcardImportUtil';
import Want from '@ohos.app.ability.Want';
// import { PickerMaskLayer } from '@hw-hmos/pickersheet';
import { Constants } from '../../data/Constants';
// import { scanBarcode, scanCore } from '@kit.ScanKit';
import { QrCodeManager } from '../../presenter/qrcode/QrCodeManager';
import { showToast, SystemModeController } from '../../util/SystemModeController';
// import { HdsNavigation, HdsNavigationAttribute,
//   HdsNavigationBadgeIconOptions, HdsNavigationTitleMode,
//   ScrollEffectType } from '@kit.UIDesignKit';
// import { HideMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import { SearchUtil } from '../../util/SearchUtil';
import { taskpool } from '@kit.ArkTS';
// import SearchClient from '../../search/search';
import { i18n } from '@kit.LocalizationKit';
import { GlobalContext } from '../../util/GlobalContext';
import { ContactListBoModel } from '../../model/ContactListBoModel';
import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import PageManager from '../../MainAbility/PageManager';
import SideBarButton from '../SideBarButton';
import { commonEventManager } from '@kit.BasicServicesKit';
import { ContactEmptyPage } from './batchselectcontacts/ContactEmptyPage';

const TAG = 'ContactList  ';
const CONTACT_ADD_EVENT: string = 'CONTACT_ADD_EVENT';
const SETTINGS_EVENT: string = 'SETTINGS_EVENT';
const GROUP_CLICK_EVENT: string = 'GROUP_CLICK_EVENT';
const CLICK_CONTACT_SETTINGS: string = 'CLICK_CONTACT_SETTINGS';
const CLICK_SCAN_CONTACT_EVENT: string = 'CLICK_SCAN_CONTACT_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

const CLICK_SEARCH_BAR_EVENT: string = 'CLICK_SEARCH_BAR_EVENT';
interface ParamsInterface {
  groupFunction: Function,
  setFunction: Function,
  jumpToFeedbackMenu: Function
}

/**
 * Contact list page
 */
@Component
export default struct ContactListPage {
  mContactPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPadding') @Watch('fullScreenPaddingOnChange') fullScreenPadding: Padding = {};
  // 联系人列表长度
  @State @Watch('onContactListLenChange') contactListListLen: number = ContactListPresenter.getInstance().total;
  // 联系人列表是否为空,用于标题刷新
  @State isEmptyContactList: boolean = false;
  @StorageLink('isContactSearch') @Watch('isContactSearchValueChange') isContactSearch: boolean = false;
  @StorageLink('selectContactId') selectContactId: string = '';
  //联系人列表新建联系人
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @State navigationMenusOpacity: number = 1;
  customParams: CustomizedParams = {};
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // whether to start the theme
  @StorageLink('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('isVerde') @Watch('onForegroundChange') isVerde: boolean = false;
  @StorageProp('isVerdeModel') isVerdeModel: boolean = false;
  @StorageProp('isMainAbilityForeground') @Watch('onForegroundChange') isMainAbilityForeground: boolean = true;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  isExportDiaShow: boolean = false;
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  // 判断是否展示联系人设置bindSheet
  @StorageLink('isShowContactsSettings') isShowContactsSettings: boolean = false;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @State isShowCustomSearchButton: boolean = false;
  @StorageLink('isShowSearch') isShowSearch: boolean = true;
  // vCard导入联系人
  @StorageProp('importVcardWant') @Watch('openImportVCardDialog') importVcardWant: Want | null = null;
  // 畅连适配
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimeNeedSplit') isMeetimeNeedSplit: boolean = false;
  @StorageProp('isMeetimePC') isMeetimePC: boolean = false;//畅连PC
  @StorageProp('isMeetimePhone') isMeetimePhone: boolean = false;
  @StorageProp('isShowJumpButton') isShowJumpButton: boolean = false;
  @StorageLink('isShowPickerMaskLayer') isShowPickerMaskLayer: boolean = false;//显示遮罩层
  @State private presenter: ContactListPresenter = ContactListPresenter.getInstance();
  scroller: Scroller = new Scroller();
  emptyScroller: Scroller = new Scroller();
  @State searchOffsetY:number = 0;
  @State searchValueLength: number = 0;
  uiExtensionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();
  private systemModeController = SystemModeController.getInstance();
  @State inputMethod: boolean = true;
  // 分享弹窗是否在打开中
  private isImportVCardDialogOpening: boolean = false;
  // 从联系人图标打开应用，进入联系人列表，不需要分帧显示联系人列表
  @State stages: number = ContactListPresenter.getInstance().intoFromContactIconFlag ? 10 : 0;
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State preListItemNum: number = 0;
  @StorageLink('showSideBar') showSideBar: boolean = true;
  // 打开/关闭云同步开关，给HDS区分scroller变化
  @State isReBindScroll: boolean = false;

  createContactParams: CustomizedParams = {
    ENC: 0
  };
  settingsParams: CustomizedParams = {
    ITEM: 0
  };
  customizedParams: CustomizedParams = {};
  autoMergeDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.merge_repeat_contact'),
      contentBuilder: () => {
        this.AutoMergeBuilder();
      },
      buttons: [
        {
          value: $r('app.string.always_auto_merge'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.w(TAG, 'choose always merge');
            sharedPreferencesUtils.saveToPreferences('isFirstAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('autoMergeCancelState', false);
            sharedPreferencesUtils.saveToPreferences('alwaysAutoMerge', true);
            sharedPreferencesUtils.saveToPreferences('autoMergeTime', new Date().getTime());

            this.mContactPresenter.repeatNum = 0;
            this.autoMergeDialogController.close();
            this.isExportDiaShow = false;
            sharedPreferencesUtils.saveToPreferences('isAutoMerge', true);
            mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        },
        {
          value: $r('app.string.only_once_merge'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.w(TAG, 'choose only once merge');
            sharedPreferencesUtils.saveToPreferences('isFirstAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('alwaysAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('isAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('autoMergeCancelState', true);
            sharedPreferencesUtils.saveToPreferences('checkAutoMergeTime', new Date().getTime());
            this.mContactPresenter.repeatNum = 0;
            mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
          }
        },
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.w(TAG, 'choose cancel merge');
            sharedPreferencesUtils.saveToPreferences('isFirstAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('autoMergeCancelState', false);
            sharedPreferencesUtils.saveToPreferences('isCancel', true);
            sharedPreferencesUtils.saveToPreferences('alwaysAutoMerge', false);
            sharedPreferencesUtils.saveToPreferences('isAutoMerge', false);
            this.mContactPresenter.repeatNum = 0;
            this.isExportDiaShow = false;
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  unSupportDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.tip'),
      content: $r('app.string.unsupport_qrcode'),
      primaryButton: {
        value: $r('app.string.got_it'),
        action: () => {
          this.unSupportDialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
      }
    }),
    cancel: () => {
      this.unSupportDialogController?.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    },
    customStyle: false,
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: {
      dy: 0,
      dx: 0
    }
  });
  importVCardDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.import_vCard_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.isImportVCardDialogOpening = false;
          HiLog.w(TAG, 'importVCardDialog cancel');
          this.importVCardDialogController?.close();
          AppStorage.setOrCreate('importVcardWant', null);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          if (this.importVcardWant) {
            HiLog.w(TAG, 'importVCardDialog confirm');
            VcardImportUtil.importVcardFromWant(this.importVcardWant, (contactId: string) => {
              try {
                commonEventManager.publish('event.custom.contacts.VCARD_SHARE', (err: BusinessError) => {
                  if (err) {
                    HiLog.w(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
                  }
                  HiLog.w(TAG, `Succeeded in publishing common event: VCARD_SHARE`);
                });
              } catch (err) {
                HiLog.e(TAG, 'importVCardDialogController publish ces err: ' + err?.message + ', stack: ' + err?.stack);
              }
              this.isImportVCardDialogOpening = false;
              HiLog.w(TAG, 'importVcardFromWant success');
              AppStorage.setOrCreate('importVcardWant', null);
              PageManager.jumpToDetailWithContactId(contactId);
            });
          }
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
      }
    }),
    showInSubWindow: true,
    autoCancel: true,
    closeAnimation: { duration: 100 },
    cancel: () => {
      AppStorage.setOrCreate('importVcardWant', null);
    },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isPC ? BlurStyle.COMPONENT_ULTRA_THICK :
      this.isThemeActive ? BlurStyle.NONE : undefined,
    shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_SM : undefined,
  });

  // 新旧数量不一样刷新数量
  refresh() {
    HiLog.w(TAG, `refresh total: ${this.mContactPresenter.total}, contactListListLen: ${this.contactListListLen}`)
    // 联系人列表长度变化的话，更新标题显示
    if (this.contactListListLen != this.mContactPresenter.total) {
      this.contactListListLen = this.mContactPresenter.total;
      this.mContactPresenter = ContactListPresenter.getInstance();
      AppStorage.setOrCreate('isDefaultPageShow', this.contactListListLen > 0)
    }
  }

  // is Contact SearchValue Change
  isContactSearchValueChange() {
    HiLog.w(TAG, `isContactSearchChange - isContactSearch value change: ${this.isContactSearch}`);
    if (!this.isContactSearch) {
      this.mContactPresenter.inputKeyword = '';
      this.searchValueLength = 0;
    }
  }

  // 监听联系人数量变化判断列表是否为空,watch回调
  onContactListLenChange(): void {
    let isEmptyContactList = this.isEmptyContactList;
    if (this.contactListListLen <= 0) {
      isEmptyContactList = true;
    } else {
      isEmptyContactList = false;
    }
    if (isEmptyContactList !== this.isEmptyContactList) {
      this.isEmptyContactList = isEmptyContactList;
      HiLog.w(TAG, `is empty list changed : ${this.isEmptyContactList}, length ${this.contactListListLen}`);
    }
  }

  onForegroundChange() {
    // v小折叠 外屏展示回到前台的时候，设置页面收起
    if ((this.isVerde && this.isMainAbilityForeground)) {
      this.isShowContactsSettings = false;
    }
  }

  // fullScreenPaddingOnChange
  fullScreenPaddingOnChange() {
    if (this.fullScreenPadding.top as number < 0) {
      this.fullScreenPaddingTop = px2vp(AppStorage.get('fullScreenPaddingTop') as number);
    } else {
      this.fullScreenPaddingTop = px2vp(this.fullScreenPadding.top as number);
    }
    HiLog.w(TAG, `fullScreenPaddingOnChange! top: ${this.fullScreenPadding.top as number}`);
    HiLog.w(TAG, `fullScreenPaddingOnChange! bottom: ${this.fullScreenPadding.bottom as number}`);
  }

  openImportVCardDialog() {
    HiLog.w(TAG, 'openImportVCardDialog');
    if (this.importVcardWant && this.importVcardWant != null) {
      this.isImportVCardDialogOpening = true;
      this.importVCardDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.importVCardDialogController);
    }
  }

  async aboutToAppear() {
    HiLog.w(TAG, 'Contact aboutToAppear!');
    GlobalContext.getContext().setObject('scrollerContactList', this.scroller);
    this.mContactPresenter.curBp = this.curBp;
    this.mContactPresenter.aboutToAppear(this.autoMergeDialogController);
    // 绑定回调方法；可能绑定前，已经查询完数量信息，执行了refresh回调（此时refresh参数为空，会被跳过）
    // 所以后边再调一次刷新
    this.mContactPresenter.bindUI(() => {
      this.refresh();
    }, () => {
      // contact 长度减一，标题联系人个数变化
      if (this.contactListListLen > 0) {
        this.contactListListLen -= 1;
      }
    })
    this.refresh();
    this.mContactPresenter.repeatNum = 0;
    this.autoMergeDialogController.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    let accountInnerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EMITTER_ID,
      priority: emitter.EventPriority.HIGH,
    }
    emitter.on(accountInnerEvent, () => {
      this.refresh();
    })
    emitter.on({ eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID }, () => {
      this.isShowContactsSettings = false;
    })
    // 联系人大头像云同步需求上线之后，在版本升级后，用户第一次打开联系人应用时，当通话记录加载完成之后
    // 需要触发一次存量联系人大头像文件拷贝操作：之前的联系人大头像文件存于联系人应用沙箱下，现在需要拷贝至群组沙箱下，用于云同步
    // 此操作只操作一次，只针对存量用户
    await BigPhotoCopyUtil.getInstance().copyPhotoFile();
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'Contact aboutToDisappear!');
    GlobalContext.getContext().removeObject('scrollerContactList');
    this.importVCardDialogController = null;
    this.unSupportDialogController = null;
    if (!this.isPC) {
      emitter.off(EmitterConstant.EMITTER_ACCOUNTANTS_EMITTER_ID);
      // 注销关于页面退出监听
      emitter.off(EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID);
      this.mContactPresenter.aboutToDisappear();
    }
  }

  onPageShow() {
    HiLog.w(TAG, 'onPageShow');
    if (this.importVcardWant && this.importVcardWant != null && !this.isImportVCardDialogOpening) {
      HiLog.w(TAG, 'importVCardDialogOpen onPageShow');
      this.importVCardDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.importVCardDialogController);
    }
    this.refresh();
    emitter.emit({ eventId: EmitterConstant.CONTACT_LIST_CACHE_UPDATE });
  }

  onPageHide() {
    HiLog.w(TAG, 'onPageCover');
    this.isShowContactsSettings = false
  }

  private getNavigationTitleMode(splitStatus: SplitStatus): NavigationTitleMode {
    //如果是悬浮窗走原来的逻辑
    if (this.isShowSmartWindow) {
      return this.getTitleMode();
    }
    if (DisplaySplitUtil.isFixedTitleBar(splitStatus)) {
      return NavigationTitleMode.Mini;
    }

    return this.getTitleMode();
  }

  private getPCNavigationTitleMode(splitStatus: SplitStatus): NavigationTitleMode {
    if (DisplaySplitUtil.isFixedTitleBar(splitStatus)) {
      return NavigationTitleMode.Mini;
    }

    return this.getTitleMode();
  }

  private getTitleMode() {
    return this.isEmptyContactList ? 1 : 0;
  }

  /**
   * 扫一扫入口
   *
   * @param context {common.Context} - 上下文
   */
  launchScan(context: common.Context) {
    // let options: scanBarcode.ScanOptions =
    //   { scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true };
    try {
      HiLog.i(TAG, `start invoke scanKit`);
      // scanBarcode.startScanForResult(context, options).then((result: scanBarcode.ScanResult) => {
      //   HiLog.i(TAG, `received scanKit result length: ${result?.originalValue?.length}`);
      //   let qrResult = QrCodeManager.getInstance().handleQrCode(result?.originalValue);
      //   if (typeof qrResult === 'number') {
      //     this.unSupportDialogController?.open();
      //     DialogControllerManager.getInstance().addDialogController(this.unSupportDialogController);
      //   } else {
      //     AppStorage.setOrCreate('accountantParams', {
      //       newContactData: qrResult
      //     });
      //     this.isShowAccountants = true;
      //   }
      // }).catch((error: BusinessError) => {
      //   HiLog.e(TAG, `scanKit err, code: ${error?.code}, message: ${error?.message}`);
      // });
    } catch (error) {
      HiLog.e(TAG, `failed to invoke scanKit, message: ${error.message}`);
    }
  }

  private getBackgroundColor(): Resource {
    let backgroundColor: Resource = $r('app.color.skin_background_primary');
    if (this.isFromMeetime) {
      backgroundColor = $r('app.color.skin_background_secondary');
    } else if (this.isThemeActive) {
      backgroundColor = $r('app.color.background_last_white');
    }
    return backgroundColor;
  }

  // getMenuBar(): HdsNavigationBadgeIconOptions[] {
  //   let value: HdsNavigationBadgeIconOptions[] = [];
  //   if (this.isContactSearch) {
  //     return value;
  //   }
  //   if (this.isVerde && !this.isEmptyContactList) {
  //     value.push(this.searchButton);
  //   } else {
  //     if (!this.isShowJumpButton) {
  //       value.push(this.newContact);
  //     } else {
  //       value.push(this.openContacts);
  //     }
  //     if (!this.isFromMeetime) {
  //       value.push(this.moreContacts);
  //     }
  //   }
  //   return value;
  // }

  // searchButton: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.search_button'),
  //     icon: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
  //       .fontSize($r('app.float.id_card_image_small'))
  //       .fontColor([$r('app.color.skin_icon_primary')]),
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       HiLog.i(TAG, 'magnifyingglass onClick');
  //       this.isContactSearch = true;
  //       emitter.emit(AlphabetIndexerPage.innerEvent);
  //       setTimeout(() => {
  //         focusControl.requestFocus('contactList_contacts_valueChange_search');
  //       }, 10)
  //     }
  //   }
  // }

  // newContact: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.accessibility_new_contact'),
  //     icon: new SymbolGlyphModifier($r('sys.symbol.plus'))
  //       .fontSize($r('app.float.id_card_image_small'))
  //       .fontColor([$r('app.color.skin_icon_primary')]),
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     componentId: 'accessibility_new_contact_id',
  //     action: () => {
  //       // 新建联系人打点-联系人列表处
  //       DotUtil.getInstance().contactDot(this.createContactParams, CONTACT_ADD_EVENT);
  //       this.isShowAccountants = true;
  //       emitter.emit(AlphabetIndexerPage.innerEvent);
  //     }
  //   }
  // }

  // openContacts: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.accessibility_open_mobile_contacts'),
  //     icon: new SymbolGlyphModifier($r('sys.symbol.person_2'))
  //       .fontSize($r('app.float.id_card_image_small'))
  //       .fontColor([$r('app.color.skin_icon_primary')]),
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     action: () => {
  //       if (this.uiExtensionSession != undefined) {
  //         HiLog.w(TAG, 'jumpTo-CSP-ContactList sendJumpToCSPMsg');
  //         this.mContactPresenter.sendMsgToMeetime(this.uiExtensionSession, 'jumpToCSP');
  //       }
  //     }
  //   }
  // }

  // moreContacts: HdsNavigationBadgeIconOptions =
  // {
  //   content: {
  //     label: $r('app.string.accessibility_more'),
  //     icon: new SymbolGlyphModifier($r('sys.symbol.dot_grid_2x2'))
  //       .fontSize($r('app.float.id_card_image_small'))
  //       .fontColor([$r('app.color.skin_icon_primary')]),
  //     isEnabled: !this.isShowPickerMaskLayer,
  //     componentId: 'HdsContactMore',
  //     action: () => {
  //       // 联系人打点--点击联系人列表更多
  //       DotUtil.getInstance().contactDot(this.customizedParams, CLICK_CONTACT_SETTINGS);
  //       let uiContext = this.getUIContext();
  //       let promptAction = uiContext.getPromptAction();
  //       let contentNode = new ComponentContent<ParamsInterface>(uiContext,
  //         wrapBuilder<[ParamsInterface]>(hdsMenuBuilder),
  //         {
  //           groupFunction: () => {
  //             // 先聚焦到空的焦点上，等待跳转
  //             AccessibilityUtil.getInstance().instantlySendAccessibilityEvent(this.isOpenAccessibility, 'focus_empty_id')
  //             // 联系人打点--联系人列表点击群组
  //             DotUtil.getInstance().contactDot(this.customizedParams, GROUP_CLICK_EVENT);
  //             this.selectContactId = '';
  //             this.mContactPresenter.toGroupList(this.curBp !== 'sm');
  //             ContextMenu.close();
  //           },
  //           setFunction: () => {
  //             // 联系人打点--联系人列表点击更多点击设置
  //             DotUtil.getInstance().contactDot(this.settingsParams, SETTINGS_EVENT);
  //             // 更改联系人设置页面为模态窗口加载
  //             this.isShowContactsSettings = true;
  //             ContextMenu.close();
  //           },
  //           jumpToFeedbackMenu: () => {
  //             try {
  //               let context = getContext(this) as common.UIAbilityContext;
  //               if (context !== null && context !== undefined) {
  //                 const want: Want = {
  //                   bundleName: 'com.ohos.hiviewcare',
  //                   abilityName:'FeedBackAbility',
  //                   parameters: {
  //                     pafAppid: '6054',
  //                     bName: 'com.ohos.contacts'
  //                   }
  //                 }
  //                 context.startAbility(want);
  //               }
  //             } catch (error) {
  //               let err = error as BusinessError;
  //               HiLog.e(TAG, 'jumpToFeedbackMenu fail error message: ' + err.message + ', error code: ' + err.code);
  //             }
  //           }
  //         });
  //       try {
  //         promptAction.openMenu(
  //           contentNode,
  //           { id: 'HdsContactMore' },
  //           { placement:Placement.BottomRight})
  //       } catch (error) {
  //         let err = error as BusinessError;
  //         HiLog.e(TAG, 'menuItems openMenu fail error message: ' + err.message + ', error code: ' + err.code);
  //       }
  //     }
  //   }
  // }

  private getSearchWidth(isContactSearch: boolean): string {
    if (isContactSearch || this.isVerde) {
      if (this.isMeetimePC) {
        return 'calc(100% - 88vp)';
      } else if (this.isPC) {
        return 'calc(100% - 96vp)';
      } else {
        return 'calc(100% - 80vp)';
      }
    }
    return this.isPC ? 'calc(100% - 48vp)' : 'calc(100% - 32vp)';
  }

  onSearchClicked(): void {
    if (this.presenter.searchSerInitStatus != 0) {
      HiLog.w(TAG, 'initFusionSearchService');
      let task = new taskpool.Task(initFusionSearchService);
      taskpool.execute(task).then((res: Object) => {
        HiLog.w(TAG, `init fusionSearchService res: ${res}`)
        this.presenter.searchSerInitStatus = Number(res.toString());
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `onSearchClicked taskpool err: ${err.message}`);
      })
    }
    this.inputMethod = true;
    HiLog.w(TAG, 'onSearchClicked ');
    animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38)
    }, () => {
      HiLog.w(TAG, 'isContactSearch value change: contactContent/onSearchClicked');
      this.isContactSearch = true;
      AppStorage.setOrCreate('calibrationAlphabetIndex', 3);
      //联系人打点--点击搜索框
      DotUtil.getInstance().contactDot(this.customParams, CLICK_SEARCH_BAR_EVENT);
    });
  }

  onArrowClicked(): void {
    HiLog.w(TAG, 'onArrowClicked ');
    if (this.isVerde) {
      HiLog.w(TAG, 'v isContactSearch value change: contactContent/onArrowClicked');
      this.isContactSearch = false;
    } else {
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 30)
      }, () => {
        HiLog.w(TAG, 'isContactSearch value change: contactContent/onArrowClicked');
        this.isContactSearch = false;
      });
    }
  }

  // 获取拖拽文本
  onSearchDrop(dragData: UnifiedData) {
    let textDrop: string = '';
    let textDropTotal: number = 0;
    let records: unifiedDataChannel.UnifiedRecord[] = dragData.getRecords();
    HiLog.i(TAG, 'onSearchDrop records length: ' + records.length);
    for (let record of records) {
      // 搜索框匹配-纯文本类型
      if (record.getType() === uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        let plainText = record as unifiedDataChannel.PlainText;
        if (!StringUtil.isEmpty(plainText.textContent)) {
          textDrop += plainText.textContent;
          textDropTotal++;
        }
      }
    }
    HiLog.i(TAG, 'onSearchDrop textDropTotal: ' + textDropTotal);
    this.presenter.inputKeyword = textDrop;
  }

  // 搜索框
  @Builder
  SearchContact() {
    Row() {
      Stack() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_ohos_id_color_primary')])
        }
        .onClick(() => {
          HiLog.w(TAG, 'onBackButtonClick');
          this.isContactSearch = false;
          AppStorage.setOrCreate('calibrationAlphabetIndex', 1);
          // SearchUtil.getInstance().disconnectSearchSession();
          this.onArrowClicked();
          this.presenter.inputKeyword = '';
          // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
          this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
        })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_back')))
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
        .draggable(false)
        .id('contactList_contacts_back_arrowBack')
        .margin({
          start: EnvironmentProp.isPC() ? LengthMetrics.resource($r('sys.float.padding_level12')) :
            LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
        })
        .visibility(this.isContactSearch || this.isVerde ? Visibility.Visible : Visibility.None)
      }

      //搜索框
      WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        Search({
          value: this.isContactSearch ? this.presenter.inputKeyword : '',
          placeholder: ResourceUtil.getPluralStringByResource($r('app.plural.search_new'), this.contactListListLen)
        })
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
          .visibility(this.splitStatus === SplitStatus.ONE_THREE_SPLIT ? Visibility.None : Visibility.Visible)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
            .fontColor([$r('app.color.skin_ohos_id_color_secondary')]))
          .cancelButton({
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
              .fontColor([$r('app.color.skin_ohos_id_color_primary')])
          })
          .width(this.getSearchWidth(this.isContactSearch))
          .accessibilityText(' ')
          .margin({
            left: this.isContactSearch || this.isVerde ? $r('sys.float.padding_level4') :
              this.isPC ? this.spaceLR : $r('app.float.id_card_margin_xxl'),
            right: this.spaceLR,
          })
          .placeholderColor($r('app.color.skin_font_secondary'))
          .id('search_box_bnt')
          .placeholderFont({
            size: ($r('sys.float.Body_L')),
            weight: FontWeight.Regular
          })
          .backgroundColor($r('app.color.skin_comp_background_tertiary'))
          .textFont({ size: $r('sys.float.Body_L'), weight: 400 })// extra options
          .focusable(this.isPC ? true : this.isContactSearch ? true : false)
          .onChange((value: string) => {
            if (this.isPC && !this.isContactSearch && value.length > 0) {
              if (ContactListBoModel.getInstance().getToSearchPage() && this.searchOffsetY === 0) {
                this.onSearchClicked();
              }
              focusControl.requestFocus('contactList_contacts_valueChange_search');
            }
            this.searchValueLength = value.replace(/\s*/g, '').length;
            this.presenter.inputKeyword = value;
            // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
            this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
          })
          .id('contactList_contacts_valueChange_search')
          .onClick(() => {
            if (this.isContactSearch) {
              return;
            }
            if (ContactListBoModel.getInstance().getToSearchPage() && this.searchOffsetY === 0) {
              this.onSearchClicked();
            }
            focusControl.requestFocus('contactList_contacts_valueChange_search');
          })
          .onDrop((event: DragEvent) => {
            // 搜索框未获焦时进行拖拽触发
            if (this.isContactSearch) {
              return;
            }
            if (ContactListBoModel.getInstance().getToSearchPage()) {
              this.onSearchClicked();
            }
            focusControl.requestFocus('contactList_contacts_valueChange_search');
            this.onSearchDrop(event.getData());
          })
          .onFocus(() => {
            this.inputMethod = true;
            // SearchUtil.getInstance().initSearchSession();
            // focusControl.requestFocus('searchContact');
          })
          .enableKeyboardOnFocus(this.inputMethod)
          .onBlur(() => {
            this.inputMethod = false;
          })
          .onAppear(() => {
            // 搜索按钮和搜索框点击进入搜索页面主动聚焦搜索框
            AccessibilityUtil.getInstance()
              .instantlySendAccessibilityEvent(this.isContactSearch, 'contactList_contacts_valueChange_search');
          })
      }
    }
    .height($r('app.float.id_item_height_large'))
    .margin({ end: this.isContactSearch && this.isMeetimePC ? LengthMetrics.vp(128) : LengthMetrics.vp(0) })
    .visibility(!this.isVerde || this.isContactSearch ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  customSearchButton() {
    Stack({ alignContent: Alignment.End }) {
      Button({type: ButtonType.Circle, buttonStyle: ButtonStyleMode.NORMAL}) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
          .focusable(false)
          .accessibilityLevel('no')
      }
      .size({ width: $r('app.float.id_button_height_hicar'), height: $r('app.float.id_button_height_hicar') })
      .visibility(!this.isVerde && this.isShowCustomSearchButton && this.contactListListLen > 0 &&
        !this.maintenanceMode ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 100, curve: Curve.Sharp })
      .accessibilityText($r('app.string.search_button'))
      .onClick(() => {
        HiLog.i(TAG, 'customSearchButton onClick');
        this.inputMethod = true;
        this.isContactSearch = true;
        AppStorage.setOrCreate('calibrationAlphabetIndex', 0);
        emitter.emit(AlphabetIndexerPage.innerEvent);
        setTimeout(() => {
          focusControl.requestFocus('contactList_contacts_valueChange_search');
        }, 10)
      })
    }
    .width('100%')
    .padding(this.getCustomSearchButtonPadding())
    .layoutWeight(1)
  }

  private getCustomSearchButtonPadding(): Padding {
    try {
      let outerPadding: number = LengthMetrics.resource($r('sys.float.padding_level8')).value;
      const buttonSpacing: number = LengthMetrics.resource($r('app.float.id_width_8')).value;
      const buttonWidth: number = LengthMetrics.resource($r('app.float.id_button_height_hicar')).value;
      // const buttonNum: number = this.getMenuBar().length;
      const buttonNum: number = 0;
      const rightPadding: number = outerPadding + buttonNum * (buttonWidth + buttonSpacing);
      return i18n.isRTL(i18n.System.getSystemLanguage()) ? { left: rightPadding, right: outerPadding } :
        { left: outerPadding, right: rightPadding };
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      HiLog.e(TAG, `getCustomSearchButtonPadding failed: ${err?.message}`);
    }
    return {};
  }

  build() {
    Stack() {
      if (this.isPC) {
        Navigation() {
          this.ContactListBuilder()
        }
        .mode(NavigationMode.Stack)
        .titleMode(this.isVerdeModel || this.isPC || this.isFromMeetime ?
          NavigationTitleMode.Mini : this.getPCNavigationTitleMode(this.splitStatus))
        .title(this.isFromMeetime ? this.MeetimeTitle() : (this.isPC ? '' : $r('app.string.contact')),
          {mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined)})
        .hideBackButton(true)
        .hideTitleBar(this.isContactSearch || DisplaySplitUtil.isSmOneThreeSplit(this.splitStatus), !this.isVerde)
        .menus(this.isVerde ? this.VerdeTitleGuide() : this.TitleGuide())
        .width('100%')
        .height('100%')
        .onNavBarStateChange((value: boolean) => {
          if (value) {
            this.onPageShow();
          } else {
            this.onPageHide();
          }
        })
        .onTitleModeChange((titleMode: NavigationTitleMode) => {
          if (titleMode === NavigationTitleMode.Full) {
            this.mContactPresenter.isFullTitle = true;
          } else {
            this.mContactPresenter.isFullTitle = false;
          }
        })
        .padding({ top: this.fullScreenPaddingTop })
        .backgroundColor(this.getBackgroundColor())
        .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
        .backgroundImageSize({ width: '100%', height: '100%' })
      } else {
        //移动端
        Stack() {
          Navigation() {
            this.SearchContact()
            //联系人列表
            this.ContactListBuilder()
            Text('')
              .id('focus_empty_id')
          }
          .mode(NavigationMode.Stack)
          //标题模式
          .titleMode(this.isContactSearch || this.isVerdeModel || this.isFromMeetime ?
            NavigationTitleMode.Mini : this.getNavigationTitleMode(this.splitStatus))
          // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.getMenuBar(), () => {}))
          .title(this.isFromMeetime ? (this.isMeetimePhone ?
            ResourceUtil.getStringByResource($r('app.string.mobile_contacts')) :
            ResourceUtil.getStringByResource($r('app.string.system_contacts'))) :
            (this.isContactSearch ? '' : ResourceUtil.getStringByResource($r('app.string.contact'))))
          .hideToolBar(true)//隐藏控制
          .hideBackButton(true)
          //菜单绑定
          .menus(this.isVerde ? this.VerdeTitleGuide() : this.TitleGuide())
          // .dynamicHideTitleBar({
          //   hideTitleArea: false,
          //   hideBottomBuilder: true,
          //   hideStatusBar: false,
          //   mode: HideMode.SCROLL_UP_TO
          // })
          .hideTitleBar(DisplaySplitUtil.isSmOneThreeSplit(this.splitStatus), !this.isVerde)
          // 1.批量删除切换到空白页通知刷新 2.云同步通知刷新
          // .bindToScrollable(this.isEmptyContactList ? [this.emptyScroller] :
          //     this.isReBindScroll ? [this.scroller] : [this.scroller])
          .width('100%')
          .height('100%')
          .onNavBarStateChange((value: boolean) => {
            if (value) {
              this.onPageShow();
            } else {
              this.onPageHide();
            }
          })
          .onTitleModeChange((titleMode: NavigationTitleMode) => {
            if (titleMode === NavigationTitleMode.Full) {
              this.mContactPresenter.isFullTitle = true;
            } else {
              this.mContactPresenter.isFullTitle = false;
            }
          })
          // .onDynamicHideStatusChange((isTitleAreaHidden: boolean, isBottomBuilderHidden: boolean,
          //   titleBarHeight: number) => {
          //   HiLog.i(TAG, `onDynamicHideStatusChange, isTitleAreaHidden: ${isTitleAreaHidden}, ` +
          //     `isBottomBuilderHidden: ${isBottomBuilderHidden}, titleBarHeight: ${titleBarHeight}`);
          //   this.isShowCustomSearchButton = isBottomBuilderHidden;
          //   this.isShowSearch = !isBottomBuilderHidden;
          // })
          .padding({ top: this.isContactSearch ? 0 :this.fullScreenPaddingTop })
          .backgroundColor(this.getBackgroundColor())
          .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
          .backgroundImageSize({ width: '100%', height: '100%' })
        }

        if (this.stages > 0 && DisplaySplitUtil.isShowIndex(this.splitStatus)) {
          if (this.searchValueLength === 0 && this.contactListListLen > 0 && !this.maintenanceMode) {
            Column() {
              AlphabetIndexerPage({
                scroller: this.scroller,
                selected: this.alphabetSelected,
                isClicked: $isAlphabetClicked,
                isAutoCollapse: this.isNeedAutoCollapse(),
                preIndexNum: this.preListItemNum,
                useSources: 'CONTACT_CONTENT'
              })
                .id('contactList_contacts_alphabetIndexer_alphabetIndexerPage')
            }
            .height('100%')
            .position(i18n.isRTL(i18n.System.getSystemLanguage()) ? { left: 0, top: this.getIndexMargin() } :
              { right: 0, top: this.getIndexMargin() })
          }
        }
      }

      Column() {
      }.backgroundColor('#0000000').width(0).height(0).zIndex(0)
      .bindSheet($$this.isShowContactsSettings, this.ShowContactsSettingBuilder(), {
        dragBar: true,
        showClose: false,
        preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
        backgroundColor: this.isThemeActive ? $r('app.color.skin_background_secondary') : undefined,
        borderWidth: { top: 8 },
        borderColor: { top: '#00000000' },
        shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_MD : undefined
      })
    }
  }

  private getIndexMargin() {
    if (this.isVerde) {
      // 搜索框高度56 + 间距8
      return '64vp';
    } else if (this.isVerdeModel || this.isFromMeetime || DisplaySplitUtil.isFixedTitleBar(this.splitStatus)) {
      // 状态栏高度38 + 标题栏mini模式高度56 + 搜索框高度56 + 间距8
      return '158vp';
    }
    // 状态栏高度38 + 标题栏FULL模式高度112 + 搜索框高度56 + 间距8
    return '214vp';
  }

  private isNeedAutoCollapse() {
    if (this.isVerde) {
      return true;
    }
    if (this.splitStatus === SplitStatus.TWO_THREE_SPLIT) {
      return true;
    }
    if (this.isShowSmartWindow) {
      return true;
    }
    return false;
  }

  // 联系人列表
  @Builder
  ContactListBuilder() {
    Stack() {
      if ((this.contactListListLen > 0 || this.isContactSearch) && !this.maintenanceMode) {
        ContactContentByRefresh({
          contactListListLen: $contactListListLen,
          navigationMenusOpacity: $navigationMenusOpacity,
          scroller: this.scroller,
          presenter: this.presenter,
          searchOffsetY: this.searchOffsetY,
          searchValueLength: this.searchValueLength,
          alphabetSelected: this.alphabetSelected,
          isAlphabetClicked: this.isAlphabetClicked,
          stages: this.stages,
          isReBindScroll: this.isReBindScroll,
        });
      } else if (this.contactListListLen == 0 || this.maintenanceMode) {
        // ContactEmptyPage();
        ContactEmptyPage()
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
    .layoutWeight(1)
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: {
  //       scrollEffectOpts:
  //       {
  //         enableScrollEffect: true,
  //         scrollEffectType: ScrollEffectType.COMMON_BLUR,
  //       }
  //     },
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     title: { title: this.isFromMeetime ? (this.isMeetimePhone ?
  //       ResourceUtil.getStringByResource($r('app.string.mobile_contacts')) :
  //       ResourceUtil.getStringByResource($r('app.string.system_contacts'))) :
  //       (this.isContactSearch ? '' : ResourceUtil.getStringByResource($r('app.string.contact'))) },
  //     stackBuilder: this.isContactSearch ? this.SearchContact.bind(this) : this.customSearchButton.bind(this),
  //     bottomBuilder: !this.isEmptyContactList && !this.isContactSearch && !this.maintenanceMode && !this.isVerde ?
  //       { builder: this.SearchContact.bind(this) } : undefined
  //   }
  // }

  @Builder
  ShowContactsSettingBuilder() {
    Column() {
      Settings({ total: this.mContactPresenter.total })
    }.height('100%').width('100%')
  }

  @Builder
  TitleGuide() {
    Row() {
      if (this.isPC && !this.showSideBar) {
        SideBarButton()
      }
      Row() {
        //
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_new_contact')))
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
        .margin({
          end: this.isFromMeetime ? LengthMetrics.vp(0) : LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .id('contactList_contacts_titleGuideClick_btn')
        .onClick(() => {
          HiLog.i(TAG, '点击了新建联系人的加号');
          // 新建联系人打点-联系人列表处
          DotUtil.getInstance().contactDot(this.createContactParams, CONTACT_ADD_EVENT);
          this.isShowAccountants = true;
          emitter.emit(AlphabetIndexerPage.innerEvent);// 发送alphabetIndexer页面的innerEvent
        })
        .visibility(this.isShowJumpButton ? Visibility.None : Visibility.Visible)
        .enabled(!this.isShowPickerMaskLayer)


        if (this.isShowJumpButton) {
          Button() {
            SymbolGlyph($r('sys.symbol.person_2'))
              .fontSize($r('app.float.id_card_image_small'))
              .fontColor([$r('app.color.skin_icon_primary')])
          }
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_open_mobile_contacts')))
          .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .stateEffect(true)
          .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
          .id('contactList_contacts_jumpToCSP_btn')

          .onClick(() => {

            if (this.uiExtensionSession != undefined) {
              HiLog.w(TAG, 'jumpTo-CSP-ContactList sendJumpToCSPMsg');
              this.mContactPresenter.sendMsgToMeetime(this.uiExtensionSession, 'jumpToCSP');
            }
          })
          .enabled(!this.isShowPickerMaskLayer)
        }
//联系人更多列表
        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_more')))
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(this.isPC ? Color.Transparent :
          this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') :
            $r('sys.color.comp_background_tertiary'))
        .bindMenu(this.MenuBuilder, {
          placement: Placement.BottomRight,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
        })
        .onClick(() => {
          // 联系人打点--点击联系人列表更多
          DotUtil.getInstance().contactDot(this.customizedParams, CLICK_CONTACT_SETTINGS);
        })
        .id('contactList_contacts_more_btn')
        .visibility(this.isFromMeetime ? Visibility.None : Visibility.Visible)
        .enabled(!this.isShowPickerMaskLayer)
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .height($r('app.float.id_item_height_large'))
      .opacity(this.navigationMenusOpacity)
      .padding({
        end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) :
          LengthMetrics.resource(this.spaceLR)
      })
      .margin({ end: this.isMeetimePC ? LengthMetrics.vp(128) : undefined })
    }
    .visibility(this.isContactSearch || this.isVerde ? Visibility.None : Visibility.Visible)
    .width('100%')
    .justifyContent(this.isPC && !this.showSideBar ? FlexAlign.SpaceBetween : FlexAlign.End)
    .margin({
      left: this.isPC ? $r('sys.float.padding_level8') : 0,
    })
    .padding({
      start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) : LengthMetrics.vp(0)
    })
  }

  @Builder
  MeetimeTitle() {
    Row() {
      ArrowBack({
        isTransition: false,
        onBackButtonClick: () => {
          if (this.uiExtensionSession != undefined) {
            HiLog.w(TAG, 'BackTo-ContactList sendBackMsg');
            this.mContactPresenter.sendMsgToMeetime(this.uiExtensionSession, 'notifyHostBackPress');
          }
        }
      }).visibility(this.isMeetimeNeedSplit ? Visibility.None : Visibility.Visible)

      Text(this.isMeetimePhone ? $r('app.string.mobile_contacts') : $r('app.string.system_contacts'))
        .fontSize(this.isMeetimeNeedSplit ? '24vp' : '20vp')
        .fontWeight(FontWeight.Bold)
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.font_primary'))
        .margin({
          start: this.isMeetimePC ? LengthMetrics.resource($r('app.float.id_card_margin_max')) :
                 this.isMeetimeNeedSplit ? LengthMetrics.resource($r('app.float.id_card_margin_xxl')) :
                 LengthMetrics.resource($r('app.float.id_card_margin_large'))
        })
    }
    .height($r('app.float.id_height_56'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  // 标题栏
  @Builder
  VerdeTitleGuide() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .type(ButtonType.Circle)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      .id('contactList_contacts_VerdeTitleGuideClick_btn')
      .onClick(() => {
        console.log('magnifyingglass666')
        HiLog.i(TAG, 'magnifyingglass onClick');
        this.isContactSearch = true;//搜索框
        emitter.emit(AlphabetIndexerPage.innerEvent);//跳转
        setTimeout(() => {
          focusControl.requestFocus('contactList_contacts_valueChange_search');
        }, 10)//搜索框获取焦点
      })
      .visibility(this.contactListListLen === 0 ? Visibility.None : Visibility.Visible)
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.search_button')))
      .enabled(!this.isShowPickerMaskLayer)
    }
    .width(this.isPC ? '100%' : '50%')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .margin({ right: this.spaceLR })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.group')})
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
        .id('contactList_contacts_group_menuItem')
        .onClick(() => {
          // 联系人打点--联系人列表点击群组
          DotUtil.getInstance().contactDot(this.customizedParams, GROUP_CLICK_EVENT);
          this.selectContactId = '';
          this.mContactPresenter.toGroupList(this.curBp !== 'sm');
          ContextMenu.close();
        })
      if (!this.isPC) {
        this.MenuDivider()
      }
      MenuItem({ content: $r('app.string.call_setting_type_setting') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('contactList_contacts_set_menuItem')
        .margin({
          top: this.isPC ? $r('sys.float.padding_level1') : 0
        })
        .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
        .onClick(() => {
          // 联系人打点--联系人列表点击更多点击设置
          DotUtil.getInstance().contactDot(this.settingsParams, SETTINGS_EVENT);
          // 更改联系人设置页面为模态窗口加载
          this.isShowContactsSettings = true;
          ContextMenu.close();
        })
    }
    .width(224)
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
    .radius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
  }

  @Builder
  AutoMergeBuilder() {
    Scroll(){
      Column() {
        Text($r('app.plural.auto_merge_msg', this.mContactPresenter.repeatNum, this.mContactPresenter.repeatNum))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_primary'))
          .textAlign(TextAlign.Start)
          .width('100%')
        Text($r('app.string.auto_merge_submsg'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_secondary'))
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
  }
}

@Concurrent
export async function initFusionSearchService(): Promise<number> {
  // 拉起全搜服务，需要使用新的方式了，原来的createService过期了，不能用了
  // let searchSession: SearchClient.SearchSession = await SearchClient.beginSearch([]);
  return 0;
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

// @Builder
// function hdsMenuBuilder(params: ParamsInterface) {
//   Menu() {
//     MenuItem({ content: $r('app.string.group')+'2' })
//       .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
//       .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
//       .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
//       .id('contactList_contacts_group_menuItem')
//       .onClick(() => {
//         params.groupFunction();
//       })
//     if (!EnvironmentProp.isPC()) {
//       menuDivider()
//     }
//     MenuItem({ content: $r('app.string.call_setting_type_setting') })
//       .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
//       .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
//       .id('contactList_contacts_setting_menuItem')
//       .margin({
//         top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
//       })
//       .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
//       .onClick(() => {
//         params.setFunction();
//       })
//     if (!EnvironmentProp.isPC()) {
//       menuDivider()
//     }
//     MenuItem({ content: $r('app.string.Help_and_feedback') })
//       .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
//       .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
//       .id('contactList_contacts_setting_menuItem')
//       .margin({
//         top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
//       })
//       .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
//       .onClick(() => {
//         params.jumpToFeedbackMenu();
//       })
//   }
//   .width(224)
//   .backgroundBlurStyle(EnvironmentProp.isPC() ? BlurStyle.COMPONENT_REGULAR : undefined)
//   .shadow({
//     radius: EnvironmentProp.isPC() ? $r('sys.float.ohos_id_default_shadow_s') : 0
//   })
//   .radius(EnvironmentProp.isPC()? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
// }





