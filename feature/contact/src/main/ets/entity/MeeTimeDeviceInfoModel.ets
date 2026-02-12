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
 * 畅连设备信息；对应contact_data表，type_id为15
 */
export default class MeeTimeDeviceInfoModel {
  // 设备id，对应contact_data表，type_id为15，extend4字段
  public comId: string

  // 设备类型， 对应contact_data表，type_id为15，extend1字段
  public deviceType: number

  // 设备类型， 对应contact_data表，extend5字段
  public profile: string

  constructor(comId: string = '', deviceType: number = -1, profile: string = '') {
    this.comId = comId
    this.deviceType = deviceType
    this.profile = profile
  }

}