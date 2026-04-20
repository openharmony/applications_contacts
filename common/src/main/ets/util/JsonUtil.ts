/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { StringUtil } from './StringUtil';
import { HiLog } from './HiLog';

const TAG = 'JsonUtil';

export class JsonUtil {
  /**
   * json字符串转对象
   *
   * @param jsonStr json字符串
   * @param defaultValue 默认值
   * @returns 预期的对象
   */
  public static jsonToObject<T>(jsonStr: string, defaultValue: T): T {
    if (StringUtil.isEmpty(jsonStr)) {
      return defaultValue;
    }
    let obj: T;
    try {
      obj = JSON.parse(jsonStr as string) as T;
    } catch (err) {
      HiLog.e(TAG, `Failed to convert the JSON character string to an object: ${err.code}`);
      obj = defaultValue;
    }
    return obj;
  }
}