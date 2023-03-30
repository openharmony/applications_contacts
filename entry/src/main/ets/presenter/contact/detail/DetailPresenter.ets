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

import router from '@ohos.router';
import prompt from '@system.prompt';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { CallLogRepository } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { CallType, CallLog } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { House } from '../../../../../../../feature/contact/src/main/ets/contract/House';
import { Relation } from '../../../../../../../feature/contact/src/main/ets/contract/Relation';
import { Phone } from '../../../../../../../feature/contact/src/main/ets/contract/Phone';
import { Email } from '../../../../../../../feature/contact/src/main/ets/contract/Email';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { Aim } from '../../../../../../../feature/contact/src/main/ets/contract/Aim';
import MorandiColor from '../../../model/bean/MorandiColor';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import DetailCallLogDataSource from '../../../model/bean/DetailCallLogDataSource';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import StringFormatUtil from "../../../util/StringFormatUtil"

const TAG = "DetailPresenter";

export default class DetailPresenter {
  private static sInstance: DetailPresenter;
  /** UI parameters */
  moreMenuOptions: Resource[] = [$r("app.string.delete_contact")];
  isFavorite: boolean = false;
  showNameLastMenu: string = '';
  lastUsedSlotId: number = -1;

  /** Display parameters */
  sourceHasId: boolean = false;
  sourceHasPhone: boolean = false;
  phoneNumberShow: string = '';
  contactId: number;
  isNewNumber: boolean = true;
  isNewDetail: boolean = false;
  topbarBackgroundColor: ResourceColor = Color.Transparent;
  newNumberBgColor: string = '';
  detailsColor: string = '';
  /** detail parameters */
  contactForm: any = {
    display_name: '',
    photoFirstName: '',
    company: '',
    position: '',
    phones: [],
    emails: [],
    aims: [],
    nickname: [],
    websites: [],
    houses: [],
    events: [],
    remarks: [],
    relationships: [],
    numRecords: [],
    portraitColor: '',
    detailsBgColor: ''
  };
  detailCallLogDataSource: DetailCallLogDataSource = new DetailCallLogDataSource();
  /** Contact Temporary */
  contacts: { [key: string]: any } = {};

  private constructor() {
  }

  public static getInstance(): DetailPresenter {
    if (DetailPresenter.sInstance == null) {
      DetailPresenter.sInstance = new DetailPresenter();
    }
    return DetailPresenter.sInstance;
  }

