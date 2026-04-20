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
import { PageLimit } from '../../../../../../../main/ets/model/type'
import HiCarCallRecordPresenter
  from '../../../../../../../main/ets/presenter/dialer/callRecord/HiCarCallRecordPresenter'
import { LimitRefreshDataUtil } from '../../../../../../../main/ets/util/LimitRefreshDataUtil'
import { ContactsGlobalThisHelper } from '../../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper'
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory'


export default function HiCarCallRecordPresenterTest() {
  describe('HiCarCallRecordPresenterTest', () => {
    let limitDataRefresh: LimitRefreshDataUtil<PageLimit, number>;
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      limitDataRefresh = new LimitRefreshDataUtil('getAllCalls', (resultPage: number, limit: number, result: number) => true);
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
    it('HiCarCallRecordPresenterTest_setPageShow', 0, () => {
      HiCarCallRecordPresenter.getInstance().setPageShow(false, true);
      expect(HiCarCallRecordPresenter.getInstance().getAllCallsError).assertFalse();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(limitDataRefresh, limitDataRefresh?.requestItem);
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      HiCarCallRecordPresenter.getInstance().setPageShow(true, false);
      expect(AppStorage.get('sysMinutesTime')).assertEqual(Math.floor(new Date().valueOf() / 1000 / 60));
      mocker.clear(limitDataRefresh);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })
  })
}