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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { ContactVo, ContactVoName, CharIndex, AlphabetIndexObj } from '../../../../../../main/ets/model/bean/ContactVo'
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor'
import { PhoneNumberInterface } from '../../../../../../main/ets/model/type'

export default function ContactVoTest() {
  describe('ContactVoTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('ContactVoTest_constructor', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      expect(cv.contactId).assertEqual('12');
    })
    it('ContactVoTest_setShowName', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      cv.setShowName();
      expect(cv.showName).assertEqual('1');
    })
    it('ContactVoTest_setphoneNumbers', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      let phoneNumbers: PhoneNumberInterface[] = [];
      cv.setphoneNumbers(phoneNumbers);
      expect(cv.phoneNumbers.length).assertEqual(0);
    })
    it('ContactVoTest_setTitle', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      cv.setTitle("22");
      expect(cv.title).assertEqual('22');
    })
    it('ContactVoTest_setSubTitle', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      cv.setSubTitle("22");
      expect(cv.subTitle).assertEqual('22');
    })
    it('ContactVoTest_setHeadChar_001', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "1", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      cv.setSubTitle("22");
      cv.setShowName();
      cv.setHeadChar();
      expect(cv.headChar).assertEqual('');
    })
    it('ContactVoTest_setHeadChar_002', 0, () => {
      let name: ContactVoName = new ContactVoName();
      let portraitColor: Resource = MorandiColor.color[0];
      let cv = new ContactVo("12", "2", '', "商铺", "2", "1", portraitColor, true, "1", "2", '0', name, "2", "1", "1", "2");
      cv.setSubTitle("22");
      cv.setShowName();
      cv.setHeadChar();
      expect(cv.headChar).assertEqual('铺');
    })
    it('ContactVoTest_CharIndex_constructor', 0, () => {
      let charIndex = new CharIndex('abc', 0, 2);
      expect(charIndex.char).assertEqual('abc');
    })
    it('ContactVoTest_AlphabetIndexObj_constructor', 0, () => {
      let alphabetIndexObj = new AlphabetIndexObj();
      expect(alphabetIndexObj).not().assertNull();
    })
  })
}