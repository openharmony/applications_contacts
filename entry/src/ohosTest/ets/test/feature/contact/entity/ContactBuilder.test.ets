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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet'
import ContactBuilder from '../../../../../../../../feature/contact/src/main/ets/entity/ContactBuilder'
import RawContact from '../../../../../../../../feature/contact/src/main/ets/entity/RawContact'
import Contact from '../../../../../../../../feature/contact/src/main/ets/entity/Contact'

export default function ContactBuilderTest() {
  describe('ContactBuilderTest', () => {
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
    it('ContactBuilderTest_setNameRawContactId', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setNameRawContactId(1)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setPhotoId', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setPhotoId(1)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setPhotoFileId', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setPhotoFileId(1)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setQuickSearchKey', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setQuickSearchKey("1")
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setPersonalNotificationRingtone', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setPersonalNotificationRingtone("1")
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setPersonalRingtone', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setPersonalRingtone("1")
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setIsTransferVoiceMail', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setIsTransferVoiceMail(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setCompany', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setCompany("1")
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setPosition', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setPosition("1")
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setHasDisplayName', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setHasDisplayName(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setReadOnly', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setReadOnly(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setHasPhoneNumber', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setHasPhoneNumber(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setHasGroup', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setHasGroup(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_setHasEmail', 0, () => {
      let contactBuilder = new ContactBuilder(1)
      const expectedImgSrc1 = contactBuilder.setHasEmail(true)
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(expectedImgSrc1));

    })
    it('ContactBuilderTest_fromResultSet', 0, () => {
      let dataShareResultSet: DataShareResultSet = {
        columnNames: [],
        columnCount: 0,
        rowCount: 0,
        isClosed: false,
        goToFirstRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToLastRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToNextRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToPreviousRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goTo: (offset: number): boolean => {
          throw new Error('Function not implemented.');
        },
        goToRow: (position: number): boolean => {
          throw new Error('Function not implemented.');
        },
        getBlob: (columnIndex: number): Uint8Array => {
          throw new Error('Function not implemented.');
        },
        getString: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getLong: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        getDouble: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        close: () => {
          throw new Error('Function not implemented.');
        },
        getColumnIndex: (columnName: string): number => {
          throw new Error('Function not implemented.');
        },
        getColumnName: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getDataType: (columnIndex: number): DataType => {
          throw new Error('Function not implemented.');
        }
      };
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getColumnIndex);
      when(mockFun)(ArgumentMatchers.any).afterReturn(1);
      let mockFun1: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getLong);
      when(mockFun1)(1).afterReturn(1)
      let mockFun7: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getString);
      when(mockFun7)(1).afterReturn("1")
      let contactBuilder = ContactBuilder.fromResultSet(dataShareResultSet)
      let contactBuilder1 = new ContactBuilder(1);
      contactBuilder1.nameRawContactId = 1;
      let rowContanct: RawContact[] = [];
      contactBuilder1.quickSearchKey = "1"
      contactBuilder1.photoId =1;
      contactBuilder1.photoFileId = 1;
      contactBuilder1.personalRingtone = "1";
      contactBuilder1.personalNotificationRingtone = "1";
      contactBuilder1.isTransferVoiceMail = true;
      contactBuilder1.company = "1";
      contactBuilder1.position = "1";
      contactBuilder1.hasDisplayName = true;
      contactBuilder1.hasPhoneNumber = true;
      contactBuilder1.readOnly = true;
      contactBuilder1.hasGroup = true;
      contactBuilder1.hasEmail = true;
      contactBuilder1.rowContacts = rowContanct;
      contactBuilder1.personalRingtonePath = '1';
      expect(JSON.stringify(contactBuilder)).assertEqual(JSON.stringify(contactBuilder1));
      mocker.clear(dataShareResultSet);
    })
    it("ContactBuilderTest_buildContact", 0, () => {
      let contactBuilder1 = new ContactBuilder(1);
      contactBuilder1.nameRawContactId = 1;
      let rowContanct: RawContact[] = [];
      contactBuilder1.quickSearchKey = "1";
      contactBuilder1.photoId = 1;
      contactBuilder1.photoFileId = 1;
      contactBuilder1.personalRingtone = "1";
      contactBuilder1.personalNotificationRingtone = "1";
      contactBuilder1.isTransferVoiceMail = true;
      contactBuilder1.company = "1";
      contactBuilder1.position = "1";
      contactBuilder1.hasDisplayName = true;
      contactBuilder1.hasPhoneNumber = true;
      contactBuilder1.readOnly = true;
      contactBuilder1.hasGroup = true;
      contactBuilder1.hasEmail = true;
      contactBuilder1.rowContacts = rowContanct;
      let contact1 = contactBuilder1.buildContact();
      let contact2 = new Contact(contactBuilder1);
      expect(JSON.stringify(contact1)).assertEqual(JSON.stringify(contact2));
    })
  })
}