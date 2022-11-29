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

import ICallLogRepository from './ICallLogRepository';
import { CallLog } from '../entity/CallLog';
import CallLogBuilder from '../entity/CallLogBuilder';
import Calls from '../contract/Calls';
import CallLogDelta from './CallLogDelta';
import FeatureAbility from '@ohos.ability.featureAbility';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import DataAbility from '@ohos.data.dataAbility';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = "CallLogRepository";

/**
 * Account type service, which is used to display account characteristics such as account type holding contact details.
 */
export class CallLogRepository implements ICallLogRepository {
  private static instance: CallLogRepository;
  private _dataAbilityHelper = FeatureAbility.acquireDataAbilityHelper(globalThis.context, Calls.CONTENT_URI);

  private constructor() {
  }

  public static getInstance(): CallLogRepository {
    if (!CallLogRepository.instance) {
      CallLogRepository.instance = new CallLogRepository()
    }
    return CallLogRepository.instance
  }

  private getDataAbilityHelper() {
    if (this._dataAbilityHelper == undefined || this._dataAbilityHelper == null) {
      this._dataAbilityHelper = FeatureAbility.acquireDataAbilityHelper(globalThis.context, Calls.CONTENT_URI);
    }
    return this._dataAbilityHelper;
  }

  saveOne(callLog: CallLog) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<number>(function (resolve, reject) {
      if (callLog.id <= 0) {
        let callLogDelta = new CallLogDelta(callLog);
        dataAbilityHelper.insert(Calls.CALL_LOG_URI, callLogDelta.createValuesBucket()).then(data => {
          resolve(data);
        }).catch(error => {
          HiLog.w(TAG, 'saveOne error:%s', JSON.stringify(error.message));
          reject();
        });
      }
    });
  }

  save(callLogs: CallLog[]) {
    return false;
  }

  clear() {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<number>(function (resolve, reject) {
      let condition = new DataAbility.DataAbilityPredicates();
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then(data => {
        resolve(data);
      }).catch(error => {
        HiLog.w(TAG, 'clear error:%s', JSON.stringify(error.message));
        reject();
      });
    });
  }

  deleteById(id: number) {
    return false;
  }

  deleteByIdIn(ids: number[]) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<number>(function (resolve, reject) {
      if (ArrayUtil.isEmpty(ids)) {
        reject();
        return;
      }
      let condition = new DataAbility.DataAbilityPredicates();
      condition.in(Calls.ID, ids);
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then(data => {
        resolve(data);
      }).catch(error => {
        HiLog.w(TAG, 'deleteByIdIn error:%s', JSON.stringify(error.message));
        reject();
      });
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

  findByCallDirectionIn(callTypes: number[]) {
    return new Promise<CallLog[]>(function (resolve, reject) {
      resolve([]);
    });
  }

  findAll(actionData) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<CallLog[]>(function (resolve, reject) {
      let condition = new DataAbility.DataAbilityPredicates();
      condition.limitAs(actionData.limit);
      condition.orderByDesc(Calls.CREATE_TIME);
      let offset = actionData.page < 3 ? (actionData.page - 1) * 50 : (actionData.page - 2) * 500 + 50;
      condition.offsetAs(offset);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, null, condition).then(resultSet => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          resolve(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          resolve(rst);
        }
      }).catch(error => {
        HiLog.w(TAG, 'findAll error:' + JSON.stringify(error.message));
        reject();
      });
    });
  }

  findByFeature(feature: number) {
    return [];
  }

  findByNumberIn(numbers: number[]) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<CallLog[]>(function (resolve, reject) {
      if (ArrayUtil.isEmpty(numbers)) {
        reject();
        return;
      }
      let realPhoneNumbers = [];
      for (let key in numbers) {
        let phoneNumber = StringUtil.removeSpace(numbers[key].toString());
        realPhoneNumbers.push(phoneNumber);
      }
      let condition = new DataAbility.DataAbilityPredicates();
      condition.in(Calls.PHONE_NUMBER, realPhoneNumbers);
      condition.orderByDesc(Calls.CREATE_TIME);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, null, condition).then(resultSet => {
        let rst: CallLog[] = [];
        if (resultSet.rowCount === 0) {
          resultSet.close();
          resolve(rst);
        } else {
          resultSet.goToFirstRow();
          do {
            let builder = CallLogBuilder.fromResultSet(resultSet);
            if (builder.id > 0) {
              rst.push(new CallLog(builder));
            }
          } while (resultSet.goToNextRow());
          resultSet.close();
          resolve(rst);
        }
      }).catch(error => {
        HiLog.w(TAG, 'findByNumberIn error:%s', JSON.stringify(error.message));
        reject();
      });
    });
  }

  notifyChange() {
    let dataAbilityHelper = this.getDataAbilityHelper();
    if (dataAbilityHelper) {
      dataAbilityHelper.notifyChange(Calls.CALL_LOG_URI).then((data) => {
        HiLog.i(TAG, "notifyChange success")
      }).catch(error => {
        HiLog.w(TAG, 'notifyChange error:%s', JSON.stringify(error.message));
      });
    }
  }

  registerDataChangeObserver(callback) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    if (dataAbilityHelper) {
      dataAbilityHelper.on("dataChange", Calls.CALL_LOG_URI, callback);
    }
  }

  unRegisterDataChangeObserver(callback) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    if (dataAbilityHelper) {
      dataAbilityHelper.off("dataChange", Calls.CALL_LOG_URI, callback);
    }
  }
}