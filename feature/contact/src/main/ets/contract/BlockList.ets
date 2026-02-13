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
 * Field constants in the contact contact_blocklist table
 */
export default class BlockList extends BaseColumns {
  public static readonly TYPES: string = 'types';
  public static readonly MARK: string = 'mark';
  public static readonly NAME: string = 'name';
  public static readonly PHONE_NUMBER: string = 'phone_number';
  public static readonly FORMAT_PHONE_NUMBER: string = 'format_phone_number';
  public static readonly INTERCEPTION_CALL_COUNT: string = 'interception_call_count';
  public static readonly INTERCEPTION_MSG_COUNT: string = 'interception_msg_count';
  public static readonly CONTENT: string = 'content';
  public static readonly TIME_STAMP: string = 'time_stamp';
}

export enum BlockType {
  BLOCK = 0,
  ACCESS = 1,
  BLOCK_START = 2
}