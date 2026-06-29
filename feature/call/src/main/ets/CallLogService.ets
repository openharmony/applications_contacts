/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ICallLogService from './ICallLogService';
import { CallLog, CallType } from './entity/CallLog';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import MergedCallLog from './entity/MergedCallLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { MergeRule } from './CallLogSetting';
import StringFormatUtil from '../../../../../entry/src/main/ets/util/StringFormatUtil';
import { common } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from 'common/src/main/ets/util/ContactsGlobalThisHelper';
import { settings } from '@kit.BasicServicesKit';
import { HiLog } from 'common/src/main/ets/util/HiLog';
import { ResourceUtil } from '../../../../../entry/src/main/ets/util/ResourceUtil';

const TAG = 'CallLogService';
const MILLISECONDS_ONE_DAY = 24 * 60 * 60 * 1000;
const MILLISECONDS_ONE_SECOND = 1000;
const DAY_OF_ONE_WEEK = 7;

export class CallLogService implements ICallLogService {
  private static instance: CallLogService;
  public mergeRule?: MergeRule;
  public context?: Context;
  public preCallLog: CallLog[] = [];

  constructor() {
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
    HiLog.i(TAG, `setMergeRule mergeRule: ${mergeRule}`);
    this.mergeRule = mergeRule;
  }

  mergeCallLogs(callLogs: CallLog[]): MergedCallLog[] {
    HiLog.i(TAG, `mergeCallLogs start`);
    if (this.mergeRule === MergeRule.CONTACT) {
      return this.mergeByContact(callLogs);
    } else {
      return this.mergeByTime(callLogs);
    }
  }

  mergeMissedCalls(callLogs: CallLog[]): MergedCallLog[] {
    HiLog.i(TAG, `mergeMissedCalls start`);
    let missedList: CallLog[] = [];
    for (let callLog of callLogs) {
      if (callLog.callType == CallType.MISSED ||
        callLog.callType == CallType.REJECTED) {
        missedList.push(callLog);
      }
    }
    return this.mergeCallLogs(missedList);
  }

  mergeByContact(callLogList: CallLog[]): MergedCallLog[] {
    HiLog.i(TAG, `mergeByContact start`);
    let resultList: MergedCallLog[] = [];
    if (ArrayUtil.isEmpty(callLogList)) {
      return resultList;
    }
    let numberCallLogMap: Map<string, MergedCallLog> = new Map();
    while (callLogList.length > 0) {
      let callLog: CallLog = callLogList.shift() as CallLog;
      let formatNumber = this.getFormatNumber(callLog);
      if (numberCallLogMap.has(formatNumber)) {
        if(callLog.absCode !== '-1') {
          let celiaCallLog = numberCallLogMap.get(formatNumber)
          if( celiaCallLog === undefined) {
          } else {
            celiaCallLog.absCode = '2';
          }
        }
        numberCallLogMap.get(formatNumber)?.ids.push(callLog.id);
      } else {
        let mergedCallLog = new MergedCallLog(callLog);
        mergedCallLog.ids = [callLog.id]
        mergedCallLog.createTime = this.formatTime(callLog.showTime) as string;
        mergedCallLog.callType = callLog.callType;
        mergedCallLog.createTimeSource = callLog.showTime;
        mergedCallLog.count = 1;
        numberCallLogMap.set(formatNumber, mergedCallLog);
      }
    }
    numberCallLogMap.forEach((mergedCallLog: MergedCallLog) => {
      resultList.push(mergedCallLog);
    })
    return resultList;
  }

  // 按时间合并通话记录
  mergeByTime(callLogList: CallLog[]): MergedCallLog[] {
    HiLog.i(TAG, `mergeByTime start`);
    let resultList: MergedCallLog[] = [];
    if (ArrayUtil.isEmpty(callLogList)) {
      return resultList;
    }
    let mergedCallLog: MergedCallLog | null = null;
    while (callLogList.length > 0) {
      let callLog: CallLog = callLogList.shift() as CallLog;
      if (this.callLogMergeCheck(mergedCallLog, callLog)) {
        if (callLog.absCode !== '-1') {
          if (mergedCallLog === null) {
          } else {
            mergedCallLog.absCode = '2';
          }
        }
        // 通话记录能合并
        mergedCallLog?.ids.push(callLog.id);
      } else {
        // 通话记录不能合并
        if (mergedCallLog) {
          mergedCallLog.count = mergedCallLog.ids.length;
          resultList.push(mergedCallLog);
        }
        mergedCallLog = new MergedCallLog(callLog);
        mergedCallLog.ids = [callLog.id]
        mergedCallLog.createTime = this.formatTime(callLog.showTime) as string;
        mergedCallLog.callType = callLog.callType;
        mergedCallLog.createTimeSource = callLog.showTime;
      }
    }
    if (mergedCallLog) {
      mergedCallLog.count = mergedCallLog.ids.length;
      resultList.push(mergedCallLog);
    }
    return resultList;
  }

