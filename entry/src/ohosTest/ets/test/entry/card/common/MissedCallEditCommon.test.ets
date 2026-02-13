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
import { describe, beforeEach, it, expect, MockKit } from '@ohos/hypium';
import MissedCallEditCommon from '../../../../../../main/ets/card/common/MissedCallEditCommon';
import { formBindingData } from '@kit.FormKit';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common'

export default function MissedCallEditCommonTest() {
  describe('MissedCallEditCommonTest', () => {
    const TAG = 'missedCallEditCommon';

    let missedCallEditCommon: MissedCallEditCommon;

    beforeEach(() => {
      missedCallEditCommon = new MissedCallEditCommon();
    })

    it('MissedCallEditCommonTest_updateToCard', 0, async () => {
      let data: formBindingData.FormBindingData = {
        data: {}
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      missedCallEditCommon.updateToCard('1',data);
      mocker.verify('i', [TAG, '[formProvider updateForm] success']).never();
      mocker.clear(HiLog);
    })

  })
}