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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { CustomizedParams } from '../../../../../main/ets/model/type'
import DotUtil, { HiAppEvent } from '../../../../../main/ets/util/DotUtil'

export default function DotUtilTest() {
  describe('DotUtilTest', () => {
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

    it('DotUtilTest_contactDot', 0, () => {
      const CONTACT_ADD_EVENT = 'CONTACT_ADD_EVENT';
      let customizedParams: CustomizedParams = {
        ENC: 0
      };
      let mocker: MockKit = new MockKit();
      let mockrFun: Function = mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().updateVersionName);
      when(mockrFun)().afterReturn(new Promise<void>(resolve => resolve()));
      DotUtil.getInstance().contactDot(customizedParams,CONTACT_ADD_EVENT)
      mocker.verify('updateVersionName',[]).once();
    })

    it('DotUtilTest_updateVersionName', 0, async () => {
      DotUtil.getInstance().version = '';
      await DotUtil.getInstance().updateVersionName();
      expect(DotUtil.getInstance().version).assertEqual('');
    })

    it('DotUtilTest_reportFaultEvent_error', 0, () => {
      DotUtil.getInstance().version = '';
      let params: CustomizedParams = {
        ENC: 0
      }
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().updateVersionName);
      when(mockFunc)().afterThrow('error');
      DotUtil.getInstance().reportFaultEvent(params, '');
      expect(DotUtil.getInstance().version).assertEqual('');
      mocker.clear(DotUtil.getInstance());
    })

    it('DotUtilTest_blockedDot_error', 0, () => {
      DotUtil.getInstance().version = '';
      let params: CustomizedParams = {
        ENC: 0
      }
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().updateVersionName);
      when(mockFunc)().afterThrow('error');
      DotUtil.getInstance().blockedDot(params, '');
      expect(DotUtil.getInstance().version).assertEqual('');
      mocker.clear(DotUtil.getInstance());
    })

    it('DotUtilTest_HiAppEvent_SchedulerUpload', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiAppEvent.getInstance(), HiAppEvent.getInstance().addEventProcessor);
      mocker.mockFunc(HiAppEvent.getInstance(), HiAppEvent.getInstance().writeCallStatusEvent);
      HiAppEvent.getInstance().SchedulerUpload(1, '', 1, [1], 1, 1, 1);
      mocker.verify('writeCallStatusEvent', ['', 1, [1], 1, 1, 1]).once();
      mocker.clear(HiAppEvent.getInstance());
    })
  })
}