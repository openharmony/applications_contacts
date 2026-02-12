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
import DataShareResultSet from '@ohos.data.DataShareResultSet';

import Calls from '../contract/Calls';
import HashMap from '@ohos.util.HashMap';

const TAG = 'CallLogBuilder ';
const ColumnIndexMap = new HashMap<string, number>();
const lineBreakRegExp = new RegExp('\r?\n|(?<!\n)\r', 'g');

function getColumnIndex(columnName: string, resultSet: DataShareResultSet): number {
  let index: number | null = ColumnIndexMap.get(columnName);
  if (index == null) {
    index = resultSet.getColumnIndex(columnName);
    ColumnIndexMap.set(columnName, index);
  }

  return index as number;
}

export default class CallLogBuilder {
  public readonly id: number = -1;
  public readonly phoneNumber: string;
  public displayName: string = '';
  public callDirection: number = -1;
  public voicemailUri: string = '';
  public simId: number = -1;
  public simType: number = -1;
  public isSatellite: number = -1;
  public isRead: boolean = false;
  public ringDuration: number = -1;
  public talkDuration: number = -1;
  public formattedNumber: string = '';
  public quickSearchKey: string = '';
  public numberType: number = -1;
  public numberTypeName: string = '';
  public beginTime: number = -1;
  public endTime: number = -1;
  public answerState: number = -1;
  public createTime: number = -1;
  public numberLocation: string = '';
  public photoId: number = -1;
  public photoUri: string = '';
  public countryIsoCode: number = -1;
  public features: number = -1;
  public markType: string = '';
  public markContent: string = '';
  public markDetails: string = '';
  public markSource: string = '';
  public isCloudMark: number = -1;
  public markCount: number = -1;
  public blockReason: number = -1;
  public detectDetails: string = '';
  public formatPhoneNumber: string = '';
  public celiaCallType: number = -1;
  public newCalling: number = -1;
  public isCnap: number = 0;
  public abstractProfile: string = '';
  public absStatus: string = '';
  public notesId: string = '';
  public absCode: string = '';
  public notesStatus: string = '';
  public startTime: number = -1;
  public abstractType: string = '';

  constructor(id: number, phoneNumber: string) {
    this.id = id;
    this.phoneNumber = phoneNumber;
  }

