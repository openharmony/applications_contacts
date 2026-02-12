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
import { PhoneNum } from '../entity/CallLogTemp';
@Observed
export default class MergedCallLog {
  public id: number;
  public createTime: string | Resource;
  public createInterceptionTime: string;
  public createInterceptionTimeType: string;
  public count: number;
  public ids: number[];
  public isSatellite: number;
  public callType: number;
  public phoneNumber: string;
  public displayName: string;
  public quickSearchKey: string;
  public numberLocation: string;
  public formattedNumber: string;
  public simType: number;
  public simId: number;
  public portraitColor?: Resource;
  public suffix?: string;
  public checked?: boolean;
  public contactName: string = '';
  public name: string = '';
  public phoneNumbers: Array<PhoneNum> = [];
  public entityId: string = '';
  public features?: number;
  public organization: string = '';
  public createTimeSource?: number;
  public markType: string = '';
  public markContent: string = '';
  public markDetails: string = '';
  public markSource: string = '';
  public isCloudMark: number = -1;
  public markCount: number = -1;
  public blockReason: number = -1;
  public detectDetails: string = '';
  public offsetY: number = 0;
  public formatPhoneNumber: string;
  public celiaCallType: number = -1;
  public createTimeAccessibilityText: string = '';
  public isCnap: number = 0;
  public newCalling: number = -1;
  public absCode: string = '0';
  public noteState: string = '-1';

  constructor(callLog: CallLog) {
    this.id = callLog.id;
    this.callType = callLog.callType;
    this.isSatellite = callLog.isSatellite
    this.phoneNumber = callLog.phoneNumber;
    this.displayName = callLog.displayName;
    this.quickSearchKey = callLog.quickSearchKey;
    this.numberLocation = callLog.numberLocation;
    this.formattedNumber = callLog.formattedNumber;
    this.simType = callLog.simType;
    this.simId = callLog.simId;
    this.features = callLog.features;
    this.ids = [];
    this.createTime = '';
    this.createInterceptionTime = '';
    this.createInterceptionTimeType = '';
    this.count = 0;
    this.markType = callLog.markType;
    this.markContent = callLog.markContent;
    this.markDetails = callLog.markDetails;
    this.markSource = callLog.markSource;
    this.isCloudMark = callLog.isCloudMark;
    this.markCount = callLog.markCount;
    this.blockReason = callLog.blockReason;
    this.detectDetails = callLog.detectDetails;
    this.formatPhoneNumber = callLog.formatPhoneNumber;
    this.celiaCallType = callLog.celiaCallType;
    this.isCnap = callLog.isCnap;
    this.newCalling = callLog.newCalling;
    this.absCode = callLog.absCode;
    this.noteState = callLog.notesStatus;
  }
}