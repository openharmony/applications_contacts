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
import VcardParse from '../../../../../../main/ets/presenter/qrcode/VCardParse';
import contact from '@ohos.contact';

export default function VCardParseTest() {
  describe('VCardParseTest', () => {

    /**
     * VCardParse getInstance 测试方法
     */
    it('VCardParseTest_getInstance_001', 0, async () => {
      let instance = VcardParse.getInstance();
      expect(instance).not().assertNull();
    })

    /**
     * VCardParse decodeValue 测试方法
     */
    it('VCardParseTest_decodeValue_002', 0, async () => {
      let instance = VcardParse.getInstance();
      let decodeValue1 = instance.decodeValue('');
      expect(decodeValue1).assertEqual('');

      let decodeValue2 = instance.decodeValue('test');
      expect(decodeValue2).assertEqual('test');
    })

    /**
     * VCardParse parseVCard 测试方法
     */
    it('VCardParseTest_parseVCard_003', 0, async () => {
      let instance = VcardParse.getInstance();
      let contactInfo1: contact.Contact =
        instance.parseVCard('BEGIN:VCARD\nN:test\nORG:testORG\nTITLE:testTitle\n' +
          'ADR;HOME:testHOME\nEMAIL;HOME:testEMAIL\nX-QQ:testQQ\nX-AIM:testAIM\n' +
          'X-MSN:testMSN\nX-YAHOO:testYAHOO\nX-SKYPE-USERNAME:testSKYPE\nX-GOOGLE-TALK:testGOOGLE\n' +
          'X-ICQ:testICQ\nX-JABBER:testJABBER\nEND:VCARD');
      expect(contactInfo1.name?.fullName).assertEqual('test');
      expect(contactInfo1.organization?.name).assertEqual('testORG');
      expect(contactInfo1.organization?.title).assertEqual('testTitle');
      expect(contactInfo1.postalAddresses![0].postalAddress).assertEqual('testHOME');
      expect(contactInfo1.emails![0].email).assertEqual('testEMAIL');
      expect(contactInfo1.imAddresses![0].imAddress).assertEqual('testQQ');
      expect(contactInfo1.imAddresses![1].imAddress).assertEqual('testAIM');
      expect(contactInfo1.imAddresses![2].imAddress).assertEqual('testMSN');
      expect(contactInfo1.imAddresses![3].imAddress).assertEqual('testYAHOO');
      expect(contactInfo1.imAddresses![4].imAddress).assertEqual('testSKYPE');
      expect(contactInfo1.imAddresses![5].imAddress).assertEqual('testGOOGLE');
      expect(contactInfo1.imAddresses![6].imAddress).assertEqual('testICQ');
      expect(contactInfo1.imAddresses![7].imAddress).assertEqual('testJABBER');
    })
  })
}