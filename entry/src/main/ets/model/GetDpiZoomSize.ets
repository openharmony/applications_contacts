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
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ObjectUtil } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ObjectUtil';
import { BusinessError } from '@kit.BasicServicesKit';

const SETTING_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
const USER_SET_DPI_VALUE_URI =
  'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=';
const USER_SET_DPI_VALUE = 'user_set_dpi_value';
const TAG = 'GetDpiZoomSize';

let dataShareHelper: dataShare.DataShareHelper | undefined;

export function addUserDpiValueListener() {
  HiLog.i(TAG, 'addUserDpiValueListener!');
  try {
    dataShare.createDataShareHelper(ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName),
      SETTING_MODE_URI, (err: BusinessError,
        data: dataShare.DataShareHelper) => {
        if (err != undefined) {
          HiLog.e(TAG,
            'addUserDpiValueListener error: code: ' + err.code + ', message: ' + err.message + ' , err != undefined');
          return;
        }
        dataShareHelper = data;
        try {
          dataShareHelper.on('dataChange', USER_SET_DPI_VALUE_URI + USER_SET_DPI_VALUE,
            () => {
              HiLog.i(TAG, 'userSetApiValue dataChange');
              queryUserDpiValue();
            });
          HiLog.i(TAG, 'addUserDpiValueListener success');
        } catch (err) {
          let error: BusinessError = err as BusinessError;
          HiLog.e(TAG,
            'addUserDpiValueListener error: code: ' + error.code + ', message: ' + error.message);
        }
      });
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG, 'addUserDpiValueListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

export function removeUserDpiValueListener() {
  HiLog.i(TAG, 'removeUserDpiValueListener');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'removeUserDpiValueListener dataShareHelper null');
    return;
  }
  try {
    dataShareHelper.off('dataChange', USER_SET_DPI_VALUE_URI + USER_SET_DPI_VALUE, () => {
      HiLog.i(TAG, 'removeUserDpiValueListener dataChange');
    });
    dataShareHelper = undefined;
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG,
      'removeUserDpiValueListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

export async function queryUserDpiValue() {
  HiLog.i(TAG, 'queryUserDpiValue');
  let dataShareHelper: dataShare.DataShareHelper =
    await dataShare.createDataShareHelper(ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName), SETTING_MODE_URI);
  let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  condition.equalTo('KEYWORD', USER_SET_DPI_VALUE);
  dataShareHelper.query(SETTING_MODE_URI, condition, [])
    .then((resultSet: DataShareResultSet) => {
      try {
        let apiUserValue: number = -1;
        if (resultSet.rowCount > 0) {
          resultSet.goToFirstRow();
          apiUserValue = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
          let zoomTimes: number = apiUserValue / Number(AppStorage.get('defaultSettingApi'));
          HiLog.i(TAG, 'queryUserDpiValue success value: ' + zoomTimes);
          if (!Number.isNaN(zoomTimes) && (zoomTimes > 1.3)) {
            HiLog.i(TAG, 'zoomTimes is Maximum Zoom!');
            AppStorage.setOrCreate('isMaximumZoom', true);
          } else {
            HiLog.i(TAG, 'zoomTimes not is Maximum Zoom!');
            AppStorage.setOrCreate('isMaximumZoom', false);
          }
        } else {
          AppStorage.setOrCreate('isMaximumZoom', false);
          HiLog.e(TAG, 'queryUserDpiValue null ');
        }
      } finally {
        ObjectUtil.closeResultSet(resultSet);
      }
    });
}