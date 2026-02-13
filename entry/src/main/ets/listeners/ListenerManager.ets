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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { sharedPreferencesUtils } from '../../../../../feature/call/oh_modules/common';
import dataShare from '@ohos.data.dataShare';
import settings from '@ohos.settings';
import DataShareHelper from '@ohos.data.dataShare';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { BusinessError } from '@ohos.base';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import CallServiceManager from '../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager';
import { osAccount } from '@kit.BasicServicesKit';
import display from '@ohos.display';
import { DeviceUtil } from '../../../../../entry/src/main/ets/feature/EnvironmentProp'
import commonEventManager from '@ohos.commonEventManager';
import { CommonEventUtil } from '../../../../../common/src/main/ets/util/CommonEventUtil';
import { CommonEventConstants } from '../../../../../common/src/main/ets/CommonEventConstants';
import IndexPresenter from '../presenter/IndexPresenter';
import { SystemModeController } from '../util/SystemModeController';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';

const TAG = 'ListenerManager';
const BUNDLE_NAME: string = 'com.ohos.contacts';
const SETTING_TIME_FORMAT_URI =
  'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=' + settings.date.TIME_FORMAT;
const SATELLITE_MODE_SWITCH_URI =
  'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
// 免打扰是否开启
const FOCUS_MODE_ENABLE = 'focus_mode_enable'
const ENABLE_DND: string = '1'
const PRIVACY_ACCOUNT: number = 101

export class ListenerManager {
  public settingDataShareHelper: DataShareHelper.DataShareHelper | null = null;
  public cloudSyncDataShareHelper: DataShareHelper.DataShareHelper | null = null;
  public meetimeLogInDataShareHelper: DataShareHelper.DataShareHelper | null = null;
  public dialpadTouchToneDataShareHelper: DataShareHelper.DataShareHelper | null = null;
  public satellitesModeSwitchDataShareHelper: DataShareHelper.DataShareHelper | null = null;
  /**
   * 帐号ID索引
   */
  private readonly KEY_USER_ID_STATUS: string = 'HiCall_User_Id_Status';
  // 畅连是否登录监听表，表名需要根据参数继续拼接
  private SETTINGS_DATA_URL = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_';
  /**
   * 查询meetime登录状态，settings数据库url后缀，需要拼接处理，无法作为常量
   */
  private SETTINGS_DB_URL_SUFFIX = '?Proxy=true&key=';
  private MAIN_USER_ID = 100;
  private localUserId = 100;
  private listenMeetimeLoginUrlFinal = '';
  private dialpadTouchToneUrlFinal = '';
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();

  constructor() {
  }

  registerListeners(): void {
    this.getLocalAccountId();
    this.subscribeTimeFormatChange();
    this.subscribeDialpadTouchToneChange();
    this.subscribeMeetimeLoginFlagChange()
    this.subscribesStelliteModeSwitchChange()
    this.subscribesHyacinthModeSwitchChange()
    this.addFoldStatusListener();
    this.subscribeThemeChange();
    this.addFocusModelListener();
  }

  unRegisterListeners(): void {
    try {
      if (this.settingDataShareHelper !== null) {
        this.settingDataShareHelper.off('dataChange', SETTING_TIME_FORMAT_URI);
      }
      if (this.satellitesModeSwitchDataShareHelper !== null) {
        this.satellitesModeSwitchDataShareHelper.off('dataChange', SATELLITE_MODE_SWITCH_URI);
      }
      if (this.meetimeLogInDataShareHelper !== null) {
        this.meetimeLogInDataShareHelper.off('dataChange', this.listenMeetimeLoginUrlFinal);
      }
      if (this.dialpadTouchToneDataShareHelper !== null) {
        this.dialpadTouchToneDataShareHelper.off('dataChange', this.dialpadTouchToneUrlFinal);
      }
      this.removeFoldStatusListener();
      if (this.subscriber !== null) {
        CommonEventUtil.unsubscribe(this.subscriber);
      }
      this.removeFocusModelListener();
    } catch (err) {
      HiLog.e(TAG, `dataShareHelper.off error: code: ${err?.message}`);
    }
  }

