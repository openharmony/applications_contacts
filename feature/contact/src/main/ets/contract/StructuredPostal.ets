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

import DataColumns from './DataColumns';
import DataType from './DataType';
import {DataItemType} from './DataType';

/**
 * Address Data Type
 */
export class StructuredPostal extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "postal_address";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.STRUCTURED_POSTAL;
  static readonly FORMATTED_ADDRESS: string = DataType.DATA;
  static readonly STREET: string = DataColumns.STREET;
  static readonly POBOX: string = DataColumns.POBOX;
  static readonly NEIGHBORHOOD: string = DataColumns.NEIGHBORHOOD;
  static readonly CITY: string = DataColumns.CITY;
  static readonly REGION: string = DataColumns.REGION;
  static readonly POSTCODE: string = DataColumns.POSTCODE;
  static readonly COUNTRY: string = DataColumns.COUNTRY;
  static readonly TYPE_HOME: number = 1;
  static readonly TYPE_WORK: number = 2;
  static readonly TYPE_OTHER: number = 3;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case StructuredPostal.TYPE_HOME:
        return $r("app.string.email_type_home");
      case StructuredPostal.TYPE_WORK:
        return $r("app.string.email_type_work");
      case StructuredPostal.TYPE_OTHER:
        return $r("app.string.email_type_other");
      default:
        return $r("app.string.email_type_custom");
    }
  }

  constructor() {
    super();
  }
}