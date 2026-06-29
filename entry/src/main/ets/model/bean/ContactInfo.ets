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

import { PhoneNumBean } from '../bean/PhoneNumBean'
import { EmailBean } from '../bean/EmailBean'
import { AIMBean } from '../bean/AIMBean'
import { HouseBean } from '../bean/HouseBean'
import { GroupBean } from '../bean/GroupBean'
import { EventBean } from '../bean/EventBean'
import { AssociatedPersonBean } from '../bean/AssociatedPersonBean'
import { StringUtil } from '../../../../../../feature/call/oh_modules/common'
import { PhoneNumber } from '../../../../../../feature/phonenumber'
import MeeTimeAbilityInfoModel from '../../../../../../feature/contact/src/main/ets/entity/MeeTimeAbilityInfoModel'
import RawContact from '../../../../../../feature/contact/src/main/ets/entity/RawContact';
import StringFormatUtil from '../../util/StringFormatUtil'
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog'

const TAG = 'ContactInfo  ';

export class ContactInfo {
  public contactID: string;
  // 主联系人的rawContactId,当前使用最小的Id
  public rowContactID: string;
  public display_name: string;
  public nickname: string;
  public phones: PhoneNumBean[];
  public emails: EmailBean [];
  public remarks: string;
  public position: string;
  public company: string;
  public aims: AIMBean[];
  public houses: HouseBean[];
  public websites: string[];
  public relationships: AssociatedPersonBean[];
  public events: EventBean[];
  public groups: GroupBean[];
  public favorite: number;
  public phoneticName: string = '';
  public otherLanLastName: string = '';
  public otherLanFirstName: string = '';
  public photo?: Uint8Array | null = null;
  public meeTimeAbilityInfoModel?: MeeTimeAbilityInfoModel;
  // 联系人原始数据信息
  public rawContacts: RawContact[] = [];
  public personalRingtone: string = '';
  public personalRingtonePath: string = '';
  public personalNotificationRingtone: string = '';

  constructor(contactID: string, display_name: string = '',
              nickname: string = '', phones: PhoneNumBean[] = [],
              emails: EmailBean[] = [], position: string = '', company: string = '', remarks: string,
              aims: AIMBean[], houses: HouseBean[], websites: string[],
              relationships: AssociatedPersonBean[], events: EventBean[], groups: GroupBean[],
              favorite: number, phoneticName: string = '', otherLanLastName: string = '',
              otherLanFirstName: string = '', photo?: Uint8Array | null) {
    this.contactID = contactID;
    this.display_name = display_name;
    this.nickname = nickname;
    this.phones = phones;
    this.emails = emails;
    this.position = position;
    this.company = company;
    this.remarks = remarks;
    this.aims = aims;
    this.houses = houses;
    this.websites = websites;
    this.relationships = relationships;
    this.events = events;
    this.groups = groups;
    this.favorite = favorite;
    this.phoneticName = phoneticName;
    this.otherLanLastName = otherLanLastName;
    this.otherLanFirstName = otherLanFirstName;
    this.photo = photo || null;
    this.rowContactID = '';
  }

  setContactID(contactID: string) {
    this.contactID = contactID;
    return this;
  }

  setRowContactId(rowContactID: string) {
    this.rowContactID = rowContactID;
    return this;
  }

  static buildFromParameters(paramsData: ContactInfo): ContactInfo {
    return new ContactInfo(
      paramsData.contactID,
      paramsData.display_name,
      paramsData.nickname,
      paramsData.phones,
      paramsData.emails,
      paramsData.position,
      paramsData.company,
      paramsData.remarks,
      paramsData.aims,
      paramsData.houses,
      paramsData.websites,
      paramsData.relationships,
      paramsData.events,
      paramsData.groups,
      paramsData.favorite,
      paramsData.phoneticName,
      paramsData.otherLanLastName,
      paramsData.otherLanFirstName,
      paramsData.photo
    )
      .setRowContactId(paramsData.rowContactID)
      .setRawContacts(paramsData.rawContacts)
      .setPersonalRingtone(paramsData.personalRingtone)
      .setPersonalNotificationRingtone(paramsData.personalNotificationRingtone)
      .setPersonalRingtonePath(paramsData.personalRingtonePath)
  }

