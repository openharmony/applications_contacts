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

import WorkFactory, { WorkerType } from '../WorkFactory'
import worker, { ErrorEvent, MessageEvents } from '@ohos.worker';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import LooseObject from '../../model/type/LooseObject';
import { DataWorkerTask } from '../DataWorkerTask';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper'
import { List, taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContactInfo } from '../../model/bean/ContactInfo';
import { UtilAuditLog, assembleLogUtils } from '../../../../../../common/src/main/ets/util/AuditLogUtils'

const TAG = 'WorkerWrapper'

export class WorkerMessage {
  public request: string = '';
  public callBackId: number = -1;
  public type?: WorkerType;
  public param?: LooseObject;
  public log?: UtilAuditLog
}

/*
 * WorkerWrapper
 *
 * Processes sending tasks to workers and receiving work processing results.
 */
export default class WorkerWrapper {
  protected mWorker?: worker.ThreadWorker;
  private callBacks: Map<string, Function> = new Map();
  private requestIndex: number = 0;
  private workType: WorkerType;
  private useWorker: boolean;
  public DTResult: boolean = true;

  constructor (workType: WorkerType, useWorker: boolean) {
    this.workType = workType;
    this.useWorker = useWorker;
    if (useWorker) {
      this.initWorker();
    }
  }

  async initWorker () {
    HiLog.i(TAG, `WorkerWrapper initWorker ${WorkerType[this.getWorkerType()]} Time:${(new Date()).valueOf()}`)
    let initWorker = await new worker.ThreadWorker('entry/ets/workers/base/Worker.ts', {
      name: WorkerType[this.getWorkerType()]
    });
    let that = this;
    initWorker.onexit = () => {
      HiLog.w(TAG, 'onexit')
      that.mWorker = undefined;
      this.useWorker = false;
    }
    initWorker.onerror = (e: ErrorEvent) => {
      HiLog.w(TAG, `onerror: ${e?.message}`)
    }
    initWorker.onmessageerror = (e: MessageEvents) => {
      HiLog.w(TAG, 'onmessageerror')
    }
    initWorker.onmessage = (message) => {
      let data = message.data as WorkerMessage
      HiLog.i(TAG, `onmessage ${data.request} Time:${(new Date()).valueOf()}`)
      const key = that.getCallBackKey(data);
      if (that.callBacks.has(key)) {
        HiLog.i(TAG, `onmessage notify result. Time:${(new Date()).valueOf()}`)
        const callback: Function | undefined = that.callBacks.get(key);
        if (callback != undefined) {
          callback(data.param);
        }
        that.callBacks.delete(key);
      }
    }
    this.mWorker = initWorker;
    this.useWorker = true;
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('init', {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }, () => {
      HiLog.i(TAG, 'activateRestore');
      try {
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('activateRestore', {
            context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          });
      } catch (err) {
        HiLog.e(TAG, `activateRestore error: ${err?.message}`);
      }
    });
    HiLog.i(TAG, `WorkerWrapper initWorker end Time:${(new Date()).valueOf()}`)
  }

  public getWorkerType (): WorkerType {
    return this.workType;
  }

  /**
   *
   * @param request 请求的方法
   * @param requestData 请求数据
   * @param callBack 回调
   */
  public async sendRequestUiThread (request: string, requestData?: LooseObject, callBack?: Function) {
    HiLog.i(TAG, 'sendRequestUiThread in ' + request);
    DataWorkerTask.getInstanceCurThread().runInWorker(request, callBack as Function, requestData);
  }

  /**
   * SendRequest to worker thread.
   *
   * @param {string} request the request worker to do
   * @param {Object} requestData  request param Data
   * @param {Object} callBack Call back from worker
   */
  public async sendRequest (request: string, requestData?: LooseObject, callBack?: Function) {
    let log: UtilAuditLog = await assembleLogUtils(request, requestData);
    try {
      if (!this.useWorker) {
        HiLog.i(TAG, 'sendRequest !useWorker ');
        WorkFactory.getTask(this.getWorkerType())?.runInWorker(request, callBack as Function, requestData);
      } else if (this.mWorker) {
        const message: WorkerMessage = new WorkerMessage();
        message.request = request;
        message.callBackId = this.requestIndex;
        message.type = this.getWorkerType();
        message.param = requestData;
        message.log = log
        if (callBack) {
          this.callBacks.set(this.getCallBackKey(message), callBack);
        }
        this.mWorker?.postMessage(message);
        HiLog.d(TAG, `${this.getWorkerType()} ${request} send succ!`);
        this.requestIndex++;
      } else {
        HiLog.w(TAG,
          `${this.getWorkerType()} ${request} send fail, worker has been closed! Time:${(new Date()).valueOf()}`);
        this.sendRequestUiThread(request, requestData, callBack);
      }
    } catch (err) {
      HiLog.e(TAG, `sendRequest err:${err?.message}`);
    }
  }

  /**
   * pageManager 的 requestItem 使用，其他查询请求未验证是否正确，使用的话需验证和适配
   * @param request 请求的方法
   * @param requestData 请求数据
   * @param callBack 回调
   */
  public async sendRequestTaskPool (request: string, requestData?: LooseObject, callBack?: Function) {
    HiLog.w(TAG, 'sendRequestTaskPool in ' + request + ' time:' + (new Date()).valueOf());
    taskpool.execute(requestInTaskPool,
      ContactsGlobalThisHelper.GetGlobalThis().getValue(ContactsGlobalThisHelper.UIContextName),
      request, requestData).then((data) => {
      HiLog.w(TAG, 'taskpool exe success main recv: ' + request);
      if (callBack) {
        callBack(data);
      }
    }).catch((e: BusinessError) => {
      HiLog.e(TAG, 'task execute error in taskpool --' + e.message + '--' + e.code);
    });
  }

  /**
   * Close  close worker thread.
   */
  public async close () {
    HiLog.i(TAG, `${this.getWorkerType()} worker close!`);
    await this.sendRequest('close');
    this.mWorker?.terminate();
    this.mWorker = undefined;
    this.useWorker = false;
    this.callBacks.clear();
  }

  private getCallBackKey (message: WorkerMessage): string {
    return message.request + message.callBackId;
  }

  public getMWorker () {
    return this.mWorker
  }

  public getRequestIndex () {
    return this.requestIndex
  }
}

@Concurrent
export async function requestInTaskPool<T> (context: Context, request: string, requestData?: LooseObject): Promise<T> {

  let resPromise: Promise<T> = new Promise((resolve) => {
    HiLog.w('requestInTaskPool', 'recv request: ' + request);
    let callBack = (data: T) => {
      resolve(data);
    }
    requestData!.context = context;
    ContactRepository.getInstance().init(context);
    ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
    DataWorkerTask.getInstanceCurThread().runInWorker(request, callBack as Function, requestData);
  });

  let res = await resPromise;
  return res;
}