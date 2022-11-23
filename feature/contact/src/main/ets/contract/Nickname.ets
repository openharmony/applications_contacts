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

import DataType from './DataType';
import {DataItemType} from './DataType';

/**
 * Nickname Data Type
 */
export class Nickname extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "nickname";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.NICKNAME;
  static readonly NAME: string = DataType.DATA;
  constructor() {
    super();
  }
}