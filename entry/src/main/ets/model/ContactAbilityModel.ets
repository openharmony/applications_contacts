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

import MorandiColor from '../model/bean/MorandiColor';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from "@ohos.data.dataSharePredicates";
import { ContactVo } from '../model/bean/ContactVo';
import { ContactInfo } from "../model/bean/ContactInfo";
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { DataItem } from '../../../../../feature/contact/src/main/ets/entity/DataItem';
import { DataItemType } from '../../../../../feature/contact/src/main/ets/contract/DataType';
import { Data } from '../../../../../feature/contact/src/main/ets/contract/Data';
import { RawContacts } from '../../../../../feature/contact/src/main/ets/contract/RawContacts';
import { Contacts } from '../../../../../feature/contact/src/main/ets/contract/Contacts';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import { CallLogRepository } from '../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { PhoneNumber } from '../../../../../feature/phonenumber/src/main/ets/PhoneNumber';

const TAG = "ContactAbility: ";
const PROFILE_CONTACT_DATA_URI = 'datashare:///com.ohos.contactsdataability/profile/contact_data';

export default {
  /**
   * Add Contact
   *
   * @param {Object} addParams Contact Information
   * @param {Object} callBack
   */
  addContact: async function (addParams: ContactInfo, callBack?, context?) {
    HiLog.i(TAG, 'Start to create a new contact.');
    if (addParams == undefined || addParams == null) {
      HiLog.e(TAG, "The addParams of parameter is NULL");
      return "";
    }
    let DAHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
    let insertValues = {
      'display_name': this.getDisplayName(addParams),
    };
    DAHelper.insert(
    RawContacts.CONTENT_URI,
      insertValues
    ).then(data => {
      if (data == -1 || data == undefined) {
        HiLog.e(TAG, 'Data inserted failed');
        return;
      }
      addParams.id = data.toString();
      this.dealParam(DAHelper, addParams, false, callBack);
    }).catch(error => {
      HiLog.e(TAG, 'logMessage insert error: ' + JSON.stringify(error.message));
    });
    HiLog.i(TAG, 'End of creating a contact.');
  },

  /**
   * Read the name, which needs to be optimized.
   * Edit Contact
   *
   * @param {Object} addParams Contact Information
   * @return {string} Contact Name
   */
  getDisplayName: function (addParams: ContactInfo): String {
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
        displayName = PhoneNumber.fromString(element.num).getNumber();
        break;
      }
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
  dealParam: function (DAHelper, addParams: ContactInfo, isCard, callBack) {
    let result = addParams.id;
    let uri = isCard ? PROFILE_CONTACT_DATA_URI : Data.CONTENT_URI;

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

    if (callBack != undefined) {
      HiLog.d(TAG, 'Start the callback function.');
      callBack(addParams.id);
    }

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
        if (data == -1) {
          HiLog.e(TAG, 'name-insert data failed!');
        }
        HiLog.d(TAG, 'name-insert data success!');
      }).catch(err => {
        HiLog.e(TAG, 'name-insert failed. Cause: ' + JSON.stringify(err.message));
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
      ).then(data => {
        if (data == -1) {
          HiLog.e(TAG, 'nickname-insert data failed!');
        }
        HiLog.d(TAG, 'nickname-insert data success!');
      }).catch(err => {
        HiLog.e(TAG, 'nickname-insert failed. Cause: ' + JSON.stringify(err.message));
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
    if (addParams.company != undefined && addParams.company.length > 0
    || addParams.position != undefined && addParams.position.length > 0) {
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
        if (data == -1) {
          HiLog.e(TAG, 'organizationContact-insert data failed!');
        }
        HiLog.d(TAG, 'organizationContact-insert data success!');
      }).catch(error => {
        HiLog.e(TAG, 'organizationContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
        if (data == -1) {
          HiLog.e(TAG, 'noteContact-insert data failed!');
        }
        HiLog.d(TAG, 'noteContact-insert insert data success!');
      }).catch(error => {
        HiLog.e(TAG, 'noteContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'phoneContact-insert data failed!');
          }
          HiLog.d(TAG, 'phoneContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'phoneContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'emailContact-insert data failed!');
          }
          HiLog.d(TAG, 'emailContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'emailContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'postalContact-insert data failed!');
          }
          HiLog.d(TAG, 'postalContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'postalContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'eventContact-insert data failed!');
          }
          HiLog.d(TAG, 'eventContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'eventContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'imContact-insert data failed!');
          }
          HiLog.d(TAG, 'imContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'imContact-insert failed. Cause: ' + JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'groupsContact-insert data failed!');
          }
          HiLog.d(TAG, 'groupsContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'groupsContact-insert failed. Cause: %s', JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'websiteContact-insert data failed!');
          }
          HiLog.d(TAG, 'websiteContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'websiteContact-insert failed. Cause: %s', JSON.stringify(error.message));
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
          if (data == -1) {
            HiLog.e(TAG, 'relationsContact-insert data failed!');
          }
          HiLog.d(TAG, 'relationsContact-insert data success!');
        }).catch(error => {
          HiLog.e(TAG, 'relationsContact-insert failed. Cause: %s', JSON.stringify(error.message));
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
  getAllContact: async function (actionData, callBack, context?) {
    HiLog.i(TAG, 'Start to query all contacts without PhoneNumbers');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findAll(actionData, contactList => {
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
        jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
        jsonObj.show = false;
        jsonObj.setShowName();
        resultList.push(jsonObj);
      }
      callBack(resultList);
      HiLog.i(TAG, 'End of querying all contacts');
    });
  },

  /**
   * 查询所有联系人手机号
   *
   * @param {string} DAHelper 数据库地址
   * @param {Object} callBack 回调
   */
  getAllContactWithPhoneNumbers: function (callBack, context?) {
    HiLog.i(TAG, 'Start to query all contacts with PhoneNumbers');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findByPhoneIsNotNull(contactList => {
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
        jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
        jsonObj.show = false;
        jsonObj.phoneNumbers = contactItem.phoneNumbers;
        jsonObj.setShowName();
        resultList.push(jsonObj);
      }
      callBack(resultList);
      HiLog.i(TAG, 'End of querying all contacts');
    });
  },

  /**
   * Obtain contact details.
   *
   * @param {Object} contactId Contact data ID.
   * @param {Object} callback Contact details
   */
  getContactById: function (contactId, callback, context?) {
    HiLog.i(TAG, 'Start to query contact by id.');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findById(contactId, contact => {
      let res = {
        'data': {}
      };
      if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
        HiLog.e(TAG, 'Query contact by id failed.');
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
      HiLog.i(TAG, 'End of querying contacts by ID.');
    });
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
    HiLog.i(TAG, 'Start to query contacts by phone number.');
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = await dataShare.createDataShareHelper(globalThis.context, Contacts.CONTENT_URI);
    }
    if (StringUtil.isEmpty(number)) {
      return;
    }
    let resultColumns = [
      'raw_contact_id',
    ];
    let cleanNumber = StringUtil.removeSpace(number);
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('detail_info', cleanNumber);
    condition.and();
    condition.equalTo('is_deleted', 0);
    condition.and();
    condition.equalTo('type_id', '5');
    let resultSet = await DAHelper.query(Data.CONTENT_URI, resultColumns, condition);
    if (StringUtil.isEmpty(resultSet) || resultSet.rowCount == 0) {
      HiLog.i(TAG, 'getContactIdByNumber-contactId resultSet is empty!');
      callBack();
      return;
    }
    resultSet.goToFirstRow();
    let contactId = resultSet.getString(0);
    resultSet.close();
    callBack(contactId);
    HiLog.i(TAG, 'End of querying contacts by phone number.');
  },

  /**
   * Edit Contact Information
   *
   * @param {string} DAHelper
   * @param {Object} addParams  Contact Information
   * @param {Object} callBack Contact ID
   */
  updateContact: async function (DAHelper, addParams, callBack, context?) {
    HiLog.i(TAG, 'Start to update contacts.');
    try {
      if (DAHelper == undefined || DAHelper.length == 0 || DAHelper == null) {
        DAHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
      }
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('raw_contact_id', addParams.id);
      DAHelper.delete(
      Data.CONTENT_URI,
        condition,
      ).then(data => {
        this.dealParam(DAHelper, addParams, false, callBack);
      }).catch(error => {
        HiLog.e(TAG, 'updateContact-update contact error: %s', JSON.stringify(error.message));
      });
      HiLog.i(TAG, 'End to update contacts.');
    } catch(err) {
      HiLog.e(TAG, 'updateContact err : ' + JSON.stringify(err));
    }
  },
  /**
   * Querying IDs by Phone Number
   *
   * @param {string} DAHelper
   * @param {string} addParams  Phone number
   * @param {Object} callBack Contact ID array
   */
  getIdByTelephone: async function (number, callBack, context?) {
    HiLog.i(TAG, 'Start to query contactID by phone number.');
    let DAHelper = await dataShare.createDataShareHelper(context ?context : globalThis.context, Contacts.CONTENT_URI);
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('detail_info', number)
      .and()
      .equalTo('type_id', 5)
      .and()
      .equalTo('is_deleted', 0);
    let columns = ["raw_contact_id"];
    let data_row = await DAHelper.query(Data.CONTENT_URI, condition, columns);
    let resultList = [];
    if (data_row.rowCount <= 0) {
      data_row.close();
      callBack(resultList);
      return;
    }
    data_row.goToFirstRow();
    let maxRows = data_row.rowCount;
    let tempIndex = data_row.rowCount;
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
    HiLog.i(TAG, 'End to query contactID by phone number.');
  },
}