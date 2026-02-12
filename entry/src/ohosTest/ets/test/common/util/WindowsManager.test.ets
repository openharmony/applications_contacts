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
import window from '@ohos.window';
import { ContactWindowsManager } from '../../../../../../../common/src/main/ets/util/WindowsManager';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ConfigurationConstant } from '@kit.AbilityKit';

const TAG: string = 'WindowsManager';

export default function WindowsManagerTest() {
  describe('WindowsManagerTest', () => {

    let windowsManager: ContactWindowsManager;

    beforeEach(() => {
      windowsManager = ContactWindowsManager.getDTTestInstance();
    })

    it('WindowsManagerTest_getInstance', 0, () => {
      expect(typeof windowsManager).assertEqual(typeof ContactWindowsManager.getInstance());
    })

    it("WindowsManagerTest_initForPhone_noIf", 0, async () => {
      let windowObj: window.Window = await window.getLastWindow(DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext);
      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(windowsManager, windowsManager.setImmersive);

      windowsManager.initForPhone(windowObj, context);

      mocker.verify("setImmersive", [context]).once();

      mocker.clear(windowsManager);
    })

    it("WindowsManagerTest_setImmersive", 0, async () => {
      let resolved = false;
      let context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      context.config.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

      let window: window.Window = {
        setWindowSystemBarProperties: (systemBarProperties: window.SystemBarProperties): Promise<void> => new Promise<void>(resolve => {
          resolved = true;
          resolve();
        }),
        setWindowLayoutFullScreen: (isLayoutFullScreen: boolean): Promise<void> => new Promise<void>(resolve => resolve())
      } as window.Window;

      windowsManager.initForPhone(window, context);

      expect(resolved).assertTrue();
    })

    it("WindowsManagerTest_setImmersive_catch", 0, async () => {
      let context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      context.config.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      let window: window.Window = {
        setWindowSystemBarProperties: (systemBarProperties: window.SystemBarProperties): Promise<void> =>
        new Promise<void>((resolve: () => void, reject: (reason:Error) => void) => {
          reject(new Error('error'));
        }),

        setWindowLayoutFullScreen: (isLayoutFullScreen: boolean): Promise<void> =>
        new Promise<void>(resolve => resolve())
      } as window.Window;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      windowsManager.initForPhone(window, context);
      mocker.verify('e', [TAG, `window is undefined`]).never();
      mocker.clear(HiLog);
    })
  })
}