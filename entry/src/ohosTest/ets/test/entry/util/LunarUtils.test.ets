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
import LunarUtils from '../../../../../main/ets/util/LunarUtils';


export default function LunarUtilsTest() {
  describe('LunarUtilsTest', () => {

    it('LunarUtilsTest_lunarMonths', 0, () => {
      expect(JSON.stringify(LunarUtils.lunarMonths(2024))).assertEqual(JSON.stringify([29,30,29,29,30,29,30,30,29,30,30,29]));
    })

    it('LunarUtilsTest_lunarMonths_13', 0, () => {
      expect(JSON.stringify(LunarUtils.lunarMonths(1892))).assertEqual(JSON.stringify([29,29,30,29,29,30,29,30,30,29,30,30,30]));
    })

    it('LunarUtilsTest_betweenLunarDays', 0, () => {
      expect(LunarUtils.betweenLunarDays(2024, 1, 27)).assertEqual(26);
    })

    it('LunarUtilsTest_betweenLunarDays_for', 0, () => {
      expect(LunarUtils.betweenLunarDays(2024, 2, 27)).assertEqual(55);
    })

    it('LunarUtilsTest_toSolar', 0, () => {
      expect(JSON.stringify(LunarUtils.toSolar(2024, 1, 10))).assertEqual(JSON.stringify([2024, 2, 19]));
    })
  })
}