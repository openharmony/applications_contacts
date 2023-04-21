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

import { HiLog } from '../../../../../../common';
import commonEvent from '@ohos.commonEventManager';
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import telephonySim from '@ohos.telephony.sim';

const TAG = 'MissedCallManager'

class MissedCallManager {
  requestMissedCallAction(action, data: any) {
    if ('notification.event.message' == action) {
      if (data && data.phoneNumber) {
        PhoneNumber.fromString(data.phoneNumber).sendMessage();
      }
    } else if ('notification.event.dialBack' == action) {
      if (data && data.phoneNumber) {
        this.autoCall(data.phoneNumber)
      }
    }
    HiLog.i(TAG, `requestMissedCallAction action: ${action}`);
    this.cancelNotification(data);
  }

  private async autoCall(phoneNumber: string) {
    HiLog.i(TAG, 'autoCall:')
    let readySimCount: number = 0;
    let readySim = -1;
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      try {
        const state = await telephonySim.getSimState(i);
        if (state) {
          if (this.isSimReady(state)) {
            readySimCount++;
            readySim = i;
          }
        }
      } catch (err) {
        HiLog.e(TAG, `autoCall, ${i} error: ${JSON.stringify(err.message)}`);
      }
    }
    if (readySimCount == 1 && readySim != -1) {
      PhoneNumber.fromString(phoneNumber).dial({
        accountId: readySim,
      })
    }
  }

  private isSimReady(state) {
    return state == telephonySim.SimState.SIM_STATE_READY || state == telephonySim.SimState.SIM_STATE_LOADED;
  }

  cancelNotification(data?: any) {
    commonEvent.publish("contact.event.CANCEL_MISSED", {
      bundleName: 'com.ohos.contacts',
      parameters: {
        missedCallData: data
      }
    }, (err) => {
      HiLog.w(TAG, JSON.stringify(err))
    })
  }
}

export const missedCallManager: MissedCallManager = new MissedCallManager();