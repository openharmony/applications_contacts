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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import RawContactDelta from '../../../../../../../../feature/contact/src/main/ets/repo/RawContactDelta';
import { ValueType } from '@ohos.data.ValuesBucket';
import RawContact from '../../../../../../../../feature/contact/src/main/ets/entity/RawContact';
import ValuesDelta from '../../../../../../../../feature/contact/src/main/ets/repo/ValuesDelta';

export default function RawContactDeltaTest() {
  let rd:RawContactDelta = new RawContactDelta();
  describe('RawContactDeltaTest', () => {
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
    it('RawContactDeltaTest_fromRawContact', 0, () => {
      let rc1: RawContact | undefined;
      let res1 = RawContactDelta.fromRawContact(rc1 as RawContact);
      expect(res1).assertUndefined();

      let vu: Map<string, number | string> = new Map<string, number | string>();
      let rc: RawContact = new RawContact(1,vu);
      let res = RawContactDelta.fromRawContact(rc);
      expect(res).not().assertEqual(undefined);
    })
    it('RawContactDeltaTest_addDataValue1', 0, () => {
      let dataValue: ValuesDelta<string | number> | undefined = new ValuesDelta<string | number>();
      dataValue.putValue("1",2)
      rd.addDataValue(dataValue);
      dataValue.putValue("type_id",2)
      rd.addDataValue(dataValue);
      expect(rd.dataValues.size).assertEqual(1);
      let dataValue1: ValuesDelta<string | number> | undefined = new ValuesDelta<string | number>();
      dataValue1.putValue("1",2)
      dataValue1.putValue("type_id",2)
      dataValue1.putValue("2",4)
      rd.addDataValue(dataValue);
      expect(dataValue1.getValue("2")).assertEqual(4);
    })
    it('RawContactDeltaTest_isContactInsert', 0, () => {
      let flag = rd.isContactInsert();
      expect(flag).assertEqual(true);
    })
    it('RawContactDeltaTest_isContactDelete', 0, () => {
      let flag = rd.isContactDelete();
      expect(flag).assertEqual(false);
    })

  })
}