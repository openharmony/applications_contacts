/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { SearchContacts } from '../contract/SearchContacts';
import { Data } from '../contract/Data';
import { DataItem } from '../entity/DataItem';

export default class SearchContact {
  readonly id: number;
  readonly values: Map<string, any>;
  readonly dataItems: DataItem[];
  constructor(id: number, values: Map<string, any>) {
    this.id = id;
    this.values = values;
    this.dataItems = [];
  }

  static fromResultSet(resultSet: any): SearchContact{
    let contentValues: Map<string, any> = new Map();
    contentValues.set(SearchContacts.ACCOUNT_ID, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.ACCOUNT_ID)));
    contentValues.set(SearchContacts.CONTACT_ID, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.CONTACT_ID)));
    contentValues.set(SearchContacts.RAW_CONTACT_ID, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.RAW_CONTACT_ID)));
    contentValues.set(SearchContacts.SEARCH_NAME, resultSet.getString(resultSet.getColumnIndex(SearchContacts.SEARCH_NAME)));
    contentValues.set(SearchContacts.DISPLAY_NAME, resultSet.getString(resultSet.getColumnIndex(SearchContacts.DISPLAY_NAME)));
    contentValues.set(SearchContacts.PHONETIC_NAME, resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHONETIC_NAME)));
    contentValues.set(SearchContacts.PHOTO_ID, resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHOTO_ID)));
    contentValues.set(SearchContacts.PHOTO_FILE_ID, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.PHOTO_FILE_ID)));
    contentValues.set(SearchContacts.IS_DELETED, resultSet.getString(resultSet.getColumnIndex(SearchContacts.IS_DELETED)));
    contentValues.set(SearchContacts.POSITION, resultSet.getString(resultSet.getColumnIndex(SearchContacts.POSITION)));
    contentValues.set(SearchContacts.PHOTO_FIRST_NAME, resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHOTO_FIRST_NAME)));
    contentValues.set(SearchContacts.SORT_FIRST_LETTER, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.SORT_FIRST_LETTER)));
    contentValues.set(SearchContacts.CUSTOM_DATA, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.CUSTOM_DATA)));
    contentValues.set(SearchContacts.DETAIL_INFO, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.DETAIL_INFO)));
    contentValues.set(SearchContacts.CONTENT_TYPE, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.CONTENT_TYPE)));
    contentValues.set(SearchContacts.HAS_PHONE_NUMBER, resultSet.getLong(resultSet.getColumnIndex(SearchContacts.HAS_PHONE_NUMBER)));
    return new SearchContact(resultSet.getLong(resultSet.getColumnIndex(SearchContacts.ID)), contentValues);
  }
}

