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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import ICallLogRepository from './ICallLogRepository';
import { CallLog, carrierCallFeaturesLimit } from '../entity/CallLog';
import CallLogBuilder from '../entity/CallLogBuilder';
import Calls from '../contract/Calls';
import { RawContacts } from '../../../../../contact/src/main/ets/contract/RawContacts';
import CallLogDelta from './CallLogDelta';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { CountryIdUtil } from '../../../../../../common/src/main/ets/util/CountryIdUtil';
import { BusinessError } from '@ohos.base';
import { ContactsGlobalThisHelper } from 'common/src/main/ets/util/ContactsGlobalThisHelper';
import {
  AllCallsGetActionData,
  CallHistorySearchGetActionData,
  FindByNumberActionData
} from '../../../../../../entry/src/main/ets/model/type';
// import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { ObjectUtil, sharedPreferencesUtils } from 'common';
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
import { emitter } from '@kit.BasicServicesKit';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import YellowPage from '../../../../../contact/src/main/ets/contract/YellowPage';
import { common } from '@kit.AbilityKit';
import { NumberMatch } from './NumberMatch';
import DotUtil from '../../../../../../entry/src/main/ets/util/DotUtil';
import dotCommon, { faultContactParams } from '../../../../../../entry/src/main/ets/util/DotCommon';
import call from '@ohos.telephony.call';
import { queryInitSettingMode, addSettingModeListener } from '../../../../../../entry/src/main/ets/model/CallSharingModel';
import { CallSharingClass } from '../../../../../../entry/src/main/ets/card/data/commonData';
import EnvironmentProp from '../../../../../../entry/src/main/ets/feature/EnvironmentProp';

import EmitterConstant from '../../../../../../entry/src/main/ets/data/EmitterConstant';
import { HashMap } from '@kit.ArkTS';
import IndexPresenter from '../../../../../../entry/src/main/ets/presenter/IndexPresenter';
import data from '@ohos.telephony.data';
import ContactNameNumberInfo from '../../../../../../feature/contact/src/main/ets/entity/ContactNameNumberInfo';
import { DataShareResultSet } from '@kit.ArkData';
import { CallLogTemp } from '../entity/CallLogTemp';

const TAG = 'CallLogRepository';
const CALL_CARRIER_INTERCEPTION = 6;
const PRIVACY_TAG = 'privacy_tag';

