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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common';
import {
  ModeType,
  showToast,
  SystemModeController,
  terminateUIAbilitySelf
} from '../../../../../main/ets/util/SystemModeController';

const TAG = 'SystemModeController';

export default function SystemModeControllerTest() {
  describe('SystemModeControllerTest', () => {
    it('SystemModeControllerTest_getIsEnablePosterAvatar', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnablePosterAvatar();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableVideoCall', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableVideoCall();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableEditAvatar', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableEditAvatar();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableVideoCallOfMeeTime', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableVideoCallOfMeeTime();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableImportOrExportContact', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableImportOrExportContact();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsCurrentModeSupportCalendar', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsCurrentModeSupportCalendar();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableCeliaCall', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableCeliaCall();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableCallRecordEntry', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableCallRecordEntry();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getIsEnableJumpToMusicApp', 0, () => {
      const res: boolean = SystemModeController.getInstance().getIsEnableJumpToMusicApp();
      expect(res).assertTrue();
    })
    it('SystemModeControllerTest_getCurrentMode', 0, () => {
      let mode: ModeType = SystemModeController.getInstance().getCurrentMode();
      switch (mode) {
        case ModeType.PENG_LAI_MODE:
          expect(SystemModeController.getInstance().getDisabledFunctionTip()?.id)
            .assertEqual($r('app.string.not_support_toast').id);
          break;
        default: //Modes without special logic are identified as default modes.
          expect(SystemModeController.getInstance().getDisabledFunctionTip()).assertEqual(undefined);
      }
    })

    it('SystemModeControllerTest_showToast', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let uiContext: UIContext = context.windowStage.getMainWindowSync().getUIContext();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(uiContext.getPromptAction(), uiContext.getPromptAction().showToast);
      showToast(uiContext, $r('app.string.not_support_toast'));
      mocker.verify('showToast', []).never();
      mocker.clear(uiContext.getPromptAction());
    })

    it('SystemModeControllerTest_terminateUIAbilitySelf', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      terminateUIAbilitySelf(context);
      mocker.verify('i', [TAG, 'terminateUIAbilitySelf succeeded']).never();
      mocker.clear(HiLog);
    })
  })
}