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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit } from '@ohos/hypium'
import simCardState from '../../../../../../main/ets/feature/sim/SimCardState'
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
const TAG = 'SimCardState';

export default function SimCardStateTest() {
  describe('SimCardStateTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('Contacts_SimCardState_isSimActive', 0, () => {
      let isSim1Active = simCardState.isSimActive(0)
      let isSim2Active = simCardState.isSimActive(1)

      expect(false).assertEqual(isSim1Active)
      expect(false).assertEqual(isSim2Active)
    })

    it('Contacts_SimCardState_init_001', 0, () => {
      AppStorage.SetOrCreate<number>('defaultSlot', 1);
      simCardState.init();
      expect(simCardState.haveSimCard).assertFalse();
    })

    it('Contacts_SimCardState_init_002', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.mSimStateArray = [true,false];
      simCardState.init();
      expect(simCardState.haveMultiSimCard).assertFalse();
    })

    it('Contacts_SimCardState_init_003', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.mSimStateArray = [false,true];
      simCardState.init();
      expect(simCardState.haveSimCard).assertTrue();
    })

    it('Contacts_SimCardState_init_004', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.haveMultiSimCard = true;
      simCardState.mSimStateArray = [true,false];
      simCardState.init();
      expect(simCardState.haveMultiSimCard).assertTrue();
    })

    it('Contacts_SimCardState_init_005', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.haveMultiSimCard = true;
      simCardState.mSimStateArray = [false,true];
      simCardState.init();
      expect(simCardState.haveSimCard).assertTrue();
    })

    it('Contacts_SimCardState_removeSimChangeListener', 0, () => {
      simCardState.removeSimChangeListener()
      expect(simCardState.haveSimCard).assertTrue();
    })

    it('Contacts_SimCardState_setListener', 0, () => {
      simCardState.setListener(() => {
      });
      expect(simCardState.haveMultiSimCard).assertTrue();
    })

    it('Contacts_SimCardState_setDefaultSlot', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.haveMultiSimCard = false;
      simCardState.mSimStateArray[0] = true;
      simCardState.setDefaultSlot();
      expect(AppStorage.get('defaultSlot')).assertEqual(0);

      simCardState.mSimStateArray[0] = false;
      simCardState.setDefaultSlot();
      expect(AppStorage.get('defaultSlot')).assertEqual(1);
    })

    it('Contacts_SimCardState_setDefaultSlot_airplaneMode', 0, () => {
      simCardState.haveSimCard = true;
      simCardState.haveMultiSimCard = true;
      AppStorage.setOrCreate('isAirplaneMode', true);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      simCardState.setDefaultSlot();
      mocker.verify('w', [TAG, `get mobile card in airplaneMode`]).once();
      mocker.clear(HiLog);
    })
  })
}