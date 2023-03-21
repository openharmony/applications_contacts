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
import radio from '@ohos.telephony.radio'
import { HiLog } from '../../../../../../common';
import telephonySim from '@ohos.telephony.sim';

const TAG = 'VoLteState';

class VoLteState {
  haveVoLteReg: boolean = false;
  voLteRegStates: boolean[] = [false, false]
  mListener: () => void;

  public init() {
    try {
      for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
        this.initVoLteListener(i);
      }
    } catch (error) {
      HiLog.w(TAG, "VoLteState, get VoLte state error:" + JSON.stringify(error));
    }
  }

  public removeVoLteListeners() {
    try {
      for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
        this.removeVoLteListener(i);
      }
    } catch (error) {
      HiLog.w(TAG, "VoLteState, removeVoLteListeners error:" + JSON.stringify(error));
    }
  }

  public setListener(listener: () => void) {
    this.mListener = listener;
  }

  private initVoLteListener(slot: number) {
    HiLog.i(TAG, 'initVoLteListener slot:' + slot);
    radio.on('imsRegStateChange', slot, radio.ImsServiceType.TYPE_VOICE, data => {
      HiLog.i(TAG, `callback: data->${JSON.stringify(data)}`);
      this.parseVoLteState(slot, data.imsRegState)
    });
    radio.getImsRegInfo(slot, radio.ImsServiceType.TYPE_VOICE, (err, data) => {
      if (err) {
        HiLog.w(TAG, "getImsRegInfo err:" + JSON.stringify(err))
      } else {
        HiLog.i(TAG, `getImsRegInfo: data->${JSON.stringify(data)}`);
        this.parseVoLteState(slot, data.imsRegState);
      }
    });
  }

  private removeVoLteListener(slot: number) {
    HiLog.d(TAG, `removeVoLteListener slot:${slot}`);
    radio.off('imsRegStateChange', slot, radio.ImsServiceType.TYPE_VOICE);
  }

  private parseVoLteState(slotId: number, data) {
    const voLte = (data == radio.ImsRegState.IMS_REGISTERED);
    const changed = (voLte != this.voLteRegStates[slotId]);
    if (!changed) {
      HiLog.w(TAG, `parseVoLteState: state not changed slotId${slotId}  data->${data}`);
      return;
    }
    this.voLteRegStates[slotId] = voLte;
    this.haveVoLteReg = this.voLteRegStates[0] || this.voLteRegStates[1];
    AppStorage.SetOrCreate<boolean>("haveVoLteReg", this.haveVoLteReg);
    AppStorage.SetOrCreate<boolean[]>("voLteRegStates", this.voLteRegStates);
    HiLog.i(TAG, `parseVoLteState: state changed slotId${slotId}  volte->${voLte}, haveVoLteReg:${this.haveVoLteReg}`);
    if (this.mListener) {
      this.mListener();
    }
  }
}

export default new VoLteState();