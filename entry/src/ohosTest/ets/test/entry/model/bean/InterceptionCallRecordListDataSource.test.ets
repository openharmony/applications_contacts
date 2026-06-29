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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import MergedCallLog from '../../../../../../../../feature/call/src/main/ets/entity/MergedCallLog'
import InterceptionCallRecordListDataSource
  from '../../../../../../main/ets/model/bean/InterceptionCallRecordListDataSource'
import { CallLog } from '../../../../../../../../feature/call/src/main/ets/entity/CallLog';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';

export default function InterceptionCallRecordListDataSourceTest() {
  describe('InterceptionCallRecordListDataSourceTest', () => {
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
    it('InterceptionCallRecordListDataSourceTest_getData', 0, () => {
      let inter: InterceptionCallRecordListDataSource = new InterceptionCallRecordListDataSource();
      expect(inter.getData(1)).assertNull();

      let callLogData: MergedCallLog[] = [];
      let callLog: CallLog = new CallLog(new CallLogBuilder(-1, ''));
      let bean: MergedCallLog = new MergedCallLog(callLog);
      bean.createInterceptionTime = '1';
      let result: LooseObject = {
        showIndex: true,
        showDivider: false,
        callLogData: bean
      }
      callLogData.push(bean);
      inter.refreshAll(callLogData);
      expect(JSON.stringify(inter.getData(0))).assertEqual(JSON.stringify(result));

      let result1: LooseObject = {
        showIndex: true,
        showDivider: true,
        callLogData: bean
      }
      let bean1:MergedCallLog = new MergedCallLog(callLog);
      bean1.createInterceptionTime = '1';
      callLogData.push(bean1);
      inter.refreshAll(callLogData);
      expect(JSON.stringify(inter.getData(0))).assertEqual(JSON.stringify(result1));

      expect(JSON.stringify(inter.getCallLogData())).assertEqual(JSON.stringify(callLogData));
    })

    it('InterceptionCallRecordListDataSourceTest_setIsShow', 0, () => {
      let inter: InterceptionCallRecordListDataSource = new InterceptionCallRecordListDataSource();
      inter.clean();
      inter.setIsShow(false);
      expect(inter.totalCount()).assertEqual(0);
      inter.setIsShow(true);
      expect(inter.totalCount()).assertEqual(0);
    })

    it('InterceptionCallRecordListDataSourceTest_remove', 0, () => {
      let inter: InterceptionCallRecordListDataSource = new InterceptionCallRecordListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(inter, inter.notifyDataDelete)
      inter.remove(0, 0);
      mocker.verify('notifyDataDelete', [0]).never();

      when(mocker.mockFunc(inter, inter.totalCount))().afterReturn(3);
      inter.remove(0, 0);
      mocker.verify('notifyDataDelete', [0]).once();
      mocker.clear(inter);
    })

    it('InterceptionCallRecordListDataSourceTest_refresh', 0, () => {
      let inter: InterceptionCallRecordListDataSource = new InterceptionCallRecordListDataSource();
      let callLogData: MergedCallLog[] = [];
      inter.setIsShow(true);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(inter, inter.notifyDataReload);
      inter.refresh(0, callLogData, true);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(inter);
    })
  })
}