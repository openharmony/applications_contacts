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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { settings } from '@kit.BasicServicesKit';

const TAG = 'SplitScreenManager';
const CONTACT_WINDOW_STATUS = 'contact_window_status';

export class SplitScreenManager {

  private constructor() {
  }

  private static instance: SplitScreenManager;

  /**
   * get Instance
   * @returns
   */
  public static getInstance(): SplitScreenManager {
    if (!SplitScreenManager.instance) {
      HiLog.w(TAG, 'init SplitScreenManager instance');
      SplitScreenManager.instance = new SplitScreenManager();
    }
    return SplitScreenManager.instance;
  }

  updateWindowStatusType(context: Context, windowStatus: WindowStatusType) {
    try {
      HiLog.w(TAG, `updateWindowStatusType, windowStatus: ${windowStatus}`);
      settings.setValueSync(context, CONTACT_WINDOW_STATUS, windowStatus.toString(), settings.domainName.USER_SECURITY);
    } catch (err) {
      HiLog.e(TAG, `updateWindowStatusType error: ${err?.code} ${err?.message}`);
    }
  }

}

