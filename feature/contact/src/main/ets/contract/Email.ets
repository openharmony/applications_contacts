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
 * Mailbox Data Type
 */
export class Email extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "email";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.EMAIL;
  static readonly ADDRESS: string = DataType.DATA;
  static readonly DISPLAY_NAME: string = DataColumns.ALIAS_DETAIL_INTO;
  static readonly TYPE_HOME: number = 1;
  static readonly TYPE_WORK: number = 2;
  static readonly TYPE_OTHER: number = 3;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Email.TYPE_HOME:
        return $r("app.string.email_type_home");
      case Email.TYPE_WORK:
        return $r("app.string.email_type_work");
      case Email.TYPE_OTHER:
        return $r("app.string.email_type_other");
      default:
        return $r("app.string.email_type_custom");
    }
  }

  constructor() {
    super();
  }
}