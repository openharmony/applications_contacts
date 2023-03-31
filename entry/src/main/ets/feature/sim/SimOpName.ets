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
import { HiLog } from '../../../../../../common';
import radio from '@ohos.telephony.radio';
import observer from '@ohos.telephony.observer';

const TAG = "SimOpName"

class SimOpName {
  spnList: Array<string | Resource> = [];

  constructor() {
    for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
      this.spnList[index] = "";
    }
  }

  /**
   * recycle
   */
  public unsubscribeSpnObserver() {
      observer.off('networkStateChange');
  }

  public initSpnObserver() {
    try {
      for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
        observer.on('networkStateChange', { slotId: index }, data => {
          if (!data) {
            HiLog.e(TAG, "there is something wrong with networkState");
            return
          } else {
            HiLog.i(TAG, "observer ON data : " + JSON.stringify(data));
            let spn = data.longOperatorName ? data.longOperatorName : data.plmnNumeric;
            if (spn) {
              HiLog.i(TAG, `networkStateChange notify Sim${index} Name:${spn}`);
              this.notifySimName(index, spn);
            }
          }
        });
      }
    } catch (err) {
      HiLog.e(TAG, "get error: " + JSON.stringify(err));
    }
  }

  public initSimName(simId: number) {
    radio.getNetworkState(simId, (error, data) => {
      if (error || !data) {
        HiLog.e(TAG, "getNetworkState error: " + JSON.stringify(error));
      } else {
        this.notifySimName(simId, data.longOperatorName);
      }
    })
  }

  public notifySimName(slot: number, spn: string) {
    HiLog.i(TAG, `notify Sim${slot} Name:${spn}`);
    this.spnList[slot] = spn;
    AppStorage.SetOrCreate<Array<string | Resource>>("spnList", this.spnList);
  }
}

export default new SimOpName();