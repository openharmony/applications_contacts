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
import GroupMemberDataSource from '../../model/bean/GroupMemberDataSource';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { CustomizedParams, GroupParams } from '../../model/type';
import { ContactVo, MemberInfo } from '../../model/bean/ContactVo';
import { GroupBean, GroupInfo } from '../../model/bean/GroupBean';
import { SelectContactParams } from '../../model/type/index';
import DotUtil from '../../util/DotUtil';

const TAG = 'GroupListDetailPresenter  ';
const CLICK_ADD_GROUP_MEMBER_EVENT = 'CLICK_ADD_GROUP_MEMBER_EVENT';

export default class GroupListDetailPresenter {
  public pathInfos?: NavPathStack;
  private static sInstance: GroupListDetailPresenter;
  public groupItemInfo: GroupBean = new GroupBean(-1, '', '', '', '', '', 0, 0, '')
  public groupName: string = ''
  public id: number = 0
  public groupListDataSource: GroupListDataSource = new GroupListDataSource();
  public groupMemberDataSource: GroupMemberDataSource = new GroupMemberDataSource()
  public groupList: Array<GroupInfo> = [];
  public memberList: Array<MemberInfo> = [];
  public groupMemberListLen: number = 0;
  public customParams: CustomizedParams = {};
  /**
   * callback of group detail query end
   */
  public updateGroupDetailInfoCallBack: UpdateGroupDetailInfo = {
    updateGroupDetail: (): void => {
    }
  };

  public static getInstance(): GroupListDetailPresenter {
    if (GroupListDetailPresenter.sInstance == null) {
      HiLog.w(TAG, 'Group getInstance!');
      GroupListDetailPresenter.sInstance = new GroupListDetailPresenter();
    }
    return GroupListDetailPresenter.sInstance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  async aboutToAppear() {
    HiLog.w(TAG, 'groupList aboutToAppear start!');
    this.groupName = this.pathInfos?.getParamByIndex(this.pathInfos.size() - 1) as string
    await this.queryGroupItemByName(this.groupName)
    this.groupList = this.groupListDataSource.getGroupData();
    this.queryAllGroupMember();
  }

  async setPageShow() {
    let addGroupContactData: string[] | undefined = AppStorage.get<Array<string>>('addGroupContactData');
    if (addGroupContactData !== undefined && addGroupContactData.length > 0) {
      HiLog.w(TAG, 'setPageShow!');
      this.addMemberInfo(addGroupContactData);
      AppStorage.setOrCreate<Array<string>>('addGroupContactData', []);
    }
    await this.queryGroupItemByName(this.groupName)
    this.queryAllGroupMember();
  }

  addMemberInfo(selectFavoriteIdList: string[]) {
    HiLog.w(TAG, 'addMemberInfo start.');
    let selectList: string[] = []
    selectFavoriteIdList.forEach((item) => {
      let ifMultiple = selectList.some((pushItem) => {
        return pushItem === item
      })
      let ifAdd = this.memberList.some((memberItem) => {
        return item === memberItem.member.rawContactId
      })
      if (!ifAdd && !ifMultiple) {
        selectList.push(item)
      }
    })
    if (!(ArrayUtil.isEmpty(selectList))) {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('updateGroupMemberList', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          selectMemberList: JSON.stringify(selectList),
          groupId: this.id.toString(),
        }, () => {
          AppStorage.SetOrCreate<Array<string>>('addGroupContactData', [])
          HiLog.w(TAG, 'addMemberList success.');
          this.queryAllGroupMember()
          HiLog.w(TAG, 'addMemberInfo end.');
        })
    }
  }

  queryAllGroupMember() {
    HiLog.w(TAG, 'queryAllGroupMember start.');
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
        if (this.memberList.length === 0) {
          this.groupMemberListLen = 0;
          this.refreshMemberList([]);
        } else {
          this.groupMemberListLen = this.memberList.length
          this.refreshMemberList(this.memberList)
        }
        this.updateGroupDetailInfoCallBack.updateGroupDetail();
        HiLog.w(TAG, `queryAllGroupMember end result len=${result?.length}`);
      })
  }

  refreshMemberList(memberList: MemberInfo[]) {
    HiLog.w(TAG, 'refreshFavoriteList start.');
    this.groupMemberDataSource.refresh(memberList);
  }


  queryGroupItemByName(groupName: string): Promise<void> {
    HiLog.w(TAG, 'queryGroupItemByName start.');
    return new Promise((resolve) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('queryGroupItemByName',
          {
            context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
            groupName
          }
          , (result: GroupBean) => {
            this.groupItemInfo = result
            this.id = this.groupItemInfo.id
            this.groupName = result.groupName
            resolve()
            HiLog.w(TAG, 'queryGroupItemByName end.');
          })

    })
  }

  resetData() {
    this.groupItemInfo = new GroupBean(-1, '', '', '', '', '', 0, 0, '')
    this.groupMemberListLen = 0
    AppStorage.setOrCreate<Array<string>>('addGroupContactData', []);
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
        , async () => {
          HiLog.w('this.queryGroupItemByName', 'groupName Change')
          await this.queryGroupItemByName(groupInfo.groupName)
          HiLog.w(TAG, 'renameGroup end.');
        })

  }

  removeMemberByContactId(contactId: number) {
    HiLog.w(TAG, 'removeMemberByContactId start.');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteMembers', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        groupId: this.id.toString(),
        contactId: [contactId]
      }, () => {
        this.queryAllGroupMember()
        HiLog.w(TAG, 'removeMemberByContactId end.');
      });

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

  toAddMember() {
    HiLog.w(TAG, 'toAddMember !!');
    // 联系人打点-手机群组-添加成员
    DotUtil.getInstance().contactDot(this.customParams, CLICK_ADD_GROUP_MEMBER_EVENT);

    const params: SelectContactParams = {
      pageTag: 'groupListDetail',
      groupId: this.id
    };

    DynamicLoader.getInstance().fire(DynamicLoader.ADD_FAVORITE_LIST_PAGE).then(() => {
      HiLog.i(TAG, `addFavoriteList24353464567---${this.pathInfos}`)
      this.pathInfos?.pushPathByName(DynamicLoader.ADD_FAVORITE_LIST_PAGE, params);
    });
  }

  toRemoveMember() {
    HiLog.w(TAG, 'toRemoveMember !!');
    DynamicLoader.getInstance().fire(DynamicLoader.REMOVE_MEMBER).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.REMOVE_MEMBER, this.id);
    });
  }

  toSendMessage() {
    HiLog.w(TAG, 'SendMessage !!');
    DynamicLoader.getInstance().fire(DynamicLoader.SELECT_MEMBER_SEND_MESSAGE).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.SELECT_MEMBER_SEND_MESSAGE, this.id);
    });
  }
}

export interface UpdateGroupDetailInfo {
  updateGroupDetail: () => void
}