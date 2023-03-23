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

import CallLogBuilder from '../entity/CallLogBuilder';
import {Direction, AnswerState} from '../contract/Calls';

export enum CallType {
  IN = 1,
  OUT = 2,
  VOICEMAIL = 4,
  MISSED = 3,
  REJECTED = 5
}

export class CallLog {
  readonly id: number = -1;
  readonly phoneNumber: string;
  readonly displayName: string;
  readonly callDirection: number;
  readonly voicemailUri: string;
  readonly simId: number;
  readonly simType: number;
  readonly isHD: boolean;
  readonly isRead: boolean;
  readonly ringDuration: number;
  readonly talkDuration: number;
  readonly formattedNumber: string;
  readonly quickSearchKey: string;
  readonly numberType: number;
  readonly numberTypeName: string;
  readonly beginTime: number;
  readonly endTime: number;
  readonly answerState: number;
  readonly createTime: number;
  readonly numberLocation: string;
  readonly photoId: number;
  readonly photoUri: string;
  readonly countryIsoCode: number;
  readonly callType: number;
  constructor(builder: CallLogBuilder) {
    this.id = builder.id;
    this.phoneNumber = builder.phoneNumber;
    this.displayName = builder.displayName;
    this.callDirection = builder.callDirection;
    this.simId = builder.simId;
    this.simType = builder.simType;
    this.isHD = builder.isHD;
    this.isRead = builder.isRead;
    this.ringDuration = builder.ringDuration;
    this.talkDuration = builder.talkDuration;
    this.formattedNumber = builder.formattedNumber;
    this.quickSearchKey = builder.quickSearchKey;
    this.numberType = builder.numberType;
    this.numberTypeName = builder.numberTypeName;
    this.beginTime = builder.beginTime;
    this.endTime = builder.endTime;
    this.answerState = builder.answerState;
    this.createTime = builder.createTime;
    this.numberLocation = builder.numberLocation;
    this.photoId = builder.photoId;
    this.photoUri = builder.photoUri;
    this.countryIsoCode = builder.countryIsoCode;
    this.callType = this.getCallLogType();
  }

  private getCallLogType() {
    if (this.callDirection == Direction.IN) {
      if (this.answerState == AnswerState.RECEIVED) {
        return CallType.IN;
      }
      if (this.answerState == AnswerState.MISSED) {
        return CallType.MISSED;
      }
      if (this.answerState == AnswerState.REJECT) {
        return CallType.REJECTED;
      }
    } else {
      return CallType.OUT;
    }
  }

  linkContact() {
  }

  /**
   * Configure Call Logs as Read
   */
  read() {
  }
}