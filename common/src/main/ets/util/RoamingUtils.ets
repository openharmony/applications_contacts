/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from './HiLog';
import radio from '@ohos.telephony.radio';
import sim from '@ohos.telephony.sim';
import { StringUtil } from './StringUtil';
import data from '@ohos.telephony.data';
import i18n from '@ohos.i18n';

const TAG = 'RoamingUtils';

const INTERNATIONAL_NUMBER_LENGTH: number = 7;
const IP_DEAD_LENGTH: number = 5;
const CHINA_PHONE_NUMBER_LENGTH: number = 11;
const CHINA_PHONE_PREFIX: string = '+86';
const CHINA_COUNTRY_ISO_CODE: string = '0086';
const CHINA_COUNTRY_ISO: string = 'CN';
const REGULAR_START: string = '^';
const CHINA_ISO_REGULAR: string = '(\\+86|86|0086)';
const REGULAR_OR: string = '?';
const REGULAR_OVER: string = '$';
const IP_DEAD_REGULAR: string = '((179[01356][0189])|(11808)|(12593)|(10193)|(96435))';
const AMERICA_MOBILE_NUMBER: string = '^\\+(13[0-9]|15[012356789]|17[0-9]|18[0-9]|14[57])[0-9]{8}$';
const MOBILE_NUMBER: string = '(13[0-9]|15[012356789]|17[1235678]|18[0-9]|19[012356789]|14[579]|16[67])\\d{8}';
const HOME_NUMBER: string = '(([1-9]\\d{8})|([1-9]\\d{9})|([1-9]\\d{10}))';
const ALL_MOBILE_NUMBER: string =
  REGULAR_START + CHINA_ISO_REGULAR + REGULAR_OR + IP_DEAD_REGULAR + MOBILE_NUMBER + REGULAR_OVER;
const ALL_HOME_NUMBER: string =
REGULAR_START + CHINA_ISO_REGULAR + REGULAR_OR + IP_DEAD_REGULAR + HOME_NUMBER + REGULAR_OVER;

/**
 * Match mobile number with prefix 0 +86 86 0086
 * 电信：133、149、153、173、177、180、181、189、190、191、193、199
 * 联通：130、131、132、145、155、156、166、167、171、175、176、185、186、196
 * 移动：134、135、136、137、138、139、147、150、151、152、157、158、159、172、178、182 、183、184、187、188、195、197、198
 * 广电：192
 */
const MOBILE_NUMBER_WITH_PREFIX: string = '^(0|\\+86|86|0086)?(13[0-9]|15[012356789]|17[1235678]|18[0-9]|19[012356789]|14[579]|16[67])[0-9]{8}$';

/**
 * Match chinese Family telephone with prefix 0.
 */
const HOME_NUMBER_WITH_ZERO: string = '^((0[1-9]\\d{8})|^(0[1-9]\\d{9})|^(0[1-9]\\d{10}))$';

/**
 * Match chinese Family telephone with prefix 0086.
 */
const HOME_NUMBER_WITH_ISO_CODE: string = '^(0086)(([1-9]\\d{8})|([1-9]\\d{9})|([1-9]\\d{10}))$';

/**
 * Match mobile number with prefix 0.
 */
const MOBILE_NUMBER_WITH_ZERO: string = '^0(13[0-9]|15[012356789]|17[1235678]|18[0-9]|19[012356789]|14[579]|16[67])[0-9]{8}$';

/**
 * Match special number start with 400.
 */
const SPECIAL_NUMBER: string = '^400\\d{7}$';

export class UpdateFormatNumerParam {
  /**
   * The phone number index of update format number
   */
  public static PHONE_NUMBER_INDEX = 0;

  /**
   * The old format number index of update format number
   */
  public static OLD_FORMAT_NUMBER_INDEX = 1;

  /**
   * The new format number index of update format number
   */
  public static NEW_FORMAT_NUMBER_INDEX = 2;
}

