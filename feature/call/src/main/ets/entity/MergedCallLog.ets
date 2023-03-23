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

export default class MergedCallLog {
  id: number;
  createTime: string;
  count: number;
  ids: number[];
  isHD: boolean;
  callType: number;
  phoneNumber: string;
  displayName: string;
  quickSearchKey: string;
  numberLocation: string;
  formattedNumber: string;
  simType: number;
  simId: number;
  constructor(callLog: CallLog) {
    this.id = callLog.id;
    this.callType = callLog.callType;
    this.isHD = callLog.isHD;
    this.phoneNumber = callLog.phoneNumber;
    this.displayName = callLog.displayName;
    this.quickSearchKey = callLog.quickSearchKey;
    this.numberLocation = callLog.numberLocation;
    this.formattedNumber = callLog.formattedNumber;
    this.simType = callLog.simType;
    this.simId = callLog.simId;
    this.ids = [];
  }
}