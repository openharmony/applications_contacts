/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { CustomizedParams, GroupParams } from '../../model/type';
import { GroupBean, GroupInfo, IntelligenceGroupInfo } from '../../model/bean/GroupBean';
import DotUtil from '../../util/DotUtil';
import IntelligenceGroupListDataSource from '../../model/bean/IntelligenceGroupListDataSource';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import { Constants } from '../../data/Constants';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import TraceConstants from '../../../../../../common/src/main/ets/TraceConstants';

const TAG = 'IntelligenceGroupSingleCategoryDetailPresenter  ';

export default class IntelligenceGroupSingleCategoryDetailPresenter {
  public pathInfos?: NavPathStack;
  private static instance: IntelligenceGroupSingleCategoryDetailPresenter;
  public categoryGroupType: string = Constants.EMTPY_STR;
  public id: number = 0
  public intelligenceGroupListDataSource: IntelligenceGroupListDataSource = new IntelligenceGroupListDataSource();
  public groupList: Array<GroupInfo> = [];
  public groupMemberListLen: number = 0;
  public customParams: CustomizedParams = {};
  // 查询数据库标记位,并发控制，同一时间只能有一次查询
  private isQueryIntelligenceGroupStatisticDoing: boolean = false;
  /**
   * 分类条数更新
   */
  public updateIntelligenceGroupList: IntelligenceGroupListInterface = {
    updateIntelligenceGroupList: (): void => {
    }
  };

  public static getInstance(): IntelligenceGroupSingleCategoryDetailPresenter {
    if (IntelligenceGroupSingleCategoryDetailPresenter.instance == null) {
      IntelligenceGroupSingleCategoryDetailPresenter.instance = new IntelligenceGroupSingleCategoryDetailPresenter();
    }
    return IntelligenceGroupSingleCategoryDetailPresenter.instance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  async aboutToAppear(categoryGroupType: string) {
    HiLog.w(TAG, `intelligenc groupList aboutToAppear :${categoryGroupType}`);
    if (this.isQueryIntelligenceGroupStatisticDoing) {
      HiLog.i(TAG, `setPageShow query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupStatisticDoing = true;
    }
    this.queryAllIntelligenceGroupByCategoryType(categoryGroupType);
  }

  async setPageShow() {
    HiLog.w(TAG, `intelligenc groupList setPageShow :${this.categoryGroupType}`);
    if (this.isQueryIntelligenceGroupStatisticDoing) {
      HiLog.i(TAG, `setPageShow query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupStatisticDoing = true;
    }
    this.queryAllIntelligenceGroupByCategoryType(this.categoryGroupType);
  }

  /**
   * query contact Statistic by company or home area or latest contact time
   *
   * @param categoryType type of company or home area or latest contact time
   */
  queryAllIntelligenceGroupByCategoryType(categoryType: string): void {
    HiLog.w(TAG, `queryAllIntelligenceGroupByCategoryType start type:${categoryType}`);
    if (categoryType === Constants.INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE) {
      this.queryOrganizationIntelligenceGroup();
    } else if (categoryType === Constants.INTELLIGENCE_GROUP_CITY_CATEGORYTYPE) {
      this.queryHomeAreaIntelligenceGroup();
    } else if (categoryType === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_CATEGORYTYPE) {
      this.queryLatestTimeContactIntelligenceGroup();
    } else {
      this.isQueryIntelligenceGroupStatisticDoing = false;
      HiLog.w(TAG, `queryAllIntelligenceGroupByCategoryType categoryType invalid.`);
    }
  }

  /**
   * query contact Statistic by company
   */
  queryOrganizationIntelligenceGroup(): void {
    HiLog.w(TAG, 'queryOrganizationIntelligenceGroup start.');
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupStatisticDoing = false;
      return;
    }

    workerWrapper.sendRequest('queryOrganizationIntelligenceGroupStatistic', {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }, (result: IntelligenceGroupInfo[]) => {
      HiLog.i(TAG, `queryOrganizationIntelligenceGroup end result len:${result?.length}.`);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
        TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);
      if (result && result?.length) {
        this.groupMemberListLen = result?.length;
        this.refreshMemberList(result);
      } else {
        HiLog.w(TAG, 'queryOrganizationIntelligenceGroup empty.');
      }
      this.isQueryIntelligenceGroupStatisticDoing = false;
      this.updateIntelligenceGroupList.updateIntelligenceGroupList();
      HiLog.i(TAG, 'queryOrganizationIntelligenceGroup end.');
    })
  }

