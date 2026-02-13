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
import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import EnvironmentProp, { DeviceUtil } from '../../../../../main/ets/feature/EnvironmentProp'
import display from '@ohos.display';
import { deviceInfo } from '@kit.BasicServicesKit';

export default function EnvironmentPropTest() {
  describe('EnvironmentPropTest', () => {

    it('Contacts_EnvironmentPropTest_isTablet', 0, () => {
      expect(EnvironmentProp.isTablet()).assertFalse();
    })

    it('Contacts_EnvironmentPropTest_isTabletOrPC', 0, () => {
      expect(EnvironmentProp.isTabletOrPC()).assertFalse();
    })

    it('Contacts_EnvironmentPropTest_isDeviceTypeTablet', 0, () => {
      expect(EnvironmentProp.isDeviceTypeTablet()).assertEqual(deviceInfo.deviceType === 'tablet');
    })

    it('Contacts_EnvironmentPropTest_isPC', 0, () => {
      expect(EnvironmentProp.isPC()).assertFalse();
    })

    it("DeviceUtil_getScreenFoldStatus_01", 0, () => {
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(4);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(EnvironmentProp, EnvironmentProp.getFoldStatus);
      when(mockFunc)().afterReturn(display.FoldStatus.FOLD_STATUS_EXPANDED);
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(1);
      when(mockFunc)().afterReturn(display.FoldStatus.FOLD_STATUS_FOLDED);
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(2);
      when(mockFunc)().afterReturn(display.FoldStatus.FOLD_STATUS_HALF_FOLDED);
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(3);
      when(mockFunc)().afterReturn(display.FoldStatus.FOLD_STATUS_UNKNOWN);
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(4);
      when(mockFunc)().afterReturn('111');
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(0);
      mocker.clear(EnvironmentProp);
    })

    it('Contacts_EnvironmentPropTest_isPhone', 0, () => {
      expect(EnvironmentProp.isPhone()).assertTrue();
    })
  })
}