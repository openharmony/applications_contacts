/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactRepository } from '../../../../../../../../feature/contact';
import { MemberInfo } from '../../../../../../main/ets/model/bean/ContactVo';
import { GroupBean, GroupInfo } from '../../../../../../main/ets/model/bean/GroupBean';
import { GroupParams, SelectContactParams } from '../../../../../../main/ets/model/type';
import GroupListDetailPresenter from '../../../../../../main/ets/presenter/group/GroupListDetailPresenter';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { DynamicLoader } from '../../../../../../../../common/src/main/ets/util/DynamicLoader';

export default function GroupListDetailPresenterTest() {
  describe('GroupListDetailPresenterTest', () => {

    let groupListDetailPresenter: GroupListDetailPresenter;

    beforeEach(() => {
      AppStorage.clear();
      groupListDetailPresenter = new GroupListDetailPresenter();
    })

    it('GroupListDetailPresenterTest_getInstance', 0, () => {
      expect(typeof groupListDetailPresenter).assertEqual(typeof GroupListDetailPresenter.getInstance());
    })

    it('GroupListDetailPresenterTest_aboutToAppear', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryGroupItemByName);
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryAllGroupMember);
      groupListDetailPresenter.pathInfos = new NavPathStack();
      groupListDetailPresenter.pathInfos?.pushPathByName('test/url', 'param');

      await groupListDetailPresenter.aboutToAppear();

      expect(groupListDetailPresenter.groupName).assertEqual('param');
      mocker.verify('queryGroupItemByName', ['param']).once();
      expect(JSON.stringify(groupListDetailPresenter.groupList))
        .assertEqual(JSON.stringify(groupListDetailPresenter.groupListDataSource.getGroupList()));
      mocker.verify('queryAllGroupMember', []).once();
      mocker.clear(groupListDetailPresenter);
    })

    it('GroupListDetailPresenterTest_aboutToAppear_pathInfos_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryGroupItemByName);
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryAllGroupMember);

      await groupListDetailPresenter.aboutToAppear();

      mocker.verify('queryGroupItemByName', ['']).once();
      mocker.verify('queryAllGroupMember', []).once();

      mocker.clear(groupListDetailPresenter);
    })

    it('GroupListDetailPresenterTest_setPageShow', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.addMemberInfo);
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryGroupItemByName);
      mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryAllGroupMember);
      AppStorage.setOrCreate<Array<string>>('addGroupContactData', ['test']);

      await groupListDetailPresenter.setPageShow();

      mocker.verify('addMemberInfo', [['test']]).once();
      expect(AppStorage.get<Array<string>>('addGroupContactData')?.toString()).assertEqual([].toString());
      mocker.verify('queryGroupItemByName', ['']).once();
      mocker.verify('queryAllGroupMember', []).once();

      mocker.clear(groupListDetailPresenter);
    })

    it('GroupListDetailPresenterTest_addMemberInfo_return1', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);

      groupListDetailPresenter.addMemberInfo([]);

      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_addMemberInfo_return2', 0, () => {
      let member1: MemberInfo = new MemberInfo();
      member1.member.rawContactId = 'test';
      groupListDetailPresenter.memberList = [member1];

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);

      groupListDetailPresenter.addMemberInfo(['test']);

      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_addMemberInfo', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('updateGroupMemberList').afterAction(() => {
        result = true;
      });
      GroupListDetailPresenter.getInstance().addMemberInfo(['test']);
      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_queryAllGroupMember', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('queryAllGroupMember').afterAction(() => {
        result = true;
      });

      groupListDetailPresenter.queryAllGroupMember();
      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_queryAllGroupMember_callback', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      ContactRepository.getInstance().init(context)
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let refreshMemberList: Function = mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.refreshMemberList);
      when(refreshMemberList)().afterAction(() => {
        expect(result).assertTrue();
        expect(groupListDetailPresenter.groupMemberListLen).assertEqual(1);
      });

      groupListDetailPresenter.queryAllGroupMember();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('GroupListDetailPresenterTest_refreshMemberList', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(groupListDetailPresenter.groupMemberDataSource, groupListDetailPresenter.groupMemberDataSource.refresh);

      groupListDetailPresenter.refreshMemberList([]);

      mocker.verify('refresh', []).once();
      mocker.clear(groupListDetailPresenter.groupMemberDataSource);
    })

    it('GroupListDetailPresenterTest_queryGroupItemByName', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('queryGroupItemByName').afterAction(() => {
        result = true;
      });

      groupListDetailPresenter.queryGroupItemByName('test');

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_queryGroupItemByName_callback', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      ContactRepository.getInstance().init(context)
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      groupListDetailPresenter.queryGroupItemByName('test').then(() => {
        expect(result).assertTrue();
        expect(groupListDetailPresenter.groupName).assertEqual('xxx');
        expect(groupListDetailPresenter.id).assertEqual(0);
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('GroupListDetailPresenterTest_resetData', 0, () => {
      groupListDetailPresenter.resetData();
      expect(0).assertEqual(groupListDetailPresenter.groupMemberListLen)
    })

    it('GroupListDetailPresenterTest_renameGroup', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('renameGroup').afterAction(() => {
        result = true;
      });
      const groupInfo: GroupParams = {
        groupName: ''
      };

      groupListDetailPresenter.renameGroup(groupInfo);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_renameGroup_callback', 0, () => {
      let groupInfo: GroupParams = {
        groupName: 'group'
      };

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      ContactRepository.getInstance().init(context)
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let queryGroupItemByName: Function = mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryGroupItemByName);
      when(queryGroupItemByName)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));

      groupListDetailPresenter.renameGroup(groupInfo);

      expect(groupListDetailPresenter.groupName).assertEqual('');
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(groupListDetailPresenter);
    })

    it('GroupListDetailPresenterTest_removeMemberByContactId', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteMembers').afterAction(() => {
        result = true;
      });

      groupListDetailPresenter.removeMemberByContactId(0);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_removeMemberByContactId_callback', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      ContactRepository.getInstance().init(context)
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let queryAllGroupMember: Function = mocker.mockFunc(groupListDetailPresenter, groupListDetailPresenter.queryAllGroupMember);
      when(queryAllGroupMember)().afterAction(() => {
        expect(result).assertTrue();
      });

      groupListDetailPresenter.removeMemberByContactId(0);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(groupListDetailPresenter);
    })

    it('GroupListDetailPresenterTest_removeMember', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteMemberByGroupID').afterAction(() => {
        result = true;
      });

      groupListDetailPresenter.removeMember(0);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_removeMember_callback', 0, () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;


      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      groupListDetailPresenter.removeMember(0);

      expect(groupListDetailPresenter.id).assertEqual(0);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('GroupListDetailPresenterTest_removeGroup', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('removeGroup').afterAction(() => {
        result = true;
      });

      groupListDetailPresenter.removeGroup(0);

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('GroupListDetailPresenterTest_removeGroup_callback', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      ContactRepository.getInstance().init(context)
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      groupListDetailPresenter.removeGroup(-1);

      expect(groupListDetailPresenter.id).assertEqual(0);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListDetailPresenterTest_back', 0, () => {
      groupListDetailPresenter.pathInfos = new NavPathStack();
      groupListDetailPresenter.pathInfos?.pushPathByName('test/url', 'param');

      groupListDetailPresenter.back();

      expect(groupListDetailPresenter.pathInfos?.size()).assertEqual(0);
    })

    it('GroupListDetailPresenterTest_back_pathInfos_null', 0, () => {
      groupListDetailPresenter.back();

      expect(groupListDetailPresenter.groupMemberListLen).assertEqual(0);
    })

    it('GroupListDetailPresenterTest_ifGroupExist', 0, () => {
      let groupInfo = new GroupInfo();
      groupInfo.group = new GroupBean(123, "23", "3434", "23", "1", "tgwe", 23, 5, "23", "1");
      groupInfo.group.groupName = 'test';
      groupListDetailPresenter.groupList = [groupInfo];

      const ifExist = groupListDetailPresenter.ifGroupExist('test');

      expect(ifExist).assertTrue();
    })

    it('GroupListDetailPresenterTest_toAddMember', 0, async () => {
      groupListDetailPresenter.pathInfos = new NavPathStack();
      const params: SelectContactParams = {
        pageTag: 'groupListDetail',
        groupId: groupListDetailPresenter.id
      };

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.ADD_FAVORITE_LIST_PAGE).afterReturn(new Promise<void>((resolve: Function, reject: Function) => {
        resolve(groupListDetailPresenter.pathInfos?.pushPathByName('addFavoriteList', params));
      }))
      groupListDetailPresenter.toAddMember();
      expect(JSON.stringify(groupListDetailPresenter.pathInfos?.getParamByName('addFavoriteList')))
        .assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('GroupListDetailPresenterTest_toRemoveMember', 0, () => {
      let mocker: MockKit = new MockKit();
      groupListDetailPresenter.pathInfos = new NavPathStack();

      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.REMOVE_MEMBER).afterReturn(new Promise<void> ((resolve: Function) =>{
        resolve(groupListDetailPresenter.pathInfos?.pushPathByName(DynamicLoader.REMOVE_MEMBER, groupListDetailPresenter.id));
      }));
      groupListDetailPresenter.toRemoveMember();

      expect(groupListDetailPresenter.pathInfos?.getParamByName(DynamicLoader.REMOVE_MEMBER).toString())
        .assertEqual(groupListDetailPresenter.id.toString());
      mocker.clear(DynamicLoader.getInstance());
    })

    it('GroupListDetailPresenterTest_toSendMessage', 0, () => {
      let mocker: MockKit = new MockKit();
      groupListDetailPresenter.pathInfos = new NavPathStack();

      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.SELECT_MEMBER_SEND_MESSAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(groupListDetailPresenter.pathInfos?.pushPathByName(DynamicLoader.SELECT_MEMBER_SEND_MESSAGE, groupListDetailPresenter.id));
      }))
      groupListDetailPresenter.toSendMessage();

      expect(groupListDetailPresenter.pathInfos?.getParamByName(DynamicLoader.SELECT_MEMBER_SEND_MESSAGE).toString())
        .assertEqual(groupListDetailPresenter.id.toString());
      mocker.clear(DynamicLoader.getInstance());
    })
  })
}