// Account type service, which is used to display account characteristics such as account type holding contact details.
export class CallLogRepository implements ICallLogRepository {
  private static instance: CallLogRepository;
  public dataShareHelper?: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper>;
  public dataShareHelperProxy?: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper>;
  public settingDataShareHelper?: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper>;
  public context?: Context
  private settingCallbackTimeId = -1;
  private state: number = -1;
  constructor() {
    this.context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
  }
  public isQueryTaskFinished: boolean | undefined = undefined;
  public result_dt: number = 0;

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    if (ctx !== undefined) {
      this.context = ctx;
    }
    return this;
  }

  unInit() {
    this.dataShareHelper = undefined;
    this.context = undefined;
    this.settingDataShareHelper = undefined;

  }

  public static getInstance(): CallLogRepository {
    if (!CallLogRepository.instance) {
      CallLogRepository.instance = new CallLogRepository()
    }
    return CallLogRepository.instance
  }

  public static getDTTestInstance(): CallLogRepository {
    // 用于DT测试创建实例对象
    return new CallLogRepository();
  }

  async getDataAbilityHelper(): Promise<dataShare.DataShareHelper> {
    let createTimes = 0;
    while (this.dataShareHelper == undefined) {
      createTimes++;
      HiLog.w(TAG, `getDataAbilityHelper createTimes: ${createTimes} start`);
      try {
        this.dataShareHelper = await dataShare.createDataShareHelper(this.context, Calls.CONTENT_URI);
        HiLog.w(TAG, `getDataAbilityHelper createTimes: ${createTimes} success!`);
        break;
      } catch (error) {
        HiLog.e(TAG, `getDataAbilityHelper createTimes: ${createTimes} error: ${error?.message}`);
        if (createTimes >= 5) {
          break;
        }
      }
    }
    return this.dataShareHelper as dataShare.DataShareHelper;
  }

  async getDataAbilityHelperProxy(): Promise<dataShare.DataShareHelper> {
    let createTimes = 0;
    while (this.dataShareHelperProxy == undefined) {
      createTimes++;
      HiLog.w(TAG, `getDataAbilityHelperProxy createTimes: ${createTimes} start`);
      try {
        this.dataShareHelperProxy = dataShare.createDataShareHelper(this.context,
          Calls.CONTENT_URI_PROXY_QUERY_CALLLOG, {isProxy: true});
        HiLog.w(TAG, `getDataAbilityHelperProxy createTimes: ${createTimes} success!`);
        break;
      } catch (error) {
        HiLog.e(TAG, `getDataAbilityHelperProxy createTimes: ${createTimes} error: ${error?.message}`);
        if (createTimes >= 5) {
          break;
        }
      }
    }
    return this.dataShareHelperProxy as dataShare.DataShareHelper;
  }

  async closeDataAbilityHelperProxy() {
    if (!this.dataShareHelperProxy) {
      HiLog.w(TAG, 'closeDataAbilityHelperProxy, datashareProxy is empty, return ');
      return;
    }
    try {
      let datashareHelperLocal =
        await (this.dataShareHelperProxy as Promise<dataShare.DataShareHelper>);
      this.dataShareHelperProxy = undefined;
      await datashareHelperLocal.close();
      HiLog.w(TAG, 'closeDataAbilityHelperProxy, close success ');
    } catch (e) {
      HiLog.e(TAG, 'closeDataAbilityHelperProxy close error, ' + e.code + '--' + e.message);
    }
  }

  saveOne(callLog: CallLog, callback: (Contact?: number) => void) {
    if (callLog.id <= 0) {
      this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let callLogDelta = new CallLogDelta(callLog);
        dataAbilityHelper.insert(Calls.CALL_LOG_URI, callLogDelta.createValuesBucket()).then((data: number) => {
          callback(data);
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, `saveOne insert error: ${error?.message}`);
          callback();
        });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `saveOne error: ${error?.message}`);
        callback();
      });
    } else {
      callback();
    }
  }

  async setSwitchState(callback: Function) {
    let isShowedFraudBanners = await sharedPreferencesUtils.getFromPreferences('showedFraudBanners', false) as boolean;
    if (!isShowedFraudBanners) {
      HiLog.i(TAG, 'getSwitchState start ');
      let context = getContext(this) as common.UIAbilityContext;
      let dataShareHelper: dataShare.DataShareHelper =
        await dataShare.createDataShareHelper(context, Calls.SETTING_MODE_URI);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('KEYWORD', Calls.SPAMSHIELD_SMART_IDENTITY_SWITCH);
      dataShareHelper.query(Calls.SETTING_MODE_URI, condition, [])
        .then((resultSet: DataShareResultSet) => {
          try {
            if (resultSet.rowCount > 0) {
              resultSet.goToFirstRow();
              this.state = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
              HiLog.i(TAG, 'getSwitchState success value: ' + ' - ' + this.state);
            } else {
              HiLog.e(TAG, 'getSwitchState null ');
              this.state = 0;
            }
            callback(this.state);
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        }).catch((error: Error) => {
          HiLog.e(TAG, `query error: ${error?.message}`);
      })
    }
  }

  clear(callback: (Contact?: number) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.notEqualTo(Calls.ANSWER_STATE, 6);
      dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then((data: number) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `clear delete error: ${error?.message}`);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `clear error: ${error?.message}`);
      callback();
    });
  }

  deleteById(id: number) {
    return false;
  }

  deleteByIdIn(ids: number[], phoneNumbers: string[], callback: (Contact?: number) => void) {
    HiLog.i(TAG, 'deleteByIdIn start!');
    if (ArrayUtil.isEmpty(ids) && ArrayUtil.isEmpty(phoneNumbers)) {
      callback();
      return;
    }
    sharedPreferencesUtils.getFromPreferences('isCallSettingDataChangeGroupByValue', 'time').then((mergeRule) => {
      HiLog.i(TAG, 'mergeRule: ' + mergeRule);
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        let tempNumber: string[] = [];
        let tempOriginalNumber: string[] = [];
        let tempFormatNumber: string[] = [];
        let tempNumberMap: Map<string, string> = new Map();
        let condition = new dataSharePredicates.DataSharePredicates();
        if (mergeRule === 'contacts' && !ArrayUtil.isEmpty(phoneNumbers)) {
          if (phoneNumbers.indexOf('') > -1) {
            // 私人号码 phone_number is null
            condition.beginWrap();
            condition.isNull(Calls.PHONE_NUMBER);
            condition.or();
            condition.in(Calls.PHONE_NUMBER, phoneNumbers);
            condition.or();
            condition.in(Calls.ID, ids);
            condition.endWrap();
          } else {
            condition.in(Calls.PHONE_NUMBER, phoneNumbers);
            condition.or();
            condition.in(Calls.ID, ids);
          }
        } else {
          condition.in(Calls.ID, ids);
        }
        dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, [Calls.PHONE_NUMBER, Calls.FORMAT_PHONE_NUMBER])
          .then((resultSet: DataShareResultSet) => {
            try {
              if (resultSet.rowCount <= 0 || !resultSet.goToFirstRow()) {
                HiLog.i(TAG, 'findRawIdById resultSet count 0');
                return;
              }
              do {
                let originNumber = resultSet.getString(resultSet.getColumnIndex(Calls.PHONE_NUMBER));
                let formatNumber = resultSet.getString(resultSet.getColumnIndex(Calls.FORMAT_PHONE_NUMBER));
                let tempNumberToAdd = formatNumber ? formatNumber : originNumber;
                if (!tempNumber.includes(tempNumberToAdd)) {
                  tempNumber.push(tempNumberToAdd);
                  tempNumberMap.set(tempNumberToAdd, originNumber)
                }
                if (originNumber && !tempOriginalNumber.includes(originNumber)) {
                  tempOriginalNumber.push(originNumber)
                }
                if (formatNumber && !tempFormatNumber.includes(formatNumber)) {
                  tempFormatNumber.push(formatNumber)
                }
              } while (resultSet.goToNextRow());
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
            dataAbilityHelper.delete(Calls.CALL_LOG_URI, condition).then((data: number) => {
              let tempCondition = new dataSharePredicates.DataSharePredicates();
              tempCondition.in(Calls.PHONE_NUMBER, tempOriginalNumber);
              tempCondition.or();
              tempCondition.in(Calls.FORMAT_PHONE_NUMBER, tempFormatNumber)
              dataAbilityHelper.query(Calls.CALL_LOG_URI, tempCondition,
                [Calls.FORMAT_PHONE_NUMBER, Calls.PHONE_NUMBER]).then(async (resultSet: DataShareResultSet) => {
                try {
                  let numberQueryed: string[] = [];
                  if (resultSet.goToFirstRow()) {
                    do {
                      numberQueryed.push(resultSet.getString(resultSet.getColumnIndex(Calls.FORMAT_PHONE_NUMBER)))
                      numberQueryed.push(resultSet.getString(resultSet.getColumnIndex(Calls.PHONE_NUMBER)))
                    } while (resultSet.goToNextRow())
                  }
                  for (let i = 0; i < tempNumber.length; i++) {
                    if (numberQueryed.includes(tempNumber[i]) ||
                    numberQueryed.includes(tempNumberMap.get(tempNumber[i]) as string)) {
                      HiLog.i(TAG, 'no need to clear chatbox');
                    } else {
                      try {
                        HiLog.i(TAG, 'need to clear chatbox');
                        const uri = 'datashare:///com.ohos.newcallingdcsdk';
                        const helper =
                          await dataShare.createDataShareHelper(this.context as common.UIAbilityContext, uri);
                        const predicates = new dataSharePredicates.DataSharePredicates();
                        let tempUri = uri + '?number=' + tempNumber[i];
                        helper.delete(encodeURIComponent(tempUri), predicates);
                      } catch (e) {
                        HiLog.e(TAG, 'deleteByIdIn chatbox error: ', e.message);
                      }
                    }
                  }
                } finally {
                  ObjectUtil.closeResultSet(resultSet);
                }
              }).catch((error: BusinessError) => {
                HiLog.e(TAG, 'deleteByIdIn error: ', error.message);
              })
              callback(data);
            }).catch((error: BusinessError) => {
              HiLog.e(TAG, 'deleteByIdIn error: ', error.message);
              callback();
            });
          })
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'getDataAbilityHelper error: ' + error.message);
        callback();
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'isCallSettingDataChangeGroupByValue  error: ' + error.message);
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

  // request settingData calllogmergetype SQL --start
  async getSettingDataAbilityHelper() {
    if (this.settingDataShareHelper == undefined) {
      let dataShareHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(this.context as Context,
        Calls.SETTING_DATA_PROXY_URI);
      this.settingDataShareHelper = dataShareHelper;
    }
    return this.settingDataShareHelper;
  }

  public settingDataObservers: Array<() => void> = [];

  public settingCallbackWithTimeout = () => {
    HiLog.w(TAG, 'settingCallbackWithTimeout changed: notify');
    if (this.settingCallbackTimeId > 0) {
      clearTimeout(this.settingCallbackTimeId);
    }
    this.settingCallbackTimeId = setTimeout(() => {
      HiLog.w(TAG, 'settingCallbackWithTimeout changed: invoke');
      this.settingCallbackTimeId = -1;
      this.settingCallback();
    }, 200);
  };

  public settingCallback = () => {
    hiTraceMeter.startTrace('settingCallback', 1);
    HiLog.i(TAG, 'settingCallback changed: Notifying observers...');
    this.getSettingDataAbilityHelper().then((settingHelper: dataShare.DataShareHelper) => {
      let columns = ['*'];
      let da = new dataSharePredicates.DataSharePredicates();
      da.equalTo('KEYWORD', 'settings.telephony.calllogmergetype');
      settingHelper.query(Calls.SETTING_DATA_PROXY_URI, da, columns).then(async (resultSet: DataShareResultSet) => {
        try {
          if (resultSet.rowCount <= 0) {
            return;
          }
          resultSet.goToFirstRow();
          let groupByValue: string = resultSet.getString(resultSet.getColumnIndex('VALUE'));
          // Just update groupByValue value
          let oldGroupByValue: string =
            await sharedPreferencesUtils.getFromPreferences('isCallSettingDataChangeGroupByValue', '') as string;
          HiLog.i(TAG, 'settingCallback groupByValue :' + groupByValue)
          if (oldGroupByValue == groupByValue) {
            HiLog.i(TAG,
              'settingCallback,groupByValue equals oldGroupByValue,do not need to update and observer :' + groupByValue)
            return;
          }
          sharedPreferencesUtils.saveToPreferences('isCallSettingDataChangeGroupByValue', groupByValue);
          for (const observer of this.settingDataObservers) {
            observer();
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'settingCallback settingHelper query error: ' + error?.message + ', stack: ' + error?.stack);
      })
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'settingCallback getSettingDataAbilityHelper error: ' + error?.message + ', stack: ' + error?.stack);
    }).finally(() => {
      hiTraceMeter.finishTrace('settingCallback', 1);
    })
  }

  registerCallLogDataChangeBySettingData() {
    this.getSettingDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.on('dataChange', Calls.SETTING_DATA_PROXY_URI, this.settingCallbackWithTimeout);
        HiLog.i(TAG, 'registerCallLogDataChangeBySettingData success')
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `registerCallLogDataChangeBySettingData error: ${error?.message}`);
    });
  }

  unregisterCallLogDataChangeBySettingData() {
    this.getSettingDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.off('dataChange', Calls.SETTING_DATA_PROXY_URI, this.settingCallbackWithTimeout);
        HiLog.i(TAG, 'unregisterCallLogDataChangeBySettingData success')
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `unregisterCallLogDataChangeBySettingData error: ${error?.message}`);
    });
  }

  registerSettingDataChangeObserver(observer: () => void): void {
    if (!observer) {
      HiLog.i(TAG, `registerSettingDataChangeObserver: observer is null.`);
      return;
    }
    if (this.settingDataObservers.length == 0) {
      this.registerCallLogDataChangeBySettingData()
    }
    const isExist = this.settingDataObservers.includes(observer);
    if (isExist) {
      return HiLog.i(TAG, 'registerSettingDataChangeObserver: Observer has been attached already.');
    }
    HiLog.i(TAG, 'registerSettingDataChangeObserver: Attached an observer.');
    this.settingDataObservers.push(observer);
  }

  unRegisterSettingDataChangeObserver(observer: () => void) {
    const observerIndex = this.settingDataObservers.indexOf(observer);
    if (observerIndex === -1) {
      HiLog.i(TAG, 'unRegisterSettingDataChangeObserver: Nonexistent observer.');
      return
    }
    this.settingDataObservers.splice(observerIndex, 1);
    HiLog.i(TAG, 'unRegisterSettingDataChangeObserver: Detached an observer.');
    if (this.settingDataObservers.length == 0) {
      this.unregisterCallLogDataChangeBySettingData();
    }
  }

  updateCallLogDisplayName(contactNameMap: HashMap<string, ContactNameNumberInfo | string>) {
    HiLog.w(TAG, `updateCallLogDisplayName  start time: ${(new Date()).valueOf()
      }, contactNameMap length: ${contactNameMap.length}`);
    if (contactNameMap.length <= 0) {
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      HiLog.w(TAG, `updateCallLogDisplayName getDataAbilityHelper success.`);
      contactNameMap.forEach((contactInfo, phoneNumber) => {
        let displayName: string = '';
        let contactId: number = -1;
        if (typeof contactInfo === 'string') {
          displayName = contactInfo;
        } else {
          displayName = contactInfo?.name ?? '';
          contactId = contactInfo?.contactId ?? -1;
        }
        if (StringUtil.isEmpty(displayName) || StringUtil.isEmpty(phoneNumber)) {
          return;
        }
        let condition = new dataSharePredicates.DataSharePredicates();
        condition.beginWrap()
        condition.equalTo(Calls.PHONE_NUMBER, phoneNumber)
        condition.or()
        condition.equalTo(Calls.FORMAT_PHONE_NUMBER, phoneNumber)
        condition.endWrap()
        condition.and()
        condition.beginWrap()
        condition.isNull(Calls.DISPLAY_NAME)
        condition.or()
        condition.equalTo(Calls.DISPLAY_NAME, '')
        condition.endWrap()

        let insertValues: Record<string, string | number> = {
          'display_name': displayName,
        };
        if (contactId > 0) {
          insertValues.quicksearch_key = contactId.toString();
          insertValues.extra1 = insertValues.quicksearch_key;
        }
        let ret = dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, insertValues);
        HiLog.w(TAG, `updateCallLogDisplayName update. phoneNumber: ${StringUtil.maskSensitiveInfo(phoneNumber)
        }, name: ${StringUtil.maskSensitiveInfo(displayName)}, quicksearch_key: ${contactId}, ret: ${ret}`);
      })
      HiLog.w(TAG, `updateCallLogDisplayName end.`);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `updateCallLogDisplayName error: ${error.message}`);
    });
  }

  handleQueryCallLogData(actionData: AllCallsGetActionData,
    callback: (Contact: CallLog[]) => void, groupByValue: string, isInterceptionCalls?: boolean) {
    HiLog.i(TAG, `handleQueryCallLogData  start time:${(new Date()).valueOf()}`);
    let datashareHelper: Promise<dataShare.DataShareHelper>;
    // 是否使用
    let businessStr = actionData.isProxyQuery ? ' proxy query ' : ' ';
    let queryUrl = actionData.isProxyQuery ? Calls.CONTENT_URI_PROXY_QUERY_CALLLOG : Calls.CALL_LOG_URI;
    if (actionData.isProxyQuery) {
      HiLog.w(TAG, 'proxyQuery');
      datashareHelper = this.getDataAbilityHelperProxy();
    } else {
      datashareHelper = this.getDataAbilityHelper();
    }
    try {
      datashareHelper?.then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let condition = new dataSharePredicates.DataSharePredicates();
        if (!isInterceptionCalls) {
          this.getCallsDataConditionFilter(condition);
        }
        //如果是骚扰拦截通话记录查询，只查询 answer_state 字段为 6 的行，其余情况过滤掉answer_state 字段等于 6
        if (isInterceptionCalls) {
          condition.and();
          condition.equalTo(Calls.ANSWER_STATE, 6);
        } else {
          condition.and();
          condition.notEqualTo(Calls.ANSWER_STATE, 6);
        }
        if (actionData.page !== undefined && actionData.page > 0) {
          let offset = ArrayUtil.getOffsetForSession(actionData.page);
          condition.limit(actionData.limit, offset);
        }
        // 按联系人分组
        if (groupByValue == 'contacts') {
          // 按联系人分组后，分组后的记录，需要按照最近记录的时间排序；
          // 通过 order by max(create_time) desc， sqllite正确执行，而且查询的create_time值是max(create_time)
          // 通过order by create_time desc, 查询的create_time值是min(create_time)
          condition.orderByDesc('max(' + Calls.CREATE_TIME + ')');
          condition
            .groupBy([Calls.PHONE_NUMBER])
            .distinct()
        } else {
          condition.orderByDesc(Calls.CREATE_TIME);
        }

        let hasDisplayNameCount = 0;
        dataAbilityHelper
          .query(queryUrl, condition, Calls.getSearchFields())
          .then((resultSet: DataShareResultSet) => {
            try {
              let rst: CallLog[] = [];
              if (resultSet.rowCount === 0) {
                if (actionData.isProxyQuery) {
                  HiLog.e(TAG, `use proxy query result is empty, will try query with no proxy.`);
                  // 如果是静默查询且结果为空，尝试非静默查询
                  actionData.isProxyQuery = false;
                  this.handleQueryCallLogData(actionData, callback, groupByValue, isInterceptionCalls);
                  return; // 确保不再继续执行后续代码
                } else {
                  callback(rst);
                }
              } else {
                resultSet.goToFirstRow();
                do {
                  let builder = CallLogBuilder.fromResultSet(resultSet);
                  if (!StringUtil.isEmpty(builder.displayName)) {
                    hasDisplayNameCount++;
                  }
                  if (builder.id > 0) {
                    rst.push(new CallLog(builder));
                  }
                } while (resultSet.goToNextRow());
                callback(rst);
              }
              HiLog.w(TAG, businessStr + `handleQueryCallLogData  ` +
                `allCallogCount == ${rst.length},  hasDisplayNameCount == ${hasDisplayNameCount}`);
              if (actionData.isProxyQuery) {
                this.closeDataAbilityHelperProxy();
              }
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
          .catch((error: BusinessError) => {
            if (actionData.isProxyQuery) {
              HiLog.e(TAG, `use proxy query error, will try query with no proxy.`);
              // 如果是静默查询异常，尝试静默查询
              actionData.isProxyQuery = false;
              this.handleQueryCallLogData(actionData, callback, groupByValue, isInterceptionCalls);
              return; // 确保不再继续执行后续代码
            } else {
              // 联系人故障打点-查询通话记录列表异常
              faultContactParams.FAULT_INFO = error.message;
              DotUtil.getInstance()
                .reportFaultEvent(faultContactParams, dotCommon.faultEventName.CALLLOG_DISPLAY_ERROR);
              HiLog.e(TAG, businessStr + `handleQueryCallLogData query error: ${error.message}, code: ${error?.code}`);
              emitter.emit(EmitterConstant.GET_ALL_CALLS_EMITTER_ID);
              if (actionData.isProxyQuery) {
                dataAbilityHelper?.close();
              }
              callback([]);
            }
          });
      }).catch((error: BusinessError) => {
        HiLog.e(TAG,
          businessStr + `handleQueryCallLogData getDataAbilityHelper error: ${error.message}, code: ${error?.code}`);
        emitter.emit(EmitterConstant.GET_ALL_CALLS_EMITTER_ID);
        callback([]);
      });
    } catch (error) {
      HiLog.e(TAG, businessStr + `handleQueryCallLogData datashare query error: ${error?.message}`);
      callback([]);
    }
  }

  // request settingData calllogmergetype SQL --end
  async findAll(actionData: AllCallsGetActionData,
    callback: (Contact: CallLog[]) => void, isInterceptionCalls?: boolean) {
    let isCallSettingDataChangeGroupByValue: string =
      (await sharedPreferencesUtils.getFromPreferences('isCallSettingDataChangeGroupByValue', 'time')) as string;
    if (actionData.isProxyQuery) {
      this.handleQueryCallLogData(actionData, callback, isCallSettingDataChangeGroupByValue, isInterceptionCalls);
      return;
    }

    let newCallback: (Contact: CallLog[]) => void = (data: CallLog[]) => {
      callback(data);
      // 因退后台被管控查询失败时，标记
      if (data !== undefined && data?.length === 0) {
        HiLog.i(TAG, `set isQueryTaskFinished false`);
        this.isQueryTaskFinished = false;
      } else {
        HiLog.i(TAG, `set isQueryTaskFinished true`);
        this.isQueryTaskFinished = true;
      }
    };
    this.handleQueryCallLogData(actionData, newCallback, isCallSettingDataChangeGroupByValue, isInterceptionCalls);
  }

  handleQueryFristMissedCallLogData(actionData: LooseObject, callback: Function, groupByValue: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      HiLog.i(TAG, 'findFristMissedCall RawContacts.FAVORITE:' + RawContacts.FAVORITE);
      condition.equalTo(Calls.IS_READ, 1)
        .and()
        .notEqualTo(Calls.ANSWER_STATE, 6)
        .orderByDesc(Calls.CREATE_TIME)
        .limit(1, 0);
      if (groupByValue == 'contacts') {
        condition
          .groupBy([Calls.PHONE_NUMBER])
          .distinct();
      }
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        try {
          let rst: CallLog[] = [];
          if (resultSet.rowCount === 0) {
            callback(rst);
          } else {
            resultSet.goToFirstRow();
            do {
              let builder = CallLogBuilder.fromResultSet(resultSet);
              HiLog.i(TAG, 'findFristMissedCall builder:');

              if (builder.id > 0) {
                rst.push(new CallLog(builder));
              }
            } while (resultSet.goToNextRow());
            HiLog.i(TAG, 'findFristMissedCall rst size:' + rst?.length);
            callback(rst);
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findFristMissedCall error:' + error?.message);
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findFristMissedCall error:%s' + error?.message);
      callback([]);
    });

  }

  async findFristMissedCall(actionData: LooseObject, callback: Function) {
    HiLog.i(TAG, 'findFristMissedCall');
    this.handleQueryFristMissedCallLogData(actionData, callback, 'all');
  }

  findByFeature(feature: number) {
    return [];
  }

  findByNumberIn(actionData: FindByNumberActionData, callback: (Contact: CallLog[]) => void) {
    HiLog.w(TAG, `findByNumberIn start, numbers length is ${actionData?.numbers?.length
    }, contactId: ${actionData?.contactId}`);
    if (ArrayUtil.isEmpty(actionData.numbers)) {
      callback([]);
      return;
    }
    let targetContactId = actionData.contactId ?? -1;
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let realPhoneNumbers: string[] = [];
      let countryId = CountryIdUtil.getCountryId();
      let options: call.NumberFormatOptions = {
        countryCode: countryId,
      }
      actionData.numbers.forEach(item => {
        let tempPhone = StringUtil.removeSpace(item.toString());
        //判断大于7
        if (tempPhone.length >= NumberMatch.QUERY_NUM_LENGTH_LIMIT) {
          tempPhone = NumberMatch.getInstance().getQueryNum(tempPhone);
        }
        realPhoneNumbers.push(tempPhone);
      });

      let condition = new dataSharePredicates.DataSharePredicates();
      this.getCallsDataConditionFilter(condition);
      condition.beginWrap();
      if (targetContactId > 0) {
        condition.equalTo(Calls.QUICK_SEARCH_KEY, targetContactId);
        condition.or();
      }
      for (let i = 0; i < realPhoneNumbers.length; i++) {
        condition.endsWith(Calls.PHONE_NUMBER, realPhoneNumbers[i]);
        if (i < realPhoneNumbers.length - 1) {
          condition.or();
        } else {
          condition.endWrap();
        }
      }
      condition.and();
      condition.notEqualTo(Calls.ANSWER_STATE, 6);
      condition.orderByDesc(Calls.CREATE_TIME);

      if (actionData.page !== undefined && actionData.page > 0) {
        const offset = ArrayUtil.getOffsetForSession(actionData.page);
        condition.limit(actionData.limit, offset);
      }

      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, Calls.getSearchFields())
        .then(async (resultSet: DataShareResultSet) => {
          try {
            HiLog.w(TAG, `findByNumberIn query end, resultSet length is ${resultSet.rowCount}`);
            let rst: CallLog[] = [];
            if (resultSet.rowCount === 0) {
              callback(rst);
            } else {
              let phoneNumberSet: Set<string> = new Set();
              //临时方案，等待两周后通话接口更新在改。
              for (let phoneNumber of actionData.numbers) {
                phoneNumberSet.add(phoneNumber);
                let formatPhoneNumber = await call.formatPhoneNumberToE164(StringUtil.removeSpace(phoneNumber),
                  options.countryCode ? options.countryCode : 'CN');
                if (!StringUtil.isEmpty(formatPhoneNumber)) {
                  phoneNumberSet.add(formatPhoneNumber);
                }
              }
              HiLog.w(TAG, `phoneNumberSet size: ${phoneNumberSet.size}`)
              resultSet.goToFirstRow();
              do {
                let builder = CallLogBuilder.fromResultSet(resultSet);
                if (builder.features !== -1 && builder.id > 0) {
                  let callLog = new CallLog(builder);
                  let quickSearchKey = -1;
                  if (!StringUtil.isEmpty(callLog.quickSearchKey)) {
                    quickSearchKey = Number.parseInt(callLog.quickSearchKey);
                  }
                  if ((targetContactId > 0 && quickSearchKey === targetContactId) ||
                  phoneNumberSet.has(callLog.phoneNumber) || phoneNumberSet.has(callLog.formatPhoneNumber)) {
                    rst.push(callLog);
                  }
                }
              } while (resultSet.goToNextRow());

              HiLog.w(TAG, `findByNumberIn end, rst length is ${rst.length}`);
              callback(rst);
            }
          } finally {
            ObjectUtil.closeResultSet(resultSet);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `findByNumberIn query error: ${error?.message}`);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `findByNumberIn getDataAbilityHelper error: ${error?.message}`);
      callback([]);
    });
  }

  /**
   * 清除未接来电时将所有未读置为已读
   *
   * @param phoneNum
   */
  markMissedCallLogAsRead(phoneNum?: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and()
        .equalTo(Calls.CALL_DIRECTION, 0)
        .and()
        .notEqualTo(Calls.ANSWER_STATE, 6);
      if (phoneNum && !StringUtil.isEmpty(phoneNum)) {
        condition.and().equalTo(Calls.PHONE_NUMBER, phoneNum);
      }
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, ['is_read']).then(resultSet => {
        try {
          HiLog.w(TAG, 'markMissedCallLogAsRead rowCount: ' + resultSet.rowCount);
          if (resultSet.rowCount > 0) {
            dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, {
              'is_read': 1
            }).then((value: number) => {
              HiLog.i(TAG, 'markMissedCallLogIsRead update succ :%s', value.toString());
            }).catch((error: BusinessError) => {
              HiLog.e(TAG, 'markMissedCallLogIsRead error:%s', error?.message);
            });
            this.updatePrivacyTagOfMissedCall(dataAbilityHelper, phoneNum);
          } else {
            HiLog.i(TAG, 'markMissedCallLogAsRead skip')
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'markMissedCallLogIsRead error:%s' + error?.message);
    });
  }

  updatePrivacyTagOfMissedCall(dataAbilityHelper: dataShare.DataShareHelper, phoneNum?: string) {
    const condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(Calls.CALL_DIRECTION, 0)
      .and()
      .notEqualTo(Calls.ANSWER_STATE, 6)
      .and()
      .equalTo(Calls.PRIVACY_TAG, 0);
    if (phoneNum && !StringUtil.isEmpty(phoneNum)) {
      condition.and().equalTo(Calls.PHONE_NUMBER, phoneNum);
    }
    dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, { PRIVACY_TAG: 1 }).then((value: number) => {
      HiLog.i(TAG, 'updatePrivacyTagOfMissedCall update succ :%s', value.toString());
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updatePrivacyTagOfMissedCall error:%s', error?.message);
    });
  }

  /**
   * 进入拦截记录页面，将所有answer_state 等于6 的通话记录未读置为已读
   */
  markInterceptionMissedCallsAsRead() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and()
        .equalTo(Calls.ANSWER_STATE, 6);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, ['is_read']).then(resultSet => {
        try {
          HiLog.i(TAG, 'markInterceptionMissedCallAsRead rowCount: ' + resultSet.rowCount);
          if (resultSet.rowCount > 0) {
            dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, {
              'is_read': 1
            }).then((value: number) => {
              HiLog.i(TAG, 'markInterceptionMissedCallAsRead update succ :%s', value.toString());
            }).catch((error: BusinessError) => {
              HiLog.e(TAG, 'markInterceptionMissedCallAsRead error:%s', error?.message);
            });
          } else {
            HiLog.i(TAG, 'markInterceptionMissedCallAsRead skip')
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'markInterceptionMissedCallAsRead error:%s' + error?.message);
    });
  }

  /**
   * Is exist call interception log.
   *
   * @param contextual environment
   * @returns true is exist call interception log, otherwise false
   */
  isExistInterceptionCallLog(): Promise<boolean> {
    return new Promise<boolean>(async (resolve) => {
      let statTime = Date.now();
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        let condition = new dataSharePredicates.DataSharePredicates();
        condition.equalTo(Calls.ANSWER_STATE, CALL_CARRIER_INTERCEPTION);
        condition.limit(1, 0);
        dataAbilityHelper
          .query(Calls.CALL_LOG_URI, condition, [])
          .then((resultSet) => {
            try {
              if (resultSet === undefined) {
                HiLog.e(TAG, 'isExistInterceptionCallLog: get undefined resultSet');
                return resolve(true);
              }
              HiLog.w(TAG,
                `query interceptionCallLog time: ${(Date.now() - statTime)}, interceptionCallLog: ${resultSet.rowCount >
                  0}`);
              return resolve(resultSet.rowCount > 0);
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          })
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'isExistInterceptionCallLog logMessage insert error: ' + error?.message);
        return resolve(true);
      });
    })
  }

  findMissedCallLogUnread(callback: (Contact: CallLog[]) => void, lastId?: number, date?: number) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.IS_READ, 0)
        .and()
        .equalTo(Calls.CALL_DIRECTION, 0)
        .and()
        .equalTo(Calls.ANSWER_STATE, 0);
      // 有时间，用时间比较，没时间，用id比较
      if (date && date > -1) {
        condition.and().greaterThan(Calls.CREATE_TIME, date);
      } else if (lastId && lastId > -1) {
        // 根据lastId过滤
        condition.and().greaterThan(Calls.ID, lastId);
      }
      condition.orderByDesc(Calls.ID);
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        try {
          HiLog.w(TAG, 'findMissedCallLogUnread rowCount: ' + resultSet.rowCount);
          let rst: CallLog[] = [];
          if (resultSet.rowCount === 0) {
            callback(rst);
          } else {
            resultSet.goToFirstRow();
            do {
              let builder = CallLogBuilder.fromResultSet(resultSet);
              if (builder.id > 0) {
                rst.push(new CallLog(builder));
              }
            } while (resultSet.goToNextRow());
            callback(rst);
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'findMissedCallLogUnread resultSet parse error:%s', error?.message);
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'findMissedCallLogUnread error:%s' + error?.message);
      callback([]);
    });
  }

  notifyChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.notifyChange(Calls.CALL_LOG_URI).then((data: void) => {
          HiLog.i(TAG, 'notifyChange success')
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'notifyChange error:%s' + error?.message);
        })
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
    });
  }

  public observers: Array<() => void> = [];
  public callback = () => {
    HiLog.d(TAG, 'CallLog changed: Notifying observers...');
    for (const observer of this.observers) {
      observer();
    }
  }

  private registerCallLogDataChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      HiLog.w(TAG, 'registerCallLogDataChange getDataAbilityHelper success')
      if (dataAbilityHelper && !(AppStorage.get('callLogDataChange') ?? false)) {
        dataAbilityHelper.on('dataChange', Calls.CALL_LOG_URI, this.callback);
        AppStorage.setOrCreate('callLogDataChange', true);
        HiLog.w(TAG, 'registerCallLogDataChange success')
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `registerCallLogDataChange getDataAbilityHelper error: ${error.message}`);
    });
  }

  private unregisterCallLogDataChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      HiLog.w(TAG, 'unregisterCallLogDataChange getDataAbilityHelper success')
      if (dataAbilityHelper) {
        dataAbilityHelper.off('dataChange', Calls.CALL_LOG_URI, this.callback);
        AppStorage.setOrCreate('callLogDataChange', false);
        HiLog.w(TAG, 'unregisterCallLogDataChange success')
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `unregisterCallLogDataChange getDataAbilityHelper error: ${error.message}`);
    });
  }

  registerCallLogDataChangeRetry() {
    HiLog.w(TAG, 'registerCallLogDataChangeRetry start')
    if (this.observers.length !== 0 && !(AppStorage.get('callLogDataChange') ?? false)) {
      this.registerCallLogDataChange()
    }
  }

  registerDataChangeObserver(observer: () => void): void {
    HiLog.w(TAG, `registerDataChangeObserver start`);
    if (!observer) {
      HiLog.w(TAG, `registerDataChangeObserver: observer is null.`);
      return;
    }
    if (this.observers.length == 0) {
      this.registerCallLogDataChange()
    }
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return HiLog.w(TAG, 'registerDataChangeObserver: Observer has been attached already.');
    }
    this.observers.push(observer);
    HiLog.w(TAG, 'registerDataChangeObserver: Attached an observer. length：' + this.observers.length);
  }

  unRegisterDataChangeObserver(observer: () => void) {
    HiLog.w(TAG, `unRegisterDataChangeObserver start`);
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      HiLog.w(TAG, 'unRegisterDataChangeObserver: Nonexistent observer.');
      return
    }
    this.observers.splice(observerIndex, 1);
    HiLog.w(TAG, 'unRegisterDataChangeObserver: Detached an observer. length：' + this.observers.length);
    if (this.observers.length == 0) {
      this.unregisterCallLogDataChange();
    }
  }

  findSearch(isAll: boolean, actionData: CallHistorySearchGetActionData, callback: (Contact?: CallLog[]) => void) {
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.notEqualTo(Calls.ANSWER_STATE, 6);
      if (isAll) {
        condition
          .beginWrap()
          .in(Calls.DISPLAY_NAME, actionData.nameArray)
          .or()
          .like(Calls.PHONE_NUMBER, `%${actionData.teleNumber}%`)
          .endWrap()
          .and()
          .orderByDesc(Calls.CREATE_TIME)
      } else {
        condition
          .beginWrap()
          .in(Calls.DISPLAY_NAME, actionData.nameArray)
          .or()
          .like(Calls.PHONE_NUMBER, `%${actionData.teleNumber}%`)
          .endWrap()
          .and()
          .orderByDesc(Calls.CREATE_TIME)
          .and()
          .limit(100, 0);
      }
      dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, null).then((resultSet: DataShareResultSet) => {
        try {
          let rst: CallLog[] = [];
          if (resultSet.rowCount === 0) {
            callback(rst);
          } else {
            resultSet.goToFirstRow();
            do {
              let builder = CallLogBuilder.fromResultSet(resultSet);
              if (builder.id > 0) {
                rst.push(new CallLog(builder));
              }
            } while (resultSet.goToNextRow());
            callback(rst);
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      }).catch((error: BusinessError) => {
        HiLog.w(TAG, 'findAll error:' + error?.message);
        callback([]);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'error:%s' + error?.message);
      callback([]);
    });
  }

  getCallsDataConditionFilter(condition: dataSharePredicates.DataSharePredicates) {
    // 过滤运营商通话，FEATURES < 1000
    condition.lessThan(Calls.FEATURES, carrierCallFeaturesLimit);
  }

  UpdateCallLogWithYellowPageInfo(phoneNumber: string, markType: string, markContent: string) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Calls.PHONE_NUMBER, phoneNumber)
      dataAbilityHelper.update(Calls.CALL_LOG_URI, condition, {
        mark_type: markType,
        mark_content: markContent
      }).then((value: number) => {
        HiLog.w(TAG, `UpdateCallLogWithYellowPageInfo update succ: ${value}`);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `UpdateCallLogWithYellowPageInfo update error: ${error.message}`);
      }).finally(() => {
        HiLog.w(TAG, `UpdateCallLogWithYellowPageInfo update. phoneNumber: ${StringUtil.maskSensitiveInfo(phoneNumber)
        }, markContent: ${StringUtil.maskSensitiveInfo(markContent)}, markType: ${markType}`);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `UpdateCallLogWithYellowPageInfo getDataAbilityHelper error: ${error.message}}`);
    });
  }

  queryCallSharingInitMode(context: common.UIAbilityContext) {
    if (!EnvironmentProp.isTabletOrPC()) {
      return;
    }

    if (AppStorage.get('isNoMissFormCard')) {
      HiLog.i(TAG, 'Has been initialized by PageManager !');
      return;
    }

    queryInitSettingMode(context, '');
  }

  /**
   * Query call logs by phone number for dialer search
   * @param searchKey - Search keyword (phone number)
   * @param contactNameKeySet - Set of contact names already searched (for deduplication)
   * @param searchPhoneNumberSet - Set of phone numbers already searched (for deduplication)
   * @param offset - Offset for pagination
   * @param limit - Limit for pagination
   * @param context - UIAbility context
   * @returns Promise<CallLogTemp[]> - Array of call log search results
   */
  async queryCallLogByPhoneNumberForDialer(searchKey: string, contactNameKeySet: Set<string>,
    searchPhoneNumberSet: Set<string>, offset: number, limit: number,
    context?: common.UIAbilityContext): Promise<CallLogTemp[]> {
    const TAG_METHOD = 'queryCallLogByPhoneNumberForDialer';
    let resultList: CallLogTemp[] = [];
    if (!context || !searchKey) {
      HiLog.e(TAG, `${TAG_METHOD} invalid parameters.`);
      return [];
    }
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      HiLog.i(TAG, `${TAG_METHOD} start: searchKey length=${searchKey.length}, offset=${offset}, limit=${limit}`);
      if (context) {
        this.init(context);
      }
      let dataAbilityHelper: dataShare.DataShareHelper = await this.getDataAbilityHelper();

      // Build query condition
      let condition = new dataSharePredicates.DataSharePredicates();
      // Filter out blocked calls
      condition.notEqualTo(Calls.ANSWER_STATE, 6);
      // Apply carrier call filter
      this.getCallsDataConditionFilter(condition);
      // Search by phone number (like query)
      condition.and();
      condition.like(Calls.PHONE_NUMBER, `%${searchKey}%`);
      // Order by create time descending
      condition.orderByDesc(Calls.CREATE_TIME);
      // Apply pagination
      if (limit > 0) {
        condition.limit(limit, offset);
      }
      resultSet = await dataAbilityHelper.query(Calls.CALL_LOG_URI, condition, Calls.getSearchFields());

      if (resultSet === undefined) {
        HiLog.e(TAG, `${TAG_METHOD} resultSet is undefined.`);
        return [];
      }
      if (resultSet.rowCount === 0) {
        HiLog.i(TAG, `${TAG_METHOD} rowCount is zero.`);
        return [];
      }

      const regex: RegExp = new RegExp('<\/?.+?>', 'g');
      resultSet.goToFirstRow();
      do {
        let builder = CallLogBuilder.fromResultSet(resultSet);
        if (builder.id <= 0) {
          continue;
        }
        let phoneNumber = builder.phoneNumber || '';
        let displayName = builder.displayName || '';
        let numberLocation = builder.numberLocation || '';
        let markType = builder.markType || '';
        let markContent = builder.markContent || '';
        let isCloudMark = builder.isCloudMark || 0;
        let markCount = builder.markCount || 0;
        let entityId = builder.id.toString();

        if (!StringUtil.isEmpty(displayName)) {
          // Deduplicate with contact name
          let nameKey = displayName.replace(regex, '');
          if (!contactNameKeySet.has(nameKey)) {
            // Highlight phone number
            let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
            resultList.push(new CallLogTemp(
              entityId,
              displayName,
              highlightPhoneNumber,
              '',
              numberLocation,
              markType,
              markContent,
              isCloudMark,
              markCount,
              0 // DATA_TYPE_TELEPHONE
            ));
            contactNameKeySet.add(nameKey);
          }
        }
        if (StringUtil.isEmpty(displayName)) {
          // Deduplicate with phone number
          let phoneKey = phoneNumber.replace(regex, '');
          if (!searchPhoneNumberSet.has(phoneKey)) {
            // Highlight phone number
            let highlightPhoneNumber = phoneNumber.replace(searchKey, '<em>' + searchKey + '</em>');
            resultList.push(new CallLogTemp(
              entityId,
              '',
              highlightPhoneNumber,
              '',
              numberLocation,
              markType,
              markContent,
              isCloudMark,
              markCount,
              0 // DATA_TYPE_TELEPHONE
            ));
            searchPhoneNumberSet.add(phoneKey);
          }
        }
      } while (resultSet.goToNextRow());

      HiLog.i(TAG, `${TAG_METHOD} end: resultList length=${resultList.length}`);
      return resultList;
    } catch (error) {
      HiLog.e(TAG, `${TAG_METHOD} error: code=${error?.code}, message=${error?.message}`);
      return [];
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }
}

