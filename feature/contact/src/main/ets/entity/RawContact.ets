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

import { RawContacts } from '../contract/RawContacts';
import { Data } from '../contract/Data';
import { DataItem } from '../entity/DataItem';

export default class RawContact {
  readonly id: number;
  readonly values: Map<string, any>;
  readonly dataItems: DataItem[];
  constructor(id: number, values: Map<string, any>) {
    this.id = id;
    this.values = values;
    this.dataItems = [];
  }

  static fromResultSet(resultSet: any): RawContact{
    let contentValues: Map<string, any> = new Map();
    contentValues.set(RawContacts.CONTACT_ID, resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID)));
    contentValues.set(RawContacts.PHOTO_ID, resultSet.getLong(resultSet.getColumnIndex(RawContacts.PHOTO_ID)));
    contentValues.set(RawContacts.PHOTO_FILE_ID, resultSet.getLong(resultSet.getColumnIndex(RawContacts.PHOTO_FILE_ID)));
    contentValues.set(RawContacts.IS_TRANSFER_VOICEMAIL, resultSet.getLong(resultSet.getColumnIndex(RawContacts.IS_TRANSFER_VOICEMAIL)) > 0 ? true : false);
    contentValues.set(RawContacts.PERSONAL_RINGTONE, resultSet.getString(resultSet.getColumnIndex(RawContacts.PERSONAL_RINGTONE)));
    contentValues.set(RawContacts.PERSONAL_NOTIFICATION_RINGTONE, resultSet.getString(resultSet.getColumnIndex(RawContacts.PERSONAL_NOTIFICATION_RINGTONE)));
    contentValues.set(RawContacts.PHOTO_FIRST_NAME, resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME)));
    contentValues.set(RawContacts.ACCOUNT_ID, resultSet.getLong(resultSet.getColumnIndex(RawContacts.ACCOUNT_ID)));
    contentValues.set(RawContacts.DISPLAY_NAME, resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME)));
    contentValues.set(RawContacts.SORT, resultSet.getLong(resultSet.getColumnIndex(RawContacts.SORT)));
    contentValues.set(RawContacts.CONTACTED_COUNT, resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT)));
    contentValues.set(RawContacts.LASTEST_CONTACTED_TIME, resultSet.getLong(resultSet.getColumnIndex(RawContacts.LASTEST_CONTACTED_TIME)));
    contentValues.set(RawContacts.FAVORITE, resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE)));
    contentValues.set(RawContacts.FAVORITE_ORDER, resultSet.getLong(resultSet.getColumnIndex(RawContacts.FAVORITE_ORDER)));
    contentValues.set(RawContacts.PHONETIC_NAME, resultSet.getString(resultSet.getColumnIndex(RawContacts.PHONETIC_NAME)));
    contentValues.set(RawContacts.COMPANY, resultSet.getString(resultSet.getColumnIndex(RawContacts.COMPANY)));
    contentValues.set(RawContacts.POSITION, resultSet.getString(resultSet.getColumnIndex(RawContacts.POSITION)));
    return new RawContact(resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)), contentValues);
  }
}

