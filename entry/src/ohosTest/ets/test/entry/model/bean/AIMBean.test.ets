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
import { AIMBean } from '../../../../../../main/ets/model/bean/AIMBean'
import { contact } from '@kit.ContactsKit'

export default function AIMBeanTest() {
  describe('AIMBeanTest', () => {
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
    it('AIMBeanTest_constructor', 0, () => {
      let id:string = "123456";
      let selectTextCustom:string = "123456";
      let aimType:string = "1";
      let aimName:string = "1234567";
      let aimbean = new AIMBean(id, selectTextCustom, aimType, aimName);
      expect(aimbean.id).assertEqual("123456");
      expect(aimbean.selectTextCustom).assertEqual("123456");
      expect(aimbean.aimType).assertEqual("1");
      expect(aimbean.aimName).assertEqual("1234567");
    })

    it('AIMBeanTest_getBeanByPickerData', 0, () => {
      let aimBean: AIMBean = new AIMBean('', '', '1', '');
      let aim: contact.ImAddress = {
        imAddress: ''
      }
      expect(JSON.stringify(AIMBean.getBeanByPickerData(aim))).assertEqual(JSON.stringify(aimBean));
      let aimBean1: AIMBean = new AIMBean('', '', '1', 'imAddress');
      let aim1: contact.ImAddress = {
        imAddress: 'imAddress',
        labelId: -1
      }
      expect(JSON.stringify(AIMBean.getBeanByPickerData(aim1))).assertEqual(JSON.stringify(aimBean1));
      let aimBean2: AIMBean = new AIMBean('', 'labelName', '10000', 'imAddress');
      let aim2: contact.ImAddress = {
        imAddress: 'imAddress',
        labelId: -1,
        labelName: 'labelName'
      }
      expect(JSON.stringify(AIMBean.getBeanByPickerData(aim2))).assertEqual(JSON.stringify(aimBean2));

    })
  })
}