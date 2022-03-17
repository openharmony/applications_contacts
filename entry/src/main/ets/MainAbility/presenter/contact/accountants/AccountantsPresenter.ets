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

import resourceManager from '@ohos.resourceManager';
import router from '@system.router';
import ContactAbility from '../../../model/ContactAbilityModel'
import HiLog from '../../../util/Hilog';
import common from "../../../model/common";
import Constants from "../../../model/common/Constants";
import util from "../../../util/Utils";
import AccountTypeService from '../../../account/AccountTypeService';
import AccountType from '../../../account/type/AccountType';
import Aim from '../../../contact/contract/Aim';
import Birthday from '../../../contact/contract/Birthday';
import Email from '../../../contact/contract/Email';
import House from '../../../contact/contract/House';
import Relation from '../../../contact/contract/Relation';
import Phone from '../../../contact/contract/Phone';
import {EmailBean} from "../../../model/bean/EmailBean";
import {ContactInfo} from "../../../model/bean/ContactInfo";
import {PhoneNumBean} from "../../../model/bean/PhoneNumBean";
import {HouseBean} from "../../../model/bean/HouseBean";
import {AIMBean} from "../../../model/bean/AIMBean";
import {AssociatedPersonBean} from "../../../model/bean/AssociatedPersonBean";

const TAG = 'AccountantsPresenter  ';

/**
 * 添加联系人页面
 */
export default class AccountantsPresenter {

  private static instance: AccountantsPresenter;

  // 联系人id
  contactId:string = "";

  // 编辑模式
  updateShow: boolean = false;

  // 监听更新标识
  changed: boolean = false;

