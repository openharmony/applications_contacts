/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import IContactRepository from './IContactRepository';
import RawContact from '../entity/RawContact';
import ContactBuilder from '../entity/ContactBuilder';
import { DataItem } from '../entity/DataItem';
import { NumberMatch } from '../cust/NumberMatch';
import { RawContacts } from '../contract/RawContacts';
import ContactsColumns from '../contract/ContactsColumns';
import { Contacts } from '../contract/Contacts';
import { Data } from '../contract/Data';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  ContactSearchResultData,
  CountAlphabetIndex,
  CountRawContact,
  IContactSearchParams,
  IT9PhoneNumbersFavoriteType,
  NameFixInfo,
  PickerShowSubData
} from '../../../../../../entry/src/main/ets/model/type/ContactParams';
import ContactListItem from './ContactListItem';
import { DataItemType } from '../contract/DataType';
import Calls from '../../../../../call/src/main/ets/contract/Calls';
import { CallLog } from '../../../../../call/src/main/ets/entity/CallLog';
import CallLogBuilder from '../../../../../call/src/main/ets/entity/CallLogBuilder';
import { SearchContacts } from '../contract/SearchContacts';
import SearchContactListItem from './SearchContactListItem';
import ContactUsuallyListItem, { ContactUsuallyListItemHasPhones } from './ContactUsuallyListItem';
import GroupMemberItem from './GroupMemberItem';
import { AlphabetIndexObj } from '../../../../../../entry/src/main/ets/model/bean/ContactVo';
import { AccountVo } from '../../../../../../entry/src/main/ets/model/bean/AccountVo';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { BusinessError } from '@ohos.base';
import { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket';
import {
  ContactBlobSource,
  GroupParams,
  PhoneNumberInterface,
  FindPhotoByIdActionData
} from '../../../../../../entry/src/main/ets/model/type';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import GroupListItem from './GroupListItem';
import RowGroup from '../contract/RowGroup';
import { GroupBean } from '../../../../../../entry/src/main/ets/model/bean/GroupBean';
import MeeTimeAbilityInfoModel from '../entity/MeeTimeAbilityInfoModel';
import DataColumns from '../contract/DataColumns';
import { sharedPreferencesUtils } from '../../../../../call/oh_modules/common/src/main/ets/util/SharedPreferencesUtils';
import ContactNameNumberInfo from '../entity/ContactNameNumberInfo';
import hiTraceMeter from '@ohos.hiTraceMeter';
import common from '@ohos.app.ability.common';
import BlockList, { BlockType } from '../contract/BlockList';
import YellowPage from '../contract/YellowPage';
import { emitter, osAccount } from '@kit.BasicServicesKit';
import { RoamingData, UpdateFormatNumerParam } from 'common/src/main/ets/util/RoamingUtils';
import DotUtil from '../../../../../../entry/src/main/ets/util/DotUtil';
import dotCommon, { faultContactParams } from '../../../../../../entry/src/main/ets/util/DotCommon';
import RecentDeleteListItem from './RecentDeleteListItem';
import DeletedRawContactsColumns from '../contract/DeletedRawContactsColumns';
import RawContactsColumns from '../contract/RawContactsColumns';
import I18n from '@ohos.i18n';
import call from '@ohos.telephony.call';
import BlockListContact, { IsBlockContact } from '../entity/BlockListContact';
import EmitterConstant from '../../../../../../entry/src/main/ets/data/EmitterConstant';
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
import { contact } from '@kit.ContactsKit';
import { Phone } from '../contract/Phone';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { Email } from '../contract/Email';
import { Aim } from '../contract/Aim';
import { House } from '../contract/House';
import { Birthday } from '../contract/Birthday';
import { Relation } from '../contract/Relation';
import { dataAbility } from '@kit.ArkData';
import fs from '@ohos.file.fs';
import GroupIdUtil from '../../../../../../entry/src/main/ets/util/GroupIdUtil';
import { ContactPhotoVo, buildContactPhotoVo } from '../../../../../../entry/src/main/ets/util/UserPhoto'
import { Action } from '@ohos.multimodalInput.keyEvent';
import { AuditLogUtils, UtilAuditLog } from '../../../../../../common/src/main/ets/util/AuditLogUtils';
import taskPool from '@ohos.taskpool';
import { HashMap } from '@kit.ArkTS';
import Contact from '../entity/Contact';
import ContactListActItem from './ContactListActItem';
import { SearchContactResult } from '../entity/SearchContactResult';
import { DbSearchPhoneNumberObj } from '../entity/DbSearchPhoneNumberObj';
import { CallLogTemp, PhoneNum } from '../../../../../call/src/main/ets/entity/CallLogTemp';
import TextUtils from 'common/src/main/ets/util/TextUtils';
import SearchUtils from 'common/src/main/ets/util/SearchUtils';
import { ArrayList, HashSet } from '@kit.ArkTS';
import { ObjectUtil } from 'common';

const TAG = 'ContactRepository';
// 预置openharmony消费者热线联系人标识，在开库第一次插入后读取配置插入该联系人syn_2字段
const OHOS_CONSUMER_HOTLINE_CONTACT = 'PREDEFINED_OHOS_CONTACT';

const NOTIFY_NOT_DOUBLE_TO_SINGLE_UPGRADE = 'not_double_to_single_upgrade';
const NOTIFY_DOUBLE_DB_FILE_NOT_COMPLETENESS = 'double_db_file_not_completeness';
const NOTIFY_DELETE_SINGLE_DB_FAIL = 'delete_single_db_fail';
const NOTIFY_RESTORE_BY_DOUBLE_DB_FININSH = 'restore_by_double_db_fininsh';
const SECONDS_OF_ONE_DAY = 24 * 60 * 60; // Seconds of one day
const INTELLIGENCE_GROUP_LIMIT_RECORDS = 35000;

export enum RestoreResultType {
  NO_CONTACTS_TO_RESTORE,
  RESTORE_FAILED,
  RESTORE_SUCCESS
}

export class ContactData {
  public contactList: ContactListItem[] = [];
  public contactIdList: number[] = [];
}

export class LogAccount {
  public accountId: string;
  public contactId: string;
  public primary: string;

  constructor(accountId: string, contactId: string, primary: string) {
    this.accountId = accountId;
    this.contactId = contactId;
    this.primary = primary;
  }
}

export class LogInfoWithoutNum {
  public accountId: string;
  public displayName: string;

  constructor(accountId: string, displayName: string) {
    this.accountId = accountId;
    this.displayName = displayName;
  }
}

class IntelligenceGroupTimestamps {
  public timestampOneWeekAgo: number;
  public timestampOneMonthAgo: number;
  public timestampThreeMonthsAgo: number;

  constructor(timestampOneWeekAgo: number = 0, timestampOneMonthAgo: number = 0, timestampThreeMonthsAgo: number = 0) {
    this.timestampOneWeekAgo = timestampOneWeekAgo;
    this.timestampOneMonthAgo = timestampOneMonthAgo;
    this.timestampThreeMonthsAgo = timestampThreeMonthsAgo;
  }
}


/**
 * Contact storage management, shielding dependency on the CP layer
 * Contacts Only
 */
export class ContactRepository implements IContactRepository {
  public static TYPE_ID_PHONE_NUMBER = 5;
  // device id type
  public static TYPE_ID_DEVICE = 15;
  public static readonly RAW_CONTACT_URL: string = RawContacts.CONTENT_URI;
  public dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;
  private static instance: ContactRepository | null;
  private context: Context | null = null;

  public resultDT: boolean = true;
  private logUtils: AuditLogUtils = AuditLogUtils.getInstance();
  private defaultSelectContactMap: Map<number, Set<string>> = new Map();
  // 创建datahelper失败标记位
  public createDataHelperFailed: boolean = false;

  public getContext() {
    return this.context;
  }

  private constructor() {
    this.context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
  }

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx?: Context) {
    if (ctx !== undefined) {
      this.context = ctx;
    }
    return this;
  }

  unInit(): void {
    HiLog.i(TAG, 'unInit...');
    this.dataShareHelper = undefined;
    this.context = null;
  }

  public static getDTTestInstance(): ContactRepository {
    // 用于DT测试创建实例对象
    return new ContactRepository();
  }

  public static getInstance(): ContactRepository {
    if (!ContactRepository.instance) {
      ContactRepository.instance = new ContactRepository();
    }
    return ContactRepository.instance;
  }

  saveTest() {
    return false;
  }

  public async isSameAccountWithLocal(userId: number): Promise<boolean> {
    try {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      const localId: number = await accountManager.getOsAccountLocalId();
      HiLog.w(TAG, `localId: ${localId}`);
      // 和本用户空间是相同的空间信息
      return userId === localId;
    } catch (error) {
      HiLog.e(TAG, `getOsAccountLocalId error: ${error?.message}`);
      return false;
    }
  }

  /**
   * Get the Data Ability Helper If the Data Share Helper is not defined, create a new Data Share Helper
   * @return {Promise<DataShareHelper>} Returns the Data Share Helper
   */
  public async getDataAbilityHelper(userId?: number) {
    HiLog.w(TAG, `getDataAbilityHelper userId: ${userId},${this.createDataHelperFailed}`);
    let uri = Contacts.CONTENT_URI;
    if (userId && userId > 0 && !(await this.isSameAccountWithLocal(userId))) {
      uri = `${Contacts.CONTENT_URI}?user=${userId}`;
    }
    let createTimes = 0;
    if (uri === Contacts.CONTENT_URI) {
      while (this.dataShareHelper == undefined) {
        createTimes++;
        HiLog.w(TAG, `getDataAbilityHelper createTimes: ${createTimes} start`);
        try {
          this.dataShareHelper =
            await dataShare.createDataShareHelper(this.context as Context, Contacts.CONTENT_URI, {});
          HiLog.w(TAG, `getDataAbilityHelper createTimes: ${createTimes} success!`);
          break;
        } catch (error) {
          HiLog.e(TAG, `getDataAbilityHelper createTimes: ${createTimes} error: ${error?.message}`);
          if (createTimes >= 5) {
            this.createDataHelperFailed = true;
            break;
          }
        }
      }
      return this.dataShareHelper as dataShare.DataShareHelper;
    } else {
      return (await dataShare.createDataShareHelper(this.context as Context, uri, {}));
    }
  }

  // syncData switch
  triggerContactsSyncDataSwitch() {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    this.getDataAbilityHelper()
      .then((dataAbilityHelper: dataShare.DataShareHelper) => {
        dataAbilityHelper.query(Contacts.CONTACT_SYNC_URI, conditionArgs, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            resultSet?.close();
          })
      })
      .catch((error: Error) => {
        HiLog.e(TAG, `getDataAbilityHelper error: ${error?.message}`);
      });
  }

  /**
   * 设置默认
   * @param contactId
   * @param dataType
   * @param dataId
   * @param primary
   */
  async setPrimary(contactId: ValueType, dataType: ValueType, dataId: ValueType, primary: boolean) {
    this.findRawIdById(contactId as number, async (rawContactIdArr: string[]) => {
      HiLog.w(TAG, `setPrimary rawContactIdArr: ${rawContactIdArr.toString()}`)
      if (ArrayUtil.isEmpty(rawContactIdArr)) {
        HiLog.w(TAG, 'query rawcontactId by contactId: ' + contactId + ', rawcontactId is empty!');
        return;
      }
      try {
        let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
        let uptateCondition = new dataSharePredicates.DataSharePredicates();
        uptateCondition
          .in(Data.RAW_CONTACT_ID, rawContactIdArr)
          .and()
          .equalTo(Data.TYPE_ID, dataType)
          .and()
          .equalTo(Data.ID, dataId)
        HiLog.w(TAG,
          `setPrimary begin, contactId: ${contactId}, dataType: ${dataType}, dataId: ${dataId}, primary: ${primary}`);
        if (primary) {
          dataAbilityHelper.update(Data.CONTENT_URI, uptateCondition, { 'extend5': '1' });
          let resetCondition = new dataSharePredicates.DataSharePredicates();
          resetCondition.in(Data.RAW_CONTACT_ID, rawContactIdArr)
            .and()
            .equalTo(Data.TYPE_ID, dataType)
            .and()
            .notEqualTo(Data.ID, dataId)
          dataAbilityHelper.update(Data.CONTENT_URI, resetCondition, { 'extend5': '0' });
        } else {
          dataAbilityHelper.update(Data.CONTENT_URI, uptateCondition, { 'extend5': '0' });
        }
        HiLog.w(TAG, 'setPrimary update success');
      } catch (err) {
        HiLog.e(TAG, 'setPrimary err:' + err?.message + ', stack: ' + err?.stack);
      }
    })
  }

  /**
   * 查询联系人畅连能力相关信息
   * @param contactId
   * @param callback
   */
  findContactMeeTimeAbilityById(contactId: number, callback: Function) {
    HiLog.i(TAG, `findContactMeeTimeAbilityById   id == ${contactId}`);
    if (contactId < 0) {
      HiLog.w(TAG, 'findContactMeeTimeAbilityById: id is invalid.');
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {

      // 查询联系人详情信息，只查询与畅连能力相关的信息（电话号信息和设备信息）
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.CONTACT_ID, contactId)
      conditionArgs.and()
      conditionArgs.in(DataColumns.TYPE_ID, [ContactRepository.TYPE_ID_PHONE_NUMBER, ContactRepository.TYPE_ID_DEVICE])
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null).then((resultSet: DataShareResultSet) => {
        try {
          if (resultSet == undefined || !resultSet.goToFirstRow()) {
            HiLog.w(TAG, 'findContactMeeTimeAbilityById not found.');
            callback();
            return;
          }
          let contactBuilder = ContactBuilder.fromResultSet(resultSet);
          let currentRawContactId = -1;
          let rawContact: RawContact | null = null;
          do {
            let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
            if (rawContactId != currentRawContactId) {
              currentRawContactId = rawContactId;
              rawContact = RawContact.fromResultSet(resultSet);
              // 设置畅连能力
              // 如果raw没有畅连能力，看其他raw有没有畅连能力
              // 解析raw的畅连能力信息
              rawContact.meeTimeAbilityInfoModel = MeeTimeAbilityInfoModel.fromResultSet(resultSet);
              contactBuilder.rowContacts.push(rawContact);
            }
            if (rawContact != undefined) {
              rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
            }
          } while (resultSet.goToNextRow());
          callback(contactBuilder.buildContact());
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'findContactMeeTimeAbilityById error:%s' + error?.message);
        callback();
      });


    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  /**
   * 查询id
   * @param id
   * @param callback
   */
  findById(id: number, callback: Function): void {
    HiLog.w(TAG, `findById   id == ${id}`);
    if (id < 0) {
      HiLog.w(TAG, 'findById: id is invalid.');
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      // 查询联系人详情信息
      // query contact
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.CONTACT_ID, id).orderByDesc(Data.RAW_CONTACT_ID);
      hiTraceMeter.startTrace('findById', 1);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null).then((resultSet: DataShareResultSet) => {
        try {
          hiTraceMeter.finishTrace('findById', 1);
          if (resultSet == undefined || !resultSet.goToFirstRow()) {
            HiLog.w(TAG, 'findById not found.');
            callback();
            return;
          }
          let contactBuilder = ContactBuilder.fromResultSet(resultSet);
          let currentRawContactId = -1;
          let rawContact: RawContact | null = null;
          do {
            let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
            // 第一条记录，设置rawContact信息，两个raw都根据第一个查询结果设置
            if (rawContactId != currentRawContactId) {
              currentRawContactId = rawContactId;
              rawContact = RawContact.fromResultSet(resultSet);
              // 解析raw的畅连能力信息
              rawContact.meeTimeAbilityInfoModel = MeeTimeAbilityInfoModel.fromResultSet(resultSet);
              contactBuilder.rowContacts.push(rawContact);
            }
            if (rawContact != undefined) {
              rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
            }
          } while (resultSet.goToNextRow());
          callback(contactBuilder.buildContact());
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        // 联系人故障打点-查询联系人详情异常-已知联系人
        faultContactParams.FAULT_INFO = error.message;
        DotUtil.getInstance()
          .reportFaultEvent(faultContactParams, dotCommon.faultEventName.DISPLAY_CONTACTS_DETAIL_ERROR);
        HiLog.e(TAG, 'findById error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  async findByIdSync(id: number): Promise<Contact | null> {
    HiLog.w(TAG, `findById   id == ${id}`);
    if (id < 0) {
      HiLog.w(TAG, 'findById: id is invalid.');
      return null;
    }
    let contact: Contact = new Contact(new ContactBuilder(id));
    let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
    if (dataAbilityHelper == undefined || dataAbilityHelper == null) {
      HiLog.e(TAG, 'findByIdSync dataAbilityHelper is null');
      return null;
    }
    let resultSet: DataShareResultSet | null | undefined = null;
    try {
      // query contact
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.CONTACT_ID, id).orderByDesc(Data.RAW_CONTACT_ID);
      hiTraceMeter.startTrace('findById', 1);
      resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, []);
      hiTraceMeter.finishTrace('findById', 1);
      if (resultSet == undefined || !resultSet.goToFirstRow()) {
        HiLog.w(TAG, 'findById not found.');
        return null;
      }
      let contactBuilder = ContactBuilder.fromResultSet(resultSet);
      let currentRawContactId = -1;
      let rawContact: RawContact | null = null;
      do {
        let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
        // 第一条记录，设置rawContact信息，两个raw都根据第一个查询结果设置
        if (rawContactId != currentRawContactId) {
          currentRawContactId = rawContactId;
          rawContact = RawContact.fromResultSet(resultSet);
          // 解析raw的畅连能力信息
          rawContact.meeTimeAbilityInfoModel = MeeTimeAbilityInfoModel.fromResultSet(resultSet);
          contactBuilder.rowContacts.push(rawContact);
        }
        if (rawContact != undefined) {
          rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
        }
      } while (resultSet.goToNextRow());
      contact = contactBuilder.buildContact();
    } catch (error) {
      HiLog.e(TAG, `findByIdSync error: ${error?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return contact;
  }


  async getPickerDataByIds(contactIds: number[], userId: number,
    callback: (contactIdPickerDataMap: Map<number, contact.Contact>, groupIds: number[]) => void): Promise<void> {
    HiLog.w(TAG, `getPickerDataByIds start, contactIds length: ${contactIds.length}, contactIds: ${contactIds}`);
    let contactIdPickerDataMap: Map<number, contact.Contact> = new Map();
    let groupIds: number[] = []
    if (contactIds.length <= 0) {
      HiLog.w(TAG, 'getPickerDataByIds: contactIds is empty.');
      callback(contactIdPickerDataMap, groupIds);
      return;
    }

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper(userId);
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs
        .equalTo(Data.IS_DELETED, 0)
        .in(RawContacts.CONTACT_ID, contactIds)
        .in(Data.TYPE_ID, [
          DataItemType.EMAIL, DataItemType.EVENT, DataItemType.GROUP_MEMBERSHIP, DataItemType.IM, DataItemType.PHONE,
          DataItemType.STRUCTURED_POSTAL, DataItemType.RELATION, DataItemType.WEBSITE, DataItemType.NAME,
          DataItemType.NOTE, DataItemType.ORGANIZATION
        ])
        .orderByAsc(RawContacts.CONTACT_ID)
        .orderByAsc(Data.RAW_CONTACT_ID)
      let columns: string[] = [RawContacts.CONTACT_ID, Data.DETAIL_INFO, Data.TYPE_ID, Data.EXTEND7, Data.CUSTOM_DATA];

      resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, columns);
      HiLog.w(TAG, `getPickerDataByIds resultSet rowCount: ${resultSet.rowCount}`);
      if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
        HiLog.w(TAG, `getPickerDataByIds not found.`);
        callback(contactIdPickerDataMap, groupIds);
        return;
      }
      do {
        let contactId = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
        let typeId = resultSet.getLong(resultSet.getColumnIndex(Data.TYPE_ID));
        let detailInfo = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
        let labelId = resultSet.getLong(resultSet.getColumnIndex(Data.CUSTOM_DATA));
        let labelName = resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7));

        let pickerData: contact.Contact = {
          id: contactId,
          key: contactId.toString(),
          emails: [],
          events: [],
          groups: [],
          imAddresses: [],
          phoneNumbers: [],
          portrait: {
            uri: ''
          },
          postalAddresses: [],
          relations: [],
          websites: [],
          name: {
            fullName: ''
          },
          note: {
            noteContent: ''
          },
          organization: {
            name: ''
          }
        }
        if (contactIdPickerDataMap.has(contactId)) {
          pickerData = contactIdPickerDataMap.get(contactId) ?? pickerData;
        }

        switch (typeId) {
          case DataItemType.EMAIL:
            let emailDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(Email.getTypeLabelResource(labelId).id);
            let email: contact.Email = {
              email: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : emailDefaultLabelName,
              labelId: labelId
            }
            pickerData.emails?.push(email)
            break;
          case DataItemType.EVENT:
            let eventDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(Birthday.getTypeLabelResource(labelId).id);
            let event: contact.Event = {
              eventDate: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : eventDefaultLabelName,
              labelId: labelId
            }
            pickerData.events?.push(event);
            break;
          case DataItemType.GROUP_MEMBERSHIP:
            let groupId = parseInt(detailInfo);
            if (groupId > 0) {
              groupIds.push(groupId);
              let group: contact.Group = {
                title: '',
                groupId: groupId,
              }
              pickerData.groups?.push(group);
            }
            break;
          case DataItemType.IM:
            let imDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(Aim.getTypeLabelResource(labelId).id);
            let aim: contact.ImAddress = {
              imAddress: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : imDefaultLabelName,
              labelId: labelId
            }
            pickerData.imAddresses?.push(aim);
            break;
          case DataItemType.PHONE:
            let phoneDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(Phone.getTypeLabelResource(labelId).id);
            let phone: contact.PhoneNumber = {
              phoneNumber: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : phoneDefaultLabelName,
              labelId: labelId
            }
            pickerData.phoneNumbers?.push(phone)
            break;
          case DataItemType.STRUCTURED_POSTAL:
            let houseDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(House.getTypeLabelResource(labelId).id);
            let house: contact.PostalAddress = {
              postalAddress: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : houseDefaultLabelName,
              labelId: labelId
            }
            pickerData.postalAddresses?.push(house);
            break;
          case DataItemType.RELATION:
            let relationDefaultLabelName = ContactsGlobalThisHelper.GetGlobalThis()
              .getDefaultUIContext()
              .resourceManager
              .getStringSync(Relation.getTypeLabelResource(labelId).id);
            let relation: contact.Relation = {
              relationName: detailInfo,
              labelName: labelId === PhoneAccountType.TYPE_ID_CUSTOM ? labelName : relationDefaultLabelName,
              labelId: labelId
            }
            pickerData.relations?.push(relation);
            break;
          case DataItemType.WEBSITE:
            let website: contact.Website = {
              website: detailInfo
            }
            pickerData.websites?.push(website);
            break;
          case DataItemType.NAME:
            pickerData.name!.fullName = detailInfo;
            break;
          case DataItemType.NOTE:
            pickerData.note!.noteContent = detailInfo;
            break;
          case DataItemType.ORGANIZATION:
            pickerData.organization!.name = detailInfo;
            break;
          default:
            break;
        }

        contactIdPickerDataMap.set(contactId, pickerData);
      } while (resultSet.goToNextRow());

      HiLog.w(TAG, `getPickerDataByIds end, contactIdPickerDataMap size: ${contactIdPickerDataMap.size}`);
      callback(contactIdPickerDataMap, groupIds);
    } catch (error) {
      HiLog.e(TAG, `getPickerDataByIds error: ${error?.message},
       contactIdPickerDataMap size: ${contactIdPickerDataMap.size}`);
      callback(contactIdPickerDataMap, groupIds);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  findIdByRawId(rawId: number, callBack: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(Data.ID, rawId);
    const resultColumns = [RawContactsColumns.CONTACT_ID];
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(RawContacts.CONTENT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            let ret: string[] = [];
            if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
              HiLog.i(TAG, 'findIdByRawId resultSet count 0');
              callBack?.(ret);
              return;
            }
            do {
              ret.push(resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.CONTACT_ID)));
            } while (resultSet.goToNextRow());
            callBack?.(ret);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findIdByRawId err:' + error?.message);
          callBack?.([]);
        })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findIdByRawId error:' + error?.message);
      callBack?.([]);
    });
  }

  async findIdByRawIdAsync(rawId: number): Promise<string[]> {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(Data.ID, rawId);
    const resultColumns = [RawContactsColumns.CONTACT_ID];
    let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
    let ret: string[] = [];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      resultSet = await dataAbilityHelper.query(RawContacts.CONTENT_URI, conditionArgs, resultColumns);

      if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
        HiLog.w(TAG, `findIdByRawId resultSet count 0, rawId: ${rawId}`);
        return ret;
      }
      do {
        ret.push(resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.CONTACT_ID)));
      } while (resultSet.goToNextRow());
      if (ret.length > 1) {
        HiLog.w(TAG, `findIdByRawId resultSet > 1, rawId: ${rawId}, contactId: ${ret}`);
      }
    } catch (e) {
      HiLog.w(TAG, 'findIdByRawIdAsync error ' + e.code + '--' + e.message);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return ret;
  }

  async findRawIdByIdAsync(contactId: number): Promise<string[]> {
    let ret: string[] = [];

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContactsColumns.CONTACT_ID, contactId);
      const resultColumns = [RawContactsColumns.ID];
      let dataAbilityHelper = await this.getDataAbilityHelper();
      resultSet = await dataAbilityHelper.query(RawContacts.CONTENT_URI, conditionArgs, resultColumns);

      if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
        HiLog.i(TAG, 'findRawIdById resultSet count 0');
        return [];
      }
      do {
        ret.push(resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.ID)));
      } while (resultSet.goToNextRow());
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return ret;
  }

  findRawIdById(contactId: number, callBack: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContactsColumns.CONTACT_ID, contactId);
    const resultColumns = [RawContactsColumns.ID];
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(RawContacts.CONTENT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            let ret: string[] = [];
            if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
              HiLog.i(TAG, 'findRawIdById resultSet count 0');
              callBack?.(ret);
              return;
            }
            do {
              ret.push(resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.ID)));
            } while (resultSet.goToNextRow());
            callBack?.(ret);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findRawIdById err:' + error?.message);
          callBack?.([]);
        })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findRawIdById error:' + error?.message);
      callBack?.([]);
    });
  }

  // contact count
  async getContactSize(accountId: ValueType, callback: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    let resultColumns = [RawContacts.DISPLAY_NAME];
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            let count = resultSet.rowCount;
            HiLog.i(TAG, 'getContactSize length:' + count);
            callback(count);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'getContactSize error:%s' + error?.message);
          callback(0);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(0);
    });
  }

  /**
   * TODO meng
   * @param contactIdList
   * @param callback
   */
  findListById(contactIdList: Array<string>, callback: Function) {
    HiLog.i(TAG, 'findListById start contactIdList size: ' + contactIdList?.length);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      .and()
      .in(Contacts.ID, contactIdList)
      .and()
      .orderByAsc(Contacts.ID)
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, [])
        .then(resultSet => {
          try {
            HiLog.i(TAG, ' findListById resultSet columnNames' + resultSet?.columnNames);
            let rst: ContactListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new ContactListItem(resultSet));
                HiLog.i(TAG, ' findListById resultSet rst size: ' + rst?.length);
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findListById query data success.');
              HiLog.i(TAG, ' findListById resultSet end, rst size: ' + rst?.length);
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findListById error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findListById error:%s' + error?.message);
      callback([]);
    });
  }

  // 获取全部联系人数量
  async getAllContactSize(callback: Function, hasMyCard: boolean = true) {
    HiLog.w(TAG, `getAllContactSize start, hasMyCard: ${hasMyCard}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (accountId != undefined && accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    if (!hasMyCard) {
      // 计算联系人总数时，不包括 我的名片
      conditionArgs.and()
      conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, 1)
    }
    let resultColumns = ['count(*) as count'];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let dataAbilityHelper = await this.getDataAbilityHelper();
      resultSet = await dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, resultColumns);
      HiLog.w(TAG, 'getAllContactSize end: ' + resultSet.rowCount);
      // 二级索引集合
      let alphabetIndex: Record<string, AlphabetIndexObj> = {}
      // 联系人数量
      let count: number = resultSet.rowCount;
      if (count <= 0) {
        callback(new CountAlphabetIndex(0, alphabetIndex));
      } else {
        resultSet.goToFirstRow();
        let size = resultSet.getLong(resultSet.getColumnIndex('count'));
        // 回调，已经获取联系人数量信息和
        callback(new CountAlphabetIndex(size, alphabetIndex));
      }
    } catch (error) {
      let err = error as BusinessError;
      HiLog.e(TAG, `getAllContactSize getDataAbilityHelper error: ${err?.message}`);
      callback(new CountAlphabetIndex(0, {}));
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  // 获取全部联系人数量 --同步Promise
  async getAllContactSizeSync(userId: number, hasMyCard: boolean = true): Promise<CountAlphabetIndex> {
    HiLog.w(TAG, `getAllContactSizeSync start, hasMyCard: ${hasMyCard}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    const isModifyDisplay = await sharedPreferencesUtils.getFromPreferences('isModifyDisplay', false) as boolean;
    if (isModifyDisplay) {
      const accountIds = await sharedPreferencesUtils.getFromPreferences('selectedAccounts', []) as number[];
      if (accountIds.length === 0) {
        HiLog.w(TAG, 'getAllContactSizeSync selected account is empty');
        return new CountAlphabetIndex(0, {});
      }
      conditionArgs.in(RawContacts.ACCOUNT_ID, accountIds);
    }
    if (!hasMyCard) {
      // 计算联系人总数时，不包括 我的名片
      conditionArgs.and()
      conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, 1)
    }
    let resultColumns = ['count(*) as count'];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let dataAbilityHelper = await this.getDataAbilityHelper(userId);
      resultSet = await dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, resultColumns);
      HiLog.w(TAG, 'getAllContactSizeSync end: ' + resultSet.rowCount);
      // 二级索引集合
      let alphabetIndex: Record<string, AlphabetIndexObj> = {}
      // 联系人数量
      let count: number = resultSet.rowCount;
      if (count <= 0) {
        return new CountAlphabetIndex(0, alphabetIndex);
      } else {
        resultSet.goToFirstRow();
        let size = resultSet.getLong(resultSet.getColumnIndex('count'));
        // 回调，已经获取联系人数量信息和
        return new CountAlphabetIndex(size, alphabetIndex);
      }
    } catch (error) {
      let err = error as BusinessError;
      HiLog.e(TAG, `getAllContactSizeSync getDataAbilityHelper error: ${err?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return new CountAlphabetIndex(0, {});
  }

  async getAllRawContactSize(callback: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    const accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    let resultColumns = ['count(*) as count'];

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_RAW_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.w(TAG, 'getAllRawContactSize end: ' + resultSet.rowCount);
            // 联系人数量
            let count: number = resultSet.rowCount;
            if (count <= 0) {
              callback(new CountRawContact(0));
            } else {
              resultSet.goToFirstRow();
              let size = resultSet.getLong(resultSet.getColumnIndex('count'));
              // 回调，已经获取联系人数量信息和
              callback(new CountRawContact(size));
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.w(TAG, 'getAddRawContactSize error:%s' + error?.message);
          callback(new CountRawContact(0));
        });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + error?.message);
      callback(new CountRawContact(0));
    });
  }

  /**
   * process 回调，处理每一行查询的联系人信息，根据联系人信息生成二级索引信息
   * @param process
   * @param callback
   */
  async getAllContactSizeAndIndex(process: (jsonObj: NameFixInfo,
    index: number, alphabetIndex: Record<string, AlphabetIndexObj>,
    isEnd: boolean) => void, callback: Function) {

    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (accountId != undefined && accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    let resultColumns = [RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, RawContacts.DISPLAY_NAME];

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      HiLog.i(TAG, 'getAllContactSizeAndIndex begin')
      hiTraceMeter.startTrace('getAllContactSizeAndIndex', 1);
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.i(TAG, 'getAllContactSizeAndIndex end: ' + resultSet.rowCount);
            hiTraceMeter.finishTrace('getAllContactSizeAndIndex', 1);
            let alphabetIndex: Record<string, AlphabetIndexObj> = {}
            // 联系人数量
            let count: number = resultSet.rowCount;
            if (count <= 0) {
              callback(new CountAlphabetIndex(count, alphabetIndex));
            } else {
              resultSet.goToFirstRow();
              let index: number = 0;
              do {
                let namePrefix: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
                let nameSuffix: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
                let displayName: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
                // 处理单条联系人，生成二级索引信息，放到二级索引集合
                process(new NameFixInfo(namePrefix, nameSuffix, displayName), index, alphabetIndex,
                  index === count - 1);
                index++;
              } while (resultSet.goToNextRow());
              // 回调，已经获取联系人数量信息和
              callback(new CountAlphabetIndex(count, alphabetIndex));
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'getAllContactIndex error:%s' + error?.message);
          callback(new CountAlphabetIndex(0, {}));
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(new CountAlphabetIndex(0, {}));
    });
  }

  findAllAcount(callback: (data: AccountVo[]) => void) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.ACCOUNT_URI, conditionArgs, ContactListItem.ACCOUNT_COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: AccountVo[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new AccountVo(resultSet.getString(resultSet.getColumnIndex(Contacts.ID)),
                  resultSet.getString(resultSet.getColumnIndex(Contacts.ACCOUNT_NAME)),
                  resultSet.getString(resultSet.getColumnIndex(Contacts.ACCOUNT_TYPE)),
                  resultSet.getString(resultSet.getColumnIndex(Contacts.DATA_INFO))));
              } while (resultSet.goToNextRow());
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findAll error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback([]);
    });
  }


  FindCurrentAccount(ids: string[], callback: (data: LogAccount[]) => void, request?:string) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();

    let resultColumns = [RawContacts.ACCOUNT_ID, RawContacts.CONTACT_ID, RawContacts.MARK_MY_CARD];

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (request === 'addContact') {
        conditionArgs.in(RawContacts.ID, ids);
      } else {
        conditionArgs.in(RawContacts.CONTACT_ID, ids);
      }
      dataAbilityHelper.query(Contacts.CONTACT_RAW_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: LogAccount[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new LogAccount(
                  resultSet.getString(resultSet.getColumnIndex(RawContacts.ACCOUNT_ID)),
                  resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID)),
                  resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD))
                ));
              } while (resultSet.goToNextRow());

              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findAll error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback([]);
    });
  }

  async findAll(actionData: AllContactGetParam, callback: (resultSet?: DataShareResultSet) => void,
    findMyCard: boolean = false) {
    HiLog.w(TAG, 'findAllContacts start');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    if (actionData.page > 0) {
      let offset = ArrayUtil.getOffsetForSession(actionData.page);
      conditionArgs.limit(actionData.limit, offset)
    }
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    if (actionData.rawContactIds !== undefined && actionData.rawContactIds.length > 0) {
      conditionArgs.in(ContactsColumns.NAME_RAW_CONTACT_ID, actionData.rawContactIds)
    }
    // 查询我的名片信息
    if (!findMyCard) {
      conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    } else {
      conditionArgs.equalTo(RawContacts.MARK_MY_CARD, '1');
    }
    // 查询未删除的
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS_CONTACT_LIST_GET_ALL_CONTACT)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.w(TAG, 'query succeeded ' + resultSet.rowCount);
            callback(resultSet);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          // 联系人故障打点-查询联系人列表异常
          faultContactParams.FAULT_INFO = error.message;
          DotUtil.getInstance().reportFaultEvent(faultContactParams,
            dotCommon.faultEventName.DISPLAY_CONTACTS_LIST_ERROR);
          HiLog.e(TAG, 'findAll error:%s' + error?.message);
          emitter.emit(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
          callback(undefined);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      emitter.emit(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
      callback(undefined);
    });
  }

  findByQuickSearchKey(searchKey: string, callback: Function) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(Contacts.QUICK_SEARCH_KEY, searchKey).orderByAsc(Data.RAW_CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null).then((resultSet: DataShareResultSet) => {
        try {
          if (resultSet == undefined || !resultSet.goToFirstRow()) {
            HiLog.w(TAG, 'findByQuickSearchKey not found.');
            callback();
            return;
          }
          let contactBuilder = ContactBuilder.fromResultSet(resultSet);
          let currentRawContactId = -1;
          let rawContact: RawContact | null = null;
          do {
            let rawContactId: number = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
            if (rawContactId != currentRawContactId) {
              currentRawContactId = rawContactId;
              rawContact = RawContact.fromResultSet(resultSet);
              contactBuilder.rowContacts.push(rawContact);
            }
            if (rawContact != undefined) {
              rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
            }
          } while (resultSet.goToNextRow());
          callback(contactBuilder.buildContact());
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'findByQuickSearchKey error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  findByPhoneIsNotNull(addParams: AllContactWithPhoneNumbersGetParam, callback: Function) {
    if (addParams == undefined) {
      callback(undefined)
      return;
    }
    HiLog.i(TAG, 'initContactsList resultList success favoriteForm favorite :' + addParams.favorite + '---' +
    addParams.editContact);
    // 获取联系人号码{联系人id，联系人对应电话信息集合}
    this.getAllContactNumbers(addParams.favorite, addParams.editContact, (contactNumberMap) => {
      // 查询联系人信息
      this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {
        // 过滤条件
        let conditionArgs = await this.initConditionArgs(addParams)
        dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            try {
              let rst: ContactListItem[] = [];
              if (resultSet.rowCount === 0) {
                callback(rst);
              } else {
                resultSet.goToFirstRow();
                do {
                  // 联系人id
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                  if (!contactNumberMap.has(id)) {
                    HiLog.w(TAG, 'findAll: contact id is invalid or contact has no phone number.');
                    continue;
                  }

                  // 过滤“我的名片”
                  if (resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD)) === '1') {
                    continue;
                  }
                  // 根据查询结果生成联系人信息
                  let contactListItem = new ContactListItem(resultSet);
                  // 根据联系人id设置对应的手机号信息
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  rst.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(rst);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, 'findAll error:%s' + error?.message);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
        callback(undefined);
      });
    }, addParams.pageTag);
  }

  public async getContactActSize(): Promise<number> {
    let contactSize: number = 0;

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      const dataAbilityHelper = await this.getDataAbilityHelper();
      // 过滤条件

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', 0);
      resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, ['count(*)']);

      let result = resultSet.goToFirstRow();
      if (result) {
        contactSize = resultSet.getDouble(0);
      }
    } catch (e) {
      HiLog.e(TAG, 'get contact size error');
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return contactSize;
  }

  async queryAllContactInfo(): Promise<ContactListActItem[]> {
    HiLog.i(TAG, 'initContactsList resultList success favoriteForm favorite');
    const pageSize = 500;
    const totalLimit = 4000;
    let offset = 0;
    let resultSet: DataShareResultSet | undefined = undefined;
    let contactSize: number = 0;

    const contacts: ContactListActItem[] = [];
    try {
      const dataAbilityHelper = await this.getDataAbilityHelper();
      contactSize = await this.getContactActSize();
      let pageNum = contactSize / pageSize;
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      const contactInfos: Map<number, ValuesBucket[]> = new Map();
      for (let i = 0; i < pageNum; i++) {
        if (contactInfos.size > totalLimit) {
          HiLog.i(TAG, 'contact number is greater than limit: ' + contactInfos.size);
          break;
        }
        conditionArgs.limit(pageSize, offset);
        offset += pageSize;
        resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, []);

        if (resultSet.rowCount === 0) {
          HiLog.i(TAG, 'resultSet is empty');
          return contacts;
        }
        let result = resultSet.goToFirstRow();
        let count: number = 0;
        while (result) {
          const rawContactId = resultSet.getLong(resultSet.getColumnIndex(DataColumns.RAW_CONTACT_ID));
          let valuesBuckets: ValuesBucket[] = [];
          if (contactInfos.has(rawContactId)) {
            valuesBuckets = contactInfos.get(rawContactId) ?? [];
          }
          const value: ValuesBucket = {};
          resultSet.columnNames.forEach((column) => {
            value[column] = resultSet!.getString(resultSet!.getColumnIndex(column));
          })
          valuesBuckets.push(value);
          contactInfos.set(rawContactId, valuesBuckets);
          result = resultSet.goToNextRow();
        }
      }
      for (const entry of contactInfos.entries()) {
        const valuesBuckets = entry[1];
        if (valuesBuckets.length > 0) {
          const contactLisActItem = new ContactListActItem(valuesBuckets);
          contacts.push(contactLisActItem);
        }
      }
      if (contacts.length > totalLimit) {
        contacts.splice(4000);
      }
    } catch (error) {
      HiLog.e(TAG, 'findAll error:%s' + error?.message);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return contacts;
  }

  findByIds(ids: Array<string>, callback: Function, request?: string) {
    // 获取联系人号码{联系人id，联系人对应电话信息集合}
    this.logGetInfo((contactNumberMap) => {
      // 查询联系人信息
      this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {

        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            try {
              let rst: ContactListItem[] = [];
              if (resultSet.rowCount === 0) {
                callback(rst);
              } else {
                resultSet.goToFirstRow();
                do {
                  // 联系人id
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                  if (!contactNumberMap.has(id)) {
                    HiLog.w(TAG, 'findAll: contact id is invalid or contact has no phone number.');
                    continue;
                  }

                  // 过滤“我的名片”
                  if (resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD)) === '1') {
                    continue;
                  }
                  // 根据查询结果生成联系人信息
                  let contactListItem = new ContactListItem(resultSet);
                  // 根据联系人id设置对应的手机号信息
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  rst.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(rst);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, 'findAll error:%s' + error?.message);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
        callback(undefined);
      });
    }, ids, request);
  }


  async initConditionArgs(addParams: AllContactWithPhoneNumbersGetParam) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    if ((-1 !== addParams.editContact && addParams.editContact) || 0 === addParams.favorite) {
      // 查询未删除，未收藏
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
      if (0 === addParams.favorite) {
        conditionArgs.and();
        conditionArgs.equalTo(RawContacts.FAVORITE, 0);
      }
      conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    } else {
      // 未删除，存在电话号码
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      if (!((addParams.pageTag && addParams.pageTag === 'arrange') || addParams.pageTag === 'group' ||
        addParams.pageTag === 'getAllContact')) {
        conditionArgs.and().equalTo(Contacts.HAS_PHONE_NUMBER, '1')
      }
      if (addParams.pageTag === 'arrange') {
        conditionArgs.orderByAsc(Contacts.NAME_RAW_CONTACT_ID)
          .orderByAsc(RawContacts.SORT)
          .orderByAsc(RawContacts.SORT_KEY);
      } else {
        conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
      }
    }
    let accountType = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if ((addParams.accountId != undefined && addParams.accountId != -1) ||
      (accountType != undefined && accountType != -1)) {
      conditionArgs.and();
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, addParams.accountId ? addParams.accountId : accountType);
    }
    if (addParams.pageTag && addParams.pageTag === 'group') {
      let rawContactIds: number[] = await this.queryGroups(addParams.groupId)
      if (rawContactIds && rawContactIds.length > 0) {
        conditionArgs.and();
        conditionArgs.notIn(Contacts.NAME_RAW_CONTACT_ID, rawContactIds);
      }
    }
    return conditionArgs;
  }

  // query groups
  private queryGroups(groupId: number): Promise<number[]> {
    HiLog.i(TAG, 'queryGroups start!!!  groupId = ' + groupId)
    return new Promise(resolve => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let resultColumns = [Data.RAW_CONTACT_ID];
        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        conditionArgs.equalTo(Data.TYPE_ID, 9);
        conditionArgs.and()
        conditionArgs.equalTo(Data.DETAIL_INFO, groupId.toString())
        dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns)
          .then((resultSet: DataShareResultSet) => {
            try {
              if (resultSet == undefined || !resultSet.goToFirstRow()) {
                HiLog.w(TAG, 'queryGroups not found.');
                resolve([]);
                return;
              }
              let ids: number[] = [];
              do {
                ids.push(resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)));
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'queryGroups end row length is :' + ids);
              resolve(ids);
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
        resolve([]);
      });
    })
  }

  /**
   * 查询所有联系人手机号
   */
  // query Number
  private getAllContactNumbers(favorite: number, editContact: number,
    callback: (v: Map<number, PhoneNumberInterface[]>) => void, pageTag?: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let resultColumns = [RawContacts.CONTACT_ID, Data.ID, Data.DETAIL_INFO, Data.EXTEND7, Data.CUSTOM_DATA];
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      // 收藏页查询，从整理跳转到批量选择联系人页面，pageTag === 'getAllContact'
      if (-1 !== editContact || 0 === favorite || pageTag === 'getAllContact') {
        // 查询有手机号或有名字的contact_data
        conditionArgs.in(Data.TYPE_ID, [DataItemType.PHONE, DataItemType.NAME]);
        conditionArgs.orderByAsc(RawContacts.CONTACT_ID);
      } else {
        // 查询手机号类型的contact_data
        conditionArgs.equalTo(Data.TYPE_ID, DataItemType.PHONE).orderByAsc(RawContacts.CONTACT_ID);
      }
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns).then((resultSet: DataShareResultSet) => {
        try {
          this.setResultSet(resultSet, callback);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(new Map());
    });
  }

  private logGetInfo(callback: (v: Map<number, PhoneNumberInterface[]>) => void, ids?: Array<string>,
    request?: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let resultColumns = [RawContacts.CONTACT_ID, Data.ID, Data.DETAIL_INFO, RawContacts.ACCOUNT_ID, Data.TYPE_ID];
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      // 查询有手机号或有名字的contact_data
      if (request === 'restoreRecycleContacts' || request === 'deleteRecycleContactByIds') {
        conditionArgs.in(Data.RAW_CONTACT_ID, ids);
        conditionArgs.in(ContactsColumns.IS_DELETED, ['1'])
      } else {
        conditionArgs.in(RawContacts.CONTACT_ID, ids);
      }

      conditionArgs.in(Data.TYPE_ID, [DataItemType.PHONE, DataItemType.NAME]);

      conditionArgs.orderByAsc(RawContacts.CONTACT_ID);


      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns).then((resultSet: DataShareResultSet) => {
        try {
          this.setResultSetWithAccountId(resultSet, callback);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(new Map());
    });
  }

  setResultSetWithAccountId(resultSet: DataShareResultSet, callback: (v: Map<number, PhoneNumberInterface[]>) => void) {
    // 用于存储联系人及其电话号码的对应关系
    let contactNumberMap = new Map<number, PhoneNumberInterface[]>();
    if (resultSet == undefined || !resultSet.goToFirstRow()) {
      HiLog.w(TAG, 'getAllContactNumbers not found.');
      callback(contactNumberMap);
      return;
    }
    let oldContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
    let oldPhoneNumber = '';
    let numberList: PhoneNumberInterface[] = [];
    do {
      let newContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
      //In order to be compatible with the PhoneNumberInterface
      //we add  labelName and checked  and set default value
      let phoneNumber: string = ''
      if (resultSet.getString(resultSet.getColumnIndex(Data.TYPE_ID)) === DataItemType.PHONE.toString()) {
        phoneNumber = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO))
      }

      let phoneNumberObj: PhoneNumberInterface = {
        dataId: resultSet.getLong(resultSet.getColumnIndex(Data.ID)),
        phoneNumber: phoneNumber,
        labelId: resultSet.getString(resultSet.getColumnIndex(Data.TYPE_ID)),
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        accountId: resultSet.getString(resultSet.getColumnIndex(RawContacts.ACCOUNT_ID)),
      }
      // 如果是同一联系人则把手机号放到同一个list中
      if (oldContact === newContact) {
        if ((oldPhoneNumber != phoneNumberObj.phoneNumber && phoneNumberObj.phoneNumber !== '') ||
          numberList.length == 0) {
          numberList.push(phoneNumberObj);
        }
      } else {
        // 联系人变化时，存储联系人与手机号码列表的对应关系
        contactNumberMap.set(oldContact, numberList);
        oldContact = newContact;
        // 将最新的号码数据存储到新的numberList
        numberList = [phoneNumberObj];
      }
      oldPhoneNumber = phoneNumberObj.phoneNumber;
    } while (resultSet.goToNextRow());
    contactNumberMap.set(oldContact, numberList);
    callback(contactNumberMap);
  }


  setResultSet(resultSet: DataShareResultSet, callback: (v: Map<number, PhoneNumberInterface[]>) => void) {
    // 用于存储联系人及其电话号码的对应关系
    let contactNumberMap = new Map<number, PhoneNumberInterface[]>();
    if (resultSet == undefined || !resultSet.goToFirstRow()) {
      HiLog.w(TAG, 'getAllContactNumbers not found.');
      callback(contactNumberMap);
      return;
    }
    let oldContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
    let oldPhoneNumber = '';
    let numberList: PhoneNumberInterface[] = [];
    do {
      let newContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
      //In order to be compatible with the PhoneNumberInterface
      //we add  labelName and checked  and set default value
      let phoneNumberObj: PhoneNumberInterface = {
        dataId: resultSet.getLong(resultSet.getColumnIndex(Data.ID)),
        phoneNumber: resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)),
        labelId: resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7)),
        numType: resultSet.getString(resultSet.getColumnIndex(Data.CUSTOM_DATA)),
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      // 如果是同一联系人则把手机号放到同一个list中
      if (oldContact === newContact) {
        if (oldPhoneNumber != phoneNumberObj.phoneNumber) {
          numberList.push(phoneNumberObj);
        }
      } else {
        // 联系人变化时，存储联系人与手机号码列表的对应关系
        contactNumberMap.set(oldContact, numberList);
        oldContact = newContact;
        // 将最新的号码数据存储到新的numberList
        numberList = [phoneNumberObj];
      }
      oldPhoneNumber = phoneNumberObj.phoneNumber;
    } while (resultSet.goToNextRow());
    contactNumberMap.set(oldContact, numberList);
    callback(contactNumberMap);
  }

  deleteById(id: number, callback: Function, log?: UtilAuditLog) {
    HiLog.w(TAG, `deleteById contactId: ${id}`);
    if (id < 0) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      this.findRawIdById(id, (rawContactIdArr: string[]) => {
        if (ArrayUtil.isEmpty(rawContactIdArr)) {
          HiLog.e(TAG, 'contactId: ' + id + ', query empty rawContactId!')
          callback();
          return;
        }
        // 删除群组数据
        let mCondition = new dataSharePredicates.DataSharePredicates();
        mCondition.equalTo('type_id', '9')
        mCondition.and();
        // contactdata信息，只能通过rawcontactid删除
        mCondition.equalTo('raw_contact_id', rawContactIdArr[0]);
        dataAbilityHelper.delete(Data.CONTENT_URI, mCondition).then((data: number) => {
          callback(data);
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'deleteGroupsById error:%s' + error?.message);
          callback();
        });
      });
      // 删除联系人
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Contacts.ID, id);
      dataAbilityHelper.delete(Contacts.CONTACT_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        // 联系人故障打点-删除手机联系人失败
        faultContactParams.FAULT_INFO = error.message;
        DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.DELETE_CONTACTS_FAIL);
        HiLog.e(TAG, 'deleteById error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  deleteByIdIn(ids: number[], callback: Function, log?: UtilAuditLog) {
    if (ArrayUtil.isEmpty(ids)) {
      HiLog.w(TAG, 'ids is Empty');
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Contacts.ID, ids);
      dataAbilityHelper.delete(Contacts.CONTACT_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'deleteById error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  notifyChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.notifyChange(Data.CONTENT_URI).then(() => {
          HiLog.i(TAG, 'notifyChange success');
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'notifyChange error:%s' + error?.message);
        });
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
    });
  }

  // 监听到变更后，回调列表（可能触发多个业务方法进行变更）
  public observers: Array<(changeInfo?: dataShare.ChangeInfo) => void> = [];

  // 监听变更contact变更和contentdata变更
  public contactsUrl: Array<string> = [Contacts.CONTACT_URI, Data.CONTENT_URI,
    Contacts.CONTACTS_HARD_DELETE, Contacts.ADD_CONTACT_BATCH];
  public callback = () => {
    HiLog.d(TAG, 'Contacts changed: Notifying observers...');
    for (const observer of this.observers) {
      observer();
    }
  }
  public callbackWithData = (e: BusinessError, changeInfo: dataShare.ChangeInfo) => {
    HiLog.d(TAG, 'Contacts changed: Notifying observers type: ' + changeInfo?.type);
    if (e) {
      HiLog.i(TAG, 'contact change error: ' + e?.message + ', stack: ' + e?.stack);
      return;
    }

    for (const observer of this.observers) {
      observer(changeInfo);
    }
  }

  /**
   * 注册联系人变更事件
   */
  private registerContactsDataChange() {
    this.contactsUrl.forEach((url, index, array) => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        if (dataAbilityHelper) {
          dataAbilityHelper.on('dataChange', dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI, url,
            this.callbackWithData);
          HiLog.i(TAG, 'registerContactsDataChange success:' + index);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
      });
    })
  }

  private unregisterContactsDataChange() {
    this.contactsUrl.forEach((url, index, array) => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        if (dataAbilityHelper) {
          dataAbilityHelper.off('dataChange', dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI, url,
            this.callbackWithData);
          HiLog.i(TAG, 'unregisterContactsDataChange success:' + index);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
      });
    })
  }

  // 注册数据库监听变更事件
  registerDataChangeObserver(observer: (changeInfo?: dataShare.ChangeInfo) => void): void {
    if (!observer) {
      HiLog.i(TAG, `registerDataChangeObserver: observer is null.`);
      return;
    }
    if (this.observers.length == 0) {
      // 注册监听
      this.registerContactsDataChange();
    }
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return HiLog.i(TAG, 'registerDataChangeObserver: Observer has been attached already.');
    }
    HiLog.i(TAG, 'registerDataChangeObserver: Attached an observer, observers.size: ' + this.observers.length);
    this.observers.push(observer);
  }

  // 取消数据库监听变更事件
  unRegisterDataChangeObserver(observer: (changeInfo?: dataShare.ChangeInfo) => void) {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      HiLog.i(TAG, 'unRegisterDataChangeObserver: Nonexistent observer.');
      return
    }
    this.observers.splice(observerIndex, 1);
    HiLog.i(TAG, 'unRegisterDataChangeObserver: Detached an observer. observers.size: ' + this.observers.length);
    if (this.observers.length == 0) {
      this.unregisterContactsDataChange();
    }
  }

  // 恢复监听的uri和对应的通知type
  private restoreContactsUris: Array<LooseObject> = [
    { 'uri': NOTIFY_NOT_DOUBLE_TO_SINGLE_UPGRADE, 'type': RestoreResultType.NO_CONTACTS_TO_RESTORE },
    { 'uri': NOTIFY_DOUBLE_DB_FILE_NOT_COMPLETENESS, 'type': RestoreResultType.NO_CONTACTS_TO_RESTORE },
    { 'uri': NOTIFY_DELETE_SINGLE_DB_FAIL, 'type': RestoreResultType.RESTORE_FAILED },
    { 'uri': NOTIFY_RESTORE_BY_DOUBLE_DB_FININSH, 'type': RestoreResultType.RESTORE_SUCCESS }
  ]

  /**
   * 恢复联系人，通知监听
   * @param callBack
   */
  registerRestoreContactsDataChangeObs(callBack: Function) {
    HiLog.i(TAG, 'registerRestoreContactsDataChangeObs');
    this.restoreContactsUris.forEach(element => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        if (!dataAbilityHelper) {
          return;
        }
        dataAbilityHelper.on(
          'dataChange', dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI,
          element.uri,
          (e: BusinessError, changeInfo: dataShare.ChangeInfo) => {
            callBack?.(element.type);
          })
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `registerRestoreContactsDataChangeObs error ${error?.message}`);
      })
    });
  }

  unRegisterRestoreContactsDataChangeObs() {
    this.restoreContactsUris.forEach(element => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        if (!dataAbilityHelper) {
          return;
        }
        dataAbilityHelper.off(
          'dataChange',
          dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI,
          element.uri,
        );
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'unRegisterRestoreContactsDataChangeObs error');
      })
    })
  }

  async queryNameByNumber(numbers: string[], contactType?: number): Promise<DataShareResultSet | undefined> {
    if (numbers == null || numbers == undefined || numbers.length == 0) {
      return undefined;
    }
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      if (!dataAbilityHelper) {
        HiLog.e(TAG, 'queryNameByNumber, dataAbilityHelper is null');
        return undefined;
      }
      let resultColumns = [
        Data.DETAIL_INFO,
        RawContacts.DISPLAY_NAME,
        Data.FORMAT_PHONE_NUMBER
      ];
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.beginWrap();
      for (let i = 0; i < numbers.length; i++) {
        condition.endsWith('detail_info', NumberMatch.getInstance().getQueryNum(numbers[i]));
        if (i < numbers.length - 1) {
          condition.or();
        } else {
          condition.endWrap();
        }
      }
      condition.equalTo('type_id', '5');
      condition.and();
      condition.equalTo('is_deleted', '0');
      if (contactType) {
        condition.and();
        condition.equalTo('favorite', contactType);
      }
      let resSet: DataShareResultSet = await dataAbilityHelper.query(Data.CONTENT_URI, condition, resultColumns);
      return Promise.resolve(resSet);
    } catch (error) {
      HiLog.e(TAG, 'queryNameByNumber query, error: ' + error?.message + ', stack: ' + error?.stack);
      return undefined;
    }
  }


  async dealContactResultSet(resultSet: DataShareResultSet, numberList: ValueType[], contactType?: number) {
    let contacts: Record<string, string>[] = [];
    let matchedNumbers: string[] = [...numberList] as string[];
    while (resultSet?.goToNextRow()) {
      let contact: Record<string, string> = {};
      contact.detailInfo = resultSet.getString(0);
      contact.displayName = resultSet.getString(1);
      contacts.push(contact);
      let index = matchedNumbers.indexOf(contact.detailInfo);
      if (index >= 0) {
        matchedNumbers.splice(index, 1);
      }
    }
    matchedNumbers = matchedNumbers.filter(filter => !StringUtil.isEmpty(filter) && filter.length >= 7);
    let resSet: DataShareResultSet | undefined = await this.queryNameByNumber(matchedNumbers, contactType);
    if (resSet === undefined) {
      return contacts;
    }
    for (let number of matchedNumbers) {
      let index = await NumberMatch.getInstance().getCallerIndex(resSet, number);
      if (index > -1) {
        resSet.goToRow(index);
        let contact: Record<string, string> = {};
        contact.detailInfo = number as string;
        contact.displayName = resSet.getString(1);
        contacts.push(contact);
      }
    }
    return contacts;
  }

  findFavoriteByIndex(index: number, callback: Function) {
    HiLog.i(TAG, 'refreshUsually findFavoriteByIndex start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.equalTo(RawContacts.FAVORITE, 1);
    conditionArgs.and();
    conditionArgs.orderByAsc('favorite_order')
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, [])
        .then(resultSet => {
          try {
            let rst: ContactUsuallyListItemHasPhones[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new ContactUsuallyListItemHasPhones(resultSet));
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findFavoriteByIndex query data success.');
              let contactMap: Map<string, ContactUsuallyListItemHasPhones> = new Map()
              rst.forEach((item: ContactUsuallyListItemHasPhones) => {
                let key = item.id.toString();
                let val = contactMap.get(key) ?? item;
                val.phones = val.phones.concat(item.phones);
                contactMap.set(key, val);
              })
              contactMap.forEach((item: ContactUsuallyListItemHasPhones, key: string) => {
                if (item.phones.length === 0) {
                  contactMap.delete(key);
                }
              })
              let callbackData: ContactUsuallyListItemHasPhones[] = Array.from(contactMap.values()).slice(0, index)
              HiLog.i(TAG, `findFavoriteByIndex callbackData `);
              callback(callbackData);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findFavoriteByIndex error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findFavoriteByIndex error:%s' + error?.message);
      callback([]);
    });
  }

  findAllFavorite(callback: (v: ContactListItem[]) => void) {
    HiLog.i(TAG, 'refreshUsually findAllFavorite start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.equalTo(RawContacts.FAVORITE, 1);
    conditionArgs.and();
    conditionArgs.orderByAsc(RawContacts.FAVORITE_ORDER)
      .orderByAsc(RawContacts.SORT)
      .orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: ContactListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new ContactListItem(resultSet));
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findAllFavorite query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findAllFavorite error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findAllFavorite error:%s' + error?.message);
      callback([]);
    });
  }

  findAllUsually(callback: Function) {
    HiLog.i(TAG, 'refreshUsually findAllUsually start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.groupBy([Calls.DISPLAY_NAME, Calls.PHONE_NUMBER]).distinct();
    conditionArgs.and();
    conditionArgs.orderByDesc(Calls.TALK_DURATION);
    conditionArgs.and();
    conditionArgs.orderByDesc(Calls.CREATE_TIME);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Calls.CALL_LOG_URI, conditionArgs, null)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: CallLog[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let builder = CallLogBuilder.fromResultSet(resultSet);
                if (builder.id > 0) {
                  rst.push(new CallLog(builder));
                }
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findAllUsually query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findAllUsually error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findAllUsually error:%s' + error?.message);
      callback([]);
    });
  }


  findAllUsuallyByRawContact(callback: Function) {
    HiLog.i(TAG, 'refreshUsually findAllUsuallyByRawContact start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('favorite', 0);
    conditionArgs.and();
    conditionArgs.equalTo('type_id', '5');
    conditionArgs.and();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.and();
    conditionArgs.equalTo('extend8', '1');
    conditionArgs.and();
    conditionArgs.greaterThan('contacted_count', 0);
    conditionArgs.and();
    conditionArgs.orderByDesc('contacted_count');
    conditionArgs.and();
    conditionArgs.limit(10, 0);
    conditionArgs.and();
    conditionArgs.orderByDesc('lastest_contacted_time');

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: ContactUsuallyListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new ContactUsuallyListItem(resultSet));
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findAllUsuallyByRawContact query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findAllUsuallyByRawContact error:%s' + error?.message);
      callback([]);
    });
  }

  getDisplayNameByFavorite(displayName: ValueType[], usuallyPhone: ValueType[], callback: Function) {
    HiLog.i(TAG, 'getDisplayNameByFavorite start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.groupBy([RawContacts.DISPLAY_NAME]).distinct();
    conditionArgs.and();
    conditionArgs.equalTo(Data.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.in(RawContacts.DISPLAY_NAME, displayName);
    conditionArgs.and();
    conditionArgs.in(Data.DETAIL_INFO, usuallyPhone);
    conditionArgs.and();
    conditionArgs.equalTo(RawContacts.FAVORITE, 0);
    conditionArgs.and();
    conditionArgs.equalTo(Data.CONTENT_TYPE, 'phone');
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, ContactUsuallyListItem.COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: ContactUsuallyListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new ContactUsuallyListItem(resultSet));
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'getDisplayNameByFavorite query data sc.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'getDisplayNameByFavorite error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getDisplayNameByFavorite error:%s' + error?.message);
      callback([]);
    });
  }

  async getAllFavoriteSizeAndIndex(process: (jsonObj: NameFixInfo,
    index: number, alphabetIndex: Record<string, AlphabetIndexObj>,
    isEnd: boolean) => void, callback: Function) {

    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.equalTo(RawContacts.FAVORITE, 1);
    conditionArgs.and();
    conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    let resultColumns = [RawContacts.SORT_FIRST_LETTER, RawContacts.PHOTO_FIRST_NAME, RawContacts.DISPLAY_NAME];
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      HiLog.i(TAG, 'getAllContactSizeAndIndex begin')
      hiTraceMeter.startTrace('getAllContactSizeAndIndex', 1);
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.i(TAG, 'getAllContactSizeAndIndex end: ' + resultSet.rowCount);
            hiTraceMeter.finishTrace('getAllContactSizeAndIndex', 1);
            let alphabetIndex: Record<string, AlphabetIndexObj> = {}
            let count: number = resultSet.rowCount;
            if (count <= 0) {
              callback(new CountAlphabetIndex(count, alphabetIndex));
            } else {
              resultSet.goToFirstRow();
              let index: number = 0;
              do {
                let namePrefix: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.SORT_FIRST_LETTER));
                let nameSuffix: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.PHOTO_FIRST_NAME));
                let displayName: string = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
                process(new NameFixInfo(namePrefix, nameSuffix, displayName), index, alphabetIndex,
                  index === count - 1);
                index++;
              } while (resultSet.goToNextRow());
              callback(new CountAlphabetIndex(count, alphabetIndex));
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'getAllContactIndex error:%s' + error?.message);
          callback(new CountAlphabetIndex(0, {}));
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(new CountAlphabetIndex(0, {}));
    });
  }

  async saveRingToneToContact(id: string, uri: string, ringToneName: string, ringToneFilePath: string,
    callBack: Function) {
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('id', id);
      HiLog.i(TAG, 'saveRingToneToContact update start');
      await dataAbilityHelper.update(Contacts.CONTACT_URI, condition, {
        'personal_ringtone': StringUtil.isEmpty(uri) ? null : uri,
        'personal_notification_ringtone': StringUtil.isEmpty(ringToneName) ? null : ringToneName,
        'ringtone_path': StringUtil.isEmpty(ringToneFilePath) ? null : ringToneFilePath
      });
      HiLog.i(TAG, 'saveRingToneToContact update success');
      callBack(true);
    } catch (err) {
      HiLog.w(TAG, 'saveRingToneToContact err:' + err?.message + ', stack: ' + err?.stack);
    }
  }

  async queryLocalRingToneUsedTimes(id: string, uri: string, callBack: Function) {
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('personal_ringtone', uri);
      condition
        .groupBy(['contact_id'])
        .distinct();
      HiLog.i(TAG, 'queryLocalRingToneUsedTimes update start');
      resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, condition, []);
      let res: number = 0;
      if (resultSet) {
        res = resultSet?.rowCount;
        HiLog.w(TAG, `queryLocalRingToneUsedTimes count is ${res}`)
      }
      callBack(res);
    } catch (err) {
      HiLog.w(TAG, 'queryLocalRingToneUsedTimes err:' + err?.message + ', stack: ' + err?.stack);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  searchContact(actionData: IContactSearchParams, callback: Function) {
    HiLog.i(TAG, 'searchContact start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    let searchValue: string = actionData.value;
    conditionArgs.beginWrap();
    conditionArgs.beginWrap();
    conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'phone');
    conditionArgs.and();
    conditionArgs.beginWrap();
    conditionArgs.like(SearchContacts.DETAIL_INFO, '%' + searchValue + '%');
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.equalTo(SearchContacts.SORT_FIRST_LETTER, '#');
    conditionArgs.and();
    conditionArgs.like(SearchContacts.SEARCH_NAME, '%' + searchValue + '%');
    conditionArgs.endWrap();
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.equalTo(SearchContacts.SORT_FIRST_LETTER, searchValue[0].toUpperCase());
    conditionArgs.and();
    conditionArgs.like(SearchContacts.SEARCH_NAME, '%' + searchValue + '%');
    conditionArgs.and();
    conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'phone');
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.equalTo(SearchContacts.SORT_FIRST_LETTER, searchValue.toUpperCase());
    conditionArgs.and();
    conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'phone');
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.like(SearchContacts.SEARCH_NAME, '%' + actionData.value + '%');
    conditionArgs.and();
    conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'phone');
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.like(SearchContacts.SEARCH_NAME, '%' + actionData.value + '%');
    conditionArgs.and();
    conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'name');
    conditionArgs.and();
    conditionArgs.equalTo(SearchContacts.HAS_PHONE_NUMBER, '0');
    conditionArgs.endWrap();
    conditionArgs.endWrap();
    conditionArgs.and();
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    conditionArgs.and()
    conditionArgs.groupBy([SearchContacts.ROW_CONTACT_ID]).distinct();
    conditionArgs.and()
    conditionArgs.limit(actionData.limitNumber, actionData.startIndex);

    let resultData: ContactSearchResultData = new ContactSearchResultData(0, [], actionData.value);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(SearchContacts.CONTENT_URI, conditionArgs, SearchContactListItem.COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.i(TAG, 'searchContact resultSet.rowCount : ' + resultSet?.rowCount);
            let rst: SearchContactListItem[] = [];
            let goTo: boolean = false;
            let totalNum: number = resultSet.rowCount;
            if (totalNum === 0) {
              resultData.data = rst;
              callback(resultData);
            } else {
              resultSet.goToFirstRow();
              do {
                rst.push(new SearchContactListItem(resultSet));
                goTo = resultSet.goToNextRow();
              } while (goTo);
              resultData.data = rst;
              HiLog.i(TAG, 'searchContact query data success.');
              callback(resultData);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'searchContact error:%s' + error?.message);
          callback(resultData);
        });
    }).catch((error: BusinessError) => {
      HiLog.i(TAG, 'searchContact:%s' + error?.message);
      callback(resultData);
    });
  }

  queryT9PhoneIsNotNull(favorite: IT9PhoneNumbersFavoriteType, callback: Function) {
    this.getAllContactNumbers(0, 0, (contactNumberMap) => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        conditionArgs.like(SearchContacts.DETAIL_INFO, `%${favorite.teleNumber}%`);
        conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
        conditionArgs.and();
        conditionArgs.equalTo(SearchContacts.CONTENT_TYPE, 'phone');
        conditionArgs.orderByAsc(SearchContacts.DISPLAY_NAME)
        dataAbilityHelper.query(
          SearchContacts.CONTENT_URI,
          conditionArgs,
          SearchContactListItem.COLUMNS
        ).then((resultSet: DataShareResultSet) => {
          try {
            let rst: ContactListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                let phoneNumbers: PhoneNumberInterface[] | undefined = contactNumberMap.get(id);
                if (phoneNumbers == undefined) {
                  HiLog.w(TAG, 'findAll: contact id is invalid or contact has no phone number.');
                  continue;
                }
                let contactListItem = new ContactListItem(resultSet);
                contactListItem.phoneNumbers = phoneNumbers;
                rst.push(contactListItem);
              } while (resultSet.goToNextRow());
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, 'findAll error:%s' + error?.message);
            callback();
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
        callback();
      });
    });
  }

  findAllGroup(callback: (v: GroupListItem[]) => void) {
    HiLog.i(TAG, 'findAllGroup start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.and();
    conditionArgs.orderByAsc('group_name');

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.GROUP_SYNC_URI, conditionArgs, ['*'])
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: GroupListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let groupListItem = new GroupListItem(resultSet);
                rst.push(groupListItem);
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'findAllGroup query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'findAllGroup error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findAllGroup error:%s' + error?.message);
      callback([]);
    });
  }

  async renameGroup(addParams: GroupParams, callback: Function) {
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('id', addParams.id);
      condition.and();
      condition.equalTo('is_deleted', 0);
      await dataAbilityHelper.update(Contacts.GROUP_SYNC_URI, condition, {
        'group_name': addParams.groupName,
        'lastest_modify_time': new Date().valueOf()
      })
      callback();
      HiLog.i(TAG, 'renameGroup update success');
    } catch (err) {
      HiLog.w(TAG, 'renameGroup err:' + err?.message + ', stack: ' + err?.stack);
    }
  }

  removeGroup(id: number, callback: Function) {
    if (id < 0) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('id', id);
      condition.and();
      condition.equalTo('is_deleted', 0);
      dataAbilityHelper.update(Contacts.GROUP_SYNC_URI, condition, {
        'is_deleted': 1,
      }).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'removeGroup error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  findGroupByGroupIds(groupIds: number[], userId: number, callback: Function) {
    HiLog.w(TAG, 'findGroupByGroupIds start');
    if (groupIds.length < 0) {
      callback([]);
      return;
    }
    this.getDataAbilityHelper(userId).then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in('id', groupIds);
      condition.and();
      condition.equalTo('is_deleted', 0);
      dataAbilityHelper.query(Contacts.GROUP_SYNC_URI, condition, [RowGroup.ID, RowGroup.GROUP_NAME])
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: GroupListItem[] = [];
            if (resultSet.rowCount === 0) {
              HiLog.w(TAG, 'findGroupByGroupIds query data rowCount is 0.');
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let groupListItem = new GroupListItem(resultSet);
                rst.push(groupListItem);
              } while (resultSet.goToNextRow());
              HiLog.w(TAG, 'findGroupByGroupIds query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'findGroupByGroupIds query error: ' + error?.message);
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findGroupByGroupIds error: ' + error?.message);
      callback([]);
    });
  }

  deleteGroupsById(ids: number[], callback: Function) {
    if (ArrayUtil.isEmpty(ids)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in('id', ids);
      condition.and();
      condition.equalTo('is_deleted', 0);

      dataAbilityHelper.update(Contacts.GROUP_SYNC_URI, condition, {
        'is_deleted': 1,
      }).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'deleteGroupsById error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  queryGroupItemByName(groupName: string, callback: Function) {
    HiLog.i(TAG, 'queryGroupItemByName start.');
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(RowGroup.GROUP_NAME, groupName);
    condition.and();
    condition.equalTo('is_deleted', 0);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.GROUP_SYNC_URI, condition, GroupListItem.COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: GroupBean = new GroupBean(-1, '', '', '', '', '', 0, 0);
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              rst.setAll(resultSet);
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'queryGroupItemByName error:%s' + error?.message);
          callback();
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryGroupItemByName error:%s' + error?.message);
      callback(error.message);
    });
  }

  findMemberByPhoneIsNotNull(groupId: number, callback: Function) {
    this.getAllMemberNumbers(groupId, (contactNumberMap) => {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        conditionArgs.equalTo('type_id', '9');
        conditionArgs.and();
        conditionArgs.equalTo('is_deleted', 0);
        conditionArgs.and();
        conditionArgs.equalTo('group_id', groupId);
        conditionArgs.and()
          .orderByAsc(RawContacts.SORT_FIRST_LETTER);
        dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, ['*'])
          .then((resultSet: DataShareResultSet) => {
            try {
              let rst: GroupMemberItem[] = [];
              if (resultSet.rowCount === 0) {
                callback(rst);
              } else {
                resultSet.goToFirstRow();
                do {
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
                  if (!contactNumberMap.has(id)) {
                    HiLog.w(TAG, 'findAll: contact id is invalid or contact has no phone number.');
                    continue;
                  }
                  let contactListItem = new GroupMemberItem(resultSet);
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  rst.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(rst);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, 'findAll error:%s' + error?.message);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'error:%s' + error?.message);
        callback(undefined);
      });
    });
  }

  // 回调 {contactId, PhoneNumberInterface[]} 类型map
  getAllMemberNumbers(groupId: number, callback: (v: Map<number, PhoneNumberInterface[]>) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', 0);
      conditionArgs.and();
      conditionArgs.equalTo(Data.TYPE_ID, DataItemType.PHONE)
        .orderByAsc(RawContacts.CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, ['*']).then((resultSet: DataShareResultSet) => {
        try {
          let contactNumberMap = new Map<number, PhoneNumberInterface[]>();
          if (resultSet == undefined || !resultSet.goToFirstRow()) {
            HiLog.w(TAG, 'getAllContactNumbers not found.');
            callback(contactNumberMap);
            return;
          }
          let oldContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
          let oldPhoneNumber = '';
          let numberList: PhoneNumberInterface[] = [];
          do {
            let newContact: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
            //In order to be compatible with the PhoneNumberInterface
            //we add  labelName and checked  and set default value
            let phoneNumberObj: PhoneNumberInterface = {
              dataId: resultSet.getLong(resultSet.getColumnIndex(Data.ID)) as number,
              phoneNumber: resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)) as string,
              labelId: resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7)) as string,
              numType: resultSet.getString(resultSet.getColumnIndex(Data.CUSTOM_DATA)) as string,
              primary: (resultSet.getString(resultSet.getColumnIndex(Data.EXTEND5)) as string) == '1',
              labelName: '',
              checked: false,
              startPhone: '',
              middlePhone: '',
              endPhone: ''
            }
            ;
            if (oldContact === newContact) {
              if (oldPhoneNumber != phoneNumberObj.phoneNumber) {
                numberList.push(phoneNumberObj);
              }
            } else {
              contactNumberMap.set(oldContact, numberList);
              oldContact = newContact;
              numberList = [phoneNumberObj];
            }
            oldPhoneNumber = phoneNumberObj.phoneNumber;
          } while (resultSet.goToNextRow());
          contactNumberMap.set(oldContact, numberList);
          callback(contactNumberMap);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback(new Map());
    });
  }

  queryAllGroupMember(groupId: string, callback: Function) {
    HiLog.i(TAG, 'queryAllGroupMember start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.and();
    conditionArgs.equalTo('type_id', '9');
    conditionArgs.and();
    conditionArgs.equalTo('detail_info', groupId);
    conditionArgs.and();
    conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, ['*'])
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: GroupMemberItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let memberListItem = new GroupMemberItem(resultSet);
                rst.push(memberListItem);
              } while (resultSet.goToNextRow());
              HiLog.i(TAG, 'queryAllGroupMember query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'queryAllGroupMember error:%s' + error?.message);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryAllGroupMember error:%s' + error?.message);
      callback([]);
    });
  }

  /**
   * 根据联系人contactid查询rawcontactId
   *
   * @param contactId contactId
   * @returns rawcontactIdList
   */
  // instrument ignore next
  public async getNumberRawContactIdsByContactId(contactId: number) {
    let rawContactIdListDefault: number[] = [contactId];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let rawContactIds: number[] = [];
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance()
          .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext())
          .getDataAbilityHelper();
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('contact_id', contactId);
      resultSet = await daHelper.query(Contacts.CONTACT_RAW_URI, predicates, [Data.ID]);
      if (resultSet && resultSet.goToFirstRow()) {
        do {
          let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.ID));
          rawContactIds.push(rawContactId);
        } while (resultSet.goToNextRow());
      }
      return rawContactIds;
    } catch (error) {
      HiLog.e(TAG, `getRawContactIdsByNumberContactId err:${error?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return rawContactIdListDefault;
  }

  /**
   * query contact info by company for batch send message
   *
   * @param origanization company
   * @callBack callBack
   */
  // instrument ignore next
  queryContactsByOriganizationForSendMsg(origanization: string, callback: Function) {
    HiLog.i(TAG, `queryContactsByOriganizationForSendMsg :${origanization?.length}`);
    // 获取联系人号码{联系人id，联系人对应电话信息集合}
    this.getAllMemberNumbers(1, (contactNumberMap) => {
      // 查询联系人信息
      this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {
        // 过滤条件
        let queryCityCondition = new dataSharePredicates.DataSharePredicates();
        let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

        if (accountId != -1) {
          queryCityCondition.equalTo(RawContacts.ACCOUNT_ID, accountId);
          queryCityCondition.and();
        }
        if (origanization) {
          queryCityCondition.equalTo(RawContacts.COMPANY, origanization);
          queryCityCondition.and();
        } else {
          queryCityCondition.beginWrap();
          queryCityCondition.isNull(RawContacts.COMPANY);
          queryCityCondition.or();
          queryCityCondition.equalTo(RawContacts.COMPANY, '');
          queryCityCondition.endWrap();
          queryCityCondition.and();
        }
        // 查询我的名片信息
        queryCityCondition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
        queryCityCondition.and();
        // 查询未删除的
        queryCityCondition.equalTo(RawContacts.IS_DELETED, '0')
          .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
        dataAbilityHelper.query(Contacts.CONTACT_URI, queryCityCondition, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            try {
              let contactsByCompany: ContactListItem[] = [];
              if (!resultSet) {
                HiLog.e(TAG, `queryContactsByOriganizationForSendMsg resultSet undefined.`);
                callback(contactsByCompany);
                return;
              }
              if (resultSet.rowCount === 0) {
                HiLog.e(TAG, `queryContactsByOriganizationForSendMsg resultSet empty.`);
                callback(contactsByCompany);
              } else {
                resultSet.goToFirstRow();
                do {
                  // contact id
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                  if (!contactNumberMap.has(id)) {
                    continue;
                  }
                  // filter my card
                  if (resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD)) === '1') {
                    continue;
                  }
                  // build contact info
                  let contactListItem = new ContactListItem(resultSet);
                  // set phonenumbers
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  contactsByCompany.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(contactsByCompany);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, `queryContactsByOriganizationForSendMsg error:${error?.message}`);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `queryContactsByOriganizationForSendMsg err:${error?.message}`);
        callback(undefined);
      })
    });
  }

  /**
   * query contact info by location for batch send message
   *
   * @param location location
   * @callBack callBack
   */
  // instrument ignore next
  queryContactsByCityForSendMsg(location: string, callback: Function) {
    HiLog.i(TAG, `queryContactsByCityForSendMsg start,${TextUtils.getMaskString(location)}`);
    // 获取联系人号码{联系人id，联系人对应电话信息集合}
    this.getAllMemberNumbers(1, (contactNumberMap) => {
      // 查询联系人信息
      this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {
        // 过滤条件
        let queryCityCondition = new dataSharePredicates.DataSharePredicates();
        let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

        if (accountId != -1) {
          queryCityCondition.equalTo(RawContacts.ACCOUNT_ID, accountId);
          queryCityCondition.and();
        }
        if (location) {
          queryCityCondition.beginsWith(RawContacts.LOCATION, location);
          queryCityCondition.and();
        } else {
          queryCityCondition.beginWrap();
          queryCityCondition.isNull(RawContacts.LOCATION);
          queryCityCondition.or();
          queryCityCondition.equalTo(RawContacts.LOCATION, '');
          queryCityCondition.endWrap();
          queryCityCondition.and();
        }
        // 查询我的名片信息
        queryCityCondition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
        queryCityCondition.and()
        // 查询未删除的
        queryCityCondition.equalTo(RawContacts.IS_DELETED, '0')
          .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
        dataAbilityHelper.query(Contacts.CONTACT_LOCATION_URI, queryCityCondition, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            try {
              let contatsByCity: ContactListItem[] = [];
              if (!resultSet) {
                HiLog.e(TAG, `queryContactsByCityForSendMsg resultSet undefined.`);
                callback(contatsByCity);
                return;
              }
              if (resultSet.rowCount === 0) {
                HiLog.e(TAG, `queryContactsByCityForSendMsg resultSet undefined.`);
                callback(contatsByCity);
              } else {
                resultSet.goToFirstRow();
                do {
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                  if (!contactNumberMap.has(id)) {
                    continue;
                  }

                  // filter my card
                  if (resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD)) === '1') {
                    continue;
                  }
                  // build contact info
                  let contactListItem = new ContactListItem(resultSet);
                  // set phonenumbers
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  contatsByCity.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(contatsByCity);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, `queryContactsByCityForSendMsg err:${error?.message}`);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `queryContactsByCityForSendMsg err:${error?.message}`);
        callback(undefined);
      });
    });
  }

  /**
   * query contact info by contactTime for batch send message
   *
   * @param contactTimeType contactTimeType
   * @callBack callBack
   */
  // instrument ignore next
  queryContactsByTimestampForSendMsg(contactTimeType: string, callback: Function) {
    HiLog.i(TAG, `queryContactsByTimestampForSendMsg start,${contactTimeType}`);
    if (contactTimeType == undefined) {
      HiLog.i(TAG, `queryContactsByTimestampForSendMsg contactTimeType undefined`);
      callback(undefined)
      return;
    }
    // 获取联系人号码{联系人id，联系人对应电话信息集合}
    this.getAllMemberNumbers(1, (contactNumberMap) => {
      // 查询联系人信息
      this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {
        // 过滤条件
        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;

        if (accountId != -1) {
          conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
        }
        const timestamps: IntelligenceGroupTimestamps = this.getIntelligenceGroupTimestamps();
        const oneWeekConactTimeStamp: number = timestamps.timestampOneWeekAgo;
        const oneMonthConactTimeStamp: number = timestamps.timestampOneMonthAgo;
        const thressMonthConactTimeStamp: number = timestamps.timestampThreeMonthsAgo;
        if (contactTimeType === '0') {
          // 1周内联系人过
          conditionArgs.greaterThan(RawContacts.LASTEST_CONTACTED_TIME, oneWeekConactTimeStamp);
          conditionArgs.and();
        } else if (contactTimeType === '1') {
          // 1个月内联系人过
          conditionArgs.greaterThan(RawContacts.LASTEST_CONTACTED_TIME, oneMonthConactTimeStamp);
          conditionArgs.and()
          conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, oneWeekConactTimeStamp);
          conditionArgs.and();
        } else if (contactTimeType === '2') {
          // 3个月内联系人过
          conditionArgs.greaterThan(RawContacts.LASTEST_CONTACTED_TIME, thressMonthConactTimeStamp);
          conditionArgs.and()
          conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, oneMonthConactTimeStamp);
          conditionArgs.and();
        } else if (contactTimeType === '3') {
          // 3个月以上联系人过
          conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, thressMonthConactTimeStamp);
          conditionArgs.and();
        } else {
          HiLog.w(TAG, 'queryIntelligenceGroupContactsByTimestamp contactTimeType invalid.');
        }
        // 查询我的名片信息
        conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
        conditionArgs.and();
        // 查询未删除的
        conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
          .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
        dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
          .then((resultSet: DataShareResultSet) => {
            try {
              let contactsByTimeStamp: ContactListItem[] = [];
              if (!resultSet) {
                HiLog.e(TAG, `queryContactsByTimestampForSendMsg resultSet undefined.`);
                callback(contactsByTimeStamp);
                return;
              }
              if (resultSet.rowCount === 0) {
                HiLog.e(TAG, `queryContactsByTimestampForSendMsg resultSet undefined.`);
                callback(contactsByTimeStamp);
              } else {
                resultSet.goToFirstRow();
                do {
                  let id: number = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                  if (!contactNumberMap.has(id)) {
                    continue;
                  }
                  // filter my card
                  if (resultSet.getString(resultSet.getColumnIndex(RawContacts.MARK_MY_CARD)) === '1') {
                    continue;
                  }
                  // build contact info
                  let contactListItem = new ContactListItem(resultSet);
                  // set phonenumbers
                  let phoneNumbersObj: PhoneNumberInterface[] | undefined = contactNumberMap.get(id)
                  if (phoneNumbersObj !== undefined) {
                    contactListItem.phoneNumbers = phoneNumbersObj;
                  }
                  contactsByTimeStamp.push(contactListItem);
                } while (resultSet.goToNextRow());
                callback(contactsByTimeStamp);
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, `queryContactsByTimestampForSendMsg err:${error?.message}`);
            callback(undefined);
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `queryContactsByTimestampForSendMsg err:${error?.message}`);
        callback(undefined);
      });
    });
  }

  /**
   * query contact info by organization
   *
   * @param organization company
   * @callBack callBack
   */
  // instrument ignore next
  async queryIntelligenceGroupContactsByOrganization(organization: string, page: number, callback: Function) {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganization :${organization?.length}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (page >= 1) {
      conditionArgs.limit(INTELLIGENCE_GROUP_LIMIT_RECORDS, (page - 1) * INTELLIGENCE_GROUP_LIMIT_RECORDS);
    }
    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
      conditionArgs.and()
    }
    if (organization) {
      conditionArgs.equalTo(RawContacts.COMPANY, organization);
      conditionArgs.and()
    } else {
      conditionArgs.beginWrap()
      conditionArgs.isNull(RawContacts.COMPANY)
      conditionArgs.or()
      conditionArgs.equalTo(RawContacts.COMPANY, '');
      conditionArgs.endWrap()
    }
    // 查询我的名片信息
    conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    conditionArgs.and()
    // 查询未删除的
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs,
        ContactListItem.COLUMNS_CONTACT_LIST_GET_ALL_CONTACT_INCLUDE_CONTACT_TIME)
        .then((resultSet: DataShareResultSet) => {
          try {
            callback(resultSet);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          // 联系人故障打点-查询联系人列表异常
          faultContactParams.FAULT_INFO = error.message;
          DotUtil.getInstance().reportFaultEvent(faultContactParams,
            dotCommon.faultEventName.DISPLAY_CONTACTS_LIST_ERROR);
          HiLog.e(TAG, `queryIntelligenceGroupContactsByOrganization err:${error?.message}`);
          callback(undefined);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `queryIntelligenceGroupContactsByOrganization err:${error?.message}`);
      emitter.emit(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
      callback(undefined);
    });
  }

  /**
   * query contact info by home area
   *
   * @param location home area
   * @param page page
   * @callBack callBack
   */
  // instrument ignore next
  async queryIntelligenceGroupContactsByCity(location: string, page: number, callback: Function) {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByCity: ${TextUtils.getMaskString(location)},${page}`);
    let queryCityCondition = new dataSharePredicates.DataSharePredicates();
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (page >= 1) {
      queryCityCondition.limit(INTELLIGENCE_GROUP_LIMIT_RECORDS, (page - 1) * INTELLIGENCE_GROUP_LIMIT_RECORDS);
    }
    if (accountId != -1) {
      queryCityCondition.equalTo(RawContacts.ACCOUNT_ID, accountId);
      queryCityCondition.and()
    }
    if (location) {
      queryCityCondition.beginsWith(RawContacts.LOCATION, location);
      queryCityCondition.and()
    } else {
      queryCityCondition.beginWrap()
      queryCityCondition.isNull(RawContacts.LOCATION)
      queryCityCondition.or()
      queryCityCondition.equalTo(RawContacts.LOCATION, '');
      queryCityCondition.endWrap()
      queryCityCondition.and()
    }
    // 查询我的名片信息
    queryCityCondition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    queryCityCondition.and()
    // 查询未删除的
    queryCityCondition.equalTo(RawContacts.IS_DELETED, '0')
      .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_LOCATION_URI, queryCityCondition,
        ContactListItem.COLUMNS_CONTACT_LIST_GET_ALL_CONTACT_INCLUDE_CONTACT_TIME)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.w(TAG, 'query succeeded ' + resultSet.rowCount);
            callback(resultSet);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          // 联系人故障打点-查询联系人列表异常
          HiLog.e(TAG, `queryIntelligenceGroupContactsByCity err:${error?.message}`);
          callback(undefined);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `queryIntelligenceGroupContactsByCity err:${error?.message}`);
      emitter.emit(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
      callback(undefined);
    });
  }

  /**
   * batch update contact company by contactids for contact database
   *
   * @param ids rawContactIds
   * @param company company
   * @param callBack callBack
   */
  // instrument ignore next
  async updateOrganizationToContact(ids: number[], company: string, callBack: Function) {
    if (!ids || ids.length === 0) {
      HiLog.e(TAG, 'updateOrganizationToContact param invalid.');
      callBack(false);
      return;
    }
    try {
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in('id', ids);
      let ret = await dataAbilityHelper.update(Contacts.CONTACT_URI, condition, {
        'company': StringUtil.isEmpty(company) ? null : company,
      });
      HiLog.i(TAG, `updateOrganizationToContact update success:${ret}`);
      callBack(true);
    } catch (err) {
      HiLog.e(TAG, `updateOrganizationToContact err:${err?.message}`);
      callBack(false);
    }
  }

  /**
   * batch update contact company by contactids for contact_data database
   *
   * @param ids contactids
   * @param company company
   * @param callBack callBack
   */
  // instrument ignore next
  async updateOrganizationToContactData(ids: number[], company: string, callBack: Function) {
    HiLog.e(TAG, `updateOrganizationToContactData: ${ids.length},company:${company?.length}`);
    if (!ids || ids.length === 0) {
      HiLog.e(TAG, 'updateContactOrganizationInfo param invalid.');
      callBack(false);
      return;
    }
    let queryCondition = new dataSharePredicates.DataSharePredicates();
    queryCondition.equalTo('type_id', 4);
    queryCondition.and();
    queryCondition.in('raw_contact_id', ids);
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      // 查询出contact_data表中有单位的联系人
      let dataHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();
      resultSet =
        await dataHelper.query(Data.CONTENT_URI, queryCondition, [RawContactsColumns.CONTACT_ID, Data.RAW_CONTACT_ID]);
      if (resultSet === undefined) {
        HiLog.e(TAG, 'updateContactOrganizationInfo resultSet undefined');
        callBack(false);
        return;
      }
      HiLog.e(TAG, `updateContactOrganizationInfo rowCount=${resultSet.rowCount}`);
      let needUpdateRawContactIds: number[] = [];
      let needInsertContactDataArr: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
          needUpdateRawContactIds.push(rawContactId);
        } while (resultSet.goToNextRow());
      }
      for (let oriRawContactId of ids) {
        if (!needUpdateRawContactIds.includes(oriRawContactId)) {
          let organizationContact: Record<string, string | number> = {
            'raw_contact_id': oriRawContactId,
            'detail_info': company,
            'type_id': 4,
          };
          needInsertContactDataArr.push(organizationContact);
        }
      }
      HiLog.e(TAG, `insert len: ${needInsertContactDataArr.length},update len:${needUpdateRawContactIds.length}`);
      if (needInsertContactDataArr && needInsertContactDataArr.length) {
        let batchInsertResult: number = await dataHelper.batchInsert(Data.CONTENT_URI, needInsertContactDataArr);
        HiLog.i(TAG, `updateOrganizationToContactData batchInsert result :${batchInsertResult}`);
      }
      if (needUpdateRawContactIds && needUpdateRawContactIds.length) {
        let updatePredicates = new dataSharePredicates.DataSharePredicates();
        updatePredicates.equalTo('type_id', 4);
        updatePredicates.and();
        updatePredicates.in('raw_contact_id', needUpdateRawContactIds);
        let updateRet = await dataHelper.update(Data.CONTENT_URI, updatePredicates, {
          'detail_info': company
        });
        HiLog.i(TAG, `updateOrganizationToContactData update result :${updateRet}`);
      }
    } catch (err) {
      HiLog.e(TAG, `updateOrganizationToContactData err:${err?.message}`);
      callBack(false);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  /**
   * query contact info by Timestamp
   *
   * @param contactTimeType Timestamp type
   * @param page page
   * @callBack callBack
   */
  // instrument ignore next
  async queryIntelligenceGroupContactsByTimestamp(contactTimeType: string, page: number,  callback: Function) {
    HiLog.w(TAG, `queryIntelligenceGroupContactsByTimestamp start:${contactTimeType},${page}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    let accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (page >= 1) {
      conditionArgs.limit(INTELLIGENCE_GROUP_LIMIT_RECORDS, (page - 1) * INTELLIGENCE_GROUP_LIMIT_RECORDS);
    }
    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    const timestamps: IntelligenceGroupTimestamps = this.getIntelligenceGroupTimestamps();
    const oneWeekConactTimeStamp: number = timestamps.timestampOneWeekAgo;
    const oneMonthConactTimeStamp: number = timestamps.timestampOneMonthAgo;
    const thressMonthConactTimeStamp: number = timestamps.timestampThreeMonthsAgo;
    if (contactTimeType === '0') {
      // 1周内联系人过
      conditionArgs.greaterThanOrEqualTo(RawContacts.LASTEST_CONTACTED_TIME, oneWeekConactTimeStamp);
    } else if (contactTimeType === '1') {
      // 1个月内联系人过
      conditionArgs.greaterThanOrEqualTo(RawContacts.LASTEST_CONTACTED_TIME, oneMonthConactTimeStamp);
      conditionArgs.and()
      conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, oneWeekConactTimeStamp);
    } else if (contactTimeType === '2') {
      // 3个月内联系人过
      conditionArgs.greaterThanOrEqualTo(RawContacts.LASTEST_CONTACTED_TIME, thressMonthConactTimeStamp);
      conditionArgs.and()
      conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, oneMonthConactTimeStamp);
    } else if (contactTimeType === '3') {
      // 3个月以上联系人过
      conditionArgs.lessThan(RawContacts.LASTEST_CONTACTED_TIME, thressMonthConactTimeStamp);
    } else {
      HiLog.w(TAG, 'queryIntelligenceGroupContactsByTimestamp contactTimeType invalid.');
    }
    // 查询我的名片信息
    conditionArgs.notEqualTo(RawContacts.MARK_MY_CARD, '1');
    // 查询未删除的
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
      .orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs,
        ContactListItem.COLUMNS_CONTACT_LIST_GET_ALL_CONTACT_INCLUDE_CONTACT_TIME)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.w(TAG, `queryIntelligenceGroupContactsByTimestamp:${resultSet?.rowCount}`);
            callback(resultSet);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `queryIntelligenceGroupContactsByTimestamp err:${error?.message}`);
          callback(undefined);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `queryIntelligenceGroupContactsByTimestamp err:${error?.message}`);
      callback(undefined);
    });
  }

  private getIntelligenceGroupTimestamps(): IntelligenceGroupTimestamps {
    const nowDate: Date = new Date();
    const currentTime: number = nowDate.getTime();
    HiLog.i(TAG, `getIntelligenceGroupTimestamps currentTime: ${currentTime}`);
    const timestamps: IntelligenceGroupTimestamps = new IntelligenceGroupTimestamps();
    timestamps.timestampOneWeekAgo = currentTime / 1000 - 7 * SECONDS_OF_ONE_DAY;
    timestamps.timestampOneMonthAgo = new Date(currentTime).setMonth(nowDate.getMonth() - 1) / 1000;
    timestamps.timestampThreeMonthsAgo = new Date(currentTime).setMonth(nowDate.getMonth() - 3) / 1000;
    return timestamps;
  }


  /**
   * queryContactByContactIds
   *
   * @param hasSearchContactIds mixsearch contactIdlist
   * @param context context
   * @returns contactIdlist
   */
  async queryContactByContactIds(hasSearchContactIds: string[],
    context?: common.UIAbilityContext): Promise<string[]> {
    if (!context || !hasSearchContactIds || hasSearchContactIds.length === 0) {
      HiLog.e(TAG, 'queryContactByContactIds invalid.');
      return [];
    }
    let resultList: string[] = [];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let columns = [Contacts.ID];
      // 电话号码正则
      let condition = new dataSharePredicates.DataSharePredicates();
      // 查询未删除的
      condition.equalTo(RawContacts.IS_DELETED, '0')
      condition.and()
      condition.in(Contacts.ID, hasSearchContactIds);
      resultSet = await daHelper.query(Contacts.CONTACT_URI, condition, columns);
      if (resultSet === undefined) {
        HiLog.i(TAG, 'queryContactByContactIds resultSet is empty!');
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.e(TAG, 'queryContactByContactIds rowCount is zero.');
      } else {
        resultSet.goToFirstRow();
        do {
          let contactId = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID)).toString();
          resultList.push(contactId);
        } while (resultSet.goToNextRow());
      }
      HiLog.i(TAG, `queryContactByContactIds end len: ${JSON.stringify(resultList)}`);
      return resultList;
    } catch (error) {
      HiLog.e(TAG, `queryContactByContactIds error: code: ${error?.code}, message: ${error?.message}`);
    } finally {
      if (resultSet && !resultSet.isClosed) {
        resultSet?.close();
      }
    }
    return [];
  }

  /**
   * search contact from db By like on contactlist
   *
   * @param searchKey searchKey
   * @param hasSearchContactIds hasSearchContactIds
   * @param context context
   * @returns contactlist
   */
  async queryContactByPhoneNumAndDisplayName(searchKey: string, hasSearchContactIds: string[],
    context?: common.UIAbilityContext): Promise<SearchContactResult[]> {
    if (!context || !searchKey || !hasSearchContactIds) {
      HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayName invalid.');
      return [];
    }
    let resultList: SearchContactResult[] = [];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      HiLog.i(TAG, `Start to query contacts by phone number and displayName:${TextUtils.getMaskString(searchKey)}`);
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let columns = ['contact_id', 'detail_info', 'company', 'type_id', 'display_name', 'contacted_count'];
      // 电话号码正则
      let pattern = /^[0-9#+*]+$/;
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.limit(5000, 0)
      if (pattern.test(searchKey)) {
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
        condition.and()
        condition.notIn('contact_id', hasSearchContactIds);
        condition.groupBy(['contact_id']);
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayName resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayName rowCount is zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            let contactInfo: SearchContactResult =
              new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
            contactInfo.entityId = contactId.toString();
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info')).toString();
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
            if (name.indexOf(searchKey) != -1) {
              let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');
              let sortValue = SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
              contactInfo.sortValue = sortValue;
              contactInfo.name = highlightName;
            } else {
              let sortValue = SearchUtils.calcPhoneNumberSortValue(phoneNumber, contactedCount, searchKey);
              contactInfo.sortValue = sortValue;
              let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
              let phoneNumberObj: DbSearchPhoneNumberObj = new DbSearchPhoneNumberObj('1', '', highlightPhoneNumber);
              contactInfo.phoneNumbers = [phoneNumberObj];
              contactInfo.name = name;
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
        condition.and()
        condition.notIn('contact_id', hasSearchContactIds);
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayName resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayName zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            let contactInfo: SearchContactResult =
              new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
            contactInfo.entityId = contactId.toString();

            // 只匹配了联系人名称需要使用em标签进行高亮
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
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
      HiLog.e(TAG, `queryContactByPhoneNumAndDisplayName end len: ${resultList?.length}`);
      resultList = resultList.sort((result1, result2) => result1.sortValue - result2.sortValue);
      return resultList;
    } catch (error) {
      HiLog.e(TAG, `queryContactByPhoneNumAndDisplayName error: code: ${error?.code}, message: ${error?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return [];
  }

  /**
   * search contact from db By like on Dialer
   *
   * @param searchKey searchKey
   * @param hasSearchContactIds hasSearchContactIds
   * @param context context
   * @returns contactlist
   */
  async queryContactByPhoneNumAndDisplayNameForDialer(searchKey: string, hasSearchContactIds: string[],
    context?: common.UIAbilityContext): Promise<CallLogTemp[]> {
    let resultList: CallLogTemp[] = [];
    if (!context || !searchKey || !hasSearchContactIds) {
      HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer invalid.');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      HiLog.i(TAG, `queryContactByPhoneNumAndDisplayNameForDialer.${searchKey.length},${hasSearchContactIds?.length}`);
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let columns = ['contact_id', 'detail_info', 'company', 'type_id', 'display_name', 'contacted_count'];
      // 纯数字正则
      let pattern = /^[0-9#+*]+$/;
      if (!pattern.test(searchKey)) {
        HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer invalid.');
        return [];
      }
      let condition = new dataSharePredicates.DataSharePredicates();
      if (searchKey.length === 1 || searchKey.length === 2) {
        // 搜索的key长度大于等于2,只匹配联系人名称
        condition.equalTo('type_id', 5);
        condition.and()
        condition.like('display_name', '%' + searchKey + '%');
        condition.and()
        // 查询未删除的
        condition.equalTo(RawContacts.IS_DELETED, '0')
        condition.and()
        // 查询我的名片信息
        condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
        condition.and()
        condition.notIn('contact_id', hasSearchContactIds);
        if (searchKey.length === 1) {
          condition.and()
          condition.greaterThan('contacted_count', 0);
        }
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer rowCount is zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            // 只匹配了联系人名称需要使用em标签进行高亮
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex(DataColumns.DETAIL_INFO)).toString();
            // 联系人姓名用em标签拼接用于高亮
            let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');
            let organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            let sortValue =
              SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
            let callogFromDb =
              new CallLogTemp(contactId.toString(), highlightName, phoneNumber, organization, '', '', '', 0, 0, 1);
            callogFromDb.sortValue = sortValue;
            resultList.push(callogFromDb);
          } while (resultSet.goToNextRow());
        }
      } else {
        // 搜索的key是数字并且长度大于3,匹配联系人名称和电话号码,type_id为5的匹配电话号码,数据中也有联系人名称
        condition.equalTo('type_id', 5);
        condition.and()
        condition.beginWrap()
        condition.like('detail_info', '%' + searchKey + '%')
        condition.or()
        condition.like('display_name', '%' + searchKey + '%');
        condition.endWrap()
        condition.and()
        // 查询未删除的
        condition.equalTo(RawContacts.IS_DELETED, '0')
        condition.and()
        // 查询我的名片信息
        condition.notEqualTo(RawContacts.MARK_MY_CARD, '1')
        condition.and()
        condition.notIn('contact_id', hasSearchContactIds);
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialer rowCount is zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info')).toString();
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
            let organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            let callogFromDb =
              new CallLogTemp(contactId.toString(), name, phoneNumber, organization, '', '', '', 0, 0, 1);
            if (name.indexOf(searchKey) != -1) {
              let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');
              callogFromDb.name = highlightName;
              let sortValue =
                SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
              callogFromDb.sortValue = sortValue;
            } else {
              // 如果名称没有与搜索key匹配,就计算联系人电话号码排序值
              let sortValue =
                SearchUtils.calcPhoneNumberSortValue(phoneNumber, contactedCount, searchKey);
              callogFromDb.sortValue = sortValue;
            }
            if (phoneNumber.indexOf(searchKey) != -1) {
              let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
              callogFromDb.phoneNumber = highlightPhoneNumber;
            }
            resultList.push(callogFromDb);
          } while (resultSet.goToNextRow());
        }
      }
      HiLog.e(TAG, `queryContactByPhoneNumAndDisplayNameForDialer end len: ${resultList?.length}`);
      resultList = resultList.sort((result1, result2) => result1.sortValue - result2.sortValue);
      return resultList;
    } catch (error) {
      HiLog.e(TAG, `queryContactByPhoneNumAndDisplayNameForDialer error: ${error?.code}, message: ${error?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return [];
  }

  /**
   * search contact limit from db By like on Dialer
   *
   * @param searchKey searchKey
   * @param page page
   * @param context context
   * @returns contactlist
   */
  async queryContactByPhoneNumAndDisplayNameForDialerLimit(searchKey: string, page: number,
    context: common.UIAbilityContext): Promise<CallLogTemp[]> {
    let resultList: CallLogTemp[] = [];
    if (page < 0 || !context || !searchKey) {
      HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit invalid.');
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      HiLog.i(TAG, `queryContactByPhoneNumAndDisplayNameForDialerLimit enter:${searchKey.length},${page}`);

      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let columns = ['contact_id', 'detail_info', 'company', 'type_id', 'display_name', 'contacted_count'];
      // 纯数字正则
      let pattern = /^[0-9#+*]+$/;
      if (!pattern.test(searchKey)) {
        HiLog.e(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit searchKey is not phoneNumber.');
        return [];
      }
      // 对于contactId相同，phoneNumber相同情况做去重（联系人库本身去重）
      let contactKeySet: HashSet<string> = new HashSet();
      const regex: RegExp = new RegExp('<\/?.+?>', 'g')
      let condition = new dataSharePredicates.DataSharePredicates();
      let offset = ArrayUtil.getOffetByPageAndLimit(page, 5000);
      condition.limit(5000, offset)
      if (searchKey.length === 1 || searchKey.length === 2) {
        // 搜索的key长度小于等于2,只匹配联系人名称
        condition.equalTo('type_id', 5);
        condition.and()
        condition.like('display_name', '%' + searchKey + '%');
        condition.and()
        // 查询未删除的
        condition.equalTo(RawContacts.IS_DELETED, '0')
        condition.and()
        // 查询我的名片信息
        condition.notEqualTo(RawContacts.MARK_MY_CARD, '1');
        if (searchKey.length === 1) {
          condition.and()
          condition.greaterThan('contacted_count', 0);
        }
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit rowCount is zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            // 只匹配了联系人名称需要使用em标签进行高亮
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount: number = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info')).toString();

            // 联系人姓名用em标签拼接用于高亮
            let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');

            let organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            let key = `${contactId}-${phoneNumber.replace(regex, '')}`;
            if (!contactKeySet.has(key)) {
              let callogFromDb =
                new CallLogTemp(contactId.toString(), highlightName, phoneNumber, organization, '', '', '', 0, 0, 1);
              let sortValue =
                SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
              callogFromDb.sortValue = sortValue;
              resultList.push(callogFromDb);
              contactKeySet.add(key);
            }
          } while (resultSet.goToNextRow());
        }
      } else {
        // 搜索的key是数字并且长度大于3,匹配联系人名称和电话号码,type_id为5的匹配电话号码,数据中也有联系人名称
        condition.equalTo('type_id', 5);
        condition.and()
        condition.beginWrap()
        condition.like('detail_info', '%' + searchKey + '%')
        condition.or()
        condition.like('display_name', '%' + searchKey + '%');
        condition.endWrap()
        condition.and()
        // 查询未删除的
        condition.equalTo(RawContacts.IS_DELETED, '0')
        condition.and()
        // 查询我的名片信息
        condition.notEqualTo(RawContacts.MARK_MY_CARD, '1')
        resultSet = await daHelper.query(Data.CONTENT_URI, condition, columns);
        if (resultSet === undefined) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit resultSet is empty!');
          return [];
        }
        if (resultSet.rowCount === 0) {
          HiLog.i(TAG, 'queryContactByPhoneNumAndDisplayNameForDialerLimit rowCount is zero.');
        } else {
          resultSet.goToFirstRow();
          do {
            let contactId = resultSet.getLong(resultSet.getColumnIndex('contact_id'));
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info')).toString();
            let name = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME)).toString();
            let contactedCount = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACTED_COUNT));
            let organization = resultSet.getString(resultSet.getColumnIndex(Contacts.COMPANY));
            let key = `${contactId}-${phoneNumber.replace(regex, '')}`;
            if (contactKeySet.has(key)) {
              continue;
            }
            contactKeySet.add(key);
            let callogFromDb =
              new CallLogTemp(contactId.toString(), name, phoneNumber, organization, '', '', '', 0, 0, 1);
            if (name.indexOf(searchKey) != -1) {
              let sortValue =
                SearchUtils.calcContactNameSortValue(name, contactedCount, searchKey);
              callogFromDb.sortValue = sortValue;
              // 联系人姓名用em标签拼接用于高亮
              let highlightName = name.replace(searchKey, '<em>' + searchKey + '</em>');
              callogFromDb.name = highlightName;
            } else {
              // 如果名称没有与搜索key匹配,就计算联系人电话号码排序值
              let sortValue =
                SearchUtils.calcPhoneNumberSortValue(phoneNumber, contactedCount, searchKey);
              callogFromDb.sortValue = sortValue;
            }
            // 联系人电话号码用em标签拼接用于高亮
            if (phoneNumber.indexOf(searchKey) != -1) {
              let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
              callogFromDb.phoneNumber = highlightPhoneNumber;
            }
            resultList.push(callogFromDb);
          } while (resultSet.goToNextRow());
        }
      }
      HiLog.i(TAG, `queryContactByPhoneNumAndDisplayNameForDialer end len: ${resultList?.length}`);
      resultList = resultList.sort((result1, result2) => result1.sortValue - result2.sortValue);
      return resultList;
    } catch (error) {
      HiLog.e(TAG, `queryContactByPhoneNumAndDisplayNameForDialerLimit error: ${error?.code}: ${error?.message}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return [];
  }

  deleteMemberByGroupId(groupId: string, callback: Function) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('type_id', '9');
      condition.and();
      condition.equalTo('detail_info', groupId);
      condition.and();

      dataAbilityHelper.delete(Data.CONTENT_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'deleteMemberByGroupId error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  activateRestore() {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      dataAbilityHelper.query(Contacts.BACKUP_RESTORE_URI, condition, []).then((resultSet: DataShareResultSet) => {
        resultSet.close();
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'activateRestore error:%s' + error?.message);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'activateRestore error:%s' + error?.message);
    });
  }

  deleteMembers(groupId: string, contactId: number[], callback: Function) {
    if (ArrayUtil.isEmpty(contactId)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      HiLog.w(TAG, `deleteMembers, contactId: ${contactId}`);
      let rawContactId: number[] = [];
      getGroupContactId(this.getContext() as common.UIAbilityContext, contactId).then((rawIdMap) => {
        HiLog.w(TAG, `deleteMembers, contactId: ${contactId}, rawId size:` + rawIdMap?.size);
        rawIdMap.forEach((uniqueKey, rawId) => {
          rawContactId.push(rawId);
          HiLog.w(TAG, `deleteMembers, contactId: ${contactId}, rawId: ${rawId}, uniqueKey: ${uniqueKey}`);
        })
        condition.equalTo('type_id', '9');
        condition.and();
        condition.equalTo('detail_info', groupId);
        condition.and();
        if (rawContactId.length > 0) {
          condition.in('raw_contact_id', rawContactId);
        }

        dataAbilityHelper.delete(Data.CONTENT_URI, condition).then((data: number) => {
          callback(data);
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'deleteMembers error:%s' + error?.message);
          callback();
        });
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `deleteMembers, err: ${err.message}`);
      })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  removeGroupMemberByRawContactId(rawContactId: number, callback: Function) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('type_id', '9');
      condition.and();
      condition.equalTo('raw_contact_id', rawContactId);

      dataAbilityHelper.delete(Data.CONTENT_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'deleteGroupsById error:%s' + error?.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback();
    });
  }

  getContactIdWithBlobNotNull(callback: Function, contactIds?: string[], page?: number, userId?: number) {
    HiLog.i(TAG, `getContactIdWithBlobNotNull begin ${contactIds?.length}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.and();
    conditionArgs.equalTo('type_id', 8);
    conditionArgs.and();
    conditionArgs.isNotNull('blob_data');
    if (contactIds !== undefined && contactIds.length > 0) {
      conditionArgs.in(RawContactsColumns.CONTACT_ID, contactIds);
    }
    if (page != undefined && page >= 0) {
      conditionArgs.limit(2500, page * 2500);
    }
    this.getDataAbilityHelper(userId).then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs,
        ['contact_id', 'blob_source', Data.RAW_CONTACT_ID, Data.DETAIL_INFO])
        .then((resultSet: DataShareResultSet) => {
          try {
            let contactBlobSourceMap: Map<string, ContactBlobSource[]> = new Map();
            let result: ContactBlobSource[] = [];
            if (resultSet.rowCount > 0) {
              resultSet.goToFirstRow();
              do {
                let contactIdStr = resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
                let item: ContactBlobSource = {
                  contactId: resultSet.getString(resultSet.getColumnIndex('contact_id')),
                  blobSource: resultSet.getLong(resultSet.getColumnIndex('blob_source')),
                  rawContactId: resultSet.getString(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)),
                  detailInfo: resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)),
                }
                let itemMap: ContactBlobSource[] | undefined = contactBlobSourceMap.get(contactIdStr);
                if (itemMap && itemMap.length) {
                  itemMap.push(item);
                  contactBlobSourceMap.set(contactIdStr, itemMap);
                } else {
                  contactBlobSourceMap.set(contactIdStr, [item]);
                }
              } while (resultSet.goToNextRow());
            }
            // 开始遍历通过contactId查询到的所有头像信息，进行筛选，确认最后的缩略图和大图;
            // 规则：先查询detail_info ，存在，则用raw_contact_id排序，获取raw_contact_id最大的一个
            // 若没有detail_info，则用raw_contact_id排序，获取raw_contact_id最大的一个blob_data
            let ctx: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext();
            let task = new taskPool.Task(getContactIdWithBlobNotNullByFilter, contactBlobSourceMap, ctx);
            taskPool.execute(task).then((result: Object) => {
              HiLog.i(TAG, 'getContactIdWithBlobNotNull end');
              callback(result);
            });
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.w(TAG, `getContactIdWithBlobNotNull error: ${error?.message}`);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, ` getContactIdWithBlobNotNull error:${error?.message}`);
      callback([]);
    });
  }

  findAllRecentDeleteContacts(callback: (v: RecentDeleteListItem[]) => void) {
    HiLog.w(TAG, 'findAllRecentDeleteContacts start.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.orderByDesc(DeletedRawContactsColumns.DELETE_TIME);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.DELETED_RAW_CONTACT_URI, conditionArgs, RecentDeleteListItem.DELETE_COLUMN)
        .then((resultSet: DataShareResultSet) => {
          try {
            let rst: RecentDeleteListItem[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let recentDeleteListItem = new RecentDeleteListItem(resultSet);
                rst.push(recentDeleteListItem);
              } while (resultSet.goToNextRow());
              HiLog.w(TAG, 'findAllRecentDeleteContacts query data success.');
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `findAllRecentDeleteContacts error: ${error?.message}`);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `findAllRecentDeleteContacts error: ${error?.message}`);
      callback([]);
    });
  }

  deleteRecycleContactByIds(ids: number[], callback: Function) {
    HiLog.w(TAG, 'deleteRecycleContactByIds start ids: ' + ids);
    if (ArrayUtil.isEmpty(ids)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then(async (dataAbilityHelper: dataShare.DataShareHelper) => {
      await this.deleteOldPhotoFile(ids, dataAbilityHelper);
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(DeletedRawContactsColumns.RAW_CONTACT_ID, ids);
      dataAbilityHelper.delete(Contacts.DELETED_RAW_CONTACT_URI, condition).then((data: number) => {
        HiLog.w(TAG, `deleteRecycleContactByIds data: ${data}`);
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `deleteRecycleContactByIds error: ${error?.message}`);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `deleteRecycleContactByIds error: ${error?.message}`);
      callback();
    });
  }

  // 回收站删除联系人时，异步将联系人的大头像文件一并删除
  async deleteOldPhotoFile(rawContactIds: number[], dataAbilityHelper: dataShare.DataShareHelper) {
    HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFile start`);
    let resultSet: DataShareResultSet | undefined = undefined;
    let resultSetContact: DataShareResultSet | undefined = undefined;
    try {
      HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFiles rawContactIds: ${rawContactIds}`);
      let detailInfoList: string[] = [];
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.in(Data.RAW_CONTACT_ID, rawContactIds);
      predicates.equalTo(Data.TYPE_ID, 8);
      predicates.in(Data.IS_DELETED, [0, 1]);
      resultSet = await dataAbilityHelper.query(Data.CONTENT_URI, predicates, [Data.DETAIL_INFO]);
      if (resultSet && resultSet.goToFirstRow()) {
        do {
          let detailInfo = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
          if (!StringUtil.isEmpty(detailInfo)) {
            detailInfoList.push(detailInfo);
          }
        } while (resultSet.goToNextRow());
      }
      HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFiles detailInfoList: ${detailInfoList}`);
      let aggregationContactInfoMap: Map<string, number> = new Map();
      let predicatesAcg = new dataSharePredicates.DataSharePredicates();
      predicatesAcg.in(Data.DETAIL_INFO, detailInfoList);
      predicatesAcg.equalTo(Data.TYPE_ID, 8);
      predicatesAcg.in(Data.IS_DELETED, [0, 1]);
      resultSetContact = await dataAbilityHelper.query(Data.CONTENT_URI, predicatesAcg, [Data.DETAIL_INFO]);
      if (resultSetContact && resultSetContact.goToFirstRow()) {
        do {
          let detailInfo = resultSetContact.getString(resultSetContact.getColumnIndex(Data.DETAIL_INFO));
          let num: number | undefined = aggregationContactInfoMap.get(detailInfo);
          if (num) {
            aggregationContactInfoMap.set(detailInfo, num += 1);
          } else {
            aggregationContactInfoMap.set(detailInfo, 1);
          }
        } while (resultSetContact.goToNextRow());
      }
      // 遍历contactPhotoInfos，判断头像是否应该删除
      HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFile begin, aggregationContactInfoMap.size: ` + aggregationContactInfoMap?.size);
      let ctx: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext();
      let groupDir = await GroupIdUtil.getInstance().getGroupDir(ctx);
      aggregationContactInfoMap.forEach(async (value, key) => {
        HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFile, aggregationContactInfo detailInfo: ${key}, num: ${value}`);
        const num: number = value;
        const filePath = key;
        // 当未查询到有未删除的联系人依赖当前大头像时（智能合并场景会有这种情况），可以删除大头像文件
        if (num === 1) {
          // 从群组沙箱路径下获取大头像文件
          const groupFilePath = groupDir + '/' + filePath;
          try {
            await fs.unlink(groupFilePath);
            HiLog.w(TAG, `bigPhotoFromFile deleteOldPhotoFiles delete photo file success`);
          } catch (e) {
            HiLog.e(TAG, `bigPhotoFromFile deleteOldPhotoFiles delete photo file, error: ${e?.message}`);
          }
        }
      })
    } catch (e) {
      HiLog.e(TAG, `bigPhotoFromFile deleteOldPhotoFiles error: ${e?.message}`);
      return;
    } finally {
      ObjectUtil.closeResultSet(resultSet);
      ObjectUtil.closeResultSet(resultSetContact);
    }
  }

  restoreRecycleContactByIds(ids: number[], callback: Function) {
    HiLog.w(TAG, 'restoreRecycleContactByIds start.');
    if (ArrayUtil.isEmpty(ids)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(DeletedRawContactsColumns.RAW_CONTACT_ID, ids);
      dataAbilityHelper.delete(Contacts.RECYCLE_RESTORE_URI, condition).then((data: number) => {
        HiLog.w(TAG, `restoreRecycleContactByIds data: ${data}`);
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `restoreRecycleContactByIds error: ${error?.message}`);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `restoreRecycleContactByIds error: ${error?.message}`);
      callback();
    });
  }

  async addNewPhoto(rawContactIdArr: string[], photo: Uint8Array, dataShareHelper: dataShare.DataShareHelper,
    contactId: string, blobSource: number) {
    try {
      HiLog.i(TAG, 'addNewPhoto start.');
      for (let rawContactId of rawContactIdArr) {
        let fileName = 'photo/' + contactId + '_' + rawContactId;
        let value: ValuesBucket = {};
        value[Data.RAW_CONTACT_ID] = rawContactId;
        value[Data.BLOB_DATA] = photo;
        value[Data.TYPE_ID] = 8;
        value[Data.BLOB_SOURCE] = blobSource;
        value[Data.DETAIL_INFO] = fileName;
        await dataShareHelper.insert(Data.CONTENT_URI, value).then((data: number) => {
          if (data == -1) {
            HiLog.e(TAG, 'dealContactPhoto-insert photo failed, rawContactId: ' + rawContactId);
          }
          HiLog.d(TAG, 'dealContactPhoto-insert insert photo success, rawContactId: ' + rawContactId);
        })
      }
    } catch (error) {
      HiLog.e(TAG, 'dealContactPhoto-insert failed. Cause: ' + error?.message + ', stack: ' + error?.stack);
    }
  }

  async updatePhoto(rawContactIdArr: string[], photo: Uint8Array, dataShareHelper: dataShare.DataShareHelper,
    conditionArgs: dataSharePredicates.DataSharePredicates) {
    try {
      for (let rawContactId of rawContactIdArr) {
        conditionArgs.equalTo('raw_contact_id', rawContactId);
        let photoContact: Record<string, Uint8Array | string | number> = {
          'blob_data': photo,
          'blob_source': 3
        };
        conditionArgs.and();
        conditionArgs.equalTo('type_id', 8);
        await dataShareHelper.update(Data.CONTENT_URI, conditionArgs, photoContact).then((data: number) => {
          if (data == -1) {
            HiLog.e(TAG, 'dealContactPhoto-update photo failed, rawContactId: ' + rawContactId);
          }
          HiLog.d(TAG, 'dealContactPhoto-update update photo success, rawContactId: ' + rawContactId);
        })
      }
    } catch (error) {
      HiLog.e(TAG, 'dealContactPhoto-update failed. Cause: ' + error?.message + ', stack: ' + error?.stack);
    }
  }

  async deletePhoto(dataShareHelper: dataShare.DataShareHelper,
    conditionArgs: dataSharePredicates.DataSharePredicates) {
    try {
      conditionArgs.and();
      conditionArgs.equalTo('type_id', 8);
      await dataShareHelper.delete(Data.CONTENT_URI, conditionArgs).then((data: number) => {
        if (data == -1) {
          HiLog.e(TAG, 'dealContactPhoto-delete photo failed!');
        }
        HiLog.d(TAG, 'dealContactPhoto-delete delete photo success!');
      })
    } catch (error) {
      HiLog.e(TAG, 'dealContactPhoto-delete failed. Cause: ' + error?.message + ', stack: ' + error?.stack);
    }
  }

  async savePhotoToDb(contactId: string, rawContactIdArr: string[], context: Context, photo: Uint8Array | null,
    needAddNewPhoto: boolean, needUpdatePhoto: boolean, needDeletePhoto: boolean, blobSource: number) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.in('raw_contact_id', rawContactIdArr);
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    if (photo != undefined && photo != null) {
      if (needAddNewPhoto) {
        await this.addNewPhoto(rawContactIdArr, photo, dataShareHelper, contactId, blobSource);
      }
      if (needUpdatePhoto) {
        await this.updatePhoto(rawContactIdArr, photo, dataShareHelper, conditionArgs);
      }
    }

    if (needDeletePhoto) {
      await this.deletePhoto(dataShareHelper, conditionArgs);
    }
  }

  restoreContacts(callBack: Function) {
    try {
      HiLog.i(TAG, 'restore contacts start');
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let condition = new dataSharePredicates.DataSharePredicates();

        dataAbilityHelper.update(
          Contacts.RESTORE_CONTACTS_URI,
          condition,
          {
            'extend5': '1'
          }
        ).then((retCode: number) => {
          HiLog.i(TAG, `restoreContacts retCode: ${retCode}`);
          callBack?.(retCode >= 0);
        }).catch((error: BusinessError) => {
          HiLog.i(TAG, 'restore contacts failed. error: ' + error?.message + ', stack: ' + error?.stack);
          callBack?.(false);
        })
      })
    } catch (error) {
      HiLog.e(TAG, 'restore contacts failed. error: ' + error?.message + ', stack: ' + error?.stack);
      callBack?.(false);
    }
  }

  findNewestContact(callBack: Function) {
    HiLog.i(TAG, 'findNewestContact start');
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.notEqualTo('is_deleted', 1)
      .and()
      .orderByDesc(RawContactsColumns.CONTACT_ID)
    // .and()
    // .limit(1, 1);
    const resultColumns = [RawContactsColumns.CONTACT_ID, RawContactsColumns.SYNC_2];
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      dataAbilityHelper.query(RawContacts.CONTENT_URI, predicates, resultColumns)
        .then(resultSet => {
          try {
            HiLog.i(TAG, `findNewestContact result.rowCount:${resultSet.rowCount}`);
            let ret: string[] = [];
            if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
              callBack?.(ret);
              return;
            }
            do {
              let columnSync2: string = resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.SYNC_2));
              if (columnSync2 !== OHOS_CONSUMER_HOTLINE_CONTACT) {
                ret.push(resultSet.getString(resultSet.getColumnIndex(RawContactsColumns.CONTACT_ID)));
              }
            } while (resultSet.goToNextRow());
            callBack?.(ret);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
    })

  }

  markContactAsPoster(contactId: string[], callback: Function) {
    HiLog.i(TAG, `markContactsAsPoster start contactIds: ${contactId}`);

    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.in('raw_contact_id', contactId)
      .and()
      .equalTo('type_id', 8);
    let updatedValue: ValuesBucket = {
      'blob_source': 3
    };
    HiLog.i(TAG, `markContactsAsPoster uri:${Data.CONTENT_URI}`);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.update(Data.CONTENT_URI, predicates, updatedValue)
        .then((data: number) => {
          HiLog.i(TAG, `markContactsAsPoster result: ${data}`);
          callback?.(data);
        }).catch((error: BusinessError) => {
        HiLog.e(TAG, `markContactsAsPoster error:${error?.message}, stack: ${error?.stack}`);
      })
    })
  }

  async findMyCard(callBack: (resultSet?: DataShareResultSet) => void) {
    HiLog.i(TAG, 'findMyCard');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    const accountId = await sharedPreferencesUtils.getFromPreferences('accountType', -1) as number;
    if (accountId != -1) {
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, accountId);
    }
    conditionArgs.equalTo(RawContacts.MARK_MY_CARD, '1');
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_RAW_URI, conditionArgs, ContactListItem.COLUMNS_RAW_CONTACT)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.i(TAG, 'findMyCard succeeded');
            callBack?.(resultSet);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `findMyCard error:${error.message}`);
          callBack?.(undefined);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `findMyCard error:${error.message}`);
      callBack?.(undefined);
    })
  }

  getContactPhotos(actionData: FindPhotoByIdActionData, callBack: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('is_deleted', 0);
    conditionArgs.and();
    conditionArgs.equalTo('type_id', 8);
    conditionArgs.and();
    conditionArgs.isNotNull('blob_data');

    if (actionData.page) {
      let offset = ArrayUtil.getOffetByPageAndLimit(actionData.page, actionData.limit);
      HiLog.i(TAG, `getContactPhotos limit: ${actionData.limit} offset:${offset}`);
      conditionArgs.limit(actionData.limit, offset);
    }

    conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY)
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs,
        [RawContacts.CONTACT_ID, RawContacts.BLOB_DATA])
        .then((resultSet: DataShareResultSet) => {
          try {
            if (!resultSet?.rowCount) {
              HiLog.w(TAG, `getContactsPhoto`)
              callBack?.([])
              return;
            }
            resultSet.goToFirstRow();
            let pixelMaps: ContactPhotoVo[] = [];
            HiLog.i(TAG, `getContactPhotos success`);
            do {
              let contactId = resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
              let blobData = resultSet.getBlob(resultSet.getColumnIndex(RawContacts.BLOB_DATA));
              pixelMaps.push(buildContactPhotoVo(contactId, blobData));
            } while (resultSet.goToNextRow());
            callBack?.(pixelMaps)
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `getContactPhotos error:${error?.message}, stack: ${error?.stack}`);
          callBack?.([]);
        });
    })
  }

  checkPreDefinedExist(name: string, phones: string[], emails: string[], callBack: Function) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.beginWrap();
    conditionArgs.beginWrap();
    conditionArgs.equalTo(Data.DETAIL_INFO, name)
      .and()
      .equalTo(Data.TYPE_ID, 6);
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.in(Data.DETAIL_INFO, phones)
      .and()
      .equalTo(Data.TYPE_ID, 5);
    conditionArgs.endWrap();
    conditionArgs.or();
    conditionArgs.beginWrap();
    conditionArgs.in(Data.DETAIL_INFO, emails)
      .and()
      .equalTo(Data.TYPE_ID, 1);
    conditionArgs.endWrap();
    conditionArgs.endWrap();
    conditionArgs.and()
      .equalTo(Data.IS_DELETED, 0)

    conditionArgs.orderByAsc(RawContacts.CONTACT_ID);

    const resultColumns = [RawContacts.CONTACT_ID, Data.RAW_CONTACT_ID, Data.DETAIL_INFO, Data.TYPE_ID];

    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns)
        .then((resultSet: DataShareResultSet) => {
          try {
            HiLog.i(TAG, `checkPreDefinedExist resultSet rowCount: ${resultSet?.rowCount}`)
            if (!resultSet?.rowCount) {
              callBack?.([]);
              return;
            }

            resultSet.goToFirstRow();

            let curRawId = '';
            let mark = 0;
            let resultList: LooseObject[] = [];
            do {
              let contactId = resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
              let rawContactId = resultSet.getString(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
              if (rawContactId != curRawId) {
                mark = 0;
                curRawId = rawContactId;
              }
              if (mark == (1 << 1 | 1)) {
                continue;
              }
              let detailInfo = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
              let typeId = resultSet.getString(resultSet.getColumnIndex(Data.TYPE_ID));
              if (typeId == '6') {
                // Name exists.
                mark |= 1;
              }
              if (typeId == '5' || typeId == '1') {
                // Phones or emails exist.
                mark |= 1 << 1;
              }
              if (mark == (1 << 1 | 1)) {
                resultList.push({
                  contactId: contactId,
                  rawId: rawContactId
                });
                break;
              }
            } while (resultSet.goToNextRow())

            callBack?.(resultList);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `checkPreDefinedExist error:${error?.message}, stack: ${error?.stack}`);
          callBack?.([]);
        })
    })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, `checkPreDefinedExist getHelper error:${error?.message}, stack: ${error?.stack}`);
        callBack?.([]);
      })


  }

  markPreDefinedContact(contactIds: string[], callBack: Function) {
    HiLog.i(TAG, `markPreDefinedContact starts contactIds: ${contactIds}`);

    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.in('contact_id', contactIds)
    let updatedValue: ValuesBucket = {
      'syn_2': 'PREDEFINED_OHOS_CONTACT'
    };
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.update(Contacts.CONTACT_RAW_URI, predicates, updatedValue)
        .then((data: number) => {
          HiLog.i(TAG, `markPreDefinedContact success: ${data}`);
          callBack?.(data);
        }).catch((error: BusinessError) => {
        HiLog.e(TAG, `markPreDefinedContact error:${error?.message}, stack: ${error?.stack}`);
        callBack?.(-1);
      })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `markPreDefinedContact getHelper error:${error?.message}, stack: ${error?.stack}`);
      callBack?.(-1)
    })
  }

  async getRawContactIdsByContactId(contactId: string) {
    let rawContactIdListDefault: string[] = [contactId];

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let rawContactIdList: string[] = [];
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance()
          .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext())
          .getDataAbilityHelper();
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('contact_id', contactId);
      resultSet = await daHelper.query(Contacts.CONTACT_RAW_URI, predicates, [Data.ID]);
      if (resultSet && resultSet.goToFirstRow()) {
        do {
          let rawContactId = resultSet.getString(resultSet.getColumnIndex(Data.ID));
          rawContactIdList.push(rawContactId);
        } while (resultSet.goToNextRow());
      }
      return rawContactIdList;
    } catch (error) {
      let err = error as BusinessError
      HiLog.e(TAG,
        'bigPhotoFromFile getRawContactIdsByContactId, err.message: ' + err.message + ', error code: ' + err.code);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    return rawContactIdListDefault;
  }

  parsingFilterCondition(
    field: string,
    filterOptions: Array<contact.FilterOptions>,
    filterCondition: dataSharePredicates.DataSharePredicates): boolean {

    let hasEmptyData = false;

    filterCondition.beginWrap()
    filterOptions.forEach((filterOption, index) => {
      // 同一个字段的条件为 或
      if (index !== 0) {
        filterCondition.or()
      }
      switch (filterOption.filterCondition) {
        case contact.FilterCondition.IS_NOT_NULL:
          filterCondition.beginWrap()
          filterCondition.isNotNull(field);
          filterCondition.and()
          filterCondition.notEqualTo(field, '');
          filterCondition.endWrap()
          break;
        case contact.FilterCondition.EQUAL_TO:
          filterCondition.equalTo(field, filterOption.value as string);
          break;
        case contact.FilterCondition.NOT_EQUAL_TO:
          filterCondition
            .beginWrap()
            .notEqualTo(field, filterOption.value as string)
            .or()
            .isNull(field)
            .endWrap()
          hasEmptyData = true;
          break;
        case contact.FilterCondition.IN:
          filterCondition.in(field, filterOption.value as ValueType[]);
          break;
        case contact.FilterCondition.NOT_IN:
          filterCondition
            .beginWrap()
            .notIn(field, filterOption.value as ValueType[])
            .or()
            .isNull(field)
            .endWrap()
          hasEmptyData = true;
          break;
        case contact.FilterCondition.CONTAINS:
          filterCondition.contains(field, filterOption.value as string);
          break;
      }
    })
    filterCondition.endWrap()
    return hasEmptyData;
  }

  // 获取子项信息的表
  async getContactIdSubDataMap(isDisplayByName: boolean, contactIdList: number[],
    dataAbilityHelper: dataShare.DataShareHelper): Promise<HashMap<number, Map<string, PickerShowSubData>>> {
    let contactIdSubDataMap = new HashMap<number, Map<string, PickerShowSubData>>();
    let dataResultSet: DataShareResultSet | undefined = undefined;
    try {
      if (!isDisplayByName) {
        let dataCondition = new dataSharePredicates.DataSharePredicates();
        dataCondition.in(RawContacts.CONTACT_ID, contactIdList);
        // 子项信息 只支持手机号
        dataCondition
          .equalTo(Data.TYPE_ID, DataItemType.PHONE)
          .equalTo(Data.IS_DELETED, '0')
          .orderByAsc(RawContacts.CONTACT_ID);
        let dataColumns = [
          RawContacts.CONTACT_ID, Data.TYPE_ID, Data.DETAIL_INFO, Data.EXTEND7, Data.CUSTOM_DATA, Data.ID];
        dataResultSet = await dataAbilityHelper.query(Data.CONTENT_URI, dataCondition, dataColumns);
        HiLog.w(TAG, `dataResultSet length: ${dataResultSet.rowCount}`);

        if (dataResultSet.goToFirstRow()) {
          do {
            let contactId = dataResultSet.getLong(dataResultSet.getColumnIndex(RawContacts.CONTACT_ID));
            let typeId = dataResultSet.getLong(dataResultSet.getColumnIndex(Data.TYPE_ID));
            let detailInfo = dataResultSet.getString(dataResultSet.getColumnIndex(Data.DETAIL_INFO));
            let labelId = dataResultSet.getLong(dataResultSet.getColumnIndex(Data.CUSTOM_DATA));
            let labelName = dataResultSet.getString(dataResultSet.getColumnIndex(Data.EXTEND7));
            let dataId = dataResultSet.getLong(dataResultSet.getColumnIndex(Data.ID));

            if (typeId === DataItemType.PHONE) {
              let keyValue = detailInfo;
              let showValue: ResourceStr = labelName;
              if (labelId !== PhoneAccountType.TYPE_ID_CUSTOM) {
                showValue = Phone.getTypeLabelResource(labelId);
              }
              let pickerShowSubDatas: Map<string, PickerShowSubData> = contactIdSubDataMap.get(contactId) ?? new Map();
              pickerShowSubDatas.set(keyValue, {
                dataId: dataId,
                keyValue: keyValue,
                showValue: showValue,
              });
              contactIdSubDataMap.set(contactId, pickerShowSubDatas);
            }
          } while (dataResultSet.goToNextRow())
        }
        HiLog.w(TAG, `contactIdSubDataMap size: ${contactIdSubDataMap.length}`);
      } else {
        HiLog.w(TAG, `no need phone infos`);
      }
      return contactIdSubDataMap;
    } catch (err) {
      HiLog.e(TAG, `getContactIdSubDataMap error: ${err.message}`);
      return contactIdSubDataMap;
    } finally {
      ObjectUtil.closeResultSet(dataResultSet);
    }
  }

  // 获取有过滤条件时的id集合
  async getFilterContactIdList(isDisplayByName: boolean, filterClause: contact.FilterClause | undefined,
    contactIdList: number[], filterType: contact.FilterType | undefined, dataAbilityHelper: dataShare.DataShareHelper)
    : Promise<number[]> {
    let dataFieldType: number = -1
    let tempDefaultSelectContactMap: Map<number, Set<string>> = new Map();
    let tempFilterContactIdList: number[] = [];
    let filterResultSet: DataShareResultSet | undefined = undefined;
    try {
      if (filterClause) {
        let filterCondition = new dataSharePredicates.DataSharePredicates();
        filterCondition.in(RawContacts.CONTACT_ID, contactIdList);
        filterCondition.equalTo(Data.IS_DELETED, '0');

        if (filterClause.id && filterClause.id.length > 0) {
          this.parsingFilterCondition(RawContacts.CONTACT_ID, filterClause.id, filterCondition);
        }
        if (filterClause.name && filterClause.name.length > 0) {
          filterCondition.beginWrap();
          let hasEmptyData = this.parsingFilterCondition(RawContacts.DISPLAY_NAME, filterClause.name, filterCondition);
          if (hasEmptyData) {
            filterCondition.or().notEqualTo(Contacts.HAS_DISPLAY_NAME, '1');
          }
          filterCondition.endWrap();
        }
        if (filterClause.focusModeList && filterClause.focusModeList.length > 0) {
          this.parsingFilterCondition(RawContacts.FOCUS_MODE_LIST, filterClause.focusModeList, filterCondition);
        }
        if (filterClause.dataItem) {
          filterCondition.beginWrap()
          switch (filterClause.dataItem.field) {
            case contact.DataField.EMAIL:
              dataFieldType = DataItemType.EMAIL;
              break;
            case contact.DataField.PHONE:
              dataFieldType = DataItemType.PHONE;
              break;
            case contact.DataField.ORGANIZATION:
              dataFieldType = DataItemType.ORGANIZATION;
              break;
            default:
              break;
          }
          filterCondition
            .beginWrap()
            .equalTo(Data.TYPE_ID, dataFieldType)
            .and()
          let hasEmptyData =
            this.parsingFilterCondition(Data.DETAIL_INFO, filterClause.dataItem.options, filterCondition);
          filterCondition.endWrap()

          if (hasEmptyData) {
            switch (filterClause.dataItem.field) {
              case contact.DataField.EMAIL:
                filterCondition.or().notEqualTo(Contacts.HAS_EMAIL, '1')
                break;
              case contact.DataField.PHONE:
                filterCondition.or().notEqualTo(Contacts.HAS_PHONE_NUMBER, '1')
                break;
              case contact.DataField.ORGANIZATION:
                filterCondition.or().equalTo(RawContacts.RAW_COMPANY, '').or().isNull(Contacts.COMPANY)
                break;
              default:
                break;
            }
          }
          filterCondition.endWrap()
        }

        let filterColumns = [RawContacts.CONTACT_ID];
        if (!isDisplayByName && dataFieldType !== -1) {
          filterColumns = [RawContacts.CONTACT_ID, Data.TYPE_ID, Data.DETAIL_INFO];
        }
        filterResultSet = await dataAbilityHelper.query(Data.CONTENT_URI, filterCondition, filterColumns);

        HiLog.w(TAG, `filterResultSet length: ${filterResultSet.rowCount}`);
        if (filterResultSet.goToFirstRow()) {
          let filterContactIdSet: Set<number> = new Set();
          do {
            let contactId = filterResultSet.getLong(filterResultSet.getColumnIndex(RawContacts.CONTACT_ID));
            let typeId = filterResultSet.getLong(filterResultSet.getColumnIndex(Data.TYPE_ID));
            let detailInfo = filterResultSet.getString(filterResultSet.getColumnIndex(Data.DETAIL_INFO));

            if (filterType === contact.FilterType.DEFAULT_SELECT ||
              filterType === contact.FilterType.SHOW_FILTER_AND_DEFAULT_SELECT) {
              if (!isDisplayByName && dataFieldType !== -1 && typeId === DataItemType.PHONE) {
                // 子项只支持 手机号
                let dataValue: Set<string> = tempDefaultSelectContactMap.get(contactId) ?? new Set();
                dataValue.add(detailInfo);
                tempDefaultSelectContactMap.set(contactId, dataValue);
              } else {
                tempDefaultSelectContactMap.set(contactId, new Set());
              }
            }
            filterContactIdSet.add(contactId);
          } while (filterResultSet.goToNextRow())
          tempFilterContactIdList = Array.from(filterContactIdSet);
        }
        HiLog.w(TAG, `filterResultSet filterContactIdList size: ${tempFilterContactIdList.length
        }, defaultSelectContactMap size: ${tempDefaultSelectContactMap.size}`);
        this.defaultSelectContactMap = tempDefaultSelectContactMap;
      } else {
        HiLog.w(TAG, `no filter!`);
      }
      return tempFilterContactIdList;
    } catch (err) {
      HiLog.e(TAG, `getFilterContactIdList error: ${err.message}`);
      return tempFilterContactIdList;
    } finally {
      ObjectUtil.closeResultSet(filterResultSet);
    }
  }

  // 分页获取全量联系人
  async getContactResultSet(limit: number, page: number, isFavorite: boolean, dataAbilityHelper:
    dataShare.DataShareHelper): Promise<ContactData> {
    let contactsData = new ContactData();
    let contactList: ContactListItem[] = [];
    let contactIdList: number[] = [];
    let contactResultSet: DataShareResultSet | undefined = undefined;
    try {
      let contactCondition = new dataSharePredicates.DataSharePredicates();
      if (isFavorite) { // 收藏联系人一次全查 可能存在问题，收藏数量超过1w时，后续查询会出问题
        contactCondition.equalTo(RawContacts.FAVORITE, '1');
      } else {
        contactCondition.limit(limit, page * limit);
      }
      contactCondition
        .equalTo(Contacts.IS_DELETED, '0')
        .notEqualTo(RawContacts.MARK_MY_CARD, '1')
        .orderByAsc(RawContacts.SORT)
        .orderByAsc(RawContacts.SORT_KEY);
      contactResultSet =
        await dataAbilityHelper.query(Contacts.CONTACT_URI, contactCondition, ContactListItem.COLUMNS);
      HiLog.w(TAG, `contactResultSet length: ${contactResultSet.rowCount}`);

      if (contactResultSet.goToFirstRow()) {
        do {
          let contactId: number = contactResultSet.getLong(contactResultSet.getColumnIndex(Contacts.ID));
          let contactListItem = new ContactListItem(contactResultSet);
          contactIdList.push(contactId);
          contactList.push(contactListItem);
        } while (contactResultSet.goToNextRow())
      }
      contactsData.contactList = contactList;
      contactsData.contactIdList = contactIdList;
      return contactsData;
    } catch (err) {
      HiLog.e(TAG, `getContactResultSet error: ${err.message}`);
      return contactsData;
    } finally {
      ObjectUtil.closeResultSet(contactResultSet);
    }
  }


  async getDesignatedPickerContacts(
    isDisplayByName: boolean,
    filterClause: contact.FilterClause | undefined,
    filterType: contact.FilterType | undefined,
    userId: number,
    page: number,
    isFavorite: boolean,
    isOnePageShow: boolean,
    callBack:
      (contactList: ContactListItem[], defaultSelectContactMap: Map<number, Set<string>>, isEnd: boolean) => void) {

    HiLog.w(TAG, `getDesignatedPickerContacts start`);
    // picker页limit 每页查询条数
    let PICKER_PAGINATION_REQUEST = 10000;
    let res: ContactListItem[] = [];
    let isEnd: boolean = false;
    let lastNumber: number = 10001;
    try {
      let dataAbilityHelper = await this.getDataAbilityHelper();
      // 获取全量联系人
      let resContacts = await this.getContactResultSet(PICKER_PAGINATION_REQUEST, page, isFavorite, dataAbilityHelper);
      lastNumber = resContacts.contactList.length;
      HiLog.w(TAG, `contactResultSet length: ${resContacts.contactList.length}`);

      // 然后获取子项
      let contactIdSubDataMap =
        await this.getContactIdSubDataMap(isDisplayByName, resContacts.contactIdList, dataAbilityHelper);
      HiLog.w(TAG, `contactIdSubDataMap size is ${contactIdSubDataMap.length}`);

      if (!filterClause) { // 没有过滤条件，直接分页查询返回
        HiLog.w(TAG, `no filter!`);
        resContacts.contactList.forEach((item) => {
          if (contactIdSubDataMap.hasKey(item.id)) {
            // 根据联系人id设置对应的手机号信息
            let pickerShowSubDatas: PickerShowSubData[] = [];
            contactIdSubDataMap.get(item.id).forEach((pickerShowSubData) => {
              pickerShowSubDatas.push(pickerShowSubData);
            });
            item.pickerShowSubDatas = pickerShowSubDatas;
          }
          res.push(item);
        })
      } else {
        HiLog.w(TAG, `has filter!`);
        // 筛选条件
        let filterContactIdList = await this.getFilterContactIdList(isDisplayByName, filterClause,
          resContacts.contactIdList, filterType, dataAbilityHelper);
        resContacts.contactList.forEach((item) => {
          if (contactIdSubDataMap.hasKey(item.id)) {
            // 根据联系人id设置对应的手机号信息
            let pickerShowSubDatas: PickerShowSubData[] = [];
            contactIdSubDataMap.get(item.id).forEach((pickerShowSubData) => {
              pickerShowSubDatas.push(pickerShowSubData);
            });
            item.pickerShowSubDatas = pickerShowSubDatas;
          }
          if ((filterType === contact.FilterType.DEFAULT_SELECT) || filterContactIdList.includes(item.id)) {
            res.push(item);
          }
        })
      }
    } catch (err) {
      HiLog.e(TAG, `getDesignatedPickerContacts error: ${err.message}`);
    } finally {
      isEnd = isFavorite ? true : lastNumber < PICKER_PAGINATION_REQUEST;
      HiLog.w(TAG, `getDesignatedPickerContacts end, page: ${page}, isEnd: ${isEnd}, res size: ${res.length
      }, defaultSelectContactMap size: ${this.defaultSelectContactMap.size}`);
      callBack(res, this.defaultSelectContactMap, isEnd);
    }
  }
}

