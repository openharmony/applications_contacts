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
import BigPhotoCopyUtil from '../../../../../main/ets/util/BigPhotoCopyUtil'
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import GroupIdUtil from '../../../../../main/ets/util/GroupIdUtil';
import { sharedPreferencesUtils } from '../../../../../../../common'
import { preferences } from '@kit.ArkData';

export default function BigPhotoCopyUtilTest() {
  describe('BigPhotoCopyUtilTest', () => {
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

    it('BigPhotoCopyUtilTest_copyPhotoFile_error', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterThrow('error');
      BigPhotoCopyUtil.getInstance().copyPhotoFile();
      expect(BigPhotoCopyUtil.getInstance().resultDT).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('BigPhotoCopyUtilTest_bigPhotoFileCopy', 0, () => {
      let callback = () => {};
      let mocker: MockKit = new MockKit();
      let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let mockFunc: Function = mocker.mockFunc(GroupIdUtil.getInstance(), GroupIdUtil.getInstance().getGroupDir);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string> (resolve => resolve('')));
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(new Promise<preferences.ValueType> (resolve => resolve(2)))
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      BigPhotoCopyUtil.getInstance().bigPhotoFileCopy(callback);
      mocker.verify('saveToPreferences', ['bigPhotoFileCopyFlag', 1]).never();
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(GroupIdUtil.getInstance());
    })
  })
}