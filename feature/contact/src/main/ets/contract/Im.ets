/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import DataType, { DataItemType } from './DataType';

/**
 * IM data type
 */
export class Im extends DataType {
  public static readonly CONTENT_ITEM_TYPE: string = 'im';
  public static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.IM;
  public static readonly PROTOCOL: string = DataType.DATA;
  public static readonly TYPE_CUSTOM: number = -1;
  public static readonly TYPE_AIM: number = 0;
  public static readonly TYPE_MSN: number = 1;
  public static readonly TYPE_YAHOO: number = 2;
  public static readonly TYPE_SKYPE: number = 3;
  public static readonly TYPE_QQ: number = 4;
  public static readonly TYPE_TALK: number = 5;
  public static readonly TYPE_ICQ: number = 6;
  public static readonly TYPE_JABBER: number = 7;
  public static readonly TYPE_INVALID: number = -2;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Im.TYPE_CUSTOM:
        return $r('app.string.email_type_home');
      case Im.TYPE_AIM:
        return $r('app.string.email_type_work');
      case Im.TYPE_MSN:
        return $r('app.string.email_type_other');
      default:
        return $r('app.string.email_type_custom');
    }
  }

  constructor() {
    super();
  }
}