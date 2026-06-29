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
import { bundleManager, common, Want } from '@kit.AbilityKit';
import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';

export const HIVOICE_NAME = 'com.ohos.vassistant';

export const CALL_TYPE_CELIA = 1;

export const CALL_TYPE_NONE = -1;

const TAG = 'CallAssistantUtil';

export function startCallAssistantRecord(context: common.UIAbilityContext, beginTime: number) {
  let want: Want = {
    bundleName: HIVOICE_NAME,
    abilityName: 'CallAssistantSettingAbility',
    type: 'contact',
  };
  want.parameters = {
    'beginTime': beginTime,
    'target': 'CallAssistantLogDetail'
  }
  HiLog.i(TAG, 'startCallAssistantRecord: ' + beginTime);
  context.startAbility(want);
}


export async function isVoiceAppEnabled(): Promise<boolean> {
  try {
    let enabled = await bundleManager.isApplicationEnabled(HIVOICE_NAME);
    HiLog.i(TAG, 'isVoiceAppEnabled: ' + enabled);
    return enabled;
  } catch (e) {
    HiLog.i(TAG, 'isVoiceAppEnabled error : ' + e);
    return false;
  }
}