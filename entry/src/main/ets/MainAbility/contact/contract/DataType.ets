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

import DataColumns from './DataColumns';

export enum DataItemType {
  EMAIL = 1,
  IM = 2,
  NICKNAME = 3,
  ORGANIZATION = 4,
  PHONE = 5,
  NAME = 6,
  STRUCTURED_POSTAL = 7,
  PHOTO = 8,
  GROUP_MEMBERSHIP = 9,
  NOTE = 10,
  EVENT = 11,
  WEBSITE = 12,
  RELATION = 13,
  CONTACT_MISC = 14,
  HI_CALL_DEVICE = 15,
  CAM_CARD = 16,
  SIP_ADDRESS = 17
}

/**
 * Basic Data Type
 */
export default class DataType {
  static readonly TYPE_CUSTOM: number = 0;
  static readonly TYPE_INVALID: number = -1;
  static readonly DATA: string = DataColumns.DETAIL_INFO;
  static readonly LABEL_ID: string = DataColumns.EXTEND7;
  static readonly LABEL_NAME: string = DataColumns.CUSTOM_DATA;
}