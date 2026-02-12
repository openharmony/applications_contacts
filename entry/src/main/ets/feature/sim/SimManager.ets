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

import telephonySim from '@ohos.telephony.sim';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import simCardState from './SimCardState'
import spn from './SimOpName'
import voLteState from './VoLteState'
import { eSIM } from '@kit.TelephonyKit';

const TAG = 'SimManager';

export default class SimManager {
  public supportSimCount: number = telephonySim.getMaxSimCount();
  private onSimStateChange = () => {
    HiLog.i(TAG, `onSimStateChange`);
    this.UpdateSimName();
  }

  constructor() {
    if (this.supportSimCount > 1) {
      // support muti sim
      simCardState.setListener(this.onSimStateChange);
    }

  }

  async init(addSimStateListener: boolean = true) {
    simCardState.init(addSimStateListener);
    if (addSimStateListener) {
      voLteState.init();
      await spn.registerSubscriber();
      if (this.supportSimCount > 1) {
        // support muti sim
        spn.initSpnObserver();
      }
    }
    this.UpdateSimName();
  }

  unInit() {
    HiLog.i(TAG, `unInit...`);
    simCardState.unInit();
    voLteState.unInit();
    spn.unsubscribe();
    spn.unInitSpnObserver()
  }
  UpdateSimName() {
    for (let index = 0; index < this.supportSimCount; index++) {
      if (simCardState.isSimActive(index)) {
        spn.querySimName(index);
      } else {
        spn.notifySimName(index, '');
      }
    }
  }

  /**
   * recycle
   */
  public recycle(removeSimCardListener: boolean = true) {
    if (this.supportSimCount > 1) {
      // support muti sim
      spn.unsubscribeSpnObserver();
    }
    if (removeSimCardListener) {
      simCardState.removeSimChangeListener();
    }
    voLteState.removeVoLteListeners();
  }

  /**
   * Whether the device is dual SIM or not.
   *
   * @return return the device is dual SIM or not
   */
  static isDualSim(): boolean {
    if (telephonySim.getMaxSimCount() > 1) {
      return true
    }
    return false
  }

  static async getEid(): Promise<string> {
    try {
      let isSupportESIM: boolean = eSIM.isSupported(1);
      HiLog.i(TAG, `get EID, invoke eSIM.isSupported result: ${isSupportESIM}`);
      if (isSupportESIM) {
        HiLog.e(TAG, `get EID, invoke eSIM.getEid`);
        return await eSIM.getEid(1);
      }
    } catch (err) {
      HiLog.e(TAG, `get EID failed. error: ${err?.code} - ${err?.message}`);
    }
    return '';
  }

  static async getIMEIs(callback: (imeiArray: Array<string>) => void) {
    let suportSimCount = telephonySim.getMaxSimCount()
    let imeiArray: string[] = []
    let indexCount = 0;
    let radio = await import('@ohos.telephony.radio');
    for (let index = 0; index < suportSimCount; index++) {
      radio.default.getIMEI(index, (error, value) => {
        if (error) {
          HiLog.e(TAG, `get IMEI, ${index} error: ${error?.message}`);
          imeiArray[index] = ''
        } else {
          HiLog.w(TAG, `get IMEI, ${index} success: ${value.length}`)
          imeiArray[index] = value
        }
        indexCount++
        if (indexCount == suportSimCount) {
          callback(imeiArray)
        }
      });
    }
  }
}