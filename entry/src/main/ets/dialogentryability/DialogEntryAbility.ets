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
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import SimManager from '../feature/sim/SimManager';
import WorkFactory, { WorkerType } from '../workers/WorkFactory';
import PageManager from './PageManager';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import common from '@ohos.app.ability.common';

const TAG = 'DiologEntryAbility ';
const COLOR = '#0000ff33';

export default class DiologEntryAbility extends UIAbility {
  public storage: LocalStorage;
  public simManager: SimManager;
  public mDataWorker: WorkerWrapper = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
  public pageManager: PageManager;
  public test_DT: boolean = true;

  constructor() {
    super();
    this.storage = new LocalStorage();
    this.simManager = new SimManager();
    this.pageManager = new PageManager(this.context);
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.i(TAG, `Application onCreate start: ${want?.abilityName}`);
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<common.UIAbilityContext>(ContactsGlobalThisHelper.CardDialogContextName, this.context);

    ContactsGlobalThisHelper.GetGlobalThis()
      .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, this.mDataWorker);
    this.mDataWorker?.sendRequest('init', {
      context: this.context
    });
    this.pageManager = new PageManager(this.context);
    this.pageManager.onCreate(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.i(TAG, 'Application onNewWant');
    this.pageManager.onNewWant(want);
  }

  onDestroy() {
    HiLog.i(TAG, 'Ability onDestroy');
    this.pageManager.onDestroy();
    this.mDataWorker?.close();
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    HiLog.i(TAG, 'Ability onWindowStageCreate');
    windowStage.loadContent(this.pageManager ? this.pageManager.mainUrl : 'pages/index', this.storage, (err, data) => {
      if (err.code) {
        HiLog.e(TAG, `Failed to load the content. Cause: err.code: ${err?.code}, err.message: ${err?.message}`);
        return;
      }
      try {
        window.getLastWindow(this.context).then((windowClass: window.Window) => {
          windowClass?.setWindowBackgroundColor(COLOR);
          windowClass?.setBackdropBlur(0);
          windowClass?.setBackdropBlurStyle(window.BlurStyle.OFF);
        })
      } catch (exception) {
        HiLog.e(TAG,
          `Window.getLastWindow, exception.code: ${exception?.code}, exception.message: ${exception?.message}`);
      }
      HiLog.i(TAG, 'Succeeded in loading the content. Data: ');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    HiLog.i(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    HiLog.i(TAG, 'Ability onForeground');
    this.simManager.init();
  }

  onBackground() {
    // Ability has back to background
    HiLog.i(TAG, 'Ability onBackground');
    this.simManager.recycle();
  }
}
