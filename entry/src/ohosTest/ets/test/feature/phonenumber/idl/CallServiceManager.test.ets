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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { Caas } from '../../../../../../../../feature/phonenumber/src/main/ets/idl/model/caasType';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import CallServiceManager from '../../../../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager'

export default function CallServiceManagerTest() {
  describe('CallServiceManagerTest', () => {
    let subject: CallServiceManager;
    let mocker: MockKit;
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      subject = CallServiceManager.getTestInstance();
      mocker = new MockKit();
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
    it('CallServiceManagerTest_getInstance', 0, () => {
      expect(CallServiceManager.getInstance() instanceof CallServiceManager).assertEqual(true)
    })
    it('CallServiceManagerTest_placeCall_wrong_param', 0, async() => {

      let result = await subject.placeCall("", Caas.MediaType.AUDIO, undefined)

      expect(result).assertEqual(false)
    })
    it('CallServiceManagerTest_isLoginMeetime', 0, async () => {
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let value = randomBoolean()
      when(mockFunc)(ContactsGlobalThisHelper.MeeTimeLoginFlagName).afterReturn(value);

      let result = await subject.isLoginMeetime()

      expect(result).assertEqual(value)
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());

    })
    it('CallServiceManagerTest_isLoginMeetime_undefined', 0, async () => {
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(mockFunc)(ContactsGlobalThisHelper.MeeTimeLoginFlagName).afterReturn(undefined);

      let result = await subject.isLoginMeetime()

      expect(result).assertEqual(false)
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

  })
}

function randomBoolean() {
  return Math.random() < 0.5 //50% chance for true
}
