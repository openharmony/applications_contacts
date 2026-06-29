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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import call from '@ohos.telephony.call';
import MmsService from '../../../../../../../feature/phonenumber/src/main/ets/MmsService';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';


export default function PhoneNumberTest() {
  describe('PhoneNumberTest', () => {

    it('PhoneNumberTest_fromString', 0, () => {
      let phoneNumber = PhoneNumber.fromString("19875421588");
      let phoneNumber1: Record<string, string> = {
        "number": "19875421588"
      }
      expect(JSON.stringify(phoneNumber)).assertEqual(JSON.stringify(phoneNumber1));
    })

    it('PhoneNumberTest_format2', 0, async () => {
      let phoneNumber1 = new PhoneNumber("00220")
      let formatNumber1 = await phoneNumber1.format()
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(call.formatPhoneNumber, call.formatPhoneNumber);
      expect(formatNumber1).assertEqual("00220");
      mocker.clear(call.formatPhoneNumber);
    })
    it('PhoneNumberTest_getNumber', 0, () => {
      let phoneNumber = new PhoneNumber("13986548752")
      expect(JSON.stringify(phoneNumber.getNumber())).assertEqual(JSON.stringify("13986548752"))
    })

    it('PhoneNumberTest_phoneNumFormat', 0, () => {
      let phoneNumber = new PhoneNumber("15281065440")
      expect(phoneNumber.phoneNumFormat()).assertEqual('152 8106 5440');
    })

    it('PhoneNumberTest_sendMessage', 0, () => {
      let phoneNumber = new PhoneNumber("15281065440")
      let mocker: MockKit = new MockKit()
      mocker.mockFunc(MmsService, MmsService.sendMessage)
      phoneNumber.sendMessage('152 8106 5440');
      expect(phoneNumber.getNumber()).assertEqual('15281065440');
      mocker.clear(MmsService);
    })

    it('PhoneNumberTest_formatDisplayPhoneNumber', 0, () => {
      let formatNumber = '123 4567 8900';
      let telNumber = '456789';
      let highlight = PhoneNumber.formatDisplayPhoneNumber(formatNumber, telNumber);
      let result = [4, 10];
      expect(highlight.toString()).assertEqual(result.toString());
    })

    it('PhoneNumberTest_showDialErrorDialog', 0, () => {
      let phoneNumber = new PhoneNumber("15281065440");
      phoneNumber.showDialErrorDialog(true);
      expect(AppStorage.get('isRingingDialog')).assertTrue();

      phoneNumber.showDialErrorDialog(false);
      expect(AppStorage.get('isNoRingingDialog')).assertTrue();
      AppStorage.clear();
    })

    it('PhoneNumberTest_format', 0, async () => {
      let phoneNumber = new PhoneNumber('')
      let formatNumber = await phoneNumber.format()
      expect(JSON.stringify(formatNumber)).assertEqual(JSON.stringify(''));
    })

    it('PhoneNumberTest_phoneAddSpace', 0, async () => {
      let phoneNumber = new PhoneNumber('13732123456');
      let phoneAddSpace = await phoneNumber.phoneAddSpace();
      expect(JSON.stringify(phoneAddSpace)).assertEqual(JSON.stringify('137 3212 3456'));
    })

    it('PhoneNumberTest_dynamicPhoneFormat', 0, () => {
      let phoneNumber = new PhoneNumber('13732123456');
      AppStorage.setOrCreate('country', 'CN');
      expect(phoneNumber.dynamicPhoneFormat()).assertEqual('137 3212 3456');
    })
  })
}