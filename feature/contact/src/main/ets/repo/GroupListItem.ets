/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import RowGroup from '../contract/RowGroup';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

export default class GroupListItem {
  public static readonly COLUMNS: string[] = [RowGroup.ID, RowGroup.ACCOUNT_ID, RowGroup.GROUP_NAME,
  RowGroup.GROUP_NOTES, RowGroup.IS_DELETED, RowGroup.GROUP_RINGTONE, RowGroup.RINGTONE_MODIFY_TIME,
  RowGroup.LASETEST_MODIFY_TIME];
  public readonly id: number;
  public readonly accountId: string;
  public readonly groupName: string;
  public readonly groupNotes: string;
  public readonly isDeleted: string;
  public readonly groupRingtone: string;
  public readonly ringtoneModifyTime: number;
  public readonly lastestModifyTime: number;
  public readonly groupId: string = '';
  public readonly groupType: string = '';
  constructor(resultSet: DataShareResultSet) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(RowGroup.ID));
    this.accountId = resultSet.getString(resultSet.getColumnIndex(RowGroup.ACCOUNT_ID));
    this.groupName = resultSet.getString(resultSet.getColumnIndex(RowGroup.GROUP_NAME));
    this.groupNotes = resultSet.getString(resultSet.getColumnIndex(RowGroup.GROUP_NOTES));
    this.isDeleted = resultSet.getString(resultSet.getColumnIndex(RowGroup.IS_DELETED));
    this.groupRingtone = resultSet.getString(resultSet.getColumnIndex(RowGroup.GROUP_RINGTONE));
    this.ringtoneModifyTime = resultSet.getLong(resultSet.getColumnIndex(RowGroup.RINGTONE_MODIFY_TIME));
    this.lastestModifyTime = resultSet.getLong(resultSet.getColumnIndex(RowGroup.LASETEST_MODIFY_TIME));
    this.groupId = '';
    this.groupType = '';
  }
}