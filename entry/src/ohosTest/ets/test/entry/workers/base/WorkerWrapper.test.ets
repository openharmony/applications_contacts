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
import { describe, it, expect, MockKit, beforeEach } from '@ohos/hypium';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';

export default function WorkWrapperTest() {
  describe('WorkWrapperTest', () => {
    let workerWrapper: WorkerWrapper;
    const TAG = 'WorkerWrapper'

    beforeEach(() => {
      workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
    })

    it('WorkWrapperTest_getWorkerType2', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(workerWrapper, workerWrapper.initWorker);

      expect(workerWrapper.getWorkerType()).assertEqual(WorkerType.DataWorker);

      mocker.verify('initWorker', []).never();

      mocker.clear(workerWrapper);
    })

    it('WorkWrapperTest_getMWorker', 0, () => {
      expect(workerWrapper.getMWorker()).assertUndefined();
    })

    it('WorkWrapperTest_getRequestIndex', 0, () => {
      expect(workerWrapper.getRequestIndex()).assertEqual(0);
    })

    it('WorkWrapperTest_close', 0, async () => {
      await workerWrapper.close();
      expect(workerWrapper.DTResult).assertTrue();
    })
  })
}