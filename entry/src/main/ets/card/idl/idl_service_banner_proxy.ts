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
import rpc from '@ohos.rpc';
import type { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';

const TAG = 'idl_service_banner_proxy';
const RPC_TIME: number = 1000;

export default class IdlServiceBannerProxy {
  dialogInfo: string;
  static readonly PROXY_DATA_LENGTH = 3;

  constructor(proxy, dialogInfo: string) {
    this.proxy = proxy;
    this.dialogInfo = dialogInfo;
  }

  bannerStart(): void {
    let option = new rpc.MessageOption();
    option.setWaitTime(RPC_TIME);
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInt(IdlServiceBannerProxy.PROXY_DATA_LENGTH);
    data.writeString('bundleName');
    data.writeString('com.ohos.contacts');
    data.writeString('abilityName');
    data.writeString('CardDialogServiceExtAbility');
    data.writeString('parameters');
    let uiExtensionTypeString: string =
      `{"ability.want.params.uiExtensionType":"sysDialog/common","dialogInfo":${this.dialogInfo}}`;
    data.writeString(uiExtensionTypeString);
    HiLog.i(TAG, 'bannerFirstStart');
    this.proxy.sendMessageRequest(1, data, reply, option).then(
      result => {
        HiLog.i(TAG, `startdialog success ${result.errCode} ${result.reply.readInt()}`);
      },
      (error: BusinessError) => HiLog.i(TAG, `startdialog error ${error?.message}, stack: ${error?.stack}`)
    ).finally(() => {
      data.reclaim();
      reply.reclaim();
    });
    return;
  }

  static readonly COMMAND_PROCESS_DATA = 1;
  static readonly COMMAND_INSERT_DATA_TO_MAP = 2;

  static readonly RECORDING_AUTO = 0;
  static readonly RECORDING_MANUAL = 1;
  static readonly RECORDING_MEETING = 2;
  private proxy: rpc.RemoteObject;
}