  async aboutToAppear() {
    // Groups, favorites, contact lists,new contacts.
    if (this.sourceHasId) {
      HiLog.i(TAG, 'onShow:sourceHasId');
      this.contactForm = {
        display_name: '',
        photoFirstName: '',
        company: '',
        position: '',
        phones: [],
        emails: [],
        aims: [],
        nickname: [],
        websites: [],
        houses: [],
        events: [],
        remarks: [],
        relationships: [],
        numRecords: [],
        portraitColor: '',
        detailsBgColor: ''
      };
      let requestData = {
        contactId: this.contactId
      };
      this.isNewNumber = false;
      this.getContactDetail(requestData);
    } else if (this.sourceHasPhone) {
      // call log, mms.
      HiLog.i(TAG, 'onShow:sourceHasPhone');
      this.contactForm = {
        display_name: '',
        photoFirstName: '',
        company: '',
        position: '',
        phones: [],
        emails: [],
        aims: [],
        nickname: [],
        websites: [],
        houses: [],
        events: [],
        remarks: [],
        relationships: [],
        numRecords: [],
        portraitColor: '',
        detailsBgColor: ''
      };
      /** Query the contact ID based on the phone number.
       If a contact exists,the contact details are displayed based on the first contact ID.*/
      globalThis.DataWorker.sendRequest("getIdByTelephone", {
        context: globalThis.context,
        phoneNumber: this.phoneNumberShow
      }, (contactId) => {
        if (!ArrayUtil.isEmpty(contactId)) {
          HiLog.i(TAG, "contactid is exist");
          // If a contact exists, set isNewNumber to false.
          this.isNewNumber = false;
          let requestData = {
            contactId: contactId[0]
          };
          this.getContactDetail(requestData);
        }
        if (this.isNewNumber) {
          // If the contact ID does not exist, the new number is used.
          this.getNewNumCallLog();
        }
      });
    }
    this.registerCallLogObsever();
    this.isNewNumber = true;
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'ContactDetail aboutToDisappear!');
  }

  registerCallLogObsever() {
    CallLogRepository.getInstance().registerDataChangeObserver(() => {
      this.refresh();
    });
  }

  refresh() {
    HiLog.i(TAG, 'refresh call log!');
    if (this.contactId != undefined) {
      this.getContactCallLog();
    } else {
      this.getNewNumCallLog();
    }
  }

  getContactDetail(data) {
    HiLog.i(TAG, 'get ContactDetail by id');
    globalThis.DataWorker.sendRequest("getContactById", {
      context: globalThis.context,
      contactId: data.contactId
    }, result => {
      if (StringUtil.isEmpty(result)) {
        // If the contact cannot be obtained based on the specified ID, the new number is used.
        this.getNewNumCallLog();
        return;
      }
      this.contactId = result.data.id;
      this.contacts = result.data;
      this.contactForm.portraitColor = MorandiColor.Color[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.contactForm.detailsBgColor = MorandiColor.detailColor[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.detailsColor = MorandiColor.detailColor[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.dealDetailsData();
    });
  }

  dealDetailsData() {
    HiLog.i(TAG, 'deal detail data');
    this.getLabelNameByTypeId();
    this.dealContactsToForm();
    this.getContactCallLog();
  }

  getLabelNameByTypeId() {
    if (this.contacts.hasOwnProperty('phones') && this.contacts.phones.length > 0) {
      this.contacts.phones.forEach((element) => {
        element.labelName = Phone.getTypeLabelResource(parseInt(element.numType, 10));
        element.phoneAddress = (element.phoneAddress == 'N' || StringUtil.isEmpty(element.phoneAddress)) ?
        $r("app.string.unknown") : element.phoneAddress;
      });
    }
    if (this.contacts.hasOwnProperty('emails') && this.contacts.emails.length > 0) {
      this.contacts.emails.forEach((element) => {
        element.labelName = Email.getTypeLabelResource(parseInt(element.emailType, 10));
      });
    }
    if (this.contacts.hasOwnProperty('aims') && this.contacts.aims.length > 0) {
      this.contacts.aims.forEach((element) => {
        element.labelName = Aim.getTypeLabelResource(parseInt(element.aimType, 10));
      });
    }
    if (this.contacts.hasOwnProperty('houses') && this.contacts.houses.length > 0) {
      this.contacts.houses.forEach((element) => {
        element.labelName = House.getTypeLabelResource(parseInt(element.houseType, 10));
      });
    }
    if (this.contacts.hasOwnProperty('events') && this.contacts.events.length > 0) {
      this.contacts.events.forEach((element) => {
        element.labelName = Birthday.getTypeLabelResource(parseInt(element.eventType, 10));
      });
    }
    if (this.contacts.hasOwnProperty('relationships') && this.contacts.relationships.length > 0) {
      this.contacts.relationships.forEach((element) => {
        element.labelName = Relation.getTypeLabelResource(parseInt(element.associatedType, 10));
      });
    }
  }

  dealContactsToForm() {
    let newContact = this.contacts;
    this.contactForm.display_name = (newContact.display_name && newContact.display_name.length > 0)
      ? newContact.display_name : $r('app.string.noName');
    this.contactForm.photoFirstName = (newContact.photoFirstName && newContact.photoFirstName.length > 0)
      ? newContact.photoFirstName.toUpperCase() : '-1';
    this.contactForm.company = (newContact.company && newContact.company.length > 0)
      ? newContact.company : '';
    this.contactForm.position = (newContact.position && newContact.position.length > 0)
      ? newContact.position : '';
    if (newContact.phones && newContact.phones.length > 0) {
      for (let item of newContact.phones) {
        let itemtemp = {
          id: item.id,
          data: PhoneNumber.fromString(item.num).getNumber(),
          num: item.num,
          type: item.numType,
          phoneAddress: item.phoneAddress,
          labelName: item.labelName
        }
        if (this.contactForm.phones) {
          this.contactForm.phones.push(itemtemp);
        } else {
          this.contactForm.phones = [itemtemp];
        }
      }
    }
    if (newContact.emails && newContact.emails.length > 0) {
      for (let item of newContact.emails) {
        let itemtemp = {
          id: item.id,
          data: item.address,
          type: item.emailType,
          labelName: item.labelName
        }
        if (this.contactForm.emails) {
          this.contactForm.emails.push(itemtemp);
        } else {
          this.contactForm.emails = [itemtemp];
        }
      }
    }
    if (newContact.aims && newContact.aims.length > 0) {
      for (let item of newContact.aims) {
        let itemtemp = {
          id: item.aimId,
          data: item.aimName,
          type: item.aimType,
          labelName: item.labelName
        }
        if (this.contactForm.aims) {
          this.contactForm.aims.push(itemtemp);
        } else {
          this.contactForm.aims = [itemtemp];
        }
      }
    }
    if (newContact.nickname && newContact.nickname.length > 0) {
      let itemtemp = {
        id: 0,
        data: newContact.nickname,
        labelName: $r("app.string.nickname")
      }
      this.contactForm.nickname = [itemtemp];
    }
    if (newContact.websites && newContact.websites.length > 0) {
      let itemtemp = {
        id: 0,
        data: newContact.websites[0],
        labelName: $r("app.string.website")
      }
      this.contactForm.websites = [itemtemp];
    }
    if (newContact.houses && newContact.houses.length > 0) {
      for (let item of newContact.houses) {
        let itemtemp = {
          id: item.houseId,
          data: item.houseName,
          type: item.houseType,
          labelName: item.labelName
        }
        if (this.contactForm.houses) {
          this.contactForm.houses.push(itemtemp);
        } else {
          this.contactForm.houses = [itemtemp];
        }
      }
    }
    if (newContact.events && newContact.events.length > 0) {
      for (let item of newContact.events) {
        let itemtemp = {
          id: item.id,
          data: item.data,
          type: item.eventType,
          labelName: item.labelName
        }
        if (this.contactForm.events) {
          this.contactForm.events.push(itemtemp);
        } else {
          this.contactForm.events = [itemtemp];
        }
      }
    }
    if (newContact.remarks && newContact.remarks.length > 0) {
      let itemtemp = {
        id: 0,
        data: newContact.remarks,
        labelName: $r("app.string.remarks")
      }
      this.contactForm.remarks = [itemtemp];
    }
    if (newContact.relationships && newContact.relationships.length > 0) {
      for (let item of this.contacts.relationships) {
        let itemtemp = {
          id: item.id,
          data: item.name,
          type: item.associatedType,
          labelName: item.labelName
        }
        if (this.contactForm.relationships) {
          this.contactForm.relationships.push(itemtemp);
        } else {
          this.contactForm.relationships = [itemtemp];
        }
      }
    }
  }

  async getContactCallLog() {
    HiLog.i(TAG, "get Contact CallLog");
    if (!ArrayUtil.isEmpty(this.contactForm.phones)) {
      let numbers: Set<string> = new Set();
      this.contactForm.phones.forEach(element => {
        numbers.add(`${element.data}`.replace(/\s+/g, ''));
      });
      /* All call records of all phone numbers of the contact are obtained. */
      globalThis.DataWorker.sendRequest("findByNumberIn", {
        context: globalThis.context,
        numbers: Array.from(numbers)
      }, (resultList) => {
        /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
        if (!ArrayUtil.isEmpty(resultList)) {
          this.lastUsedSlotId = resultList[0].simId;
        } else {
          this.lastUsedSlotId = -1;
        }
        this.detailCallLogDataSource.refresh(this.getDetailMessage(resultList));
      });
      /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
    }
    // Processing Initialization Data
    this.showNameLastMenu = (this.contactForm.display_name && this.contactForm.display_name.length > 6)
      ? this.subStringWithEllipsis(this.contactForm.display_name, 7) : this.contactForm.display_name;
  }

  // Obtains call records and assembles parameters when the call is not a contact.
  async getNewNumCallLog() {
    this.isNewDetail = true;
    HiLog.i(TAG, "get new number call log");
    let numbers: any = [this.phoneNumberShow.replace(/\s+/g, '')];
    let formatNum = PhoneNumber.fromString(this.phoneNumberShow).getNumber();
    this.contactForm.display_name = formatNum;
    /* Creating a Contact Phone List Object */
    let itemtemp = {
      id: 0,
      data: formatNum,
      num: this.phoneNumberShow,
      type: 1,
      labelName: $r("app.string.phone_type_mobile"),
      phoneAddress: $r("app.string.unknown")
    }
    this.contactForm.phones = [itemtemp];
    this.contactForm.portraitColor = MorandiColor.Color[0];
    this.contactForm.detailsBgColor = MorandiColor.detailColor[0];
    this.newNumberBgColor = MorandiColor.detailColor[0];
    globalThis.DataWorker.sendRequest("findByNumberIn", {
      context: globalThis.context,
      numbers: numbers
    }, (resultList) => {
      /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
      if (!ArrayUtil.isEmpty(resultList)) {
        this.lastUsedSlotId = resultList[0].simId;
      } else {
        this.lastUsedSlotId = -1;
      }
      this.detailCallLogDataSource.refresh(this.getDetailMessage(resultList));
    });
    if (this.detailCallLogDataSource.totalCount() > 0) {
      let bgColorId = Math.abs(parseInt(this.detailCallLogDataSource.getData(0).callLog.id, 10));
      this.contactForm.portraitColor = MorandiColor.Color[bgColorId % 6];
      this.contactForm.detailsBgColor = MorandiColor.detailColor[bgColorId % 6];
      this.newNumberBgColor = MorandiColor.detailColor[bgColorId % 6];
    }
  }

  /**
   * Data required for converting the original
   * callLogList content into call record details
   *
   * @param {Array} originList Original Call List
   * @return {Array} resultList
   */
  getDetailMessage(originList: CallLog[]) {
    let resultList = [];
    if (ArrayUtil.isEmpty(originList)) {
      return resultList;
    }
    originList.forEach(element => {
      let callTimeDetail = this.getTimeDetailByCallTime(element);
      let contactDetailCallsItem = {
        id: element.id.toString(),
        phone: element.phoneNumber,
        name: element.displayName,
        callTime: element.createTime.toString(),
        callType: element.callType,
        callTag: element.numberLocation,
        simType: element.simType.toString(),
        simId: element.simId,
        isHd: element.isHD,
        ringTime: element.ringDuration,
        formatNumber: element.formattedNumber,
        talkTime: this.getTalkTimeMessage(element),
        dateDetail: callTimeDetail.date,
        timeDetail: callTimeDetail.time
      };
      resultList.push(contactDetailCallsItem)
    });
    return resultList;
  }

  /**
   * Obtain the call details of the call record according to the call record.
   *
   * @param {Object} callLogElement Call log
   * @return {string} resultMessage Status information
   */
  getTalkTimeMessage(callLogElement: CallLog) {
    let resultMessage: Resource | string = null;
    switch (callLogElement.callType) {
      case CallType.IN:
        resultMessage = this.getDescriptionByDuration(callLogElement.talkDuration);
        break;
      case CallType.OUT:
        resultMessage = callLogElement.talkDuration == 0
          ? $r('app.string.blockCall') : this.getDescriptionByDuration(callLogElement.talkDuration);
        break;
      case CallType.MISSED:
        resultMessage = this.getDescriptionByDuration(callLogElement.ringDuration);
        break;
      case CallType.REJECTED:
        resultMessage = $r('app.string.reject');
        break;
      default:
        resultMessage = "";
        break;
    }
    return resultMessage;
  }

  /**
   * Obtains the call duration based on the specified timestamp. The unit is s.
   *
   * @param {number} timeDuration
   * @return {Object} Return time unit
   */
  getDescriptionByDuration(timeDuration) {
    let seconds = parseInt(timeDuration);
    if (seconds < 60) {
      // Less than one minute
      return $r('app.string.secondsFormat', seconds);
    } else {
      let minutes = Math.floor(seconds / 60);
      if (minutes < 60) {
        // Within an hour
        return $r('app.string.minutesSecondsFormat', minutes, seconds % 60);
      } else {
        let hours = Math.floor(minutes / 60);
        return $r('app.string.hourMinutesSecondsFormat', hours, minutes % 60, seconds % 3600 % 60);
      }
    }
  }

  /**
   * Obtain the time details based on the call record generation time.
   *
   * @param {number} callTime Initial Talk Time
   * @return {string} timeDetail Talk time after processing
   */
  getTimeDetailByCallTime(element: CallLog) {
    let callTime = element.createTime.toString();
    let callLogTime = new Date(parseInt(callTime, 10) * 1000);
    // time detail
    let year = callLogTime.getFullYear();
    let mounth = callLogTime.getMonth() + 1;
    let day = callLogTime.getDate();
    let hour = callLogTime.getHours().toString();
    let minutes = callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes().toString();
    // description
    let now = new Date();
    let timeDetail: any = {};
    if (parseInt(StringFormatUtil.judgeSysTime()) == 12) {
      timeDetail.time = StringFormatUtil.getDayMessage(hour, minutes);
    } else {
      timeDetail.time = $r("app.string.time_normal", hour, minutes);
    }
    if (now.getFullYear() - callLogTime.getFullYear() == 0) {
      if (now.getMonth() - callLogTime.getMonth() == 0) {
        if (now.getDate() - callLogTime.getDate() == 0) {
          timeDetail.date = "";
          return timeDetail;
        }
      }
      timeDetail.date = $r("app.string.monthDay", mounth, day);
    } else {
      timeDetail.date = $r("app.string.yearMonthDay", year, mounth, day);
    }
    return timeDetail;
  }

  // Edit Contact
  updateContact() {
    let phoneNumbers = [{
                          'phoneNumber': '',
                          'phoneAddress': ''
                        }];
    if (this.isNewNumber) {
      phoneNumbers[0].phoneNumber = this.phoneNumberShow;
      phoneNumbers[0].phoneAddress = this.contactForm?.phones[0]?.phoneAddress;
    }
    let upDataShow = false;
    if (this.contactId != undefined) {
      upDataShow = true
    }
    router.replace({
      url: 'pages/contacts/accountants/Accountants',
      params: {
        updataShow: upDataShow,
        contactId: this.contacts.id,
        phoneNumbers: phoneNumbers
      },
    });
  }

  clearAllCallLog() {
    let id = '';
    let ids = [];
    for (let index = 0; index < this.detailCallLogDataSource.totalCount(); index++) {
      id = this.detailCallLogDataSource.getData(index).callLog.id;
      ids.push(id);
    }
    this.removeCallLog(ids);
  }

  // Delete call records based on the ID set.
  removeCallLog(ids) {
    HiLog.i(TAG, 'removeCallLog');
    globalThis.DataWorker.sendRequest("deleteCallLogsById", {
      context: globalThis.context,
      ids: ids
    }, (data) => {
      HiLog.i(TAG, 'removeCallLog Success');
      CallLogRepository.getInstance().notifyChange()
    });
  }

  // Deleting a contact
  deleteContact() {
    AlertDialog.show({
      message: $r('app.string.delete_contact_sure'),
      alignment: EnvironmentProp.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom,
      autoCancel: true,
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        fontColor: $r("sys.color.ohos_id_color_handup"),
        action: () => {
          HiLog.i(TAG, 'delete contact')
          this.doDeleteContact();
        }
      },
      cancel: () => {
        HiLog.i(TAG, 'Closed callbacks')
      },
      offset: {
        dx: 0, dy: -52
      },
      gridCount: 4
    })
  }

  // Delete a contact
  doDeleteContact() {
    globalThis.DataWorker.sendRequest("deleteContactById", {
      context: globalThis.context,
      contactId: this.contactId
    }, (result) => {
      if (result == 0 || result == undefined) {
        ContactRepository.getInstance().notifyChange()
      } else {
        HiLog.i(TAG, `doDeleteContact Failed ${JSON.stringify(result)}`);
        prompt.showToast({
          message: 'contactDetail Failed to delete data.'
        });
      }
    });
    router.back();
  }

  // Sending Messages
  sendMessage(phoneNumber, formatnum, name) {
    PhoneNumber.fromString(phoneNumber).sendMessage(formatnum, name);
  }

  changeTopBarBackgroundColor(isTopForItem) {
    if (isTopForItem) {
      this.topbarBackgroundColor = Color.White;
    } else {
      this.topbarBackgroundColor = Color.Transparent;
    }
  }

  getTopBarBackgroundColor() {
    return this.topbarBackgroundColor;
  }

  // Truncates the first five characters of the string plus..
  subStringWithEllipsis(str, len) {
    let newLength = 0;
    let newStr = '';
    let chineseRegex = /[^\x00-\xff]/g;
    let singleChar = '';
    let strLength = str.replace(chineseRegex, '**').length;
    for (let i = 0; i < strLength; i++) {
      singleChar = str.charAt(i).toString();
      if (singleChar.match(chineseRegex) != null) {
        newLength += 2;
      } else {
        newLength++;
      }
      if (newLength > len) {
        break;
      }
      newStr += singleChar;
    }
    newStr += '..'
    return newStr;
  }

  getSettingsMenus() {
    let tmpMoreMenu = [];
    this.moreMenuOptions.forEach(element => {
      tmpMoreMenu.push({});
    });
    let mMoreMenu: Array<{
      value: string,
      action: () => void
    }> = [{
            value: "",
            action: () => {
            }
          }];
    mMoreMenu = tmpMoreMenu;
    this.moreMenuOptions.forEach((element, i) => {
      globalThis.context.resourceManager.getString(element.id, (err, typeName) => {
        mMoreMenu[i] = {
          value: typeName,
          action: () => {
            switch (i) {
              case 0:
                this.deleteContact();
                break;
            }
          }
        };
      });
    });
    return mMoreMenu;
  }
}