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

import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { HiLog } from 'common/src/main/ets/util/HiLog';
import { CallLogService, CallLogRepository } from '../../../../../../feature/call';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { CallInfoGetParamsInCallback } from '../type/ContactParams';
import { ContactInfo } from '../bean/ContactInfo';
import {
  AllCallsGetActionData,
  CallHistorySearchGetActionData
} from '../../../../../../entry/src/main/ets/model/type';
import { MergeRule } from '../../../../../../feature/call/src/main/ets/CallLogService.ets';
import { CallLog } from '../../../../../../feature/call/src/main/ets/entity/CallLog';

const TAG = 'CallLogModel';

class CallLogModel {
  /**
   * Obtains and caches all 2000 call records.
   *
   * @param {string} DAHelper Database path
   * @param {string} mergeRule  Call Record Type
   * @param {Object} callBack Call log data
   */
  async getAllCalls(param: ContactInfo, actionData: AllCallsGetActionData, mergeRule: MergeRule, callBack: Function,
    context?: Context) {
    if (context) {
      CallLogRepository.getInstance().init(context);
    }
    HiLog.i(TAG, 'getAllCalls in:' + JSON.stringify(actionData));
    CallLogRepository.getInstance().findAll(actionData, (result: CallLog[]) => {
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [],
        missedList: [],
        callLogSearchList: [],
        timeStamp: ''
      };
      if (ArrayUtil.isEmpty(result)) {
        HiLog.i(TAG, 'getAllCalls logMessage callLog resultSet is empty!');
        callBack(resultData);
        return;
      }
      CallLogService.getInstance().init(context);
      CallLogService.getInstance().setMergeRule(mergeRule)
      resultData.callLogList = CallLogService.getInstance().mergeCallLogs(result);
      resultData.missedList = CallLogService.getInstance().mergeMissedCalls(result);
      let numberList = this.getNumberList(resultData);
      this.queryContactsName(numberList, resultData, (resultData: CallInfoGetParamsInCallback) => {
        callBack(resultData);
      }, context)
    });
  }

  getNumberList(resultData: CallInfoGetParamsInCallback) {
    let numberList: Set = new Set();
    for (let callLog of resultData.callLogList) {
      numberList.add(callLog.phoneNumber);
    }
    for (let missed of resultData.missedList) {
      numberList.add(missed.phoneNumber);
    }
    return Array.from(numberList);
  }

  queryContactsName(numberList: string[], resultData: CallInfoGetParamsInCallback, callback: Function,
    context?: Context) {
    if (numberList.length == 0) {
      HiLog.w(TAG, "queryContactsName, has no number");
      callback(resultData);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance().queryContactDataByNumber(numberList, (contacts: Record<string, string>[]) => {
      // Convert the result to Map, key: mobile number, value: name
      let numberMap = this.getNumberMap(contacts);
      this.buildName(resultData, numberMap);
      callback(resultData);
    });
  }

  getNumberMap(contacts: Record<string, string>[]) {
    let numberMap: Map<string, string> = new Map();
    for (let item of contacts) {
      if (!StringUtil.isEmpty(item.displayName)) {
        numberMap.set(item.detailInfo, item.displayName);
      }
    }
    return numberMap;
  }

  buildName(resultData: CallInfoGetParamsInCallback, numberMap: Map<string, string>) {
    // Match the result based on the mobile number.
    for (let callLog of resultData.callLogList) {
      if (numberMap.has(callLog.phoneNumber)) {
        callLog.displayName = numberMap.get(callLog.phoneNumber) as string;
      } else {
        callLog.displayName = "";
      }
    }
    for (let missed of resultData.missedList) {
      if (numberMap.has(missed.phoneNumber)) {
        missed.displayName = numberMap.get(missed.phoneNumber) as string;
      } else {
        missed.displayName = "";
      }
    }
  }

  async getCallHistorySearch(actionData: CallHistorySearchGetActionData, mergeRule: MergeRule, callBack: Function,
    context?: Context) {
    if (context) {
      CallLogRepository.getInstance().init(context);
    }
    CallLogRepository.getInstance().findSearch(actionData, (result?: CallLog[]) => {
      HiLog.i(TAG, 'getCallHistorySearch resultSet.rowCount :' + JSON.stringify(result?.length));
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [],
        missedList: [],
        callLogSearchList: [],
        timeStamp: ''
      };
      if (result == undefined || ArrayUtil.isEmpty(result)) {
        HiLog.i(TAG, 'getCallHistorySearch logMessage callLog resultSet is empty!');
        callBack(resultData);
        return;
      }
      CallLogService.getInstance().init(context);
      CallLogService.getInstance().setMergeRule(mergeRule)
      resultData.callLogList = CallLogService.getInstance().mergeCallLogs(result);
      resultData.missedList = CallLogService.getInstance().mergeMissedCalls(result);
      let numberList = this.getNumberList(resultData);
      this.queryContactsName(numberList, resultData, () => {
        callBack(resultData);
      }, context)
    })
  }
}

export default new CallLogModel();