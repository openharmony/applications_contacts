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

import data_preferences from '@ohos.data.preferences';
import contextConstant from '@ohos.app.ability.contextConstant';
import { ContactsGlobalThisHelper } from './ContactsGlobalThisHelper';
import { HiLog } from './HiLog';

const TAG: string = 'SharedPreferencesUtils'
const NAME: string = 'CONTACT_PREFERENCE';
type ValueType = number | string | boolean | Array<number> | Array<string> | Array<boolean>;
/**
 * @ohos.data.preferences
 * 用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。
 * 数据存储形式为键值对，键的类型为字符串型，值的存储数据类型包括数字型、字符型、布尔型以及这3种类型的数组类型。
 */
class SharedPreferencesUtils {
  private mPreferences?: data_preferences.Preferences;
  private context?: Context;
  private log: string = 'HiLog';
  private str: string = '';

  constructor() {
    this.getPreferences().then((data) => {
      this.mPreferences = data;
    })
  }

  public getLog(): string {
    return this.log;
  }
  public getStr(): string {
    return this.str;
  }

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    this.context = ctx;
  }

  /**
   * getFromPreferences
   *
   * @return the value get from Preferences
   */
  public async getFromPreferences(key: string, defValue: data_preferences.ValueType) {
    let preferences: data_preferences.Preferences | undefined = await this.getPreferences();
    if (!preferences) {
      HiLog.e(TAG, 'getFromPreferences, preferences is undefined');
      return defValue;
    }
    return await preferences.get(key, defValue);
  }

  /**
   * saveToPreferences
   *
   * @param key save to Preferences
   * @param value save to Preferences
   */
  public async saveToPreferences(key: string, value: ValueType) {
    let preferences: data_preferences.Preferences | undefined = await this.getPreferences();
    if (!preferences) {
      HiLog.e(TAG, 'saveToPreferences, preferences is undefined');
      return;
    }
    await preferences.put(key, value);
    preferences.flush();
  }

  public async removePreferencesFromCache(key: string) {
    let options: data_preferences.Options = { name: NAME };
    // 从缓存中移出指定的Preferences实例
    // 应用首次调用getPreferences接口获取某个Preferences实例后，该实例会被会被缓存起来，后续再次getPreferences时不会再次从持久化文件中读取，直接从缓存中获取Preferences实例。
    // 调用此接口移出缓存中的实例之后，再次getPreferences将会重新读取持久化文件，生成新的Preferences实例。
    // 调用该接口后，不建议再使用旧的Preferences实例进行数据操作，否则会出现数据一致性问题，应将Preferences实例置为null，系统将会统一回收。
    let ctx: Context = this.context ? this.context : ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    await data_preferences.removePreferencesFromCache(ctx, options);
    this.mPreferences = undefined;
  }

  /**
   * 获取 Preferences 实例
   * @returns
   */
  private async getPreferences() {
    try {
      if (this.mPreferences) {
        return this.mPreferences;
      }
      let ctx: Context = this.context ? this.context : ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      ctx.area = contextConstant.AreaMode.EL1;
      // NAME 参数 为 Preferences实例的名称。
      return await data_preferences.getPreferences(ctx, NAME);
    } catch (err) {
      HiLog.e(TAG, `getPreferences failed, error: ${err?.code}-${err?.message}`);
      return undefined;
    }
  }
}

export const sharedPreferencesUtils: SharedPreferencesUtils = new SharedPreferencesUtils();