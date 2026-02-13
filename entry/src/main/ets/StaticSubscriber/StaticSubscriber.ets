/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { HiLog, ObjectUtil } from '../../../../../common';
import { MissedCallService } from '../../../../../feature/call';
import call from '@ohos.telephony.call';
import telephonySim from '@ohos.telephony.sim';
import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility'
import { sharedPreferencesUtils } from '../../../../../common';
import { BusinessError } from '@ohos.base';
import sim from '@ohos.telephony.sim';
import LooseObject from '../model/type/LooseObject';
import { FormCardController } from '../card/common/FormCardController';
import { settings } from '@kit.BasicServicesKit';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';

const TAG = 'StaticSubscriber'
const SPAMSHIELD_BLOCKING_NOTIFY_SWITCH = 'spamshield_blocking_notify'
const SPAMSHIELD_BLOCKING_NOTIFY_SWITCH_ON = '1'
const SPAMSHIELD_BLOCKING_NOTIFY_SWITCH_OFF = '0'
const SETTING_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';

export default class StaticSubscriber extends StaticSubscriberExtensionAbility {
  public mFormCardController: FormCardController = FormCardController.getInstance();
  public dataShareHelper?: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper>;
  public resultDT: number = 0;

  private async callAction(phoneNumber: string) {
    HiLog.i(TAG, 'callAction')
    let readySimCount: number = 0;
    let readySim = -1;
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      try {
        const state = await telephonySim.getSimState(i);
        if (state) {
          if (this.isSimReady(state)) {
            readySimCount++;
            readySim = i;
          }
        }
      } catch (err) {
        HiLog.e(TAG, `callAction, ${i} error: ${err?.message}`);
      }
    }
    if (readySimCount == 1 && readySim != -1) {
      this.mFormCardController.dealCallNumber(phoneNumber);
    } else {
      telephonySim.getDefaultVoiceSlotId((err, slot: number) => {
        if (err) {

          HiLog.e(TAG, `getDefaultVoiceSlotId, ${slot} error: ${err?.message}, stack: ${err?.stack}`);
          this.callSharingPhone((modemState: string, callSharing: number) => {
            if (modemState === '1_sink' && callSharing === 1 && !call.hasVoiceCapability()) {
              this.mFormCardController.callSharingNumber(phoneNumber);
            } else {
              // get context
              call.makeCall(this.context as Context, phoneNumber).catch((err: BusinessError) => {
                HiLog.e(TAG, `callAction, error: ${err?.message}, stack: ${err?.stack}`);
              })
            }
          });

        } else {

          HiLog.w(TAG, `getDefaultVoiceSlotId,  ${slot} `);
          let options: call.DialOptions = {
            accountId: slot,
          }
          call.dialCall(phoneNumber, options, (err: BusinessError<void>, value: void) => {
            if (err) {
              HiLog.e(TAG, `dial finish err: ${err?.message}`);
            } else {
              HiLog.w(TAG, 'dial finish');
            }
          });

        }
      })
    }
  }

  private isSimReady(state: sim.SimState) {
    return state == telephonySim.SimState.SIM_STATE_READY || state == telephonySim.SimState.SIM_STATE_LOADED;
  }

  async callSharingPhone(callback: Function) {
    HiLog.e(TAG, 'callSharingPhone!');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(this.context, SETTING_MODE_URI);
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('KEYWORD', 'distributed_modem_state');
    condition.or()
    condition.equalTo('KEYWORD', 'distributed_call_phone_sharing_sink');
    dataShareHelper.query(SETTING_MODE_URI, condition, [])
      .then((resultSet: DataShareResultSet) => {
        try {
          let modemState: string = '';
          let callSharing: number = -1;
          if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            callSharing = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
            resultSet.goToLastRow();
            modemState = resultSet.getString(resultSet.getColumnIndex('VALUE'));
            HiLog.i(TAG, 'querySettingMode success value: ' + modemState + ' - ' + callSharing);
          } else {
            HiLog.e(TAG, 'querySettingMode null ');
          }
          callback(modemState, callSharing);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
  }

  onReceiveEvent(event: LooseObject) {
    HiLog.i(TAG, 'onReceiveEvent, event:' + event?.event);
    let parameters: LooseObject = JSON.parse(JSON.stringify(event.parameters));
    MissedCallService.getInstance().init(this.context);
    // 未接来电通知
    if ('usual.event.INCOMING_CALL_MISSED' == event.event) {
      if (parameters.countList && parameters.countList != undefined) {
        MissedCallService.getInstance().updateAllMissedCallNotifications(this.context as Context).catch((e: Error) => {
          HiLog.e(TAG, `updateAllMissedCallNotifications err: ${e.message}`);
          HiLog.e(TAG, `updateAllMissedCallNotifications err: ${e.stack}`);
        });
      } else if (parameters.isBlocked && parameters.phoneNumber) {
        //收到拦截来电，发送拦截通知，如果是黑名单号码，更新拦截次数
        this.sendBlockedNotification(parameters);
      } else if (parameters.isHarassmentGuidance && parameters.slotId != undefined) {
        // 通知拦截引导
        MissedCallService.getInstance().sendInterceptNotificationSlotId(parameters.slotId);
      } else {
        MissedCallService.getInstance().updateMissedCallNotifications(this.context as Context).catch((e: Error) => {
          HiLog.e(TAG, `updateMissedCallNotifications err: ${e.message}`);
          HiLog.e(TAG, `updateMissedCallNotifications err: ${e.stack}`);
        });
      }
    } else if ('contact.event.CANCEL_MISSED' == event.event) {
      // 取消未接来电通知
      if (event.parameters?.missedCallData != undefined) {
        if (event.parameters.missedCallData.isBlocked) {
          // 进入通话防护页面，将所有拦截未读数量置为0，标题、文本中个数置为0，并且清除拦截通知
          this.cancelInterceptionNotificationAction();
        } else if (event.parameters.missedCallData.isRemoveBlocked) {
          // 移除拦截通知，拦截通知标题（拦截 %d 个骚扰电话）中个数置为0，未读数量不变
          sharedPreferencesUtils.saveToPreferences('newInterceptionCallsCount', 0)
        } else {
          if ('notification.event.dialBack' == event.parameters?.action) {
            let phoneNum: string = event.parameters.missedCallData.phoneNumber
            if (phoneNum) {
              this.callAction(phoneNum);
            }
          }
          // 取消单个未接来电
          MissedCallService.getInstance()
            .cancelMissedNotificationAction(event.parameters?.missedCallData).catch((e: Error) => {
            HiLog.e(TAG, `cancelMissedNotificationAction err: ${e.message}`);
            HiLog.e(TAG, `cancelMissedNotificationAction err: ${e.stack}`);
          });
        }
      } else {
        // 取消所有未接来电
        MissedCallService.getInstance().cancelAllMissedNotificationAction().catch((e: Error) => {
          HiLog.e(TAG, `cancelAllMissedNotificationAction err: ${e.message}`);
          HiLog.e(TAG, `cancelAllMissedNotificationAction err: ${e.stack}`);
        });
      }
    }
  }

  private sendBlockedNotification(parameters: LooseObject) {
    sharedPreferencesUtils.getFromPreferences('interceptionCallsCount', 0).then((count) => {
      let interceptionCallsCount: number = count as number + 1;
      sharedPreferencesUtils.saveToPreferences('interceptionCallsCount', interceptionCallsCount).then(() => {
        sharedPreferencesUtils.getFromPreferences('newInterceptionCallsCount', 0).then((count) => {
          let newInterceptionCallsCount: number = count as number + 1;
          sharedPreferencesUtils.saveToPreferences('newInterceptionCallsCount', newInterceptionCallsCount).then(() => {
            let blockingNotifyState = settings.getValueSync(this.context as Context, SPAMSHIELD_BLOCKING_NOTIFY_SWITCH,
              SPAMSHIELD_BLOCKING_NOTIFY_SWITCH_ON);
            HiLog.i(TAG, `sendBlockedNotification blockingNotifyState: ${blockingNotifyState}`);
            if (blockingNotifyState === SPAMSHIELD_BLOCKING_NOTIFY_SWITCH_OFF) {
              return;
            }
            MissedCallService.getInstance()
              .updateBlockedNotificationAction(parameters.phoneNumber,
                this.context, parameters?.detectDetails).catch((e: Error) => {
              HiLog.e(TAG, `updateBlockedNotificationAction err: ${e.message}`);
              HiLog.e(TAG, `updateBlockedNotificationAction err: ${e.stack}`);
            });
          });
        });
      });
    });
  }

  private cancelInterceptionNotificationAction() {
    let interceptionCallsCount: number = 0;
    sharedPreferencesUtils.saveToPreferences('interceptionCallsCount', interceptionCallsCount);
    sharedPreferencesUtils.saveToPreferences('newInterceptionCallsCount', interceptionCallsCount);
    MissedCallService.getInstance()
      .cancelInterceptionNotificationAction().catch((e: Error) => {
      HiLog.e(TAG, `cancelInterceptionNotificationAction err: ${e.message}`);
      HiLog.e(TAG, `cancelInterceptionNotificationAction err: ${e.stack}`);
    });
  }
}