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

export enum CallTypeMeetime {
  IN = 1,
  OUT = 2,
  VOICEMAIL = 4,
  MISSED = 3,
  REJECTED = 5,
  RECEIVED_BY_OTHER = 6,
  REJECTED_BY_OTHER = 7,
}

/**
 * 通话响应状态
 */
export enum AnswerState {
  CALL_OUT = -1,
  MISSED = 0,
  RECEIVED = 1,
  REJECT = 2,
  SYSTEM_MISSED = 0,
  SYSTEM_RECEIVED = 1,
  SYSTEM_REJECT = 2,
  RECEIVED_BY_OTHER = 3,
  REJECT_BY_OTHER = 5,
}

/**
 * 来去电
 */
export enum Direction {
  OUT = 0,
  IN = 1,
  SYSTEM_IN = 0,
  SYSTEM_OUT = 1
}

export class FeatureType {
  public static SYSTEM: number = 0;
}

export class MeetimeCalls {
  /**
   * 获取通话类型
   *
   * @param callDirection
   * @param answerState
   */
  public static getCallType(features: number, callDirection: number, answerState: number): number {
    // 系统通话
    if (features === FeatureType.SYSTEM) {
      if (callDirection === Direction.SYSTEM_IN) {
        if (answerState === AnswerState.SYSTEM_MISSED) {
          return CallTypeMeetime.MISSED;
        } else if (answerState === AnswerState.SYSTEM_REJECT) {
          return CallTypeMeetime.REJECTED;
        } else {
          return CallTypeMeetime.IN;
        }
      } else {
        return CallTypeMeetime.OUT;
      }
    } else {
      if (callDirection === Direction.IN) {
        if (answerState === AnswerState.MISSED) {
          return CallTypeMeetime.MISSED;
        } else if (answerState === AnswerState.REJECT) {
          return CallTypeMeetime.REJECTED;
        } else if (answerState === AnswerState.RECEIVED_BY_OTHER) {
          return CallTypeMeetime.RECEIVED_BY_OTHER
        } else if (answerState === AnswerState.REJECT_BY_OTHER) {
          return CallTypeMeetime.REJECTED_BY_OTHER
        } else {
          return CallTypeMeetime.IN;
        }
      } else {
        return CallTypeMeetime.OUT;
      }
    }
  }
}