  getDisplayNameByRule(): string {
    let displayNameByRule = '';
    if (this.display_name.length > 0) {
      displayNameByRule = this.display_name;
    } else if (this.phoneticName.length > 0) {
      displayNameByRule = this.phoneticName;
    } else if (this.nickname.length > 0) {
      displayNameByRule = this.nickname;
    } else if (this.company.length > 0) {
      displayNameByRule = this.company;
    } else if (this.position.length > 0) {
      displayNameByRule = this.position;
    } else if (this.phones.length > 0) {
      for (let element of this.phones) {
        if (StringUtil.isEmpty(element.num)) {
          continue;
        }
        displayNameByRule = PhoneNumber.fromString(element.num).getNumber();
        break;
      }
    }
    if (StringUtil.isEmpty(displayNameByRule) && this.emails.length > 0) {
      for (let element of this.emails) {
        if (StringUtil.isEmpty(element.address)) {
          continue;
        }
        displayNameByRule = element.address;
        break;
      }
    }
    // if (StringUtil.isEmpty(displayNameByRule)&&this.aims.length>0) {
    //   for (let element of this.aims) {
    //     if (StringUtil.isEmpty(element.aimName)) {
    //       continue;
    //     }
    //     displayNameByRule = element.aimName;
    //     break;
    //   }
    // }

    return displayNameByRule;
  }

  setDisplayName(display_name: string) {
    this.display_name = display_name;
    return this;
  }

  setPhoneticName(phoneticName: string) {
    this.phoneticName = phoneticName;
    return this;
  }

  setNickName(nickname: string) {
    this.nickname = nickname;
    return this;
  }

  setPhones(phones: PhoneNumBean[]) {
    this.phones = phones;
    return this;
  }

  setEmails(emails: EmailBean[]) {
    this.emails = emails;
    return this;
  }

  setRemarks(remarks: string) {
    this.remarks = remarks;
    return this;
  }

  setPosition(position: string) {
    this.position = position;
    return this;
  }

  setCompany(company: string) {
    this.company = company;
    return this;
  }

  setAims(aims: AIMBean[]) {
    this.aims = aims;
    return this;
  }

  setHouses(houses: HouseBean[]) {
    this.houses = houses;
    return this;
  }

  setWebsites(websites: string[]) {
    this.websites = websites;
    return this;
  }

  setRelationships(relationships: AssociatedPersonBean[]) {
    this.relationships = relationships;
    return this;
  }

  setEvents(events: EventBean[]) {
    const numExp = new RegExp('[0-9]', 'g')
    for (let item of events) {
      if (StringFormatUtil.checkEventValid2(item.data)) {
        item.data = item.data.replaceAll('/', '-')
        HiLog.w(TAG, `event data is YYYY/MM/DD data`)
      } else if (StringFormatUtil.checkEventValid(item.data)) {
        HiLog.w(TAG, `event data is default data`)
      } else {
        let printStr: string = item.data?.replace(numExp, '*');
        HiLog.w(TAG, `event data not valid. data:${printStr}`)
        continue;
      }
      this.events.push(item)
    }
    return this;
  }

  setGroups(groups: GroupBean[]) {
    this.groups = groups;
    return this;
  }

  setRawContacts(rawContacts: RawContact[]) {
    this.rawContacts = rawContacts;
    return this;
  }

  setPersonalRingtone(personalRingtone: string) {
    this.personalRingtone = personalRingtone;
    return this;
  }

  setPersonalNotificationRingtone(personalNotificationRingtone: string) {
    this.personalNotificationRingtone = personalNotificationRingtone;
    return this;
  }

  setPersonalRingtonePath(personalRingtonePath: string) {
    this.personalRingtonePath = personalRingtonePath;
    return this;
  }
}
