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
import Utils from './Utils';
import HiLog from './HiLog';
import call from '@ohos.telephony.call';

const TAG = 'DialUtil ';

export default class DialUtil {
  private static sInstance: DialUtil;

  public static getInstance(): DialUtil {
    HiLog.i(TAG, 'getInstance start !');
    if (DialUtil.sInstance == null) {
      HiLog.i(TAG, 'getInstance init ');
      DialUtil.sInstance = new DialUtil();
    }
    return DialUtil.sInstance;
  }

  /**
   * dial拨号
   *
   * @param phoneNum 电话号码
   * @param callback 拨号回调 data:是否是紧急号码   err：拨号失败  value：拨号结果
   */
  dial(phoneNum: string, callback) {
    HiLog.i(TAG, 'dial phonenum is %s', phoneNum);
    if (Utils.isEmpty(phoneNum)) {
      return;
    }
    let num: string = Utils.removeSpace(phoneNum);

    call.isEmergencyPhoneNumber(num, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'isEmergencyPhoneNumber err %s', err.message);
        return;
      }
      if (data) {
        call.dial(num, { dialScene: 2 }, (err, value) => {
          callback(data, err, value);
          if (err) {
            HiLog.e(TAG, 'dialEmergencyPhoneNumber finish err %s', err.message);
            return;
          }
          HiLog.i(TAG, 'dialEmergencyPhoneNumber finish %s', value);
        });
      } else {
        call.dial(num, (err, value) => {
          callback(data, err, value);
          if (err) {
            HiLog.e(TAG, 'dial finish err %s', err.message);
            return;
          }
          HiLog.i(TAG, 'dial finish %s', value);
        });
      }
    });
  }
}

