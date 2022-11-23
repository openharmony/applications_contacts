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

import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

const TAG = "CallLogSetting";

export enum MergeRule {
  TIME = 1,
  CONTACT = 2
}

export default class CallLogSetting {
  private static readonly CALL_LOG_SETTING_PREFERENCE_NAME: string = 'call_log_setting';
  private static readonly KEY_MERGE_RULE: string = 'merge_rule';
  private static instance: CallLogSetting;

  private constructor() {
  }

  public static getInstance(): CallLogSetting {
    if (!CallLogSetting.instance) {
      CallLogSetting.instance = new CallLogSetting();
    }
    return CallLogSetting.instance;
  }

  setMergeRule(mergeRule: MergeRule) {
    HiLog.i(TAG, 'MergeRule: ' + JSON.stringify(mergeRule));
    AppStorage.SetOrCreate(CallLogSetting.KEY_MERGE_RULE, mergeRule);
  }

  getMergeRule(): MergeRule {
    if (!AppStorage.Has(CallLogSetting.KEY_MERGE_RULE)) {
      return MergeRule.TIME;
    }
    let rst = AppStorage.Get(CallLogSetting.KEY_MERGE_RULE);
    if (rst == MergeRule.CONTACT) {
      return MergeRule.CONTACT;
    }
    return MergeRule.TIME;
  }
}