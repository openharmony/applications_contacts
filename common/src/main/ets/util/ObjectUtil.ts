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
import { DataShareResultSet, relationalStore } from '@kit.ArkData';
import { HiLog } from './HiLog';

export class ObjectUtil {
  static isEmpty(object: any): boolean {
    return object === undefined ||
      (Object.prototype.isPrototypeOf.call(Object.prototype, object) && Object.keys(object).length === 0);
  }

  static isUndefined(object: any): boolean {
    return object === undefined;
  }

  static assign(target: any, ...source: any): any {
    return Object.assign(target, ...source);
  }

  /**
   * Closes the given resultSet if it is not already closed.
   *
   * @param {DataShareResultSet | relationalStore.ResultSet | undefined} resultSet - The resultSet to close.
   * @returns {void} This method does not return a value.
   */
  static closeResultSet(resultSet: DataShareResultSet | relationalStore.ResultSet | undefined): void {
    try {
      if (resultSet && !resultSet.isClosed) {
        resultSet.close();
      }
    } catch (error) {
      HiLog.e('Failed to close resultSet: ', error ? error?.message : '');
    }
  }
}