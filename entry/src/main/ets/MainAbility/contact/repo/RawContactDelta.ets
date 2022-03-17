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

import ValuesDelta from './ValuesDelta.ets';
import DAOperation from './DAOperation.ets';
import RawContacts from '../contract/RawContacts.ets';
import Data from '../contract/Data.ets';
import RawContact from '../entity/RawContact.ets';
import HiLog from '../../util/HiLog';

const TAG = "RawContactDelta";

/**
 * 联系人详情编辑模型
 */
export default class RawContactDelta {
  // 用于存放rawContact表本身的字段
  values: ValuesDelta;
  readonly dataValues: Map<number, ValuesDelta[]> = new Map();
  constructor() {
    this.values = new ValuesDelta();
  }

  static fromRawContact(rawContact: RawContact) {
    if (rawContact == undefined) {
      return;
    }
    let rawContactDelta = new RawContactDelta();
    rawContactDelta.values = ValuesDelta.fromValues(rawContact.values);
    for (let dataItem of rawContact.dataItems) {
      rawContactDelta.addDataValue(ValuesDelta.fromValues(dataItem.values));
    }
    return rawContactDelta;
  }

  addDataValue(dataValue: ValuesDelta) {
    if (dataValue == undefined) {
      return;
    }
    let mimeTypeId = dataValue.getValue(Data.TYPE_ID);
    if (mimeTypeId == undefined ) {
      return;
    }
    let valuesDeltas = this.getMimeEntries(mimeTypeId);
    if (valuesDeltas == undefined) {
      valuesDeltas = [dataValue];
      this.dataValues.set(mimeTypeId, valuesDeltas);
    } else {
      valuesDeltas.push(dataValue);
    }
  }

  private getMimeEntries(typeId: number) {
    let mimeEntries = this.dataValues.get(typeId);
    return mimeEntries;
  }

  isContactInsert () {
    return this.values.isInsert();
  }

  isContactDelete () {
    return this.values.isDelete();
  }

  buildDiff(diff: DAOperation[]) {
    let isContactInsert = this.isContactInsert();
    let isContactDelete = this.isContactDelete();
//    let isContactUpdate = !isContactInsert && !isContactDelete;
    let beforeId = this.values.getValue(RawContacts.ID);
    let firstIndex = diff.length;
    let opt = this.values.buildDiff(RawContacts.CONTENT_URI);
    diff.push(opt);
    if (isContactDelete) {
      return;
    }
    for (let mimeEntries of this.dataValues.values()) {
      for (let data of mimeEntries) {
        opt = data.buildDiff(Data.CONTENT_URI);
        if (data.isInsert()) {
          if (isContactInsert) {
            opt.withValueBackReferences(Data.RAW_CONTACT_ID, firstIndex);
          } else {
            opt.withValue(Data.RAW_CONTACT_ID, beforeId);
          }
        }
        diff.push(opt);
      }
    }
  }
}