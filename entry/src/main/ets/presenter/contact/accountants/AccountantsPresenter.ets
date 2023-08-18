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

import inputMethod from '@ohos.inputMethod';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { AccountTypeService } from '../../../../../../../feature/account/src/main/ets/AccountTypeService';
import { AccountType } from '../../../../../../../feature/account/src/main/ets/type/AccountType';
import { House } from '../../../../../../../feature/contact/src/main/ets/contract/House';
import { Relation } from '../../../../../../../feature/contact/src/main/ets/contract/Relation';
import { Phone } from '../../../../../../../feature/contact/src/main/ets/contract/Phone';
import { Email } from '../../../../../../../feature/contact/src/main/ets/contract/Email';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { Aim } from '../../../../../../../feature/contact/src/main/ets/contract/Aim';
import { EmailBean } from "../../../model/bean/EmailBean";
import { ContactInfo } from "../../../model/bean/ContactInfo";
import { PhoneNumBean } from "../../../model/bean/PhoneNumBean";
import { HouseBean } from "../../../model/bean/HouseBean";
import { AIMBean } from "../../../model/bean/AIMBean";
import { EventBean } from "../../../model/bean/EventBean";
import { AssociatedPersonBean } from "../../../model/bean/AssociatedPersonBean";
import PreferencesUtil from './../../../util/PreferencesUtil'

const TAG = 'AccountantsPresenter  ';

/**
 * Add Contact Presenter
 */
export default class AccountantsPresenter {
  private static instance: AccountantsPresenter;
  static readonly timeSub: number = 1000;
  getPhones: Array<{ [key: string]: any }> = [];
  getEmails: Array<{ [key: string]: any }> = [];
  clickBefEvent: Date = new Date();
  clickAftEvent: Date = new Date();
  contactId: string = "";
  routerAvtiveFlag: boolean = false;

  // update mark
  updateShow: boolean = false;
  isShowPosition: boolean = false;
  showMore: boolean = false;
  addState: boolean = false;

  // refresh mark
  changed: boolean = false;

  // contact detail
  contactInfoBefore: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
  contactInfoAfter: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
  MagList: object = [];

  private constructor() {
  }

  public static getInstance(): AccountantsPresenter {
    if (!AccountantsPresenter.instance) {
      AccountantsPresenter.instance = new AccountantsPresenter()
    }
    return AccountantsPresenter.instance
  }

  refreshState: (presenter: AccountantsPresenter) => void;

  init(refreshState?) {
    this.contactId = "";
    this.updateShow = false;
    this.MagList = [1];
    this.contactInfoBefore = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
    this.contactInfoAfter = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
    this.clickBefEvent = new Date();
    this.clickAftEvent = this.clickBefEvent;
    this.refreshState = refreshState;
  }

  refresh() {
    this.contactInfoBefore = this.contactInfoAfter;
    this.changed = !this.changed;
    if (this.refreshState) {
      this.refreshState(this);
    }
  }

  updatesInit() {
    HiLog.i(TAG, ' init start');
    this.contactInfoAfter.setID(this.contactId);
    if (this.updateShow === true) {
      HiLog.i(TAG, ' getPageData start ');
      this.getPageData(this.contactId);
    }
  }

  isExistenceInfo(afterInfo: any) {
    if (!afterInfo) {
      return false;
    } else {
      let flag = false;
      flag = flag || !StringUtil.isEmpty(afterInfo.display_name);
      flag = flag || !StringUtil.isEmpty(afterInfo.nickname);
      flag = flag || !StringUtil.isEmpty(afterInfo.remarks);
      flag = flag || !StringUtil.isEmpty(afterInfo.position);
      flag = flag || !StringUtil.isEmpty(afterInfo.company);
      if (!ArrayUtil.isEmpty(afterInfo.phones)) {
        for (let item of afterInfo.phones) {
          flag = flag || !StringUtil.isEmpty(item?.num);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.emails)) {
        for (let item of afterInfo.emails) {
          flag = flag || !StringUtil.isEmpty(item?.address);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.aims)) {
        for (let item of afterInfo.aims) {
          flag = flag || !StringUtil.isEmpty(item?.aimName);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.houses)) {
        for (let item of afterInfo.houses) {
          flag = flag || !StringUtil.isEmpty(item?.houseName);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.websites)) {
        for (let item of afterInfo.websites) {
          flag = flag || !StringUtil.isEmpty(item);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.events)) {
        for (let item of afterInfo.events) {
          flag = flag || !StringUtil.isEmpty(item?.data);
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.relationships)) {
        for (let item of afterInfo.relationships) {
          flag = flag || !StringUtil.isEmpty(item?.name);
        }
      }
      return flag;
    }
  }

