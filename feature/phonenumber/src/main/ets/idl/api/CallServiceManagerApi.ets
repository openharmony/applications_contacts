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

import { Caas } from '../model/caasType';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';

export interface ExtraParam {
  contactId?: number;
  isRedial?: boolean;
  uiSession?: UIExtensionContentSession;
  deviceComId?: string;
  deviceType?: number;
}

export interface CallServiceManagerApi {

  /**
   * 发起通话
   *
   * @param callPhoneNumber 电话号码
   * @param mediaType 呼叫类型
   * @param extra 附加参数
   */
  placeCall(callPhoneNumber: string, mediaType: Caas.MediaType,
    extra?: ExtraParam ) : Promise<boolean>;
}
