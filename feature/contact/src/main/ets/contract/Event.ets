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
 * Important Holiday Data Types
 */
export class Event extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "contact_event";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.EVENT;
  static readonly START_DATE: string = DataType.DATA;
  static readonly TYPE_ANNIVERSARY: number = 1;
  static readonly TYPE_OTHER: number = 2;
  static readonly TYPE_BIRTHDAY: number = 3;
  static readonly TYPE_LUNARBIRTHDAY: number = 4;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Event.TYPE_ANNIVERSARY:
        return $r("app.string.phone_type_home");
      case Event.TYPE_BIRTHDAY:
        return $r("app.string.phone_type_mobile");
      case Event.TYPE_OTHER:
        return $r("app.string.phone_type_work");
      default:
        return $r("app.string.phone_type_custom");
    }
  }

  constructor() {
    super();
  }
}