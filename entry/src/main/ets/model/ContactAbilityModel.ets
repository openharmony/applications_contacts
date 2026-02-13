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
import DataShareHelper from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { AlphabetIndexObj, CharIndex, CHINESE_CHAR_CODE, ContactVo } from '../model/bean/ContactVo';
import { ContactInfo } from '../model/bean/ContactInfo';
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { DataItem } from '../../../../../feature/contact/src/main/ets/entity/DataItem';
import { NumberMatch } from '../../../../../feature/contact/src/main/ets/cust/NumberMatch';
import DataType, { DataItemType } from '../../../../../feature/contact/src/main/ets/contract/DataType';
import { Data } from '../../../../../feature/contact/src/main/ets/contract/Data';
import RawContactsColumns from '../../../../../feature/contact/src/main/ets/contract/RawContactsColumns';
import { RawContacts } from '../../../../../feature/contact/src/main/ets/contract/RawContacts';
import RawContact from '../../../../../feature/contact/src/main/ets/entity/RawContact';
import { Contacts } from '../../../../../feature/contact/src/main/ets/contract/Contacts';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  ContactSearchResultData,
  CountAlphabetIndex,
  CountRawContact,
  IContactListAndAlphabetIndex,
  IContactSearchParams,
  IT9PhoneNumbersQueryParams,
  NameFixInfo,
  PickerContactList,
  ContactPickerListItem,
  ContactInfoGetParamsInCallback
} from '../../ets/model/type/ContactParams';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import { FavoriteBean } from './bean/FavoriteBean';
import { CallLog } from '../../../../../feature/call/src/main/ets/entity/CallLog';
import { SearchContactsBean } from './bean/SearchContactsBean';
import { BusinessError } from '@ohos.base';
import { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket';
import common from '@ohos.app.ability.common';
import ContactListItem from '../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import { RichContactInfo } from './bean/RichContactInfo';
import { ContactReturnObj, FindPhotoByIdActionData, GroupParams } from './type';
import { PhoneNumBean } from './bean/PhoneNumBean';
import { EmailBean } from './bean/EmailBean';
import { AIMBean } from './bean/AIMBean';
import { HouseBean } from './bean/HouseBean';
import { EventBean } from './bean/EventBean';
import { AssociatedPersonBean } from './bean/AssociatedPersonBean';
import ContactUsuallyListItem, {
  ContactUsuallyListItemHasPhones
} from '../../../../../feature/contact/src/main/ets/repo/ContactUsuallyListItem';
import Contact from '../../../../../feature/contact/src/main/ets/entity/Contact';
import GroupMemberItem from '../../../../../feature/contact/src/main/ets/repo/GroupMemberItem';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from './type/LooseObject';
import ArrayList from '@ohos.util.ArrayList';
import { GroupBean, IntelligenceGroupInfo } from './bean/GroupBean';
import { AccountVo } from './bean/AccountVo';
import HashMap from '@ohos.util.HashMap';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { ObjectUtil } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ObjectUtil';

import MeeTimeDeviceInfoModel from '../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel';
import HashSet from '@ohos.util.HashSet';
import GroupListItem from '../../../../../feature/contact/src/main/ets/repo/GroupListItem';
import { sharedPreferencesUtils } from '../../../../../common';
import taskpool from '@ohos.taskpool';
import DotUtil from '../util/DotUtil';
import dotCommon, { faultContactParams } from '../util/DotCommon';
import RecentDeleteBean from './bean/RecentDeleteBean';
import RecentDeleteListItem from '../../../../../feature/contact/src/main/ets/repo/RecentDeleteListItem';
import { RoamingUtils } from '../../../../../common/src/main/ets/util/RoamingUtils';
import { AuditLogUtils, UtilAuditLog } from '../../../../../common/src/main/ets/util/AuditLogUtils';
import { JSON } from '@kit.ArkTS';
import { contact } from '@kit.ContactsKit';
import { ContactInfoUtil } from '../util/ContactInfoUtil';
import { getHeadChar } from '../util/UserPhoto';
import { RingtoneItem, RingtoneSelectionUtil } from '../util/RingtoneSelectionUtil';
import { systemSoundManager } from '@kit.AudioKit';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../data/EmitterConstant';
import fs from '@ohos.file.fs';
import GroupIdUtil from '../util/GroupIdUtil';
import { SearchContactResult } from './bean/SearchContactResult';
import { DbSearchPhoneNumberObj } from './bean/DbSearchPhoneNumberObj';
import TextUtils from '../../../../../common/src/main/ets/util/TextUtils';
import SearchUtils from '../../../../../common/src/main/ets/util/SearchUtils';
import { LogAccount } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';

const TAG = 'ContactAbility: ';
const PROFILE_CONTACT_DATA_URI = 'datashare:///com.ohos.contactsdataability/profile/contact_data';
// SQLITE_MAX_DEEP
const SQLITE_MAX_DEEP = 998;
// DATASHARE_MAX_SIZE
const DATASHARE_MAX_SIZE = 819200;

// 默认号码标记
export const PRIMARY_FLAG = '1';

// 非默认号码的标记
export const NOT_PRIMARY_FLAG = '0';

const numberRegExp: RegExp = new RegExp('\\d', 'g');

// hasOrganization
let hasOrganization = true;
let hasNickName = true;
let emailList: ArrayList<string> = new ArrayList;
let logUtils: AuditLogUtils = AuditLogUtils.getInstance();

class ContactAbilityModel {
  public str: string = '';
  public result_dt: boolean = true;

  /*
   * */
  getContext(context?: common.UIAbilityContext | Context): common.UIAbilityContext | Context {
    return context ? context : ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
  }

  /**
   * Add Contact
   * @param {Object} addParams Contact Information,
   * it is not a realy instance of class ContactInfo ,it not has the function of ContactInfo
   * @param {Object} callBack
   */
  async addContact(addParams: ContactInfo, callBack: Function,
    isMyCard: boolean = false, context?: common.UIAbilityContext, log?: UtilAuditLog) {
    HiLog.w(TAG, 'addContact, Start to create a new contact.');
    if (addParams == undefined || addParams == null) {
      HiLog.e(TAG, 'addContact, The addParams of parameter is NULL');
      return;
    }
    let daHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();

    let contactInfoInstance = ContactInfo.buildFromParameters(addParams); // there is not method in addParams
    // 根据指定规则获取名称
    const displayName = this.getDisplayName(contactInfoInstance);
    if (StringUtil.isEmpty(displayName)) {
      HiLog.w(TAG, 'addContact, display_name is empty!');
    }
    let insertValues: Record<string, string | number> = {
      'display_name': displayName,
    };
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (accountId != undefined && accountId != -1) {
      insertValues.account_id = accountId;
    }
    if (isMyCard) {
      insertValues.primary_contact = '1';
    }
    daHelper.insert(
      RawContacts.CONTENT_URI,
      insertValues
    ).then(async (rowContactID: number) => {
      HiLog.w(TAG, 'addContact, insert success.');
      if (log) {
        let strAccountId: string = '-1'
        ContactRepository.getInstance().FindCurrentAccount([rowContactID.toString()], (data: LogAccount[]) => {
          if (data.length > 0 && data[0].primary !== '1') {
            strAccountId = data[0].accountId
            log.affectedAccount = strAccountId
            log.contactId = data[0].contactId
            logUtils.writeAuditEvent(log);
          }
        }, 'addContact');


      }

      if (rowContactID == -1 || rowContactID == undefined) {
        HiLog.e(TAG, 'addContact, Data inserted failed');
        return;
      }
      // 提前查询一下contactId，可以和处理data信息并发；避免后续需要contactId时，需要同步等待查询contactId
      let findIdFeature = ContactRepository.getInstance().findIdByRawIdAsync(rowContactID);
      contactInfoInstance.contactID = rowContactID.toString(); // 本地新建的联系人 contactID == rowContactID
      contactInfoInstance.rowContactID = rowContactID.toString();
      let dealFlag: boolean = await this.dealParam(daHelper, contactInfoInstance, false);
      let contactIdArr = await findIdFeature;
      if (dealFlag) {
        if (contactIdArr.length > 0) {
          this.updateRingToneToContact(false, contactIdArr[0],
            contactInfoInstance.personalRingtone,
            contactInfoInstance.personalNotificationRingtone, '', contactInfoInstance.personalRingtonePath);
          callBack([contactInfoInstance.contactID, contactIdArr[0]]);
        } else {
          callBack([contactInfoInstance.contactID]);
        }
      } else {
        callBack([]);
      }
    }).catch((error: BusinessError) => {
      // 联系人故障打点-保存手机联系人失败
      faultContactParams.FAULT_INFO = error.message;
      DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_CONTACTS_FAIL);
      HiLog.e(TAG, 'addContact, logMessage insert error: ' + error?.message);
      callBack([]);
    });
    HiLog.w(TAG, 'addContact, End of creating a contact.');
    emitter.emit({ eventId: EmitterConstant.CONTACT_LIST_CACHE_UPDATE });
  }

  async updateRingToneToContact(isUpdateContact: boolean, contactId: string, personalRingtone: string,
    personalNotificationRingtone: string, contactBeforePersonalRingtone: string, personalRingtonePath: string) {
    if (StringUtil.isEmpty(contactId)) {
      HiLog.e(TAG, 'contact is not existed ');
    }
    try {
      HiLog.w(TAG, `updateRingToneToContact`);
      this.saveRingToneToContact(contactId, personalRingtone, personalNotificationRingtone, personalRingtonePath,
        async (result: boolean) => {
          HiLog.w(TAG, 'updateRingToneToContact: ' + result);
          if (isUpdateContact) {
            this.removeContactLocalRingtone(contactId,
              contactBeforePersonalRingtone,
              personalRingtone);
          }
        });
    } catch (error) {
      HiLog.e(TAG, 'updateRingToneToContact error: ' + error?.code + ', message: ' + error?.message);
      return;
    }
  }

  async removeContactLocalRingtone(id: string, originalContactRingtoneInfo: string, personalRingtone: string) {
    HiLog.i(TAG, `removeContactLocalRingtone ${originalContactRingtoneInfo}`);
    let ringtoneResult: RingtoneItem | undefined =
      await RingtoneSelectionUtil.findRingtoneFromList(originalContactRingtoneInfo);
    if ((ringtoneResult && !StringUtil.isEmpty(ringtoneResult.path)) ||
    StringUtil.isEmpty(originalContactRingtoneInfo) || originalContactRingtoneInfo === '-1') {
      HiLog.w(TAG, `originalContactRingtoneInfo is not localMusic`);
      return;
    }
    if (originalContactRingtoneInfo === personalRingtone) {
      HiLog.w(TAG, `originalContactRingtoneInfo is not change`);
      return;
    }

    try {

      // 代码可能还有用，请不要删除
      // 当前铃音库已经处理多联系人对应同一本地音乐场景，即每一个联系人的本地音乐铃声URI都是独一无二的
      // 联系人暂不用处理数据库中相同铃音URI的数量大于一时调用removeCustomizedTone接口
      this.queryLocalRingToneUsedTimes(id, originalContactRingtoneInfo, async (result: number) => {
        HiLog.w(TAG, 'removeContactLocalRingtone, queryLocalRingToneUsedTimes succ: ' + result);
        if (result < 1) {
          systemSoundManager.getSystemSoundManager()
            .removeCustomizedTone(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              originalContactRingtoneInfo);
        }
      });
    } catch (error) {
      HiLog.e(TAG, 'queryLocalRingToneUsedTimes error: ' + error?.code + ', message: ' + error?.message);
      return;
    }
  }

  /**
   * Read the name, which needs to be optimized.
   * Edit Contact
   *
   * @param {Object} addParams Contact Information
   * @return {string} Contact Name
   */
  getDisplayName(contactInfoInstance: ContactInfo): string {
    let displayName = contactInfoInstance.getDisplayNameByRule();
    return displayName;
  }

  /**
   * Convert the data to the database.
   *
   * @param {string} daHelper Database path
   * @param {Object} addParams Contact Information
   * @param {boolean} isCard Indicates whether the information is a business card.
   */
  async dealParam(daHelper: DataShareHelper.DataShareHelper, addParams: ContactInfo,
    isCard: boolean): Promise<boolean> {
    HiLog.w(TAG, 'dealParam start.');
    if (addParams == undefined || addParams == null || daHelper == undefined || daHelper == null) {
      HiLog.e(TAG, 'dealParam, The addParams or daHelper is NULL');
      return false;
    }
    let result = addParams.rowContactID;
    let uri = isCard ? PROFILE_CONTACT_DATA_URI : Data.CONTENT_URI;

    let contactDataArr: LooseObject[] = [];
    const dataContactData = this.dataContact(addParams, daHelper, result, uri);
    if (dataContactData !== undefined) {
      contactDataArr.push(dataContactData);
    }
    const orgData = this.organizationContact(addParams, daHelper, result, uri);
    if (orgData !== undefined) {
      contactDataArr.push(orgData);
    }
    const noteData = this.noteContact(addParams, daHelper, result, uri);
    if (noteData !== undefined) {
      contactDataArr.push(noteData);
    }
    const phoneDataArr = this.phoneContact(addParams, daHelper, result, uri);
    if (phoneDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(phoneDataArr);
    }
    const emailDataArr = this.emailContact(addParams, daHelper, result, uri);
    if (emailDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(emailDataArr);
    }
    const postalDataArr = this.postalContact(addParams, daHelper, result, uri);
    if (postalDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(postalDataArr);
    }
    const eventDataArr = this.eventContact(addParams, daHelper, result, uri);
    if (eventDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(eventDataArr);
    }
    const imDataArr = this.imContact(addParams, daHelper, result, uri);
    if (imDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(imDataArr);
    }
    const groupDataArr = this.groupsContact(addParams, daHelper, result, uri);
    if (groupDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(groupDataArr);
    }
    const websiteDataArr = this.websiteContact(addParams, daHelper, result, uri);
    if (websiteDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(websiteDataArr);
    }
    const nickData = this.nickContact(addParams, daHelper, result, uri);
    if (nickData !== undefined) {
      contactDataArr.push(nickData);
    }
    const relationDataArr = this.relationsContact(addParams, daHelper, result, uri);
    if (relationDataArr !== undefined) {
      contactDataArr = contactDataArr.concat(relationDataArr);
    }
    const photoData = this.photoContact(addParams, daHelper, result, uri);
    if (photoData !== undefined) {
      contactDataArr.push(photoData);
    }
    let batchInsertFlag: number = await daHelper.batchInsert(uri, contactDataArr);
    HiLog.w(TAG, 'batchInsert result :' + batchInsertFlag + ' contactID == ' + addParams.contactID);
    return this.isDbOperateSuccess(batchInsertFlag);
  }

  /**
   * Save the contact name to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {string} result Contact ID
   * @param {string} uri Database address
   */
  dataContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    let displayName = '';
    let updateFlag = 0;
    if (addParams.display_name != undefined && addParams.display_name.length > 0) {
      displayName = addParams.display_name;
    } else {
      // 按规则从其他信息获得的联系人名称
      updateFlag = 1;
      displayName = this.getDisplayName(addParams);
    }

    HiLog.w(TAG, 'dataContact, displayName size is ' + displayName.length);
    if (displayName.length > 0) {
      let dataContact: Record<string, number | string> = {
        'raw_contact_id': result,
        'detail_info': displayName,
        'alpha_name': displayName,
        'phonetic_name': addParams.phoneticName,
        'other_lan_last_name': addParams.otherLanLastName,
        'other_lan_first_name': addParams.otherLanFirstName,
        'type_id': 6,
        // 对于名称信息为空，从其他方案获得的，设置extend7标志？
        'extend7': updateFlag
      };
      return dataContact;
    } else {
      HiLog.w(TAG, 'skip insert displayName');
      return undefined;
    }
  }

  /**
   * Save the contact nickname information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  nickContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    if (addParams.nickname != undefined && addParams.nickname.length > 0) {
      let nickContact: Record<string, string | number> = {
        'raw_contact_id': result,
        'detail_info': addParams.nickname,
        'type_id': 3,
      };
      return nickContact;
    } else {
      HiLog.w(TAG, 'skip insert nick');
      return undefined;
    }
  }

  /**
   * Save the position information of the contact company to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {string} result Contact ID
   * @param {string} uri Database address
   */
  organizationContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    let company = '';
    let position = '';
    if (addParams.company != undefined && addParams.company.length > 0) {
      company = addParams.company.trim();
    }
    if (addParams.position != undefined && addParams.position.length > 0) {
      position = addParams.position.trim();
    }
    if (addParams.company != undefined && addParams.company.length > 0 ||
      addParams.position != undefined && addParams.position.length > 0) {
      let organizationContact: Record<string, string | number> = {
        'raw_contact_id': result,
        'detail_info': company,
        'position': position,
        'type_id': 4,
      };
      return organizationContact;
    } else {
      HiLog.w(TAG, 'skip insert org');
      return undefined;
    }
  }

  /**
   * Save the contact remarks to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  noteContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    if (addParams.remarks != undefined && addParams.remarks.length > 0) {
      let noteContact: Record<string, number | string> = {
        'raw_contact_id': result,
        'detail_info': addParams.remarks,
        'type_id': 10,
      };
      return noteContact;
    } else {
      HiLog.w(TAG, 'skip insert note');
      return undefined;
    }
  }

  /**
   * The contact mobile number information is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  phoneContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'phoneContact, add phones size is ' + addParams.phones.length);
    if (addParams.phones != undefined && addParams.phones.length > 0) {
      let index = 1;
      const phoneDataArr: LooseObject [] = [];
      addParams.phones.forEach((element, index) => {
        if (StringUtil.isEmpty(element.num)) {
          return;
        }
        HiLog.w(TAG, `phoneContact, index: ${index}, add phoneNumber size is ${element.num.length}`);
        let phoneContact: Record<string, string | number | undefined> = {
          'raw_contact_id': result,
          'detail_info': element.num,
          'extend7': element.selectTextCustom,
          'custom_data': element.numType,
          'type_id': 5,
          'extend5': element.primary == true ? PRIMARY_FLAG : NOT_PRIMARY_FLAG,
        };
        phoneDataArr.push(phoneContact);
      });
      return phoneDataArr;
    } else {
      HiLog.w(TAG, 'skip insert phone');
      return undefined;
    }
  }

  /**
   * Save the contact email information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  emailContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'emailContact, add emails size is ' + addParams.emails.length);
    if (addParams.emails != undefined && addParams.emails.length > 0) {
      let index = 1;
      const emailDataArr: LooseObject [] = [];
      addParams.emails.forEach(element => {
        if (StringUtil.isEmpty(element.address)) {
          return;
        }
        let emailContact: Record<string, string | number | undefined> = {
          'raw_contact_id': result,
          'detail_info': element.address,
          'extend7': element.selectTextCustom,
          'custom_data': element.emailType,
          'type_id': 1,
        };
        emailDataArr.push(emailContact);
      });
      return emailDataArr;
    } else {
      HiLog.w(TAG, 'skip insert email');
      return undefined;
    }
  }

  /**
   * The contact address information is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  postalContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'postalContact, add houses size is ' + addParams.houses.length);
    if (addParams.houses != undefined && addParams.houses.length > 0) {
      let index = 1;
      const houseDataArr: LooseObject [] = [];
      addParams.houses.forEach(element => {
        if (StringUtil.isEmpty(element.houseName)) {
          return;
        }
        let postalContact: Record<string, string | number | undefined> = {
          'raw_contact_id': result,
          'detail_info': element.houseName,
          'extend7': element.selectTextCustom,
          'custom_data': element.houseType,
          'type_id': 7,
        };
        houseDataArr.push(postalContact);
      });
      return houseDataArr;
    } else {
      HiLog.w(TAG, 'skip insert house');
      return undefined;
    }
  }

  /**
   * Save the contact special date information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  eventContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'eventContact, add events size is ' + addParams.events.length);
    if (addParams.events != undefined && addParams.events.length > 0) {
      let index = 1;
      const eventDataArr: LooseObject [] = [];
      addParams.events.forEach(element => {
        if (StringUtil.isEmpty(element.data)) {
          return;
        }
        let eventContact: Record<string, string | number> = {
          'raw_contact_id': result,
          'detail_info': element.data,
          'custom_data': element.eventType,
          'type_id': 11,
          'calendar_event_id': element.calendarEventId === undefined ? '' : element.calendarEventId,
        };
        eventDataArr.push(eventContact);
      });
      return eventDataArr;
    } else {
      HiLog.w(TAG, 'skip insert event');
      return undefined;
    }
  }

  /**
   * Save the contact IMA information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  imContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'imContact, add aims size is ' + addParams.aims.length);
    if (addParams.aims != undefined && addParams.aims.length > 0) {
      const imDataArr: LooseObject [] = [];
      addParams.aims.forEach(element => {
        if (StringUtil.isEmpty(element.aimName)) {
          return;
        }
        let imContact: Record<string, number | string | undefined> = {
          'raw_contact_id': result,
          'detail_info': element.aimName,
          'extend7': element.selectTextCustom,
          'custom_data': element.aimType,
          'type_id': 2,
        };
        imDataArr.push(imContact);
      });
      return imDataArr;
    } else {
      HiLog.w(TAG, 'skip insert im');
      return undefined;
    }
  }

  /**
   * Save the contact group information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  groupsContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'groupsContact, add groups size is ' + addParams.groups.length);
    if (!ArrayUtil.isEmpty(addParams.groups)) {
      const groupDataArr: LooseObject [] = [];
      addParams.groups.forEach(element => {
        if (!StringUtil.isEmpty(element.groupName)) {
          let groupsContact: Record<string, number | string> = {
            'raw_contact_id': result,
            'detail_info': element.groupName,
            'extend7': element.groupId + '',
            'custom_data': element.groupType,
            'type_id': 9,
          };
          groupDataArr.push(groupsContact);
        }
      });
      return groupDataArr;
    } else {
      HiLog.w(TAG, 'skip insert group');
      return undefined;
    }
  }

  /**
   * Save the contact website information to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  websiteContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'websiteContact, add websites size is ' + addParams.websites.length);
    if (!ArrayUtil.isEmpty(addParams.websites)) {
      const websiteArr: LooseObject [] = [];
      addParams.websites.forEach(element => {
        if (StringUtil.isEmpty(element)) {
          return;
        }
        let websiteContact: Record<string, string | number> = {
          'raw_contact_id': result,
          'detail_info': element,
          'type_id': 12,
        };
        websiteArr.push(websiteContact);
      });
      return websiteArr;
    } else {
      HiLog.w(TAG, 'skip insert website');
      return undefined;
    }
  }

  /**
   * The relation information of the contact is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  relationsContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'relationsContact, add relationships size is ' + addParams.relationships.length);
    if (!ArrayUtil.isEmpty(addParams.relationships)) {
      let index = 1;
      const relationArr: LooseObject [] = [];
      addParams.relationships.forEach(element => {
        if (StringUtil.isEmpty(element.name)) {
          return;
        }
        let relationsContact: Record<string, string | number | undefined> = {
          'raw_contact_id': result,
          'detail_info': element.name,
          'extend7': element.selectTextCustom,
          'custom_data': element.associatedType,
          'type_id': 13
        };
        relationArr.push(relationsContact);
      });
      return relationArr;
    } else {
      HiLog.w(TAG, 'skip insert relation');
      return undefined;
    }
  }

  /**
   * The photo information of the contact is saved to the database.
   *
   * @param {Object} addParams Contact Information
   * @param {string} daHelper Database path
   * @param {number} result Contact ID
   * @param {string} uri Database address
   */
  photoContact(addParams: ContactInfo, daHelper: DataShareHelper.DataShareHelper, result: string, uri: string) {
    HiLog.w(TAG, 'update photo');
    if (addParams.photo !== undefined && addParams.photo !== null) {
      let photoContact: Record<string, number | string | Uint8Array> = {
        'raw_contact_id': result,
        'blob_data': addParams.photo,
        'type_id': 8,
        'blob_source': 3
      };
      return photoContact;
    } else {
      HiLog.w(TAG, 'skip photoContact-insert');
      return undefined;
    }
  }

  /**
   * Querying All Accounts
   * @param callBack
   */
  async getAllAccount(callBack: Function) {
    HiLog.i(TAG, 'Start to query all account');
    ContactRepository.getInstance().findAllAcount((accountList: AccountVo[]) => {
      if (ArrayUtil.isEmpty(accountList)) {
        HiLog.i(TAG, 'getAllAcount resultSet is empty!');
        let emptyResult: AccountVo[] = [];
        callBack(emptyResult);
        return;
      }
      callBack(accountList);
      HiLog.i(TAG, 'End of querying all accounts');
    });
  }

  /**
   * Querying the Mobile Numbers of All Contacts
   *
   * @param {string} daHelper
   * @param {Object} callBack
   */
  async getAllContact(actionData: AllContactGetParam, callBack: Function, findMyCard: boolean = false) {
    HiLog.i(TAG, 'Start to query all contacts without PhoneNumbers');
    ContactRepository.getInstance().findAll(actionData, (resultSet?: DataShareResultSet) => {
      if (resultSet === undefined) {
        HiLog.i(TAG, 'queryContacts-SelectcontactsModel queryContact resultSet is empty!');
        let emptyResult: ContactVo[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: ContactVo[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
          let portraitColor = MorandiColor.color[Math.abs(id) % 6];
          let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
          jsonObj.contactId = id.toString();
          jsonObj.nameRawContactId =
            resultSet.getLong(resultSet.getColumnIndex(Contacts.NAME_RAW_CONTACT_ID)).toString();
          jsonObj.emptyNameData = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
          // 联系人列表页，生成二级索引需要
          jsonObj.displayName = jsonObj.emptyNameData;
          jsonObj.namePrefix = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
          jsonObj.nameSuffix = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
          jsonObj.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
          jsonObj.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
          jsonObj.sort = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT));
          jsonObj.sortKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_KEY));
          jsonObj.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
          // 联系人实际获取的sort为空，此操作为了解决联系人列表页排序紊乱问题，使用NamePrefix字段联系人名称首字母来进行排序
          jsonObj.sort = jsonObj.namePrefix
          jsonObj.show = false;
          jsonObj.setShowName();
          jsonObj.setHeadChar();
          resultList.push(jsonObj);
        } while (resultSet.goToNextRow());
      }
      callBack(resultList);
      HiLog.i(TAG, 'End of querying all contacts');
    }, findMyCard);
  }

  async getMyCard(callBack: Function) {
    HiLog.i(TAG, 'Start to getMyCard');

    let param: AllContactGetParam = new AllContactGetParam(0, 0);
    const findMyCard = true;
    this.getAllContact(param, (result: ContactVo[]) => {
      callBack?.(result);
    }, findMyCard)
  }

  getContactSize(accountId: ValueType, callback: Function) {
    ContactRepository.getInstance().getContactSize(accountId, callback);
  }

  getAllContactSize(callback: (result: CountAlphabetIndex) => void, hasMyCard: boolean = true) {
    ContactRepository.getInstance().getAllContactSize(callback, hasMyCard);
  }

  async getAllContactSizeSync(userId: number, hasMyCard: boolean = true): Promise<CountAlphabetIndex> {
    return ContactRepository.getInstance().getAllContactSizeSync(userId, hasMyCard);
  }

  getAllRawContactSize(callback: (result: CountRawContact) => void) {
    ContactRepository.getInstance().getAllRawContactSize(callback);
  }

  getAllContactSizeAndIndex(callback: (result: CountAlphabetIndex) => void) {
    ContactRepository.getInstance()
      .getAllContactSizeAndIndex((jsonObj: NameFixInfo, index: number,
        alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
        try {
          this.addAlphabetIndexObj(jsonObj, index, alphabetIndex, isEnd);
        } catch (e) {
          HiLog.e(TAG, 'addAlphabetIndexObj err :' + (e as BusinessError).message);
        }
      }, callback);
  }

  getAllFavoriteSizeAndIndex(callback: (result: CountAlphabetIndex) => void) {
    ContactRepository.getInstance()
      .getAllFavoriteSizeAndIndex((jsonObj: NameFixInfo, index: number,
        alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
        try {
          this.addAlphabetIndexObj(jsonObj, index, alphabetIndex, isEnd);
        } catch (e) {
          HiLog.e(TAG, 'addAlphabetIndexObj err :' + (e as BusinessError).message);
        }
      }, callback);
  }

  /**
   * 二级索引字母和汉字对应关系
   * @param jsonObj
   * @param index
   * @param alphabetIndex
   * @param isEnd
   */
  addAlphabetIndexObj(jsonObj: NameFixInfo | ContactVo | ContactPickerListItem, index: number,
    alphabetIndex: Record<string, AlphabetIndexObj>, isEnd?: boolean) {
    // 排序首字母对应的二级索引对象
    let alphabetIndexObj: AlphabetIndexObj;
    // 排序首字母对应的二级索引对象已经存在，修改存在的
    if (alphabetIndex[jsonObj.namePrefix]) {
      alphabetIndexObj = alphabetIndex[jsonObj.namePrefix];
    } else {
      // 排序首字母对应的二级索引对象不存在，新建
      alphabetIndexObj = {
        enPrefix: new CharIndex(jsonObj.nameSuffix, index, index),
        zhPrefix: []
      };
    }
    alphabetIndexObj.enPrefix.end = index;
    // PHOTO_FIRST_NAME 对应的首字符，是中文
    // 存在异常情况：如果displayName是“men大姐夫”  会给PHOTO_FIRST_NAME存成“大”，然后导致二级索引会显示“大”，参照双框架的话，实际上这种应该没有二级索引
    // 新增判断逻辑，PHOTO_FIRST_NAME首字母和displayName首字母相同，才加入二级索引
    let nameSuffixFirstChar = jsonObj.nameSuffix.charCodeAt(0);
    if (nameSuffixFirstChar == jsonObj.displayName.charCodeAt(0) && nameSuffixFirstChar > CHINESE_CHAR_CODE) {
      let cn_char: CharIndex;
      // 上个中文
      let last_cn: CharIndex | undefined = undefined;
      if (alphabetIndexObj.zhPrefix.length > 0) {
        last_cn = alphabetIndexObj.zhPrefix[alphabetIndexObj.zhPrefix.length - 1];
      }
      // 上个中文没有，即当前为第一个；或上个中文和当前的不相等；将当前汉字加入二级索引
      if (last_cn === undefined || last_cn.char !== jsonObj.nameSuffix) {
        cn_char = new CharIndex(jsonObj.nameSuffix, index, index);
        alphabetIndexObj.zhPrefix.push(cn_char);
      } else {
        cn_char = last_cn;
      }
      cn_char.end = index;
    }
    alphabetIndex[jsonObj.namePrefix] = alphabetIndexObj;
  }

  /**
   * 查询所有联系人手机号
   *
   * @param {string} daHelper 数据库地址
   * @param {Object} callBack 回调
   * @param {Object} addParams  Contact Information
   */
  getAllContactWithPhoneNumbers(callBack: Function,
    addParams: AllContactWithPhoneNumbersGetParam, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'Start to query all contacts with PhoneNumbers');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance()
      .findByPhoneIsNotNull(addParams, (contactList: ContactListItem[]) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: IContactListAndAlphabetIndex = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (ArrayUtil.isEmpty(contactList)) {
          HiLog.i(TAG, 'getAllContactWithPhoneNumbers-SelectcontactsModel queryContact resultSet is empty!');
          callBack(callBackData);
          return;
        }

        contactList.forEach((contactItem, index: number) => {
          let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.emptyNameData = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.displayName = contactItem.displayName;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.company = contactItem.company;
          jsonObj.position = contactItem.position;
          jsonObj.extra3 = contactItem.extra3;
          jsonObj.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(jsonObj.contactId)) % 6];
          jsonObj.show = false;
          jsonObj.phoneNumbers = contactItem.phoneNumbers;
          // 设置显示的名字
          jsonObj.setShowName();
          // 设置头像文字
          jsonObj.setHeadChar();
          jsonObj.nameRawContactId = contactItem.nameRawContactId.toString();
          jsonObj.favorite = contactItem.favorite;
          jsonObj.quickSearchKey = contactItem.quickSearchKey;

          resultList.push(jsonObj);
          // 添加二级索引相关
          this.addAlphabetIndexObj(jsonObj, index, alphabetIndex, index === contactList.length - 1);
        });
        callBack(callBackData);
        HiLog.i(TAG, 'End of querying all contacts');
      });
  }

  /**
   * 查询picker 联系人
   *
   * @param {string} daHelper 数据库地址
   * @param {Object} callBack 回调
   * @param {Object} addParams  Contact Information
   */
  getPickerContacts(isDisplayByName: boolean, contactSelectionFilter: contact.ContactSelectionFilter, userId: number,
    page: number, isFavorite: boolean, isOnePageShow: boolean,
    callBack: (result: PickerContactList) => void, context?: common.UIAbilityContext) {
    HiLog.w(TAG, `getPickerContacts start, page: ${page}`);
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().getDesignatedPickerContacts(
      isDisplayByName,
      contactSelectionFilter?.filterClause,
      contactSelectionFilter?.filterType,
      userId,
      page,
      isFavorite,
      isOnePageShow,
      (contactList: ContactListItem[], defaultSelectContactMap: Map<number, Set<string>>, isEnd: boolean) => {

        HiLog.w(TAG, `getDesignatedPickerContacts success, isEnd: ${isEnd}, contactList size: ${contactList.length
        }, defaultSelectContactMap size: ${defaultSelectContactMap.size}`);
        let resultList: ContactPickerListItem[] = [];
        let callBackData: PickerContactList = {
          contactList: resultList,
          defaultSelectContactMap: defaultSelectContactMap,
          isEnd: isEnd
        };

        contactList.forEach((contactItem) => {
          if (contactItem.pickerShowSubDatas.length <= 0) {
            contactItem.pickerShowSubDatas.push({ dataId: 0, keyValue: '', showValue: '' });
          }
          contactItem.pickerShowSubDatas.forEach((pickerShowSubData, index) => {
            let contactPickerListItem: ContactPickerListItem = {
              contactId: contactItem.id,
              displayName: contactItem.displayName,
              pickerShowSubData: pickerShowSubData,
              isFavorite: contactItem.favorite === '1',
              headChar: getHeadChar(contactItem.displayName),
              nameSuffix: contactItem.photoFirstName,
              namePrefix: contactItem.sortFirstLetter,
              favoriteOrder: contactItem.favoriteOrder,
              isFirst: index === 0
            }
            resultList.push(contactPickerListItem);
          })
        });
        HiLog.w(TAG, 'getPickerContacts end');
        callBack(callBackData);
      });
  }

  /**
   * 查询picker 联系人----同步
   */
  async getPickerContactsSync(isDisplayByName: boolean,
    contactSelectionFilter: contact.ContactSelectionFilter | undefined, userId: number, page: number,
    isFavorite: boolean, isOnePageShow: boolean, context?: common.UIAbilityContext): Promise<PickerContactList> {
    HiLog.w(TAG, `getPickerContactsSync start, page: ${page}`);
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    let resultList: ContactPickerListItem[] = [];
    let callBackData: PickerContactList = {
      contactList: resultList,
      defaultSelectContactMap: new Map(),
      isEnd: false
    };
    await ContactRepository.getInstance().getDesignatedPickerContacts(
      isDisplayByName,
      contactSelectionFilter?.filterClause,
      contactSelectionFilter?.filterType,
      userId,
      page,
      isFavorite,
      isOnePageShow,
      (contactList: ContactListItem[], defaultSelectContactMap: Map<number, Set<string>>, isEnd: boolean) => {
        HiLog.w(TAG, `getPickerContactsSync getPickerContactsSync success, isEnd: ${isEnd}, contactList size:
          ${contactList.length}, defaultSelectContactMap size: ${defaultSelectContactMap.size}`);
        contactList.forEach((contactItem) => {
          if (contactItem.pickerShowSubDatas.length <= 0) {
            contactItem.pickerShowSubDatas.push({ dataId: 0, keyValue: '', showValue: '' });
          }
          contactItem.pickerShowSubDatas.forEach((pickerShowSubData, index) => {
            let contactPickerListItem: ContactPickerListItem = {
              contactId: contactItem.id,
              displayName: contactItem.displayName,
              pickerShowSubData: pickerShowSubData,
              isFavorite: contactItem.favorite === '1',
              headChar: getHeadChar(contactItem.displayName),
              nameSuffix: contactItem.photoFirstName,
              namePrefix: contactItem.sortFirstLetter,
              favoriteOrder: contactItem.favoriteOrder,
              isFirst: index === 0
            }
            resultList.push(contactPickerListItem);
          })
        });
        callBackData.contactList = resultList;
        callBackData.defaultSelectContactMap = defaultSelectContactMap;
        callBackData.isEnd = isEnd;
        HiLog.w(TAG, 'getPickerContactsSync end');
      });
    return callBackData;
  }

  /**
   * 保存联系人铃声
   *
   * @param {string} id 联系人id
   * @param {string} uri 铃声uri
   * @param {string} ringToneName 铃声
   * @param {Object} callBack 回调
   */
  async saveRingToneToContact(id: string, uri: string, ringToneName: string,
    ringToneFilePath: string, callBack: (result: boolean) => void) {
    HiLog.w(TAG, `saveRingToneToContact start`);
    await ContactRepository.getInstance().saveRingToneToContact(id, uri, ringToneName, ringToneFilePath, callBack)
  }

  /**
   * 查询使用本地铃音的联系人数量
   *
   * @param {string} id 联系人id
   * @param {string} uri 铃声uri
   * @param {Object} callBack 回调
   */
  async queryLocalRingToneUsedTimes(id: string, uri: string, callBack: (result: number) => void) {
    HiLog.w(TAG, `queryLocalRingToneUsedTimes start, uri: ${uri}`);
    await ContactRepository.getInstance()
      .queryLocalRingToneUsedTimes(id, uri, callBack)
  }

  findNewestContact(callback: Function, context?: common.UIAbilityContext | Context) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findNewestContact(callback);
  }

  markContactAsPoster(contactIds: string[], callback: Function, context?: common.UIAbilityContext | Context) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().markContactAsPoster(contactIds, callback);

  }

  /**
   * Obtain contact details.
   *
   * @param {Object} contactId Contact data ID.
   * @param {Object} callback Contact details
   */
  getContactById(contactId: number, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query contact by id :' + contactId);
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findById(contactId, (contact: Contact) => {
      const res: ContactReturnObj = new ContactReturnObj();
      if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
        HiLog.e(TAG, 'Query contact by id failed.');
        callBack(res);
        return;
      }

      const contactDetailInfo: RichContactInfo = new RichContactInfo('');

      // 设置畅连能力
      for (let rawContact of contact.rowContacts) {
        if (rawContact.meeTimeAbilityInfoModel && rawContact.meeTimeAbilityInfoModel.extra4 > 0) {
          contactDetailInfo.meeTimeAbilityInfoModel = rawContact.meeTimeAbilityInfoModel;
          break;
        }
      }
      // 智能合并的联系人，合并内容
      this.aggregateRawContactToContact(contact.rowContacts, contactDetailInfo);
      this.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);

      contactDetailInfo.contactID = contact.id.toString();
      contactDetailInfo.rowContactID = contact.rowContacts[0].id.toString();
      contactDetailInfo.meeTimeAbilityInfoModel.contactId = Number.parseInt(contactDetailInfo.contactID);
      contactDetailInfo.photoFirstName = contact.rowContacts[0].values.get(RawContacts.PHOTO_FIRST_NAME) as string;
      contactDetailInfo.accountId = contact.rowContacts[0].values.get(RawContacts.ACCOUNT_ID) as number;
      // 新增 联系人原始信息
      contactDetailInfo.rawContacts = contact.rowContacts;
      contactDetailInfo.personalRingtone = contact.personalRingtone;
      contactDetailInfo.personalRingtonePath = contact.personalRingtonePath;
      contactDetailInfo.personalNotificationRingtone = contact.personalNotificationRingtone;
      res.data = contactDetailInfo;
      callBack(res);
      HiLog.w(TAG,
        'End of querying contacts by ID.' + contactDetailInfo.contactID + '----' +
        this.getRawIdsFromContactInfo(contactDetailInfo));
    });
  }

  /**
   * Obtain contact details.
   *
   * @param {Object} contactId Contact data ID.
   * @param {Object} callback Contact details
   */
  async getContactByIdSync(contactId: number, context?: common.UIAbilityContext | Context): Promise<ContactReturnObj> {
    HiLog.i(TAG, 'Start to query contact by id :' + contactId);
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    let contact = await ContactRepository.getInstance().findByIdSync(contactId);
    const res: ContactReturnObj = new ContactReturnObj();
    if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
      HiLog.e(TAG, 'Query contact by id failed.');
      return res;
    }

    const contactDetailInfo: RichContactInfo = new RichContactInfo('');
    // 设置畅连能力
    for (let rawContact of contact.rowContacts) {
      if (rawContact.meeTimeAbilityInfoModel && rawContact.meeTimeAbilityInfoModel.extra4 > 0) {
        contactDetailInfo.meeTimeAbilityInfoModel = rawContact.meeTimeAbilityInfoModel;
        break;
      }
    }
    // 智能合并的联系人，合并内容
    this.aggregateRawContactToContact(contact.rowContacts, contactDetailInfo);
    this.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);

    contactDetailInfo.contactID = contact.id.toString();
    contactDetailInfo.rowContactID = contact.rowContacts[0].id.toString();
    contactDetailInfo.meeTimeAbilityInfoModel.contactId = Number.parseInt(contactDetailInfo.contactID);
    contactDetailInfo.photoFirstName = contact.rowContacts[0].values.get(RawContacts.PHOTO_FIRST_NAME) as string;
    let firstName = contact.rowContacts[0]?.values?.get(RawContacts.PHOTO_FIRST_NAME);
    contactDetailInfo.photoFirstName = firstName ? firstName as string : '';
    let accountId = contact.rowContacts[0]?.values?.get(RawContacts.ACCOUNT_ID);
    contactDetailInfo.accountId = accountId ? accountId as number : -1;
    // 新增 联系人原始信息
    contactDetailInfo.rawContacts = contact.rowContacts;
    contactDetailInfo.personalRingtone = contact.personalRingtone;
    contactDetailInfo.personalRingtonePath = contact.personalRingtonePath;
    contactDetailInfo.personalNotificationRingtone = contact.personalNotificationRingtone;
    res.data = contactDetailInfo;
    HiLog.w(TAG,
      'End of querying contacts by ID.' + contactDetailInfo.contactID + '----' +
      this.getRawIdsFromContactInfo(contactDetailInfo));
    return res;
  }

  aggregateRawContactToContact(rawContacts: RawContact[], contactDetailInfo: RichContactInfo) {
    HiLog.i(TAG, 'aggregateRawContactToContact,rawContacts len : ' + rawContacts.length);
    for (let dataItem of rawContacts[0].dataItems) {
      // 处理智能合并的 主联系人
      this.dealResult(dataItem, contactDetailInfo);
    }
    if (rawContacts.length == 0) {
      HiLog.i(TAG, 'aggregateRawContactToContact end ,only has one rawContact');
      return;
    }
    for (let index = 1; index < rawContacts.length; index++) {
      let rawContact: RawContact = rawContacts[index];
      // 处理智能合并的 其它联系人
      for (let dataItem of rawContact.dataItems) {
        this.addToMaster(dataItem, contactDetailInfo);
      }
    }
  }

  addToMaster(dataItem: DataItem, contactDetailInfo: RichContactInfo) {
    // 保留收藏状态，不覆盖
    if (contactDetailInfo.favorite == 0) {
      contactDetailInfo.favorite = Number(dataItem.values.get(DataType.FAVORITE));
    }
    try {
      let typeId: number = Number(dataItem.values.get(Data.TYPE_ID));
      let data: string = dataItem.values.get(DataType.DATA) as string;
      let labelId: string = dataItem.values.get(DataType.LABEL_ID) as string;
      let labelName: string = dataItem.values.get(DataType.LABEL_NAME) as string;
      switch (typeId) {
        case DataItemType.NAME:
          contactDetailInfo.display_name = dataItem.values.get(DataType.DATA) as string;
          contactDetailInfo.nameUpdate = dataItem.values.get(DataType.LABEL_ID);
          contactDetailInfo.phoneticName = dataItem.values.get(Data.PHONETIC_NAME) as string;
          HiLog.i(TAG, 'addToMaster, display_name size is ' + contactDetailInfo.display_name.length);
          break;
        case DataItemType.PHONE:
          let isPrimary = dataItem.values.get(DataType.IS_PRIMARY);
          let id = dataItem.values.get(Data.ID);
          const phoneElement: PhoneNumBean = new PhoneNumBean(labelId,
            data, labelName, '', '',
            isPrimary == '1', Number(id));
          phoneElement.setPickerData(data, labelId,
            parseInt(labelName));
          // 标记有畅连能力的手机号
          phoneElement.meeTimeAbilityFlag = dataItem.values.get(Data.EXTEND1) as string;
          phoneElement.formatNum = dataItem.values.get(Data.FORMAT_PHONE_NUMBER) as string;
          // 不重复的电话，添加到电话集合
          if (contactDetailInfo.phones) {
            if (!this.judgeIsMasterHasSamePhoneAndMergeAbilityFlag(contactDetailInfo.phones, phoneElement)) {
              contactDetailInfo.phones.push(phoneElement);
            }
          } else {
            contactDetailInfo.phones = [phoneElement];
          }
          HiLog.i(TAG, 'addToMaster, phoneNumber size is ' + phoneElement.num.length);
          // 打印电话号码中的 非法符号
          const symbol = phoneElement.num.replace(numberRegExp, '');
          const symbolPhoneNumber = phoneElement.num.replace(numberRegExp, '*');
          if (symbol.length > 0) {
            HiLog.i(TAG, `addToMaster, phoneNumber nonnormal symbol size is ${symbol.length}, symbol: '${symbol}', ` +
              `symbolPhoneNumber: '${symbolPhoneNumber}'`);
          }
          break;
        case DataItemType.EMAIL:
          const emailElement: EmailBean = new EmailBean(labelId, data,
            labelName);
          emailElement.setPickerData(data, labelId,
            parseInt(labelName));
          // 不重复的email添加到email集合
          if (contactDetailInfo.emails) {
            if (!this.isMasterHasSameEmails(contactDetailInfo.emails, emailElement)) {
              contactDetailInfo.emails.push(emailElement);
            }
          } else {
            contactDetailInfo.emails = [emailElement];
          }
          break;
        case DataItemType.NOTE:
          if (StringUtil.isEmpty(contactDetailInfo.remarks)) {
            contactDetailInfo.remarks = data;
          }
          break;
        case DataItemType.ORGANIZATION:
          if (StringUtil.isEmpty(contactDetailInfo.company)) {
            contactDetailInfo.company = data;
            let position: string = dataItem.values.get(Data.POSITION) as string;
            if (!StringUtil.isEmpty(position)) {
              contactDetailInfo.position = dataItem.values.get(Data.POSITION) as string;
            }
          }
          break;
        case DataItemType.IM:
          const aimElement: AIMBean = new AIMBean('', labelId, labelName,
            data);
          aimElement.setPickerData(data, labelId,
            parseInt(labelName));
          if (contactDetailInfo.aims) {
            if (!this.isMasterHasSameAims(contactDetailInfo.aims, aimElement)) {
              contactDetailInfo.aims.push(aimElement);
            }
          } else {
            contactDetailInfo.aims = [aimElement];
          }
          break;
        case DataItemType.STRUCTURED_POSTAL:
          const houseElement: HouseBean = new HouseBean('', labelId,
            labelName, data);
          houseElement.setPickerData(data, labelId,
            parseInt(labelName));
          if (contactDetailInfo.houses) {
            if (!this.isMasterHasSameHouses(contactDetailInfo.houses, houseElement)) {
              contactDetailInfo.houses.push(houseElement);
            }
          } else {
            contactDetailInfo.houses = [houseElement];
          }
          break;
        case DataItemType.NICKNAME:
          if (StringUtil.isEmpty(contactDetailInfo.nickname)) {
            contactDetailInfo.nickname = data;
          }
          break;
        case DataItemType.EVENT:
          const eventElement: EventBean = new EventBean(labelId,
            data, labelName, '');
          eventElement.calendarEventId = dataItem.values.get(Data.CALENDAR_EVENT_ID) as string;
          eventElement.contactDataId = dataItem.values.get(Data.ID) as number;
          eventElement.setPickerData(data, labelId,
            parseInt(labelName));
          if (contactDetailInfo.events) {
            if (!this.isMasterHasSameEvents(contactDetailInfo.events, eventElement)) {
              contactDetailInfo.events.push(eventElement);
            }
          } else {
            contactDetailInfo.events = [eventElement];
          }
          break;
        case DataItemType.WEBSITE:
          let websiteElement = data;
          if (contactDetailInfo.websites) {
            if (!this.isMasterHasSameWebsites(contactDetailInfo.websites, websiteElement)) {
              contactDetailInfo.websites.push(websiteElement as string);
            }
          } else {
            contactDetailInfo.websites = [websiteElement as string];
          }
          break;
        case DataItemType.RELATION:
          const relationElement: AssociatedPersonBean = new AssociatedPersonBean(labelId, '',
            data, labelName);
          relationElement.setPickerData(data, labelId,
            parseInt(labelName));
          if (contactDetailInfo.relationships) {
            if (!this.isMasterHasSameRelationships(contactDetailInfo.relationships, relationElement)) {
              contactDetailInfo.relationships.push(relationElement);
            }
          } else {
            contactDetailInfo.relationships = [relationElement];
          }
          break;
        case DataItemType.HI_CALL_DEVICE:
          // 判断不重复的设备信息才加入集合，避免智能合并的联系人，畅连家庭设备，重复显示
          let deviceInfo = new MeeTimeDeviceInfoModel(
            dataItem.values.get(Data.EXTEND4) as string,
            Number.parseInt(dataItem.values.get(Data.EXTEND1) as string),
            dataItem.values.get(Data.EXTEND5) as string
          );
          if (!this.isMasterHasSameDevice(contactDetailInfo.meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr,
            deviceInfo)) {
            contactDetailInfo.meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr.push(deviceInfo);
          }
          break;
        case DataItemType.GROUP_MEMBERSHIP:
          const groupElement: GroupBean = new GroupBean(-1, '', '', '', '', '', 0, 0, '');
          groupElement.setPickerData('', parseInt(data));
          if (contactDetailInfo.groups) {
            if (!this.isMasterHasSameGroups(contactDetailInfo.groups, groupElement)) {
              contactDetailInfo.groups.push(groupElement);
            }
          } else {
            contactDetailInfo.groups = [groupElement];
          }
          break;
      }
    } catch (e) {
      HiLog.e(TAG, 'addToMaster :' + e?.code + ', message: ' + e?.message);
    }
  }

  isMasterHasSameGroups(groups: GroupBean[], groupElement: GroupBean) {
    return groups.some(group => {
      return ContactInfoUtil.isGroupEquals(group, groupElement);
    });
  }

  isMasterHasSameRelationships(relationships: AssociatedPersonBean[], relationElement: AssociatedPersonBean) {
    return relationships.some(relationship => {
      return ContactInfoUtil.isRelationshipEquals(relationship, relationElement);
    });
  }

  isMasterHasSameWebsites(websites: string[], websiteElement: string | number | undefined) {
    return websites.some(website => {
      return website == websiteElement;
    });
  }

  isMasterHasSameDevice(deviceList: MeeTimeDeviceInfoModel[], deviceElement: MeeTimeDeviceInfoModel) {
    return deviceList.some(device => {
      return device.comId == deviceElement.comId && device.deviceType == deviceElement.deviceType;
    });
  }

  isMasterHasSameEvents(events: EventBean[], eventElement: EventBean) {
    return events.some(event => {
      return ContactInfoUtil.isEventEquals(event, eventElement);
    });
  }

  isMasterHasSameHouses(houses: HouseBean[], houseElement: HouseBean) {
    return houses.some(house => {
      return ContactInfoUtil.isHouseEquals(house, houseElement);
    });
  }

  isMasterHasSameAims(aims: AIMBean[], aimElement: AIMBean) {
    return aims.some(aim => {
      return ContactInfoUtil.isAimEquals(aim, aimElement);
    });
  }

  isMasterHasSameEmails(emails: EmailBean[], emailElement: EmailBean) {
    return emails.some(email => {
      return ContactInfoUtil.isEmailEquals(email, emailElement);
    });
  }

  // 判断是否master是否有相同的手机号，如果有的话，合并畅连能力标记到主的电话号码
  judgeIsMasterHasSamePhoneAndMergeAbilityFlag(phones: PhoneNumBean[], phoneElement: PhoneNumBean) {
    // phones exist phoneElement
    return phones.some(phone => {
      if (ContactInfoUtil.isPhoneNumEquals(phone, phoneElement)) {
        if (phone.meeTimeAbilityFlag !== PhoneNumBean.PHONE_NUM_HAS_MEETIME_ABILITY_FLAG &&
          phoneElement.meeTimeAbilityFlag === PhoneNumBean.PHONE_NUM_HAS_MEETIME_ABILITY_FLAG) {
          phone.meeTimeAbilityFlag = phoneElement.meeTimeAbilityFlag;
        }
        return true;
      }
      return false;
    });
  }

  getPickerDataByIds(
    contactIds: number[], userId: number, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.w(TAG, 'Start to getPickerDataByIds');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().getPickerDataByIds(
      contactIds, userId, (contactIdPickerDataMap: Map<number, contact.Contact>, groupIds: number[]) => {
      HiLog.w(TAG, `end to getPickerDataByIds, groupIds: ${groupIds}`);
      if (!ArrayUtil.isEmpty(groupIds)) {
        ContactRepository.getInstance().findGroupByGroupIds(groupIds, userId, (groupData: GroupListItem[]) => {
          HiLog.w(TAG, `findGroupByGroupIds end, groupData length: ${groupData.length}`);
          let groupIdMap: HashMap<number, GroupListItem> = new HashMap();
          if (!ArrayUtil.isEmpty(groupData)) {
            HiLog.w(TAG, 'findGroupByGroupIds data is not empty!');
            groupData.forEach((group: GroupListItem) => {
              groupIdMap.set(group.id, group);
            })
          }
          contactIdPickerDataMap.forEach((pickerData: contact.Contact) => {
            pickerData.groups?.forEach((group: contact.Group) => {
              group.title = groupIdMap.get(group.groupId)?.groupName;
            })
          })
          callBack(contactIdPickerDataMap);
        })
      } else {
        callBack(contactIdPickerDataMap);
      }
    })
  }

  /**
   * Obtain contactId by rawContactId
   * @param {Object} rawContactId
   */
  getContactIdByRawId(rawContactId: number, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to getContactIdByRawId');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findIdByRawId(rawContactId, callBack);
  }

  /**
   * Obtain contact details.
   *
   * @param {Object} contactId Contact data IDList.
   * @param {Object} callback Contact details
   */
  getContactByIdList(contactIdList: Array<string>, callBack: Function, context?: Context) {
    HiLog.i(TAG, 'Start to query contact by idList. Length: ' + contactIdList?.length);
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findListById(contactIdList, (contactList: ContactListItem[]) => {
        HiLog.i(TAG, 'Start to query contact by contactList length' + contactList.length);
        if (ArrayUtil.isEmpty(contactList)) {
          let emptyResult: FavoriteBean[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: FavoriteBean[] = [];
        for (let contactItem of contactList) {
          let jsonObj: FavoriteBean = new FavoriteBean('', -1, '', '', '',
            '', MorandiColor.color[0], true, '', false, 0, '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.isCommonUseType = 0;
          jsonObj.displayName = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.position = contactItem.position;
          jsonObj.portraitColor = MorandiColor.color[Math.abs(parseInt(jsonObj.contactId)) % 6];
          jsonObj.show = contactItem.show as boolean;
          jsonObj.isUsuallyShow = false;
          jsonObj.favorite = 1;
          jsonObj.favoriteOrder = contactItem.favoriteOrder.toString();
          jsonObj.setShowName();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'findFavoriteByIndex data success! List length: ' + resultList?.length);
        callBack(resultList);
      });
    } else {
      HiLog.e(TAG, 'have none context');
    }
  }

  /**
   * 根据联系人id获取畅连能力
   *
   * @param {Object} contactId Contact data ID.
   * @param {Object} callback Contact details
   */
  getContactMeeTimeAbilityById(contactId: number, callBack: Function, context?: common.UIAbilityContext | Context) {
    HiLog.i(TAG, 'Start to query contact meetime ability by id.');
    if (context) {
      ContactRepository.getInstance().init(context);
    }

    ContactRepository.getInstance().findContactMeeTimeAbilityById(contactId, (contact: Contact) => {
      const res: ContactReturnObj = new ContactReturnObj();
      if (contact == undefined || ArrayUtil.isEmpty(contact.rowContacts)) {
        HiLog.e(TAG, 'Query contact meetime ability  by id failed.');
        callBack(res);
        return;
      }
      //TODO 待确认 rowContacts[0] 使用情况
      const contactDetailInfo: RichContactInfo = new RichContactInfo('');
      // 设置畅连能力，如果存在raw有能力信息，将能力信息设置到contact
      for (let rawContact of contact.rowContacts) {
        if (rawContact.meeTimeAbilityInfoModel && rawContact.meeTimeAbilityInfoModel.extra4 > 0) {
          contactDetailInfo.meeTimeAbilityInfoModel = rawContact.meeTimeAbilityInfoModel;
          break;
        }
      }

      // 合并联系人信息
      this.aggregateRawContactToContact(contact.rowContacts, contactDetailInfo);
      this.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);

      contactDetailInfo.rowContactID = contact.rowContacts[0].id.toString();
      contactDetailInfo.meeTimeAbilityInfoModel.contactId = Number.parseInt(contactDetailInfo.contactID);
      res.data = contactDetailInfo;
      callBack(res);
      HiLog.i(TAG, 'End of querying meetime ability  contacts by ID.');
    });
  }

  /**
   * 更新畅连能力的手机号信息
   * @param contactDetailInfo
   */
  updateMeeTimeAbilityPhoneNumber(contactDetailInfo: RichContactInfo) {
    HiLog.i(TAG, 'Update the mobile number information of the smooth connection capability.');
    // 如果有畅联能力，设置畅连能力的手机号;
    // 如果是原生联系人创建的，可能有多个手机号，使用其中的一个手机号判断畅联能力（该手机号有标志）
    // 如果是畅联联系人新建的，只会有一个手机号，手机号没有标志
    if (contactDetailInfo.meeTimeAbilityInfoModel.extra4 > 0) {
      if (!ArrayUtil.isEmpty(contactDetailInfo.phones)) {
        if (contactDetailInfo.phones.length > 1) {
          contactDetailInfo.phones.forEach(phone => {
            if (phone.meeTimeAbilityFlag == PhoneNumBean.PHONE_NUM_HAS_MEETIME_ABILITY_FLAG) {
              contactDetailInfo.meeTimeAbilityInfoModel.phoneNumber = phone.num;
            }
          });
        } else {
          // 只有一个手机号，直接使用
          contactDetailInfo.meeTimeAbilityInfoModel.phoneNumber = contactDetailInfo.phones[0].num;
        }
      }
    }
  }

  /**
   * Process contact details
   *
   * @param {Object} resultSet
   * @param {Object} contactDetailInfo Contact details data
   * @param {Object} actionData Contact data
   */
  dealResult(dataItem: DataItem, contactDetailInfo: RichContactInfo) {
    contactDetailInfo.favorite = Number(dataItem.values.get(DataType.FAVORITE));
    try {
      let typeId: number = Number(dataItem.values.get(Data.TYPE_ID));
      let data = dataItem.values.get(DataType.DATA);
      let labelId = dataItem.values.get(DataType.LABEL_ID);
      let labelName = dataItem.values.get(DataType.LABEL_NAME);
      switch (typeId) {
        case DataItemType.NAME:
          contactDetailInfo.display_name = dataItem.values.get(Data.DISPLAY_NAME) as string;
          contactDetailInfo.nameUpdate = dataItem.values.get(DataType.LABEL_ID);
          contactDetailInfo.phoneticName = dataItem.values.get(Data.PHONETIC_NAME) as string;
          HiLog.i(TAG, 'dealResult, display_name size is ' + contactDetailInfo.display_name?.length);
          break;
        case DataItemType.PHONE:
          let isPrimary = dataItem.values.get(DataType.IS_PRIMARY);
          let id = dataItem.values.get(Data.ID);
          const phoneElement: PhoneNumBean = new PhoneNumBean(labelId as string,
            data as string, labelName as string, '', '',
            isPrimary == '1', Number(id));
          phoneElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          // 标记有畅连能力的手机号
          phoneElement.meeTimeAbilityFlag = dataItem.values.get(Data.EXTEND1) as string;
          phoneElement.formatNum = dataItem.values.get(Data.FORMAT_PHONE_NUMBER) as string;
          if (contactDetailInfo.phones) {
            if (!this.judgeIsMasterHasSamePhoneAndMergeAbilityFlag(contactDetailInfo.phones, phoneElement)) {
              contactDetailInfo.phones.push(phoneElement);
            }
          } else {
            contactDetailInfo.phones = [phoneElement];
          }
          HiLog.i(TAG, 'dealResult, phoneNumber size is ' + phoneElement.num?.length);
          // 打印电话号码中的 非法符号
          const symbol = phoneElement.num?.replace(numberRegExp, '');
          const symbolPhoneNumber = phoneElement.num?.replace(numberRegExp, '*');
          if (symbol.length > 0) {
            HiLog.i(TAG, `dealResult, phoneNumber nonnormal symbol size is ${symbol.length}, symbol: '${symbol}', ` +
              `symbolPhoneNumber: '${symbolPhoneNumber}'`);
          }
          break;
        case DataItemType.EMAIL:
          const emailElement: EmailBean = new EmailBean(labelId as string, data as string,
            labelName as string);
          emailElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          if (contactDetailInfo.emails) {
            if (!this.isMasterHasSameEmails(contactDetailInfo.emails, emailElement)) {
              contactDetailInfo.emails.push(emailElement);
            }
          } else {
            contactDetailInfo.emails = [emailElement];
          }
          break;
        case DataItemType.NOTE:
          contactDetailInfo.remarks = data as string;
          break;
        case DataItemType.ORGANIZATION:
          contactDetailInfo.position = dataItem.values.get(Data.POSITION) as string;
          contactDetailInfo.company = data as string;
          break;
        case DataItemType.IM:
          const aimElement: AIMBean = new AIMBean('', labelId as string, labelName as string,
            data as string);
          aimElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          if (contactDetailInfo.aims) {
            if (!this.isMasterHasSameAims(contactDetailInfo.aims, aimElement)) {
              contactDetailInfo.aims.push(aimElement);
            }
          } else {
            contactDetailInfo.aims = [aimElement];
          }
          break;
        case DataItemType.STRUCTURED_POSTAL:
          const houseElement: HouseBean = new HouseBean('', labelId as string,
            labelName as string, data as string);
          houseElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          if (contactDetailInfo.houses) {
            if (!this.isMasterHasSameHouses(contactDetailInfo.houses, houseElement)) {
              contactDetailInfo.houses.push(houseElement);
            }
          } else {
            contactDetailInfo.houses = [houseElement];
          }
          break;
        case DataItemType.NICKNAME:
          contactDetailInfo.nickname = data as string;
          break;
        case DataItemType.EVENT:
          const eventElement: EventBean = new EventBean(labelId as string,
            data as string, labelName as string, '');
          eventElement.calendarEventId = dataItem.values.get(Data.CALENDAR_EVENT_ID) as string;
          eventElement.contactDataId = dataItem.values.get(Data.ID) as number;
          eventElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          if (contactDetailInfo.events) {
            if (!this.isMasterHasSameEvents(contactDetailInfo.events, eventElement)) {
              contactDetailInfo.events.push(eventElement);
            }
          } else {
            contactDetailInfo.events = [eventElement];
          }
          break;
        case DataItemType.WEBSITE:
          let websiteElement = data;
          if (contactDetailInfo.websites) {
            if (!this.isMasterHasSameWebsites(contactDetailInfo.websites, websiteElement)) {
              contactDetailInfo.websites.push(websiteElement as string);
            }
          } else {
            contactDetailInfo.websites = [websiteElement as string];
          }
          break;
        case DataItemType.RELATION:
          const relationElement: AssociatedPersonBean = new AssociatedPersonBean(labelId as string, '',
            data as string, labelName as string);
          relationElement.setPickerData(data as string, labelId as string,
            parseInt(labelName as string));
          if (contactDetailInfo.relationships) {
            if (!this.isMasterHasSameRelationships(contactDetailInfo.relationships, relationElement)) {
              contactDetailInfo.relationships.push(relationElement);
            }
          } else {
            contactDetailInfo.relationships = [relationElement];
          }
          break;
        case DataItemType.HI_CALL_DEVICE:
          contactDetailInfo.meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr.push(
            new MeeTimeDeviceInfoModel(
              dataItem.values.get(Data.EXTEND4) as string,
              Number.parseInt(dataItem.values.get(Data.EXTEND1) as string),
              dataItem.values.get(Data.EXTEND5) as string
            )
          );
          break;
        case DataItemType.GROUP_MEMBERSHIP:
          const groupElement: GroupBean = new GroupBean(-1, '', '', '', '', '', 0, 0, '');
          groupElement.setPickerData('', parseInt(data as string));
          if (contactDetailInfo.groups) {
            contactDetailInfo.groups.push(groupElement);
          } else {
            contactDetailInfo.groups = [groupElement];
          }
          break;
      }
    } catch (e) {
      HiLog.e(TAG, 'dealResult :' + e?.code + ', message: ' + e?.message);
    }

  }

  setPrimary(contactId: ValueType, dataType: ValueType, dataId: ValueType, primary: boolean) {
    HiLog.i(TAG, 'setPrimary:' + contactId);
    ContactRepository.getInstance().setPrimary(contactId, dataType, dataId, primary);
  }

  /**
   * Edit Contact Information
   *
   * @param {string} daHelper
   * @param {Object} addParams  Contact Information
   * @param {Object} callBack Contact ID
   */
  async updateContact(daHelper: dataShare.DataShareHelper | null, contactBefore: ContactInfo,
    contactAfter: ContactInfo,
    deletePhoto: boolean,
    callBack: Function, isMyCard: boolean = false, context?: common.UIAbilityContext, log?: UtilAuditLog) {
    HiLog.i(TAG, `Start to update contacts. isMyCard:${isMyCard}`);
    let updateFlag: boolean = false;
    try {
      let updateContactInfo =
        ContactInfo.buildFromParameters(contactAfter); // there is no function bind the object of addParams
      // 更新联系人铃声
      await this.updateRingToneToContact(true, updateContactInfo.contactID,
        updateContactInfo.personalRingtone, updateContactInfo.personalNotificationRingtone,
        contactBefore.personalRingtone, updateContactInfo.personalRingtonePath);
      if (daHelper == undefined || daHelper == null) {
        daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      }
      let rawContactIds: string[] = this.getRawIdsFromContactInfo(updateContactInfo);
      // 1、更新畅联
      await this.updateMeetTime(daHelper, rawContactIds, isMyCard);
      HiLog.i(TAG, 'updateContact,first updateMeeTimeAbilityInfo data success!');
      // 2、 删选主联系人和其他联系人
      let rawContactsInfos: ContactInfo[] = this.filterRawContact(contactBefore, updateContactInfo);
      // 4、 更新所有联系人
      if (!ArrayUtil.isEmpty(rawContactsInfos)) {
        HiLog.i(TAG, 'updateContact, last update rawContact start...');
        updateFlag = await this.updateRawContacts(rawContactsInfos, daHelper, deletePhoto);
      }
      HiLog.w(TAG,
        'updateContact flag :' + updateFlag + ' ,contactId:' + updateContactInfo.contactID + ',rawContactIds:' +
          rawContactIds);
      if (updateFlag) {
        callBack(updateContactInfo.contactID);
      } else {
        callBack();
      }
    } catch (err) {
      callBack();
      HiLog.e(TAG, 'updateContact err : ' + err?.code + ', message: ' + err?.message);
    }
  }

  getRawIdsFromContactInfo(updateContactInfo: ContactInfo): string[] {
    let ids: string[] = [];
    if (updateContactInfo == null || updateContactInfo == undefined) {
      HiLog.w(TAG, 'getRawIdsFromContactInfo failed ,contactInfo is null');
      return ids;
    }

    for (let item of updateContactInfo.rawContacts) {
      if (item?.id) {
        ids.push(item.id.toString());
      } else {
        HiLog.w(TAG, 'getRawIdsFromContactInfo failed ,item.id is null');
      }
    }
    return ids;
  }

  async updateMeetTime(daHelper: dataShare.DataShareHelper, rawContactIds: string[], isMyCard: boolean) {
    // 修改的话，可能修改手机号，需要重新判断，更新下是否有畅连能力
    const updateInfo: Record<string, string | number> = {
      'version': 0,
      'extra1': '',
      'extra2': '',
      'extra3': '',
      'extra4': 0,
      'primary_contact': isMyCard ? '1' : '0'
    };
    if (ArrayUtil.isEmpty(rawContactIds)) {
      HiLog.w(TAG, 'updateMeetTime failed ,rawContactIds is empty');
      return;
    }
    let conditionUpdate = new dataSharePredicates.DataSharePredicates();
    conditionUpdate.in('id', rawContactIds);
    let updateResult: number = await daHelper.update(RawContacts.CONTENT_URI, conditionUpdate, updateInfo);
    HiLog.i(TAG, 'updateMeeTimeAbilityInfo data result : ' + updateResult + ' , rawContactIds: ' + rawContactIds);
  }

  async updateRawContacts(rawContactsInfos: ContactInfo[], daHelper: dataShare.DataShareHelper,
    deletePhoto: boolean): Promise<boolean> {
    HiLog.i(TAG, 'updateRawContacts start...');
    let updateFlag: boolean = false;
    for (let raw of rawContactsInfos) {
      // 更新联系人编辑的信息
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('raw_contact_id', raw.rowContactID);
      condition.and();
      condition.notEqualTo('type_id', '9');
      // 删除之前头像条件:
      // 1、删除头像（ContactInfo.photo 为空，dealParam会跳过头像处理）
      // 2、用户修改、新增了头像（此时contactInfo.photo 不为空，dealParam后续可以新增进入）
      if (!deletePhoto && (raw.photo === undefined || raw.photo === null)) {
        condition.and();
        condition.notEqualTo('type_id', '8');
      }
      let delResult: number = await daHelper.delete(Data.CONTENT_URI, condition);
      if (this.isDbOperateSuccess(delResult)) {
        updateFlag = await this.dealParam(daHelper as dataShare.DataShareHelper, raw, false);
      } else {
        HiLog.w(TAG,
          'updateOtherRawContacts failed ,contactId:' + raw.contactID + ' ,rawContactId:' + raw.rowContactID);
        updateFlag = false;
      }
    }
    return updateFlag;
  }

  filterRawContact(contactBefore: ContactInfo, saveContactInfo: ContactInfo): ContactInfo[] {
    HiLog.i(TAG, 'filterRawContact start ...');
    let result: ContactInfo[] = [];
    let originalRaw: RawContact[] = saveContactInfo.rawContacts;
    // 原始raw数据转换成contactInfo
    let allOriginalInfo: ContactInfo[] = [];
    for (let item of originalRaw) {
      allOriginalInfo.push(this.convertRawToContactInfo(item, saveContactInfo.contactID, saveContactInfo.photo));
    }
    for (let originalInfo of allOriginalInfo) {
      // 判断原始的other数据中是否存在 待保存的数据没有的字段。如果存在，则说明otherContact 在本次修改中字段被删除，需要将other中字段删除,
      // 并返回删除之后的对象,用于后续的删除保存
      this.handleDelContactInfo(originalInfo, saveContactInfo);
      this.handleAddContactInfo(originalInfo, saveContactInfo, contactBefore);
      result.push(originalInfo);

    }
    HiLog.i(TAG, 'filterRawContact result size : ' + result.length);
    return result;
  }

  handleAddContactInfo(originalInfo: ContactInfo, saveContactInfo: ContactInfo, contactBefore: ContactInfo) {
    // 从after中筛选出相对before新增的字段信息，信息存在时，替换给otherRawContact
    // phones 删选出 save中before没有的手机信息，save新增的手机号
    let needAddPhones: PhoneNumBean[] = this.handlePhones(saveContactInfo.phones, contactBefore.phones);
    if (needAddPhones.length > 0) {
      originalInfo.phones = originalInfo.phones.concat(needAddPhones);
    }
    // emails
    let needAddEmails: EmailBean[] = this.handleEmails(saveContactInfo.emails, contactBefore.emails);
    if (needAddEmails.length > 0) {
      originalInfo.emails = originalInfo.emails.concat(needAddEmails);
    }
    // aims
    let needAddAims: AIMBean[] = this.handleAims(saveContactInfo.aims, contactBefore.aims);
    if (needAddAims.length > 0) {
      originalInfo.aims = originalInfo.aims.concat(needAddAims);
    }
    // houses
    let needAddHouses: HouseBean[] = this.handleHouses(saveContactInfo.houses, contactBefore.houses);
    if (needAddHouses.length > 0) {
      originalInfo.houses = originalInfo.houses.concat(needAddHouses);
    }
    // websites
    let needAddWebsite: string[] = this.handleWebsites(saveContactInfo.websites, contactBefore.websites);
    if (needAddWebsite.length > 0) {
      originalInfo.websites = originalInfo.websites.concat(needAddWebsite);
    }
    // relationships
    let needAddRelationships: AssociatedPersonBean[] =
      this.handleRelationships(saveContactInfo.relationships, contactBefore.relationships);
    if (needAddRelationships.length > 0) {
      originalInfo.relationships = originalInfo.relationships.concat(needAddRelationships);
    }
    // events
    let needAddEvents: EventBean[] = this.handleEvents(saveContactInfo.events, contactBefore.events);
    if (needAddEvents.length > 0) {
      originalInfo.events = originalInfo.events.concat(needAddEvents);
    }
    // groups
    let needAddGroups: GroupBean[] = this.handleGroups(saveContactInfo.groups, contactBefore.groups);
    if (needAddGroups.length > 0) {
      originalInfo.groups = originalInfo.groups.concat(needAddGroups);
    }
    // display_name 名称使用保存的display_name 覆盖
    originalInfo.display_name = saveContactInfo.display_name;
    // nickname
    if (saveContactInfo.nickname != contactBefore.nickname) {
      originalInfo.nickname = saveContactInfo.nickname;
    }
    // remarks
    if (saveContactInfo.remarks != contactBefore.remarks) {
      originalInfo.remarks = saveContactInfo.remarks;
    }
    // position
    if (saveContactInfo.position != contactBefore.position) {
      originalInfo.position = saveContactInfo.position;
    }
    // organization
    if (saveContactInfo.company != contactBefore.company) {
      originalInfo.company = saveContactInfo.company;
    }
    // phoneticName
    if (saveContactInfo.phoneticName != contactBefore.phoneticName) {
      originalInfo.phoneticName = saveContactInfo.phoneticName;
    }
    // otherLanLastName
    if (saveContactInfo.otherLanLastName != contactBefore.otherLanLastName) {
      originalInfo.otherLanLastName = saveContactInfo.otherLanLastName;
    }
    // otherLanFirstName
    if (saveContactInfo.otherLanFirstName != contactBefore.otherLanFirstName) {
      originalInfo.otherLanFirstName = saveContactInfo.otherLanFirstName;
    }
    // favorite
    if (saveContactInfo.favorite != contactBefore.favorite) {
      originalInfo.favorite = saveContactInfo.favorite;
    }
  }

  handleDelContactInfo(originalInfo: ContactInfo, saveContactInfo: ContactInfo) {
    // saveContact  全量联系人字段  // original 部分联系人字段
    // 1、other不为空，save 为空 2、other为单项值时,other值与save不同 3、other为多项值时，other不包含在save内
    // phones
    let needRemovePhones: PhoneNumBean[] = this.handlePhones(originalInfo.phones, saveContactInfo.phones);
    if (needRemovePhones.length > 0) {
      originalInfo.phones = ContactInfoUtil.filterRemovePhones(originalInfo.phones, needRemovePhones);
    }
    // emails
    let needRemoveEmails: EmailBean[] = this.handleEmails(originalInfo.emails, saveContactInfo.emails);
    if (needRemoveEmails.length > 0) {
      originalInfo.emails = ContactInfoUtil.filterRemoveEmails(originalInfo.emails, needRemoveEmails);
    }
    // aims
    let needRemoveAims: AIMBean[] = this.handleAims(originalInfo.aims, saveContactInfo.aims);
    if (needRemoveAims.length > 0) {
      originalInfo.aims = ContactInfoUtil.filterRemoveAims(originalInfo.aims, needRemoveAims);
    }
    // houses
    let needRemoveHouses: HouseBean[] = this.handleHouses(originalInfo.houses, saveContactInfo.houses);
    if (needRemoveHouses.length > 0) {
      originalInfo.houses = ContactInfoUtil.filterRemoveHouses(originalInfo.houses, needRemoveHouses);
    }
    // websites
    let needRemoveWebsites: string[] = this.handleWebsites(originalInfo.websites, saveContactInfo.websites);
    if (needRemoveWebsites.length > 0) {
      originalInfo.websites = ContactInfoUtil.filterRemoveWebsites(originalInfo.websites, needRemoveWebsites);
    }
    // relationships
    let needRemoveRelationships: AssociatedPersonBean[] =
      this.handleRelationships(originalInfo.relationships, saveContactInfo.relationships);
    if (needRemoveRelationships.length > 0) {
      originalInfo.relationships =
        ContactInfoUtil.filterRemoveRelationships(originalInfo.relationships, needRemoveRelationships);
    }
    // events
    let needRemoveEvents: EventBean[] = this.handleEvents(originalInfo.events, saveContactInfo.events);
    if (needRemoveEvents.length > 0) {
      originalInfo.events = ContactInfoUtil.filterRemoveEvents(originalInfo.events, needRemoveEvents);
    }
    // groups
    let needRemoveGroups: GroupBean[] = this.handleGroups(originalInfo.groups, saveContactInfo.groups);
    if (needRemoveGroups.length > 0) {
      originalInfo.groups = ContactInfoUtil.filterRemoveGroups(originalInfo.groups, needRemoveGroups);
    }
    // display_name 名称需要始终继承主联系人的
    if (this.handleDisplayName(originalInfo.display_name, saveContactInfo.display_name)) {
      originalInfo.display_name = saveContactInfo.display_name;
    }
    // nickname
    if (this.handleSimpleData(originalInfo.nickname, saveContactInfo.nickname)) {
      originalInfo.nickname = '';
    }
    // remarks
    if (this.handleSimpleData(originalInfo.remarks, saveContactInfo.remarks)) {
      originalInfo.remarks = '';
    }
    // position
    if (this.handleSimpleData(originalInfo.position, saveContactInfo.position)) {
      originalInfo.position = '';
    }
    // company
    if (this.handleSimpleData(originalInfo.company, saveContactInfo.company)) {
      originalInfo.company = '';
    }
    // phoneticName
    if (this.handleSimpleData(originalInfo.phoneticName, saveContactInfo.phoneticName)) {
      originalInfo.phoneticName = '';
    }
    // otherLanLastName
    if (this.handleSimpleData(originalInfo.otherLanLastName, saveContactInfo.otherLanLastName)) {
      originalInfo.otherLanLastName = '';
    }
    // otherLanFirstName
    if (this.handleSimpleData(originalInfo.otherLanFirstName, saveContactInfo.otherLanFirstName)) {
      originalInfo.otherLanFirstName = '';
    }
    // favorite
    if (this.handleFavorite(originalInfo.favorite, saveContactInfo.favorite)) {
      originalInfo.favorite = saveContactInfo.favorite;
    }
  }

  handleGroups(original: GroupBean[], saved: GroupBean[]): GroupBean[] {
    let extraList: GroupBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isGroupEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleEvents(original: EventBean[], saved: EventBean[]): EventBean[] {
    let extraList: EventBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isEventEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleRelationships(original: AssociatedPersonBean[],
    saved: AssociatedPersonBean[]): AssociatedPersonBean[] {
    let extraList: AssociatedPersonBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isRelationshipEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleWebsites(original: string[], saved: string[]): string[] {
    let extraList: string[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return savedItem == item;
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleHouses(original: HouseBean[], saved: HouseBean[]): HouseBean[] {
    let extraList: HouseBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isHouseEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleAims(original: AIMBean[], saved: AIMBean[]): AIMBean[] {
    // original 中有 saved没有的数据项
    let extraList: AIMBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isAimEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleEmails(original: EmailBean[], saved: EmailBean[]): EmailBean[] {
    // original 中有 saved没有的数据项
    let extraList: EmailBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isEmailEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handlePhones(original: PhoneNumBean[], saved: PhoneNumBean[]): PhoneNumBean[] {
    // original 中有 saved没有的数据项
    let extraList: PhoneNumBean[] = [];
    for (let item of original) {
      let result = saved.filter(savedItem => {
        return ContactInfoUtil.isPhoneNumEquals(item, savedItem);
      });
      // 原始数据不在要保存的数据里，需要被删除
      if (result.length == 0) {
        extraList.push(item);
      }
    }
    return extraList;
  }

  handleDisplayName(original: string, saved: string): boolean {
    return true;
  }

  handleSimpleData(original: string, saved: string): boolean {
    if (!StringUtil.isEmpty(original) && StringUtil.isEmpty(saved)) {
      return true;
    }
    return false;
  }

  handleFavorite(original: number, saved: number): boolean {
    if (original != saved) {
      return true;
    }
    return false;
  }

  convertRawToContactInfo(rawContact: RawContact, contactId: string,
    photo: Uint8Array | null | undefined): ContactInfo {
    HiLog.i(TAG, 'start convertRawToContactInfo...');
    let contactDetailInfo: RichContactInfo = new RichContactInfo('');
    if (rawContact == null || rawContact == undefined) {
      return contactDetailInfo;
    }
    HiLog.i(TAG, 'convertRawToContactInfo dataItem size :' + rawContact.dataItems.length);
    for (let dataItem of rawContact.dataItems) {
      this.dealResult(dataItem, contactDetailInfo);
    }
    this.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);
    //
    contactDetailInfo.photo = photo;
    contactDetailInfo.contactID = contactId;
    contactDetailInfo.rowContactID = rawContact.id.toString();
    contactDetailInfo.meeTimeAbilityInfoModel.contactId = Number.parseInt(contactDetailInfo.contactID);
    contactDetailInfo.photoFirstName = rawContact.values.get(RawContacts.PHOTO_FIRST_NAME) as string;
    contactDetailInfo.accountId = rawContact.values.get(RawContacts.ACCOUNT_ID) as number;
    return contactDetailInfo;
  }

  async updateMasterRawContact(masterRawContactInfo: ContactInfo, daHelper: dataShare.DataShareHelper,
    deletePhoto: boolean): Promise<boolean> {
    HiLog.i(TAG, 'updateMasterRawContact start...' + masterRawContactInfo.rowContactID);
    // 更新联系人编辑的信息
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('raw_contact_id', masterRawContactInfo.rowContactID);
    condition.and();
    condition.notEqualTo('type_id', '9');
    if (!deletePhoto && (masterRawContactInfo.photo === undefined || masterRawContactInfo.photo === null)) {
      condition.and();
      condition.notEqualTo('type_id', '8');
    }
    let delResult: number = await daHelper.delete(Data.CONTENT_URI, condition);
    if (this.isDbOperateSuccess(delResult)) {
      return this.dealParam(daHelper as dataShare.DataShareHelper, masterRawContactInfo, false);
    } else {
      HiLog.e(TAG, 'updateMasterRawContact delete fail');
      return false;
    }
  }

  private isDbOperateSuccess(result: number): boolean {
    return result >= 0;
  }

  distinctForPhoneNum(updateContactId: string, contactInfoMap: HashMap<string, ValuesBucket[]>) {
    HiLog.i(TAG, 'contactInfoMap  length:' + contactInfoMap.length);
    let phoneSet: HashSet<ValueType | Uint8Array | null> = new HashSet();
    let params: ValuesBucket[] = [];
    contactInfoMap.get(updateContactId).forEach(valuesBucket => {
      if (valuesBucket.type_id == 5) {
        phoneSet.add(valuesBucket.detail_info);
      }
    });
    contactInfoMap.forEach((value, key) => {
      if (key != updateContactId) {
        if (value && value.length > 0) {
          let newParams = value.concat();
          value.forEach(valuesBucket => {
            if (valuesBucket.type_id == 5) {
              let size = phoneSet.length;
              phoneSet.add(valuesBucket.detail_info);
              if (phoneSet.length === size) {
                newParams.splice(newParams.indexOf(valuesBucket), 1);
              }
            }
          });
          params = params.concat(newParams);
        }
      }
    });
    return params;
  }

  /**
   * Querying IDs by Phone Number
   *
   * @param {string} daHelper
   * @param {string} addParams  Phone number
   * @param {Object} callBack Contact ID array
   */
  async getIdByTelephone(
    number: ValueType, quickSearchKey: number, callBack: Function, context?: common.UIAbilityContext) {

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      HiLog.w(TAG, 'getIdByTelephone Start to query contactID by phone number.');
      let resultList: string[] = [];
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let numStr = number as string;
      let formatPhoneNumber = RoamingUtils.getFormatNumberBySystemRegion(number as string);

      HiLog.w(TAG, `getIdByTelephone numStr: ${StringUtil.maskSensitiveInfo(numStr)
      }, formatPhoneNumber: ${StringUtil.maskSensitiveInfo(formatPhoneNumber)}, quickSearchKey: ${quickSearchKey}`);

      let condition = new dataSharePredicates.DataSharePredicates();
      let columns = [Data.RAW_CONTACT_ID, Data.DETAIL_INFO, RawContacts.CONTACT_ID, Data.FORMAT_PHONE_NUMBER];

      // 通过 phoneNumber 去查联系人ID
      condition = new dataSharePredicates.DataSharePredicates();
      condition.beginWrap();
      // 长度小于7，直接equal匹配
      if (StringUtil.isEmpty(numStr) || numStr.length < 7) {
        condition.equalTo(Data.DETAIL_INFO, numStr);
      } else {
        // 长度大于7，截取后7为，endsWith查询
        condition.endsWith(Data.DETAIL_INFO, NumberMatch.getInstance().getQueryNum(numStr));
      }
      // 存在formatPhoneNumber，使用格式化号码查询
      if (!StringUtil.isEmpty(formatPhoneNumber)) {
        condition.or();
        condition.equalTo(Data.FORMAT_PHONE_NUMBER, formatPhoneNumber);
      }
      condition.endWrap();
      condition.and()
        .equalTo(Data.TYPE_ID, 5)
        .and()
        .equalTo(Data.IS_DELETED, 0)
        .and()
        .notEqualTo(Data.MARK_MY_CARD, '1');
      resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
      HiLog.w(TAG, 'getIdByTelephone phoneNumber resultSet.rowCount: ' + resultSet.rowCount);
      if (resultSet && resultSet.rowCount > 0) {
        let matchIndex = await NumberMatch.getInstance().getCallerIndex(resultSet, numStr);
        HiLog.w(TAG, `getIdByTelephone matchIndex: ${matchIndex}}`);
        if (matchIndex < 0) {
          callBack(resultList);
          HiLog.w(TAG, 'getIdByTelephone End to query contactID by phone number.  No matches!');
          return;
        }
        resultSet.goToRow(matchIndex);
        do {
          resultList.push(resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID)));
        } while (resultSet.goToNextRow());
      }
      HiLog.w(TAG, 'getIdByTelephone End to query contactID by phone number.');
      callBack(resultList);
    } catch (err) {
      callBack([]);
      // 联系人故障打点-查询联系人详情异常-未知联系人
      faultContactParams.FAULT_INFO = err.message;
      DotUtil.getInstance().reportFaultEvent(faultContactParams,
        dotCommon.faultEventName.DISPLAY_CONTACTS_DETAIL_ERROR);
      HiLog.e(TAG, 'getIdByTelephone err : ' + err?.code + ', message: ' + err?.message);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  /**
   * Determine whether there are contacts by Phone Number and displayName
   *
   * @param {string} daHelper
   * @param {string[]} addParams  Phone number
   * @param {string} addParams  displayName
   */
  async isHasContactByPhoneNumAndDisplayName(number: string[], displayName: string,
    callBack: Function, context?: common.UIAbilityContext) {

    let dataRow: DataShareResultSet | undefined = undefined;
    try {
      HiLog.w(TAG, `Start to query contacts by phone number and displayName,
        number length: ${number.length}, displayName: ${StringUtil.maskSensitiveInfo(displayName)}`);
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      if (number.length === 0) {
        // 无号码联系人判定是否重复
        HiLog.w(TAG, 'contact without numbers');
        condition.equalTo('display_name', displayName)
          .and()
          .equalTo('is_deleted', 0)
      } else {
        condition.in('detail_info', number)
          .and()
          .equalTo('display_name', displayName)
          .and()
          .equalTo('type_id', 5)
          .and()
          .equalTo('is_deleted', 0);
      }
      let columns = ['id'];
      dataRow = await daHelper.query(Data.CONTENT_URI, condition, columns);
      callBack(dataRow.rowCount > (number.length - 1 >= 0 ? number.length - 1 : 0));
    } catch (error) {
      // 联系人故障打点-加载SIM卡联系人失败
      faultContactParams.FAULT_INFO = error.message;
      DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_SIM_CONTACTS_FAIL);
      HiLog.e(TAG, 'isHasContactByPhoneNumAndDisplayName error: ' + error?.code + ', message: ' + error?.message);
    } finally {
      ObjectUtil.closeResultSet(dataRow);
    }
  }

  /**
   * Edit Contact Favorite
   *
   * @param {string} daHelper
   * @param {Object} addParams  Contact Information
   * @param {Object} callBack Contact ID
   */
  async updateFavorite(daHelper: dataShare.DataShareHelper | null, addParams: Record<string, string | number>,
    callBack: Function, context?: common.UIAbilityContext) {
    HiLog.w(TAG, 'updateFavorite start.');
    if (daHelper == undefined || daHelper == null) {
      daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    }
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('contact_id', addParams.id);
    const va: Record<string, string | number> = {
      'favorite': addParams.favorite.toString(),
      'favorite_order': Number(addParams.favoriteOrder)
    };
    daHelper.update(
      RawContacts.CONTENT_URI,
      condition,
      va
    ).then((data: number) => {
      if (data == -1) {
        HiLog.e(TAG, 'updateFavorite data failed!');
      }
      daHelper?.notifyChange(Data.CONTENT_URI);
      HiLog.w(TAG, 'updateFavorite data success!');
      callBack(addParams.favorite);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'updateFavorite failed. Cause: ' + err?.code + ', message: ' + err?.message);
    });
    HiLog.w(TAG, 'updateFavorite end.');
  }

  // 查询raw_contact表的favorite_order最大值
  async queryFavoriteOrder() {
    let favoriteOrder: number = 0;

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance()
          .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext())
          .getDataAbilityHelper();
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.orderByDesc('favorite_order');
      predicates.limit(1, 0);
      predicates.greaterThan('favorite_order', 0);
      resultSet = await daHelper.query(Contacts.CONTACT_RAW_URI, predicates, ['favorite_order']);
      if (resultSet && resultSet.goToFirstRow()) {
        favoriteOrder = resultSet.getLong(resultSet.getColumnIndex('favorite_order'));
      }
      HiLog.w(TAG, 'bigPhotoFromFile queryContactDataInfo favoriteOrder: ' + favoriteOrder);
      return favoriteOrder;
    } catch (error) {
      HiLog.e(TAG, 'bigPhotoFromFile queryContactDataInfo error: ' + error?.code + ', message: ' + error?.message);
      return favoriteOrder;
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  /**
   * Edit Contact List Favorite
   *
   * @param {string} daHelper
   * @param {Array} favoriteList  Contact List Information
   * @param {Object} callBack Contact ID
   */
  async updateFavoriteList(daHelper: dataShare.DataShareHelper | null, favoriteList: LooseObject,
    updateToFavorite: boolean, favoriteOrder: number, callBack: Function,
    context?: common.UIAbilityContext) {
    HiLog.w(TAG, 'updateFavoriteList start.');

    if (!daHelper) {
      daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    }

    let length: number = favoriteList.length;
    const contactIds: string[] = [];
    for (let i = 0; i < length; i++) {
      contactIds.push(favoriteList[i]);
    }

    const promises: Promise<number>[] = [];
    // 分批处理，每批4000条
    for (let i = 0; i < length; i += 4000) {
      const batch = contactIds.slice(i, i + 4000);
      const condition = new dataSharePredicates.DataSharePredicates();
      condition.in('contact_id', batch);

      const values: Record<string, boolean | number> = {
        'favorite': updateToFavorite,
        'favorite_order': Number(favoriteOrder)
      };

      let promise = daHelper.update(RawContacts.CONTENT_URI, condition, values);
      promise.then((updatedRows: number) => {
        HiLog.w(TAG, `updateFavoriteList data success! Updated rows: ${updatedRows}`);
        daHelper?.notifyChange(Data.CONTENT_URI);
      })
        .catch((err: BusinessError) => {
          HiLog.e(TAG, `updateFavoriteList failed. Code: ${err.code}, Message: ${err.message}`);
        });
      promises.push(promise);
    }
    await Promise.all(promises);
    callBack();
    HiLog.w(TAG, 'updateFavoriteList end.');
  }

  /**
   * Edit Contact List Favorite
   *
   * @param {string} daHelper
   * @param {Array} favoriteIds  ContactId List Information
   * @param {Object} callBack Contact ID
   */
  async deleteFavorite(favoriteIds: string[], callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'zwn deleteFavorite start.');
    let daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.in('contact_id', favoriteIds)
    const va: Record<string, number> = {
      'favorite': 0
    };
    daHelper.update(
      RawContacts.CONTENT_URI,
      condition,
      va
    ).then((data: number) => {
      HiLog.w(TAG, 'deleteFavorite data: ' + data);
      callBack(data);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'deleteFavorite failed. Cause: ' + err?.code + ', message: ' + err?.message);
    });
    HiLog.i(TAG, 'deleteFavorite end.');
  }

  /**
   * Querying the Mobile Numbers of All Favorites
   *
   * @param {string} daHelper
   * @param {Object} callBack
   */
  async getFavoriteByIndex(actionData: LooseObject, index: number,
    callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'findFavoriteByIndex start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findFavoriteByIndex(index, (favoriteList: ContactUsuallyListItemHasPhones[]) => {
        if (ArrayUtil.isEmpty(favoriteList)) {
          let emptyResult: FavoriteBean[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: FavoriteBean[] = [];
        for (let contactItem of favoriteList) {
          let jsonObj: FavoriteBean =
            new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], true, '', false, 0, '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.isCommonUseType = 0;
          jsonObj.displayName = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.position = contactItem.position;
          jsonObj.portraitColor = MorandiColor.color[Math.abs(parseInt(jsonObj.contactId)) % 6];
          jsonObj.isUsuallyShow = false;
          jsonObj.favorite = 1;
          jsonObj.favoriteOrder = contactItem.favoriteOrder.toString();
          jsonObj.setShowName();
          jsonObj.phones = contactItem.phones;
          jsonObj.id = contactItem.id;
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, `findFavoriteByIndex data success! `);
        callBack(resultList);
      });
    }
    HiLog.i(TAG, 'findFavoriteByIndex end.');
  }

  async updateUsuallyList(daHelper: dataShare.DataShareHelper | null, usuallyList: string[],
    callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'updateUsuallyList start.');
    if (daHelper == undefined || daHelper == null) {
      daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    }
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.in('detail_info', usuallyList);
    const va: Record<string, string | null> = {
      'extend8': null
    };
    daHelper.update(
      Data.CONTENT_URI,
      condition,
      va
    ).then(() => {
      HiLog.i(TAG, 'updateUsuallyList success!');
      callBack();
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'updateUsuallyList failed. Cause: ' + err?.code + ', message: ' + err?.message);
    });
    HiLog.i(TAG, 'updateUsuallyList end.');
  }

  /**
   * Querying the Mobile Numbers of All Favorites
   *
   * @param {string} daHelper
   * @param {Object} callBack
   */
  async getAllFavorite(callBack: Function, context?: common.UIAbilityContext) {
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
          let jsonObj: FavoriteBean =
            new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], true, '', false, 0, '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.isCommonUseType = 0;
          jsonObj.displayName = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.position = contactItem.position;
          jsonObj.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(jsonObj.contactId)) % 6];
          jsonObj.isUsuallyShow = false;
          jsonObj.favorite = 1;
          jsonObj.favoriteOrder = contactItem.favoriteOrder.toString();
          jsonObj.setShowName();
          jsonObj.setHeadChar();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'getAllFavorite data success!');
        callBack(resultList);
      });
    }
    HiLog.i(TAG, 'getAllFavorite end.');
  }

  /**
   * Query call records
   *
   * @param {string} daHelper
   * @param {Object} callBack call records
   */
  async getAllUsually(callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'getAllUsually start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findAllUsually((callLog: CallLog[]) => {
        if (ArrayUtil.isEmpty(callLog)) {
          let emptyResult: CallLog[] = [];
          callBack(emptyResult);
          return;
        }
        HiLog.i(TAG, 'getAllUsually data success! ');
        callBack(callLog);
      });
    }
    HiLog.i(TAG, 'getAllUsually end.');
  }

  /**
   * Query Recent Contacts By Raw_Contacts_Table
   *
   * @param {string} daHelper
   * @param {Object} callBack call records
   */
  async getAllUsuallyByRawContact(callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'getAllUsuallyByRawContact start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance()
        .findAllUsuallyByRawContact((favoriteList: ContactUsuallyListItem[]) => {
          if (ArrayUtil.isEmpty(favoriteList)) {
            let emptyResult: FavoriteBean[] = [];
            callBack(emptyResult);
            return;
          }
          let resultList: FavoriteBean[] = [];
          for (let i = 0; i < favoriteList.length; i++) {
            let jsonObj: FavoriteBean =
              new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
            jsonObj.contactId = favoriteList[i].id.toString();
            jsonObj.isCommonUseType = 1;
            jsonObj.displayName = favoriteList[i].displayName;
            jsonObj.namePrefix = favoriteList[i].sortFirstLetter;
            jsonObj.nameSuffix = favoriteList[i].photoFirstName;
            jsonObj.position = favoriteList[i].position;
            jsonObj.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(jsonObj.contactId)) % 6];
            jsonObj.isUsuallyShow = false;
            jsonObj.favorite = 0;
            jsonObj.phoneNum = favoriteList[i].detailInfo;
            jsonObj.setShowName();
            jsonObj.setHeadChar();
            resultList.push(jsonObj);
          }
          HiLog.i(TAG, 'getDisplayNamesFindUsually sc.');
          callBack(resultList);
        });
    }
    HiLog.i(TAG, 'getAllUsuallyByRawContact end.');
  }

  /**
   * DisplayName Query Favorite
   *
   * @param {string} daHelper
   * @param {Object} addParams Contact Information
   * @param {Object} callBack Contact Information
   */
  async getDisplayNamesFindUsually(displayName: ValueType[], usuallyPhone: ValueType[],
    callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'getDisplayNamesFindUsually start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance()
        .getDisplayNameByFavorite(displayName, usuallyPhone, (favoriteList: ContactUsuallyListItem[]) => {
          if (ArrayUtil.isEmpty(favoriteList)) {
            let emptyResult: FavoriteBean[] = [];
            callBack(emptyResult);
            return;
          }
          let resultList: FavoriteBean[] = [];
          for (let i = 0; i < favoriteList.length; i++) {
            let jsonObj: FavoriteBean =
              new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
            jsonObj.contactId = favoriteList[i].id.toString();
            jsonObj.isCommonUseType = 1;
            jsonObj.displayName = favoriteList[i].displayName;
            jsonObj.namePrefix = favoriteList[i].sortFirstLetter;
            jsonObj.nameSuffix = favoriteList[i].photoFirstName;
            jsonObj.position = favoriteList[i].position;
            jsonObj.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(jsonObj.contactId)) % 6];
            jsonObj.isUsuallyShow = false;
            jsonObj.favorite = 0;
            jsonObj.phoneNum = favoriteList[i].detailInfo;
            jsonObj.setShowName();
            jsonObj.setHeadChar();
            resultList.push(jsonObj);
          }
          HiLog.i(TAG, 'getDisplayNamesFindUsually sc.');
          callBack(resultList);
        });
    }
    HiLog.i(TAG, 'getDisplayNamesFindUsually end! ');
  }

  /**
   * Move Favorite Data Sorting
   *
   * @param {string} daHelper
   * @param {Object} addParams Contact Information
   * @param {Object} callBack favoriteOrder
   */
  async moveSortFavorite(daHelper: dataShare.DataShareHelper | null, addParams: LooseObject,
    callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'moveSortFavorite start.');
    if (daHelper == undefined || daHelper == null) {
      daHelper = await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    }
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('contact_id', addParams.id);
    const va: Record<string, number> = {
      'favorite_order': Number.parseInt(addParams.favoriteOrder)
    };
    daHelper.update(
      RawContacts.CONTENT_URI,
      condition,
      va
    ).then((data: number) => {
      if (data == -1) {
        HiLog.e(TAG, 'moveSortFavorite data failed!');
        callBack('');
        return;
      }
      HiLog.i(TAG, 'moveSortFavorite data success!');
      callBack(addParams.favoriteOrder);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'moveSortFavorite failed. Cause: ' + err?.code + ', message: ' + err?.message);
    });
    HiLog.i(TAG, 'End to update moveSortFavorite.');
  }

  /**
   * Querying the Mobile Numbers of Search Contacts
   *
   * @param {string} daHelper
   * @param {Object} callBack
   */
  async getSearchContact(actionData: IContactSearchParams, callBack: Function, context?: Context) {
    HiLog.i(TAG, 'getSearchContact start.');
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().searchContact(actionData, (contactList: ContactSearchResultData) => {
      if (ArrayUtil.isEmpty(contactList.data)) {
        HiLog.i(TAG, 'getSearchContact resultSet is empty!');
        let emptyResult: SearchContactsBean[] = [];
        contactList.data = emptyResult;
        callBack(contactList);
        return;
      }
      let resultList: SearchContactsBean[] = [];
      for (let contactItem of contactList.data) {
        let portraitColor: Resource = MorandiColor.color[Math.abs(Number(contactItem.contactId)) % 6];
        let jsonObj: SearchContactsBean =
          new SearchContactsBean('', '', '', '', '', '', '', '', '', 0, '', '', '', portraitColor, '', '');
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
        jsonObj.detailInfo = contactItem.detailInfo;
        jsonObj.hasPhoneNumber = contactItem.hasPhoneNumber;
        resultList.push(jsonObj);
      }
      contactList.data = resultList;
      callBack(contactList);
      HiLog.i(TAG, 'getSearchContact end.');
    });
  }

  getQueryT9PhoneNumbers(callBack: Function, addParams: IT9PhoneNumbersQueryParams,
    context?: common.UIAbilityContext) {
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
        let portraitColor: Resource = MorandiColor.color[Math.abs(contactItem.id) % 6];
        let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
        jsonObj.contactId = contactItem.id.toString();
        jsonObj.emptyNameData = contactItem.displayName;
        jsonObj.namePrefix = contactItem.sortFirstLetter;
        jsonObj.nameSuffix = contactItem.photoFirstName;
        jsonObj.company = contactItem.company;
        jsonObj.position = contactItem.position;
        jsonObj.show = false;
        jsonObj.phoneNumbers = contactItem.phoneNumbers;
        jsonObj.setShowName();
        jsonObj.setHeadChar();
        resultList.push(jsonObj);
      }
      callBack(resultList);
      HiLog.i(TAG, 'End of querying all contacts');
    });
  }

  /**
   * Add Group
   *
   * @param {Object} addParams Group name
   * @param {Object} callBack
   */
  async addGroup(groupName: string, groupAccountId: string, callBack?: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'Start to create a new contact.');
    if (groupName == undefined || groupName == '') {
      HiLog.e(TAG, 'The addParams of parameter is NULL');
      return;
    }
    let daHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    daHelper.insert(
      Contacts.GROUP_SYNC_URI,
      {
        'group_name': groupName,
        'lastest_modify_time': new Date().valueOf(),
        'account_id': groupAccountId
      }
    ).then((data: number) => {
      if (!data || data == -1) {
        HiLog.e(TAG, 'Data inserted failed');
        if (callBack != undefined) {
          callBack(data);
        }
        return;
      }
      HiLog.i(TAG, 'Start to create a new group.');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'logMessage insert error: ' + error?.code + ', message: ' + error?.message);
    });
    HiLog.i(TAG, 'End of creating a group.');
  }

  /**
   * Query groups
   *
   * @param {string} daHelper
   * @param {Object} callBack groupList
   */
  async getAllGroup(callBack: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findAllGroup((groupList: GroupListItem[]) => {
      if (ArrayUtil.isEmpty(groupList)) {
        let emptyResult: GroupBean[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: GroupBean[] = this.changeGroupListItemToGroupBeanList(groupList);
      HiLog.i(TAG, 'getAllGroup.');
      callBack(resultList);
    }
    );
    HiLog.i(TAG, 'getAllGroup end.');
  }

  changeGroupListItemToGroupBeanList(listItem: GroupListItem[]): GroupBean[] {
    let resultList: GroupBean[] = [];
    for (let index = 0; index < listItem.length; index++) {
      const element: GroupListItem = listItem[index];
      let groupBean: GroupBean = new GroupBean(element.id, element.accountId, element.groupName, element.groupNotes,
        element.isDeleted, element.groupRingtone, element.ringtoneModifyTime, element.lastestModifyTime,
        element.groupId, element.groupType);

      resultList.push(groupBean);
    }
    return resultList;
  }

  /**
   * Update groupName
   *
   * @param {string} daHelper
   * @param {Object}
   */
  async renameGroup(addParams: GroupParams, callBack?: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().renameGroup(addParams, (result: number) => {
      HiLog.i(TAG, `renameGroup result ${result}`);
      callBack!(result);
    });
  }

  async removeGroup(addParams: number, callBack?: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().removeGroup(addParams, (result: number) => {
      HiLog.i(TAG, `removeGroup result ${result}`);
      callBack!(result);
    });
  }

  async deleteGroupsById(addParams: number[], callBack?: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().deleteGroupsById(addParams, (result: number) => {
      HiLog.i(TAG, `deleteGroupsById result ${result}`);
      callBack!(result);
    });
  }

  async queryGroupItemByName(addParams: string, callBack?: Function, context?: common.UIAbilityContext) {

    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().queryGroupItemByName(addParams, (result: GroupBean | number) => {
      HiLog.i(TAG, `queryGroupItemByName result ${result}`);
      callBack!(result);
    });
  }

  async updateGroupMemberList(selectMemberList: string[],
    groupId: string, callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'updateGroupMemberList start.');
    let daHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    let uri = Data.CONTENT_URI + '?isFromBatch=true';
    let params: ValuesBucket[] = [];
    if (selectMemberList != undefined && selectMemberList.length > 0) {
      selectMemberList.forEach(element => {
        let contactData: ValuesBucket = {};
        contactData.detail_info = groupId;
        contactData.type_id = '9';
        contactData.raw_contact_id = element;
        params.push(contactData);
      });

      daHelper.batchInsert(uri, params).then((data: number) => {
        if (data == -1) {
          HiLog.e(TAG, 'groupsContact-insert data failed!');
        }
        HiLog.d(TAG, 'groupsContact-insert data success!');
        callBack(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'groupsContact-insert failed. Cause: ' + error?.code + ', message: ' + error?.message);
      });
    }
    if (callBack != undefined) {
      HiLog.d(TAG, 'Start the callback function.');
    }
  }

  // querying all group members
  async queryAllGroupMember(addParams: string, callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryAllGroupMember start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().queryAllGroupMember(addParams, (memberList: GroupMemberItem[]) => {
        if (ArrayUtil.isEmpty(memberList)) {
          let emptyResult: ContactVo[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: ContactVo[] = [];
        for (let contactItem of memberList) {
          if (this.isContainRepeat(resultList, contactItem.id.toString())) {
            HiLog.i(TAG, 'queryAllGroupMember has add same contact continue, contactId : ' + contactItem.id.toString());
            continue;
          }
          let portraitColor = MorandiColor.color[Math.abs(contactItem.id) % 6];
          let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.emptyNameData = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.company = contactItem.company;
          jsonObj.position = contactItem.position;
          jsonObj.rawContactId = contactItem.rawContactId.toString();
          jsonObj.phoneNumbers = contactItem.phoneNumbers;
          jsonObj.show = false;
          jsonObj.setShowName();
          jsonObj.setHeadChar();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'getAllFavorite data success!');
        callBack(resultList);
      });
    }
    HiLog.i(TAG, 'getAllFavorite end.');
  }

  /**
   * query contact category stastics order by company when company is not empty
   *
   * @param context context
   * @returns IntelligenceGroupInfo[] stastics arr
   */
  // instrument ignore next
  async queryStatisticInfoByOrganization(context: common.UIAbilityContext): Promise<IntelligenceGroupInfo[]> {
    HiLog.i(TAG, 'queryStatisticInfoByOrganization start');
    if (!context) {
      HiLog.e(TAG, 'queryStatisticInfoByOrganization param invalid.');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    let intelligenceGroupInfos: IntelligenceGroupInfo[] = [];
    try {
      let dataAbilityHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

      if (accountId != -1) {
        condition.equalTo(RawContacts.ACCOUNT_ID, accountId);
        condition.and();
      }
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      condition.and();
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      HiLog.i(TAG, 'queryStatisticInfoByOrganization update start');
      resultSet = await dataAbilityHelper.query(Contacts.INTELLIGENCE_GROUP_COMPANY_CLASSIFY_URI, condition,
        ContactListItem.COLUMNS_INTELLIGENCE_GROUP);
      if (resultSet === undefined) {
        HiLog.e(TAG, 'queryStatisticInfoByOrganization resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.e(TAG, 'queryStatisticInfoByOrganization resultSet is zero!');
      } else {
        resultSet.goToFirstRow();
        do {
          let company =
            resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY)).toString();
          let count =
            resultSet.getLong(resultSet.getColumnIndex('count'));
          if (!company) {
            HiLog.e(TAG, `intelligenc group company empty, count:${count}`);
            continue;
          }
          let tmpGroupInfo: IntelligenceGroupInfo = new IntelligenceGroupInfo(company, '0', count, false);
          intelligenceGroupInfos.push(tmpGroupInfo);
        } while (resultSet.goToNextRow());
      }
      HiLog.i(TAG, `queryStatisticInfoByOrganization res:${intelligenceGroupInfos?.length}`);
    } catch (err) {
      HiLog.e(TAG, `queryStatisticInfoByOrganization err:${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return intelligenceGroupInfos;
  }

  /**
   * query contact category stastics order by company when company is empty
   *
   * @param context context
   * @returns IntelligenceGroupInfo[] stastics arr
   */
  // instrument ignore next
  async queryStatisticInfoForNoOrganization(context: common.UIAbilityContext): Promise<IntelligenceGroupInfo[]> {
    HiLog.w(TAG, 'queryStatisticInfoForNoOrganization start');
    if (!context) {
      HiLog.e(TAG, 'queryStatisticInfoForNoOrganization param invalid.');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    let groupTmpArr: IntelligenceGroupInfo[] = [];
    try {
      let dataAbilityHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

      if (accountId != -1) {
        condition.equalTo(RawContacts.ACCOUNT_ID, accountId);
        condition.and();
      }
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      condition.and();
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0');
      resultSet = await dataAbilityHelper.query(Contacts.INTELLIGENCE_GROUP_NO_COMPANY_CLASSIFY_URI, condition,
        ContactListItem.COLUMNS_INTELLIGENCE_GROUP);
      if (resultSet === undefined) {
        HiLog.i(TAG, 'queryStatisticInfoForNoOrganization resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          let count =
            resultSet.getLong(resultSet.getColumnIndex('count'));
          let tmpGroupInfo: IntelligenceGroupInfo = new IntelligenceGroupInfo('', '0', count, true);
          groupTmpArr.push(tmpGroupInfo);
        } while (resultSet.goToNextRow());
      }
      HiLog.i(TAG, `queryStatisticInfoForNoOrganization success,${groupTmpArr?.length}`);
    } catch (err) {
      HiLog.e(TAG, `queryStatisticInfoForNoOrganization err:${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return groupTmpArr;
  }

  /**
   * query contact category stastics order by company
   *
   * @callBack callBack
   * @context context
   */
  // instrument ignore next
  async queryOrganizationIntelligenceGroupStatistic(callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryOrganizationIntelligenceGroupStatistic');
    if (!context) {
      HiLog.e(TAG, 'queryOrganizationIntelligenceGroupStatistic param invalid.');
      callBack([]);
      return;
    }
    ContactRepository.getInstance().init(context);
    let groupInfoHasCompany: IntelligenceGroupInfo[] = await this.queryStatisticInfoByOrganization(context);

    let groupInfoNoCompany: IntelligenceGroupInfo[] = await this.queryStatisticInfoForNoOrganization(context);
    HiLog.i(TAG,
      `queryOrganizationIntelligenceGroupStatistic: ${groupInfoHasCompany?.length},${groupInfoNoCompany?.length}`);

    if (groupInfoNoCompany && groupInfoNoCompany.length) {
      for (let groupTmp of groupInfoNoCompany) {
        groupInfoHasCompany.push(groupTmp);
      }
    }
    callBack(groupInfoHasCompany);
  }

  /**
   * query contact category stastics order by home area when city is not empty
   *
   * @param context context
   * @returns IntelligenceGroupInfo[] stastics arr
   */
  // instrument ignore next
  async queryStatisticInfoByCity(context: common.UIAbilityContext): Promise<IntelligenceGroupInfo[]> {
    HiLog.i(TAG, 'queryStatisticInfoByCity start');
    if (!context) {
      HiLog.e(TAG, 'queryStatisticInfoByCity param invalid');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    let intelligenceGroupInfos: IntelligenceGroupInfo[] = [];
    try {
      let dataAbilityHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

      if (accountId != -1) {
        condition.equalTo(RawContacts.ACCOUNT_ID, accountId);
        condition.and();
      }
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      condition.and();
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      resultSet = await dataAbilityHelper.query(Contacts.INTELLIGENCE_GROUP_CITY_CLASSIFY_URI, condition,
        ContactListItem.COLUMNS_LOCATION);
      if (resultSet === undefined) {
        HiLog.e(TAG, 'queryStatisticInfoByCity resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.e(TAG, 'queryStatisticInfoByCity resultSet is empty!');
      } else {
        resultSet.goToFirstRow();
        do {
          let location =
            resultSet.getString(resultSet.getColumnIndex(Contacts.LOCATION)).toString();
          let count =
            resultSet.getLong(resultSet.getColumnIndex('count'));
          if (!location) {
            HiLog.e(TAG, `queryStatisticInfoByCity loacation is empty,${count}`);
            continue;
          }
          let tmpGroupInfo: IntelligenceGroupInfo = new IntelligenceGroupInfo(location, '1', count, false);
          intelligenceGroupInfos.push(tmpGroupInfo);

        } while (resultSet.goToNextRow());
      }
      HiLog.i(TAG, 'queryStatisticInfoByCity update success');
    } catch (err) {
      HiLog.w(TAG, `queryStatisticInfoByCity err:${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return intelligenceGroupInfos;
  }

  /**
   * query contact category stastics order by home area when city is empty
   *
   * @param context context
   * @returns IntelligenceGroupInfo[] stastics arr
   */
  // instrument ignore next
  async queryStatisticInfoForNoCity(context: common.UIAbilityContext): Promise<IntelligenceGroupInfo[]> {
    HiLog.w(TAG, 'queryStatisticInfoForNoCity start');
    if (!context) {
      HiLog.e(TAG, 'queryStatisticInfoForNoCity param invalid');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    let intelligenceGroupInfos: IntelligenceGroupInfo[] = [];
    try {
      let dataAbilityHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

      if (accountId != -1) {
        condition.equalTo(RawContacts.ACCOUNT_ID, accountId);
        condition.and();
      }
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0');
      condition.and();
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      resultSet = await dataAbilityHelper.query(Contacts.INTELLIGENCE_GROUP_NO_CITY_CLASSIFY_URI, condition,
        ContactListItem.COLUMNS_LOCATION);
      if (resultSet === undefined) {
        HiLog.e(TAG, 'queryStatisticInfoForNoCity resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.e(TAG, 'queryStatisticInfoForNoCity resultSet is empty!');
      } else {
        resultSet.goToFirstRow();
        do {
          let count =
            resultSet.getLong(resultSet.getColumnIndex('count'));
          let tmpGroupInfo: IntelligenceGroupInfo = new IntelligenceGroupInfo('', '1', count, true);
          intelligenceGroupInfos.push(tmpGroupInfo);
        } while (resultSet.goToNextRow());
      }
      HiLog.i(TAG, 'queryStatisticInfoForNoCity update success');
    } catch (err) {
      HiLog.w(TAG, `queryStatisticInfoForNoCity err:${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return intelligenceGroupInfos;
  }

  /**
   * query contact category stastics order by home area
   *
   * @callBack callBack
   * @context context
   */
  async queryCityIntelligenceGroupStatistic(callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryCityIntelligenceGroupStatistic');
    if (!context) {
      HiLog.e(TAG, 'queryCityIntelligenceGroupStatistic param invalid.');
      callBack([]);
      return;
    }
    ContactRepository.getInstance().init(context);
    let groupInfoHasCity: IntelligenceGroupInfo[] = await this.queryStatisticInfoByCity(context);
    let groupInfoNoCity: IntelligenceGroupInfo[] = await this.queryStatisticInfoForNoCity(context);
    if (groupInfoNoCity && groupInfoNoCity.length) {
      for (let groupTmp of groupInfoNoCity) {
        groupInfoHasCity.push(groupTmp);
      }
    }
    HiLog.i(TAG,
      `queryCityIntelligenceGroupStatistic: ${groupInfoHasCity?.length},${groupInfoNoCity?.length}`);
    callBack(groupInfoHasCity);
  }

  /**
   * query contact category stastics order by contact time
   *
   * @callBack callBack
   * @context context
   */
  async queryLatestContactTimeIntelligenceGroupStatistic(callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryLatestContactTimeIntelligenceGroupStatistic');
    if (!context) {
      HiLog.e(TAG, 'queryLatestContactTimeIntelligenceGroupStatistic param invalid.');
      callBack([]);
      return;
    }
    let groupInfoByTimeStamp: IntelligenceGroupInfo[] = await this.queryStatisticInfoByLatestContactTime(context);
    HiLog.i(TAG,
      `queryLatestContactTimeIntelligenceGroupStatistic: ${groupInfoByTimeStamp?.length}`);
    callBack(groupInfoByTimeStamp);
  }

  /**
   * query contact category stastics order by contact time
   *
   * @param context context
   * @returns IntelligenceGroupInfo[] stastics arr
   */
  async queryStatisticInfoByLatestContactTime(context: common.UIAbilityContext): Promise<IntelligenceGroupInfo[]> {
    HiLog.i(TAG, 'queryStatisticInfoByLatestContactTime start');
    if (!context) {
      HiLog.e(TAG, 'queryStatisticInfoByLatestContactTime param invalid.');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    let intelligenceGroupInfos: IntelligenceGroupInfo[] = [];
    try {
      let dataAbilityHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

      if (accountId != -1) {
        condition.equalTo(RawContacts.ACCOUNT_ID, accountId);
        condition.and();
      }
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      condition.and();
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      resultSet = await dataAbilityHelper.query(Contacts.INTELLIGENCE_GROUP_LATEST_CONTACT_TIME_CLASSIFY_URI, condition,
        ContactListItem.COLUMNS_LATEST_CONTACT_TIME);
      if (resultSet === undefined) {
        HiLog.e(TAG, 'queryStatisticInfoByLatestContactTime resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.e(TAG, 'queryStatisticInfoByLatestContactTime resultSet is empty!');
      } else {
        resultSet.goToFirstRow();
        do {
          let type =
            resultSet.getString(resultSet.getColumnIndex(Contacts.TYPE)).toString();
          let count =
            resultSet.getLong(resultSet.getColumnIndex('count'));
          if (!type) {
            HiLog.e(TAG, `queryStatisticInfoByLatestContactTime type is empty:${count}`);
            continue;
          }
          let tmpGroupInfo: IntelligenceGroupInfo = new IntelligenceGroupInfo(type, '2', count, true);
          intelligenceGroupInfos.push(tmpGroupInfo);
        } while (resultSet.goToNextRow());
      }
    } catch (err) {
      HiLog.w(TAG, `queryStatisticInfoByLatestContactTime err:${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return intelligenceGroupInfos;
  }

  /**
   * query contact info by organization
   *
   * @param organization company
   * @callBack callBack
   * @context context
   */
  async queryIntelligenceGroupContactsByOrganization(organization: string, page: number, callBack: Function,
    context?: common.UIAbilityContext) {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganization :${organization?.length}`);
    if (!context) {
      HiLog.e(TAG, 'queryIntelligenceGroupContactsByOrganization param invalid.');
      callBack(undefined);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryIntelligenceGroupContactsByOrganization(organization, page, (resultSet?: DataShareResultSet) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: IContactListAndAlphabetIndex = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryIntelligenceGroupContactsByOrganization resultSet is empty!');
          callBack(callBackData);
          return;
        }

        if (resultSet.rowCount > 0) {
          resultSet.goToFirstRow();
          let index = 0;
          do {
            let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
            let portraitColor = MorandiColor.color[Math.abs(id) % 6];
            let contactInfo: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
            contactInfo.contactId = id.toString();
            contactInfo.nameRawContactId =
              resultSet.getLong(resultSet.getColumnIndex(Contacts.NAME_RAW_CONTACT_ID)).toString();
            contactInfo.emptyNameData = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
            // 联系人列表页，生成二级索引需要
            contactInfo.displayName = contactInfo.emptyNameData;
            contactInfo.namePrefix = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
            contactInfo.nameSuffix = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
            contactInfo.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            contactInfo.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
            contactInfo.sort = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT));
            contactInfo.sortKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_KEY));
            contactInfo.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
            contactInfo.show = false;
            contactInfo.setShowName();
            contactInfo.setHeadChar();
            resultList.push(contactInfo);
            this.addAlphabetIndexObj(contactInfo, index, alphabetIndex, index === resultSet.rowCount - 1);
            index++;
          } while (resultSet.goToNextRow());
        }
        callBack(callBackData);
        HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganization,${resultList?.length}`);
      });
  }

  /**
   * query contact info by home area
   *
   * @param location home area
   * @callBack callBack
   * @context context
   */
  async queryIntelligenceGroupContactsByCity(location: string, page: number, callBack: Function,
    context?: common.UIAbilityContext) {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByCity,${page}`);
    if (!context) {
      HiLog.e(TAG, 'queryIntelligenceGroupContactsByCity param invalid.');
      callBack(undefined);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryIntelligenceGroupContactsByCity(location, page, (resultSet?: DataShareResultSet) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: IContactListAndAlphabetIndex = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (resultSet === undefined) {
          HiLog.e(TAG, 'queryIntelligenceGroupContactsByCity resultSet is empty!');
          callBack(callBackData);
          return;
        }
        if (resultSet.rowCount === 0) {
          HiLog.e(TAG, 'queryIntelligenceGroupContactsByCity resultSet is empty!');
        } else {
          resultSet.goToFirstRow();
          let index = 0;
          do {
            let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
            let portraitColor = MorandiColor.color[Math.abs(id) % 6];
            let contactInfo: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
            contactInfo.contactId = id.toString();
            contactInfo.nameRawContactId =
              resultSet.getLong(resultSet.getColumnIndex(Contacts.NAME_RAW_CONTACT_ID)).toString();
            contactInfo.emptyNameData = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
            // 联系人列表页，生成二级索引需要
            contactInfo.displayName = contactInfo.emptyNameData;
            contactInfo.namePrefix = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
            contactInfo.nameSuffix = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
            contactInfo.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            contactInfo.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
            contactInfo.sort = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT));
            contactInfo.sortKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_KEY));
            contactInfo.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
            contactInfo.show = false;
            contactInfo.setShowName();
            contactInfo.setHeadChar();
            resultList.push(contactInfo);
            this.addAlphabetIndexObj(contactInfo, index, alphabetIndex, index === resultSet.rowCount - 1);
            index++;
          } while (resultSet.goToNextRow());
        }
        callBack(callBackData);
        HiLog.i(TAG, 'End of querying all contacts');
      });
  }

  /**
   * batch update contact company by contactids
   *
   * @param contactIds contactIds
   * @param company company
   * @param callBack callBack
   * @param context context
   */
  async updateContactOrganizationInfo(contactIds: number[], company: string, callBack: Function,
    context?: common.UIAbilityContext) {
    HiLog.i(TAG, `updateContactOrganizationInfo result: ${TextUtils.getMaskString(company)}`);
    if (!contactIds || contactIds.length === 0 || !context) {
      HiLog.e(TAG, 'updateContactOrganizationInfo param invalid.');
      return;
    }
    if (context) {
      ContactRepository.getInstance().init(context);
      await ContactRepository.getInstance().updateOrganizationToContact(contactIds, company, (result: boolean) => {
        HiLog.i(TAG, `updateContactOrganizationInfo result: ${result}`);
      });

      for (let contactId of contactIds) {
        // 根据contactid查询rawcontactid,再根据rawcontactid更新单位
        let rawContactIdList = await ContactRepository.getInstance().getNumberRawContactIdsByContactId(contactId);
        await ContactRepository.getInstance()
          .updateOrganizationToContactData(rawContactIdList, company, (result: boolean) => {
            HiLog.i(TAG, `updateContactOrganizationInfo result: ${result}`);
          });
      }
      callBack(true)
    }
  }

  /**
   * query contact info by Timestamp
   *
   * @param contactTimeType Timestamp type
   * @callBack callBack
   * @context context
   */
  async queryIntelligenceGroupContactsByTimestamp(contactTimeType: string, page: number, callBack: Function,
    context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryIntelligenceGroupContactsByTimestamp');
    if (!context) {
      HiLog.e(TAG, 'queryIntelligenceGroupContactsByOrganization param invalid.');
      callBack(undefined);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryIntelligenceGroupContactsByTimestamp(contactTimeType, page, (resultSet?: DataShareResultSet) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: IContactListAndAlphabetIndex = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryIntelligenceGroupContactsByTimestamp resultSet is empty!');
          callBack(callBackData);
          return;
        }
        if (resultSet.rowCount > 0) {
          resultSet.goToFirstRow();
          let index = 0;
          do {
            let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
            let portraitColor = MorandiColor.color[Math.abs(id) % 6];
            let contactTmp: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
            contactTmp.contactId = id.toString();
            contactTmp.nameRawContactId =
              resultSet.getLong(resultSet.getColumnIndex(Contacts.NAME_RAW_CONTACT_ID)).toString();
            contactTmp.emptyNameData = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
            // 联系人列表页，生成二级索引需要
            contactTmp.displayName = contactTmp.emptyNameData;
            contactTmp.namePrefix = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
            contactTmp.nameSuffix = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
            contactTmp.company = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            contactTmp.position = resultSet.getString(resultSet.getColumnIndex(Contacts.POSITION));
            contactTmp.sort = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT));
            contactTmp.sortKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_KEY));
            contactTmp.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
            contactTmp.favorite = resultSet.getString(resultSet.getColumnIndex(RawContacts.FAVORITE));
            contactTmp.show = false;
            contactTmp.setShowName();
            contactTmp.setHeadChar();
            resultList.push(contactTmp);
            this.addAlphabetIndexObj(contactTmp, index, alphabetIndex, index === resultSet.rowCount - 1);
            index++;
          } while (resultSet.goToNextRow());
        }
        callBack(callBackData);
        HiLog.i(TAG, 'End of querying all contacts');
      });
  }

  /**
   * query contact info by company for batch send message
   *
   * @callBack callBack
   * @param organization company
   * @context context
   */
  async intelligenceGroupQueryContactsForSendMsgByOrganization(callBack: Function,
    organization: string, context?: common.UIAbilityContext) {
    HiLog.i(TAG, `intelligenceGroupQueryContactsForSendMsgByOriganization: ${organization?.length}`);
    if (!context) {
      HiLog.e(TAG, 'intelligenceGroupQueryContactsForSendMsgByOriganization param invalid.');
      callBack([]);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryContactsByOriganizationForSendMsg(organization, (contactList: ContactListItem[]) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: ContactInfoGetParamsInCallback = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (ArrayUtil.isEmpty(contactList)) {
          HiLog.i(TAG, 'intelligenceGroupQueryContactsForSendMsgByOriganization resultSet is empty!');
          callBack(callBackData);
          return;
        }

        contactList.forEach((contactItem, index: number) => {
          let contactTmp: ContactVo = new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '');
          contactTmp.contactId = contactItem.id.toString();
          contactTmp.emptyNameData = contactItem.displayName;
          contactTmp.namePrefix = contactItem.sortFirstLetter;
          contactTmp.displayName = contactItem.displayName;
          contactTmp.nameSuffix = contactItem.photoFirstName;
          contactTmp.company = contactItem.company;
          contactTmp.position = contactItem.position;
          contactTmp.extra3 = contactItem.extra3;
          contactTmp.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(contactTmp.contactId)) % 6];
          contactTmp.show = false;
          contactTmp.phoneNumbers = contactItem.phoneNumbers;
          // 设置显示的名字
          contactTmp.setShowName();
          // 设置头像文字
          contactTmp.setHeadChar();
          contactTmp.nameRawContactId = contactItem.nameRawContactId.toString();
          contactTmp.favorite = contactItem.favorite;
          contactTmp.quickSearchKey = contactItem.quickSearchKey;

          resultList.push(contactTmp);
          // 添加二级索引相关
          this.addAlphabetIndexObj(contactTmp, index, alphabetIndex, index === contactList.length - 1);
        });
        callBack(callBackData);
        HiLog.i(TAG, `intelligenceGroupQueryContactsForSendMsgByOriganization end: ${resultList.length}`);
      });
  }

  /**
   * query contact info by location for batch send message
   *
   * @callBack callBack
   * @param location city
   * @context context
   */
  async intelligenceGroupQueryContactsForSendMsgByCity(callBack: Function,
    location: string, context?: common.UIAbilityContext) {
    HiLog.i(TAG, `intelligenceGroupQueryContactsForSendMsgByCity start,${TextUtils.getMaskString(location)}`);
    if (!context) {
      HiLog.e(TAG, 'intelligenceGroupQueryContactsForSendMsgByCity param invalid.');
      callBack([]);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryContactsByCityForSendMsg(location, (contactList: ContactListItem[]) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: ContactInfoGetParamsInCallback = {
          contactList: resultList, // 联系人集合
          alphabetIndex: alphabetIndex // 二级索引相关对象
        };
        if (ArrayUtil.isEmpty(contactList)) {
          HiLog.i(TAG, 'intelligenceGroupQueryContactsForSendMsgByCity resultSet is empty!');
          callBack(callBackData);
          return;
        }

        contactList.forEach((contactItem, index: number) => {
          let contactForMsg: ContactVo = new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '');
          contactForMsg.contactId = contactItem.id.toString();
          contactForMsg.emptyNameData = contactItem.displayName;
          contactForMsg.namePrefix = contactItem.sortFirstLetter;
          contactForMsg.displayName = contactItem.displayName;
          contactForMsg.nameSuffix = contactItem.photoFirstName;
          contactForMsg.company = contactItem.company;
          contactForMsg.position = contactItem.position;
          contactForMsg.extra3 = contactItem.extra3;
          contactForMsg.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(contactForMsg.contactId)) % 6];
          contactForMsg.show = false;
          contactForMsg.phoneNumbers = contactItem.phoneNumbers;
          // 设置显示的名字
          contactForMsg.setShowName();
          // 设置头像文字
          contactForMsg.setHeadChar();
          contactForMsg.nameRawContactId = contactItem.nameRawContactId.toString();
          contactForMsg.favorite = contactItem.favorite;
          contactForMsg.quickSearchKey = contactItem.quickSearchKey;

          resultList.push(contactForMsg);
          // 添加二级索引相关
          this.addAlphabetIndexObj(contactForMsg, index, alphabetIndex, index === contactList.length - 1);
        });
        callBack(callBackData);
        HiLog.i(TAG, `intelligenceGroupQueryContactsForSendMsgByTimestamp end: ${resultList.length}`);
      });
  }

  /**
   * query contact info by contactTime for batch send message
   *
   * @callBack callBack
   * @param contactTimeType contactTimeType
   * @context context
   */
  async intelligenceGroupQueryContactsForSendMsgByTimestamp(callBack: Function,
    contactTimeType: string, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'queryIntelligenceGroupSendMsg start.');
    if (!context) {
      HiLog.e(TAG, 'queryIntelligenceGroupContactsByOrganization param invalid.');
      callBack([]);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance()
      .queryContactsByTimestampForSendMsg(contactTimeType, (contactList: ContactListItem[]) => {
        let resultList: ContactVo[] = [];
        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let callBackData: ContactInfoGetParamsInCallback = {
          contactList: resultList,
          alphabetIndex: alphabetIndex // index object
        };
        if (ArrayUtil.isEmpty(contactList)) {
          HiLog.i(TAG, 'intelligenceGroupQueryContactsForSendMsgByTimestampresultSet is empty!');
          callBack(callBackData);
          return;
        }

        contactList.forEach((contactItem, index: number) => {
          let contactForMsg: ContactVo = new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '');
          contactForMsg.contactId = contactItem.id.toString();
          contactForMsg.emptyNameData = contactItem.displayName;
          contactForMsg.namePrefix = contactItem.sortFirstLetter;
          contactForMsg.displayName = contactItem.displayName;
          contactForMsg.nameSuffix = contactItem.photoFirstName;
          contactForMsg.company = contactItem.company;
          contactForMsg.position = contactItem.position;
          contactForMsg.extra3 = contactItem.extra3;
          contactForMsg.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(contactForMsg.contactId)) % 6];
          contactForMsg.show = false;
          contactForMsg.phoneNumbers = contactItem.phoneNumbers;
          // 设置显示的名字
          contactForMsg.setShowName();
          // 设置头像文字
          contactForMsg.setHeadChar();
          contactForMsg.nameRawContactId = contactItem.nameRawContactId.toString();
          contactForMsg.favorite = contactItem.favorite;
          contactForMsg.quickSearchKey = contactItem.quickSearchKey;

          resultList.push(contactForMsg);
          // 添加二级索引相关
          this.addAlphabetIndexObj(contactForMsg, index, alphabetIndex, index === contactList.length - 1);
        });
        callBack(callBackData);
        HiLog.i(TAG, `intelligenceGroupQueryContactsForSendMsgByTimestamp end: ${resultList.length}`);
      });
  }

  isContainRepeat(resultList: ContactVo[], contactId: string): boolean {
    let result = resultList.filter(item => {
      return item.contactId == contactId;
    });
    return result.length > 0;
  }

  async findMemberByPhoneIsNotNull(addParams: number, callBack: Function, context?: common.UIAbilityContext) {
    HiLog.i(TAG, 'findMemberByPhoneIsNotNull start.');
    if (context) {
      ContactRepository.getInstance().init(context);
      ContactRepository.getInstance().findMemberByPhoneIsNotNull(addParams, (memberList: GroupMemberItem[]) => {
        if (ArrayUtil.isEmpty(memberList)) {
          let emptyResult: ContactVo[] = [];
          callBack(emptyResult);
          return;
        }
        let resultList: ContactVo[] = [];
        for (let contactItem of memberList) {
          let portraitColor = MorandiColor.color[Math.abs(contactItem.id) % 6];
          let jsonObj: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
          jsonObj.contactId = contactItem.id.toString();
          jsonObj.emptyNameData = contactItem.displayName;
          jsonObj.namePrefix = contactItem.sortFirstLetter;
          jsonObj.nameSuffix = contactItem.photoFirstName;
          jsonObj.company = contactItem.company;
          jsonObj.position = contactItem.position;
          jsonObj.rawContactId = contactItem.rawContactId.toString();
          jsonObj.phoneNumbers = contactItem.phoneNumbers;
          jsonObj.show = false;
          jsonObj.setShowName();
          jsonObj.setHeadChar();
          resultList.push(jsonObj);
        }
        HiLog.i(TAG, 'findMemberByPhoneIsNotNull data success!');
        callBack(resultList);
      });
    }
    HiLog.i(TAG, 'findMemberByPhoneIsNotNull end.');
  }

  async deleteMemberByGroupId(id: string, callBack?: Function, context?: common.UIAbilityContext) {

    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().deleteMemberByGroupId(id, (result: number) => {
      HiLog.i(TAG, `deleteMemberByGroupId result ${result}`);
      callBack!(result);
    });
  }

  async deleteMembers(groupId: string, contactId: number[],
    callBack?: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().deleteMembers(groupId, contactId, (result: number) => {
      HiLog.i(TAG, `deleteMembers result ${result}`);
      callBack!(result);
    }
    );
  }

  async activateRestore(context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().activateRestore();
  }

  async copyContact(copyList: LooseObject[], context: common.UIAbilityContext, accountId: number, callback: Function) {
    // query raw_contact
    if (copyList == null || copyList == undefined || accountId == undefined) {
      HiLog.e(TAG, 'The copyList of parameter is NULL');
      callback(0);
    }
    HiLog.i(TAG, 'copyContact start. copyList :' + copyList.length);

    let daHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    let insertNum = 0;
    HiLog.i(TAG, 'copyContact daHelper get ');
    copyList.forEach((contact, index) => {
      if (!ObjectUtil.isEmpty(contact)) {
        let insertValues: ValuesBucket = {
          'display_name': contact.name,
          'account_id': accountId
        };
        daHelper.insert(RawContacts.CONTENT_URI, insertValues).then((data: number) => {
          if (data == -1 || data == undefined) {
            HiLog.e(TAG, 'Data inserted failed');
            callback(0);
          }
          let option = new dataSharePredicates.DataSharePredicates();
          option.equalTo(RawContactsColumns.CONTACT_ID, contact.contactId);
          HiLog.i(TAG, 'copyContact query contact_data start!');
          daHelper.query(Data.CONTENT_URI, option, []).then((resultSet: DataShareResultSet) => {
            try {
              HiLog.i(TAG, 'copyContact query contact_data  rowCount is:' + resultSet.rowCount);
              // insert contact_data
              if (resultSet.rowCount === 0) {
                HiLog.e(TAG, 'copyContact query contact_data err.');
                callback(0);
              }
              HiLog.i(TAG, 'copyContact query contact_data is succeed!');
              let params = this.setContactData(resultSet, data, data, false, false);
              HiLog.i(TAG, 'copyContact query contact_data params length: ' + params?.length);
              HiLog.i(TAG, 'copyContact  contact_data batchInsert start');
              daHelper.batchInsert(Data.CONTENT_URI, params).then((data: number) => {
                HiLog.i(TAG, 'copyContact contact_data inserted succeed,data is :' + data);
                if (data == -1 || data == undefined) {
                  HiLog.e(TAG, 'Data inserted failed');
                  callback(0);
                }
                insertNum += params.length;
                HiLog.i(TAG, 'copyContact contact_data inserted succeed,insertNum is :' + insertNum);
                if (index != 0 && index == copyList.length - 1) {
                  callback(insertNum);
                }
              }).catch((error: BusinessError) => {
                HiLog.e(TAG,
                  'copyContact contact_data batch insert error: ' + error?.code + ', message: ' + error?.message);
                callback(0);
              });
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          }).catch((error: BusinessError) => {
            HiLog.e(TAG, 'copyContact contact_data query error: ' + error?.code + ', message: ' + error?.message);
            callback(0);
          });

        });

      }
    });
    HiLog.i(TAG, 'End of creating a contact.');
  }

  /**
   * Query all recent delete contacts
   *
   * @param {string} daHelper
   * @param {Object} callBack deleteContactList
   */
  async getAllRecentDeleteContacts(callBack: Function, context?: common.UIAbilityContext) {
    if (context) {
      ContactRepository.getInstance().init(context);
    }
    ContactRepository.getInstance().findAllRecentDeleteContacts((deleteContactList: RecentDeleteListItem[]) => {
      if (ArrayUtil.isEmpty(deleteContactList)) {
        HiLog.w(TAG, 'getAllRecentDeleteContacts is empty');
        let emptyResult: RecentDeleteBean[] = [];
        callBack(emptyResult);
        return;
      }
      let resultList: RecentDeleteBean[] = this.changeRecentListItemToRecentBeanList(deleteContactList);
      HiLog.w(TAG, 'getAllRecentDeleteContacts.');
      callBack(resultList);
    });
    HiLog.w(TAG, 'getAllRecentDeleteContacts end.');
  }

  /**
   * change Recent List Item To Recent BeanList
   *
   * @param listItem
   */
  changeRecentListItemToRecentBeanList(listItem: RecentDeleteListItem[]): RecentDeleteBean[] {
    let resultList: RecentDeleteBean[] = [];
    for (let index = 0; index < listItem.length; index++) {
      const element: RecentDeleteListItem = listItem[index];
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(element.id, element.displayName, element.deleteSource,
          element.deleteTime, element.isChecked);
      resultList.push(recentDeleteBean);
    }
    return resultList;
  }

  setContactData(resultSet: DataShareResultSet, newContactId: number, newRawContactId: number,
    nameFlag: boolean, theSamePhone: boolean): ValuesBucket[] {
    resultSet.goToFirstRow();
    let vbs: ValuesBucket[] = [];
    let hasSameEmail = true;
    do {
      let contactData: ValuesBucket = {};
      contactData.type_id = resultSet.getLong(resultSet.getColumnIndex(Data.TYPE_ID));
      if (nameFlag && contactData.type_id == 6) {
        continue;
      }
      if (theSamePhone && contactData.type_id == 5) {
        continue;
      }
      if (nameFlag && (contactData.type_id == 3)) {
        if (!hasNickName) {
          continue;
        }
        if (resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)) == '') {
          continue;
        } else {
          hasNickName = false;
        }
      }
      if (nameFlag && (contactData.type_id == 4)) {
        if (!hasOrganization) {
          continue;
        }
        if (resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)) == '') {
          continue;
        } else {
          hasOrganization = false;
        }
      }
      if (nameFlag && (contactData.type_id == 1) &&
        (newContactId == resultSet.getLong(resultSet.getColumnIndex(RawContactsColumns.CONTACT_ID)))) {
        if (resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)) !== '') {
          emailList.add(resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)));
        }
        continue;
      }
      if (nameFlag && (contactData.type_id == 1)) {
        if (emailList.length !== 0) {
          emailList.forEach(email => {
            if (email == resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO))) {
              hasSameEmail = false;
            }
          });
        }
        if (!hasSameEmail) {
          hasSameEmail = true;
          continue;
        }
      }
      // TODO newContactId修改为raw_contact_id
      contactData.raw_contact_id = newRawContactId;
      contactData.read_only = resultSet.getLong(resultSet.getColumnIndex(Data.READ_ONLY));
      contactData.version = resultSet.getLong(resultSet.getColumnIndex(Data.VERSION));
      contactData.is_preferred_number = resultSet.getLong(resultSet.getColumnIndex(Data.IS_PREFERRED_NUMBER));
      contactData.detail_info = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
      contactData.family_name = resultSet.getString(resultSet.getColumnIndex(Data.FAMILY_NAME));
      contactData.middle_name_phonetic = resultSet.getString(resultSet.getColumnIndex(Data.MIDDLE_NAME_PHONETIC));
      contactData.given_name = resultSet.getString(resultSet.getColumnIndex(Data.GIVEN_NAME));
      contactData.given_name_phonetic = resultSet.getString(resultSet.getColumnIndex(Data.GIVEN_NAME_PHONETIC));
      contactData.alias_detail_info = resultSet.getString(resultSet.getColumnIndex(Data.ALIAS_DETAIL_INTO));
      contactData.phonetic_name = resultSet.getString(resultSet.getColumnIndex(Data.PHONETIC_NAME));
      contactData.position = resultSet.getString(resultSet.getColumnIndex(Data.POSITION));
      contactData.extend1 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND1));
      contactData.extend2 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND2));
      contactData.extend3 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND3));
      contactData.extend4 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND4));
      contactData.city = resultSet.getString(resultSet.getColumnIndex(Data.CITY));
      contactData.country = resultSet.getString(resultSet.getColumnIndex(Data.COUNTRY));
      contactData.neighborhood = resultSet.getString(resultSet.getColumnIndex(Data.NEIGHBORHOOD));
      contactData.pobox = resultSet.getString(resultSet.getColumnIndex(Data.POBOX));
      contactData.postcode = resultSet.getString(resultSet.getColumnIndex(Data.POSTCODE));
      contactData.region = resultSet.getString(resultSet.getColumnIndex(Data.REGION));
      contactData.street = resultSet.getString(resultSet.getColumnIndex(Data.STREET));
      contactData.alpha_name = resultSet.getString(resultSet.getColumnIndex(Data.ALPHA_NAME));
      contactData.other_lan_last_name = resultSet.getString(resultSet.getColumnIndex(Data.OTHER_LAN_LAST_NAME));
      contactData.other_lan_first_name = resultSet.getString(resultSet.getColumnIndex(Data.OTHER_LAN_FIRST_NAME));
      contactData.extend5 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND5));
      contactData.lan_style = resultSet.getString(resultSet.getColumnIndex(Data.LAN_STYLE));
      contactData.custom_data = resultSet.getString(resultSet.getColumnIndex(Data.CUSTOM_DATA));
      contactData.extend6 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND6));
      contactData.extend7 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7));
      contactData.blob_data = resultSet.getBlob(resultSet.getColumnIndex(Data.BLOB_DATA));
      contactData.blob_data = contactData.blob_data ? contactData.blob_data : null;
      contactData.syn_1 = resultSet.getString(resultSet.getColumnIndex(Data.SYN_1));
      contactData.syn_2 = resultSet.getString(resultSet.getColumnIndex(Data.SYN_2));
      contactData.syn_3 = resultSet.getString(resultSet.getColumnIndex(Data.SYN_3));
      contactData.extend8 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND8));
      contactData.extend9 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND9));
      contactData.extend10 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND10));
      contactData.extend11 = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND11));
      vbs.push(contactData);
    } while (resultSet.goToNextRow());
    return vbs;
  }
}

