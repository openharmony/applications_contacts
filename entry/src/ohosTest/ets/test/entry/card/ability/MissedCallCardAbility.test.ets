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
import MissedCallCardAbility from '../../../../../../main/ets/card/ability/MissedCallCardAbility';
import Window from '@ohos.window';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { Rect } from '@ohos.application.AccessibilityExtensionAbility';
import { AsyncCallback, BusinessError } from '@ohos.base';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { common, Want } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { sharedPreferencesUtils } from '../../../../../../../../feature/call/oh_modules/common';
import { preferences } from '@kit.ArkData';
import missedCallEditCommon from '../../../../../../main/ets/card/common/MissedCallEditCommon';
import { formBindingData } from '@kit.FormKit';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';

const TAG = 'MissedCallCardAbilityTAG ';

export default function MissedCallCardAbilityTest() {
  describe('MissedCallCardAbilityTest', () => {

    let missedCallCardAbility: MissedCallCardAbility;
    let result: boolean;

    beforeEach(() => {
      result = false;
      missedCallCardAbility = new MissedCallCardAbility();
      missedCallCardAbility.common = {
        updateToCard: (formId: string, data: formBindingData.FormBindingData): void => {
          result = true;
        }
      } as missedCallEditCommon;
    })

    it('MissedCallCardAbilityTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      missedCallCardAbility.onCreate();
      mocker.verify('w', [TAG, `Ability onCreate`]).never();
      mocker.clear(HiLog);
    })

    it('MissedCallCardAbilityTest_onForeground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      missedCallCardAbility.onForeground();
      mocker.verify('w', [TAG, `Ability onForeground`]).never();
      mocker.clear(HiLog);
    })

    it('MissedCallCardAbilityTest_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      missedCallCardAbility.onBackground();
      mocker.verify('w', [TAG, `Ability onBackground`]).never();
      mocker.clear(HiLog);
    })

    it('MissedCallCardAbilityTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      missedCallCardAbility.onDestroy();
      mocker.verify('w', [TAG, `Ability onDestroy`]).never();
      mocker.clear(HiLog);
    })
  })
}