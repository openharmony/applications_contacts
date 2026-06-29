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
import { describe, beforeEach, it, expect, MockKit } from '@ohos/hypium';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import PageManager from '../../../../../main/ets/dialogentryability/PageManager';
import Want from '@ohos.app.ability.Want';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'DialogPageManager';

export default function PageManagerTest() {
  describe('PageManagerTest', () => {

    let pageManager: PageManager;

    beforeEach(() => {
      let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      pageManager = new PageManager(context);
    })

    it('PageManagerTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(pageManager, pageManager.onRequest);
      let want: Want = {}
      pageManager.onCreate(want);
      mocker.verify('onRequest', [want.parameters as Record<string, Object>, true]).once();
      mocker.clear(pageManager);
    })

    it('PageManagerTest_onNewWant', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(pageManager, pageManager.onRequest);
      let want: Want = {}
      pageManager.onNewWant(want);
      mocker.verify('onRequest', [want.parameters as Record<string, Object>, false]).once();
      mocker.clear(pageManager);
    })

    it('PageManagerTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      pageManager.onDestroy();
      mocker.verify('i', [TAG, 'onDestroy']).once();
      mocker.clear(HiLog);
    })

    it('PageManagerTest_onRequest_multi_num_dialog', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'multi_num_dialog',
        'contactId': '0'
      }
      pageManager.onRequest(parameters, true)
      expect(pageManager.mainUrl).assertEqual('pages/dialogPage/multiNumIndex')
    })

    it('PageManagerTest_onRequest_multi_sim_dialog', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'multi_sim_dialog',
        'contactId': '0'
      }
      pageManager.onRequest(parameters, true);
      expect(pageManager.mainUrl).assertEqual('pages/dialogPage/multiSimIndex')
    })

    it('PageManagerTest_onRequest_multi_other_dialog_true', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'multi_other_dialog',
        'contactId': '0'
      }
      pageManager.onRequest(parameters, true);
      expect(pageManager.mainUrl).assertEqual('pages/index')
    })

    it('PageManagerTest_onRequest_multi_other_dialog_false', 0, () => {
      let parameters: Record<string, Object> = {
        'pageFlag': 'multi_other_dialog',
        'contactId': '0'
      }
      pageManager.onRequest(parameters, false);
      expect(pageManager.mainUrl).assertEqual('pages/index')
    })

  })
}