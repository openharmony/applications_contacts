/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http:// www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @file: call manager service
 */
import commonEvent from '@ohos.commonEvent';
import wantAgent from '@ohos.wantAgent';
import notify from '@ohos.notification';
let Subscriber;
let id = 1;
const events = ['usual.event.INCOMING_CALL_MISSED'];


class MissedCallsService {
    constructor() {
    }

    async addSubscriber() {
        Subscriber = await new Promise((resolve, reject) => {
            commonEvent.createSubscriber({ events },
                (err, data) => {
                    resolve(data);
                }
            );
        });

        commonEvent.subscribe(Subscriber, (err, data) => {
            this.sendNotification(data.data);
        });
    }

    async sendNotification(text) {
        const notificationRequest = {
            content: {
                contentType: notify.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
                normal: {
                    title: 'voice call',
                    text: '',
                },
            },
            id: id,
            slotType: notify.SlotType.OTHER_TYPES,
            deliveryTime: new Date().getTime()
        };
        const res = await wantAgent.getWantAgent({
            wants: [{
                        bundleName: 'com.ohos.contacts',
                        abilityName: 'com.ohos.contacts.MainAbility',
                        uri: 'page_flag_missed_calls',
                    }],
            operationType: wantAgent.OperationType.START_ABILITY,
            requestCode: 0,
        });
        Object.assign(notificationRequest, { wantAgent: res });
        notificationRequest.content.normal.title = text;
        notificationRequest.content.normal.text = this.$t('value.callRecords.missedCalls');
        id++;
        notify.publish(notificationRequest);
    }
}

let service = new MissedCallsService();

export default service;