/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
export default class EmitterConstant {
  public static readonly EMITTER_ACCOUNTANTS_EMITTER_ID: number = 1468;
  public static readonly EMITTER_ACCOUNTANTS_EVENT_ID: number = 1469;
  public static readonly EMITTER_ACCOUNTANTS_EVENT_ID_HIDE: number = 1470;
  public static readonly EMITTER_ACCOUNTANTS_TEXTAREA_ID: number = 1480;
  public static readonly EMITTER_SETTING_ABOUT_EXIT_ID: number = 1490;
  public static readonly EVENT_LIST_ADD_MEMBERS_ITEM_CHECKED: number = 1499;
  public static readonly EVENT_LIST_RECENT_DELETE_ITEM_CHECKED: number = 1500;
  public static readonly EVENT_LIST_DELETE_MEMBER_ITEM_CHECKED: number = 1501;
  public static readonly EVENT_LIST_RING_TONE_PLAY: number = 1600;
  /**
   * 通知hicar的searchpage应用在哪
   */
  public static readonly EMITTER_NOTICE_WHERE_APP_EVENT_ID: number = 1471;
  public static readonly EMITTER_CONTACTS_DEFAULT_SELECTED_EVENT_ID: number = 10240;

  public static readonly GET_ALL_CALLS_EMITTER_ID: string = 'GET_ALL_CALLS_EMITTER_ID';
  public static readonly GET_ALL_CONTACTS_EMITTER_ID: string = 'GET_ALL_CONTACTS_EMITTER_ID';

  public static readonly UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID: string = 'UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID';

  public static readonly MERGE_EVENT_ID: number = 109;


  /**
   * vcard导出完成事件
   */
  public static readonly EMITTER_EXPORT_EVENT_ID: number = 110;

  /**
   * vcard导入-从沙箱导入完成事件
   */
  public static readonly EMITTER_IMPORT_SANDBOX_EVENT_ID: number = 111;

  /**
   * vcard导入-从文件管理picker完成事件
   */
  public static readonly EMITTER_IMPORT_PICKER_EVENT_ID: number = 112;

  /*
  * 最近删除-分批次删除订阅事件id
  */
  public static readonly EMITTER_RECENT_DELETE_EVENT_ID: number = 113;

  /*
  * 设置 - sim卡导入
  */

  public static readonly SETTING_EXPORT_EMITTER_ID: number = 107;
  /*
  * 开机 - sim卡导入
  */
  public static readonly EXPORT_EMITTER_ID: number = 106;

  /*
  * 索引条 - 联系人列表
  */
  public static readonly CONTACT_CONTENT_ALPHABET_INDEXER_EMITTER_ID: number = 997;

  /*
  * 索引条 - 非联系人列表
  */
  public static readonly OTHER_ALPHABET_INDEXER_EMITTER_ID: number = 998;
  /*
  * 列表 - 列表缓存更新
  */
  public static readonly CONTACT_LIST_CACHE_UPDATE: number = 996;

  /*
* 取消收藏 -进度条显示
*/
  public static readonly DELETE_FAVORITE_PROGRESS: number = 200;
}