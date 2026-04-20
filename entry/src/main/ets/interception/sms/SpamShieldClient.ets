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
import { common } from '@kit.AbilityKit'
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import RestoreCallback from './MmsResultCallback';
import SpamShieldMmsProxy from './SpamShieldMmsProxy';

const TAG = 'SpamShieldClient: ';

export default class SpamShieldClient {

  // 连接短信 BlockedServiceExtAbility，恢复短信
  public connectServiceExt(context: common.UIAbilityContext, phoneNumbers: string[]): Promise<string> {
    return new Promise<string>((resolve) =>{
      context.connectServiceExtensionAbility({
        bundleName: 'com.ohos.mms',
        abilityName: 'BlockedServiceExtAbility'
      }, {
        onConnect(elementName, remote) {
          HiLog.i(TAG, 'onConnect blockedService')
          if (remote === null) {
            HiLog.i(TAG, 'onConnect remote binder null')
            return;
          }
          let restoreService = new SpamShieldMmsProxy(remote);
          let callback: RestoreCallback = new RestoreCallback('RestoreCallback');
          restoreService.restoreBlockedMessage(phoneNumbers, callback);
          resolve(callback.res);
        },
        onDisconnect(elementName) {// 回调，服务端释放时，客户端收到事件
          HiLog.i(TAG, 'onDisconnect blockedService')
        },
        onFailed(code) {
          HiLog.i(TAG, `blockedService onFailed: ${code}`)
        }
      })
    })
  }

  // 连接短信 MmsContactServiceExtAbility，将删除联系人通知给短信
  public connectMmsServiceExt(context: common.UIAbilityContext, contactIds: string[]): Promise<string> {
    return new Promise<string>((resolve) =>{
      context.connectServiceExtensionAbility({
        bundleName: 'com.ohos.mms',
        abilityName: 'MmsContactServiceExtAbility'
      }, {
        onConnect(elementName, remote) {
          HiLog.i(TAG, 'onConnect mmsContactService')
          if (remote === null) {
            HiLog.i(TAG, 'onConnect remote binder null')
            return;
          }
          let restoreService = new SpamShieldMmsProxy(remote);
          let callback: RestoreCallback = new RestoreCallback('RestoreCallback');
          restoreService.sendDeletedMessage(contactIds, callback);
          resolve(callback.res);
        },
        onDisconnect(elementName) {// 回调，服务端释放时，客户端收到事件
          HiLog.i(TAG, 'onDisconnect mmsContactService')
        },
        onFailed(code) {
          HiLog.i(TAG, `mmsContactService onFailed: ${code}`)
        }
      })
    })
  }

  disconnectServiceExt(context: common.UIAbilityContext) {
  }
}