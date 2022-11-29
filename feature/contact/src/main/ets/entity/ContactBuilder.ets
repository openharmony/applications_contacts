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

import RawContact from './RawContact';
import Contact from './Contact';
import { Contacts } from '../contract/Contacts';
import { Data } from '../contract/Data';
import { RawContacts } from '../contract/RawContacts';

/**
 * Call log constructor
 */
export default class ContactBuilder {
  readonly id: number;
  nameRawContactId: number;
  quickSearchKey: string;
  photoId: number;
  photoFileId: number;
  personalRingtone: string;
  personalNotificationRingtone: string;
  isTransferVoiceMail: boolean;
  company: string;
  position: string;
  hasDisplayName: boolean;
  hasPhoneNumber: boolean;
  readOnly: boolean;
  hasGroup: boolean;
  hasEmail: boolean;
  rowContacts: RawContact[];

  constructor(id: number) {
    this.id = id;
  }

  static fromResultSet(resultSet: any): ContactBuilder{
    let contactBuilder = new ContactBuilder(resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID)));
    contactBuilder.setNameRawContactId(resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)));
    contactBuilder.setQuickSearchKey(resultSet.getString(resultSet.getColumnIndex(Contacts.QUICK_SEARCH_KEY)));
    contactBuilder.setPhotoId(resultSet.getLong(resultSet.getColumnIndex(Contacts.PHOTO_ID)));
    contactBuilder.setPhotoFileId(resultSet.getLong(resultSet.getColumnIndex(Contacts.PHOTO_FILE_ID)));
    contactBuilder.setPersonalRingtone(resultSet.getString(resultSet.getColumnIndex(Contacts.PERSONAL_RINGTONE)));
    contactBuilder.setPersonalNotificationRingtone(resultSet.getString(resultSet.getColumnIndex(Contacts.PERSONAL_NOTIFICATION_RINGTONE)));
    contactBuilder.setIsTransferVoiceMail(resultSet.getLong(resultSet.getColumnIndex(Contacts.IS_TRANSFER_VOICEMAIL)) > 0 ? true : false);
    contactBuilder.setCompany(resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY)));
    contactBuilder.setPosition(resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION)));
    contactBuilder.setHasDisplayName(resultSet.getLong(resultSet.getColumnIndex(Contacts.HAS_DISPLAY_NAME)) > 0 ? true : false);
    contactBuilder.setHasEmail(resultSet.getLong(resultSet.getColumnIndex(Contacts.IS_TRANSFER_VOICEMAIL)) > 0 ? true : false);
    contactBuilder.setHasGroup(resultSet.getLong(resultSet.getColumnIndex(Contacts.HAS_GROUP)) > 0 ? true : false);
    contactBuilder.setHasPhoneNumber(resultSet.getLong(resultSet.getColumnIndex(Contacts.HAS_PHONE_NUMBER)) > 0 ? true : false);
    contactBuilder.setReadOnly(resultSet.getLong(resultSet.getColumnIndex(Contacts.READ_ONLY)) > 0 ? true : false);
    contactBuilder.setRowContacts([]);
    return contactBuilder;
  }

  setNameRawContactId(nameRawContactId: number) {
    this.nameRawContactId = nameRawContactId;
    return this;
  }

  setPhotoId(photoId: number) {
    this.photoId = photoId;
    return this;
  }

  setPhotoFileId(photoFileId: number) {
    this.photoFileId = photoFileId;
    return this;
  }

  setQuickSearchKey(quickSearchKey: string) {
    this.quickSearchKey = quickSearchKey;
    return this;
  }

  setPersonalNotificationRingtone(personalNotificationRingtone: string) {
    this.personalNotificationRingtone = personalNotificationRingtone;
    return this;
  }

  setPersonalRingtone(personalRingtone: string) {
    this.personalRingtone = personalRingtone;
    return this;
  }

  setIsTransferVoiceMail(isTransferVoiceMail: boolean) {
    this.isTransferVoiceMail = isTransferVoiceMail;
    return this;
  }

  setCompany(company: string) {
    this.company = company;
    return this;
  }

  setPosition(position: string) {
    this.position = position;
    return this;
  }

  setHasDisplayName(hasDisplayName: boolean) {
    this.hasDisplayName = hasDisplayName;
    return this;
  }

  setReadOnly(readOnly: boolean) {
    this.readOnly = readOnly;
    return this;
  }

  setHasPhoneNumber(hasPhoneNumber: boolean) {
    this.hasPhoneNumber = hasPhoneNumber;
    return this;
  }

  setHasGroup(hasGroup: boolean) {
    this.hasGroup = hasGroup;
    return this;
  }

  setHasEmail(hasEmail: boolean) {
    this.hasEmail = hasEmail;
    return this;
  }

  setRowContacts(rowContacts: RawContact[]) {
    this.rowContacts = rowContacts;
    return this;
  }

  buildContact() {
    return new Contact(this);
  }
}