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
import { describe, it, expect } from '@ohos/hypium';
import VoicemailManager from '../../../../../../main/ets/feature/sim/VoicemailManager';
import { StringUtil } from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';

export default function VoicemailManagerTest() {
  describe('VoicemailManagerTest', () => {

    //如果测试手机有sim卡，则结果是sim卡的手机号
    it('VoicemailManagerTest_getVoicemailNumber_noSIM', 0, async () => {
      let number: string = await VoicemailManager.getInstance().getVoicemailNumber(0);
      number != '' ? expect(StringUtil.isEmpty(number)).assertFalse() : expect(number).assertEqual('');
    })

    it('VoicemailManagerTest_setVoicemailInfo_noSIM', 0, () => {
      VoicemailManager.getInstance().setVoicemailInfo(0, 'testName', 'testValue', (data: number) => {
        expect(data).not().assertEqual(0);
      });
    })

    it('StringUtil', 0, async () => {
      let res: Boolean = StringUtil.isEmpty('1')
      expect(res).assertEqual(false);
    })
  })
}