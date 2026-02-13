/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { data, radio, sim } from '@kit.TelephonyKit';
import I18n from '@ohos.i18n';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import { StringUtil } from './StringUtil'

const TAG = 'CountryIdUtil'

export class CountryIdUtil {
  static getCountryIdForNetWork(): string {
    try {
      let country = radio.getISOCountryCodeForNetworkSync(data.getDefaultCellularDataSlotIdSync());
      return country.toUpperCase();
    } catch (e) {
      HiLog.e(TAG, `getISOCountryCodeForNetWork error:${e?.message}, stack: ${e?.stack}`);
      return '';
    }
  }

  static getCountryIdForSim(): string {
    try {
      let country = '';
      let defaultSlot = AppStorage.get('defaultSlot') as number;
      if (defaultSlot === 0 || defaultSlot === 1) {
        country = sim.getISOCountryCodeForSimSync(defaultSlot);
      } else {
        country = sim.getISOCountryCodeForSimSync(0);
        if (StringUtil.isEmpty(country)) {
          country = sim.getISOCountryCodeForSimSync(1);
        }
      }
      return country.toUpperCase();
    } catch (e) {
      HiLog.e(TAG, `getISOCountryCodeForSim error:${e?.message}, stack: ${e?.stack}`);
      return '';
    }
  }

  static getCountryIdSysReg(): string {
    try {
      let country = I18n.System.getSystemRegion();
      return country;
    } catch (e) {
      HiLog.e(TAG, `getCountryIdSysReg error:${e?.message}, stack: ${e?.stack}`);
      return '';
    }
  }

  static getCountryId(): string {
    let country = CountryIdUtil.getCountryIdForNetWork();
    if (!StringUtil.isEmpty(country)) {
      HiLog.w(TAG, `contryForNetWork is ${country} `);
      return country;
    }

    country = CountryIdUtil.getCountryIdForSim();
    if (!StringUtil.isEmpty(country)) {
      HiLog.w(TAG, `contryForSim is ${country} `);
      return country;
    }

    country = CountryIdUtil.getCountryIdSysReg();
    if (!StringUtil.isEmpty(country)) {
      HiLog.w(TAG, `contryForSysReg is ${country} `);
      return country;
    }

    return 'CN';
  }
}
