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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import ContactDetail from './contacts/details/ContactDetail';
import Accountants, { AccountantTitleClass, NavDestinationHeaderView } from './contacts/accountants/Accountants';
import ContactsPickerPage, { PickerTitleView } from './contacts/batchselectcontacts/ContactsPickerPage';
import ContactList from './contacts/ContactList';
import IndexPresenter from '../../ets/presenter/IndexPresenter';
import { removeSettingModeListener } from '../../ets/model/CallSharingModel';
import EnvironmentProp from '../../ets/feature/EnvironmentProp';
import { CallSharingClass } from '../../ets/card/data/commonData';
import { UiExtentionParam,
  URL_TYPE_BATCH_SELECT_CONTACT,
  URL_TYPE_CONTACT_DETAIL,
  URL_TYPE_CONTACT_LIST,
} from '../uiExtentionAbility/ContactUiExtentionAbility';
import {
  ContactsGlobalThisHelper
} from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BusinessError, emitter, osAccount, } from '@kit.BasicServicesKit';
import { contact } from '@kit.ContactsKit';
import AccessibilityUtil from '../util/AccessibilityUtil';
import mediaquery from '@ohos.mediaquery';
import { removeAirPlaneModeListener } from '../model/AirplaneModel';
import ContactListPresenter from '../presenter/contact/ContactListPresenter';
import EmitterConstant from '../data/EmitterConstant';
// import { PickerMaskLayer } from '@hw-hmos/pickersheet';
// import appLock from '@hms.security.appLock';
import { Constants } from '../data/Constants';
import ContactsPickerPresenter from '../presenter/contact/batchselectcontacts/ContactsPickerPresenter';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit'

const TAG = 'ContactUiExtentionIndex';

/**
 * Contact list Entry
 */
let storage = LocalStorage.getShared()

@Entry(storage)
@Component
export default struct ContactUiExtentionIndex {

  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private isPC: boolean = EnvironmentProp.isPC();
  private uiExtentionParam = ContactsGlobalThisHelper.GetGlobalThis()
    .getValue<UiExtentionParam>(ContactsGlobalThisHelper.UiExtentionAbilityParams);
  private mPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getInstance();
  @StorageLink('isShowBindSheet') isShowBindSheet: boolean = false;
  @State isPageReady : boolean = false;
  @StorageLink('isShowPickerMaskLayer') isShowPickerMaskLayer: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isGettingPickerData') isGettingPickerData: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('isFromSaveContactPicker') isFromSaveContactPicker: boolean = false;
  @StorageProp('isSaveExistContact') isSaveExistContact: boolean = false;
  @StorageProp('isPickerSearch') isSearching: boolean = false;
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  @StorageProp('accountantTitleClass') accountantTitleClass: AccountantTitleClass = new AccountantTitleClass();
  @StorageProp('contactFromPicker') contactFromPicker: contact.Contact = {
    id: 0,
    key: '',
    emails: [],
    events: [],
    groups: [],
    imAddresses: [],
    phoneNumbers: [],
    portrait: {
      uri: ''
    },
    postalAddresses: [],
    relations: [],
    websites: [],
    name: {
      fullName: ''
    },
    note: {
      noteContent: ''
    },
    organization: {
      name: ''
    }
  };
  @StorageProp('meetimeCurBp') meetimeCurBp: string = 'sm';
  listener = mediaquery.matchMediaSync('(orientation: landscape)');
  mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  mContactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();

  @Builder
  myRouter(name: string) {
    if (name === 'Accountants') {
      Accountants({ isShowAccountants: $isShowBindSheet });
    } else if (name === 'ContactDetail') {
      ContactDetail();
    } else if (name === 'BatchSelectContactsPage') {
      ContactsPickerPage();
    } else if (name === 'SingleSelectContactPage') {
      ContactsPickerPage({ isContactMultiSelect: false });
    }
  }

