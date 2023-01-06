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
 * Phone Data Type
 */
export class Phone extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "phone";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.PHONE;
  static readonly NUMBER: string = DataType.DATA;
  static readonly TYPE_MOBILE: number = 1;
  static readonly TYPE_HOME: number = 2;
  static readonly TYPE_WORK: number = 3;
  static readonly TYPE_FAX_WORK: number = 4;
  static readonly TYPE_FAX_HOME: number = 5;
  static readonly TYPE_PAGER: number = 6;
  static readonly TYPE_OTHER: number = 7;
  static readonly TYPE_MAIN: number = 12;
  static readonly TYPE_CUSTOM: number = 99;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Phone.TYPE_HOME:
        return $r("app.string.phone_type_home");
      case Phone.TYPE_MOBILE:
        return $r("app.string.phone_type_mobile");
      case Phone.TYPE_WORK:
        return $r("app.string.phone_type_work");
      case Phone.TYPE_FAX_WORK:
        return $r("app.string.phone_type_fax_work");
      case Phone.TYPE_FAX_HOME:
        return $r("app.string.phone_type_fax_home");
      case Phone.TYPE_PAGER:
        return $r("app.string.phone_type_pager");
      case Phone.TYPE_OTHER:
        return $r("app.string.phone_type_other");
      case Phone.TYPE_MAIN:
        return $r("app.string.phone_type_main");
      default:
        return $r("app.string.phone_type_custom");
    }
  }

  constructor() {
    super();
  }
}