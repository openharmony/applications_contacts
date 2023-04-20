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

import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import Constants from '../../../../../common/src/main/ets/Constants';
import AbilityStage from "@ohos.app.ability.AbilityStage"
import notification from '@ohos.notificationManager';

const TAG = 'MyAbilityStage ';

export default class MyAbilityStage extends AbilityStage {
    onCreate() {
        HiLog.i(TAG, 'AbilityStage onCreate');
        notification.setNotificationEnable({
            bundle: "com.ohos.contacts"
        }, true, (err, data) => {
            if (err) {
                HiLog.e(TAG, "enableNotification err: " + JSON.stringify(err));
            }
        })
        notification.addSlot({
            type: notification.SlotType.SOCIAL_COMMUNICATION,
            level: notification.SlotLevel.LEVEL_HIGH,
            desc: "missedCall",
            lockscreenVisibility: 2
        })
        globalThis.config = Constants.initConfig(this.context);
    }
}