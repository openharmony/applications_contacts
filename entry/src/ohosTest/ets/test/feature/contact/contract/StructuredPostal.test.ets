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
import { StructuredPostal } from '../../../../../../../../feature/contact/src/main/ets/contract/StructuredPostal'

export default function StructuredPostalTest() {
  describe('StructuredPostalTest', () => {
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
    it('StructuredPostalTest_getTypeLabelResource', 0, () => {
      const imgSrc1: Resource = StructuredPostal.getTypeLabelResource(StructuredPostal.TYPE_HOME);
      const expectedImgSrc1: Resource = $r("app.string.email_type_home");
      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));

      const imgSrc2: Resource = StructuredPostal.getTypeLabelResource(StructuredPostal.TYPE_WORK);
      const expectedImgSrc2: Resource = $r("app.string.email_type_work");
      expect(JSON.stringify(imgSrc2)).assertEqual(JSON.stringify(expectedImgSrc2));

      const imgSrc3: Resource = StructuredPostal.getTypeLabelResource(StructuredPostal.TYPE_OTHER);
      const expectedImgSrc3: Resource = $r("app.string.email_type_other");
      expect(JSON.stringify(imgSrc3)).assertEqual(JSON.stringify(expectedImgSrc3));

      const imgSrc4: Resource = StructuredPostal.getTypeLabelResource(StructuredPostal.TYPE_CUSTOM);
      const expectedImgSrc4: Resource =  $r("app.string.email_type_custom");
      expect(JSON.stringify(imgSrc4)).assertEqual(JSON.stringify(expectedImgSrc4));

    })

  })
}