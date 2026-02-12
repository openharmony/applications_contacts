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
import { PhoneNumBean } from '../../../../../../main/ets/model/bean/PhoneNumBean'
import { contact } from '@kit.ContactsKit';

export default function PhoneNumBeanTest() {
  describe('PhoneNumBeanTest', () => {
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
    it('PhoneNumBeanTest_constructor', 0, () => {
      let cb = new PhoneNumBean("2314","23", "3434", "23","1",true,-1);
      expect(cb.selectTextCustom).assertEqual("2314");
    })

    it('PhoneNumBeanTest_getBeanByPickerData', 0, () => {
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '1', '', '');
      let phone: contact.PhoneNumber = {
        phoneNumber: ''
      }
      expect(JSON.stringify(PhoneNumBean.getBeanByPickerData(phone))).assertEqual(JSON.stringify(phoneNumBean));
      let phoneNumBean1: PhoneNumBean = new PhoneNumBean('', '13801001234', '1', '', '');
      let phone1: contact.PhoneNumber = {
        phoneNumber: '13801001234',
        labelId: 0
      }
      expect(JSON.stringify(PhoneNumBean.getBeanByPickerData(phone1))).assertEqual(JSON.stringify(phoneNumBean1));
      let phoneNumBean2: PhoneNumBean = new PhoneNumBean('labelName', '13801001234', '10000', '', '');
      let phone2: contact.PhoneNumber = {
        phoneNumber: '13801001234',
        labelId: 0,
        labelName: 'labelName'
      }
      expect(JSON.stringify(PhoneNumBean.getBeanByPickerData(phone2))).assertEqual(JSON.stringify(phoneNumBean2));
    })
  })
}