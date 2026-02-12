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

import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import rpc from '@ohos.rpc';
import { Caas } from './model/caasType';
import IdlCallServiceProxy from './service/idl_call_service_proxy';
import { CallServiceManagerApi, ExtraParam } from './api/CallServiceManagerApi';
import { CALL_SERVICE_ABILITY_NAME, MEETIME_SERVICE_BUNDLE_NAME } from './model/Constants';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import RemoteContactInfo from './model/RemoteContactInfo';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import IdlContactsServiceProxy from './service/idl_contacts_service_proxy';
import settings from '@ohos.settings';
import { RoamingUtils } from 'common/src/main/ets/util/RoamingUtils';
import { StringUtil } from 'common';


const TAG = '[MEETIME_contactUiFeature] CallServiceManager';
const HI_CALL_SUCCESS = 200300;

/**
 * 通话管理类
 */
export default class CallServiceManager implements CallServiceManagerApi {
  private static instance: CallServiceManager;
  private remoteObj: rpc.IRemoteObject | null = null;
  private INVALID_CONTACT_ID = -1;
  // 给contact_id传入一个无效值，匹配CallService的数据解析顺序

  public static EMPTY_STRING = ''
  // 畅连登录标记
  public static MEETIMT_LOGIN_FLAG = '1';
  // 畅连是否登录，从setting表查询的key值
  public static MEETIMT_LOGIN_FLAG_KEY = 'HiCall_Activated_Status';
  //开启卫星通信功能
  public static SATELLITE_MODE_SWITCH_ON = '1.0';
  //卫星功能是否开启，从setting表查询的key值
  public static SATELLITE_MODE_SWITCH = 'satellite_mode_switch'
  //风信子功能是否开启，从setting表查询的key值
  public static HYACINTH_MODE_SWITCH = 'satellite_mode_switch_hyacinth'
  // 拨号按键音类型
  public static DIALPAD_TOUCH_TONE_TYPE = 'dialpad_touch_tone_type'

  private constructor() {
  }

  /**
   * 获取ContastServiceManager实例
   *
   * @returns 结果
   */
  public static getInstance(): CallServiceManager {
    if (!CallServiceManager.instance) {
      CallServiceManager.instance = new CallServiceManager();
    }
    return CallServiceManager.instance;
  }

  public static getTestInstance(): CallServiceManager {
    return new CallServiceManager();
  }

  private async connectCallService(): Promise<rpc.IRemoteObject> {
    return await new Promise((resolve, reject) => {
      let want: Want = {
        'deviceId': '',
        'bundleName': MEETIME_SERVICE_BUNDLE_NAME,
        'abilityName': CALL_SERVICE_ABILITY_NAME
      };
      HiLog.i(TAG, 'starting ServiceExtensionAbility.');
      HiLog.i(TAG, 'onConnect start');
      let options: common.ConnectOptions = {
        onConnect: (elementName, remote) => {
          // Service在onConnect()方法中返回的rpc.RemoteObject实例
          HiLog.i(TAG, 'onConnect called');
          if (remote === null) {
            HiLog.e(TAG, `onConnect remote is null`);
            return;
          }
          resolve(remote);
        },
        onDisconnect: () => {
          HiLog.i(TAG, 'onDisconnect called');
        },
        onFailed: () => {
          HiLog.e(TAG, 'onFailed called');
        }
      }
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().connectServiceExtensionAbility(want, options);
    });
  }

  private async connectService(abilityName: string): Promise<rpc.IRemoteObject> {
    return await new Promise((resolve, reject) => {
      let want: Want = {
        'deviceId': '',
        'bundleName': MEETIME_SERVICE_BUNDLE_NAME,
        'abilityName': abilityName
      };
      HiLog.i(TAG, 'starting ServiceExtensionAbility.');
      HiLog.i(TAG, 'onConnect start');
      let options: common.ConnectOptions = {
        onConnect: (elementName, remote) => {
          // Service在onConnect()方法中返回的rpc.RemoteObject实例
          HiLog.i(TAG, 'onConnect called');
          if (remote === null) {
            HiLog.e(TAG, `onConnect remote is null`);
            return;
          }
          resolve(remote);
        },
        onDisconnect: () => {
          HiLog.i(TAG, 'onDisconnect called');
        },
        onFailed: () => {
          HiLog.e(TAG, 'onFailed called');
        }
      }
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().connectServiceExtensionAbility(want, options);
    });
  }


