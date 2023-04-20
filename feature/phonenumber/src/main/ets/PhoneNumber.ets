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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import i18n from '@ohos.i18n';
import MmsService from './MmsService';
import TelecomService from './TelecomService';
import call from '@ohos.telephony.call';

const TAG = 'PhoneNumber';

/**
 * Number object, which provides number-related services.
 */
export class PhoneNumber {
  readonly number: string;
  constructor(number: string) {
    this.number = number;
  }

  static fromString(number: string): PhoneNumber {
    return new PhoneNumber(StringUtil.removeSpace(number));
  }

  isDialEmergencyNum(): Promise<boolean> {
    let phoneNumber = this.number;
    return new Promise<boolean>(function (resolve, reject) {
      call.isEmergencyPhoneNumber(phoneNumber, (err, data) => {
        if (err) {
          HiLog.e(TAG, 'isEmergencyPhoneNumber error: ' + JSON.stringify(err));
          reject(err);
        } else {
          HiLog.i(TAG, 'isEmergencyPhoneNumber data: ' + JSON.stringify(data));
          resolve(data);
        }
      });
    });
  }

  dial(options?: any): Promise<boolean> {
    HiLog.i(TAG, 'dial phone.');
    let phoneNumber = this.number;
    if (!options && AppStorage.Has('defaultSlot')) {
      options = {
        accountId: AppStorage.Get<number>('defaultSlot'),
      }
    }
    return new Promise<boolean>(function (resolve, reject) {
      TelecomService.getInstance().dial(phoneNumber, options, (data)  => {
        HiLog.i(TAG, ` dial data:${JSON.stringify(data)}`);
        if (!!data) {
          resolve(data);
        } else {
          reject({code: -1});
        }
      });
    });
  }

  sendMessage(formatnum?:string, name?: string) {
    HiLog.i(TAG, 'send message.');
    MmsService.sendMessage(this.number, formatnum, name);
  }

  getNumber() {
    let phoneNumber = this.number;
    return phoneNumber;
  }

  format() {
    let phoneNumber = this.number;
    let countryId = i18n.getSystemRegion();
    let phoneNumberFormat= new i18n.PhoneNumberFormat(countryId);
    let isNumberValid:boolean = phoneNumberFormat.isValidNumber(phoneNumber);
    let formatNumber = isNumberValid ? phoneNumberFormat.format(phoneNumber) : phoneNumber;
    return formatNumber;
  }
}