export interface RoamingData {
  formatNumber: string,
  labelId: number
}

export class RoamingUtils {

  public static getMaxSimCount() {
    return sim.getMaxSimCount();
  }

  /**
   * Is network roaming
   * @returns true if anyone sim is roaming
   */
  public static async isNetworkRoaming(accountId?: number): Promise<boolean> {
    let slotId: number = accountId ?? data.getDefaultCellularDataSlotIdSync()
    return await RoamingUtils.isSimRoaming(slotId);
  }

  /**
   * Get roaming dial number
   *
   * @param oriNum the number in database column detail_info
   * @param formatNumber the format number in database column format_phone_number
   * @returns which numbers to call
   */
  public static async getRoamingDialNumber(oriNum: string | undefined,
    formatNumber: string | undefined, validCallLogNumber?: string, accountId?: number): Promise<string[]> {
    let tempPhoneNumber = oriNum;
    tempPhoneNumber = StringUtil.removeSpace(tempPhoneNumber);
    tempPhoneNumber = StringUtil.removeDash(tempPhoneNumber);
    if (!tempPhoneNumber || tempPhoneNumber.length === 0) {
      HiLog.w(TAG, `phone number is null`);
      return [];
    }
    if (await RoamingUtils.isNoNeedDealWithRoaming(tempPhoneNumber, accountId)) {
      HiLog.w(TAG, `No need to deal with roaming`);
      return Array.of<string>(tempPhoneNumber);
    }
    let result: string | undefined = RoamingUtils.getValidNumber(tempPhoneNumber, formatNumber);
    if (result && result.length > 0) {
      return RoamingUtils.isOnlyChineseMobile(tempPhoneNumber, result);
    }

    // format_number is null, get country code from sim card
    HiLog.w(TAG, `Phone number is invalid in current iso`);
    if (validCallLogNumber) {
      return RoamingUtils.isOnlyChineseMobile(tempPhoneNumber, validCallLogNumber);
    }
    let phoneNumbers: string[] = [];
    let slotId = accountId ?? data.getDefaultCellularDataSlotIdSync();
    if (await RoamingUtils.isSimRoaming(slotId)) {
      let formatNumberFromSimOne = RoamingUtils.getFormatNumberFromSim(tempPhoneNumber, slotId);
      if (!formatNumberFromSimOne || formatNumberFromSimOne.length === 0) {
        return Array.of<string>(tempPhoneNumber);
      }
      phoneNumbers.push(formatNumberFromSimOne);
    }

    if (phoneNumbers.indexOf(tempPhoneNumber) === -1) {
      phoneNumbers.push(tempPhoneNumber);
    }
    if (phoneNumbers.length === 1) {
      phoneNumbers = RoamingUtils.isOnlyChineseMobile(tempPhoneNumber, phoneNumbers[0])
    }
    return phoneNumbers;
  }

  public static isOnlyChineseMobile(tempPhoneNumber: string, result: string): string[] {
    let phoneNumbers: string[] = [];
    if (!RoamingUtils.isChineseMobileNumber(result) && result !== tempPhoneNumber) {
      phoneNumbers.push(tempPhoneNumber)
    }
    phoneNumbers.push(result);
    return phoneNumbers;
  }

  /**
   * Is chinese mobile phone number
   * @returns true if is chinese phone number
   */
  public static isChineseMobileNumber(phoneNumber: string): boolean {
    let tempPhoneNumber = phoneNumber;
    tempPhoneNumber = RoamingUtils.deleteIpHead(tempPhoneNumber);
    let reg: RegExp = new RegExp(MOBILE_NUMBER_WITH_PREFIX);
    tempPhoneNumber = StringUtil.removeSpace(tempPhoneNumber);
    tempPhoneNumber = StringUtil.removeDash(tempPhoneNumber);
    return reg.test(tempPhoneNumber);
  }

