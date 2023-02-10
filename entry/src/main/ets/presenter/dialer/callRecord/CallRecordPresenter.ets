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

import CallLog from '../../../model/calllog/CalllogModel';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import router from '@ohos.router';
import { CallLogRepository } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import CallRecordListDataSource from './../../../model/bean/CallRecordListDataSource';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';

const TAG = 'CallRecordPresenter'

export default class CallRecordPresenter {
  private static mPresenter: CallRecordPresenter;
  callLogList = [];
  missedList = [];
  mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mMissCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mDialerPresent: DialerPresenter = DialerPresenter.getInstance();
  isShow: boolean = false;
  page: number = 0;
  limit: number = 0;
  dateLength: number = 0;

  static getInstance() {
    if (CallRecordPresenter.mPresenter == null) {
      CallRecordPresenter.mPresenter = new CallRecordPresenter();
    }
    return CallRecordPresenter.mPresenter;
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow');
    this.isShow = true;
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageHide');
    this.isShow = false;
  }

  aboutToAppear() {
    this.isShow = true;
    this.requestItem();
    CallLogRepository.getInstance().registerDataChangeObserver(() => {
      HiLog.i(TAG, 'refresh');
      this.requestItem();
    });
    ContactRepository.getInstance().registerDataChangeObserver(() => {
      HiLog.i(TAG, 'refresh');
      this.requestItem();
    });
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    this.isShow = false;
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
    CallLog.getAllCalls(actionData, data => {
      HiLog.i(TAG, 'getAllCalls and refresh, length is ' + JSON.stringify(data.callLogList.length));
      this.dateLength = data.callLogList.length;
      if (!ArrayUtil.isEmpty(data.callLogList)) {
        this.callLogList = this.callLogList.concat(data.callLogList);
        this.mDialerPresent.refresh();
      }
      if (!ArrayUtil.isEmpty(data.missedList)) {
        this.missedList = this.missedList.concat(data.missedList);
      }
      if (!ObjectUtil.isEmpty(this.mAllCallRecordListDataSource)) {
        this.mAllCallRecordListDataSource.refresh(this.callLogList);
      }
      if (!ObjectUtil.isEmpty(this.mMissCallRecordListDataSource)) {
        this.mMissCallRecordListDataSource.refresh(this.missedList);
      }
      if (this.dateLength < this.limit) {
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

  dialing(phoneNumber, options?: any) {
    PhoneNumber.fromString(options).dial();
  }

  deleteCallLog(id) {
    CallLogRepository.getInstance().deleteByIdIn(id, data => {
      CallLogRepository.getInstance().notifyChange();
    });
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