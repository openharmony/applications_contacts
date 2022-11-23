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

import { AccountType } from './AccountType';
import DataKind from './DataKind';
import EditType from './EditType';
import { Phone } from '../../../../../contact/src/main/ets/contract/Phone';
import { Email } from '../../../../../contact/src/main/ets/contract/Email';
import { House } from '../../../../../contact/src/main/ets/contract/House';
import { Birthday } from '../../../../../contact/src/main/ets/contract/Birthday';
import { Aim } from '../../../../../contact/src/main/ets/contract/Aim';
import { Im } from '../../../../../contact/src/main/ets/contract/Im';
import { StructuredPostal } from '../../../../../contact/src/main/ets/contract/StructuredPostal';
import { Event } from '../../../../../contact/src/main/ets/contract/Event';
import { Relation } from '../../../../../contact/src/main/ets/contract/Relation';

/**
 * Phone Account Type
 */
export default class PhoneAccountType extends AccountType {
  static readonly TYPE_KEY: string = AccountType.PHONE_ACCOUNT_TYPE;
  readonly mineKinds: Map<string, DataKind> = new Map();
  constructor() {
    super();
    this.init();
  }

  private init() {
    this.addDataKindPhone();
    this.addDataKindEmail();
    this.addDataKindIm();
    this.addDataKindStructuredPostal();
    this.addDataKindEvent();
    this.addDataKindRelation();
    this.addDataKindAim();
    this.addDataKindBirthday();
    this.addDataKindHouse();
  }

