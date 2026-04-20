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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { CustomizedParams, GroupParams } from '../../model/type';
import { AlphabetIndexObj, ContactVo, MemberInfo } from '../../model/bean/ContactVo';
import { GroupBean, GroupInfo } from '../../model/bean/GroupBean';
import ContactListDataSource from '../../model/bean/ContactListDataSource';
import AlphabetIndexerPresenter from '../contact/alphabetindex/AlphabetIndexerPresenter';
import { Constants } from '../../data/Constants';
import { ContactInfoGetParamsInCallback } from '../../model/type/ContactParams';
import { AddSelectMemSendMsgUpdateToolbar } from './IntelligenceGroupSelectMemSendMsgPresenter';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import TraceConstants from '../../../../../../common/src/main/ets/TraceConstants';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import TextUtils from '../../../../../../common/src/main/ets/util/TextUtils';

const TAG = 'IntelligenceGroupSingleGroupDetailPresenter  ';
const INTELLIGENCE_GROUP_QUERY_LIMIT = 35000;

export default class IntelligenceGroupSingleGroupDetailPresenter {
  public pathInfos?: NavPathStack;
  public groupName: string = Constants.EMTPY_STR;
  public categoryIndex: string = Constants.EMTPY_STR;
  public categoryGroupType: string = Constants.EMTPY_STR;
  public id: number = 0;
  public contactListDataSource: ContactListDataSource = new ContactListDataSource();
  public groupMemberListLen: Number = 0;
  public alphabetIndexPresenter: AlphabetIndexerPresenter = new AlphabetIndexerPresenter();
  public initialIndex: number = 0;
  // 查询数据库标记位,并发控制，同一时间只能有一次查询
  private isQueryIntelligenceGroupContactListDoing: boolean = false;
  public memberCount: number = 0;

