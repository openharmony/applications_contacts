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
import { describe, it, expect, MockKit } from '@ohos/hypium';
import RecentDeleteDataSource from '../../../../../../main/ets/model/bean/RecentDeleteDataSource';
import RecentDeleteBean from '../../../../../../main/ets/model/bean/RecentDeleteBean';

export default function RecentDeleteDataSourceTest() {
  describe('RecentDeleteDataSourceTest', () => {
    it('RecentDeleteDataSourceTest_totalCount', 0, () => {
      let cd = new RecentDeleteDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('RecentDeleteDataSourceTest_refresh', 0, () => {
      let cd = new RecentDeleteDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(cd.recentDeleteList);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('RecentDeleteDataSourceTest_getRecentDeleteData', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      callLogData.push(new RecentDeleteBean(2, "action2", "", 2, false));
      cd.refresh(callLogData);
      expect(cd.getRecentDeleteData().length).assertEqual(2)
    })

    it('RecentDeleteDataSourceTest_getRecentDeleteList', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      callLogData.push(new RecentDeleteBean(2, "action2", "", 2, false));
      cd.refresh(callLogData);
      expect(cd.getRecentDeleteList().length).assertEqual(2)
    })

    it('RecentDeleteDataSourceTest_getData_if_1', 0, () => {
      let cd = new RecentDeleteDataSource();
      cd.refresh([]);
      let result: RecentDeleteBean | null = cd.getData(0);
      expect(result).assertNull();
    })

    it('RecentDeleteDataSourceTest_getData_if_2', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      cd.refresh(callLogData);
      let result: RecentDeleteBean | null = cd.getData(2);
      expect(result).assertNull();
    })

    it('RecentDeleteDataSourceTest_getData_if_3', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      cd.refresh(callLogData);
      let result: RecentDeleteBean | null = cd.getData(0);
      expect(result?.id).assertEqual(1);
    })

    it('RecentDeleteDataSourceTest_remove_if_1', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      callLogData.push(new RecentDeleteBean(2, "action2", "", 2, false));
      cd.refresh(callLogData);
      cd.remove(-1);

      expect(cd.getRecentDeleteList().length).assertEqual(2)
    })

    it('RecentDeleteDataSourceTest_remove_if_2', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      callLogData.push(new RecentDeleteBean(2, "action2", "", 2, false));
      cd.refresh(callLogData);
      cd.remove(2);

      expect(cd.getRecentDeleteList().length).assertEqual(2)
    })

    it('RecentDeleteDataSourceTest_remove_if_3', 0, () => {
      let cd = new RecentDeleteDataSource();
      let callLogData: RecentDeleteBean[] = [];
      callLogData.push(new RecentDeleteBean(1, "action1", "", 1, false));
      callLogData.push(new RecentDeleteBean(2, "action2", "", 2, false));
      cd.refresh(callLogData);
      cd.remove(1);

      expect(cd.getRecentDeleteList().length).assertEqual(1)
    })
  })
}