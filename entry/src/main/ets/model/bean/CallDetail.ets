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
import { CallType } from '../../../../../../feature/call';
import { RecorderLog } from '../type';
import { DeviceUtils } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/DeviceUtils';
import { CallTypeMeetime } from '../../../../../../feature/call/src/main/ets/contract/MeetimeCalls';
import { CallBean } from './CallBean';

export default class CallDetail extends CallBean {
  public callTypeEnum: CallType | CallTypeMeetime;
  public mediaType: number = DeviceUtils.NATIVE_CALL;
  public simId: number;
  public isSatellite: number;
  public ringTime: number;
  public talkTime: Resource | string | null;
  public talkDuration: number;
  public dateDetail: Resource | string | undefined;
  public timeDetail: Resource | string | undefined;
  // 通话类型，运营商通话，畅连聊天，畅连语音等
  public features: number
  public recordLogList?: RecorderLog[] | undefined;
  public celiaCallType: number = -1;
  public newCalling: number = -1;
  // 一句话摘要（摘要内容，摘要摘要状态，备忘录id，备忘录状态，通话结束时间，摘要生成时间，摘要类型）
  public abstractProfile: string = '';
  public absStatus: string = '';
  public notesId: string = '';
  public absCode: string = '';
  public notesStatus: string = '';
  public endTime: number = -1;
  public startTime: number = -1;
  public abstractType: string = '';

  constructor(id: string, phone: string, name: string, callTime: string, beginTime: string,
              callType: CallType | CallTypeMeetime,
              callTag: string,
              simType: string,
              simId: number,
              isSatellite: number,
              ringTime: number,
              formatNumber: string,
              talkTime: Resource | string | null,
              talkDuration: number,
              dateDetail: Resource | string | undefined,
              timeDetail: Resource | string | undefined,
              features: number,
              celiaCallType:number,
              newCalling:number,
	      abstractProfile:string,
              absStatus:string,
              notesId:string,
              absCode:string,
              notesStatus:string,
              endTime:number,
              startTime:number,
              abstractType:string) {
    super(id, phone)
    this.name = name;
    this.callTime = callTime;
    this.beginTime = beginTime;
    this.callTypeEnum = callType;
    this.callTag = callTag;
    this.simType = simType;
    this.simId = simId;
    this.isSatellite = isSatellite;
    this.ringTime = ringTime;
    this.formatNumber = formatNumber;
    this.talkTime = talkTime;
    this.talkDuration = talkDuration;
    this.dateDetail = dateDetail;
    this.timeDetail = timeDetail;
    this.features = features;
    this.celiaCallType = celiaCallType;
    this.newCalling = newCalling;
    this.abstractProfile = abstractProfile;
    this.absStatus = absStatus;
    this.notesId = notesId;
    this.absCode = absCode;
    this.notesStatus = notesStatus;
    this.endTime = endTime;
    this.startTime = startTime;
    this.abstractType = abstractType;
  }
}