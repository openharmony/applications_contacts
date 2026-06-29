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
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { PhoneNumberInterface } from '../../../../../../entry/src/main/ets/model/type';
import { PickerShowSubData } from '../../../../../../entry/src/main/ets/model/type/ContactParams';

export default class ContactListItem {
  public static readonly COLUMNS: string[] = [Contacts.ID, Contacts.NAME_RAW_CONTACT_ID,
    Contacts.QUICK_SEARCH_KEY, RawContacts.DISPLAY_NAME,
    RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME,
    Contacts.COMPANY, Contacts.POSITION, RawContacts.FAVORITE_ORDER, RawContacts.FAVORITE, RawContacts.MARK_MY_CARD];
  public static readonly COLUMNS_CONTACT_LIST_INDEX: string[] = [Contacts.ID, Contacts.NAME_RAW_CONTACT_ID,
    Contacts.QUICK_SEARCH_KEY, RawContacts.DISPLAY_NAME,
    RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME,
    Contacts.COMPANY, Contacts.POSITION, RawContacts.FAVORITE_ORDER, RawContacts.FAVORITE,
    RawContacts.SORT_KEY, RawContacts.SORT
  ];
  public static readonly COLUMNS_CONTACT_LIST_GET_ALL_CONTACT: string[] = [Contacts.ID, Contacts.NAME_RAW_CONTACT_ID,
    RawContacts.DISPLAY_NAME,
    RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME,
    Contacts.COMPANY, Contacts.POSITION, RawContacts.FAVORITE, RawContacts.MARK_MY_CARD
  ];
  public static readonly COLUMNS_INTELLIGENCE_GROUP: string[] = [Contacts.COMPANY, Contacts.COUNT];
  public static readonly COLUMNS_LOCATION: string[] = [Contacts.LOCATION, Contacts.COUNT];
  public static readonly COLUMNS_LATEST_CONTACT_TIME: string[] = [Contacts.LOCATION, Contacts.COUNT];
  public static readonly COLUMNS_CONTACT_LIST_GET_ALL_CONTACT_INCLUDE_CONTACT_TIME: string[] = [Contacts.ID,
    Contacts.NAME_RAW_CONTACT_ID,
    RawContacts.DISPLAY_NAME,
    RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME,
    Contacts.COMPANY, Contacts.POSITION, RawContacts.FAVORITE, RawContacts.MARK_MY_CARD,
    RawContacts.LASTEST_CONTACTED_TIME,
    RawContacts.SORT_KEY, RawContacts.SORT
  ];
  public static readonly COLUMNS_WITH_MEETIME_IMG: string[] =
    [Contacts.ID, Contacts.NAME_RAW_CONTACT_ID, Contacts.QUICK_SEARCH_KEY, RawContacts.DISPLAY_NAME,
      RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, Contacts.COMPANY, Contacts.POSITION,
      RawContacts.FAVORITE_ORDER, RawContacts.EXTRA3];
  public static readonly ACCOUNT_COLUMNS: string[] =
    [Contacts.ID, Contacts.ACCOUNT_NAME, Contacts.ACCOUNT_TYPE, Contacts.DATA_INFO];
  public static readonly COLUMNS_RAW_CONTACT: string[] =
    [Contacts.ID, RawContacts.CONTACT_ID, RawContacts.DISPLAY_NAME];
  public readonly id: number;
  public readonly nameRawContactId: number;
  public readonly displayName: string;
  public readonly sortFirstLetter: string;
  public readonly photoFirstName: string;
  public readonly quickSearchKey: string;
  public readonly company: string;
  public readonly position: string;
  public readonly favoriteOrder: number;
  public readonly extra3: string;
  public show?: boolean = false;
  public phoneNumbers: PhoneNumberInterface[] = [];
  public readonly favorite: string;
  public readonly sort: string;
  public readonly sortKey: string;
  public pickerShowSubDatas: PickerShowSubData[] = [];

  constructor(resultSet: DataShareResultSet) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
    this.nameRawContactId = resultSet.getLong(resultSet.getColumnIndex(Contacts.NAME_RAW_CONTACT_ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
    this.sortFirstLetter = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
    this.photoFirstName = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
    this.quickSearchKey = resultSet.getString(resultSet.getColumnIndex(Contacts.QUICK_SEARCH_KEY));
    this.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
    this.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
    this.favoriteOrder = resultSet.getLong(resultSet.getColumnIndex(RawContacts.FAVORITE_ORDER));
    this.extra3 = resultSet.getString(resultSet.getColumnIndex(RawContacts.EXTRA3))
    this.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
    this.sort = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT));
    this.sortKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_KEY));
  }

  createContact() {
    return new Contact(new ContactBuilder(this.id));
  }
}