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

import { HiLog } from '../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import GroupMemberDataSource from '../../model/bean/GroupMemberDataSource';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { ContactVo, MemberInfo } from '../../model/bean/ContactVo';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../data/EmitterConstant';
import AccessibilityUtil from '../../util/AccessibilityUtil';

const TAG = 'RemoveMemberPresenter';

export default class RemoveMemberPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static mPresenter: RemoveMemberPresenter;
  public groupMemberDataSource: GroupMemberDataSource = new GroupMemberDataSource()
  public memberList: Array<MemberInfo> = [];
  public isSelectAll: boolean = false;
  public selectedCount: number = 0;
  public id: number = 0;
  public checkedStatus: Set<number> = new Set<number>();
  public sceillOnlenth: number = 0;

  public static getTestInstance(): RemoveMemberPresenter {
    return new RemoveMemberPresenter();
  }

  static getInstance() {
    if (RemoveMemberPresenter.mPresenter == null) {
      RemoveMemberPresenter.mPresenter = new RemoveMemberPresenter();
    }
    return RemoveMemberPresenter.mPresenter;
  }

  back() {
    this.pathInfos.pop();
  }

  resetData() {
    this.isSelectAll = false;
    this.selectedCount = 0;
  }

  sendSelectedEvent(id: number | null) {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_DELETE_MEMBER_ITEM_CHECKED,
    };
    let eventData: emitter.EventData = {
      data: {
        'id': id
      }
    };
    emitter.emit(innerEvent, eventData);
  }

  initMemberData() {
    this.id = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as number;
    this.queryAllGroupMember()
  }

  queryAllGroupMember() {
    HiLog.i(TAG, 'queryAllGroupMember start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('queryAllGroupMember', {
        groupId: this.id.toString(),
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      }, (result: ContactVo[]) => {
        this.memberList = [];
        for (let item of result) {
          this.memberList.push({
            member: item, checked: false
          })
        }
        this.groupMemberDataSource.refresh(this.memberList);
        HiLog.i(TAG, 'queryAllGroupMember end.');
      })
  }

  itemOnClick(item: ContactVo, index: number) {
    HiLog.w(TAG, 'contactId: ' + item.contactId + ',  index: ' + index);
    let contactId: number = Number(item.contactId);
    if (this.checkedStatus.has(contactId)) {
      this.checkedStatus.delete(contactId);
    } else {
      this.checkedStatus.add(contactId);
    }
    this.sendSelectedEvent(contactId);
    this.selectedCount = this.checkedStatus.size;
    if (this.selectedCount === this.memberList.length) {
      this.isSelectAll = true;
    } else {
      this.isSelectAll = false;
    }
  }

  deleteEvent() {
    HiLog.i(TAG, 'deleteEvent start.');
    let ids: number[] = [];
    this.memberList.forEach((member) => {
      let contactId: number = Number(member.member.contactId);
      if (this.checkedStatus.has(contactId)) {
        ids.push(contactId);
      }
    })
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteMembers', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        groupId: this.id.toString(),
        contactId: ids
      }, () => {
        HiLog.i(TAG, 'deleteEvent response');
        if (this.isSelectAll) {
          this.groupMemberDataSource.remove(0, this.memberList.length - 1);
        } else {
          let groupArr = this.memberList.filter((item) => {
            let contactId: number = Number(item.member.contactId);
            return !this.checkedStatus.has(contactId);
          });
          this.memberList = groupArr;
          this.groupMemberDataSource.refresh(this.memberList);
        }
        this.isSelectAll = false;
        this.selectedCount = 0;
        this.back();
      });
  }

  checkAll() {
    let contactsTotal = this.memberList.length;
    HiLog.w(TAG, `checkAll start, selectedCount: ${this.selectedCount}, contactsTotal: ${contactsTotal}`);
    if (this.selectedCount != 0 && this.selectedCount === contactsTotal) {
      this.checkedStatus.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, contactsTotal);
    } else {
      this.memberList.forEach((member): void => {
        let contactId: number = Number(member.member.contactId);
        this.checkedStatus.add(contactId);
      });
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, contactsTotal);
    }
    this.selectedCount = this.checkedStatus.size;
    this.sendSelectedEvent(null);
  }
}