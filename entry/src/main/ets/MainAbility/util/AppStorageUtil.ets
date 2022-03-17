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
import deviceInfo from '@ohos.deviceInfo';

/**
 * 保存全局的数据工具
 */
export default class AppStorageUtil {
  constructor() {
    this.initData();
  }

  initData() {
  }

  /**
   *  是否从全屏界面回来
   *
   * @param isFromFullScreen
   */
  static setPreferences(preferences) {
    AppStorage.SetOrCreate('preferences', preferences);
  }

  /**
   * 是否从全屏界面回来
   *
   * @return isFromFullScreen
   */
  static getPreferences() {
    let preferences = AppStorage.Get('preferences');
    return preferences;
  }

  static setCallLogTotalData(callLogTotalData: {}) {
    AppStorage.SetOrCreate("callLogTotalData", callLogTotalData);
  }

  static getCallLogTotalData() {
    let callLogTotalData: {} = AppStorage.Get('callLogTotalData');
    return callLogTotalData;
  }

  /**
   *  查询设备的类型
   *
   * @param deviceType 设备的类型
   *
   * default：智能手机
   * tablet：平板
   * tv：智慧屏
   * wearable：智能穿戴
   * liteWearable：轻量级智能穿戴
   * smartVision：智慧视觉设备
   *
   */

  static setDeviceType(deviceType) {
    AppStorage.SetOrCreate('deviceType', deviceType);
  }

  /**
   *  获取查询到的设备的类型
   *
   * @return deviceType 设备的类型
   */
  static getDeviceType() {
    let deviceType: string = AppStorage.Get('deviceType');
    return deviceType;
  }

  /**
 *  保存状态到AppStorage，和组件建立双向数据绑定
 *
 * @param propName 键
 * @param defaultValue 值
 */
  static setAndLink(propName, defaultValue) {
    AppStorage.SetAndLink(propName, defaultValue);
  }

  /**
 *  保存状态到AppStorage，和组件建立双向数据绑定
 *
 * @param propName 键
 * @param defaultValue 值
 */
  static SetOrCreate(propName, defaultValue) {
    AppStorage.SetOrCreate(propName, defaultValue);
  }

  /**
    *  标识为呼叫前编辑
    *
    * @param hasInfoMsg 标识为呼叫前编辑
    */
  static setIsEditNumber(isEditNumber) {
    AppStorage.SetOrCreate('isEditNumber', isEditNumber);
  }

  /**
   * 标识为呼叫前编辑
   *
   * @return isEditNumber 标识为呼叫前编辑
   */
  static isEditNumber() {
    let isEditNumber: boolean = AppStorage.Get('isEditNumber');
    return isEditNumber;
  }

  /**
     *  赋值电话号码
     *
     * @param hasInfoMsg 赋值电话号码
     */
  static setNumTextDialer(numTextDialer) {
    AppStorage.SetOrCreate('numTextDialer', numTextDialer);
  }

  /**
   * 获取呼叫前电话号码
   *
   * @return isEditNumber 电话号码
   */
  static getNumTextDialer() {
    let numTextDialer: number = AppStorage.Get('numTextDialer');
    return numTextDialer;
  }

  static initData() {
    let deviceTypeInfo = deviceInfo.deviceType;
    AppStorageUtil.setDeviceType(deviceTypeInfo);
    AppStorageUtil.setIsEditNumber(false);
    AppStorageUtil.setNumTextDialer('');

  }
}