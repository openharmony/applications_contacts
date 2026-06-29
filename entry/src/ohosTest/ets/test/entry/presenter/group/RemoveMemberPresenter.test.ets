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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import RemoveMemberPresenter from '../../../../../../main/ets/presenter/group/RemoveMemberPresenter';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import { ContactRepository } from '../../../../../../../../feature/contact';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataShare from '@ohos.data.dataShare';
import { ContactVo, ContactVoName, MemberInfo } from '../../../../../../main/ets/model/bean/ContactVo';
import { AsyncCallback } from '@ohos.base';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ResourceUtil } from '../../../../../../../../entry/src/main/ets/util/ResourceUtil';

export default function RemoveMemberPresenterTest() {
  describe('RemoveMemberPresenterTest', () => {

    it('RemoveMemberPresenter_getInstance', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getInstance();
      expect(typeof rp).assertEqual(typeof RemoveMemberPresenter.getTestInstance());
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_back', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      rp.back();
      let num = rp.pathInfos.size();
      expect(num).assertEqual(0);
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_resetData', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      rp.resetData();
      expect(rp.isSelectAll).assertFalse();
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_initMemberData', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      mocker.mockFunc(rp, rp.queryAllGroupMember);
      rp.initMemberData();
      mocker.verify('queryAllGroupMember', ['']).once();
      // mocker.clear(rp);
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_queryAllGroupMember_callback', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

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

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      when(mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(result).assertTrue();
        });

      rp.queryAllGroupMember();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(rp.groupMemberDataSource);
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_deleteEvent_isSelectAll_false', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates, callback: AsyncCallback<number, void>): void => {
            result = true;
          }
        } as dataShare.DataShareHelper)));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      rp.isSelectAll = false;

      let member1: MemberInfo = new MemberInfo();
      member1.member = new ContactVo('0', '', '',  '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0', new ContactVoName(), 'roxy', '570977632', '2', '2', '');
      rp.memberList = [member1];
      rp.checkedStatus.add(Number(member1.member.contactId));

      let result1 = false;
      when(mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.remove))(ArgumentMatchers.any)
        .afterAction(() => {
          result1 = true;
        });

      let result2 = false;
      when(mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          result2 = true;
        });

      when(mocker.mockFunc(rp, rp.back))()
        .afterAction(() => {
          expect(result).assertTrue();
          expect(result1).assertFalse();
          expect(result2).assertTrue();
          expect(rp.isSelectAll).assertFalse();
          expect(rp.selectedCount).assertEqual(0);
          expect(JSON.stringify(rp.memberList)).assertEqual(JSON.stringify([member1]));
        });

      rp.deleteEvent();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(rp);
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_deleteEvent_isSelectAll_true', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates, callback: AsyncCallback<number, void>): void => {
            result = true;
          }
        } as dataShare.DataShareHelper)));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      rp.isSelectAll = true;

      let member1: MemberInfo = new MemberInfo();
      member1.member = new ContactVo('0', '', '',  '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0', new ContactVoName(), 'roxy', '570977632', '2', '2', '');
      rp.memberList = [member1];
      rp.checkedStatus.add(Number(member1.member.contactId));

      let result1 = false;
      when(mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.remove))(ArgumentMatchers.any)
        .afterAction(() => {
          result1 = true;
        });

      when(mocker.mockFunc(rp, rp.back))()
        .afterAction(() => {
          expect(result).assertTrue();
          expect(result1).assertTrue();
          expect(rp.isSelectAll).assertFalse();
          expect(rp.selectedCount).assertEqual(0);
          expect(JSON.stringify(rp.memberList)).assertEqual(JSON.stringify([member1]));
        });

      rp.deleteEvent();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(rp);
      mocker.clear(ResourceUtil);
    })

    it('RemoveMemberPresenter_checkAll_true', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      let member1: MemberInfo = new MemberInfo();
      member1.member = new ContactVo('0', '', '',  '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0', new ContactVoName(), 'roxy', '570977632', '2', '2', '');
      rp.memberList = [member1];
      rp.checkedStatus.add(Number(member1.member.contactId));
      rp.selectedCount = 1;
      rp.isSelectAll = true;

      mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.refresh);
      rp.checkAll();

      expect(rp.selectedCount).assertEqual(0);
      mocker.clear(ResourceUtil);
      mocker.clear(rp.groupMemberDataSource);
    })

    it('RemoveMemberPresenter_checkAll_false', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      let rp: RemoveMemberPresenter = RemoveMemberPresenter.getTestInstance();
      let member1: MemberInfo = new MemberInfo();
      member1.member = new ContactVo('0', '', '',  '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0', new ContactVoName(), 'roxy', '570977632', '2', '2', '');
      rp.memberList = [member1];
      rp.isSelectAll = false;

      mocker.mockFunc(rp.groupMemberDataSource, rp.groupMemberDataSource.refresh);

      rp.checkAll();

      expect(rp.selectedCount).assertEqual(1);
      mocker.clear(ResourceUtil);
      mocker.clear(rp.groupMemberDataSource)
    })
  })
}