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
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ProfileUtils } from '../../../../../main/ets/util/ProfileUtils';
import { RichContactInfo } from '../../../../../main/ets/model/bean/RichContactInfo';
import { PhoneNumBean } from '../../../../../main/ets/model/bean/PhoneNumBean';
import { EmailBean } from '../../../../../main/ets/model/bean/EmailBean';
import { AIMBean } from '../../../../../main/ets/model/bean/AIMBean';
import { HouseBean } from '../../../../../main/ets/model/bean/HouseBean';
import { AssociatedPersonBean } from '../../../../../main/ets/model/bean/AssociatedPersonBean';

export default function ProfileUtilsTest() {
  describe('ProfileUtilsTest', () => {
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
    it('ProfileUtilsTest_buildShareTextCard', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let phone = new PhoneNumBean('1', '570977632', '10000', '', '', true);
      phone.phoneAddress = 'address';
      let phones: PhoneNumBean[] = [phone];
      let emails: EmailBean[] = [new EmailBean('text', '', '10000')];
      let aims: AIMBean[] = [new AIMBean('1', 'text', '10000', '')];
      let houses: HouseBean[] = [new HouseBean('1', '', '10000', 'home1')];
      let relationships: AssociatedPersonBean[] = [new AssociatedPersonBean('text', '1', 'relation1', '10000')];
      let websites: string[] = ['www.zly.com','www.zly.com'];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.phones = phones;
      contacts.emails = emails;
      contacts.aims = aims;
      contacts.houses = houses;
      contacts.display_name = 'test';
      contacts.company = 'test';
      contacts.position = 'test';
      contacts.phoneticName ='test';
      contacts.nickname = 'test';
      contacts.websites = websites;
      contacts.relationships = relationships;
      contacts.remarks = 'test';
      ProfileUtils.getLabelNameByTypeId(contacts);
      expect(ProfileUtils.resultDT).assertEqual('')
    })
    it('ProfileUtilsTest_buildShareTextCard_2', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let contacts: RichContactInfo = new RichContactInfo('1');
      let res: string = ProfileUtils.buildShareTextCard(contacts);
      expect(res).assertEqual('')
    })
    it('ProfileUtilsTest_getLabelNameByTypeId_01', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let phone = new PhoneNumBean('1', '570977632', '10000', '', '', true);
      phone.phoneAddress = 'address';
      let phones: PhoneNumBean[] = [phone];
      let emails: EmailBean[] = [new EmailBean('text', '', '10000')];
      let aims: AIMBean[] = [new AIMBean('1', 'text', '10000', '')];
      let houses: HouseBean[] = [new HouseBean('1', '', '10000', 'home1')];
      let relationships: AssociatedPersonBean[] = [new AssociatedPersonBean('text', '1', 'relation1', '10000')];
      let websites: string[] = ['www.zly.com','www.zly2.com'];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.phones = phones;
      contacts.emails = emails;
      contacts.aims = aims;
      contacts.houses = houses;
      contacts.display_name = 'test';
      contacts.company = 'test';
      contacts.position = 'test';
      contacts.phoneticName ='test';
      contacts.nickname = 'test';
      contacts.websites = websites;
      contacts.relationships = relationships;
      contacts.remarks = 'test';
      ProfileUtils.getLabelNameByTypeId(contacts);
      expect(ProfileUtils.resultDT).assertEqual('')
    })
  })
}