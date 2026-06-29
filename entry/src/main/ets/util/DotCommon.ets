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
import { CustomizedParams } from '../model/type';

class EventName {
  public readonly CARD_ADD_CONTACT_EVENT = 'CARD_ADD_CONTACT_EVENT';
  public readonly CARD_CALL_CONTACT_EVENT = 'CARD_CALL_CONTACT_EVENT';
  public readonly CARD_VIEW_DETAIL_EVENT = 'CARD_VIEW_DETAIL_EVENT';
  public readonly CARD_ADD_CONTACTS_NUMBER_EVENT = 'CARD_ADD_CONTACTS_NUMBER_EVENT';
  public readonly CARD_EDIT_ADD_CONTACT_EVENT = 'CARD_EDIT_ADD_CONTACT_EVENT';
  public readonly CARD_EDIT_DELETE_CONTACT_EVENT = 'CARD_EDIT_DELETE_CONTACT_EVENT';
  public readonly CARD_EDIT_SAVE_CONTACT_EVENT = 'CARD_EDIT_SAVE_CONTACT_EVENT';
  public readonly CARD_EDIT_CANCEL_CONTACT_EVENT = 'CARD_EDIT_CANCEL_CONTACT_EVENT';
  public readonly CARD_EDIT_MOVE_CONTACT_EVENT = 'CARD_EDIT_MOVE_CONTACT_EVENT';
  public readonly ADD_BLOCKLIST_EVENT = 'ADD_BLOCKLIST_EVENT';
  public readonly REMOVE_BLOCKLIST_EVENT = 'REMOVE_BLOCKLIST_EVENT';
  public readonly SHARE_CONTACT_EVENT = 'SHARE_CONTACT_EVENT';
  public readonly VIDEO_CALLING_EVENT = 'VIDEO_CALLING_EVENT';
  public readonly IMPORT_CONTACT_EVENT = 'IMPORT_CONTACT_EVENT';
  public readonly EXPORT_CONTACT_EVENT = 'EXPORT_CONTACT_EVENT';
  public readonly CLICK_EXPORT_CONTACT_EVENT = 'CLICK_EXPORT_CONTACT_EVENT';
  public readonly SETTINGS_IMPORT_AND_EXPORT_EVENT = 'SETTINGS_IMPORT_AND_EXPORT_EVENT';
  public readonly SETTINGS_SHOW_CONTACT_EVENT = 'SETTINGS_SHOW_CONTACT_EVENT';
  public readonly SETTINGS_ORGANIZE_CONTACT_EVENT = 'SETTINGS_ORGANIZE_CONTACT_EVENT';
  public readonly AUTO_UPDATE_DATA_EVENT = 'AUTO_UPDATE_DATA_EVENT';
  public readonly DELETE_CONTACT_EVENT = 'DELETE_CONTACT_EVENT';
  public readonly DELETE_CONTACT_DIALOG_EVENT = 'DELETE_CONTACT_DIALOG_EVENT';
  public readonly PRESS_CONTACT_EVENT = 'PRESS_CONTACT_EVENT';
  public readonly NUMBER_TAG_EVENT = 'NUMBER_TAG_EVENT';
  public readonly NUMBER_TAG_TYPE_EVENT = 'NUMBER_TAG_TYPE_EVENT';
  public readonly MARK_UNKNOWN_NUM_EVENT = 'MARK_UNKNOWN_NUM_EVENT';
  public readonly SIM_GUIDE_DIALOG_EVENT = 'SIM_GUIDE_DIALOG_EVENT';
  public readonly FAVORITE_PRESS_CHOOSE_EVENT = 'FAVORITE_PRESS_CHOOSE_EVENT';
  public readonly PRESS_VIEW_LOG_EVENT = 'PRESS_VIEW_LOG_EVENT';
  public readonly PRESS_LOG_CHOOSE_EVENT = 'PRESS_LOG_CHOOSE_EVENT';
  public readonly DELETE_LOG_DIALOG_EVENT = 'DELETE_LOG_DIALOG_EVENT';
  public readonly SETTINGS_RECENT_DELETE_EVENT = 'SETTINGS_RECENT_DELETE_EVENT';
  public readonly RECENT_DELETE_CLEAR_EVENT = 'RECENT_DELETE_CLEAR_EVENT';
  public readonly RECENTDEL_CLEAR_DIALOG_EVENT = 'RECENTDEL_CLEAR_DIALOG_EVENT';
  public readonly RECENT_DELETE_RESTORE_EVENT = 'RECENT_DELETE_RESTORE_EVENT';
  public readonly SET_VOICE_NUM_DIALOG_EVENT = 'SET_VOICE_NUM_DIALOG_EVENT';
  public readonly MISSED_CALL_EVENT = 'MISSED_CALL_EVENT';
  public readonly RECENT_DELETE_OPERATE_EVENT = 'RECENT_DELETE_OPERATE_EVENT';
  public readonly RECENTDEL_DELETE_DIALOG_EVENT = 'RECENTDEL_DELETE_DIALOG_EVENT';
  public readonly PRESS_SLIDE_DIAL_BUTTON_EVENT = 'PRESS_SLIDE_DIAL_BUTTON_EVENT';
  public readonly STICKER_BOARD_APPEAR_EVENT = 'STICKER_BOARD_APPEAR_EVENT';
  public readonly CLICK_STICKER_BOARD_EVENT = 'CLICK_STICKER_BOARD_EVENT';
  public readonly CLICK_INDEX_BAR_EVENT = 'CLICK_INDEX_BAR_EVENT';
  public readonly CLICK_MYCARD_EVENT = 'CLICK_MYCARD_EVENT';
  public readonly EDIT_MYCARD_EVENT = 'EDIT_MYCARD_EVENT';
  public readonly CLICK_MYCARD_MENU_EVENT = 'CLICK_MYCARD_MENU_EVENT';
  public readonly DELETE_MYCARD_EVENT = 'DELETE_MYCARD_EVENT';
  public readonly CLICK_CONTACT_ABOUT_EVENT = 'CLICK_CONTACT_ABOUT_EVENT';
  public readonly REBUILD_INDEX_EVENT = 'REBUILD_INDEX_EVENT';
}

