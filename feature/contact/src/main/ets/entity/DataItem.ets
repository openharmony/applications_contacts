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

import { Data } from '../contract/Data';
import DataType from '../contract/DataType';

/**
 * Contact data
 */
export class DataItem {
  readonly values: Map<string, any>;
  constructor(values: Map<string, any>) {
    this.values = values;
  }

  static fromResultSet(resultSet: any): DataItem{
    let contentValues: Map<string, any> = new Map();
    contentValues.set(Data.ID, resultSet.getLong(resultSet.getColumnIndex(Data.ID)));
    contentValues.set(Data.TYPE_ID, resultSet.getLong(resultSet.getColumnIndex(Data.TYPE_ID)));
    contentValues.set(Data.RAW_CONTACT_ID, resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)));
    contentValues.set(Data.READ_ONLY, resultSet.getLong(resultSet.getColumnIndex(Data.READ_ONLY)) > 0 ? true : false);
    contentValues.set(Data.DETAIL_INFO, resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)));
    contentValues.set(Data.FAMILY_NAME, resultSet.getString(resultSet.getColumnIndex(Data.FAMILY_NAME)));
    contentValues.set(Data.MIDDLE_NAME_PHONETIC, resultSet.getString(resultSet.getColumnIndex(Data.MIDDLE_NAME_PHONETIC)));
    contentValues.set(Data.IS_PREFERRED_NUMBER, resultSet.getLong(resultSet.getColumnIndex(Data.IS_PREFERRED_NUMBER)));
    contentValues.set(Data.GIVEN_NAME, resultSet.getString(resultSet.getColumnIndex(Data.GIVEN_NAME)));
    contentValues.set(Data.GIVEN_NAME_PHONETIC, resultSet.getString(resultSet.getColumnIndex(Data.GIVEN_NAME_PHONETIC)));
    contentValues.set(Data.ALIAS_DETAIL_INTO, resultSet.getString(resultSet.getColumnIndex(Data.ALIAS_DETAIL_INTO)));
    contentValues.set(Data.PHONETIC_NAME, resultSet.getString(resultSet.getColumnIndex(Data.PHONETIC_NAME)));
    contentValues.set(Data.POSITION, resultSet.getString(resultSet.getColumnIndex(Data.POSITION)));
    contentValues.set(Data.CITY, resultSet.getString(resultSet.getColumnIndex(Data.CITY)));
    contentValues.set(Data.COUNTRY, resultSet.getString(resultSet.getColumnIndex(Data.COUNTRY)));
    contentValues.set(Data.NEIGHBORHOOD, resultSet.getString(resultSet.getColumnIndex(Data.NEIGHBORHOOD)));
    contentValues.set(Data.POBOX, resultSet.getString(resultSet.getColumnIndex(Data.POBOX)));
    contentValues.set(Data.POSTCODE, resultSet.getString(resultSet.getColumnIndex(Data.POSTCODE)));
    contentValues.set(Data.REGION, resultSet.getString(resultSet.getColumnIndex(Data.REGION)));
    contentValues.set(Data.STREET, resultSet.getString(resultSet.getColumnIndex(Data.STREET)));
    contentValues.set(Data.ALPHA_NAME, resultSet.getString(resultSet.getColumnIndex(Data.ALPHA_NAME)));
    contentValues.set(Data.OTHER_LAN_LAST_NAME, resultSet.getString(resultSet.getColumnIndex(Data.OTHER_LAN_LAST_NAME)));
    contentValues.set(Data.OTHER_LAN_FIRST_NAME, resultSet.getString(resultSet.getColumnIndex(Data.OTHER_LAN_FIRST_NAME)));
    contentValues.set(Data.LAN_STYLE, resultSet.getString(resultSet.getColumnIndex(Data.LAN_STYLE)));
    contentValues.set(Data.CUSTOM_DATA, resultSet.getString(resultSet.getColumnIndex(Data.CUSTOM_DATA)));
    contentValues.set(Data.BLOB_DATA, resultSet.getString(resultSet.getColumnIndex(Data.BLOB_DATA)));
    contentValues.set(Data.EXTEND1, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND1)));
    contentValues.set(Data.EXTEND2, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND2)));
    contentValues.set(Data.EXTEND3, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND3)));
    contentValues.set(Data.EXTEND4, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND4)));
    contentValues.set(Data.EXTEND5, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND5)));
    contentValues.set(Data.EXTEND6, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND6)));
    contentValues.set(Data.EXTEND7, resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7)));
    contentValues.set(Data.SYN_1, resultSet.getString(resultSet.getColumnIndex(Data.SYN_1)));
    contentValues.set(Data.SYN_2, resultSet.getString(resultSet.getColumnIndex(Data.SYN_2)));
    contentValues.set(Data.SYN_3, resultSet.getString(resultSet.getColumnIndex(Data.SYN_3)));
    return new DataItem(contentValues);
  }

  getId() {
    return this.values.get(Data.ID);
  }

  getContentTypeId() {
    return this.values.get(Data.TYPE_ID);
  }

  getData() {
    return this.values.get(DataType.DATA);
  }

  getLabelId() {
    return this.values.get(DataType.LABEL_ID);
  }

  getLabelName() {
    return this.values.get(DataType.LABEL_NAME);
  }
}