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

import BaseColumns from '../contract/BaseColumns';
import DataColumns from '../contract/DataColumns';
import DAOperation from './DAOperation';
import { HiLog } from 'common/src/main/ets/util/HiLog';

const TAG = 'ValuesDelta';

/**
 * Contact details editing model
 */
export default class ValuesDelta<T> {
  private readonly _idColumn: string = BaseColumns.ID;
  before: Map<string, T> = new Map<string, T>();
  after: Map<string, T> = new Map<string, T>();
  constructor() {
  }
  static fromValues<T>(values: Map<string, T>) {
    let valuesDelta = new ValuesDelta<T>();
    valuesDelta.before = values;
    valuesDelta.after = new Map<string, T>();
    return valuesDelta;
  }

  getValue(key: string): T | undefined {
    let result: T | undefined = undefined;
    if (this.after != undefined && this.after.has(key)) {
      result = this.after.get(key);
    } else if (this.before != undefined && this.before.has(key)) {
      result = this.before.get(key);
    }
    return result
  }

  putValue(key: string, value: T) {
    if (this.after == undefined) {
      this.after = new Map();
    }
    this.after.set(key, value);
  }

  isInsert() {
    return!this.beforeExists() && (this.after != undefined);
  }

  isDelete() {
    return this.beforeExists() && (this.after == undefined);
  }

  isUpdate() {
    if (!this.beforeExists() || this.after == undefined || this.after.size == 0) {
      return false;
    }
    for (let kvArr of this.after) {
      const key = kvArr[0];
      const newValue = kvArr[1];
      const oldValue = this.before.get(key);
      if (this.isObjectsEqual(oldValue, newValue)) {
        return true;
      }
    }
    return false;
  }

  private isObjectsEqual(oldValue?: T, newValue?: T) {
    return oldValue == newValue;
  }

  private beforeExists() {
    return this.before != undefined && this.before.has(this._idColumn);
  }
}