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
import DeviceTypeEnum from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/DeviceTypeEnum'
import { DeviceUtils } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/DeviceUtils'
import FeatureTypeEnum from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/FeatureTypeEnum'

export default function DeviceUtilsTest() {
  describe('DeviceUtilsTest', () => {
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
    it('DeviceUtilsTest_generateFeatures_null', 0, () => {
      let duRes = DeviceUtils.generateFeatures(null, null);
      expect(duRes).assertEqual(DeviceUtils.DEFAULT_ERROR);
    })
    it('DeviceUtilsTest_generateFeatures1', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.HANDSET,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PHONE);
    })
    it('DeviceUtilsTest_generateFeatures2', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.SPEAKER,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_SPEAKER);
    })
    it('DeviceUtilsTest_generateFeatures3', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.TV,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_TV);
    })
    it('DeviceUtilsTest_generateFeatures4', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.PAD,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PAD);
    })
    it('DeviceUtilsTest_generateFeatures5', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.WATCH,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_WATCH);
    })
    it('DeviceUtilsTest_generateFeatures6', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.LEARNING_PAD,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_LEARNING_PAD);
    })
    it('DeviceUtilsTest_generateFeatures7', 0, () => {
      let duRes = DeviceUtils.generateFeatures(DeviceTypeEnum.PC,0);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PC);
    })
    it('DeviceUtilsTest_generateFeatures8', 0, () => {
      let duRes = DeviceUtils.generateFeatures(100,100);
      expect(duRes).assertEqual(FeatureTypeEnum.FEATURES_DEVICE_TYPE_UNKNOW);
    })

    it('DeviceUtilsTest_getDeviceTypeFromFeatures_null', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(null);
      expect(duRes).assertEqual(DeviceUtils.DEFAULT_ERROR);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures1', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PHONE);
      expect(duRes).assertEqual(DeviceTypeEnum.HANDSET);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures2', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_SPEAKER);
      expect(duRes).assertEqual(DeviceTypeEnum.SPEAKER);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures3', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_TV);
      expect(duRes).assertEqual(DeviceTypeEnum.TV);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures4', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PAD);
      expect(duRes).assertEqual(DeviceTypeEnum.PAD);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures5', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_WATCH);
      expect(duRes).assertEqual(DeviceTypeEnum.WATCH);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures6', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_LEARNING_PAD);
      expect(duRes).assertEqual(DeviceTypeEnum.LEARNING_PAD);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures7', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(FeatureTypeEnum.FEATURES_DEVICE_TYPE_PC);
      expect(duRes).assertEqual(DeviceTypeEnum.PC);
    })
    it('DeviceUtilsTest_getDeviceTypeFromFeatures8', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(100);
      expect(duRes).assertEqual(DeviceTypeEnum.UNKNOWN);
    })

    it('DeviceUtilsTest_getMediaTypeFromFeatures_null', 0, () => {
      let duRes = DeviceUtils.getDeviceTypeFromFeatures(null);
      expect(duRes).assertEqual(DeviceUtils.DEFAULT_ERROR);
    })
    it('DeviceUtilsTest_getMediaTypeFromFeatures', 0, () => {
      expect(DeviceUtils.getMediaTypeFromFeatures(null)).assertEqual(DeviceUtils.DEFAULT_ERROR);

      let duRes = DeviceUtils.getMediaTypeFromFeatures(0, 2);
      expect(duRes).assertEqual(3);
    })
  })
}