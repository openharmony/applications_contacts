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

import worker from '@ohos.worker';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

const TAG = "AudioWorker ";

export class AudioHepler {
  private workerName: string;
  private workerUri: string;
  private mWorker;
  constructor(name: string, workerUri: string) {
    this.workerName = name;
    this.workerUri = workerUri;
    this.initWorker();
  }

  private initWorker(): void {
    this.mWorker = new worker.Worker(this.workerUri, { type: "classic", name: this.workerName });
    this.mWorker.onerror = this.onError.bind(this);
    this.mWorker.onmessageError = this.onMessageError.bind(this);
    this.mWorker.onexit = this.onExit.bind(this);
    this.mWorker.onmessage = this.onMessage.bind(this);
  }

  public onError(e: any): void {
    HiLog.e(TAG, "AudioWorker is error" + JSON.stringify(e));
  }

  public onMessageError(e: any): void {
    HiLog.e(TAG, "AudioWorker Message is error" + JSON.stringify(e));
  }

  public onExit(e: any): void {
    HiLog.e(TAG, "AudioWorker is Exit");
  }

  public onMessage(e: any): void {
    HiLog.e(TAG, "AudioWorker return message");
  }

  public postMessage(message: any): void {
    HiLog.i(TAG, "AudioWorker postMessage");
    this.mWorker.postMessage(message);
  }
}