@Concurrent
export async function isInBlockList(context: common.UIAbilityContext, phoneNumber: string,
  isWhite: boolean): Promise<IsBlockContact> {
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('isInBlockList', 'Start to query a phoneNumber is in blockList.');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    let realPhoneNumber: string = StringUtil.removeSpace(phoneNumber.toString());
    //判断大于7
    if (realPhoneNumber.length >= NumberMatch.QUERY_NUM_LENGTH_LIMIT) {
      realPhoneNumber = NumberMatch.getInstance().getQueryNum(realPhoneNumber);
    }
    option.beginWrap();
    option.endsWith(BlockList.PHONE_NUMBER, realPhoneNumber);
    option.endWrap();
    option.and();
    if (isWhite) {
      option.equalTo('types', 1);
    } else {
      option.equalTo('types', 0);
    }
    resultSet = await dataAbilityHelper.query(Contacts.BLOCK_LIST_URI, option, []);
    let res: boolean = false;
    let newPhoneNumber: string = phoneNumber;
    if (resultSet.rowCount > 0) {
      //号码强匹配
      let matchIndex = await NumberMatch.getInstance().getCallerIndex(resultSet, phoneNumber);
      resultSet.goToRow(matchIndex);
      newPhoneNumber = resultSet.getString(resultSet.getColumnIndex(BlockList.PHONE_NUMBER));
      res = (matchIndex != -1);
    }
    HiLog.i('isInBlockList', 'query a phoneNumber is in blockList:' + res);
    return {
      isInBlock: res,
      phoneNumber: newPhoneNumber
    };
  } catch (err) {
    HiLog.e('isInBlockList ', `isInBlockList error: ${err?.message}, stack: ${err?.stack}`);
    return {
      isInBlock: false,
      phoneNumber: phoneNumber
    };
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

@Concurrent
export async function getBlockedCallCountByDetectDetails(context: common.UIAbilityContext,
  detectDetails: string): Promise<BlockListContact | undefined> {

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('getBlockedCallCountByDetectDetails', 'Start to query blocked call count by detectDetails');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(BlockList.PHONE_NUMBER, detectDetails);
    option.and();
    option.equalTo(BlockList.TYPES, BlockType.BLOCK_START);
    resultSet = await dataAbilityHelper.query(Contacts.BLOCK_LIST_URI,
      option, [BlockList.PHONE_NUMBER, BlockList.INTERCEPTION_CALL_COUNT]);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      let blockListContact = BlockListContact.fromResultSet(resultSet);
      HiLog.i('getBlockedCallCountByDetectDetails',
        'query blocked call count:' + blockListContact.interceptionCallCount);
      return blockListContact;
    }
    HiLog.w('getBlockedCallCountByDetectDetails', 'findByDetectDetails not found.');
    return undefined;
  } catch (err) {
    HiLog.e('getBlockedCallCountByDetectDetails', `error: ${err?.message}, stack: ${err?.stack}`);
    return undefined;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

@Concurrent
export async function getBlockedCallCountByPhoneNumber(context: common.UIAbilityContext,
  phoneNumber: string): Promise<BlockListContact | undefined> {

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('getBlockedCallCountByPhoneNumber', 'Start to query blocked call count by phoneNumber');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    let realPhoneNumber: string = StringUtil.removeSpace(phoneNumber.toString());
    //判断大于7
    if (realPhoneNumber.length >= NumberMatch.QUERY_NUM_LENGTH_LIMIT) {
      realPhoneNumber = NumberMatch.getInstance().getQueryNum(realPhoneNumber);
    }
    option.endsWith(BlockList.PHONE_NUMBER, realPhoneNumber);
    resultSet = await dataAbilityHelper.query(Contacts.BLOCK_LIST_URI,
      option, [BlockList.PHONE_NUMBER, BlockList.INTERCEPTION_CALL_COUNT]);
    if (resultSet.rowCount > 0) {
      //号码强匹配
      let resultId = await NumberMatch.getInstance().getCallerIndex(resultSet, phoneNumber);
      if (resultSet.goToRow(resultId)) {
        let blockListContact = BlockListContact.fromResultSet(resultSet);
        HiLog.i('getBlockedCallCountByPhoneNumber',
          'query blocked call count:' + blockListContact.interceptionCallCount);
        return blockListContact;
      }
    }
    HiLog.w('getBlockedCallCountByPhoneNumber', 'findByPhoneNumber not found.');
    return undefined;
  } catch (err) {
    HiLog.e('getBlockedCallCountByPhoneNumber', `error: ${err?.message}, stack: ${err?.stack}`);
    return undefined;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

@Concurrent
export async function updateBlockedCallCountByDetectDetails(context: common.UIAbilityContext,
  blockListContact: BlockListContact, isAdd: boolean) {
  try {
    HiLog.i('updateBlockedCallCountByDetectDetails', 'Start to update block call count by detectDetails.');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(BlockList.PHONE_NUMBER, blockListContact.phoneNumber);
    let count: number = blockListContact.interceptionCallCount;
    let updateCount = isAdd ? count + 1 : count - 1;
    let data: ValuesBucket = {
      'interception_call_count': updateCount
    };
    dataAbilityHelper.update(Contacts.BLOCK_LIST_URI, option, data)
      .then((data: number) => {
        HiLog.i('updateBlockedCallCountByDetectDetails',
          'End of update block call count by detectDetails, data: ' + data);
      }).catch((error: BusinessError) => {
      HiLog.e('updateBlockedCallCountByDetectDetails', ' error:%s', error?.message);
    });
  } catch (err) {
    HiLog.e('updateBlockedCallCountByDetectDetails ', ` error: ${err?.message}, stack: ${err?.stack}`);
  }
}

@Concurrent
export async function updateBlockedCallCountByPhoneNumber(context: common.UIAbilityContext,
  blockListContact: BlockListContact, isAdd: boolean) {
  try {
    HiLog.i('updateBlockedCallCountByPhoneNumber', 'Start to update block call count by phoneNumber.');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    // 更新黑白名单拦截数量时，使用数据库存的phoneNumber更新
    option.equalTo(BlockList.PHONE_NUMBER, blockListContact.phoneNumber);
    let count: number = blockListContact.interceptionCallCount;
    let updateCount = isAdd ? count + 1 : count - 1;
    let data: ValuesBucket = {
      'interception_call_count': updateCount
    };
    dataAbilityHelper.update(Contacts.BLOCK_LIST_URI, option, data)
      .then((data: number) => {
        HiLog.i('updateBlockedCallCountByPhoneNumber', 'End of update block call count by phoneNumber, data: ' + data);
      }).catch((error: BusinessError) => {
      HiLog.e('updateBlockedCallCountByPhoneNumber', ' error:%s', error?.message);
    });
  } catch (err) {
    HiLog.e('updateBlockedCallCountByPhoneNumber ', ` error: ${err?.message}, stack: ${err?.stack}`);
  }
}

/**
 * update to white list
 *
 * @param context to get dataShare object
 * @param phoneNumber which to be found
 *
 */
@Concurrent
export async function updateToWhiteList(context: common.UIAbilityContext, phoneNumber: string) {
  try {
    HiLog.i('updateToWhiteList', 'Start to update a phoneNumber from block list to white list.');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(BlockList.PHONE_NUMBER, phoneNumber);
    let data: ValuesBucket = {
      types: 1
    };
    dataAbilityHelper.update(Contacts.BLOCK_LIST_URI, option, data)
      .then((data: number) => {
        HiLog.i('updateToAllowList', 'End of update a phoneNumber from block list to allow list.');
      }).catch((error: BusinessError) => {
      HiLog.e('updateToWhiteList', 'updateToWhiteList error:%s', error?.message);
    });
  } catch (err) {
    HiLog.e('updateToWhiteList ', `updateToWhiteList error: ${err?.message}, stack: ${err?.stack}`);
  }
}

@Concurrent
export async function addToWhiteList(context: common.UIAbilityContext, phoneNumber: string) {
  try {
    HiLog.i('addToWhiteList', 'Start to query a phoneNumber is in blockList.');
    let dataAbilityHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(BlockList.PHONE_NUMBER, phoneNumber);
    let data: ValuesBucket = {
      'phone_number': phoneNumber,
      types: 1
    };
    dataAbilityHelper.insert(Contacts.BLOCK_LIST_URI, data)
      .then((data: number) => {
        if (!data || data == -1) {
          HiLog.e('addToAllowList', 'Data inserted failed');
        }
        HiLog.i('addToAllowList', 'End of add a phoneNumber to blockList.');
      }).catch((error: BusinessError) => {
      HiLog.e('addToWhiteList', 'addToBlockList error:%s', error?.message);
    });
  } catch (err) {
    HiLog.e('addToWhiteList ', `isInBlockList error: ${err?.message}, stack: ${err?.stack}`);
  }
}

// 号码匹配规则: 1.号码完全相等; 2.号码长度大于等于7位，后7位相等。
@Concurrent
export async function queryContactNameByNumber(
  context: Context, numbers: string[], contactType?: number): Promise<ContactNameNumberInfo[]> {
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('queryContactNameByNumber', 'Start to query contact name by number.  numbers.length: ' + numbers.length);
    let contactInfos: ContactNameNumberInfo[] = [];
    let dataShareHelper = await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let condition = new dataSharePredicates.DataSharePredicates();

    condition.beginWrap();
    condition.in(Data.DETAIL_INFO, numbers);
    condition.or();
    condition.in(Data.FORMAT_PHONE_NUMBER, numbers);
    condition.endWrap();
    condition.and();
    condition.equalTo(Data.TYPE_ID, '5');
    condition.and();
    condition.equalTo(Data.IS_DELETED, '0');
    condition.and();
    condition.notEqualTo(Data.MARK_MY_CARD, '1');
    if (contactType) {
      condition.and();
      condition.equalTo('favorite', contactType);
    }
    let queryColumn: string[] =
      [Data.DETAIL_INFO, RawContacts.DISPLAY_NAME, Data.FORMAT_PHONE_NUMBER, RawContacts.CONTACT_ID];
    resultSet = await dataShareHelper.query(Data.CONTENT_URI, condition, queryColumn);
    HiLog.i('queryContactNameByNumber',
      'Matching numbers are exactly equal.  resultSet.rowCount: ' + resultSet.rowCount);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      do {
        let phoneNumber = StringUtil.removeSpace(resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)));
        let name = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
        let formatPhoneNumber = resultSet.getString(resultSet.getColumnIndex(Data.FORMAT_PHONE_NUMBER));
        let contactId = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
        contactInfos.push(new ContactNameNumberInfo(phoneNumber, name, formatPhoneNumber, contactId));
        let index1 = numbers.indexOf(phoneNumber);
        if (index1 >= 0) {
          numbers.splice(index1, 1);
        }
        let index2 = numbers.indexOf(formatPhoneNumber);
        if (index2 >= 0) {
          numbers.splice(index2, 1);
        }
      } while (resultSet.goToNextRow());
    }

    numbers = numbers.filter(item => !StringUtil.isEmpty(item) && item.length >= 7);
    condition = new dataSharePredicates.DataSharePredicates();
    condition.beginWrap();
    for (let i = 0; i < numbers.length; i++) {
      condition.endsWith('detail_info', NumberMatch.getInstance().getQueryNum(numbers[i]));
      if (i < numbers.length - 1) {
        condition.or();
      } else {
        condition.endWrap();
      }
    }
    condition.equalTo('type_id', '5');
    condition.and();
    condition.equalTo('is_deleted', '0');
    condition.and();
    condition.notEqualTo(Data.MARK_MY_CARD, '1');
    if (contactType) {
      condition.and();
      condition.equalTo('favorite', contactType);
    }
    resultSet = await dataShareHelper.query(Data.CONTENT_URI, condition, queryColumn);
    HiLog.i('queryContactNameByNumber',
      'Match the last 7 digits of the number exactly.  resultSet.rowCount: ' + resultSet.rowCount);
    if (resultSet.rowCount > 0) {
      for (let number of numbers) {
        let index = await NumberMatch.getInstance().getCallerIndex(resultSet, number);
        if (index > -1) {
          resultSet.goToRow(index);
          let name = resultSet.getString(resultSet.getColumnIndex(RawContacts.DISPLAY_NAME));
          let formatPhoneNumber = resultSet.getString(resultSet.getColumnIndex(Data.FORMAT_PHONE_NUMBER));
          let contactId = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
          contactInfos.push(new ContactNameNumberInfo(number, name, formatPhoneNumber, contactId));
        }
      }
    }
    HiLog.i('queryContactNameByNumber', 'End to query contact name by number.');
    return contactInfos;
  } catch (err) {
    HiLog.e('queryContactNameByNumber ', `queryContactNameByNumber error: ${err?.message}, stack: ${err?.stack}`);
    emitter.emit(EmitterConstant.GET_ALL_CALLS_EMITTER_ID);
    return [];
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

/**
 * Query format number by phone number
 *
 * @param context to get dataShare object
 * @param phoneNumber which to be found
 * @returns the format number of phone number
 */
@Concurrent
export async function queryFormatNumberByNumber(
  context: common.UIAbilityContext, phoneNumber: string): Promise<RoamingData | undefined> {
  if (phoneNumber.length === 0) {
    HiLog.w('ContactRepository ', 'queryFormatNumber failed, phone number is null');
    return undefined;
  }

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let resultColumns = [Data.FORMAT_PHONE_NUMBER, Data.CUSTOM_DATA];
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(Data.TYPE_ID, 5);
    conditionArgs.and()
    conditionArgs.equalTo(Data.DETAIL_INFO, phoneNumber)
    resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns);
    if (resultSet == undefined || !resultSet.goToFirstRow()) {
      HiLog.w('ContactRepository ', 'queryFormatNumber not found.');
      return undefined;
    }
    let formatNum = resultSet.getString(resultSet.getColumnIndex(Data.FORMAT_PHONE_NUMBER));
    let label = resultSet.getLong(resultSet.getColumnIndex(Data.CUSTOM_DATA));
    HiLog.w('ContactRepository ', 'query formatNumber success');
    return {
      formatNumber: formatNum,
      labelId: label
    };
  } catch (err) {
    HiLog.e('ContactRepository ', `query formatNumber error: ${err?.message}, stack: ${err?.stack}`);
    return undefined;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

/**
 * Update format number by phone number
 *
 * @param context to get dataShare object
 * @param phoneNumber which to be found
 * @returns update is success
 */
@Concurrent
export async function updateFormatNumberByNumber(
  context: common.UIAbilityContext, phoneNumber: string[]): Promise<number> {
  if (phoneNumber[UpdateFormatNumerParam.PHONE_NUMBER_INDEX].length === 0) {
    HiLog.w('ContactRepository ', 'updateFormatNumberByNumber failed, phone number is null');
    return -1;
  }
  try {
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(Data.TYPE_ID, 5);
    conditionArgs.and()
    conditionArgs.equalTo(Data.DETAIL_INFO, phoneNumber[UpdateFormatNumerParam.PHONE_NUMBER_INDEX]);
    if (phoneNumber[UpdateFormatNumerParam.OLD_FORMAT_NUMBER_INDEX].length === 0) {
      conditionArgs
        .beginWrap()
        .isNull(Data.FORMAT_PHONE_NUMBER)
        .or()
        .equalTo(Data.FORMAT_PHONE_NUMBER, '')
        .endWrap();
    } else {
      conditionArgs.equalTo(Data.FORMAT_PHONE_NUMBER, phoneNumber[UpdateFormatNumerParam.OLD_FORMAT_NUMBER_INDEX]);
    }
    let values: ValuesBucket = {
      'format_phone_number': phoneNumber[UpdateFormatNumerParam.NEW_FORMAT_NUMBER_INDEX],
    }
    let result = await dataShareHelper.update(Data.CONTENT_URI, conditionArgs, values);
    HiLog.i('ContactRepository ', 'update formatNumber success');
    return result;
  } catch (err) {
    HiLog.e('ContactRepository ', `update formatNumber error: ${err?.message}, stack: ${err?.stack}`);
    return -1;
  }
}

/**
 * Query BlockList
 * @param {Object} context
 * @param {string[]} query phone numbers
 * @param {number} query types
 * @return {boolean} query result
 */
@Concurrent
export async function isInBlockOrAccessList(context: common.UIAbilityContext, phoneNumbers: string[],
  types: number): Promise<boolean> {
  try {
    if (phoneNumbers.length === 0) {
      return false;
    }
    HiLog.i('ContactRepository ', 'Start to query if phoneNumbers exist in blockList.');
    let realPhoneNumbers: string[] = [];
    phoneNumbers.forEach(item => {
      let tempPhone = StringUtil.removeSpace(item.toString());
      //判断大于7
      if (tempPhone.length >= NumberMatch.QUERY_NUM_LENGTH_LIMIT) {
        tempPhone = NumberMatch.getInstance().getQueryNum(tempPhone);
      }
      realPhoneNumbers.push(tempPhone);
    });
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let count = 0;
    for (let i = 0; i < realPhoneNumbers.length; i++) {
      let option = new dataSharePredicates.DataSharePredicates();
      option.beginWrap();
      option.endsWith(BlockList.PHONE_NUMBER, realPhoneNumbers[i]);
      option.endWrap();
      option.and();
      option.equalTo(BlockList.TYPES, types);
      option.and();
      option.lessThan(BlockList.TIME_STAMP, Date.now());

      let resultSet: DataShareResultSet | undefined = undefined;
      try {
        resultSet = await dataShareHelper.query(Contacts.BLOCK_LIST_URI, option, []);
        if (resultSet.rowCount > 0) {
          //号码强匹配
          let matchIndex = await NumberMatch.getInstance().getCallerIndex(resultSet, phoneNumbers[i]);
          if (matchIndex > -1) {
            count++;
          }
        }

      } finally {

        ObjectUtil.closeResultSet(resultSet);
      }
    }
    let res: boolean = (count === phoneNumbers.length);

    return res;
  } catch (err) {
    HiLog.e('ContactRepository ', `isInBlockList error: ${err?.message}, stack: ${err?.stack}`);
    return false;
  }
}

/**
 * Query BlockList
 * @param {Object} context
 * @param {string[]} query phone numbers
 * @param {number} query types
 * @return {boolean} query result
 */
@Concurrent
export async function isInStartWithBlock(context: common.UIAbilityContext, phoneNumber: string): Promise<boolean> {
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('ContactRepository ', 'Start to query a phoneNumber is in start with blockList.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(BlockList.TYPES, 2);
    option.and();
    option.lessThan(BlockList.TIME_STAMP, Date.now());

    resultSet = await dataShareHelper.query(Contacts.BLOCK_LIST_URI, option, []);
    if (resultSet.rowCount > 0) {
      // 依次匹配开头号码，安工逻辑写死+86
      resultSet.goToFirstRow();
      do {
        let blockNumber =
          resultSet.getString(resultSet.getColumnIndex(BlockList.PHONE_NUMBER));
        let reg: string = '+86';
        if (!blockNumber.startsWith(reg)) {
          blockNumber = reg + blockNumber;
        }
        if (!phoneNumber.startsWith(reg)) {
          phoneNumber = reg + phoneNumber;
        }
        if (phoneNumber.startsWith(blockNumber)) {
          return true;
        }
      } while (resultSet.goToNextRow());
    }
    HiLog.i('ContactRepository ', 'query a phoneNumber is in start with blockList is:');
    return false;
  } catch (err) {
    HiLog.e('ContactRepository ', `isInStartWithBlock error: ${err?.message}, stack: ${err?.stack}`);
    return false;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

/**
 * Add BlockList
 * @param {Object} context
 * @param {string[]} addBlockList phone numbers
 * @return {number} add result
 *
 */
@Concurrent
export async function addBlockList(context: common.UIAbilityContext,
  phoneNumbers: string, displayName: string): Promise<number> {
  try {
    HiLog.i('ContactRepository ', 'Start to add phoneNumbers in blockList.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let data =
      await dataShareHelper.insert(Contacts.BLOCK_LIST_URI, {
        'phone_number': phoneNumbers,
        'name': displayName,
        'types': BlockType.BLOCK,
        'time_stamp': Date.now()
      })
    HiLog.i('ContactRepository ', 'add phoneNumbers in blockList data:' + data);
    if (!data || data == -1) {
      HiLog.e('ContactRepository ', 'Data inserted blockList failed');
      return -1;
    }
    HiLog.i('ContactRepository ', 'add phoneNumbers in blockList data:' + data);
    return data;
  } catch (error) {
    HiLog.e('ContactRepository ', 'phoneNumbers insert in blockList error: ' + error?.message);
    return -1;
  }
}

/**
 * Delete BlockList
 * @param {Object} context
 * @param {string[]} deleteBlockList phone numbers
 * @return {boolean} delete result
 *
 */
@Concurrent
export async function cancelBlockList(context: common.UIAbilityContext, phoneNumbers: string[]): Promise<boolean> {
  try {
    HiLog.i('ContactRepository ', `Start to delete ${phoneNumbers?.length} phoneNumbers is in blockList.`);
    let countryId: string;
    try {
      countryId = I18n.System.getSystemRegion();
    } catch (error) {
      countryId = 'CN';
    }
    let options: call.NumberFormatOptions = {
      countryCode: countryId,
    }
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    let formatPhones: string[] = [];
    //所有号码统一+一遍国家码。
    for (let phone of phoneNumbers) {
      let formatNumber: string = await call.formatPhoneNumberToE164(StringUtil.removeSpace(phone.toString()),
          options.countryCode ? options.countryCode : 'CN');
      if (StringUtil.isEmpty(formatNumber)) {
        HiLog.i('ContactRepository ', `formatNumber is empty, skip push.`);
      } else {
        formatPhones.push(formatNumber);
      }
    }
    if (formatPhones.length > 0) {
      conditionArgs.in(BlockList.FORMAT_PHONE_NUMBER, formatPhones);
      conditionArgs.or();
    }
    conditionArgs.in(BlockList.PHONE_NUMBER, phoneNumbers);
    conditionArgs.and();
    conditionArgs.equalTo(BlockList.TYPES, BlockType.BLOCK);
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let data =
      await dataShareHelper.delete(Contacts.BLOCK_LIST_URI, conditionArgs);
    if (data == -1) {
      HiLog.e('ContactRepository ', 'delete phoneNumbers in blockList in failed!');
      return false;
    }
    HiLog.i('ContactRepository ', 'delete phoneNumbers is in blockList data:' + data);
    return true;
  } catch (err) {
    HiLog.e('ContactRepository ', 'delete phoneNumbers in blockList error: ' + err?.message);
    return false;
  }
}

/**
 * Update BlockList
 * @param {Object} context
 * @param {string[]} updateBlockList phone numbers
 * @return {number} update result
 *
 */
@Concurrent
export async function updateBlockList(context: common.UIAbilityContext,
  phoneNumbers: string, displayName: string): Promise<number> {
  try {
    HiLog.i('ContactRepository ', 'Start to update a phoneNumber is in blockList.');
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(BlockList.PHONE_NUMBER, phoneNumbers);
    conditionArgs.and();
    conditionArgs.equalTo(BlockList.TYPES, BlockType.ACCESS);
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let data =
      await dataShareHelper.update(Contacts.BLOCK_LIST_URI, conditionArgs, {
        'types': BlockType.BLOCK,
        'time_stamp': Date.now(),
        'name': displayName
      });
    if (!data || data == -1) {
      HiLog.e('ContactRepository ', 'update phoneNumbers in blockList in failed!');
      return -1;
    }
    HiLog.i('ContactRepository ', 'update phoneNumbers is in blockList data:' + data);
    return data;
  } catch (error) {
    HiLog.e('ContactRepository ', 'update phoneNumbers in blockList error: ' + error?.message);
    return -1;
  }
}

/**
 * Query YellowPage
 * @param {Object} context
 * @param {string} query phone numbers
 * @return {ContactNameNumberInfo[]} query result
 */
@Concurrent
export async function queryYellowPageByNumber(context: common.UIAbilityContext,
  phoneNumber: string): Promise<ContactNameNumberInfo[]> {
  if (StringUtil.isEmpty(phoneNumber)) {
    return [];
  }

  let resultSet: DataShareResultSet | undefined = undefined;
  let allRecordResultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('ContactRepository ', 'Start to query phoneNumbers in yellowPage.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, YellowPage.YELLOW_PAGE_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(YellowPage.NUMBER, phoneNumber);
    resultSet = await dataShareHelper.query(YellowPage.YELLOW_PAGE_VIEW_URI, option, [])
    let contactInfos: ContactNameNumberInfo[] = [];
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      let yellowPageId = resultSet.getLong(resultSet.getColumnIndex(YellowPage.YELLOW_PAGE_ID));
      HiLog.i('ContactRepository ', 'query phoneNumbers in yellowPage ypid is:' + yellowPageId);
      option = new dataSharePredicates.DataSharePredicates();
      option.equalTo(YellowPage.YELLOW_PAGE_ID, yellowPageId);
      allRecordResultSet = await dataShareHelper.query(YellowPage.YELLOW_PAGE_VIEW_URI, option, [])
      HiLog.i('ContactRepository ', 'query phoneNumbers in yellowPage is:' +
      allRecordResultSet.rowCount);
      do {
        let number = allRecordResultSet.getString(allRecordResultSet.getColumnIndex(YellowPage.NUMBER));
        contactInfos.push(new ContactNameNumberInfo(number,
          allRecordResultSet.getString(allRecordResultSet.getColumnIndex(YellowPage.NAME))));
      } while (allRecordResultSet.goToNextRow());
    } else {
      HiLog.i('ContactRepository ', 'queryYellowPageByNumber is 0')
    }
    return contactInfos;
  } catch (err) {
    HiLog.e('ContactRepository ', `queryYellowPageByNumber error: ${err?.message}, stack: ${err?.stack}`);
    return [];
  } finally {
    ObjectUtil.closeResultSet(resultSet);
    ObjectUtil.closeResultSet(allRecordResultSet);
  }
}

/**
 * Query is in YellowPage
 *
 * @param {Object} context
 * @param {string} query phone numbers
 *
 * @return {boolean} query result
 */
@Concurrent
export async function queryYellowPageNameByNumber(context: common.UIAbilityContext,
  phoneNumbers: string[]): Promise<Map<string, string>> {
  let yellowInfoMap = new Map<string, string>();
  if (phoneNumbers.length <= 0) {
    HiLog.w('ContactRepository ', 'queryYellowPageNameByNumber jump');
    return yellowInfoMap;
  }

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.w('ContactRepository ', 'Start to query yellowPage name by phoneNumber.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, YellowPage.YELLOW_PAGE_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.in(YellowPage.NUMBER, phoneNumbers);
    resultSet =
      await dataShareHelper.query(YellowPage.YELLOW_PAGE_VIEW_URI, option, [YellowPage.NAME, YellowPage.NUMBER])
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      do {
        let yellowPageNumber = resultSet.getString(resultSet.getColumnIndex(YellowPage.NUMBER));
        let yellowPageName = resultSet.getString(resultSet.getColumnIndex(YellowPage.NAME));
        yellowInfoMap.set(yellowPageNumber, yellowPageName);
      } while (resultSet.goToNextRow());
    }
  } catch (err) {
    HiLog.e('ContactRepository ', `queryYellowPageNameByNumber error: ${err?.message}`);
    throw new Error(`queryYellowPageNameByNumber error: ${err?.message}`);
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
  return yellowInfoMap;
}

@Concurrent
export async function queryUniqueKeyByContactId(context: common.UIAbilityContext, contactId: string):
  Promise<Map<number, string>> {
  let rawIdMap = new Map<number, string>();
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.w('ContactRepository ', `queryUniqueKeyByContactId start! contactId: ${contactId}`);
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, RawContacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(RawContacts.CONTACT_ID, contactId);
    option.and();
    option.equalTo(RawContacts.IS_DELETED, '0');
    resultSet = await dataShareHelper.query(RawContacts.CONTENT_URI, option, [RawContacts.ID, RawContacts.UNIQUE_KEY])
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      do {
        let uniqueKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.UNIQUE_KEY));
        let rawId = resultSet.getLong(resultSet.getColumnIndex(RawContacts.ID));
        rawIdMap.set(rawId, uniqueKey)
      } while (resultSet.goToNextRow());
    }
    HiLog.w('ContactRepository ', `queryUniqueKeyByContactId success, rawIdMap size: ${rawIdMap.size}`);
  } catch (err) {
    HiLog.e('ContactRepository ', `queryUniqueKeyByContactId error: ${err.message}`);
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
  return rawIdMap;
}