/**
 * Query is in YellowPage
 *
 * @param {Object} context
 * @param {string} query phone numbers
 *
 * @return {boolean} query result
 */
@Concurrent
export async function queryIsInYellowPageByNumber(context: common.UIAbilityContext,
  phoneNumber: string): Promise<boolean> {
  if (StringUtil.isEmpty(phoneNumber)) {
    return false;
  }
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('ContactRepository ', 'Start to query phoneNumbers in yellowPage.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, YellowPage.YELLOW_PAGE_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(YellowPage.NUMBER, phoneNumber);
    resultSet = await dataShareHelper.query(YellowPage.YELLOW_PAGE_VIEW_URI, option, [])
    if (resultSet.rowCount > 0) {
      return true;
    }
    return false;
  } catch (err) {
    HiLog.e('ContactRepository ', `queryYellowPageByNumber error: ${err?.message}, stack: ${err?.stack}`);
    return false;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}

/**
 * Query the format number of recent calls lasting more than 15 seconds
 *
 * @param {Object} context to get data share object
 * @param {string} which need query phone number
 *
 * @return {string | undefined} the format number or undefined
 */
@Concurrent
export async function queryValidFormatNumber(context: common.UIAbilityContext,
  phoneNumber: string): Promise<string | undefined> {
  if (StringUtil.isEmpty(phoneNumber)) {
    return undefined;
  }
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('CallLogRepository ', 'Start to queryValidFormatNumber.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Calls.CONTENT_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(Calls.PHONE_NUMBER, phoneNumber)
      .and()
      .greaterThan(Calls.TALK_DURATION, 15)
      .and()
      .notEqualTo(Calls.ANSWER_STATE, 6)
      .orderByDesc(Calls.CREATE_TIME)
      .limit(1, 0);
    resultSet = await dataShareHelper.query(Calls.CALL_LOG_URI, option, [Calls.FORMAT_PHONE_NUMBER]);
    if (resultSet.rowCount === 0) {
      return undefined;
    }
    if (!resultSet.goToFirstRow()) {
      return undefined;
    }
    let formatNum: string = resultSet.getString(resultSet.getColumnIndex(Calls.FORMAT_PHONE_NUMBER));
    if (formatNum.length === 0) {
      return undefined;
    }
    return formatNum;
  } catch (err) {
    HiLog.e('CallLogRepository ', `queryValidFormatNumber error: ${err?.message}, stack: ${err?.stack}`);
    return undefined;
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}