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

import Calls from '../contract/Calls';

export default class CallLogBuilder {
  readonly id: number = -1;
  readonly phoneNumber: string;
  displayName: string;
  callDirection: number;
  voicemailUri: string;
  simId: number;
  simType: number;
  isHD: boolean;
  isRead: boolean;
  ringDuration: number;
  talkDuration: number;
  formattedNumber: string;
  quickSearchKey: string;
  numberType: number;
  numberTypeName: string;
  beginTime: number;
  endTime: number;
  answerState: number;
  createTime: number;
  numberLocation: string;
  photoId: number;
  photoUri: string;
  countryIsoCode: number;
  constructor(id: number, phoneNumber: string) {
    this.id = id;
    this.phoneNumber = phoneNumber;
  }

  static fromResultSet(resultSet: any): CallLogBuilder{
    let callLogBuilder = new CallLogBuilder(resultSet.getLong(resultSet.getColumnIndex(Calls.ID)),
    resultSet.getString(resultSet.getColumnIndex(Calls.PHONE_NUMBER)));
    callLogBuilder.setDisplayName(resultSet.getString(resultSet.getColumnIndex(Calls.DISPLAY_NAME)));
    callLogBuilder.setCallDirection(resultSet.getLong(resultSet.getColumnIndex(Calls.CALL_DIRECTION)));
    callLogBuilder.setDisplayName(resultSet.getString(resultSet.getColumnIndex(Calls.DISPLAY_NAME)));
    callLogBuilder.setVoicemailUri(resultSet.getString(resultSet.getColumnIndex(Calls.VOICEMAIL_URI)));
    callLogBuilder.setSimId(resultSet.getLong(resultSet.getColumnIndex(Calls.SIM_ID)));
    callLogBuilder.setSimType(resultSet.getLong(resultSet.getColumnIndex(Calls.SIM_TYPE)));
    callLogBuilder.setIsHD(resultSet.getLong(resultSet.getColumnIndex(Calls.IS_HD)) > 0 ? true : false);
    callLogBuilder.setIsRead(resultSet.getLong(resultSet.getColumnIndex(Calls.IS_READ)) > 0 ? true : false);
    callLogBuilder.setRingDuration(resultSet.getLong(resultSet.getColumnIndex(Calls.RING_DURATION)));
    callLogBuilder.setTalkDuration(resultSet.getLong(resultSet.getColumnIndex(Calls.TALK_DURATION)));
    callLogBuilder.setFormattedNumber(resultSet.getString(resultSet.getColumnIndex(Calls.FORMAT_NUMBER)));
    callLogBuilder.setQuickSearchKey(resultSet.getString(resultSet.getColumnIndex(Calls.QUICK_SEARCH_KEY)));
    callLogBuilder.setNumberType(resultSet.getLong(resultSet.getColumnIndex(Calls.NUMBER_TYPE)));
    callLogBuilder.setNumberTypeName(resultSet.getString(resultSet.getColumnIndex(Calls.NUMBER_TYPE_NAME)));
    callLogBuilder.setBeginTime(resultSet.getLong(resultSet.getColumnIndex(Calls.BEGIN_TIME)));
    callLogBuilder.setEndTime(resultSet.getLong(resultSet.getColumnIndex(Calls.END_TIME)));
    callLogBuilder.setAnswerState(resultSet.getLong(resultSet.getColumnIndex(Calls.ANSWER_STATE)));
    callLogBuilder.setCreateTime(resultSet.getLong(resultSet.getColumnIndex(Calls.CREATE_TIME)));
    callLogBuilder.setNumberLocation(resultSet.getString(resultSet.getColumnIndex(Calls.NUMBER_LOCATION)));
    callLogBuilder.setPhotoUri(resultSet.getString(resultSet.getColumnIndex(Calls.PHOTO_URI)));
    callLogBuilder.setPhotoId(resultSet.getLong(resultSet.getColumnIndex(Calls.PHOTO_ID)));
    callLogBuilder.setCountryIsoCode(resultSet.getLong(resultSet.getColumnIndex(Calls.COUNTRY_ISO_CODE)));
    return callLogBuilder;
  }

  setDisplayName(displayName: string) {
    this.displayName = displayName;
    return this;
  }

  setCallDirection(callDirection: number) {
    this.callDirection = callDirection;
    return this;
  }

  setVoicemailUri(voicemailUri: string) {
    this.voicemailUri = voicemailUri;
    return this;
  }

  setSimId(simId: number) {
    this.simId = simId;
    return this;
  }

  setSimType(simType: number) {
    this.simType = simType;
    return this;
  }

  setIsHD(isHD: boolean) {
    this.isHD = isHD;
    return this;
  }

  setIsRead(isRead: boolean) {
    this.isRead = isRead;
    return this;
  }

  setRingDuration(ringDuration: number) {
    this.ringDuration = ringDuration;
    return this;
  }

  setTalkDuration(talkDuration: number) {
    this.talkDuration = talkDuration;
    return this;
  }

  setFormattedNumber(formattedNumber: string) {
    this.formattedNumber = formattedNumber;
    return this;
  }

  setQuickSearchKey(quickSearchKey: string) {
    this.quickSearchKey = quickSearchKey;
    return this;
  }

  setNumberType(numberType: number) {
    this.numberType = numberType;
    return this;
  }

  setNumberTypeName(numberTypeName: string) {
    this.numberTypeName = numberTypeName;
    return this;
  }

  setBeginTime(beginTime: number) {
    this.beginTime = beginTime;
    return this;
  }

  setEndTime(endTime: number) {
    this.endTime = endTime;
    return this;
  }

  setAnswerState(answerState: number) {
    this.answerState = answerState;
    return this;
  }

  setCreateTime(createTime: number) {
    this.createTime = createTime;
    return this;
  }

  setNumberLocation(numberLocation: string) {
    this.numberLocation = numberLocation;
    return this;
  }

  setPhotoId(photoId: number) {
    this.photoId = photoId;
    return this;
  }

  setPhotoUri(photoUri: string) {
    this.photoUri = photoUri;
    return this;
  }

  setCountryIsoCode(countryIsoCode: number) {
    this.countryIsoCode = countryIsoCode;
    return this;
  }
}