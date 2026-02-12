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
import { bundleManager } from '@kit.AbilityKit';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import prompt from '@ohos.promptAction';

const TAG = 'CheckRestoreUtils'
const BUNDLE_NAME_SOUND_RECORDER = 'com.ohos.soundrecorder';

export function isCallRecorderEnable(): boolean {
  try {
    let enabled = bundleManager.isApplicationEnabledSync(BUNDLE_NAME_SOUND_RECORDER);
    HiLog.i(TAG, `isCallRecorderEnable: ${enabled}`);
    return enabled;
  } catch (err) {
    HiLog.e(TAG, `isCallRecorderEnable error, ${err?.code}, ${err?.message}`);
    return false;
  }
}

export function toastForCallRecorderDisable() {
  prompt.showToast({
    message: $r('app.string.restore_recorder'),
    duration: 3000, // 提示框显示 3 秒
    bottom: 80 // 距离底部的距离
  });
}
