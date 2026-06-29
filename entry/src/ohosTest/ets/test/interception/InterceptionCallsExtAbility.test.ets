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
import { describe, it, expect, MockKit } from '@ohos/hypium'
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import SimCardState from '../../../../main/ets/feature/sim/SimCardState';
import SimManager from '../../../../main/ets/feature/sim/SimManager';
import InterceptionCallsExtAbility from '../../../../main/ets/interception/InterceptionCallsExtAbility';

export default function InterceptionCallsExtAbilityTest() {

  describe('InterceptionCallsExtAbilityTest', () => {

    it("interceptionCallsExtAbilityTest_onCreate", 0, () => {
      let interceptionCallsExtAbility: InterceptionCallsExtAbility = new InterceptionCallsExtAbility();
      interceptionCallsExtAbility.onCreate();
      expect(interceptionCallsExtAbility.count).assertEqual(0);
    })

    it("interceptionCallsExtAbilityTest_onDestroy", 0, () => {
      let interceptionCallsExtAbility: InterceptionCallsExtAbility = new InterceptionCallsExtAbility();
      interceptionCallsExtAbility.onDestroy();
      expect(interceptionCallsExtAbility.count).assertEqual(0);
    })

    it("interceptionCallsExtAbilityTest_onForeground", 0, () => {
      let interceptionCallsExtAbility: InterceptionCallsExtAbility = new InterceptionCallsExtAbility();
      interceptionCallsExtAbility.onForeground();
      expect(interceptionCallsExtAbility.count).assertEqual(0);
    })

    it("interceptionCallsExtAbilityTest_onBackground", 0, () => {
      let interceptionCallsExtAbility: InterceptionCallsExtAbility = new InterceptionCallsExtAbility();
      interceptionCallsExtAbility.onBackground();
      expect(interceptionCallsExtAbility.count).assertEqual(0);
    })

  })

}