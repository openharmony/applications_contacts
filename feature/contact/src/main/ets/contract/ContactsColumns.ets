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
 * Field constants in the contact table
 */
export default class ContactsColumns extends BaseColumns {
  static readonly NAME_RAW_CONTACT_ID: string = "name_raw_contact_id";
  static readonly PHOTO_ID: string = "photo_id";
  static readonly PHOTO_FILE_ID: string = "photo_file_id";
  static readonly PERSONAL_RINGTONE: string = "personal_ringtone";
  static readonly IS_TRANSFER_VOICEMAIL: string = "is_transfer_voicemail";
  static readonly COMPANY: string = "company";
  static readonly POSITION: string = "position";
  static readonly QUICK_SEARCH_KEY: string = "quick_search_key";
  static readonly READ_ONLY: string = "read_only";
  static readonly PERSONAL_NOTIFICATION_RINGTONE: string = "personal_notification_ringtone";
  static readonly HAS_PHONE_NUMBER: string = "has_phone_number";
  static readonly HAS_DISPLAY_NAME: string = "has_display_name";
  static readonly HAS_EMAIL: string = "has_email";
  static readonly HAS_GROUP: string = "has_group";
}