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

export default class VoiceMail {
  static readonly CONTACT_URI: string = "datashare:///com.ohos.voicemailability";
  static readonly ID: string = "id";
  static readonly PHONE_NUMBER: string = "phone_number";
  static readonly QUICK_SEARCH_KEY: string = "quicksearch_key";
  static readonly DISPLAY_NAME: string = "display_name";
  static readonly VOICEMAIL_URI: string = "voicemail_uri";
  static readonly VOICEMAIL_TYPE: string = "voicemail_type";
  static readonly VOICE_FILE_SIZE: string = "voice_file_size";
  static readonly VOICE_DURATION: string = "voice_duration";
  static readonly VOICE_STATUS: string = "voice_status";
  static readonly ORIGIN_TYPE: string = "origin_type";
  static readonly CREATE_TIME: string = "create_time";
  constructor() {
  }
}