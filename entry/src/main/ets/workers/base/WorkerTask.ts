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

import { WorkerMessage } from "./WorkerWrapper"
import { ThreadWorkerGlobalScope, MessageEvents } from '@ohos.worker';
import { HiLog } from "../../../../../../common"
import buffer from "@ohos.buffer"

const TAG = "WorkerTask"
/*
 * WorkerTask
 *
 * Work sub thread task
 */
export abstract class WorkerTask {
    workerPort: ThreadWorkerGlobalScope

    constructor(workerPort?: ThreadWorkerGlobalScope) {
        HiLog.i(TAG, `WorkerTask constructor`)
        this.workerPort = workerPort;
    }

    /**
     * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
     * The event handler is executed in the worker thread.
     *
     * @param e message data
     */
    public onmessage(message: MessageEvents) {
        try {
            let data = <WorkerMessage> message.data
            HiLog.i(TAG, `onmessage ${data.request}`)
            this.runInWorker(data.request, (v) => {
                HiLog.i(TAG, "runInWorker callback in")
                data.param = v;
                const str = JSON.stringify(data)
                let buf = buffer.from(str).buffer;
                this.workerPort?.postMessage(buf, [buf]);
            }, data.param);
        } catch (err) {
            HiLog.e(TAG, 'runInWorker err = ' + JSON.stringify(err));
        }
    }

    public abstract runInWorker(request: string, callBack: (v?: any) => void, param?: any);
}

export default WorkerTask;