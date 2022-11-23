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
  readonly callLog: CallLog;
  constructor(callLog: CallLog) {
    this.callLog = callLog;
  }

  createValuesBucket(): {} {
    if (!this.callLog) {
      return [];
    }

    return {
      [Calls.PHONE_NUMBER]: this.callLog.phoneNumber,
      [Calls.DISPLAY_NAME]: this.callLog.displayName,
      [Calls.CALL_DIRECTION]: this.callLog.callDirection,
      [Calls.VOICEMAIL_URI]: this.callLog.voicemailUri,
      [Calls.SIM_TYPE]: this.callLog.simType,
      [Calls.IS_HD]: this.callLog.isHD,
      [Calls.IS_READ]: this.callLog.isRead,
      [Calls.RING_DURATION]: this.callLog.ringDuration,
      [Calls.TALK_DURATION]: this.callLog.talkDuration,
      [Calls.FORMAT_NUMBER]: this.callLog.formattedNumber,
      [Calls.QUICK_SEARCH_KEY]: this.callLog.quickSearchKey,
      [Calls.NUMBER_TYPE]: this.callLog.numberType,
      [Calls.BEGIN_TIME]: this.callLog.beginTime,
      [Calls.END_TIME]: this.callLog.endTime,
      [Calls.ANSWER_STATE]: this.callLog.answerState,
      [Calls.CREATE_TIME]: this.callLog.createTime,
      [Calls.NUMBER_LOCATION]: this.callLog.numberLocation,
      [Calls.PHOTO_ID]: this.callLog.photoId,
      [Calls.PHOTO_URI]: this.callLog.photoUri,
      [Calls.COUNTRY_ISO_CODE]: this.callLog.countryIsoCode,
    };
  }
}