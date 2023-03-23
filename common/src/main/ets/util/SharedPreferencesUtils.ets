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

const NAME: string = "CONTACT_PREFERENCE";
type ValueType = number | string | boolean | Array<number> | Array<string> | Array<boolean>;

class SharedPreferencesUtils {
  private mPreferences: data_preferences.Preferences;
  private context: Context;

  constructor() {
    this.getPreferences().then((data) => {
      this.mPreferences = data;
    })
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
  public async getFromPreferences(key: string, defValue) {
    let preferences: data_preferences.Preferences = await this.getPreferences();
    return await preferences.get(key, defValue);
  }

  /**
   * saveToPreferences
   *
   * @param key save to Preferences
   * @param value save to Preferences
   */
  public async saveToPreferences(key: string, value: ValueType) {
    let preferences: data_preferences.Preferences = await this.getPreferences();
    await preferences.put(key, value);
    preferences.flush()
  }

  private async getPreferences() {
    if (this.mPreferences) {
      return this.mPreferences;
    }
    return await data_preferences.getPreferences(globalThis.context ? globalThis.context : this.context, NAME);
  }
}

export const sharedPreferencesUtils: SharedPreferencesUtils = new SharedPreferencesUtils();