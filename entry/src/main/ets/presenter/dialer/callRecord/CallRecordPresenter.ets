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

import { HiLog, ArrayUtil } from '../../../../../../../common';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import router from '@ohos.router';
import { CallLogRepository } from '../../../../../../../feature/call';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import CallRecordListDataSource from './../../../model/bean/CallRecordListDataSource';
import CallLogSetting from '../../../../../../../feature/call/src/main/ets/CallLogSetting'
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';

const TAG = 'CallRecordPresenter'
const DELAY_TIME: number = 1000;

export default class CallRecordPresenter {
  private static mPresenter: CallRecordPresenter;
  mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mMissCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mDialerPresent: DialerPresenter = DialerPresenter.getInstance();
  isShow: boolean = false;
  page: number = 0;
  limit: number = 0;
  context: Context;
  worker: WorkerWrapper;
  refreshState: () => void
  loading: boolean = false;
  callLogListPages: Array<number> = [];
  missedListPages: Array<number> = [];
  callLogIndex: number = 0;
  missedIndex: number = 0;
  tabIndex: number = 0;
  initStarted: boolean = false;
  taskId: number = undefined;
  onCallsChange = () => {
    HiLog.i(TAG, 'onCallsChange refresh');
    this.setDelayTask();
  }
  onContactChange = () => {
    HiLog.i(TAG, 'onContactChange refresh');
    this.setDelayTask();
  }

  static getInstance() {
    if (globalThis.presenterManager?.callRecordPresenter) {
      return globalThis.presenterManager.callRecordPresenter;
    }
    if (CallRecordPresenter.mPresenter == null) {
      CallRecordPresenter.mPresenter = new CallRecordPresenter();
    }
    return CallRecordPresenter.mPresenter;
  }

  bindUI(refreshState?: () => void) {
    this.refreshState = refreshState;
  }

