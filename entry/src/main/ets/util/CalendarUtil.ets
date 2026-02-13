/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import i18n from '@ohos.i18n';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import { GetLunarDateRe } from '../model/type';

const YEAR_CONVERT: number = 2697;
const YEAR_CYCLE: number = 60;
const LUNAR_MONTH = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '腊'];
const LUNAR_DAY = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十', '十一', '十二', '十三', '十四',
'十五', '十六', '十七', '十八', '十九', '廿十', '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十',
'三一'];
const NUM_CHAR = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
const TAG = 'CalendarUtil'

/**
 * Calendar Util
 */
class CalendarUtil {
  //Gregorian calendar to lunar calendar
  getLunarDate(date: Date) {
    let calendar: i18n.Calendar = i18n.getCalendar('zh-CN', 'chinese');
    calendar.setTime(date);
    let lunarYear: number = calendar.get('era') * YEAR_CYCLE + calendar.get('year') - YEAR_CONVERT;
    let lunarMonth: number = calendar.get('month');
    let lunarDay: number = calendar.get('date');

    let calendarHansPrev: i18n.Calendar = i18n.getCalendar('zh-Hans');
    calendarHansPrev.set(date.getFullYear(), date.getMonth(),
      date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds());
    calendarHansPrev.add('month', 1);
    let nextMonthDate: Date = new Date(calendarHansPrev.get('year'), calendarHansPrev.get('month'),
      calendarHansPrev.get('date'), calendarHansPrev.get('hour'), calendarHansPrev.get('minute'),
      calendarHansPrev.get('second'));
    calendar.setTime(nextMonthDate);
    let lunarMonthNext: number = calendar.get('month');
    let isLeapMonth: boolean = (lunarMonth === lunarMonthNext);

    let getLunarDateReData: GetLunarDateRe = {
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeapMonth
    }
    return getLunarDateReData
  }

  formatLunarDate(lunar: GetLunarDateRe, retYear:boolean = true) {
    if (!lunar) {
      return '';
    }
    let result: string = '';
    if (lunar.year && retYear) {
      result += `${lunar.year}年`
    }
    if (lunar.month != undefined) {
      if (lunar.isLeapMonth) {
        result += `闰` + `${LUNAR_MONTH[lunar.month - 1]}月`
      } else {
        result += `${LUNAR_MONTH[lunar.month]}月`
      }
    }
    if (lunar.day) {
      result += `${LUNAR_DAY[lunar.day - 1]}`
    }
    return result;
  }

  //Obtain Gregorian calendar date to the last day of the lunar calendar each year
  getLunarCalendarLastDay(lunarDate: string) {
    HiLog.i(TAG, 'gregorian date of the first day of the next year: ' + lunarDate);
    let date: Date = new Date(lunarDate)
    date.setDate(date.getDate() - 1)
    let lunarDatePrev: string = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    HiLog.i(TAG, 'lunar date of the last day of the year: ' + lunarDatePrev);
    return lunarDatePrev;
  }
}

export default new CalendarUtil();




