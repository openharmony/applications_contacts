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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { MeetimeCalls } from '../../../../../../../../feature/call/src/main/ets/contract/MeetimeCalls'
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder'

export default function MeetimeCallsTest() {
  describe('MeetimeCallsTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    // let meetimeCalls: MeetimeCalls;

    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      // let MeetimeCalls: MeetimeCalls;
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
    it("MeetimeCalls_getCallType_01", 0, () => {
      let callLogDate = new CallLogBuilder(1, '');
      callLogDate.features = 0;
      callLogDate.callDirection = 0;
      callLogDate.answerState = 0;

      const featureTypeNum = 0;
      const callDirectionNum = 0;
      const answerStateNum = 0;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(3)
    })
    it("MeetimeCalls_getCallType_02", 0, () => {
      let callLogDate = new CallLogBuilder(1, '');
      callLogDate.features = 0;
      callLogDate.callDirection = 0;
      callLogDate.answerState = 0;

      const featureTypeNum = 0;
      const callDirectionNum = 0;
      const answerStateNum = 2;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(5)
    })
    it("MeetimeCalls_getCallType_03", 0, () => {
      let callLogDate = new CallLogBuilder(1, '');
      callLogDate.features = 0;
      callLogDate.callDirection = 0;
      callLogDate.answerState = 0;

      const featureTypeNum = 0;
      const callDirectionNum = 0;
      const answerStateNum = 7;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(1)
    })
    it("MeetimeCalls_getCallType_04", 0, () => {
      const featureTypeNum = 0;
      const callDirectionNum = 1;
      const answerStateNum = 0;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(2)
    })
    it("MeetimeCalls_getCallType_05", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 1;
      const answerStateNum = 0;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(3)
    })
    it("MeetimeCalls_getCallType_06", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 1;
      const answerStateNum = 2;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(5)
    })
    it("MeetimeCalls_getCallType_07", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 1;
      const answerStateNum = 3;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(6)
    })
    it("MeetimeCalls_getCallType_08", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 1;
      const answerStateNum = 5;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(7)
    })
    it("MeetimeCalls_getCallType_09", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 1;
      const answerStateNum = 4;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(1)
    })
    it("MeetimeCalls_getCallType_10", 0, () => {
      const featureTypeNum = 1;
      const callDirectionNum = 7;
      const answerStateNum = 4;
      let gerCallType = MeetimeCalls.getCallType(featureTypeNum,callDirectionNum,answerStateNum);
      expect(gerCallType).assertEqual(2)
    })
  })
}