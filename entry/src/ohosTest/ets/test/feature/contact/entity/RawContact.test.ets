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
import RawContact from '../../../../../../../../feature/contact/src/main/ets/entity/RawContact'
import { RawContacts } from '../../../../../../../../feature/contact'


export default function RawContactTest() {
  describe('RawContactTest', () => {
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
    it('RawContactTest_fromResultSet', 0, () => {
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
      let mock: MockKit = new MockKit()
      let mockFun: Function = mock.mockFunc(dataShareResultSet,dataShareResultSet.getColumnIndex);
      when(mockFun)(ArgumentMatchers.any).afterReturn(1);
      let mockFun1: Function = mock.mockFunc(dataShareResultSet,dataShareResultSet.getLong);
      when(mockFun1)(1).afterReturn(1)
      let mockFun7: Function = mock.mockFunc(dataShareResultSet,dataShareResultSet.getString);
      when(mockFun7)(1).afterReturn("1")
      let rawContact = RawContact.fromResultSet(dataShareResultSet)
      let values: Map<string, string | number> = new Map();
      values.set(RawContacts.CONTACT_ID,1)
      values.set(RawContacts.PHOTO_ID,1)
      values.set(RawContacts.PHOTO_FILE_ID,1)
      values.set(RawContacts.IS_TRANSFER_VOICEMAIL,1)
      values.set(RawContacts.PERSONAL_RINGTONE,"1")
      values.set(RawContacts.PERSONAL_NOTIFICATION_RINGTONE,"1")
      values.set(RawContacts.PHOTO_FIRST_NAME,"1")
      values.set(RawContacts.ACCOUNT_ID,1)
      values.set(RawContacts.DISPLAY_NAME,"1")
      values.set(RawContacts.SORT,"1")
      values.set(RawContacts.CONTACTED_COUNT,"1")
      values.set(RawContacts.LASTEST_CONTACTED_TIME,"1")
      values.set(RawContacts.FAVORITE,"1")
      values.set(RawContacts.FAVORITE_ORDER,"1")
      values.set(RawContacts.PHONETIC_NAME,"1")
      values.set(RawContacts.COMPANY,"1")
      values.set(RawContacts.POSITION,"1")
      let rawContact1 = new RawContact(1,values)
      expect(JSON.stringify(rawContact)).assertEqual(JSON.stringify(rawContact1));
      mock.clear(dataShareResultSet);




    })
  })
}