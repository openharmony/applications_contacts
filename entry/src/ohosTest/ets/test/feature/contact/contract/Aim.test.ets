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
import { Aim } from '../../../../../../../../feature/contact/src/main/ets/contract/Aim'
import { contact } from '@kit.ContactsKit'
import PhoneAccountType from '../../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';

export default function AimTest() {
  describe('AimTest', () => {
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
    it('AimTest_getTypeLabelResource', 0, () => {
      const imgSrc1: Resource = Aim.getTypeLabelResource(Aim.TYPE_AIM);
      const expectedImgSrc1: Resource = $r("app.string.instant_type_aim");
      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));

      const imgSrc2: Resource = Aim.getTypeLabelResource(Aim.TYPE_WINDOWSLIVE);
      const expectedImgSrc2: Resource = $r("app.string.instant_type_windowslive");
      expect(JSON.stringify(imgSrc2)).assertEqual(JSON.stringify(expectedImgSrc2));

      const imgSrc3: Resource = Aim.getTypeLabelResource(Aim.TYPE_YAHOO);
      const expectedImgSrc3: Resource = $r("app.string.instant_type_yahoo");
      expect(JSON.stringify(imgSrc3)).assertEqual(JSON.stringify(expectedImgSrc3));

      const imgSrc4: Resource = Aim.getTypeLabelResource(Aim.TYPE_SKYPE);
      const expectedImgSrc4: Resource = $r("app.string.instant_type_skype");
      expect(JSON.stringify(imgSrc4)).assertEqual(JSON.stringify(expectedImgSrc4));

      const imgSrc5: Resource = Aim.getTypeLabelResource(Aim.TYPE_QQ);
      const expectedImgSrc5: Resource = $r("app.string.instant_type_qq");
      expect(JSON.stringify(imgSrc5)).assertEqual(JSON.stringify(expectedImgSrc5));

      const imgSrc6: Resource = Aim.getTypeLabelResource(Aim.TYPE_HANGOUTS);
      const expectedImgSrc6: Resource = $r("app.string.instant_type_hangouts");
      expect(JSON.stringify(imgSrc6)).assertEqual(JSON.stringify(expectedImgSrc6));

      const imgSrc7: Resource = Aim.getTypeLabelResource(Aim.TYPE_ICQ);
      const expectedImgSrc7: Resource = $r("app.string.instant_type_icq");
      expect(JSON.stringify(imgSrc7)).assertEqual(JSON.stringify(expectedImgSrc7));

      const imgSrc8: Resource = Aim.getTypeLabelResource(Aim.TYPE_JABBER);
      const expectedImgSrc8: Resource = $r("app.string.instant_type_jabber");
      expect(JSON.stringify(imgSrc8)).assertEqual(JSON.stringify(expectedImgSrc8));

      const imgSrc9: Resource = Aim.getTypeLabelResource(Aim.TYPE_CUSTOM);
      const expectedImgSrc9: Resource = $r("app.string.instant_type_custom");
      expect(JSON.stringify(imgSrc9)).assertEqual(JSON.stringify(expectedImgSrc9));

      const imgSrc10: Resource = Aim.getTypeLabelResource(9);
      const expectedImgSrc10: Resource = $r("app.string.instant_type_custom");
      expect(JSON.stringify(imgSrc10)).assertEqual(JSON.stringify(expectedImgSrc10));
    })

    it('AimTest_apiTypeToSystemType', 0, () => {
      expect(Aim.apiTypeToSystemType(contact.ImAddress.CUSTOM_LABEL)).assertEqual(PhoneAccountType.TYPE_ID_CUSTOM);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_AIM)).assertEqual(Aim.TYPE_AIM);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_YAHOO)).assertEqual(Aim.TYPE_YAHOO);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_SKYPE)).assertEqual(Aim.TYPE_SKYPE);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_QQ)).assertEqual(Aim.TYPE_QQ);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_ICQ)).assertEqual(Aim.TYPE_ICQ);
      expect(Aim.apiTypeToSystemType(contact.ImAddress.IM_JABBER)).assertEqual(Aim.TYPE_JABBER);
      expect(Aim.apiTypeToSystemType(777)).assertEqual(Aim.TYPE_AIM);
    })

  })
}