  aboutToAppear() {
    HiLog.w(TAG, `aboutToAppear! isPC: ${this.isPC}`);
    try {
      // 畅连拉起联系人列表页
      if (this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_LIST ||
        this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_DETAIL) {
        // 监听屏幕是否横屏显示
        this.listener.on('change', (mediaQueryResult) => {
          let spaceLR: Resource = $r('sys.float.padding_level8');
          let isPortraitDisplay: boolean = false;
          if (!mediaQueryResult.matches) {
            // 是竖屏情况下
            isPortraitDisplay = true;
          }
          if (!isPortraitDisplay && this.meetimeCurBp !== 'sm') {
            spaceLR = $r('sys.float.padding_level12');
          }
          AppStorage.setOrCreate('spaceLR', spaceLR);
          AppStorage.setOrCreate('isTabletLandscape', !isPortraitDisplay && this.meetimeCurBp !== 'sm');
        })
        this.mIndexPresenter.initAirPlaneMode();
        if (EnvironmentProp.isTabletOrPC()) {
          this.mIndexPresenter.initCallPhoneSharingMode();
          this.mIndexPresenter.initDistributedModemState();
          this.mIndexPresenter.initCallSMSSharingMode();
        } else {
          this.mIndexPresenter.isOnCallSharing();
        }
      }

      // PC上没有应用锁
      if (!this.isPC) {
        // 暂时绕过应用锁相关逻辑，待后续完善
        this.isPageReady = true;
        // osAccount.getAccountManager().getOsAccountLocalId().then((localId) => {
        //   HiLog.w(TAG, `getOsAccountLocalId localId: ${localId}`);
        //   appLock.isAppProtected(Constants.CONTACT_BUNDLE_NAME, { userId: localId }).then((isShowPickerMaskLayer) => {
        //     this.isShowPickerMaskLayer = isShowPickerMaskLayer
        //     HiLog.w(TAG, `isAppProtected isShowPickerMaskLayer: ${this.isShowPickerMaskLayer}`);
        //   }).catch((err: BusinessError) => {
        //     HiLog.e(TAG, `isAppProtected error: ${err?.message}`);
        //   }).finally(() => {
        //     this.isPageReady = true;
        //   })
        //
        //   appLock.on('appProtectedStateChange', (appProtectedStates) => {
        //     appProtectedStates.forEach((appProtectedState) => {
        //       if (appProtectedState.appInfo.bundleName === Constants.CONTACT_BUNDLE_NAME &&
        //         appProtectedState.userId === localId) {
        //         this.isShowPickerMaskLayer = appProtectedState.isProtected;
        //         HiLog.w(TAG, `appProtectedStateChange isShowPickerMaskLayer: ${this.isShowPickerMaskLayer}`);
        //       }
        //     })
        //   })
        // }).catch((err: BusinessError) => {
        //   HiLog.e(TAG, `getOsAccountLocalId error: ${err?.message}`);
        // });
      } else {
        this.isPageReady = true;
      }
    } catch (err) {
      HiLog.e(TAG, `aboutToAppear error: ${err?.message}`);
      this.isPageReady = true;
    }
  }

