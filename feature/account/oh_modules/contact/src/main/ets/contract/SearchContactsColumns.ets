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

import BaseColumns from './BaseColumns';

/**
 * Field constants in the contact searchcontact table
 */
export default class SearchContactsColumns extends BaseColumns {
  static readonly ACCOUNT_ID: string = 'account_id';
  static readonly CONTACT_ID: string = 'contact_id';
  static readonly ROW_CONTACT_ID: string = 'raw_contact_id';
  static readonly SEARCH_NAME: string = 'search_name';
  static readonly DISPLAY_NAME: string = 'display_name';
  static readonly PHONETIC_NAME: string = 'phonetic_name';
  static readonly PHOTO_ID: string = 'photo_id';
  static readonly PHOTO_FILE_ID: string = 'photo_file_id';
  static readonly IS_DELETED: string = 'is_deleted';
  static readonly TYPE_ID: string = 'type_id';
  static readonly POSITION: string = 'position';
  static readonly DETAIL_INFO: string = 'detail_info';
  static readonly PHOTO_FIRST_NAME: string = 'photo_first_name';
  static readonly SORT_FIRST_LETTER: string = 'sort_first_letter';
  static readonly CUSTOM_DATA: string = 'custom_data';
  static readonly CONTENT_TYPE: string = 'content_type';
  static readonly HAS_PHONE_NUMBER: string = 'has_phone_number';
}