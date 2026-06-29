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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { GroupBean, GroupInfo } from '../../../../../../main/ets/model/bean/GroupBean';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';

export default function GroupBeanTest() {
  describe('GroupBeanTest', () => {
    let dataShareResultSet: DataShareResultSet;

    beforeEach(() => {
      dataShareResultSet = {
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
    })

    it('GroupBeanTest_constructor', 0, () => {
      let cb = new GroupBean(123456, "23", "3434", "23", "1", "tgwe", 23, 5, "23", "1");
      expect(cb.id).assertEqual(123456);
    })

    it('GroupBeanTest_setAll', 0, () => {
      let groupBean = new GroupBean(123456, "23", "3434", "23", "1", "tgwe", 23, 5, "23", "1");
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getColumnIndex);
      when(mockFun)(ArgumentMatchers.any).afterReturn(1);
      let mockFun1: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getLong);
      when(mockFun1)(1).afterReturn(1);
      let mockFun7: Function = mocker.mockFunc(dataShareResultSet, dataShareResultSet.getString);
      when(mockFun7)(1).afterReturn("1");
      groupBean.setAll(dataShareResultSet);
      expect(groupBean.id).assertEqual(1);
      mocker.clear(dataShareResultSet);
    })

    it('GroupBeanTest_GroupInfo_constructor', 0, () => {
      let groupBean = new GroupBean(123456789, "2333", "3434", "23", "1", "tgwe", 23, 5, "23", "1");

      let groupInfo = new GroupInfo(groupBean, 2, false);
      expect(groupInfo.memberCount).assertEqual(2);
    })
  })
}