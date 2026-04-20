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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { BusinessError } from '@ohos.base';
import { SendMessageParams } from '../../../../../entry/src/main/ets/model/type/ContactParams';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from '../../../../../entry/src/main/ets/model/type/LooseObject';
const TAG = 'MmsService ';
// mms
const MMS_BUNDLE_NAME = 'com.ohos.mms';
const MMS_ABILITY_NAME = 'com.ohos.mms.MainAbility';
const MMS_ENTITIES = 'entity.system.home';

export default class MmsService {
  static sendMessage(number: string, formatNum: string, name?: string, contactId?: number) {
    let params: SendMessageParams[] = [];
    params.push(new SendMessageParams(number, formatNum, name, contactId));
    MmsService.jumpToMms(params);
  }

  static groupSendMessage(params: SendMessageParams[]) {
    MmsService.jumpToMms(params);
  }

  // Switching to the SMS app
  static jumpToMms(params: SendMessageParams[]) {
    let actionData: Record<string, string> = {};
    actionData.contactObjects = JSON.stringify(params);
    actionData.pageFlag = 'conversation';
    const want: LooseObject = {
      bundleName: MMS_BUNDLE_NAME,
      abilityName: MMS_ABILITY_NAME,
      parameters: actionData,
      entities: [
        MMS_ENTITIES,
      ]
    };

    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().startAbility(want).then(() => {
      HiLog.i(TAG, 'jumpToMms success.');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToMms failed: %s', error?.message);
    })
  }
}