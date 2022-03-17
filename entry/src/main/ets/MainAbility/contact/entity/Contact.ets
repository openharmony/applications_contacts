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

import AccountType from '../../account/type/AccountType';
import RawContact from './RawContact';
import ContactBuilder from './ContactBuilder';
import ContactDelta from '../repo/ContactDelta';

export default class Contact {
  readonly id: number;
  readonly nameRawContactId: number;
  readonly quickSearchKey: string;
  readonly photoId: number;
  readonly photoFileId: number;
  readonly personalRingtone: string;
  readonly personalNotificationRingtone: string;
  readonly isTransferVoiceMail: boolean;
  readonly company: string;
  readonly position: string;
  readonly hasDisplayName: boolean;
  readonly hasPhoneNumber: boolean;
  readonly readOnly: boolean;
  readonly hasGroup: boolean;
  readonly hasEmail: boolean;
  readonly rowContacts: RawContact[];
  readonly accountTypes: AccountType[];

  constructor(contactBuilder: ContactBuilder) {
    this.id = contactBuilder.id;
    this.nameRawContactId = contactBuilder.nameRawContactId;
    this.quickSearchKey = contactBuilder.quickSearchKey;
    this.photoId = contactBuilder.photoId;
    this.photoFileId = contactBuilder.photoFileId;
    this.personalRingtone = contactBuilder.personalRingtone;
    this.personalNotificationRingtone = contactBuilder.personalNotificationRingtone;
    this.isTransferVoiceMail = contactBuilder.isTransferVoiceMail;
    this.company = contactBuilder.company;
    this.position = contactBuilder.position;
    this.hasDisplayName = contactBuilder.hasDisplayName;
    this.hasPhoneNumber = contactBuilder.hasPhoneNumber;
    this.readOnly = contactBuilder.readOnly;
    this.hasGroup = contactBuilder.hasGroup;
    this.hasEmail = contactBuilder.hasEmail;
    this.rowContacts = contactBuilder.rowContacts;
    this.accountTypes = contactBuilder.accountTypes;
  }

  addToBlackList() {
    return;
  }

  removeFromBlackList() {
    return;
  }

  isInBlackList() {
    return false;
  }

  star() {
    return false;
  }

  unStar() {
    return false;
  }

  protected getSharedText() {
    return "我是被分享的文本";
  }

  protected getSharedQRCode() {
    return "我是被分享的二维码";
  }

  protected getSharedVcard() {
    return "我是被分享的Vcard";
  }
  /**
   * type:
   * 1: 二维码
   * 2：vCard
   * 3：文本
   */
  shareContactByType(type: number) {
  }

  // 照理这个联系人不应该关心，但是日历模块太小，先放这
  addBirthDayToCalendar() {

  }

  clearPhotos() {
    return false;
  }

  getPhoto() {
    return {};
  }

  isReadOnly() {
    return false;
  }
}

