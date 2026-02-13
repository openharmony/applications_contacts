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
import { describe, beforeEach, it, expect, MockKit } from '@ohos/hypium'
import BasicDataSource from '../../../../../../main/ets/model/bean/BasicDataSource'

export default function BasicDataSourceTest() {
  describe('BasicDataSourceTest', () => {
    let basicDataSource: BasicDataSource;
    let listener: DataChangeListener;

    beforeEach(() => {
      basicDataSource = new BasicDataSource();
      listener = {
        onDataReloaded: () => {
        },
        onDataAdded: () => {
        },
        onDataAdd: () => {
        },
        onDataMoved: () => {
        },
        onDataMove: () => {
        },
        onDataDeleted: () => {
        },
        onDataDelete: () => {
        },
        onDataChanged: () => {
        },
        onDataChange: (index: number) => {
        },
        onDatasetChange: (dataOperations: DataOperation[]): void => {
        }
      };
    })

    it('BasicDataSourceTest_totalCount', 0, () => {
      let num = 0;
      let totalnum = basicDataSource.totalCount();
      expect(num).assertEqual(totalnum);
    })
    it('BasicDataSourceTest_getData', 0, () => {
      let num = 0;
      let getdate = basicDataSource.getData(num);
      expect(getdate).assertEqual(undefined);
    })
    it('BasicDataSourceTest_registerDataChangeListener', 0, () => {
      basicDataSource.registerDataChangeListener(listener);
      expect(JSON.stringify(basicDataSource.listeners[0])).assertEqual(JSON.stringify(listener));

      basicDataSource.listeners.push(listener);
      basicDataSource.registerDataChangeListener(listener);
      expect(JSON.stringify(basicDataSource.listeners[0])).assertEqual(JSON.stringify(listener));
    })
    it('BasicDataSourceTest_unregisterDataChangeListener', 0, () => {
      basicDataSource.listeners = [listener]
      basicDataSource.unregisterDataChangeListener(listener);
      expect(basicDataSource.listeners.length).assertEqual(0);

      basicDataSource.listeners = [];
      basicDataSource.unregisterDataChangeListener(listener);
      expect(basicDataSource.listeners.length).assertEqual(0);
    })
    it('BasicDataSourceTest_notifyDataReload', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(listener, listener.onDataReloaded);
      basicDataSource.listeners = [listener]
      basicDataSource.notifyDataReload();
      mocker.verify('onDataReloaded', []).once();
      mocker.clear(listener)
    })
    it('BasicDataSourceTest_notifyDataAdd', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(listener, listener.onDataAdd);
      basicDataSource.listeners = [listener]
      basicDataSource.notifyDataAdd(0);
      mocker.verify('onDataAdd', [0]).once();
      mocker.clear(listener)
    })
    it('BasicDataSourceTest_notifyDataChange', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(listener, listener.onDataChange);
      basicDataSource.listeners = [listener]
      basicDataSource.notifyDataChange(0);
      mocker.verify('onDataChange', [0]).once();
      mocker.clear(listener)
    })
    it('BasicDataSourceTest_notifyDataDelete', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(listener, listener.onDataDelete);
      basicDataSource.listeners = [listener]
      basicDataSource.notifyDataDelete(0);
      mocker.verify('onDataDelete', [0]).once();
      mocker.clear(listener)
    })
    it('BasicDataSourceTest_notifyDataMove', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(listener, listener.onDataMove);
      basicDataSource.listeners = [listener]
      basicDataSource.notifyDataMove(0, 1);
      mocker.verify('onDataMove', [0, 1]).once();
      mocker.clear(listener)
    })
  })
}