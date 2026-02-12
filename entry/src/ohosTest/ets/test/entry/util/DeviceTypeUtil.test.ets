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
import DeviceTypeUtil from '../../../../../main/ets/util/DeviceTypeUtil'

export default function DeviceTypeUtilTest() {
  describe('DeviceTypeUtilTest', () => {
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
    it('DeviceTypeUtilTest_iisTablet', 0, () => {
      expect(DeviceTypeUtil.isTablet('lg')).assertTrue();
      expect(DeviceTypeUtil.isTablet('lg1')).assertFalse();
    })

    it('DeviceTypeUtilTest_isFoldable', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(false);
      expect(DeviceTypeUtil.isFoldable()).assertFalse();
      mocker.clear(DeviceTypeUtil);
    })

    it('DeviceTypeUtilTest_isStraightBoard', 0, () => {
      expect(DeviceTypeUtil.isStraightBoard('')).assertFalse();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(true);
      expect(DeviceTypeUtil.isStraightBoard('')).assertFalse();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(false);
      expect(DeviceTypeUtil.isStraightBoard('sm')).assertTrue();
      mocker.clear(DeviceTypeUtil);
    })

    it('DeviceTypeUtilTest_isMinFoldAble', 0, () => {
      expect(DeviceTypeUtil.isMinFoldAble('')).assertFalse();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(false);
      expect(DeviceTypeUtil.isMinFoldAble('')).assertFalse();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(true);
      expect(DeviceTypeUtil.isMinFoldAble('sm')).assertTrue();
      mocker.clear(DeviceTypeUtil);
    })

    it('DeviceTypeUtilTest_isMaxFoldAbleExpanded', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(false);
      expect(DeviceTypeUtil.isMaxFoldAbleExpanded('')).assertFalse();
      when(mocker.mockFunc(DeviceTypeUtil, DeviceTypeUtil.isFoldable))().afterReturn(true);
      expect(DeviceTypeUtil.isMaxFoldAbleExpanded('md')).assertTrue();
      mocker.clear(DeviceTypeUtil);
    })
  })
}