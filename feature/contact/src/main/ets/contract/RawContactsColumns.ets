/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import BaseColumns from './BaseColumns';

/**
 * Field constants in the contact rawcontact table
 */
export default class RawContactsColumns extends BaseColumns {
  public static readonly CONTACT_ID: string = 'contact_id';
  public static readonly PHOTO_ID: string = 'photo_id';
  public static readonly PHOTO_FILE_ID: string = 'photo_file_id';
  public static readonly IS_TRANSFER_VOICEMAIL: string = 'is_transfer_voicemail';
  public static readonly PERSONAL_RINGTONE: string = 'personal_ringtone';
  public static readonly IS_DELETED: string = 'is_deleted';
  public static readonly PERSONAL_NOTIFICATION_RINGTONE: string = 'personal_notification_ringtone';
  public static readonly PHOTO_FIRST_NAME: string = 'photo_first_name';
  public static readonly ACCOUNT_ID: string = 'account_id';
  public static readonly VERSION: string = 'version';
  public static readonly DISPLAY_NAME: string = 'display_name';
  public static readonly SORT: string = 'sort';
  public static readonly SORT_KEY: string = 'sort_key';
  public static readonly CONTACTED_COUNT: string = 'contacted_count';
  public static readonly LASTEST_CONTACTED_TIME: string = 'lastest_contacted_time';
  public static readonly FAVORITE: string = 'favorite';
  public static readonly FAVORITE_ORDER: string = 'favorite_order';
  public static readonly PHONETIC_NAME: string = 'phonetic_name';
  public static readonly PHONETIC_NAME_TYPE: string = 'phonetic_name_type';
  public static readonly COMPANY: string = 'company';
  public static readonly LOCATION: string = 'location';
  public static readonly RAW_COMPANY: string = 'raw_company';
  public static readonly POSITION: string = 'position';
  public static readonly READ_ONLY: string = 'read_only';
  public static readonly SORT_FIRST_LETTER: string = 'sort_first_letter';
  public static readonly MERGE_MODE: string = 'merge_mode';
  public static readonly IS_NEED_MERGE: string = 'is_need_merge';
  public static readonly MERGE_STATUS: string = 'merge_status';
  public static readonly IS_MERGE_TARGET: string = 'is_merge_target';
  public static readonly VIBRATION_SETTING: string = 'vibration_setting';
  public static readonly BLOB_DATA: string = 'blob_data';
  public static readonly SYNC_ID: string = 'sync_id';
  public static readonly SYNC_1: string = 'syn_1';
  public static readonly SYNC_2: string = 'syn_2';
  public static readonly SYNC_3: string = 'syn_3';
  public static readonly HAS_GROUP: string = 'has_group';
  public static readonly FORM_ID: string = 'form_id';
  // 对应畅连头像
  public static readonly EXTRA3: string = 'extra3';
  public static readonly UUID: string = 'uuid';
  public static readonly CALENDAR_EVENT_ID: string = 'calendar_event_id';
  public static readonly UNIQUE_KEY: string = 'unique_key';

  // 标记“我的名片”
  public static readonly MARK_MY_CARD: string = 'primary_contact';

  // 免打扰
  public static readonly FOCUS_MODE_LIST: string = 'focus_mode_list';

}