export default new ContactAbilityModel();

export const dealContactPhoto = (contactId: string, context: Context,
  photo: Uint8Array | null, needAddNewPhoto: boolean,
  needUpdatePhoto: boolean, needDeletePhoto: boolean, blobSource: number) => {
  let task = new taskpool.Task(setPhotoToDb, contactId, context,
    photo as Uint8Array, needAddNewPhoto, needUpdatePhoto, needDeletePhoto, blobSource);
  taskpool.execute(task);
};

@Concurrent
async function setPhotoToDb(contactId: string, context: Context, photo: Uint8Array | null,
  needAddNewPhoto: boolean, needUpdatePhoto: boolean, needDeletePhoto: boolean, blobSource: number) {
  ContactRepository.getInstance().init(context)
    .findRawIdById(Number(contactId), async (rawContactIdArr: string[]) => {
      const TAG: string = 'dealContactPhoto ';
      if (ArrayUtil.isEmpty(rawContactIdArr)) {
        HiLog.e(TAG, 'contactId: ' + contactId + ' find rawcontactid is empty!');
        return;
      }
      let rawContactId = rawContactIdArr[0];
      await ContactRepository.getInstance()
        .savePhotoToDb(contactId, rawContactIdArr, context, photo, needAddNewPhoto, needUpdatePhoto, needDeletePhoto,
          blobSource);
    });
}

