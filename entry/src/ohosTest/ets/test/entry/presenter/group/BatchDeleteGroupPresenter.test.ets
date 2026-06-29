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
import { GroupBean, GroupInfo } from '../../../../../../main/ets/model/bean/GroupBean';
import BatchDeleteGroupPresenter from '../../../../../../main/ets/presenter/group/BatchDeleteGroupPresenter';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import dataShare from '@ohos.data.dataShare';
import { ContactRepository } from '../../../../../../../../feature/contact';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { ResourceUtil } from '../../../../../../main/ets/util/ResourceUtil';

export default function BatchDeleteGroupPresenterTest() {
  describe('BatchDeleteGroupPresenterTest', () => {

    let batchDeleteGroupPresenter: BatchDeleteGroupPresenter;

    beforeEach(() => {
      batchDeleteGroupPresenter = new BatchDeleteGroupPresenter();
    })

    it('BatchDeleteGroupPresenterTest_getInstance', 0, () => {
      expect(typeof BatchDeleteGroupPresenter.getInstance()).assertEqual(typeof batchDeleteGroupPresenter);
    })

    it('BatchDeleteGroupPresenterTest_back', 0, () => {
      batchDeleteGroupPresenter.pathInfos = new NavPathStack();
      batchDeleteGroupPresenter.pathInfos.pushPathByName('test/url', 'param');

      batchDeleteGroupPresenter.back();

      expect(batchDeleteGroupPresenter.pathInfos.size()).assertEqual(0);
    })

    it('BatchDeleteGroupPresenterTest_resetData', 0, () => {
      batchDeleteGroupPresenter.resetData();

      expect(batchDeleteGroupPresenter.isSelectAll).assertEqual(false);
      expect(batchDeleteGroupPresenter.selectedCount).assertEqual(0);
      expect(batchDeleteGroupPresenter.groupSelected.toString()).assertEqual([].toString());
    })

    it('BatchDeleteGroupPresenterTest_initGroupData', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeleteGroupPresenter.groupListDataSource, batchDeleteGroupPresenter.groupListDataSource.refresh);
      let groupList = [new GroupInfo()];
      groupList[0].checked = true;
      batchDeleteGroupPresenter.groupListDataSource.groupList = groupList;

      batchDeleteGroupPresenter.initGroupData();

      mocker.verify('refresh', [groupList]).once();

      mocker.clear(batchDeleteGroupPresenter.groupListDataSource);
    })

    it('BatchDeleteGroupPresenterTest_checkboxChanged_true', 0, () => {
      let groupList = [new GroupInfo()];
      groupList[0].checked = false;
      batchDeleteGroupPresenter.groupList = groupList;

      batchDeleteGroupPresenter.checkboxChanged(1, true, 0);

      expect(batchDeleteGroupPresenter.groupList[0].checked).assertTrue();
      expect(batchDeleteGroupPresenter.isSelectAll).assertTrue();
      expect(batchDeleteGroupPresenter.selectedCount).assertEqual(1);

      batchDeleteGroupPresenter.groupSelected.push(1);
      batchDeleteGroupPresenter.groupSelected.push(2);
      batchDeleteGroupPresenter.checkboxChanged(1, true, 0);
      expect(batchDeleteGroupPresenter.isSelectAll).assertTrue();
    })

    it('BatchDeleteGroupPresenterTest_checkboxChanged_false', 0, () => {
      let groupList = [new GroupInfo()];
      groupList[0].checked = true;
      batchDeleteGroupPresenter.groupList = groupList;
      batchDeleteGroupPresenter.groupSelected = [1];

      batchDeleteGroupPresenter.checkboxChanged(1, false, 0);

      expect(batchDeleteGroupPresenter.groupList[0].checked).assertFalse();
      expect(batchDeleteGroupPresenter.isSelectAll).assertFalse();
      expect(batchDeleteGroupPresenter.selectedCount).assertEqual(-1);

      batchDeleteGroupPresenter.groupSelected = [2];
      batchDeleteGroupPresenter.checkboxChanged(1, false, 0);
      expect(batchDeleteGroupPresenter.isSelectAll).assertFalse();
    })

    it('BatchDeleteGroupPresenterTest_removeMember', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteMemberByGroupId').afterAction(() => {
        result = true;
      });

      batchDeleteGroupPresenter.removeMember(0);

      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('BatchDeleteGroupPresenterTest_removeMember_callback', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      batchDeleteGroupPresenter.removeMember(0);

      expect(batchDeleteGroupPresenter.isSelectAll).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('BatchDeleteGroupPresenterTest_deleteEvent', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteGroupsById').afterAction(() => {
        result = true;
      });
      batchDeleteGroupPresenter.groupSelected = [1, 2, 3];
      mocker.mockFunc(batchDeleteGroupPresenter, batchDeleteGroupPresenter.removeMember);

      batchDeleteGroupPresenter.deleteEvent();

      mocker.verify('removeMember', [1]).once();
      mocker.verify('removeMember', [2]).once();
      mocker.verify('removeMember', [3]).once();
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(batchDeleteGroupPresenter);
    })

    it('BatchDeleteGroupPresenterTest_deleteEvent_callback_isSelectAll_true', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let result1 = false;
      let remove: Function = mocker.mockFunc(batchDeleteGroupPresenter.groupListDataSource, batchDeleteGroupPresenter.groupListDataSource.remove);
      when(remove)(0).afterAction(() => {
        result1 = true;
      });

      let back: Function = mocker.mockFunc(batchDeleteGroupPresenter, batchDeleteGroupPresenter.back);
      when(back)().afterAction(() => {
        expect(result).assertTrue();
        expect(result1).assertTrue();
      });

      batchDeleteGroupPresenter.isSelectAll = true;
      batchDeleteGroupPresenter.groupSelected = [1, 2, 3];
      mocker.mockFunc(batchDeleteGroupPresenter, batchDeleteGroupPresenter.removeMember);

      batchDeleteGroupPresenter.deleteEvent();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(batchDeleteGroupPresenter.groupListDataSource);
      mocker.clear(batchDeleteGroupPresenter);
      mocker.clear(ContactRepository.getInstance());
    })

    it('BatchDeleteGroupPresenterTest_deleteEvent_callback_isSelectAll_false', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let refresh: Function = mocker.mockFunc(batchDeleteGroupPresenter.groupListDataSource, batchDeleteGroupPresenter.groupListDataSource.refresh);
      when(refresh)(ArgumentMatchers.any).afterAction(() => {
        expect(result).assertTrue();
      });

      batchDeleteGroupPresenter.isSelectAll = false;
      batchDeleteGroupPresenter.groupSelected = [1];
      mocker.mockFunc(batchDeleteGroupPresenter, batchDeleteGroupPresenter.removeMember);

      let groupInfo1: GroupInfo = new GroupInfo(new GroupBean(0, '1', 'group', 'note', 'false', 'ring', 0, 0, '1', 'type'), 1, false);
      let groupInfo2: GroupInfo = new GroupInfo(new GroupBean(0, '1', 'group', 'note', 'false', 'ring', 0, 0, '3', 'type'), 1, false);

      batchDeleteGroupPresenter.groupList = [groupInfo1, groupInfo2];

      batchDeleteGroupPresenter.deleteEvent();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(batchDeleteGroupPresenter.groupListDataSource);
      mocker.clear(batchDeleteGroupPresenter);
      mocker.clear(ContactRepository.getInstance());
    })

    it('BatchDeleteGroupPresenterTest_getDeleteDialogTitle_01', 0, () => {
      const expectedTitle = $r("app.string.delete_all_group_title");
      batchDeleteGroupPresenter.isSelectAll = true;

      const title = batchDeleteGroupPresenter.getDeleteDialogTitle();

      expect(JSON.stringify(title)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchDeleteGroupPresenterTest_getDeleteDialogTitle_02', 0, () => {
      const expectedTitle = $r("app.string.delete_group");
      batchDeleteGroupPresenter.selectedCount = 1;

      const title = batchDeleteGroupPresenter.getDeleteDialogTitle();

      expect(JSON.stringify(title)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchDeleteGroupPresenterTest_getDeleteDialogTitle_03', 0, () => {
      const expectedTitle = ResourceUtil.getPluralStringByResource($r('app.plural.delete_group_title'), 0);

      const title = batchDeleteGroupPresenter.getDeleteDialogTitle();

      expect(JSON.stringify(title)).assertEqual(JSON.stringify(expectedTitle));
    })
  })
}