  onCreate(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallsChange);
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
  }

  onDestroy() {
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallsChange);
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactChange);
  }

  startInit() {
    if (this.initStarted) {
      return;
    }
    HiLog.i(TAG, "startInit");
    this.initStarted = true;
    if (this.page == 0) {
      this.page++;
    }
    this.refreshContinue();
  }

  cachePageOne() {
    if (!this.initStarted && !this.loading) {
      HiLog.i(TAG, "cachePageOne")
      this.page = 1;
      this.callLogIndex = 0;
      this.missedIndex = 0;
      this.refreshContinue();
    } else {
      HiLog.i(TAG, "no need cachePageOne");
    }
  }

  setPageShow(isShow: boolean) {
    if (this.isShow == isShow) {
      return;
    }
    this.isShow = isShow;
    if (this.isShow) {
      this.startInit();
    }
    this.setTabShow();
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear!');
    this.startInit();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
  }

  setTabShow() {
    if (this.isShow) {
      HiLog.i(TAG, 'setTabShow:' + this.tabIndex);
      if (this.tabIndex == 0) {
        this.mMissCallRecordListDataSource.setIsShow(false);
        this.mAllCallRecordListDataSource.setIsShow(true);
      } else {
        this.mAllCallRecordListDataSource.setIsShow(false);
        this.mMissCallRecordListDataSource.setIsShow(true);
      }
    } else {
      this.mAllCallRecordListDataSource.setIsShow(false);
      this.mMissCallRecordListDataSource.setIsShow(false);
    }
  }

  setTabIndex(index) {
    if (this.tabIndex != index) {
      this.tabIndex = index;
      this.setTabShow();
    }
  }

  requestItem() {
    HiLog.i(TAG, 'CallLogs requestItem!');
    if (this.page == 0) {
      this.page++;
      this.refreshContinue();
    } else if (!this.initStarted && !this.loading) {
      this.cachePageOne();
    } else {
      HiLog.i(TAG, 'isLoading');
    }
  }

  setDelayTask() {
    if (this.taskId != undefined) {
      clearTimeout(this.taskId);
      this.taskId = undefined;
    }
    let delay: number = 0;
    if (this.page != 0) {
      delay += DELAY_TIME;
    }
    if (!this.isShow) {
      delay += DELAY_TIME;
    }
    if (delay > 0) {
      this.taskId = setTimeout(() => {
        if (this.page != 0) {
          this.setDelayTask();
        } else {
          this.requestItem();
        }
      }, delay);
    } else {
      this.requestItem();
    }
  }

  refreshContinue() {
    if (this.loading) {
      HiLog.i(TAG, 'refreshContinue is loading');
      return;
    }
    if (this.page == 0) {
      HiLog.i(TAG, 'refreshContinue end');
      return;
    }
    if (this.page == 1) {
      this.limit = 50;
    } else {
      this.limit = 500;
    }
    this.refreshPage(this.page, this.limit, () => {
      if (this.initStarted) {
        setTimeout(() => {
          this.refreshContinue();
        },!this.isShow ? 700 : 1);
      }
    })
  }

  refreshPage(page: number, limit: number, callback?: () => void) {
    this.loading = true;
    let actionData: any = {};
    actionData.page = page;
    actionData.limit = limit;
    this.worker?.sendRequest("getAllCalls", {
      context: this.context,
      mergeRule: CallLogSetting.getInstance().getMergeRule(),
      actionData: actionData
    }, (data) => {
      let dateLength = data.callLogList.length;
      HiLog.i(TAG, `refreshPage ${page} and getAllCalls, length is ` + dateLength);
      if (Array.prototype.isPrototypeOf(data.callLogList)) {
        this.mAllCallRecordListDataSource.refresh(this.callLogIndex, this.callLogListPages[page-1], data.callLogList);
        this.mDialerPresent.refresh();
      }
      if (Array.prototype.isPrototypeOf(data.missedList)) {
        this.mMissCallRecordListDataSource.refresh(this.missedIndex, this.missedListPages[page - 1], data.missedList);
      }
      this.callLogListPages[page-1] = dateLength;
      this.callLogIndex += this.callLogListPages[page-1];
      this.missedListPages[page - 1] = data.missedList.length;
      this.missedIndex += this.missedListPages[page - 1];
      if (this.refreshState) {
        this.refreshState();
      }
      if (dateLength < limit) {
        this.page = 0;
        HiLog.i(TAG, 'CallLogs load completed: ' + JSON.stringify(this.mAllCallRecordListDataSource.totalCount()));
        if (this.callLogListPages.length > page) {
          this.callLogListPages.splice(page, this.callLogListPages.length - page);
        }
        if (this.missedListPages.length > page) {
          this.missedListPages.splice(page, this.missedListPages.length - page);
        }
        if (this.mAllCallRecordListDataSource.totalCount() > this.callLogIndex) {
          this.mAllCallRecordListDataSource.remove(this.callLogIndex, this.mAllCallRecordListDataSource.totalCount() - this.callLogIndex);
        }
        if (this.mMissCallRecordListDataSource.totalCount() > this.missedIndex) {
          this.mMissCallRecordListDataSource.remove(this.missedIndex, this.mMissCallRecordListDataSource.totalCount() - this.missedIndex);
        }
        this.callLogIndex = 0;
        this.missedIndex = 0;
        this.loading = false;
      } else {
        this.page = page + 1;
        this.loading = false;
        if (callback) {
          callback();
        }
      }
    })
  }

  dialing(phoneNumber, options?: any) {
    PhoneNumber.fromString(phoneNumber).dial(options);
  }

  deleteCallLog(id, index?) {
    globalThis.DataWorker.sendRequest("deleteCallLogsById", {
      context: globalThis.context,
      ids: id
    }, (data) => {
      HiLog.i(TAG, 'deleteCallLog Success');
      CallLogRepository.getInstance().notifyChange()
    });
    if (index != undefined) {
      if (this.tabIndex == 0) {
        this.mAllCallRecordListDataSource.remove(index);
      } else {
        this.mMissCallRecordListDataSource.remove(index);
      }
    }
  }

  jumpToContactDetail(phoneNumber) {
    router.push(
      {
        url: "pages/contacts/details/ContactDetail",
        params: {
          sourceHasPhone: true,
          phoneNumberShow: phoneNumber
        }
      }
    )
  }
}