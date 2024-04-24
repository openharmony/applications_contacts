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

import { HiLog, sharedPreferencesUtils } from 'common';
import { MissedCallNotifier, MissedCallNotifyData } from './MissedCallNotifier'
import { CallLogRepository } from '../repo/CallLogRepository';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { CallLog } from '../entity/CallLog'

const TAG = 'MissedCallService';
const LAST_MISSED_ID: string = 'Last_Missed_id'
const PREFERENCE_NAME: string = 'CONTACT_PREFERENCE';

export class MissedCallService {
  private static sInstance: MissedCallService = undefined;
  private context: Context = undefined;
  private lastMissedId = -1;
  private onCallLogChanged = () => {
    if (this.lastMissedId != -1) {
      HiLog.i(TAG, 'onCallLogChanged lastMissedId:' + this.lastMissedId);
      this.sendMissedCallNotify(this.lastMissedId);
    }
    this.unRegisterDataChangeObserver();
  }

  /**
   * getInstance for MissedCallService
   */
  public static getInstance() {
    if (!MissedCallService.sInstance || MissedCallService.sInstance == undefined) {
      MissedCallService.sInstance = new MissedCallService();
    }
    return MissedCallService.sInstance;
  }

  /**
   * init
   *
   * @param ctx context needed init
   */
  public init(ctx: Context) {
    this.context = ctx;
    sharedPreferencesUtils.init(ctx);
    MissedCallNotifier.getInstance().init(ctx);
    CallLogRepository.getInstance().init(ctx);
    ContactRepository.getInstance().init(ctx);
  }

  /**
   * updateAllMissedCallNotifications
   */
  public async updateAllMissedCallNotifications() {
    HiLog.i(TAG, 'updateMissedCallNotifications');
    MissedCallNotifier.getInstance().cancelAllNotification();
    this.sendMissedCallNotify();
  }

  /**
   * updateMissedCallNotifications
   */
  public async updateMissedCallNotifications() {
    if (this.lastMissedId == -1) {
      this.lastMissedId = await this.getLastNotificationId();
    }
    this.registerDataChangeObserver();
    HiLog.i(TAG, 'updateMissedCallNotifications, lastMissedId:' + this.lastMissedId);
    this.sendMissedCallNotify(this.lastMissedId);
  }

  /**
   *
   * Unread missed call notification
   */
  public async unreadCallNotification(map:Map<string,string>) {
    MissedCallNotifier.getInstance().sendUnreadCallNotification(map);
  }

  /**
   * cancelMissedNotificationAction
   *
   * @param data MissedCallNotifyData need cancel notify
   */
  public async cancelMissedNotificationAction(data: MissedCallNotifyData) {
    HiLog.i(TAG, `cancelMissedNotificationAction, ${JSON.stringify(data)}`);
    MissedCallNotifier.getInstance().cancelNotificationById(data.id, data.count);
    CallLogRepository.getInstance().markMissedCallLogAsRead(data.phoneNumber);
  }

  /**
   * cancelAllMissedNotificationAction
   */
  public async cancelAllMissedNotificationAction() {
    let unreadMissed = await MissedCallNotifier.getInstance().getMissedBadgeNumber()
    if (unreadMissed > 0) {
      HiLog.i(TAG, `cancelAllMissedNotificationAction cancel all`);
      MissedCallNotifier.getInstance().cancelAllNotification();
      CallLogRepository.getInstance().markMissedCallLogAsRead();
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

  private registerDataChangeObserver() {
    HiLog.i(TAG, 'registerDataChangeObserver');
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallLogChanged);
  }

  private unRegisterDataChangeObserver() {
    HiLog.i(TAG, 'unRegisterDataChangeObserver');
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallLogChanged);
  }

  private async getLastNotificationId() {
    return <number> await sharedPreferencesUtils.getFromPreferences(LAST_MISSED_ID, -1)
  }

  private setLastNotificationId(id: number, lastId?: number): boolean {
    if (!lastId || this.lastMissedId < id) {
      HiLog.i(TAG, `setLastNotificationId: ${id}`);
      this.lastMissedId = id;
      this.unRegisterDataChangeObserver();
      sharedPreferencesUtils.saveToPreferences(LAST_MISSED_ID, id)
      return true;
    }
    return false;
  }

  private sendMissedCallNotify(lastId?: number) {
    CallLogRepository.getInstance().findMissedCallLogUnread((data: CallLog[]) => {
      HiLog.i(TAG, 'sendMissedCallNotify, callLog unread count:' + data.length);
      if (data.length <= 0 || !this.setLastNotificationId(data[0].id, lastId)) {
        HiLog.i(TAG, 'sendMissedCallNotify, No new CallLog.');
        return;
      }
      let phoneNums = new Set();
      for (let callLog of data) {
        phoneNums.add(callLog.phoneNumber);
      }
      this.queryContactsName(Array.from(phoneNums), (numberMap) => {
        let missedData: Map<string, MissedCallNotifyData> = new Map();
        for (let callLog of data) {
          let displayName = callLog.phoneNumber;
          if (numberMap.has(callLog.phoneNumber)) {
            displayName = numberMap.get(callLog.phoneNumber);
          }
          if (!missedData.has(displayName)) {
            missedData.set(displayName, {
              phoneNumber: callLog.phoneNumber,
              displayName: displayName,
              id: callLog.id,
              createTime: callLog.createTime,
              count: 1,
              ringDuration: callLog.ringDuration
            });
          } else {
            missedData.get(displayName).count++;
          }
        }
        MissedCallNotifier.getInstance().updateMissedCallNotifications(missedData);
      })
    }, lastId);
  }

  private queryContactsName(numberList, callback) {
    if (numberList.length == 0) {
      HiLog.w(TAG, 'queryContactsName, has no number');
      callback(new Map());
      return;
    }
    ContactRepository.getInstance().queryContactDataByNumber(numberList, contacts => {
      // Convert the result to Map, key: mobile number, value: name
      let numberMap = this.getNumberMap(contacts);
      callback(numberMap);
    });
  }

  private getNumberMap(contacts) {
    let numberMap = new Map();
    for (let item of contacts) {
      if (!StringUtil.isEmpty(item.displayName)) {
        numberMap.set(item.detailInfo, item.displayName);
      }
    }
    return numberMap;
  }
}