  // 通话记录合并规则检查
  callLogMergeCheck(oldElement: MergedCallLog | null, newElement: CallLog): boolean {
    if (oldElement === null) {
      return false;
    }
    if (this.mergeRule === MergeRule.CONTACT) {
      return this.callLogContactMergeCheck(oldElement, newElement);
    } else {
      return this.callLogTimeMergeCheck(oldElement, newElement);
    }
  }

  // 按联系人合并通话记录合并规则检查
  callLogContactMergeCheck(oldElement: MergedCallLog, newElement: CallLog): boolean {
    if (this.getFormatNumber(oldElement) == this.getFormatNumber(newElement)) {
      return true;
    } else {
      return false;
    }
  }

  // 按时间合并通话记录合并规则检查
  callLogTimeMergeCheck(oldElement: MergedCallLog, newElement: CallLog): boolean {
    /* Merge Rules:
       1. The phone numbers are combined only when the phone numbers are the same.
        2. If the number is the same and the call type is 1, 2, 3, or 5,
        the call is combined. Types 1, 2, 3, and 5 are not combined.
    */
    if (this.getFormatNumber(oldElement) == this.getFormatNumber(newElement)) {
      if (oldElement.callType == CallType.IN || oldElement.callType == CallType.OUT ||
        oldElement.callType == CallType.OTHER) {
        if (newElement.callType == CallType.IN || newElement.callType == CallType.OUT ||
          newElement.callType == CallType.OTHER) {
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

  getFormatNumber(callLog: MergedCallLog | CallLog): string {
    let phoneNumber =
      !StringUtil.isEmpty(callLog.formatPhoneNumber) ? callLog.formatPhoneNumber : callLog.phoneNumber;
    return phoneNumber
  }

  /**
   * 显示拦截通话记录的来电时间以及所在分组
   * @param callLogList
   * @return resultList
   */
  displayInterceptionCallsTime(callLogList: CallLog[]): MergedCallLog[] {
    let resultList: MergedCallLog[] = [];
    if (ArrayUtil.isEmpty(callLogList)) {
      return resultList;
    }
    // Call records are cached from the first record.
    let now = new Date();
    let todayTime: number = new Date(now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate()).getTime();
    let timeFormat = settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext() as Context, settings.date.TIME_FORMAT, '12');
    for (let i = 0; i < callLogList.length; i++) {
      let tempElement = new MergedCallLog(callLogList[i]);
      tempElement.createTime = this.formatInterceptionCallsTime(callLogList[i].createTime,
        todayTime, Number.parseInt(timeFormat));
      tempElement.createTimeSource = callLogList[i].createTime;
      tempElement.createInterceptionTime = this.createInterceptionGroupTime(callLogList[i].createTime, todayTime);
      tempElement.createInterceptionTimeType =
        this.createInterceptionGroupTimeType(callLogList[i].createTime, todayTime);
      resultList.push(tempElement)
    }
    return resultList;
  }

  /**
   * Obtain the interception call time, 格式化拦截通话记录创建时间，小时：分钟.
   *
   * @param date Interception Call record creation timestamp
   * @return {object} Talk time
   */
  formatInterceptionCallsTime(date: number, todayTime: number, systime: number): string | Resource {
    if (Number.isNaN(date)) {
      return JSON.stringify(date);
    }
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let timestamp = date * 1000;
    let callTime = new Date(timestamp);
    let year = callTime.getFullYear();
    let mounth = callTime.getMonth() + 1;
    let day = callTime.getDate();
    let hour = callTime.getHours();
    let minutes = callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes().toString();
    let timeDetail: string | Resource = '';
    timeDetail = StringFormatUtil.getDayMessage(year, mounth, day, hour, minutes)
    if (todayTime - callTime.getTime() > 7 * MILLISECONDS_ONE_DAY) {
      timeDetail = callTime.getFullYear() == new Date().getFullYear() ?
        (callTime.getMonth() + 1) + '/' + callTime.getDate() :
        callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    }
    let res = timeDetail
    return res;
  }

  /**
   * Obtain the call time.
   *
   * @param date Call record creation timestamp
   * @param now current date - default value now()
   * @returns
   * @return {object} Talk time
   */
  formatTime(date: number, now: Date = new Date()) {
    let result: string | Resource = '';
    // If the value is not a number, the value is not parsed.
    if (Number.isNaN(date)) {
      return date;
    }
    let timestamp = date * 1000;
    let callTime = new Date(timestamp);
    if (callTime.getTime() > now.getTime()) {
      result = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else if (callTime.getFullYear() == now.getFullYear()) {
      if (callTime.getMonth() == now.getMonth()) {
        // Same month of the same year
        let timeDiff = Number.parseInt(((now.getTime() - callTime.getTime()) / 60000).toString());
        let dayDiff = now.getDate() - callTime.getDate();
        let year = callTime.getFullYear();
        let mounth = callTime.getMonth() + 1;
        let day = callTime.getDate();
        let hour = callTime.getHours();
        let minutes = callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes().toString();
        if (dayDiff == 0) {
          // 同天
          if (timeDiff == 0) {
            result = $r('app.string.justNow');
          } else if (timeDiff < 60) {
            result = ResourceUtil.getPluralStringByResource($r('app.plural.minutesAgo'), timeDiff);
          } else {
            let timeDetail: Record<string, Resource | string | undefined> = {};
            timeDetail.time = StringFormatUtil.getDayMessage(year, mounth, day, hour, minutes);
            result = timeDetail.time
          }
        } else if (dayDiff == 1) {
          result = $r('app.string.yesterday');
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
   * 创建拦截通话记录分组时间，今天、昨天、5具体日期、七天前
   *
   * @param date Interception Call record creation timestamp
   * @param todayTime
   * @param nowTime
   * @return {object} group time
   */
  createInterceptionGroupTime(date: number, todayTime: number, now: Date = new Date()): string {
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let result: string | Resource = '';
    let resultStr: string = '';
    // If the value is not a number, the value is not parsed.
    if (Number.isNaN(date)) {
      return JSON.stringify(date);
    }
    let timestamp = date * 1000;
    let callTime = new Date(timestamp);
    if (callTime.getTime() > now.getTime()) {
      resultStr = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else if (callTime.getTime() - todayTime >= 0) {
      //同天
      result = $r('app.string.today');
      resultStr = context.resourceManager.getStringSync(result.id);
    } else if (todayTime - callTime.getTime() <= MILLISECONDS_ONE_DAY) {
      result = $r('app.string.yesterday');
      resultStr = context.resourceManager.getStringSync(result.id);
    } else if (todayTime - callTime.getTime() > MILLISECONDS_ONE_DAY &&
      todayTime - callTime.getTime() <= 7 * MILLISECONDS_ONE_DAY) {
      resultStr = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else {
      result = $r('app.string.one_week_ago');
      resultStr = context.resourceManager.getStringSync(result.id);
    }
    return resultStr;
  }

  /**
   * create Interception GroupTime Type，today yesterday one_week_ago
   *
   * @param date Interception Call record creation timestamp
   * @param todayTime
   * @param nowTime
   * @return {object} group time
   */
  createInterceptionGroupTimeType(date: number, todayTime: number, now: Date = new Date()): string {
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let resultStr: string = '';
    // If the value is not a number, the value is not parsed.
    if (Number.isNaN(date)) {
      return JSON.stringify(date);
    }
    let timestamp = date * MILLISECONDS_ONE_SECOND;
    let callTime = new Date(timestamp);
    if (callTime.getTime() > now.getTime()) {
      // 通话记录的创建时间比当前时间大，显示具体时间
      resultStr = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else if (callTime.getTime() - todayTime >= 0) {
      // 通话记录产生在当天
      resultStr = '0';
    } else if (todayTime - callTime.getTime() <= MILLISECONDS_ONE_DAY) {
      // 通话记录产生在前一天
      resultStr = '1';
    } else if (todayTime - callTime.getTime() > MILLISECONDS_ONE_DAY &&
      todayTime - callTime.getTime() <= DAY_OF_ONE_WEEK * MILLISECONDS_ONE_DAY) {
      resultStr = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else {
      // 通话记录产生在七天前
      resultStr = '2';
    }
    return resultStr;
  }

  getMergeRule() {
    return this.mergeRule;
  }

  updatePreCallLog(callLog: CallLog[]) {
    if (callLog.length > 0) {
      // 最后一项
      this.preCallLog = [callLog.pop() as CallLog];
      let tempElement = new MergedCallLog(this.preCallLog[0]);
      // 从后往前遍历
      while (callLog.length > 0) {
        let tempCallLog = callLog.pop() as CallLog;
        // 如果可以和最后一项合并
        if (this.callLogMergeCheck(tempElement, tempCallLog)) {
          // 同一批的存放在preCallLog
          this.preCallLog.unshift(tempCallLog);
        } else {
          callLog.push(tempCallLog);
          break;
        }
      }
    }
  }
}

interface objInterface {
  id: number;
  timeObj: number;
}