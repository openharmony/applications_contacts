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
 * Field constants in the contact table
 */
export default class ContactsColumns extends BaseColumns {
  public static readonly NAME_RAW_CONTACT_ID: string = 'name_raw_contact_id';
  public static readonly PHOTO_ID: string = 'photo_id';
  public static readonly PHOTO_FILE_ID: string = 'photo_file_id';
  public static readonly PERSONAL_RINGTONE: string = 'personal_ringtone';
  public static readonly PERSONAL_RINGTONE_PATH: string = 'ringtone_path';
  public static readonly IS_TRANSFER_VOICEMAIL: string = 'is_transfer_voicemail';
  public static readonly COMPANY: string = 'company';
  public static readonly LOCATION: string = 'location';
  public static readonly COUNT: string = 'count';
  public static readonly TYPE: string = 'type';
  public static readonly POSITION: string = 'position';
  public static readonly QUICK_SEARCH_KEY: string = 'quick_search_key';
  public static readonly READ_ONLY: string = 'read_only';
  public static readonly PERSONAL_NOTIFICATION_RINGTONE: string = 'personal_notification_ringtone';
  public static readonly HAS_PHONE_NUMBER: string = 'has_phone_number';
  public static readonly HAS_DISPLAY_NAME: string = 'has_display_name';
  public static readonly HAS_EMAIL: string = 'has_email';
  public static readonly HAS_GROUP: string = 'has_group';
  public static readonly BLOB_DATA: string = 'blob_data';
  public static readonly ACCOUNT_NAME: string = 'account_name';
  public static readonly ACCOUNT_TYPE: string = 'account_type';
  public static readonly DATA_INFO: string = 'data_info';
  public static readonly FORM_ID: string = 'form_id';
  public static readonly DISPLAY_NAME: string = 'display_name';
  public static readonly IS_DELETED: string = 'is_deleted';
  public static readonly PHOTO_FIRST_NAME: string = 'photo_first_name';
}