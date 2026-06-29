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

import { ThreadWorkerGlobalScope, MessageEvents } from '@ohos.worker';
import { HiLog } from '../../../../../common'
import { DataWorkerTask } from './DataWorkerTask'
import WorkerWrapper, { WorkerMessage } from './base/WorkerWrapper'
import WorkerTask from './base/WorkerTask'
import Constants from '../../../../../feature/call/oh_modules/common/src/main/ets/Constants';

const TAG = 'WorkFactory'

export enum WorkerType {
  DataWorker,
}

export default class WorkFactory {
  /**
   * Get the Task for worker
   *
   * @param workerPort ThreadWorkerGlobalScope
   * @param message worker message data
   * @return WorkerTask for the message
   */
  static getTask(type: WorkerType, workerPort?: ThreadWorkerGlobalScope): WorkerTask | undefined {
    HiLog.i(TAG, `getTask in ${type}. Time:${(new Date()).valueOf()}`);
    let task: WorkerTask | undefined = undefined;
    if (type == WorkerType.DataWorker) {
      task = DataWorkerTask.getInstance(workerPort);
    }
    HiLog.i(TAG, 'getTask end' + ' time:' + (new Date()).valueOf());
    return task;
  }

  /**
   * Get the Worker Wrapper obj
   *
   * @param type WorkerType
   * @return WorkerWrapper for the WorkerType
   */
  static getWorker(type: WorkerType): WorkerWrapper | undefined {
    HiLog.i(TAG, `getWorker in ${type}. Time:${(new Date()).valueOf()}`)
    let worker: WorkerWrapper | undefined = undefined
    if (type == WorkerType.DataWorker) {
      HiLog.i(TAG, 'getWorker ' + type + ' time:' + (new Date()).valueOf())
      worker = new WorkerWrapper(WorkerType.DataWorker, true);
    }
    HiLog.i(TAG, 'getWorker end' + ' time:' + (new Date()).valueOf())
    return worker;
  }
}