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
import { describe, beforeEach, it, expect } from '@ohos/hypium';
import {
  OriginalDataHandleHelper
} from '../../../../../../../main/ets/presenter/contact/accountants/OriginalDataHandleHelper';
import { PhoneNumBean } from '../../../../../../../main/ets/model/bean/PhoneNumBean';
import { ContactInfo } from '../../../../../../../main/ets/model/bean/ContactInfo';
import { EventBean } from '../../../../../../../main/ets/model/bean/EventBean';

export default function OriginalDataHandleHelperTest() {
  describe('OriginalDataHandleHelperTest', () => {

    let originalDataHandleHelper: OriginalDataHandleHelper;

    beforeEach(() => {
      originalDataHandleHelper = new OriginalDataHandleHelper();
    })

    it('OriginalDataHandleHelperTest_phoneOriginalData_if', 0, () => {
      expect(originalDataHandleHelper.phoneOriginalData()).assertDeepEquals(originalDataHandleHelper);
    })

    it('OriginalDataHandleHelperTest_phoneOriginalData', 0, () => {
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', false)];

      originalDataHandleHelper.phoneOriginalData(phones);

      expect(originalDataHandleHelper.phoneOriginalDataMap.get('570977632')).assertDeepEquals(phones[0]);
    })

    it('OriginalDataHandleHelperTest_inheritOriginalDataHandle_noIf1', 0, () => {
      let contactInfo: ContactInfo =
        new ContactInfo('1', 'roxy', 'roxy', [], [], 'position1', 'company1', 'remarks1', [], [], [], [], [], [], 1);

      originalDataHandleHelper.inheritOriginalDataHandle(contactInfo);

      expect(originalDataHandleHelper.phoneOriginalDataMap.size).assertEqual(0);
    })

    it('OriginalDataHandleHelperTest_inheritOriginalDataHandle_noIf2', 0, () => {
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', false)];
      let contactInfo: ContactInfo =
        new ContactInfo('1', 'roxy', 'roxy', phones, [], 'position1', 'company1', 'remarks1', [], [], [], [], [], [],
          1);

      originalDataHandleHelper.inheritOriginalDataHandle(contactInfo);

      expect(originalDataHandleHelper.phoneOriginalDataMap.size).assertEqual(0);
    })

    it('OriginalDataHandleHelperTest_inheritOriginalDataHandle_if_if', 0, () => {
      let phone: PhoneNumBean = new PhoneNumBean('1', '570977632', '1', '', '', true);
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', false)];
      let event: EventBean = new EventBean('1', '1', '1', '1');
      let contactInfo: ContactInfo =
        new ContactInfo('1', 'roxy', 'roxy', phones, [], 'position1', 'company1', 'remarks1', [], [], [], [], [], [],
          1);
      contactInfo.events.push(event);
      originalDataHandleHelper.phoneOriginalDataMap.set('570977632',phone);
      originalDataHandleHelper.eventOriginalDataMap.set(event.contactDataId, event);

      originalDataHandleHelper.inheritOriginalDataHandle(contactInfo);

      expect(contactInfo.phones[0].primary).assertTrue();
    })

  })
}