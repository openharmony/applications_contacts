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
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil'

export default function ArrayUtilTest() {
  describe('ArrayUtilTest', () => {
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
    it('ArrayUtilTest_getCurrentPage', 0, () => {
      const result1 = ArrayUtil.getCurrentPage(10);
      expect(result1).assertEqual(1);

      const result2 = ArrayUtil.getCurrentPage(50);
      expect(result2).assertEqual(2);

      const result3 = ArrayUtil.getCurrentPage(549);
      expect(result3).assertEqual(2);
    })
    it('ArrayUtilTest_getOffsetForSession', 0, () => {
      const result1 = ArrayUtil.getOffsetForSession(1);
      expect(result1).assertEqual(0);

      const result2 = ArrayUtil.getOffsetForSession(3);
      expect(result2).assertEqual(2550);
    })
    it('ArrayUtilTest_getLimitForSession', 0, () => {
      const result1 = ArrayUtil.getLimitForSession(1);
      expect(result1).assertEqual(50);

      const result2 = ArrayUtil.getLimitForSession(2);
      expect(result2).assertEqual(2500);
    })
    it('ArrayUtilTest_isEmpty', 0, () => {
      const result1 = ArrayUtil.isEmpty(undefined);
      expect(result1).assertTrue();

      const result2 = ArrayUtil.isEmpty(null);
      expect(result2).assertTrue();

      const result3 = ArrayUtil.isEmpty([]);
      expect(result3).assertTrue();

      const result4 = ArrayUtil.isEmpty([1]);
      expect(result4).assertFalse();
    })

    it('ArrayUtilTest_getOffetByPageAndLimit', 0, () => {
      let page: number = 1;
      let limit: number = 2;
      expect(ArrayUtil.getOffetByPageAndLimit(page, limit)).assertEqual(0);
    })

    it('ArrayUtilTest_getQueriedCount', 0, () => {
      let page: number = 1;
      expect(ArrayUtil.getQueriedCount(page)).assertEqual(0);
      expect(ArrayUtil.getQueriedCount(2)).assertEqual(2550);
    })
  })
}