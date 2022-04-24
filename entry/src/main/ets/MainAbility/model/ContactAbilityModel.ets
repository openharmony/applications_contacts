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
import featureAbility from '@ohos.ability.featureAbility'
import dataAbility  from '@ohos.data.dataAbility';
import {ContactVo} from '../model/bean/ContactVo';
import {ContactInfo} from "../model/bean/ContactInfo";
import DataItem from '../contact/entity/DataItem';
import {DataItemType} from '../contact/contract/DataType';
import Data from '../contact/contract/Data';
import HiLog from '../util/Hilog';
import StringUtil from '../util/StringUtil';
import ArrayUtil from '../util/ArrayUtil';
import ContactRepository from '../contact/repo/ContactRepository';
import CallLogRepository from '../call/repo/CallLogRepository';
import PreferencesUtil from './../util/PreferencesUtil'
import RawContacts from '../contact/contract/RawContacts';

const TAG = "ContactAbility: ";

export default {
  /**
     * Add Contact
     *
     * @param {string} DAHelper Database path
     * @param {Object} addParams Contact Information
     * @param {Object} callBack
    */
  addContact: function (addParams: ContactInfo, DAHelper?, callBack?) {
    if (addParams == undefined || addParams == null) {
      HiLog.e(TAG, "The addParams of parameter is NULL");
      return "";
    }
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    let insertValues = {
      'display_name': this.getDisplayName(addParams),
    };
    DAHelper.insert(
      Constants.uri.ROW_CONTACTS_URI,
      insertValues
    ).then(data => {
      HiLog.i(TAG, 'Data inserted successfully');
      addParams.id = data.toString();
      this.dealParam(DAHelper, addParams, false);
      if (callBack != undefined) {
        HiLog.d(TAG, 'Start the callback function.');
        if (!PreferencesUtil.isUsed()) {
          PreferencesUtil.setIsUsed(true);
        }
        callBack(addParams.id);
      }
    }).catch(error => {
      HiLog.e(TAG, 'logMessage insert error: %s', JSON.stringify(error.message));
    });
  },

  /**
     * Read the name, which needs to be optimized.
     * Edit Contact
     *
     * @param {Object} addParams Contact Information
     * @return {string} Contact Name
   */
  getDisplayName: function (addParams: ContactInfo): String{
    let displayName = '';
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
    } else if (addParams.nickname != undefined && addParams.nickname.length > 0) {
      displayName = addParams.nickname;
    } else if (addParams.hasOwnProperty('company') && addParams.company.length > 0) {
      displayName = addParams.company;
    } else if (addParams.hasOwnProperty('position') && addParams.position.length > 0) {
      displayName = addParams.position;
    } else if (addParams.hasOwnProperty('phones') && addParams.phones.length > 0) {
      for (let element of addParams.phones) {
        if (StringUtil.isEmpty(element.num)) {
          continue;
        }
        displayName = element.num;
        break;
      }
    } else {
      displayName = '';
    }
    return displayName;
  },

  /**
     * Convert the data to the database.
     *
     * @param {string} DAHelper Database path
     * @param {Object} addParams Contact Information
     * @param {boolean} isCard Indicates whether the information is a business card.
    */
  dealParam: function (DAHelper, addParams: ContactInfo, isCard) {
    let result = addParams.id;
    let uri = isCard ? Constants.uri.PROFILE_CONTACT_DATA_URI : Constants.uri.CONTACT_DATA_URI;

    this.dataContact(addParams, DAHelper, result, uri);
    this.organizationContact(addParams, DAHelper, result, uri);
    this.noteContact(addParams, DAHelper, result, uri);
    this.phoneContact(addParams, DAHelper, result, uri);
    this.emailContact(addParams, DAHelper, result, uri);
    this.postalContact(addParams, DAHelper, result, uri);
    this.eventContact(addParams, DAHelper, result, uri);
    this.imContact(addParams, DAHelper, result, uri);
    this.groupsContact(addParams, DAHelper, result, uri);
    this.websiteContact(addParams, DAHelper, result, uri);
    this.nickContact(addParams, DAHelper, result, uri);
    this.relationsContact(addParams, DAHelper, result, uri);
    ContactRepository.getInstance().notifyChange();
    CallLogRepository.getInstance().notifyChange();
  },

  /**
     * Save the contact name to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {string} result Contact ID
     * @param {string} uri Database address
     */
  dataContact: function (addParams, DAHelper, result, uri) {
    let displayName = '';
    let updateFlag = 0;
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
    } else {
      updateFlag = 1;
      displayName = this.getDisplayName(addParams);
    }

    if (displayName.length > 0) {
      let dataContact = {
        'raw_contact_id': result,
        'detail_info': displayName,
        'alpha_name': displayName,
        'phonetic_name': addParams.hasOwnProperty('phonetic_name') ? (addParams.phonetic_name) : "",
        'other_lan_last_name': addParams.hasOwnProperty('other_lan_last_name') ? (addParams.other_lan_last_name) : "",
        'other_lan_first_name': addParams.hasOwnProperty('other_lan_first_name') ? (addParams.other_lan_first_name) : "",
        'type_id': 6,
        'extend7': updateFlag
      };
      DAHelper.insert(
        uri,
        dataContact
      ).then(data => {
        HiLog.d(TAG, 'name-insert data success!');
      }).catch(err => {
        HiLog.e(TAG, 'name-Operation failed. Cause: %s', JSON.stringify(err.message));
      });
    }
  },

  /**
     * Save the contact nickname information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  nickContact: function (addParams, DAHelper, result, uri) {
    if (addParams.nickname != undefined && addParams.nickname.length > 0) {
      let nickContact = {
        'raw_contact_id': result,
        'detail_info': addParams.nickname,
        'type_id': 9,
      };
      DAHelper.insert(
        uri,
        nickContact
      ).catch(error => {
        HiLog.e(TAG, 'nickContact:insert contact error');
      });
    }
  },
  /**
     * Save the position information of the contact company to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {string} result Contact ID
     * @param {string} uri Database address
     */
  organizationContact: function (addParams, DAHelper, result, uri) {
    let company = '';
    let position = '';
    if (addParams.company != undefined && addParams.company.length > 0) {
      company = addParams.company;
    }
    if (addParams.position != undefined && addParams.position.length > 0) {
      position = addParams.position;
    }
    if (addParams.company.length > 0 || addParams.position.length > 0) {
      let organizationContact = {
        'raw_contact_id': result,
        'detail_info': company,
        'position': position,
        'type_id': 4,
      };
      DAHelper.insert(
        uri,
        organizationContact
      ).then(data => {
        HiLog.d(TAG, 'organizationContact-insert data success!');
      }).catch(error => {
        HiLog.e(TAG, 'organizationContact-insert contact error: %s', JSON.stringify(error.message));
      });
    }
  },

  /**
     * Save the contact remarks to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  noteContact: function (addParams, DAHelper, result, uri) {
    if (addParams.remarks != undefined && addParams.remarks.length > 0) {
      let noteContact = {
        'raw_contact_id': result,
        'detail_info': addParams.remarks,
        'type_id': 10,
      };
      DAHelper.insert(
        uri,
        noteContact
      ).then(data => {
        HiLog.d(TAG, 'noteContact-logMessage insert data success!');
      }).catch(error => {
        HiLog.e(TAG, 'noteContact-insert contact error: %s', JSON.stringify(error.message));
      });
    }
  },

  /**
     * The contact mobile number information is saved to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  phoneContact: function (addParams, DAHelper, result, uri) {
    if (addParams.phones != undefined && addParams.phones.length > 0) {
      let index = 1;
      addParams.phones.forEach(element => {
        if (StringUtil.isEmpty(element.num)) {
          return;
        }
        let phoneContact = {
          'raw_contact_id': result,
          'detail_info': element.num,
          'extend7': (index++).toString(),
          'custom_data': element.numType,
          'type_id': 5,
        };
        DAHelper.insert(
          uri,
          phoneContact
        ).then(data => {
          HiLog.d(TAG, 'phoneContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'phoneContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * Save the contact email information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  emailContact: function (addParams, DAHelper, result, uri) {
    if (addParams.emails != undefined && addParams.emails.length > 0) {
      let index = 1;
      addParams.emails.forEach(element => {
        if (StringUtil.isEmpty(element.address)) {
          return;
        }
        let emailContact = {
          'raw_contact_id': result,
          'detail_info': element.address,
          'extend7': (index++).toString(),
          'custom_data': element.emailType,
          'type_id': 1,
        };
        DAHelper.insert(
          uri,
          emailContact
        ).then(data => {
          HiLog.d(TAG, 'emailContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'emailContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * The contact address information is saved to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  postalContact: function (addParams, DAHelper, result, uri) {
    if (addParams.houses != undefined && addParams.houses.length > 0) {
      let index = 1;
      addParams.houses.forEach(element => {
        if (StringUtil.isEmpty(element.houseName)) {
          return;
        }
        let postalContact = {
          'raw_contact_id': result,
          'detail_info': element.houseName,
          'extend7': (index++).toString(),
          'custom_data': element.houseType,
          'type_id': 7,
        };
        DAHelper.insert(
          uri,
          postalContact
        ).then(data => {
          HiLog.d(TAG, 'postalContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'postalContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },


  /**
     * Save the contact special date information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  eventContact: function (addParams, DAHelper, result, uri) {
    if (addParams.events != undefined && addParams.events.length > 0) {
      let index = 1;
      addParams.events.forEach(element => {
        if (StringUtil.isEmpty(element.data)) {
          return;
        }
        let eventContact = {
          'raw_contact_id': result,
          'detail_info': element.data,
          'extend7': (index++).toString(),
          'custom_data': element.eventType,
          'type_id': 11
        };
        DAHelper.insert(
          uri,
          eventContact
        ).then(data => {
          HiLog.d(TAG, 'eventContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'eventContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * Save the contact IMA information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  imContact: function (addParams, DAHelper, result, uri) {
    if (addParams.aims != undefined && addParams.aims.length > 0) {
      let index = 1;
      addParams.aims.forEach(element => {
        if (StringUtil.isEmpty(element.aimName)) {
          return;
        }
        let imContact = {
          'raw_contact_id': result,
          'detail_info': element.aimName,
          'extend7': (index++).toString(),
          'custom_data': element.aimType,
          'type_id': 2,
        };
        DAHelper.insert(
          uri,
          imContact
        ).then(data => {
          HiLog.d(TAG, 'imContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'imContact-insert contact error:%s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * Save the contact group information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  groupsContact: function (addParams, DAHelper, result, uri) {
    if (addParams.groups != undefined && addParams.groups.length > 0) {
      addParams.groups.forEach(element => {
        let groupsContact = {
          'raw_contact_id': result,
          'detail_info': element.groupName,
          'extend7': element.groupId + '',
          'custom_data': element.groupType,
          'type_id': 9,
        };
        DAHelper.insert(
          uri,
          groupsContact
        ).then(data => {
          HiLog.d(TAG, 'groupsContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'groupsContact-insert contact error:%s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * Save the contact website information to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  websiteContact: function (addParams, DAHelper, result, uri) {
    if (!ArrayUtil.isEmpty(addParams.websites)) {
      addParams.websites.forEach(element => {
        if (StringUtil.isEmpty(element))
        return;
        let websiteContact = {
          'raw_contact_id': result,
          'detail_info': element,
          'type_id': 12,
        };
        DAHelper.insert(
          uri,
          websiteContact
        ).then(data => {
          HiLog.d(TAG, 'websiteContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'websiteContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * The relation information of the contact is saved to the database.
     *
     * @param {Object} addParams Contact Information
     * @param {string} DAHelper Database path
     * @param {number} result Contact ID
     * @param {string} uri Database address
     */
  relationsContact: function (addParams, DAHelper, result, uri) {
    if (!ArrayUtil.isEmpty(addParams.relationships)) {
      let index = 1;
      addParams.relationships.forEach(element => {
        if (StringUtil.isEmpty(element.name)) {
          return;
        }
        let relationsContact = {
          'raw_contact_id': result,
          'detail_info': element.name,
          'extend7': (index++).toString(),
          'custom_data': element.associatedType,
          'type_id': 13,
        };
        DAHelper.insert(
          uri,
          relationsContact
        ).then(data => {
          HiLog.d(TAG, 'relationsContact-logMessage insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'relationsContact-insert contact error: %s', JSON.stringify(error.message));
        });
      });
    }
  },

  /**
     * Querying the Mobile Numbers of All Contacts
     *
     * @param {string} DAHelper
     * @param {Object} callBack
     */
  getAllContact: async function (callBack?) {
    let contactList = await ContactRepository.getInstance().findAll();

    if (ArrayUtil.isEmpty(contactList)) {
      HiLog.i(TAG, 'queryContacts-SelectcontactsModel queryContact resultSet is empty!');
      let emptyResult: ContactVo[] = [];
      callBack(emptyResult);
      return;
    }
    let resultList = [];
    for (let contactItem of contactList) {
      let jsonObj: ContactVo = new ContactVo("", "", "", "", "", "", true, "", "");
      jsonObj.contactId = contactItem.id.toString();
      jsonObj.emptyNameData = contactItem.displayName;
      jsonObj.namePrefix = contactItem.sortFirstLetter;
      jsonObj.nameSuffix = contactItem.photoFirstName;
      jsonObj.company = contactItem.company;
      jsonObj.position = contactItem.position;
      jsonObj.portraitColor = Constants.background.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
      jsonObj.show = false;
      jsonObj.setShowName();
      resultList.push(jsonObj);
    };
    callBack(resultList);
  },

  /**
     * 查询所有联系人手机号
     *
     * @param {string} DAHelper 数据库地址
     * @param {Object} callBack 回调
     */
  getAllContactWithPhoneNumbers: async function (callBack?) {
    let contactList = await ContactRepository.getInstance().findByPhoneIsNotNull();

    if (ArrayUtil.isEmpty(contactList)) {
      HiLog.i(TAG, 'getAllContactWithPhoneNumbers-SelectcontactsModel queryContact resultSet is empty!');
      let emptyResult: ContactVo[] = [];
      callBack(emptyResult);
      return;
    }
    let resultList = [];
    for (let contactItem of contactList) {
      let jsonObj: ContactVo = new ContactVo("", "", "", "", "", "", true, "", "");
      jsonObj.contactId = contactItem.id.toString();
      jsonObj.emptyNameData = contactItem.displayName;
      jsonObj.namePrefix = contactItem.sortFirstLetter;
      jsonObj.nameSuffix = contactItem.photoFirstName;
      jsonObj.company = contactItem.company;
      jsonObj.position = contactItem.position;
      jsonObj.portraitColor = Constants.background.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
      jsonObj.show = false;
      jsonObj.phoneNumbers = contactItem.phoneNumbers;
      jsonObj.setShowName();
      resultList.push(jsonObj);
    }
    ;
    callBack(resultList);
  },

  /**
     * Obtain contact details.
     *
     * @param {Object} contactId Contact data ID.
     * @param {Object} callback Contact details
    */
  getContactById: async function (contactId?, callback?) {
    let res = {
      'data': {}
    };
    let contact = await ContactRepository.getInstance().findById(contactId);
    if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
      callback(res);
      return;
    }
    let contactDetailInfo: any = {};
    for (let dataItem of contact.rowContacts[0].dataItems) {
      this.dealResult(dataItem, contactDetailInfo);
    }
    contactDetailInfo.id = contact.rowContacts[0].id;
    contactDetailInfo.photoFirstName = contact.rowContacts[0].values.get(RawContacts.PHOTO_FIRST_NAME);
    res.data = contactDetailInfo;
    callback(res);
  },

  /**
     * Process contact details
     *
     * @param {Object} resultSet
     * @param {Object} contactDetailInfo Contact details data
     * @param {Object} actionData Contact data
     */
  dealResult: function (dataItem: DataItem, contactDetailInfo) {
    switch (dataItem.getContentTypeId()) {
      case DataItemType.NAME:
        contactDetailInfo.display_name = dataItem.getData();
        contactDetailInfo.nameUpdate = dataItem.getLabelId();
        break;
      case DataItemType.PHONE:
        let phone_element = {
          'num': dataItem.getData(),
          'id': dataItem.getLabelId(),
          'numType': dataItem.getLabelName()
        };
        if (contactDetailInfo.phones) {
          contactDetailInfo.phones.push(phone_element);
        } else {
          contactDetailInfo.phones = [phone_element];
        }
        break;
      case DataItemType.EMAIL:
        let email_element = {
          'address': dataItem.getData(),
          'id': dataItem.getLabelId(),
          'emailType': dataItem.getLabelName()
        };
        if (contactDetailInfo.emails) {
          contactDetailInfo.emails.push(email_element);
        } else {
          contactDetailInfo.emails = [email_element];
        }
        break;
      case DataItemType.NOTE:
        contactDetailInfo.remarks = dataItem.getData();
        break;
      case DataItemType.ORGANIZATION:
        contactDetailInfo.position = dataItem.values.get(Data.POSITION);
        contactDetailInfo.company = dataItem.getData();
        break;
      case DataItemType.IM:
        let aim_element = {
          'aimName': dataItem.getData(),
          'aimId': dataItem.getLabelId(),
          'aimType': dataItem.getLabelName()
        };
        if (contactDetailInfo.aims) {
          contactDetailInfo.aims.push(aim_element);
        } else {
          contactDetailInfo.aims = [aim_element];
        }
        break;
      case DataItemType.STRUCTURED_POSTAL:
        let house_element = {
          'houseName': dataItem.getData(),
          'houseId': dataItem.getLabelId(),
          'houseType': dataItem.getLabelName()
        };
        if (contactDetailInfo.houses) {
          contactDetailInfo.houses.push(house_element);
        } else {
          contactDetailInfo.houses = [house_element];
        }
        break;
      case DataItemType.GROUP_MEMBERSHIP:
        contactDetailInfo.nickname = dataItem.getData();
        break;
      case DataItemType.EVENT:
        let event_element = {
          'id': dataItem.getLabelId(),
          'data': dataItem.getData(),
          'eventType': dataItem.getLabelName(),
          'eventName': ""
        };
        if (contactDetailInfo.events) {
          contactDetailInfo.events.push(event_element);
        } else {
          contactDetailInfo.events = [event_element];
        }
        break;
      case DataItemType.WEBSITE:
        let website_element = dataItem.getData();
        if (contactDetailInfo.websites) {
          contactDetailInfo.websites.push(website_element);
        } else {
          contactDetailInfo.websites = [website_element];
        }
        break;
      case DataItemType.RELATION:
        let relation_element = {
          'id': dataItem.getLabelId(),
          'associatedPersonId': '',
          'name': dataItem.getData(),
          'associatedType': dataItem.getLabelName(),
        };
        if (contactDetailInfo.relationships) {
          contactDetailInfo.relationships.push(relation_element);
        } else {
          contactDetailInfo.relationships = [relation_element];
        }
        break;
    }
  },

  /**
     * Obtains the contact ID of the number by phone number
     *
     * @param {string} DAHelper
     * @param {string} number Mobile number
     * @param {Object} callBack Contact ID
     */
  getContactIdByNumber: async function (DAHelper, number, callBack) {
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    if (StringUtil.isEmpty(number)) {
      return;
    }
    let resultColumns = [
      'raw_contact_id',
    ];
    let cleanNumber = StringUtil.removeSpace(number);
    let condition = new dataAbility.DataAbilityPredicates();
    condition.equalTo('detail_info', cleanNumber);
    condition.and();
    condition.equalTo('is_deleted', 0);
    condition.and();
    condition.equalTo('type_id', '5');
    let resultSet = await DAHelper.query(Constants.uri.CONTACT_DATA_URI, resultColumns, condition);
    if (StringUtil.isEmpty(resultSet) || resultSet.rowCount == 0) {
      HiLog.i(TAG, 'getContactIdByNumber-contactId resultSet is empty!');
      callBack();
      return;
    }
    resultSet.goToFirstRow();
    let contactId = resultSet.getString(0);
    resultSet.close();
    callBack(contactId);
  },

  /**
     * Edit Contact Information
     *
     * @param {string} DAHelper
     * @param {Object} addParams  Contact Information
     * @param {Object} callBack Contact ID
     */
  updateContact: async function (DAHelper, addParams, callBack) {
    if (DAHelper == undefined || DAHelper.length == 0 || DAHelper == null) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    let condition = new dataAbility.DataAbilityPredicates();
    condition.equalTo('raw_contact_id', addParams.id);
    DAHelper.delete(
      Constants.uri.CONTACT_DATA_URI,
      condition,
    ).then(data => {
      this.dealParam(DAHelper, addParams);
      callBack(addParams.id);
    }).catch(error => {
      HiLog.e(TAG, 'updateContact-update contact error: %s', JSON.stringify(error.message));
      callBack(addParams.id);
    });
  },
  /**
     * Querying IDs by Phone Number
     *
     * @param {string} DAHelper
     * @param {string} addParams  Phone number
     * @param {Object} callBack Contact ID array
     */
  getIdByTelephone: async function (number, callBack) {
    let DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    let condition = new dataAbility.DataAbilityPredicates();
    condition.equalTo('detail_info', number)
      .and()
      .equalTo('type_id', 5)
      .and()
      .equalTo('is_deleted', 0);
    let columns = ["raw_contact_id"];
    let data_row = await DAHelper.query(Constants.uri.CONTACT_DATA_URI, columns, condition)
    data_row.goToFirstRow();
    let resultList = [];
    let maxRows = data_row.rowCount;
    let tempIndex = data_row.rowCount;
    if (data_row.rowCount <= 0) {
      data_row.close();
      callBack(resultList);
    }
    let index = 0;
    do {
      resultList.push(data_row.getString(data_row.getColumnIndex("raw_contact_id")));
      if ((++index) >= maxRows) {
        data_row.close();
        callBack(resultList);
      }
      if (!data_row.goToNextRow()) {
        break;
      }
    } while ((--tempIndex) >= 0)
    data_row.close();
  },
}