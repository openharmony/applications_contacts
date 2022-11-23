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

import BaseColumns from './BaseColumns';

/**
 * Field constants in the contact rawcontact table
 */
export default class RawContactsColumns extends BaseColumns {
  static readonly CONTACT_ID: string = "contact_id";
  static readonly PHOTO_ID: string = "photo_id";
  static readonly PHOTO_FILE_ID: string = "photo_file_id";
  static readonly IS_TRANSFER_VOICEMAIL: string = "is_transfer_voicemail";
  static readonly PERSONAL_RINGTONE: string = "personal_ringtone";
  static readonly IS_DELETED: string = "is_deleted";
  static readonly PERSONAL_NOTIFICATION_RINGTONE: string = "personal_notification_ringtone";
  static readonly PHOTO_FIRST_NAME: string = "photo_first_name";
  static readonly ACCOUNT_ID: string = "account_id";
  static readonly VERSION: string = "version";
  static readonly DISPLAY_NAME: string = "display_name";
  static readonly SORT: string = "sort";
  static readonly CONTACTED_COUNT: string = "contacted_count";
  static readonly LASTEST_CONTACTED_TIME: string = "lastest_contacted_time";
  static readonly FAVORITE: string = "favorite";
  static readonly FAVORITE_ORDER: string = "favorite_order";
  static readonly PHONETIC_NAME: string = "phonetic_name";
  static readonly PHONETIC_NAME_TYPE: string = "phonetic_name_type";
  static readonly COMPANY: string = "company";
  static readonly POSITION: string = "position";
  static readonly READ_ONLY: string = "read_only";
  static readonly SORT_FIRST_LETTER: string = "sort_first_letter";
  static readonly MERGE_MODE: string = "merge_mode";
  static readonly IS_NEED_MERGE: string = "is_need_merge";
  static readonly MERGE_STATUS: string = "merge_status";
  static readonly IS_MERGE_TARGET: string = "is_merge_target";
  static readonly VIBRATION_SETTING: string = "vibration_setting";
  static readonly SYNC_ID: string = "sync_id";
  static readonly SYNC_1: string = "syn_1";
  static readonly SYNC_2: string = "syn_2";
  static readonly SYNC_3: string = "syn_3";
}