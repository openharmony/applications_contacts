/**
 * Copyright (c) 2023-2025 Huawei Device Co., Ltd.
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
/**
 * NewCallUtils
 */

import { HiLog, NumberAddressUtil } from '../../../../../feature/call/oh_modules/common';
import { sim } from '@kit.TelephonyKit';
import { i18n } from '@kit.LocalizationKit';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'NewCallUtils';

export class NewCallUtils {
  public static async getNewCallingSwitchConfigs(slotId: number): Promise<string[] | undefined> {
    try {
      /* 从随卡配置读取 */
      const operatorPLMN: string = await sim.getSimOperatorNumeric(slotId);
      const simConfig = await sim.getOperatorConfigs(slotId);
      const simNewCallSwitchConfig =
        simConfig.find(config => config.field === 'new_call_switch_configs_string_array')?.value;
      HiLog.i(TAG, `get new call config ${simNewCallSwitchConfig} from operator configs of plmn ${operatorPLMN}`);
      if (simNewCallSwitchConfig === undefined || simNewCallSwitchConfig === '') {
        HiLog.i(TAG, `new call config not exit for plan ${operatorPLMN}`);
        return undefined;
      }
      const simNewCallConfigsArray: string[] = JSON.parse(simNewCallSwitchConfig);
      if (Array.isArray(simNewCallConfigsArray)) {
        HiLog.i(TAG, `parse new_call_switch_configs_string_array array success.`);
        return simNewCallConfigsArray;
      }
      HiLog.e(TAG, `parse new call config ${simNewCallSwitchConfig} fail`);
      return undefined;
    } catch (e) {
      HiLog.e(TAG, `get new_call_switch_configs_string_array from operator config file fail ${e?.message}`);
      return undefined;
    }
  }

  public static async checkNewCallSwitchConfigsBySlotId(slotId: number, context: Context): Promise<boolean> {
    const newCallingConfigs = await NewCallUtils.getNewCallingSwitchConfigs(slotId);
    if (newCallingConfigs === undefined) {
      return false;
    }
    const country = await sim.getISOCountryCodeForSim(slotId);
    const number = await sim.getShowNumber(slotId);
    return NewCallUtils.checkNewSwitchConfigs(newCallingConfigs, country, number, context);
  }

  public static async checkNewSwitchConfigs(configs: string[] | undefined, country: string, number: string,
    context: Context): Promise<boolean> {
    try {
      if (configs === undefined) {
        HiLog.w(TAG, 'new_call_switch_configs_string_array is not exist.');
        return false;
      }
      if (!Array.isArray(configs) || configs.length < 3) {
        HiLog.w(TAG, `check new calling switch config is not array or len invalid`);
        return false;
      }

      /* 检查开关配置 */
      const flag = configs[2];
      if (flag !== '1') {
        HiLog.w(TAG, `configs switch is off`);
        return false;
      }

      /* 检查型号 */
      const models = configs[0].toUpperCase().split('/');
      let modelMatch = false;
      const deviceModel: string = deviceInfo.productModel.toUpperCase();
      HiLog.i(TAG, `check current module ${deviceModel} from conf ${configs[0]}`);
      for (let index = 0; index < models.length; index++) {
        if (models[index] === 'ALL' || deviceModel.includes(models[index]) || deviceModel === models[index]) {
          HiLog.i(TAG, `current device model ${deviceModel} match config ${models[index]}`);
          modelMatch = true;
          break;
        }
      }

      if (!modelMatch) {
        HiLog.w(TAG, `current model ${deviceModel} not match config`);
        return false;
      }

      /* 检查区域 */
      const areas = configs[1].toUpperCase().split('/');
      let phoneNumberFormat: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat(country.toUpperCase());
      let locationEn = phoneNumberFormat.getLocationName(number, 'en-GB').toUpperCase();
      let locationCn = await NumberAddressUtil.getNumberLocation(context, number);
      let areaMatch: boolean = NewCallUtils.checkNumberLocationMatch(locationEn, areas) ||
        NewCallUtils.checkNumberLocationMatch(locationCn, areas);
      HiLog.i(TAG, `check location with conf ${configs[1]} ret ${areaMatch}`);

      if (!areaMatch) {
        HiLog.w(TAG, `current location not match config ${configs[1]}`);
        return false;
      }
      HiLog.i(TAG, `current model ${deviceModel} and area match conf`);
      return true;
    } catch (e) {
      HiLog.e(TAG, `check new calling switch config return fail ${e?.message}`);
      return false;
    }
  }

  private static checkNumberLocationMatch(location: string, areas: string[]): boolean {
    for (let index = 0; index < areas.length; index++) {
      if (areas[index] === 'ALL' || location.includes(areas[index])) {
        HiLog.i(TAG, `current location match config area ${index}`);
        return true;
      }
    }
    HiLog.i(TAG, `current lacation not match config area.`);
    return false;
  }
}