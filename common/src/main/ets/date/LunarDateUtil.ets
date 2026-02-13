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
import { DayData } from './Date';
import { DateManager } from './DateManager';
import { HiLog } from '../util/HiLog';

/* Chinese zodiac */
const ZODIAC: string[] =
  ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
const HEAVENLY_STEMS: string[] =
  ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
const JIAN_ZHI: string[] =
  ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

const LUNAR_STRING: string[] = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
/**
 * 12生肖计算时的偏移值
 */
const OFFSET_OF_ZODIAC: number = 4;
/**
 * 12生肖
 */
const SIZE_OF_ZODIAC: number = 12;
const BEGIN_CHINESE_ERA: number = 33;
const OFFSET_OF_TEN = 10;
const OFFSET_OF_TWENTY: number = 20;
const RUN: string = '闰';
const MONTH_SIZE: number = 12;
/**
 * 农历冬月是11月
 */
const MONTH_OF_DONG_YUE: number = 11;
/**
 * 农历腊月是12月
 */
const MONTH_OF_LA_YUE: number = 12;
/**
 * 农历正月是1月
 */
const MONTH_OF_ZHENG_YUE: number = 1;
//农历月份
const WINTERMONTH: string = '冬月';
const LASTMONTH: string = '腊月';
const FIRSTMONTH: string = '正月';

const YEAR_START: number = 1897;

const TAG: string = 'LunarDateUtil';

export class LunarDateUtil {

  /**
   * 农历具体日期
   * @param date
   * @returns
   */
  static getLunarDateShow(date: Date, retYear: boolean = true): string {
    let chineseMonth = ''
    const chineseDate: DayData | undefined = DateManager.getInstance().getDayData(date.getFullYear(),
      date.getMonth() + 1, date.getDate());
    if (!chineseDate) {
      HiLog.e(TAG, `chineseDate is null`);
      return '';
    }
    if (chineseDate.lunaMonth > MONTH_SIZE) {
      chineseMonth =
        LunarDateUtil.getRun() + LunarDateUtil.getChineseMonth(chineseDate.lunaMonth - MONTH_SIZE);
    } else {
      chineseMonth = LunarDateUtil.getChineseMonth(chineseDate.lunaMonth);
    }
    const lunarYear: number = LunarDateUtil.getLunarYear(date);
    let lunarDate = '';
    const chineseDay = LunarDateUtil.getChineseDay(chineseDate.lunarDay);
    if (lunarYear && retYear) {
      lunarDate += lunarYear + '年';
    }
    lunarDate += chineseMonth + chineseDay;
    return lunarDate;
  }

  /**
   * 农历具体日期
   * @param date
   * @returns
   */
  static getLunarDate(date: Date): string {
    let chineseMonth = ''
    const chineseDate: DayData | undefined = DateManager.getInstance().getDayData(date.getFullYear(),
      date.getMonth() + 1, date.getDate());
    if (!chineseDate) {
      HiLog.e(TAG, `chineseDate is null`);
      return '';
    }
    if (chineseDate.lunaMonth > MONTH_SIZE) {
      chineseMonth =
        LunarDateUtil.getRun() + LunarDateUtil.getChineseMonth(chineseDate.lunaMonth - MONTH_SIZE);
    } else {
      chineseMonth = LunarDateUtil.getChineseMonth(chineseDate.lunaMonth);
    }
    const lunarYear: number = LunarDateUtil.getLunarYear(date);
    const chineseYear = LunarDateUtil.getChineseYearReal(lunarYear);
    let lunarDate = '';
    const chineseDay = LunarDateUtil.getChineseDay(chineseDate.lunarDay);
    const now: Date = new Date();
    const currentLunarYear: number = LunarDateUtil.getLunarYear(now);
    if (lunarYear === currentLunarYear) {
      lunarDate = chineseMonth + chineseDay;
    } else {
      lunarDate = lunarYear + chineseYear + chineseMonth + chineseDay;
    }
    return lunarDate;
  }