@Concurrent
export async function getGroupContactId(context: common.UIAbilityContext, contactId: number[]):
  Promise<Map<number, string>> {
  let rawIdMap = new Map<number, string>();
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.w('ContactRepository ', `getGroupContactId start! contactId: ${contactId}`);
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, RawContacts.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    if (contactId.length > 1) {
      option.in(RawContacts.CONTACT_ID, contactId);
    } else {
      option.equalTo(RawContacts.CONTACT_ID, contactId.toString());
    }
    option.and();
    option.equalTo(RawContacts.IS_DELETED, '0');
    resultSet = await dataShareHelper.query(RawContacts.CONTENT_URI, option, [RawContacts.ID, RawContacts.UNIQUE_KEY])
    HiLog.w('ContactRepository ', ` ${resultSet.rowCount}`);
    if (resultSet !== undefined && resultSet.rowCount > 0) {
      do {
        let uniqueKey = resultSet.getString(resultSet.getColumnIndex(RawContacts.UNIQUE_KEY));
        let rawId = resultSet.getLong(resultSet.getColumnIndex(RawContacts.ID));
        rawIdMap.set(rawId, uniqueKey)
      } while (resultSet.goToNextRow());
    } else {
      // 如果 resultSet 为 undefined，进行错误处理
      HiLog.e('ContactRepository ', ' resultSet is undefined');
    }
    HiLog.w('ContactRepository ', `getGroupContactId success, rawIdMap size: ${rawIdMap.size}`);
  } catch (err) {
    HiLog.e('ContactRepository ', `getGroupContactId error: ${err.message}`);
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
  return rawIdMap;
}