  // 联系人详情
  contactInfoBefore: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
  contactInfoAfter: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);


  // 下拉菜单
  birthdayMenu: any = [{ value: "", action: () => {} }];

  // 生日菜单默认选择类型
  birthDaySelect: Resource = $r("app.string.birthday_type_grebirthday");

  // 多联系人管理
  // [1] 占位
  MagList:any = [];

  private constructor() {
  }

  public static getInstance(): AccountantsPresenter {
    if (!AccountantsPresenter.instance) {
      AccountantsPresenter.instance = new AccountantsPresenter()
    }
    return AccountantsPresenter.instance
  }

  init() {
    this.getContactMenus();

    this.contactId = "";
    this.updateShow = false;
    this.MagList = [1];
    this.contactInfoBefore = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
    this.contactInfoAfter = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
  }

  refresh() {
    this.contactInfoBefore = this.contactInfoAfter;
    this.changed = !this.changed;
  }

  getContactMenus() {
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList;
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    let tmpPhoneMenu = [];
    menuKindTypeList = phoneType.mineKinds.get(Birthday.CONTENT_ITEM_TYPE).typeList;
    menuKindTypeList.forEach(element => {
      tmpPhoneMenu.push({});
    });
    this.birthdayMenu = tmpPhoneMenu;
    resourceManager.getResourceManager().then(result => {
      menuKindTypeList.forEach((element, i) => {
        result.getString(element.labelRes.id, (err, typeName) => {
          this.birthdayMenu[i] = {
            value: typeName,
            action: () => {
              this.birthDaySelect = element.labelRes;
            }
          }
        })
      })
    })
  }

  updatesInit() {
    HiLog.i(TAG, ' init start');
    this.contactInfoAfter.setID(this.contactId);
    if(this.updateShow == true ){
      HiLog.i(TAG, ' getPageData start %s', this.contactId);
      this.getPageData(this.contactId);
    }
  }

  isEmptyInfo(afterInfo: any) {
    let flag = false;
    flag = flag || !util.isEmpty(afterInfo.display_name);
    flag = flag || !util.isEmpty(afterInfo.nickname);
    flag = flag || !util.isEmpty(afterInfo.remarks);
    flag = flag || !util.isEmpty(afterInfo.position);
    flag = flag || !util.isEmpty(afterInfo.company);
    if (!util.isEmptyList(afterInfo.phones)) {
      flag = flag || !util.isEmpty(afterInfo.phones[0].num);
    }
    if (!util.isEmptyList(afterInfo.emails)) {
      flag = flag || !util.isEmpty(afterInfo.emails[0].address);
    }
    if (!util.isEmptyList(afterInfo.aims)) {
      flag = flag || !util.isEmpty(afterInfo.aims[0].aimName);
    }
    if (!util.isEmptyList(afterInfo.houses)) {
      flag = flag || !util.isEmpty(afterInfo.houses[0].houseName);
    }
    if (!util.isEmptyList(afterInfo.websites)) {
      flag = flag || !util.isEmpty(afterInfo.websites[0]);
    }
    if (!util.isEmptyList(afterInfo.events)) {
      flag = flag || !util.isEmpty(afterInfo.events[0].data);
    }
    if (!util.isEmptyList(afterInfo.relationships)) {
      flag = flag || !util.isEmpty(afterInfo.relationships[0].name);
    }
    return flag;
  }

  getPageData(id: string) {
    if (util.isEmpty(id)) {
      HiLog.e(TAG, 'The parameter ID is empty.');
    }
    var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    ContactAbility.getContactById(DAHelper, id, result => {
      if (util.isEmpty(result)) {
        HiLog.e(TAG, 'The result in the database is empty.');
        return;
      }
      this.dealRecordDetailsData(result.data);
    });
  }

  private dealRecordDetailsData(data){
    let contactTemp = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], []);
    if (!data.hasOwnProperty('id') || data.id != this.contactId) {
      HiLog.e(TAG, 'Failed to query the database based on the ID.');
      return;
    }
    contactTemp.setID(data.id);
    if(data.hasOwnProperty('display_name')) {
      contactTemp.setDisplayName(data.display_name);
    }
    if(data.hasOwnProperty('nickname')) {
      contactTemp.setNickName(data.nickname);
    }
    if(data.hasOwnProperty('phones')) {
      contactTemp.setPhones(data.phones);
    }
    if(data.hasOwnProperty('emails')) {
      contactTemp.setEmails(data.emails);
    }
    if(data.hasOwnProperty('remarks')) {
      contactTemp.setRemarks(data.remarks);
    }
    if(data.hasOwnProperty('position')) {
      contactTemp.setPosition(data.position);
    }
    if(data.hasOwnProperty('company')) {
      contactTemp.setCompany(data.company);
    }
    if(data.hasOwnProperty('aims')) {
      contactTemp.setAims(data.aims);
    }
    if(data.hasOwnProperty('houses')) {
      contactTemp.setHouses(data.houses);
    }
    if(data.hasOwnProperty('websites')) {
      contactTemp.setWebsites(data.websites);
    }
    if(data.hasOwnProperty('relationships')) {
      contactTemp.setRelationships(data.relationships);
    }
    if(data.hasOwnProperty('events')) {
      contactTemp.setEvents(data.events);
    }
    if(data.hasOwnProperty('groups')) {
      contactTemp.setGroups(data.groups);
    }
    this.contactInfoBefore = contactTemp;
    this.contactInfoAfter = contactTemp;
  }

  public getArray(array) {
    if(util.isEmptyList(array))
    array.push({});
    let itemList = util.isEmptyList(array) ? this.MagList : array;
    itemList = itemList.map((item, index) => {return { i: index + 1, item: item };})
    return itemList;
  }

  public addMore(type: any) {
    switch (type) {
      case "phone":
        this.contactInfoAfter.phones.push(new PhoneNumBean("", "", "1", "", ""));
        break;
      case "email":
        this.contactInfoAfter.emails.push(new EmailBean("", "",  "1"));
        break;
      case "AIM":
        this.contactInfoAfter.aims.push(new AIMBean("", "", "1", ""));
        break;
      case "house":
        this.contactInfoAfter.houses.push(new HouseBean("", "", "1", ""));
        break;
      case "relationships":
        this.contactInfoAfter.relationships.push(new AssociatedPersonBean("1", "", "", ""));
        break;
      default:
        break;
    }
    this.refresh();
  }

  public deleteItem(typeName: string, startIndex){
    switch(typeName){
      case "phone":
        if(this.contactInfoAfter.phones.length > 1){
          this.contactInfoAfter.phones.splice(startIndex, 1);
        }
        break;
      case "email":
        if(this.contactInfoAfter.emails.length > 1){
          this.contactInfoAfter.emails.splice(startIndex, 1);
        }
        break;
      case "AIM":
        if(this.contactInfoAfter.aims.length > 1){
          this.contactInfoAfter.aims.splice(startIndex, 1);
        }
      case "house":
        if(this.contactInfoAfter.houses.length > 1){
          this.contactInfoAfter.houses.splice(startIndex, 1);
        }
        break;
      case "relationships":
        if(this.contactInfoAfter.relationships.length > 1){
          this.contactInfoAfter.relationships.splice(startIndex, 1);
        }
        break;
      default:
        break;
    }
    this.refresh();
  }

  public phoneMenuSelect(type: number){
    return Phone.getTypeLabelResource(type);
  }

  public getTextDisplay(typeName: string, data: any) {
    let display: string = "";
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
        if (data.item.hasOwnProperty("name")) {
          display = data.item.name;
        }
        break;
      default:
        break;
    }
    return display;
  }

  public listItemChange(typeName: string, data:any, arg:string){
    switch(typeName){
      case "phone":
        if (util.isEmpty(this.contactInfoAfter.phones[data.i - 1].id)) {
          this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean("", "", "1", "", "");
        }
        this.contactInfoAfter.phones[data.i - 1].num = arg.toString();
        break;
      case "email":
        if (util.isEmpty(this.contactInfoAfter.emails[data.i - 1].id)) {
          this.contactInfoAfter.emails[data.i - 1] = new EmailBean("", "", "1");
        }
        this.contactInfoAfter.emails[data.i - 1].address = arg.toString();
        break;
      case "AIM":
        if (util.isEmpty(this.contactInfoAfter.aims[data.i - 1].aimId)) {
          this.contactInfoAfter.aims[data.i - 1] = new AIMBean("", "", "1", "");
        }
        this.contactInfoAfter.aims[data.i - 1].aimName = arg.toString();
        break;
      case "house":
        if (util.isEmpty(this.contactInfoAfter.houses[data.i - 1].houseId)) {
          this.contactInfoAfter.houses[data.i - 1] = new HouseBean("", "", "1", "");
        }
        this.contactInfoAfter.houses[data.i - 1].houseName = arg.toString();
        break;
      case "relationships":
        if (util.isEmpty(this.contactInfoAfter.relationships[data.i - 1].associatedPersonId)) {
          this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean("1", "", "", "");
        }
        this.contactInfoAfter.relationships[data.i - 1].name = arg.toString();
        break;
      default:
        break;
    }
  }

  public menuSelect(typeName: string, data: any) {
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
      default:
        return "";
        break;
    }
  }

  getMenuList(typeName: string){
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList;
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    switch(typeName){
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
      default:
        break;
    }
    return menuKindTypeList;
  }

  public menuChange(typeName: string, data: any, item: any) {
    switch (typeName) {
      case "phone":
        if (util.isEmptyObject(this.contactInfoAfter.phones[data.i - 1])) {
          this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean("", "", "", "", "");
        }
        this.contactInfoAfter.phones[data.i - 1].numType = item.rawValue.toString();
        break;
      case "email":
        if (util.isEmptyObject(this.contactInfoAfter.emails[data.i - 1])) {
          this.contactInfoAfter.emails[data.i - 1] = new EmailBean("", "", "");
        }
        this.contactInfoAfter.emails[data.i - 1].emailType = item.rawValue.toString();
        break;
      case "AIM":
        if (util.isEmptyObject(this.contactInfoAfter.aims[data.i - 1])) {
          this.contactInfoAfter.aims[data.i - 1] = new AIMBean("", "", "", "");
        }
        this.contactInfoAfter.aims[data.i - 1].aimType = item.rawValue.toString();
        break;
      case "house":
        if (util.isEmptyObject(this.contactInfoAfter.houses[data.i - 1])) {
          this.contactInfoAfter.houses[data.i - 1] = new HouseBean("", "", "", "");
        }
        this.contactInfoAfter.houses[data.i - 1].houseType = item.rawValue.toString();
        break;
      case "relationships":
        if (util.isEmptyObject(this.contactInfoAfter.relationships[data.i - 1])) {
          this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean("", "", "", "");
        }
        this.contactInfoAfter.relationships[data.i - 1].associatedType = item.rawValue.toString();
        break;
      default:
        break;
    }
    this.refresh();
  }
}