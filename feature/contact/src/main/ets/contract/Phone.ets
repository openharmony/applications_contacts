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
import { contact } from '@kit.ContactsKit';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';

/**
 * Phone Data Type
 */
export class Phone extends DataType {
  public static readonly CONTENT_ITEM_TYPE: string = 'phone';
  public static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.PHONE;
  public static readonly NUMBER: string = DataType.DATA;
  public static readonly TYPE_MOBILE: number = 1;
  public static readonly TYPE_HOME: number = 2;
  public static readonly TYPE_WORK: number = 3;
  public static readonly TYPE_FAX_WORK: number = 4;
  public static readonly TYPE_FAX_HOME: number = 5;
  public static readonly TYPE_PAGER: number = 6;
  public static readonly TYPE_OTHER: number = 7;
  public static readonly TYPE_MAIN: number = 12;
  public static readonly TYPE_CUSTOM: number = 99;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Phone.TYPE_HOME:
        return $r('app.string.phone_type_home');
      case Phone.TYPE_MOBILE:
        return $r('app.string.phone_type_mobile');
      case Phone.TYPE_WORK:
        return $r('app.string.phone_type_work');
      case Phone.TYPE_FAX_WORK:
        return $r('app.string.phone_type_fax_work');
      case Phone.TYPE_FAX_HOME:
        return $r('app.string.phone_type_fax_home');
      case Phone.TYPE_PAGER:
        return $r('app.string.phone_type_pager');
      case Phone.TYPE_OTHER:
        return $r('app.string.phone_type_other');
      case Phone.TYPE_MAIN:
        return $r('app.string.phone_type_main');
      default:
        return $r('app.string.phone_type_custom');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.PhoneNumber.CUSTOM_LABEL:
        return PhoneAccountType.TYPE_ID_CUSTOM;
      case contact.PhoneNumber.NUM_HOME:
        return Phone.TYPE_HOME;
      case contact.PhoneNumber.NUM_MOBILE:
        return Phone.TYPE_MOBILE;
      case contact.PhoneNumber.NUM_WORK:
        return Phone.TYPE_WORK;
      case contact.PhoneNumber.NUM_FAX_WORK:
        return Phone.TYPE_FAX_WORK;
      case contact.PhoneNumber.NUM_FAX_HOME:
        return Phone.TYPE_FAX_HOME;
      case contact.PhoneNumber.NUM_PAGER:
        return Phone.TYPE_PAGER;
      case contact.PhoneNumber.NUM_OTHER:
        return Phone.TYPE_OTHER;
      case contact.PhoneNumber.NUM_MAIN:
        return Phone.TYPE_MAIN;
      default:
        return Phone.TYPE_MOBILE;
    }
  }

  constructor() {
    super();
  }
}