  /**
   * Is chinese home phone number
   * @returns true if is chinese phone number
   */
  public static isChineseHomeNumber(phoneNumber: string): boolean {
    let reg: RegExp = new RegExp(HOME_NUMBER);
    return reg.test(phoneNumber);
  }

  /**
   * Is america mobile phone number
   * @returns true if is chinese phone number
   */
  public static isAmericaNumber(phoneNumber: string): boolean {
    let reg: RegExp = new RegExp(AMERICA_MOBILE_NUMBER);
    return reg.test(phoneNumber);
  }

  /**
   * Is the number no need to deal with roaming scenarios
   * @returns false is need deal with it
   */
  public static async isNoNeedDealWithRoaming(phoneNumber: string | undefined, accountId?: number): Promise<boolean> {
    return (phoneNumber ? phoneNumber.startsWith('+') : false) || !await RoamingUtils.isNetworkRoaming(accountId);
  }

  /**
   * Get valid number from phoneNumber and formatNumber
   * @returns true the number is valid
   */
  public static getValidNumber(phoneNumber: string | undefined, formatNumber: string | undefined): string | undefined {
    if (!phoneNumber || !formatNumber) {
      HiLog.w(TAG, `getValidNumber failed, phone number is null or formatNumber is null`);
      return undefined;
    }
    let result = formatNumber;
    let tempNumber = phoneNumber;
    result = StringUtil.removeSpace(result);
    tempNumber = StringUtil.removeSpace(tempNumber);
    if (!result.startsWith(CHINA_PHONE_PREFIX)) {
      HiLog.w(TAG, `isValidOverseaNumber`);
      return RoamingUtils.isValidOverseaNumber(tempNumber, result) ? result : undefined;
    }
    let tempFormatNumber = result.substring(CHINA_PHONE_PREFIX.length);
    if (tempNumber.search(tempFormatNumber) >= 0) {
      return result;
    }
    HiLog.w(TAG, `china phone number is not match format phone number`);
    if (tempNumber.match(ALL_MOBILE_NUMBER) != null || tempNumber.match(ALL_HOME_NUMBER) != null) {
      tempNumber = RoamingUtils.deleteChinaIso(tempNumber);
      tempNumber = tempNumber.substring(IP_DEAD_LENGTH);
      if (tempNumber.match(MOBILE_NUMBER) != null || tempNumber.match(HOME_NUMBER) != null) {
        tempNumber = CHINA_PHONE_PREFIX + tempNumber;
      }
    }
    return RoamingUtils.addPrefixForChineseNumber(tempNumber);
  }

  /**
   * Is the number need deal with roaming scenarios
   * @returns true is need deal with it
   */
  public static isValidOverseaNumber(phoneNumber: string | undefined, formatNumber: string | undefined): boolean {
    if (!phoneNumber || !formatNumber) {
      return false;
    }
    let tempNumber = RoamingUtils.getValidOverseaNumber(phoneNumber, INTERNATIONAL_NUMBER_LENGTH);
    let tempFormatNumber = RoamingUtils.getValidOverseaNumber(formatNumber, tempNumber.length);
    return tempNumber === tempFormatNumber;
  }

  /**
   * Add +86 to chinese phone number
   * @returns if the phoneNumber is valid, add +86
   */
  public static addPrefixForChineseNumber(phoneNumber: string | undefined): string | undefined {
    if (!phoneNumber || phoneNumber.length === 0) {
      return undefined;
    }
    if (phoneNumber.match(MOBILE_NUMBER_WITH_PREFIX) != null) {
      return RoamingUtils.addPrefixForMobileNumber(phoneNumber);
    }
    if (phoneNumber.match(HOME_NUMBER_WITH_ZERO) != null) {
      return CHINA_PHONE_PREFIX + phoneNumber.substring(1);
    }
    if (phoneNumber.match(HOME_NUMBER_WITH_ISO_CODE) != null) {
      return CHINA_PHONE_PREFIX + phoneNumber.substring(CHINA_COUNTRY_ISO_CODE.length);
    }
    if (phoneNumber.match(SPECIAL_NUMBER) != null) {
      return CHINA_PHONE_PREFIX + phoneNumber;
    }
    return phoneNumber;
  }

