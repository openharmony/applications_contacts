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
import { PreDefinedContactUtil } from '../../../../../main/ets/util/PreDefineContactUtil'
import {
  sharedPreferencesUtils
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/SharedPreferencesUtils';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { preferences } from '@kit.ArkData';
import { ContactInfo } from '../../../../../main/ets/model/bean/ContactInfo';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';

export default function PreDefineContactUtilTest() {
  describe('PreDefineContactUtilTest', () => {
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
    it('PreDefineContactUtilTest_getPreDefinedContactLoaded', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(new Promise<preferences.ValueType>(resolve => resolve(true)));
      PreDefinedContactUtil.getPreDefinedContactLoaded().then(result => {
        expect(result).assertTrue();
      })
      mocker.clear(sharedPreferencesUtils);
    })

    it('PreDefineContactUtilTest_setPreDefinedContactLoaded', 0, async () => {
      let mocker: MockKit = new MockKit();
      let saveFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils
        .saveToPreferences);
      when(saveFromPreferences)(ArgumentMatchers.any).afterReturnNothing();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils
        .getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(new Promise<preferences.ValueType>(
        resolve => resolve(true)));

      PreDefinedContactUtil.setPreDefinedContactLoaded();

      PreDefinedContactUtil.getPreDefinedContactLoaded().then(result => {
        expect(result).assertTrue();
      })
      mocker.clear(sharedPreferencesUtils);
    })

    it('PreDefineContactUtilTest_getPredefinedPhoto_catch', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext))().afterThrow('error');

      PreDefinedContactUtil.getPredefinedPhoto(callback);
      expect(PreDefinedContactUtil.resultDT).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('PreDefineContactUtilTest_insertPreDefinedContact', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let getFunc: Function = mocker.mockFunc(PreDefinedContactUtil, PreDefinedContactUtil
        .getPredefinedPhoto);
      when(getFunc)(ArgumentMatchers.any).afterReturnNothing();

      PreDefinedContactUtil.insertPreDefinedContact('');

      mocker.verify('getPredefinedPhoto', [callback]).once();
      mocker.clear(PreDefinedContactUtil);
    })

    it('PreDefineContactUtilTest_insertPreDefinedContact_callback', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getFunc: Function = mocker.mockFunc(PreDefinedContactUtil, PreDefinedContactUtil
      .getPredefinedPhoto);

      PreDefinedContactUtil.insertPreDefinedContact('');

      when(getFunc)(ArgumentMatchers.any).afterAction(() => {
        mocker.verify('insertContactWithInfoAndPhoto', ['', null, null]).once();
      });

      mocker.clear(PreDefinedContactUtil);
    })

    it('PreDefineContactUtilTest_updatePreDefinedContact', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let getFunc: Function = mocker.mockFunc(PreDefinedContactUtil, PreDefinedContactUtil
        .getPredefinedPhoto);
      when(getFunc)(ArgumentMatchers.any).afterReturnNothing();

      let contactInfo: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [],
        [], 1, '', '', '');
      PreDefinedContactUtil.updatePreDefinedContact(contactInfo, '', '');

      mocker.verify('getPredefinedPhoto', [callback]).once();
      mocker.clear(PreDefinedContactUtil);
    })

    it('PreDefineContactUtilTest_updatePreDefinedContact_callback', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let getFunc: Function = mocker.mockFunc(PreDefinedContactUtil, PreDefinedContactUtil
        .getPredefinedPhoto);

      let contactInfo: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [],
        [], 1, '', '', '');
      PreDefinedContactUtil.updatePreDefinedContact(contactInfo, '', '');

      when(getFunc)(ArgumentMatchers.any).afterAction(() => {
        mocker.verify('updateContactWithInfoAndPhoto', ['', null, null]).once();
      });

      mocker.clear(PreDefinedContactUtil);
    })

    it('PreDefineContactUtilTest_insertContactWithInfoAndPhoto', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);
      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterReturnNothing();

      PreDefinedContactUtil.insertContactWithInfoAndPhoto('', null, null);

      mocker.verify('sendRequest', ['addContact', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactInfoAfter: '',
        photoBlob: null,
        isMyCard: false
      }, callback]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_insertContactWithInfoAndPhoto_callback', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);

      PreDefinedContactUtil.insertContactWithInfoAndPhoto('', null, null);

      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterAction((arg: string[]) => {
        expect(arg.length).assertEqual(0);
        mocker.verify('setPreDefinedContactLoaded', []).once();
        mocker.verify('markPreDefinedContact', ['']).once();
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_updateContactWithInfoAndPhoto', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);
      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterReturnNothing();

      PreDefinedContactUtil.updateContactWithInfoAndPhoto('', null, null);

      mocker.verify('sendRequest', ['updateContact', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactInfoAfter: '',
        photoBlob: null,
        deletePhoto: false,
        isMyCard: false
      }, callback]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_updateContactWithInfoAndPhoto_callback', 0, async () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);

      PreDefinedContactUtil.updateContactWithInfoAndPhoto('', null, null);

      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterAction((arg: string[]) => {
        expect(arg.length).assertEqual(0);
        mocker.verify('setPreDefinedContactLoaded', []).once();
        mocker.verify('markPreDefinedContact', ['']).once();
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_checkPredefinedExist', 0, async () => {
      let callback = () => {};
      let contactInfo: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [],
        [], 1, '', '', '');
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);
      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterReturnNothing();

      PreDefinedContactUtil.checkPredefinedExist(contactInfo, callback);

      mocker.verify('sendRequest', ['checkPreDefinedExist', {
        name: '',
        phones: [],
        emails: []
      }, callback]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_checkPredefinedExist_callback', 0, async () => {
      let callback = () => {};
      let contactInfo: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [],
        [], 1, '', '', '');
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);

      PreDefinedContactUtil.checkPredefinedExist(contactInfo, callback);

      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any)
        .afterAction((resultList: LooseObject[]) => { expect(resultList.length).assertEqual(0); });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_markPreDefinedContact', 0, async () => {
      let callback = () => {};
      let contactId: string[] = [];
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);
      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterReturnNothing();

      PreDefinedContactUtil.markPreDefinedContact(contactId);

      mocker.verify('sendRequest', ['markPreDefinedContact', {
        contactId: []
      }, callback]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

    it('PreDefineContactUtilTest_markPreDefinedContact_callback', 0, async () => {
      let callback = () => {};
      let contactId: string[] = [];
      let mocker: MockKit = new MockKit();
      let dataWorker: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(dataWorker);

      PreDefinedContactUtil.markPreDefinedContact(contactId);

      when(mocker.mockFunc(dataWorker, dataWorker.sendRequest))(ArgumentMatchers.any).afterAction((res: number) => {
        expect(res).assertEqual(0);
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dataWorker);
    })

  })
}