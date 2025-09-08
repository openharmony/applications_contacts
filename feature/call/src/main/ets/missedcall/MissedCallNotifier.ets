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
import NotificationManager from '@ohos.notificationManager'
import WantAgent from '@ohos.app.ability.wantAgent';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import Notification from '@ohos.notification'
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
const TAG = 'MissedCallNotifier';

const BUNDLE_NAME: string = 'com.ohos.contacts';
const ABILITY_NAME: string = 'com.ohos.contacts.MainAbility';
const GROUP_NAME: string = 'MissedCall'
const KEY_MISSED_BADGE_NUM = 'missed_badge_number'
const KEY_ID = 'unread_call_notification_id'
const KEY_DISPLAY_NAME = 'unread_call_notification_displayName'
const KEY_COUNT = 'unread_call_notification_count'
const KEY_CREATE_TIME = 'unread_call_notification_create_time'
const KEY_RING_DURATION = 'unread_call_notification_ring_duration'
const actionBtnMaps: Record<string, Resource> =
  {
    'notification.event.dialBack': $r('app.string.dial_back'),
    'notification.event.message': $r('app.string.message'),
  };

export class MissedCallNotifyData {
  id?: number;
  displayName?: string;
  readonly phoneNumber: string = '';
  count?: number;
  createTime?: number;
  ringDuration?: number;

  constructor(id: number, displayName: string, phoneNumber: string, count: number, createTime: number, ringDuration: number) {
    this.id = id;
    this.displayName = displayName;
    this.phoneNumber = phoneNumber;
    this.count = count;
    this.createTime = createTime;
    this.ringDuration = ringDuration;
  }
}

export class MissedCallNotifier {
  private label?: string;
  private context?: Context;
  private static sInstance: MissedCallNotifier | undefined = undefined;
  private missedBadgeNumber: number = -1;
  private UnReadMissedCallData?: MissedCallNotifyData;

  /**

   getInstance for MissedCallNotifier
   */
  public static getInstance() {
    if (!MissedCallNotifier.sInstance || MissedCallNotifier.sInstance == undefined) {
      MissedCallNotifier.sInstance = new MissedCallNotifier();
    }
    return MissedCallNotifier.sInstance;
  }
  /**

   init
   @param ctx context needed init
   */
  public init(ctx: Context) {
    this.context = ctx;
    if (!this.label) {
      this.label = this.getContext()?.resourceManager.getStringSync($r('app.string.missed_call'));
    }
    sharedPreferencesUtils.init(this.getContext());
  }

  /**
   * update Missed Call Notification
   *
   * @param missedData missedCallData - missed call data for notification
   */
  public async updateMissedCallNotifications(missedData: Map<string, MissedCallNotifyData>) {
    let notifyData = await this.getMissedCallNotifyDatas();
    HiLog.i(TAG, `updateMissedCallNotifications notifyData:${notifyData.length} missedData: ${missedData.size}`)
    let badgeNumber: number = 0;
    if (notifyData.length > 0) {
      for (let notify of notifyData) {
        let key: string | undefined = notify.displayName;
        if (key !== undefined && missedData.has(key)) {
          let missed = missedData.get(key)
          missedData.delete(key)
          if (missed !== undefined && missed.id != notify.id) {
            notify.createTime = missed.createTime;
            notify.ringDuration = missed.ringDuration;
            if (notify.count) {
              notify.count += missed.count ? missed.count : 0;
            }
            this.sendNotification(notify);
          }
        }
        badgeNumber += notify.count ? notify.count : 0;
      }
    }
    for (let notify of missedData.values()) {
      await this.sendNotification(notify);
      badgeNumber += notify.count ? notify.count : 0;
    }
    if (badgeNumber > 0) {
      this.setMissedBadgeNumber(badgeNumber);
    }
  }

