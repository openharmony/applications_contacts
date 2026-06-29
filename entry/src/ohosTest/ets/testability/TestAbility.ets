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
import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import hilog from '@ohos.hilog';
import { Hypium } from '@ohos/hypium';
import testsuite from '../test/List.test';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { BusinessError } from '@ohos.base';

export class DTGlobalContext {
  private constructor() { }
  private static instance: DTGlobalContext;
  private _objects = new Map<string, Object>();

  public static getContext(): DTGlobalContext {
    if (!DTGlobalContext.instance) {
      DTGlobalContext.instance = new DTGlobalContext();
    }
    return DTGlobalContext.instance;
  }

  getObject(value: string): Object | undefined {
    return this._objects.get(value);
  }

  setObject(key: string, objectClass: Object | null): void {
    this._objects.set(key, objectClass as Object);
  }
}

export default class TestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onCreate.');
    let abilityDelegator: AbilityDelegatorRegistry.AbilityDelegator;
    abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
    let abilityDelegatorArguments: AbilityDelegatorRegistry.AbilityDelegatorArgs;
    abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments();
    hilog.info(0x0000, 'testTag', '%{public}s', 'start run testcase!!!');
    Hypium.hypiumTest(abilityDelegator, abilityDelegatorArguments, testsuite);
    DTGlobalContext.getContext().setObject('contactContext', this.context);
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onWindowStageCreate');
    windowStage.loadContent('testability/pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', `Failed to load the content. Cause: ${err?.message}`);
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s',
        JSON.stringify(data) ?? '');
    });
    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((err: BusinessError, data) => {
      let errCode: number = err.code;
      if (errCode) {
        hilog.error(0x0000, 'testTag', `Failed to obtain the main window. Cause: ${err?.message}`);
        return;
      }
      windowClass = data;

      if (windowClass) {
        DTGlobalContext.getContext().setObject('UIContext', windowClass.getUIContext());
      }
    })
  }

  onWindowStageDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onForeground');
  }

  onBackground() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'TestAbility onBackground');
  }
}