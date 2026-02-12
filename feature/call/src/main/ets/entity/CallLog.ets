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
import { AnswerState, Direction, MeetimeDirection } from '../contract/Calls';
import { CallTypeMeetime as CallTypeMeeTime } from '../contract/MeetimeCalls';

export enum CallType {
  IN = 1,
  OUT = 2,
  VOICEMAIL = 4,
  MISSED = 3,
  REJECTED = 5,
  OTHER = 7
}

// 运营商通话的 features 字段取值，联系人应用只展示 features < carrierCallFeaturesLimit 的通话记录
// 1 << 0 :  Call had video
// 1 << 1 :  Call was pulled externally
// 1 << 2 :  Call was HD
// 1 << 3 :  Call was WIFI call
// 1 << 4 :  Indicates the call underwent Assisted Dialing
// 1 << 5 :  Call was on RTT at some point
// 1 << 6 :  Call was VoLTE
export const carrierCallFeaturesLimit = 1000;

/**
 * feature转为二进制，对应的位，是1表示是该类型，不能直接使用等于判断，使用FeaturesUtil.isType判断
 * 原生联系人使用7位，更高位畅连使用
 */
export enum FeaturesType {
  VOICE = 0, // Voice call
  VIDEO = 1, // Video call
}

export class FeaturesUtil {
  public static isType(type: FeaturesType, feature?: number): boolean {
    if (feature == undefined) {
      return false;
    }

    // 如果是通话类型，0就是通话类型，而没用位表示
    if (type == FeaturesType.VOICE && feature == FeaturesType.VOICE) {
      return true;
    }

    // 判断指定位数的数字是不是1
    return (feature >> (type - 1) & 1) == 1 ? true : false;
  }
}

export class CallLog {
  public readonly id: number = -1;
  public readonly phoneNumber: string;
  public readonly displayName: string;
  public readonly callDirection: number;
  public readonly voicemailUri: string;
  public readonly simId: number;
  public readonly simType: number;
  public readonly isSatellite: number;
  public readonly isRead: boolean;
  public readonly ringDuration: number;
  public readonly talkDuration: number;
  public readonly formattedNumber: string;
  public readonly quickSearchKey: string;
  public readonly numberType: number;
  public readonly numberTypeName: string;
  public readonly beginTime: number;
  public readonly endTime: number;
  public readonly answerState: number;
  public readonly createTime: number;
  public numberLocation: string;
  public readonly photoId: number;
  public readonly photoUri: string;
  public readonly countryIsoCode: number;
  public readonly features: number = -1;
  public callType: CallType | CallTypeMeeTime;
  public checked: boolean;
  public showTime: number;
  public readonly markType: string;
  public readonly markContent: string;
  public readonly markDetails: string;
  public readonly markSource: string;
  public readonly isCloudMark: number;
  public readonly markCount: number;
  public readonly blockReason: number;
  public readonly detectDetails: string;
  public readonly formatPhoneNumber: string;
  public readonly celiaCallType: number;
  public readonly newCalling: number;
  public readonly isCnap: number;
  public readonly abstractProfile: string;
  public readonly absStatus: string;
  public readonly notesId: string;
  public readonly absCode: string;
  public readonly notesStatus: string;
  public readonly startTime: number;
  public readonly abstractType: string;

  constructor(builder: CallLogBuilder) {
    this.id = builder.id;
    this.phoneNumber = builder.phoneNumber;
    this.displayName = builder.displayName;
    this.callDirection = builder.callDirection;
    this.voicemailUri = builder.voicemailUri;
    this.simId = builder.simId;
    this.simType = builder.simType;
    this.isSatellite = builder.isSatellite;
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
    this.features = builder.features;
    this.callType = this.getCallLogType();
    this.checked = false;
    this.showTime = this.getShowTime();
    this.markType = builder.markType;
    this.markContent = builder.markContent;
    this.markDetails = builder.markDetails;
    this.markSource = builder.markSource;
    this.isCloudMark = builder.isCloudMark;
    this.markCount = builder.markCount;
    this.blockReason = builder.blockReason;
    this.detectDetails = builder.detectDetails;
    this.formatPhoneNumber = builder.formatPhoneNumber;
    this.celiaCallType = builder.celiaCallType;
    this.newCalling = builder.newCalling;
    this.isCnap = builder.isCnap;
    this.abstractProfile = builder.abstractProfile;
    this.absStatus = builder.absStatus;
    this.notesId = builder.notesId;
    this.absCode = builder.absCode;
    this.notesStatus = builder.notesStatus;
    this.startTime = builder.startTime;
    this.abstractType = builder.abstractType;
  }

  // 如果是畅连访问，后续会更新这个值
  private getCallLogType(): CallType | CallTypeMeeTime {
    if (this.callDirection == (this.features < carrierCallFeaturesLimit ? Direction.IN : MeetimeDirection.IN)) {
      if (this.answerState == AnswerState.RECEIVED) {
        return CallType.IN;
      }
      if (this.answerState == AnswerState.MISSED) {
        return CallType.MISSED;
      }
      if (this.answerState == AnswerState.REJECT) {
        return CallType.REJECTED;
      }
      if (this.answerState == AnswerState.OTHER) {
        return CallType.OTHER;
      }
      return CallType.IN;
    } else {
      return CallType.OUT;
    }
  }

  private getShowTime(): number {
    return this.createTime;
  }
}

export class CallLogCnap {
  public isCnap: number;
  public displayName: string;
  constructor(isCnap: number, displayName: string) {
    this.isCnap = isCnap;
    this.displayName = displayName;
  }
}