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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { intl } from '@kit.LocalizationKit';

const TAG: string = 'DateTimeFormat ';

export class DateTimeFormat {
  private constructor() {
  }

  private static instance: DateTimeFormat;

  private dateForYearLong: intl.DateTimeFormat | undefined = new intl.DateTimeFormat('', {dateStyle: 'long'});
  private dateForMonth: intl.DateTimeFormat | undefined = new intl.DateTimeFormat('', {month: 'long', day: 'numeric'});
  private dateForHourTwelve: intl.DateTimeFormat | undefined =
    new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h12'});
  private dateForHourTwenty: intl.DateTimeFormat | undefined =
    new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h24'});

  /**
   * get Instance
   * @returns
   */
  public static getInstance(): DateTimeFormat {
    if (!DateTimeFormat.instance) {
      HiLog.w(TAG, 'init DateTimeFormat.instance')
      DateTimeFormat.instance = new DateTimeFormat();
    }
    return DateTimeFormat.instance;
  }

  public initDateTimeFormat() {
    this.dateForYearLong = new intl.DateTimeFormat('', {dateStyle: 'long'});
    this.dateForMonth = new intl.DateTimeFormat('', {month: 'long', day: 'numeric'});
    this.dateForHourTwelve = new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h12'});
    this.dateForHourTwenty = new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h24'});
  }

  public getDateTimeForYearLong(): intl.DateTimeFormat {
    if (this.dateForYearLong) {
      return this.dateForYearLong;
    }
    this.dateForYearLong = new intl.DateTimeFormat('', {dateStyle: 'long'});
    return this.dateForYearLong;
  }

  public getDateTimeForMonth(): intl.DateTimeFormat {
    if (this.dateForMonth) {
      return this.dateForMonth;
    }
    this.dateForMonth = new intl.DateTimeFormat('', {month: 'long', day: 'numeric'});
    return this.dateForMonth;
  }

  public getDateTimeForHourTwelve(): intl.DateTimeFormat {
    if (this.dateForHourTwelve) {
      return this.dateForHourTwelve;
    }
    this.dateForHourTwelve = new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h12'});
    return this.dateForHourTwelve;
  }

  public getDateTimeForHourTwenty(): intl.DateTimeFormat {
    if (this.dateForHourTwenty) {
      return this.dateForHourTwenty;
    }
    this.dateForHourTwenty = new intl.DateTimeFormat('', {timeStyle: 'short', hourCycle: 'h24'});
    return this.dateForHourTwenty;
  }

  public unInitDateTimeFormat() {
    this.dateForYearLong = undefined;
    this.dateForMonth = undefined;
    this.dateForHourTwelve = undefined;
    this.dateForHourTwenty = undefined;
  }
}