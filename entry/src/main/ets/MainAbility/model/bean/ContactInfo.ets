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

import {PhoneNumBean} from "../bean/PhoneNumBean"
import {EmailBean} from "../bean/EmailBean"
import {AIMBean} from "../bean/AIMBean"
import {HouseBean} from "../bean/HouseBean"
import {GroupBean} from "../bean/GroupBean"
import {EventBean} from "../bean/EventBean"
import {AssociatedPersonBean} from "../bean/AssociatedPersonBean"

export class ContactInfo {
  id: string;
  display_name: string;
  nickname: string;
  //  phonetic_name: string;
  phones: PhoneNumBean[];
  emails: EmailBean [];
  remarks: string;
  position: string;
  company: string;
  aims: AIMBean[];
  houses: HouseBean[];
  websites: string[];
  relationships: AssociatedPersonBean[];
  events: EventBean[];
  groups: GroupBean[];
  constructor(id: string, display_name: string,
              nickname: string, phones: PhoneNumBean[],
              emails: EmailBean[], position: string, company: string, remarks: string,
              aims: AIMBean[], houses: HouseBean[], websites: string[],
              relationships: AssociatedPersonBean[], events: EventBean[], groups: GroupBean[]) {
    this.id = id;
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
  }

  setID(id: string) {
    this.id = id;
    return this;
  }

  setDisplayName(display_name: string) {
    this.display_name = display_name;
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
    this.events = events;
    return this;
  }

  setGroups(groups: GroupBean[]) {
    this.groups = groups;
    return this;
  }
}
