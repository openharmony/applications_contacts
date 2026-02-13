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
import { HouseBean } from '../../../../../../main/ets/model/bean/HouseBean'
import { contact } from '@kit.ContactsKit';

export default function HouseBeanTest() {
  describe('HouseBeanTest', () => {
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
    it('HouseBeanTest_constructor', 0, () => {
      let cb = new HouseBean( "121222","false", "true","member");
      expect(cb.id).assertEqual("121222")
    })

    it('HouseBeanTest_getBeanByPickerData', 0, () => {
      let bean: HouseBean = new HouseBean('', '', '1', '')
      let house: contact.PostalAddress = {
        postalAddress: ''
      }
      expect(JSON.stringify(HouseBean.getBeanByPickerData(house))).assertEqual(JSON.stringify(bean));
      let bean1: HouseBean = new HouseBean('', '', '1', '123')
      let house1: contact.PostalAddress = {
        postalAddress: '123',
        labelId: 0
      }
      expect(JSON.stringify(HouseBean.getBeanByPickerData(house1))).assertEqual(JSON.stringify(bean1));
      let bean2: HouseBean = new HouseBean('', 'labelName', '10000', 'postalAddress')
      let house2: contact.PostalAddress = {
        postalAddress: 'postalAddress',
        labelId: 0,
        labelName: 'labelName'
      }
      expect(JSON.stringify(HouseBean.getBeanByPickerData(house2))).assertEqual(JSON.stringify(bean2));
    })
  })
}