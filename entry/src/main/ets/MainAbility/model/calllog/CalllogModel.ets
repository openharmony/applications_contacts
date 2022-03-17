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

import featureAbility from '@ohos.ability.featureAbility';
import ArrayUtil from '../../util/ArrayUtil';
import HiLog from '../../util/HiLog';
import CallLog from '../../call/entity/CallLog';
import {CallType} from '../../call/entity/CallLog';
import CallLogRepository from '../../call/repo/CallLogRepository';
import CallLogService from '../../call/CallLogService';
import CallLogBuilder from '../../call/entity/CallLogBuilder';

featureAbility:featureAbility;
const TAG = 'calllogModel';

export default {
  // 插入一条测试通话记录
  testInsertCallLog: function () {
    let phoneNumbers = ['18071712413', '18772362656', '13720249349', '18161845409'];
    let  formatPhoneNumbers = ['180 7171 2413', '187 7236 2656', '137 2024 9349', '181 6184 5409'];
    let  contactName = ['李四', 'Tom', '铃南', ''];
    let  contactId = ['1', '2', '3', ''];
    let  callTypes = [0, 1];
    let  answerStatus = [0, 1, 2];
    let  numIndex = Math.floor(Math.random() * 4);
    let  typeIndex = Math.floor(Math.random() * 2);
    let  answerindex = Math.floor(Math.random() * 3);
    let  now = new Date();
    let  timestamp = now.getTime();

    let callLogBuilder = new CallLogBuilder(0, phoneNumbers[numIndex]);
    callLogBuilder.setDisplayName(contactName[numIndex])
      .setCallDirection(callTypes[typeIndex])
      .setRingDuration(123456)
      .setTalkDuration(123456)
      .setFormattedNumber(formatPhoneNumbers[numIndex])
      .setQuickSearchKey(contactId[numIndex])
      .setAnswerState(answerStatus[answerindex])
      .setCreateTime(1641779105)
      .setNumberLocation("江苏无锡");
    let repo = CallLogRepository.getInstance();
    repo.saveOne(new CallLog(callLogBuilder)).then(data => {
      console.info('testInsertCallLog logMessage Insert calllog result success! ');
    }).catch(error => {
      console.info('testInsertCallLog' + 'logMessage insert error:' + error);
    });
  },

  /**
     * 获取全量(2000条)通话记录，并缓存
     *
     * @param {string} DAHelper 数据库路径
     * @param {string} mergeRule  通话记录类型
     * @param {Object} callBack 通话记录数据
     */
  getAllCalls: async function (DAHelper, mergeRule, callBack) {
    let  resultData = {
      callLogList: [], missedList: [], totalCount: 0, missedCount: 0
    };
    let callLogs = await CallLogRepository.getInstance().findAll();
    if (ArrayUtil.isEmpty(callLogs)) {
      HiLog.i(TAG, 'getAllCalls logMessage callLog resultSet is empty!');
      resultData.callLogList = [];
      resultData.missedList = [];
      resultData.totalCount = 0;
      resultData.missedCount = 0;
      callBack(resultData);
      return;
    }

    let  callLogList: CallLog[] = [];
    let  missedList: CallLog[] = [];
    for (let callLog of callLogs) {
      callLogList.push(callLog);
      if (callLog.callType == CallType.MISSED ||
      callLog.callType == CallType.REJECTED) {
        missedList.push(callLog); // 过滤未接来电数据
        let timeList = [];
        if (mergeRule == 'from_contact') { // 过滤按联系人未接电话后又重拨出
          for (let  k = 0; k < missedList.length; k++) {
            let missedPhone = missedList[k].phoneNumber;
            for (let  i = 0; i < callLogList.length; i++) {
              let allSpecialPhone = callLogList[i].phoneNumber;
              if (missedPhone == allSpecialPhone) {
                let timeNumber = callLogList[i].createTime;
                let obj = {
                  'id': i,
                  'timeObj': timeNumber,
                };
                timeList.push(obj);
                let max = timeList[0].timeObj;
                for (let  j = 0; j < timeList.length; j++) {
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
    // 合并规则
    if (mergeRule == 'from_contact') {
      resultData.callLogList = CallLogService.getInstance().mergeByContact(callLogList);
      resultData.missedList = CallLogService.getInstance().mergeByContact(missedList);
      resultData.totalCount = resultData.callLogList.length;
      resultData.missedCount = resultData.missedList.length;
    } else {
      resultData.callLogList = CallLogService.getInstance().mergeByTime(callLogList);
      resultData.missedList = CallLogService.getInstance().mergeByTime(missedList);
      resultData.totalCount = callLogs.length;
      resultData.missedCount = missedList.length;
    }
    callBack(resultData);
  },
}