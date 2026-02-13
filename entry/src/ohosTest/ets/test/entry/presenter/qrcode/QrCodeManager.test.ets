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
import { describe, expect, it} from '@ohos/hypium';
import { QrCodeManager } from '../../../../../../main/ets/presenter/qrcode/QrCodeManager';
import contact from '@ohos.contact';

export default function QrCodeManagerTest() {
  describe('QrCodeManagerTest', () => {

    /**
     * QrCodeManager getInstance 测试方法
     */
    it('QrCodeManagerTest_getInstance_001', 0, async () => {
      let instance = QrCodeManager.getInstance();
      expect(instance).not().assertNull();
    })

    /**
     * QrCodeManager handleQrCode 测试方法
     */
    it('QrCodeManagerTest_handleQrCode_002', 0, async () => {
      let instance = QrCodeManager.getInstance();

      /**
       * mecard测试用例
       */
      const meCardContent = 'MECARD:N:a;TEL:567;ORG:testORG;ADR:testADR;EMAIL:testEMAIL;URL:testURL;NOTE:testNOTE;;';
      let contactInfo1: contact.Contact =
        instance.handleQrCode(meCardContent) as contact.Contact;
      expect(contactInfo1.name?.fullName).assertEqual('a');
      expect(contactInfo1.phoneNumbers![0].phoneNumber).assertEqual('567');
      expect(contactInfo1.organization?.name).assertEqual('testORG');
      expect(contactInfo1.postalAddresses![0].postalAddress).assertEqual('testADR');
      expect(contactInfo1.emails![0].email).assertEqual('testEMAIL');
      expect(contactInfo1.websites![0].website).assertEqual('testURL');
      expect(contactInfo1.note?.noteContent).assertEqual('testNOTE');

      /**
       * vcard测试用例
       */
      let contactInfo2: contact.Contact = instance.handleQrCode('BEGIN:VCARD\nN:test\nEND:VCARD') as contact.Contact;
      expect(contactInfo2.name?.fullName).assertEqual('test');

      /**
       * 异常测试用例
       */
      let unKnowType = instance.handleQrCode('unknow');
      expect(unKnowType).assertEqual(-1);
    })
  })
}