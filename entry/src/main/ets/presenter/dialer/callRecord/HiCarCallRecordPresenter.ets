/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { dataShare } from '@kit.ArkData';
import hiTraceMeter from '@ohos.hiTraceMeter';
import { HiLog } from '../../../../../../../common';
import { CallLogRepository } from '../../../../../../../feature/call';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import CallRecordListDataSource from '../../../model/bean/CallRecordListDataSource';
import CallLogSetting from '../../../../../../../feature/call/src/main/ets/CallLogSetting';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { missedCallManager } from '../../../feature/missedCall/MissedCallManager';
import { LimitRefreshDataUtil } from '../../../util/LimitRefreshDataUtil';
import { GetAllCallActionData } from '../../../model/type';
import { CallInfoGetParamsInCallback, FavoriteFormType } from '../../../model/type/ContactParams';
import ContactListPresenter from '../../contact/ContactListPresenter';
import { CallLogSearchBo } from '../../../model/bean/CallLogSearchBo';
import DialerConstant from '../../../data/DialerConstant';

const TAG = 'HiCarCallRecordPresenter';

/**
 *用于联系人hicar的通话记录界面与数据库进行交互
 */
export default class HiCarCallRecordPresenter {
  private static instance?: HiCarCallRecordPresenter;
  public mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  public getAllCallsError: boolean = false;
  private isShow: boolean = false;
  private refreshState: () => void = () => {
  };
  private callLogRefreshIndex: number = 0;
  // 是否已经初始化，初始化列表，只会初始化一次，再次进入，不会初始化了
  private initStarted: boolean = false;
  private limitDataRefresh: LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback> | undefined =
    undefined;
  private onCallsChange = () => {
    HiLog.i(TAG, 'onCallsChange refresh');
    this.requestItem();
    // 通话记录改变，可能使收藏页面，的最近列表从无到有; 联系人详情页面打电话，拨号盘拨打，都会调用到
    CallLogSearchBo.getInstance().refreshCallChangeFlag();
  }
  private debounceTimer: number | null = null;
  // 联系人数据变更触发回调
  private onCallsLogChange = () => {
    HiLog.i(TAG, 'onCallsLogChange refresh');
    CallLogSearchBo.getInstance().refreshCallChangeFlag();
    this.onDataChange();
  }
  private onHiCarContactChange = (changeInfo?: dataShare.ChangeInfo): void => {
    ContactListPresenter.getInstance().onContactChange(changeInfo);
  }
  // 开始查询前执行回调，查询前准备动作，将查询index置为0
  private mPrepareCallBack = () => {
    this.callLogRefreshIndex = 0;
  }

  public static getInstance(): HiCarCallRecordPresenter {
    if (HiCarCallRecordPresenter.instance === undefined) {
      HiCarCallRecordPresenter.instance = new HiCarCallRecordPresenter();
    }
    return HiCarCallRecordPresenter.instance;
  }

  public static release(): void {
    HiCarCallRecordPresenter.instance = undefined;
  }

  public bindUI(refreshState: () => void): void {
    this.refreshState = refreshState;
  }

