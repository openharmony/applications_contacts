/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
/**
 * VisionGlass相关参数
 */
export class VisionGlassConstants {
  /**
   * want parameters中存储联系人应用是否在vision glass上的key值
   */
  public static readonly XR_CALLER_BUNDLENAME: string = 'ohos.aafwk.param.callerBundleName';
  /**
   * 存储联系人应用在vision glass上，XRDeviceType对应的value值
   */
  public static readonly VISION_GLASS: string = 'com.ohos.visionglass';
  /**
   * 联系人是否在vision glass设备上启动
   */
  public static readonly KEY_IS_IN_VISION_GLASS: string = 'isInVisionGlass';
  /**
   * VisionGlass vendorId
   */
  public static readonly VISION_GLASS_VENDOR_ID: string = '18455';
  /**
   * VisionGlass productId
   */
  public static readonly VISION_GLASS_PRODUCT_ID: string = '16962';
}