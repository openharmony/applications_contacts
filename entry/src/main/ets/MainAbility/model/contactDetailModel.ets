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

import Constants from './common/Constants';
import StringUtil from '../util/StringUtil';
import ArrayUtil from '../util/ArrayUtil';
import HiLog from '../util/HiLog';
import router from '@system.router';
import ContactAbilityModel from './ContactAbilityModel';
import featureAbility from '@ohos.ability.featureAbility';
import prompt from '@system.prompt';
import Birthday from '../contact/contract/Birthday';
import Relation from '../contact/contract/Relation';
import House from '../contact/contract/House';
import Aim from '../contact/contract/Aim';
import Email from '../contact/contract/Email';
import Phone from '../contact/contract/Phone';
import CallLogRepository from '../call/repo/CallLogRepository';
import ContactRepository from '../contact/repo/ContactRepository';
import CallLog from '../call/entity/CallLog';
import {CallType} from '../call/entity/CallLog';

const TAG = 'ContactDetailModel';

/**
 * Contact Details Logic
 */
export default {
  // More options menu
  moreMenuOptions: [$r("app.string.delete_contact")],
  /** Favorite Tag */
  isFavorite: false,
  /** Used to display the collapsed showNameLast button. */
  showNameLastMenu: '',
  /** Check whether the call record data is cleared.*/
  isCallLogClean: false,

  /** Indicates whether the new optimized request interface is used.
   * This field is added to the favorites page for invoking the new interface. */
  sourceHasId: false,
  /** Check whether the contact details are obtained. */
  containContacts: false,
  /** Jump from call log */
  sourceHasPhone: false,
  /** Indicates the incoming phone number of the new number. */
  phoneNumberShow: '',
  /** Contact ID */
  contactId: '',
  isNewNumber: true,
  /** Display parameters assembled based on contact details. */
  contactForm: {
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
  },
  /** Contact Temporary */
  contacts: {
    starred: 0,
    contactId: 0,
    organization: '',
    id: '',
    phones: [],
    emails: [],
    aims: [],
    nickname: '',
    websites: [],
    houses: [],
    events: [],
    remarks: '',
    relationships: [],
    pinYinName: '',
    alphaName: '',
    showGroupsString: '',
    name: {
      fullName: '',
    },
    display_name: '',
    namePrefix: '',
    lastName: '',
    company: '',
    position: '',
    numRecords: [],
    groups: [],
    detailsBgColor: '',
    portraitColor: '',
  },
  phoneNumbers: [
    {
      'phoneNumber': '',
      'phoneAddress': ''
    }
  ],

  onShow(callback) {
    // Groups, favorites, contact lists,new contacts.
    if (this.sourceHasId) {
      HiLog.i(TAG, 'onShow:sourceHasId');
      let requestData = {
        contactId: this.contactId
      };
      this.isNewNumber = false;
      this.getContactDetail(requestData, () => {
        callback();
      });
    } else if (this.containContacts) {
      HiLog.i(TAG, 'onShow:add');
      // After a contact is added and edited, the details page is displayed.
      // The contacts have been transferred and only call records are loaded.
      this.isNewNumber = false;
      this.dealRecordDetailsData();
    } else if (this.sourceHasPhone) {
      // call log, mms.
      HiLog.i(TAG, 'onShow:sourceHasPhone');
      /** Query the contact ID based on the phone number.
      If a contact exists,the contact details are displayed based on the first contact ID.*/
      ContactAbilityModel.getIdByTelephone(this.phoneNumberShow, (contactId) => {
        if (!StringUtil.isEmpty(contactId)) {
          // If a contact exists, set isNewNumber to false.
          this.isNewNumber = false;
          let requestData = {
            contactId: contactId[0]
          };
          this.getContactDetail(requestData);
        } else {
          // If the contact ID does not exist, the new number is used.
          this.getDetailAsNewNumber();
        }
      });
    }
  },

  getContactDetail(data, callback) {
    HiLog.i(TAG, 'get ContactDetail by id');
    ContactAbilityModel.getContactById(data.contactId, result => {
      if (StringUtil.isEmpty(result)) {
        // If the contact cannot be obtained based on the specified ID, the new number is used.
        this.getDetailAsNewNumber();
        return;
      }
      this.contactId = result.data.id;
      this.contacts = result.data;
      this.contacts.portraitColor = Constants.background.Color[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.contacts.detailsBgColor = Constants.background.detailColor[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.dealRecordDetailsData();
      callback();
    });
  },

  dealRecordDetailsData() {
    // get labelName
    HiLog.i(TAG, 'deal detail data');
    this.phoneNumberType();
    this.emailType();
    this.instantMessageType();
    this.residentialType();
    this.eventsType();
    this.relationshipsType();

    let newContacts = this.dealContactsToForm();
    this.contactForm.showMoreButton = false;
    this.setContactForm(newContacts);
    this.processingInitializationData();
  },

  dealContactsToForm() {
    let newContact: any = {};
    newContact.display_name = (this.contacts.display_name && this.contacts.display_name.length > 0)
      ? this.contacts.display_name : '';
    newContact.photoFirstName = (this.contacts.photoFirstName && this.contacts.photoFirstName.length > 0)
      ? this.contacts.photoFirstName : '-1';
    newContact.company = (this.contacts.company && this.contacts.company.length > 0)
      ? this.contacts.company : '';
    newContact.position = (this.contacts.position && this.contacts.position.length > 0)
      ? this.contacts.position : '';

    if (this.contacts.phones && this.contacts.phones.length > 0) {
      for (let item of this.contacts.phones) {
        let itemtemp = {
          id: item.id,
          data: item.num,
          type: item.numType,
          phoneAddress: item.phoneAddress,
          labelName: item.labelName
        }
        if (newContact.phones) {
          newContact.phones.push(itemtemp);
        } else {
          newContact.phones = [itemtemp];
        }
      }
    }
    if (this.contacts.emails && this.contacts.emails.length > 0) {
      for (let item of this.contacts.emails) {
        let itemtemp = {
          id: item.id,
          data: item.address,
          type: item.emailType,
          labelName: item.labelName
        }
        if (newContact.emails) {
          newContact.emails.push(itemtemp);
        } else {
          newContact.emails = [itemtemp];
        }
      }
    }
    if (this.contacts.aims && this.contacts.aims.length > 0) {
      for (let item of this.contacts.aims) {
        let itemtemp = {
          id: item.aimId,
          data: item.aimName,
          type: item.aimType,
          labelName: item.labelName
        }
        if (newContact.aims) {
          newContact.aims.push(itemtemp);
        } else {
          newContact.aims = [itemtemp];
        }
      }
    }
    if (this.contacts.nickname && this.contacts.nickname.length > 0) {
      let itemtemp = {
        id: 0,
        data: this.contacts.nickname,
        labelName: $r("app.string.nickname")
      }
      newContact.nickname = [itemtemp];
    }
    if (this.contacts.websites && this.contacts.websites.length > 0) {
      let itemtemp = {
        id: 0,
        data: this.contacts.websites[0],
        labelName: $r("app.string.website")
      }
      newContact.websites = [itemtemp];
    }
    if (this.contacts.houses && this.contacts.houses.length > 0) {
      for (let item of this.contacts.houses) {
        let itemtemp = {
          id: item.houseId,
          data: item.houseName,
          type: item.houseType,
          labelName: item.labelName
        }
        if (newContact.houses) {
          newContact.houses.push(itemtemp);
        } else {
          newContact.houses = [itemtemp];
        }
      }
    }
    if (this.contacts.events && this.contacts.events.length > 0) {
      for (let item of this.contacts.events) {
        let itemtemp = {
          id: item.id,
          data: item.data,
          type: item.eventType,
          labelName: item.labelName
        }
        if (newContact.events) {
          newContact.events.push(itemtemp);
        } else {
          newContact.events = [itemtemp];
        }
      }
    }
    if (this.contacts.remarks && this.contacts.remarks.length > 0) {
      let itemtemp = {
        id: 0,
        data: this.contacts.remarks,
        labelName: $r("app.string.remarks")
      }
      newContact.remarks = [itemtemp];
    }
    if (this.contacts.relationships && this.contacts.relationships.length > 0) {
      for (let item of this.contacts.relationships) {
        let itemtemp = {
          id: item.id,
          data: item.name,
          type: item.associatedType,
          labelName: item.labelName
        }
        if (newContact.relationships) {
          newContact.relationships.push(itemtemp);
        } else {
          newContact.relationships = [itemtemp];
        }
      }
    }
    return newContact;
  },

  setContactForm(newContacts) {
    HiLog.i(TAG, 'setContactForm');
    this.contactForm.display_name = (newContacts.display_name && newContacts.display_name.length > 0)
      ? newContacts.display_name : $r('app.string.noName');
    this.contactForm.photoFirstName = (newContacts.photoFirstName && newContacts.photoFirstName.length > 0)
      ? newContacts.photoFirstName.toUpperCase() : '';
    this.contactForm.company = (newContacts.company && newContacts.company.length > 0)
      ? newContacts.company : '';

    this.contactForm.position = (newContacts.position && newContacts.position.length > 0)
      ? newContacts.position : '';

    this.contactForm.phones = (newContacts.phones && newContacts.phones.length > 0)
      ? newContacts.phones : [];

    this.contactForm.emails = (newContacts.emails && newContacts.emails.length > 0)
      ? newContacts.emails : [];

    this.contactForm.aims = (newContacts.aims && newContacts.aims.length > 0)
      ? newContacts.aims : [];

    this.contactForm.nickname = (newContacts.nickname && newContacts.nickname.length > 0)
      ? newContacts.nickname : [];

    this.contactForm.websites = (newContacts.websites && newContacts.websites.length > 0)
      ? newContacts.websites : [];

    this.contactForm.houses = (newContacts.houses && newContacts.houses.length > 0)
      ? newContacts.houses : [];

    this.contactForm.events = (newContacts.events && newContacts.events.length > 0)
      ? newContacts.events : [];

    this.contactForm.remarks = (newContacts.remarks && newContacts.remarks.length > 0)
      ? newContacts.remarks : [];

    this.contactForm.relationships = (newContacts.relationships && newContacts.relationships.length > 0)
      ? newContacts.relationships : [];
  },

  processingInitializationData : async function() {
    HiLog.i(TAG, 'processingInitializationData');
    if (!ArrayUtil.isEmpty(this.contactForm.phones)) {
      let numbers = [];
      this.contactForm.phones.forEach(element => {
        numbers.push(element.data);
      });
      /* All call records of all phone numbers of the contact are obtained. */
      await CallLogRepository.getInstance().findByNumberIn(numbers).then((resultList) => {
        /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
        this.contactForm.numRecords = this.getDetailMessage(resultList);
      });
      /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
    }
    // Processing Initialization Data
    this.showNameLastMenu = (this.contactForm.display_name && this.contactForm.display_name.length > 6)
      ? this.subStringWithEllipsis(this.contactForm.display_name, 7) : this.contactForm.display_name;
  },

  // Type of obtaining details
  phoneNumberType() {
    if (this.contacts.hasOwnProperty('phones') && this.contacts.phones.length > 0) {
      this.contacts.phones.forEach((element) => {
        element.labelName = Phone.getTypeLabelResource(parseInt(element.numType, 10));
        // 归属地
        element.phoneAddress = (element.phoneAddress == 'N' || StringUtil.isEmpty(element.phoneAddress)) ?
        $r("app.string.unknown") : element.phoneAddress;
      });
    }
  },
  emailType() {
    if (this.contacts.hasOwnProperty('emails') && this.contacts.emails.length > 0) {
      this.contacts.emails.forEach((element) => {
        element.labelName = Email.getTypeLabelResource(parseInt(element.emailType, 10));
      });
    }
  },
  instantMessageType() {
    if (this.contacts.hasOwnProperty('aims') && this.contacts.aims.length > 0) {
      this.contacts.aims.forEach((element) => {
        element.labelName = Aim.getTypeLabelResource(parseInt(element.aimType, 10));
      });
    }
  },
  residentialType() {
    if (this.contacts.hasOwnProperty('houses') && this.contacts.houses.length > 0) {
      this.contacts.houses.forEach((element) => {
        element.labelName = House.getTypeLabelResource(parseInt(element.houseType, 10));
      });
    }
  },
  eventsType() {
    if (this.contacts.hasOwnProperty('events') && this.contacts.events.length > 0) {
      this.contacts.events.forEach((element) => {
        element.labelName = Birthday.getTypeLabelResource(parseInt(element.eventType, 10));
      });
    }
  },
  relationshipsType() {
    if (this.contacts.hasOwnProperty('relationships') && this.contacts.relationships.length > 0) {
      this.contacts.relationships.forEach((element) => {
        element.labelName = Relation.getTypeLabelResource(parseInt(element.associatedType, 10));
      });
    }
  },

  /* Display phone number details when no contact data is available.*/
  getDetailAsNewNumber() {
    let numbers = [this.phoneNumberShow.replace(/\s+/g, '')];
    this.getNewNumRecords(numbers);
  },

  // Obtains call records and assembles parameters when the call is not a contact.
  getNewNumRecords : async function(numbers) {
    let newContacts: any = {};
    this.contactForm.showMoreButton = false;
    await CallLogRepository.getInstance().findByNumberIn(numbers).then((resultList) => {
      /* Encapsulate the attributes required on the detail
       page based on the obtained raw call record data. */
      this.contactForm.numRecords = this.getDetailMessage(resultList);
      /* Creating a Contact Phone List Object */
      let phoneNumbersTemp = {
        id: 0,
        data: "",
        type: 1,
        phoneAddress: ""
      };
      if (this.contactForm.numRecords.length > 0) {
        phoneNumbersTemp.phoneAddress = this.contactForm.numRecords[0].callTag;
      }
      phoneNumbersTemp.data = this.phoneNumberShow;
      let phoneNumbersTempList = [phoneNumbersTemp];
      this.contactForm.phones = phoneNumbersTempList;
      newContacts.phones = phoneNumbersTempList;
      // Assemble contacts: originalContacts
      newContacts.showMoreButton = this.contactForm.showMoreButton;
      newContacts.numRecords = this.contactForm.numRecords;
      /* On the page for redirecting to a new number,
      use the ID of the first call record to obtain
      the value from the background color of the avatar.*/
      newContacts.portraitColor = Constants.background.Color[Math.abs(parseInt(this.contactForm.numRecords[0].id, 10)) % 6];
      newContacts.detailsBgColor = Constants.background.detailColor[Math.abs(parseInt(this.contactForm.numRecords[0].id, 10)) % 6];
      this.contacts = newContacts;
      this.contactForm.display_name = (this.contactForm.phones && this.contactForm.phones[0])
        ? this.contactForm.phones[0].data : '';
    });
  },

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
  },

  /**
     * Obtain the call details of the call record according to the call record.
     *
     * @param {Object} callLogElement Call log
     * @return {string} resultMessage Status information
     */
  getTalkTimeMessage(callLogElement: CallLog) {
    HiLog.i(TAG, 'getTalkTimeMessage callLogElement');
    let resultMessage: Resource = null;
    if (callLogElement.callType == CallType.IN) {
      // Incoming call: The call duration is displayed directly.
      resultMessage = this.getDescriptionByDuration(callLogElement.talkDuration);
    } else if (callLogElement.callType == CallType.OUT) {
      // Outgoing call: If the call duration is 0,
      // the call is not connected. Otherwise, the call duration is displayed.
      resultMessage = callLogElement.talkDuration == 0 ? $r('app.string.blockCall')
                                                       : this.getDescriptionByDuration(callLogElement.talkDuration);
    } else if (callLogElement.callType == CallType.MISSED) {
      // Missed: Indicates the ringing duration of the missed caller ID.
      resultMessage = this.getDescriptionByDuration(callLogElement.ringDuration);
    } else if (callLogElement.callType == CallType.REJECTED) {
      // Reject
      resultMessage = $r('app.string.reject');
    }
    return resultMessage;
  },

  /**
     * Obtains the call duration based on the specified timestamp. The unit is s.
     *
     * @param {number} timeDuration
     * @return {Object} Return time unit
     */
  getDescriptionByDuration(timeDuration) {
    HiLog.i(TAG, 'getDescriptionByDuration timeDuration');
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
  },

  /**
     * Obtain the time details based on the call record generation time.
     *
     * @param {number} callTime Initial Talk Time
     * @return {string} timeDetail Talk time after processing
     */
  getTimeDetailByCallTime(element: CallLog) {
    let callTime = element.createTime.toString();
    HiLog.i(TAG, 'getTimeDetailByCallTime callTime');
    let callLogTime = new Date(parseInt(callTime, 10) * 1000);
    let now = new Date();
    // time detail
    let year = callLogTime.getFullYear();
    let mounth = callLogTime.getMonth() + 1;
    let day = callLogTime.getDate();
    let hour = callLogTime.getHours().toString();
    let minutes = callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes().toString();
    // description
    let timeDetail:any = {};
    if (now.getFullYear() - callLogTime.getFullYear() == 0) {
      if (now.getMonth() - callLogTime.getMonth() == 0) {
        if (now.getDate() - callLogTime.getDate() == 0) {
          timeDetail.date = "";
          timeDetail.time = this.getDayMessage(hour,minutes);
          return timeDetail;
        }
      }
      timeDetail.date = $r("app.string.monthDay", mounth, day);
      timeDetail.time = this.getDayMessage(hour,minutes);
    } else {
      timeDetail.date = $r("app.string.yearMonthDay", year, mounth, day);
      timeDetail.time = this.getDayMessage(hour,minutes);
    }
    return timeDetail;
  },

  /**
     * Obtain the description of the time within a day based on the hour.
     *
     * @param {number} hour
     * @return {string} Time node
     */
  getDayMessage(hour,minutes) {
    HiLog.i(TAG, ' getDayMessage');
    if (hour >= 0 && hour < 5) {
      return $r("app.string.time_early_morning", hour, minutes);
    }
    if (hour >= 5 && hour < 11) {
      return $r("app.string.time_morning", hour, minutes);
    }
    if (hour >= 11 && hour < 13) {
      return $r("app.string.time_noon", hour, minutes);
    }
    if (hour >= 13 && hour < 17) {
      return $r("app.string.time_afternoon", hour, minutes);
    }
    if (hour >= 17 && hour < 19) {
      return $r("app.string.time_nightfall", hour, minutes);
    }
    if (hour >= 19 && hour < 22) {
      return $r("app.string.time_night", hour, minutes);
    }
    if (hour >= 22 && hour < 24) {
      return $r("app.string.time_middle_night", hour, minutes);
    }
  },

  // Edit Contact
  updateContact() {
    // Transfer the new number and home area data.
    if (this.isNewNumber) {
      this.phoneNumbers[0].phoneNumber = this.phoneNumberShow;
      this.phoneNumbers[0].phoneAddress = this.contacts.phones[0].phoneAddress;
    }
    let upDataShow = false;
    if (!StringUtil.isEmpty(this.contactId)) {
      upDataShow = true
    }
    router.replace({
      uri: 'pages/contacts/accountants/Accountants',
      params: {
        updataShow: upDataShow,
        contactForm: this.contacts,
        phoneNumbers: this.phoneNumbers
      },
    });
  },

  // Clear Call Record dialog box
  clearPhoneRecords() {
    HiLog.i(TAG, ' clearPhoneRecords');
    AlertDialog.show(
      {
        message: $r('app.string.clear_calllog_sure'),
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.dialog_delete'),
          fontColor: $r("sys.color.ohos_id_color_handup"),
          action: () => {
            this.clearRecordsMore();
          }
        },
        cancel: () => {
          HiLog.i(TAG, 'Closed callbacks')
        },
        offset: {
          dx: 0, dy: -15
        },
      }
    )
  },

  // Deleting Call Records
  clearRecordsMore() {
    let id = '';
    let ids = [];
    for (let index = 0; index < this.contactForm.numRecords.length; index++) {
      id = this.contactForm.numRecords[index].id;
      ids.push(id);
    }
    this.removeCallLog(ids);
    this.contactForm.numRecords = [];
    this.contactForm.showMoreButton = false;
  },

  // Delete call records based on the ID set.
  removeCallLog(ids) {
    HiLog.i(TAG, 'removeCallLog');
    CallLogRepository.getInstance().deleteByIdIn(ids).then(data => {
      HiLog.i(TAG, 'removeCallLog Success');
      this.contactForm.numRecords = null;
      this.isCallLogClean = true;
      CallLogRepository.getInstance().notifyChange();
    })
  },

  // Deleting a contact
  deleteContact() {
    AlertDialog.show(
      {
        message: $r('app.string.delete_contact_sure'),
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.dialog_delete'),
          fontColor: $r("sys.color.ohos_id_color_handup"),
          action: () => {
            HiLog.i(TAG, 'Callback when the second button is clicked')
            this.doDeleteContact();
          }
        },
        cancel: () => {
          HiLog.i(TAG, 'Closed callbacks')
        },
        offset: {
          dx: 0, dy: -15
        },
      }
    )
  },

  // Delete a contact
  doDeleteContact() {
    ContactRepository.getInstance().deleteById(this.contactId).then((result) => {
      if (result == 0) {
        ContactRepository.getInstance().notifyChange();
        CallLogRepository.getInstance().notifyChange();
        router.back();
      } else {
        prompt.showToast({
          message: 'contactDetail Failed to delete data.'
        });
      }
    });
  },

  // Sending Messages
  sendMessage(phoneNumber, name) {
    HiLog.i(TAG, 'sendMessage success');
    let params = [];
    params.push({
      contactsName: name,
      telephone: phoneNumber,
      telephoneFormat: phoneNumber
    });
    this.jumpToMms(params);
  },

  // Switching to the SMS app
  jumpToMms(params) {
    let actionData: any = {};
    actionData.contactObjects = JSON.stringify(params);
    actionData.pageFlag = 'conversation';
    let str = {
      'want': {
        'bundleName': Constants.string.MMS_BUNDLE_NAME,
        'abilityName': Constants.string.MMS_ABILITY_NAME,
        'parameters': actionData,
        'entities': [
          Constants.string.MMS_ENTITIES,
        ]
      },
    };
    featureAbility.startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToMms');
    }).catch((error) => {
      HiLog.e(TAG, 'jumpToMms,failed: %s', JSON.stringify(error.message));
    })
  },

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
  },

  // Implement deep copy of obj objects.
  copy(obj) {
    return JSON.parse(JSON.stringify(obj));
  },

  // Show Hide More Options
  getMore() {
    if (Boolean(this.contactForm.showMoreButton) == true) {
      this.contactForm.showMoreButton = false;
    }
    this.dealRecordDetailsData();
  }
};