  public initDatabaseListener(): void {
    HiLog.i(TAG, 'initDatabaseListener!');
    this.limitRefreshInit();
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallsChange);
    ContactRepository.getInstance().registerDataChangeObserver(this.onHiCarContactChange);
    CallLogRepository.getInstance().registerSettingDataChangeObserver(this.onCallsLogChange);
    this.startInit();
  }

  public releaseDatabaseListener(): void {
    HiLog.i(TAG, 'initDatabaseListener!');
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallsChange);
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onHiCarContactChange);
    CallLogRepository.getInstance().unRegisterSettingDataChangeObserver(this.onCallsLogChange);
    this.limitRefreshUnInit();
  }

  public setPageShow(isShow: boolean, isFromOnPageShow?: boolean): void {
    HiLog.i(TAG, `setPageShow   isShow == ${isShow}`);
    HiLog.i(TAG, `this.isShow: ${this.isShow}`);
    if (this.isShow == isShow) {
      return;
    }
    if (this.limitDataRefresh == undefined) {
      this.limitRefreshInit()
    }
    this.isShow = isShow;
    this.limitDataRefresh?.setTaskForeground(isShow);
    if (this.isShow) {
      this.startInit();
      if (!isFromOnPageShow) {
        this.cancelMissedCallNotification()
      }
    }
    // 以分钟为单位 刷新通话记录列表时间
    if (this.isShow) {
      this.mAllCallRecordListDataSource.setIsShow(true);
      AppStorage.setOrCreate('sysMinutesTime', Math.floor(new Date().valueOf() / 1000 / 60));
    } else {
      this.mAllCallRecordListDataSource.setIsShow(false);
    }
  }

  public requestItem(): void {
    HiLog.i(TAG, 'CallLog requestItem!' + ' time:' + (new Date()).valueOf());
    hiTraceMeter.startTrace('requestItem', 2000)
    this.limitDataRefresh?.requestItem();
    hiTraceMeter.finishTrace('requestItem', 2000)
  }

  private cancelMissedCallNotification(): void {
    const teleNumber = AppStorage.get<string>(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE)
    HiLog.i(TAG, `cancelMissedCallNotification`);
    if (StringUtil.isEmpty(teleNumber as string)) {
      missedCallManager.cancelNotification()
    }
  }

  /**
   * 数据变化时的处理函数
   * 当数据发生变化时，会清除当前的定时器，并在200毫秒后执行请求函数
   */
  private onDataChange(): void {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      HiLog.i(TAG, 'onDataChange requestItem');
      this.requestItem();
    }, 200)
  }

  // defect density startInit
  private startInit(): void {
    HiLog.i(TAG, `startInit   this.initStarted == ${this.initStarted}`);
    if (!this.initStarted) {
      this.initStarted = true;
      this.requestItem();
    }
  }

  private limitRefreshInit(): void {
    HiLog.i(TAG, 'limitRefreshInit...');
    if (this.limitDataRefresh != undefined) {
      HiLog.i(TAG, 'limitRefresh has init,return..');
      return;
    }
    hiTraceMeter.startTrace('getAllCalls', 2001)
    this.limitDataRefresh = new LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback>('getAllCalls',
      (page: number, limit: number, result: CallInfoGetParamsInCallback) => {
        hiTraceMeter.finishTrace('getAllCalls', 2001)
        AppStorage.setOrCreate('callRecordInit', true);
        let dateLength: number = result.callLogList.length;
        HiLog.i(TAG, 'result.isEnd: ' + result.isEnd)
        let isEnd: boolean = result.isEnd === true;
        HiLog.i(TAG, `getAllCalls refreshPage ${page} limit ${limit}, length is ${dateLength}, isEnd is ${isEnd}`);
        HiLog.i(TAG,
          `getAllCalls callLogRefreshIndex ${this.callLogRefreshIndex}, length is ${result.callLogList.length}`);
        // 通话记录刷新，替换当前查询出来的部分，如果到了end，替换当前index到结尾
        this.mAllCallRecordListDataSource.refresh(this.callLogRefreshIndex, result.callLogList, isEnd);
        // 更新查询出来的通话记录条数
        this.callLogRefreshIndex += result.callLogList.length;
        DialerPresenter.getInstance().refresh();
        if (this.refreshState) {
          this.refreshState();
        }
        return isEnd;
      }, {
        mergeRule: CallLogSetting.getInstance().getMergeRule(),
        favoriteForm: JSON.stringify(new FavoriteFormType())
      } as GetAllCallActionData)
    this.limitDataRefresh.setPrepareCallBack(this.mPrepareCallBack);
  }

  private limitRefreshUnInit(): void {
    HiLog.i(TAG, 'limitRefreshUnInit');
    this.limitDataRefresh?.release();
    this.limitDataRefresh = undefined;
  }
}