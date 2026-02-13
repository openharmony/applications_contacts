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

import ValuesDelta from './ValuesDelta';
import { Data } from '../contract/Data';
import RawContact from '../entity/RawContact';
import { ValueType } from '@ohos.data.ValuesBucket';

const TAG = 'RawContactDelta';

/**
 * Contact details editing model
 */
export default class RawContactDelta {
  // Stores fields in the rawContact table.
  public values: ValuesDelta<ValueType>;
  public readonly dataValues: Map<number, ValuesDelta<string | number>[]> = new Map();

  constructor() {
    this.values = new ValuesDelta();
  }

  static fromRawContact(rawContact: RawContact) {
    if (rawContact == undefined) {
      return;
    }
    let rawContactDelta = new RawContactDelta();
    rawContactDelta.values = ValuesDelta.fromValues<ValueType>(rawContact.values);
    for (let dataItem of rawContact.dataItems) {
      rawContactDelta.addDataValue(ValuesDelta.fromValues<string | number>(dataItem.values));
    }
    return rawContactDelta;
  }

  addDataValue(dataValue: ValuesDelta<string | number>) {
    if (dataValue == undefined) {
      return;
    }
    let mimeTypeId: string | number | undefined = dataValue.getValue(Data.TYPE_ID);
    if (mimeTypeId == undefined) {
      return;
    }
    let valuesDeltas: ValuesDelta<string | number>[] | undefined = this.getMimeEntries(Number(mimeTypeId));
    if (valuesDeltas == undefined) {
      valuesDeltas = [dataValue];
      this.dataValues.set(Number(mimeTypeId), valuesDeltas);
    } else {
      valuesDeltas.push(dataValue);
    }
  }

  private getMimeEntries(typeId: number) {
    let mimeEntries = this.dataValues.get(typeId);
    return mimeEntries;
  }

  isContactInsert(): boolean {
    return this.values.isInsert();
  }

  isContactDelete(): boolean {
    return this.values.isDelete();
  }

}