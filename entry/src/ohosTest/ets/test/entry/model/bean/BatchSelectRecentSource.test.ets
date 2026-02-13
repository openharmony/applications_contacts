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
import { ArrayUtil } from '../../../../../../../../common';
import { CallLog } from '../../../../../../../../feature/call';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import MergedCallLog from '../../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import BatchSelectRecentSource from '../../../../../../main/ets/model/bean/BatchSelectRecentSource';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';

export default function BatchSelectRecentSourceTest() {
  describe('BatchSelectRecentSourceTest', () => {

    it('BatchSelectRecentSourceTest_totalCount', 0, () => {
      let bsr = new BatchSelectRecentSource();
      expect(bsr.totalCount()).assertEqual(0)
    })

    it('BatchSelectRecentSourceTest_getData', 0, () => {
      let bsr = new BatchSelectRecentSource();
      expect(bsr.getData(0)).assertEqual(null)
    })

    it('BatchSelectRecentSourceTest_getData2', 0, () => {
      let mocker: MockKit = new MockKit();
      let index = 0;
      let bsr = new BatchSelectRecentSource();
      let callLogs: MergedCallLog[] = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];

      mocker.mockFunc(bsr, bsr.notifyDataReload);

      bsr.refresh(callLogs);

      let showDivifer: boolean = !ArrayUtil.isEmpty(callLogs) && (index != (callLogs.length - 1));
      let result:LooseObject = {
        showDivifer: showDivifer,
        index: index,
        calllog: callLogs[index]
      } as LooseObject;

      expect(JSON.stringify(bsr.getData(0))).assertEqual(JSON.stringify(result))
      mocker.clear(bsr);
    })

    it('BatchSelectRecentSourceTest_refresh', 0, () => {
      let mocker: MockKit = new MockKit();
      let bsr = new BatchSelectRecentSource();

      mocker.mockFunc(bsr, bsr.notifyDataReload);

      bsr.refresh([]);

      mocker.verify('notifyDataReload', []).once();
      mocker.clear(bsr);
    })

    it('BatchSelectRecentSourceTest_refreshSpecificOne', 0, () => {
      let mocker: MockKit = new MockKit();
      let bsr = new BatchSelectRecentSource();
      let callLogs: MergedCallLog[] = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];

      mocker.mockFunc(bsr, bsr.notifyDataReload);
      mocker.mockFunc(bsr, bsr.notifyDataChange);

      bsr.refresh(callLogs);

      bsr.refreshSpecificOne(0, false);

      mocker.verify('notifyDataChange', [0]).once();
      mocker.clear(bsr);
    })
  })
}