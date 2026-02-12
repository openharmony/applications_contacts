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
import { describe, it, expect } from '@ohos/hypium';
import IdlServiceBannerProxy from '../../../../../../main/ets/card/idl/idl_service_banner_proxy';
import { rpc } from '@kit.IPCKit';
import { BusinessError } from '@kit.BasicServicesKit';


export default function IdlServiceBannerProxyTest() {
  let idlServiceBannerProxy: IdlServiceBannerProxy;

  describe("IdlServiceBannerProxyTest", () => {

    it('IdlServiceBannerProxyTest_bannerStart_resolve', 0, () => {
      let result1 = false;
      let proxy: rpc.RemoteObject = {
        sendMessageRequest: (code: number,
                             data: rpc.MessageSequence,
                             reply: rpc.MessageSequence,
                             options: rpc.MessageOption):
          Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(
          (resolve: (value: rpc.RequestResult | PromiseLike<rpc.RequestResult>) => void,
           reject: (reason?: BusinessError) => void
          ) => {
            result1 = true;
            let result: rpc.RequestResult = {
              reply: {
                readInt: (): number => 1,
                reclaim: () => {
                }
              } as rpc.MessageSequence,
              errCode: 0,
              code: 0,
              data: {
                reclaim: () => {
                }
              } as rpc.MessageSequence
            }
            resolve(result);
          })
      } as rpc.RemoteObject;

      idlServiceBannerProxy = new IdlServiceBannerProxy(proxy, 'dialogInfo');

      idlServiceBannerProxy.bannerStart();

      expect(result1).assertTrue();
    })

    it('IdlServiceBannerProxyTest_bannerStart_reject', 0, () => {
      let result1 = false;
      let proxy: rpc.RemoteObject = {
        sendMessageRequest: (code: number,
                             data: rpc.MessageSequence,
                             reply: rpc.MessageSequence,
                             options: rpc.MessageOption):
          Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(
          (resolve: (value: rpc.RequestResult | PromiseLike<rpc.RequestResult>) => void,
           reject: (reason?: BusinessError) => void
          ) => {
            result1 = true;
            let result: BusinessError = {
              code: 401,
              message: 'error'
            } as BusinessError;
            reject(result);
          })
      } as rpc.RemoteObject;

      idlServiceBannerProxy = new IdlServiceBannerProxy(proxy, 'dialogInfo');

      idlServiceBannerProxy.bannerStart();

      expect(result1).assertTrue();
    })
  })

}