  /**
   * query contact Statistic byhome area
   */
  queryHomeAreaIntelligenceGroup(): void {
    HiLog.w(TAG, 'queryHomeAreaIntelligenceGroup start.');
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupStatisticDoing = false;
      return;
    }

    workerWrapper.sendRequest('queryCityIntelligenceGroupStatistic', {
      groupId: this.id.toString(),
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }, (result: IntelligenceGroupInfo[]) => {
      HiLog.i(TAG, `queryHomeAreaIntelligenceGroup end result len:${result?.length}.`);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
        TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);
      if (result && result?.length) {
        this.groupMemberListLen = result?.length;
        this.refreshMemberList(result);
      } else {
        HiLog.w(TAG, 'queryHomeAreaIntelligenceGroup end.');
      }
      this.isQueryIntelligenceGroupStatisticDoing = false;
      this.updateIntelligenceGroupList.updateIntelligenceGroupList();
      HiLog.w(TAG, 'queryHomeAreaIntelligenceGroup end.');
    })
  }

  /**
   * query contact Statistic by latest contact time
   */
  queryLatestTimeContactIntelligenceGroup(): void {
    HiLog.w(TAG, 'queryLatestTimeContactIntelligenceGroup start.');
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupStatisticDoing = false;
      return;
    }

    workerWrapper.sendRequest('queryLatestContactTimeIntelligenceGroupStatistic', {
      groupId: this.id.toString(),
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }, (result: IntelligenceGroupInfo[]) => {
      HiLog.i(TAG, `queryLatestTimeContactIntelligenceGroup end result len:${result?.length}.`);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY,
        TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID);
      if (result && result?.length) {
        this.groupMemberListLen = result?.length;
        this.refreshMemberList(result);
      } else {
        HiLog.w(TAG, 'queryLatestTimeContactIntelligenceGroup empty.');
      }
      this.isQueryIntelligenceGroupStatisticDoing = false;
      this.updateIntelligenceGroupList.updateIntelligenceGroupList();
      HiLog.i(TAG, 'queryOrganizationIntelligenceGroup end.');
    });
  }


  refreshMemberList(intelligencGroupList: IntelligenceGroupInfo[]) {
    HiLog.w(TAG, 'refreshMemberList start.');
    this.intelligenceGroupListDataSource.refresh(intelligencGroupList);
  }

  resetData() {
    this.groupMemberListLen = 0;
    this.intelligenceGroupListDataSource.clearData();
    this.isQueryIntelligenceGroupStatisticDoing = false;
  }

  back() {
    this.pathInfos?.pop();
  }

  toIntelliGenceGroupSingleGroupDetail(categoryGroupType: string, intelliGroupName: string, categoryIndex: string,
    memberCount: number) {
    HiLog.w(TAG, 'toIntelliGenceGroupSingleGroupDetail !!');
    let params: Record<string, boolean | string | number> = {
      'intelliGroupName': intelliGroupName,
      'categoryGroupType': categoryGroupType,
      'categoryIndex': categoryIndex,
      'memberCount': memberCount
    }
    DynamicLoader.getInstance().fire(DynamicLoader.INTELLIGENCE_GROUP_SINGLE_GROUP_DETAIL).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.INTELLIGENCE_GROUP_SINGLE_GROUP_DETAIL, params);
    });
  }
}

/**
 * 更新智能分组的数量
 */
export interface IntelligenceGroupListInterface {
  updateIntelligenceGroupList: () => void
}