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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { SmartMobilityInfo, SmartMobilityStatus, SmartMobilityType } from '../../../../../../main/ets/model/bean/DeviceInfoBean'

export default function DeviceInfoBeanTest() {
  describe('DeviceInfoBeanTest', () => {
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
    it('DeviceInfoBeanTest_SmartMobilityInfo', 0, () => {
      const di1: SmartMobilityInfo = {
        status: SmartMobilityStatus.IDLE,
        type: SmartMobilityType.HICAR,
        data: {'cs': 'cs'}
      };
      expect(di1.status).assertEqual(0);
      expect(di1.type).assertEqual(0);
      expect(di1.data?.['cs'].toString()).assertEqual('cs');
      const di2: SmartMobilityInfo = {
        status: SmartMobilityStatus.RUNNING,
        type: SmartMobilityType.SUPER_LAUNCHER,
        data: {'cs': 'cs'}
      };
      expect(di2.status).assertEqual(1);
      expect(di2.type).assertEqual(1);
      expect(di2.data?.['cs'].toString()).assertEqual('cs');
      const di3: SmartMobilityInfo = {
        status: SmartMobilityStatus.RUNNING,
        type: SmartMobilityType.CAR_HOP,
        data: {'cs': 'cs'}
      };
      expect(di3.status).assertEqual(1);
      expect(di3.type).assertEqual(2);
      expect(di2.data?.['cs'].toString()).assertEqual('cs');
    })
  })
}