  /**
   * 判断农历日期对应年份是否与阳历年份一致
   * @param date 阳历日期
   * @returns 农历日期对应年份
   */
  static getLunarYear(date: Date): number {
    // 十月
    const OCTOBER: number = 10;
    // 三月
    const MARCH: number = 3;
    const solarYear = date.getFullYear();
    const solarMonth = date.getMonth();
    let lunarYear = 0;
    const chineseDate: DayData | undefined = DateManager.getInstance().getDayData(date.getFullYear(),
      date.getMonth() + 1, date.getDate()) as DayData;
    let lunarMonth = chineseDate.lunaMonth;
    if (lunarMonth > MONTH_SIZE) {
      lunarMonth = lunarMonth - MONTH_SIZE;
    }
    // 如果阳历月份（一月，二月，三月）对应农历月份（腊月，冬月，十月），对应农历年份-1
    if (lunarMonth >= OCTOBER && solarMonth <= MARCH) {
      lunarYear = solarYear - 1;
    } else {
      lunarYear = solarYear;
    }
    return lunarYear;
  }

  /**
   * 获取农历年份，如：庚子鼠年
   * @return 农历年份
   */
  static getChineseYearReal(mLunarYear: number): string {
    const yearText = '年';
    return LunarDateUtil.getChineseHeavenlyEarthly(mLunarYear) +
    LunarDateUtil.getZodiac(mLunarYear) + yearText;
  }

  /**
   * 农历形式展示月份
   * @param mLunarMonth
   * @returns
   */
  static getChineseMonth(mLunarMonth: number): string {
    if (mLunarMonth <= 0 || mLunarMonth > MONTH_SIZE) {
      return '';
    }
    let chineseMonth = '';
    let normalMonthStr: string;
    switch (mLunarMonth) {
      case MONTH_OF_ZHENG_YUE:
        return FIRSTMONTH;
      case MONTH_OF_DONG_YUE:
        return WINTERMONTH;
      case MONTH_OF_LA_YUE:
        return LASTMONTH;
      default:
        break;
    }
    normalMonthStr = LunarDateUtil.getChineseNum(mLunarMonth) + '月';
    chineseMonth = chineseMonth + normalMonthStr;
    return chineseMonth;
  }

  /**
   * 农历形式展示数字
   * @param num
   * @returns
   */

  static getChineseNum(num: number): string {
    if (num < 0) {
      return '';
    }
    let convertNum = '';

    switch (Math.floor(num / OFFSET_OF_TEN)) {
      case 1: // 大于十小于十九，农历前缀为‘十’
        convertNum = '十';
        break;
      case 2: // 大于二十小于二十九，农历前缀为‘二十’
        if ((num % OFFSET_OF_TWENTY) === 0) {
          convertNum = '二十';
        } else {
          convertNum = '廿';
        }
        break;
      case 3: // 农历三十
        convertNum = '三十';
        break;
      default:
        break;
    }
    let offset = Math.floor(num % OFFSET_OF_TEN);
    if (offset !== 0) {
      convertNum = convertNum + LUNAR_STRING[offset];
    }
    return convertNum;
  }

  static getChineseHeavenlyEarthly(solarYear: number): string {
    let ganNum = (solarYear - YEAR_START + BEGIN_CHINESE_ERA) % 10;
    let zhiNum = (solarYear - YEAR_START + BEGIN_CHINESE_ERA) % 12;
    let result = '';
    let isGanNumValid = ganNum >= 0 && ganNum < HEAVENLY_STEMS.length;
    if (!isGanNumValid || zhiNum < 0 || zhiNum >= JIAN_ZHI.length) {
      return result;
    }
    result = HEAVENLY_STEMS[ganNum] + JIAN_ZHI[zhiNum];
    return result;
  }

  static getZodiac(mLunarYear: number, language?: string, isCard?: boolean): string {
    return ZODIAC[(mLunarYear - OFFSET_OF_ZODIAC) % SIZE_OF_ZODIAC];
  }

  static getChineseDay(lunarDay: number): string {
    let chineseDay = '';
    if (lunarDay <= OFFSET_OF_TEN) {
      chineseDay = chineseDay + '初';
    }
    return chineseDay + LunarDateUtil.getChineseNum(lunarDay);
  }

  static getRun() { // 获取闰
    return RUN;
  }
}