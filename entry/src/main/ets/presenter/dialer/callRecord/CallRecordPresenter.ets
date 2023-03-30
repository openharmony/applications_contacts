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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import router from '@ohos.router';
import { CallLogRepository } from '../../../../../../../feature/call';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import CallRecordListDataSource from './../../../model/bean/CallRecordListDataSource';
import CallLogSetting from '../../../../../../../feature/call/src/main/ets/CallLogSetting'
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import emitter from '@ohos.events.emitter';

const TAG = 'CallRecordPresenter'

export default class CallRecordPresenter {
  private static mPresenter: CallRecordPresenter;
  mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mMissCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mDialerPresent: DialerPresenter = DialerPresenter.getInstance();
  isShow: boolean = false;

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
    HiLog.i(TAG, 'aboutToAppear!');
    this.isShow = true;
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    this.isShow = false;
  }

  refreshMissedList(missedList) {
    HiLog.i(TAG, 'refreshMissedList, length is ' + missedList.length);
    if (!ObjectUtil.isEmpty(this.mMissCallRecordListDataSource)) {
      this.mMissCallRecordListDataSource.refresh(missedList);
    }
  }

  refreshCallLogList(callLogList) {
      HiLog.i(TAG, 'refreshCallLogList, length is ' + callLogList.length);
      if (!ObjectUtil.isEmpty(this.mAllCallRecordListDataSource)) {
        this.mAllCallRecordListDataSource.refresh(callLogList);
        this.mDialerPresent.refresh();
      }
  }

  dialing(phoneNumber, options?: any) {
    PhoneNumber.fromString(phoneNumber).dial(options);
  }

  deleteCallLog(id) {
    globalThis.DataWorker.sendRequest("deleteCallLogsById", {
      context: globalThis.context,
      ids: id
    }, (data) => {
      HiLog.i(TAG, 'deleteCallLog Success');
      CallLogRepository.getInstance().notifyChange()
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