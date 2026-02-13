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
import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import {
  DSDS_MODE_TDM,
  DSDS_MODE_V2,
  DSDS_MODE_V3,
  DSDS_MODE_V5
} from '../../../../../main/ets/component/mutisim/DsdaConstants';
import {
  CALLING_FLAG,
  getDialDirectlyAccountId,
  isRinging,
  unregisterCallStateListener,
  registerCallStateListener
} from '../../../../../main/ets/model/CallStateModel';

export default function CallStateModelTest() {
  describe('CallStateModelTest', () => {

    beforeAll(() => {
      AppStorage.delete('combinedCallState');
    })
    afterAll(() => {
      AppStorage.delete('combinedCallState');
    })

    it('testForOnlyDsdsV3', 0, () => {
      AppStorage.delete('combinedCallState')
      expect(getDialDirectlyAccountId(DSDS_MODE_V2)).assertUndefined();
      expect(getDialDirectlyAccountId(DSDS_MODE_TDM)).assertUndefined();
      expect(getDialDirectlyAccountId(DSDS_MODE_V5)).assertUndefined();
    })

    it('testForSingleSimCalling', 0, () => {
      // SIM1
      AppStorage.setOrCreate('combinedCallState', CALLING_FLAG << 0);
      expect(getDialDirectlyAccountId(DSDS_MODE_V3)).assertEqual(0);

      // SIM2
      AppStorage.setOrCreate('combinedCallState', CALLING_FLAG << 1);
      expect(getDialDirectlyAccountId(DSDS_MODE_V3)).assertEqual(1);
    })

    it('testForBothSimCalling', 0, () => {
      AppStorage.setOrCreate('combinedCallState', (CALLING_FLAG << 0) | (CALLING_FLAG << 1));
      expect(getDialDirectlyAccountId(DSDS_MODE_V3)).assertUndefined();
    })

    it('CallStateModelTest_getDialDirectlyAccountId_001', 0, () => {
      AppStorage.setOrCreate('combinedCallState', 0);
      expect(getDialDirectlyAccountId(DSDS_MODE_V3)).assertUndefined();
    })

    it('CallStateModelTest_isRinging', 0, () => {
      expect(isRinging()).assertFalse();
    })
  })
}