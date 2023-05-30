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

import Contact from '../entity/Contact';
import { Contacts } from '../contract/Contacts';
import { RawContacts } from '../contract/RawContacts';
import ContactBuilder from '../entity/ContactBuilder';
import { Data } from '../contract/Data';

export default class ContactUsuallyListItem {
  static readonly COLUMNS: string[] = [Data.RAW_CONTACT_ID, Contacts.QUICK_SEARCH_KEY, RawContacts.DISPLAY_NAME,
  RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, Contacts.COMPANY, Contacts.POSITION,
  RawContacts.FAVORITE_ORDER, Data.DETAIL_INFO, Data.CONTENT_TYPE];
  readonly id: number;
  readonly displayName: string;
  readonly sortFirstLetter: string;
  readonly photoFirstName: string;
  readonly quickSearchKey: string;
  readonly company: string;
  readonly position: string;
  readonly favoriteOrder: string;
  readonly detailInfo: string;
  readonly contentType: string;

  constructor(resultSet: any) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
    this.sortFirstLetter = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
    this.photoFirstName = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
    this.quickSearchKey = resultSet.getString(resultSet.getColumnIndex(Contacts.QUICK_SEARCH_KEY));
    this.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
    this.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
    this.favoriteOrder = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE_ORDER));
    this.detailInfo = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
    this.contentType = resultSet.getString(resultSet.getColumnIndex(Data.CONTENT_TYPE));
  }

//  createContact() {
//    return new Contact(new ContactBuilder(this.id));
//  }
}