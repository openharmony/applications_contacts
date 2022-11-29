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
import deviceInfo from '@ohos.deviceInfo';

const TAG = 'EnvironmentProp';

export default class EnvironmentProp {
  private static readonly DEVICE_TYPE = deviceInfo.deviceType;
  constructor() {
  }

  /**
  * Querying the Device Type
  *
  * default：智能手机
  * tablet：平板
  * tv：智慧屏
  * wearable：智能穿戴
  * liteWearable：轻量级智能穿戴
  * smartVision：智慧视觉设备
  */
  static getDeviceType(): string {
    return this.DEVICE_TYPE;
  }

  static isTablet(): boolean{
    let deviceType = EnvironmentProp.getDeviceType();
    return deviceType === "tablet";
  }
}