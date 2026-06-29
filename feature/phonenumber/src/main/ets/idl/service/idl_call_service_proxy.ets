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
import RemoteContactInfo from '../model/RemoteContactInfo';
import { CallBack } from './i_idl_call_service';
import IIdlCallService from './i_idl_call_service';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const INVALID_PARAM_ERR_CODE = -1;
const TAG = '[MEETIME_contactUiFeature] IdlCallServiceProxy';

/**
 * 通话服务proxy
 */
export default class IdlCallServiceProxy implements IIdlCallService {

  /**
   * 呼出电话定义code
   */
  public static readonly COMMAND_START_CALL_ACTION = 1;
  private proxy: rpc.IRemoteObject;

  constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  /**
   * 发起通话
   *
   * @param scope 应用校验标识
   * @param mediaType 通话类型
   * @param remoteInfo 通话对端信息
   * @param cb 是否成功回调
   */
  startCallAction(scope: string, mediaType: number, remoteContactInfo: RemoteContactInfo, cb: CallBack): void {
    if (typeof(mediaType) !== 'number' || !remoteContactInfo) {
      HiLog.e(TAG, 'startCallAction parameter is invalid, return.');
      cb(INVALID_PARAM_ERR_CODE);
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    // meetime security issues
    data.writeInterfaceToken('idl.IIdlCallService');
    data.writeString(scope);
    data.writeInt(mediaType);
    data.writeParcelable(remoteContactInfo);
    this.proxy.sendMessageRequest(IdlCallServiceProxy.COMMAND_START_CALL_ACTION, data, reply, option)
      .then((result) => {
        if (result.errCode === 0) {
          let errCode: number = result.reply.readInt();
          cb(errCode);
        } else {
          HiLog.e(TAG, `sendRequest failed, errCode: ${result.errCode}.`);
        }
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }
}
