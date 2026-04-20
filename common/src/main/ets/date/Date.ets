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
import { DateUtil } from '../util/DateUtil';

/*
 * 单年信息数据
 * */
export class YearData {
  public static readonly MONTH_OF_YEAR: number = 12;
  private _lunaYear: string = '';
  private months: MonthInfo[] = []

  constructor(solarYear: number) {
    this._solarYear = solarYear;
    this.months = new Array(YearData.MONTH_OF_YEAR)
    for (let i = 1; i <= YearData.MONTH_OF_YEAR; ++i) {
      this.months[i - 1] = new MonthInfo(this.solarYear, i)
    }
  }

  // 公历年份
  private _solarYear: number

  public get solarYear() {
    return this._solarYear
  }

  public get lunarYear() {
    return this._lunaYear
  }

  public set lunarYear(lunarYear: string) {
    this._lunaYear = lunarYear
  }

  getAllMonthInfo(): MonthInfo[] {
    return this.months;
  }

  getMonthInfo(solarMonth: number): MonthInfo | undefined {
    if (solarMonth < 1 || solarMonth > YearData.MONTH_OF_YEAR) {
      return undefined;
    }
    return this.months[solarMonth - 1]
  }
}

const LUNAR_CHINESE_TEXT: string = '农历';

export {
  LUNAR_CHINESE_TEXT
}

/*
 * 单月信息数据
 * */
export class MonthInfo {
  // 阳历月份
  private month: number;
  private year: number;
  private date: Date;
  private days: DayData[] = []

  constructor(solarYear: number, solarMonth: number) {
    this.month = solarMonth
    this.year = solarYear
    // Init with real month number
    this.date = new Date(solarYear, solarMonth, 0)
    this.getDaysInfo()
  }

  getDaysInfo(): DayData[] {
    if (this.days.length != 0) {
      return this.days;
    }
    this.days = [];
    let dayNum = this.date.getDate();

    for (let i = 1; i <= dayNum; ++i) {
      this.days.push(new DayData(this.year, this.month, i))
    }
    return this.days;
  }

  getDayData(day: number): DayData | undefined {
    if (day <= 0 || day > this.days.length) {
      return undefined;
    }
    return this.days[day - 1];
  }

  getMonth(): number {
    return this.month
  }
}

/*
 * 单天信息数据
 * */
export class DayData {
  private static readonly WEEKDAYS: number = 7;
  public dayMarkValue: string = '';
  public isToday: boolean = false;
  protected _date: Date;
  // 星期
  private _weekDay: number = -1; // 星期索引 0:星期天; 1：星期1
  private _lunaDay: number = -1; // 农历索引

  // 使用本地时间初始化
  constructor(solarYear: number, solarMonth: number, solarDay: number) {
    this._solarYear = solarYear
    this._solarMonth = solarMonth
    this._solarDay = solarDay
    this._date = new Date(DateUtil.dateToStamp(solarYear, solarMonth - 1, solarDay)) // 为了保证getDay正常
  }

  private _isSelected?: boolean;

  public get isSelected(): boolean {
    return this._isSelected ? this._isSelected : false;
  }

  public set isSelected(isSelected: boolean) {
    this._isSelected = isSelected;
  }

  // 公历天
  private _solarYear: number;

  public get solarYear() {
    return this._solarYear
  }

  public set solarYear(solarYear: number) {
    this._solarYear = solarYear;
    this._date.setFullYear(solarYear);
  }

  private _solarMonth: number;

  public get solarMonth() {
    return this._solarMonth
  }

  public set solarMonth(solarMonth: number) {
    this._solarMonth = solarMonth;
    this._date.setMonth(solarMonth - 1);
  }

  private _solarDay: number;

  public get solarDay() {
    return this._solarDay
  }

  public set solarDay(solarDay: number) {
    this._solarDay = solarDay;
    this._date.setDate(solarDay);
  }

  public get lunarDay() {
    return this._lunaDay
  }

  public set lunarDay(lunarDay: number) {
    this._lunaDay = lunarDay
  }

  private _lunaMonth: number = -1; // 农历索引

  public get lunaMonth() {
    return this._lunaMonth
  }

  public set lunaMonth(lunaMonth: number) {
    this._lunaMonth = lunaMonth
  }

  static buildByDate(date: Date): DayData {
    let dayData = new DayData(date.getFullYear(), date.getMonth() + 1, date.getDate())
    return dayData;
  }
}