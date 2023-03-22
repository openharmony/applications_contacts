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
  REJECT = 2
}

export enum Direction {
  IN = 0,
  OUT = 1
}

export default class Calls {
  static readonly CONTENT_URI: string = "datashare:///com.ohos.calllogability";
  static readonly CALL_LOG_URI: string = Calls.CONTENT_URI + "/calls/calllog";
  static readonly ID: string = "id";
  static readonly PHONE_NUMBER: string = "phone_number";
  static readonly DISPLAY_NAME: string = "display_name";
  static readonly CALL_DIRECTION: string = "call_direction";
  static readonly VOICEMAIL_URI: string = "voicemail_uri";
  static readonly SIM_ID: string = "slot_id"
  static readonly SIM_TYPE: string = "sim_type";
  static readonly IS_HD: string = "is_hd";
  static readonly IS_READ: string = "is_read";
  static readonly RING_DURATION: string = "ring_duration";
  static readonly TALK_DURATION: string = "talk_duration";
  static readonly FORMAT_NUMBER: string = "format_number";
  static readonly QUICK_SEARCH_KEY: string = "quicksearch_key";
  static readonly NUMBER_TYPE: string = "number_type";
  static readonly NUMBER_TYPE_NAME: string = "number_type_name";
  static readonly BEGIN_TIME: string = "begin_time";
  static readonly END_TIME: string = "end_time";
  static readonly ANSWER_STATE: string = "answer_state";
  static readonly CREATE_TIME: string = "create_time";
  static readonly NUMBER_LOCATION: string = "number_location";
  static readonly PHOTO_ID: string = "photo_id";
  static readonly PHOTO_URI: string = "photo_uri";
  static readonly COUNTRY_ISO_CODE: string = "country_iso_code";
  static readonly EXTRA1: string = "extra1";
  static readonly EXTRA2: string = "extra2";
  static readonly EXTRA3: string = "extra3";
  static readonly EXTRA4: string = "extra4";
  static readonly EXTRA5: string = "extra5";
  static readonly EXTRA6: string = "extra6";
  constructor() {
  }
}