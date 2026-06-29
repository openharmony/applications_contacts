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
import DataShareResultSet from '@ohos.data.DataShareResultSet'
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil'
import MeeTimeDeviceInfoModel from './MeeTimeDeviceInfoModel'

export default class MeeTimeAbilityInfoModel {
  // 账号id
  public extra1: string
  // 账号昵称
  public extra2: string
  // 头像地址
  public extra3: string
  // 能力信息 按位取
  // 二进制 1畅连电话  2畅连视频  3消息
  public extra4: number
  // 能力信息二进制字符串
  public extra4Binary: string
  // 具备畅连能力的手机号；如果联系人对应多个具备畅连能力的手机号，会使用其中的第一个
  public phoneNumber: string = ''

  // 畅连设备信息，发送畅连消息时，需要指定设备信息
  public meeTimeDeviceInfoModelArr: MeeTimeDeviceInfoModel[] = []

  // 联系人id
  public contactId: number = -1

  public copy(meeTimeAbilityInfoModel: MeeTimeAbilityInfoModel) {
    this.extra1 = meeTimeAbilityInfoModel.extra1;
    this.extra2 = meeTimeAbilityInfoModel.extra2;
    this.extra3 = meeTimeAbilityInfoModel.extra3;
    this.extra4 = meeTimeAbilityInfoModel.extra4;

    this.extra4Binary = meeTimeAbilityInfoModel.extra4Binary;
    this.phoneNumber = meeTimeAbilityInfoModel.phoneNumber;
    this.meeTimeDeviceInfoModelArr = meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr;
    this.contactId = meeTimeAbilityInfoModel.contactId;
  }

  public constructor(extra1: string = '', extra2: string = '', extra3: string = '', extra4: number = 0) {
    this.extra1 = extra1;
    this.extra2 = extra2;
    this.extra3 = extra3;
    if (extra4 == undefined || extra4 == null) {
      extra4 = 0
    }
    this.extra4 = extra4;
    this.extra4Binary = StringUtil.paddingLeft(Number(extra4).toString(2), '0', 3);
  }

  static fromResultSet(resultSet: DataShareResultSet): MeeTimeAbilityInfoModel {
    let extra1: string = resultSet.getString(resultSet.getColumnIndex('extra1'))
    let extra2: string = resultSet.getString(resultSet.getColumnIndex('extra2'))
    let extra3: string = resultSet.getString(resultSet.getColumnIndex('extra3'))
    let extra4: number = resultSet.getLong(resultSet.getColumnIndex('extra4'))

    return new MeeTimeAbilityInfoModel(extra1, extra2, extra3, extra4);

  }

  public hasCallAblity() {
    return this.extra4Binary.charAt(0) == '1'
  }

  public hasVedioAbility() {
    return this.extra4Binary.charAt(1) == '1'
  }

  public hasChatAblity() {
    return this.extra4Binary.charAt(2) == '1'
  }


}