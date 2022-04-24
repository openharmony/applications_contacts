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

import {EmailBean} from './EmailBean';
import {RemDayBean} from './RemDayBean';
import {AssociatedPersonBean} from './AssociatedPersonBean';
import {AIMBean} from './AIMBean';
import {HouseBean} from './HouseBean';
import {GroupBean} from './GroupBean';
import {PhoneNumBean} from './PhoneNumBean';

export class ContactBean {
  /**
   * Contact ID primary key.
   */
  id: string;

  /**
   * Contact Name
   */
  name: string;

  /**
   * The Company
   */
  company: string;

  /**
   * Position
   */
  position: string;

  /**
   * Mobile Number List
   */
  phoneNumList: PhoneNumBean[];

  /**
   * Mailbox List
   */
  emailBeanList: EmailBean[];

  /**
   * Nickname
   */
  nickName: string

  /**
   * Website List
   */
  webSitList: string[]

  /**
   * Anniversaries List
   */
  remembranceDayList: RemDayBean[]

  /**
   * Ringtone
   */
  ringtone: string

  /**
   * Associated Person List
   */
  associatedPersonList: AssociatedPersonBean[]

  /**
   * Remarks
   */
  remarks: string

  /**
   * AIM List
   */
  aimList: AIMBean[]

  /**
   * Address List
   */
  houseList: HouseBean[]

  /**
   * Group List
   */
  groupList: GroupBean[]

  constructor(
    id: string,
    name: string,
    company: string,
    position: string,
    phoneNumList: PhoneNumBean[],
    emailBeanList: EmailBean[],
    nickName: string,
    webSitList: string[],
    remembranceDayList: RemDayBean[],
    ringtone: string,
    associatedPersonList: AssociatedPersonBean[],
    remarks: string,
    aimList: AIMBean[],
    houseList: HouseBean[],
    groupList: GroupBean[]) {
    this.id = id;
    this.name = name;
    this.company = company;
    this.position = position;
    this.phoneNumList = phoneNumList;
    this.emailBeanList = emailBeanList;
    this.nickName = nickName;
    this.webSitList = webSitList;
    this.remembranceDayList = remembranceDayList;
    this.ringtone = ringtone;
    this.associatedPersonList = associatedPersonList;
    this.remarks = remarks;
    this.aimList = aimList;
    this.houseList = houseList;
    this.groupList = groupList;
  }
}
