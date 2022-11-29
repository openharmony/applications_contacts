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

import Contact from '../entity/Contact';
import { Contacts } from '../contract/Contacts';
import { RawContacts } from '../contract/RawContacts';
import ContactBuilder from '../entity/ContactBuilder';

export default class ContactListItem {
  static readonly COLUMNS: string[] = [Contacts.ID, Contacts.QUICK_SEARCH_KEY, RawContacts.DISPLAY_NAME,
  RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, Contacts.COMPANY, Contacts.POSITION];
  readonly id: number;
  readonly displayName: string;
  readonly sortFirstLetter: string;
  readonly photoFirstName: string;
  readonly quickSearchKey: string;
  readonly company: string;
  readonly position: string;
  phoneNumbers: [] = [];

  constructor(resultSet: any) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
    this.sortFirstLetter = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
    this.photoFirstName = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
    this.quickSearchKey = resultSet.getString(resultSet.getColumnIndex(Contacts.QUICK_SEARCH_KEY));
    this.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
    this.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
  }

  createContact() {
    return new Contact(new ContactBuilder(this.id));
  }
}