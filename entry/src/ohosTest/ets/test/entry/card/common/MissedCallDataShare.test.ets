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
import { describe, beforeEach, it, expect } from '@ohos/hypium'
import { MissedCallDataShare } from '../../../../../../main/ets/card/common/MissedCallDataShare';

export default function MissedCallDataShareTest() {
  describe('MissedCallDataShareTest', () => {
    let missedCallDataShare: MissedCallDataShare;

    beforeEach(() => {
      missedCallDataShare = new MissedCallDataShare();
    })

    it('MissedCallDataShareTest_initData', 0, async () => {
      missedCallDataShare.initData();
      expect(missedCallDataShare.flag).assertTrue();
    })

    it('MissedCallDataShareTest_setMissedLogToRead', 0, async () => {
      missedCallDataShare.setMissedLogToRead(['phone_number']);
      expect(missedCallDataShare.flag).assertTrue();
    })
  })
}