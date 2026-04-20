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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { AIMBean } from '../../../../../main/ets/model/bean/AIMBean'
import { AssociatedPersonBean } from '../../../../../main/ets/model/bean/AssociatedPersonBean'
import { EmailBean } from '../../../../../main/ets/model/bean/EmailBean'
import { EventBean } from '../../../../../main/ets/model/bean/EventBean'
import { GroupBean } from '../../../../../main/ets/model/bean/GroupBean'
import { HouseBean } from '../../../../../main/ets/model/bean/HouseBean'
import { PhoneNumBean } from '../../../../../main/ets/model/bean/PhoneNumBean'
import { ContactInfoUtil } from '../../../../../main/ets/util/ContactInfoUtil'

export default function ContactInfoUtilTest() {
  describe('ContactInfoUtilTest', () => {
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
    it('ContactInfoUtilTest_isPhoneNumEquals', 0, () => {
      let original1: PhoneNumBean | undefined;
      let other1: PhoneNumBean | undefined;
      let original: PhoneNumBean = new PhoneNumBean('1', '13366669999', '1', '1', '2');
      let other: PhoneNumBean = new PhoneNumBean('1', '13366669999', '1', '1', '2');
      expect(ContactInfoUtil.isPhoneNumEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isPhoneNumEquals(original1 as PhoneNumBean, other1 as PhoneNumBean)).assertTrue();
      expect(ContactInfoUtil.isPhoneNumEquals(original1 as PhoneNumBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isEmailEquals', 0, () => {
      let original1: EmailBean | undefined;
      let other1: EmailBean | undefined;
      let original: EmailBean = new EmailBean('1', '1', '1');
      let other: EmailBean = new EmailBean('1', '1', '1');
      expect(ContactInfoUtil.isEmailEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isEmailEquals(original1 as EmailBean, other1 as EmailBean)).assertTrue();
      expect(ContactInfoUtil.isEmailEquals(original1 as EmailBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isAimEquals', 0, () => {
      let original1: AIMBean | undefined;
      let other1: AIMBean | undefined;
      let original: AIMBean = new AIMBean('1', '1', '1', '1');
      let other: AIMBean = new AIMBean('1', '1', '1', '1');
      expect(ContactInfoUtil.isAimEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isAimEquals(original1 as AIMBean, other1 as AIMBean)).assertTrue();
      expect(ContactInfoUtil.isAimEquals(original1 as AIMBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isHouseEquals', 0, () => {
      let original1: HouseBean | undefined;
      let other1: HouseBean | undefined;
      let original: HouseBean = new HouseBean('1', '1', '1', '1');
      let other: HouseBean = new HouseBean('1', '1', '1', '1');
      expect(ContactInfoUtil.isHouseEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isHouseEquals(original1 as HouseBean, other1 as HouseBean)).assertTrue();
      expect(ContactInfoUtil.isHouseEquals(original1 as HouseBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isRelationshipEquals', 0, () => {
      let original1: AssociatedPersonBean | undefined;
      let other1: AssociatedPersonBean | undefined;
      let original: AssociatedPersonBean = new AssociatedPersonBean('1', '1', '1', '1');
      let other: AssociatedPersonBean = new AssociatedPersonBean('1', '1', '1', '1');
      expect(ContactInfoUtil.isRelationshipEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isRelationshipEquals(original1 as AssociatedPersonBean, other1 as AssociatedPersonBean)).assertTrue();
      expect(ContactInfoUtil.isRelationshipEquals(original1 as AssociatedPersonBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isEventEquals', 0, () => {
      let original1: EventBean | undefined;
      let other1: EventBean | undefined;
      let original: EventBean = new EventBean('1', '1', '1', '1');
      let other: EventBean = new EventBean('1', '1', '1', '1');
      expect(ContactInfoUtil.isEventEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isEventEquals(original1 as EventBean, other1 as EventBean)).assertTrue();
      expect(ContactInfoUtil.isEventEquals(original1 as EventBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_isGroupEquals', 0, () => {
      let original1: GroupBean | undefined;
      let other1: GroupBean | undefined;
      let original: GroupBean = new GroupBean(1, '1', '1', '1', '1', '1', 1, 1);
      let other: GroupBean = new GroupBean(1, '1', '1', '1', '1', '1', 1, 1);
      expect(ContactInfoUtil.isGroupEquals(original, other)).assertTrue();
      expect(ContactInfoUtil.isGroupEquals(original1 as GroupBean, other1 as GroupBean)).assertTrue();
      expect(ContactInfoUtil.isGroupEquals(original1 as GroupBean, other)).assertFalse();
    })

    it('ContactInfoUtilTest_filterRemovePhones', 0, () => {
      let original: PhoneNumBean = new PhoneNumBean('1', '13366669999', '1', '1', '2');
      let needRemove: PhoneNumBean = new PhoneNumBean('2', '13366669993', '2', '2', '1');
      let originals: PhoneNumBean[] = [];
      originals.push(original);
      let needRemoves: PhoneNumBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemovePhones(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: PhoneNumBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isPhoneNumEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemovePhones(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveEmails', 0, () => {
      let original: EmailBean = new EmailBean('1', '1', '1');
      let needRemove: EmailBean = new EmailBean('2', '2', '2');
      let originals: EmailBean[] = [];
      originals.push(original);
      let needRemoves: EmailBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveEmails(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: EmailBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isEmailEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveEmails(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveAims', 0, () => {
      let original: AIMBean = new AIMBean('1', '1', '1', '1');
      let needRemove: AIMBean = new AIMBean('2', '2', '2', '2');
      let originals: AIMBean[] = [];
      originals.push(original);
      let needRemoves: AIMBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveAims(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: AIMBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isAimEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveAims(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveHouses', 0, () => {
      let original: HouseBean = new HouseBean('1', '1', '1', '1');
      let needRemove: HouseBean = new HouseBean('2', '2', '2', '2');
      let originals: HouseBean[] = [];
      originals.push(original);
      let needRemoves: HouseBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveHouses(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: HouseBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isHouseEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveHouses(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveWebsites', 0, () => {
      let original: string[] = ['1', '1'];
      let needRemove: string[] = ['2', '2'];
      expect(JSON.stringify(ContactInfoUtil.filterRemoveWebsites(original, needRemove)))
        .assertEqual(JSON.stringify(original));
    })

    it('ContactInfoUtilTest_filterRemoveRelationships', 0, () => {
      let original:AssociatedPersonBean = new AssociatedPersonBean('1', '1', '1', '1');
      let needRemove:AssociatedPersonBean = new AssociatedPersonBean('2', '2', '2', '2');
      let originals: AssociatedPersonBean[] = [];
      originals.push(original);
      let needRemoves: AssociatedPersonBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveRelationships(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: AssociatedPersonBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isRelationshipEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveRelationships(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveEvents', 0, () => {
      let original:EventBean = new EventBean('1', '1', '1', '1');
      let needRemove:EventBean = new EventBean('2', '2', '2', '2');
      let originals: EventBean[] = [];
      originals.push(original);
      let needRemoves: EventBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveEvents(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: EventBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isEventEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveEvents(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })

    it('ContactInfoUtilTest_filterRemoveGroups', 0, () => {
      let original:GroupBean = new GroupBean(1, '1', '1', '1', '1', '1', 1, 1);
      let needRemove:GroupBean = new GroupBean(2, '2', '2', '2', '2', '2', 2, 2);
      let originals: GroupBean[] = [];
      originals.push(original);
      let needRemoves: GroupBean[] = [];
      needRemoves.push(needRemove);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveGroups(originals, needRemoves)))
        .assertEqual(JSON.stringify(originals));

      let result: GroupBean[] = [];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.isGroupEquals))(ArgumentMatchers.any).afterReturn(true);
      expect(JSON.stringify(ContactInfoUtil.filterRemoveGroups(originals, needRemoves)))
        .assertEqual(JSON.stringify(result));
      mocker.clear(ContactInfoUtil);
    })
  })
}