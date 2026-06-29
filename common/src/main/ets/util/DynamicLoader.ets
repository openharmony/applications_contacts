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
import { HiLog } from './HiLog';

const TAG = 'DynamicLoader';
export class DynamicLoader {
  public static ACCOUNTANTS = 'Accountants';
  public static BATCH_SELECT_CONTACTS_PAGE = 'BatchSelectContactsPage';
  public static CONTACT_DETAIL_PAGE = 'ContactDetail';
  public static IMPORT_AND_EXPORT_PAGE = 'ImportAndExport';
  public static EDIT_FAVORITE_LIST_PAGE = 'editFavoriteList';
  public static BATCH_DELETE_RECORD_PAGE = 'BatchDeleteRecord';
  public static SINGLE_SELECT_CONTACTS_PAGE = 'SingleSelectContactPage';
  public static BATCH_DELETE_GROUP = 'BatchDeleteGroup';
  public static GROUP_LIST_DETAIL = 'GroupListDetail';
  public static REMOVE_MEMBER = 'RemoveMember';
  public static SELECT_MEMBER_SEND_MESSAGE = 'SelectMemberSendMessage';
  public static ARRANGE_CONTACTS_PAGE = 'ArrangeContacts';
  public static SELECT_REPEAT_CONTACT_PAGE = 'SelectRepeatContact';
  public static COPY_CONTACTS_PAGE = 'CopyContacts';
  public static ADD_FAVORITE_LIST_PAGE = 'addFavoriteList';
  public static ACCOUNT_LIST_PAGE = 'AccountList';
  public static BATCH_DELETE_CONTACTS = 'BatchDeleteContacts';
  public static RECENT_DELETE_PAGE = 'RecentDelete';
  public static SETTING_ABOUT_PAGE = 'SettingAbout';
  public static RING_TONE_SELECTION_PAGE = 'LocalMusicSelection';
  public static VIDEO_RING_TONE_SELECTION_PAGE = 'VideoMusicSelection';
  public static INTELLIGENCE_GROUP_SINGLE_CATEGORY_DETAIL = 'IntelligenceGroupSingleCategoryDetail';
  public static INTELLIGENCE_GROUP_SINGLE_GROUP_DETAIL = 'IntelligenceGroupSingleGroupDetail';
  public static INTELLIGENCE_GROUP_SELECT_MEM_SEND_MSG = 'IntelligenceGroupSelectMemSendMsg';

  public tag: string = 'DynamicLoader: ';
  // dfx global pointer
  private static instance: DynamicLoader | null = null;
  public dynamicLoaderCB: ((key: string) => Promise<boolean>) | null = null;
  // 联系人设置--动态加载回调
  public dynamicLoaderSettingsCB: ((key: string) => Promise<boolean>) | null = null;
  // 联系人铃声--动态加载回调
  public dynamicLoaderRingToneCB: ((key: string) => Promise<boolean>) | null = null;

  constructor() {
  }

  register(loaderCallback: (key: string) => Promise<boolean>): void {
    this.dynamicLoaderCB = loaderCallback;
  }

  // 注册联系人设置动态加载回调
  registerSettings(loaderCallback: (key: string) => Promise<boolean>): void {
    this.dynamicLoaderSettingsCB = loaderCallback;
  }

  // 注册联系人铃声动态加载回调
  registerRingTone(loaderCallback: (key: string) => Promise<boolean>): void {
    this.dynamicLoaderRingToneCB = loaderCallback;
  }

  // 通过是否传参，判断是否为设置页面加载
  async fire(key: string, isSettings?: boolean, isRingTone?: boolean): Promise<boolean> {
    HiLog.i(TAG, 'dynamic load page fire: ' + key);
    let value: boolean = false;
    try {
      if (isSettings) {
        if (this.dynamicLoaderSettingsCB === null) {
          return true;
        }
        value = await this.dynamicLoaderSettingsCB(key);
      } else if (isRingTone) {
        if (this.dynamicLoaderRingToneCB === null) {
          return true;
        }
        value = await this.dynamicLoaderRingToneCB(key);
      } else {
        if (this.dynamicLoaderCB === null) {
          return true;
        }
        value = await this.dynamicLoaderCB(key);
      }
      // 通过await import('xxx') 方式，引入页面
      HiLog.w(TAG, 'fire value is ' + value);
    } catch (error) {
      HiLog.e(TAG, `Error in dynamic load page fire: ${error?.message}`);
    }
    return value;
  }

  public static getInstance(): DynamicLoader {
    if (DynamicLoader.instance === null) {
      DynamicLoader.instance = new DynamicLoader();
    }
    return DynamicLoader.instance;
  }
}