/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import WorkFactory, { WorkerType } from "../WorkFactory"
import worker from '@ohos.worker';
import { HiLog } from "../../../../../../common"
import buffer from "@ohos.buffer"

const TAG = "WorkerWrapper"

export class WorkerMessage {
  request: string;
  callBackId: number;
  type?: WorkerType;
  param?: any;
}

/*
 * WorkerWrapper
 *
 * Processes sending tasks to workers and receiving work processing results.
 */
export default class WorkerWrapper {
  protected mWorker: worker.ThreadWorker = undefined;
  private callBacks: Map<string, (result?: any) => void> = new Map();
  private requestIndex: number = 0;
  private workType: WorkerType;
  private useWorker: boolean;

  constructor(workType: WorkerType, useWorker: boolean) {
    this.workType = workType;
    this.useWorker = useWorker;
    if (useWorker) {
      this.initWorker();
    }
  }

  async initWorker() {
    HiLog.i(TAG, `WorkerWrapper initWorker ${WorkerType[this.getWorkerType()]}`)
    let initWorker = await new worker.ThreadWorker("entry/ets/workers/base/Worker.ts", {
      name: WorkerType[this.getWorkerType()]
    });
    let that = this;
    initWorker.onexit = function (message) {
      HiLog.w(TAG, "onexit")
      that.mWorker = undefined;
    }
    initWorker.onerror = function (e) {
      HiLog.w(TAG, "onerror:" + JSON.stringify(e))
    }
    initWorker.onmessageerror = function (e) {
      HiLog.w(TAG, "onmessageerror:" + JSON.stringify(e))
    }
    initWorker.onmessage = function (message) {
      const buff = <ArrayBuffer> message.data;
      const str = buffer.from(buff).toString();
      let data = <WorkerMessage> JSON.parse(str)
      HiLog.i(TAG, `onmessage ${data.request}`)
      const key = that.getCallBackKey(data);
      if (that.callBacks.has(key)) {
        HiLog.i(TAG, `onmessage notify result.`)
        const callback = that.callBacks.get(key);
        if (callback) {
          callback(data.param);
        }
        that.callBacks.delete(key);
      }
    }
    this.mWorker = initWorker;
    HiLog.i(TAG, `WorkerWrapper initWorker end`)
  }

  public getWorkerType(): WorkerType {
    return this.workType;
  }

  /**
   * SendRequest to worker thread.
   *
   * @param {string} request the request worker to do
   * @param {Object} requestData  request param Data
   * @param {Object} callBack Call back from worker
   */
  public async sendRequest(request: string, requestData?: any, callBack?: (result?: any) => void) {
    HiLog.i(TAG, "sendRequest in " + request)
    if (!this.useWorker) {
      WorkFactory.getTask(this.getWorkerType()).runInWorker(request, callBack, requestData);
    } else if (this.mWorker) {
      const message = {
        request: request,
        callBackId: this.requestIndex,
        type: this.getWorkerType(),
        param: requestData
      }
      if (callBack) {
        this.callBacks.set(this.getCallBackKey(message), callBack);
      }
      this.mWorker?.postMessage(message);
      HiLog.d(TAG, `${this.getWorkerType()} ${request} send succ!`);
      this.requestIndex++;
    } else {
      HiLog.w(TAG, `${this.getWorkerType()} ${request} send fail, worker has been closed!`);
    }
  }

  /**
   * Close  close worker thread.
   */
  public close() {
    HiLog.i(TAG, `${this.getWorkerType()} worker close!`);
    this.mWorker?.terminate();
    this.mWorker = undefined;
    this.callBacks.clear();
  }

  private getCallBackKey(message: WorkerMessage): string {
    return message.request + message.callBackId;
  }
}
