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

const TAG = 'TelecomService';

export default class TelecomService {
  private static sInstance: TelecomService;

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
  async dial(phoneNum: string, options: call.DialOptions, callback) {
    HiLog.i(TAG, 'dial start ');
    if (StringUtil.isEmpty(phoneNum)) {
      HiLog.i(TAG, 'dial phoneNum is empty ');
      return;
    }
    let num: string = StringUtil.removeSpace(phoneNum);
    call.dial(num, options, (err, value) => {
      callback(value);
      if (err) {
        HiLog.e(TAG, 'dial finish err: ' + JSON.stringify(err.message));
        return;
      }
      HiLog.i(TAG, 'dial finish value: ' + JSON.stringify(value));
    });
  }
}