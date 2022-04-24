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

import dataStorage from '@ohos.data.storage';
import featureAbility from '@ohos.ability.featureAbility';
import ObjectUtil from '../Util/ObjectUtil';
import HiLog from '../util/HiLog';

const TAG = "CallLogSetting";

export enum MergeRule {
  TIME = 1,
  CONTACT = 2
}

export default class CallLogSetting {
  private static readonly CALL_LOG_SETTING_PREFERENCE_NAME: string = 'call_log_setting';
  private static readonly KEY_MERGE_RULE: string = 'merge_rule';
  private static instance: CallLogSetting;
  private _storage;
  private constructor() {
    this.setStorage();
  }

  public static getInstance(): CallLogSetting {
    if (!CallLogSetting.instance) {
      CallLogSetting.instance = new CallLogSetting();
    }
    return CallLogSetting.instance;
  }

  private getStorage() {
    if (ObjectUtil.isEmpty(this._storage)) {
      HiLog.w(TAG, "_storage is null!");
      this.setStorage();
    }
    return this._storage;
  }

  private async setStorage() {
    let context = featureAbility.getContext();
    let path = await context.getFilesDir();
    this._storage = dataStorage.getStorageSync(path + '/' + CallLogSetting.CALL_LOG_SETTING_PREFERENCE_NAME);
  }

  setMergeRule(mergeRule: MergeRule) {
    let storage = this.getStorage();
    storage.putSync(CallLogSetting.KEY_MERGE_RULE, mergeRule);
    storage.flushSync();
  }

  getMergeRule(): MergeRule {
    let storage = this.getStorage();
    if (ObjectUtil.isEmpty(storage)) {
      HiLog.w(TAG, "getMergeRule: _storage is null!");
      return MergeRule.TIME;
    }
    let rst = storage.getSync(CallLogSetting.KEY_MERGE_RULE, MergeRule.TIME);
    if (rst == MergeRule.CONTACT) {
      return MergeRule.CONTACT;
    }
    return MergeRule.TIME;
  }
}