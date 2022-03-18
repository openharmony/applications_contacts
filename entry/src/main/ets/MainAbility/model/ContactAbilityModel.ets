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
import {PhoneNumBean} from '../model/bean/PhoneNumBean';
import {ContactInfo} from "../model/bean/ContactInfo";
import dbChangeHelper from '../model/common/DbChangeHelper';
import DataItem from '../contact/entity/DataItem';
import {DataItemType} from '../contact/contract/DataType';
import Data from '../contact/contract/Data';
import HiLog from '../util/Hilog';
import Utils from '../util/Utils';
import ArrayUtil from '../util/ArrayUtil';
import {LooseObject} from '../app';
import ContactRepository from '../contact/repo/ContactRepository';
import common from './common';

const TAG = "ContactAbility: ";

export default {
  /**
     * 添加联系人
     *
     * @param {string} DAHelper 数据库路径
     * @param {Object} addParams 联系人信息
     * @param {Object} callBack 回调
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
        callBack(addParams.id);
      }
    }).catch(error => {
      HiLog.e(TAG, 'logMessage insert error: %s', JSON.stringify(error.message));
    });
  },

  /**
     * 读取名字，需要优化
     * 编辑联系人
     *
     * @param {Object} addParams 联系人信息
     * @return {string} 联系人姓名
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
    } else {
      displayName = '';
    }
    return displayName;
  },

  /**
     * 将数据转换 存进数据库
     *
     * @param {string} DAHelper 数据库路径
     * @param {Object} addParams 联系人信息
     * @param {boolean} isCard 是否为名片信息
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
    dbChangeHelper.getInstance().notifyChange(DAHelper, Constants.uri.CONTACT_DATA_URI)
    dbChangeHelper.getInstance().notifyChange(common.getDAHelper(Constants.uri.CALLLOG_DB_URI), Constants.uri.CALL_LOG_URI);
  },

  /**
     * 联系人姓名存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {string} result 联系人ID
     * @param {string} uri 数据库地址
     */
  dataContact: function (addParams, DAHelper, result, uri) {
    let displayName = '';
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
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
     * 联系人昵称信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
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
     * 联系人公司职位信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {string} result 联系人ID
     * @param {string} uri 数据库地址
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
     * 联系人备注信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
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
     * 联系人手机号信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  phoneContact: function (addParams, DAHelper, result, uri) {
    if (addParams.phones != undefined && addParams.phones.length > 0) {
      let index = 1;
      addParams.phones.forEach(element => {
        if (Utils.isEmpty(element.num)) {
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
     * 联系人邮箱信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  emailContact: function (addParams, DAHelper, result, uri) {
    if (addParams.emails != undefined && addParams.emails.length > 0) {
      let index = 1;
      addParams.emails.forEach(element => {
        if (Utils.isEmpty(element.address)) {
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
     * 联系人地址信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  postalContact: function (addParams, DAHelper, result, uri) {
    if (addParams.houses != undefined && addParams.houses.length > 0) {
      let index = 1;
      addParams.houses.forEach(element => {
        if (Utils.isEmpty(element.houseName)) {
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
     * 联系人特殊日期信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  eventContact: function (addParams, DAHelper, result, uri) {
    if (addParams.events != undefined && addParams.events.length > 0) {
      let index = 1;
      addParams.events.forEach(element => {
        if (Utils.isEmpty(element.data)) {
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
     * 联系人IMA信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  imContact: function (addParams, DAHelper, result, uri) {
    if (addParams.aims != undefined && addParams.aims.length > 0) {
      let index = 1;
      addParams.aims.forEach(element => {
        if (Utils.isEmpty(element.aimName)) {
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
     * 联系人群组信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
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
     * 联系人website信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  websiteContact: function (addParams, DAHelper, result, uri) {
    if (!Utils.isEmptyList(addParams.websites)) {
      addParams.websites.forEach(element => {
        if (Utils.isEmpty(element))
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
     * 联系人relation信息存入数据库
     *
     * @param {Object} addParams 联系人信息
     * @param {string} DAHelper 数据库路径
     * @param {number} result 联系人ID
     * @param {string} uri 数据库地址
     */
  relationsContact: function (addParams, DAHelper, result, uri) {
    if (!Utils.isEmptyList(addParams.relationships)) {
      let index = 1;
      addParams.relationships.forEach(element => {
        if (Utils.isEmpty(element.name)) {
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
     * 查询所有联系人手机号
     *
     * @param {string} DAHelper 数据库地址
     * @param {Object} callBack 回调
     */
  getAllContact: async function (DAHelper?, callBack?) {
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    let contactNumberMap = await this.getAllContactNumbers(DAHelper); // 获取所有联系人及其电话号码的Map映射关系

    let contactList = await ContactRepository.getInstance().findAll();

    if (Utils.isEmptyList(contactList)) {
      HiLog.i(TAG, 'queryContacts-SelectcontactsModel queryContact resultSet is empty!');
      callBack();
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
      jsonObj.phoneNum =
      contactNumberMap.has(jsonObj.contactId) ?
        contactNumberMap.get(jsonObj.contactId)[0].phoneNumber
                                              : "";
      jsonObj.phoneNumbers = contactNumberMap.has(jsonObj.contactId) ? contactNumberMap.get(jsonObj.contactId) : [];
      jsonObj.setShowName();
      resultList.push(jsonObj);
    };
    callBack(resultList);
  },

  /**
     * 获取联系人详细数据
     *
     * @param {string} DAHelper 数据库路径
     * @param {Object} contactId 联系人数据id
     * @param {Object} callback 联系人详情
    */
  getContactById: async function (DAHelper?, contactId?, callback?) {
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
    res.data = contactDetailInfo;
    callback(res);
  },

  /**
     * 处理联系人详细数据
     *
     * @param {Object} resultSet 结果集
     * @param {Object} contactDetailInfo 联系人详情数据
     * @param {Object} actionData 联系人数据
     */
  dealResult: function (dataItem: DataItem, contactDetailInfo) {
    switch (dataItem.getContentTypeId()) {
      case DataItemType.NAME:
        contactDetailInfo.display_name = dataItem.getData();
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
     * 查询所有联系人手机号
     *
     * @param {string} DAHelper 数据库地址
      */
  getAllContactNumbers: async function (DAHelper) {
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    let resultColumns = ['raw_contact_id', 'detail_info', 'extend7']; // extend7代表labelId
    let conditionArgs = new dataAbility.DataAbilityPredicates();
    conditionArgs.equalTo('type_id', '5').orderByAsc('raw_contact_id');
    let resultSet = await DAHelper.query(Constants.uri.CONTACT_DATA_URI, resultColumns, conditionArgs);
    if (Utils.isEmpty(resultSet) || resultSet.rowCount == 0) {
      HiLog.i(TAG, 'getAllContactNumbers-Selectcontacts Model getAllContactNumbers resultSet is empty!');
      return new Map();
    }
    let contactNumberMap = new Map(); // 用于存储联系人及其电话号码的对应关系
    resultSet.goToFirstRow();
    let oldContact = resultSet.getString(0);
    let numberList = [];
    do {
      let newContact = resultSet.getString(0);
      if (oldContact == String(newContact)) { // 如果是同一联系人则把手机号放到同一个list中
        numberList.push({
          'phoneNumber': resultSet.getString(1),
          'labelId': resultSet.getString(2)
        });
      } else {
        // 联系人变化时，存储联系人与手机号码列表的对应关系
        contactNumberMap.set(oldContact, numberList);
        oldContact = newContact;
        // 将最新的号码数据存储到新的numberList
        numberList = [{
                        'phoneNumber': resultSet.getString(1),
                        'labelId': resultSet.getString(2)
                      }];
      }
    } while (resultSet.goToNextRow());
    contactNumberMap.set(oldContact, numberList);
    return contactNumberMap;
  },

  /**
     * 通过电话号码获取该号码的联系人id
     *
     * @param {string} DAHelper 数据库地址
     * @param {string} number 手机号号码
     * @param {Object} callBack 联系人Id
     */
  getContactIdByNumber: async function (DAHelper, number, callBack) {
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    if (Utils.isEmpty(number)) {
      return;
    }
    let resultColumns = [
      'raw_contact_id',
    ];
    let cleanNumber = Utils.removeSpace(number);
    let condition = new dataAbility.DataAbilityPredicates();
    condition.equalTo('detail_info', cleanNumber);
    condition.and();
    condition.equalTo('is_deleted', 0);
    condition.and();
    condition.equalTo('type_id', '5');
    let resultSet = await DAHelper.query(Constants.uri.CONTACT_DATA_URI, resultColumns, condition);
    if (Utils.isEmpty(resultSet) || resultSet.rowCount == 0) {
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
     * 编辑联系人信息
     *
     * @param {string} DAHelper 数据库路径
     * @param {Object} addParams  联系人信息
     * @param {Object} callBack 联系人ID
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
     * 根据电话号码查id
     *
     * @param {string} DAHelper 数据库路径
     * @param {string} addParams  电话号码
     * @param {Object} callBack 联系人ID数组
     */
  getIdByTelephone: async function (DAHelper, number, callBack) {
    if (DAHelper == undefined || DAHelper.length == 0) {
      DAHelper = featureAbility.acquireDataAbilityHelper(Constants.uri.CONTACT_DB_URI);
    }
    let condition = new dataAbility.DataAbilityPredicates();
    condition.equalTo('detail_info', number)
      .and()
      .equalTo('type_id', 5);
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