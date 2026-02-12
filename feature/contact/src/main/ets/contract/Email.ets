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

import DataColumns from './DataColumns';
import DataType, { DataItemType } from './DataType';
import { contact } from '@kit.ContactsKit';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';

/**
 * Mailbox Data Type
 */
export class Email extends DataType {
  public static readonly CONTENT_ITEM_TYPE: string = 'email';
  public static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.EMAIL;
  public static readonly ADDRESS: string = DataType.DATA;
  public static readonly DISPLAY_NAME: string = DataColumns.ALIAS_DETAIL_INTO;
  public static readonly TYPE_HOME: number = 1;
  public static readonly TYPE_WORK: number = 2;
  public static readonly TYPE_OTHER: number = 3;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Email.TYPE_HOME:
        return $r('app.string.email_type_home');
      case Email.TYPE_WORK:
        return $r('app.string.email_type_work');
      case Email.TYPE_OTHER:
        return $r('app.string.email_type_other');
      default:
        return $r('app.string.email_type_custom');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.Email.CUSTOM_LABEL:
        return PhoneAccountType.TYPE_ID_CUSTOM;
      case contact.Email.EMAIL_HOME:
        return Email.TYPE_HOME;
      case contact.Email.EMAIL_WORK:
        return Email.TYPE_WORK;
      case contact.Email.EMAIL_OTHER:
        return Email.TYPE_OTHER;
      default:
        return Email.TYPE_HOME;
    }
  }

  constructor() {
    super();
  }
}