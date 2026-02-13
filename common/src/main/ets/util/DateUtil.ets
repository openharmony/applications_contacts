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
/**
 * 日期工具类
 *
 * @since 2022-03-21
 */

export const HOURS_PER_DAY = 24;

// 一周7天
export const DAY_PER_WEEK: number = 7;

// 一年12个月
export const MONTH_PER_YEAR: number = 12;

// 一小时分钟数
export const MINUTES_PER_HOUR = 60;

// 一天分钟数
export const MINUTES_PER_DAY = MINUTES_PER_HOUR * HOURS_PER_DAY;

// 一分钟秒数
export const SECONDS_PER_MINUTE = 60;

// 一秒毫秒数
export const MILLS_PER_SECOND = 1000;

// 一分钟毫秒数
export const MILLS_PER_MINUTE = MILLS_PER_SECOND * SECONDS_PER_MINUTE;

// 一小时毫秒数
export const MILLS_PER_HOUR = MILLS_PER_MINUTE * MINUTES_PER_HOUR;

// 一天毫秒数
export const MILLS_PER_DAY = MILLS_PER_HOUR * HOURS_PER_DAY;

// 30天毫秒数
export const MILLS_THIRTY_DAYS = MILLS_PER_DAY * 30;

// 一周毫秒数
export const MILLS_PER_WEEK = MILLS_PER_DAY * DAY_PER_WEEK;

// 年份下限值：公元1年
export const YEAR_LOWER_LIMIT: number = 1;

// 月份下限值：公元1年1月
export const MONTH_LOWER_LIMIT: number = YEAR_LOWER_LIMIT * 12 + 0;

// 年份上限值：公元5000年
export const YEAR_UPPER_LIMIT: number = 5000;

// 月份上限值：公元5000年12月
export const MONTH_UPPER_LIMIT: number = YEAR_UPPER_LIMIT * 12 + 11;

// 农历显示开始时间：1900年1月1日
export const LUNAR_START_TIME: number = 1900;

// 农历显示结束时间：2100年12月31日
export const LUNAR_END_TIME: number = 2100;

export class DateUtil {
  /**
   * 根据年月日获取日期
   *
   * @param year 年
   * @param month 月，取值 0 ~ 11
   * @param day 日
   */
  static dateToStamp(year: number, month: number, day: number): number {
    const newDate = new Date(year, month, day);
    let newTimeStamp = newDate.getTime();
    if (newDate.getHours() !== 0) {
      newTimeStamp += (HOURS_PER_DAY - newDate.getHours()) * MILLS_PER_HOUR;
    }
    return newTimeStamp;
  }
}