  private addDataKindPhone() {
    let typeList: EditType[] = [];
    typeList.push(this.buildPhoneType(Phone.TYPE_MOBILE));
    typeList.push(this.buildPhoneType(Phone.TYPE_WORK));
    typeList.push(this.buildPhoneType(Phone.TYPE_HOME));
    typeList.push(this.buildPhoneType(Phone.TYPE_MAIN));
    typeList.push(this.buildPhoneType(Phone.TYPE_FAX_WORK));
    typeList.push(this.buildPhoneType(Phone.TYPE_FAX_HOME));
    typeList.push(this.buildPhoneType(Phone.TYPE_PAGER));
    typeList.push(this.buildPhoneType(Phone.TYPE_OTHER));
    typeList.push(this.buildPhoneType(Phone.TYPE_CUSTOM));
    let kind = new DataKind(Phone.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Phone.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindEmail() {
    let typeList: EditType[] = [];
    typeList.push(this.buildEmailType(Email.TYPE_HOME));
    typeList.push(this.buildEmailType(Email.TYPE_WORK));
    typeList.push(this.buildEmailType(Email.TYPE_OTHER));
    typeList.push(this.buildEmailType(Email.TYPE_CUSTOM));
    let kind = new DataKind(Email.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Email.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindIm() {
    let typeList: EditType[] = [];
    typeList.push(this.buildImType(Im.TYPE_AIM));
    typeList.push(this.buildImType(Im.TYPE_MSN));
    typeList.push(this.buildImType(Im.TYPE_YAHOO));
    typeList.push(this.buildImType(Im.TYPE_SKYPE));
    typeList.push(this.buildImType(Im.TYPE_QQ));
    typeList.push(this.buildImType(Im.TYPE_GOOGLE_TALK));
    typeList.push(this.buildImType(Im.TYPE_JABBER));
    typeList.push(this.buildImType(Im.TYPE_CUSTOM));
    let kind = new DataKind(Im.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Im.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindStructuredPostal() {
    let typeList: EditType[] = [];
    typeList.push(this.buildEmailType(StructuredPostal.TYPE_HOME));
    typeList.push(this.buildEmailType(StructuredPostal.TYPE_WORK));
    typeList.push(this.buildEmailType(StructuredPostal.TYPE_OTHER));
    typeList.push(this.buildEmailType(StructuredPostal.TYPE_CUSTOM));
    let kind = new DataKind(StructuredPostal.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(StructuredPostal.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindEvent() {
    let typeList: EditType[] = [];
    typeList.push(this.buildEventType(Event.TYPE_BIRTHDAY));
    typeList.push(this.buildEventType(Event.TYPE_LUNARBIRTHDAY));
    typeList.push(this.buildEventType(Event.TYPE_ANNIVERSARY));
    typeList.push(this.buildEventType(Event.TYPE_OTHER));
    typeList.push(this.buildEventType(Event.TYPE_CUSTOM));
    let kind = new DataKind(Event.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Event.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindAim() {
    let typeList: EditType[] = [];
    typeList.push(this.buildAimType(Aim.TYPE_AIM));
    typeList.push(this.buildAimType(Aim.TYPE_WINDOWSLIVE));
    typeList.push(this.buildAimType(Aim.TYPE_YAHOO));
    typeList.push(this.buildAimType(Aim.TYPE_SKYPE));
    typeList.push(this.buildAimType(Aim.TYPE_QQ));
    typeList.push(this.buildAimType(Aim.TYPE_HANGOUTS));
    typeList.push(this.buildAimType(Aim.TYPE_ICQ));
    typeList.push(this.buildAimType(Aim.TYPE_JABBER));
    typeList.push(this.buildAimType(Aim.TYPE_CUSTOM));
    let kind = new DataKind(Aim.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Aim.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindRelation() {
    let typeList: EditType[] = [];
    typeList.push(this.buildRelationType(Relation.TYPE_ASSISTANT));
    typeList.push(this.buildRelationType(Relation.TYPE_BROTHER));
    typeList.push(this.buildRelationType(Relation.TYPE_CHILD));
    typeList.push(this.buildRelationType(Relation.TYPE_DOMESTIC_PARTNER));
    typeList.push(this.buildRelationType(Relation.TYPE_FATHER));
    typeList.push(this.buildRelationType(Relation.TYPE_MANAGER));
    typeList.push(this.buildRelationType(Relation.TYPE_MOTHER));
    typeList.push(this.buildRelationType(Relation.TYPE_PARENTS));
    typeList.push(this.buildRelationType(Relation.TYPE_PARTNER));
    typeList.push(this.buildRelationType(Relation.TYPE_REFERRED_BY));
    typeList.push(this.buildRelationType(Relation.TYPE_RELATIVE));
    typeList.push(this.buildRelationType(Relation.TYPE_SISTERS));
    typeList.push(this.buildRelationType(Relation.TYPE_SPOUSES));
    typeList.push(this.buildRelationType(Relation.TYPE_CUSTOM));
    let kind = new DataKind(Relation.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Relation.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindBirthday() {
    let typeList: EditType[] = [];
    typeList.push(this.buildBirthdayType(Birthday.TYPE_GREBIRTHDAY));
    typeList.push(this.buildBirthdayType(Birthday.TYPE_LUNARBIRTHDAY));
    typeList.push(this.buildBirthdayType(Birthday.TYPE_ANNIVERSARIES));
    typeList.push(this.buildBirthdayType(Birthday.TYPE_OTHER));
    let kind = new DataKind(Birthday.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(Birthday.CONTENT_ITEM_TYPE, kind);
  }

  private addDataKindHouse() {
    let typeList: EditType[] = [];
    typeList.push(this.buildHouseType(House.TYPE_DWELLING));
    typeList.push(this.buildHouseType(House.TYPE_POSITION));
    typeList.push(this.buildHouseType(House.TYPE_OTHER));
    typeList.push(this.buildHouseType(House.TYPE_CUSTOM));

    let kind = new DataKind(House.CONTENT_ITEM_TYPE, typeList);
    this.mineKinds.set(House.CONTENT_ITEM_TYPE, kind);
  }

  private buildHouseType(type: number) {
    return new EditType(type, House.getTypeLabelResource(type));
  }

  private buildPhoneType(type: number) {
    return new EditType(type, Phone.getTypeLabelResource(type));
  }

  private buildEmailType(type: number) {
    return new EditType(type, Email.getTypeLabelResource(type));
  }

  private buildImType(type: number) {
    return new EditType(type, Im.getTypeLabelResource(type));
  }

  private buildStructuredPostalType(type: number) {
    return new EditType(type, StructuredPostal.getTypeLabelResource(type));
  }

  private buildEventType(type: number) {
    return new EditType(type, Event.getTypeLabelResource(type));
  }

  private buildBirthdayType(type: number) {
    return new EditType(type, Birthday.getTypeLabelResource(type));
  }

  private buildAimType(type: number) {
    return new EditType(type, Aim.getTypeLabelResource(type));
  }

  private buildRelationType(type: number) {
    return new EditType(type, Relation.getTypeLabelResource(type));
  }
}
