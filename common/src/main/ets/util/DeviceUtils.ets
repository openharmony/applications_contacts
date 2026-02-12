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

import DeviceTypeEnum from './DeviceTypeEnum';
import FeatureTypeEnum from './FeatureTypeEnum';
import { HiLog } from './HiLog';

const FIRST_LEVEL_DEVICE = 10;
const SECOND_LEVEL_DEVICE = 20;

const TAG = '[MEETIME_contactsServiceLibrary] DeviceUtils'

/**
 * 查询设备信息获取工具类
 *
 * @author 00354063
 * @since 2023-06-30
 */
export namespace DeviceUtils {

  /**
   * 家庭设备deviceType
   */
  export const FAMILY_DEVICE_TYPES = [
  DeviceTypeEnum.SPEAKER, DeviceTypeEnum.WATCH, DeviceTypeEnum.TV, DeviceTypeEnum.CAMERA, DeviceTypeEnum.LEARNING_PAD,
  DeviceTypeEnum.DEVICE_VALUE_OHOS_ROBOT, DeviceTypeEnum.SMART_CAMERA_HAIQUE, DeviceTypeEnum.SMART_DOORBELL_HAIQUE,
  DeviceTypeEnum.SMART_PROJECTOR_DEV, DeviceTypeEnum.SMART_BOX_DEV, DeviceTypeEnum.INTELLIGENT_CENTRAL_CONTROL_DEV,
  DeviceTypeEnum.PORTABLE_SMART_SCREEN_DEV, DeviceTypeEnum.OFFICE_TREASURE_DEV, DeviceTypeEnum.LEARNING_TABLE_LAMP_DEV,
  ];

  /**
   * 私有设备deviceType
   */
  export const PRIVATE_DEVICE_TYPES = [
  DeviceTypeEnum.HANDSET_APP, DeviceTypeEnum.HANDSET, DeviceTypeEnum.SPEAKER_APP, DeviceTypeEnum.WATCH_APP,
  DeviceTypeEnum.TV_APP, DeviceTypeEnum.PAD, DeviceTypeEnum.CAMERA_APP, DeviceTypeEnum.SMART_WATCH,
  DeviceTypeEnum.PC, DeviceTypeEnum.DEVICE_VALUE_CAR_DEV
  ];

  export const DEFAULT_ZERO = 0;
  export const DEFAULT_ONE = 1;
  export const DEFAULT_ERROR = -1;
  export const DEVICE_ICON_TYPE = 0;
  export const DEVICE_NAME_TYPE = 1;
  export const MEETIME_AUDIO = 0; // 畅连语音
  export const MEETIME_VIDEO = 1; // 畅连视频
  export const NATIVE_CALL = 3; // 运营商通话

  /**
   * 根据deviceType生成通话记录features字段
   *
   * @param deviceType - 设备类型
   * @param mediaType - 畅连通话类型
   * @returns 生成的features字段
   */
  export function generateFeatures(deviceType: DeviceTypeEnum, mediaType: number): number {
    if (deviceType === null || mediaType === null) {
      return DeviceUtils.DEFAULT_ERROR;
    }
    switch (deviceType) {
      case DeviceTypeEnum.HANDSET:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_PHONE | mediaType;
      case DeviceTypeEnum.SPEAKER:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_SPEAKER | mediaType;
      case DeviceTypeEnum.TV:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_TV | mediaType;
      case DeviceTypeEnum.PAD:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_PAD | mediaType;
      case DeviceTypeEnum.WATCH:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_WATCH | mediaType;
      case DeviceTypeEnum.LEARNING_PAD:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_LEARNING_PAD | mediaType;
      case DeviceTypeEnum.PC:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_PC | mediaType;
      default:
        return FeatureTypeEnum.FEATURES_DEVICE_TYPE_UNKNOW;
    }

  }

  /**
   * 根据features字段获取设备类型，返回类型参考DeviceTypeEnum
   *
   * @param features - 通话记录中的features字段
   * @returns 设备类型
   */
  export function getDeviceTypeFromFeatures(features: number): number {
    if (features === null) {
      return DeviceUtils.DEFAULT_ERROR;
    }
    switch (features & ~DeviceUtils.DEFAULT_ONE) {
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_PHONE:
        return DeviceTypeEnum.HANDSET;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_SPEAKER:
        return DeviceTypeEnum.SPEAKER;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_TV:
        return DeviceTypeEnum.TV;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_PAD:
        return DeviceTypeEnum.PAD;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_WATCH:
        return DeviceTypeEnum.WATCH;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_LEARNING_PAD:
        return DeviceTypeEnum.LEARNING_PAD;
      case FeatureTypeEnum.FEATURES_DEVICE_TYPE_PC:
        return DeviceTypeEnum.PC;
      default:
        return DeviceTypeEnum.UNKNOWN;
    }
  }

  /**
   * 根据features字段区分畅连语音，畅连视频，运营商通话
   *
   * @params features - 通话记录中的features字段
   * @params deviceType - 设备类型
   * @returns 0 - 畅连语音 1 - 畅连视频 2 - 运营商通话
   */
  export function getMediaTypeFromFeatures(features: number, deviceType: number = DeviceTypeEnum.HANDSET): number {
    if (features === null) {
      return DeviceUtils.DEFAULT_ERROR;
    }
    let featureType = generateFeatures(deviceType, DeviceUtils.DEFAULT_ZERO);

    // 区分畅连还是运营商，相等为畅连
    if ((featureType & features) === featureType) {
      if (features & DeviceUtils.DEFAULT_ONE) {
        // 畅连视频
        return MEETIME_VIDEO;
      } else {
        return MEETIME_AUDIO;
      }
    } else {
      return NATIVE_CALL;
    }
  }
}