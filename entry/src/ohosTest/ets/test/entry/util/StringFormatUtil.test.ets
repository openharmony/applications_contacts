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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import StringFormatUtil from '../../../../../main/ets/util/StringFormatUtil';
import { DTGlobalContext } from '../../../testability/TestAbility';
import common from '@ohos.app.ability.common';

export default function StringFormatUtilTest() {
  describe('StringFormatUtilTest', () => {

    it('StringFormatUtilTest_formatLocaleDateString', 0, () => {
      const date: Resource = StringFormatUtil.formatLocaleDateString("1/1/2024") as Resource;
      const expectedResult = '2024年1月1日';
      expect(JSON.stringify(date)).assertEqual(JSON.stringify(expectedResult));
    })

    it('StringFormatUtilTest_numberFormatDateString', 0, () => {
      const result = StringFormatUtil.numberFormatDateString(2023, 1, 1);
      const expectedResult = '2023-01-01';
      expect(result).assertEqual(expectedResult);
    })

    it('StringFormatUtilTest_stringFormatDateResource', 0, () => {
      const date = StringFormatUtil.stringFormatDateResource('2023-1-1', false);
      const expectedDate= '2023年1月1日';
      expect(JSON.stringify(date)).assertEqual(JSON.stringify(expectedDate));

      const lunarDate: string = StringFormatUtil.stringFormatDateResource('2023-1-1', true) as string;
      const expectedLunarDate = "2022年腊月";
      expect(lunarDate.slice(0, 7)).assertEqual(expectedLunarDate);
    })

    it('StringFormatUtilTest_stringFormatDateResource01', 0, () => {
      const date = StringFormatUtil.stringFormatDateResource('--12-13', true);
      const expectedDate= '冬月初七';
      expect(JSON.stringify(date)).assertEqual(JSON.stringify(expectedDate));

      const date1 = StringFormatUtil.stringFormatDateResource('--12-12', false);
      const expectedDate1= '12月12日';
      expect(JSON.stringify(date1)).assertEqual(JSON.stringify(expectedDate1));
    })

    it('StringFormatUtilTest_judgeSysTime', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.TimeFormatName)
        .afterReturn('12');
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let message1 = StringFormatUtil.judgeSysTime(context);

      expect(message1).assertEqual('12');

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('StringFormatUtilTest_judgeSysTime_timeFormat_undefined', 0, () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.TimeFormatName)
        .afterReturn(undefined);

      let message1 = StringFormatUtil.judgeSysTime();

      expect(message1).assertEqual('12');

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('StringFormatUtilTest_getDayMessage', 0, () => {
      const dayMessage = StringFormatUtil.getDayMessage(2024, 7, 26, 3, '21');
      expect(typeof dayMessage).assertEqual('object');

      const dayMessage1 = StringFormatUtil.getDayMessage(2024, 7, 26, 7, '21');
      expect(typeof dayMessage1).assertEqual('object');

      const dayMessage2 = StringFormatUtil.getDayMessage(2024, 7, 26, 11, '21');
      expect(typeof dayMessage2).assertEqual('object');

      const dayMessage3 = StringFormatUtil.getDayMessage(2024, 7, 26, 12, '21');
      expect(typeof dayMessage3).assertEqual('object');

      const dayMessage4 = StringFormatUtil.getDayMessage(2024, 7, 26, 18, '21');
      expect(typeof dayMessage4).assertEqual('object');

      const dayMessage5 = StringFormatUtil.getDayMessage(2024, 7, 26, 23, '21');
      expect(typeof dayMessage5).assertEqual('object');

      const dayMessage11 = StringFormatUtil.getDayMessage(2024, 7, 6, 3, '30');
      expect(typeof dayMessage11).assertEqual('object');

      const dayMessage22 = StringFormatUtil.getDayMessage(2024, 7, 6, 22, '30');
      expect(typeof dayMessage22).assertEqual('object');
    })

    it('StringFormatUtilTest_clearPhoneNumberSymbols', 0, () => {
      const phoneNumber1 = StringFormatUtil.clearPhoneNumberSymbols('');
      expect(phoneNumber1).assertEqual('');

      const phoneNumber2 = StringFormatUtil.clearPhoneNumberSymbols('123456');
      expect(phoneNumber2).assertEqual('123456');

      const phoneNumber3 = StringFormatUtil.clearPhoneNumberSymbols('1234;56');
      expect(phoneNumber3).assertEqual('1234');

      const phoneNumber4 = StringFormatUtil.clearPhoneNumberSymbols('123,456');
      expect(phoneNumber4).assertEqual('123');

      const phoneNumber5 = StringFormatUtil.clearPhoneNumberSymbols('12,34;56');
      expect(phoneNumber5).assertEqual('12');

      const phoneNumber6 = StringFormatUtil.clearPhoneNumberSymbols('1;2345,6');
      expect(phoneNumber6).assertEqual('1');
    })

    it('StringFormatUtilTest_undefinedYearDate2To1', 0, () => {
      let date: string = '2024-12-12';
      expect(StringFormatUtil.undefinedYearDate2To1(date)).assertEqual('2024-12-12');

      let date1: string = '2025-12-13';
      expect(StringFormatUtil.undefinedYearDate2To1(date1)).assertEqual('2025-12-13');

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(Number, Number.parseInt);
      when(mockFunc)(ArgumentMatchers.any).afterThrow('error');
      mocker.clear(Number);
    })

    it('StringFormatUtilTest_undefinedYearDate2To1_02', 0, () => {
      let date: string = '1900-12-12';
      expect(StringFormatUtil.undefinedYearDate2To1(date)).
      assertEqual(new Date().getFullYear() + date.slice(date.indexOf('-')));
    })

    it('StringFormatUtilTest_checkEventValid', 0, () => {
      let result: Boolean = StringFormatUtil.checkEventValid(undefined);
      expect(result).assertFalse();

      let result1: Boolean = StringFormatUtil.checkEventValid('-123-456-789');
      expect(result1).assertTrue();
    })
  })
}