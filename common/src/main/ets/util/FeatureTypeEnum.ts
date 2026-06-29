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
 * 通话记录Features字段设备类型
 *
 */
enum FeatureTypeEnum {
  /*
   * 未知设备类型
   */
  FEATURES_DEVICE_TYPE_UNKNOW = -1,

  /*
   * TV设备
   */
  TWENTY_SIX = 26,
  FEATURES_DEVICE_TYPE_TV = 1 << TWENTY_SIX,

  /*
   * PAD设备
   */
  TWENTY_FIVE = 25,
  FEATURES_DEVICE_TYPE_PAD = 1 << TWENTY_FIVE,

  /**
   * 手机设备
   */
  THIRTY = 30,
  FEATURES_DEVICE_TYPE_PHONE = 1 << THIRTY,

  /**
   * 音箱设备
   */
  TWENTY_NINE = 29,
  FEATURES_DEVICE_TYPE_SPEAKER = 1 << TWENTY_NINE,

  /**
   * 手表设备
   */
  TWENTY_SEVEN = 27,
  FEATURES_DEVICE_TYPE_WATCH = 1 << TWENTY_SEVEN,

  /**
   * PC设备
   */
  TWENTY_FOUR = 24,
  FEATURES_DEVICE_TYPE_PC = 1 << TWENTY_FOUR,

  /**
   * 学习智慧屏设备
   */
  TWENTY_THREE = 23,
  FEATURES_DEVICE_TYPE_LEARNING_PAD = 1 << TWENTY_THREE
}

export default FeatureTypeEnum;