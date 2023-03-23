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
import CommonEvent from '@ohos.commonEventManager';
import telephonySim from '@ohos.telephony.sim';
import Constants from "../../../../../../common/src/main/ets/Constants"
import { HiLog } from '../../../../../../common';

const TAG = "SimOpName"

class SimOpName {
  spnList: Array<string | Resource> = [];
  spnEventSubscriber: any;

  constructor() {
    for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
      this.spnList[index] = "";
    }
  }

  /**
   * recycle
   */
  public unsubscribeSpnObserver() {
    if (this.spnEventSubscriber) {
      CommonEvent.unsubscribe(this.spnEventSubscriber);
    }
  }

  public initSpnObserver() {
    let subscribeInfo = {
      events: ['usual.event.SPN_INFO_CHANGED']
    };
    CommonEvent.createSubscriber(subscribeInfo, (err, data) => {
      if (err) {
        HiLog.e(TAG, JSON.stringify(err))
        return
      }
      this.spnEventSubscriber = data;
      CommonEvent.subscribe(data, (err, data) => {
        if (data && data.parameters) {
          let spn = data.parameters.CUR_SPN ? data.parameters.CUR_SPN : data.parameters.CUR_PLMN;
          if (spn) {
            HiLog.i(TAG, `SPN_INFO_CHANGED notify Sim${data.parameters.CUR_SLOT_ID} Name:${spn}`);
            this.notifySimName(data.parameters.CUR_SLOT_ID, spn);
          }
        }
      })
    });
  }

  public initSimName(simId: number) {
    telephonySim.getSimSpn(simId, (error, data) => {
      if (error || !data) {
        HiLog.i(TAG, "getSimSpn error" + JSON.stringify(error))
        telephonySim.getSimOperatorNumeric(simId, (error, opNum) => {
          if (error) {
            HiLog.i(TAG, "getSimOperatorNumeric error" + JSON.stringify(error))
          } else {
            HiLog.i(TAG, "getSimSpn error, opNum:" + opNum)
            this.notifySimName(simId, opNum);
          }
        })
      } else {
        this.notifySimName(simId, data);
      }
    })
  }

  public notifySimName(slot: number, spn: string) {
    HiLog.i(TAG, `notify Sim${slot} Name:${spn}`);
    this.spnList[slot] = spn;
    if (Constants.SPN_CHINA.MOBILE == spn) {
      this.spnList[slot] = $r('app.string.china_mobile')
    } else if (Constants.SPN_CHINA.TELECOM == spn) {
      this.spnList[slot] = $r('app.string.china_telecom')
    } else if (Constants.SPN_CHINA.UNICOM == spn) {
      this.spnList[slot] = $r('app.string.china_unicom')
    }
    AppStorage.SetOrCreate<Array<string | Resource>>("spnList", this.spnList);
  }
}

export default new SimOpName();