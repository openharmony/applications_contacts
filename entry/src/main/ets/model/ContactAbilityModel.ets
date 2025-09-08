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
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactVo } from '../model/bean/ContactVo';
import { ContactInfo } from '../model/bean/ContactInfo';
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { DataItem } from '../../../../../feature/contact/src/main/ets/entity/DataItem';
import { DataItemType } from '../../../../../feature/contact/src/main/ets/contract/DataType';
import { Data } from '../../../../../feature/contact/src/main/ets/contract/Data';
import { RawContacts } from '../../../../../feature/contact/src/main/ets/contract/RawContacts';
import { Contacts } from '../../../../../feature/contact/src/main/ets/contract/Contacts';
import { HiLog } from 'common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import { PhoneNumber } from '../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { FavoriteBean } from './bean/FavoriteBean';
import { CallLog } from '../../../../../feature/call/src/main/ets/entity/CallLog';
import { SearchContactsBean } from './bean/SearchContactsBean';
import common from '@ohos.app.ability.common';
import { ValueType } from '@kit.ArkData';
import Contact from '../../../../../feature/contact/src/main/ets/entity/Contact';
import { ContactReturnObj } from './type';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  ContactSearchResultData,
  IContactSearchParams,
  IT9PhoneNumbersQueryParams
} from './type/ContactParams';
import { PhoneNumBean } from './bean/PhoneNumBean';
import { RichContactInfo } from './bean/RichContactInfo';
import { EmailBean } from './bean/EmailBean';
import { AIMBean } from './bean/AIMBean';
import { HouseBean } from './bean/HouseBean';
import { EventBean } from './bean/EventBean';
import { AssociatedPersonBean } from './bean/AssociatedPersonBean';
import ContactListItem from '../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import ContactUsuallyListItem from '../../../../../feature/contact/src/main/ets/repo/ContactUsuallyListItem';
import LooseObject from './LooseObject ';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

const TAG = 'ContactAbility: ';
const PROFILE_CONTACT_DATA_URI = 'datashare:///com.ohos.contactsdataability/profile/contact_data';

class ContactAbilityModel {
  static getContactById(contactId: string, arg1: Function, arg2: Context) {
    throw new Error('Method not implemented.');
  }

