/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import DeletedRawContactsColumns from '../contract/DeletedRawContactsColumns';

export default class RecentDeleteListItem {
  public static readonly DELETE_COLUMN: string[] = [DeletedRawContactsColumns.RAW_CONTACT_ID,
  DeletedRawContactsColumns.DISPLAY_NAME, DeletedRawContactsColumns.DELETE_SOURCE,
  DeletedRawContactsColumns.DELETE_TIME];
  // RAW_CONTACT_ID
  public readonly id: number;
  public readonly displayName: string;
  public readonly deleteTime: number = 0;
  public readonly deleteSource: string = '';
  public readonly isChecked: boolean = false;
  constructor(resultSet: DataShareResultSet) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(DeletedRawContactsColumns.RAW_CONTACT_ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex( DeletedRawContactsColumns.DISPLAY_NAME));
    this.deleteSource = resultSet.getString(resultSet.getColumnIndex(DeletedRawContactsColumns.DELETE_SOURCE));
    this.deleteTime = resultSet.getLong(resultSet.getColumnIndex(DeletedRawContactsColumns.DELETE_TIME));
    this.isChecked = false;
  }
}