  static fromResultSet(resultSet: DataShareResultSet): CallLogBuilder {
    let callLogBuilder = new CallLogBuilder(resultSet.getLong(getColumnIndex(Calls.ID, resultSet)),
      resultSet.getString(getColumnIndex(Calls.PHONE_NUMBER, resultSet)));
    callLogBuilder.setDisplayName(resultSet.getString(getColumnIndex(Calls.DISPLAY_NAME, resultSet)));
    callLogBuilder.setCallDirection(resultSet.getLong(getColumnIndex(Calls.CALL_DIRECTION, resultSet)));
    callLogBuilder.setVoicemailUri(resultSet.getString(getColumnIndex(Calls.VOICEMAIL_URI, resultSet)));
    callLogBuilder.setSimId(resultSet.getLong(getColumnIndex(Calls.SIM_ID, resultSet)));
    callLogBuilder.setSimType(resultSet.getLong(getColumnIndex(Calls.SIM_TYPE, resultSet)));
    callLogBuilder.setIsSatellite(resultSet.getLong(getColumnIndex(Calls.IS_SATELLITE, resultSet)));
    callLogBuilder.setIsRead(resultSet.getLong(getColumnIndex(Calls.IS_READ, resultSet)) > 0 ? true : false);
    callLogBuilder.setRingDuration(resultSet.getLong(getColumnIndex(Calls.RING_DURATION, resultSet)));
    callLogBuilder.setTalkDuration(resultSet.getLong(getColumnIndex(Calls.TALK_DURATION, resultSet)));
    callLogBuilder.setFormattedNumber(resultSet.getString(getColumnIndex(Calls.FORMAT_NUMBER, resultSet)));
    callLogBuilder.setQuickSearchKey(resultSet.getString(getColumnIndex(Calls.QUICK_SEARCH_KEY, resultSet)));
    callLogBuilder.setNumberType(resultSet.getLong(getColumnIndex(Calls.NUMBER_TYPE, resultSet)));
    callLogBuilder.setNumberTypeName(resultSet.getString(getColumnIndex(Calls.NUMBER_TYPE_NAME, resultSet)));
    callLogBuilder.setBeginTime(resultSet.getLong(getColumnIndex(Calls.BEGIN_TIME, resultSet)));
    callLogBuilder.setEndTime(resultSet.getLong(getColumnIndex(Calls.END_TIME, resultSet)));
    callLogBuilder.setAnswerState(resultSet.getLong(getColumnIndex(Calls.ANSWER_STATE, resultSet)));
    callLogBuilder.setCreateTime(resultSet.getLong(getColumnIndex(Calls.CREATE_TIME, resultSet)));
    callLogBuilder.setNumberLocation(resultSet.getString(getColumnIndex(Calls.NUMBER_LOCATION, resultSet)));
    callLogBuilder.setPhotoUri(resultSet.getString(getColumnIndex(Calls.PHOTO_URI, resultSet)));
    callLogBuilder.setPhotoId(resultSet.getLong(getColumnIndex(Calls.PHOTO_ID, resultSet)));
    callLogBuilder.setCountryIsoCode(resultSet.getLong(getColumnIndex(Calls.COUNTRY_ISO_CODE, resultSet)));
    callLogBuilder.setFeatures(resultSet.getLong(getColumnIndex(Calls.FEATURES, resultSet)));
    callLogBuilder.setMarkType(resultSet.getString(getColumnIndex(Calls.MARK_TYPE, resultSet)));
    callLogBuilder.setMarkContent(resultSet.getString(getColumnIndex(Calls.MARK_CONTENT, resultSet)));
    callLogBuilder.setMarkDetails(resultSet.getString(getColumnIndex(Calls.MARK_DETAILS, resultSet)));
    callLogBuilder.setMarkSource(resultSet.getString(getColumnIndex(Calls.MARK_SOURCE, resultSet)));
    callLogBuilder.setIsCloudMark(resultSet.getLong(getColumnIndex(Calls.IS_CLOUD_MARK, resultSet)));
    callLogBuilder.setMarkCount(resultSet.getLong(getColumnIndex(Calls.MARK_COUNT, resultSet)));
    callLogBuilder.setBlockReason(resultSet.getLong(getColumnIndex(Calls.BLOCK_REASON, resultSet)));
    callLogBuilder.setDetectDetails(resultSet.getString(getColumnIndex(Calls.DETECT_DETAILS, resultSet)));
    callLogBuilder.setFormatPhoneNumber(resultSet.getString(getColumnIndex(Calls.FORMAT_PHONE_NUMBER, resultSet)));
    callLogBuilder.setCeliaCallType(resultSet.getLong(getColumnIndex(Calls.CELIA_CALL_TYPE, resultSet)));
    callLogBuilder.setNewCalling(resultSet.getLong(getColumnIndex(Calls.NEW_CALLING, resultSet)));
    callLogBuilder.setCnap(resultSet.getLong(getColumnIndex(Calls.IS_CNAP, resultSet)));
    callLogBuilder.setAbstractProfile(resultSet.getString(getColumnIndex(Calls.ABSTRACT_PROFILE, resultSet)));
    callLogBuilder.setAbsStatus(resultSet.getString(getColumnIndex(Calls.ABS_STATUS, resultSet)));
    callLogBuilder.setNotesId(resultSet.getString(getColumnIndex(Calls.NOTES_ID, resultSet)));
    callLogBuilder.setAbsCode(resultSet.getString(getColumnIndex(Calls.ABS_CODE, resultSet)));
    callLogBuilder.setNotesStatus(resultSet.getString(getColumnIndex(Calls.NOTES_STATUS, resultSet)));
    callLogBuilder.setStartTime(resultSet.getLong(getColumnIndex(Calls.START_TIME, resultSet)));
    callLogBuilder.setAbstractType(resultSet.getString(getColumnIndex(Calls.ABSTRACT_TYPE, resultSet)));
    return callLogBuilder;
  }

  setDisplayName(displayName: string) {
    // 去掉通话记录姓名中的换行符
    this.displayName = displayName.replace(lineBreakRegExp, '');
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

  setIsSatellite(isSatellite: number) {
    this.isSatellite = isSatellite;
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

  setFeatures(features: number) {
    this.features = features;
    return this;
  }

  setMarkType(markType: string) {
    this.markType = markType;
    return this;
  }

  setMarkContent(markContent: string) {
    this.markContent = markContent;
    return this;
  }

  setMarkDetails(markContent: string) {
    this.markDetails = markContent;
    return this;
  }

  setMarkSource(markContent: string) {
    this.markSource = markContent;
    return this;
  }

  setIsCloudMark(isCloudMark: number) {
    this.isCloudMark = isCloudMark;
    return this;
  }

  setMarkCount(markCount: number) {
    this.markCount = markCount;
    return this;
  }

  setBlockReason(blockReason: number) {
    this.blockReason = blockReason;
    return this;
  }

  setDetectDetails(detectDetails: string) {
    this.detectDetails = detectDetails;
    return this;
  }

  setFormatPhoneNumber(formatPhoneNumber: string) {
    this.formatPhoneNumber = formatPhoneNumber;
  }

  setCeliaCallType(celiaCallType: number) {
    this.celiaCallType = celiaCallType;
    return this;
  }

  setNewCalling(newCalling: number) {
    this.newCalling = newCalling;
    return this;
  }

  setCnap(cnapFlag: number) {
    this.isCnap = cnapFlag;
    return this;
  }

  setAbstractProfile(abstractProfile: string) {
    this.abstractProfile = abstractProfile;
    return this;
  }

  setAbsStatus(absStatus: string) {
    this.absStatus = absStatus;
    return this;
  }

  setNotesId(notesId: string) {
    this.notesId = notesId;
    return this;
  }

  setAbsCode(absCode: string) {
    this.absCode = absCode;
    return this;
  }

  setNotesStatus(notesStatus: string) {
    this.notesStatus = notesStatus;
    return this;
  }

  setStartTime(startTime: number) {
    this.startTime = startTime;
    return this;
  }

  setAbstractType(abstractType: string) {
    this.abstractType = abstractType;
    return this;
  }
}