  /**
   * 底部toolbar加载回调
   */
  public updateToolbar: AddSelectMemSendMsgUpdateToolbar = {
    updateToolbar: (): void => {
    }
  };

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  async aboutToAppear() {
    this.alphabetIndexPresenter.clearCache();
    if (this.isQueryIntelligenceGroupContactListDoing) {
      HiLog.i(TAG, `aboutToAppear query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupContactListDoing = true;
    }
    HiLog.i(TAG, `aboutToAppear single group detail:${this.categoryGroupType},${TextUtils.getMaskString(this.groupName)},${this.categoryIndex}`);
    this.queryIntelligenceGroupContacts();
  }

  async setPageShow() {
    if (this.isQueryIntelligenceGroupContactListDoing) {
      HiLog.i(TAG, `setPageShow query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupContactListDoing = true;
    }
    HiLog.i(TAG, `setPageShow single group detail:${this.categoryGroupType},${TextUtils.getMaskString(this.groupName)},${this.categoryIndex}`);
    this.queryIntelligenceGroupContacts();
  }

  /**
   * 根据分类名称查询联系人名称
   */
  async queryIntelligenceGroupContacts() {
    if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE) {
      this.queryIntelligenceGroupContactsByOrganization(this.groupName);
    } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CITY_CATEGORYTYPE) {
      this.queryIntelligenceGroupContactsByCity(this.groupName);
    } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_CATEGORYTYPE) {
      this.queryIntelligenceGroupContactsByTimeStamp(this.categoryIndex);
    } else {
      HiLog.e(TAG, `setPageShow categoryGroupType invalid:${this.categoryGroupType}`);
      this.isQueryIntelligenceGroupContactListDoing = false;
    }
  }

  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, 'resetInitialIndex firstIndex is %s', firstIndex.toString());
    this.initialIndex = firstIndex;
  }

  /**
   * update contact company by contactids
   *
   * @param contactIds contactIds
   * @param organization company
   */
  updateContactsOrganizationInfo(contactIds: number[], organization: string): void {
    HiLog.i(TAG, `updateContactsOrganizationInfo start,${TextUtils.getMaskString(organization)}`);
    if (!contactIds || contactIds.length === 0) {
      HiLog.e(TAG, `updateContactsOrganizationInfo contactIds empty.`);
      return;
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateContactOrganizationInfo', {
        rawContactIds: contactIds,
        organization: organization,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      }, (result: boolean) => {
        this.queryIntelligenceGroupContacts();
        HiLog.i(TAG, `updateContactsOrganizationInfo result:${result}`);
      })
  }

  /**
   * query contact info by organization
   *
   * @param organization company
   */
  queryIntelligenceGroupContactsByOrganization(organization: string): void {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganization: ${TextUtils.getMaskString(organization)}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByOrganization', {
        organization: organization,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: 1
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganization: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberList(result.contactList);
          this.alphabetIndexPresenter.initContactList(result.contactList);
          this.alphabetIndexPresenter.initAlphabetIndex(result.alphabetIndex);
        } else {
          this.groupMemberListLen = 0;
          this.refreshMemberList([]);
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, 0);
          HiLog.e(TAG, `queryIntelligenceGroupContactsByOrganization result is empty.`);
        }
        this.updateToolbar.updateToolbar();
        // 如果只有一页数据，直接返回
        if ((!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) &&
          this.memberCount <= INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.isQueryIntelligenceGroupContactListDoing = false;
          return;
        }
        if (this.memberCount > INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.queryIntelligenceGroupContactsByOrganizationLimit(organization, 2);
        }
      });
  }

  /**
   * limit query contact info by organization
   *
   * @param organization organization
   * @param page page
   */
  queryIntelligenceGroupContactsByOrganizationLimit(organization: string, page: number): void {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganizationLimit: ${TextUtils.getMaskString(organization)},page:${page}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByOrganization', {
        organization: organization,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: page
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByOrganizationLimit: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberListByPage(result.contactList, page,
            result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT);
        }
        if (!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.handleContactDataWhenQueryEnd();
        } else {
          this.queryIntelligenceGroupContactsByOrganizationLimit(organization, page + 1);
        }
      });
  }

  /**
   * query contact info by phone city
   *
   * @param city home area
   */
  queryIntelligenceGroupContactsByCity(city: string): void {
    HiLog.w(TAG, `queryIntelligenceGroupContactsByCity start`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByCity', {
        location: city,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: 1
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByCity: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberList(result.contactList);
          this.alphabetIndexPresenter.initContactList(result.contactList);
          this.alphabetIndexPresenter.initAlphabetIndex(result.alphabetIndex);
        } else {
          this.groupMemberListLen = 0;
          this.refreshMemberList([]);
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, 0);
          HiLog.e(TAG, `queryIntelligenceGroupContactsByCity result is empty.`);
        }
        this.updateToolbar.updateToolbar();
        // 如果只有一页数据，直接返回
        if ((!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) &&
          this.memberCount <= INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.isQueryIntelligenceGroupContactListDoing = false;
          return;
        }
        if (this.memberCount > INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.queryIntelligenceGroupContactsByCityLimit(city, 2);
        }
      });
  }

  /**
   * limit query contact info by city
   *
   * @param city city
   * @param page page
   */
  queryIntelligenceGroupContactsByCityLimit(city: string, page: number): void {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByCityLimit: ${TextUtils.getMaskString(city)},page:${page}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByCity', {
        location: city,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: page
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByCityLimit: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberListByPage(result.contactList, page,
            result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT);
        }
        if (!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.handleContactDataWhenQueryEnd();
        } else {
          this.queryIntelligenceGroupContactsByCityLimit(city, page + 1);
        }
      });
  }

  /**
   * query contact info by phone TimeStamp
   *
   * @param categoryIndex TimeStamp type
   */
  queryIntelligenceGroupContactsByTimeStamp(categoryIndex: string): void {
    HiLog.w(TAG, `queryIntelligenceGroupContactsByTimeStamp start,${categoryIndex}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByTimestamp', {
        contactTimeType: categoryIndex,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: 1
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByTimeStamp: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberList(result.contactList);
          this.alphabetIndexPresenter.initContactList(result.contactList);
          this.alphabetIndexPresenter.initAlphabetIndex(result.alphabetIndex);
        } else {
          this.groupMemberListLen = 0;
          this.refreshMemberList([]);
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, 0);
          HiLog.e(TAG, `queryIntelligenceGroupContactsByTimeStamp result is empty.`);
        }
        this.updateToolbar.updateToolbar();
        // 如果只有一页数据，直接返回
        if ((!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) &&
          this.memberCount <= INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.isQueryIntelligenceGroupContactListDoing = false;
          return;
        }
        if (this.memberCount > INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.queryIntelligenceGroupContactsByTimeStampLimit(categoryIndex, 2);
        }
      });
  }

  /**
   * limitquery contact info by timeStamp
   *
   * @param categoryIndex categoryIndex
   * @param page page
   */
  queryIntelligenceGroupContactsByTimeStampLimit(categoryIndex: string, page: number): void {
    HiLog.i(TAG, `queryIntelligenceGroupContactsByTimeStampLimit: ${categoryIndex},page:${page}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryIntelligenceGroupContactsByTimestamp', {
        contactTimeType: categoryIndex,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        page: page
      }, (result: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryIntelligenceGroupContactsByTimeStampLimit: ${result.contactList?.length}`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID);
        if (result.contactList && result.contactList.length) {
          this.groupMemberListLen = result.contactList.length;
          AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT, result.contactList?.length);
          this.refreshMemberListByPage(result.contactList, page,
            result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT);
        }
        if (!result || !result.contactList || result.contactList.length < INTELLIGENCE_GROUP_QUERY_LIMIT) {
          this.handleContactDataWhenQueryEnd();
        } else {
          this.queryIntelligenceGroupContactsByTimeStampLimit(categoryIndex, page + 1);
        }
      });
  }

  private handleContactDataWhenQueryEnd(): void {
    this.alphabetIndexPresenter.initContactList(this.contactListDataSource.contactList);
    // 二级索引相关
    let alphabetIndex: Record<string, AlphabetIndexObj> = {};
    let index = 0;
    this.contactListDataSource.contactList.forEach(contactVo => {
      ContactAbilityModel.addAlphabetIndexObj(contactVo, index,
        alphabetIndex, index === this.contactListDataSource.contactList.length - 1);
      index++;
    })
    this.alphabetIndexPresenter.initAlphabetIndex(alphabetIndex);
    this.isQueryIntelligenceGroupContactListDoing = false;
    this.updateToolbar.updateToolbar();
  }

  public onNewContactToIndex = (newContactId: string, newContactIndex: number) => {
    if (AppStorage.get('breakpoint') != 'sm') {
      AppStorage.setOrCreate('selectContactId', newContactId);
    }
  };

  refreshMemberList(result: ContactVo[]) {
    HiLog.w(TAG, `refreshMemberList start:${result?.length}`);
    this.contactListDataSource.refresh(0, result, true);
  }

  refreshMemberListByPage(result: ContactVo[], page: number, isEnd: boolean) {
    HiLog.w(TAG, `refreshMemberListByPage start:${result?.length},${page},${isEnd}`);
    this.contactListDataSource.refresh((page - 1) * INTELLIGENCE_GROUP_QUERY_LIMIT, result, isEnd);
  }

  resetData() {
    this.groupMemberListLen = 0;
    this.contactListDataSource.clearData();
    this.isQueryIntelligenceGroupContactListDoing = false;
  }

  back() {
    this.pathInfos?.pop();
  }

  toSendMessage(categoryGroupType: string, intelliGroupName: string, categoryIndex: string) {
    let params: Record<string, boolean | string> = {
      'groupName': intelliGroupName,
      'categoryGroupType': categoryGroupType,
      'categoryIndex': categoryIndex
    }
    DynamicLoader.getInstance().fire(DynamicLoader.INTELLIGENCE_GROUP_SELECT_MEM_SEND_MSG).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.INTELLIGENCE_GROUP_SELECT_MEM_SEND_MSG, params);
    });
  }

  /**
   * parse contactdata from picker
   *
   * @param data contactinfo
   * @returns contactIds
   */
  public async parseContactForResult(data: string): Promise<string[]> {
    HiLog.i(TAG, `parseContactForResult enter.`);
    let ids: string[] = [];
    try {
      let result = JSON.parse(data) as Record<string, string | number>[];
      for (let dataTmp of result) {
        ids.push(dataTmp?.id + '');
      }
    } catch (err) {
      HiLog.e(TAG, `parseContactForResult error:${err?.message}`);
    }
    return ids;
  }
}