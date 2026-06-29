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
import { describe, it, expect, MockKit, ArgumentMatchers, when, beforeEach, afterEach } from '@ohos/hypium';
import { HiLog } from '../../../../../../../../../feature/call/oh_modules/common';
import { ContactVo } from '../../../../../../../main/ets/model/bean/ContactVo';
import BatchDeleteContactsPresenter
  from '../../../../../../../main/ets/presenter/contact/settings/BatchDeleteContactsPresenter';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import { HashSet } from '@kit.ArkTS';
import ContactListShowInfo from '../../../../../../../main/ets/model/bean/ContactListShowInfo';
import { ResourceUtil } from '../../../../../../../../../entry/src/main/ets/util/ResourceUtil';

const TAG = 'BatchDeleteContactsPresenter ';

export default function BatchDeleteContactsPresenterTest() {

  describe('BatchDeleteContactsPresenterTest', () => {
    let batchDeleteContactsPresenter: BatchDeleteContactsPresenter;
    let mocker: MockKit = new MockKit();

    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      batchDeleteContactsPresenter = BatchDeleteContactsPresenter.getTestInstance();
    })

    afterEach(() => {
      mocker.clear(ResourceUtil);
    })


    it("batchDeleteContactsPresenterTest_judgeAndLogSortError_01", 0, () => {
      let contactVo: ContactVo = new ContactVo("", "#", "1", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '');
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);

      contactVo.sort = '-1';
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);
    })

    it("batchDeleteContactsPresenterTest_judgeAndLogSortError_02", 0, () => {
      let contactVo: ContactVo = new ContactVo("", "...", "1", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '');
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);

      contactVo.sort = '99';
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);
    })

    it("batchDeleteContactsPresenterTest_judgeAndLogSortError_03", 0, () => {
      let contactVo: ContactVo = new ContactVo("", "0", "1", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '');
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);
    })

    it("batchDeleteContactsPresenterTest_judgeAndLogSortError_04", 0, () => {
      let contactVo: ContactVo = new ContactVo("", "", "1", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '');
      BatchDeleteContactsPresenter.getInstance().judgeAndLogSortError(contactVo);
      expect(BatchDeleteContactsPresenter.getInstance().selectCount).assertEqual(0);
    })

    it("batchDeleteContactsPresenterTest_getInstance", 0, () => {
      expect(typeof BatchDeleteContactsPresenter.getInstance()).assertEqual(typeof batchDeleteContactsPresenter);
    })

    it("batchDeleteContactsPresenterTest_logSortError", 0, () => {
      let contactVo: ContactVo = new ContactVo("", "0", "1", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '');
      let title: string = "title";
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      batchDeleteContactsPresenter.logSortError(title, contactVo);
      mocker.verify('i', [TAG, `${title}, sort error sortFirstLetter: ${contactVo.namePrefix} sort: ${contactVo.sort}`])
        .never();
      mocker.clear(HiLog);
    })

    it("batchDeleteContactsPresenterTest_initContactsList", 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequestUiThread);
      when(mockSendRequest)('getAllContactSize')
        .afterReturn(new Promise<boolean>((resolve: Function, reject: Function) => {
          resolve(true);
        }))
      mocker.mockFunc(batchDeleteContactsPresenter, batchDeleteContactsPresenter.refreshPageMessage);
      batchDeleteContactsPresenter.initContactsList();
      mocker.verify('refreshPageMessage', []).never();
      mocker.clear(batchDeleteContactsPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it("batchDeleteContactsPresenterTest_delete1", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      batchDeleteContactsPresenter.delete();
      mocker.verify('e', [TAG, `delete size can not be 0`]).once();
      mocker.clear(HiLog);
    })

    it("batchDeleteContactsPresenterTest_delete2", 0, () => {
      let selectedContacts: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      selectedContacts.add('1');
      selectedContacts.add('2');
      selectedContacts.add('3');
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteContactByIds').afterAction(() => {
        result = true;
      });
      mocker.mockFunc(batchDeleteContactsPresenter.contactListDataSource,
        batchDeleteContactsPresenter.contactListDataSource.notifyDataReload);
      batchDeleteContactsPresenter.delete();
      expect(result).assertTrue();
      mocker.verify('notifyDataReload', []).never();
      mocker.clear(batchDeleteContactsPresenter.contactListDataSource);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it("batchDeleteContactsPresenterTest_onItemClick", 0, () => {
      let item: ContactListShowInfo = new ContactListShowInfo(true, true, '1', '2', 'h', 'H', 'G', '李', '明');
      let selectedContacts: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      selectedContacts.add('1');
      batchDeleteContactsPresenter.onItemClick(item, 1);
      expect(selectedContacts.has(item.contactId)).assertFalse();

      let item1: ContactListShowInfo = new ContactListShowInfo(true, true, '2', '2', 'h', 'H', 'G', '李', '明');
      let selectedContacts1: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      selectedContacts1.add('1');
      batchDeleteContactsPresenter.onItemClick(item1, 1);
      expect(selectedContacts1.has(item1.contactId)).assertTrue();

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeleteContactsPresenter, batchDeleteContactsPresenter.refreshPageMessage);
      batchDeleteContactsPresenter.onItemClick(item, 1);
      mocker.verify('refreshPageMessage', []).once();
      mocker.clear(batchDeleteContactsPresenter);
    })

    it("batchDeleteContactsPresenterTest_onClickAll", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      let selectedContacts: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      selectedContacts.add('1');
      batchDeleteContactsPresenter.contactsTotal = 1;
      batchDeleteContactsPresenter.onClickAll();
      expect(selectedContacts.isEmpty()).assertTrue();
      mocker.clear(ResourceUtil);
    })

    it('batchDeleteContactsPresenterTest_aboutToAppear', 0, () => {
      let selectedContacts: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeleteContactsPresenter, batchDeleteContactsPresenter.initContactsList);
      mocker.mockFunc(batchDeleteContactsPresenter, batchDeleteContactsPresenter.refreshPageMessage);

      batchDeleteContactsPresenter.aboutToAppear();

      expect(batchDeleteContactsPresenter.contactsListInited).assertFalse();
      expect(selectedContacts.isEmpty()).assertTrue();
      mocker.verify('initContactsList', []).once();
      mocker.verify('refreshPageMessage', []).once();
      mocker.clear(batchDeleteContactsPresenter);
    })

    it('batchDeleteContactsPresenterTest_refreshPageMessage', 0, () => {
      let selectedContacts: HashSet<string> = batchDeleteContactsPresenter.selectedContacts;
      selectedContacts.add('1');
      batchDeleteContactsPresenter.contactsTotal = 1;
      batchDeleteContactsPresenter.refreshPageMessage();
      expect(JSON.stringify(batchDeleteContactsPresenter.icSelectAll))
        .assertEqual(JSON.stringify($r('sys.symbol.checkmark_square_on_square_fill')));
    })
  })
}