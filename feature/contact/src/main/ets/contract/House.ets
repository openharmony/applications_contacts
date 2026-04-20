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

/**
 * Phone Data Type - Address
 */
import { contact } from '@kit.ContactsKit';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';


export class House {
  public static readonly CONTENT_ITEM_TYPE: string = 'vnd.cursor.item/house_v2';
  public static readonly TYPE_DWELLING: number = 1;
  public static readonly TYPE_POSITION: number = 2;
  public static readonly TYPE_OTHER: number = 3;
  public static readonly TYPE_CUSTOM: number = 0;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case House.TYPE_DWELLING:
        return $r('app.string.house_type_dwelling');
      case House.TYPE_POSITION:
        return $r('app.string.house_type_position');
      case House.TYPE_OTHER:
        return $r('app.string.house_type_other');
      case House.TYPE_CUSTOM:
        return $r('app.string.house_type_custom');
      default:
        return $r('app.string.house_type_custom');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.PostalAddress.CUSTOM_LABEL:
        return PhoneAccountType.TYPE_ID_CUSTOM;
      case contact.PostalAddress.ADDR_HOME:
        return House.TYPE_DWELLING;
      case contact.PostalAddress.ADDR_WORK:
        return House.TYPE_POSITION;
      case contact.PostalAddress.ADDR_OTHER:
        return House.TYPE_OTHER;
      default:
        return House.TYPE_DWELLING;
    }
  }

  constructor() {
  }
}