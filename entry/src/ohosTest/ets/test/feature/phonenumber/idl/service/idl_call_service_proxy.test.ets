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
import { describe, expect, it } from '@ohos/hypium';
import IdlCallServiceProxy
  from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/service/idl_call_service_proxy';
import { rpc } from '@kit.IPCKit';
import RemoteContactInfo from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/model/RemoteContactInfo';

export default function IdlCallServiceProxyTest() {
  describe('IdlCallServiceProxyTest', () => {

    it('IdlCallServiceProxyTest_startCallAction_if', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(resolve => resolve({
          errCode: 0,
          code: 1,
          reply: {
            readInt: () => 1
          } as rpc.MessageSequence
        } as rpc.RequestResult))
      } as rpc.IRemoteObject;

      new IdlCallServiceProxy(proxy).startCallAction('', 1, new RemoteContactInfo('570977632',1), (code: number) => {
        expect(code).assertEqual(1)
      });
    })

    it('IdlCallServiceProxyTest_startCallAction_else', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 1,
            code: 1,
            reply: {
              readInt: () => 1
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlCallServiceProxy(proxy).startCallAction('', 1, new RemoteContactInfo('570977632',1), (code: number) => {
        expect(code).assertEqual(1);
      });

    })
  })
}