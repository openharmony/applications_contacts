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
import Want from '@ohos.app.ability.Want';
import rpc from '@ohos.rpc';
import IdlServiceBannerProxy from '../../idl/idl_service_banner_proxy';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { CardDialogInfoType } from '../../type/commonType';

const TAG = 'Banner_CLASS';
let mServiceBannerProxy: IdlServiceBannerProxy | undefined;

export default class Banner {
  private connectionId: number | undefined = undefined;
  private static sInstance: Banner;

  static getInstance() {
    if (Banner.sInstance == null) {
      Banner.sInstance = new Banner();
    }
    return Banner.sInstance;
  }

  public getConnectionId(): number {
    this.connectionId = 1;
    return this.connectionId;
  }

  bannerStart(dialogInfo: CardDialogInfoType) {
    HiLog.i(TAG, 'bannerStart start')
    let want: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    };
    let formContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
    HiLog.i(TAG, 'formContext startAbility success')
    this.connectionId = formContext?.connectServiceExtensionAbility(want, {
      onConnect(elementName:undefined, remote: rpc.RemoteObject) {
        if (remote === null) {
          return;
        }
        mServiceBannerProxy = new IdlServiceBannerProxy(remote, JSON.stringify(dialogInfo));
        mServiceBannerProxy.bannerStart();
      },
      onDisconnect(elementName) {
      },
      onFailed(code: number) {
        mServiceBannerProxy = undefined;
      }
    });
  }
}