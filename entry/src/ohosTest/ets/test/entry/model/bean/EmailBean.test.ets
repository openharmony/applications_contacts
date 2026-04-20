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
import { EmailBean } from '../../../../../../main/ets/model/bean/EmailBean'
import { contact } from '@kit.ContactsKit'

export default function EmailBeanTest() {
  describe('EmailBeanTest', () => {
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
    it('EmailBeanTest_constructor', 0, () => {
      let cb = new EmailBean("2342424", "action", "12345678901")
      expect(cb.address).assertEqual('action')
    })

    it('EmailBeanTest_getBeanByPickerData', 0, () => {
      let emailBean: EmailBean = new EmailBean('', '', '1')
      let email: contact.Email = {
        email: ''
      }
      expect(JSON.stringify(EmailBean.getBeanByPickerData(email))).assertEqual(JSON.stringify(emailBean));
      let emailBean1: EmailBean = new EmailBean('', 'email', '1')
      let email1: contact.Email = {
        email: 'email',
        labelId: 0
      }
      expect(JSON.stringify(EmailBean.getBeanByPickerData(email1))).assertEqual(JSON.stringify(emailBean1));
      let emailBean2: EmailBean = new EmailBean('labelName', 'email', '10000')
      let email2: contact.Email = {
        email: 'email',
        labelId: 0,
        labelName: 'labelName'
      }
      expect(JSON.stringify(EmailBean.getBeanByPickerData(email2))).assertEqual(JSON.stringify(emailBean2));
    })
  })
}