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
import CallLog from './entity/CallLog';
import {CallType} from './entity/CallLog';
import ArrayUtil from '../util/ArrayUtil';
import MergedCallLog from './entity/MergedCallLog';
import StringUtil from '../util/StringUtil';


/**
 * 账户类型服务类，账户类型持有联系人详情如何展示等账号特征信息
 */
export default class CallLogService implements ICallLogService {
  private static instance: CallLogService;

  private constructor() {
  }

  public static getInstance(): CallLogService {
    if (!CallLogService.instance) {
      CallLogService.instance = new CallLogService()
    }
    return CallLogService.instance
  }

  /**
   * 按时间合并情况下，在原通话记录数据基础上完善通话记录业务数据后处理
   *
   * @param callLogList 通话记录
   * @return
   */
  mergeByTime(callLogList: CallLog[]) {
    var resultList = [];
    if (ArrayUtil.isEmpty(callLogList)) {
      return resultList;
    }
    let tempElement = new MergedCallLog(callLogList[0]); // 从第一条记录开始，缓存通话记录
    var tempCallTime = callLogList[0].createTime; // 保留最近一条记录的创建时间，在通话记录合并后，显示该时间。
    var tempCallType = callLogList[0].callType; // 保留最近一条记录的通话记录类型，在通话记录合并后，显示该类型。
    var num = 1;
    var ids = [];
    ids.push(callLogList[0].id);
    for (var i = 1; i < callLogList.length; i++) {
      var element = callLogList[i];
      if (this.callLogMergeCheck(tempElement, element)) { // 缓存字段与当前字段校验是否需要合并
        num++;
        ids.push(element.id); // 将最新记录id放入合并数组
      } else {
        /* 最新数据和缓存不一致，则替换缓存数据的num及ids数据，并将缓存的数据记录放入结果集*/
        tempElement.count = num;
        tempElement.ids = ids;
        tempElement.createTime = this.formatTime(tempCallTime); // 显示已保存的最近一条记录的创建时间
        tempElement.callType = tempCallType;
        resultList.push(tempElement);
        /* 重置num及ids为最新计数及记录 ，重置tempCallTime为下条记录的最新创建时间*/
        num = 1;
        ids = [];
        tempCallTime = element.createTime;
        tempCallType = element.callType;
        ids.push(element.id);
      }
      tempElement = new MergedCallLog(element);
    }
    /* 将最后一条缓存数据放入结果集*/
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
   * 按联系人合并的情况下，在原通话记录数据基础上完善通话记录业务数据后处理
   *
   * @param {Array} callLogList 通话记录
   * @return {Array} 通话记录
   */
  mergeByContact(callLogs: CallLog[]) {
    var resultList = [];
    if (ArrayUtil.isEmpty(callLogs)) {
      return resultList;
    }
    var contactTempMap = new Map();
    var phoneNumberMap = new Map();
    for (var i = 0; i < callLogs.length; i++) {
      var element = new MergedCallLog(callLogs[i]);
      element.createTime = this.formatTime(callLogs[i].createTime);
      element.count = 1; // 按联系人合并的情况下，合并记录条目固定为1
      element.ids = [callLogs[i].id]; // 按联系人合并的情况下，合并记录ids固定为本身id
      if (StringUtil.isEmpty(element.quickSearchKey)) { // 没有联系人的通话记录，按照电话号码合并
        if (!phoneNumberMap.has(element.phoneNumber)) {
          resultList.push(element);
          phoneNumberMap.set(element.phoneNumber, callLogs[i].phoneNumber);
        }
      } else { // 有联系人的通话记录，按照联系人合并
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
   * 获取通话时间
   *
   * @param date 通话记录创建时间戳
   * @return {object} 通话时间
   */
  formatTime(date) {
    let result = "";
    if (isNaN(date)) { // 非数字时，不进行解析
      return date;
    }
    var timestamp = parseInt(date) * 1000;
    // 通话时间
    let callTime = new Date(timestamp);
    // 当前时间
    let now = new Date();
    if (callTime.getTime() > now.getTime()) {
      result = callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate();
    } else if (callTime.getFullYear() == now.getFullYear()) {
      // 同年
      if (callTime.getMonth() == now.getMonth()) {
        // 同年同月
        let timeDiff = parseInt(((now.getTime() - callTime.getTime()) / 60000).toString());
        let dayDiff = now.getDate() - callTime.getDate();
        if (dayDiff == 0) {
          // 同天
          if (timeDiff == 0) {
            result = '刚刚';
          } else if (timeDiff < 60) {
            result = timeDiff + '分钟前';
          } else {
            // 'hh:mm'
            result = callTime.getHours()
            + ':' + (callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes());
          }
        } else if (dayDiff == 1) {
          // 昨天
          result = '昨天';
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
   * 按时间合并情况下，校验两条通话记录是否需要合并,需要合并返回true，否则返回false
   *
   * @param oldElement 合并前通话记录
   * @param newElement 合并后通话记录
   * @return
   */
  private callLogMergeCheck(oldElement: MergedCallLog, newElement: CallLog) {
    /* 合并规则：
       1.电话号码相同前提下才会合并。
       2.号码相同的前提下，呼叫类型为1,2或3,5则合并。1,2和3,5类型不合并。
    */
    if (oldElement.phoneNumber.trim() == newElement.phoneNumber.trim()) { // 电话号码相同
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
}