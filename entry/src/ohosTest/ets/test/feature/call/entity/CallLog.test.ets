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
import { FeatureType } from '../../../../../../../../feature/call/src/main/ets/contract/MeetimeCalls'
import { CallLog, FeaturesType, FeaturesUtil } from '../../../../../../../../feature/call/src/main/ets/entity/CallLog'
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder'

export default function CallLogTest() {
  describe('CallLogTest', () => {
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

    it('CallLogTest_getCallLogType', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.callDirection = 1;

      const CallTypeNum = 2;
      const CallLogTypeFnEl = new CallLog(CallLogData)
      expect(CallLogTypeFnEl.callType).assertEqual(CallTypeNum);

      CallLogData.callDirection = 0;
      const CallTypeNumIf1 = 1;
      const CallLogTypeFnIf1 = new CallLog(CallLogData)
      expect(CallLogTypeFnIf1.callType).assertEqual(CallTypeNumIf1);

      CallLogData.answerState = 1;
      const CallTypeNumIf2 = 1;
      const CallLogTypeFnIf2 = new CallLog(CallLogData)
      expect(CallLogTypeFnIf2.callType).assertEqual(CallTypeNumIf2);
      expect(CallLogTypeFnIf2.showTime).assertEqual(CallLogTypeFnIf2.beginTime);

      CallLogData.answerState = 0;
      const CallTypeNumIf3 = 3;
      const CallLogTypeFnIf3 = new CallLog(CallLogData)
      expect(CallLogTypeFnIf3.callType).assertEqual(CallTypeNumIf3);
      expect(CallLogTypeFnIf2.showTime).assertEqual(CallLogTypeFnIf2.createTime);

      CallLogData.answerState = 2;
      const CallTypeNumIf4 = 5;
      const CallLogTypeFnIf4 = new CallLog(CallLogData)
      expect(CallLogTypeFnIf4.callType).assertEqual(CallTypeNumIf4);
      expect(CallLogTypeFnIf2.showTime).assertEqual(CallLogTypeFnIf2.createTime);

      CallLogData.answerState = 7;
      const CallLogType = new CallLog(CallLogData);
      expect(CallLogType.callType).assertEqual(7);
    })
    it("CallLogTest_featuresUtil_01", 0, () => {
      const type = FeaturesType.VOICE;
      expect(FeaturesUtil.isType(type,undefined)).assertEqual(false)
    })
    it("CallLogTest_featuresUtil_02", 0, () => {
      const type = FeaturesType.VOICE;
      let result: boolean = FeaturesUtil.isType(type,0);
      expect(result).assertEqual(true);
    })
    it("CallLogTest_featuresUtil_03", 0, () => {
      const type = FeaturesType.VOICE;
      let result: boolean = FeaturesUtil.isType(type,1);
      expect(result).assertEqual(false);
    })
    it("CallLogTest_featuresUtil_04", 0, () => {
      const type = FeaturesType.VIDEO;
      let result: boolean = FeaturesUtil.isType(type,1);
      expect(result).assertEqual(true);
    })

  })
}