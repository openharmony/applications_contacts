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
import HiLog from '../util/HiLog';
import StringUtil from '../util/StringUtil';
import Call from '@ohos.telephony.call';

const TAG = 'PhoneNumber';

/**
 * Number object, which provides number-related services.
 */
export default class PhoneNumber {
  readonly number: string;
  constructor(number: string) {
    this.number = number;
  }

  static fromString(number: string): PhoneNumber {
    return new PhoneNumber(StringUtil.removeSpace(number));
  }

  callOut(): Promise<number> {
    let number = this.number;
    return new Promise<number>(function (resolve, reject) {
      if (StringUtil.isEmpty(number)) {
        HiLog.w(TAG, "callOut: number is empty.");
        reject("number is empty.")
        return;
      }
      Call.isEmergencyPhoneNumber(number).then((isEmergency) => {
        if (isEmergency) {
          return Call.dial(number, {
            dialScene: 2
          });
        } else {
          return Call.dial(number);
        }
      }).catch(err => {
        HiLog.e(TAG, "callOut: isEmergencyPhoneNumber err.");
        reject();
      });
    });
  }

  sendMessage() {
  }
}