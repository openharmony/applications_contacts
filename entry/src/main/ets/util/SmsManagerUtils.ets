/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from '../../../../../feature/call/oh_modules/common';
import { common } from '@kit.AbilityKit';
import { SmsManager } from '../interception/sms/SmsManager';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'SmsManagerUtils';

/**
 *  Send request tool by serviceExtensionAbility
 */
export default class SmsManagerUtils {

  // 成功删除联系人时调用此方法，通知短信联系人成功删除
  public static notifyMmsWhenDeleteContact(ids: number[], data: number) {
    if (data === 0) {
      HiLog.i(TAG, 'send message to mms when delete contact succ');
      //删除联系人时通知到短信
      let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let smsManager: SmsManager = new SmsManager();
      smsManager.sendMessageContactDeleted(context, ids.map(String));
    }
  }
}