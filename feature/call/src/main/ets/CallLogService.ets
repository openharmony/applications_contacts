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

import ICallLogService from './ICallLogService';
import { CallLog } from './entity/CallLog';
import { CallType } from './entity/CallLog';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import MergedCallLog from './entity/MergedCallLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { MergeRule } from './CallLogSetting';
import StringFormatUtil from '../../../../../entry/src/main/ets/util/StringFormatUtil';

export class CallLogService implements ICallLogService {
  private static instance: CallLogService;
  private mergeRule: MergeRule;
  private context: Context;

  private constructor() {
  }

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    this.context = ctx;
  }

  public static getInstance(): CallLogService {
    if (!CallLogService.instance) {
      CallLogService.instance = new CallLogService();
    }
    return CallLogService.instance;
  }

  setMergeRule(mergeRule: MergeRule) {
    this.mergeRule = mergeRule;
  }

  mergeCallLogs(callLogs: CallLog[]) {
    if (this.getMergeRule() === MergeRule.CONTACT) {
      return this.mergeByContact(callLogs);
    } else {
      return this.mergeByTime(callLogs);
    }
  }

  mergeMissedCalls(callLogs: CallLog[]) {
    let mergeRule = this.getMergeRule();
    let callLogList: CallLog[] = [];
    let missedList: CallLog[] = [];
    for (let callLog of callLogs) {
      callLogList.push(callLog);
      if (callLog.callType == CallType.MISSED ||
      callLog.callType == CallType.REJECTED) {
        //Filtering Missed Call Data
        missedList.push(callLog);
        let timeList = [];
        // Filtering by Contact Missed Calls and Redialing
        if (mergeRule === MergeRule.CONTACT) {
          for (let k = 0; k < missedList.length; k++) {
            let missedPhone = missedList[k].phoneNumber;
            for (let i = 0; i < callLogList.length; i++) {
              let allSpecialPhone = callLogList[i].phoneNumber;
              if (missedPhone == allSpecialPhone) {
                let timeNumber = callLogList[i].createTime;
                let obj = {
                  'id': i,
                  'timeObj': timeNumber,
                };
                timeList.push(obj);
                let max = timeList[0].timeObj;
                for (let j = 0; j < timeList.length; j++) {
                  if (timeList[j].timeObj > max) {
                    max = timeList[j].timeObj;
                    let n = timeList[j].id;
                    if (callLogList[n].callType == CallType.OUT) {
                      missedList.splice(k, 1);
                    }
                  } else {
                    let m = timeList[0].id;
                    if (callLogList[m].callType == CallType.OUT) {
                      missedList.splice(k, 1);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    if (mergeRule === MergeRule.CONTACT) {
      return this.mergeByContact(missedList);
    } else {
      return this.mergeByTime(missedList);
    }
  }

  /**
   * In the case of merging by time, the post-processing of the call record
   * service data is optimized based on the original call record data.
   * @param callLogList
   * @return
   */
  private mergeByTime(callLogList: CallLog[]) {
    let resultList = [];
    if (ArrayUtil.isEmpty(callLogList)) {
      return resultList;
    }
    // Call records are cached from the first record.
    let tempElement = new MergedCallLog(callLogList[0]);
    // Indicates the creation time of the latest record.
    // After call records are merged, the time is displayed.
    let tempCallTime = callLogList[0].createTime;
    // Type of the call record that retains the latest record.
    // This type is displayed after the call record is combined.
    let tempCallType = callLogList[0].callType;
    let num = 1;
    let ids = [];
    ids.push(callLogList[0].id);
    for (let i = 1; i < callLogList.length; i++) {
      let element = callLogList[i];
      // Whether the cached field needs to be combined with the current field
      if (this.callLogMergeCheck(tempElement, element)) {
        num++;
        // Put the latest record ID into the merged array.
        ids.push(element.id);
      } else {
        //If the latest data is inconsistent with the cached data,
        // replace the num and ids data in the cached data and
        // save the cached data to the result set.
        tempElement.count = num;
        tempElement.ids = ids;
        // Displays the creation time of the latest saved record.
        tempElement.createTime = this.formatTime(tempCallTime);
        tempElement.callType = tempCallType;
        resultList.push(tempElement);
        /* Reset num and ids to the latest count and record,
        and reset tempCallTime to the latest creation time of the next record.*/
        num = 1;
        ids = [];
        tempCallTime = element.createTime;
        tempCallType = element.callType;
        ids.push(element.id);
      }
      tempElement = new MergedCallLog(element);
    }
    /* Put the last piece of cached data into the result set*/
    if (tempElement != null) {
      tempElement.count = num;
      tempElement.ids = ids;
      tempElement.createTime = this.formatTime(tempCallTime);
      tempElement.callType = tempCallType;
      resultList.push(tempElement);
    }
    return resultList;
  }

  /**
   * In the case of merging by contact, the post-processing
   * of the call record service data is optimized based on the original call record data.
   *
   * @param {Array} callLogList
   * @return {Array} callLogList
   */
  private mergeByContact(callLogs: CallLog[]) {
    let resultList = [];
    if (ArrayUtil.isEmpty(callLogs)) {
      return resultList;
    }
    let contactTempMap = new Map();
    let phoneNumberMap = new Map();
    for (let i = 0; i < callLogs.length; i++) {
      let element = new MergedCallLog(callLogs[i]);
      element.createTime = this.formatTime(callLogs[i].createTime);
      // In the case of merging by contact, the combined record entry is fixed to 1.
      element.count = 1;
      // In the case of merging by contact, the IDs of
      // the merging record are fixed to the ID of the record.
      element.ids = [callLogs[i].id];
      // Call records without contacts are combined by phone number.
      if (StringUtil.isEmpty(element.quickSearchKey)) {
        if (!phoneNumberMap.has(element.phoneNumber)) {
          resultList.push(element);
          phoneNumberMap.set(element.phoneNumber, callLogs[i].phoneNumber);
        }
      } else { // Call records with contacts are merged by contact.
        let isContactKey = contactTempMap.has(element.quickSearchKey);
        if (!isContactKey) {
          resultList.push(element);
          contactTempMap.set(element.quickSearchKey, callLogs[i].quickSearchKey);
        }
      }
    }
    return resultList;
  }

  /**
   * Obtain the call time.
   *
   * @param date Call record creation timestamp
   * @return {object} Talk time
   */
  private formatTime(date) {
    let result;
    // If the value is not a number, the value is not parsed.
    if (isNaN(date)) {
      return date;
    }
    let timestamp = parseInt(date) * 1000;
    let callTime = new Date(timestamp);
    let now = new Date();
    if (callTime.getTime() > now.getTime()) {
      result = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else if (callTime.getFullYear() == now.getFullYear()) {
      if (callTime.getMonth() == now.getMonth()) {
        // Same month of the same year
        let timeDiff = parseInt(((now.getTime() - callTime.getTime()) / 60000).toString());
        let dayDiff = now.getDate() - callTime.getDate();
        let hour = callTime.getHours().toString();
        let minutes = callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes().toString();
        if (dayDiff == 0) {
          // 同天
          if (timeDiff == 0) {
            result = $r("app.string.justNow");
          } else if (timeDiff < 60) {
            result = $r("app.string.minutesAgo", timeDiff);
          } else {
            let timeDetail: any = {};
            if (parseInt(StringFormatUtil.judgeSysTime(this.context)) == 12) {
              timeDetail.time = StringFormatUtil.getDayMessage(hour, minutes);
            } else {
              timeDetail.time = $r("app.string.time_normal", hour, minutes);
            }
            result = timeDetail.time
          }
        } else if (dayDiff == 1) {
          result = $r("app.string.yesterday");
        } else {
          result = (callTime.getMonth() + 1) + '/' + callTime.getDate(); // 'MM/dd'
        }
      } else {
        result = (callTime.getMonth() + 1) + '/' + callTime.getDate();
      }
    } else {
      // 'yyyy/MM/dd'
      result = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    }
    return result;
  }

  /**
   * Checks whether two call records need to be combined when the call records are combined by time.
   * If the call records need to be combined, true is returned. Otherwise, false is returned.
   *
   * @param oldElement Call records before merging
   * @param newElement Combined call records
   * @return
   */
  private callLogMergeCheck(oldElement: MergedCallLog, newElement: CallLog) {
    /* Merge Rules:
       1. The phone numbers are combined only when the phone numbers are the same.
        2. If the number is the same and the call type is 1, 2, 3, or 5,
        the call is combined. Types 1, 2, 3, and 5 are not combined.
    */
    if (oldElement.phoneNumber.trim() == newElement.phoneNumber.trim()) {
      if (oldElement.callType == CallType.IN || oldElement.callType == CallType.OUT) {
        if (newElement.callType == CallType.IN || newElement.callType == CallType.OUT) {
          return true;
        }
        return false;
      }
      if (newElement.callType == CallType.MISSED || newElement.callType == CallType.REJECTED) {
        return true;
      }
    }
    return false;
  }

  private getMergeRule() {
    return this.mergeRule;
  }
}