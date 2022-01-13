/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import commonEvent from '@ohos.commonEvent';
import wantAgent from '@ohos.wantAgent';
import notify from '@ohos.notification';
import sim from '@ohos.telephony.sim';
import radio from '@ohos.telephony.radio';
import CONSTANTS from '../../common/constants/Constants.js'

const EventConstants = {
    EVENTPACKAGEADDED: 'usual.event.PACKAGEADDED',
    EVENTPACKAGECHANGED: 'usual.event.PACKAGECHANGED',
    EVENTPACKAGEREMOVED: 'usual.event.PACKAGEREMOVED',
    EVENTSMSRECEIVE: 'usual.event.SMSRECEIVECOMPLETED',
    EVENTINCOMINGCALLMISSED: 'usual.event.INCOMINGCALLMISSED'

}

let mCommonEventSubscriber = null;
let mCommonEventSubscribeInfo = {
    events: [EventConstants.EVENTPACKAGEADDED,
    EventConstants.EVENTPACKAGECHANGED,
    EventConstants.EVENTPACKAGEREMOVED,
    EventConstants.EVENTSMSRECEIVE,
    EventConstants.EVENTINCOMINGCALLMISSED
    ]
};

let id = 1;
const notificationRequest = {
    content: {
        contentType: notify.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
            title: 'voice call',
            text: '',
        },
    },
    id,
    slotType: notify.SlotType.OTHER_TYPES,
    deliveryTime: new Date().getTime()
};

var TAG = 'indexDemo';

