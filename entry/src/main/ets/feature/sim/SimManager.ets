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
import simCardState from './SimCardState'
import spn from './SimOpName'
import voLteState from './VoLteState'

export default class SimManager {
  supportSimCount: number = telephonySim.getMaxSimCount();
  private onSimStateChange = () => {
    for (let index = 0; index < this.supportSimCount; index++) {
      if (simCardState.isSimReady(index)) {
        spn.initSimName(index);
      } else {
        spn.notifySimName(index, "");
      }
    }
  }

  constructor() {
    if (this.supportSimCount > 1) {
      // support muti sim
      simCardState.setListener(this.onSimStateChange);
    }

  }

  init() {
    simCardState.init();
    voLteState.init();
    if (this.supportSimCount > 1) {
      // support muti sim
      spn.initSpnObserver();
    }
  }

  /**
   * recycle
   */
  public recycle() {
    if (this.supportSimCount > 1) {
      // support muti sim
      spn.unsubscribeSpnObserver();
    }
    simCardState.removeSimChangeListener();
    voLteState.removeVoLteListeners();
  }
}