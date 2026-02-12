/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { RoamingData, RoamingUtils, UpdateFormatNumerParam } from '../../../../../../common/src/main/ets/util/RoamingUtils';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { Phone } from '../../../../../../feature/contact/src/main/ets/contract/Phone';
import { BusinessError } from '@ohos.base';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import {
  queryFormatNumberByNumber,
  updateFormatNumberByNumber
} from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import {
  queryValidFormatNumber
} from '../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import call from '@ohos.telephony.call';
import taskpool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { RoamingNumItem, RoamingSelectNumDialog } from '../../pages/dialog/RoamingSelectNumDialog';
import { UIContext } from '@ohos.arkui.UIContext';
import GetNumberLocation from '../../util/GetNumberLocation';
import {
  QUERY_LOCATION_PHONE_NUMBER_MAX_LEN,
  QUERY_LOCATION_PHONE_NUMBER_MIN_LEN
} from '../../presenter/dialer/DialerPresenter';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';

const TAG = 'RoamingManager';

export class RoamingManager {
  private static instance: RoamingManager;

  public static getInstance(): RoamingManager {
    if (!RoamingManager.instance) {
      RoamingManager.instance = new RoamingManager();
    }
    return RoamingManager.instance;
  }

  /**
   * Handle roaming dial, get dial number from phone number and format number, then dial out
   * @param phoneNum the phone number
   * @param options the param of dial out with slot
   * @param callback whether dial out success of failed
   */
  public async handleRoaming(uiContext: UIContext, phoneOrigin: string | undefined,
    options?: call.DialOptions, callback?: Function) {
    phoneOrigin = StringUtil.removeSpace(phoneOrigin);
    phoneOrigin = StringUtil.removeDash(phoneOrigin);
    if (!phoneOrigin || phoneOrigin.length === 0) {
      HiLog.e(TAG, `handleRoaming failed. Cause: phone number is null`);
      this.roamingCallback(callback, false)
      return;
    }
    let phoneNum: string = phoneOrigin;
    if (await RoamingUtils.isNoNeedDealWithRoaming(phoneNum, options?.accountId)) {
      HiLog.w(TAG, `No need to deal with roaming`);
      this.dialing(phoneNum, options, callback);
      return;
    }
    let callLogFormatNum: string | undefined = await this.queryValidFormatNumber(
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), phoneNum);
    this.queryFormatNumberTask(phoneNum, (info: RoamingData | undefined) => {
      let formatNum = info?.formatNumber;
      RoamingUtils.getRoamingDialNumber(phoneNum, formatNum, callLogFormatNum, options?.accountId)
        .then((phoneList: string[]) => {
          if (!phoneList || phoneList.length === 0) {
            HiLog.e(TAG, `handleRoaming failed. Cause: no volid number`);
            this.roamingCallback(callback, false);
            return;
          }
          HiLog.w(TAG, `phoneList length is: ${phoneList.length}`);
          if (phoneList.length === 1) {
            this.dialing(phoneList[0], options, callback);
            return;
          }
          this.buildRoamingNumItems(phoneList, info?.labelId).then((roamingNumberList: RoamingNumItem[]) => {
            if (!roamingNumberList || roamingNumberList.length === 0) {
              HiLog.e(TAG, `handleRoaming failed, roaming phone list is null`);
              this.roamingCallback(callback, false);
              return;
            }
            let roamingDialogCallback = (item?: RoamingNumItem) => {
              this.handleDialogCallback(item, phoneNum, formatNum, options, callback);
            }
            RoamingSelectNumDialog.showDialog(uiContext, roamingNumberList, roamingDialogCallback);
          });
        });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getDialingNumber failed. Cause: %s', error?.message);
      this.roamingCallback(callback, false);
    });
  }

  /**
   * Query formatNumber for phone number
   *
   * @param phoneNumber which to find
   * @param callBack the query result
   */
  public async queryValidFormatNumber(context: common.Context,
    phoneNumber: string): Promise<string | undefined> {
    try {
      let task = new taskpool.Task(queryValidFormatNumber, context, phoneNumber);
      return await taskpool.execute(task) as string | undefined;
    } catch (err) {
      HiLog.e(TAG, 'queryFormatNumberTask failed err: ' + (err as BusinessError).message);
      return undefined;
    }
  }

  public handleDialogCallback(item: RoamingNumItem | undefined, phoneNum: string, formatNum: string | undefined,
    options: call.DialOptions | undefined, callback: Function | undefined) {
    if (item) {
      this.updateFormatNumber(phoneNum, formatNum, item.number);
      this.dialing(item.number, options, callback);
    } else {
      HiLog.e(TAG, `handleRoaming failed, no select any item in roaming number`);
      this.roamingCallback(callback, false);
    }
  }

  /**
   * Query formatNumber for phone number
   *
   * @param phoneNumber which to find
   * @param callBack the query result
   */
  public async queryFormatNumberTask(phoneNumber: string, callback?: Function) {
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    try {
      let task = new taskpool.Task(queryFormatNumberByNumber, context, phoneNumber);
      taskpool.execute(task).then((data: Object) => {
        let roamingData: RoamingData | undefined = data as RoamingData | undefined;
        if (callback) {
          callback(roamingData);
        }
      });
    } catch (err) {
      if (callback) {
        callback(false);
      }
      HiLog.e(TAG, 'queryFormatNumberTask failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * Update formatNumber for phone number
   *
   * @param phoneNumber which to find
   * @param callBack is update success
   */
  public async updateFormatNumberTask(
    phoneNumberList: string[], callback?: Function) {
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    try {
      let task = new taskpool.Task(updateFormatNumberByNumber, context, phoneNumberList);
      taskpool.execute(task).then((data: Object) => {
        let result: number = data as number;
        if (callback) {
          callback(result);
        }
      });
    } catch (err) {
      if (callback) {
        callback(-1);
      }
      HiLog.e(TAG, 'updateFormatNumberTask failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * Update format number if user choose the number of auto add prefix
   * @param phone which the origin number
   * @param oldFormatNumber which is query contacts db by origin number
   * @param newFormatNumber which is need to be updated
   * @param callback if update success
   */
  public async updateFormatNumber(
    phone: string, oldFormatNumber: string | undefined, newFormatNumber: string, callback?: Function) {
    let tempNum = phone;
    tempNum = StringUtil.removeSpace(tempNum);
    tempNum = StringUtil.removeDash(tempNum);
    if (tempNum === newFormatNumber) {
      HiLog.w(TAG, 'choose original num, no need to update format number');
      return;
    }
    if (oldFormatNumber === undefined) {
      HiLog.w(TAG, 'contacts not found by phone number, no need to update format number');
      return;
    }
    let parmaList: string[] = [];
    parmaList[UpdateFormatNumerParam.PHONE_NUMBER_INDEX] = phone;
    parmaList[UpdateFormatNumerParam.OLD_FORMAT_NUMBER_INDEX] = oldFormatNumber;
    parmaList[UpdateFormatNumerParam.NEW_FORMAT_NUMBER_INDEX] = newFormatNumber;
    this.updateFormatNumberTask(parmaList, callback);
  }

  /**
   * Get location by number
   *
   * @param phones which need to get
   * @param context to get location
   * @returns the number's locations
   */
  public async getLocations(phones: string[] | undefined, context?: common.Context): Promise<string[]> {
    if (!phones || phones.length === 0) {
      return [];
    }
    return new Promise<string[]>((resolve) => {
      GetNumberLocation.getNumberLocationArr(phones, (location: string[]) => {
        resolve(location);
      }, context);
    });
  }

  public async buildRoamingNumItems(phoneList: string[], labelId?: number): Promise<RoamingNumItem[]> {
    let roamingNumberList: RoamingNumItem[] = [];
    if (phoneList.length === 0) {
      return roamingNumberList;
    }
    let locations: string[] = await this.getLocations(phoneList);
    if (locations.length !== phoneList.length) {
      locations = new Array(phoneList.length).fill($r('app.string.unknow_location'));
    }
    for (let i = 0; i < phoneList.length; i++) {
      let numLocation: string | Resource = (StringUtil.isEmpty(locations[i]) || locations[i] === 'N') ?
        $r('app.string.unknow_location') : locations[i];
      roamingNumberList.push({
        number: phoneList[i],
        numType: Phone.getTypeLabelResource(labelId ?? 7),
        location: numLocation
      });
    }
    return roamingNumberList;
  }

  /**
   * 连接眼镜时拨打电话在眼镜端拉起通话界面，并标记由眼镜打出，拨打视频通话变为拨打语音
   * @param options
   * @returns
   */
  private isDialByVisionGlass(options: call.DialCallOptions): call.DialCallOptions {
    let isInVisionGlass = AppStorage.get<boolean>(VisionGlassConstants.KEY_IS_IN_VISION_GLASS);
    if (!isInVisionGlass) {
      return options;
    }
    if (options === undefined) {
      options = {
        extraParams: {
          dialByGlass: true
        }
      }
    } else if (options.extraParams === undefined) {
      options.extraParams = {
        dialByGlass: true
      };
    } else {
      options.extraParams.dialByGlass = true;
    }
    HiLog.i(TAG, 'dial by vision glass.');
    if (options.videoState === call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL) {
      options.videoState = call.VideoStateType.TYPE_VOICE;
    }
    return options;
  }

  public dialing(phoneNumber: string, options?: call.DialOptions, callback?: Function) {
    options = this.isDialByVisionGlass(options as call.DialCallOptions);
    PhoneNumber.fromString(phoneNumber).dial(options).then(() => {
      this.roamingCallback(callback, true);
      HiLog.e(TAG, 'dialing success.');
    }).catch((error: BusinessError) => {
      this.roamingCallback(callback, false);
      HiLog.e(TAG, 'dialing failed. Cause: %s', error?.message);
    })
  }

  public roamingCallback(callback?: Function, result?: boolean) {
    if (callback) {
      callback(result);
    }
  }
}