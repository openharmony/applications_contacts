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
 * Field constants in the contact data table
 */
export default class DataColumns extends BaseColumns {
  public static readonly TYPE_ID: string = 'type_id';
  public static readonly RAW_CONTACT_ID: string = 'raw_contact_id';
  public static readonly READ_ONLY: string = 'read_only';
  public static readonly VERSION: string = 'version';
  public static readonly IS_PREFERRED_NUMBER: string = 'is_preferred_number';
  public static readonly DETAIL_INFO: string = 'detail_info';
  public static readonly FORMAT_PHONE_NUMBER: string = 'format_phone_number';
  public static readonly FAMILY_NAME: string = 'family_name';
  public static readonly MIDDLE_NAME_PHONETIC: string = 'middle_name_phonetic';
  public static readonly GIVEN_NAME: string = 'given_name';
  public static readonly GIVEN_NAME_PHONETIC: string = 'given_name_phonetic';
  public static readonly ALIAS_DETAIL_INTO: string = 'alias_detail_info';
  public static readonly PHONETIC_NAME: string = 'phonetic_name';
  public static readonly POSITION: string = 'position';
  public static readonly EXTEND1: string = 'extend1';
  public static readonly EXTEND2: string = 'extend2';
  public static readonly EXTEND3: string = 'extend3';
  public static readonly EXTEND4: string = 'extend4';
  public static readonly CITY: string = 'city';
  public static readonly COUNTRY: string = 'country';
  public static readonly NEIGHBORHOOD: string = 'neighborhood';
  public static readonly POBOX: string = 'pobox';
  public static readonly POSTCODE: string = 'postcode';
  public static readonly REGION: string = 'region';
  public static readonly STREET: string = 'street';
  public static readonly ALPHA_NAME: string = 'alpha_name';
  public static readonly OTHER_LAN_LAST_NAME: string = 'other_lan_last_name';
  public static readonly OTHER_LAN_FIRST_NAME: string = 'other_lan_first_name';
  public static readonly EXTEND5: string = 'extend5';
  public static readonly LAN_STYLE: string = 'lan_style';
  public static readonly CUSTOM_DATA: string = 'custom_data';
  public static readonly EXTEND6: string = 'extend6';
  public static readonly EXTEND7: string = 'extend7';
  public static readonly EXTEND8: string = 'extend8';
  public static readonly EXTEND9: string = 'extend9';
  public static readonly EXTEND10: string = 'extend10';
  public static readonly EXTEND11: string = 'extend11';
  public static readonly BLOB_DATA: string = 'blob_data';
  public static readonly SYN_1: string = 'syn_1';
  public static readonly SYN_2: string = 'syn_2';
  public static readonly SYN_3: string = 'syn_3';
  public static readonly FAVORITE: string = 'favorite';
  public static readonly CONTENT_TYPE: string = 'content_type';
  public static readonly IS_DELETED: string = 'is_deleted';
  public static readonly CALENDAR_EVENT_ID: string = 'calendar_event_id';
  public static readonly BLOB_SOURCE: string = 'blob_source';
  // 标记“我的名片”
  public static readonly MARK_MY_CARD: string = 'primary_contact';
  public static readonly DISPLAY_NAME: string = 'display_name';
}