@Concurrent
export async function searchContactByPhoneNumAndDisplayNameForLimit(searchKey: string, page: number, limit: number,
  context: Context): Promise<Object> {
  let resultList: SearchContactResult[] = [];
  const TAG: string = 'ContactAbilityModel ';
  if (TextUtils.isEmpty(searchKey) || !context || page < 0 || limit < 0) {
    HiLog.i(TAG, 'searchContactByPhoneNumAndDisplayNameForLimit param invalid!');
    return [];
  }
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    let daHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    let columns = ['contact_id', 'detail_info', 'company', 'type_id', 'display_name', 'contacted_count'];
    // 电话号码正则
    let pattern = /^[0-9#+*]+$/;
    let condition = new dataSharePredicates.DataSharePredicates();

    let offset = ArrayUtil.getOffetByPageAndLimit(page, limit);
    condition.limit(limit, offset)
    let isDigital = pattern.test(searchKey);
    HiLog.i(TAG, `searchContactByPhoneNumAndDisplayNameForLimit start,${isDigital},${searchKey.length},${page},${limit}.`);
    if (isDigital) {
      // 搜索的key是电话号码,匹配联系人名称和电话号码,type_id为5的匹配电话号码,数据中也有联系人名称
      condition.equalTo('type_id', 5);
      condition.and()
      condition.beginWrap()
      if (searchKey.length > 1) {
        condition.like('detail_info', '%' + searchKey + '%')
      } else {
        condition.beginsWith('detail_info', searchKey)
      }
      condition.or()
      condition.like('display_name', '%' + searchKey + '%');
      condition.endWrap()
      condition.and()
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      condition.and()
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1')
      condition.groupBy(['contact_id']);
      resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
      if (resultSet === undefined) {
        HiLog.i(TAG, 'searchContactByPhoneNumAndDisplayNameForLimit resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.i(TAG, 'searchContactByPhoneNumAndDisplayNameForLimit rowCount is zero.');
      } else {
        resultSet.goToFirstRow();
        do {
          let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
          let contactInfo: SearchContactResult =
            new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
          contactInfo.entityId = contactId.toString();
          let phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info')).toString();
          let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
          let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
          if (name.indexOf(searchKey) != -1) {
            let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');
            contactInfo.name = highlightName;
            contactInfo.sortValue =
              SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
          } else {
            let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
            let phoneNumberObj: DbSearchPhoneNumberObj = new DbSearchPhoneNumberObj('1', '', highlightPhoneNumber);
            contactInfo.phoneNumbers = [phoneNumberObj];
            contactInfo.name = name;
            contactInfo.sortValue =
              SearchUtils.calcPhoneNumberSortValue(phoneNumber, contactedCount, searchKey);
          }
          contactInfo.organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
          resultList.push(contactInfo);
        } while (resultSet.goToNextRow());
      }
    } else {
      // 搜索的key非数字,只匹配联系人名称
      condition.equalTo('type_id', 6);
      condition.and()
      condition.like('detail_info', '%' + searchKey + '%');
      condition.and()
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      condition.and()
      // 查询我的名片信息
      condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
      condition.groupBy(['contact_id']);
      resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
      if (resultSet === undefined) {
        HiLog.i(TAG, 'searchContactByPhoneNumAndDisplayNameForLimit resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.i(TAG, 'searchContactByPhoneNumAndDisplayNameForLimit rowCount is zero.');
      } else {
        resultSet.goToFirstRow();
        do {
          let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
          let contactInfo: SearchContactResult =
            new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
          contactInfo.entityId = contactId.toString();
          let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
          // 只匹配了联系人名称需要使用em标签进行高亮
          let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
          let upperCaseName = name.toUpperCase();
          let upperCaseSearchKey = searchKey.toUpperCase();
          contactInfo.sortValue =
            SearchUtils.calcContactNameSortValue(upperCaseName, contactedCount, upperCaseSearchKey);
          contactInfo.name = SearchUtils.getHighlightName(name, searchKey);
          contactInfo.organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
          resultList.push(contactInfo);
        } while (resultSet.goToNextRow());
      }
    }
    HiLog.i(TAG, `searchContactByPhoneNumAndDisplayNameForLimit end=${resultList.length}`);
    resultList = resultList.sort((result1, result2) => result1.sortValue - result2.sortValue);
    return resultList;
  } catch (error) {
    HiLog.e(TAG, `searchContactByPhoneNumAndDisplayNameForLimit error: code: ${error.code}, message: ${error.message}`);
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
  return [];
}