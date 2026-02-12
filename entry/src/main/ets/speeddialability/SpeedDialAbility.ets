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
import common from '@ohos.app.ability.common';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import {
  ContactsGlobalThisHelper
} from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import SimManager from '../feature/sim/SimManager';
import { BusinessError } from '@ohos.base';
import CantactColumnUtils from '../util/CantactColumnUtils';
import { FontScaleState } from '../util/fontScaleState';

const TAG = 'SpeedDialAbility ';

export default class SpeedDialAbility extends UIAbility {
  public simManager: SimManager = new SimManager();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.i(TAG, 'SpeedDialAbility onCreate start want?.abilityName: ' + want?.abilityName);
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<common.UIAbilityContext>(ContactsGlobalThisHelper.SpeedDialContextName, this.context);
    this.toVoicemailPage(want);
  }

  onDestroy() {
    HiLog.i(TAG, 'SpeedDialAbility onDestroy');
  }

  fetchSystemFontSizeScale() {
    let fontSizeScale = this.context.config.fontSizeScale;
    FontScaleState.updateAppFontGearSize(fontSizeScale)
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    try {
      // Main window is created, set main page for this ability
      this.fetchSystemFontSizeScale();
      window.getLastWindow(this.context, (err, windowObj) => {
        if (err && err.code) {
          HiLog.e(TAG, 'Window.getLastWindow error: ' + err?.message + ', stack: ' + err?.stack);
          return;
        }
        // 窗口大小
        windowObj.on('windowSizeChange', (data) => {
          CantactColumnUtils.getInstance().updateBreakpoint(data.width)
        });

        try {
          // 窗口内容规避区域
          let avoidArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          let navigationArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          this.updateWindowFullScreenPadding(avoidArea.topRect.height, navigationArea.bottomRect.height)
        } catch (exception) {
          console.error(TAG, 'Failed to obtain the area. Cause:' + exception?.message);
        }

        this.setPreferredOrientation(windowObj)
      })
      HiLog.i(TAG, 'SpeedDialAbility onWindowStageCreate');
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
      windowStage.loadContent('pages/speeddial/SpeedDial', (err, data) => {
        if (err.code) {
          HiLog.i(TAG, 'SpeedDialAbility Failed to load the content. Cause: %{public}s', err?.message);
          return;
        }
        try {
          this.context.reportDrawnCompleted((err: BusinessError) => {
            if (err.code) {
              HiLog.e(TAG, `reportDrawnCompleted failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            HiLog.i(TAG, 'reportDrawnCompleted succeed');
          });
        } catch (err) {
          // 捕获同步的参数错误
          let code: number = err?.code;
          let message: string = err?.message;
          HiLog.e(TAG, `reportDrawnCompleted failed, code is ${code}, message is ${message}`);
        }
        HiLog.i(TAG, 'SpeedDialAbility Succeeded in loading the content.');
      });
    } catch (exception) {
      HiLog.e(TAG, 'Window.getLastWindow exception: ' + exception?.message + ', stack: ' + exception?.stack);
    }
  }

  setPreferredOrientation(windowObj: window.Window): void {
    if (!windowObj) {
      HiLog.i(TAG, 'set the window orientation Failed, Cause: Can not get windowObj');
      return;
    }
    let windowOrientation: window.Orientation = window.Orientation.FOLLOW_DESKTOP;
    windowObj.setPreferredOrientation(windowOrientation).then(() => {
      HiLog.i(TAG, 'setting the window orientation Succeeded');
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'set the window orientation Failed, Cause: ' + err?.message + ', stack: ' + err?.stack);
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    HiLog.i(TAG, 'SpeedDialAbility onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    HiLog.i(TAG, 'SpeedDialAbility onForeground');
    this.simManager.init();
  }

  onBackground() {
    // Ability has back to background
    HiLog.i(TAG, 'SpeedDialAbility onBackground');
    this.simManager.recycle();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.i(TAG, 'onNewWant');
    this.toVoicemailPage(want);
  }

  updateWindowFullScreenPadding(top: number, bottom: number): void {
    HiLog.i(TAG, `updateWindowFullScreenPadding start! top: ${top}, bottom: ${bottom} time: ${(new Date()).valueOf()}`);
    let prePadding = AppStorage.get<Padding>('fullScreenPadding');
    let padding: Padding = {
      top: top < 0 ? prePadding?.top ?? 0 : top,
      bottom: bottom < 0 ? prePadding?.bottom ?? 0 : bottom,
      left: $r('sys.float.padding_level0'),
      right: $r('sys.float.padding_level0')
    }
    AppStorage.setOrCreate('fullScreenPaddingSpeedDial', padding);
    HiLog.i(TAG, `updateWindowFullScreenPadding end! top: ${padding.top}, bottom: ${padding.bottom} time: ${(new Date()).valueOf()}`);
  }

  toVoicemailPage(want: Want) {
    HiLog.i(TAG, 'toVoicemailPage');
    let parameters = want.parameters;
    let pageFlag = parameters?.pageFlag;
    if (parameters && pageFlag && pageFlag === 'voicemailPage') {
      HiLog.i(TAG, 'toVoicemailPage toVoicemailFromSetting');
      let param: Record<string, Object> = {
        'slotId': parameters.slotId
      }
      AppStorage.setOrCreate('voicemailParam', param);
      AppStorage.setOrCreate('toVoicemailFromSetting', true);
    } else {
      AppStorage.setOrCreate('toVoicemailFromSetting', false);
      let isGoSpeedHome: boolean = AppStorage.get('isGoSpeedHome') as boolean;
      AppStorage.setOrCreate('isGoSpeedHome', !isGoSpeedHome);
    }
  }
}
