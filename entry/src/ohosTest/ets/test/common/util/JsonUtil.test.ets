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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { JsonUtil } from '../../../../../../../common/src/main/ets/util/JsonUtil';

export default function JsonUtilTest() {
  describe('JsonUtilTest', () => {
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
    it('JsonUtilTest_jsonToObject', 0, () => {
      let defaultValue: Record<string, string | number | boolean> = {
        'phoneNumber': '123258',
        'index': 0,
        'lastFlag': true
      };
      const jsonStr: string = '';
      const res1 = JsonUtil.jsonToObject(jsonStr, defaultValue);
      expect(res1['phoneNumber']).assertEqual('123258');
      expect(res1['index']).assertEqual(0);
      expect(res1['lastFlag']).assertEqual(true);

      const jsonStr1 = '{"phoneNumber":"123","index":1,"lastFlag":"1"}';
      const res2 = JsonUtil.jsonToObject(jsonStr1, defaultValue);
      expect(res2['phoneNumber']).assertEqual('123');
      expect(res2['index']).assertEqual(1);
      expect(res2['lastFlag']).assertEqual('1');
    })
  })
}