  /**
   * cancel Missed Call Notification
   */
  public cancelAllNotification() {
    HiLog.i(TAG, 'cancelNotification,cancel all')
    this.setMissedBadgeNumber(0);
    NotificationManager.cancelGroup(GROUP_NAME).catch((error: Error) => {
      HiLog.e(TAG, `cancelNotification,err ${JSON.stringify(error)}}`)
  });
}
/**

 get Missed Call BadgeNumber
 */
public async getMissedBadgeNumber() {
  if (this.missedBadgeNumber == -1) {
    this.missedBadgeNumber = await sharedPreferencesUtils.getFromPreferences(KEY_MISSED_BADGE_NUM, -1) as number;
  }
  return this.missedBadgeNumber;
}
/**

 cancel Missed Call Notification By NotificationId
 @param id Notification Id
 */
public async cancelNotificationById(id: number, count: number) {
    HiLog.i(TAG, 'cancelNotificationById:' + id)
    NotificationManager.cancel(id, this.label).catch((error: Error) => {
      HiLog.e(TAG, `cancelNotificationById,err ${JSON.stringify(error)}}`)
  });
  let badgeNumber = await this.getMissedBadgeNumber();
  badgeNumber -= count;
  if (badgeNumber >= 0) {
    this.setMissedBadgeNumber(badgeNumber);
  }
}
private constructor() {
}

private getContext(): Context {
  if (this.context && this.context != undefined) {
    return this.context;
  }
  return globalThis.context;
}

private async getMissedCallNotifyDatas() {
  HiLog.i(TAG, `getMissedCallNotifyDatas in`)
  let result: Array<MissedCallNotifyData> = [];
  const notifications: Array<NotificationManager.NotificationRequest> =
    await NotificationManager.getActiveNotifications()
  for (let notify of notifications) {
    if (notify.groupName == GROUP_NAME && notify.extraInfo) {
      result.push(notify.extraInfo as MissedCallNotifyData);
    }
  }
  HiLog.i(TAG, `getMissedCallNotifyDatas result: ${result.length}`)
  return result;
}

private async sendNotification(missedCallData: MissedCallNotifyData) {
  let id = missedCallData.id;
  const displayName = missedCallData.displayName;
  const count = missedCallData.count as number;
  const createTime = missedCallData.createTime;
  const ringDuration = missedCallData.ringDuration;
  sharedPreferencesUtils.saveToPreferences(KEY_ID, id);
  sharedPreferencesUtils.saveToPreferences(KEY_DISPLAY_NAME, displayName);
  sharedPreferencesUtils.saveToPreferences(KEY_COUNT, count);
  sharedPreferencesUtils.saveToPreferences(KEY_CREATE_TIME, createTime);
  sharedPreferencesUtils.saveToPreferences(KEY_RING_DURATION, ringDuration)
  HiLog.i(TAG, `sendNotification in id:${id}, count:${count}, createTime:${createTime}`)
  let str_text = this.getContext()?.resourceManager.getStringSync($r('app.string.contacts_ring_times')) +
    ringDuration + this.getContext()?.resourceManager.getStringSync($r('app.string.contacts_time_sec'));
    if (ringDuration === 0) {
      str_text = this.getContext()?.resourceManager.getStringSync(
r('app.string.missed_call'))
}
const notificationRequest: NotificationManager.NotificationRequest = {
content: {
contentType: Notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
normal: {
title: count > 1 ? `displayName({count})` : displayName as string,
text: str_text,
additionalText: missedCallData.phoneNumber
},
},
id: id,
label: this.label,
groupName: GROUP_NAME,
slotType: Notification.SlotType.SOCIAL_COMMUNICATION,
deliveryTime: new Date().getTime(),
extraInfo: missedCallData
}

let wantAgentObj = await this.getWantAgent(missedCallData, 'notification.event.click');
notificationRequest.wantAgent = wantAgentObj;
notificationRequest.actionButtons = [];
for (const key of Object.keys(actionBtnMaps)) {
  const wantAgent = await this.getWantAgent(missedCallData, key);
  const title = this.getContext()?.resourceManager.getStringSync(actionBtnMaps[key]);
  notificationRequest.actionButtons.push({
    title: title,
    wantAgent: wantAgent
  });
}
notificationRequest.removalWantAgent = await this.createWantAgentForCommonEvent(missedCallData, 'notification.event.cancel');
NotificationManager.publish(notificationRequest).then(() => {
  HiLog.i(TAG, '===>publish promise success req.id : ' + notificationRequest.id);
}).catch((err: Error) => {
  HiLog.e(TAG, '===>publish promise failed because ' + JSON.stringify(err));
});
HiLog.i(TAG, 'sendNotification end')
}

/**

send Unread Call Notification
*/
public async sendUnreadCallNotification(map: Map<string, string>) {
let id: number = await sharedPreferencesUtils.getFromPreferences(KEY_ID, -1) as number;
let displayName: string = await sharedPreferencesUtils.getFromPreferences(KEY_DISPLAY_NAME, '') as string;
let count: number = await sharedPreferencesUtils.getFromPreferences(KEY_COUNT, -1) as number;
let createTime: number = await sharedPreferencesUtils.getFromPreferences(KEY_CREATE_TIME, -1) as number;
let ringDuration: number = await sharedPreferencesUtils.getFromPreferences(KEY_RING_DURATION, -1) as number;
let missCallData = map.get('missedPhoneJson')
const parameters: LooseObject = JSON.parse(JSON.stringify(missCallData));
for (let i = 0; i < parameters.phoneNumberList.length; i++) {
const missedPhoneNumber = parameters.phoneNumberList[i] as string
if (i === (parameters.phoneNumberList.length - 1)) {
this.UnReadMissedCallData = new MissedCallNotifyData(i, missedPhoneNumber, missedPhoneNumber, count, createTime, ringDuration);
} else {
this.UnReadMissedCallData = new MissedCallNotifyData(i, missedPhoneNumber, missedPhoneNumber, count, createTime, 0);
}
this.sendNotification(this.UnReadMissedCallData);
}
}

private setMissedBadgeNumber(newBadgeNum: number) {
  HiLog.i(TAG, 'setMissedBadgeNumber :' + newBadgeNum);
  this.missedBadgeNumber = newBadgeNum;
  NotificationManager.setBadgeNumber(newBadgeNum);
  sharedPreferencesUtils.saveToPreferences(KEY_MISSED_BADGE_NUM, newBadgeNum);
}

/**
 * create wantAgent for common event
 *
 * @param mAction
 * @return return the created WantAgent object.
 */
private async createWantAgentForCommonEvent(missedCallData: MissedCallNotifyData, action?: string) {
  return await WantAgent.getWantAgent({
    wants: [{ action: 'contact.event.CANCEL_MISSED', parameters: {
      action: action,
      missedCallData: missedCallData
    }, }],
    actionType: WantAgent.OperationType.SEND_COMMON_EVENT,
    requestCode: 0
  })
}
private getWantAgent(missedCallData: MissedCallNotifyData, action: string): Object {
let data: Record<string, object | string> = {}
  data.action = action,
  data.missedCallData = missedCallData
  if (action == 'notification.event.dialBack') {
    HiLog.i(TAG, 'getWantAgent add page_flag_edit_before_calling')
    return this.createWantAgentForCommonEvent(missedCallData, action);
  }
  return WantAgent.getWantAgent({
    wants: [{
      deviceId: '',
      bundleName: BUNDLE_NAME,
      abilityName: ABILITY_NAME,
      uri: '',
      type: 'phone',
      parameters: data,
      entities: []
    }],
    requestCode: 0,
    actionType: WantAgent.OperationType.START_ABILITY,
    wantAgentFlags: [WantAgent.WantAgentFlags.ONE_TIME_FLAG]
  });
}
}