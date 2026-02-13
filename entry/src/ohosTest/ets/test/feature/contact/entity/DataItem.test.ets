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
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet'
import { DataItem } from '../../../../../../../../feature/contact/src/main/ets/entity/DataItem'
import { Data } from '../../../../../../../../feature/contact'

export default function DataItemTest() {
  describe('DataItemTest', () => {
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
    it('DataItemTest_getId', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("id", 0);
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getId();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("id")));
    })
    it('DataItemTest_getContentTypeId', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("type_id", 1);
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getContentTypeId();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("type_id")));
    })
    it('DataItemTest_getData', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("detail_info", "1");
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getData();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("detail_info")));
    })
    it('DataItemTest_getPhoneticName', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set('phonetic_name', '1');
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getPhoneticName();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("phonetic_name")));
    })
    it('DataItemTest_getLabelId', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("extend7", 1);
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getLabelId();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("extend7")));
    })
    it('DataItemTest_getLabelName', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("custom_data", 1)
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getLabelName();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("custom_data")));
    })
    it('DataItemTest_getFavorite', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("favorite", 1);
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getFavorite();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("favorite")));
    })
    it('DataItemTest_getSuperPrimary', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("extend5", 1);
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getSuperPrimary();
      expect(JSON.stringify(expectedImgSrc1)).assertEqual(JSON.stringify(values.get("extend5")));
    })
    it('DataItemTest_fromResultSet', 0, () => {
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
      }
      ;
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getColumnIndex);
      when(mockFun)(ArgumentMatchers.any).afterReturn(1);
      let mockFun1: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getLong);
      when(mockFun1)(1).afterReturn(1)
      let mockFun7: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getString);
      when(mockFun7)(1).afterReturn("1")

      let dataItem = DataItem.fromResultSet(dataShareResultSet)
      let values: Map<string, string | number> = new Map();
      values.set(Data.ID, 1)
      values.set(Data.TYPE_ID, 1)
      values.set(Data.RAW_CONTACT_ID, 1)
      values.set(Data.READ_ONLY, 1)
      values.set(Data.DETAIL_INFO, "1")
      values.set(Data.FAMILY_NAME, "1")
      values.set(Data.MIDDLE_NAME_PHONETIC, "1")
      values.set(Data.IS_PREFERRED_NUMBER, 1)
      values.set(Data.GIVEN_NAME, "1")
      values.set(Data.ALIAS_DETAIL_INTO, "1")
      values.set(Data.FORMAT_PHONE_NUMBER,"1")
      values.set(Data.PHONETIC_NAME, "1")
      values.set(Data.POSITION, "1")
      values.set(Data.CITY, "1")
      values.set(Data.COUNTRY, "1")
      values.set(Data.NEIGHBORHOOD, "1")
      values.set(Data.POBOX, "1")
      values.set(Data.POSTCODE, "1")
      values.set(Data.REGION, "1")
      values.set(Data.STREET, "1")
      values.set(Data.ALPHA_NAME, "1")
      values.set(Data.OTHER_LAN_LAST_NAME, "1")
      values.set(Data.OTHER_LAN_FIRST_NAME, "1")
      values.set(Data.EXTEND1, "1")
      values.set(Data.EXTEND2, "1")
      values.set(Data.EXTEND3, "1")
      values.set(Data.EXTEND4, "1")
      values.set(Data.EXTEND5, "1")
      values.set(Data.EXTEND6, "1")
      values.set(Data.EXTEND7, "1")
      values.set(Data.SYN_1, "1")
      values.set(Data.SYN_2, "1")
      values.set(Data.SYN_3, "1")
      values.set(Data.FAVORITE, "1")
      let dataItem1 = new DataItem(values);
      expect(JSON.stringify(dataItem)).assertEqual(JSON.stringify(dataItem1));
      mocker.clear(dataShareResultSet);
    })
    it('DataItemTest_getExtend1', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("extend1", 1)
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getExtend1();
      expect(expectedImgSrc1).not().assertNull();
    })
    it('DataItemTest_getExtend2', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("extend2", 2)
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getExtend2();
      expect(expectedImgSrc1).not().assertNull();
    })
    it('DataItemTest_getExtend4', 0, () => {
      let values: Map<string, string | number> = new Map();
      values.set("extend4", 4)
      let dataItem = new DataItem(values);
      const expectedImgSrc1 = dataItem.getExtend4();
      expect(expectedImgSrc1).not().assertNull();
    })
  })
}