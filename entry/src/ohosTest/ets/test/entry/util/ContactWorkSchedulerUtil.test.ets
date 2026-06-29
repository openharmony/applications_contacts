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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { ContactWorkSchedulerUtil } from '../../../../../main/ets/util/ContactWorkSchedulerUtil';

export default function ContactWorkSchedulerUtilTest() {
  describe('ContactWorkSchedulerUtilTest', () => {
    let contactWorkSchedulerUtil: ContactWorkSchedulerUtil;

    beforeEach(() => {
      contactWorkSchedulerUtil = new ContactWorkSchedulerUtil();
    })

    it('ContactWorkSchedulerUtilTest_getInstance', 0, () => {
      expect(typeof ContactWorkSchedulerUtil.getInstance()).assertEqual(typeof contactWorkSchedulerUtil);
    })

    it('ContactWorkSchedulerUtilTest_simUsedCount', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(contactWorkSchedulerUtil, contactWorkSchedulerUtil.getMaxSimCount);
      when(mockFunc)().afterReturn(0);
      expect((await contactWorkSchedulerUtil.simUsedCount()).NUM).assertEqual(0);
      mocker.clear(contactWorkSchedulerUtil);
    })
  })
}