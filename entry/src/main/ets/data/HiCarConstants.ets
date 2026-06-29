/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export class HiCarConstants {
  /**
   * want parameters中存储联系人应用是否在hicar上的key值
   */
  public static readonly HICAR_DEVICE_TYPE: string = 'hiCarDeviceType';
  /**
   * 存储联系人应用在hicar上，hiCarDeviceType对应的value值
   */
  public static readonly HICAR_DEVICE_TYPE_CAR: string = 'Car';
  /**
   * 应用是否在hicar上
   */
  public static readonly KEY_IS_IN_HICAR: string = 'isInHiCar';
  /**
   * 联系人的搜索页面是否展示引导页面
   */
  public static readonly KEY_IS_SHOW_GUIDE: string = 'isShowGuide';
  /**
   * hicar拨号盘按钮与按钮之间的margin值
   */
  public static readonly DIAL_BUTTON_MARGIN: number = 4;
  /**
   * CALL_EVENT点位ENC的枚举值，表示入口是hicar通话记录tab
   */
  public static readonly CONTACT_DOT_ENC_CALL_RECORDS = 11;
  /**
   * CALL_EVENT点位ENC的枚举值，表示入口是hicar联系人tab
   */
  public static readonly CONTACT_DOT_ENC_CONTACTS = 12;
  /**
   * CALL_EVENT点位ENC的枚举值，表示入口是hicar搜索页面
   */
  public static readonly CONTACT_DOT_ENC_SEARCH = 13;
  /**
   * CALL_EVENT点位ENC的枚举值，表示入口是hicar拨号tab
   */
  public static readonly CONTACT_DOT_ENC_DIALING = 14;
  /**
   *display的名字
   */
  public static readonly HI_CAR = 'HiCar';
}

export enum ImageType {
  /**
   * 没有通话记录
   */
  NO_CALL_RECORDS = 0,
  /**
   * 没有联系人
   */
  NO_CONTACTS = 1,
  /**
   * 没有搜索结果
   */
  NO_RESULT = 2
}