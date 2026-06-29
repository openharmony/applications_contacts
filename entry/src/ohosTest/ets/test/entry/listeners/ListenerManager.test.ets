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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { ListenerManager } from '../../../../../main/ets/listeners/ListenerManager';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { ContactsGlobalThisHelper } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import { AsyncCallback } from '@ohos.base';
import dataShare from '@ohos.data.dataShare';
import {
  sharedPreferencesUtils
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/SharedPreferencesUtils';
import { preferences } from '@kit.ArkData';

export default function ListenerManagerTest() {
  describe('ListenerManagerTest', () => {

    let listenerManager: ListenerManager;

    beforeEach(() => {
      listenerManager = new ListenerManager();
    })

    it('MainAbilityTest_registerListeners', 0, () => {
      let mocker: MockKit = new MockKit();

      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
        .afterReturn(context);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);

      listenerManager.registerListeners();

      mocker.verify('getDefaultUIContext', []).atMost(7);

      mocker.clear(contactsGlobalThisHelper);
      mocker.clear(workerWrapper);
    })

    it('MainAbilityTest_registerListeners_subscribeTimeFormatChange_error', 0, () => {
      let mocker: MockKit = new MockKit();

      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
        .afterThrow('error');

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);

      listenerManager.registerListeners();

      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).times(0);

      mocker.clear(contactsGlobalThisHelper);
      mocker.clear(workerWrapper);
    })

    it('MainAbilityTest_registerListeners_activateRestore_error', 0, () => {
      let mocker: MockKit = new MockKit();

      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
        .afterReturn(context);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterThrow('error');

      listenerManager.registerListeners();

      mocker.verify('getDefaultUIContext', []).times(0);

      mocker.clear(contactsGlobalThisHelper);
      mocker.clear(workerWrapper);
    })

    it('MainAbilityTest_registerListeners_subscribeMeetimeLoginFlagChange_error', 0, () => {
      let mocker: MockKit = new MockKit();

      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
        .afterReturn(context);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('updateTimeFormat')
        .afterAction(() => {
          when(mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getDefaultUIContext))()
            .afterThrow('error');
        });

      listenerManager.registerListeners();

      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).times(0);

      mocker.clear(contactsGlobalThisHelper);
      mocker.clear(workerWrapper);
    })

    it('MainAbilityTest_unRegisterListeners_noError', 0, () => {
      let result = false;
      listenerManager.settingDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          result = true;
        }
      } as dataShare.DataShareHelper;

      let result1 = false;
      listenerManager.cloudSyncDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          result1 = true;
        }
      } as dataShare.DataShareHelper;

      listenerManager.unRegisterListeners();

      expect(result).assertTrue();
      expect(result1).assertTrue();
    })

    it('MainAbilityTest_unRegisterListeners_null', 0, () => {
      listenerManager.unRegisterListeners();
      expect(listenerManager.settingDataShareHelper).assertNull();
    })

    it('MainAbilityTest_unRegisterListeners_settingDataShareHelper_error', 0, () => {
      let result = false;
      listenerManager.settingDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          throw new Error('error');
        }
      } as dataShare.DataShareHelper;

      let result1 = false;
      listenerManager.cloudSyncDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          result1 = true;
        }
      } as dataShare.DataShareHelper;
      listenerManager.unRegisterListeners();

      expect(result).assertFalse();
      expect(result1).assertFalse();
    })

    it('MainAbilityTest_unRegisterListeners_cloudSyncDataShareHelper_error', 0, () => {
      let result = false;
      listenerManager.settingDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          result = true;
        }
      } as dataShare.DataShareHelper;

      let result1 = false;
      listenerManager.cloudSyncDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          throw new Error('error');
        }
      } as dataShare.DataShareHelper;
      listenerManager.unRegisterListeners();

      expect(result).assertTrue();
      expect(result1).assertFalse();
    })

    it('MainAbilityTest_unRegisterListeners_dialpadTouchToneDataShareHelper_error', 0, () => {
      let result = false;
      listenerManager.dialpadTouchToneDataShareHelper = {
        off: (type: 'dataChange', uri: string, callback?: AsyncCallback<void>): void => {
          result = true;
        }
      } as dataShare.DataShareHelper;

      listenerManager.unRegisterListeners();

      expect(result).assertTrue();
    })

    it('ListenerManagerTest_getLocalAccountId', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(new Promise<preferences.ValueType>(resolve => resolve(0)));
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await listenerManager.getLocalAccountId();
      mocker.verify('getFromPreferences', ['HiCall_User_Id_Status', 0]).once();
      mocker.clear(sharedPreferencesUtils);
    })
  })
}