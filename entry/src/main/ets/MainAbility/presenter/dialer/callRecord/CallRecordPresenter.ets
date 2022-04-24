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
import HiLog from '../../../util/Hilog';
import ObjectUtil from '../../../util/ObjectUtil';
import DialUtil from '../../../util/DialUtil';
import ArrayUtil from '../../../util/ArrayUtil';
import observer from '@ohos.telephony.observer';
import router from '@system.router';
import CallLogRepository from '../../../call/repo/CallLogRepository';
import ContactRepository from '../../../contact/repo/ContactRepository';
import CallRecordListDataSource from './../../../model/bean/CallRecordListDataSource';

const TAG = 'CallRecordPresenter'

export default class CallRecordPresenter {
  private static mPresenter: CallRecordPresenter;
  callLogList: [] = [];
  missedList: [] = [];
  mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  mMissCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  private _isCallStateChangeObserved = false;

  static getInstance() {
    if (CallRecordPresenter.mPresenter == null) {
      CallRecordPresenter.mPresenter = new CallRecordPresenter();
    }
    return CallRecordPresenter.mPresenter;
  }

  aboutToAppear() {
    this.refresh();
    CallLogRepository.getInstance().registerDataChangeObserver(() => {
      HiLog.i(TAG, 'refresh');
      this.refresh();
    });
    ContactRepository.getInstance().registerDataChangeObserver(() => {
      HiLog.i(TAG, 'refresh');
      this.refresh();
    });
    if (!this._isCallStateChangeObserved) {
      observer.on('callStateChange', (callback: {
        state,
        number,
      }) => {
        HiLog.i(TAG, 'callStateChange state' + callback.state);
        if (callback.state === 0) {
          HiLog.i(TAG, "callback.state:" + callback.state);
          ContactRepository.getInstance().notifyChange();
        }
      });
      this._isCallStateChangeObserved = true;
    }
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    CallLogRepository.getInstance().unRegisterDataChangeObserver(() => {
    });
    ContactRepository.getInstance().unRegisterDataChangeObserver(() => {
    });
  }

  refresh() {
    CallLog.getAllCalls(data => {
      if (!ArrayUtil.isEmpty(data.callLogList)) {
        this.callLogList = data.callLogList;
      } else {
        this.callLogList = [];
      }
      if (!ArrayUtil.isEmpty(data.missedList)) {
        this.missedList = data.missedList;
      } else {
        this.missedList = [];
      }
      if (!ObjectUtil.isEmpty(this.mAllCallRecordListDataSource)) {
        this.mAllCallRecordListDataSource.refresh(this.callLogList);
      }
      if (!ObjectUtil.isEmpty(this.mMissCallRecordListDataSource)) {
        this.mMissCallRecordListDataSource.refresh(this.missedList);
      }
    })
  }

  dialing(phoneNumber) {
    DialUtil.getInstance().dial(phoneNumber, (data, err, value) => {
      HiLog.i(TAG, 'dialing callback');
    });
  }

  deleteCallLog(id) {
    CallLogRepository.getInstance().deleteByIdIn(id).then(data => {
      CallLogRepository.getInstance().notifyChange();
    });
  }

  jumpToContactDetail(phoneNumber) {
    router.push(
      {
        uri: "pages/contacts/details/ContactDetail",
        params: {
          sourceHasPhone: true,
          phoneNumberShow: phoneNumber
        }
      }
    )
  }
}