  /**
   * 发起通话
   *
   * @param callPhoneNumber 电话号码
   * @param mediaType 呼叫类型
   * @param extra 附加参数
   */
  public async placeCall(callPhoneNumber: string, mediaType: Caas.MediaType, extra?: ExtraParam): Promise<boolean> {
    let formatPhoneNumber = RoamingUtils.getFormatNumber(callPhoneNumber, 'CN');
    HiLog.w(TAG, `callPhoneNumber: ${StringUtil.maskSensitiveInfo(callPhoneNumber)
    }, formatPhoneNumber: ${StringUtil.maskSensitiveInfo(formatPhoneNumber)}`);
    if (formatPhoneNumber) {
      callPhoneNumber = formatPhoneNumber;
    }
    let isSuccess = false;
    if (!callPhoneNumber || typeof mediaType !== 'number') {
      HiLog.e(TAG, 'Parameter is invalid');
      return isSuccess;
    }

    // 连接畅联服务
    this.remoteObj = await this.connectCallService() as rpc.IRemoteObject;

    isSuccess = await new Promise((resolve, reject) => {
      let serviceExtProxy = new IdlCallServiceProxy(this.remoteObj as rpc.IRemoteObject);
      let remoteInfo = new RemoteContactInfo(CallServiceManager.EMPTY_STRING);
      if (extra?.contactId === undefined || extra?.contactId === null) {
        remoteInfo = new RemoteContactInfo(callPhoneNumber, this.INVALID_CONTACT_ID,
          extra?.deviceComId, extra?.deviceType);
      } else {
        remoteInfo = new RemoteContactInfo(callPhoneNumber,
          Number.parseInt(extra?.contactId.toString()), extra?.deviceComId, extra?.deviceType);
      }
      serviceExtProxy.startCallAction(CallServiceManager.EMPTY_STRING, mediaType, remoteInfo, (errorCode) => {
        HiLog.i(TAG, `placeCall errorCode, errorCode: ${errorCode}`);
        if (errorCode === HI_CALL_SUCCESS) {
          resolve(true);
        }
      });
    });

    return isSuccess;
  }


  /**
   * 判断畅连是否登录
   *
   */
  public async isLoginMeetime(): Promise<boolean> {
    let loginFlag =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<boolean>(ContactsGlobalThisHelper.MeeTimeLoginFlagName);
    if (loginFlag === undefined) {
      return false;
    }
    return loginFlag;
  }

  /**
   * 更新拨号按键音类型
   */
  public async updateDialpadTouchToneType() {
    // 数据变更后重新查询
    HiLog.i(TAG, 'refresh dialpadTouchToneType ');
    settings.getValue(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      CallServiceManager.DIALPAD_TOUCH_TONE_TYPE,
      settings.domainName.USER_PROPERTY).then((dialpadTouchToneType: string) => {
      HiLog.i(TAG, 'dialpadTouchToneType = ' + dialpadTouchToneType);
      AppStorage.SetOrCreate<string>('dialpadTouchToneType', dialpadTouchToneType);
    })
  }

  /**
   * 更新畅连是否登录标记
   */
  public async updateMeetimeLoginFlag() {
    // 数据变更后重新查询
    HiLog.i(TAG, 'refresh settings is meetime login start ');
    settings.getValue(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      CallServiceManager.MEETIMT_LOGIN_FLAG_KEY,
      settings.domainName.USER_PROPERTY
    ).then((activatedStatus: string) => {
      let loginFlag = (activatedStatus == CallServiceManager.MEETIMT_LOGIN_FLAG) ? true : false;
      HiLog.i(TAG, 'refresh settings is meetime login end ' + loginFlag);
      ContactsGlobalThisHelper.GetGlobalThis().set<boolean>(ContactsGlobalThisHelper.MeeTimeLoginFlagName, loginFlag);
    });

  }

  /**
   * 更新仙人掌功能是否开启
   */
  public async updateStelliteModeSwitch() {
    // 数据变更后重新查询
    HiLog.i(TAG, 'refresh updateStelliteModeSwitch  start ');
    settings.getValue(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      CallServiceManager.SATELLITE_MODE_SWITCH).then((activatedStatus: string) => {
      let stelliteMode = (activatedStatus == CallServiceManager.SATELLITE_MODE_SWITCH_ON) ? true : false;
      HiLog.i(TAG, 'refresh updateStelliteModeSwitch end & activatedStatus= ' + activatedStatus);
      AppStorage.SetOrCreate<boolean>('isSatelliteMode', stelliteMode);
    })
  }

  /**
   * 更新风信子功能是否开启
   */
  public async updateHyacinthModeSwitch() {
    // 数据变更后重新查询
    HiLog.i(TAG, 'refresh updateHyacinthModeSwitch  start ');
    settings.getValue(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      CallServiceManager.HYACINTH_MODE_SWITCH).then((activatedStatus: string) => {
      let hyacinthMode = (activatedStatus == CallServiceManager.SATELLITE_MODE_SWITCH_ON) ? true : false;
      HiLog.i(TAG, 'refresh updateHyacinthModeSwitch end & activatedStatus= ' + activatedStatus);
      AppStorage.SetOrCreate<boolean>('isHyacinthMode', hyacinthMode);
    })
  }

  /**
   * 调用畅连接口，返回最新的畅连能力
   *
   */
  public async syncContactMeeTimeAbility(contactId: number,
    phoneNumbers: Record<string, string | number>[]): Promise<string> {

    HiLog.i(TAG, 'begin query metime ability')
    let msg = '';
    // 连接畅连服务
    this.remoteObj = await this.connectService('ContactServiceExtAbility') as rpc.IRemoteObject;

    let serviceExtProxy = new IdlContactsServiceProxy(this.remoteObj);

    msg = await new Promise((resolve, reject) => {
      serviceExtProxy.queryContactCapabilityByPhoneNumbers(Number.parseInt(contactId.toString()),
        JSON.stringify(phoneNumbers), (result: string) => {
          HiLog.i(TAG, 'end query metime ability')
          resolve(result);
        })
    });


    return msg;
  }
}
