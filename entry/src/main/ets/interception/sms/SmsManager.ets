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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import { common } from '@kit.AbilityKit';
import SpamShieldClient from './SpamShieldClient';
import MmsResultCallback from './MmsResultCallback';

const TAG = 'SmsManager: ';

export class SmsManager { //sms manager

  //恢复拦截短信
  restoreBlockedMessage(context: common.UIAbilityContext, phoneNumbers: string[], callback?: MmsResultCallback): void {
      let client: SpamShieldClient = new SpamShieldClient();
      try {
        client.connectServiceExt(context, phoneNumbers);
      } catch (err) {
        HiLog.e(TAG, `createDataShareHelper fail ${err?.message}`);
      }
  }

  //删除联系人时，发送通知给短信
  sendMessageContactDeleted(context: common.UIAbilityContext,
    contactIds: string[], callback?: MmsResultCallback): void {
    let client: SpamShieldClient = new SpamShieldClient();
    try {
      client.connectMmsServiceExt(context, contactIds);
    } catch (err) {
      HiLog.e(TAG, `createDataShareHelper fail ${err?.message}`);
    }
  }
}