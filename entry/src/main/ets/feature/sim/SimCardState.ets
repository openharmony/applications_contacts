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
import observer from '@ohos.telephony.observer';
import telephonySim from '@ohos.telephony.sim';
import { HiLog } from '../../../../../../common';

export const simId_NONE: number = -1;

export const simId_ONE: number = 0;

export const simId_TWO: number = 1;

const TAG = 'SimCardState';

class SimCardState {
  mListener: () => void;
  mSimStateArray: Array<telephonySim.SimState> =
    [telephonySim.SimState.SIM_STATE_UNKNOWN, telephonySim.SimState.SIM_STATE_UNKNOWN];
  haveSimCard: boolean = false;
  haveMultiSimCard: boolean = false;

  /**
   * isSimReady
   *
   * @param slotId the sim slot id number
   * @return boolean the sim is ready or not
   */
  public isSimReady(slotId: number) {
    return this.mSimStateArray[slotId] == telephonySim.SimState.SIM_STATE_READY || this.mSimStateArray[slotId]
    == telephonySim.SimState.SIM_STATE_LOADED;
  }

  /*
   * Initialization is required only when callback is required. Callback is required to ensure data accuracy and timeliness.
   */
  public init() {
    try {
      HiLog.i(TAG, "SimCardState, init.")
      this.addSimChangeListener();
      this.getSimCardState();
    } catch (error) {
      HiLog.w(TAG, "SimCardState, get sim state error.")
    }
  }

  public removeSimChangeListener() {
    HiLog.i(TAG, 'removeSimChangeListener ! ');
    observer.off('simStateChange');
  }

  public setListener(listener: () => void) {
    this.mListener = listener;
  }

  private addSimChangeListener() {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      observer.on('simStateChange', {
        slotId: i
      }, value => {
        let simState = value?.state;
        HiLog.i(TAG, `simStateChange for ${i}, SIM value: ` + simState);
        this.parseSimCardStateForSlot(i, simState);
      });
    }
  }

  private getSimCardState() {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      telephonySim.getSimState(i, (err, value) => {
        if (err) {
          HiLog.e(TAG, `getSimCardState, ${i} error: ${JSON.stringify(err.message)}`);
        } else {
          this.parseSimCardStateForSlot(i, value)
        }
      });
    }
  }

  private parseSimCardStateForSlot(slotId: number, value) {
    let changed: boolean = (value != this.mSimStateArray[slotId]);
    if (!changed) {
      return;
    }
    this.mSimStateArray[slotId] = value;
    this.haveSimCard = this.isSimReady(simId_ONE) || this.isSimReady(simId_TWO);
    this.haveMultiSimCard = this.isSimReady(simId_ONE) && this.isSimReady(simId_TWO);
    AppStorage.SetOrCreate<boolean>("haveMultiSimCard", this.haveMultiSimCard);
    AppStorage.SetOrCreate<boolean>("haveSimCard", this.haveSimCard);
    HiLog.i(TAG, `parseSimCardStateForSlot sim ${slotId}} state ${value}}, haveSimCard: ` + this.haveSimCard +
    ', haveMultiSimCard: ' + this.haveMultiSimCard);
    this.setDefaultSlot();
    if (this.mListener) {
      this.mListener();
    }
  }

  private setDefaultSlot() {
    if (this.haveSimCard) {
      if (!this.haveMultiSimCard) {
        if (this.isSimReady(simId_ONE)) {
          AppStorage.SetOrCreate<number>('defaultSlot', simId_ONE);
        } else {
          AppStorage.SetOrCreate<number>('defaultSlot', simId_TWO);
        }
      } else {
        telephonySim.getDefaultVoiceSlotId((err, slot: number) => {
          if (err) {
            HiLog.e(TAG, `getDefaultVoiceSlotId, ${slot} error: ${JSON.stringify(err)}`);
          } else {
            AppStorage.SetOrCreate<number>('defaultSlot', slot);
          }
        })
      }
    } else {
      if (AppStorage.Has('defaultSlot')) {
        AppStorage.Delete('defaultSlot')
      }
    }
  }
}

export default new SimCardState();