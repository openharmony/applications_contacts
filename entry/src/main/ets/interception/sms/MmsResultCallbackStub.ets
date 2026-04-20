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

const TAG = 'BlockedResultCallbackStub';

export default abstract class MmsResultCallbackStub extends rpc.RemoteObject implements ResultCallback {
  private static readonly DESCRIPTOR: string = 'idl.SpamShieldMmsService';
  private static readonly COMMAND_ON_RESULT = 1;

  constructor(des: string) {
    super(des);
  }

  asObject(): rpc.IRemoteObject {
    return this;
  }

  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence,
                               reply: rpc.MessageSequence, option: rpc.MessageOption): Promise<boolean> {
    HiLog.i(TAG, 'onRemoteMessageRequest called, code = ' + code);
    if (data.readInterfaceToken() !== MmsResultCallbackStub.DESCRIPTOR) {
      HiLog.i(TAG, 'DESCRIPTOR unmatched.');
      return false;
    }
    switch (code) {
      case MmsResultCallbackStub.COMMAND_ON_RESULT: {
        let errCodeVar = data.readInt();
        let resultVar = data.readString();
        this.onResult(errCodeVar, resultVar);
        return true;
      }
      default: {
        HiLog.i(TAG, 'invalid request code' + code);
        break;
      }
    }
    return false;
  }

  abstract onResult(errCode: number, result: string): void;
}