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
import { CallType } from '../../../../../../../../feature/call';
import CallDetail from '../../../../../../main/ets/model/bean/CallDetail';
import DetailCallLogDataSource from '../../../../../../main/ets/model/bean/DetailCallLogDataSource';

export default function DetailCallLogDataSourceTest() {
  describe('DetailCallLogDataSourceTest', () => {
    it('DetailCallLogDataSourceTest_totalCount', 0, () => {
      let cd = new DetailCallLogDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('DetailCallLogDataSourceTest_refresh', 0, () => {
      let detailCallLogList: CallDetail[] = [];
      let cd = new DetailCallLogDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, detailCallLogList, true);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('DetailCallLogDataSourceTest_getData', 0, () => {
      let cd = new DetailCallLogDataSource();
      expect(cd.getData(0)).assertEqual(null);
      let detailCallLogList: CallDetail[] = [];
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      cd.refresh(0, detailCallLogList, true)
      expect(cd.getData(0)?.showTitle).assertEqual(true)
    })

    it("DetailCallLogDataSourceTest_getAllData", 0, () => {
      let cd = new DetailCallLogDataSource();
      new CallDetail('', '', '', '', '', CallType.IN, '', '', 1, 1, 0, '', '', 0, '', '', 0, -1, -1, "", "", "", "", "", -1, -1, "")
      expect(JSON.stringify(cd.getAllData())).assertEqual(JSON.stringify([]))
    })

    it("DetailCallLogDataSourceTest_remove", 0, () => {
      let cd = new DetailCallLogDataSource();
      cd.remove(-1);

      let detailCallLogList: CallDetail[] = [];
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      cd.refresh(0, detailCallLogList, true)

      cd.remove(5);

      expect(cd.totalCount()).assertEqual(2);
    })

    it("DetailCallLogDataSourceTest_remove_001", 0, () => {
      let cd = new DetailCallLogDataSource();
      let detailCallLogList: CallDetail[] = [];
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      cd.refresh(0, detailCallLogList, true)

      cd.remove(1);
      expect(cd.totalCount()).assertEqual(1);
    })

    it("DetailCallLogDataSourceTest_remove_002", 0, () => {
      let cd = new DetailCallLogDataSource();
      let detailCallLogList: CallDetail[] = [];
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      detailCallLogList.push(new CallDetail("", "", "", "", "", CallType.IN,
        "", "", -1, 1, -1, "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""))
      cd.refresh(0, detailCallLogList, true)

      cd.remove(1, 1);
      expect(cd.totalCount()).assertEqual(1);
    })

    it('DetailCallLogDataSourceTest_refresh_001', 0, () => {
      let detailCallLogList: CallDetail[] = [];
      let cd = new DetailCallLogDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, detailCallLogList, false);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })
  })
}