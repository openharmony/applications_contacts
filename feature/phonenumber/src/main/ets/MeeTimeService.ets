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
import CallServiceManager from './idl/CallServiceManager';
import { ExtraParam } from './idl/api/CallServiceManagerApi';
import { Caas } from './idl/model/caasType';


export default class MeeTimeService {
  /**
   * 畅连通话
   * @param number
   * @param contactId
   */
  static meeTimeCall(number: string, contactId: number, deviceComId?: string, deviceType?: number) {
    let extraParam: ExtraParam = {
      contactId: contactId,
      isRedial: false,
      deviceComId: deviceComId,
      deviceType: deviceType
    }
    CallServiceManager.getInstance().placeCall(number, Caas.MediaType.AUDIO, extraParam)
  }

  /**
   * 畅连语音
   * @param number
   * @param contactId
   */
  static meeTimeVideo(number: string, contactId: number, deviceComId?: string, deviceType?: number) {
    let extraParam: ExtraParam = {
      contactId: contactId,
      isRedial: false,
      deviceComId: deviceComId,
      deviceType: deviceType
    }
    CallServiceManager.getInstance().placeCall(number, Caas.MediaType.VIDEO, extraParam)
  }

  /**
   * 畅连是否登录了
   * @returns
   */
  static isMeeTimeLogin(): Promise<boolean> {
    return CallServiceManager.getInstance().isLoginMeetime()
  }

  /**
   * 同步联系人畅连能力，根据畅连接口
   */
  static syncContactMeeTimeAbility(contactId: number,
                                   phoneNumbers: Record<string, string | number>[]): Promise<string> {
    return CallServiceManager.getInstance().syncContactMeeTimeAbility(contactId, phoneNumbers)
  }

}
