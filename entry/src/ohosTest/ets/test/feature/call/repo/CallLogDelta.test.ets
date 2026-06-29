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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { CallLog } from '../../../../../../../../feature/call'
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog'
import Calls from '../../../../../../../../feature/call/src/main/ets/contract/Calls'
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder'
import CallLogDelta from '../../../../../../../../feature/call/src/main/ets/repo/CallLogDelta'


export default function CallLogDeltaTest() {
  describe('CallLogDeltaTest', () => {
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

    it('CallLogDeltaTest_createValuesBucket_02', 0, () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, ''));
      let callLogDelta = new CallLogDelta(callLog);

      let res = callLogDelta.createValuesBucket();

      let result: Record<string, string | number | boolean> = {};
      result[Calls.PHONE_NUMBER] = callLog.phoneNumber;
      result[Calls.DISPLAY_NAME] = callLog.displayName;
      result[Calls.CALL_DIRECTION] = callLog.callDirection;
      result[Calls.VOICEMAIL_URI] = callLog.voicemailUri;
      result[Calls.SIM_TYPE] = callLog.simType;
      result[Calls.IS_SATELLITE] = callLog.isSatellite;
      result[Calls.IS_READ] = callLog.isRead;
      result[Calls.FEATURES] = callLog.features;
      result[Calls.RING_DURATION] = callLog.ringDuration;
      result[Calls.TALK_DURATION] = callLog.talkDuration;
      result[Calls.FORMAT_NUMBER] = callLog.formattedNumber;
      result[Calls.QUICK_SEARCH_KEY] = callLog.quickSearchKey;
      result[Calls.NUMBER_TYPE] = callLog.numberType;
      result[Calls.BEGIN_TIME] = callLog.beginTime;
      result[Calls.END_TIME] = callLog.endTime;
      result[Calls.ANSWER_STATE] = callLog.answerState;
      result[Calls.CREATE_TIME] = callLog.createTime;
      result[Calls.NUMBER_LOCATION] = callLog.numberLocation;
      result[Calls.PHOTO_ID] = callLog.photoId;
      result[Calls.PHOTO_URI] = callLog.photoUri;
      result[Calls.COUNTRY_ISO_CODE] = callLog.countryIsoCode;

      expect(JSON.stringify(res)).assertEqual(JSON.stringify(result))
    })
  })
}