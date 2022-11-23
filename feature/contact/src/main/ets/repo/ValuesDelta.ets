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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';

const TAG = "ValuesDelta";

/**
 * Contact details editing model
 */
export default class ValuesDelta {
  private readonly _idColumn: string = BaseColumns.ID;
  before: Map<string, any>;
  after: Map<string, any>;
  constructor() {
  }

  static fromValues(values: Map<string, any>) {
    let valuesDelta = new ValuesDelta();
    valuesDelta.before = values;
    valuesDelta.after = new Map();
    return valuesDelta;
  }

  getValue(key: string) {
    let result;
    if (this.after != undefined && this.after.has(key)) {
      result = this.after.get(key);
    } else if (this.before != undefined && this.before.has(key)) {
      result = this.before.get(key);
    }
    return result
  }

  putValue(key: string, value: any) {
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
    for (let key of this.after.keys()) {
      let newValue = this.after.get(key);
      let oldValue = this.before.get(key);
      let mimetypeId = this.before.get(DataColumns.TYPE_ID);
      if (this.isObjectsEqual(oldValue, newValue, mimetypeId, key)) {
        return true;
      }
    }
    return false;
  }

  private isObjectsEqual(oldValue: any, newValue: any, mimetype: number, key: string) {
    return oldValue == newValue;
  }

  buildDiff(targetUri: string) {
    if (targetUri == undefined) {
      return undefined;
    }

    let opt;
    if (this.isInsert()) {
      this.after.delete(this._idColumn);
      opt = DAOperation.newInsert(targetUri);
      opt.valuesBucket = this.mapToObj(this.after);
    } else if (this.isDelete()) {
      opt = DAOperation.newDelete(targetUri);
      opt.predicates = this._idColumn + "=" + this.getValue(this._idColumn);
    } else if (this.isUpdate) {
      opt = DAOperation.newUpdate(targetUri);
      opt.predicates = this._idColumn + "=" + this.getValue(this._idColumn);
      opt.valuesBucket = this.mapToObj(this.after);
    } else {
      HiLog.i(TAG, 'buildDiff do nothing.');
    }
    return opt;
  }

  private mapToObj(map: Map<string, any>) {
    let obj = {};
    for (let [key, value] of map) {
      obj[key] = value;
    }
    return obj;
  }


  private beforeExists() {
    return this.before != undefined && this.before.has(this._idColumn);
  }
}