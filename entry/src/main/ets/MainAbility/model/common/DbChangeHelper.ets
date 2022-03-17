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

import HiLog from '../../util/HiLog';

const TAG = 'DbChangeHelper  '

/**
 * 数据库改变监听辅助类
 */
export default class DbChangeHelper {
  private static sIinstance: DbChangeHelper;

  public static getInstance(): DbChangeHelper {
    if (!DbChangeHelper.sIinstance) {
      DbChangeHelper.sIinstance = new DbChangeHelper();
    }
    return DbChangeHelper.sIinstance;
  }

  /**
   * notifychange 发出通知
   *
   * @param dataAbilityHelper dataAbilityHelper
   * @param uri 需要监听的表URI
   */
  notifyChange(dataAbilityHelper, uri: string) {
    dataAbilityHelper.notifyChange(uri, (err, data) => {
      if (err) {
        HiLog.e(TAG, "notifyChange failed because %s", JSON.stringify(err));
        return;
      }
      HiLog.i(TAG, "notifyChange success data : %s", JSON.stringify(data))
    });
  }

  /**
   * registerDbChangeLister 注册数据库变化监听
   *
   * @param dataAbilityHelper
   * @param uri 监听的数据库URI
   * @param callback 回调提供给调用者
   */
  registerDbChangeLister(dataAbilityHelper, uri: string, callback) {
    HiLog.i(TAG, 'registerDbChangeLister uri : %s', uri);
    dataAbilityHelper.on("dataChange", uri, (data) => {
      HiLog.i(TAG, 'on success data : %s', JSON.stringify(data))
      callback(data)
    });
  }

  /**
   * unRegisterDbChangeLister 反注册数据库变化监听
   *
   * @param dataAbilityHelper
   * @param uri 监听的数据库URI
   * @param callback 回调提供给调用者
   */
  unRegisterDbChangeLister(dataAbilityHelper, uri: string, callback) {
    dataAbilityHelper.info(TAG + 'unRegisterDbChangeLister uri : ' + uri);
    dataAbilityHelper.off("dataChange", uri, (data) => {
      HiLog.i(TAG, 'on success data : %s', JSON.stringify(data))
      callback(data)
    });
  }
}