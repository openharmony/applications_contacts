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

/**
 * 设备类型定义
 *
 * 注意：新增删除设备类型原则上需要与caas和云端进行同步。
 */
export enum DeviceTypeEnum {
  /*
   * 未知设备类型
   */
  UNKNOWN = 0,

  /*
   * handset_app
   */
  HANDSET_APP = 1,

  /**
   * handset
   */
  HANDSET = 2,

  /**
   * speaker_app
   */
  SPEAKER_APP = 3,

  /**
   * speaker
   */
  SPEAKER = 4,

  /**
   * watch
   */
  WATCH = 5,

  /**
   * watch_app
   */
  WATCH_APP = 6,

  /**
   * TV
   */
  TV = 7,

  /**
   * TV_APP
   */
  TV_APP = 8,

  /**
   * pad
   */
  PAD = 9,

  /**
   * camera
   */
  CAMERA = 10,

  /**
   * camera_app
   */
  CAMERA_APP = 11,

  /**
   * smart_watch
   */
  SMART_WATCH = 12,

  /**
   * mobile_intelligent_vision
   */
  LEARNING_PAD = 13,

  /**
   * device type for PC
   */
  PC = 16,

  /**
   * device type value for car
   */
  DEVICE_VALUE_CAR_DEV = 17,

  /**
   * device type value for Openharmony Robot
   */
  DEVICE_VALUE_OHOS_ROBOT = 18,

  /**
   * smart_watch_haique
   */
  SMART_CAMERA_HAIQUE = 10000,

  /**
   * smart_doorbell_haique
   */
  SMART_DOORBELL_HAIQUE = 10001,

  /**
   * device type value for Smart Projector
   */
  SMART_PROJECTOR_DEV = 10002,

  /**
   * device type value for Smart box
   */
  SMART_BOX_DEV = 10003,

  /**
   * device type value for Intelligent central control
   */
  INTELLIGENT_CENTRAL_CONTROL_DEV = 10004,

  /**
   * device type value for Portable Smart Screen
   */
  PORTABLE_SMART_SCREEN_DEV = 10006,

  /**
   * device type value for Office treasure
   */
  OFFICE_TREASURE_DEV = 10007,

  /**
   * device type value for Learning Table Lamp
   */
  LEARNING_TABLE_LAMP_DEV = 10008
}


export default DeviceTypeEnum;