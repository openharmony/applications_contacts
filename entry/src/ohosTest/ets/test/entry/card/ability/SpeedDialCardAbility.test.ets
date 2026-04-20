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
import SpeedDialCardAbility from '../../../../../../main/ets/card/ability/SpeedDialCardAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { Rect } from '@ohos.application.AccessibilityExtensionAbility';
import { AsyncCallback, BusinessError } from '@ohos.base';
import Window from '@ohos.window';
import { common, Want } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { sharedPreferencesUtils } from '../../../../../../../../feature/call/oh_modules/common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { preferences } from '@kit.ArkData';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';

const TAG = 'SpeedDialCardAbilityTAG';

export default function SpeedDialCardAbilityTest() {
  describe('SpeedDialCardAbility', () => {

    let speedDialCardAbility: SpeedDialCardAbility;

    beforeEach(() => {
      speedDialCardAbility = new SpeedDialCardAbility();
    })

    it('SpeedDialCardAbility_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      speedDialCardAbility.onCreate();
      mocker.verify('w', [TAG, `Ability onCreate`]).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialCardAbility_onForeground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      speedDialCardAbility.onForeground();
      mocker.verify('w', [TAG, `Ability onForeground`]).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialCardAbility_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      speedDialCardAbility.onBackground();
      mocker.verify('w', [TAG, `Ability onBackground`]).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialCardAbility_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      speedDialCardAbility.onDestroy();
      mocker.verify('w', [TAG, `Ability onDestroy`]).once();
      mocker.clear(HiLog);
    })
  })
}