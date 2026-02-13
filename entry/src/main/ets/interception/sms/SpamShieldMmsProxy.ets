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
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import ResultCallback from './IMmsResultCallback';
import ISpamShieldMms from './ISpamShieldMms';

const TAG = 'RestoreProxy';

export default class SpamShieldMmsProxy implements ISpamShieldMms {
  public static readonly DESCRIPTOR: string = 'idl.SpamShieldMmsService';
  public static readonly MMS_CONTACT_DESCRIPTOR: string = 'idl.MmsContactService';
  public static readonly COMMAND_RESTORE_BLOCK_MESSAGE = 1;
  public static readonly COMMAND_SEND_DELETED_MESSAGE = 3;
  private proxy: rpc.IRemoteObject;

  public constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  public asObject(): rpc.IRemoteObject {
    return this.proxy;
  }

  restoreBlockedMessage(phoneNumbers: Array<string>, callback: ResultCallback): void {
    HiLog.i(TAG, 'enter restoreBlockedMessage');
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(SpamShieldMmsProxy.DESCRIPTOR);
    data.writeStringArray(phoneNumbers);
    data.writeRemoteObject(callback.asObject());
    this.proxy.sendMessageRequest(SpamShieldMmsProxy.COMMAND_RESTORE_BLOCK_MESSAGE, data, reply, option)
      .then((result: rpc.RequestResult) => {
        HiLog.i(TAG, 'sendMessageRequest succ');
        if (result.errCode !== 0) {
          HiLog.i(TAG, 'sendMessageRequest failed, errCode: ' + result.errCode);
        }
      })
      .catch((e: Error) => {
        HiLog.e(TAG, `sendMessageRequest failed, message: ${e?.message}`);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  sendDeletedMessage(contactIds: Array<string>, callback: ResultCallback): void {
    HiLog.i(TAG, 'enter sendDeletedMessage');
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(SpamShieldMmsProxy.MMS_CONTACT_DESCRIPTOR);
    data.writeStringArray(contactIds);
    data.writeRemoteObject(callback.asObject());
    this.proxy.sendMessageRequest(SpamShieldMmsProxy.COMMAND_SEND_DELETED_MESSAGE, data, reply, option)
      .then((result: rpc.RequestResult) => {
        HiLog.i(TAG, 'sendDeletedMessageRequest succ');
        if (result.errCode !== 0) {
          HiLog.i(TAG, 'sendDeletedMessageRequest failed, errCode: ' + result.errCode);
        }
      })
      .catch((e: Error) => {
        HiLog.e(TAG, `sendDeletedMessageRequest failed, message: ${e?.message}`);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }
}