@Concurrent
export async function getContactIdWithBlobNotNullByFilter(contactBlobSourceMap: Map<string, ContactBlobSource[]>):
  Promise<ContactBlobSource[]> {
  let resultDefault: ContactBlobSource[] = [];
  try {
    if (contactBlobSourceMap && contactBlobSourceMap.size) {
      let keys = contactBlobSourceMap.keys();
      for (let key of keys) {
        let itemList: ContactBlobSource[] | undefined = contactBlobSourceMap.get(key);
        if (itemList === undefined || !itemList || itemList.length < 1) {
          continue;
        }
        // 默认初始值
        let itemResult: ContactBlobSource = itemList[0];
        if (itemList && itemList.length === 1) {
           itemResult = itemList[0];
        } else {
          // 查询detail_info,存在,则用raw_contact_id排序，获取raw_contact_id最大的一个detail_info的头像
          let detailInfoNotNullList = itemList.filter((v) => {
            return !StringUtil.isEmpty(v.detailInfo);
          })
          if (detailInfoNotNullList && detailInfoNotNullList.length) {
            // 按照rawId倒叙
            detailInfoNotNullList.sort((v1, v2) => {
              return parseInt(v2.rawContactId) - parseInt(v1.rawContactId);
            })
            let result = detailInfoNotNullList[0];
            HiLog.w('ContactRepository getContactIdWithBlobNotNullCompareFileScale ',
              `getContactIdWithBlobNotNull by detailInfo, contactId: ${key},rawContactId: ${result.rawContactId},blobSource: ${result.blobSource},detailInfo: ${result.detailInfo}`);
            itemResult = result;
          } else {
            // 若没有detail_info，则用raw_contact_id排序，获取raw_contact_id最大的一个blob_data
            itemList.sort((v1, v2) => {
              return parseInt(v2.rawContactId) - parseInt(v1.rawContactId);
            })
            HiLog.w('ContactRepository getContactIdWithBlobNotNullCompareFileScale ',
              `getContactIdWithBlobNotNull by blobSource, contactId: ${key}, rawContactId: ${itemList[0].rawContactId},blobSource: ${itemList[0].blobSource}, detailInfo: ${itemList[0].detailInfo}`);
            itemResult = itemList[0];
          }
        }
        resultDefault.push(itemResult);
      }
    }
    return resultDefault;
  } catch (err) {
    HiLog.e('ContactRepository getContactIdWithBlobNotNullCompareFileScale ',
      `getContactIdWithBlobNotNull error: ${err.message}`);
  }
  return resultDefault;
}