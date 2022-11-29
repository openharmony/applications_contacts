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
export class StringUtil {
  static isEmpty(str: string): boolean {
    return str == 'undefined' || !str || !/[^\s]/.test(str);
  }

  static removeSpace(str: string): string {
    if (this.isEmpty(str)) {
      return '';
    }
    return str.replace(/[\s]/g, '');
  }

  /* Obtains the result string that matches the specified substring in the original character string.
   Only the result of the first successful match is returned.(The matching rule ignores spaces.)
   */
  static getMatchedString(textValue, regString): string{
    if (this.isEmpty(textValue) || this.isEmpty(regString)) {
      return '';
    }
    regString = this.removeSpace(regString);
    let matchedTemp = '';

    // spaces count
    let k = 0;
    for (let i = 0; i < textValue.length; i++) {
      if (textValue.charAt(i) == regString.charAt(0)) {
        for (let j = 0; j < regString.length; j++) {
          if (textValue.charAt(i + k + j) == regString.charAt(j) || textValue.charAt(i + k + j) == ' ') {
            matchedTemp = matchedTemp + textValue.charAt(i + k + j);
            if (textValue.charAt(i + k + j) == ' ') {
              // If the main string is a space, the substring is not counted.
              k++;
              j--;
            }
          } else {
            k = 0;
            matchedTemp = '';
            break;
          }
          if (j == regString.length - 1) {
            return matchedTemp;
          }
        }
      }
    }
    return '';
  }
}