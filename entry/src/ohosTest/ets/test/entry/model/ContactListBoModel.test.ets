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
import { describe, it, expect, MockKit } from '@ohos/hypium'
import { ContactListBoModel } from '../../../../../main/ets/model/ContactListBoModel'

export default function ContactListBoModelTest() {
  describe('ContactListBoModelTest', () => {
    it("contactListBoModelTest_getToSearchPage", 0, () => {
      let contactListBoModel: ContactListBoModel = new ContactListBoModel();
      let result = contactListBoModel.getToSearchPage();
      expect(result).assertTrue();
    })

    it("contactListBoModelTest_setToSearchPage", 0, () => {
      let contactListBoModel: ContactListBoModel = new ContactListBoModel();
      contactListBoModel.setToSearchPage(false);
      expect(contactListBoModel.getToSearchPage()).assertTrue();
    })

    it('contactListBoModelTest_getInstance', 0, () => {
      let cd = new ContactListBoModel();
      expect(typeof cd).assertEqual(typeof ContactListBoModel.getInstance());
    })

    it("contactListBoModelTest_getToSearchPage_1", 0, () => {
      let cd = new ContactListBoModel();
      cd.setToSearchPage(false)
      expect(cd.getToSearchPage()).assertTrue();
    })

    it("contactListBoModelTest_setToSearchPage_1", 0, () => {
      let cd = new ContactListBoModel();
      expect(cd.getToSearchPage()).assertTrue();
    })
  })
}