  getPageData(id: string) {
    if (StringUtil.isEmpty(id)) {
      HiLog.e(TAG, 'The parameter ID is empty.');
    }
    globalThis.DataWorker.sendRequest("getContactById", {
      context: globalThis.context,
      contactId: id
    }, result => {
      if (StringUtil.isEmpty(result)) {
        HiLog.e(TAG, 'The result in the database is empty.');
        return;
      }
      this.dealRecordDetailsData(result.data);
    });
  }

  private dealRecordDetailsData(data) {
    let contactTemp = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
    if (!data.hasOwnProperty('id') || data.id != this.contactId) {
      HiLog.e(TAG, 'Failed to query the database based on the ID.');
      return;
    }
    contactTemp.setID(data.id);
    let nameUpdate = 0;
    if (data.hasOwnProperty('nameUpdate')) {
      nameUpdate = data.nameUpdate;
    }
    if (data.hasOwnProperty('display_name') && nameUpdate == 0) {
      contactTemp.setDisplayName(data.display_name);
    }
    if (data.hasOwnProperty('nickname')) {
      contactTemp.setNickName(data.nickname);
    }
    if (data.hasOwnProperty('phones')) {
      contactTemp.setPhones(data.phones);
    }
    if (data.hasOwnProperty('emails')) {
      contactTemp.setEmails(data.emails);
    }
    if (data.hasOwnProperty('remarks')) {
      contactTemp.setRemarks(data.remarks);
    }
    if (data.hasOwnProperty('position')) {
      contactTemp.setPosition(data.position);
      this.isShowPosition = true;
    }
    if (data.hasOwnProperty('company')) {
      contactTemp.setCompany(data.company);
    }
    if (data.hasOwnProperty('aims')) {
      contactTemp.setAims(data.aims);
    }
    if (data.hasOwnProperty('houses')) {
      contactTemp.setHouses(data.houses);
    }
    if (data.hasOwnProperty('websites')) {
      contactTemp.setWebsites(data.websites);
    }
    if (data.hasOwnProperty('relationships')) {
      contactTemp.setRelationships(data.relationships);
    }
    if (data.hasOwnProperty('events')) {
      contactTemp.setEvents(data.events);
    }
    if (data.hasOwnProperty('groups')) {
      contactTemp.setGroups(data.groups);
    }
    this.contactInfoBefore = contactTemp;
    this.getPhones = this.getArray(this.contactInfoBefore.phones);
    this.getEmails = this.getArray(this.contactInfoBefore.emails);
    this.contactInfoAfter = contactTemp;
  }

  public getData(type: string, index: number): { [key: string]: any } {
    let data = new Array<{ [key: string]: any }>();
    switch (type) {
      case "phone":
        data = this.getArray(this.contactInfoBefore.phones);
        break;
      case "email":
        data = this.getArray(this.contactInfoBefore.emails);
        break;
      case "AIM":
        data = this.getArray(this.contactInfoBefore.aims);
        break;
      case "house":
        data = this.getArray(this.contactInfoBefore.houses);
        break;
      case "relationships":
        data = this.getArray(this.contactInfoBefore.relationships);
        break;
      case "events":
        data = this.getArray(this.contactInfoBefore.events);
        break;
      default:
        break;
    }
    if (index < data.length) {
      return data[index];
    }
    return {
      i: index + 1, item: {}
    };
  }

