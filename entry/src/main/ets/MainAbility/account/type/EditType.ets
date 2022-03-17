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
 * 描述联系人数据类型中的一项，包括国际化资源，类型对应在数据库中的值
 */
export default class EditType {
  readonly rawValue: number;
  readonly labelRes: Resource;

  constructor(rawValue: number, labelRes: Resource) {
    this.rawValue = rawValue;
    this.labelRes = labelRes;
  }
}