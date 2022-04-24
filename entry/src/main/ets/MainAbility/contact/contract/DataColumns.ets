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
  static readonly TYPE_ID: string = "type_id";
  static readonly RAW_CONTACT_ID: string = "raw_contact_id";
  static readonly READ_ONLY: string = "read_only";
  static readonly VERSION: string = "version";
  static readonly IS_PREFERRED_NUMBER: string = "is_preferred_number";
  static readonly DETAIL_INFO: string = "detail_info";
  static readonly FAMILY_NAME: string = "family_name";
  static readonly MIDDLE_NAME_PHONETIC: string = "middle_name_phonetic";
  static readonly GIVEN_NAME: string = "given_name";
  static readonly GIVEN_NAME_PHONETIC: string = "given_name_phonetic";
  static readonly ALIAS_DETAIL_INTO: string = "alias_detail_info";
  static readonly PHONETIC_NAME: string = "phonetic_name";
  static readonly POSITION: string = "position";
  static readonly EXTEND1: string = "extend1";
  static readonly EXTEND2: string = "extend2";
  static readonly EXTEND3: string = "extend3";
  static readonly EXTEND4: string = "extend4";
  static readonly CITY: string = "city";
  static readonly COUNTRY: string = "country";
  static readonly NEIGHBORHOOD: string = "neighborhood";
  static readonly POBOX: string = "pobox";
  static readonly POSTCODE: string = "postcode";
  static readonly REGION: string = "region";
  static readonly STREET: string = "street";
  static readonly ALPHA_NAME: string = "alpha_name";
  static readonly OTHER_LAN_LAST_NAME: string = "other_lan_last_name";
  static readonly OTHER_LAN_FIRST_NAME: string = "other_lan_first_name";
  static readonly EXTEND5: string = "extend5";
  static readonly LAN_STYLE: string = "lan_style";
  static readonly CUSTOM_DATA: string = "custom_data";
  static readonly EXTEND6: string = "extend6";
  static readonly EXTEND7: string = "extend7";
  static readonly BLOB_DATA: string = "blob_data";
  static readonly SYN_1: string = "syn_1";
  static readonly SYN_2: string = "syn_2";
  static readonly SYN_3: string = "syn_3";
}