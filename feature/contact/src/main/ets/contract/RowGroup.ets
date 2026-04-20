/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
 * Field constants in the contact group table
 */
export default class RowGroup extends BaseColumns {
  public static readonly ACCOUNT_ID: string = 'account_id';
  public static readonly GROUP_NAME: string = 'group_name';
  public static readonly GROUP_NOTES: string = 'group_notes';
  public static readonly IS_DELETED: string = 'is_deleted';
  public static readonly GROUP_RINGTONE: string = 'group_ringtone';
  public static readonly RINGTONE_MODIFY_TIME: string = 'ringtone_modify_time';
  public static readonly LASETEST_MODIFY_TIME: string = 'lastest_modify_time';
}