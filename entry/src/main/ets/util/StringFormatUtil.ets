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
import settings from '@ohos.settings';
import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { intl } from '@kit.LocalizationKit';
import { LunarDateUtil } from '../../../../../common/src/main/ets/date/LunarDateUtil';
import i18n from '@ohos.i18n'
import { DateTimeFormat } from './DateTimeFormat';

const TAG = 'StringFormatUtil';

const UNDEFINED_YEAR: number = 1904;

export default class StringFormatUtil {
  static numberFormatDateString(year: number, month: number, day: number): string {
    return year + '-' + month.toString().padStart(2, '0') + '-' + day.toString().padStart(2, '0');
  }

  static formatLocaleDateString(dateString: string): Resource | string {
    let DATE_FOR_YEAR_LONG = new intl.DateTimeFormat('', {dateStyle: 'long'});
    const formattedDate:string = DATE_FOR_YEAR_LONG.format(new Date(dateString));
    return formattedDate;
  }

  /**
   * @param data: original event data from db
   * @returns Return a Boolean value indicating whether the data is valid or not.
   */
  static checkEventValid(data: string | undefined): boolean {
    if (!data) {
      return false;
    }
    const reg: RegExp = new RegExp('([0-9]+|-)-[0-9]+-[0-9]+');
    if (data.match(reg)) {
      return true;
    } else {
      return false;
    }
  }

  static checkEventValid2(data: string | undefined): boolean {
    // 筛选YYYY/MM/DD格式生日
    if (!data) {
      return false;
    }
    const reg: RegExp = new RegExp('([0-9]+|/)/[0-9]+/[0-9]+');
    if (data.match(reg)) {
      return true;
    } else {
      return false;
    }
  }
  static stringFormatDateResource(data: string, lunar: boolean): string {
    let year: number = UNDEFINED_YEAR;
    let month: number = 0;
    let day: number = 0;
    const noYearReg:RegExp = new RegExp('--[0-9]+-[0-9]+');
    if (data.match(noYearReg)) {
      month = Number.parseInt(data.substr(2, data.lastIndexOf('-')));
    } else {
      year = Number.parseInt(data.substr(0, data.indexOf('-')));
      month = Number.parseInt(data.substr(data.indexOf('-') + 1, data.lastIndexOf('-')));
    }
    day = Number.parseInt(data.substr(data.lastIndexOf('-') + 1, data.length));

    let dateString = StringFormatUtil.numberFormatDateString(year, month, day);
    let date = new Date(dateString);
    if (year <= UNDEFINED_YEAR) {
      if (lunar) {
        return LunarDateUtil.getLunarDateShow(date, false);
      }
      return StringFormatUtil.getMonthmessage(year, month - 1, day);
    }
    let DATE_FOR_YEAR_LONG = new intl.DateTimeFormat('', {dateStyle: 'long'});
    const formattedDate: string = DATE_FOR_YEAR_LONG.format(date);
    if (lunar) {
      return LunarDateUtil.getLunarDateShow(date);
    }
    return formattedDate;

  }

