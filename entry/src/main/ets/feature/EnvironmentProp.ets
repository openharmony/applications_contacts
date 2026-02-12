/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import display from '@ohos.display';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog'
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'EnvironmentProp';

export default class EnvironmentProp {

  static getFoldStatus() {
    return display.getFoldStatus();
  }

  constructor() {
  }

  static isTablet(): boolean {
    if (AppStorage.get('isSmallPad')) {
      return true;
    }
    let breakpoint: string | undefined = AppStorage.get('breakpoint');
    return breakpoint === 'lg';
  }

  static isTabletOrPC(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === '2in1' || deviceTypeInfo === 'tablet';
  }

  static isDeviceTypeTablet(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === 'tablet';
  }

  static isPC(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === '2in1';
  }

  static isPhone(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === 'phone';
  }
}

export class DeviceUtil {

  constructor() {
  }

  static isFoldable(): boolean {
    let ret: boolean = false;
    try {
      ret = display.isFoldable();
    } catch (exception) {
    }
    if (ret === undefined || !ret) {
      return false;
    }
    return true;
  }

  /**
   * get screen FoldStatus
   *
   * @returns {number} 1：折叠完全展开 2：折叠状态 3：完全展开和折叠之间 4：未知
   */
  static getScreenFoldStatus(): number {
    let status: number = FoldStatusEnum.DEFAULT;
    try {
      switch (EnvironmentProp.getFoldStatus()) {
        case display.FoldStatus.FOLD_STATUS_EXPANDED:
          status = FoldStatusEnum.FOLD_STATUS_EXPANDED;
          break;
        case display.FoldStatus.FOLD_STATUS_FOLDED:
          status = FoldStatusEnum.FOLD_STATUS_FOLDED;
          break;
        case display.FoldStatus.FOLD_STATUS_HALF_FOLDED:
          status = FoldStatusEnum.FOLD_STATUS_HALF_FOLDED;
          break;
        case display.FoldStatus.FOLD_STATUS_UNKNOWN:
          status = FoldStatusEnum.FOLD_STATUS_UNKNOWN;
          break;
        default:
          status = FoldStatusEnum.DEFAULT;
          break;
      }
    } catch (exception) {
      HiLog.e(TAG, `Failed to obtain the fold status. Code: ${exception?.code},${exception?.message}`);
    }
    return status;
  }
}

enum FoldStatusEnum {
  DEFAULT = 0,
  FOLD_STATUS_EXPANDED = 1,
  FOLD_STATUS_FOLDED = 2,
  FOLD_STATUS_HALF_FOLDED = 3,
  FOLD_STATUS_UNKNOWN = 4
}