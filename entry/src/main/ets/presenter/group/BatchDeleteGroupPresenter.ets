/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import GroupListDataSource from '../../model/bean/GroupListDataSource';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { GroupInfo } from '../../model/bean/GroupBean';
import { ResourceUtil } from '../../util/ResourceUtil';

const TAG = 'BatchDeleteGroupPresenter';

export default class BatchDeleteGroupPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static mPresenter: BatchDeleteGroupPresenter;
  public groupListDataSource: GroupListDataSource = new GroupListDataSource();
  public groupSelected: Array<number> = [];
  public groupList: Array<GroupInfo> = [];
  public isSelectAll: boolean = false;
  public selectedCount: number = 0;

  static getInstance() {
    if (BatchDeleteGroupPresenter.mPresenter == null) {
      BatchDeleteGroupPresenter.mPresenter = new BatchDeleteGroupPresenter();
    }
    return BatchDeleteGroupPresenter.mPresenter;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  back() {
    this.pathInfos.pop();
  }

  resetData() {
    this.isSelectAll = false;
    this.selectedCount = 0;
    this.groupSelected = [];
  }

  initGroupData() {
    this.groupList = this.groupListDataSource.getGroupData();
    this.groupList.forEach((item) => {
      item.checked = false;
    });
    this.groupListDataSource.refresh(this.groupList);
  }

  checkboxChanged(id: number, value: boolean, itemIndex: number) {
    this.groupList[itemIndex].checked = value;
    let count: number = this.selectedCount;
    if (value) {
      this.groupSelected.push(id);
      count++;
      if (this.groupSelected.length === this.groupList.length) {
        this.isSelectAll = true;
      }
    } else {
      for (let i = this.groupSelected.length - 1; i >= 0; i--) {
        let selectedId = this.groupSelected[i];
        if (id === selectedId) {
          count--;
          this.groupSelected.splice(i, 1);
          break;
        }
      }
      this.isSelectAll = false;
    }
    this.selectedCount = count;
  }

  removeMember(id: number) {
    HiLog.w(TAG, 'removeMember start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteMemberByGroupId',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          groupId: id.toString()
        }
        , () => {
          HiLog.w(TAG, 'removeMember end.');
        })
  }

  deleteEvent() {
    HiLog.w(TAG, 'deleteEvent start.');
    let ids: number[] = [];
    this.groupSelected.forEach((item) => {
      ids = ids.concat(item);
    });
    for (let item of ids) {
      this.removeMember(item)
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteGroupsById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: ids
      }, () => {
        HiLog.w(TAG, 'deleteEvent response');
        if (this.isSelectAll) {
          this.groupListDataSource.remove(0, this.groupList.length - 1);
        } else {
          let groupArr = this.groupList.filter((item) => {
            return this.groupSelected.every((selectedId) => {
              return item.group.id != selectedId;
            })
          });
          this.groupList = groupArr;
          this.groupListDataSource.refresh(this.groupList);
        }
        this.groupSelected = [];
        this.isSelectAll = false;
        this.selectedCount = 0;
        this.back();
        HiLog.w(TAG, 'deleteEvent end.');
      });
  }

  getDeleteDialogTitle(): Resource | string {
    let title: Resource | string;
    if (this.isSelectAll) {
      title = $r('app.string.delete_all_group_title');
    } else if (this.selectedCount === 1) {
      title = $r('app.string.delete_group');
    } else {
      title =  ResourceUtil.getPluralStringByResource($r('app.plural.delete_group_title'), this.selectedCount);
    }
    return title;
  }
}