class EventParam {
  public readonly ADD_CONTACT = 'add detail';
  public readonly SHORT_CUT_CARD_TYPE = 0;
  public readonly SPEED_DIAL_CARD_TYPE = 1;
  public readonly MISSED_CALL_CARD_TYPE = 2;
  public readonly SELECT_FALSE: number = 0;
  public readonly SELECT_TRUE: number = 1;
  public readonly CARD_NUMBER_ONE: number = 0;
  public readonly CARD_NUMBER_TWO: number = 1;
  public readonly SIM_CARD_ONE: number = 0;
  public readonly SIM_CARD_TWO: number = 1;
  public readonly PROMPT_LATER: number = 0;
  public readonly IMPORT: number = 1;
  public readonly ITEM_SHARE: number = 0;
  public readonly ITEM_UNFAVORITE: number = 1;
  public readonly ITEM_CONTACT_MULTISELECT: number = 2;
  public readonly CALL_RECORD_MENU: number = 0;
  public readonly DIALER_SEARCH_MENU: number = 1;
  public readonly DETAIL_MENU: number = 2;
  public readonly MARK_TYPE_CRANK: number = 1;
  public readonly MARK_TYPE_FRAUD: number = 2;
  public readonly MARK_TYPE_EXPRESS: number = 3;
  public readonly MARK_TYPE_PROMOTE_SALES: number = 4;
  public readonly MARK_TYPE_HOUSE_AGENT: number = 5;
  public readonly MARK_TYPE_INSURANCE: number = 6;
  public readonly MARK_TYPE_TAXI: number = 7;
  public readonly MARK_TYPE_CUSTOMIZE: number = 8;
  public readonly DIALOG_CANCEL: number = 0;
  public readonly DIALOG_DELETE: number = 1;
  public readonly DIALOG_CLEAR: number = 1;
  public readonly CHECK_ONE: number = 0;
  public readonly CHECK_MORE: number = 1;
  public readonly CHECK_ALL: number = 2;
  public readonly CHECK_NONE: number = -1;
  public readonly CLICK_RESTORE: number = 0;
  public readonly CLICK_DELETE: number = 1;
  public readonly NOT_CLICK: number = 2;
  public readonly CLICK_CANCEL: number = 0;
  public readonly CLICK_CALL: number = 0;
  public readonly CLICK_DELETE_LOG: number = 1;
  public readonly SET_VOICE_MAIL: number = 1;
  public readonly CANCEL_SET: number = 0;
  public readonly SEARCH_CONTACT_FAIL_MASSAGE = 'taskpool:: task has been canceled';
  public readonly NO_CARD: number = 0;
  public readonly ONE_CARD: number = 1;
  public readonly TWO_CARD: number = 2;
  public readonly CLICK_CONTACT_CALL_HISTORY_DETAIL: number = 0;
  public readonly CLICK_CALL_HISTORY: number = 1;
  public readonly CLICK_CALL_HISTORY_SEARCH: number = 2;
  public readonly CLICK_SERVICE_PROVIDER: number = 0;
  public readonly CLICK_VOICEMAIL_NUMBER: number = 1;
}

