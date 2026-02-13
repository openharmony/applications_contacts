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

import { HiLog, sharedPreferencesUtils } from 'common';
import { MissedCallNotifier, MissedCallNotifyData } from './MissedCallNotifier';
import { CallLogRepository } from '../repo/CallLogRepository';
import {
  ContactRepository,
  queryContactNameByNumber
} from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { CallLog } from '../entity/CallLog';
import NumberMarkUtil from '../../../../../../entry/src/main/ets/util/NumberMarkUtil';
import taskpool from '@ohos.taskpool';
import ContactNameNumberInfo from '../../../../../contact/src/main/ets/entity/ContactNameNumberInfo';
import CallRecordPresenter from '../../../../../../entry/src/main/ets/presenter/dialer/callRecord/CallRecordPresenter';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import BlockListContact, {
  IsBlockContact
} from '../../../../../../feature/contact/src/main/ets/entity/BlockListContact';
import DotUtil from '../../../../../../entry/src/main/ets/util/DotUtil';
import dotCommon, { customParams } from '../../../../../../entry/src/main/ets/util/DotCommon';

const TAG = 'MissedCallService';
// 优先用时间
const LAST_MISSED_ID: string = 'Last_Missed_id'
// 最新的未接来电通知的时间
const LAST_INCOMING_CALL_NOTIFICATION_TIME: string = 'LAST_INCOMING_CALL_NOTIFICATION_TIME';

const PREFERENCE_NAME: string = 'CONTACT_PREFERENCE';

// sp中没有存未接来电最后的callid或者没有最新的创建时间 就为-1
const NO_MISSED_ID_OR_NO_CREATE_TIME = -1;

export class MissedCallService {
  private static sInstance: MissedCallService = new MissedCallService();
  private context?: Context;
  // 优先用时间比较，没时间用id比较
  public lastMissedId = -1;
  // lastMissedId 不要再用了，哟ing这个
  public lastIncomingCallNotificationTime = -1;