export default {
    testGetIMEI() {
        console.info(TAG + 'testGetIMEI' + 'logMessage testGetIMEI start!!')
        radio.getIMEI(0).then(data => {
            console.info(TAG + 'testGetIMEI' + 'logMessage testGetIMEI :' + data);
        }).catch(err => {
            console.info(TAG + 'testGetIMEI' + 'logMessage testGetIMEI error:' + err);
        });
    },
    data: {},
    onCreate() {
        console.info(TAG + 'onCreate' + 'logMessage onCreate index_demo');

    },
    onInit() {
        console.info(TAG + 'onInit' + 'logMessage onInit index_demo');
    },
    onShow() {
        console.info(TAG + 'onShow' + 'logMessage onShow index_demo');
    },
    onDestroy() {

    },

    subscribeMissedCallsEvent() {
        console.info(TAG + 'subscribeMissedCallsEvent' + 'logMessage subscribeMissedCallsEvent!!')
        console.info(TAG + 'subscribeMissedCallsEvent' + 'logMessage commonEvent = ' + commonEvent);
        commonEvent.createSubscriber(mCommonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
        console.info(TAG + 'subscribeMissedCallsEvent' + 'logMessage createSubscriber success!!!');
    },

    unSubscribeMissedCallsEvent() {
        console.info(TAG + 'logMessage unSubscribeMissedCallsEvent start!!!');
        commonEvent.unsubscribe(mCommonEventSubscriber, () => {
            console.info(TAG + 'logMessage unSubscribe MissedCalls Event success!!!');
        });
    },

    createSubscriberCallBack(err, data) {
        console.info(TAG + 'logMessage createSubscriberCallBack success!!! commonEventSubscriber = ' + data);
        mCommonEventSubscriber = data;
        commonEvent.subscribe(mCommonEventSubscriber, this.subscriberCallBack.bind(this));
        console.info(TAG + 'createSubscriberCallBack' + 'logMessage subscribe MissedCallsEvent success!!!');
    },
    subscriberCallBack(err, data) {
        console.info(TAG + 'subscriberCallBack' + 'logMessage eventData callBackSuccess!!!' + JSON.stringify(data));
        this.sendNotification(data.data);
        console.info(TAG + 'subscriberCallBack' + 'logMessage sendNotification success!!!!!');
    },
    sendNotification: async function (text) {
        console.info(TAG + 'sendNotification' + 'logMessage send notification start!!!');
        const res = await wantAgent.getWantAgent({
            wants: [{
                        bundleName: 'com.ohos.contacts_l2',
                        abilityName: 'com.ohos.contacts.MainAbility',
                    }],
            operationType: wantAgent.OperationType.START_ABILITY,
            requestCode: 0,
            wantAgentFlags: [wantAgent.Flags.ONETIMEFLAG],
        });
        console.info(TAG + 'sendNotification' + 'logMessage send notification start!!! res = ' + res);
        Object.assign(notificationRequest, {
            wantAgent: res
        });
        console.info(TAG + 'sendNotification' + 'logMessage send notification start!!! Object = ' + Object);
        notificationRequest.content.normal.title = text;
        notificationRequest.content.normal.text = 'Ring 7 seconds'
        console.info(TAG + 'sendNotification' + 'logMessage send notification start!!! text = ' + text);
        notify.publish(notificationRequest);
    },
    testGetSimSpn() {
        console.info(TAG + 'testGetSimSpn' + 'logMessage getSpn start!!')
        sim.getSimSpn(0).then(data => {
            console.info(TAG + 'testGetSimSpn' + 'logMessage getSPN :' + data);
        }).catch(err => {
            console.info(TAG + 'testGetSimSpn' + 'logMessage getSpnMessage error:' + err);
        })
    },
    testGetSimState() {
        console.info(TAG + 'testGetSimState' + 'logMessage getSimState start!!')
        sim.getSimState(0).then(data => {
            console.info(TAG + 'testGetSimState' + 'logMessage getSimState :' + data);
        }).catch(err => {
            console.info(TAG + 'testGetSimState' + 'logMessage getSimState error:' + err);
        });
    },
    testGetSimMessage() {
        console.info(TAG + 'testGetSimMessage' + 'logMessage testGetSimMessage start!!')
        radio.getNetworkState(0).then(data => {
            console.info(TAG + 'testGetSimMessage' + 'logMessage testGetSimMessage :' + JSON.stringify(data));
        }).catch(err => {
            console.info(TAG + 'testGetSimMessage' + 'logMessage testGetSimMessage error:' + err);
        });
    },
    testHasSimCard1() {
        console.info(TAG + 'testHasSimCard1' + 'logMessage testHasSimCard1 start!!')
        sim.hasSimCard(0).then(data => {
            console.info(TAG + 'testHasSimCard1' + 'logMessage testHasSimCard1 :' + data);
        }).catch(err => {
            console.info(TAG + 'testHasSimCard1' + 'logMessage testHasSimCard1 error:' + err);
        });
    },
    testHasSimCard2() {
        console.info(TAG + 'testHasSimCard2' + 'logMessage testHasSimCard2 start!!')
        sim.hasSimCard(1).then(data => {
            console.info(TAG + 'testHasSimCard2' + 'logMessage testHasSimCard2 :' + data);
        }).catch(err => {
            console.info(TAG + 'testHasSimCard2' + 'logMessage testHasSimCard2 error:' + err);
        });
    },
    testGetSimCount() {
        console.info(TAG + 'testGetSimCount' + 'logMessage testGetSimCount start!');
        this.testGetSimCardCount((count) => {
            console.info(TAG + 'testGetSimCount' + 'logMessage simCard count = ' + count);
        });
    },
    async testGetSimCardCount(callBack) {
        var hasCard1 = false;
        try {
            hasCard1 = await sim.hasSimCard(0);
        } catch {

        }
        console.info(TAG + 'testGetSimCardCount' + 'logMessage hasCard1 :' + hasCard1);
        var hasCard2 = false
        try {
            hasCard2 = await sim.hasSimCard(1);
        } catch {

        }
        console.info(TAG + 'testGetSimCardCount' + 'logMessage hasCard2 :' + hasCard2);
        var count = 0;
        if (hasCard1 && hasCard2) {
            count = 2;
        } else if (hasCard1 || hasCard2) {
            count = 1;
        } else {
            count = 0;
        }
        callBack(count);
    },
    testInsertCallLog: async function () {
        var DAHelper = this.$app.$def.getDAHelper(CONSTANTS.uri.CALLLOG_DB_URI);
        var phoneNumbers = ['18792404709', '19991445854', '19891445853', '18161845409'];
        var formatPhoneNumbers = ['187 9240 4709', '199 9144 5854', '198 9144 5853', '181 6184 5409'];
        var callTypes = ['1', '2', '3', '5'];
        var numIndex = Math.floor(Math.random() * 4);
        var typeIndex = Math.floor(Math.random() * 4);
        var now = new Date();
        var timestamp = now.getTime();
        var insertValues = {
            'phone_number': phoneNumbers[numIndex],
            'display_name': '',
            'call_direction': callTypes[typeIndex],
            'voicemail_uri': '',
            'sim_type': '',
            'is_hd': '0',
            'is_read': '',
            'ring_duration': '123456',
            'talk_duration': '123456',
            'format_number': formatPhoneNumbers[numIndex],
            'quicksearch_key': '',
            'number_type': '',
            'begin_time': '',
            'end_time': '',
            'answer_state': '',
            'create_time': timestamp + '',
            'number_location': 'Xi an',
            'photo_id': '',
            'photo_uri': '',
            'country_iso_code': '',
        };
        console.info(TAG + 'testInsertCallLog' + 'logMessage Insert calllog uri = ' + CONSTANTS.uri.CALL_LOG_URI);
        DAHelper.insert(
            CONSTANTS.uri.CALL_LOG_URI,
            insertValues,
        ).then(data => {
            this.contactId = data;
            console.info(TAG + 'testInsertCallLog logMessage Insert calllog result success! data = ' + data.length);
        }).catch(error => {
            console.info(TAG + 'testInsertCallLog' + 'logMessage insert error:' + error);
        });
    },

    testInsertVoiceMail: async function () {
        var DAHelper = this.$app.$def.getDAHelper(CONSTANTS.uri.VOICEMAIL_DB_URI);
        var phoneNumbers = ['12599', '12596'];
        var numIndex = Math.floor(Math.random() * 2);
        var duration = 10 + Math.floor(Math.random() * 10);
        var now = new Date();
        var timestamp = now.getTime();
        var insertValues = {
            'phone_number': phoneNumbers[numIndex],
            'display_name': '',
            'voicemail_type': 'China Mobile',
            'voicemail_uri': '',
            'voice_file_size': '0',
            'voice_duration': duration,
            'voice_status': '',
            'origin_type': '',
            'create_time': timestamp + ''
        };
        console.info(TAG + 'testInsertVoiceMail' + 'logMessage Insert voicemail uri = ' + CONSTANTS.uri.VOICEMAIL_URI);
        DAHelper.insert(
            CONSTANTS.uri.VOICEMAIL_URI,
            insertValues,
        ).then(data => {
            console.info(TAG + 'testInsertVoiceMail' + 'logMessage Insert voicemail result success! data = ' + data);
        }).catch(error => {
            console.info(TAG + 'testInsertVoiceMail' + 'logMessage insert error:' + error);
        });
    },
    testGetDefaultSimSlot() {
        console.info(TAG + 'testGetDefaultSimSlot' + 'logMessage testGetDefaultSimSlot start');
        sim.getDefaultVoiceSlotId().then(data => {
            console.info(TAG + 'testGetDefaultSimSlot' + 'logMessage getDefaultVoiceSlotId :' + data);
        }).catch(err => {
            console.info(TAG + 'testGetDefaultSimSlot' + 'logMessage getDefaultVoiceSlotId error:' + err);
        });
    }
}
