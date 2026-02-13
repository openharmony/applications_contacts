/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
 * Field constants in the contact deleted_raw_contact table
 */
export default class DeletedRawContactsColumns extends BaseColumns {
  public static readonly ID: string = 'id';
  public static readonly CONTACT_ID: string = 'contact_id';
  public static readonly RAW_CONTACT_ID: string = 'raw_contact_id';
  public static readonly DELETE_TIME: string = 'delete_time';
  public static readonly DELETE_SOURCE: string = 'delete_source';
  public static readonly DISPLAY_NAME: string = 'display_name';
  public static readonly DELETE_ACCOUNT: string = 'delete_account';
  public static readonly BACKUP_DATA: string = 'backup_data';
  public static readonly DELETE_DATE: string = 'delete_date';
  public static readonly IS_DELETED: string = 'is_deleted';
}