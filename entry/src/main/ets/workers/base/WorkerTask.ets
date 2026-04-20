/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { WorkerMessage } from './WorkerWrapper'
import { ThreadWorkerGlobalScope, MessageEvents } from '@ohos.worker';
import { HiLog } from '../../../../../../common'
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper'
import common from '@ohos.app.ability.common';
import LooseObject from '../../model/type/LooseObject';
import { UtilAuditLog } from '../../../../../../common/src/main/ets/util/AuditLogUtils';

const TAG = 'WorkerTask'

/*
 * WorkerTask
 *
 * Work sub thread task
 */
export abstract class WorkerTask {
  public workerPort?: ThreadWorkerGlobalScope
  public closed: boolean = false;

  constructor (workerPort?: ThreadWorkerGlobalScope) {
    HiLog.i(TAG, `WorkerTask constructor`)
    this.workerPort = workerPort;
  }

  /**
   * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
   * The event handler is executed in the worker thread.
   *
   * @param e message data
   */
  public onmessage (message: MessageEvents) {
    try {
      let data = message.data as WorkerMessage
      HiLog.i(TAG, `onmessage ${data.request} time:${(new Date()).valueOf()}`)
      if (data.request == 'close') {
        this.workerPort?.close();
        this.closed = true;
      } else if (data.request == 'init') {
        ContactsGlobalThisHelper.GetGlobalThis()
          .set<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName, data.param?.context)
        if (this.closed) {
          HiLog.w(TAG, 'init worker closed');
          return;
        }
        this.workerPort?.postMessage(data);
      } else if (data.request === 'updateTimeFormat') {
        HiLog.i(TAG, 'updateTimeFormat: ' + data.param?.timeFormat);
        ContactsGlobalThisHelper.GetGlobalThis()
          .set<string>(ContactsGlobalThisHelper.TimeFormatName, data.param?.timeFormat);
        if (this.closed) {
          HiLog.w(TAG, 'updateTimeFormat worker closed');
          return;
        }
        this.workerPort?.postMessage(data);
      } else {
        this.runInWorker(data.request, (v?: LooseObject) => {
          HiLog.i(TAG, 'runInWorker callback in' + ' time:' + (new Date()).valueOf())
          if (this.closed) {
            HiLog.w(TAG, 'worker closed')
            return;
          }
          data.param = v as LooseObject;
          this.workerPort?.postMessage(data);
        }, data.param as LooseObject, data.log);
      }
    } catch (err) {
      HiLog.e(TAG, `runInWorker err = ${err?.message}`);
    }
  }

  public abstract runInWorker (request: string, callBack: Function, param?: LooseObject, log?: UtilAuditLog);
}

export default WorkerTask;