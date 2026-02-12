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

export enum AnswerState {
  MISSED = 0,
  RECEIVED = 1,
  REJECT = 2,
  BLOCKED = 6,
  OTHER = 7
}

export enum Direction {
  IN = 0,
  OUT = 1
}

export enum MeetimeDirection {
  IN = 1,
  OUT = 0
}

export default class Calls {
  public static readonly CONTENT_URI: string = 'datashare:///com.ohos.calllogability';
  // 静默访问uri
  public static readonly CONTENT_URI_PROXY_QUERY_CALLLOG: string =
    'datashareproxy://com.ohos.contactsdataability/callsEl5/calllog';
  public static readonly CALL_LOG_URI: string = Calls.CONTENT_URI + '/calls/calllog';
  public static readonly ID: string = 'id';
  public static readonly PHONE_NUMBER: string = 'phone_number';
  public static readonly DISPLAY_NAME: string = 'display_name';
  public static readonly CALL_DIRECTION: string = 'call_direction';
  public static readonly VOICEMAIL_URI: string = 'voicemail_uri';
  public static readonly SIM_ID: string = 'slot_id'
  public static readonly SIM_TYPE: string = 'sim_type';
  public static readonly IS_SATELLITE: string = 'hw_is_satellite';
  public static readonly IS_READ: string = 'is_read';
  public static readonly RING_DURATION: string = 'ring_duration';
  public static readonly TALK_DURATION: string = 'talk_duration';
  public static readonly FORMAT_NUMBER: string = 'format_number';
  public static readonly QUICK_SEARCH_KEY: string = 'quicksearch_key';
  public static readonly NUMBER_TYPE: string = 'number_type';
  public static readonly NUMBER_TYPE_NAME: string = 'number_type_name';
  public static readonly BEGIN_TIME: string = 'begin_time';
  public static readonly END_TIME: string = 'end_time';
  public static readonly ANSWER_STATE: string = 'answer_state';
  public static readonly CREATE_TIME: string = 'create_time';
  public static readonly NUMBER_LOCATION: string = 'number_location';
  public static readonly PHOTO_ID: string = 'photo_id';
  public static readonly PHOTO_URI: string = 'photo_uri';
  public static readonly COUNTRY_ISO_CODE: string = 'country_iso_code';
  public static readonly PRIVACY_TAG: string = 'privacy_tag';
  public static readonly EXTRA1: string = 'extra1';
  public static readonly EXTRA2: string = 'extra2';
  public static readonly EXTRA3: string = 'extra3';
  public static readonly EXTRA4: string = 'extra4';
  public static readonly EXTRA5: string = 'extra5';
  public static readonly EXTRA6: string = 'extra6';
  public static readonly FEATURES: string = 'features';
  public static readonly MARK_TYPE: string = 'mark_type';
  public static readonly MARK_CONTENT: string = 'mark_content';
  public static readonly MARK_DETAILS: string = 'mark_details';
  public static readonly MARK_SOURCE: string = 'mark_source';
  public static readonly IS_CLOUD_MARK: string = 'is_cloud_mark';
  public static readonly MARK_COUNT: string = 'mark_count';
  public static readonly BLOCK_REASON: string = 'block_reason';
  public static readonly DETECT_DETAILS: string = 'detect_details';
  public static readonly FORMAT_PHONE_NUMBER: string = 'format_phone_number';
  public static readonly CELIA_CALL_TYPE: string = 'celia_call_type';
  public static readonly NEW_CALLING: string = 'new_calling';
  public static readonly IS_CNAP: string = 'is_cnap';
  public static readonly SETTING_DATA_PROXY_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
  public static readonly CALL_RECORDER_LOG_PROXY_URI = 'datashare:///com.ohos.callrecorder.datashareAbility/call_record/record_log';
  public static readonly SETTING_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_100?Proxy=true';
  public static readonly SPAMSHIELD_SMART_IDENTITY_SWITCH = 'spamshield_call_live_detection';
  public static readonly ABSTRACT_PROFILE: string = 'abstract_profile';
  public static readonly ABS_STATUS: string = 'abs_status';
  public static readonly NOTES_ID: string = 'notes_id';
  public static readonly ABS_CODE: string = 'abs_code';
  public static readonly NOTES_STATUS: string = 'notes_status';
  public static readonly START_TIME: string = 'start_time';
  public static readonly ABSTRACT_TYPE: string = 'abstract_type';

  constructor() {
  }

  static getSearchFields() {
    return [
      Calls.ID,
      Calls.SIM_ID,
      Calls.PHONE_NUMBER,
      Calls.DISPLAY_NAME,
      Calls.CALL_DIRECTION,
      Calls.VOICEMAIL_URI,
      Calls.SIM_TYPE,
      Calls.IS_READ,
      Calls.RING_DURATION,
      Calls.TALK_DURATION,
      Calls.FORMAT_NUMBER,
      Calls.QUICK_SEARCH_KEY,
      Calls.NUMBER_TYPE,
      Calls.NUMBER_TYPE_NAME,
      Calls.BEGIN_TIME,
      Calls.END_TIME,
      Calls.ANSWER_STATE,
      Calls.CREATE_TIME,
      Calls.NUMBER_LOCATION,
      Calls.PHOTO_ID,
      Calls.PHOTO_URI,
      Calls.COUNTRY_ISO_CODE,
      Calls.MARK_TYPE,
      Calls.MARK_CONTENT,
      Calls.MARK_DETAILS,
      Calls.MARK_SOURCE,
      Calls.BLOCK_REASON,
      Calls.DETECT_DETAILS,
      Calls.IS_CLOUD_MARK,
      Calls.MARK_COUNT,
      Calls.IS_SATELLITE,
      Calls.EXTRA1,
      Calls.EXTRA2,
      Calls.EXTRA3,
      Calls.EXTRA4,
      Calls.EXTRA5,
      Calls.EXTRA6,
      Calls.FEATURES,
      Calls.FORMAT_PHONE_NUMBER,
      Calls.CELIA_CALL_TYPE,
      Calls.NEW_CALLING,
      Calls.IS_CNAP,
      Calls.ABSTRACT_PROFILE,
      Calls.ABS_STATUS,
      Calls.NOTES_ID,
      Calls.ABS_CODE,
      Calls.NOTES_STATUS,
      Calls.START_TIME,
      Calls.ABSTRACT_TYPE,
    ]
  }
}