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
 * Phone Data Type - Birthday
 */
import { contact } from '@kit.ContactsKit';


export class Birthday {
  public static readonly CONTENT_ITEM_TYPE: string = 'vnd.cursor.item/birthday_v2';
  public static readonly TYPE_GREBIRTHDAY: number = 1;
  public static readonly TYPE_LUNARBIRTHDAY: number = 2;
  public static readonly TYPE_ANNIVERSARIES: number = 3;
  public static readonly TYPE_OTHER: number = 0;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Birthday.TYPE_GREBIRTHDAY:
        return $r('app.string.birthday_type_grebirthday');
      case Birthday.TYPE_LUNARBIRTHDAY:
        return $r('app.string.birthday_type_lunarbirthday');
      case Birthday.TYPE_ANNIVERSARIES:
        return $r('app.string.birthday_type_anniversaries');
      case Birthday.TYPE_OTHER:
        return $r('app.string.birthday_type_other');
      default:
        return $r('app.string.birthday_type_other');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.Event.EVENT_BIRTHDAY:
        return Birthday.TYPE_GREBIRTHDAY;
      case contact.Event.EVENT_ANNIVERSARY:
        return Birthday.TYPE_ANNIVERSARIES;
      case contact.Event.EVENT_OTHER:
        return Birthday.TYPE_OTHER;
      default:
        return Birthday.TYPE_OTHER;
    }
  }

  constructor() {
  }
}