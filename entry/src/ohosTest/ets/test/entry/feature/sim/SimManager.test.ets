/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, it, MockKit, when, ArgumentMatchers, expect } from '@ohos/hypium';
import SimCardState from '../../../../../../main/ets/feature/sim/SimCardState';
import SimManager from '../../../../../../main/ets/feature/sim/SimManager';
import SimOpName from '../../../../../../main/ets/feature/sim/SimOpName';
import VoLteState from '../../../../../../main/ets/feature/sim/VoLteState';

export default function SimManagerTest() {
  describe('SimManagerTest', () => {

    it('SimManagerTest_init', 0, async () => {
      let mocker: MockKit = new MockKit();
      let simManager = new SimManager();
      mocker.mockFunc(simManager, simManager.UpdateSimName);

      await simManager.init();

      mocker.verify('UpdateSimName', []).once();

      mocker.clear(simManager)
    })

    it('SimManagerTest_unInit', 0, () => {
      let mocker: MockKit = new MockKit();
      let simManager = new SimManager();
      mocker.mockFunc(SimOpName, SimOpName.unInitSpnObserver);

      simManager.unInit();

      mocker.verify('unInitSpnObserver', []).once();

      mocker.clear(SimOpName)
    })

    it('SimManagerTest_UpdateSimName_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let simManager = new SimManager();
      mocker.mockFunc(SimOpName, SimOpName.querySimName);

      simManager.UpdateSimName();

      mocker.verify('querySimName', [5]).never();

      mocker.clear(SimOpName);
    })

    it('SimManagerTest_UpdateSimName_002', 0, () => {
      let mocker: MockKit = new MockKit();
      let simManager = new SimManager();
      mocker.mockFunc(SimOpName, SimOpName.querySimName);
      let mockFunc: Function = mocker.mockFunc(SimCardState, SimCardState.isSimActive);
      when(mockFunc)(ArgumentMatchers.anyNumber).afterReturn(true);

      simManager.UpdateSimName();

      mocker.verify('querySimName', [0]).once();

      mocker.clear(SimCardState);
      mocker.clear(SimOpName);
    })

    it('SimManagerTest_recycle', 0, () => {
      let mocker: MockKit = new MockKit();
      let simManager = new SimManager();
      mocker.mockFunc(VoLteState, VoLteState.removeVoLteListeners);

      simManager.recycle();

      mocker.verify('removeVoLteListeners', []).once();

      mocker.clear(VoLteState)
    })

    it('SimManagerTest_getIMEIs', 0, () => {
      let callback: (imeiArray: Array<string>) => void = (async (str: string[]) => {
      });
      SimManager.getIMEIs(callback);
      expect(callback).not().assertNull();
    })
  })
}