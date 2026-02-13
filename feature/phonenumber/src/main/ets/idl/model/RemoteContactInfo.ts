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

import type rpc from '@ohos.rpc';

/**
 * 此通通话对端信息
 */
export default class RemoteContactInfo {
  /**
   * 对端手机号码
   * 格式：+国际电话区号XXXXXXXXXXX
   */
  public phoneNumber: string;

  /**
   * 畅连联系人id
   */
  public contactId: number;

  public deviceType: number;

  /**
   * 对端的设备通信标识
   */
  public deviceComId: string;

  constructor(phoneNumber: string, contactId?: number, deviceComId?: string, deviceType?: number) {
    this.phoneNumber = phoneNumber;
    this.contactId = contactId;
    this.deviceComId = deviceComId;
    this.deviceType = deviceType;
  }

  /**
   * 将此可序列对象封送到MessageSequence
   *
   * @param messageSequence
   * @returns true:封送成功,false:封送失败
   * @function
   */
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    messageSequence.writeString(this.phoneNumber);
    // 拨打畅联家庭设备时，会有设备类型和设备id信息
    if (this.deviceType) {
      if (this.contactId) {
        messageSequence.writeInt(this.contactId);
      } else {
        // 没有contactId，传0；
        // 畅联读取时，按顺序读取，需要有contactId信息
        // 否则，会把读取int值，会把deviceType读到contactId，后续读取也会错位
        messageSequence.writeInt(0);
      }
      if (this.deviceType) {
        messageSequence.writeInt(this.deviceType);
      }
      if (this.deviceComId) {
        messageSequence.writeString(this.deviceComId);
      } else {
        messageSequence.writeString('');
      }
      return true;
    }
    if (this.contactId) {
      messageSequence.writeInt(this.contactId);
    }
    if (this.deviceType) {
      messageSequence.writeInt(this.deviceType);
    }
    if (this.deviceComId) {
      messageSequence.writeString(this.deviceComId);
    } else {
      messageSequence.writeString('');
    }
    return true;
  }

  /**
   * 从MessageSequence中解封此可序列对象
   *
   * @param messageSequence
   * @returns true:反序列化成功,false:反序列化失败
   * @function
   */
  unmarshalling(messageSequence): boolean {
    this.phoneNumber = messageSequence.readString();
    this.contactId = messageSequence.readInt();
    this.deviceType = messageSequence.readInt();
    this.deviceComId = messageSequence.readString();
    return true;
  }
}