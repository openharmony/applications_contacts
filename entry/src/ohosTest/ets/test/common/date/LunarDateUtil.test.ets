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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import { LunarDateUtil } from '../../../../../../../common/src/main/ets/date/LunarDateUtil';
import { DateManager } from '../../../../../../../common/src/main/ets/date/DateManager';
import { DayData } from '../../../../../../../common/src/main/ets/date/Date';

export default function LunarDateUtilTest() {
  describe('LunarDateUtilTest', () => {

    it('LunarDateUtilTest_getLunarDateShow', 0, () => {
      let chineseDate: DayData = new DayData(2025, 5, 21);
      chineseDate.lunaMonth = 13;
      let mocker: MockKit = new MockKit();
      let getDayData: Function = mocker.mockFunc(DateManager.getInstance(), DateManager.getInstance().getDayData);
      when(getDayData)().afterReturn(undefined);
      let date1 = new Date(2024, 11, 5);
      expect(LunarDateUtil.getLunarDateShow(date1)).assertEqual('');

      let date2 = new Date(2025, 5, 21);
      when(getDayData)(date2.getFullYear()).afterReturn(chineseDate);
      expect(LunarDateUtil.getLunarDateShow(date2)).assertEqual('2025年闰正月初');
      mocker.clear(DateManager.getInstance());

      let date = new Date(2024, 11, 5);
      expect(LunarDateUtil.getLunarDateShow(date)).assertEqual('2024年冬月初五');
    })

    it('LunarDateUtilTest_getLunarDate', 0, () => {
      let mocker: MockKit = new MockKit();
      let getDayData: Function = mocker.mockFunc(DateManager.getInstance(), DateManager.getInstance().getDayData);
      when(getDayData)().afterReturn(undefined);
      let date1 = new Date(2024, 11, 5);
      expect(LunarDateUtil.getLunarDate(date1)).assertEqual('');

      let date2 = new Date(2025, 5, 21);
      let chineseDate: DayData = new DayData(2025, 5, 21);
      chineseDate.lunaMonth = 13;
      when(getDayData)(date2.getFullYear()).afterReturn(chineseDate);
      expect(LunarDateUtil.getLunarDate(date2)).assertEqual('闰正月初');

      mocker.clear(DateManager.getInstance());

      let date = new Date(2024, 11, 5);
      expect(LunarDateUtil.getLunarDate(date)).assertEqual('2024甲辰龙年冬月初五');
    })

    it('LunarDateUtilTest_getChineseYearReal', 0, () => {
      expect(LunarDateUtil.getChineseYearReal(2024)).assertEqual('甲辰龙年');
    })

    it('LunarDateUtilTest_getChineseMonth', 0, () => {
      expect(LunarDateUtil.getChineseMonth(13)).assertEqual('');
      expect(LunarDateUtil.getChineseMonth(1)).assertEqual('正月');
      expect(LunarDateUtil.getChineseMonth(11)).assertEqual('冬月');
      expect(LunarDateUtil.getChineseMonth(12)).assertEqual('腊月');
      let mLunarMonth = 7;
      expect(LunarDateUtil.getChineseMonth(mLunarMonth)).assertEqual('七月');
    })

    it('LunarDateUtilTest_getChineseNum', 0, () => {
      expect(LunarDateUtil.getChineseNum(-1)).assertEqual('');
      expect(LunarDateUtil.getChineseNum(11)).assertEqual('十一');
      expect(LunarDateUtil.getChineseNum(20)).assertEqual('二十');
      expect(LunarDateUtil.getChineseNum(27)).assertEqual('廿七');
      expect(LunarDateUtil.getChineseNum(30)).assertEqual('三十');
    })

    it('LunarDateUtilTest_getChineseHeavenlyEarthly', 0, () => {
      expect(LunarDateUtil.getChineseHeavenlyEarthly(1800)).assertEqual('');
      expect(LunarDateUtil.getChineseHeavenlyEarthly(2024)).assertEqual('甲辰');
    })

    it('LunarDateUtilTest_getZodiac', 0, () => {
      expect(LunarDateUtil.getZodiac(2024)).assertEqual('龙');
      expect(LunarDateUtil.getRun()).assertEqual('闰')
    })

    it('LunarDateUtilTest_getChineseDay', 0, () => {
      expect(LunarDateUtil.getChineseDay(7)).assertEqual('初七');
      expect(LunarDateUtil.getChineseDay(11)).assertEqual('十一');
    })
  })
}