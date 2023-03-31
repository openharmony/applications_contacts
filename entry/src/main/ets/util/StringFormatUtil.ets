/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import settings from '@ohos.settings';
import CalendarUtil from './CalendarUtil'

export default {
  numberFormatDateString(year : number, month : number, day : number) : string {
    return year + "-" + month + "-" + day;
  },

  stringFormatDateResource(data: string, lunar: boolean): Resource|string{
    let year: number = parseInt(data.substr(0, data.indexOf("-")));
    let month: number = parseInt(data.substr(data.indexOf("-") + 1, data.lastIndexOf("-")));
    let day: number = parseInt(data.substr(data.lastIndexOf("-") + 1, data.length));
    if (lunar) {
      return CalendarUtil.formatLunarDate(CalendarUtil.getLunarDate(new Date(year,month-1,day)))
    }
    return $r("app.string.yearMonthDay", year, month, day);
  },

  judgeSysTime(context?: Context) {
    return settings.getValueSync(context ? context : globalThis.context, settings.date.TIME_FORMAT, "24");
  },

  /**
   * Obtain the description of the time within a day based on the hour.
   *
   * @param {number} hour
   * @return {string} Time node
   */
  getDayMessage(hour, minutes) {
    if (hour >= 0 && hour < 5) {
      return $r("app.string.time_early_morning", hour, minutes);
    }
    if (hour >= 5 && hour < 11) {
      return $r("app.string.time_morning", hour, minutes);
    }
    if (hour >= 11 && hour < 13) {
      return $r("app.string.time_noon", hour >= 12 ? (parseInt(hour) - 12).toString() : hour, minutes);
    }
    if (hour >= 13 && hour < 17) {
      return $r("app.string.time_afternoon", (parseInt(hour) - 12).toString(), minutes);
    }
    if (hour >= 17 && hour < 19) {

      return $r("app.string.time_nightfall", (parseInt(hour) - 12).toString(), minutes);
    }
    if (hour >= 19 && hour < 22) {

      return $r("app.string.time_night", (parseInt(hour) - 12).toString(), minutes);
    }
    if (hour >= 22 && hour < 24) {
      return $r("app.string.time_middle_night", (parseInt(hour) - 12).toString(), minutes);
    }
  }
}