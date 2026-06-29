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
 * Phone Data Type - Instant Messaging
 */
import { contact } from '@kit.ContactsKit';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';


export class Aim {
  public static readonly CONTENT_ITEM_TYPE: string = 'vnd.cursor.item/aim_v2';
  public static readonly TYPE_AIM: number = 1;
  public static readonly TYPE_WINDOWSLIVE: number = 2;
  public static readonly TYPE_YAHOO: number = 3;
  public static readonly TYPE_SKYPE: number = 4;
  public static readonly TYPE_QQ: number = 5;
  public static readonly TYPE_HANGOUTS: number = 6;
  public static readonly TYPE_ICQ: number = 7;
  public static readonly TYPE_JABBER: number = 8
  public static readonly TYPE_CUSTOM: number = 0;
  public static readonly IM_ADDR_HANGOUTS: number = 9;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Aim.TYPE_AIM:
        return $r('app.string.instant_type_aim');
      case Aim.TYPE_WINDOWSLIVE:
        return $r('app.string.instant_type_windowslive');
      case Aim.TYPE_YAHOO:
        return $r('app.string.instant_type_yahoo');
      case Aim.TYPE_SKYPE:
        return $r('app.string.instant_type_skype');
      case Aim.TYPE_QQ:
        return $r('app.string.instant_type_qq');
      case Aim.TYPE_HANGOUTS:
        return $r('app.string.instant_type_hangouts');
      case Aim.TYPE_ICQ:
        return $r('app.string.instant_type_icq');
      case Aim.TYPE_JABBER:
        return $r('app.string.instant_type_jabber');
      case Aim.TYPE_CUSTOM:
        return $r('app.string.instant_type_custom');
      default:
        return $r('app.string.instant_type_custom');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.ImAddress.CUSTOM_LABEL:
        return PhoneAccountType.TYPE_ID_CUSTOM;
      case contact.ImAddress.IM_AIM:
        return Aim.TYPE_AIM;
      case contact.ImAddress.IM_YAHOO:
        return Aim.TYPE_YAHOO;
      case contact.ImAddress.IM_SKYPE:
        return Aim.TYPE_SKYPE;
      case contact.ImAddress.IM_QQ:
        return Aim.TYPE_QQ;
      case contact.ImAddress.IM_ICQ:
        return Aim.TYPE_ICQ;
      case contact.ImAddress.IM_JABBER:
        return Aim.TYPE_JABBER;
      case contact.ImAddress.IM_MSN:
        return Aim.TYPE_WINDOWSLIVE;
      case Aim.IM_ADDR_HANGOUTS:
        return Aim.TYPE_HANGOUTS;
      default:
        return Aim.TYPE_AIM;
    }
  }

  constructor() {
  }
}