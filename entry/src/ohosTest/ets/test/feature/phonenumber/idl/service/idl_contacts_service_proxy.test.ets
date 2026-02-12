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
import IdlContactsServiceProxy
  from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/service/idl_contacts_service_proxy';
import { rpc } from '@kit.IPCKit';

export default function IdlContactsServiceProxyTest() {
  describe('IdlContactsServiceProxyTest', () => {

    it('IdlContactsServiceProxy_insertContacts', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readInt: () => 1
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).insertContacts('', (returnValue: number) => {
        expect(returnValue).assertEqual(1);
      });
    })

    it('IdlContactsServiceProxy_insertContacts_noIf', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readInt: () => 1
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).insertContacts('hi', (returnValue: number) => {
        expect(returnValue).assertEqual(1);
      });
    })

    it('IdlContactsServiceProxy_batchQueryContactCapability', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readString: () => ''
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).batchQueryContactCapability('', (returnValue: string) => {
        expect(returnValue).assertEqual('');
      });
    })

    it('IdlContactsServiceProxy_batchQueryContactCapability_noIf', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readString: () => ''
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).batchQueryContactCapability('hi', (returnValue: string) => {
        expect(returnValue).assertEqual('');
      });
    })

    it('IdlContactsServiceProxy_queryContactCapabilityByPhoneNumbers', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readString: () => ''
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).queryContactCapabilityByPhoneNumbers(1, '', (returnValue: string) => {
        expect(returnValue).assertEqual('');
      });
    })

    it('IdlContactsServiceProxy_queryContactCapabilityByPhoneNumbers_noIf', 0, () => {
      let proxy: rpc.IRemoteObject = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          return new Promise<rpc.RequestResult>(resolve => resolve({
            errCode: 0,
            code: 1,
            reply: {
              readString: () => ''
            } as rpc.MessageSequence
          } as rpc.RequestResult))
        }
      } as rpc.IRemoteObject;

      new IdlContactsServiceProxy(proxy).queryContactCapabilityByPhoneNumbers(1, '["570977632"]', (returnValue: string) => {
        expect(returnValue).assertEqual('');
      });
    })

  })
}