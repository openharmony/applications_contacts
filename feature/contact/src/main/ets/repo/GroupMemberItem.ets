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

import { Contacts } from '../contract/Contacts';
import { RawContacts } from '../contract/RawContacts';
import { SearchContacts } from '../contract/SearchContacts';
import { Data } from '../contract/Data';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { PhoneNumberInterface } from '../../../../../../entry/src/main/ets/model/type';
export default class GroupMemberItem {
  public static readonly COLUMNS: string[] = [RawContacts.CONTACT_ID, Contacts.QUICK_SEARCH_KEY,
 RawContacts.DISPLAY_NAME, RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, Contacts.COMPANY,
  Contacts.POSITION, Data.DETAIL_INFO, SearchContacts.ROW_CONTACT_ID];
  public readonly id: number;
  public readonly displayName: string;
  public readonly sortFirstLetter: string;
  public readonly photoFirstName: string;
  public readonly quickSearchKey: string;
  public readonly company: string;
  public readonly position: string;
  public readonly detailInfo: string;
  public readonly rawContactId: number;
  public phoneNumbers: PhoneNumberInterface[] = [];
  constructor(resultSet: DataShareResultSet) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
    this.sortFirstLetter = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
    this.photoFirstName = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
    this.quickSearchKey = resultSet.getString(resultSet.getColumnIndex(Contacts.QUICK_SEARCH_KEY));
    this.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
    this.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
    this.detailInfo = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
    this.rawContactId = resultSet.getLong(resultSet.getColumnIndex(SearchContacts.ROW_CONTACT_ID));
  }
}