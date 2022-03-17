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
import Constants from '../model/common/Constants';
import HiLog from './HiLog';
import AppStorageUtil from './AppStorageUtil';

const TAG = 'PreferencesUtil->';

/**
 * 保存全局的数据工具
 */
export default {
  async initDataStorage() {
    let context = featureAbility.getContext();
    let path = await context.getFilesDir();
    return dataStorage.getStorageSync(path + Constants.string.PATH_OF_PREFERENCES);
  },

  getPreferencesInstance() {
    return AppStorageUtil.getPreferences();
  },

  /**
     * 获取值
     *
     * @param {string} key value值
     */
  getValue(key) {
    HiLog.i(TAG, 'getValue start: ');
    let prefIns = this.getPreferencesInstance();
    return prefIns.getSync(key, Constants.string.EMPTY_STR);
  },

  /**
   * 给设置值
   *
   * @param keyOfSwitch  key
   * @param valueOfSwitch  value
   */
  setValueForSwitch(keyOfSwitch, valueOfSwitch) {
    let prefIns = this.getPreferencesInstance();
    prefIns.putSync(keyOfSwitch, valueOfSwitch);
    prefIns.flushSync();
  },

  /**
   * 是否是简洁布局
   */
  getConciseLayout() {
    let prefIns = this.getPreferencesInstance();
    return prefIns.getSync(Constants.string.CONCISE_LAYOUT_SWITCH, Constants.bool.TRUE);
  },

  /**
     * 查询联系人类型
     */
  getAccountRadio() {
    let prefIns = this.getPreferencesInstance();
    return prefIns.getSync(Constants.string.DISPLAY_ACCOUNT_RADIO, Constants.string.EMPTY_STR);
  },

  /**
     * 自定义联系人视图
     */
  getCustomizeView() {
    let prefIns = this.getPreferencesInstance();
    return prefIns.getSync(Constants.string.CUSTOMIZE_VIEW_INPUT, Constants.string.EMPTY_STR);
  },

  /**
     * 联系人数量
     */
  getContactCount() {
    let prefIns = this.getPreferencesInstance();
    return prefIns.getSync(Constants.string.CONTACTS_COUNT, Constants.int.ZERO);
  },

  /**
     * 通话记录合并规则
     */
  getCalllogMergeRule(): string{
    let prefIns = this.getPreferencesInstance();
    HiLog.i(TAG, 'getCalllogMergeRule');
    return prefIns.getSync(Constants.string.CALL_LOG_MERGE_RULE, 'from_time');
  },
}