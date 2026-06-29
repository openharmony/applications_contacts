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
import DialogEntryAbility from '../../../../../main/ets/dialogentryability/DialogEntryAbility';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Window from '@ohos.window';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'DiologEntryAbility ';

export default function DialogEntryAbilityTest() {
  describe('DialogEntryAbilityTest', () => {

    let dialogEntryAbility: DialogEntryAbility;

    beforeEach(() => {
      dialogEntryAbility = new DialogEntryAbility();
    })

    it('DialogEntryAbilityTest_onCreate', 0, () => {
      let want: Want = {};
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.UNKNOWN,
        lastExitReason: AbilityConstant.LastExitReason.UNKNOWN,
        lastExitMessage: ''
      };
      dialogEntryAbility.onCreate(want, launchParam);
      expect(dialogEntryAbility.pageManager).not().assertUndefined()
    })

    it('DialogEntryAbilityTest_onNewWant', 0, () => {
      let want: Want = {
        'parameters':{}
      }
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.UNKNOWN,
        lastExitReason: AbilityConstant.LastExitReason.UNKNOWN,
        lastExitMessage: ''
      };
      dialogEntryAbility.onNewWant(want, launchParam);
      expect(dialogEntryAbility.pageManager).not().assertUndefined()
    })

    it('DialogEntryAbilityTest_onDestroy', 0, () => {
      dialogEntryAbility.onDestroy();
      expect(dialogEntryAbility.pageManager).not().assertUndefined()
    })

    it('DialogEntryAbilityTest_onWindowStageCreate_error_return', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>) => {
          result = true;
          callback({
            code: 1300002, message: 'This window state is abnormal'
          } as BusinessError)
        }
      } as Window.WindowStage;

      dialogEntryAbility.onWindowStageCreate(windowStage);
      expect(result).assertTrue();
    })

    it('DialogEntryAbilityTest_onWindowStageCreate', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>) => {
          result = true;
          callback({
            message: 'this is not an error.'
          } as BusinessError)
        }
      } as Window.WindowStage;

      dialogEntryAbility.onWindowStageCreate(windowStage);

      expect(result).assertTrue();
    })


    it('DialogEntryAbilityTest_onWindowStageDestroy', 0, () => {
      dialogEntryAbility.onWindowStageDestroy();
      expect(dialogEntryAbility.test_DT).assertTrue();
    })

    it('DialogEntryAbilityTest_onForeground', 0, () => {
      dialogEntryAbility.onForeground();
      expect(dialogEntryAbility.test_DT).assertTrue();
    })

    it('DialogEntryAbilityTest_onBackground', 0, () => {
      dialogEntryAbility.onBackground();
      expect(dialogEntryAbility.test_DT).assertTrue();
    })
  })
}