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
import Notification from "@ohos.notificationManager"
import WantAgent from '@ohos.app.ability.wantAgent';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
var notificationManager = globalThis.requireNapi("notificationManager");

const TAG = "MissedCallNotifier";

const BUNDLE_NAME: string = 'com.ohos.contacts';
const ABILITY_NAME: string = 'com.ohos.contacts.MainAbility';
const GROUP_NAME: string = "MissedCall"
const KEY_MISSED_BADGE_NUM = 'missed_badge_number'
const actionBtnMaps =
  {
    'notification.event.dialBack': $r('app.string.dial_back'),
    'notification.event.message': $r('app.string.message'),
  };

export class MissedCallNotifyData {
  id?: number;
  displayName?: string;
  readonly phoneNumber: string;
  count?: number;
  createTime?: number;
  ringDuration?: number;
}

export class MissedCallNotifier {
  private label: string;
  private context: Context;
  private static sInstance: MissedCallNotifier = undefined;
  private missedBadgeNumber: number = -1;

  /**
   * getInstance for MissedCallNotifier
   */
  public static getInstance() {
    if (!MissedCallNotifier.sInstance || MissedCallNotifier.sInstance == undefined) {
      MissedCallNotifier.sInstance = new MissedCallNotifier();
    }
    return MissedCallNotifier.sInstance;
  }

  /**
   * init
   *
   * @param ctx context needed init
   */
  public init(ctx: Context) {
    this.context = ctx;
    if (!this.label) {
      this.label = this.getContext()?.resourceManager.getStringSync($r("app.string.missed_call"));
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
        let key: string = notify.displayName;
        if (missedData.has(key)) {
          let missed = missedData.get(key)
          missedData.delete(key)
          if (missed.id != notify.id) {
            notify.createTime = missed.createTime;
            notify.ringDuration = missed.ringDuration;
            notify.count += missed.count;
            this.sendNotification(notify);
          }
        }
        badgeNumber += notify.count;
      }
    }
    for (let notify of missedData.values()) {
      await this.sendNotification(notify);
      badgeNumber += notify.count;
    }
    if (badgeNumber > 0) {
      this.setMissedBadgeNumber(badgeNumber);
    }
  }

  /**
   * cancel Missed Call Notification
   */
  public cancelAllNotification() {
    HiLog.i(TAG, "cancelNotification,cancel all")
    this.setMissedBadgeNumber(0);
    Notification.cancelGroup(GROUP_NAME).catch(error => {
      HiLog.e(TAG, `cancelNotification,err ${JSON.stringify(error)}}`)
    });
  }

  /**
   * get Missed Call BadgeNumber
   */
  public async getMissedBadgeNumber() {
    if (this.missedBadgeNumber == -1) {
      this.missedBadgeNumber = <number> await sharedPreferencesUtils.getFromPreferences(KEY_MISSED_BADGE_NUM, -1);
    }
    return this.missedBadgeNumber;
  }

  /**
   * cancel Missed Call Notification By NotificationId
   *
   * @param id Notification Id
   */
  public async cancelNotificationById(id: number, count: number) {
    HiLog.i(TAG, "cancelNotificationById:" + id)
    Notification.cancel(id, this.label).catch(error => {
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

  private getContext() {
    if (this.context && this.context != undefined) {
      return this.context;
    }
    return globalThis.context;
  }

  private async getMissedCallNotifyDatas() {
    HiLog.i(TAG, `getMissedCallNotifyDatas in`)
    let result: Array<MissedCallNotifyData> = [];
    const notifications: Array<Notification.NotificationRequest> =
      await Notification.getAllActiveNotifications()
    for (let notify of notifications) {
      if (notify.groupName == GROUP_NAME && notify.extraInfo) {
        result.push(<MissedCallNotifyData> notify.extraInfo);
      }
    }
    HiLog.i(TAG, `getMissedCallNotifyDatas result: ${result.length}`)
    return result;
  }

  private async sendNotification(missedCallData: MissedCallNotifyData) {
    const {id, displayName, count, createTime, ringDuration} = missedCallData;
    HiLog.i(TAG, `sendNotification in id:${id}, count:${count}, createTime:${createTime}`)
    let str_text = this.getContext()?.resourceManager.getStringSync($r("app.string.contacts_ring_times")) +
    ringDuration + this.getContext()?.resourceManager.getStringSync($r("app.string.contacts_time_sec"));
    const notificationRequest: Notification.NotificationRequest = {
      content: {
        contentType: Notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: count > 1 ? `${displayName} (${count})` : displayName,
          text: str_text,
          additionalText: ""
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
    notificationRequest.removalWantAgent = await this.createWantAgentForCommonEvent(missedCallData, "contact.event.CANCEL_MISSED");
    Notification.publish(notificationRequest).then(() => {
      HiLog.i(TAG, '===>publish promise success req.id : ' + notificationRequest.id);
    }).catch((err) => {
      HiLog.e(TAG, '===>publish promise failed because ' + JSON.stringify(err));
    });
    HiLog.i(TAG, 'sendNotification end')
  }

  private setMissedBadgeNumber(newBadgeNum: number) {
    HiLog.i(TAG, 'setMissedBadgeNumber :' + newBadgeNum);
    this.missedBadgeNumber = newBadgeNum;
    notificationManager.setBadgeNumber(newBadgeNum);
    sharedPreferencesUtils.saveToPreferences(KEY_MISSED_BADGE_NUM, newBadgeNum);
  }

  /**
   * create wantAgent for common event
   *
   * @param mAction
   * @return return the created WantAgent object.
   */
  private async createWantAgentForCommonEvent(missedCallData, action: string) {
    return await WantAgent.getWantAgent({
      wants: [{ action: action, parameters: {
        missedCallData: missedCallData
      }, }],
      operationType: WantAgent.OperationType.SEND_COMMON_EVENT,
      requestCode: 0 // requestCode是WantAgentInfo的请求码，是使用者定义的一个私有值
    })
  }

  private getWantAgent(missedCallData: MissedCallNotifyData, action: string) {
    let data: any = {}
    data.action = action,
    data.missedCallData = missedCallData
    if (action == "notification.event.dialBack") {
      HiLog.i(TAG, 'getWantAgent add page_flag_edit_before_calling')
      data.pageFlag = 'page_flag_edit_before_calling'
      data.phoneNumber = missedCallData.phoneNumber;
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
      operationType: WantAgent.OperationType.START_ABILITY,
      wantAgentFlags: [WantAgent.WantAgentFlags.ONE_TIME_FLAG]
    });
  }
}