/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { CallLogRepository } from '../../../../../feature/call';
import { ContactRepository } from '../../../../../feature/contact';
import { HiLog, ArrayUtil } from '../../../../../common';
import CallLogSetting from '../../../../../feature/call/src/main/ets/CallLogSetting'
import WorkerWrapper from "../workers/base/WorkerWrapper";
import { DataWorkerConstant } from "../workers/DataWorkerWrapper";
import emitter from '@ohos.events.emitter'
import Constants from '../../../../../common/src/main/ets/Constants';

const TAG = "CallsService"

export default class CallsService {
  page: number = 0;
  limit: number = 50;
  callLogList: Array<any> = [];
  missedList: Array<any> = [];
  context: Context;
  worker: WorkerWrapper;
  innerEvent = {
    eventId: Constants.Event.CALLS_CHANGE,
    priority: emitter.EventPriority.HIGH
  };
  onContactsChange = () => {
    HiLog.i(TAG, 'onContactsChange refresh');
    this.requestItem();
  }
  onCallLogsChange = () => {
    HiLog.i(TAG, 'refresh');
    this.requestItem();
  }

  constructor(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
    this.requestItem();
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallLogsChange);
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactsChange);
    emitter.on({
      eventId: Constants.Event.CALLS_MERGE,
      priority: emitter.EventPriority.HIGH
    }, () => {
      this.requestItem();
    })
  }

  onDestroy() {
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactsChange);
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallLogsChange);
    emitter.off(Constants.Event.CALLS_MERGE);
  }

  requestItem() {
    HiLog.i(TAG, 'CallLogs requestItem!');
    if (this.page == 0) {
      this.callLogList = [];
      this.missedList = [];
      this.page++;
      this.refresh();
    } else {
      HiLog.i(TAG, 'isLoading');
    }
  }

  refresh() {
    if (this.page == 1) {
      this.limit = 50;
    } else {
      this.limit = 500;
    }
    let actionData: any = {};
    actionData.page = this.page;
    actionData.limit = this.limit;
    this.worker.sendRequest(DataWorkerConstant[DataWorkerConstant.getAllCalls], {
      context: this.context,
      mergeRule: CallLogSetting.getInstance().getMergeRule(),
      actionData: actionData
    }, (data) => {
      HiLog.i(TAG, 'getAllCalls and refresh, length is ' + JSON.stringify(data.callLogList.length));
      const dateLength = data.callLogList.length;
      if (!ArrayUtil.isEmpty(data.callLogList)) {
        this.callLogList = this.callLogList.concat(data.callLogList);
      }
      if (!ArrayUtil.isEmpty(data.missedList)) {
        this.missedList = this.missedList.concat(data.missedList);
      }
      HiLog.i(TAG, 'getAllCalls and refresh end, length is ' + JSON.stringify(this.callLogList.length));

      AppStorage.SetOrCreate("callLogList", this.callLogList)
      AppStorage.SetOrCreate("missedList", this.missedList)
      emitter.emit(this.innerEvent);
      if (dateLength < this.limit) {
        this.page = 0;
        HiLog.i(TAG, 'CallLogs load completed: ' + JSON.stringify(this.callLogList.length));
      } else {
        this.page++;
        setTimeout(() => {
          this.refresh();
        }, this.page == 2 ? 700 : 1);
      }
    })
  }
}