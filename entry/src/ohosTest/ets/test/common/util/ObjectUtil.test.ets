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
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil'
import LooseObject from '../../../../../main/ets/model/type/LooseObject'

export default function ObjectUtilTest() {
  describe('ObjectUtilTest', () => {
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
    it('ObjectUtilTest_isEmpty', 0, () => {
      const result1 = ObjectUtil.isEmpty(undefined);
      expect(result1).assertTrue();

      const result2 = ObjectUtil.isEmpty({});
      expect(result2).assertTrue();

      const result3 = ObjectUtil.isEmpty({ key: 'value' });
      expect(result3).assertFalse();

      const result4 = ObjectUtil.isEmpty("sfa");
      expect(result4).assertFalse();

      const result5 = ObjectUtil.isEmpty(2342);
      expect(result5).assertFalse();

      const result6 = ObjectUtil.isEmpty("");
      expect(result6).assertFalse();

    })
    it('ObjectUtilTest_isUndefined', 0, () => {
      const result1 = ObjectUtil.isUndefined(undefined);
      expect(result1).assertTrue();

      const result2 = ObjectUtil.isUndefined(null);
      expect(result2).assertFalse();
    })
    it('ObjectUtilTest_assign', 0, () => {
      let target: LooseObject = { key1: 'value' };
      const preLength = Object.keys(target).length;
      expect(preLength).assertEqual(1);

      ObjectUtil.assign(target, { key2: 'value' });
      const lastLength = Object.keys(target).length;
      expect(lastLength).assertEqual(2);
    })
  })
}