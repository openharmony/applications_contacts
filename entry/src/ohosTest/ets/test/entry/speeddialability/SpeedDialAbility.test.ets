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
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import SpeedDialAbility from '../../../../../main/ets/speeddialability/SpeedDialAbility';
import window from '@ohos.window';
import { AsyncCallback, BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common'

export default function SpeedDialAbilityTest() {
  const TAG = 'SpeedDialAbility ';
  describe('SpeedDialAbilityTest', () => {

    let speedDialAbility: SpeedDialAbility;
    beforeEach(() => {
      speedDialAbility = new SpeedDialAbility();
    })

    it('SpeedDialAbilityTest_onCreate', 0, () => {
      let want: Want = {
        'parameters': {}
      }

      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.UNKNOWN,
        lastExitReason: AbilityConstant.LastExitReason.UNKNOWN,
        lastExitMessage:''
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(speedDialAbility, speedDialAbility.toVoicemailPage);

      speedDialAbility.onCreate(want, launchParam);

      mocker.verify('toVoicemailPage', [want]).once();
      mocker.clear(speedDialAbility);
    })

    it('SpeedDialAbilityTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      speedDialAbility.onDestroy();
      mocker.verify('i', [TAG, 'SpeedDialAbility onDestroy']).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_if', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 1300002, message: 'This window state is abnormal.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_if_stringify_undefined', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 1300002, message: 'This window state is abnormal.'
          } as BusinessError)
        }
      } as window.WindowStage;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(JSON,JSON.stringify))(ArgumentMatchers.any).afterReturn(undefined);

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();

      mocker.clear(JSON);
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_if_err_undefined', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 1300002, message: 'This window state is abnormal.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_try_if_return', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'This is not an error.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 16000050, message: 'Internal error'
          } as BusinessError);
        }
      } as common.UIAbilityContext;

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_try_if', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'This is not an error.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            message: 'this is not an error'
          } as BusinessError);
        }
      } as common.UIAbilityContext;

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_try_if_stringify_undefined', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'This is not an error.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            message: 'this is not an error'
          } as BusinessError);
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(JSON,JSON.stringify))(ArgumentMatchers.any).afterReturn(undefined);

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();

      mocker.clear(JSON);
    })

    it('SpeedDialAbilityTest_onWindowStageCreate_catch', 0, () => {
      let result = false;
      let windowStage: window.WindowStage = {
        loadContent: (path: string, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'This is not an error.'
          } as BusinessError)
        }
      } as window.WindowStage;

      speedDialAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          throw new Error('error');
        }
      } as common.UIAbilityContext;

      speedDialAbility.onWindowStageCreate(windowStage);

      expect(result).assertFalse();
    })


    it('SpeedDialAbilityTest_onWindowStageDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      speedDialAbility.onWindowStageDestroy();
      mocker.verify('i', [TAG, 'SpeedDialAbility onWindowStageDestroy']).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialAbilityTest_onForeground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      speedDialAbility.onForeground();
      mocker.verify('i', [TAG, 'SpeedDialAbility onForeground']).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialAbilityTest_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      speedDialAbility.onBackground();
      mocker.verify('i', [TAG, 'SpeedDialAbility onBackground']).once();
      mocker.clear(HiLog);
    })

    it('SpeedDialAbilityTest_onNewWant', 0, () => {
      let parameters: Record<string, string> = {
        'contactObjects': ''
      };
      let want: Want = {
        'parameters': parameters,
        'uri': ''
      };
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.UNKNOWN,
        lastExitReason: AbilityConstant.LastExitReason.UNKNOWN,
        lastExitMessage:''
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(speedDialAbility, speedDialAbility.toVoicemailPage);
      speedDialAbility.onNewWant(want, launchParam);
      mocker.verify('toVoicemailPage', [want]).once();
      mocker.clear(speedDialAbility);
    })

    it('SpeedDialAbilityTest_toVoicemailPage', 0, () => {
      let parameters: Record<string, string> = {
        'pageFlag': 'voicemailPage'
      };
      let want: Want = {
        'parameters': parameters,
        'uri': ''
      };
      speedDialAbility.toVoicemailPage(want);
      expect(AppStorage.get('toVoicemailFromSetting')).assertTrue();
      let parameters2: Record<string, string> = {
        'pageFlag': 'test'
      };
      let want1: Want = {
        'parameters': parameters2,
        'uri': ''
      };
      speedDialAbility.toVoicemailPage(want1);
      expect(AppStorage.get('toVoicemailFromSetting')).assertEqual(false);
    })

    it('SpeedDialAbilityTest_toVoicemailPage_parameters_undefined', 0, () => {
      AppStorage.setOrCreate('isGoSpeedHome',false);

      let want: Want = {
        'parameters': undefined,
        'uri': ''
      };
      speedDialAbility.toVoicemailPage(want);

      expect(AppStorage.get('toVoicemailFromSetting')).assertFalse();
      expect(AppStorage.get('isGoSpeedHome')).assertTrue();
    })
  })
}