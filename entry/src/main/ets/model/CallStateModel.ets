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
import observer from '@ohos.telephony.observer';
import call from '@ohos.telephony.call';
import { DSDS_MODE_V3 } from '../component/mutisim/DsdaConstants';
import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';

export const CALLING_FLAG = 0x01;

const TAG = 'CallStateModel';

const SIM_1_CALLING = CALLING_FLAG << 0;
const SIM_2_CALLING = CALLING_FLAG << 1;

export function registerCallStateListener() {
  try {
  observer.on('callStateChange', { slotId: 0 }, callback => {
    let cachedState: number | undefined = AppStorage.get('combinedCallState');
    if (!cachedState) {
      cachedState = 0;
    }

    if (callback.state === call.CallState.CALL_STATE_RINGING || callback.state === call.CallState.CALL_STATE_OFFHOOK) {
      cachedState = cachedState | SIM_1_CALLING;
    } else {
      cachedState = cachedState & ~SIM_1_CALLING;
    }
    HiLog.i(TAG, 'callStateChange slot 0 - newState = ' + callback.state + ', cachedState = ' + cachedState);
    AppStorage.setOrCreate('combinedCallState', cachedState);
  });

  observer.on('callStateChange', { slotId: 1 }, callback => {
    let cachedState: number | undefined = AppStorage.get('combinedCallState');
    if (!cachedState) {
      cachedState = 0;
    }

    if (callback.state === call.CallState.CALL_STATE_RINGING || callback.state === call.CallState.CALL_STATE_OFFHOOK) {
      cachedState = cachedState | SIM_2_CALLING;
    } else {
      cachedState = cachedState & ~SIM_2_CALLING;
    }
    HiLog.i(TAG, 'callStateChange slot 1 - newState = ' + callback.state + ', cachedState = ' + cachedState);
    AppStorage.setOrCreate('combinedCallState', cachedState);
  });
  } catch (err) {
    HiLog.e(TAG, 'callStateChange ERR : ' + (err as Error).message)
  }
}

export function unregisterCallStateListener() {
  observer.off('callStateChange');
}

export function isRinging(): boolean {
  return call.getCallStateSync() === call.CallState.CALL_STATE_RINGING;
}

export function getDialDirectlyAccountId(dsdsMode: number): number | undefined {
  if (dsdsMode !== DSDS_MODE_V3) {
    return undefined;
  }

  let cachedState: number | undefined = AppStorage.get('combinedCallState');
  if (!cachedState || cachedState === 0) {
    // No calls
    return undefined;
  }

  const both = SIM_1_CALLING | SIM_2_CALLING;
  if ((cachedState & both) === both) {
    // DSDA!
    return undefined;
  }

  if ((cachedState & SIM_1_CALLING) === SIM_1_CALLING) {
    // SIM 1 calling, use SIM 1
    return 0;
  } else if ((cachedState & SIM_2_CALLING) === SIM_2_CALLING) {
    // SIM 2 calling, use SIM2
    return 1;
  } else {
    // Will never reach here
    return undefined;
  }
}
