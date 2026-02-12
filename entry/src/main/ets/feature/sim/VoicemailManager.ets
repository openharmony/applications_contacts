/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import sim from '@ohos.telephony.sim';
import { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { RoamingUtils } from '../../../../../../common/src/main/ets/util/RoamingUtils';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

const TAG = 'VoicemailManager ';

export default class VoicemailManager {
  public static instance: VoicemailManager;

  public static getInstance(): VoicemailManager {
    if (!VoicemailManager.instance) {
      VoicemailManager.instance = new VoicemailManager();
    }
    return VoicemailManager.instance;
  }

  public getVoicemailNumber(slotId: number): Promise<string> {
    HiLog.i(TAG, `getVoiceMailNumber start slot: ` + slotId);
    return new Promise(resolve => {
      sim.getVoiceMailNumber(slotId, (err: BusinessError, data: string) => {

        if (data) {
          resolve(data);
        } else {
          HiLog.i(TAG, `getVoiceMailNumber callback: err->${err?.message}, stack: ${err?.stack}`);
          resolve('');
        }
      });
    })
  }

  public setVoicemailInfo(slotId: number, name: string, value: string, callback: Function) {
    HiLog.i(TAG, 'setVoicemailInfo');
    let promise:Promise<void> = sim.setVoiceMailInfo(slotId, name, value);
    promise.then(() => {
      HiLog.i(TAG, `setVoiceMailInfo success.`);
      callback(0);
    }).catch((err: BusinessError) => {
      HiLog.i(TAG, `setVoiceMailInfo failed, promise: err->${err?.message}, stack: ${err?.stack}`);
      callback(err.code);
    }).finally(() => {
      this.updateVoicemailNumber();
    });
  }

  async updateVoicemailNumber() {
    HiLog.i(TAG, `updateVoicemailNumber start`);
    try {
      let number1 = await this.getVoicemailNumber(0);
      let number2 = await this.getVoicemailNumber(1);
      let formatNumber1 = RoamingUtils.getFormatNumberBySystemRegion(number1);
      let formatNumber2 = RoamingUtils.getFormatNumberBySystemRegion(number2);
      number1 = !StringUtil.isEmpty(formatNumber1) ? formatNumber1 as string : number1;
      number2 = !StringUtil.isEmpty(formatNumber2) ? formatNumber2 as string : number2;
      AppStorage.setOrCreate('voicemailNumbers', [number1, number2]);
    } catch (err) {
      HiLog.e(TAG, `updateVoicemailNumber err: ${err?.message}, stack: ${err?.stack}!`);
    }
    HiLog.i(TAG, `updateVoicemailNumber end`);
  }
}