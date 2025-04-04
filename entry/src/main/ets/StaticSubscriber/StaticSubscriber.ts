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
import { HiLog } from '../../../../../common';
import { MissedCallService } from '../../../../../feature/call';
import { PhoneNumber } from '../../../../../feature/phonenumber';
import call from '@ohos.telephony.call';
import telephonySim from '@ohos.telephony.sim';

const TAG = 'StaticSubscriber'
var StaticSubscriberExtensionAbility = globalThis.requireNapi('application.StaticSubscriberExtensionAbility');
export default class StaticSubscriber extends StaticSubscriberExtensionAbility {
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
        HiLog.e(TAG, `callAction, ${i} error: ${JSON.stringify(err.message)}`);
      }
    }
    if (readySimCount == 1 && readySim != -1) {
      PhoneNumber.fromString(phoneNumber).dial({
        accountId: readySim,
      })
    } else {
      call.makeCall(phoneNumber).catch(err => {
        HiLog.e(TAG, `callAction,  error: ${JSON.stringify(err)}`);
      })
    }
  }

  private isSimReady(state) {
    return state == telephonySim.SimState.SIM_STATE_READY || state == telephonySim.SimState.SIM_STATE_LOADED;
  }

  onReceiveEvent(event) {
    HiLog.i(TAG, 'onReceiveEvent, event:' + JSON.stringify(event));
    const missCallData = JSON.parse(JSON.stringify(event));
    const parameters = JSON.parse(JSON.stringify(missCallData.parameters));
    let updateMissedCallNotificationsMap: Map<string, string> = new Map();
    MissedCallService.getInstance().init(this.context);
    if ('usual.event.INCOMING_CALL_MISSED' == event.event) {
      MissedCallService.getInstance().updateMissedCallNotifications();
      if (parameters.countList != null) {
        updateMissedCallNotificationsMap.set('missedPhoneJson', missCallData.parameters);
        MissedCallService.getInstance().unreadCallNotification(updateMissedCallNotificationsMap);
      }
    } else if ('contact.event.CANCEL_MISSED' == event.event) {
      if (event.parameters?.missedCallData) {
        if ('notification.event.dialBack' == event.parameters?.action) {
          let phoneNum: string = event.parameters.missedCallData.phoneNumber
          if (phoneNum) {
            this.callAction(phoneNum);
          }
        }
        MissedCallService.getInstance().cancelMissedNotificationAction(event.parameters?.missedCallData)
      } else {
        MissedCallService.getInstance().cancelAllMissedNotificationAction()
      }
    }
  }
}