  public onCallLogChanged = () => {
    if (this.lastIncomingCallNotificationTime != -1 || this.lastMissedId != -1) {
      HiLog.i(TAG, 'onCallLogChanged lastInfo:' +
      this.lastMissedId + '--' + this.lastIncomingCallNotificationTime);
      if (this.context !== null) {
        this.sendMissedCallNotify(this.context);
      }
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

  public static getDTTestInstance(): MissedCallService {
    // 用于DT测试创建实例对象
    return new MissedCallService();
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
  public async updateAllMissedCallNotifications(context: Context) {
    HiLog.i(TAG, 'updateMissedCallNotifications');
    await MissedCallNotifier.getInstance().cancelAllNotification();
    this.sendMissedCallNotify(context);
  }

  /**
   * updateMissedCallNotifications，查询上次未接来电最新时间和id 设置到本地
   */
  public async updateMissedCallNotifications(context: Context) {
    if (this.lastMissedId == -1) {
      this.lastMissedId = await this.getLastNotificationId();
    }
    if (this.lastIncomingCallNotificationTime == -1) {
      this.lastIncomingCallNotificationTime = await this.getLastIncomingCallNotificationTime();
    }
    this.registerDataChangeObserver();
    HiLog.i(TAG, 'updateMissedCallNotifications, lastInfo:' + this.lastMissedId + '--' +
      this.lastIncomingCallNotificationTime);
    if (this.lastIncomingCallNotificationTime === NO_MISSED_ID_OR_NO_CREATE_TIME) {
      // 双升单场景如果createtime为-1,此时将lastmisseid也设置为-1，这样就去查询所有的未接来电
      this.lastMissedId = NO_MISSED_ID_OR_NO_CREATE_TIME;
      HiLog.w(TAG, 'findMissedCallLogUnread date is -1.');
    }
    this.sendMissedCallNotify(context);
  }

  /**
   * updateBlockedNotificationAction
   */
  public async updateBlockedNotificationAction(phoneNumber: string,
    context: StaticSubscriberExtensionContext, detectDetails?: string) {
    HiLog.i(TAG, 'updateBlockedNotificationAction');
    this.sendBlockedCallNotify(phoneNumber, context, detectDetails);
  }

  /**
   * cancelMissedNotificationAction
   *
   * @param data MissedCallNotifyData need cancel notify
   */
  public async cancelMissedNotificationAction(data: MissedCallNotifyData) {

    MissedCallNotifier.getInstance().cancelNotificationById(Number(data.id), Number(data.count));
    CallLogRepository.getInstance().markMissedCallLogAsRead(data.phoneNumber);
  }

  /**
   * cancelAllMissedNotificationAction
   */
  public async cancelAllMissedNotificationAction() {
    HiLog.i(TAG, `cancelAllMissedNotificationAction cancel all`);
    MissedCallNotifier.getInstance().cancelAllNotification();
    CallLogRepository.getInstance().markMissedCallLogAsRead();
  }

  public async cancelInterceptionNotificationAction() {
    HiLog.i(TAG, `cancelInterceptionNotificationAction`);
    MissedCallNotifier.getInstance().cancelInterceptionNotification();
  }

  private constructor() {
  }


  registerDataChangeObserver() {
    HiLog.i(TAG, 'registerDataChangeObserver');
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallLogChanged);
  }

  unRegisterDataChangeObserver() {
    HiLog.i(TAG, 'unRegisterDataChangeObserver');
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallLogChanged);
  }

  async getLastNotificationId() {
    return (await sharedPreferencesUtils.getFromPreferences(LAST_MISSED_ID, -1)) as number
  }

  /**
   * 获取最新未接来电提醒的时间
   * @returns
   */
  async getLastIncomingCallNotificationTime() {
    return (await sharedPreferencesUtils.getFromPreferences(LAST_INCOMING_CALL_NOTIFICATION_TIME, -1)) as number;
  }

  setLastNotificationId(id: number): boolean {
    if (this.lastMissedId == -1 || this.lastMissedId < id) {
      HiLog.i(TAG, `setLastNotificationId: ${id}`);
      this.lastMissedId = id;
      this.unRegisterDataChangeObserver();
      sharedPreferencesUtils.saveToPreferences(LAST_MISSED_ID, id)
      return true;
    }
    return false;
  }

  /**
   * 更新最新的未接来电通知时间
   * @param newestTime
   * @returns
   */
  setLastIdAndIncomingCallNotificationTime(id: number, newestTime: number): boolean {
    let res = false;
    HiLog.w(TAG, `setLastInfo: ${id}, ${newestTime}`);
    if (this.lastMissedId == -1 || this.lastMissedId < id) {
      HiLog.i(TAG, `setLastNotificationId: ${id}`);
      this.lastMissedId = id;
      sharedPreferencesUtils.saveToPreferences(LAST_MISSED_ID, id)
      res = true;
    }

    // 如果老的时间信息为-1，或老的时间信息小于当前时间信息
    if (this.lastIncomingCallNotificationTime == -1 || this.lastIncomingCallNotificationTime < newestTime) {
      HiLog.i(TAG, `setLastIncomingCallNotificationTime: ${newestTime}`);
      this.lastIncomingCallNotificationTime = newestTime;
      sharedPreferencesUtils.saveToPreferences(LAST_INCOMING_CALL_NOTIFICATION_TIME, newestTime);
      res = true;
    }

    if (res) {
      this.unRegisterDataChangeObserver();
    }
    return res;
  }

  /**
   * send blocked call notifications
   *
   * @param phoneNumber
   * @param context
   */
  public async sendBlockedCallNotify(phoneNumber: string,
    context: StaticSubscriberExtensionContext, detectDetails?: string) {
    HiLog.i(TAG, `sendBlockedCallNotify`);
    MissedCallNotifier.getInstance().updateBlockedCallNotifications();
    if (detectDetails) {
      // 查询此开头号码的拦截记录次数
      CallRecordPresenter.getInstance().getBlockedCallCountByDetectDetails(detectDetails as string,
        context, (blockListContact: BlockListContact | undefined) => {
          if (blockListContact != undefined) {
            HiLog.i(TAG, 'sendBlockedCallNotify getBlockedCallCountByDetectDetails: ' +
            blockListContact.interceptionCallCount);
            CallRecordPresenter.getInstance().
            updateBlockedCallCountByDetectDetails(context, blockListContact, true);
          }
        });
    } else {
      // 查询此号码是否在黑名单
      CallRecordPresenter.getInstance().isInBlockList(phoneNumber as string, (res: IsBlockContact)=> {
        HiLog.i(TAG, 'sendBlockedCallNotify isInBlockList: ' + res?.isInBlock);
        if (res?.isInBlock) {
          // 查询此号码的拦截记录次数
          CallRecordPresenter.getInstance().getBlockedCallCountByPhoneNumber(phoneNumber as string,
            context, (blockListContact: BlockListContact | undefined) => {
              if (blockListContact != undefined) {
                HiLog.i(TAG, 'sendBlockedCallNotify getBlockedCallCountByPhoneNumber: ' +
                blockListContact.interceptionCallCount);
                CallRecordPresenter.getInstance().
                updateBlockedCallCountByPhoneNumber(context, blockListContact, true);
              }
            });
        }
      }, false, context);
    }
  }

  /**
   * 发送未接来电通知
   */
  public async sendMissedCallNotify(context?: Context) {
    HiLog.w(TAG, `sendMissedCallNotify in lastIno: + ${this.lastMissedId} -- ${this.lastIncomingCallNotificationTime}`)
    // 查询未接来电
    CallLogRepository.getInstance().findMissedCallLogUnread((data: CallLog[]) => {
      HiLog.i(TAG, 'sendMissedCallNotify, callLog unread count:' + data.length);
      // 设置最新的时间信息和lastId信息
      if (data.length <= 0 || !this.setLastIdAndIncomingCallNotificationTime(data[0].id, data[0].createTime)) {
        HiLog.i(TAG, 'sendMissedCallNotify, No new CallLog.');
        return;
      }
      let phoneNums: Set<string> = new Set();
      data.forEach((callLog) => {
        phoneNums.add(callLog.phoneNumber);
      })
      // 根据电话号码查询联系人名称
      this.queryContactsName(Array.from(phoneNums), (numberMap?: Map<string, string>) => {
        // 未接来电通知map
        let missedData: Map<string, MissedCallNotifyData> = new Map();
        data.forEach((callLog) => {
          HiLog.i(TAG, `callLog infos, id: ${callLog.id} createTime: ${callLog.createTime}, ringDuration: ${
            callLog.ringDuration}, markType: ${callLog.markType}, markSource: ${callLog.markSource}`);
          let displayName = callLog.phoneNumber;
          let numberLocation = this.getMissedCallNumberMarkInfoOrNumberLocation(callLog, context);
          if (!StringUtil.isEmpty(callLog.displayName)) {
            displayName = callLog.displayName;
            HiLog.i(TAG, `callLog displayName`);
          } else if (!StringUtil.isEmpty(callLog.markType) && callLog.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC) {
            displayName = this.getMissedCallNumberMarkName(callLog, context).toString();
            HiLog.i(TAG, `getMissedCallNumberMarkName`);
          } else if (numberMap != undefined && numberMap.has(callLog.phoneNumber)) {
            displayName = numberMap.get(callLog.phoneNumber) as string;
            if (StringUtil.isEmpty(displayName)) {
              HiLog.e(TAG, `get empty notify displayName from db, phoneNumber length is ${callLog.phoneNumber?.length}`);
            }
          }
          if (!missedData.has(displayName)) {
            missedData.set(displayName, new MissedCallNotifyData(callLog.id, displayName, callLog.phoneNumber, 1,
              callLog.createTime, callLog.ringDuration, numberLocation));
          } else {
            let missedDataByName = missedData.get(displayName);
            if (missedDataByName !== undefined) {
              (missedDataByName.count as number)++;
            }
          }
        })
        MissedCallNotifier.getInstance().updateMissedCallNotifications(missedData);
      })
    }, this.lastMissedId != -1 ? this.lastMissedId : undefined,
      this.lastIncomingCallNotificationTime != -1 ? this.lastIncomingCallNotificationTime : undefined);
    // 联系人打点--未接来电通知
    DotUtil.getInstance()
      .contactDot(customParams, dotCommon.eventName.MISSED_CALL_EVENT);
  }

  public sendInterceptNotificationSlotId(slotId: number) {
    HiLog.w(TAG, 'this intercept notification slotId is: ' + slotId);
    MissedCallNotifier.getInstance().interceptNotificationGuidance(slotId);
  }

  queryContactsName(numberList: string[], callback: (Contact?: Map<string, string>) => void) {
    if (numberList.length == 0) {
      HiLog.w(TAG, 'queryContactsName, has no number');
      callback(new Map());
      return;
    }

    let task = new taskpool.Task(queryContactNameByNumber, this.context as Context, numberList);
    taskpool.execute(task).then((contactInfos: Object) => {
      let numberMap: Map<string, string> = new Map();
      (contactInfos as ContactNameNumberInfo[]).forEach(item => {
        if (!StringUtil.isEmpty(item.name)) {
          numberMap.set(item.phoneNumber, item.name);
        }
      })
      callback(numberMap);
    })
  }

  getMissedCallNumberMarkName(item: CallLog, context?: Context): string {
    HiLog.i(TAG, `getMissedCallNumberMarkName ` + item.markType);
    if (!context) {
      HiLog.e(TAG, `getMissedCallNumberMarkName context is undefined`);
      return item.phoneNumber;
    }
    // Cloud Mark Yellow page
    // Cloud Mark others
    // Cloud Mark enterprise
    if (item.isCloudMark === 1 && item.markType === NumberMarkUtil.PRE_FRAUD_PHONE_DESC &&
      item.markSource === NumberMarkUtil.ANTI_FRAUD_CENTER) {
      // 国家反诈中心
      return context?.resourceManager.getStringSync($r('app.string.suspected_fraud').id);
    } else if (item.isCloudMark === 1 && !StringUtil.isEmpty(item.markType) &&
      (item.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
        item.markType == NumberMarkUtil.OTHER_PHONE_DESC ||
        item.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE)) {
      return item.markContent;
    } else {
      return item.phoneNumber;
    }
  }

  getMissedCallNumberMarkInfoOrNumberLocation(item: CallLog, context?: Context): string {
    HiLog.i(TAG, `getMissedCallNumberMarkInfoOrNumberLocation ` + item.markType);
    if (!context) {
      HiLog.e(TAG, `getMissedCallNumberMarkInfoOrNumberLocation context is undefined`);
      return item.numberLocation == 'N' ? '' : item.numberLocation;
    }
    if (item.markType == NumberMarkUtil.PRE_FRAUD_PHONE_DESC) {
      if (item.markSource == NumberMarkUtil.ANTI_FRAUD_CENTER) {
        // 国家反诈中心
        let phoneNumber =
          !StringUtil.isEmpty(item.formattedNumber) ? item.formattedNumber : item.phoneNumber;
        let numberLocation = (item.numberLocation && item.numberLocation !== 'N') ? item.numberLocation : '';
        return `${phoneNumber} ${numberLocation}`;
      } else {
        // 高风险电话
        return context?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(item.markType).id);
      }
    } else if (item.isCloudMark === 0 && !StringUtil.isEmpty(item.markType) &&
      item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      item.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      item.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      item.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      // 用户手动标记
      if (item.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        return item.markContent;
      }
      return context?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(item.markType).id);
    } else if (item.isCloudMark === 1 && !StringUtil.isEmpty(item.markType) &&
      item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      item.markType != NumberMarkUtil.PRE_CUSTOM_PHONE_DESC &&
      item.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      item.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      item.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      return context?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(item.markType).id);
    } else {
      return item.numberLocation == 'N' ? '' : item.numberLocation;
    }
  }

  getNumberMap(contacts: Record<string, string>[]): Map<string, string> {
    let numberMap: Map<string, string> = new Map();
    contacts.forEach((item: Record<string, string>) => {
      if (!StringUtil.isEmpty(item.displayName)) {
        numberMap.set(item.detailInfo, item.displayName);
      }
    })
    return numberMap;
  }
}