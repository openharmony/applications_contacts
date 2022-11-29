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

/**
 * Phone Data Type - Birthday
 */
export class Birthday {
  static readonly CONTENT_ITEM_TYPE: string = "vnd.android.cursor.item/birthday_v2";
  static readonly TYPE_GREBIRTHDAY: number = 1;
  static readonly TYPE_LUNARBIRTHDAY: number = 2;
  static readonly TYPE_ANNIVERSARIES: number = 3;
  static readonly TYPE_OTHER: number = 0;


  static getTypeLabelResource(type: number) {
    switch (type) {
      case Birthday.TYPE_GREBIRTHDAY:
        return $r("app.string.birthday_type_grebirthday");
      case Birthday.TYPE_LUNARBIRTHDAY:
        return $r("app.string.birthday_type_lunarbirthday");
      case Birthday.TYPE_ANNIVERSARIES:
        return $r("app.string.birthday_type_anniversaries");
      case Birthday.TYPE_OTHER:
        return $r("app.string.birthday_type_other");
      default:
        return $r("app.string.birthday_type_other");
    }
  }

  constructor() {
  }
}