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
import { HiLog } from "../../../../../common";
import { MissedCallService } from "../../../../../feature/call";

const TAG = "StaticSubscriber"
var StaticSubscriberExtensionAbility = globalThis.requireNapi('application.StaticSubscriberExtensionAbility');
export default class StaticSubscriber extends StaticSubscriberExtensionAbility {
    onReceiveEvent(event) {
        HiLog.i(TAG, 'onReceiveEvent, event:' + JSON.stringify(event));
        MissedCallService.getInstance().init(this.context);
        if ("usual.event.INCOMING_CALL_MISSED" == event.event) {
            MissedCallService.getInstance().updateMissedCallNotifications();
        } else if ( "contact.event.CANCEL_MISSED" == event.event) {
            if (event.parameters?.missedCallData) {
                MissedCallService.getInstance().cancelMissedNotificationAction(event.parameters?.missedCallData)
            } else {
                MissedCallService.getInstance().cancelAllMissedNotificationAction()
            }
        }
    }
}