  static judgeSysTime(context?: Context): string {
    let timeFormat = ContactsGlobalThisHelper.GetGlobalThis().getValue<string>(ContactsGlobalThisHelper.TimeFormatName);
    if (timeFormat === undefined) {
      HiLog.i('judgeSysTime', 'init judgeSysTime');
      try {
        timeFormat = settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext() as Context, settings.date.TIME_FORMAT, '12');
        HiLog.w('judgeSysTime', `refreshTimeFormat from settings:${timeFormat}`);
        ContactsGlobalThisHelper.GetGlobalThis().set<string>(ContactsGlobalThisHelper.TimeFormatName, timeFormat);
      } catch (err) {
        HiLog.e('judgeSysTime', `judgeSysTime err: ${err}`);
      }
    }
    return timeFormat;
  }

  /**
   * Obtain the description of the time within a day based on the hour.
   *
   * @param {number} hour
   * @return {string|Resource} Time nodev
   */
  static getDayMessage(year: number, mounth: number, day: number,
    hour: number, minutes: string, isFromDetail?: boolean) {
    let is24HourClock: boolean = i18n.System.is24HourClock();
    if (!is24HourClock) {
      let systemLanguage: string = i18n.System.getSystemLanguage();
      let locale = new Intl.Locale(systemLanguage);
      let language = locale.language;
      if (language == 'zh') {
        let displayHour = (hour % 12) ? (hour % 12) : 12;
        if (hour < 5) { // till 4:59
          return $r('app.string.time_before_dawn', displayHour.toString(), minutes)
        } else if (hour < 8) { // till 7:59
          return $r('app.string.time_early_morning', displayHour.toString(), minutes)
        } else if (hour < 12) { // till 11:59
          return $r('app.string.time_morning', displayHour.toString(), minutes)
        } else if (hour < 13) { // till 12:59
          return $r('app.string.time_noon', displayHour.toString(), minutes)
        } else if (hour < 19) { // till 18:59
          return $r('app.string.time_afternoon', displayHour.toString(), minutes)
        } else { // till 23:59
          return $r('app.string.time_night', displayHour.toString(), minutes)
        }
      } else {
        let DATE_FOR_HOUR_TWELVE = isFromDetail ? DateTimeFormat.getInstance().getDateTimeForHourTwelve()
          : new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h12'});
        const formattedDate: string = DATE_FOR_HOUR_TWELVE.format(new Date(year, mounth, day, hour, parseInt(minutes)));
        return formattedDate;
      }
    } else {
      let DATE_FOR_HOUR_TWENTY = isFromDetail ? DateTimeFormat.getInstance().getDateTimeForHourTwenty() :
        new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h24'});
      let formattedDate: string = DATE_FOR_HOUR_TWENTY.format(new Date(year, mounth, day, hour, parseInt(minutes)));
      // 小时补0，HH:MM
      if (formattedDate.match('^[0-9]{1}:')) {
        formattedDate = '0' + formattedDate;
      }
      return formattedDate;
    }
  }

  static getYearmessage(year: number, mounth: number, day: number, isFromDetail?: boolean) {
    let DATE_FOR_YEAR_LONG = isFromDetail ? DateTimeFormat.getInstance().getDateTimeForYearLong() :
      new intl.DateTimeFormat('', {dateStyle: 'long'});
    const formattedDate: string = DATE_FOR_YEAR_LONG.format(new Date(year, mounth, day));
    return formattedDate;
  }

  static getMonthmessage(year: number, mounth: number, day: number, isFromDetail?: boolean) {
    let DATE_FOR_MONTH = isFromDetail ? DateTimeFormat.getInstance().getDateTimeForMonth() :
      new intl.DateTimeFormat('', {month: 'long', day: 'numeric'});
    const formattedDate: string = DATE_FOR_MONTH.format(new Date(year, mounth, day));
    return formattedDate;
  }

  static clearPhoneNumberSymbols(phoneNumber: string): string {
    if (!phoneNumber || phoneNumber === '') {
      return '';
    }
    let commaIndex = phoneNumber.indexOf(',');
    let semicolonIndex = phoneNumber.indexOf(';');
    if (semicolonIndex >= 0 && commaIndex === -1) {
      phoneNumber = phoneNumber.substring(0, semicolonIndex);
    } else if (commaIndex >= 0 && semicolonIndex === -1) {
      phoneNumber = phoneNumber.substring(0, commaIndex);
    } else if (semicolonIndex >= 0 && commaIndex >= 0) {
      if (commaIndex > semicolonIndex) {
        phoneNumber = phoneNumber.substring(0, semicolonIndex);
      } else {
        phoneNumber = phoneNumber.substring(0, commaIndex);
      }
    }
    return phoneNumber;
  }

  static undefinedYearDate2To1(date: string, isLunar: boolean = false): string {
    try {
      // 双上没有年份的日期，到单上默认是1904，需要转换成 当前年份
      let year = Number.parseInt(date.slice(0, date.indexOf('-')));
      if (year <= UNDEFINED_YEAR) {
        if (isLunar) {
          let calendarLunar: i18n.Calendar = i18n.getCalendar('zh-CN', 'chinese');
          calendarLunar.setTime(new Date(date));
          calendarLunar.add('year', new Date().getFullYear() - year);
          let calendar: i18n.Calendar = i18n.getCalendar('zh-CN');
          calendar.setTime(calendarLunar.getTimeInMillis());
          date = StringFormatUtil.numberFormatDateString(
            calendar.get('year'), calendar.get('month') + 1, calendar.get('date'));
        } else {
          date = new Date().getFullYear() + date.slice(date.indexOf('-'));
        }
      }
    } catch (err) {
      HiLog.e(TAG, `noYearDate2To1 err: ${err.message}`);
    }
    return date;
  }

  static isUndefinedYearDate(date: string): boolean {
    try {
      // 双上没有年份的日期，到单上默认是1904
      let year = Number.parseInt(date.slice(0, date.indexOf('-')));
      if (year <= UNDEFINED_YEAR) {
        return true;
      }
    } catch (err) {
      HiLog.e(TAG, `noYearDate2To1 err: ${err.message}`);
    }
    return false;
  }

  /**
   * 无障碍朗读会把日期读作分数，此方法专用于无障碍日期朗读转换
   * @param callTime date
   * @param now now
   * @returns transformed date message
   */
  static getAccessibilityTextByTime(callTime: number, now: Date = new Date()): string {
    let callLogTime = new Date(callTime * 1000);
    // time detail
    let year = callLogTime.getFullYear();
    let month = callLogTime.getMonth() + 1;
    let day = callLogTime.getDate();
    // description
    let date = '';
    if (now.getFullYear() - callLogTime.getFullYear() == 0) {
      if (now.getMonth() - callLogTime.getMonth() == 0) {
        let dayDiff = now.getDate() - callLogTime.getDate();
        // 当前 和 前一天的 内容，朗读原内容
        if (dayDiff === 0 || dayDiff === 1) {
          date = '';
          return date;
        }
      }
      date = StringFormatUtil.getMonthmessage(year, month - 1, day);
    } else {
      date = StringFormatUtil.getYearmessage(year, month - 1, day);
    }
    return date;
  }
}