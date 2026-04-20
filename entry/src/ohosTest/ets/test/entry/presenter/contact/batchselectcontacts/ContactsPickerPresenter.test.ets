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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { ContactPickerListItem,
  ContactPickerParam,
  PickerShowSubData } from '../../../../../../../main/ets/model/type/ContactParams'
import ContactsPickerPresenter
  from '../../../../../../../main/ets/presenter/contact/batchselectcontacts/ContactsPickerPresenter'
import { HashMap } from '@kit.ArkTS'
import DotUtil from '../../../../../../../main/ets/util/DotUtil'
import { contact } from '@kit.ContactsKit'
import { ContactsGlobalThisHelper } from '../../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BusinessError } from '@kit.BasicServicesKit'
import { UiExtentionParam } from '../../../../../../../main/ets/uiExtentionAbility/ContactUiExtentionAbility'
import { common, UIExtensionContentSession } from '@kit.AbilityKit'
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper'
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory'
import { ResourceUtil } from '../../../../../../../main/ets/util/ResourceUtil';

export default function ContactsPickerPresenterTest() {
  describe('ContactsPickerPresenterTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('ContactsPickerPresenterTest_getInstance', 0, () => {
      ContactsPickerPresenter.unInstance();
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      expect(typeof contactsPickerPresenter).assertEqual(typeof ContactsPickerPresenter.getInstance());
    })

    it('ContactsPickerPresenterTest_aboutToAppear_01', 0, () => {
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      let mocker = new MockKit();
      when(mocker.mockFunc(contactsPickerPresenter, contactsPickerPresenter.initContactList))().afterAction(() => {});
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      contactsPickerPresenter.uiExtentionParam = new UiExtentionParam();
      contactsPickerPresenter.aboutToAppear(true);

      mocker.verify('setOrCreate', ['isGettingPickerData', false]).once();
      mocker.clear(AppStorage);
      mocker.clear(contactsPickerPresenter);
    })

    it('ContactsPickerPresenterTest_aboutToAppear_02', 0, () => {
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      let param: ContactPickerParam = {
        isSaveExistContact: false,
        isDisplayByName: false,
        phoneNumberShow: ''
      }
      let mocker = new MockKit();
      when(mocker.mockFunc(contactsPickerPresenter, contactsPickerPresenter.initContactList))().afterAction(() => {});
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      let pathInfos = new NavPathStack();
      pathInfos.pushPathByName('test', param);
      contactsPickerPresenter.initNavPaths(pathInfos);

      contactsPickerPresenter.aboutToAppear(true);
      mocker.verify('setOrCreate', ['isGettingPickerData', false]).once();
      mocker.clear(AppStorage);
      mocker.clear(contactsPickerPresenter);
    })

    it('ContactsPickerPresenterTest_selectAllOnClick', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      ContactsPickerPresenter.getInstance().totalCount = 1;
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let list: ContactPickerListItem[] = [];
      let contactPickerListItem: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list.push(contactPickerListItem);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list;
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      let setString = new Set<string>();
      setString.add(pickerShowSubData.keyValue);
      const selectedContactsMap = new HashMap<number, Set<string>>();
      selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().selectAllOnClick();
      expect(JSON.stringify(ContactsPickerPresenter.getInstance().selectedContactsMap))
        .assertEqual(JSON.stringify(selectedContactsMap));
      mocker.clear(ContactsPickerPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })

    it('ContactsPickerPresenterTest_selectAllOnClick1', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      ContactsPickerPresenter.getInstance().totalCount = 1;
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let list: ContactPickerListItem[] = [];
      let contactPickerListItem: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list.push(contactPickerListItem);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list;
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      let setString = new Set<string>();
      setString.add(pickerShowSubData.keyValue);
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().selectAllOnClick();
      mocker.verify('refreshPageMessage', []).once();
      mocker.clear(ContactsPickerPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })

    it('ContactsPickerPresenterTest_selectAllOnClick_else', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      ContactsPickerPresenter.getInstance().selectedCount = 1;
      ContactsPickerPresenter.getInstance().selectAllOnClick();
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(0);
      mocker.clear(ContactsPickerPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })

    it('ContactsPickerPresenterTest_itemOnClick', 0, () => {
      let contactId: number = 1;
      let subData: string = '';
      ContactsPickerPresenter.getInstance().isSaveExistContact = true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().saveExistContact);
      ContactsPickerPresenter.getInstance().itemOnClick(contactId, subData, 0);
      mocker.verify('saveExistContact', [contactId]).once();

      ContactsPickerPresenter.getInstance().isSaveExistContact = false;
      mocker.mockFunc(ContactsPickerPresenter.getInstance(),
        ContactsPickerPresenter.getInstance().initSelectedDataSource);
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().itemOnMultiClick);
      ContactsPickerPresenter.getInstance().itemOnClick(contactId, subData, 0);
      mocker.verify('itemOnMultiClick', [contactId, subData]).once();
      mocker.clear(ContactsPickerPresenter.getInstance());
    })

    it('ContactsPickerPresenterTest_itemOnClick_false', 0, () => {
      let contactId: number = 1;
      let subData: string = '';
      let dataId: number = 0;
      ContactsPickerPresenter.getInstance().isSaveExistContact = false;
      ContactsPickerPresenter.getInstance().isMultiSelect = false;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsPickerPresenter.getInstance(),
        ContactsPickerPresenter.getInstance().initSelectedDataSource);
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().itemOnSingleClick);
      ContactsPickerPresenter.getInstance().itemOnSingleClick(contactId, subData, 0);
      mocker.verify('itemOnSingleClick', [contactId, subData, dataId]).once();
      mocker.clear(ContactsPickerPresenter.getInstance());
    })

    it('ContactsPickerPresenterTest_itemOnSingleClick', 0, () => {
      ContactsPickerPresenter.getInstance().selectedCount = 1;
      ContactsPickerPresenter.getInstance().itemOnSingleClick(1, '', 1);
      expect(ContactsPickerPresenter.getInstance().URI).assertEqual('content://com.ohos.contacts/data/anco/1');
    })

    it('ContactsPickerPresenterTest_itemOnMultiClick', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let setString = new Set<string>();
      setString.add(pickerShowSubData.keyValue);
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().isDisplayByName = true;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1);
      expect(ContactsPickerPresenter.getInstance().selectedContactsMap.length).assertEqual(0);
    })

    it('ContactsPickerPresenterTest_itemOnMultiClick_else_if', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let setString = new Set<string>();
      setString.add(pickerShowSubData.keyValue);
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().isDisplayByName = false;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1, '123');
      expect(ContactsPickerPresenter.getInstance().selectedContactsMap.length).assertEqual(0);
    })

    it('ContactsPickerPresenterTest_itemOnMultiClick_else_if_01', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let setString = new Set<string>();
      setString.add(pickerShowSubData.keyValue);
      setString.add('111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().isDisplayByName = false;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1, '123');
      expect(ContactsPickerPresenter.getInstance().selectedContactsMap.length).assertEqual(1);
    })

    it('ContactsPickerPresenterTest_itemOnMultiClick_else', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let setString = new Set<string>();
      setString.add('111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().isDisplayByName = false;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1, '123');
      expect(ContactsPickerPresenter.getInstance().selectedContactsMap.length).assertEqual(1);
    })

    it('ContactsPickerPresenterTest_itemOnMultiClick01', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let setString = new Set<string>();
      setString.add('111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(2, setString);
      ContactsPickerPresenter.getInstance().selectedCount = ContactsPickerPresenter.getInstance().selectLimit;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1, '123');
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(10000);

      ContactsPickerPresenter.getInstance().selectedCount = 0;
      ContactsPickerPresenter.getInstance().itemOnMultiClick(1, '123');
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(0);
    })

    it('ContactsPickerPresenterTest_initDefaultSelected', 0, () => {
      let setString = new Set<string>();
      setString.add('111');
      let defaultSelectContactMap = new Map<number, Set<string>>();
      defaultSelectContactMap.set(1, setString);
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let list: ContactPickerListItem[] = [];
      let contactPickerListItem: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list.push(contactPickerListItem);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list;
      ContactsPickerPresenter.getInstance().isMultiSelect = true;
      ContactsPickerPresenter.getInstance().selectedCount = ContactsPickerPresenter.getInstance().selectLimit;
      ContactsPickerPresenter.getInstance().initDefaultSelected(defaultSelectContactMap);
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(10000);

      ContactsPickerPresenter.getInstance().selectedCount = 1;
      ContactsPickerPresenter.getInstance().isMultiSelect = false;
      ContactsPickerPresenter.getInstance().initDefaultSelected(defaultSelectContactMap);
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(1);
    })

    it('ContactsPickerPresenterTest_initDefaultSelected01', 0, () => {
      let setString = new Set<string>();
      let defaultSelectContactMap = new Map<number, Set<string>>();
      defaultSelectContactMap.set(1, setString);
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let list: ContactPickerListItem[] = [];
      let contactPickerListItem: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list.push(contactPickerListItem);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list;
      ContactsPickerPresenter.getInstance().isMultiSelect = false;
      ContactsPickerPresenter.getInstance().selectedCount = 0;
      ContactsPickerPresenter.getInstance().contactIdMap.set(1, list);
      ContactsPickerPresenter.getInstance().selectedContactsMap = new HashMap<number, Set<string>>();
      ContactsPickerPresenter.getInstance().initDefaultSelected(defaultSelectContactMap);
      expect(ContactsPickerPresenter.getInstance().selectedCount).assertEqual(1);

      let pickerShowSubDatas1: PickerShowSubData[] = [];
      let list1: ContactPickerListItem[] = [];
      let contactPickerListItem1: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list1.push(contactPickerListItem1);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list1;
      ContactsPickerPresenter.getInstance().initDefaultSelected(defaultSelectContactMap);
      expect(ContactsPickerPresenter.getInstance().selectedContactsMap.hasKey(1)).assertEqual(true);
    })

    it('ContactsPickerPresenterTest_initSelectedDataSource', 0, () => {
      let pickerShowSubDatas: PickerShowSubData[] = [];
      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      pickerShowSubDatas.push(pickerShowSubData);
      let list: ContactPickerListItem[] = [];
      let contactPickerListItem: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: true,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      list.push(contactPickerListItem);
      ContactsPickerPresenter.getInstance().contactsSource.contactList = list;
      let setString = new Set<string>();
      setString.add('123');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      ContactsPickerPresenter.getInstance().contactIdMap.set(1, list);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsPickerPresenter.getInstance().selectedSource,
        ContactsPickerPresenter.getInstance().selectedSource.refresh);
      ContactsPickerPresenter.getInstance().initSelectedDataSource();
      mocker.verify('refresh', [list]).once();
      mocker.clear(ContactsPickerPresenter.getInstance().selectedSource);
    })

    it('ContactsPickerPresenterTest_selectBatchContact', 0, () => {
      let mocker: MockKit = new MockKit();
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      contactsPickerPresenter.selectedContactsMap.set(1, new Set<string>());
      mocker.mockFunc(contactsPickerPresenter, contactsPickerPresenter.getPickerDataByIds);

      contactsPickerPresenter.selectBatchContact()

      mocker.verify('getPickerDataByIds', [new Set<number>().add(1),
        (contactIdPickerDataMap: Map<number, contact.Contact>) => {
        contactsPickerPresenter.confirm(contactIdPickerDataMap);
      }]).once();
      mocker.clear(contactsPickerPresenter);
    })

    it('ContactsPickerPresenterTest_confirm_01', 0, () => {
      let mocker: MockKit = new MockKit();
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();

      let contact: contact.Contact = { id: 1 };
      let contactIdPickerDataMap: Map<number, contact.Contact> = new Map();
      contactIdPickerDataMap.set(1, contact);

      let result = false;
      let session: UIExtensionContentSession = {
        sendData: (data: Record<string, Object>): void => {
          result = true;
        }
      } as UIExtensionContentSession;

      contactsPickerPresenter.isContactsPicker = false;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession))(ArgumentMatchers.any)
        .afterReturn(session);

      contactsPickerPresenter.confirm(contactIdPickerDataMap);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactsPickerPresenterTest_confirm_02', 0, () => {
      let mocker: MockKit = new MockKit();
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();

      let contact: contact.Contact = { id: 1 };
      let contactIdPickerDataMap: Map<number, contact.Contact> = new Map();
      contactIdPickerDataMap.set(1, contact);

      let result = false;
      let session: UIExtensionContentSession = {
        sendData: (data: Record<string, Object>): void => {
          result = true;
        }
      } as UIExtensionContentSession;

      contactsPickerPresenter.isContactsPicker = true;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession))(ArgumentMatchers.any)
        .afterReturn(session);

      contactsPickerPresenter.confirm(contactIdPickerDataMap);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactsPickerPresenterTest_saveExistContact', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResourceId);
      ContactsPickerPresenter.getInstance().isSaveExistContact = true;
      ContactsPickerPresenter.getInstance().isContactsPicker = true;
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().refreshPageMessage);
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      ContactsPickerPresenter.getInstance().saveExistContact(1);
      mocker.verify('setOrCreate', ['isFromPickerSaveExistContact', true]).once();
      mocker.clear(AppStorage);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(ResourceUtil);
      mocker.clear(ContactsPickerPresenter.getInstance());
    })

    it('ContactsPickerPresenterTest_dealPickerDataResult', 0, () => {
      let contactIdPickerDataMap = new Map<number, contact.Contact>();
      let pickerData: contact.Contact = new contact.Contact();
      let phoneNumber: contact.PhoneNumber = new contact.PhoneNumber();
      phoneNumber.phoneNumber = '13800001111';
      let phones: contact.PhoneNumber[] = [];
      phones.push(phoneNumber);
      pickerData.phoneNumbers = phones;
      contactIdPickerDataMap.set(1, pickerData);
      ContactsPickerPresenter.getInstance().isDisplayByName = true;
      let result = ContactsPickerPresenter.getInstance().dealPickerDataResult(contactIdPickerDataMap);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify([pickerData]));

      ContactsPickerPresenter.getInstance().isDisplayByName = false;
      let setString = new Set<string>();
      setString.add('13800001111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      let result1 = ContactsPickerPresenter.getInstance().dealPickerDataResult(contactIdPickerDataMap);
      expect(JSON.stringify(result1)).assertEqual(JSON.stringify([pickerData]));
    })

    it('ContactsPickerPresenterTest_dealContactName', 0, () => {
      let contacts: Record<string, string | number>[] = [];
      let contact1: Record<string, string | number> = {
        'contactName': '',
        'telephone': '13800001111',
        'id': 1,
        'contactId': 1,
      };
      contacts.push(contact1);

      let contactIdPickerDataMap = new Map<number, contact.Contact>();
      let pickerData: contact.Contact = new contact.Contact();
      let phoneNumber: contact.PhoneNumber = new contact.PhoneNumber();
      phoneNumber.phoneNumber = '13800001111';
      let phones: contact.PhoneNumber[] = [];
      phones.push(phoneNumber);
      pickerData.phoneNumbers = phones;
      contactIdPickerDataMap.set(1, pickerData);
      ContactsPickerPresenter.getInstance().isDisplayByName = true;

      ContactsPickerPresenter.getInstance().selectedContactsMap = new HashMap<number, Set<string>>();
      let setString = new Set<string>();
      setString.add('13800001111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      let result = ContactsPickerPresenter.getInstance().dealContactName(contactIdPickerDataMap);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(contacts));
    })

    it('ContactsPickerPresenterTest_dealContactName01', 0, () => {
      let contacts: Record<string, string | number>[] = [];
      let contact1: Record<string, string | number> = {
        'contactName': '',
        'telephone': '',
        'id': 1,
        'contactId': 1,
      };
      contacts.push(contact1);

      let contactIdPickerDataMap = new Map<number, contact.Contact>();
      let pickerData: contact.Contact = new contact.Contact();
      let phones: contact.PhoneNumber[] = [];
      pickerData.phoneNumbers = phones;
      contactIdPickerDataMap.set(1, pickerData);
      ContactsPickerPresenter.getInstance().isDisplayByName = true;

      ContactsPickerPresenter.getInstance().selectedContactsMap = new HashMap<number, Set<string>>();
      let setString = new Set<string>();
      setString.add('13800001111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      let result = ContactsPickerPresenter.getInstance().dealContactName(contactIdPickerDataMap);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(contacts));
    })

    it('ContactsPickerPresenterTest_dealContactName_else', 0, () => {
      let contacts: Record<string, string | number>[] = [];
      let contact1: Record<string, string | number> = {
        'contactName': '',
        'telephone': '13800001111',
        'id': 1,
        'contactId': 1,
      };
      contacts.push(contact1);

      let contactIdPickerDataMap = new Map<number, contact.Contact>();
      let pickerData: contact.Contact = new contact.Contact();
      let phoneNumber: contact.PhoneNumber = new contact.PhoneNumber();
      phoneNumber.phoneNumber = '13800001111';
      let phones: contact.PhoneNumber[] = [];
      phones.push(phoneNumber);
      pickerData.phoneNumbers = phones;
      contactIdPickerDataMap.set(1, pickerData);
      ContactsPickerPresenter.getInstance().isDisplayByName = false;
      ContactsPickerPresenter.getInstance().selectedContactsMap = new HashMap<number, Set<string>>();
      let setString = new Set<string>();
      setString.add('13800001111');
      ContactsPickerPresenter.getInstance().selectedContactsMap.set(1, setString);
      let result = ContactsPickerPresenter.getInstance().dealContactName(contactIdPickerDataMap);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(contacts));
    })

    it('ContactsPickerPresenterTest_refreshPageMessage', 0, () => {
      ContactsPickerPresenter.getInstance().selectedCount = 1;
      ContactsPickerPresenter.getInstance().totalCount = 1;
      ContactsPickerPresenter.getInstance().refreshPageMessage();
      expect(JSON.stringify(ContactsPickerPresenter.getInstance().allSelectMessage))
        .assertEqual(JSON.stringify($r('app.string.unselect_all')));

      ContactsPickerPresenter.getInstance().selectedCount = 0;
      ContactsPickerPresenter.getInstance().refreshPageMessage();
      expect(JSON.stringify(ContactsPickerPresenter.getInstance().allSelectMessage))
        .assertEqual(JSON.stringify($r('app.string.select_all')));
    })

    it('ContactsPickerPresenterTest_getPickerDataByIds_01', 0, () => {
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(AppStorage, AppStorage.get))('isGettingPickerData').afterReturn(true);

      contactsPickerPresenter.getPickerDataByIds(new Set<number>().add(1), () => {
      })
      mocker.verify('get', ['isGettingPickerData']).once();
      mocker.clear(AppStorage);
    })

    it('ContactsPickerPresenterTest_getPickerDataByIds_02', 0, () => {
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getPickerDataByIds').afterAction(() => {
        result = true;
      });
      when(mocker.mockFunc(AppStorage, AppStorage.get))('isGettingPickerData').afterReturn(false);
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate)
      contactsPickerPresenter.getPickerDataByIds(new Set<number>().add(1), () => {
      })
      mocker.verify('setOrCreate', ['isGettingPickerData', true]).once();

      mocker.clear(AppStorage);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('ContactsPickerPresenterTest_checkTheParameterType_01', 0, () => {
      let result: common.AbilityResult = {
        resultCode: 401
      }
      let contactsPickerPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getTestInstance();
      const context: common.UIAbilityContext = {
        terminateSelfWithResult: (parameter: common.AbilityResult) => {
          expect(JSON.stringify(parameter)).assertEqual(JSON.stringify(result));
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))()
        .afterReturn(context);

      contactsPickerPresenter.selectLimit = 0;

      contactsPickerPresenter.checkTheParameterType();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactsPickerPresenterTest_checkTheParameterType_02', 0, () => {
      let result: BusinessError = {
        code: 0,
        name: '',
        message: ''
      }
      let mocker: MockKit = new MockKit();
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.IS_NOT_NULL;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]

      let filterOptions: contact.FilterOptions = {filterCondition}
      let field: contact.DataField = contact.DataField.EMAIL;
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let dataFilter: contact.DataFilter = {field, options};
      filterClause.dataItem = dataFilter;
      let filterType: contact.FilterType = contact.FilterType.SHOW_FILTER;
      let filter: contact.ContactSelectionFilter = {
        filterClause, filterType
      };
      ContactsPickerPresenter.getInstance().filter = filter;
      let mockFunc: Function = mocker.mockFunc(ContactsPickerPresenter.getInstance(),
        ContactsPickerPresenter.getInstance().checkFilterOptions);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(result);
      ContactsPickerPresenter.getInstance().checkTheParameterType();
      mocker.verify('checkFilterOptions', [filter.filterClause.id, 'id']).once();
      mocker.clear(ContactsPickerPresenter.getInstance());
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_else', 0, () => {
      let options: contact.FilterOptions[] = [];
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'str'}) parameter is incorrect, filterOptions length is ${options.length}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'str');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_EQUAL_TO', 0, () => {
      let filterCondition: contact.FilterCondition = contact.FilterCondition.EQUAL_TO;
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'str'}) parameter is incorrect, value type is ${typeof filterOptions.value}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'str');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_NOT_EQUAL_TO', 0, () => {
      let filterCondition: contact.FilterCondition = contact.FilterCondition.NOT_EQUAL_TO;
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'str'}) parameter is incorrect, value type is ${typeof filterOptions.value}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'str');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_CONTAINS', 0, () => {
      let filterCondition: contact.FilterCondition = contact.FilterCondition.CONTAINS;
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'str'}) parameter is incorrect, value type is ${typeof filterOptions.value}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'str');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_IN', 0, () => {
      let filterCondition: contact.FilterCondition = contact.FilterCondition.IN;
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'obj'}) parameter is incorrect, value type is ${typeof filterOptions.value}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'obj');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_checkFilterOptions_NOT_IN', 0, () => {
      let filterCondition: contact.FilterCondition = contact.FilterCondition.NOT_IN;
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let list: BusinessError = {
        code: 401,
        name: '',
        message: `The filterClause(${'obj'}) parameter is incorrect, value type is ${typeof filterOptions.value}`
      }
      let result = ContactsPickerPresenter.getInstance().checkFilterOptions(options, 'obj');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })

    it('ContactsPickerPresenterTest_getSearchContactResult', 0, () => {
      let value: string = ' ';
      ContactsPickerPresenter.getInstance().getSearchContactResult(value);
      expect(ContactsPickerPresenter.getInstance().inputKeyword).assertEqual(value);

      let value1: string = 'str ing';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsPickerPresenter.getInstance(), ContactsPickerPresenter.getInstance().contactSearchTask);
      ContactsPickerPresenter.getInstance().getSearchContactResult(value1);
      expect(ContactsPickerPresenter.getInstance().inputKeyword).assertEqual(value1);
      mocker.clear(ContactsPickerPresenter.getInstance());
    })
  })
}