  /**
   * Add Contact
   *
   * @param {Object} addParams Contact Information
   * @param {Object} callBack
   */
  async addContact(addParams: ContactInfo, callBack?: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'Start to create a new contact.');
    if (addParams == undefined || addParams == null) {
      HiLog.e(TAG, 'The addParams of parameter is NULL');
      return;
    }
    let DAHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
    let insertValues: Record<string, string> = {
      'display_name': this.getDisplayName(addParams)
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
    }).catch((error: Error) => {
      HiLog.e(TAG, 'logMessage insert error: ' + JSON.stringify(error.message));
    });
    HiLog.i(TAG, 'End of creating a contact.');
  }
  /**
   * Read the name, which needs to be optimized.
   * Edit Contact
   *
   * @param {Object} addParams Contact Information
   * @return {string} Contact Name
   */
  getDisplayName(addParams: ContactInfo): string {
    let displayName = '';
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
    } else if (addParams.nickname != undefined && addParams.nickname.length > 0) {
      displayName = addParams.nickname;
    } else if (addParams.company != undefined && addParams.company.length > 0) {
      displayName = addParams.company;
    } else if (addParams.position != undefined && addParams.position.length > 0) {
      displayName = addParams.position;
    } else if (addParams.phones != undefined && addParams.phones.length > 0) {
      for (let element of addParams.phones) {
        if (StringUtil.isEmpty(element.num)) {
          continue;
        }
        displayName = PhoneNumber.fromString(element.num).getNumber();
        break;
      }
    }
    return displayName;
  }

  /**
   * Convert the data to the database.
   *
   * @param {string} DAHelper Database path
   * @param {Object} addParams Contact Information
   * @param {boolean} isCard Indicates whether the information is a business card.
   */
  dealParam(DAHelper: dataShare.DataShareHelper | null, addParams: ContactInfo, isCard: boolean, callBack: Function | undefined) {
    if (DAHelper != null || DAHelper != undefined) {
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
    }
  }

  /**
   * Save the contact name to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {string} result Contact ID
   * @param {string} uri Database address
   */
  dataContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    let displayName = '';
    let updateFlag = 0;
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
    } else {
      updateFlag = 1;
      displayName = this.getDisplayName(addParams);
    }
    if (displayName.length > 0) {
      let dataContact: Record<string, string | number> = {
        'raw_contact_id': result,
        'detail_info': displayName,
        'alpha_name': displayName,
        'phonetic_name': addParams.phoneticName,
        'other_lan_last_name': addParams.otherLanLastName,
        'other_lan_first_name': addParams.otherLanFirstName,
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
      }).catch((err: Error) => {
        HiLog.e(TAG, 'name-insert failed. Cause: ' + JSON.stringify(err.message));
      });
    }
  }

  /**
   * Save the contact nickname information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  nickContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.nickname != undefined && addParams.nickname.length > 0) {
      let nickContact: Record<string, string | number> = {
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
      }).catch((err: Error) => {
        HiLog.e(TAG, 'nickname-insert failed. Cause: ' + JSON.stringify(err.message));
      });
    }
  }
  /**
   * Save the position information of the contact company to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {string} result Contact ID
   * @param {string} uri Database address
   */
  organizationContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
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
      let organizationContact: Record<string, string | number> = {
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
      }).catch((error: Error) => {
        HiLog.e(TAG, 'organizationContact-insert failed. Cause: ' + JSON.stringify(error.message));
      });
    }
  }
  /**
   * Save the contact remarks to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  noteContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.remarks != undefined && addParams.remarks.length > 0) {
      let noteContact: Record<string, string | number> = {
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
      }).catch((error: Error) => {
        HiLog.e(TAG, 'noteContact-insert failed. Cause: ' + JSON.stringify(error.message));
      });
    }
  }
  /**
   * The contact mobile number information is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  phoneContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.phones != undefined && addParams.phones.length > 0) {
      let index = 1;
      addParams.phones.forEach(element => {
        if (StringUtil.isEmpty(element.num)) {
          return;
        }
        let phoneContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'phoneContact-insert failed. Cause: ' + JSON.stringify(error.message));
        });
      });
    }
  }
  /**
   * Save the contact email information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  emailContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.emails != undefined && addParams.emails.length > 0) {
      let index = 1;
      addParams.emails.forEach(element => {
        if (StringUtil.isEmpty(element.address)) {
          return;
        }
        let emailContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'emailContact-insert failed. Cause: ' + JSON.stringify(error.message));
        });
      });
    }
  }
  /**
   * The contact address information is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  postalContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.houses != undefined && addParams.houses.length > 0) {
      let index = 1;
      addParams.houses.forEach(element => {
        if (StringUtil.isEmpty(element.houseName)) {
          return;
        }
        let postalContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'postalContact-insert failed. Cause: ' + JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * Save the contact special date information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  eventContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.events != undefined && addParams.events.length > 0) {
      let index = 1;
      addParams.events.forEach(element => {
        if (StringUtil.isEmpty(element.data)) {
          return;
        }
        let eventContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'eventContact-insert failed. Cause: ' + JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * Save the contact IMA information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  imContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.aims != undefined && addParams.aims.length > 0) {
      let index = 1;
      addParams.aims.forEach(element => {
        if (StringUtil.isEmpty(element.aimName)) {
          return;
        }
        let imContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'imContact-insert failed. Cause: ' + JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * Save the contact group information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  groupsContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (addParams.groups != undefined && addParams.groups.length > 0) {
      addParams.groups.forEach(element => {
        let groupsContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'groupsContact-insert failed. Cause: %s', JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * Save the contact website information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  websiteContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (!ArrayUtil.isEmpty(addParams.websites)) {
      addParams.websites.forEach(element => {
        if (StringUtil.isEmpty(element)) {
          return;
        }
        let websiteContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'websiteContact-insert failed. Cause: %s', JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * The relation information of the contact is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} DAHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  relationsContact(addParams: ContactInfo, DAHelper: dataShare.DataShareHelper, result: string, uri: string) {
    if (!ArrayUtil.isEmpty(addParams.relationships)) {
      let index = 1;
      addParams.relationships.forEach(element => {
        if (StringUtil.isEmpty(element.name)) {
          return;
        }
        let relationsContact: Record<string, string | number> = {
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
        }).catch((error: Error) => {
          HiLog.e(TAG, 'relationsContact-insert failed. Cause: %s', JSON.stringify(error.message));
        });
      });
    }
  }

  /**
   * Querying the Mobile Numbers of All Contacts
   *
   * @param {string} DAHelper
   * @param {Object} callBack
   */
  async getAllContact(actionData: AllContactGetParam, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query all contacts without PhoneNumbers');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findAll(actionData, (contactList?: ContactListItem[]) => {
      if (contactList === undefined || contactList.length == 0) {
        HiLog.i(TAG, 'queryContacts-SelectcontactsModel queryContact resultSet is empty!');
        let emptyResult: ContactVo[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: ContactVo[] = [];
      for (let contactItem of contactList) {
        let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', true, '', '');
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
  }

  /**
   * 查询所有联系人手机号
   *
   * @param {string} DAHelper 数据库地址
   * @param {Object} callBack 回调
   * @param {Object} addParams  Contact Information
   */
  getAllContactWithPhoneNumbers(callBack: Function, addParams: AllContactWithPhoneNumbersGetParam, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query all contacts with PhoneNumbers');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findByPhoneIsNotNull(addParams.favorite, addParams.editContact, (contactList: ContactVo[]) => {
      if (ArrayUtil.isEmpty(contactList)) {
        HiLog.i(TAG, 'getAllContactWithPhoneNumbers-SelectcontactsModel queryContact resultSet is empty!');
        let emptyResult: ContactVo[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: ContactVo[] = [];
      for (let contactItem of contactList) {
        let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', true, '', '');
        jsonObj.contactId = contactItem.id.toString();
        jsonObj.emptyNameData = contactItem.displayName;
        jsonObj.namePrefix = contactItem.namePrefix;
        jsonObj.nameSuffix = contactItem.nameSuffix;
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
  }

  /**
   * Obtain contact details.
   *
   * @param {Object} contactId Contact data ID.
   * @param {Object} callback Contact details
   */
  getContactById(contactId: number, callback: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query contact by id.');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findById(contactId, (contact: Contact) => {
      const res: ContactReturnObj = new ContactReturnObj();
      if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
        HiLog.e(TAG, 'Query contact by id failed.');
        callback(res);
        return;
      }
      let contactDetailInfo: RichContactInfo = new RichContactInfo('');
      for (let dataItem of contact.rowContacts[0].dataItems) {
        // 处理智能合并的 主联系人
        this.dealResult(dataItem, contactDetailInfo);
      }
      contactDetailInfo.id = contact.rowContacts[0].id.toString();
      contactDetailInfo.photoFirstName = contact.rowContacts[0].values.get(RawContacts.PHOTO_FIRST_NAME) as string;
      res.data = contactDetailInfo;
      callback(res);
      HiLog.i(TAG, 'End of querying contacts by ID.');
    });
  }

  /**
   * Process contact details
   *
   * @param {Object} resultSet
   * @param {Object} contactDetailInfo Contact details data
   * @param {Object} actionData Contact data
   */
  dealResult(dataItem: DataItem, contactDetailInfo: RichContactInfo) {
    contactDetailInfo.favorite = dataItem.getFavorite()?.toString();
    switch (dataItem.getContentTypeId()) {
      case DataItemType.NAME:
        contactDetailInfo.display_name = (dataItem.getData()) as string;
        contactDetailInfo.nameUpdate = dataItem.getLabelId();
        break;
      case DataItemType.PHONE:
        let phone_element: PhoneNumBean =
          new PhoneNumBean(dataItem.getLabelId() as string, dataItem.getData() as string, dataItem.getLabelName() as string, '', '');
        if (contactDetailInfo.phones) {
          contactDetailInfo.phones.push(phone_element);
        } else {
          contactDetailInfo.phones = [phone_element];
        }
        break;
      case DataItemType.EMAIL:
        let email_element: EmailBean = new EmailBean(dataItem.getLabelId() as string, dataItem.getData() as string, dataItem.getLabelName() as string);
        if (contactDetailInfo.emails) {
          contactDetailInfo.emails.push(email_element);
        } else {
          contactDetailInfo.emails = [email_element];
        }
        break;
      case DataItemType.NOTE:
        contactDetailInfo.remarks = (dataItem.getData()) as string;
        break;
      case DataItemType.ORGANIZATION:
        contactDetailInfo.position = dataItem.values.get(Data.POSITION) as string;
        contactDetailInfo.company = dataItem.getData() as string;
        break;
      case DataItemType.IM:
        let aim_element: AIMBean = new AIMBean('', dataItem.getLabelId() as string, dataItem.getLabelName() as string, dataItem.getData() as string);
        if (contactDetailInfo.aims) {
          contactDetailInfo.aims.push(aim_element);
        } else {
          contactDetailInfo.aims = [aim_element];
        }
        break;
      case DataItemType.STRUCTURED_POSTAL:
        let house_element: HouseBean = new HouseBean('', dataItem.getLabelId() as string, dataItem.getLabelName() as string, dataItem.getData() as string);
        if (contactDetailInfo.houses) {
          contactDetailInfo.houses.push(house_element);
        } else {
          contactDetailInfo.houses = [house_element];
        }
        break;
      case DataItemType.GROUP_MEMBERSHIP:
        contactDetailInfo.nickname = dataItem.getData() as string;
        break;
      case DataItemType.EVENT:
        let event_element: EventBean = new EventBean(dataItem.getLabelId() as string, dataItem.getData() as string, dataItem.getLabelName() as string, '');
        if (contactDetailInfo.events) {
          contactDetailInfo.events.push(event_element);
        } else {
          contactDetailInfo.events = [event_element];
        }
        break;
      case DataItemType.WEBSITE:
        let website_element = dataItem.getData() as string;
        if (contactDetailInfo.websites) {
          contactDetailInfo.websites.push(website_element);
        } else {
          contactDetailInfo.websites = [website_element];
        }
        break;
      case DataItemType.RELATION:
        let relation_element = new AssociatedPersonBean(dataItem.getLabelId() as string, '', dataItem.getData() as string, dataItem.getLabelName() as string);
        if (contactDetailInfo.relationships) {
          contactDetailInfo.relationships.push(relation_element);
        } else {
          contactDetailInfo.relationships = [relation_element];
        }
        break;
    }
  }

  /**
   * Edit Contact Information
   *
   * @param {string} DAHelper
   * @param {Object} addParams  Contact Information
   * @param {Object} callBack Contact ID
   */
  async updateContact(DAHelper: dataShare.DataShareHelper | null, addParams: ContactInfo, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to update contacts.');
    try {
      if (DAHelper == undefined || DAHelper == null) {
        DAHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
      }
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('raw_contact_id', addParams.id);
      DAHelper.delete(
        Data.CONTENT_URI,
        condition,
      ).then(data => {
        this.dealParam(DAHelper, addParams, false, callBack);
      }).catch((error: Error) => {
        HiLog.e(TAG, 'updateContact-update contact error: %s', JSON.stringify(error.message));
      });
      HiLog.i(TAG, 'End to update contacts.');
    } catch (err) {
      HiLog.e(TAG, 'updateContact err : ' + JSON.stringify(err));
    }
  }

  /**
   * Querying IDs by Phone Number
   *
   * @param {string} DAHelper
   * @param {string} addParams  Phone number
   * @param {Object} callBack Contact ID array
   */
  async getIdByTelephone(number: ValueType, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query contactID by phone number.');
    let DAHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('detail_info', number)
      .and()
      .equalTo('type_id', 5)
      .and()
      .equalTo('is_deleted', 0);
    let columns = ['raw_contact_id'];
    let data_row = await DAHelper.query(Data.CONTENT_URI, condition, columns);
    let resultList: string[] = [];
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
      resultList.push(data_row.getString(data_row.getColumnIndex('raw_contact_id')));
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
  }

  /**
   * Edit Contact Favorite
   *
   * @param {string} DAHelper
   * @param {Object} addParams  Contact Information
   * @param {Object} callBack Contact ID
   */
  async updateFavorite(DAHelper: dataShare.DataShareHelper | null, addParams: Record<string, string | number>, callBack: Function,
    context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'updateFavorite start.');
    if (DAHelper == undefined || DAHelper == null) {
      DAHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
    }
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('contact_id', addParams.id);
    const va: Record<string, string | number> = {
      'favorite': addParams.favorite,
    }
    DAHelper.update(
      RawContacts.CONTENT_URI,
      condition,
      va
    ).then(data => {
      if (data == -1) {
        HiLog.e(TAG, 'updateFavorite data failed!');
      }
      HiLog.i(TAG, 'updateFavorite data success!');
      callBack(addParams.favorite)
    }).catch((err: Error) => {
      HiLog.e(TAG, 'updateFavorite failed. Cause: ' + JSON.stringify(err.message));
    });
    HiLog.i(TAG, 'updateFavorite end.');
  }
  /**
   * Querying the Mobile Numbers of All Favorites
   *
   * @param {string} DAHelper
   * @param {Object} callBack
   */
  async getAllFavorite(callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'getAllFavorite start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findAllFavorite((favoriteList) => {
        if (ArrayUtil.isEmpty(favoriteList)) {
          let emptyResult: FavoriteBean[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: FavoriteBean[] = [];
        for (let contactItem of favoriteList) {
          let jsonObj: FavoriteBean = new FavoriteBean('', -1, '', '', '', '', '', true, '', false, 0, '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.isCommonUseType = 0;
          jsonObj.displayName = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.position = contactItem.position;
          jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
          jsonObj.isUsuallyShow = false;
          jsonObj.favorite = 1;
          jsonObj.setShowName();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'getAllFavorite data success!');
        callBack(resultList);
      })
    }
    HiLog.i(TAG, 'getAllFavorite end.');
  }
  /**
   * Query call records
   *
   * @param {string} DAHelper
   * @param {Object} callBack call records
   */
  async getAllUsually(callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'getAllUsually start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findAllUsually((callLog: CallLog[]) => {
        if (ArrayUtil.isEmpty(callLog)) {
          let emptyResult: CallLog[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: CallLog[] = [];
        resultList = callLog;
        HiLog.i(TAG, 'getAllUsually data success! ');
        callBack(resultList);
      });
    }
    HiLog.i(TAG, 'getAllUsually end.');
  }
  /**
   * DisplayName Query Favorite
   *
   * @param {string} DAHelper
   * @param {Object} addParams Contact Information
   * @param {Object} callBack Contact Information
   */
  async getDisplayNamesFindUsually(displayName: ValueType[], usuallyPhone: ValueType[], callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'getDisplayNamesFindUsually start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().getDisplayNameByFavorite(displayName, usuallyPhone, (favoriteList: ContactUsuallyListItem[]) => {
        if (ArrayUtil.isEmpty(favoriteList)) {
          let emptyResult: FavoriteBean[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: FavoriteBean[] = [];
        for (let i = 0; i < favoriteList.length; i++) {
          let jsonObj: FavoriteBean = new FavoriteBean('', -1, '', '', '', '', '', false, '', false, 0, '');
          jsonObj.contactId = favoriteList[i].id.toString();
          jsonObj.isCommonUseType = 1;
          jsonObj.displayName = favoriteList[i].displayName;
          jsonObj.namePrefix = favoriteList[i].sortFirstLetter;
          jsonObj.nameSuffix = favoriteList[i].photoFirstName;
          jsonObj.position = favoriteList[i].position;
          jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
          jsonObj.isUsuallyShow = false;
          jsonObj.favorite = 0;
          jsonObj.phoneNum = favoriteList[i].detailInfo;
          jsonObj.setShowName();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'getDisplayNamesFindUsually sc.');
        callBack(resultList);
      })
    }
    HiLog.i(TAG, 'getDisplayNamesFindUsually end! ');
  }
  /**
   * Move Favorite Data Sorting
   *
   * @param {string} DAHelper
   * @param {Object} addParams Contact Information
   * @param {Object} callBack favoriteOrder
   */
  async moveSortFavorite(DAHelper: dataShare.DataShareHelper | null, addParams: LooseObject, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'moveSortFavorite start.');
    if (DAHelper == undefined || DAHelper == null) {
      DAHelper = await dataShare.createDataShareHelper(context ? context : globalThis.context, Contacts.CONTENT_URI);
    }
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('contact_id', addParams.id);
    const va: Record<string, string | number> = {
      'favorite_order': addParams.favoriteOrder > 9 ? addParams.favoriteOrder : '0' + addParams.favoriteOrder
    }
    DAHelper.update(
      RawContacts.CONTENT_URI,
      condition,
      va
    ).then(data => {
      if (data == -1) {
        HiLog.e(TAG, 'moveSortFavorite data failed!');
        callBack('')
        return;
      }
      HiLog.i(TAG, 'moveSortFavorite data success!');
      callBack(addParams.favoriteOrder);
    }).catch((err: Error) => {
      HiLog.e(TAG, 'moveSortFavorite failed. Cause: ' + JSON.stringify(err.message));
    })
    HiLog.i(TAG, 'End to update moveSortFavorite.');
  }
  /**
   * Querying the Mobile Numbers of Search Contacts
   *
   * @param {string} DAHelper
   * @param {Object} callBack
   */
  async getSearchContact(actionData: IContactSearchParams, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'getSearchContact start.');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().searchContact(actionData, (contactList: ContactSearchResultData) => {
      if (ArrayUtil.isEmpty(contactList.data)) {
        HiLog.i(TAG, 'getSearchContact resultSet is empty!');
        let emptyResult: SearchContactsBean[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: SearchContactsBean[] = [];
      for (let contactItem of contactList.data) {
        let jsonObj: SearchContactsBean = new SearchContactsBean('', '', '', '', '', '', '', '', '', 0, '', '', '', '', '', '');
        jsonObj.id = contactItem.id.toString();
        jsonObj.accountId = contactItem.accountId;
        jsonObj.contactId = contactItem.contactId;
        jsonObj.rawContactId = contactItem.rawContactId;
        jsonObj.searchName = contactItem.searchName;
        jsonObj.displayName = contactItem.displayName;
        jsonObj.phoneticName = contactItem.phoneticName;
        jsonObj.photoId = contactItem.photoId;
        jsonObj.photoFileId = contactItem.photoFileId;
        jsonObj.isDeleted = Number(contactItem.isDeleted);
        jsonObj.position = contactItem.position;
        jsonObj.sortFirstLetter = contactItem.sortFirstLetter;
        jsonObj.photoFirstName = contactItem.photoFirstName;
        jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
        jsonObj.detailInfo = contactItem.detailInfo;
        jsonObj.hasPhoneNumber = contactItem.hasPhoneNumber;
        resultList.push(jsonObj);
      }
      callBack(resultList);
      HiLog.i(TAG, 'getSearchContact end.');
    })
  }
  getQueryT9PhoneNumbers(callBack: Function, addParams: IT9PhoneNumbersQueryParams, context?: common.UIAbilityContext | Context) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().queryT9PhoneIsNotNull(addParams.favorite, (contactList: ContactListItem[]) => {
      if (ArrayUtil.isEmpty(contactList)) {
        HiLog.i(TAG, 'getQueryT9PhoneNumbers queryContact resultSet is empty!');
        let emptyResult: ContactVo[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: ContactVo[] = [];
      for (let contactItem of contactList) {
        let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', true, '', '');
        jsonObj.contactId = contactItem.id.toString();
        jsonObj.emptyNameData = contactItem.displayName;
        jsonObj.namePrefix = contactItem.sortFirstLetter;
        jsonObj.nameSuffix = contactItem.photoFirstName;
        jsonObj.company = contactItem.company;
        jsonObj.position = contactItem.position;
        jsonObj.portraitColor = MorandiColor.Color[Math.abs(parseInt(jsonObj.contactId)) % 6];
        jsonObj.show = false;
        if (contactItem.phoneNumbers !== undefined) {
          jsonObj.phoneNumbers = contactItem.phoneNumbers;
        }
        jsonObj.setShowName();
        resultList.push(jsonObj);
      }
      callBack(resultList);
      HiLog.i(TAG, 'End of querying all contacts');
    })
  }
}

export default new ContactAbilityModel();