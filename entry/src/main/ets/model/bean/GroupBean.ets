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
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import RowGroup from '../../../../../../feature/contact/src/main/ets/contract/RowGroup';
import { contact } from '@kit.ContactsKit';

export class GroupBean {
  public id: number;
  public accountId: string;
  public groupName: string;
  public groupNotes: string;
  public isDeleted: string;
  public groupRingtone: string;
  public ringtoneModifyTime: number;
  public lastestModifyTime: number;
  public groupId: string = '';
  public groupType: string = '';
  public pickerData: contact.Group = {
    title: ''
  }

  constructor(id: number, accountId: string, groupName: string, groupNotes: string, isDeleted: string,
              groupRingtone: string, ringtoneModifyTime: number, lastestModifyTime: number,
              groupId: string = '', groupType: string = '',
  ) {

    this.id = id
    this.accountId = accountId;
    this.groupName = groupName;
    this.groupNotes = groupNotes;
    this.isDeleted = isDeleted;
    this.groupRingtone = groupRingtone;
    this.ringtoneModifyTime = ringtoneModifyTime;
    this.lastestModifyTime = lastestModifyTime;
    this.groupId = groupId
    this.groupType = groupType
  }

  setAll(resultSet: DataShareResultSet) {
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

  setPickerData(title: string, groupId?: number) {
    this.pickerData.title = title;
    this.pickerData.groupId = groupId;
  }
}

export class GroupInfo {
  public group: GroupBean;
  public memberCount: number;
  public checked: boolean;

  constructor(group?: GroupBean, memberCount?: number, checked?: boolean) {
    if (group) {
      this.group = group;
    } else {
      this.group = new GroupBean(-1, '', '', '', '', '', 0, 0, '')
    }
    if (memberCount) {
      this.memberCount = memberCount;
    } else {
      this.memberCount = 0;
    }
    if (checked) {
      this.checked = checked;
    } else {
      this.checked = false;
    }
  }
}

export class IntelligenceGroupInfo {
  public groupName: string;
  public categoryType: string;
  public memberCount: number;
  public isTranslate: boolean;
  public checked?: boolean;

  constructor(groupName: string, categoryType: string, memberCount: number, isTranslate: boolean, checked?: boolean) {
    this.groupName = groupName ?? '';
    this.isTranslate = isTranslate;
    this.categoryType = categoryType ?? '0';
    if (memberCount) {
      this.memberCount = memberCount;
    } else {
      this.memberCount = 0;
    }
    if (checked) {
      this.checked = checked;
    } else {
      this.checked = false;
    }
  }
}