  private subscribeThemeChange(): void {
    // 创建订阅者回调
    CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_THEME_INFO)
      .then((subscribeInfo: commonEventManager.CommonEventSubscriber) => {
        HiLog.i(TAG, 'creating subscriber end');
        this.subscriber = subscribeInfo;
        // 订阅公共事件回调
        if (this.subscriber !== null) {
          CommonEventUtil.subscribe(this.subscriber, CommonEventConstants.COMMON_EVENT_THEME_INFO, () => {
            this.mIndexPresenter.isDefaultColor();
          })
        } else {
          HiLog.e(TAG, 'Need create subscriber');
        }
      })
  }


  /**
   * 获取是否开启免打扰
   */
  public async addFocusModelListener() {
    let localAccountId = await this.getOsAccountLocalId();
    if (localAccountId === PRIVACY_ACCOUNT) {
      // 隐私空间无免打扰功能
      HiLog.w(TAG, `the privacy space does not determine the DND mode.`);
      AppStorage.setOrCreate<boolean>('focusModelEnable', false);
      return;
    }
    try {
      let focusModeEnable: string =
        settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), FOCUS_MODE_ENABLE, '0',
          settings.domainName.USER_SECURITY);
      HiLog.w(TAG, `getFocusModelFlag: ${focusModeEnable}`);
      AppStorage.setOrCreate<boolean>('focusModelEnable', focusModeEnable === ENABLE_DND);
      // 添加监听
      let isRegisteredListener =
        settings.registerKeyObserver(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), FOCUS_MODE_ENABLE,
          settings.domainName.USER_SECURITY, () => {
            settings.getValue(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), FOCUS_MODE_ENABLE,
              settings.domainName.USER_SECURITY)
              .then((value) => {
                HiLog.w(TAG, `focusModeEnable change value is ${value}`);
                AppStorage.setOrCreate<boolean>('focusModelEnable', value === ENABLE_DND);
              })
              .catch((error: BusinessError) => {
                AppStorage.setOrCreate<boolean>('focusModelEnable', false);
                HiLog.e(TAG, `failed to get the setting,${error.message} `);
              })
          });
      HiLog.w(TAG, `registered listener:${isRegisteredListener}`);
    } catch (error) {
      AppStorage.setOrCreate<boolean>('focusModelEnable', false);
      HiLog.e(TAG, `addFocusModelListener fail  ${error?.message}}`)
    }
  }

  async getLocalAccountId() {
    // localAccountId 用于拼接监听的setting表的名称
    let localAccountId = await sharedPreferencesUtils.getFromPreferences(this.KEY_USER_ID_STATUS, 0) as number;
    if (localAccountId === 0) {
      localAccountId = await this.getOsAccountLocalId();
      await sharedPreferencesUtils.saveToPreferences(this.KEY_USER_ID_STATUS, localAccountId);
      HiLog.i(TAG, 'localAccountId:' + localAccountId);
    }
    if (localAccountId === 0) {
      localAccountId = this.MAIN_USER_ID;
    }
    HiLog.i(TAG, 'localAccount:' + this.localUserId);
    AppStorage.setOrCreate('isPrimaryAccount', localAccountId === this.MAIN_USER_ID);
    this.localUserId = localAccountId;
  }

  /**
   * 获取操作系统
   * @returns
   */
  async getOsAccountLocalId(): Promise<number> {
    let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
    try {
      const localId: number = await accountManager.getOsAccountLocalId();
      HiLog.i(TAG, 'getOsAccountLocalId successfully, localId: ' + localId);
      return localId;
    } catch (err) {
      HiLog.w(TAG, `getOsAccountLocalId failed, error: ${err?.message}`);
    }
    return 0;
  }

  private subscribeTimeFormatChange(): void {
    HiLog.i(TAG, 'subscribeTimeFormatChange')
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      dataShare.createDataShareHelper(context, SETTING_TIME_FORMAT_URI)
        .then((data: DataShareHelper.DataShareHelper) => {
          HiLog.i(TAG, 'createDataShareHelper succeed');
          this.settingDataShareHelper = data;
          this.settingDataShareHelper.on('dataChange', SETTING_TIME_FORMAT_URI, () => {
            let timeFormat = settings.getValueSync(context, settings.date.TIME_FORMAT, '24');
            HiLog.w(TAG, 'refreshTimeFormat: ' + timeFormat);
            ContactsGlobalThisHelper.GetGlobalThis().set<string>(ContactsGlobalThisHelper.TimeFormatName, timeFormat);
            ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
              .sendRequest('updateTimeFormat', {
                timeFormat: timeFormat
              });
          });
        })
        .catch((err: BusinessError) => {
          HiLog.e(TAG, `createDataShareHelper error: code: ${err.code}, message: ${err.message} `);
        });
    } catch (err) {
      HiLog.e(TAG, `createDataShareHelper error: ${err.message}`);
    }
  }

  private async subscribeDialpadTouchToneChange(): Promise<void> {
    HiLog.i(TAG, 'subscribeDialpadTouchToneChange')
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      this.dialpadTouchToneUrlFinal = this.SETTINGS_DATA_URL + this.localUserId + this.SETTINGS_DB_URL_SUFFIX +
      CallServiceManager.DIALPAD_TOUCH_TONE_TYPE;
      HiLog.i(TAG, 'subscribeDialpadTouchToneChange, finalUri: ' + StringUtil.maskSensitiveInfo(this.dialpadTouchToneUrlFinal));
      dataShare.createDataShareHelper(context, this.dialpadTouchToneUrlFinal)
        .then((data: DataShareHelper.DataShareHelper) => {
          HiLog.i(TAG, 'DialpadTouchTone createDataShareHelper succeed');
          this.dialpadTouchToneDataShareHelper = data;
          let dialpadTouchToneType =
            settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              CallServiceManager.DIALPAD_TOUCH_TONE_TYPE, '1',
              settings.domainName.USER_PROPERTY);
          HiLog.i(TAG, 'dialpadTouchToneType = ' + dialpadTouchToneType);
          AppStorage.setOrCreate<string>('dialpadTouchToneType', dialpadTouchToneType);
          this.dialpadTouchToneDataShareHelper.on('dataChange', this.dialpadTouchToneUrlFinal, () => {
            try { // 数据变更
              CallServiceManager.getInstance().updateDialpadTouchToneType()
            } catch (err) {
              HiLog.e(TAG, `updateDialpadTouchToneType error: ${err?.message}`);
            }
          });
        })
        .catch((err: BusinessError) => {
          HiLog.e(TAG, `subscribeDialpadTouchToneChange error: ${err.message}`);
        });
    } catch (err) {
      HiLog.e(TAG, `subscribe dialpad touch tone change error: ${err.message}`);
    }
  }


  private async subscribeMeetimeLoginFlagChange(): Promise<void> {
    this.listenMeetimeLoginUrlFinal = this.SETTINGS_DATA_URL + this.localUserId + this.SETTINGS_DB_URL_SUFFIX +
    CallServiceManager.MEETIMT_LOGIN_FLAG_KEY;
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    dataShare.createDataShareHelper(context, this.listenMeetimeLoginUrlFinal).then(async data => {
      this.meetimeLogInDataShareHelper = data;
      HiLog.i(TAG, 'createmeetimeLoginDataShareHelper succeed, data:' + data);
      this.meetimeLogInDataShareHelper.on('dataChange', this.listenMeetimeLoginUrlFinal, async (err) => {
        if (err) {
          HiLog.e(TAG, `MeetimeLoginFlag dataChange error: ${err.message}`);
        }
        // 数据变更后重新查询
        CallServiceManager.getInstance().updateMeetimeLoginFlag();
      });
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `MeetimeLoginFlag createDataShareHelper error: ${err.message}`);
    });
  }

  //天通状态下拨号按钮修改
  private subscribesStelliteModeSwitchChange(): void {
    HiLog.i(TAG, 'subscribesStelliteModeSwitchChange')
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      dataShare.createDataShareHelper(context, SATELLITE_MODE_SWITCH_URI)
        .then((data: DataShareHelper.DataShareHelper) => {
          HiLog.i(TAG, 'StelliteModeSwitch createDataShareHelper succeed');
          this.satellitesModeSwitchDataShareHelper = data;
          this.satellitesModeSwitchDataShareHelper.on('dataChange', SATELLITE_MODE_SWITCH_URI, () => {
            HiLog.i(TAG, 'StelliteModeSwitch createDataShareHelper succeed');
            // 数据变更后触发拨号按钮修改
            CallServiceManager.getInstance().updateStelliteModeSwitch()
          });
        })
        .catch((err: BusinessError) => {
          HiLog.e(TAG, `activateRestore error: ${err.message}`);
        });
    } catch (err) {
      HiLog.e(TAG, `StelliteModeSwitch createDataShareHelper error: ${err.message}`);
    }
  }

  //风信子状态下拨号按钮修改
  private subscribesHyacinthModeSwitchChange(): void {
    HiLog.i(TAG, 'subscribesHyacinthModeSwitchChange')
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      dataShare.createDataShareHelper(context, SATELLITE_MODE_SWITCH_URI)
        .then((data: DataShareHelper.DataShareHelper) => {
          HiLog.i(TAG, 'HyacinthModeSwitch createDataShareHelper succeed');
          this.satellitesModeSwitchDataShareHelper = data;
          this.satellitesModeSwitchDataShareHelper.on('dataChange', SATELLITE_MODE_SWITCH_URI, () => {
            HiLog.i(TAG, 'HyacinthModeSwitch createDataShareHelper succeed');
            // 风信子数据变更后触发拨号按钮修改
            CallServiceManager.getInstance().updateHyacinthModeSwitch()
          });
        })
        .catch((err: BusinessError) => {
          HiLog.e(TAG, `activateRestore error: ${err.message}`);
        });
    } catch (err) {
      HiLog.e(TAG, `HyacinthModeSwitch createDataShareHelper error: ${err.message}`);
    }
  }

  private activateRestore(): void {
    HiLog.i(TAG, 'activateRestore');
    try {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('activateRestore', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        });
    } catch (err) {
      HiLog.e(TAG, `activateRestore error: ${err.message}`);
    }
  }

  private addFoldStatusListener() {
    if (!DeviceUtil.isFoldable()) {
      HiLog.i(TAG, `addFoldStatusListener fun tip: the current device is not a foldable screen`);
      return;
    }
    try {
      let initFoldStatus = display.getFoldStatus();
      AppStorage.setOrCreate<number>('FoldStatus', initFoldStatus);
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        AppStorage.setOrCreate<number>('FoldStatus', foldStatus);
      })
    } catch (err) {
      HiLog.e(TAG, `foldStatusChange err: ${err.message}`);
    }
  }

  private removeFoldStatusListener() {
    if (!DeviceUtil.isFoldable()) {
      HiLog.i(TAG, `removeFoldStatusListener fun tip: the current device is not a foldable screen`);
      return;
    }
    try {
      display.off('foldStatusChange');
      AppStorage.delete('FoldStatus');
    } catch (err) {
      HiLog.e(TAG, `Failed to unregister foldStatusChange err: ${err.message}`);
    }
  }

  private async removeFocusModelListener() {
    let localAccountId = await this.getOsAccountLocalId();
    if (localAccountId !== PRIVACY_ACCOUNT) {
      // 隐私空间无免打扰功能，不需要取消注册
      let removeFocusMode: boolean =
        settings.unregisterKeyObserver(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          FOCUS_MODE_ENABLE,
          settings.domainName.USER_SECURITY);
      HiLog.w(TAG, `do not disturb deregistration: ${removeFocusMode} `);
    }
  }
}