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
export default class YellowPage extends BaseColumns {
  public static readonly YELLOW_PAGE_URI: string = 'datashare:///com.ohos.numbermarkability';
  public static readonly YELLOW_PAGE_VIEW_URI: string = YellowPage.YELLOW_PAGE_URI + '/yellow_page_view';

  public static readonly PHOTO: string = 'photo';
  public static readonly PHOTO_URI: string = 'photo_uri';
  public static readonly NAME: string = 'name';
  public static readonly DAIL_MAP: string = 'dail_map';
  public static readonly HOT_POINTS: string = 'hot_points';
  public static readonly NUMBER: string = 'number';
  public static readonly YELLOW_PAGE_ID: string = 'ypid';
}
