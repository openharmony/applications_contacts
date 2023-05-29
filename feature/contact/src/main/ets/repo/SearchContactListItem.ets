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
import ContactBuilder from '../entity/ContactBuilder';
import { SearchContacts } from '../contract/SearchContacts';

export default class SearchContactListItem {
  static readonly COLUMNS: string[] = [SearchContacts.ID, SearchContacts.ACCOUNT_ID, SearchContacts.CONTACT_ID,
  SearchContacts.ROW_CONTACT_ID, SearchContacts.SEARCH_NAME, SearchContacts.DISPLAY_NAME, SearchContacts.PHONETIC_NAME,
  SearchContacts.PHOTO_ID, SearchContacts.PHOTO_FILE_ID, SearchContacts.IS_DELETED, SearchContacts.POSITION,
  SearchContacts.PHOTO_FIRST_NAME, SearchContacts.SORT_FIRST_LETTER, SearchContacts.CUSTOM_DATA,
  SearchContacts.DETAIL_INFO, SearchContacts.CONTENT_TYPE, SearchContacts.HAS_PHONE_NUMBER];
  readonly id: number;
  readonly accountId: string;
  readonly contactId: string;
  readonly rawContactId: string;
  readonly searchName: string;
  readonly displayName: string;
  readonly phoneticName: string;
  readonly photoId: string;
  readonly photoFileId: string;
  readonly isDeleted: number;
  readonly position: string;
  readonly photoFirstName: string;
  readonly sortFirstLetter: string;
  readonly customData: string;
  readonly detailInfo: string;
  readonly contentType: string;
  readonly hasPhoneNumber: string;

  constructor(resultSet: any) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(SearchContacts.ID));
    this.accountId = resultSet.getString(resultSet.getColumnIndex(SearchContacts.ACCOUNT_ID));
    this.contactId = resultSet.getString(resultSet.getColumnIndex(SearchContacts.CONTACT_ID));
    this.rawContactId = resultSet.getString(resultSet.getColumnIndex(SearchContacts.ROW_CONTACT_ID));
    this.searchName = resultSet.getString(resultSet.getColumnIndex(SearchContacts.SEARCH_NAME));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(SearchContacts.DISPLAY_NAME));
    this.phoneticName = resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHONETIC_NAME));
    this.photoId = resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHOTO_ID));
    this.photoFileId = resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHOTO_FILE_ID));
    this.isDeleted = resultSet.getString(resultSet.getColumnIndex(SearchContacts.IS_DELETED));
    this.position = resultSet.getString(resultSet.getColumnIndex(SearchContacts.POSITION));
    this.photoFirstName = resultSet.getString(resultSet.getColumnIndex(SearchContacts.PHOTO_FIRST_NAME));
    this.sortFirstLetter = resultSet.getString(resultSet.getColumnIndex(SearchContacts.SORT_FIRST_LETTER));
    this.customData = resultSet.getString(resultSet.getColumnIndex(SearchContacts.CUSTOM_DATA));
    this.detailInfo = resultSet.getString(resultSet.getColumnIndex(SearchContacts.DETAIL_INFO));
    this.contentType = resultSet.getString(resultSet.getColumnIndex(SearchContacts.CONTENT_TYPE));
    this.hasPhoneNumber = resultSet.getString(resultSet.getColumnIndex(SearchContacts.HAS_PHONE_NUMBER));
  }
}