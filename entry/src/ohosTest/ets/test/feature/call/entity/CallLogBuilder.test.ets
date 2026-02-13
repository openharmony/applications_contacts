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
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder'

export default function CallLogBuilderTest() {
  describe('CallLogBuilderTest', () => {
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

    it('CallLogBuilderTest_setDisplayName', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.displayName = 'name'
      expect(CallLogData.setDisplayName('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setCallDirection', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.callDirection = 1
      expect(CallLogData.setCallDirection(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setVoicemailUri', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.voicemailUri = 'name'
      expect(CallLogData.setVoicemailUri('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setSimId', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.simId = 1
      expect(CallLogData.setSimId(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setSimType', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.simType = 1
      expect(CallLogData.setSimType(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setIsRead', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.isRead = true
      expect(CallLogData.setIsRead(true)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setRingDuration', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.ringDuration = 1
      expect(CallLogData.setRingDuration(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setTalkDuration', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.talkDuration = 1
      expect(CallLogData.setTalkDuration(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setFormattedNumber', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.formattedNumber = 'name'
      expect(CallLogData.setFormattedNumber('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setQuickSearchKey', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.quickSearchKey = 'name'
      expect(CallLogData.setQuickSearchKey('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setNumberType', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.numberType = 1
      expect(CallLogData.setNumberType(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setNumberTypeName', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.numberTypeName = 'name'
      expect(CallLogData.setNumberTypeName('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setBeginTime', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.beginTime = 1
      expect(CallLogData.setBeginTime(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setEndTime', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.endTime = 1
      expect(CallLogData.setEndTime(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setAnswerState', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.answerState = 1
      expect(CallLogData.setAnswerState(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setCreateTime', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.createTime = 1
      expect(CallLogData.setCreateTime(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setNumberLocation', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.numberLocation = 'name'
      expect(CallLogData.setNumberLocation('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setPhotoId', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.photoId = 1
      expect(CallLogData.setPhotoId(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setPhotoUri', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.photoUri = 'name'
      expect(CallLogData.setPhotoUri('name')).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setCountryIsoCode', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.countryIsoCode = 1
      expect(CallLogData.setCountryIsoCode(1)).assertEqual(CallLogData);
    })
    it('CallLogBuilderTest_setFeatures', 0, () => {
      let CallLogData: CallLogBuilder = new CallLogBuilder(1,'');
      CallLogData.features = 1
      expect(CallLogData.setFeatures(1)).assertEqual(CallLogData);
    })
  })
}