  onPageShow(): void {
    HiLog.i(TAG, 'onPageShow')
    setTimeout(() => {
      HiLog.i(TAG, 'show bind sheet')
      this.isShowBindSheet = true;
    }, 100)
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageCover')
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    if (this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_LIST ||
      this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_DETAIL) {
      removeSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING);
      removeSettingModeListener(CallSharingClass.DISTRIBUTED_MODEM_STATE);
      removeSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING);
      this.listener?.off('change');
      removeAirPlaneModeListener();
    }
  }

  private getNavigationMode(): NavigationMode {
    let navigationMode: NavigationMode = NavigationMode.Auto;
    if (this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_LIST ||
      this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_DETAIL || this.uiExtentionParam?.isContactsPicker) {
      navigationMode = NavigationMode.Stack;
    }
    return navigationMode;
  }

  @Builder
  ShowContactsPickerPageView() {
    Stack() {
      ContactsPickerPage({ isContactMultiSelect: this.uiExtentionParam?.isContactMultiSelect })
        .hitTestBehavior(this.isGettingPickerData ? HitTestMode.Block : HitTestMode.Default)
    }
    .width('100%').height('100%')
  }

  @Builder
  ShowSaveContactsPickerPageView() {
    Stack() {
      Accountants({ isShowAccountants: $isShowBindSheet, params: {
        editContact: 0,
        callId: '',
        phones: [],
        phoneNumberShow: '',
        newContactData: this.contactFromPicker,
        updataShow: false,
        relationships: [],
        contactId: this.contactFromPicker.id as number,
      } })
        .hitTestBehavior(this.isGettingPickerData ? HitTestMode.Block : HitTestMode.Default)

      // 新建联系人picker 应用锁
      if (this.isShowPickerMaskLayer) {
        // PickerMaskLayer({
        //   onclose: () => {
        //     HiLog.w(TAG, `PickerMaskLayer onclose`);
        //   },
        //   appInfos: [{ bundleName: Constants.CONTACT_BUNDLE_NAME, appIndex: 0 }],
        //   unlockProxy: true,
        //   maskShow: this.isShowPickerMaskLayer
        // })
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  ShowAccountantsView() {
    Column() {
      Accountants({ isShowAccountants: $isShowAccountants })
    }.width('100%').height('100%')
  }


  build() {
    Stack() {
     Navigation(this.pathInfos) {
        // UEC方式加载联系人页面
        if (!this.uiExtentionParam.isContactsPicker && this.isPageReady) {
          Flex({ direction: FlexDirection.Column }) {
            if (this.uiExtentionParam?.urlType == URL_TYPE_BATCH_SELECT_CONTACT) {
              Stack() {
                ContactsPickerPage({ isContactMultiSelect: this.uiExtentionParam?.isContactMultiSelect })
              }
            } else if (this.uiExtentionParam?.urlType == URL_TYPE_CONTACT_LIST) {
              // ContactList();
            } else if (this.uiExtentionParam?.urlType === URL_TYPE_CONTACT_DETAIL) {
              ContactDetail();
            }
          }
        }
      }
      .mode(NavigationMode.Stack)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .navDestination(this.myRouter)
      .bindSheet(this.isShowBindSheet && this.uiExtentionParam.isContactsPicker && !this.isFromSaveContactPicker,
        this.ShowContactsPickerPageView(), {
          dragBar: false,
          showClose: false,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_background_secondary') : undefined,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            HiLog.w(TAG, `shouldDismiss, isGettingPickerData: ${this.isGettingPickerData
            }, isSaveExistContact: ${this.isSaveExistContact}`);
            if (!this.isGettingPickerData) {
              this.isShowBindSheet = false;
              if (this.isSaveExistContact) {
                ContactsGlobalThisHelper.GetGlobalThis()
                  .getDefaultUIContext()?.terminateSelfWithResult({ resultCode: 1 })
                  .then(() => {
                    HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded ');
                  })
                  .catch((error: BusinessError) => {
                    HiLog.e(TAG, `Operation failed. Cause: ${error?.message}`);
                  });
              } else {
                this.isShowBindSheet = false;
                setTimeout(() => {
                  // 选择联系人Picker，侧滑返回，返回默认选中的数据
                  this.mPresenter.returnDefaultSelectContactData();
                }, 100);
              }
            }
          },
          onWillSpringBackWhenDismiss: () => {
            // 如果注册该回调函数，则不会回弹，由开发者控制下滑关闭时是否回弹。
            // 在回调函数中可以通过调用springBack来实现回弹效果。
          }
        })


      // 新建联系人Picker 半模态
      Column() {
      }.backgroundColor('#0000000')
      .height(0).width(0).zIndex(0)
      .bindSheet(this.isShowBindSheet && this.uiExtentionParam.isContactsPicker && this.isFromSaveContactPicker,
        this.ShowSaveContactsPickerPageView(), {
          title: NavDestinationHeaderView({
            isThemeActive: this.accountantTitleClass.isThemeActive,
            isOpenAccessibility: this.accountantTitleClass.isOpenAccessibility,
            fontSizeScale: this.accountantTitleClass.fontSizeScale,
            pageTitle: this.accountantTitleClass.pageTitle,
            isSave: this.accountantTitleClass.isSave && !this.isShowPickerMaskLayer,
            cancelOnClick: this.accountantTitleClass.cancelOnClick,
            savelOnClick: this.accountantTitleClass.savelOnClick,
          }),
          dragBar: true,
          showClose: false,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_background_secondary') : undefined,
          preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            HiLog.i(TAG, 'save picker shouldDismiss')
            if (!this.isGettingPickerData) {
              HiLog.i(TAG, 'save picker shouldDismiss, is not get picker data')
              ContactsGlobalThisHelper.GetGlobalThis()
                .getDefaultUIContext()?.terminateSelfWithResult({ resultCode: 1 })
                .then(() => {
                  HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded ');
                })
                .catch((error: BusinessError) => {
                  HiLog.e(TAG, `Operation failed. Cause: ${error?.message}`);
                });
            }
          },
          onWillSpringBackWhenDismiss: () => {
            // 如果注册该回调函数，则不会回弹，由开发者控制下滑关闭时是否回弹。
            // 在回调函数中可以通过调用springBack来实现回弹效果。
          }
        })


      // 新建联系人 半模态，保存至已有联系人picker 会拉起
      Column() {
      }.backgroundColor('#0000000')
      .height(0).width(0).zIndex(0)
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
    }
  }
}