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
import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';

export const NOTEPAD_NAME = 'com.ohos.notepad';

const TAG = 'NotePadUtil';


export async function isNotePadAppEnabled(): Promise<boolean> {
    try {
      let enabled = bundleManager.isApplicationEnabledSync(NOTEPAD_NAME);
      HiLog.i(TAG, 'isNotePadAppEnabled : ' + enabled);
      return enabled;
    } catch (e) {
      HiLog.i(TAG, 'isNotePadAppEnabled error : ' + e);
      return false;
    }
}