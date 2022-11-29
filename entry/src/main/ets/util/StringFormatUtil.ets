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

export default {
  numberFormatDateString(year : number, month : number, day : number) : string {
    return year + "-" + month + "-" + day;
  },

  stringFormatDateResource(data: string): Resource{
    let year: number = parseInt(data.substr(0, data.indexOf("-")));
    let month: number = parseInt(data.substr(data.indexOf("-") + 1, data.lastIndexOf("-")));
    let day: number = parseInt(data.substr(data.lastIndexOf("-") + 1, data.length));
    return $r("app.string.yearMonthDay", year, month, day);
  }
}