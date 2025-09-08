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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import ICallLogRepository from './ICallLogRepository';
import { CallLog } from '../entity/CallLog';
import CallLogBuilder from '../entity/CallLogBuilder';
import Calls from '../contract/Calls';
import CallLogDelta from './CallLogDelta';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from 'common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { BusinessError } from '@ohos.base';
import {
  AllCallsGetActionData,
  CallHistorySearchGetActionData,
  FindByNumberActionData
} from '../../../../../../entry/src/main/ets/model/type';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

const TAG = 'CallLogRepository';

/**
 * Account type service, which is used to display account characteristics such as account type holding contact details.
 */
export class CallLogRepository implements ICallLogRepository {
  private static instance: CallLogRepository;
  public dataShareHelper?: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper>;
  private context?: Context
  private constructor() {
  }

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    this.context = ctx;
  }

  public static getInstance(): CallLogRepository {
    if (!CallLogRepository.instance) {
      CallLogRepository.instance = new CallLogRepository()
    }
    return CallLogRepository.instance
  }

  private async getDataAbilityHelper() {
    if (this.dataShareHelper == undefined) {
      this.dataShareHelper = await dataShare.createDataShareHelper(this.context ? this.context : globalThis.context,
        Calls.CONTENT_URI);
    }
    return this.dataShareHelper;
  }

  saveOne(callLog: CallLog, callback: (Contact?: number) => void) {
    if (callLog.id <= 0) {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let callLogDelta = new CallLogDelta(callLog);
        dataAbilityHelper.insert(Calls.CALL_LOG_URI, callLogDelta.createValuesBucket()).then((data: number) => {
          callback(data);
        }).catch((error: BusinessError) => {
          HiLog.w(TAG, 'saveOne error:%s', JSON.stringify(error.message));
          callback();
        });
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        callback();
      });
    } else {
      callback();
    }
  }

  clear(callback: (Contact?: number) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'clear error:%s', JSON.stringify(error.message));
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  deleteById(id: number) {
    return false;
  }

  deleteByIdIn(ids: number[], callback: (Contact?: number) => void) {
    if (ArrayUtil.isEmpty(ids)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Calls.ID, ids);
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'deleteByIdIn error:%s', JSON.stringify(error.message));
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  deleteByNumber(number: string) {
    return false;
  }

  deleteByLookupUri(number: string) {
    return false;
  }

  readByNumber(number: string) {
    return false;
  }

  readById(id: number) {
    return false;
  }

  findAll(actionData: AllCallsGetActionData, callback: (Contact: CallLog[]) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      let offset =
        actionData.page != undefined && actionData.page < 3 ? (actionData.page - 1) * 50 :
          (actionData.page != undefined ? actionData.page - 2 : 1) * 500 + 50;
      condition.limit(actionData.limit, offset);
      condition.orderByDesc(Calls.CREATE_TIME);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          callback(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          callback(rst);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findAll error:' + JSON.stringify(error.message));
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  findByFeature(feature: number) {
    return [];
  }

  findByNumberIn(actionData: FindByNumberActionData, callback: (Contact: CallLog[]) => void) {
    if (ArrayUtil.isEmpty(actionData.numbers)) {
      callback([]);
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let realPhoneNumbers: string[] = [];
      for (let key of actionData.numbers) {
        let phoneNumber = StringUtil.removeSpace(actionData.numbers[key].toString());
        realPhoneNumbers.push(phoneNumber);
      }
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Calls.PHONE_NUMBER, realPhoneNumbers);
      condition.orderByDesc(Calls.CREATE_TIME);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          callback(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          callback(rst);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findByNumberIn error:%s', JSON.stringify(error.message));
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  markMissedCallLogAsRead(phoneNum?: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and().equalTo(Calls.CALL_DIRECTION, 0);
      if (phoneNum && !StringUtil.isEmpty(phoneNum)) {
        condition.and().equalTo(Calls.PHONE_NUMBER, phoneNum);
      }
      dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, {
        'is_read': 1
      }).then((value: number) => {
        HiLog.i(TAG, 'markMissedCallLogIsRead update succ :%d', value.toString());
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'markMissedCallLogIsRead error:%s', JSON.stringify(error.message));
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'markMissedCallLogIsRead error:%s' + JSON.stringify(error.message));
    });
  }

  findMissedCallLogUnread(callback: (Contact: CallLog[]) => void, lastId?: number) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and()
        .equalTo(Calls.CALL_DIRECTION, 0)
        .and()
        .equalTo(Calls.ANSWER_STATE, 0);

      if (lastId && lastId > -1) {
        condition.and().greaterThan(Calls.ID, lastId);
      }
      condition.orderByDesc(Calls.ID);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          callback(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          callback(rst);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findMissedCallLogUnread resultSet parse error:%s', JSON.stringify(error.message));
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'findMissedCallLogUnread error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  notifyChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.notifyChange(Calls.CALL_LOG_URI).then((data: void) => {
          HiLog.i(TAG, 'notifyChange success')
        }).catch((error: BusinessError) => {
          HiLog.w(TAG, 'notifyChange error:%s' + JSON.stringify(error.message));
        })
      }
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  observers: Array<() => void> = [];
  callback = () => {
    HiLog.d(TAG, 'CallLog changed: Notifying observers...');
    for (const observer of this.observers) {
      observer();
    }
  }

  registerCallLogDataChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.on('dataChange', Calls.CALL_LOG_URI, this.callback);
        HiLog.i(TAG, 'registerCallLogDataChange success')
      }
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  unregisterCallLogDataChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        HiLog.i(TAG, 'start unregisterCallLogDataChange');
        dataAbilityHelper.off('dataChange', Calls.CALL_LOG_URI, this.callback);
        HiLog.i(TAG, 'unregisterCallLogDataChange success')
      }
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  registerDataChangeObserver(observer: () => void): void {
    if (!observer) {
      HiLog.i(TAG, 'registerDataChangeObserver: observer is null.');
      return;
    }
    if (this.observers.length == 0) {
      this.registerCallLogDataChange()
    }
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return HiLog.i(TAG, 'registerDataChangeObserver: Observer has been attached already.');
    }
    HiLog.i(TAG, 'registerDataChangeObserver: Attached an observer.');
    this.observers.push(observer);
  }

  unRegisterDataChangeObserver(observer: () => void) {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      HiLog.i(TAG, 'unRegisterDataChangeObserver: Nonexistent observer.');
      return
    }
    this.observers.splice(observerIndex, 1);
    HiLog.i(TAG, 'unRegisterDataChangeObserver: Detached an observer.');
    if (this.observers.length == 0) {
      this.unregisterCallLogDataChange();
    }
  }

  findSearch(actionData: CallHistorySearchGetActionData, callback: (Contact?: CallLog[]) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Calls.DISPLAY_NAME, actionData.nameArray)
        .or()
        .like(Calls.PHONE_NUMBER, `%${actionData.teleNumber}%`);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          callback(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          callback(rst);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findAll error:' + JSON.stringify(error.message));
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }
}