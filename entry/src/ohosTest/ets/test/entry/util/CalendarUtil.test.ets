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
import { describe, it, expect } from '@ohos/hypium'
import { GetLunarDateRe } from '../../../../../main/ets/model/type'
import CalendarUtil from '../../../../../main/ets/util/CalendarUtil'

export default function CalendarUtilTest() {
  describe('CalendarUtilTest', () => {

    it('CalendarUtilTest_getLunarDate0', 0, () => {
      const date = new Date(2023, 0, 1);
      const lunarDate = CalendarUtil.getLunarDate(date);
      expect(lunarDate.month).assertEqual(11);
    })

    it('CalendarUtilTest_formatLunarDate1', 0, () => {
      const lunarDateRe: GetLunarDateRe = {
        year: 2022,
        month: 11,
        day: 10,
        isLeapMonth: false
      };
      const lunarDate = CalendarUtil.formatLunarDate(lunarDateRe);
      const expectedData = '2022年腊月';
      expect(lunarDate.slice(0,7)).assertEqual(expectedData);

      lunarDateRe.isLeapMonth = true;
      expect(CalendarUtil.formatLunarDate(lunarDateRe)).assertEqual('2022年闰十一月初十');
    })

    it('CalendarUtilTest_formatLunarDate_luna_noYear', 0, () => {
      const lunarDateRe: GetLunarDateRe = {
      } as GetLunarDateRe;

      const lunarDate = CalendarUtil.formatLunarDate(lunarDateRe);

      expect(lunarDate).assertEqual('');
    })

    it('CalendarUtilTest_getLunarCalendarLastDay',0,()=>{
      let result:string = CalendarUtil.getLunarCalendarLastDay('2024-1-20');
      expect(result).assertEqual('2024-1-19');
    })
  })
}