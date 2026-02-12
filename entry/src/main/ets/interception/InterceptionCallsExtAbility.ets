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
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import LooseObject from '../model/type/LooseObject';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import WorkFactory, { WorkerType } from '../workers/WorkFactory';
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { uiExtensionHost, window } from '@kit.ArkUI';
import SimManager from '../feature/sim/SimManager';
import { FontScaleState } from '../util/fontScaleState'
import { Configuration } from '@ohos.app.ability.Configuration'

const TAG = 'InterceptionCallsExtAbility'

export default class InterceptionCallsExtAbility extends UIExtensionAbility {
  public mDataWorker: WorkerWrapper = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
  public simManager: SimManager = new SimManager();
  public count: number = 0;

  onCreate() {
    HiLog.i(TAG, `onCreate`)
  }

  onForeground() {
    HiLog.i(TAG, `onForeground`);
    this.simManager.init();
  }

  onBackground() {
    HiLog.i(TAG, `onBackground`);
    this.simManager.recycle();
  }

  onDestroy() {
    HiLog.i(TAG, `onDestroy`)
  }

  fetchSystemFontSizeScale() {
    let fontSizeScale = this.context.config.fontSizeScale;
    FontScaleState.updateAppFontGearSize(fontSizeScale)
  }

  onConfigurationUpdate(newConfig: Configuration) {
    FontScaleState.updateAppFontGearSize(newConfig.fontSizeScale)
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    HiLog.i(TAG, `onSessionCreate`)
    this.fetchSystemFontSizeScale()
    ContactsGlobalThisHelper.GetGlobalThis()
      .set(ContactsGlobalThisHelper.UIContextName, this.context)
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, this.mDataWorker)
    this.mDataWorker.sendRequest('init', {
      context: this.context
    });
    let storageParamObj: LooseObject = {
      'uiExtensionSession': session
    };
    let storage: LocalStorage = new LocalStorage(storageParamObj);
    HiLog.i(TAG, `load interception calls`)
    // 加载拦截通话记录页面
    session.loadContent('pages/dialer/callRecord/InterceptionCallsEntry', storage);
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `onSessionDestroy`)
  }
}