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
import { describe, expect, it } from '@ohos/hypium';
import VoLteState from '../../../../../../main/ets/feature/sim/VoLteState';

export default function VoLteStateTest() {
  describe('VoLteStateTest', () => {
    it('Contacts_VoLteStateTest_init', 0, () => {
      VoLteState.init();
      expect(VoLteState.haveVoLteReg).assertFalse();
    })

    it('Contacts_VoLteStateTest_removeVoLteListeners', 0, () => {
      VoLteState.removeVoLteListeners();
      expect(VoLteState.haveVoLteReg).assertFalse();
    })

    it('Contacts_VoLteStateTest_setListener', 0, () => {
      VoLteState.setListener(() => {
      });
      expect(VoLteState.haveVoLteReg).assertFalse();
    })
  })
}