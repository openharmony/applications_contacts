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
import { describe, it, expect, MockKit, when, beforeEach } from '@ohos/hypium';
import { MessageEvents } from '@ohos.worker';
import { WorkerMessage } from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { DataWorkerTask } from '../../../../../../main/ets/workers/DataWorkerTask';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { CallLogRepository } from '../../../../../../../../feature/call';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import WorkerTask from '../../../../../../main/ets/workers/base/WorkerTask';

export default function WorkerTaskTest() {
  describe('WorkerTaskTest', () => {
    let workerTask:WorkerTask;

    beforeEach(()=>{
      workerTask = DataWorkerTask.getInstance();
    })

    it("WorkerTaskTest_onmessage_close", 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker:MockKit = new MockKit();
      let data: WorkerMessage = {
        request: 'close',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "context": context
        }
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      };
      workerTask.closed = false;
      let worker:Function=mocker.mockFunc(workerTask,workerTask.workerPort?.close);
      when(worker)(data.request).afterAction(()=>{
        workerTask.closed = true;
        throw  new Error('error')
      });

      workerTask.onmessage(message);
      expect(workerTask.closed).assertTrue();
      mocker.clear(workerTask);
    })

    it('WorkerTaskTest_onmessage_init', 0, () => {
      let data: WorkerMessage = {
        request: 'init',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        }
      };

      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      }

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);

      workerTask.onmessage(message)

      mocker.verify('set', [ContactsGlobalThisHelper.UIContextName, data.param?.context]).once();

      workerTask.closed = true;
      workerTask.onmessage(message)

      mocker.verify('set', [ContactsGlobalThisHelper.UIContextName, data.param?.context]).times(2);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      workerTask.closed = false;
    })

    it('WorkerTaskTest_onmessage_init_param_undefined', 0, () => {
      let data: WorkerMessage = {
        request: 'init',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: undefined
      };

      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      }

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);

      workerTask.onmessage(message)

      mocker.verify('set', [ContactsGlobalThisHelper.UIContextName, data.param?.context]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it("WorkerTaskTest_OnMessage_UpdateTimeFormat", 0, () => {
      let data: WorkerMessage = {
        request: 'updateTimeFormat',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "timeFormat": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        }
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      }
      //声明方法
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      workerTask.onmessage(message);
      mocker.verify('set', [ContactsGlobalThisHelper.TimeFormatName, data.param?.timeFormat]).once();

      workerTask.closed = true;
      workerTask.onmessage(message);
      mocker.verify('set', [ContactsGlobalThisHelper.TimeFormatName, data.param?.timeFormat]).times(2);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      workerTask.closed = false;
    })

    it("WorkerTaskTest_OnMessage_UpdateTimeFormat_param_undefined", 0, () => {
      let data: WorkerMessage = {
        request: 'updateTimeFormat',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: undefined
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      }
      //声明方法
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      workerTask.onmessage(message);
      mocker.verify('set', [ContactsGlobalThisHelper.TimeFormatName, data.param?.timeFormat]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('WorkerTaskTest_onmessage_else_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker:MockKit = new MockKit();
      let data: WorkerMessage = {
        request: 'findByNumberIn',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "context": context
        }
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      };
      let result = false;
      workerTask.closed = true;

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                expect(result).assertTrue();
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      workerTask.onmessage(message);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('WorkerTaskTest_onmessage_else', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      let data: WorkerMessage = {
        request: 'findByNumberIn',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "context": context
        }
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      };
      let result = false;
      workerTask.closed = false;

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                expect(result).assertTrue();
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      workerTask.onmessage(message);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('WorkerTaskTest_onmessage_close_error', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      let data: WorkerMessage = {
        request: 'findByNumberIn',
        callBackId: -1,
        type: WorkerType.DataWorker,
        param: {
          "context": context
        }
      };
      let message: MessageEvents = {
        "data": data,
        "type": "1",
        "timeStamp": 123324,
      };
      let result = false;
      workerTask.closed = false;

      let runInWorker: Function = mocker.mockFunc(workerTask, workerTask.runInWorker);
      when(runInWorker)(data.request).afterAction(()=>{
        result = true;
        throw  new Error('error')
      });

      workerTask.onmessage(message);
      expect(result).assertTrue();
      mocker.clear(workerTask);
    })

  })
}