  public getArray(array): Array<{ [key: string]: any }> {
    if (ArrayUtil.isEmpty(array))
    array.push({});
    let itemList = ArrayUtil.isEmpty(array) ? this.MagList : array;
    itemList = itemList.map((item, index) => {
      return {
        i: index + 1, item: item
      };
    })
    return itemList;
  }

  public addMore(type: any) {
    switch (type) {
      case "phone":
        if (!this.updateShow) {
          this.contactInfoAfter.phones.push(new PhoneNumBean("", "", "1", "", ""));
        } else {
          let add = {
            i: this.getPhones.length + 1,
            item: new PhoneNumBean("", "", "1", "", "")
          }
          this.getPhones.push(add);
        }
        break;
      case "email":
        if (!this.updateShow) {
          this.contactInfoAfter.emails.push(new EmailBean("", "", "1"));
        } else {
          let add = {
            i: this.getEmails.length + 1,
            item: new EmailBean("", "", "1")
          }
          this.getEmails.push(add);
        }
        break;
      case "AIM":
        this.contactInfoAfter.aims.push(new AIMBean("", "", "1", ""));
        break;
      case "house":
        this.contactInfoAfter.houses.push(new HouseBean("", "", "1", ""));
        break;
      case "relationships":
        this.contactInfoAfter.relationships.push(new AssociatedPersonBean("", "", "", "1"));
        break;
      case "events":
        this.contactInfoAfter.events.push(new EventBean("", "", "1", ""));
        break;
      default:
        break;
    }
    this.refresh();
  }

  public deleteItem(typeName: string, startIndex) {
    HiLog.i(TAG, `deleteItem ${typeName} ${startIndex}`);
    switch (typeName) {
      case "phone":
        if (this.contactInfoAfter.phones.length > startIndex) {
          if (this.contactInfoAfter.phones.length > 0) {
            this.contactInfoAfter.phones.splice(startIndex, 1);
          } else {
            this.contactInfoAfter.phones[0].num = "";
          }
        }
        this.getPhones = this.getArray(this.contactInfoAfter.phones);
        break;
      case "email":
        if (this.contactInfoAfter.phones.length > startIndex) {
          if (this.contactInfoAfter.emails.length > 0) {
            this.contactInfoAfter.emails.splice(startIndex, 1);
          } else {
            this.contactInfoAfter.emails[0].address = "";
          }
        }
        this.getEmails = this.getArray(this.contactInfoAfter.emails);
        break;
      case "AIM":
        if (this.contactInfoAfter.aims.length > 1) {
          this.contactInfoAfter.aims.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.aims[0].aimName = "";
        }
        break;
      case "house":
        if (this.contactInfoAfter.houses.length > 1) {
          this.contactInfoAfter.houses.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.houses[0].houseName = "";
        }
        break;
      case "relationships":
        if (this.contactInfoAfter.relationships.length > 1) {
          this.contactInfoAfter.relationships.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.relationships[0].name = "";
        }
        break;
      case "events":
        if (this.contactInfoAfter.events.length > 1) {
          this.contactInfoAfter.events.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.events[0].data = "";
        }
        break;
      default:
        break;
    }
    this.addState = this.isExistenceInfo(this.contactInfoAfter);
    this.refresh();
  }

  public getTextDisplay(typeName: string, data: any) {
    let display: string = "";
    if (data && data.item) {
      switch (typeName) {
        case "phone":
          if (data.item.hasOwnProperty("num")) {
            display = data.item.num;
          }
          break;
        case "email":
          if (data.item.hasOwnProperty("address")) {
            display = data.item.address;
          }
          break;
        case "AIM":
          if (data.item.hasOwnProperty("aimName")) {
            display = data.item.aimName;
          }
          break;
        case "house":
          if (data.item.hasOwnProperty("houseName")) {
            display = data.item.houseName;
          }
          break;
        case "relationships":
          if (data?.item.hasOwnProperty("name")) {
            display = data.item.name;
          }
          break;
        case "events":
          if (data.item.hasOwnProperty("data")) {
            display = data.item.data;
          }
          break;
        default:
          break;
      }
    }
    return display;
  }

