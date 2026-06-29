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
import I18n from '@ohos.i18n';
import MmsService from './MmsService';
import TelecomService from './TelecomService';
import call from '@ohos.telephony.call';
import StringFormatUtil from '../../../../../entry/src/main/ets/util/StringFormatUtil';
import { SendMessageParams } from '../../../../../entry/src/main/ets/model/type/ContactParams';
import { DialogControllerManager } from '../../../../../entry/src/main/ets/MainAbility/ControllerManager';
import DialerConstant from '../../../../../entry/src/main/ets/data/DialerConstant';
import { BusinessError } from '@ohos.base';
import {
  DIAL_INTERNAL_ERROR,
  DSDA_DIAL_INTERNAL_ERROR,
  DSDS_MODE_TDM,
  DSDS_MODE_V2,
  DSDS_MODE_V5
} from './idl/model/Constants';
import sim from '@ohos.telephony.sim';

const TAG = 'PhoneNumber';
const DEFAULT_INDEX = -1;

/**
 * Number object, which provides number-related services.
 */
export class PhoneNumber {
  public readonly number: string;
  public static isRingingDialogController?: CustomDialogController
  public static isNoRingingDialogController?: CustomDialogController

  constructor(number: string) {
    this.number = number;
  }

  static fromString(number: string | undefined): PhoneNumber {
    return new PhoneNumber(StringUtil.removeSpace(number));
  }

  isDialEmergencyNum(): Promise<boolean> {
    let phoneNumber = this.number.charAt(0) === '+' ? this.number.substring(1) : this.number;
    return new Promise<boolean>((resolve, reject) => {
      call.isEmergencyPhoneNumber(phoneNumber, (err, data) => {
        if (err) {
          HiLog.e(TAG, `isEmergencyPhoneNumber error: ${err?.message}`);
          reject(err);
        } else {
          HiLog.i(TAG, 'isEmergencyPhoneNumber success');
          resolve(data);
        }
      });
    });
  }

  async dial(options?: call.DialOptions): Promise<boolean> {
    HiLog.w(TAG, 'dial phone.');
    let phoneNumber = this.number;
    if (!options && AppStorage.Has('defaultSlot')) {
      options = {
        accountId: AppStorage.get<number>('defaultSlot'),
      }
    }
    let dsdsMode: number = DSDS_MODE_V2
    dsdsMode = await sim.getDsdsMode()
    let haveSimCard: boolean = AppStorage.get('haveSimCard') as boolean;
    let isRinging = call.getCallStateSync() === call.CallState.CALL_STATE_RINGING;
    HiLog.w(TAG, `dial param  phoneNumber length: ${phoneNumber?.length}, options: {extras: ${options?.extras},
     accountId: ${options?.accountId}}`);
    return new Promise<boolean>((resolve, reject) => {
      TelecomService.getInstance().dial(phoneNumber, options as call.DialOptions, (data: number) => {
        if (data === 0) {
          resolve(!!data);
        } else {
          HiLog.w(TAG, 'dial phone error data: ' + data + ' dsdsMode: ' + dsdsMode + ' isRinging: ' + isRinging);
          if (data === DIAL_INTERNAL_ERROR) {
            this.showDialErrorDialog();
          } else if (data === DSDA_DIAL_INTERNAL_ERROR) {
            if (haveSimCard && (dsdsMode === DSDS_MODE_TDM || dsdsMode === DSDS_MODE_V5)) {
              this.showDialErrorDialog();
            } else {
              this.showDialErrorDialog(isRinging);
            }
          }
          reject(data);
        }
      });
    });
  }

  showDialErrorDialog(isRinging?: boolean) {
    HiLog.w(TAG, 'showDialErrorDialog');
    if (isRinging) {
      PhoneNumber.isRingingDialogController?.open();
      AppStorage.setOrCreate('isRingingDialog', true);
      DialogControllerManager.getInstance().addDialogController(PhoneNumber.isRingingDialogController);
    } else {
      PhoneNumber.isNoRingingDialogController?.open();
      AppStorage.setOrCreate('isNoRingingDialog', true);
      DialogControllerManager.getInstance().addDialogController(PhoneNumber.isNoRingingDialogController);
    }
  }

