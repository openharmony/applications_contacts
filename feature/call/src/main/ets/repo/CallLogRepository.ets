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
import dataSharePredicates from "@ohos.data.dataSharePredicates";
import ICallLogRepository from './ICallLogRepository';
import { CallLog } from '../entity/CallLog';
import CallLogBuilder from '../entity/CallLogBuilder';
import Calls from '../contract/Calls';
import CallLogDelta from './CallLogDelta';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = "CallLogRepository";

/**
 * Account type service, which is used to display account characteristics such as account type holding contact details.
 */
export class CallLogRepository implements ICallLogRepository {
  private static instance: CallLogRepository;
  private dataShareHelper;
  private context: Context

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

  saveOne(callLog: CallLog, callback) {
    if (callLog.id <= 0) {
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        let callLogDelta = new CallLogDelta(callLog);
        dataAbilityHelper.insert(Calls.CALL_LOG_URI, callLogDelta.createValuesBucket()).then(data => {
          callback(data);
        }).catch(error => {
          HiLog.w(TAG, 'saveOne error:%s', JSON.stringify(error.message));
          callback();
        });
      }).catch(error => {
        HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        callback();
      });
    } else {
      callback();
    }
  }

  clear(callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then(data => {
        callback(data);
      }).catch(error => {
        HiLog.w(TAG, 'clear error:%s', JSON.stringify(error.message));
        callback();
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  deleteById(id: number) {
    return false;
  }

  deleteByIdIn(ids: number[], callback) {
    if (ArrayUtil.isEmpty(ids)) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Calls.ID, ids);
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then(data => {
        callback(data);
      }).catch(error => {
        HiLog.w(TAG, 'deleteByIdIn error:%s', JSON.stringify(error.message));
        callback();
      });
    }).catch(error => {
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

  findAll(actionData, callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      let offset = actionData.page < 3 ? (actionData.page - 1) * 50 : (actionData.page - 2) * 500 + 50;
      condition.limit(actionData.limit, offset);
      condition.orderByDesc(Calls.CREATE_TIME);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then(resultSet => {
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
      }).catch(error => {
        HiLog.w(TAG, 'findAll error:' + JSON.stringify(error.message));
        callback([]);
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  findByFeature(feature: number) {
    return [];
  }

  findByNumberIn(numbers: number[], callback) {
    if (ArrayUtil.isEmpty(numbers)) {
      callback([]);
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let realPhoneNumbers = [];
      for (let key in numbers) {
        let phoneNumber = StringUtil.removeSpace(numbers[key].toString());
        realPhoneNumbers.push(phoneNumber);
      }
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in(Calls.PHONE_NUMBER, realPhoneNumbers);
      condition.orderByDesc(Calls.CREATE_TIME);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then(resultSet => {
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
      }).catch(error => {
        HiLog.w(TAG, 'findByNumberIn error:%s', JSON.stringify(error.message));
        callback([]);
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  markMissedCallLogAsRead(phoneNum?: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and().equalTo(Calls.CALL_DIRECTION, 0);
      if (phoneNum && !StringUtil.isEmpty(phoneNum)) {
        condition.and().equalTo(Calls.PHONE_NUMBER, phoneNum);
      }
      dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, {
        "is_read": 1
      }).then(value => {
        HiLog.i(TAG, 'markMissedCallLogIsRead update succ :%d', value);
      }).catch(error => {
        HiLog.w(TAG, 'markMissedCallLogIsRead error:%s', JSON.stringify(error.message));
      });
    }).catch(error => {
      HiLog.w(TAG, 'markMissedCallLogIsRead error:%s' + JSON.stringify(error.message));
    });
  }

  findMissedCallLogUnread(callback, lastId?: number) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0).and().equalTo(Calls.CALL_DIRECTION, 0).and().equalTo(Calls.ANSWER_STATE, 0);

      if (lastId && lastId > -1) {
        condition.and().greaterThan(Calls.ID, lastId);
      }
      condition.orderByDesc(Calls.ID);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then(resultSet => {
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
      }).catch(error => {
        HiLog.w(TAG, 'findMissedCallLogUnread resultSet parse error:%s', JSON.stringify(error.message));
        callback([]);
      });
    }).catch(error => {
      HiLog.w(TAG, 'findMissedCallLogUnread error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  notifyChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.notifyChange(Calls.CALL_LOG_URI).then((data) => {
          HiLog.i(TAG, "notifyChange success")
        }).catch(error => {
          HiLog.w(TAG, 'notifyChange error:%s' + JSON.stringify(error.message));
        })
      }
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  registerDataChangeObserver(callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.on("dataChange", Calls.CALL_LOG_URI, callback);
      }
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  unRegisterDataChangeObserver(callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.off("dataChange", Calls.CALL_LOG_URI, callback);
      }
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }
}