  public listItemChange(typeName: string, data: any, arg: string) {
    try {
      switch (typeName) {
        case "phone":
          if (StringUtil.isEmpty(this.contactInfoAfter?.phones[data?.i - 1]?.numType)) {
            this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean("", "", "1", "", "");
          }
          this.contactInfoAfter.phones[data.i - 1].num = arg.toString();
          break;
        case "email":
          if (StringUtil.isEmpty(this.contactInfoAfter?.emails[data?.i - 1]?.emailType)) {
            this.contactInfoAfter.emails[data.i - 1] = new EmailBean("", "", "1");
          }
          this.contactInfoAfter.emails[data.i - 1].address = arg.toString();
          break;
        case "AIM":
          if (StringUtil.isEmpty(this.contactInfoAfter?.aims[data?.i - 1]?.aimType)) {
            this.contactInfoAfter.aims[data.i - 1] = new AIMBean("", "", "1", "");
          }
          this.contactInfoAfter.aims[data.i - 1].aimName = arg.toString();
          break;
        case "house":
          if (StringUtil.isEmpty(this.contactInfoAfter?.houses[data?.i - 1]?.houseType)) {
            this.contactInfoAfter.houses[data.i - 1] = new HouseBean("", "", "1", "");
          }
          this.contactInfoAfter.houses[data.i - 1].houseName = arg.toString();
          break;
        case "relationships":
          if (StringUtil.isEmpty(this.contactInfoAfter?.relationships[data?.i - 1]?.associatedType)) {
            this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean("", "", "", "1");
          }
          this.contactInfoAfter.relationships[data.i - 1].name = arg.toString();
          break;
        default:
          break;
      }
    } catch (error) {
      HiLog.e(TAG, "something error happened: " + JSON.stringify(error));
    }
  }

  public menuSelect(typeName: string, data: any) {
    if (data == undefined || data.item == undefined) {
      return "";
    }
    let typeId = 1;
    switch (typeName) {
      case "phone":
        if (data.item.hasOwnProperty("numType")) {
          typeId = Number(data.item.numType)
        }
        return Phone.getTypeLabelResource(typeId);
        break;
      case "email":
        if (data.item.hasOwnProperty("emailType")) {
          typeId = Number(data.item.emailType)
        }
        return Email.getTypeLabelResource(typeId);
        break;
      case "AIM":
        if (data.item.hasOwnProperty("aimType")) {
          typeId = Number(data.item.aimType)
        }
        return Aim.getTypeLabelResource(typeId);
        break;
      case "house":
        if (data.item.hasOwnProperty("houseType")) {
          typeId = Number(data.item.houseType)
        }
        return House.getTypeLabelResource(typeId);
        break;
      case "relationships":
        if (data.item.hasOwnProperty("associatedType")) {
          typeId = Number(data.item.associatedType)
        }
        return Relation.getTypeLabelResource(typeId);
        break;
      case "events":
        if (data.item.hasOwnProperty("eventType")) {
          typeId = Number(data.item.eventType)
        }
        return Birthday.getTypeLabelResource(typeId);
        break;
      default:
        return "";
        break;
    }
  }

  getMenuList(typeName: string) {
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList;
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    switch (typeName) {
      case "phone":
        menuKindTypeList = phoneType.mineKinds.get(Phone.CONTENT_ITEM_TYPE).typeList;
        break;
      case "email":
        menuKindTypeList = phoneType.mineKinds.get(Email.CONTENT_ITEM_TYPE).typeList;
        break;
      case "AIM":
        menuKindTypeList = phoneType.mineKinds.get(Aim.CONTENT_ITEM_TYPE).typeList;
        break;
      case "house":
        menuKindTypeList = phoneType.mineKinds.get(House.CONTENT_ITEM_TYPE).typeList;
        break;
      case "relationships":
        menuKindTypeList = phoneType.mineKinds.get(Relation.CONTENT_ITEM_TYPE).typeList;
        break;
      case "events":
        menuKindTypeList = phoneType.mineKinds.get(Birthday.CONTENT_ITEM_TYPE).typeList;
        break;
      default:
        break;
    }
    return menuKindTypeList;
  }

