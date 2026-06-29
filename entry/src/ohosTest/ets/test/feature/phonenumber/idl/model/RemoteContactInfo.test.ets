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
import RemoteContactInfo from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/model/RemoteContactInfo';
import { rpc } from '@kit.IPCKit';

export default function RemoteContactInfoTest() {
  describe('RemoteContactInfoTest', () => {
    let remoteContactInfo: RemoteContactInfo;

    it('RemoteContactInfoTest_marshalling', 0, () => {
      remoteContactInfo = new RemoteContactInfo('570977632', 1, '');
      let messageSequence: rpc.MessageSequence = {
        writeString: (val: string): void => {

        },
        writeInt: (val: number): void => {

        }
      } as rpc.MessageSequence;

      let result = remoteContactInfo.marshalling(messageSequence);
      expect(result).assertTrue();
    })

    it('RemoteContactInfoTest_marshalling_noIf', 0, () => {
      remoteContactInfo = new RemoteContactInfo('570977632');
      let messageSequence: rpc.MessageSequence = {
        writeString: (val: string): void => {

        },
        writeInt: (val: number): void => {

        },
      } as rpc.MessageSequence;

      let result = remoteContactInfo.marshalling(messageSequence);
      expect(result).assertTrue();
    })

    it('RemoteContactInfoTest_unmarshalling', 0, () => {
      remoteContactInfo = new RemoteContactInfo('570977632', 1, '');
      let messageSequence: rpc.MessageSequence = {
        readString: (val: string): string => '570977632',
        readInt: (val: number): number => 1,
      } as rpc.MessageSequence;

      remoteContactInfo.unmarshalling(messageSequence);
      expect(remoteContactInfo.phoneNumber).assertEqual('570977632');
      expect(remoteContactInfo.contactId).assertEqual(1);
      expect(remoteContactInfo.deviceComId).assertEqual('570977632');
    })

  })
}