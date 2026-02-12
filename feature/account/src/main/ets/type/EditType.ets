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

/**
 * Describes a contact data type, including internationalization resources.
 * The type corresponds to the value in the database.
 */
export default class EditType {
  public readonly rawValue: number;
  // 对于自定义下拉框，可能是string字符串；对于定义好的下拉框是Resource
  public readonly labelRes: Resource | string;

  constructor(rawValue: number, labelRes: Resource | string) {
    this.rawValue = rawValue;
    this.labelRes = labelRes;
  }
}