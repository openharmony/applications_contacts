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
import NotificationManager from '@ohos.notificationManager';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { HiLog, sharedPreferencesUtils, StringUtil } from '../../../../../../common';
import { ContactsGlobalThisHelper } from 'common/src/main/ets/util/ContactsGlobalThisHelper';
import { image } from '@kit.ImageKit';
import { BusinessError, osAccount } from '@kit.BasicServicesKit';

const TAG = 'MissedCallNotifier';
const BUNDLE_NAME: string = 'com.ohos.contacts';
const ABILITY_NAME: string = 'com.ohos.contacts.MainAbility';
const GROUP_NAME: string = 'MissedCall'
const CANCEL_BLOCKED_ID: number = 0;
const KEY_MISSED_BADGE_NUM = 'missed_badge_number'
const MISSED_CALL_NOTIFY_DATA = 'missedCallNotifyData';
const actionBtnMaps: Record<string, Resource> =
  {
    'notification.event.dialBack': $r('app.string.dial_back'),
    'notification.event.message': $r('app.string.message'),
  };

export class MissedCallNotifyData {
  public id?: number;
  public displayName?: string;
  public readonly phoneNumber?: string;
  public count?: number;
  public createTime?: number;
  public ringDuration?: number;
  public numberLocation?: string;
  public isRemoveBlocked?: boolean;
  public hw_custom_appname?: string;
  public extra_show_assistant_action = true;

  constructor(id?: number, displayName?: string, phoneNumber?: string, count?: number, createTime?: number,
    ringDuration?: number, numberLocation?: string, isRemoveBlocked?: boolean, hw_custom_appname?: string) {
    this.id = id;
    this.displayName = displayName;
    this.phoneNumber = phoneNumber;
    this.count = count;
    this.createTime = createTime;
    this.ringDuration = ringDuration;
    this.numberLocation = numberLocation;
    this.isRemoveBlocked = isRemoveBlocked;
    this.hw_custom_appname = hw_custom_appname;
  }
}

