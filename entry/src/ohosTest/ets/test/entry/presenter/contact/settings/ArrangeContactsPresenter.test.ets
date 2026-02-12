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
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import { AccountVo } from '../../../../../../../main/ets/model/bean/AccountVo'
import { ContactVo, ContactVoName } from '../../../../../../../main/ets/model/bean/ContactVo'
import LooseObject from '../../../../../../../main/ets/model/type/LooseObject'
import ArrangeContactsPresenter, {
  RepeatContactVo
} from '../../../../../../../main/ets/presenter/contact/settings/ArrangeContactsPresenter'
import SettingsPresenter from '../../../../../../../main/ets/presenter/contact/settings/SettingsPresenter'
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper'
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory'
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import ArrayList from '@ohos.util.ArrayList'
import MorandiColor from '../../../../../../../main/ets/model/bean/MorandiColor'
import HashMap from '@ohos.util.HashMap'
import { DynamicLoader } from '../../../../../../../../../feature/call/oh_modules/common';
import { ResourceUtil } from '../../../../../../../main/ets/util/ResourceUtil'


export default function ArrangeContactsPresenterTest() {
  describe('ArrangeContactsPresenterTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.

    let arrangeContactsPresenter: ArrangeContactsPresenter;
    let contactVo: ContactVo;
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.

      arrangeContactsPresenter = new ArrangeContactsPresenter();
      contactVo = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
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
    it('ArrangeContactsPresenterTest_getInstance', 0, () => {
      expect(typeof ArrangeContactsPresenter.getInstance()).assertEqual(typeof arrangeContactsPresenter);
    })
    it('ArrangeContactsPresenterTest_initContactList1', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllContactWithPhoneNumbers').afterAction(() => {
        result = true;
      });

      arrangeContactsPresenter.initContactList(() => {});

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('ArrangeContactsPresenterTest_initContactList2', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllContactWithPhoneNumbers').afterAction(() => {
        result = true;
      });

      arrangeContactsPresenter.initContactList(() => {});

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('ArrangeContactsPresenterTest_phonenumberFormat', 0, () => {
      let phoneNumber: string = '13466668888';

      const labelName: string = arrangeContactsPresenter.phonenumberFormat(phoneNumber);

      const expectedLabelName = '134\xa06666\xa08888';
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_01', 0, () => {
      let phoneLabelId: string = '1';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName: string = arrangeContactsPresenter.phonenumberFormat(phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_02', 0, () => {
      let phoneLabelId: string = '2';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_home_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_03', 0, () => {
      let phoneLabelId: string = '3';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_work_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_04', 0, () => {
      let phoneLabelId: string = '4';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_fax_work_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_05', 0, () => {
      let phoneLabelId: string = '5';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_fax_home_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_06', 0, () => {
      let phoneLabelId: string = '6';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_pager_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_07', 0, () => {
      let phoneLabelId: string = '7';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_other_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_08', 0, () => {
      let phoneLabelId: string = '12';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_main_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_09', 0, () => {
      let phoneLabelId: string = '99';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      const expectedLabelName = $r("app.string.phone_type_custom_expansion", phoneNumber);
      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectedLabelName));
    })
    it('ArrangeContactsPresenterTest_getPhoneLabelNameById_10', 0, () => {
      let phoneLabelId: string = '100';
      let phoneNumber: string = '123456';

      const labelName = arrangeContactsPresenter.getPhoneLabelNameById(phoneLabelId, phoneNumber);

      expect(labelName).assertNull();
    })
    it('ArrangeContactsPresenterTest_goSelect', 0, () => {
      arrangeContactsPresenter.pathInfos = new NavPathStack();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(arrangeContactsPresenter.pathInfos?.pushPathByName('SelectRepeatContact', ''));
      }))
      arrangeContactsPresenter.goSelect();

      expect(arrangeContactsPresenter.pathInfos.getAllPathName().toString()).assertEqual(["SelectRepeatContact"].toString());
      mocker.clear(DynamicLoader.getInstance());
    })

    it('ArrangeContactsPresenterTest_compare', 0, async () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo1 = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1', '2');
      let contactVo2 = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '2', '0', name, '2', '1', '1', '2');
      let contactList: ContactVo[] = [];
      contactList.push(contactVo1);
      contactList.push(contactVo2);

      expect(arrangeContactsPresenter.compare(contactList)[0][0]).assertEqual('12');
    });
    it("ArrangeContactsPresenterTest_arrange", 0, async () => {
      contactVo.contactId = 'contactId';
      let repeatContactVo: RepeatContactVo = new RepeatContactVo([contactVo, contactVo]);
      arrangeContactsPresenter.selectedRepeatContacts.set(contactVo.contactId, repeatContactVo);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(arrangeContactsPresenter, arrangeContactsPresenter.onDeleteConfirm);

      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
        .afterReturn(context);

      arrangeContactsPresenter.arrange();

      const deleteIds = ['contactId'];
      const contactIdParam: LooseObject = {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: [['contactId', 'contactId']],
      }
      mocker.verify('onDeleteConfirm', [deleteIds]).never();
      mocker.clear(arrangeContactsPresenter);
      mocker.clear(contactsGlobalThisHelper);
    });
    it("ArrangeContactsPresenterTest_onDeleteConfirm", 0, async () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteContactByIds').afterAction(() => {
        result = true;
      });

      arrangeContactsPresenter.onDeleteConfirm(['']);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    });
    it("ArrangeContactsPresenterTest_getAllAccount", 0, async () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllAccount').afterAction(() => {
        result = true;
      });

      arrangeContactsPresenter.getAllAccountAndContactSize(() => {});

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    });
    it("ArrangeContactsPresenterTest_getAccountNameList", 0, async () => {
      let item: AccountVo = new AccountVo('accountId', 'accountName', 'accountType','');
      arrangeContactsPresenter.accountList = [item];

      const accountNameList = arrangeContactsPresenter.getAccountNameList();

      expect(JSON.stringify(accountNameList)).assertEqual(JSON.stringify(['accountName']));
    });
    it("ArrangeContactsPresenterTest_resetInitialIndex", 0, async () => {
      arrangeContactsPresenter.resetInitialIndex(1);

      expect(arrangeContactsPresenter.initialIndex).assertEqual(1);
    });
    it("ArrangeContactsPresenterTest_getUnmergedContacts", 0, async () => {
      let repeatId = ['1','2']
      arrangeContactsPresenter.getUnmergedContacts(repeatId);

      expect(arrangeContactsPresenter.initialIndex).assertEqual(0);;
    });

    it("ArrangeContactsPresenterTest_getContactSizeByAccountId_01", 0, async () => {
      let result = 0;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      let accountId = "1";
      when(mockSendRequest)('getContactSize').afterAction(() => {
        result = 0;
      });
      ArrangeContactsPresenter.getInstance().getContactSizeByAccountId(accountId)
      expect(ArrangeContactsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })
    it("ArrangeContactsPresenterTest_exportVCF", 0, async () => {
      let accountIds=['1','2']
      let contactsIsMore=true
      let curNo4VCF=1
      SettingsPresenter.getInstance().exportVCF(accountIds, contactsIsMore, curNo4VCF)
      expect(arrangeContactsPresenter.refreshContactsEmitterId).assertEqual(108);
    })

    it('ArrangeContactsPresenterTest_repeatListAddData', 0, () => {
      let repeatContactMap: HashMap<string, RepeatContactVo> = new HashMap();
      let idsList: string[][][] = [];
      let cv = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      cv.displayName = '1';
      let cv1 = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      cv1.displayName = '1'
      let contactList: ContactVo[] = [];
      contactList.push(cv);
      contactList.push(cv1);
      ArrangeContactsPresenter.getInstance().contactList = contactList;
      let repeatContactVo: RepeatContactVo = new RepeatContactVo(contactList);
      repeatContactMap.set('1', repeatContactVo);
      let mocker: MockKit = new MockKit();
      let ids: string[][] = [];
      let id: string[] = ['1'];
      ids.push(id);
      when(mocker.mockFunc(ArrangeContactsPresenter.getInstance(),
        ArrangeContactsPresenter.getInstance().compare))(ArgumentMatchers.any).afterReturn(ids);
      ArrangeContactsPresenter.getInstance().repeatListAddData(repeatContactMap, idsList, 0);
      expect(ArrangeContactsPresenter.getInstance().repeatList.length != 0).assertTrue();
      mocker.clear(ArrangeContactsPresenter.getInstance());
    })

    it('ArrangeContactsPresenterTest_onItemClick', 0, () => {
      let contactList: ContactVo[] = [];
      let item: RepeatContactVo = new RepeatContactVo(contactList);
      item.repeatId = '1';
      let repeatContactMap: HashMap<string, RepeatContactVo> = new HashMap();
      repeatContactMap.set('1', item);
      ArrangeContactsPresenter.getInstance().selectedRepeatContacts = repeatContactMap;
      ArrangeContactsPresenter.getInstance().onItemClick(item, 0);
      expect(ArrangeContactsPresenter.getInstance().selectCount).assertEqual(0);

      ArrangeContactsPresenter.getInstance().selectedRepeatContacts.set('2', item);
      ArrangeContactsPresenter.getInstance().onItemClick(item, 0);
      expect(ArrangeContactsPresenter.getInstance().selectCount).assertEqual(2);
    })

    it('ArrangeContactsPresenterTest_onClickAll', 0, () => {
      ArrangeContactsPresenter.getInstance().repeatList = [];
      ArrangeContactsPresenter.getInstance().selectedRepeatContacts = new HashMap();
      let cv = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      cv.displayName = '1';
      let contactList: ContactVo[] = [];
      contactList.push(cv);
      let repeatContactVo: RepeatContactVo = new RepeatContactVo(contactList);
      ArrangeContactsPresenter.getInstance().repeatList.push(repeatContactVo);
      ArrangeContactsPresenter.getInstance().selectedRepeatContacts.set('1', repeatContactVo);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);

      ArrangeContactsPresenter.getInstance().onClickAll();
      expect(ArrangeContactsPresenter.getInstance().selectCount).assertEqual(0);

      ArrangeContactsPresenter.getInstance().selectedRepeatContacts = new HashMap();
      let cv1 = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      cv1.displayName = '1'
      contactList.push(cv1);
      let repeatContactVo1: RepeatContactVo = new RepeatContactVo(contactList);
      repeatContactVo1.repeatId = '2';
      ArrangeContactsPresenter.getInstance().repeatList.push(repeatContactVo1);
      ArrangeContactsPresenter.getInstance().selectedRepeatContacts.set('1', repeatContactVo);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);

      ArrangeContactsPresenter.getInstance().onClickAll();
      expect(ArrangeContactsPresenter.getInstance().selectCount).assertEqual(3);
      mocker.clear(ResourceUtil);
    })
  })
}