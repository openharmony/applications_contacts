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

import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import {
  ContactsGlobalThisHelper
} from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';

const SETTING_AIRPLANE_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
const ON_SETTING_AIRPLANE_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=airplane_mode';
const QUERY_AIRPLANE_MODE_KEY = 'settings.telephony.airplanemode';
const TAG = 'AirplaneMode';

let dataShareHelper: dataShare.DataShareHelper | undefined;

/**
 * add AirPlaneMode Listener.
 */
export function addAirPlaneModeListener(callback: Function) {
  HiLog.i(TAG, 'addAirPlaneModeListener');
  try {
    dataShare.createDataShareHelper(ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName),
      SETTING_AIRPLANE_MODE_URI, (err: BusinessError,
                                  data: dataShare.DataShareHelper) => {
        if (err != undefined) {
          HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + err.code + ', message: ' + err.message);
          return;
        }
        dataShareHelper = data;
        try {
          dataShareHelper.on('dataChange', ON_SETTING_AIRPLANE_MODE_URI, () => {
            HiLog.i(TAG, 'addAirPlaneModeListener dataChange');
            queryAirPlaneMode(callback, true);
          });
          queryAirPlaneMode(callback, false);
          HiLog.i(TAG, 'addAirPlaneModeListener success');
        } catch (err) {
          let error: BusinessError = err as BusinessError;
          HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + error.code + ', message: ' + error.message);
        }
      });
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

/**
 * remove AirPlaneMode Listener.
 */
export function removeAirPlaneModeListener() {
  HiLog.i(TAG, 'removeAirPlaneModeListener');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'removeAirPlaneModeListener dataShareHelper null');
    return;
  }
  try {
    dataShareHelper.off('dataChange', ON_SETTING_AIRPLANE_MODE_URI);
    dataShareHelper = undefined;
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG, 'removeAirPlaneModeListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

/**
 * query AirPlaneMode.
 */
export function queryAirPlaneMode(callback: Function, isListen: boolean) {
  HiLog.i(TAG, 'queryAirPlaneMode');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'queryAirPlaneMode dataShareHelper null');
    return;
  }
  let condition = new dataSharePredicates.DataSharePredicates();
  condition.equalTo('KEYWORD', QUERY_AIRPLANE_MODE_KEY);
  try {
    // ID, KEYWORD, VALUE
    dataShareHelper.query(ON_SETTING_AIRPLANE_MODE_URI, condition, []).then((data: DataShareResultSet) => {
      try {
        HiLog.i(TAG, 'queryAirPlaneMode query succeed');
        let obj: Record<string, number | boolean> = {
          'data': -1,
          'isListen': isListen
        }
        if (data.rowCount > 0) {
          data.goToFirstRow()
          HiLog.i(TAG, 'queryAirPlaneMode query succeed return key');
          let res: number = data.getLong(data.getColumnIndex('VALUE'));
          obj.data = res;
          callback(obj);
          return;
        }
        callback(obj);
      } finally {
        ObjectUtil.closeResultSet(data);
      }
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'queryAirPlaneMode query in error: err: ' +  err?.code + ', message: ' + err?.message);
    });
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG, 'queryAirPlaneMode query out error: code: ' + error.code + ', message: ' + error.message);
  }
}

export async function queryAirPlaneStatus(context: common.UIAbilityContext, callback: Function) {
  HiLog.i(TAG, 'queryAirPlaneStatus');
  try {
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, SETTING_AIRPLANE_MODE_URI);
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('KEYWORD', QUERY_AIRPLANE_MODE_KEY);
    dataShareHelper.query(ON_SETTING_AIRPLANE_MODE_URI, condition, []).then((resultSet: DataShareResultSet) => {
      try {
        if (resultSet.rowCount > 0) {
          resultSet.goToLastRow();
          let value: number = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
          HiLog.i(TAG, 'queryAirPlaneStatus success value: ' + value);
          callback(value === 1);
        } else {
          HiLog.i(TAG, 'queryAirPlaneStatus null ');
          callback(false);
        }
      } finally {
        ObjectUtil.closeResultSet(resultSet);
      }
    });
  } catch (err) {
    callback(false);
    HiLog.i(TAG, 'queryAirPlaneStatus failed err: ' + (err as BusinessError).message);
  }
}

