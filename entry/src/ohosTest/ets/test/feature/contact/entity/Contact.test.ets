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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import Contact from '../../../../../../../../feature/contact/src/main/ets/entity/Contact'
import ContactBuilder from '../../../../../../../../feature/contact/src/main/ets/entity/ContactBuilder'


export default function ContactTest() {
  describe('ContactTest', () => {
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
    it('ContactTest_addToBlackList', 0, () => {
      let contactBuilder = new ContactBuilder(1);
      let contact = new Contact(contactBuilder);
      const imgSrc1:undefined = undefined;

      const expectedImgSrc1 = contact.addToBlackList()

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_removeFromBlackList", 0, () => {
      const imgSrc1: undefined = undefined;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.removeFromBlackList();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_isInBlackList", 0, () => {
      const imgSrc1: boolean = false;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.isInBlackList();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_star", 0, () => {
      const imgSrc1: boolean = false;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.star();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_unStar", 0, () => {
      const imgSrc1: boolean = false;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.unStar();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it('ContactTest_shareContactByType', 0, () => {
      const imgSrc1:undefined = undefined;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.shareContactByType(1)

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it("ContactTest_addBirthDayToCalendar", 0, () => {
      const imgSrc1: undefined = undefined;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.shareContactByType(1);

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_clearPhotos", 0, () => {
      const imgSrc1: boolean = false;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.clearPhotos();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_isReadOnly", 0, () => {
      const imgSrc1: boolean = false;
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.isReadOnly();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_getSharedText", 0, () => {
      const imgSrc1: String = "我是被分享的文本";
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.getSharedText();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_getSharedQRCode", 0, () => {
      const imgSrc1: String = "我是被分享的二维码";
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.getSharedQRCode();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
    it("ContactTest_getSharedVcard", 0, () => {
      const imgSrc1: String = "我是被分享的Vcard";
      let expectImgSrc = new Contact(new ContactBuilder(1));

      const expectedImgSrc1 = expectImgSrc.getSharedVcard();

      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));
    })
  })
}