  public static getISOCountryCodeForNetworkSync(): string {
    return radio.getISOCountryCodeForNetworkSync(data.getDefaultCellularDataSlotIdSync());
  }

  public static getFormatNumberFromNetWork(phoneNumber: string | undefined): string | undefined {
    if (!phoneNumber || phoneNumber.length === 0) {
      return undefined;
    }
    let country = RoamingUtils.getISOCountryCodeForNetworkSync();
    HiLog.i(TAG, `getISOCountryCodeForNetwork country: ${country}`)
    if (!country || country.length === 0) {
      return undefined;
    }
    return RoamingUtils.getFormatNumber(phoneNumber, country);
  }

  public static isNumberMatchCurrentCountry(
    phoneNumber: string | undefined, formatNumber: string | undefined): boolean {
    if (!phoneNumber || phoneNumber.length === 0 || !formatNumber || formatNumber.length === 0) {
      return false;
    }
    let tempNum: string = StringUtil.removeSpace(phoneNumber);
    if (RoamingUtils.isCreatePhoneNumberInUS(tempNum, formatNumber)) {
      return false;
    }
    let currentFormatNumber: string | undefined = RoamingUtils.getFormatNumberFromNetWork(tempNum);
    return formatNumber === currentFormatNumber;
  }

  public static addPrefixForMobileNumber(phoneNumber: string): string {
    if (phoneNumber.startsWith(CHINA_COUNTRY_ISO_CODE)) {
      return CHINA_PHONE_PREFIX + phoneNumber.substring(CHINA_COUNTRY_ISO_CODE.length);
    }
    if (phoneNumber.length === CHINA_PHONE_NUMBER_LENGTH) {
      return CHINA_PHONE_PREFIX + phoneNumber;
    }
    if (phoneNumber.match(MOBILE_NUMBER_WITH_ZERO)) {
      return CHINA_PHONE_PREFIX + phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  public static getValidOverseaNumber(phoneNumber: string, numberLength: number): string {
    if (phoneNumber.length < numberLength) {
      return phoneNumber;
    }
    return phoneNumber.substring(phoneNumber.length - numberLength);
  }

  public static deleteChinaIso(phoneNumber: string): string {
    if (phoneNumber.startsWith(CHINA_PHONE_PREFIX)) {
      return phoneNumber.substring(CHINA_PHONE_PREFIX.length);
    }
    if (phoneNumber.startsWith(CHINA_COUNTRY_ISO_CODE)) {
      return phoneNumber.substring(CHINA_COUNTRY_ISO_CODE.length);
    }
    return phoneNumber;
  }

  public static deleteIpHead(phoneNumber: string): string {
    let tempNum = phoneNumber;
    if (tempNum.match(ALL_MOBILE_NUMBER) != null) {
      tempNum = RoamingUtils.deleteChinaIso(tempNum);
      tempNum = tempNum.substring(IP_DEAD_LENGTH);
      if (tempNum.match(MOBILE_NUMBER) != null) {
        return CHINA_PHONE_PREFIX + tempNum;
      }
      tempNum = phoneNumber;
    }
    if (tempNum.match(ALL_HOME_NUMBER) != null) {
      tempNum = RoamingUtils.deleteChinaIso(tempNum);
      tempNum = tempNum.substring(IP_DEAD_LENGTH);
      if (tempNum.match(HOME_NUMBER) != null) {
        return CHINA_PHONE_PREFIX + tempNum;
      }
      tempNum = phoneNumber;
    }
    if (tempNum.match(REGULAR_START + IP_DEAD_REGULAR) != null) {
      return CHINA_PHONE_PREFIX + tempNum.substring(IP_DEAD_LENGTH);
    }
    return tempNum;
  }

  private static async isSimRoaming(slotId: number): Promise<boolean> {
    let simActive = await sim.isSimActive(slotId) ?? false;
    if (!simActive) {
      return false;
    }
    let state: radio.NetworkState = await radio.getNetworkState(slotId);
    return state ? state.isRoaming : false;
  }

  public static isCreatePhoneNumberInUS(phoneNumber: string, formatNumber: string): boolean {
    if (!phoneNumber || phoneNumber.length === 0 || !formatNumber || formatNumber.length === 0) {
      return false;
    }
    return (phoneNumber.match(MOBILE_NUMBER) != null) && (formatNumber.match(AMERICA_MOBILE_NUMBER) != null);
  }

  static getISOCountryCodeForSimSync(slotId: number): string {
    return sim.getISOCountryCodeForSimSync(slotId);
  }

  public static getFormatNumberFromSim(phoneNumber: string | undefined, slotId: number): string | undefined {
    if (!phoneNumber) {
      HiLog.w(TAG, `getFormatNumberFromSim in slotId: ${slotId} faield, phoneNumber is null`);
      return undefined;
    }
    let simIso = RoamingUtils.getISOCountryCodeForSimSync(slotId);
    HiLog.w(TAG, `getFormatNumberFromSim in slotId: ${slotId} , simIso : ${simIso}`);
    if (!simIso || simIso.length === 0) {
      return undefined;
    }
    simIso = simIso.toUpperCase();
    let result: string | undefined = undefined;
    if (simIso === CHINA_COUNTRY_ISO) {
      result = RoamingUtils.getFormatNumberFromChinaSim(phoneNumber);
    } else {
      result = RoamingUtils.getFormatNumber(simIso, phoneNumber);
    }
    if (RoamingUtils.isNumberMatchCurrentCountry(phoneNumber, result)) {
      HiLog.w(TAG, `isNumberMatchCurrentCountry true`);
      result = undefined;
    }
    return result;
  }

  public static getFormatNumber(phoneNumber: string | undefined, countryIso: string | undefined): string | undefined {
    if (!phoneNumber || phoneNumber.length === 0 || !countryIso || countryIso.length === 0) {
      return undefined;
    }
    let option: i18n.PhoneNumberFormatOptions = {
      type: 'E164'
    }
    countryIso = countryIso.toUpperCase();
    let numberFormat: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat(countryIso, option);
    if (!numberFormat.isValidNumber(phoneNumber)) {
      return undefined;
    }
    return numberFormat.format(phoneNumber);
  }

  public static getFormatNumberBySystemRegion(phoneNumber: string | undefined): string | undefined {
    let systemRegion: string = i18n.System.getSystemRegion(); // 获取系统当前地区设置
    return RoamingUtils.getFormatNumber(phoneNumber, systemRegion);
  }

  public static getFormatNumberFromChinaSim(phoneNumber: string | undefined): string | undefined {
    if (!phoneNumber || phoneNumber.length === 0) {
      HiLog.w(TAG, `getFormatNumberFromChinaSim failed, phoneNumber is null`);
      return undefined;
    }
    let tempNum = phoneNumber;
    if (tempNum.length >= CHINA_PHONE_NUMBER_LENGTH) {
      tempNum = RoamingUtils.deleteIpHead(tempNum);
      let result: string | undefined = RoamingUtils.addPrefixForChineseNumber(tempNum);
      if (!result) {
        HiLog.w(TAG, `getFormatNumberFromChinaSim failed, addPrefixForChineseNumber failed`);
        return undefined;
      }
      if (tempNum === result && !tempNum.startsWith(CHINA_PHONE_PREFIX)) {
        return phoneNumber;
      }
      return result;
    }
    if (tempNum.match(SPECIAL_NUMBER) != null) {
      return CHINA_PHONE_PREFIX + phoneNumber;
    }
    return undefined;
  }
}