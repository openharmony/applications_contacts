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
import { PageLimit } from '../../../../../main/ets/model/type';
import { LimitRefreshDataUtil } from '../../../../../main/ets/util/LimitRefreshDataUtil';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../testability/TestAbility';
import data_preferences from '@ohos.data.preferences';
import { CallLogRepository } from '../../../../../../../feature/call';
import { CallLogService } from '../../../../../../../feature/call/src/main/ets/CallLogService';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ArrayUtil, HiLog, sharedPreferencesUtils } from '../../../../../../../common';


export default function LimitRefreshDataUtilTest() {
  describe('LimitRefreshDataUtilTest', () => {

    let limitDataRefresh: LimitRefreshDataUtil<PageLimit, number>;
    const TAG: string = 'LimitRefreshDataUtil';

    beforeEach(() => {
      limitDataRefresh = new LimitRefreshDataUtil('getAllCalls', (resultPage: number, limit: number, result: number) => true);
    })

    it('LimitRefreshDataUtilTest_constructor_noTask', 0, () => {
      const task = '     ';
      let limitDataRefresh = new LimitRefreshDataUtil(task, (resultPage: number, limit: number, result: number) => true);
      expect(JSON.parse(JSON.stringify(limitDataRefresh))['task']).not().assertEqual(task);
    })

    it('LimitRefreshDataUtilTest_setTaskForeground_return', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(limitDataRefresh, limitDataRefresh.requestItem);
      limitDataRefresh.setTaskForeground(true);
      mocker.verify('requestItem', []).never();

      mocker.clear(limitDataRefresh);
    })

    it('LimitRefreshDataUtilTest_setTaskForeground_if_if', 0, () => {
      limitDataRefresh.setForeground(false);

      limitDataRefresh.setPause(true);

      limitDataRefresh.setTaskId(1);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(limitDataRefresh, limitDataRefresh.requestItem);
      limitDataRefresh.setTaskForeground(true);
      mocker.verify('requestItem', []).once();

      mocker.clear(limitDataRefresh);
    })

    it('LimitRefreshDataUtilTest_setTaskForeground_if_else', 0, () => {
      limitDataRefresh.setForeground(false);

      limitDataRefresh.setPause(true);

      limitDataRefresh.setPage(1);
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(limitDataRefresh, limitDataRefresh.queryAll);

      limitDataRefresh.setTaskForeground(true);

      mocker.verify('queryAll', []).once();

      mocker.clear(limitDataRefresh);
    })

    it('LimitRefreshDataUtilTest_setTaskForeground_if_not_if_no_else', 0, () => {
      limitDataRefresh.setForeground(false);

      limitDataRefresh.setPause(true);

      limitDataRefresh.setPage(0);
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(limitDataRefresh, limitDataRefresh.queryAll);

      limitDataRefresh.setTaskForeground(true);

      mocker.verify('queryAll', []).never();

      mocker.clear(limitDataRefresh);
    })

    it('LimitRefreshDataUtilTest_getResultCallBack', 0, () => {
      let result: boolean = limitDataRefresh.getResultCallBack()(1, 1, 1);
      expect(result).assertTrue();
    })

    it('LimitRefreshDataUtilTest_setPrepareCallBack', 0, () => {
      let callback = () => {
      };
      limitDataRefresh.setPrepareCallBack(callback);
      expect(limitDataRefresh.getTask()).assertEqual('getAllCalls');
    })

    it('LimitRefreshDataUtilTest_requestItem_01', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(limitDataRefresh, limitDataRefresh.queryAll);

      limitDataRefresh.setTask('');
      limitDataRefresh.requestItem();
      mocker.verify('queryAll', []).never();

      limitDataRefresh.setTask('1');
      limitDataRefresh.setTaskId(1);
      limitDataRefresh.requestItem();
      mocker.verify('queryAll', []).once();

      mocker.clear(limitDataRefresh);
    })

    it('LimitRefreshDataUtilTest_requestItem_02', 0, () => {
      limitDataRefresh.setPage(1);
      limitDataRefresh.requestItem();

      expect(limitDataRefresh.getTaskId()).not().assertEqual(-1);
    })

    it('LimitRefreshDataUtilTest_requestItem_isForeground_false', 0, () => {
      limitDataRefresh.setTaskForeground(false);
      limitDataRefresh.setPage(1);
      limitDataRefresh.requestItem();

      expect(limitDataRefresh.getTaskId()).not().assertEqual(-1);
    })

    it('LimitRefreshDataUtilTest_queryAll_return', 0, () => {
      limitDataRefresh.setPause(true);

      limitDataRefresh.queryAll();

      expect(limitDataRefresh.getPause()).assertTrue();
    })

    it('LimitRefreshDataUtilTest_queryAll_if_if_return', 0, () => {
      limitDataRefresh = new LimitRefreshDataUtil('findByNumberIn', (resultPage: number, limit: number, result: number) => false);
      limitDataRefresh.setPage(1);
      limitDataRefresh.setTaskId(1);

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(limitDataRefresh, limitDataRefresh.requestItem);
      mocker.mockFunc(limitDataRefresh, limitDataRefresh.getNextPage);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      CallLogRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(ArrayUtil, ArrayUtil.getLimitForSession))(1).afterReturn(0);

      limitDataRefresh.queryAll();

      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        mocker.verify('requestItem', []).once();
        mocker.verify('getNextPage', []).never();
      })

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ArrayUtil);
      mocker.clear(limitDataRefresh);
      mocker.clear(HiLog);
    })

    it('LimitRefreshDataUtilTest_queryAll_if_isForeground_true', 0, () => {
      limitDataRefresh = new LimitRefreshDataUtil('findByNumberIn', (resultPage: number, limit: number, result: number) => false);
      limitDataRefresh.setPage(1);
      limitDataRefresh.setTaskId(-1);
      limitDataRefresh.setForeground(true);

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(limitDataRefresh, limitDataRefresh.requestItem);
      when(mocker.mockFunc(limitDataRefresh, limitDataRefresh.getNextPage))(1).afterAction(() => {
        expect(limitDataRefresh.getRefreshedPages()[0]).assertEqual(1);
        return 0;
      });

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isCallSettingDataChangeGroupByValue')
        .afterReturn(new Promise<string>(resolve => resolve('contacts')));

      mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance().setMergeRule);

      let updatePreCallLog: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .updatePreCallLog);
      when(updatePreCallLog)(ArgumentMatchers.any).afterReturn([]);

      let mergeCallLogs: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .mergeCallLogs);
      when(mergeCallLogs)(ArgumentMatchers.any).afterReturn([]);

      let mergeMissedCalls: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .mergeMissedCalls);
      when(mergeMissedCalls)(ArgumentMatchers.any).afterReturn([]);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      CallLogRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            close: () => {
            },
            goToFirstRow: () => true,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(ArrayUtil, ArrayUtil.getLimitForSession))(1).afterReturn(0);

      limitDataRefresh.queryAll();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ArrayUtil);
      mocker.clear(limitDataRefresh);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CallLogService.getInstance());
    })

    it('LimitRefreshDataUtilTest_queryAll_if_isForeground_false', 0, () => {
      limitDataRefresh = new LimitRefreshDataUtil('findByNumberIn', (resultPage: number, limit: number, result: number) => false);
      limitDataRefresh.setPage(1);
      limitDataRefresh.setTaskId(-1);
      limitDataRefresh.setForeground(false);

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(limitDataRefresh, limitDataRefresh.requestItem);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isCallSettingDataChangeGroupByValue')
        .afterReturn(new Promise<string>(resolve => resolve('contacts')));

      mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance().setMergeRule);

      let updatePreCallLog: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .updatePreCallLog);
      when(updatePreCallLog)(ArgumentMatchers.any).afterReturn([]);

      let mergeCallLogs: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .mergeCallLogs);
      when(mergeCallLogs)(ArgumentMatchers.any).afterReturn([]);

      let mergeMissedCalls: Function = mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance()
        .mergeMissedCalls);
      when(mergeMissedCalls)(ArgumentMatchers.any).afterReturn([]);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      CallLogRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            close: () => {
            },
            goToFirstRow: () => true,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(ArrayUtil, ArrayUtil.getLimitForSession))(1).afterReturn(0);

      limitDataRefresh.queryAll();
      mocker.verify('getLimitForSession', [1]).once();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ArrayUtil);
      mocker.clear(limitDataRefresh);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CallLogService.getInstance());
    })

    it('LimitRefreshDataUtilTest_queryAll_else', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(ArrayUtil, ArrayUtil.getLimitForSession))(1).afterReturn(1);
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('accountType')
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      limitDataRefresh = new LimitRefreshDataUtil('getAllContact', (resultPage: number, limit: number, result: number) => true);
      limitDataRefresh.setPage(1);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
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

      let getNextPage: Function = mocker.mockFunc(limitDataRefresh, limitDataRefresh.getNextPage);
      when(getNextPage)(1).afterAction(() => {
        expect(result).assertTrue();
      });

      limitDataRefresh.queryAll();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ArrayUtil);
      mocker.clear(limitDataRefresh);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ContactRepository.getInstance());
    })

    it('LimitRefreshDataUtilTest_queryPage', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)(limitDataRefresh.getTask()).afterAction(() => {
        result = true;
      });
      limitDataRefresh.queryPage(1, 50);
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('LimitRefreshDataUtilTest_queryPage_sendRequest_if', 0, () => {
      let mocker: MockKit = new MockKit();

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
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


      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('isCallSettingDataChangeGroupByValue')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve('contacts')));

      limitDataRefresh.queryPage(1, 50, (isEnd: boolean) => {
        expect(isEnd).assertTrue();
        expect(result).assertFalse();
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(sharedPreferencesUtils);
    })

    it('LimitRefreshDataUtilTest_queryPage_sendRequest_if_noCallback', 0, () => {
      let mocker: MockKit = new MockKit();

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
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


      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('isCallSettingDataChangeGroupByValue')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve('contacts')));

      limitDataRefresh.queryPage(1, 50);
      expect(limitDataRefresh.getPause()).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(sharedPreferencesUtils);
    })

    it('LimitRefreshDataUtilTest_queryPage_sendRequest_if_actionData', 0, () => {
      let mocker: MockKit = new MockKit();

      let actionData: PageLimit = {
        page: 1, limit: 1
      };

      limitDataRefresh = new LimitRefreshDataUtil('getAllCalls', (resultPage: number, limit: number, result: number) => true, actionData);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('getAllCalls')
        .afterReturn(new Promise<void>(resolve => resolve()));

      limitDataRefresh.queryPage(1, 50, (isEnd: boolean) => {
      });

      expect(limitDataRefresh.getPause()).assertFalse();

      mocker.clear(workerWrapper);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(sharedPreferencesUtils);
    })

    it('LimitRefreshDataUtilTest_getNextPage_01', 0, () => {
      let page = limitDataRefresh.getNextPage(1);
      expect(page).assertEqual(limitDataRefresh.getCurrentPage());
    })

    it('LimitRefreshDataUtilTest_getNextPage_02', 0, () => {
      limitDataRefresh.setRefreshedPages([1, 2, 3]);
      limitDataRefresh.setCurrentPage(3);
      let page = limitDataRefresh.getNextPage(1);
      expect(page).assertEqual(4);
    })

    it('LimitRefreshDataUtilTest_getNextPage_03', 0, () => {
      limitDataRefresh.setRefreshedPages([1, 2, 3]);
      limitDataRefresh.setCurrentPage(3);
      let page = limitDataRefresh.getNextPage(2);
      expect(page).assertEqual(4);
    })

    it('LimitRefreshDataUtilTest_getNextPage_04', 0, () => {
      limitDataRefresh.setRefreshedPages([0, 1, 2, 3]);
      limitDataRefresh.setCurrentPage(3);
      let page = limitDataRefresh.getNextPage(0);
      expect(page).assertEqual(4);
    })

    it('LimitRefreshDataUtilTest_getRefreshedPages', 0, () => {
      let numbers: number[] = [1, 2]
      limitDataRefresh.setRefreshedPages(numbers);
      let page = limitDataRefresh.getRefreshedPages();
      expect(page).assertEqual(numbers)
    })

    it('LimitRefreshDataUtilTest_release', 0, () => {
      limitDataRefresh.setTaskId(1);
      limitDataRefresh.release();
      expect(limitDataRefresh.getTaskId()).assertEqual(-1);
    })
  })
}