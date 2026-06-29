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
import { AIMBean } from '../../../../../../main/ets/model/bean/AIMBean'
import { AssociatedPersonBean } from '../../../../../../main/ets/model/bean/AssociatedPersonBean'
import { ContactInfo } from '../../../../../../main/ets/model/bean/ContactInfo'
import { EmailBean } from '../../../../../../main/ets/model/bean/EmailBean'
import { EventBean } from '../../../../../../main/ets/model/bean/EventBean'
import { GroupBean } from '../../../../../../main/ets/model/bean/GroupBean'
import { HouseBean } from '../../../../../../main/ets/model/bean/HouseBean'
import { PhoneNumBean } from '../../../../../../main/ets/model/bean/PhoneNumBean'
import RawContact from '../../../../../../../../feature/contact/src/main/ets/entity/RawContact'

export default function ContactInfoTest() {
  describe('ContactInfoTest', () => {
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
    it('ContactInfoTest_setID', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean[] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setContactID("12345").contactID).assertEqual("12345");
    })
    it('ContactInfoTest_getDisplayNameByRule', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setContactID("12345").contactID).assertEqual("12345");
      let displayNameByRule: string = '';
      ct.display_name = "display_name";
      expect(ct.getDisplayNameByRule()).assertEqual("display_name");
      ct.display_name = "";
      ct.nickname = "nickname";
      expect(ct.getDisplayNameByRule()).assertEqual("nickname");
      ct.nickname = "";
      ct.company = "company";
      expect(ct.getDisplayNameByRule()).assertEqual("company");
      ct.company = "";
      ct.position = "position";
      expect(ct.getDisplayNameByRule()).assertEqual("position");
      ct.position = "";
      ct.phoneticName = 'phoneticName';
      expect(ct.getDisplayNameByRule()).assertEqual("phoneticName");
    })
    it("ContactInfoTest_getDisplayNameByRule02", 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.phones = [new PhoneNumBean('1', '1570977632', '1', '', '', true)];
      expect(ct.getDisplayNameByRule()).assertEqual("1570977632");
      ct.phones = [new PhoneNumBean('1', '', '1', '', '', true)];
      expect(ct.getDisplayNameByRule()).assertEqual('');
    })
    it("ContactInfoTest_getDisplayNameByRule03", 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.phones = [new PhoneNumBean('1', '', '1', '', '', true)];
      expect(ct.getDisplayNameByRule()).assertEqual('');
    })
    it("ContactInfoTest_getDisplayNameByRule_email", 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.emails = [new EmailBean('1', '北京', '1')];
      expect(ct.getDisplayNameByRule()).assertEqual('北京');
      ct.emails = [new EmailBean('1', '', '1')];
      expect(ct.getDisplayNameByRule()).assertEqual('');
    })
    it('ContactInfoTest_setDisplayName', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setDisplayName("DisplayName").display_name).assertEqual("DisplayName");
    })
    it('ContactInfoTest_setPhoneticName', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setPhoneticName("PhoneticName").phoneticName).assertEqual("PhoneticName");
    })
    it('ContactInfoTest_setPhones', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.phones = [new PhoneNumBean('1', '112', '1', '', '', true)];
      expect(JSON.stringify(ct.setPhones(ct.phones).phones)).assertEqual(JSON.stringify(ct.phones));
    })
    it('ContactInfoTest_setEmails', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.emails = [new EmailBean('1', '北京', '1')];
      expect(JSON.stringify(ct.setEmails(ct.emails).emails)).assertEqual(JSON.stringify(ct.emails));
    })
    it('ContactInfoTest_setAims', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.aims = [new AIMBean('1', '1', '1', '1')]
      expect(JSON.stringify(ct.setAims(ct.aims).aims)).assertEqual(JSON.stringify(ct.aims));
    })
    it('ContactInfoTest_setHouses', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.houses = [new HouseBean('1', '1', '1', '1')]
      expect(JSON.stringify(ct.setHouses(ct.houses).houses)).assertEqual(JSON.stringify(ct.houses));
    })
    it('ContactInfoTest_setWebsites', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = ['websites'];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(JSON.stringify(ct.setWebsites(websites).websites)).assertEqual(JSON.stringify(websites));
    })
    it('ContactInfoTest_setRelationships', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.relationships = [new AssociatedPersonBean('1', '1', '1', '1')]
      expect(JSON.stringify(ct.setRelationships(ct.relationships).relationships)).assertEqual(JSON.stringify(ct.relationships));
    })
    it('ContactInfoTest_setEvents', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.events = [new EventBean('1', '1', '1', '1')]
      expect(JSON.stringify(ct.setEvents(ct.events).events)).assertEqual(JSON.stringify(ct.events));
    })
    it('ContactInfoTest_setGroups', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname,
        phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      ct.groups = [new GroupBean(1, '1', '1', '1', '1', '1', 1, 1)]
      expect(JSON.stringify(ct.setGroups(ct.groups).groups)).assertEqual(JSON.stringify(ct.groups));
    })
    it('ContactInfoTest_setNickName', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setNickName("setNickName").nickname).assertEqual("setNickName");
    })
    it('ContactInfoTest_setRemarks', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setRemarks("setRemarks").remarks).assertEqual("setRemarks");
    })
    it('ContactInfoTest_setPosition', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setPosition("setPosition").position).assertEqual("setPosition");
    })
    it('ContactInfoTest_setCompany', 0, () => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(ct.setCompany("setCompany").company).assertEqual("setCompany");
    })

    it('ContactInfoTest_setRawContacts', 0, () => {
      let map: Map<string, string> = new Map();
      let rowContact: RawContact = new RawContact(1, map);
      let rowContactList: RawContact[] = [rowContact];
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean [] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      let ct = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
      expect(JSON.stringify(ct.setRawContacts(rowContactList))).assertEqual(JSON.stringify({
        "phoneticName": "",
        "otherLanLastName": "",
        "otherLanFirstName": "",
        "photo": null,
        "rawContacts": rowContactList,
        "personalRingtone": "",
        "personalRingtonePath": "",
        "personalNotificationRingtone": "",
        "contactID": "",
        "display_name": "",
        "nickname": "",
        "phones": [],
        "emails": [],
        "position": "",
        "company": "",
        "remarks": "",
        "aims": [],
        "houses": [],
        "websites": [],
        "relationships": [],
        "events": [],
        "groups": [],
        "favorite": -1,
        "rowContactID": ""
      }));
    })
  })
}