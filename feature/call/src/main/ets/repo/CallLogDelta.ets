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

import { CallLog } from '../entity/CallLog';
import Calls from '../contract/Calls';

export default class CallLogDelta {
  public readonly callLog: CallLog;

  constructor(callLog: CallLog) {
    this.callLog = callLog;
  }

  createValuesBucket(): Record<string, string | number | boolean> {
    if (!this.callLog) {
      return {};
    }
    let result: Record<string, string | number | boolean> = {};
    result[Calls.PHONE_NUMBER] = this.callLog.phoneNumber;
    result[Calls.DISPLAY_NAME] = this.callLog.displayName;
    result[Calls.CALL_DIRECTION] = this.callLog.callDirection;
    result[Calls.VOICEMAIL_URI] = this.callLog.voicemailUri;
    result[Calls.SIM_TYPE] = this.callLog.simType;
    result[Calls.IS_SATELLITE] = this.callLog.isSatellite;
    result[Calls.IS_READ] = this.callLog.isRead;
    result[Calls.FEATURES] = this.callLog.features;
    result[Calls.RING_DURATION] = this.callLog.ringDuration;
    result[Calls.TALK_DURATION] = this.callLog.talkDuration;
    result[Calls.FORMAT_NUMBER] = this.callLog.formattedNumber;
    result[Calls.QUICK_SEARCH_KEY] = this.callLog.quickSearchKey;
    result[Calls.NUMBER_TYPE] = this.callLog.numberType;
    result[Calls.BEGIN_TIME] = this.callLog.beginTime;
    result[Calls.END_TIME] = this.callLog.endTime;
    result[Calls.ANSWER_STATE] = this.callLog.answerState;
    result[Calls.CREATE_TIME] = this.callLog.createTime;
    result[Calls.NUMBER_LOCATION] = this.callLog.numberLocation;
    result[Calls.PHOTO_ID] = this.callLog.photoId;
    result[Calls.PHOTO_URI] = this.callLog.photoUri;
    result[Calls.COUNTRY_ISO_CODE] = this.callLog.countryIsoCode;

    return result;
  }
}