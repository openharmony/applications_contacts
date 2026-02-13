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
import GroupListDataSource from '../../model/bean/GroupListDataSource';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { GroupParams, RequestParam } from '../../model/type';
import { ContactVo } from '../../model/bean/ContactVo';
import { GroupBean, GroupInfo } from '../../model/bean/GroupBean';
import { IntelligenceGroupListInterface } from '../intelligencegroup/IntelligenceGroupSingleCategoryDetailPresenter';

const TAG = 'GroupListPresenter  ';

export default class GroupListPresenter {
  public pathInfos?: NavPathStack;
  private static sInstance: GroupListPresenter;
  public groupList: GroupInfo[] = [];
  public groupListDataSource: GroupListDataSource = new GroupListDataSource();
  public groupCount: number = 0;
  /**
   * 群组数量更新
   */
  public updateGroupList: IntelligenceGroupListInterface = {
    updateIntelligenceGroupList: (): void => {
    }
  };

  public static getInstance(): GroupListPresenter {
    if (GroupListPresenter.sInstance == null) {
      HiLog.w(TAG, 'Group getInstance!');
      GroupListPresenter.sInstance = new GroupListPresenter();
    }
    return GroupListPresenter.sInstance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  refreshGroup() {
    HiLog.w(TAG, 'refreshGroup start.');
    const actionData: Record<string, number> = {};
    const requestParam: RequestParam<Record<string, number>> = {
      actionData: actionData,
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllGroup', requestParam, async (group: GroupBean[]) => {
        let result: GroupInfo[] = []
        for (let item of group) {
          let memberCount = await this.getMemberLen(item.id)
          result.push(new GroupInfo(item, memberCount, false))
        }
        this.groupList = [];
        this.groupList = result;
        this.groupCount = result.length;
        this.refreshGroupList(this.groupList);
        this.updateGroupList.updateIntelligenceGroupList();
        HiLog.w(TAG, `refreshGroup end,group len:${group?.length}`);
      })
  }

  getMemberLen(id: number): Promise<number> {
    HiLog.w(TAG, `getMemberLen start groupId=${id}`);
    return new Promise((resolve) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('queryAllGroupMember', {
          groupId: id.toString(),
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        }, (result: ContactVo[]) => {
          let MemberCount: number = 0
          MemberCount = result?.length
          resolve(MemberCount)
          HiLog.w(TAG, `getMemberLen end result len=${result?.length}`);
        })
    })
  }

  backItemClick() {
    HiLog.w(TAG, 'backItemClick');
  }

  refreshGroupList(groupList: GroupInfo[]) {
    HiLog.w(TAG, 'refreshGroupList start.');
    this.groupListDataSource.refresh(groupList);
  }

  aboutToAppear() {
    HiLog.w(TAG, 'groupList aboutToAppear!');
    this.refreshGroup()
  }

  addGroup(groupName: string,groupAccountId: String) {
    HiLog.w(TAG, 'addGroup start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('addGroup',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          groupName,
          groupAccountId
        }
        , () => {
          this.refreshGroup()
          this.toGroupListDetail(groupName)
          HiLog.w(TAG, 'addGroup end.');
        })
  }

  renameGroup(groupInfo: GroupParams) {
    HiLog.w(TAG, 'renameGroup start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('renameGroup',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          groupInfo
        }
        , () => {
          this.refreshGroup()
          HiLog.w(TAG, 'renameGroup end.');
        })
  }

  removeMember(id: number) {
    HiLog.w(TAG, 'removeMember start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteMemberByGroupID',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          groupId: id.toString()
        }
        , () => {
          HiLog.w(TAG, 'removeMember end.');
        })
  }

  removeGroup(id: number) {
    HiLog.w(TAG, 'removeGroup start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('removeGroup',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          id
        }
        , () => {
          this.refreshGroup()
          HiLog.w(TAG, 'removeGroup end.');
        })
  }

  back() {
    this.pathInfos?.pop();
  }

  ifGroupExist(groupName: string) {
    let ifExist: boolean = false
    ifExist = this.groupList.some((item) => {
      return item.group.groupName == groupName
    })
    return ifExist
  };

  toBatchDeleteGroup() {
    DynamicLoader.getInstance().fire(DynamicLoader.BATCH_DELETE_GROUP).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.BATCH_DELETE_GROUP, '');
    });
  }

  toGroupListDetail(groupName: string) {
    HiLog.w(TAG, 'toGroupListDetail !!');
    DynamicLoader.getInstance().fire(DynamicLoader.GROUP_LIST_DETAIL).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.GROUP_LIST_DETAIL, groupName);
    });
  }
}