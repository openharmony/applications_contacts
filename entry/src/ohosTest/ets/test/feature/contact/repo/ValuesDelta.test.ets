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
import { describe, it, expect, beforeEach, MockKit, when } from '@ohos/hypium'
import { CallLog } from '../../../../../../../../feature/call';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import ValuesDelta from '../../../../../../../../feature/contact/src/main/ets/repo/ValuesDelta';


export default function ValuesDeltaTest() {
  describe('ValuesDeltaTest', () => {

    let valuesDelta: ValuesDelta<CallLog>;

    beforeEach(() => {
      valuesDelta = new ValuesDelta<CallLog>();
    })

    it('ValuesDeltaTest_fromValues', 0, () => {
      let values: Map<string, CallLog> = new Map<string, CallLog>();
      values.set("1", new CallLog(new CallLogBuilder(1, "11")))

      let res: ValuesDelta<CallLog> = ValuesDelta.fromValues(values);

      expect(res.before.size).assertEqual(1);
    })

    it('ValuesDeltaTest_getValue_if', 0, () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, "11"));
      valuesDelta.after.set('1', callLog);

      let res: CallLog | undefined = valuesDelta.getValue('1');

      expect(res).assertDeepEquals(callLog);
    })

    it('ValuesDeltaTest_getValue_else', 0, () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, "11"));
      valuesDelta.before.set('1', callLog);

      let res: CallLog | undefined = valuesDelta.getValue('1');

      expect(res).assertDeepEquals(callLog);
    })

    it('ValuesDeltaTest_getValue_notIf_noElse', 0, () => {
      let res: CallLog | undefined = valuesDelta.getValue('1');

      expect(res).assertUndefined();
    })

    it('ValuesDeltaTest_putValue', 0, () => {
      valuesDelta.putValue("1", new CallLog(new CallLogBuilder(1, "11")))

      expect(valuesDelta.after.size).assertEqual(1);
    })

    it('ValuesDeltaTest_isInsert', 0, () => {
      let flag = valuesDelta.isInsert();

      expect(flag).assertTrue();
    })

    it('ValuesDeltaTest_isDelete1', 0, () => {
      let flag = valuesDelta.isDelete();

      expect(flag).assertFalse();
    })

    it('ValuesDeltaTest_isDelete2', 0, () => {
      valuesDelta.before.set('id', new CallLog(new CallLogBuilder(1, '570977632')));

      let flag = valuesDelta.isDelete();

      expect(flag).assertFalse();
    })

    it('ValuesDeltaTest_isUpdate_if1', 0, () => {
      let flag = valuesDelta.isUpdate();
      expect(flag).assertFalse();
    })

    it('ValuesDeltaTest_isUpdate_if2', 0, () => {
      valuesDelta.before.set('id', new CallLog(new CallLogBuilder(1, '570977632')));

      let flag = valuesDelta.isUpdate();
      expect(flag).assertFalse();
    })

    it('ValuesDeltaTest_isUpdate_for_false', 0, () => {
      valuesDelta.before.set('id', new CallLog(new CallLogBuilder(1, '570977632')));
      valuesDelta.after.set('0', new CallLog(new CallLogBuilder(1, '570977632')));

      let flag = valuesDelta.isUpdate();

      expect(flag).assertFalse();
    })

    it('ValuesDeltaTest_isUpdate_for_true', 0, () => {
      valuesDelta.before.set('id', new CallLog(new CallLogBuilder(1, '570977632')));
      valuesDelta.after.set('id', new CallLog(new CallLogBuilder(1, '570977632')));

      let flag = valuesDelta.isUpdate();

      expect(flag).assertFalse();
    })

  })
}