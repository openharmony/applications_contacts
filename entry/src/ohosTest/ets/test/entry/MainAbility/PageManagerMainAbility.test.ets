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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium';
import PageManager from '../../../../../main/ets/MainAbility/PageManager';
import { DTGlobalContext } from '../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import Constants from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { paramsInterface } from '../../../../../main/ets/model/type';
import { targetPageClass } from '../../../../../main/ets/model/type/ContactParams';
import StartOptions from '@ohos.app.ability.StartOptions';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import { ContactRepository } from '../../../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { missedCallManager } from '../../../../../main/ets/feature/missedCall/MissedCallManager';
import { MissedCallNotifyData } from '../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import { DialogControllerManager } from '../../../../../main/ets/MainAbility/ControllerManager';
import { call } from '@kit.TelephonyKit';
import IndexPresenter from '../../../../../main/ets/presenter/IndexPresenter';

export default function PageManagerMainAbilityTest() {
  const TAG = 'PageManager';
  const SHARE_VCARD_BUNDLE_NAME = 'com.ohos.instantshare'
  const SHARE_VCARD_APP_ID = '5765880207852903673'
  const MY_APP_BUNDLE_NAME = 'com.example.myapplication'

  describe('PageManagerMainAbilityTest', () => {

    let pageManager: PageManager;

    beforeEach(() => {
      AppStorage.clear();
      let context = DTGlobalContext.getContext().getObject("contactContext") as common.UIAbilityContext;
      pageManager = new PageManager(context);
    })

    it('PageManagerMainAbilityTest_onCreate', 0, () => {
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let onRequest: Function = mocker.mockFunc(pageManager, pageManager.onRequest);
      let result = false;
      when(onRequest)(want.parameters as Record<string, Object>).afterAction(() => {
        result = true;
      });
      pageManager.onCreate(want);
      expect(result).assertTrue();

      mocker.clear(pageManager);
    });

    it('PageManagerMainAbilityTest_onNewWant', 0, () => {
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let onRequest: Function = mocker.mockFunc(pageManager, pageManager.onRequest);
      let result = false;
      when(onRequest)(want.parameters as Record<string, Object>).afterAction(() => {
        result = true;
      });
      pageManager.onNewWant(want);
      expect(result).assertTrue();

      mocker.clear(pageManager);
    });

    it('PageManagerMainAbilityTest_onDestroy', 0, () => {
      pageManager.onDestroy();
      expect(pageManager.mainUrl).assertEqual('pages/index')
    });
    //urlName = 'pages/index'
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_dialer', 0, () => {
      pageManager.mainUrl = 'pages/';
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_dialer',
        'contactId': '0',
        'ohos.aafwk.param.callerBundleName': 'com.ohos.contacts',
        'isNoMissFormCard': 'true'
      }
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let result1 = false;
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)().afterAction(() => {
        result1 = true;
      });
      pageManager.onRequest(parameters, want, false);
      expect(result1).assertTrue();

      mocker.clear(missedCallManager);
    });
    it('PageManagerMainAbilityTest_onRequest_went_action_if', 0, () => {
      let parameters: Record<string, Object> = {
        'ohos.aafwk.param.callerBundleName': SHARE_VCARD_BUNDLE_NAME,
        'ohos.aafwk.param.callerAppIdentifier': SHARE_VCARD_APP_ID
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        action: 'ohos.want.action.viewData'
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(pageManager, pageManager.importVcardFromWant);
      pageManager.onRequest(parameters, want, false);
      mocker.verify('importVcardFromWant', [want]).once();
      mocker.clear(pageManager);
    });
    it('PageManagerMainAbilityTest_onRequest_went_action_else', 0, () => {
      let parameters: Record<string, Object> = {
        'ohos.aafwk.param.callerBundleName': MY_APP_BUNDLE_NAME
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        action: 'ohos.want.action.viewData'
      } as Want;
      pageManager.onRequest(parameters, want, false);
      let isContactSearch: boolean = AppStorage.get('isContactSearch') ?? true;
      expect(isContactSearch).assertFalse();
    });
    it('PageManagerMainAbilityTest_onRequest_page_flag_contacts_list', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_contacts_list',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    it('PageManagerMainAbilityTest_onRequest_harassment_filter', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'harassment_filter',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    it('PageManagerMainAbilityTest_onRequest_page_contact_privacy_statement', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_contact_privacy_statement',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(AppStorage.get('isFromExternalApp')).assertEqual(true);
    });
    //urlName = 'pages/index'
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_choose_contacts', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_choose_contacts',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    //urlName = 'ContactDetail'
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_contact_details_contactId_1', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_contact_details',
        'contactId': '1',
        'isFormCard': 'true'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        sourceHasId: true,
        contactId: parameters.contactId,
        pageFlag: parameters.pageFlag.toString()
      }
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    //urlName = 'ContactDetail'
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_contact_details_no_contactId', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_contact_details',
        'phoneNumber': '570977632'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        sourceHasPhone: true,
        phoneNumberShow: parameters.phoneNumber,
        fromSmsList: true,
        sourceHasParam: true
      }
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    //urlName = 'pages/index'
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_edit_before_calling', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_edit_before_calling',
        'phoneNumber': '950800'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(AppStorage.get(Constants.storage.teleNumber)).assertEqual(parameters.phoneNumber);

      let parameters1: Record<string, Object> = {
        'pageFlag': 'page_flag_edit_before_calling',
        'phoneNumber': ''
      };
      pageManager.onRequest(parameters1, want, false);
      expect(AppStorage.get(Constants.storage.teleNumber)).assertEqual('');
    });
    //urlName = 'Accountants';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_save_contact', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_save_contact',
        'phoneNumber': '570977632'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        phoneNumbers: [
          {
            'phoneNumber': parameters.phoneNumber?.toString().replace(new RegExp('[^0123456789+]*', 'g'), '')
          }
        ],
        disPlayName: parameters.contactName,
        sourceHasParam: true,
      };
      let urlName = 'Accountants';
      let pageIndex = 3;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    //urlName = 'Accountants';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_save_contact_no_phoneNum', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_save_contact',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        phoneNumbers: [
          {
            'phoneNumber': parameters.phoneNumber?.toString().replace(new RegExp('[^0123456789+]*', 'g'), '')
          }
        ],
        disPlayName: parameters.contactName,
        sourceHasParam: true,
      };
      let urlName = 'Accountants';
      let pageIndex = 3;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });
    //urlName = 'selectContactsList';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_save_exist_contact', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_save_exist_contact',
        'phoneNumber': '570977632'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        phoneNumberShow: parameters.phoneNumber,
        isSaveExistContact: true,
        isDisplayByName: true
      };
      let urlName = 'SingleSelectContactPage';
      let pageIndex = 4;
      pageManager.onRequest(parameters, want, false);
      expect(JSON.stringify(AppStorage.get(Constants.storage.targetPage)))
        .assertEqual(JSON.stringify(new targetPageClass(urlName, pageIndex, params)));
    });
    //urlName = 'BatchSelectContactsPage';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_sms_forward', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_sms_forward',
        'phoneNumber': '570977632'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        selectType: 1
      };
      let urlName = 'BatchSelectContactsPage';
      let pageIndex = 4;
      pageManager.onRequest(parameters, want, false);
      expect(JSON.stringify(AppStorage.get(Constants.storage.targetPage)))
        .assertEqual(JSON.stringify(new targetPageClass(urlName, pageIndex, params)));
    });
    //urlName = 'BatchSelectContactsPage';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_multi_choose', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_multi_choose',
        'phoneNumber': '570977632',
        'contactCount': 1,
        'isLimit': false,
        'isNotShowTab': false
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        selectType: 0,
        isLimit: parameters.isLimit,
        contactCount: parameters.contactCount,
        isNotShowTab:false,
        isCardEntry:false
      };
      let urlName = 'BatchSelectContactsPage';
      let pageIndex = 4;
      pageManager.onRequest(parameters, want, false);

      expect(JSON.stringify(AppStorage.get(Constants.storage.targetPage)))
        .assertEqual(JSON.stringify(new targetPageClass(urlName, pageIndex, params)));
    });
    //urlName = 'BatchSelectContactsPage';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_multi_choose_noIsNotShowTab', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_multi_choose',
        'phoneNumber': '570977632',
        'contactCount': 1,
        'isLimit': false
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        selectType: 0,
        isLimit: parameters.isLimit,
        contactCount: parameters.contactCount,
        isNotShowTab:false,
        isCardEntry:false
      };
      let urlName = 'BatchSelectContactsPage';
      let pageIndex = 4;
      pageManager.onRequest(parameters, want, false);
      expect(JSON.stringify(AppStorage.get(Constants.storage.targetPage)))
        .assertEqual(JSON.stringify(new targetPageClass(urlName, pageIndex, params)));
    });
    //urlName = 'SingleSelectContactPage';
    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_page_flag_single_choose', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'page_flag_single_choose'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {
        selectType: 0
      };
      let urlName = 'SingleSelectContactPage';
      let pageIndex = 4;
      pageManager.onRequest(parameters, want, false);
      expect(JSON.stringify(AppStorage.get(Constants.storage.targetPage)))
        .assertEqual(JSON.stringify(new targetPageClass(urlName, pageIndex, params)));
    });

    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_default_isOnCreate_true', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'xx',
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let params: paramsInterface = {};
      let mocker: MockKit = new MockKit();
      let result = false;
      let set = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      when(set)(ContactsGlobalThisHelper.IndexPresenterName).afterAction(() => {
        result = true;
      });
      let result1 = false;
      let requestItem = mocker.mockFunc(pageManager, pageManager.requestItem);
      when(requestItem)().afterAction(() => {
        result1 = true;
      });
      pageManager.onRequest(parameters, want, true);
      // expect(result).assertTrue();
      expect(result1).assertTrue();
      expect(JSON.stringify(AppStorage.get('params'))).assertEqual(JSON.stringify(params));
      expect(pageManager.mainUrl).assertEqual('pages/index');

      mocker.clear(pageManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_default_isOnCreate_false', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'xx'
      };
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
    });

    it('PageManagerMainAbilityTest_onRequest_if1_pageFlag_null', 0, () => {
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        uri: ''
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DialogControllerManager.getInstance(), DialogControllerManager.getInstance().closeAll);
      pageManager.onRequest(parameters, want, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');
      mocker.clear(DialogControllerManager.getInstance());

      let want1: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        uri: 'content://com.ohos.contacts.MainAbility/page_flag_save_contact'
      } as Want;
      pageManager.onRequest(parameters, want1, false);
      expect(pageManager.mainUrl).assertEqual('pages/index');

      let want2: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        uri: 'content://com.ohos.contacts.MainAbility/contact_list'
      } as Want;
      pageManager.onRequest(parameters, want2, false);
      expect(AppStorage.get(Constants.storage.mainTabsIndex)).assertEqual(IndexPresenter.getInstance().contactIndex);
    });

    it('PageManagerMainAbilityTest_onRequest_elseif_isOnCreate_true', 0, () => {
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        uri: 'content://com.ohos.contacts.MainAbility/page_flag_single_choose'
      } as Want;
      let mocker: MockKit = new MockKit();
      let result1 = false;
      let requestItem = mocker.mockFunc(pageManager, pageManager.requestItem);
      when(requestItem)().afterAction(() => {
        result1 = true;
      });
      let params: paramsInterface = {
        selectType: 0
      };
      pageManager.onRequest(parameters, want, true);
      expect(result1).assertTrue();
      expect(JSON.stringify(AppStorage.get('params'))).assertEqual(JSON.stringify(params));
      expect(pageManager.mainUrl).assertEqual('pages/contacts/batchselectcontacts/SingleSelectContactsEntry');

      mocker.clear(pageManager);
    });

    it('PageManagerMainAbilityTest_onRequest_elseif2_isOnCreate_true', 0, () => {
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
        uri: 'tel:570977632'
      } as Want;
      let mocker: MockKit = new MockKit();
      let result = false;
      let set = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      when(set)(ContactsGlobalThisHelper.IndexPresenterName).afterAction(() => {
        result = true;
      });
      let result1 = false;
      let requestItem = mocker.mockFunc(pageManager, pageManager.requestItem);
      when(requestItem)().afterAction(() => {
        result1 = true;
      });
      let phoneNumber = decodeURIComponent(want.uri as string).replace(new RegExp('^tel\:'), '');
      let params: paramsInterface = {
        mainTabsIndex: 0,
        teleNumber: phoneNumber
      };
      pageManager.onRequest(parameters, want, true);
      // expect(result).assertTrue();
      expect(result1).assertTrue();
      expect(AppStorage.get(Constants.storage.teleNumber)).assertEqual(phoneNumber);
      expect(JSON.stringify(AppStorage.get('params'))).assertEqual(JSON.stringify(params));
      expect(pageManager.mainUrl).assertEqual('pages/index');

      mocker.clear(pageManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('PageManagerMainAbilityTest_onRequest_if1_else_isOnCreate_false', 0, () => {
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let result = false;
      let requestMissedCallAction = mocker.mockFunc(pageManager, pageManager.requestMissedCallAction);
      when(requestMissedCallAction)(parameters['action']).afterAction(() => {
        result = true;
      });
      let result1 = false;
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)().afterAction(() => {
        result1 = true;
      });
      mocker.mockFunc(DialogControllerManager.getInstance(), DialogControllerManager.getInstance().closeAll);
      mocker.mockFunc(pageManager, pageManager.requestItem);
      pageManager.onRequest(parameters, want, false);
      expect(result).assertTrue();
      expect(result1).assertTrue();

      mocker.clear(pageManager);
      mocker.clear(DialogControllerManager.getInstance());
    });

    it('PageManagerMainAbilityTest_onRequest_else_isOnCreate_true', 0, () => {
      AppStorage.setOrCreate('mainTabsIndex', 0);
      AppStorage.set('isVerde', false);
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let result = false;
      let requestMissedCallAction = mocker.mockFunc(pageManager, pageManager.requestMissedCallAction);
      when(requestMissedCallAction)(parameters['action']).afterAction(() => {
        result = true;
      });
      let result1 = false;
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)().afterAction(() => {
        result1 = true;
      });
      let result2 = false;
      let set = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      when(set)(ContactsGlobalThisHelper.IndexPresenterName).afterAction(() => {
        result2 = true;
      });
      let result3 = false;
      let requestItem = mocker.mockFunc(pageManager, pageManager.requestItem);
      when(requestItem)().afterAction(() => {
        result3 = true;
      });
      let params: paramsInterface = {mainTabsIndex: 0};
      parameters.pageFlag = 'page_flag_edit_before_calling';
      pageManager.onRequest(parameters, want, true);
      expect(JSON.stringify(AppStorage.get('params'))).assertEqual(JSON.stringify(params));
      expect(pageManager.mainUrl).assertEqual('pages/index');
      //expect(result2).assertTrue();
      expect(result3).assertTrue();

      mocker.clear(pageManager);
      mocker.clear(missedCallManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('PageManagerMainAbilityTest_onRequest_else_isOnCreate_false', 0, () => {
      let parameters: Record<string, Object> = {};
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let result = false;
      let requestMissedCallAction = mocker.mockFunc(pageManager, pageManager.requestMissedCallAction);
      when(requestMissedCallAction)(parameters['action']).afterAction(() => {
        result = true;
      });
      mocker.mockFunc(DialogControllerManager.getInstance(), DialogControllerManager.getInstance().closeAll);
      pageManager.onRequest(parameters, want, false);
      expect(result).assertTrue();

      mocker.clear(pageManager);
      mocker.clear(DialogControllerManager.getInstance());
    });

    it('PageManagerMainAbilityTest_requestMissedCallAction_if1_noIf2', 0, () => {
      let action = 'notification.event.message';
      let mocker: MockKit = new MockKit();
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)(null).afterAction(() => {
      });
      pageManager.requestMissedCallAction(action);
      mocker.verify('cancelNotification', [null]).times(0);

      mocker.clear(missedCallManager);
    });

    it('PageManagerMainAbilityTest_requestMissedCallAction_if1_if2_hasPhone', 0, () => {
      let action = 'notification.event.message';
      let data: MissedCallNotifyData = new MissedCallNotifyData(1, 'displayName', '570977632');
      let mocker: MockKit = new MockKit();
      let result = false;
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)(data).afterAction(() => {
        result = true;
      });
      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions) => new Promise<void>(resolve => resolve())
      } as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      pageManager.requestMissedCallAction(action, data);

      expect(result).assertTrue();

      mocker.clear(missedCallManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('PageManagerMainAbilityTest_requestMissedCallAction_if1_if2_noPhone', 0, () => {
      let action = 'notification.event.message';
      let data: MissedCallNotifyData = new MissedCallNotifyData();
      let mocker: MockKit = new MockKit();
      let result = false;
      let cancelNotification = mocker.mockFunc(missedCallManager, missedCallManager.cancelNotification);
      when(cancelNotification)(data).afterAction(() => {
        result = true;
      });
      pageManager.requestMissedCallAction(action, data);
      expect(result).assertTrue();

      mocker.clear(missedCallManager);

    });

    it('PageManagerMainAbilityTest_requestItem_result_empty', 0, () => {
      let mocker: MockKit = new MockKit();
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterThrow('error');
      pageManager.requestItem();
      expect(JSON.stringify(AppStorage.get('contactListUpdated'))).assertUndefined();

      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('PageManagerMainAbilityTest_requestItem', 0, () => {
      let mocker: MockKit = new MockKit();
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      pageManager.requestItem();
      expect(JSON.stringify(AppStorage.get('contactListUpdated'))).assertUndefined();

      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });
  })
}