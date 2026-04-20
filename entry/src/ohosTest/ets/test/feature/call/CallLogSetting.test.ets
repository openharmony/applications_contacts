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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import CallLogSetting, { MergeRule } from '../../../../../../../feature/call/src/main/ets/CallLogSetting'

export default function CallLogSettingTest() {
  describe('CallLogSettingTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.

    let callLogSetting: CallLogSetting;

    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      AppStorage.clear();
      callLogSetting = new CallLogSetting();
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

    it('CallLogSettingTest_getInstance', 0, () => {
      expect(typeof CallLogSetting.getInstance()).assertEqual(typeof callLogSetting);
    })

    it('CallLogSettingTest_getMergeRule', 0, () => {
      const getMergeRuleTest01 = MergeRule.TIME;
      const MergeRuleTi: MergeRule = callLogSetting.getMergeRule()
      expect(JSON.stringify(MergeRuleTi)).assertEqual(JSON.stringify(getMergeRuleTest01));
    })

    it('CallLogSettingTest_getMergeRule00', 0, () => {
      const getMergeRuleTest00 = MergeRule.TIME;
      AppStorage.SetOrCreate('merge_rule', MergeRule.TIME);
      const MergeRuleTiME: MergeRule = callLogSetting.getMergeRule()
      expect(JSON.stringify(MergeRuleTiME)).assertEqual(JSON.stringify(getMergeRuleTest00));
    })

    it('CallLogSettingTest_getMergeRule01', 0, () => {
      const getMergeRuleTest02 = MergeRule.CONTACT;
      AppStorage.SetOrCreate('merge_rule', MergeRule.CONTACT);
      const MergeRuleTi: MergeRule = callLogSetting.getMergeRule()
      expect(JSON.stringify(MergeRuleTi)).assertEqual(JSON.stringify(getMergeRuleTest02));
    })

    it("CallLogSettingTest_getMergeRule02", 0, () => {
      const getMergeRuleTest01 = MergeRule.TIME;
      const callLogString= 'merge_rule';
      AppStorage.Get(callLogString);
      const MergeRuleTi: MergeRule = callLogSetting.getMergeRule()
      expect(JSON.stringify(MergeRuleTi)).assertEqual(JSON.stringify(getMergeRuleTest01));
    })
    it('CallLogSettingTest_setMergeRule00', 0, () => {
      const setMergeRuleTest = MergeRule.TIME;
      callLogSetting.setMergeRule(MergeRule.TIME)
      const AppStorageTi: MergeRule | undefined = AppStorage.get('merge_rule')
      expect(JSON.stringify(AppStorageTi)).assertEqual(JSON.stringify(setMergeRuleTest));

      const setMergeRuleTestCon = MergeRule.CONTACT;
      callLogSetting.setMergeRule(MergeRule.CONTACT);
      const AppStorageCon: MergeRule | undefined = AppStorage.get('merge_rule')
      expect(JSON.stringify(AppStorageCon)).assertEqual(JSON.stringify(setMergeRuleTestCon));
    })
  })
}