  dialerSpecialCode() {
    let phoneNumber: string = this.number;
    call.inputDialerSpecialCode(phoneNumber, (err: BusinessError) => {
      if (err) {
        HiLog.e(TAG, `inputDialerSpecialCode error: ${err?.message}`);
      } else {
        HiLog.w(TAG, 'inputDialerSpecialCode success');
        setTimeout(() => {
          HiLog.w(TAG, 'start clear...');
          AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, '');
          AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, '');
        }, 400)
      }
    });
  }

  sendMessage(formatNum?: string, name?: string, contactId?: number) {
    HiLog.w(TAG, 'send message.');
    MmsService.sendMessage(this.number, formatNum as string, name, contactId);
  }

  static groupSendMessage(params: SendMessageParams[]) {
    MmsService.groupSendMessage(params);
  }

  getNumber() {
    let phoneNumber = this.number;
    return phoneNumber;
  }

  async format() {
    let phoneNumber = this.number;
    phoneNumber = StringFormatUtil.clearPhoneNumberSymbols(phoneNumber);
    if (StringUtil.isEmpty(phoneNumber)) {
      HiLog.e(TAG, `phoneNumber is empty`);
      return phoneNumber
    }
    let countryId = I18n.getSystemRegion();
    let options: call.NumberFormatOptions = {
      countryCode: countryId
    }
    let formatNumber = await call.formatPhoneNumber(phoneNumber, options);
    if (StringUtil.isEmpty(formatNumber)) {
      HiLog.e(TAG, `formatNumber is empty,but original number is not empty,original length: ${phoneNumber?.length}`);
      formatNumber = phoneNumber;
    }
    return formatNumber;
  }
  //这个方法在格式化代码的时候会删除掉区号
  phoneNumFormat() {
    let phoneNumber = this.number;
    phoneNumber = StringFormatUtil.clearPhoneNumberSymbols(phoneNumber);
    let countryId: string | undefined = 'CN';
    try {
      countryId = AppStorage.get('country');
      if (!countryId) {
        HiLog.w(TAG, `countryId error ${countryId} `);
        countryId = 'CN';
      }
    } catch (error) {
      HiLog.e(TAG, `Failed to obtain the country code, error is: ${error}`);
      countryId = 'CN';
    }
    countryId = countryId.toUpperCase();
    let phoneNumberFormat = new I18n.PhoneNumberFormat(countryId);
    let isNumberValid: boolean = phoneNumberFormat.isValidNumber(phoneNumber);
    let formatNumber = isNumberValid ? phoneNumberFormat.format(phoneNumber) : phoneNumber;
    return formatNumber;
  }
  //这个方法在格式化代码会增加空格
  async phoneAddSpace() {
    let phoneNumber = this.number;
    try {
      let countryId = 'CN';
      try {
        countryId = I18n.System.getSystemRegion();
      } catch (error) {
        countryId = 'CN';
      }
      let options: call.NumberFormatOptions = {
        countryCode: countryId
      }
      let formatNumber: string = await call.formatPhoneNumber(phoneNumber, options);
      if (StringUtil.isEmpty(formatNumber)) {
        formatNumber = phoneNumber;
      }
      return formatNumber;
    } catch (err) {
      HiLog.e(TAG, `phoneAddSpace, err: ${err.message}`)
      return phoneNumber;
    }
  }

  // 对拨号中的号码进行格式化
  dynamicPhoneFormat() {
    let phoneNumber = this.number;
    let countryId: string | undefined = 'CN';
    try {
      countryId = AppStorage.get('country');
      if (!countryId) {
        HiLog.w(TAG, `countryId error ${countryId} `);
        countryId = 'CN'
      }
    } catch (error) {
      countryId = 'CN';
      HiLog.e(TAG, `Failed to obtain the country code, error is: ${error}`);
    }
    countryId = countryId.toUpperCase();
    let option: I18n.PhoneNumberFormatOptions = {
      type: 'TYPING'
    }
    let numberFormat: I18n.PhoneNumberFormat = new I18n.PhoneNumberFormat(countryId, option);
    let formatNumber: string = numberFormat.format(phoneNumber);
    HiLog.w(TAG, `format after length: ${formatNumber.length} `);
    return formatNumber;
  }

  static formatDisplayPhoneNumber(formatPhoneNumber: string, highlight: string) {
    let phoneNumber = formatPhoneNumber.replace(new RegExp('\\s*', 'g'), '');
    highlight = highlight.replace(new RegExp('\\s*', 'g'), '');
    let indexStart = phoneNumber.indexOf(highlight);
    let indexEnd = indexStart === DEFAULT_INDEX ? DEFAULT_INDEX : indexStart + highlight.length - 1;
    if (indexStart === DEFAULT_INDEX) {
      return [DEFAULT_INDEX, DEFAULT_INDEX];
    }
    Array.from(formatPhoneNumber).forEach((item: string, index: number) => {
      if (item === ' ') {
        if (index <= indexStart) {
          ++indexStart;
          ++indexEnd;
        } else if (index <= indexEnd) {
          ++indexEnd;
        }
      }
    })
    return [indexStart, indexEnd];
  }
}