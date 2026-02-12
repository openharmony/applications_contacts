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

export class Constants {
  /**
   * window避让区域高度的px值
   */
  public static readonly KEY_WINDOW_AVOID_AREA_HEIGHT_PX: string = 'windowAvoidAreaHeightPx';
  /**
   * window避让区域宽度的px值
   */
  public static readonly KEY_WINDOW_AVOID_AREA_WIDTH_PX: string = 'windowAvoidAreaWidthPx';
  /**
   * 联系人搜索的结果数
   */
  public static readonly KEY_CONTACT_SEARCH_NUMBER: string = 'contactSearchNumber';
  /**
   * 是否有双卡
   */
  public static readonly KEY_HAVE_MULTI_SIM_CARD: string = 'haveMultiSimCard';
  /**
   * 默认拨号卡号
   */
  public static readonly KEY_DEFAULT_SLOT: string = 'defaultSlot';
  /**
   * 通话记录是否为空
   */
  public static readonly KEY_CALL_LOG_LIST_EMPTY: string = 'callLogListEmpty';
  /**
   * 当前tab的index
   */
  public static readonly KEY_MAIN_TABS_INDEX: string = 'mainTabsIndex';
  /**
   * 当前窗口宽度的px值
   */
  public static readonly KEY_WINDOW_WIDTH_PX: string = 'windowWidthPX';
  /**
   * 当前窗口高度的px值
   */
  public static readonly KEY_WINDOW_HEIGHT_PX: string = 'windowHeightPx';
  /**
   * 是否显示粘贴光标
   */
  public static readonly KEY_IS_PASTE_SHOW_CURSOR: string = 'isPasteShowCursor';
  /**
   * 拨号按钮信息列表
   */
  public static readonly KEY_SPN_LIST: string = 'spnList';
  /**
   * 通话记录和联系人列表item之间的分割线宽度
   */
  public static readonly DIVIFER_HEIGHT: string = '1vp';
  /**
   * 是否有剪切
   */
  public static readonly KEY_IS_DIALER_INPUT_CUT: string = 'isDialerInputCut';
  /**
   * 选中联系人ID
   */
  public static readonly KEY_SELECT_CONTACT_ID: string = 'selectContactId';
  /**
   * 标记当前通话记录所处页面，0表示全部通话记录页面，1表示未接通话记录页面
   */
  public static readonly KEY_RECORD_TYPE: string = 'recordType';
  /**
   * 标记通话记录是否初始化完成
   */
  public static readonly KEY_CALL_RECORD_INIT: string = 'callRecordInit';
  /**
   * 标记活跃通话ID
   */
  public static readonly KEY_ACTIVE_CALL_ID: string = 'activeCallId';
  /**
   * 是否展示拨号盘
   */
  public static readonly KEY_SHOW_DIAL_BTN: string = 'showDialBtn';
  /**
   * 联系人是否在搜索状态
   */
  public static readonly KEY_IS_SHOW_CONTACT_SEARCH: string = 'isContactSearch';
  /**
   * 窗口的dpi
   */
  public static readonly KEY_DPI: string = 'dpi';
  /**
   * 联系人包名 bundleName
   */
  public static readonly CONTACT_BUNDLE_NAME: string = 'com.ohos.contacts';

  /**
   * intelligence group company categorytype
   */
  public static readonly INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE: string = '0';

  /**
   * intelligence group city categorytype
   */
  public static readonly INTELLIGENCE_GROUP_CITY_CATEGORYTYPE: string = '1';

  /**
   * intelligence group contact time categorytype
   */
  public static readonly INTELLIGENCE_GROUP_CONTACT_TIME_CATEGORYTYPE: string = '2';
  /**
   * intelligence group contact time categorytype one week contacted
   */
  public static readonly INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_ONE_WEEK: string = 'CONTACT_WEEKLY';
  /**
   * intelligence group contact time categorytype one month contacted
   */
  public static readonly INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_ONE_MONTH: string = 'CONTACT_MONTHLY';
  /**
   * intelligence group contact time categorytype three month contacted
   */
  public static readonly INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_THREE_MONTH: string = 'CONTACT_IN_THREE_MONTHS';

  /**
   * intelligence group user id
   */
  public static readonly INTELLIGENCE_GROUP_USER_ID: string = 'intelligenceGroupUserId';

  /**
   * 智能群组跳转联系人详情页来源参数
   */
  public static readonly FROM_PAGE_INTELLIGENCE_GROUPD: string = 'intelligenceGroupContactDetail';

  /**
   * account user id
   */
  public static readonly HICALL_USER_ID_STATUS: string = 'HiCall_User_Id_Status';

  /**
   * appstorage key intelligence_group_member_count
   */
  public static readonly INTELLIGENCE_GROUP_MEMBER_COUNT: string = 'intelligenceGroupContactCount';

  /**
   * intelligence group contact time categorytype more than three month not contacted
   */
  public static readonly INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_MORE_THAN_THREE_MONTH: string =
    'CONTACT_OVER_THREE_MONTHS';

  public static readonly EMTPY_STR: string = '';
}

export enum Favorite {
  /**
   * 联系人被收藏了
   */
  TRUE = '1',
  /**
   * 联系人被收藏了
   */
  FALSE = '0'

}

export enum SimCardType {
  /**
   * 实体SIM卡
   */
  PSIM = 0,
  /**
   * eSIM卡
   */
  ESIM = 1,
}
/**
 * 蓬莱模式下主页进程后台管控定时器的ID
 */
export const TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND = 'TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND_CONTROL_IN_INDEX';