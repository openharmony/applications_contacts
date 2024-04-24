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
import { EmailBean } from '../../../model/bean/EmailBean';
import { ContactInfo } from '../../../model/bean/ContactInfo';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import { HouseBean } from '../../../model/bean/HouseBean';
import { AIMBean } from '../../../model/bean/AIMBean';
import { EventBean } from '../../../model/bean/EventBean';
import { AssociatedPersonBean } from '../../../model/bean/AssociatedPersonBean';
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
  contactId: string = '';
  routerAvtiveFlag: boolean = false;

  // update mark
  updateShow: boolean = false;
  isShowPosition: boolean = false;
  showMore: boolean = false;
  addState: boolean = false;
  phones: string = '';
  editContact: number = -1;
  phoneNumberShow: string = '';
  callId: string = '';

  // refresh mark
  changed: boolean = false;
  originalContactInfo = JSON.stringify(new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0));
  // contact detail
  contactInfoBefore: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
  contactInfoAfter: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
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
  clickEnable = true;

  init(refreshState?) {
    this.contactId = '';
    this.updateShow = false;
    this.MagList = [1];
    this.contactInfoBefore = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
    this.contactInfoAfter = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
    this.refreshState = refreshState;
    this.routerAvtiveFlag = false;
  }

  refresh() {
    this.contactInfoBefore = this.contactInfoAfter;
    this.getPhones = this.getArray(this.contactInfoBefore.phones);
    this.getEmails = this.getArray(this.contactInfoBefore.emails);
    this.changed = !this.changed;
    this.refreshAddState();
    if (this.refreshState) {
      this.refreshState(this);
    }
  }

  refreshAddState() {
    let addState = this.originalContactInfo != this.getExistenceInfoString(this.contactInfoAfter);
    if (this.addState != addState) {
      HiLog.i(TAG, 'refreshAddState addState change:' + addState)
      this.addState = addState
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

  getExistenceInfoString(afterInfo: ContactInfo) {
    let temp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
    if (!afterInfo) {
      return JSON.stringify(temp);
    } else {
      if (!StringUtil.isEmpty(afterInfo.display_name)) {
        temp.display_name = afterInfo.display_name;
      }
      if (!StringUtil.isEmpty(afterInfo.nickname)) {
        temp.nickname = afterInfo.nickname
      }
      if (!StringUtil.isEmpty(afterInfo.remarks)) {
        temp.remarks = afterInfo.remarks;
      }
      if (!StringUtil.isEmpty(afterInfo.position)) {
        temp.position = afterInfo.position
      }
      if (!StringUtil.isEmpty(afterInfo.company)) {
        temp.company = afterInfo.company
      }
      if (!ArrayUtil.isEmpty(afterInfo.phones)) {
        for (let item of afterInfo.phones) {
          if (!StringUtil.isEmpty(item?.num)) {
            temp.phones.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.emails)) {
        for (let item of afterInfo.emails) {
          if (!StringUtil.isEmpty(item?.address)) {
            temp.emails.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.aims)) {
        for (let item of afterInfo.aims) {
          if (!StringUtil.isEmpty(item?.aimName)) {
            temp.aims.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.houses)) {
        for (let item of afterInfo.houses) {
          if (!StringUtil.isEmpty(item?.houseName)) {
            temp.houses.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.websites)) {
        for (let item of afterInfo.websites) {
          if (!StringUtil.isEmpty(item)) {
            temp.websites.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.events)) {
        for (let item of afterInfo.events) {
          if (!StringUtil.isEmpty(item?.data)) {
            temp.events.push(item)
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.relationships)) {
        for (let item of afterInfo.relationships) {
          if (!StringUtil.isEmpty(item?.name)) {
            temp.relationships.push(item)
          }
        }
      }
      return JSON.stringify(temp);
    }
  }

  getPageData(id: string) {
    if (StringUtil.isEmpty(id)) {
      HiLog.e(TAG, 'The parameter ID is empty.');
    }
    globalThis.DataWorker.sendRequest('getContactById', {
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
    let contactTemp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
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
    this.originalContactInfo = this.getExistenceInfoString(contactTemp)
    if (0 === this.editContact) {
      if ('' !== this.phones) {
        let saveTemp: Array<{ [key: string]: any }>  = this.getArray(this.phones);
        for(let i = 0; i < saveTemp?.length ; i ++){
          let phoneNumBean: PhoneNumBean = new PhoneNumBean('','','','','');
          phoneNumBean.id = saveTemp[i]?.item?.id;
          phoneNumBean.num = saveTemp[i]?.item?.num;
          phoneNumBean.numType = saveTemp[i]?.item?.type;
          phoneNumBean.homeArea = '';
          phoneNumBean.carriers = '';
          this.contactInfoBefore.phones.push(phoneNumBean);
        }
      }
    } else if (1 === this.editContact || 2 === this.editContact) {
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('','','','','');
      phoneNumBean.id = this.callId;
      phoneNumBean.num = this.phoneNumberShow;
      phoneNumBean.numType = '';
      phoneNumBean.homeArea = '';
      phoneNumBean.carriers = '';
      this.contactInfoBefore.phones.push(phoneNumBean);
    }
    this.getPhones = this.getArray(this.contactInfoBefore.phones);
    this.getEmails = this.getArray(this.contactInfoBefore.emails);
    this.contactInfoAfter = contactTemp;
    this.refreshAddState()
  }

  public getData(type: string, index: number): { [key: string]: any } {
    let data = new Array<{ [key: string]: any }>();
    switch (type) {
      case 'phone':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.phones);
        } else {
          data = this.getPhones;
        }
        break;
      case 'email':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.emails);
        } else {
          data = this.getEmails;
        }
        break;
      case 'AIM':
        data = this.getArray(this.contactInfoBefore.aims);
        break;
      case 'house':
        data = this.getArray(this.contactInfoBefore.houses);
        break;
      case 'relationships':
        data = this.getArray(this.contactInfoBefore.relationships);
        break;
      case 'events':
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
    if (ArrayUtil.isEmpty(array)) {
      array = [{}];
    }
    let itemList = ArrayUtil.isEmpty(array) ? this.MagList : array;
    itemList = itemList.map((item, index) => {
      return {
        i: index + 1, item: item
      };
    })
    return itemList;
  }

  public getDataArray(type: string) {
    let data = new Array<{ [key: string]: any }>();
    switch (type) {
      case 'phone':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.phones);
        } else {
          data = this.getPhones;
        }
        break;
      case 'email':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.emails);
        } else {
          data = this.getEmails;
        }
        break;
      case 'AIM':
        data = this.getArray(this.contactInfoBefore.aims);
        break;
      case 'house':
        data = this.getArray(this.contactInfoBefore.houses);
        break;
      case 'relationships':
        data = this.getArray(this.contactInfoBefore.relationships);
        break;
      case 'events':
        data = this.getArray(this.contactInfoBefore.events);
        break;
      default:
        break;
    }
    HiLog.i(TAG, 'getDataArray type: ' + type + ', length: ' + data.length);
    return data;
  }

  public addMore(type: any) {
    switch (type) {
      case 'phone':
        this.contactInfoAfter.phones.push(new PhoneNumBean('', '', '1', '', ''));
        break;
      case 'email':
        this.contactInfoAfter.emails.push(new EmailBean('', '', '1'));
        break;
      case 'AIM':
        this.contactInfoAfter.aims.push(new AIMBean('', '', '1', ''));
        break;
      case 'house':
        this.contactInfoAfter.houses.push(new HouseBean('', '', '1', ''));
        break;
      case 'relationships':
        this.contactInfoAfter.relationships.push(new AssociatedPersonBean('', '', '', '1'));
        break;
      case 'events':
        this.contactInfoAfter.events.push(new EventBean('', '', '1', ''));
        break;
      default:
        break;
    }
    this.refresh();
  }

  public deleteItem(typeName: string, startIndex) {
    HiLog.i(TAG, `deleteItem ${typeName} ${startIndex}`);
    switch (typeName) {
      case 'phone':
        if (this.contactInfoAfter.phones.length > 1) {
          this.contactInfoAfter.phones.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.phones[0].num = '';
        }
        this.getPhones = this.getArray(this.contactInfoAfter.phones);
        break;
      case 'email':
        if (this.contactInfoAfter.emails.length > 1) {
          this.contactInfoAfter.emails.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.emails[0].address = '';
        }
        this.getEmails = this.getArray(this.contactInfoAfter.emails);
        break;
      case 'AIM':
        if (this.contactInfoAfter.aims.length > 1) {
          this.contactInfoAfter.aims.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.aims[0].aimName = '';
        }
        break;
      case 'house':
        if (this.contactInfoAfter.houses.length > 1) {
          this.contactInfoAfter.houses.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.houses[0].houseName = '';
        }
        break;
      case 'relationships':
        if (this.contactInfoAfter.relationships.length > 1) {
          this.contactInfoAfter.relationships.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.relationships[0].name = '';
        }
        break;
      case 'events':
        if (this.contactInfoAfter.events.length > 1) {
          this.contactInfoAfter.events.splice(startIndex, 1);
        } else {
          this.contactInfoAfter.events[0].data = '';
        }
        break;
      default:
        break;
    }
    this.refresh();
  }

  public getTextDisplay(typeName: string, data: any) {
    let display: string = '';
    if (data && data.item) {
      switch (typeName) {
        case 'phone':
          if (data.item.hasOwnProperty('num')) {
            display = data.item.num;
          }
          break;
        case 'email':
          if (data.item.hasOwnProperty('address')) {
            display = data.item.address;
          }
          break;
        case 'AIM':
          if (data.item.hasOwnProperty('aimName')) {
            display = data.item.aimName;
          }
          break;
        case 'house':
          if (data.item.hasOwnProperty('houseName')) {
            display = data.item.houseName;
          }
          break;
        case 'relationships':
          if (data?.item.hasOwnProperty('name')) {
            display = data.item.name;
          }
          break;
        case 'events':
          if (data.item.hasOwnProperty('data')) {
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
        case 'phone':
          if (StringUtil.isEmpty(this.contactInfoAfter?.phones[data?.i - 1]?.numType)) {
            this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean('', '', '1', '', '');
          }
          this.contactInfoAfter.phones[data.i - 1].num = arg.toString();
          break;
        case 'email':
          if (StringUtil.isEmpty(this.contactInfoAfter?.emails[data?.i - 1]?.emailType)) {
            this.contactInfoAfter.emails[data.i - 1] = new EmailBean('', '', '1');
          }
          this.contactInfoAfter.emails[data.i - 1].address = arg.toString();
          break;
        case 'AIM':
          if (StringUtil.isEmpty(this.contactInfoAfter?.aims[data?.i - 1]?.aimType)) {
            this.contactInfoAfter.aims[data.i - 1] = new AIMBean('', '', '1', '');
          }
          this.contactInfoAfter.aims[data.i - 1].aimName = arg.toString();
          break;
        case 'house':
          if (StringUtil.isEmpty(this.contactInfoAfter?.houses[data?.i - 1]?.houseType)) {
            this.contactInfoAfter.houses[data.i - 1] = new HouseBean('', '', '1', '');
          }
          this.contactInfoAfter.houses[data.i - 1].houseName = arg.toString();
          break;
        case 'relationships':
          if (StringUtil.isEmpty(this.contactInfoAfter?.relationships[data?.i - 1]?.associatedType)) {
            this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean('', '', '', '1');
          }
          this.contactInfoAfter.relationships[data.i - 1].name = arg.toString();
          break;
        default:
          break;
      }
      this.refreshAddState()
    } catch (error) {
      HiLog.e(TAG, 'something error happened: ' + JSON.stringify(error));
    }
  }

  public menuSelect(typeName: string, data: any) {
    let typeId = 1;
    switch (typeName) {
      case 'phone':
        if (data.item.hasOwnProperty('numType')) {
          typeId = Number(data.item.numType)
        }
        return Phone.getTypeLabelResource(typeId);
        break;
      case 'email':
        if (data.item.hasOwnProperty('emailType')) {
          typeId = Number(data.item.emailType)
        }
        return Email.getTypeLabelResource(typeId);
        break;
      case 'AIM':
        if (data.item.hasOwnProperty('aimType')) {
          typeId = Number(data.item.aimType)
        }
        return Aim.getTypeLabelResource(typeId);
        break;
      case 'house':
        if (data.item.hasOwnProperty('houseType')) {
          typeId = Number(data.item.houseType)
        }
        return House.getTypeLabelResource(typeId);
        break;
      case 'relationships':
        if (data.item.hasOwnProperty('associatedType')) {
          typeId = Number(data.item.associatedType)
        }
        return Relation.getTypeLabelResource(typeId);
        break;
      case 'events':
        if (data.item.hasOwnProperty('eventType')) {
          typeId = Number(data.item.eventType)
        }
        return Birthday.getTypeLabelResource(typeId);
        break;
      default:
        return '';
        break;
    }
  }

  getMenuList(typeName: string) {
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList;
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    switch (typeName) {
      case 'phone':
        menuKindTypeList = phoneType.mineKinds.get(Phone.CONTENT_ITEM_TYPE).typeList;
        break;
      case 'email':
        menuKindTypeList = phoneType.mineKinds.get(Email.CONTENT_ITEM_TYPE).typeList;
        break;
      case 'AIM':
        menuKindTypeList = phoneType.mineKinds.get(Aim.CONTENT_ITEM_TYPE).typeList;
        break;
      case 'house':
        menuKindTypeList = phoneType.mineKinds.get(House.CONTENT_ITEM_TYPE).typeList;
        break;
      case 'relationships':
        menuKindTypeList = phoneType.mineKinds.get(Relation.CONTENT_ITEM_TYPE).typeList;
        break;
      case 'events':
        menuKindTypeList = phoneType.mineKinds.get(Birthday.CONTENT_ITEM_TYPE).typeList;
        break;
      default:
        break;
    }
    return menuKindTypeList;
  }

  public menuChange(typeName: string, data: any, item: any) {
    switch (typeName) {
      case 'phone':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.phones[data.i - 1])) {
          this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean('', '', '', '', '');
        }
        this.contactInfoAfter.phones[data.i - 1].numType = item.rawValue.toString();
        data.numType = item.rawValue.toString();
        break;
      case 'email':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.emails[data.i - 1])) {
          this.contactInfoAfter.emails[data.i - 1] = new EmailBean('', '', '');
        }
        this.contactInfoAfter.emails[data.i - 1].emailType = item.rawValue.toString();
        data.emailType = item.rawValue.toString();
        break;
      case 'AIM':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.aims[data.i - 1])) {
          this.contactInfoAfter.aims[data.i - 1] = new AIMBean('', '', '', '');
        }
        this.contactInfoAfter.aims[data.i - 1].aimType = item.rawValue.toString();
        break;
      case 'house':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.houses[data.i - 1])) {
          this.contactInfoAfter.houses[data.i - 1] = new HouseBean('', '', '', '');
        }
        this.contactInfoAfter.houses[data.i - 1].houseType = item.rawValue.toString();
        break;
      case 'relationships':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.relationships[data.i - 1])) {
          this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean('', '', '', '');
        }
        this.contactInfoAfter.relationships[data.i - 1].associatedType = item.rawValue.toString();
        break;
      case 'events':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.events[data.i - 1])) {
          this.contactInfoAfter.events[data.i - 1] = new EventBean('', '', '', '');
        }
        this.contactInfoAfter.events[data.i - 1].eventType = item.rawValue.toString();
        break;
      default:
        break;
    }
    this.addState = true;
    this.refresh();
  }

  saveClickEnable() {
    HiLog.i(TAG, 'msl, saveClickEnable in addState:' + this.addState + ',clickEnable:' + this.clickEnable)
    return this.addState && this.clickEnable;
  }

  public saveContact() {
    if (this.saveClickEnable()) {
      this.clickEnable = false
      if (this.updateShow === false) {
        globalThis.DataWorker.sendRequest('addContact',
          {
            context: globalThis.context,
            contactInfoAfter: JSON.stringify(this.contactInfoAfter)
          }
          , (arg) => {
            this.clickEnable = true
            this.contactId = arg.toString();
            this.routerAvtiveFlag = true;
            if (!PreferencesUtil.isUsed()) {
              PreferencesUtil.setIsUsed(true);
            }
          })
      }
      else {
        globalThis.DataWorker.sendRequest('updateContact', {
          context: globalThis.context,
          contactInfoAfter: JSON.stringify(this.contactInfoAfter)
        }, (arg) => {
          this.clickEnable = true
          this.contactId = arg.toString();
          this.routerAvtiveFlag = true;
          if (!PreferencesUtil.isUsed()) {
            PreferencesUtil.setIsUsed(true);
          }
        })
      }
    }
  }

  public textChange(data: string) {
    this.refresh();
  }

  /**
   * Hide the Keyboard to prevent occlusion dialogs.
   */
  hideKeyboard() {
    inputMethod.getController().hideSoftKeyboard((err) => {
    })
  }
}