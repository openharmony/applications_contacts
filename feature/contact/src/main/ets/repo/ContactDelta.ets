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
import RawContactDelta from './RawContactDelta';
import { RawContacts } from '../contract/RawContacts';
import DAOperation from './DAOperation';

export default class ContactDelta {
  readonly rawContactDeltas: RawContactDelta[];
  constructor() {
    this.rawContactDeltas = [];
  }

  static fromContact(contact: Contact) {
    let contactDelta = new ContactDelta();
    for (let rawContact of contact.rowContacts) {
      let rawContactDelta = RawContactDelta.fromRawContact(rawContact);
      contactDelta.rawContactDeltas.push(rawContactDelta);
    }
    return contactDelta;
  }

  buildDiff() {
    let diff = [];
    for (let i = 0; i < this.rawContactDeltas.length; i++) {
      let rawContactDelta = this.rawContactDeltas[i];
      rawContactDelta.buildDiff(diff);
    }
    return diff;
  }

  private findRawContactId() {
    for (let i = 0; i < this.rawContactDeltas.length; i++) {
      let rawContactId = this.rawContactDeltas[i].values.getValue(RawContacts.ID);
      if (rawContactId != undefined && rawContactId >= 0) {
        return rawContactId;
      }
    }
    return -1;
  }
}