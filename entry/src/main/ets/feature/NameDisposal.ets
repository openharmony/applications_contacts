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

const reg = new RegExp('&#x3c;', 'g');
const regEx = new RegExp('&#x2f;', 'g');
const regExp = new RegExp('&#x3e;', 'g');
const hasComma: RegExp = new RegExp('&comma;', 'g');
const COMMA_REPLACE: string = '&comma;';
/**
 * 名称处理
 */
export default class NameDisposal {
  /**
   *  Handling Special Characters in Names
   **/
  static charEscape(value:string[]) {
    let data = value.toString().replace(reg, '<').replace(regEx, '/').replace(regExp, '>');
    let dataMap = data.split(',').map(item => item.includes(COMMA_REPLACE) ? item.replace(hasComma, ',') : item);
    return dataMap;
  }

}