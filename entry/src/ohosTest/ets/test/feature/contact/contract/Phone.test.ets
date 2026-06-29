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
import { Phone } from '../../../../../../../../feature/contact/src/main/ets/contract/Phone'

export default function PhoneTest() {
  describe('PhoneTest', () => {
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
    it('PhoneTest_getTypeLabelResource', 0, () => {
      const imgSrc1: Resource = Phone.getTypeLabelResource(Phone.TYPE_HOME);
      const expectedImgSrc1: Resource = $r("app.string.phone_type_home");
      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));

      const imgSrc2: Resource = Phone.getTypeLabelResource(Phone.TYPE_MOBILE);
      const expectedImgSrc2: Resource = $r("app.string.phone_type_mobile");
      expect(JSON.stringify(imgSrc2)).assertEqual(JSON.stringify(expectedImgSrc2));

      const imgSrc3: Resource = Phone.getTypeLabelResource(Phone.TYPE_WORK);
      const expectedImgSrc3: Resource = $r("app.string.phone_type_work");
      expect(JSON.stringify(imgSrc3)).assertEqual(JSON.stringify(expectedImgSrc3));

      const imgSrc4: Resource = Phone.getTypeLabelResource(Phone.TYPE_FAX_WORK);
      const expectedImgSrc4: Resource = $r("app.string.phone_type_fax_work");
      expect(JSON.stringify(imgSrc4)).assertEqual(JSON.stringify(expectedImgSrc4));

      const imgSrc5: Resource = Phone.getTypeLabelResource(Phone.TYPE_FAX_HOME);
      const expectedImgSrc5: Resource = $r("app.string.phone_type_fax_home");
      expect(JSON.stringify(imgSrc5)).assertEqual(JSON.stringify(expectedImgSrc5));

      const imgSrc6: Resource = Phone.getTypeLabelResource(Phone.TYPE_PAGER);
      const expectedImgSrc6: Resource = $r("app.string.phone_type_pager");
      expect(JSON.stringify(imgSrc6)).assertEqual(JSON.stringify(expectedImgSrc6));

      const imgSrc7: Resource = Phone.getTypeLabelResource(Phone.TYPE_OTHER);
      const expectedImgSrc7: Resource = $r("app.string.phone_type_other");
      expect(JSON.stringify(imgSrc7)).assertEqual(JSON.stringify(expectedImgSrc7));

      const imgSrc8: Resource = Phone.getTypeLabelResource(Phone.TYPE_MAIN);
      const expectedImgSrc8: Resource = $r("app.string.phone_type_main");
      expect(JSON.stringify(imgSrc8)).assertEqual(JSON.stringify(expectedImgSrc8));

      const imgSrc9: Resource = Phone.getTypeLabelResource(Phone.TYPE_CUSTOM);
      const expectedImgSrc9: Resource = $r("app.string.phone_type_custom");
      expect(JSON.stringify(imgSrc9)).assertEqual(JSON.stringify(expectedImgSrc9));
    })

    it('PhoneTest_apiTypeToSystemType', 0, () => {
      expect(Phone.apiTypeToSystemType(0)).assertEqual(10000);
      expect(Phone.apiTypeToSystemType(1)).assertEqual(Phone.TYPE_HOME);
      expect(Phone.apiTypeToSystemType(2)).assertEqual(Phone.TYPE_MOBILE);
      expect(Phone.apiTypeToSystemType(3)).assertEqual(Phone.TYPE_WORK);
      expect(Phone.apiTypeToSystemType(4)).assertEqual(Phone.TYPE_FAX_WORK);
      expect(Phone.apiTypeToSystemType(5)).assertEqual(Phone.TYPE_FAX_HOME);
      expect(Phone.apiTypeToSystemType(6)).assertEqual(Phone.TYPE_PAGER);
      expect(Phone.apiTypeToSystemType(7)).assertEqual(Phone.TYPE_OTHER);
      expect(Phone.apiTypeToSystemType(12)).assertEqual(Phone.TYPE_MAIN);
      expect(Phone.apiTypeToSystemType(111)).assertEqual(Phone.TYPE_MOBILE);
    })

  })
}