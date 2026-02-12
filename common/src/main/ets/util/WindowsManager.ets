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

import { HiLog } from './HiLog';
import window from '@ohos.window';
import { ContactsGlobalThisHelper } from './ContactsGlobalThisHelper';
import { common } from '@kit.AbilityKit';

const TAG: string = 'WindowsManager';

export class ContactWindowsManager {
  private mainWindow?: window.Window = undefined;
  private static instance:ContactWindowsManager;
  private context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
  private constructor() {
  }

  /**
   * Get ContactWindowsManager Single Instance
   */
  public static getInstance(): ContactWindowsManager {
    if (!ContactWindowsManager.instance) {
      ContactWindowsManager.instance = new ContactWindowsManager();
    }
    return ContactWindowsManager.instance
  }

  public static getDTTestInstance(): ContactWindowsManager {
    // 用于DT测试创建实例对象
    return new ContactWindowsManager();
  }

  /**
   * set mainWindow of App
   *
   * @param window
   */
  public initForPhone(window: window.Window, context: common.UIAbilityContext): void {
    if (!window) {
      HiLog.e(TAG, `window is undefined`);
      return;
    }
    this.mainWindow = window;
    this.setImmersive(context);
  }
  /**
   * For the immersive effect, it is necessary to add
   * padding for app pages
   */
  public setImmersive(context: common.UIAbilityContext): void {
    HiLog.d(TAG, 'setNavigationBarColor start');
    HiLog.i(TAG, 'setImmersive dark mode is :' + context?.config?.colorMode);
    this.mainWindow?.setWindowLayoutFullScreen(true);
    let currentColorMode = context.config.colorMode;
    const systemBarProperties: window.SystemBarProperties = {
      statusBarColor: '#00000000',
      isStatusBarLightIcon: false,
      statusBarContentColor: currentColorMode ? '#ff000000' : '#ffffffff',
      navigationBarColor: '#00000000',
      navigationBarContentColor: currentColorMode ? '#ff000000' : '#ffffffff',
    };
    try {
      this.mainWindow?.setWindowSystemBarProperties(systemBarProperties);
    } catch (err) {
      HiLog.e(TAG, `setNavigationBarColor err: ${err}`);
    }
  }
}