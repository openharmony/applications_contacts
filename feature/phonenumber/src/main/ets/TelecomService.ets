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
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import call from '@ohos.telephony.call';
import { BusinessError } from '@ohos.base';

const TAG = 'TelecomService';
const MINIMUN_INTERVAL_BETWEEN_TWO_CALLS = 1000;

export default class TelecomService {
  private static sInstance: TelecomService;
  private lastDialCallTime: number = -1;

  public static getInstance(): TelecomService {
    HiLog.i(TAG, 'getInstance start !');
    if (TelecomService.sInstance == null) {
      HiLog.i(TAG, 'getInstance init ');
      TelecomService.sInstance = new TelecomService();
    }
    return TelecomService.sInstance;
  }

  /**
   * dial number
   *
   * @param phoneNum telephone number
   * @param options DialOptions Look @ohos.telephony.call.d.ts
   * @param callback dail callback data:is emergency   err：failure  value：result
   */
  async dial(phoneNum: string, options: call.DialCallOptions, callback: CallableFunction) {
    HiLog.w(TAG, 'dial start ');
    if (options == undefined) {
      HiLog.w(TAG, 'dial options is undefined ');
      options = {};
    }
    if (StringUtil.isEmpty(phoneNum)) {
      HiLog.w(TAG, 'dial phoneNum is empty ');
      callback(-1);
      return;
    }
    let num: string = StringUtil.removeSpace(phoneNum);
    let nowTime = new Date().getTime();
    if ((nowTime - this.lastDialCallTime) > MINIMUN_INTERVAL_BETWEEN_TWO_CALLS || nowTime < this.lastDialCallTime) {
      HiLog.w(TAG, `nowTime: ${nowTime}, lastDialCallTime: ${this.lastDialCallTime}, dialCall success`);
      this.lastDialCallTime = nowTime;
      call.dialCall(num, options, (err: BusinessError<void>, value: void) => {
        if (err) {
          HiLog.e(TAG, `dial finish err: ${err?.message}`);
          callback(err.code);
        } else {
          callback(0); // Normal
          HiLog.w(TAG, 'dial finish success');
        }
      });
    } else {
      HiLog.e(TAG, `nowTime: ${nowTime}, lastDialCallTime: ${this.lastDialCallTime}, dialCall fails`);
      callback(-1);
    }
  }
}