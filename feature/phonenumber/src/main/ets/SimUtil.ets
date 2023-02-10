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

import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import SharedPreferencesUtils from "./SharedPreferencesUtils";

export const simId_NONE: number = -1;

export const simId_ONE: number = 0;

export const simId_TWO: number = 1;

const INTERVAL = 1000;

const TIME_OUT = 10;

const KEY_LAST_ID: string = "last_used_sim_key"

const TAG = 'SimUtil';

interface Observer {
  (): void;
}

class SimCardState {
  mSimStateArray: Array<telephonySim.SimState> =
    [telephonySim.SimState.SIM_STATE_UNKNOWN, telephonySim.SimState.SIM_STATE_UNKNOWN];
  haveSimCard: boolean = false;
  haveMultiSimCard: boolean = false;
  private observers: Observer[] = [];

  constructor() {
    this.addSimChangeListener();
    this.getSimCardState();
  }

  /**
   * attachObserver The subscription management methods.
   *
   * @param Observer the Observer need attach
   */
  public attachObserver(observer: Observer): void {
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return console.log('Subject: Observer has been attached already.');
    }
    HiLog.d(TAG, 'Subject: Attached an observer.');
    this.observers.push(observer);
    if (observer) {
      observer();
    }
  }

  /**
   * detachObserver
   *
   * @param Observer the Observer need detach
   */
  public detachObserver(observer: Observer): void {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      return console.log('Subject: Nonexistent observer.');
    }

    this.observers.splice(observerIndex, 1);
    HiLog.d(TAG, 'Subject: Detached an observer.');
  }

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

  private notify(): void {
    HiLog.d(TAG, 'sim state changed: Notifying observers...');
    for (const observer of this.observers) {
      observer();
    }
  }

  private addSimChangeListener() {
    HiLog.i(TAG, 'addSimChangeListener start ! ');
    observer.on('simStateChange', {
      slotId: simId_ONE
    }, value => {
      let simState = value?.state;
      HiLog.i(TAG, 'simStateChange for simId_ONE, SIM value: ' + simState);
      this.parseSimCardStateForSlot(simId_ONE, simState);
    });
    observer.on('simStateChange', {
      slotId: simId_TWO
    }, value => {
      let simState = value?.state;
      HiLog.i(TAG, 'simStateChange for simId_TWO, SIM value: ' + simState);
      this.parseSimCardStateForSlot(simId_TWO, simState);
    });
  }

  private getSimCardState() {
    HiLog.i(TAG, '-----getSimCardState-----');
    telephonySim.getSimState(simId_ONE, (err, value) => {
      if (err) {
        HiLog.e(TAG, 'getSimCardState, simId_ONE error: ' + JSON.stringify(err.message));
      } else {
        this.parseSimCardStateForSlot(simId_ONE, value)
      }
    });
    telephonySim.getSimState(simId_TWO, (err, value) => {
      if (err) {
        HiLog.e(TAG, 'getSimCardState, simId_TWO error: ' + JSON.stringify(err.message));
      } else {
        this.parseSimCardStateForSlot(simId_TWO, value)
      }
    });
  }

  private parseSimCardStateForSlot(slotId: number, value) {
    HiLog.i(TAG, 'parseSimCardStateForSlot, slotId: ' + slotId + ', SimCardState value: ' + value);
    let changed: boolean = (value != this.mSimStateArray[slotId]);
    if (!changed) {
      return;
    }
    this.mSimStateArray[slotId] = value;
    this.haveSimCard = this.isSimReady(simId_ONE) || this.isSimReady(simId_TWO);
    this.haveMultiSimCard = this.isSimReady(simId_ONE) && this.isSimReady(simId_TWO);
    HiLog.i(TAG, 'parseSimCardStateForSlot sim state changed, haveSimCard: ' + this.haveSimCard +
        ', haveMultiSimCard: ' + this.haveMultiSimCard);
    this.notify();
  }
}

export const simCardState: SimCardState = new SimCardState();

/**
 * getLastUsedSlotId
 *
 * @return the last sim id number used to dail
 */
export function getLastUsedSlotId(): Promise<number> {
  return new Promise<number>(async (resolve) => {
    const value = <number> await SharedPreferencesUtils.getFromPreferences(KEY_LAST_ID, simId_NONE)
    HiLog.i(TAG, "getLastUsedSlotId:" + value);
    resolve(value)
  });
}

/**
 * setLastUsedSlotId
 *
 * @param simId the sim id number
 */
export function setLastUsedSlotId(simId: number) {
  HiLog.i(TAG, "setLastUsedSlotId:" + simId)
  SharedPreferencesUtils.getFromPreferences(KEY_LAST_ID, simId);
}

/**
 * getSimName
 *
 * @param simId the sim id number
 * @return the sim name to show
 */
export function getSimName(simId: number): Promise<string> {
  return new Promise((resolveInner) => {
    telephonySim.getSimSpn(simId, (error, data) => {
      if (error || !data) {
        HiLog.i(TAG, "getSimSpn error" + JSON.stringify(error))
        telephonySim.getSimOperatorNumeric(simId, (error, opNum) => {
          if (error) {
            HiLog.i(TAG, "getSimOperatorNumeric error" + JSON.stringify(error))
          } else {
            HiLog.i(TAG, "getSimSpn error, opNum:" + opNum)
            resolveInner(opNum);
          }
        })
      } else {
        resolveInner(data);
      }
    })
  })
}