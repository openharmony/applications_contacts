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
 * Field constants in the contact yellow_page_view view
 */
export default class NumberMark extends BaseColumns {
  public static readonly NUMBER_MARK_URI: string = 'datashare:///com.ohos.numbermarkability';
  public static readonly NUMBER_MARK_INFO_URI: string = NumberMark.NUMBER_MARK_URI + '/number_mark';

  public static readonly ID: string = '_ID';
  public static readonly NUMBER: string = 'NUMBER';
  public static readonly NAME: string = 'NAME';
  public static readonly CLASSIFY: string = 'CLASSIFY';
  public static readonly MARKED_COUNT: string = 'MARKED_COUNT';
  public static readonly IS_CLOUD: string = 'IS_CLOUD';
  public static readonly DESCRIPTION: string = 'DESCRIPTION';
  public static readonly SAVE_TIMESTAMP: string = 'SAVE_TIMESTAMP';
  public static readonly SUPPLIER: string = 'SUPPLIER';
}
