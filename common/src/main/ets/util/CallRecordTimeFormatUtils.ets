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
import { HiLog } from './HiLog';

export class FormatTime {
  public static MILL_SECONDS = 1000;
  public static SIXTY_RATE = 60;
  public static TEN_RATE = 10;
}

export enum FuncType {
  AUDIO = 0,
  VIDEO = 1,
  MESSAGE = 2,
  NATIVE_CALL = 3,
  NATIVE_MSG = 4,
}

export class DefaultBaseData {
  public static NUMBER = 0;
  public static STRING = '';
  public static BOOLEAN = false;
  // 默认下拉框的索引值0 “手机”
  public static PHONE_TYPE_INDEX = 0;
  public static INVALID_NUMBER = -1;
}

export class CallRecordTimeFormatUtils {
  /**
   * 毫秒转为时分秒
   *
   * @param millisecond 毫秒数
   */
  static duration(millisecond: number): string {
    const time = millisecond / FormatTime.MILL_SECONDS;
    let hours = Math.floor((time / (FormatTime.SIXTY_RATE * FormatTime.SIXTY_RATE)));
    let minutes = Math.floor((time / (FormatTime.SIXTY_RATE)) % FormatTime.SIXTY_RATE);
    let seconds = Math.floor((time) % FormatTime.SIXTY_RATE);

    if (time >= (FormatTime.SIXTY_RATE * FormatTime.SIXTY_RATE)) {
      return hours + '小时 ' + minutes + '分' + seconds + '秒';
    } else if (time < (FormatTime.SIXTY_RATE * FormatTime.SIXTY_RATE) && time >= FormatTime.SIXTY_RATE) {
      return minutes + ' 分 ' + seconds + ' 秒';
    } else if (time < FormatTime.SIXTY_RATE) {
      return seconds + ' 秒';
    } else {
      return '';
    }
  }

  /**
   * 通话记录创建时间显示控制
   *
   * @param time 通话记录创建时间
   */
  static getYear(time: number): string {
    const now = new Date(time) as Date;
    let Y = now.getFullYear();
    let M = (now.getMonth() + 1 < FormatTime.TEN_RATE ? '0' + (now.getMonth() + 1) : now.getMonth() + 1);
    let D = (now.getDate() < FormatTime.TEN_RATE ? '0' + now.getDate() : now.getDate());
    let h = (now.getHours() < FormatTime.TEN_RATE ? '0' + now.getHours() : now.getHours());
    let m = (now.getMinutes() < FormatTime.TEN_RATE ? '0' + now.getMinutes() : now.getMinutes());
    let today = new Date(new Date().setHours(0, 0, 0, 0)).getTime();

    const newTimes = new Date();
    let fullYear = newTimes.getFullYear();
    if (Y < fullYear) {
      return Y + '年' + M + '月' + D + '日 ' + h + ':' + m;
    } else if (time > today) {
      return h + ':' + m;
    } else {
      return M + '月' + D + '日 ' + h + ':' + m;
    }
  }
}
