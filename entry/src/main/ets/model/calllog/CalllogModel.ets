/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { ObjectUtil } from '../../../../../../common/src/main/ets/util/ObjectUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import TraceConstants from '../../../../../../common/src/main/ets/TraceConstants';
import { CallLog, CallLogRepository, CallLogService } from '../../../../../../feature/call';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { MergeRule } from '../../../../../../feature/call/src/main/ets/CallLogSetting';
import MergedCallLog from '../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallInfoGetParamsInCallback } from '../type/ContactParams';
import { AllCallsGetActionData, RecorderLog } from '../type';
import LooseObject from '../type/LooseObject';
import CallDetail from '../bean/CallDetail';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import Calls from '../../../../../../feature/call/src/main/ets/contract/Calls';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { HashMap, taskpool } from '@kit.ArkTS';
import { queryContactNameByNumber, queryYellowPageNameByNumber } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import ContactNameNumberInfo from '../../../../../../feature/contact/src/main/ets/entity/ContactNameNumberInfo';
import { sharedPreferencesUtils } from '../../../../../../common';
import NumberMarkUtil from '../../util/NumberMarkUtil';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'CallLogModel';

class CallLogModel {
  /**
   * Obtains and caches all call records.
   *
   * @param {Object} call Record Action Data
   * @param {Object} callBack Call log data
   * @param {boolean} true: Query Interception Call Record; false: Query All Call Record
   */
  async getAllCalls(actionData: AllCallsGetActionData, callBack: CallableFunction) {
    HiLog.i(TAG, `getAllCalls start`);
    let groupByValue: string =
      (await sharedPreferencesUtils.getFromPreferences('isCallSettingDataChangeGroupByValue', 'time')) as string;
    CallLogRepository.getInstance().findAll(actionData, (result: CallLog[]) => {
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [], missedList: [], callLogSearchList: [], timeStamp: ''
      };

      if (actionData.limit === undefined || result.length < actionData.limit) {
        HiLog.i(TAG, 'getAllCalls isEnd ');
        resultData.isEnd = true;
      } else {
        resultData.isEnd = false;
      }
      CallLogService.getInstance().setMergeRule(groupByValue === 'contacts' ? MergeRule.CONTACT : MergeRule.TIME);

      // 第一次分页查询 清空 preCallLog
      if ((actionData.page ?? 0) <= 1) {
        CallLogService.getInstance().preCallLog = [];
      }
      // 合并通话记录时，排除通话记录数组中的 最后一组可合并的数据，并放在下一次合并的数据当中
      // 防止出现 一组可合并的数据 合并完成之后，出现不止一条通话记录
      if (resultData.isEnd) {
        // 最后一次查询，不用排除通话记录数组中的 最后一组可合并的数据
        result = [...CallLogService.getInstance().preCallLog, ...result];
        CallLogService.getInstance().preCallLog = [];
      } else {
        // 合并上次查询结果和本次的查询结果，然后后边再和并
        result = [...CallLogService.getInstance().preCallLog, ...result];
        CallLogService.getInstance().updatePreCallLog(result)
      }
      // 合并
      // 按时间合并，排序后，可能存在相邻同手机号，通话时间不同的通话记录
      // 按联系人合并，根据phoneNumber分组了，再排序，没有相邻的记录是同手机号了
      resultData.callLogList = CallLogService.getInstance().mergeCallLogs([...result]);
      resultData.missedList = CallLogService.getInstance().mergeMissedCalls([...result]);
      let isNeedQueryContactName: boolean =
        actionData.isNeedQueryContact == undefined ? true : actionData.isNeedQueryContact;
      // 更新displayName
      this.updateContactDisplayName(resultData, callBack, isNeedQueryContactName);
      // 更新黄页信息
      this.updateYellowPageInfo(resultData.callLogList);
    });
  }

  updateContactDisplayName(resultData: CallInfoGetParamsInCallback, callback: Function,
    isNeedQueryContactName: boolean) {
    HiLog.w(TAG, `updateContactDisplayName start! time: ${(new Date()).valueOf()
    }, isNeedQueryContactName: ${isNeedQueryContactName}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_CALL_DISPLAY_NAME, TraceConstants.TRACE_CALL_DISPLAY_NAME_ID);
    let contactNameMap: HashMap<string, ContactNameNumberInfo> = new HashMap<string, ContactNameNumberInfo>();
    // 没有displayName的通话记录号码
    let numberSet: Set<string> = new Set();
    resultData.callLogList.forEach((callLog) => {
      if (StringUtil.isEmpty(callLog.displayName)) {
        if (!StringUtil.isEmpty(callLog.phoneNumber)) {
          numberSet.add(callLog.phoneNumber);
        }
        if (!StringUtil.isEmpty(callLog.formatPhoneNumber)) {
          numberSet.add(callLog.formatPhoneNumber);
        }
      }
    })
    let numbers: string[] = Array.from(numberSet);
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    if (numbers.length <= 0) {
      HiLog.w(TAG, `updateContactDisplayName out! time: ${(new Date()).valueOf()}`);
      callback(resultData);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_CALL_DISPLAY_NAME, TraceConstants.TRACE_CALL_DISPLAY_NAME_ID);
      return;
    }
    if (!isNeedQueryContactName) {
      callback(resultData);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_CALL_DISPLAY_NAME, TraceConstants.TRACE_CALL_DISPLAY_NAME_ID);
    } else {
      // 根据号码，查联系人信息，设置名字
      let task = new taskpool.Task(queryContactNameByNumber, context, numbers);
      taskpool.execute(task).then((contactInfosObject: Object) => {
        try {
          HiLog.w(TAG, `updateContactDisplayName end! time: ${(new Date()).valueOf()}`);
          // 二次匹配，新匹配到的 {phoneNumber，displayName} 对应对象
          let contactInfos = contactInfosObject as ContactNameNumberInfo[];
          contactInfos.forEach((item: ContactNameNumberInfo) => {
            if (!StringUtil.isEmpty(item.phoneNumber)) {
              contactNameMap.set(item.phoneNumber, item);
            }
            if (!StringUtil.isEmpty(item.formatPhoneNumber)) {
              contactNameMap.set(item.formatPhoneNumber, item);
            }
          })
          HiLog.w(TAG, `updateContactDisplayName contactNameMap length: ${contactNameMap.length}`);
          resultData.callLogList.forEach((callLog) => {
            let contactNameNumberInfo: ContactNameNumberInfo | undefined = undefined;
            if (contactNameMap.hasKey(callLog.formatPhoneNumber)) {
              contactNameNumberInfo = contactNameMap.get(callLog.formatPhoneNumber);
            } else if (contactNameMap.hasKey(callLog.phoneNumber)) {
              contactNameNumberInfo = contactNameMap.get(callLog.phoneNumber);
            } else {
              return;
            }
            if (contactNameNumberInfo && StringUtil.isEmpty(callLog.displayName) &&
              !StringUtil.isEmpty(contactNameNumberInfo.name)) {
              callLog.displayName = contactNameNumberInfo.name;
              if (contactNameNumberInfo.contactId > 0) {
                callLog.quickSearchKey = contactNameNumberInfo.contactId.toString();
              }
            }
          })
          resultData.missedList.forEach((callLog) => {
            let contactNameNumberInfo: ContactNameNumberInfo | undefined = undefined;
            if (contactNameMap.hasKey(callLog.formatPhoneNumber)) {
              contactNameNumberInfo = contactNameMap.get(callLog.formatPhoneNumber);
            } else if (contactNameMap.hasKey(callLog.phoneNumber)) {
              contactNameNumberInfo = contactNameMap.get(callLog.phoneNumber);
            } else {
              return;
            }
            if (contactNameNumberInfo && StringUtil.isEmpty(callLog.displayName) &&
              !StringUtil.isEmpty(contactNameNumberInfo.name)) {
              callLog.displayName = contactNameNumberInfo.name;
              if (contactNameNumberInfo.contactId > 0) {
                callLog.quickSearchKey = contactNameNumberInfo.contactId.toString();
              }
            }
          })
          hiTraceMeter.finishTrace(TraceConstants.TRACE_CALL_DISPLAY_NAME, TraceConstants.TRACE_CALL_DISPLAY_NAME_ID);
          callback(resultData);
          // 二次匹配更新通话记录的联系人信息
          CallLogRepository.getInstance().updateCallLogDisplayName(contactNameMap);
        } catch (err) {
          HiLog.e(TAG, `updateContactDisplayName err: ${err.message}`);
          callback(resultData);
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `updateContactDisplayName queryContactNameByNumber taskpool err: ${err.message}`);
        callback(resultData);
      })
    }
  }

  updateYellowPageInfo(callRecords: MergedCallLog[]) {
    HiLog.w(TAG, `updateYellowPageInfo start! time: ${(new Date()).valueOf()}`);
    let noMarkTypeNumberSet: Set<string> = new Set();
    let yellowNameMap: HashMap<string, string> = new HashMap();
    callRecords.forEach((callLog) => {
      // markType 为空的号码，需要查询并更新其 markType
      if (StringUtil.isEmpty(callLog.markType)) {
        noMarkTypeNumberSet.add(callLog.phoneNumber);
      }
      // displayName 为空的黄页号码，并且不为云端黄页，displayName 需要更新为对应的 markContent
      if (StringUtil.isEmpty(callLog.displayName) &&
        !StringUtil.isEmpty(callLog.markType) &&
        callLog.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
        callLog.isCloudMark !== 1) {
        yellowNameMap.set(callLog.phoneNumber, callLog.markContent);
      }
    })
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let noMarkTypeNumbers: string[] = Array.from(noMarkTypeNumberSet);
    HiLog.w(TAG, `updateYellowPageInfo noMarkTypeNumbers: ${noMarkTypeNumbers.length
    }, yellowNameMap: ${yellowNameMap.length}`);

    let task = new taskpool.Task(queryYellowPageNameByNumber, context, noMarkTypeNumbers);
    taskpool.execute(task).then((yellowInfoMapObject: Object) => {
      let yellowInfoMap = yellowInfoMapObject as Map<string, string>;
      noMarkTypeNumbers.forEach((phoneNumber) => {
        let yellowPageName: string = yellowInfoMap.get(phoneNumber) ?? '';
        if (StringUtil.isEmpty(yellowPageName)) {
          // yellowPageName 为空，更新 markType = 0
          CallLogRepository.getInstance().UpdateCallLogWithYellowPageInfo(
            phoneNumber, NumberMarkUtil.PRE_NONE_PHONE_DESC, yellowPageName);
        } else {
          // yellowPageName 不为空，表示黄页号码，更新 markType = 10
          CallLogRepository.getInstance().UpdateCallLogWithYellowPageInfo(
            phoneNumber, NumberMarkUtil.YELLOW_PAGE_PHONE_DESC, yellowPageName);
          yellowNameMap.set(phoneNumber, yellowPageName);
        }
      })
      CallLogRepository.getInstance().updateCallLogDisplayName(yellowNameMap);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `updateYellowPageInfo queryYellowPageNameByNumber taskpool err: ${err.message}`);
    })
  }


  /**
   * Obtains and caches all call records.
   *
   * @param {Object} call Record Action Data
   * @param {Object} callBack Call log data
   */
  async getInterceptionCalls(actionData: AllCallsGetActionData, callBack: CallableFunction) {
    HiLog.i(TAG, `getInterceptionCalls in: ${actionData}`);
    CallLogRepository.getInstance().findAll(actionData, (result: CallLog[]) => {
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [], missedList: [], callLogSearchList: [], timeStamp: ''
      };

      if (actionData.limit === undefined || result.length < actionData.limit) {
        HiLog.i(TAG, 'getAllCalls isEnd ');
        resultData.isEnd = true;
      } else {
        resultData.isEnd = false;
      }
      resultData.callLogList = CallLogService.getInstance().displayInterceptionCallsTime(result);
      callBack(resultData);
    }, true);
  }

  /**
   * Obtains Frist Missed Call.
   *
   * @param {string} daHelper Database path
   * @param {string} mergeRule  Call Record Type
   * @param {Object} callBack Call log data
   */
  async getFirstMissedCall(actionData: LooseObject, callBack: CallableFunction, context?: Context) {
    if (context) {
      CallLogRepository.getInstance().init(context);
      CallLogRepository.getInstance().findFristMissedCall(actionData, (result: CallLog[]) => {
        let resultData: CallLog[] = result
        if (ArrayUtil.isEmpty(result)) {
          HiLog.i(TAG, 'getFirstMissedCall logMessage callLog resultSet is empty!');
          callBack([]);
          return;
        } else {
          callBack(resultData);
        }
      });
    }
  }

  handleCallLogSearchList(timeStamp: string, callBack: CallableFunction, data: CallInfoGetParamsInCallback,
                          result: Array<MergedCallLog>, nameArray: Array<string>,
                          callLogSearchList: Array<MergedCallLog>) {
    let resultData: CallInfoGetParamsInCallback = {
      callLogSearchList: [], timeStamp: timeStamp, callLogList: [], missedList: []
    };
    for (let i = 0; i < result?.length; i++) {
      const phoneNumber: string | undefined = result[i]?.phoneNumber;
      data?.callLogList?.findIndex((item) => {
        if (item.phoneNumber === phoneNumber) {
          if (!callLogSearchList.includes(result[i])) {
            resultData.callLogSearchList.push(result[i]);
          }
        }
      })
    }
    for (let i = 0; i < data?.callLogList?.length; i++) {
      const phoneNumber: string | undefined = data?.callLogList[i]?.phoneNumber;
      if (phoneNumber !== undefined && !nameArray.includes(data?.callLogList[i]?.displayName) &&
        !nameArray.includes(data?.callLogList[i]?.phoneNumber)) {
        nameArray.push(phoneNumber);
        let callLog = data?.callLogList[i];
        callLog.phoneNumber = phoneNumber;
        resultData.callLogSearchList.push(callLog);
      }
    }
    callBack(resultData);
  }

  async getRecorderMessage(callDetailList: CallDetail[], callback: Function) {
    let phoneNumbers: Set<string> = new Set();
    callDetailList.forEach((item: CallDetail) => {
      phoneNumbers.add(item.phone);
    });
    let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in('phone_number', Array.from<string>(phoneNumbers));
      condition.notEqualTo('is_deleted', 1);
      let columns = ['id', 'date_added', 'file_path', 'display_name', 'phone_number'];
      let dataHelper = await dataShare.createDataShareHelper(context, uri);
      dataHelper.query(uri, condition, columns).then((resultSet) => {
        try {
          let resultSetUse: Record<string, RecorderLog[]> = {};
          while (resultSet.goToNextRow()) {
            let id = resultSet.getLong(resultSet.getColumnIndex('id'));
            let dateAdded = resultSet.getString(resultSet.getColumnIndex('date_added'));
            let filePath = resultSet.getString(resultSet.getColumnIndex('file_path'));
            let displayName = resultSet.getString(resultSet.getColumnIndex('display_name'));
            let phoneNumber = resultSet.getString(resultSet.getColumnIndex('phone_number'));
            if (!resultSetUse[dateAdded]) {
              resultSetUse[dateAdded] = [];
            }
            resultSetUse[dateAdded].push({
              dateAdded: dateAdded,
              filePath: filePath,
              displayName: displayName,
              phoneNumber: phoneNumber,
              id: id
            });
          }
          let result: CallDetail[] = callDetailList;
          this.queryCallRecord(callDetailList, resultSetUse);
          callback(result);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    } catch (err) {
      callback(callDetailList);
    }
  }

  queryCallRecord(callDetailList: CallDetail[], resultSetUse: Record<string, RecorderLog[]>): CallDetail[] {
    let result: CallDetail[] = callDetailList;
    let callRecordListByTime: Record<string, number> = {};
    Object.keys(resultSetUse).forEach((beginTime) => {
      callRecordListByTime[beginTime] = parseInt(beginTime);
    });
    for (let j = 0; j < result.length; j++) {
      let curCallDetail: CallDetail = result[j] as CallDetail;
      let beginTime = curCallDetail.beginTime;
      if (beginTime === '' || beginTime === '0') {
        continue;
      }

      if (resultSetUse[beginTime]) {
        result[j].recordLogList = resultSetUse[beginTime];
        continue;
      }

      let beginCompare: number = parseInt(beginTime);
      let endCompare: number = beginCompare + curCallDetail.talkDuration;
      let oldRecordList: RecorderLog[] = [];
      Object.keys(resultSetUse).forEach((beginTime) => {
        if (callRecordListByTime[beginTime] >= (beginCompare - 1) &&
          callRecordListByTime[beginTime] <= (endCompare + 1)) {
          oldRecordList.push(resultSetUse[beginTime][0]);
        }
      });
      if (oldRecordList.length > 0) {
        result[j].recordLogList = oldRecordList;
      }
    }
    return result;
  }
}

interface ContactInterface {
  detailInfo: string
  displayName: string
}

export default new CallLogModel()