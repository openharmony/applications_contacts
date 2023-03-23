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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { CallLogService, CallLogRepository } from '../../../../../../feature/call';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

const TAG = 'CallLogModel';

export default {
  /**
   * Obtains and caches all 2000 call records.
   *
   * @param {string} DAHelper Database path
   * @param {string} mergeRule  Call Record Type
   * @param {Object} callBack Call log data
   */
  getAllCalls: async function (actionData, mergeRule, callBack, context?) {
    if (context) {
      CallLogRepository.getInstance().init(context);
    }
    HiLog.i(TAG, 'getAllCalls in:' + JSON.stringify(actionData));
    CallLogRepository.getInstance().findAll(actionData, result => {
      let resultData = {
        callLogList: [], missedList: []
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
      this.queryContactsName(numberList, resultData, resultData => {
        callBack(resultData);
      }, context)
    });
  },

  getNumberList(resultData) {
    let numberList = new Set();
    for (let callLog of resultData.callLogList) {
      numberList.add(callLog.phoneNumber);
    }
    for (let missed of resultData.missedList) {
      numberList.add(missed.phoneNumber);
    }
    return Array.from(numberList);
  },

  queryContactsName(numberList, resultData, callback, context?) {
    if (numberList.length == 0) {
      HiLog.w(TAG, "queryContactsName, has no number");
      callback(resultData);
      return;
    }
    ContactRepository.getInstance().init(context);
    ContactRepository.getInstance().queryContactDataByNumber(numberList, contacts => {
      // Convert the result to Map, key: mobile number, value: name
      let numberMap = this.getNumberMap(contacts);
      this.buildName(resultData, numberMap);
      callback(resultData);
    });
  },

  getNumberMap(contacts) {
    let numberMap = new Map();
    for (let item of contacts) {
      if (!StringUtil.isEmpty(item.displayName)) {
        numberMap.set(item.detailInfo, item.displayName);
      }
    }
    return numberMap;
  },

  buildName(resultData, numberMap) {
    // Match the result based on the mobile number.
    for (let callLog of resultData.callLogList) {
      if (numberMap.has(callLog.phoneNumber)) {
        callLog.displayName = numberMap.get(callLog.phoneNumber);
      } else {
        callLog.displayName = "";
      }
    }
    for (let missed of resultData.missedList) {
      if (numberMap.has(missed.phoneNumber)) {
        missed.displayName = numberMap.get(missed.phoneNumber);
      } else {
        missed.displayName = "";
      }
    }
  }
}