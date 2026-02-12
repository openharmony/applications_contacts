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
import { HiLog } from './HiLog';

export class StringUtil {
  static isEmpty(str?: string): boolean {
    return str === 'undefined' || !str || !new RegExp('[^\\s]').test(str);
  }

  static transferEmptyStrIfUndefined(str: string | undefined): string {
    if (str === undefined) {
      return '';
    }

    return str as string;
  }

  /**
   * 根据指定字符padCh，补全字符串str 到指定长度len
   * @param str
   * @param padCh
   * @param len
   * @returns
   */
  static paddingLeft(str: string, padCh: string, len: number): string {
    while (str.length < len) {
      str = padCh + str;
    }

    return str;
  }

  static removeSpace(str: string): string {
    if (StringUtil.isEmpty(str)) {
      return '';
    }
    return str.replace(new RegExp('[\\s]', 'g'), '');
  }

  static removeDash(str: string): string {
    if (StringUtil.isEmpty(str)) {
      return '';
    }
    return str.replace(new RegExp('[\-\]', 'g'), '');
  }

  static removeFormatChar(str: string): string {
    if (StringUtil.isEmpty(str)) {
      return '';
    }
    return str.replace(new RegExp('[\\-\\(\\)\\s]+', 'g'), '');
  }

  static hasFormatChar(str: string): boolean {
    if (str === '' || str === undefined || str === null) {
      return false;
    } else if (str.match('[\\-\\(\\)\\s]+')) {
      return true;
    }
    return false;
  }

  /* Obtains the result string that matches the specified substring in the original character string.
   Only the result of the first successful match is returned.(The matching rule ignores spaces.)
   */
  static getMatchedString(textValue: string, regString: string): string {
    if (StringUtil.isEmpty(textValue) || StringUtil.isEmpty(regString)) {
      return '';
    }
    regString = StringUtil.removeSpace(regString);
    let matchedTemp = '';

    // spaces count
    let k = 0;
    for (let i = 0; i < textValue.length; i++) {
      if (textValue.charAt(i) === regString.charAt(0)) {
        for (let j = 0; j < regString.length; j++) {
          if (textValue.charAt(i + k + j) === regString.charAt(j) || textValue.charAt(i + k + j) === ' ') {
            matchedTemp = matchedTemp + textValue.charAt(i + k + j);
            if (textValue.charAt(i + k + j) === ' ') {
              // If the main string is a space, the substring is not counted.
              k++;
              j--;
            }
          } else {
            k = 0;
            matchedTemp = '';
            break;
          }
          if (j === regString.length - 1) {
            return matchedTemp;
          }
        }
      }
    }
    return '';
  }

  static maskSensitiveInfo(str: string): string {
    try {
      if (StringUtil.isEmpty(str)) {
        return '';
      }
      // 只有一个字符，大概率是姓名只有一个字，此时不打印
      if (str.length <= 1) {
        return `*:${str.length}`;
      }
      // 只有2个字符时，打印首字母跟长度2，与下面统一
      if (str.length <= 2) {
        return `${str.substring(0, 1)}:${str.length}`;
      }
      // 大概率是姓名、公司，打印首尾字符
      if (str.length <= 6) {
        return `${str.substring(0, 1)}:${str.substring(str.length - 1, str.length)}:${str.length}`;
      }
      // 针对长姓名等情况，打印前两位，后两位
      if (str.length <= 9) {
        return `${str.substring(0, 2)}:${str.substring(str.length - 2, str.length)}:${str.length}`;
      }
      // 号码或者座机，打印前三位，后四位
      if (str.length <= 11) {
        return `${str.substring(0, 3)}:${str.substring(str.length - 4, str.length)}:${str.length}`;
      }
      // 对于带有+86这样的手机，打印前六位
      if (str.length <= 14) {
        return `${str.substring(0, 6)}:${str.substring(str.length - 4, str.length)}:${str.length}`;
      }
      return `${str.substring(0, 3)}:${str.substring(str.length - 4, str.length)}:${str.length}`;
    } catch (e) {
      HiLog.e('StringUtil', `maskSensitiveInfo error: ${e?.message}`);
      return '***';
    }
  }

  static maskDeviceId(str: string): string {
    try {
      if (StringUtil.isEmpty(str)) {
        return '';
      }
      if (str.length > 14) {
        // 设备信息，打印前四位，后四位
        return `${str.substring(0, 4)}:${str.substring(str.length - 4, str.length)}:${str.length}`;
      }
      return this.maskSensitiveInfo(str);
    } catch (e) {
      HiLog.e('StringUtil', `maskDeviceId error: ${e?.message}`);
      return '***';
    }
  }
}