class FaultEventName {
  public readonly ADD_CONTACTS_PHOTO_FAIL = 'ADD_CONTACTS_PHOTO_FAIL';
  public readonly CALLLOG_DISPLAY_ERROR = 'CALLLOG_DISPLAY_ERROR';
  public readonly ADD_CONTACTS_FAIL = 'ADD_CONTACTS_FAIL';
  public readonly ADD_SIM_CONTACTS_FAIL = 'ADD_SIM_CONTACTS_FAIL';
  public readonly DISPLAY_CONTACTS_DETAIL_ERROR = 'DISPLAY_CONTACTS_DETAIL_ERROR';
  public readonly SEARCH_CONTACTS_FAIL = 'SEARCH_CONTACTS_FAIL';
  public readonly DELETE_CONTACTS_FAIL = 'DELETE_CONTACTS_FAIL';
  public readonly DISPLAY_CONTACTS_LIST_ERROR = 'DISPLAY_CONTACTS_LIST_ERROR';
  public readonly CALLLOG_SEARCH_ERROR = 'CALLLOG_SEARCH_ERROR';
  public readonly SIM_STATE_ERROR = 'SIM_STATE_ERROR';
}

class StatusEventName {
  public readonly SIM_NUM_EVENT = 'SIM_NUM_EVENT';
}

class CommonData {
  public eventName = new EventName();
  public eventParam = new EventParam();
  public faultEventName = new FaultEventName();
  public statusEventName = new StatusEventName();
}

export default new CommonData();

export let customParams: CustomizedParams = {};

export let contactParams: CustomizedParams = {
  ENC: 0,
};

export let addContactNumberParams: CustomizedParams = {
  NUM: 0
};

export let autoUpdateDataParams: CustomizedParams = {
  ITEM: 0,
};

export let videoCallParams: CustomizedParams = {
  ENC: 0,
  SLOT: 0,
  ISMULTISIMCARD: 0,
  HAS_DEFAULT_SIM_CARD: 0,
  REGISTERED_VOLTE_CARD: 0
};

export let exportContactParams: CustomizedParams = {
  ISEXPORT: 0,
};

export let deleteDialogContactParams: CustomizedParams = {
  ISPOP: 0,
  ISDELETE: 0
};

export let importContactParams: CustomizedParams = {
  IMPORT: 0
};

export let itemParams: CustomizedParams = {
  ITEM: 0,
};

export let markTypeParams: CustomizedParams = {
  MARKTYPE: 0,
};

export let faultContactParams: CustomizedParams = {
  FAULT_INFO: ''
};

export let deleteLogDialogParams: CustomizedParams = {
  ISDELETE: 0
};

export let clearContactParams: CustomizedParams = {
  CLEAR: 0
};

export let recentDeleteOperateContactParams: CustomizedParams = {
  NUM: 0,
  OPERATE: 0
};

export let setContactParams: CustomizedParams = {
  ISSET: 0
};

export let recentDeleteDialogContactParams: CustomizedParams = {
  ISDELETE: 0
};

export let slideDialParams: CustomizedParams = {
  DIRECTION: 0,
};

export let searchIndexParams: CustomizedParams = {
  SEARCH_INDEX: -2,
};

export let abstractRestart: CustomizedParams = {};

export let abstractParams: CustomizedParams = {
  STATUS: 0,
};

export let abstractClick: CustomizedParams = {};

export let abstractFail: CustomizedParams = {
  IS_AUTO_SUMMARY: false,
  ERROR_TYPE: 'summary generation timeout',
};