export class MissedCallNotifier {
  private label?: string;
  private labelHarassment?: string;
  private context?: Context;
  private static sInstance: MissedCallNotifier | undefined = undefined;
  public missedBadgeNumber: number = -1;
  private UnReadMissedCallData?: MissedCallNotifyData;
  private CONTENT_URI: string = 'datashare:///com.ohos.calllogability';
  private CALL_LOG_URI: string = 'datashare:///com.ohos.calllogability/calls/calllog';

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
      let res = $r('app.string.missed_call');
      this.label = this.getContext()?.resourceManager.getStringSync(res.id);
    }
    if (!this.labelHarassment) {
      let res = $r('app.string.commotion_intercept');
      this.labelHarassment = this.getContext()?.resourceManager.getStringSync(res.id);
    }
    sharedPreferencesUtils.init(this.getContext());
  }

  /**
   * update blocked call notifications
   */
  public async updateBlockedCallNotifications() {
    let imageResource: image.ImageSource | null = null;
    let imagePixelMap: image.PixelMap | null = null;
    try {
      HiLog.i(TAG, `updateBlockedCallNotifications`)
      let interceptionCallsCount: number =
        await sharedPreferencesUtils.getFromPreferences('interceptionCallsCount', 1) as number;
      let newInterceptionCallsCount: number =
        await sharedPreferencesUtils.getFromPreferences('newInterceptionCallsCount', 1) as number;
      let strTitle: string = this.getContext()?.resourceManager
        .getPluralStringValueSync($r('app.plural.interceptionNotifyTitle'), newInterceptionCallsCount);
      let strText: string = this.getContext()?.resourceManager
        .getPluralStringValueSync($r('app.plural.interceptionNotificationText'), interceptionCallsCount);

      // 将资源图片转化为PixelMap对象
      let imageArray = await this.getContext()?.resourceManager
        .getMediaContent($r('app.media.ic_harassment_interception_notification'));
      imageResource = image.createImageSource(imageArray.buffer);
      imagePixelMap = await imageResource.createPixelMap({
        desiredSize: {
          height: 150,
          width: 150
        }
      });

      const notificationRequest: NotificationManager.NotificationRequest = {
        content: {
          notificationContentType: NotificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: strTitle,
            text: strText
          },
        },
        id: CANCEL_BLOCKED_ID,
        label: this.label,
        notificationSlotType: NotificationManager.SlotType.SOCIAL_COMMUNICATION,
        smallIcon: imagePixelMap
      }
      if (!notificationRequest.deliveryTime || notificationRequest.deliveryTime <= 0) {
        notificationRequest.deliveryTime = new Date().getTime();
      }
      let data: Record<string, object | string> = {};
      data.action = 'notification.event.click';
      data.pageFlag = 'harassment_filter'
      let wantAgentObj = await wantAgent.getWantAgent({
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
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.ONE_TIME_FLAG]
      });
      notificationRequest.wantAgent = wantAgentObj;
      // 设置 removalWantAgent ，拦截来电通知消失时，会发送removal的通知（即contact.event.CANCEL_MISSED）
      let missedCallData: MissedCallNotifyData = new MissedCallNotifyData();
      missedCallData.isRemoveBlocked = true;
      notificationRequest.removalWantAgent =
        await this.createWantAgentForCommonEvent(missedCallData, 'notification.event.cancel') || undefined
      NotificationManager.publish(notificationRequest).then(() => {
        HiLog.i(TAG, '===>publish promise success req.id: ' + notificationRequest.id +
          ' ,req.time: ' + notificationRequest.deliveryTime);
      }).catch((err: Error) => {
        HiLog.e(TAG, '===>publish promise failed because ' + err?.message + ', stack: ' + err?.stack);
      });
      HiLog.i(TAG, 'sendBlockedNotification end');
    } catch (err) {
      HiLog.e(TAG, 'sendBlockedNotification err: ' + err?.message + ', stack: ' + err?.stack);
    } finally {
      [imageResource, imagePixelMap].forEach(resource => {
        resource?.release().catch((error: BusinessError) => {
          HiLog.e(TAG, ' release resource error: ' + error?.message);
        });
      });
    }
  }

  /**
   * update Missed Call Notification
   *
   * @param missedData missedCallData - missed call data for notification
   */
  public async updateMissedCallNotifications(missedData: Map<string, MissedCallNotifyData>) {
    let notifyData = await this.getMissedCallNotifyDatas();
    HiLog.w(TAG, `updateMissedCallNotifications notifyData:${notifyData.length} missedData: ${missedData.size}`)
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
              HiLog.w(TAG, `updateMissedCallNotifications notify.count:${notify.count} missed.count: ${missed.count}`)
              notify.count += missed.count ? missed.count : 0;
            }
            this.sendNotification(notify);
          }
        }
        badgeNumber += notify.count ? notify.count : 0;
      }
    }
    for (let notify of Array.from(missedData.values())) {
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
  public async cancelAllNotification() {
    HiLog.w(TAG, 'cancelNotification, cancel all');
    await this.setMissedBadgeNumber(0);
    this.getMissedCallNotifyDatas().then((results: MissedCallNotifyData[]) => {
      HiLog.w(TAG, 'cancelNotification, getMissedCallNotifyDatas success.');
      results.forEach((result) => {
        NotificationManager.cancel(result.id, this.label).catch((error: Error) => {
          HiLog.e(TAG, `cancelNotificationById, id: ${result.id}, err ${error?.message}, stack: ${error?.stack}`);
        });
      })
    })
  }

  public cancelInterceptionNotification() {
    HiLog.w(TAG, 'cancelInterceptionNotification')
    NotificationManager.cancel(CANCEL_BLOCKED_ID, this.label).catch((error: Error) => {
      HiLog.e(TAG, `cancelInterceptionNotificationById,err ${error?.message}, stack: ${error?.stack}`)
    });
  }

  /**
   * get Missed Call BadgeNumber
   */
  public async getMissedBadgeNumber() {
    if (this.missedBadgeNumber == -1) {
      this.missedBadgeNumber = (await sharedPreferencesUtils.getFromPreferences(KEY_MISSED_BADGE_NUM, -1)) as number;
    }
    return this.missedBadgeNumber;
  }

  /**
   * cancel Missed Call Notification By NotificationId
   *
   * @param id Notification Id
   */
  public async cancelNotificationById(id: number, count: number) {
    HiLog.w(TAG, 'cancelNotificationById:' + id)
    NotificationManager.cancel(id, this.label).catch((error: Error) => {
      HiLog.e(TAG, `cancelNotificationById,err ${error?.message}, stack: ${error?.stack}`)
    });
    let badgeNumber = await this.getMissedBadgeNumber();
    badgeNumber -= count;
    if (badgeNumber >= 0) {
      this.setMissedBadgeNumber(badgeNumber);
    }
  }

  constructor() {
  }

  private getContext(): Context {
    if (this.context && this.context != undefined) {
      return this.context;
    }
    return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
  }

  async getMissedCallNotifyDatas() {
    try {
      HiLog.w(TAG, `getMissedCallNotifyDatas in`);
      let result: MissedCallNotifyData[] = [];
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      const localId: number = await accountManager.getOsAccountLocalId();
      const notifications: NotificationManager.NotificationRequest[] =
        await NotificationManager.getActiveNotifications();
      for (let notify of notifications) {
        if (notify.groupName?.startsWith(GROUP_NAME) && notify.extraInfo) {
          HiLog.w(TAG, `current userId: ${localId}`);
          result.push(notify.extraInfo as MissedCallNotifyData);
        }
      }
      HiLog.w(TAG, `getMissedCallNotifyDatas result: ${result.length}`);
      return result;
    } catch (err) {
      HiLog.e(TAG, `getMissedCallNotifyDatas err: ${err?.message}, stack: ${err?.stack}`);
      return [];
    }
  }

  /**
   * 发通知
   * @param missedCallData
   */
  async sendNotification(missedCallData: MissedCallNotifyData) {
    let imageResource: image.ImageSource | null = null;
    let imagePixelMap: image.PixelMap | null = null;
    try {
      const id = missedCallData.id;
      const displayName = missedCallData.displayName as string;
      const count = missedCallData.count as number;
      const createTime = missedCallData.createTime as number;
      const ringDuration = missedCallData.ringDuration;
      missedCallData.hw_custom_appname = this.getContext()?.resourceManager.getStringSync($r('app.string.dialer'));

      let location: string = '';
      // If displayName is equal to phoneNumber, no contact is set for the current number.
      // Display number location for unknown calls.
      if (missedCallData.displayName === missedCallData.phoneNumber) {
        // Location - Carrier
        let addressInfo = missedCallData.numberLocation;
        if (addressInfo && !StringUtil.isEmpty(addressInfo)) {
          // Only required location.
          addressInfo = addressInfo.split(' ')[0]
          location = addressInfo + ' ';
        }
      }
      let strText = location +
      this.getContext()?.resourceManager.getPluralStringValueSync($r('app.plural.contacts_ring_times'),
        ringDuration as number);

      // 将资源图片转化为PixelMap对象
      let imageArray = await this.getContext()?.resourceManager.getMediaContent($r('app.media.ic_missed_notification'));
      imageResource = image.createImageSource(imageArray.buffer);
      imagePixelMap = await imageResource.createPixelMap({
        desiredSize: {
          height: 150,
          width: 150
        }
      });

      const notificationRequest: NotificationManager.NotificationRequest = {
        content: {
          notificationContentType: NotificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: count > 1 ? `${displayName} (${count})` : displayName,
            text: strText,
            additionalText: missedCallData.phoneNumber
          },
        },
        id: id,
        label: this.label,
        groupName: GROUP_NAME + displayName,
        notificationSlotType: NotificationManager.SlotType.SERVICE_INFORMATION,
        deliveryTime: createTime * 1000,
        extraInfo: missedCallData,
        smallIcon: imagePixelMap
      }
      await this.publishNotification(notificationRequest, missedCallData);
    } catch (err) {
      HiLog.e(TAG, `sendNotification err: ${err?.message}, stack: ${err?.stack}`);
    } finally {
      [imageResource, imagePixelMap].forEach(resource => {
        resource?.release().catch((error: BusinessError) => {
          HiLog.e(TAG, ' release resource error: ' + error?.message);
        });
      });
    }
  }

  private async publishNotification(notificationRequest: NotificationManager.NotificationRequest,
    missedCallData: MissedCallNotifyData) {
    if (!notificationRequest.deliveryTime || notificationRequest.deliveryTime <= 0) {
      notificationRequest.deliveryTime = new Date().getTime();
    }

    // 创建主 wantAgent
    let wantAgentObj: WantAgent | null = null;
    wantAgentObj = await this.getWantAgent(missedCallData, 'notification.event.click')
    if (wantAgentObj) {
      notificationRequest.wantAgent = wantAgentObj
    }
    // 创建 actionButtons 的 wantAgent
    notificationRequest.actionButtons = [];
    HiLog.i(TAG, `publishNotification: creating actionButtons, count: ${Object.keys(actionBtnMaps).length}`);
    for (const key of Object.keys(actionBtnMaps)) {
      const wantAgent = await this.getWantAgent(missedCallData, key);
      if (!wantAgent) {
        continue; // 跳过无效的按钮
      }
      const title = this.getContext()?.resourceManager.getStringSync(actionBtnMaps[key].id);
      notificationRequest.actionButtons.push({
        title: title,
        wantAgent: wantAgent
      });
    }
    HiLog.i(TAG, `publishNotification: actionButtons created, count: ${notificationRequest.actionButtons.length}`);

    // 设置 removalWantAgent 信息，未接来电通知消失时，会发送赋值给次removal的通知（即contact.event.CANCEL_MISSED）
    notificationRequest.removalWantAgent =
      await this.createWantAgentForCommonEvent(missedCallData, 'notification.event.cancel') || undefined

    NotificationManager.publish(notificationRequest).then(() => {
      HiLog.i(TAG, '===>publish promise success req.id : ' + notificationRequest.id +
        '  req.time: ' + notificationRequest.deliveryTime);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, '===>publish promise failed because ' + err?.message + ', stack: ' + err?.stack);
    });
    HiLog.i(TAG, 'publishNotification end')
  }

  async interceptNotificationGuidance(slotId: number) {
    let imageResource: image.ImageSource | null = null;
    let imagePixelMap: image.PixelMap | null = null;
    try {
      let titleStr = this.getContext()?.resourceManager.getStringSync($r('app.string.setting_harassment_blocking'));
      let textStr =
        this.getContext()?.resourceManager.getStringSync($r('app.string.adjusting_harassment_interception_settings'));

      // 将资源图片转化为PixelMap对象   call_harassment_filter
      let imageArray = await this.getContext()?.resourceManager.getMediaContent($r('app.media.call_harassment_filter'));
      imageResource = image.createImageSource(imageArray.buffer);
      imagePixelMap = await imageResource.createPixelMap({
        desiredSize: {
          height: 150,
          width: 150
        }
      });

      const notificationRequest: NotificationManager.NotificationRequest = {
        content: {
          notificationContentType: NotificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: titleStr,
            text: textStr,
          },
        },
        label: this.labelHarassment,
        notificationSlotType: NotificationManager.SlotType.SOCIAL_COMMUNICATION,
        smallIcon: imagePixelMap
      }

      let data: Record<string, string | number> = {
        'action': 'notification.event.click',
        'abilityName': 'CallSettingsAbility',
        'slotId': slotId
      }

      let removeData: Record<string, string | number> = {
        'action': 'notification.event.cancel',
        'abilityName': 'CallSettingsAbility',
        'slotId': slotId
      }
      data.pageFlag = 'harassment_filter'

      notificationRequest.wantAgent = await wantAgent.getWantAgent({
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
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.ONE_TIME_FLAG]
      });

      notificationRequest.removalWantAgent = await wantAgent.getWantAgent({
        wants: [{ parameters: removeData }],
        actionType: wantAgent.OperationType.SEND_COMMON_EVENT,
        requestCode: 0
      })

      HiLog.w(TAG, 'add notificationRequest Finished');
      // 发送通知
      NotificationManager.publish(notificationRequest).then(() => {
        HiLog.w(TAG, '===>publish promise Harassment interception success req.id : ' + notificationRequest.id +
          '  req.time: ' + notificationRequest.deliveryTime);
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, '===>publish promise Harassment interception failed because ' + err?.message +
          ', stack: ' + err?.stack);
      });
    } finally {
      // 释放资源
      [imageResource, imagePixelMap].forEach(resource => {
        resource?.release().catch((error: BusinessError) => {
          HiLog.e(TAG, ' release resource error: ' + error?.message);
        });
      });
    }
  }

  async setMissedBadgeNumber(newBadgeNum: number) {
    HiLog.w(TAG, 'setMissedBadgeNumber :' + newBadgeNum);
    this.missedBadgeNumber = newBadgeNum;
    try {
      await NotificationManager.setBadgeNumber(newBadgeNum);
    } catch (e) {
      HiLog.e(TAG, `setMissedBadgeNumber: error, ${e?.code} ${e?.message}`);
    }
    sharedPreferencesUtils.saveToPreferences(KEY_MISSED_BADGE_NUM, newBadgeNum);
  }

  /**
   * create wantAgent for common event
   *
   * @param mAction
   * @return return the created WantAgent object.
   */
  async createWantAgentForCommonEvent(missedCallData: MissedCallNotifyData,
    action?: string): Promise<WantAgent | null> {
    try {
      HiLog.i(TAG, `createWantAgentForCommonEvent start, action: ${action}, missedCallData.id: ${missedCallData?.id}`);

      const wantAgentObj = await wantAgent.getWantAgent({
        wants: [{
          bundleName: BUNDLE_NAME,
          abilityName: ABILITY_NAME,
          action: 'contact.event.CANCEL_MISSED',
          parameters: {
            action: action === undefined ? '' : action,
            missedCallData: missedCallData
          },
        }],
        actionType: wantAgent.OperationType.SEND_COMMON_EVENT,
        requestCode: 0
      });

      HiLog.i(TAG, `createWantAgentForCommonEvent: success, action: ${action}`);
      return wantAgentObj;
    } catch (err) {
      HiLog.e(TAG,
        `createWantAgentForCommonEvent error, action: ${action}, err: ${err?.message}, stack: ${err?.stack}`);
      return null
    }
  }

  async getWantAgent(missedCallData: MissedCallNotifyData, action: string): Promise<WantAgent | null> {
    try {
      HiLog.i(TAG, `getWantAgent start, action: ${action}, missedCallData.id: ${missedCallData?.id}`);

      let data: Record<string, object | string> = {};
      data.action = action;
      data.missedCallData = missedCallData;

      if (action == 'notification.event.dialBack') {
        return await this.createWantAgentForCommonEvent(missedCallData, action);
      } else if (action == 'notification.event.click') {
        data.pageFlag = 'page_flag_dialer';
      } else if (action == 'notification.event.message') {
        HiLog.w(TAG, 'getWantAgent: processing message action');
      }

      const wantAgentObj = await wantAgent.getWantAgent({
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
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.ONE_TIME_FLAG]
      });
      HiLog.i(TAG, `getWantAgent: success for action: ${action}`);
      return wantAgentObj;
    } catch (err) {
      HiLog.e(TAG, `getWantAgent error for action: ${action}, err: ${err?.message}, stack: ${err?.stack}`);
      return null
    }
  }
}