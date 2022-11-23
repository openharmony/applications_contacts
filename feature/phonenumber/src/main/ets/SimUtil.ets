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
import telephonySim from '@ohos.telephony.sim';
import observer from '@ohos.telephony.observer';

const TAG = 'SimCardState';

export class SimCardState {
  haveSimCard: boolean = false;
  simId_ONE: number = 0;
  simId_TWO: number = 1;

  public static getInstance(): SimCardState {
    return new SimCardState();
  }

  public getSimCardState() {
    HiLog.i(TAG, '-----getSimCardState-----');
    telephonySim.getSimState(this.simId_ONE, (err, value) => {
      if (err) {
        HiLog.e(TAG, 'getSimCardState, SIM error: ' + JSON.stringify(err.message));
      } else {
        HiLog.i(TAG, 'getSimCardState, SIM value: ' + value);
        if (value == telephonySim.SimState.SIM_STATE_READY
        || value == telephonySim.SimState.SIM_STATE_LOADED) {
          this.haveSimCard = true;
        } else {
          HiLog.i(TAG, 'getSimCardState, SIM_Failed value: ' + value);
          this.haveSimCard = false;
        }
      }
    });
  }

  public addSimChangeListener() {
    HiLog.i(TAG, 'addSimChangeListener start ! ' );
    observer.on('simStateChange', {
      slotId: this.simId_ONE
    }, value => {
      let simState = value.state;
      HiLog.i(TAG, 'addSimChangeListener, SIM value: ' + simState);
      if (simState == telephonySim.SimState.SIM_STATE_READY
      || simState == telephonySim.SimState.SIM_STATE_LOADED) {
        this.haveSimCard = true;
      } else {
        HiLog.i(TAG, 'addSimChangeListener, SIM_Failed value: ' + simState);
        this.haveSimCard = false;
      }
    });
  }
}