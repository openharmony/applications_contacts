/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import AbilityStage from '@ohos.app.ability.AbilityStage';
import notificationManager from '@ohos.notificationManager';
import notification from '@ohos.notification';
import type { Configuration } from '@ohos.app.ability.Configuration';

const TAG = 'MyAbilityStage ';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    HiLog.i(TAG, 'AbilityStage onCreate');
    notificationManager.setNotificationEnable({
      bundle: 'com.ohos.contacts'
    }, true, (err, data) => {
      if (err) {
        HiLog.e(TAG, `enableNotification err.code: ${err?.code}, err.message: ${err?.message}`);
      }
    });
    notificationManager.addSlot({
      type: notification.SlotType.SOCIAL_COMMUNICATION,
      level: notificationManager.SlotLevel.LEVEL_HIGH,
      desc: 'missedCall',
      lockscreenVisibility: 2
    }, (err) => {
      if (err) {
        HiLog.e(TAG, `addSlot err.code: ${err?.code}, err.message: ${err?.message}`);
      }
    });
  }

  // 环境变化通知接口，发生全局配置变更时回调。
  onConfigurationUpdate(newConfig: Configuration): void {
    // 0: dark mode, 1: light mode
    HiLog.i(TAG, `onConfigurationUpdate dark mode is: ${this.context?.config?.colorMode}`);
    AppStorage.setOrCreate('currentColorMode', this.context?.config?.colorMode);
  }
}