  public menuChange(typeName: string, data: any, item: any) {
    if (data && data.i) {
      switch (typeName) {
        case "phone":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.phones[data.i - 1])) {
            this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean("", "", "", "", "");
          }
          this.contactInfoAfter.phones[data.i - 1].numType = item.rawValue.toString();
          break;
        case "email":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.emails[data.i - 1])) {
            this.contactInfoAfter.emails[data.i - 1] = new EmailBean("", "", "");
          }
          this.contactInfoAfter.emails[data.i - 1].emailType = item.rawValue.toString();
          break;
        case "AIM":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.aims[data.i - 1])) {
            this.contactInfoAfter.aims[data.i - 1] = new AIMBean("", "", "", "");
          }
          this.contactInfoAfter.aims[data.i - 1].aimType = item.rawValue.toString();
          break;
        case "house":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.houses[data.i - 1])) {
            this.contactInfoAfter.houses[data.i - 1] = new HouseBean("", "", "", "");
          }
          this.contactInfoAfter.houses[data.i - 1].houseType = item.rawValue.toString();
          break;
        case "relationships":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.relationships[data.i - 1])) {
            this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean("", "", "", "");
          }
          this.contactInfoAfter.relationships[data.i - 1].associatedType = item.rawValue.toString();
          break;
        case "events":
          if (ObjectUtil.isEmpty(this.contactInfoAfter.events[data.i - 1])) {
            this.contactInfoAfter.events[data.i - 1] = new EventBean("", "", "", "");
          }
          this.contactInfoAfter.events[data.i - 1].eventType = item.rawValue.toString();
          break;
        default:
          break;
      }
    } else {
      HiLog.e(TAG, "data.i is Empty!" + JSON.stringify(data));
      return;
    }
    this.addState = true;
    this.refresh();
  }

  public saveContact() {
    this.clickAftEvent = new Date();
    if (this.getAddState() && !this.clicksMultiple()) {
      if (this.updateShow === false) {
        globalThis.DataWorker.sendRequest("addContact",
          {
            context: globalThis.context,
            contactInfoAfter: JSON.stringify(this.contactInfoAfter)
          }
          , (arg) => {
            this.contactId = arg.toString();
            this.routerAvtiveFlag = true;
            if (!PreferencesUtil.isUsed()) {
              PreferencesUtil.setIsUsed(true);
            }
          })
      }
      else {
        globalThis.DataWorker.sendRequest("updateContact", {
          context: globalThis.context,
          contactInfoAfter: JSON.stringify(this.contactInfoAfter)
        }, (arg) => {
          this.contactId = arg.toString();
          this.routerAvtiveFlag = true;
          if (!PreferencesUtil.isUsed()) {
            PreferencesUtil.setIsUsed(true);
          }
        })
      }
    }
  }

  private clicksMultiple() {
    if (this.clickAftEvent.getTime() - this.clickBefEvent.getTime() > AccountantsPresenter.timeSub) {
      this.clickBefEvent = this.clickAftEvent;
      return false;
    }
    else {
      this.clickBefEvent = this.clickAftEvent;
      return true;
    }
  }

  public getAddState() {
    try {
      if (this.contactInfoAfter) {
        return this.addState && this.isExistenceInfo(this.contactInfoAfter);
      }
    } catch (err) {
      HiLog.i(TAG, "something err: " + JSON.stringify(err));
    }
  }

  public textChange(data: string) {
    this.addState = true;
    if (data.length === 0) {
      if (!this.isExistenceInfo(this.contactInfoAfter)) {
        this.addState = false;
      }
    }
    this.refresh();
  }

  /**
   * Hide the Keyboard to prevent occlusion dialogs.
   */
  hideKeyboard() {
    inputMethod.getController().hideSoftKeyboard((err) => {
      if (err === undefined) {
        HiLog.i(TAG, 'Succeeded in hiding softKeyboard.');
      } else {
        HiLog.e(TAG, 'Failed to hideSoftKeyboard: ' + JSON.stringify(err));
      }
    })
  }
}