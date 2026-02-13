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
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { CallSharingClass } from '../card/data/commonData';
import IndexPresenter from '../presenter/IndexPresenter';
import EnvironmentProp from '../feature/EnvironmentProp';
import { call } from '@kit.TelephonyKit';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';

const SETTING_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
const ON_DISTRIBUTED_CALL_PHONE_SHARING_URI =
  'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=';
const DISTRIBUTED_MODEM_STATE = 'distributed_modem_state';

const TAG = 'distributedCallPhoneSharingMode';

let dataShareHelper: dataShare.DataShareHelper | undefined;

/**
 * add SettingMode Listener.
 */
export function addSettingModeListener(settingKeyWord: string) {
  HiLog.i(TAG, 'addSettingModeListener - ' + settingKeyWord);
  try {
    dataShare.createDataShareHelper(ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName),
      SETTING_MODE_URI, (err: BusinessError,
        data: dataShare.DataShareHelper) => {
        if (err != undefined) {
          HiLog.e(TAG, 'addSettingModeListener error: code: ' + err.code + ', message: ' + err.message);
          return;
        }
        dataShareHelper = data;
        try {
          if (settingKeyWord === DISTRIBUTED_MODEM_STATE) {
            dataShareHelper.on('dataChange', SETTING_MODE_URI,
              () => {
                HiLog.i(TAG, 'addSettingMode dataChange');
                queryInitSettingMode(ContactsGlobalThisHelper.GetGlobalThis()
                  .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName), settingKeyWord);
              });
          } else {
            dataShareHelper.on('dataChange', ON_DISTRIBUTED_CALL_PHONE_SHARING_URI + settingKeyWord,
              () => {
                HiLog.i(TAG, 'addSettingMode dataChange');
                queryInitSettingMode(ContactsGlobalThisHelper.GetGlobalThis()
                  .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName), settingKeyWord);
              });
          }
          HiLog.i(TAG, 'addSettingModeListener success');
        } catch (err) {
          let error: BusinessError = err as BusinessError;
          HiLog.e(TAG,
            'addSettingModeListener error: code: ' + error.code + ', message: ' + error.message);
        }
      });
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG, 'addSettingModeListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

/**
 * remove SettingMode Listener.
 */
export function removeSettingModeListener(settingKeyWord: string) {
  HiLog.i(TAG, 'removeSettingModeListener');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'removeSettingModeListener dataShareHelper null');
    return;
  }
  try {
    dataShareHelper.off('dataChange', ON_DISTRIBUTED_CALL_PHONE_SHARING_URI + settingKeyWord, () => {
      HiLog.i(TAG, 'removeSettingModeListener dataChange');
    });
    dataShareHelper = undefined;
  } catch (err) {
    let error: BusinessError = err as BusinessError;
    HiLog.e(TAG,
      'removevListener error: code: ' + error.code + ', message: ' + error.message);
  }
}

export async function queryInitSettingMode(context: common.UIAbilityContext, settingKeyWord: string) {
  HiLog.i(TAG, 'querySettingMode');
  let beforeModemState: boolean = AppStorage.get('isDistributedModemState') ?? false;
  let beforeCallSharing: boolean = AppStorage.get('isDistributedCallPhoneSharing') ?? false;
  let beforeCallSource: boolean = AppStorage.get('isDistributedCallSourcePhone') ?? false;
  try {
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, SETTING_MODE_URI);
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (settingKeyWord === CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING) {
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING);
    } else if (settingKeyWord === '') {
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_MODEM_STATE);
      condition.or()
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_SOURCE_PHONE);
      condition.or()
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING);
      condition.or()
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING);
    } else {
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_MODEM_STATE);
      condition.or()
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_SOURCE_PHONE);
      condition.or()
      condition.equalTo('KEYWORD', CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING);
    }
    dataShareHelper.query(SETTING_MODE_URI, condition, ['KEYWORD', 'VALUE'])
      .then((resultSet: DataShareResultSet) => {
        try {
          if (resultSet.goToFirstRow()) {
            do {
              let keyWord: string = resultSet.getString(resultSet.getColumnIndex('KEYWORD'));
              let value: string = resultSet.getString(resultSet.getColumnIndex('VALUE'));
              initSettingsDataFiltering(keyWord, value);
            } while (resultSet.goToNextRow());
          }
          if ((settingKeyWord !== CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING)) {
            updateMainTabIndex(beforeModemState, beforeCallSharing, beforeCallSource);
          }
          IndexPresenter.getInstance().isOnCallSharing();
          if (AppStorage.get('isNoMissFormCard')) {
            IndexPresenter.getInstance().initMainTabIndex();
          }
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
  } catch (err) {
    HiLog.i(TAG, 'querySettingMode failed err: ' + (err as BusinessError).message);
  }
}

export function initSettingsDataFiltering(keyWord: string, value: string) {
  if (keyWord === CallSharingClass.DISTRIBUTED_MODEM_STATE) {
    let keyValue = value === CallSharingClass.ON_DISTRIBUTED_MODEM_STATE;
    HiLog.i(TAG, `${keyWord} value is ${keyValue}. `);
    AppStorage.setOrCreate('isDistributedModemState', keyValue);
  } else if (keyWord === CallSharingClass.DISTRIBUTED_CALL_SOURCE_PHONE) {
    let keyValue = Number(value) === CallSharingClass.ON_DISTRIBUTED_CALL_SOURCE_PHONE;
    HiLog.i(TAG, `${keyWord} value is ${keyValue}. `);
    AppStorage.setOrCreate('isDistributedCallSourcePhone', keyValue);
  } else if (keyWord === CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING) {
    let keyValue = Number(value) === CallSharingClass.ON_CALL_PHONE_SHARING;
    HiLog.i(TAG, `${keyWord} value is ${keyValue}. `);
    AppStorage.setOrCreate('isDistributedCallPhoneSharing', keyValue);
  } else if (keyWord === CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING) {
    let keyValue = Number(value) === CallSharingClass.ON_CALL_SMS_SHARING;
    HiLog.i(TAG, `${keyWord} value is ${keyValue}. `);
    AppStorage.setOrCreate('isDistributedCallSMSSharing', keyValue);
  }
}

export function updateMainTabIndex(beforeModemState: boolean, beforeCallSharing: boolean, beforeCallSource: boolean) {
  let afterModemState: boolean = AppStorage.get('isDistributedModemState') ?? false;
  let afterCallSharing: boolean = AppStorage.get('isDistributedCallPhoneSharing') ?? false;
  let afterCallSource: boolean = AppStorage.get('isDistributedCallSourcePhone') ?? false;
  if ((beforeModemState === afterModemState) && (beforeCallSharing === afterCallSharing) &&
    (beforeCallSource === afterCallSource)) {
    return;
  }
  if (EnvironmentProp.isDeviceTypeTablet() && call.hasVoiceCapability()) {
    return;
  }
  HiLog.i(TAG, 'CallSharingModel updateMainTabIndex!');
  IndexPresenter.getInstance().updateMainTabIndex();
  IndexPresenter.getInstance().updateMainTabIndexId();
}