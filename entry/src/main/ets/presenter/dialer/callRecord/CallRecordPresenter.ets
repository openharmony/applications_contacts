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

import { HiLog } from '../../../../../../../common';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { CallLogRepository, CallLogService } from '../../../../../../../feature/call';
import BlockListContact, {
  IsBlockContact
} from '../../../../../../../feature/contact/src/main/ets/entity/BlockListContact';
import {
  addBlockList,
  addToWhiteList,
  cancelBlockList,
  ContactRepository,
  getBlockedCallCountByPhoneNumber,
  getBlockedCallCountByDetectDetails,
  isInBlockList,
  isInBlockOrAccessList,
  queryYellowPageNameByNumber,
  updateBlockedCallCountByPhoneNumber,
  updateBlockedCallCountByDetectDetails,
  updateBlockList,
  updateToWhiteList,
  isInStartWithBlock
} from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { getNumberMarkInfoTask } from '../../../../../../../feature/contact/src/main/ets/repo/PhoneNumberMarkInfo';
import CallRecordListDataSource from '../../../model/bean/CallRecordListDataSource';
import CallLogSetting from '../../../../../../../feature/call/src/main/ets/CallLogSetting';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { missedCallManager } from '../../../feature/missedCall/MissedCallManager';
import { LimitRefreshDataUtil } from '../../../util/LimitRefreshDataUtil';
import { GetAllCallActionData, ReqData, SingleSelectContact } from '../../../model/type';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { CallInfoGetParamsInCallback, ContactPickerParam, FavoriteFormType } from '../../../model/type/ContactParams';
import call from '@ohos.telephony.call';
import LooseObject from '../../../model/type/LooseObject';
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallLogCnap } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import taskpool from '@ohos.taskpool';
import ContactListPresenter from '../../contact/ContactListPresenter';
import InterceptionCallRecordListDataSource from '../../../model/bean/InterceptionCallRecordListDataSource';
import { CallLogSearchBo } from '../../../model/bean/CallLogSearchBo';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { BlockType } from '../../../../../../../feature/contact/src/main/ets/contract/BlockList';
import { settings, StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import { queryIsInYellowPageByNumber } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import DialerConstant from '../../../data/DialerConstant';
import { dataShare } from '@kit.ArkData';
import hiTraceMeter from '@ohos.hiTraceMeter';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { JSON } from '@kit.ArkTS';
import { ResourceUtil } from '../../../util/ResourceUtil';
import deviceInfo from '@ohos.deviceInfo';

const TAG = 'CallRecordPresenter';
// 黑名单号码
const BLOCK_LIST_NUMBER = 1;
// 全部拦截
const ALL_INTERCEPTED_NUMBER = 3;
// 未知号码
const UNKNOWN_NUMBER = 4;
// 陌生号码
const STRANGE_NUMBER = 5;
// 黑名单开头匹配号码
const BLOCK_LIST_START_NUMBER = 6;
// 标记拦截
const MARK_INTERCEPTED_NUMBER = 1002;

export default class CallRecordPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static mPresenter: CallRecordPresenter | null;
  public interceptionCallRecordInit: boolean = false; // 通话拦截记录查询结果标志位，未查询完不更新UI
  public interceptionCallRecordChange: number = 1; // 通知拦截记录的列表刷新，值无用
  public mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource(); // 所有通话记录数据源
  public mMissCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource(); // 未接通话记录数据源
  public mInterceptionCallRecordListDataSource:
    InterceptionCallRecordListDataSource = new InterceptionCallRecordListDataSource; // 拦截通话记录数据源
  public isShow: boolean = false;
  public isInterceptionCallRecordShow: boolean = false;
  public refreshState: (business: string) => void = () => {
  };
  // interceptionCallLogRefreshIndex
  public interceptionCallLogRefreshIndex: number = 0;
  public callLogRefreshIndex: number = 0; // 所有通话记录刷新时已经获取的页数
  public missedRefreshIndex: number = 0; // 未接通话记录刷新时已经获取的页数
  public myAccountantsModel: SingleSelectContact | undefined; // 新建联系人参数
  public deleteCallLogItemID: number = -1;
  public tabIndex: number = 0; // 0：全部通话， 1：未接来电
  // 是否已经初始化，初始化列表，只会初始化一次，再次进入，不会初始化了
  public initStarted: boolean = false;
  public getAllCallsError: boolean = false;
  public limitDataRefresh: LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback> | undefined =
    undefined;
  public limitInterceptionCallsDataRefresh: LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback> |
  undefined = undefined;
  public onCallsChange = () => {
    HiLog.w(TAG, 'onCallsChange refresh');
    this.requestItem('onCallsChange');
    // 通话记录改变，可能使收藏页面，的最近列表从无到有; 联系人详情页面打电话，拨号盘拨打，都会调用到
    CallLogSearchBo.getInstance().refreshCallChangeFlag();
  };
  public debounceTimer: number | null = null;
  // 联系人数据变更触发回调
  public onContactChange = () => {
    HiLog.w(TAG, 'onContactChange refresh');
    CallLogSearchBo.getInstance().refreshCallChangeFlag();
    this.onDataChange();
  };
  // 设置数据变更触发回调
  public onCallsLogChange = () => {
    HiLog.w(TAG, 'onCallsLogChange refresh');
    CallLogSearchBo.getInstance().refreshCallChangeFlag();
    this.onDataChange();
  };
  //骚扰拦截通话记录数据库变更触发回调
  public onInterceptionCallsChange = () => {
    HiLog.w(TAG, 'onInterceptionCallsChange refresh');
    this.requestInterceptionCallsItem(true);
  };
  public appearNumber: number = 0;
  public preSysMinutesTime: number = -1;
  /**
   * 删除通话记录DataSource
   *
   * @param ids 通话记录id
   */
  public deleteCallrecord(ids: string[]): void {
    if (!ids || ids.length === 0) {
      HiLog.e(TAG, `deleteCallrecord ids empty.`);
      return;
    }
    HiLog.w(TAG, `deleteCallrecord ids=${ids}`);
    this.mAllCallRecordListDataSource.removeCallLog(ids);
    // 更新查询出来的通话记录条数
    this.callLogRefreshIndex = this.mAllCallRecordListDataSource.totalCount();
  }

  /**
   * 查看通话记录的个数
   *
   * @returns 通话记录个数
   */
  public allRecordLen(): number {
    let callRecordLen = this.mAllCallRecordListDataSource.totalCount() ?? 0;
    let missCallRecordLen = this.mMissCallRecordListDataSource.totalCount() ?? 0;
    let interceptionCallRecordLen = this.mInterceptionCallRecordListDataSource.totalCount() ?? 0;
    return callRecordLen + missCallRecordLen + interceptionCallRecordLen;
  }

  /**
   * 数据变化时的处理函数
   * 当数据发生变化时，会清除当前的定时器，并在200毫秒后执行请求函数
   */
  private onDataChange() {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      HiLog.w(TAG, 'onDataChange requestItem');
      this.requestItem('onDataChange');
    }, 200);
  }


  // 开始查询前执行回调，查询前准备动作，将查询index置为0
  public mPrepareCallBack = () => {
    this.callLogRefreshIndex = 0;
    this.interceptionCallLogRefreshIndex = 0;
    this.missedRefreshIndex = 0;
  };

  constructor() {

  }

  /**
   * get CallRecordPresenter Instance
   * @returns
   */
  static getInstance(): CallRecordPresenter {
    if (CallRecordPresenter.mPresenter == null) {
      CallRecordPresenter.mPresenter = new CallRecordPresenter();
    }
    return CallRecordPresenter.mPresenter;
  }

  bindUI(refreshState: (businessStr: string) => void) {
    this.refreshState = refreshState;
  }

  startInit() {
    HiLog.w(TAG, `startInit   this.initStarted == ${this.initStarted}`);
    if (!this.initStarted) {
      this.initStarted = true;
      this.requestItem('startInit');
    }
  }

  setPageShow(isShow: boolean, isFromOnPageShow?: boolean) {
    HiLog.w(TAG, `setPageShow   isShow == ${isShow}`);
    if (this.isShow == isShow) {
      return;
    }
    AppStorage.setOrCreate('isShowSegmentBtn', false);
    if (this.limitDataRefresh == undefined || this.limitInterceptionCallsDataRefresh == undefined) {
      this.limitRefreshInit();
    }
    this.isShow = isShow;
    this.limitDataRefresh?.setTaskForeground(isShow);
    if (this.isShow) {
      this.startInit();
      if (!isFromOnPageShow) {
        this.cancelMissedCallNotification();
      }
      missedCallManager.cancelNotification();
    }
    this.setTabShow();
  }

  setInterceptionCallsPageShow(isInterceptionCallRecordShow: boolean) {
    if (isInterceptionCallRecordShow) {
      this.updateInterceptionCallLogDataCreateTime();
    }
    if (this.isInterceptionCallRecordShow == isInterceptionCallRecordShow) {
      return;
    }
    this.isInterceptionCallRecordShow = isInterceptionCallRecordShow;
    this.limitInterceptionCallsDataRefresh?.setTaskForeground(isInterceptionCallRecordShow);
    if (this.isInterceptionCallRecordShow) {
      this.mInterceptionCallRecordListDataSource.setIsShow(true);
    }
  }

  //HiCar也需要注册这个单例的回调方法，避免双方指向同一个对象，这里生成了一个给phone使用的回调方法
  private onPhoneContactChange = (changeInfo?: dataShare.ChangeInfo): void => {
    ContactListPresenter.getInstance().onContactChange(changeInfo);
    this.onDataChange();
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear...');
    CallLogRepository.getInstance().isQueryTaskFinished = false;
    this.limitRefreshInit();
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallsChange);
    ContactRepository.getInstance().registerDataChangeObserver(this.onPhoneContactChange);
    CallLogRepository.getInstance().registerSettingDataChangeObserver(this.onCallsLogChange);
    this.requestItem('aboutToAppear');
    this.appearNumber += 1;
  }

  limitRefreshInit(): void {
    HiLog.w(TAG, 'limitRefreshInit...');
    if (this.limitDataRefresh != undefined && this.limitInterceptionCallsDataRefresh != undefined) {
      HiLog.w(TAG, 'limitRefresh has init,return..');
      return;
    }
    hiTraceMeter.startTrace('getAllCalls', 1001);
    this.limitDataRefresh = new LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback>('getAllCalls',
      (page: number, limit: number, result: CallInfoGetParamsInCallback) => {
        hiTraceMeter.finishTrace('getAllCalls', 1001);
        AppStorage.setOrCreate('callRecordInit', true);
        let dateLength: number = result.callLogList.length;
        HiLog.w(TAG, 'result.isEnd: ' + result.isEnd);
        let isEnd: boolean = result.isEnd === true;
        HiLog.w(TAG, `getAllCalls refreshPage ${page} limit ${limit}, length is ${dateLength}, isEnd is ${isEnd}`);
        HiLog.w(TAG,
          `getAllCalls callLogRefreshIndex ${this.callLogRefreshIndex}, length is ${result.callLogList.length}`);
        HiLog.w(TAG,
          `getAllCalls missedRefreshIndex ${this.missedRefreshIndex}, length is ${result.missedList.length}`);
        // 通话记录刷新，替换当前查询出来的部分，如果到了end，替换当前index到结尾
        this.mAllCallRecordListDataSource.refresh(this.callLogRefreshIndex, result.callLogList, isEnd);
        // 更新查询出来的通话记录条数
        this.callLogRefreshIndex += result.callLogList.length;
        DialerPresenter.getInstance().refresh();
        // 未接来电刷新
        this.mMissCallRecordListDataSource.refresh(this.missedRefreshIndex, result.missedList, isEnd);
        this.missedRefreshIndex += result.missedList.length;
        if (this.refreshState) {
          this.refreshState('limitDataRefresh requestItem ');
        }
        this.setMoreMenuStatus();
        if (page === 1) {
          // 打印第一个通话记录的数据，判断页面是否刷新
          let callRecord = this.mAllCallRecordListDataSource.getData(0);
          this.printCallRecordInfos(callRecord as MergedCallLog, 'all');
          let missCallRecord = this.mMissCallRecordListDataSource.getData(0);
          this.printCallRecordInfos(missCallRecord as MergedCallLog, 'miss');
        }
        if (isEnd) {
          // 打印总的通话记录数据长度，判断页面是否刷新
          HiLog.w(TAG, `getAllCalls all totalCount ${this.mAllCallRecordListDataSource.totalCount()}`);
          HiLog.w(TAG, `getAllCalls all miss totalCount ${this.mMissCallRecordListDataSource.totalCount()}`);
        }
        return isEnd;
      }, {
        mergeRule: CallLogSetting.getInstance().getMergeRule(),
        favoriteForm: JSON.stringify(new FavoriteFormType())
      } as GetAllCallActionData);
    //获取所有拦截通话记录
    this.limitInterceptionCallsDataRefresh =
      new LimitRefreshDataUtil<GetAllCallActionData, CallInfoGetParamsInCallback>('getInterceptionCalls',
        (page: number, limit: number, result: CallInfoGetParamsInCallback) => {
          this.interceptionCallRecordInit = true;
          let dateLength: number = result.callLogList.length;
          HiLog.w(TAG, `getInterceptionCalls result.isEnd: ` + result.isEnd);
          let isEnd: boolean = result.isEnd === true;
          if (isEnd) {
            // 设置和联系人同时操作通话防护列表，通知列表刷新
            AppStorage.setOrCreate('interceptionCallRecordChange', ++this.interceptionCallRecordChange);
          }
          HiLog.w(TAG, 'getInterceptionCalls refreshPage: ' + page +
            ' limit: ' + limit + ' length is: ' + dateLength + ' isEnd is: ' + isEnd);
          HiLog.w(TAG, 'getInterceptionCalls interceptionCallLogRefreshIndex: ' + this.interceptionCallLogRefreshIndex +
            ' length is: ' + result.callLogList.length);
          this.mInterceptionCallRecordListDataSource.refresh(this.interceptionCallLogRefreshIndex,
            result.callLogList, isEnd);
          this.interceptionCallLogRefreshIndex += result.callLogList.length;
          if (this.refreshState) {
            this.refreshState('limitInterceptionCallsDataRefresh requestItem ');
          }
          return isEnd;
        }, {} as GetAllCallActionData);
    this.limitDataRefresh.setPrepareCallBack(this.mPrepareCallBack);
    this.limitInterceptionCallsDataRefresh?.setPrepareCallBack(this.mPrepareCallBack);
  }

  printCallRecordInfos(callRecord: MergedCallLog, tag: string = '') {
    HiLog.w(TAG, `${tag}, getAllCalls 1st callRecord quickSearchKey: ${callRecord?.quickSearchKey
    }, disName: ${StringUtil.maskSensitiveInfo(callRecord?.displayName)
    }, phoneNum: ${StringUtil.maskSensitiveInfo(callRecord?.phoneNumber)}, count: ${callRecord?.count
    }, callType: ${callRecord?.callType}, markType: ${callRecord?.markType
    }, markContent: ${StringUtil.maskSensitiveInfo(callRecord?.markContent)}, markSource: ${callRecord?.markSource
    }, markDetails: ${StringUtil.maskSensitiveInfo(callRecord?.markDetails)}`);
  }

  limitRefreshUnInit(): void {
    HiLog.w(TAG, 'limitRefreshUnInit');
    this.limitInterceptionCallsDataRefresh?.release();
    this.limitDataRefresh?.release();
    this.limitInterceptionCallsDataRefresh = undefined;
    this.limitDataRefresh = undefined;
  }

  //注册拦截通话记录列表变化监听
  registerInterceptionCallsDataChangeObserver() {
    CallLogRepository.getInstance().registerDataChangeObserver(this.onInterceptionCallsChange);
  }

  //注销拦截通话记录列表变化监听
  unRegisterInterceptionCallsDataChangeObserver() {
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onInterceptionCallsChange);
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear!');
    if (this.appearNumber > 1) {
      this.appearNumber -= 1;
    } else {
      CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallsChange);
      ContactRepository.getInstance().unRegisterDataChangeObserver(this.onPhoneContactChange);
      CallLogRepository.getInstance().unRegisterSettingDataChangeObserver(this.onCallsLogChange);
      this.limitRefreshUnInit();
      this.initStarted = false;
      this.mAllCallRecordListDataSource.clean();
      this.mMissCallRecordListDataSource.clean();
      this.mInterceptionCallRecordListDataSource.clean();
    }
  }

  setTabShow() {
    if (this.isShow) {
      HiLog.w(TAG, 'setTabShow:' + this.tabIndex);
      // 电话tab
      if (this.tabIndex == 0) {
        // 全部通话
        this.mMissCallRecordListDataSource.setIsShow(false);
        this.mAllCallRecordListDataSource.setIsShow(true);
        this.updateCallLogDataCreateTime(false);
      } else {
        // 未接来电
        this.mAllCallRecordListDataSource.setIsShow(false);
        this.mMissCallRecordListDataSource.setIsShow(true);
        this.updateCallLogDataCreateTime(true);
      }
    } else {
      this.mAllCallRecordListDataSource.setIsShow(false);
      this.mMissCallRecordListDataSource.setIsShow(false);
    }
  }

  setTabIndex(index: number) {
    if (this.tabIndex != index) {
      this.tabIndex = index;
      this.setTabShow();
      this.setMoreMenuStatus();
    }
  }

  setMoreMenuStatus() {
    if (this.tabIndex === 0 && this.mAllCallRecordListDataSource.totalCount() > 0) {
      AppStorage.SetOrCreate('hasCallRecord', true);
    } else if (this.tabIndex === 1 && this.mMissCallRecordListDataSource.totalCount() > 0) {
      AppStorage.SetOrCreate('hasCallRecord', true);
    } else {
      AppStorage.SetOrCreate('hasCallRecord', false);
    }
  }

  requestItem(tag?: string) {
    HiLog.w(TAG, `CallLog requestItem! tag: ${tag}, time: ${(new Date()).valueOf()}`);
    hiTraceMeter.startTrace('requestItem', 1000);
    this.limitDataRefresh?.requestItem();
    hiTraceMeter.finishTrace('requestItem', 1000);
  }

  //查询拦截通话记录
  requestInterceptionCallsItem(fromDataChange?: boolean) {
    HiLog.w(TAG, 'CallLog requestInterceptionCallsItem!' + fromDataChange);
    if (!fromDataChange) {
      let data: LooseObject = {
        isBlocked: true
      };
      missedCallManager.cancelNotification(data);
      CallLogRepository.getInstance().markInterceptionMissedCallsAsRead();
    }
    this.limitInterceptionCallsDataRefresh?.requestItem();
  }

  dialing(phoneNumber: string, options?: call.DialOptions) {
    PhoneNumber.fromString(phoneNumber).dial(options);
  }

  deleteCallLog(ids: number[], phoneNumbers: string[], index?: number) {
    HiLog.w(TAG, 'deleteCallLog start');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteCallLogsById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: ids,
        phoneNumbers: phoneNumbers
      }, () => {
        HiLog.w(TAG, 'deleteCallLog Success');
      });
    if (index != undefined) {
      if (this.tabIndex == 0) {
        this.mAllCallRecordListDataSource.remove(index);
      } else {
        this.mMissCallRecordListDataSource.remove(index);
      }
    }
  }

  deleteInterceptionCallLog(id: number[], index?: number) {
    HiLog.w(TAG, 'deleteInterceptionCallLog id: ' + id);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteCallLogsById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: id
      }, () => {
        HiLog.w(TAG, 'deleteCallLog Success');
      });
    if (index != undefined) {
      this.mInterceptionCallRecordListDataSource.remove(index);
    }
  }

  cancelMissedCallNotification() {
    let teleNumber = AppStorage.Get<string>(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE);
    HiLog.w(TAG, `cancelMissedCallNotification`);
    if (StringUtil.isEmpty(teleNumber as string)) {
      missedCallManager.cancelNotification();
    }
  }

  // Jump Detail By NavPathStack
  jumpToContactDetail(phoneNumber: string, isMarked: boolean, markType: string, markCount: number, markSource: string,
    isCloud: boolean, markContent: string, markDetails: string, isYellowPage: boolean, isPrivateNumber: boolean,
    cnap?: CallLogCnap, quickSearchKey?: string) {
    HiLog.w(TAG, `jumpToContactDetail, pathInfos: ${StringUtil.maskSensitiveInfo(this.pathInfos.getAllPathName().toString())}`);
    const params: Record<string, boolean | string | number> = {
      'sourceHasPhone': true,
      'phoneNumberShow': phoneNumber,
      'isMarked': isMarked,
      'markType': markType,
      'markCount': markCount,
      'markSource': markSource,
      'isCloud': isCloud,
      'markContent': markContent,
      'markDetails': markDetails,
      'isYellowPage': isYellowPage,
      'isPrivateNumber': isPrivateNumber,
      'quickSearchKey': quickSearchKey ?? '',
      'isFromCallLog': true,
    };
    if (cnap?.isCnap === 1) {
      params['isCnap'] = true;
      params['displayName'] = cnap.displayName;
    }
    if (this.pathInfos.size() > 0 &&
      this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === 'ContactDetail') {
      this.pathInfos.replacePathByName('ContactDetail', params);
    } else {
      DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
        HiLog.w(TAG, `enterFire, equipment is ${AppStorage.get('breakpoint')}`);
        if (AppStorage.get('breakpoint') !== 'sm') {
          this.pathInfos.replacePathByName('ContactDetail', params);
        } else {
          this.pathInfos.pushPathByName('ContactDetail', params);
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `enterFire error: ${err?.message}, equipment is ${AppStorage.get('breakpoint')}`);
        if (AppStorage.get('breakpoint') !== 'sm') {
          this.pathInfos.replacePathByName('ContactDetail', params);
        } else {
          this.pathInfos.pushPathByName('ContactDetail', params);
        }
      });
    }
  }

  // defect density toDefaultPage
  toDefaultPage() {
    HiLog.w(TAG, `pathInfos pushPathByName: DialerPad --- isShowSmartWindow:${AppStorage.get('isShowSmartWindow')},${AppStorage.get('isNavigationModeSplit')}`);
    if (!EnvironmentProp.isPC() && !AppStorage.get('isNavigationModeSplit')) {
      HiLog.w(TAG, `pathInfos pushPathByName return.`);
      return;
    }
    if (AppStorage.get('breakpoint') !== 'sm' && AppStorage.get('breakpoint') !== '') {
      this.pathInfos.clear();
      this.pathInfos.pushPathByName('DialerPad', '', false);
      AppStorage.setOrCreate('isShowDial', false);
      HiLog.i(TAG, 'go to DialerPad');
    }
  }

  /**
   * go default page when on new want
   */
  toDefaultPageWhenOnNewWant() {
    let breakPoint = AppStorage.get('breakpoint') as string;
    let deviceType = deviceInfo.deviceType;
    HiLog.w(TAG,
      `toDefaultPageWhenSplit: DialerPad --- isShowSmartWindow:${AppStorage.get('isShowSmartWindow')},${breakPoint},${deviceType},${EnvironmentProp.isPC()},${AppStorage.get('isNavigationModeSplit')},${breakPoint}`);
    if (breakPoint !== 'sm' && breakPoint !== '') {
      this.pathInfos.clear();
      this.pathInfos.pushPathByName('DialerPad', '', false);
      AppStorage.setOrCreate('isShowDial', false);
      HiLog.i(TAG, 'go to DialerPad toDefaultPageWhenSplit');
    }
  }

  /**
   * 更新通话记录的显示时间
   */
  updateCallLogDataCreateTime(isOnlyMissCall: boolean) {
    // 以分钟为单位 刷新通话记录列表时间
    let curSysMinutesTime = Math.floor(new Date().valueOf() / 1000 / 60);
    HiLog.w(TAG, `pre sysMinutesTime: ${this.preSysMinutesTime}, cur sysMinutesTime: ${curSysMinutesTime
    }, time: ${new Date().valueOf()}`);
    if (this.preSysMinutesTime === curSysMinutesTime) {
      HiLog.w(TAG, `no need update callLog time`);
      return;
    }
    this.preSysMinutesTime = curSysMinutesTime;
    let callLogData: MergedCallLog[] = [];
    if (isOnlyMissCall) {
      callLogData = this.mMissCallRecordListDataSource.getCallLogData() as MergedCallLog[];
    } else {
      callLogData = this.mAllCallRecordListDataSource.getCallLogData() as MergedCallLog[];
    }
    for (let i = 0; i < callLogData.length; ++i) {
      if (callLogData[i].createTimeSource !== undefined) {
        callLogData[i].createTime =
          CallLogService.getInstance().formatTime(callLogData[i].createTimeSource as number) as string;
      }
    }
    if (isOnlyMissCall) {
      this.mMissCallRecordListDataSource.refreshAll(callLogData);
    } else {
      this.mAllCallRecordListDataSource.refreshAll(callLogData);
    }
  }

  /**
   * 更新通话拦截记录的显示时间
   */
  updateInterceptionCallLogDataCreateTime() {
    let callLogData: MergedCallLog[] = this.mInterceptionCallRecordListDataSource.getCallLogData() as MergedCallLog[];
    let now = new Date();
    let todayTime: number = new Date(now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate()).getTime();
    let timeFormat = settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext() as Context, settings.date.TIME_FORMAT, '12');
    for (let i = 0; i < callLogData.length; ++i) {
      if (callLogData[i].createTimeSource !== undefined) {
        callLogData[i].createTime =
          CallLogService.getInstance().formatInterceptionCallsTime(callLogData[i].createTimeSource as number,
            todayTime, Number.parseInt(timeFormat)) as string;
        callLogData[i].createInterceptionTime =
          CallLogService.getInstance().createInterceptionGroupTime(callLogData[i].createTimeSource as number,
            todayTime);
      }
    }
    this.mInterceptionCallRecordListDataSource.refreshAll(callLogData);
  }

  addToWhiteList(phoneNumber: string, callback: Function) {
    HiLog.w(TAG, 'addBlockList start.');
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let task = new taskpool.Task(addToWhiteList, context, phoneNumber);
      taskpool.execute(task);
      callback(true);
    } catch (err) {
      callback(false);
      HiLog.w(TAG, 'isInBlockList failed err: ' + (err as BusinessError).message);
    }
  }

  updateToWhiteList(phoneNumber: string, callback: Function) {
    HiLog.w(TAG, 'addBlockList start.');
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let task = new taskpool.Task(updateToWhiteList, context, phoneNumber);
      taskpool.execute(task);
      callback(true);
    } catch (err) {
      callback(false);
      HiLog.w(TAG, 'isInBlockList failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * in blockList or not
   *
   * @param phoneNumber
   * @param callback
   * @param isWhite
   * @param context
   */
  isInBlockList(phoneNumber: string, callback: Function, isWhite: boolean, context?: StaticSubscriberExtensionContext) {
    HiLog.w(TAG, 'isInBlockList start.');
    try {
      let con = context ? context : ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let task = new taskpool.Task(isInBlockList, con, phoneNumber, isWhite);
      taskpool.execute(task).then((result: Object) => {
        HiLog.w(TAG, 'isInBlockList isInBlockOrAllowList');
        callback(result as IsBlockContact);
      });
    } catch (err) {
      callback({
        isInBlock: false,
        phoneNumber: phoneNumber
      });
      HiLog.w(TAG, 'isInBlockList failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * get blocked call count by detectDetails
   *
   * @param phoneNumber
   * @param context
   * @param callback
   */
  getBlockedCallCountByDetectDetails(detectDetails: string, context: Context, callback: Function) {
    HiLog.w(TAG, 'getBlockedCallCountByDetectDetails start.');
    try {
      let task = new taskpool.Task(getBlockedCallCountByDetectDetails, context, detectDetails);
      taskpool.execute(task).then((result: Object) => {
        if (result != undefined) {
          HiLog.w(TAG, 'query blocked call count:' + result);
          callback(result as BlockListContact);
        }
      })
    } catch (err) {
      callback(undefined);
      HiLog.e(TAG, 'getBlockedCallCountByDetectDetails failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * get blocked call count by phoneNumber
   *
   * @param phoneNumber
   * @param context
   * @param callback
   */
  getBlockedCallCountByPhoneNumber(phoneNumber: string, context: Context, callback: Function) {
    HiLog.w(TAG, 'getBlockedCallCountByPhoneNumber start.');
    try {
      let task = new taskpool.Task(getBlockedCallCountByPhoneNumber, context, phoneNumber);
      taskpool.execute(task).then((result: Object) => {
        if (result != undefined) {
          HiLog.w(TAG, 'query blocked call count:' + result);
          callback(result as BlockListContact);
        }
      });
    } catch (err) {
      callback(undefined);
      HiLog.e(TAG, 'getBlockedCallCountByPhoneNumber failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * update blocked call count by detectDetails
   *
   * @param phoneNumber
   * @param context
   * @param count
   */
  updateBlockedCallCountByDetectDetails(context: Context, blockListContact: BlockListContact, isAdd: boolean) {
    HiLog.w(TAG, 'updateBlockedCallCountByDetectDetails start.');
    try {
      let task = new taskpool.Task(updateBlockedCallCountByDetectDetails, context, blockListContact, isAdd);
      taskpool.execute(task);
    } catch (err) {
      HiLog.e(TAG, 'updateBlockedCallCountByDetectDetails failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * update blocked call count by phoneNumber
   *
   * @param phoneNumber
   * @param context
   * @param count
   */
  updateBlockedCallCountByPhoneNumber(context: Context, blockListContact: BlockListContact, isAdd: boolean) {
    HiLog.w(TAG, 'updateBlockedCallCountByPhoneNumber start.');
    try {
      let task = new taskpool.Task(updateBlockedCallCountByPhoneNumber, context, blockListContact, isAdd);
      taskpool.execute(task);
    } catch (err) {
      HiLog.e(TAG, 'updateBlockedCallCountByPhoneNumber failed err: ' + (err as BusinessError).message);
    }
  }

  getBlockReasonResource(item: MergedCallLog): Resource | string {
    switch (item.blockReason) {
      case BLOCK_LIST_NUMBER:
      case BLOCK_LIST_START_NUMBER:
        return $r('app.string.blocklist_number');
      case UNKNOWN_NUMBER:
        return $r('app.string.unknown_phonenumber');
      case STRANGE_NUMBER:
        return $r('app.string.harassment_blockreason_strangenumber');
      case ALL_INTERCEPTED_NUMBER:
        return $r('app.string.interception_rule_blockall_title');
      case MARK_INTERCEPTED_NUMBER:
        if (item.markType) {
          switch (item.markType) {
            case NumberMarkUtil.PRE_CRANK_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.harassment_nuisance_calls_reason').id);
            case NumberMarkUtil.PRE_FRAUD_PHONE_DESC:
              if (item.isCloudMark === 1) {
                if (item.markSource == NumberMarkUtil.ANTI_FRAUD_CENTER) {
                  // 疑似诈骗
                  return ContactsGlobalThisHelper.GetGlobalThis()
                    .getDefaultUIContext()
                  ?.resourceManager
                    .getStringSync($r('app.string.suspected_fraud').id);
                } else {
                  // 高风险电话
                  if (item.markSource == NumberMarkUtil.ANTIFRAUD_CENTER_MARK_SOURCE) {
                    return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
                    ?.resourceManager?.getStringSync($r('app.string.number_mark_fraud'));
                  } else {
                    // 高风险  xx人标记过
                    return this.getResourceStrWithMark(item, $r('app.string.harassment_scam_calls_reason').id);
                  }
                }
              } else {
                return this.getResourceStrWithMark(item, $r('app.string.harassment_scam_calls_reason').id);
              }
            case NumberMarkUtil.PRE_EXPRESS_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.number_mark_express').id);
            case NumberMarkUtil.PRE_PROMOTE_SALES_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.harassment_advertising_calls_reason').id);
            case NumberMarkUtil.PRE_HOUSE_AGENT_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.harassment_real_estate_calls_reason').id);
            case NumberMarkUtil.PRE_INSURANCE_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.number_mark_insurance').id);
            case NumberMarkUtil.PRE_TAXI_PHONE_DESC:
              return this.getResourceStrWithMark(item, $r('app.string.number_mark_taxi').id);
            case NumberMarkUtil.OTHER_PHONE_DESC:
              return this.getResourceStrWithMark(item);
            default:
              return '';
          }
        }
      default:
        return '';
    }
  }

  private getResourceStrWithMark(item: MergedCallLog, resId?: number): string {
    if (!item) {
      return '';
    }
    let strBuilder: string[] = [];
    try {
      if (resId) {
        strBuilder.push(this.getResourceStr(resId));
      } else {
        strBuilder.push(item.markContent);
      }
      if (item.isCloudMark === 1) {
        strBuilder.push(ResourceUtil.getPluralStringByResource($r('app.plural.already_mark_update'), item.markCount));
      } else {
        strBuilder.push(this.getResourceStr($r('app.string.harassment_blockreason_mark_by_user').id));
      }
      return strBuilder.join('  ');
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.i(TAG, `get resource failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    return '';
  }

  private getResourceStr(resId: number, ...args: Array<string | number>): string {
    return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      .resourceManager.getStringSync(resId, ...args);
  }

  /**
   * 从通话记录，长按一条后，新建联系人
   *
   * @param phoneNumber
   */
  createNewContact(phoneNumber: string) {
    HiLog.w(TAG, 'createNewContact start.');
    const params: Record<string, Record<string, string>[] | boolean> = {
      'updataShow': false,
      'phoneNumbers': [
        {
          'phoneNumber': phoneNumber
        }
      ]
    };
    DynamicLoader.getInstance().fire(DynamicLoader.ACCOUNTANTS).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.ACCOUNTANTS, params);
    });
  }

  creatAccountantsObj(phoneNumber: string, displayName: string) {
    HiLog.w(TAG, 'createNewContact start.');
    let phoneNumbers: Record<string, string> = {
      'phoneNumber': phoneNumber,
    };
    let contact: SingleSelectContact = StringUtil.isEmpty(displayName) ? {
      updataShow: false,
      phoneNumbers: [phoneNumbers],
    } as SingleSelectContact : {
      updataShow: false,
      phoneNumbers: [phoneNumbers],
      disPlayName: displayName,
      displayNameHighlight: true,
    } as SingleSelectContact;
    this.myAccountantsModel = contact;
  }

  saveExistingContacts(phoneNumber: string) {
    HiLog.w(TAG, 'saveExistingContacts start.');
    const params: ContactPickerParam = {
      phoneNumberShow: phoneNumber,
      isSaveExistContact: true,
      isDisplayByName: true,
    };
    DynamicLoader.getInstance().fire(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE, params);
    });
  }

  /**
   * Add BlockList
   *
   * @param {Object} addToBlockList phone numbers
   * @param {Object} callBack
   */
  addToBlockList(phoneNumbers: string[], displayName: string, callBack: Function) {
    for (let i = 0; i < phoneNumbers.length; i++) {
      this.isInAccessList(phoneNumbers[i], (result: boolean) => {
        if (result) {
          this.addToBlockListByUpdate(phoneNumbers[i], displayName, callBack);
        } else {
          this.addToBlockLitByInsert(phoneNumbers[i], displayName, callBack);
        }
      });
    }
  }

  private isInAccessList(phoneNumber: string, callBack: Function) {
    HiLog.w(TAG, 'isInAccessList start.');
    this.isInBlockOrAccessList([phoneNumber as string], BlockType.ACCESS
      , ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (arg: boolean) => {
        HiLog.w(TAG, 'isInAccessList: ' + arg);
        callBack(arg);
      });
  }

  private addToBlockLitByInsert(phoneNumber: string, displayName: string, callBack: Function) {
    this.addBlockList(phoneNumber, displayName,
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (data: Object) => {
        if (!data || data == -1) {
          HiLog.e(TAG, 'Data inserted failed');
          callBack(false);
        }
        callBack(true);
      }
    );
  }

  private addToBlockListByUpdate(phoneNumber: string, displayName: string, callBack: Function) {
    this.updateBlockList(phoneNumber, displayName,
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (data: Object) => {
        if (!data || data == -1) {
          HiLog.e(TAG, 'Data inserted failed');
          callBack(false);
        }
        callBack(true);
      }
    );
  }

  /**
   * Add BlockList
   *
   * @param {Object} addBlockList phone numbers
   * @param {Object} callBack
   * @param {Object} context
   */
  private async addBlockList(phoneNumbers: string, displayName: string,
    context: common.UIAbilityContext, callBack?: Function) {
    try {
      let task = new taskpool.Task(addBlockList, context, phoneNumbers, displayName);
      taskpool.execute(task).then((data: Object) => {
        if (!data || data == -1) {
          HiLog.e(TAG, 'Data inserted failed');
        }
        AppStorage.setOrCreate('blockListChanged', true);
        if (callBack != undefined) {
          callBack(data);
        }
      });
    } catch (err) {
      HiLog.e(TAG, 'blockList insert error: ' + (err as BusinessError).message);
    }
  }

  /**
   * Update BlockList
   *
   * @param {Object} updateBlockList phone number
   * @param {Object} callBack
   * @param {Object} context
   */
  private async updateBlockList(phoneNumbers: string, displayName: string,
    context: common.UIAbilityContext, callBack?: Function) {
    try {
      let task = new taskpool.Task(updateBlockList, context, phoneNumbers, displayName);
      taskpool.execute(task).then((data: Object) => {
        if (!data || data == -1) {
          HiLog.e(TAG, 'Data inserted failed');
        }
        AppStorage.setOrCreate('blockListChanged', true);
        if (callBack != undefined) {
          callBack(data);
        }
      });
    } catch (err) {
      HiLog.e(TAG, 'blockList insert error: ' + (err as BusinessError).message);
    }
  }

  /**
   * Query BlockList；号码全在才是true
   *
   * @param {Object} queryBlockList phone numbers
   * @param {Object} queryBlockList block types
   * @param {Object} callBack
   * @param {Object} context
   */
  async isInBlockOrAccessList(phoneNumbers: string[], types: number,
    context: common.UIAbilityContext, callBack?: Function) {
    try {
      let task = new taskpool.Task(isInBlockOrAccessList, context, phoneNumbers,
        types);
      taskpool.execute(task).then((result: Object) => {
        if (callBack != undefined) {
          callBack(result);
        }
      });
    } catch (err) {
      HiLog.e(TAG, 'isInBlockOrAccessList failed err: ' + (err as BusinessError).message);
      if (callBack != undefined) {
        callBack(false);
      }
    }
  }

  /**
   * Delete BlockList
   *
   * @param {Object} deleteBlockList phone numbers
   * @param {Object} context
   * @param {Object} callBack
   */
  async cancelBlockList(phoneNumbers: string[], context: common.UIAbilityContext, callBack?: Function) {
    try {
      let task = new taskpool.Task(cancelBlockList, context, phoneNumbers);
      taskpool.execute(task).then((data: Object) => {
        if (data == -1) {
          HiLog.e(TAG, 'delete phoneNumbers in blockList in failed!');
        }
        AppStorage.setOrCreate('blockListChanged', true);
        if (callBack != undefined) {
          callBack(true);
        }
        HiLog.w(TAG, 'delete phoneNumbers in blockList success!');
      });
    } catch (err) {
      if (callBack != undefined) {
        callBack(false);
      }
      HiLog.e(TAG, 'cancelBlockList failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * Query BlockList
   *
   * @param {Object} queryBlockList phone numbers
   * @param {Object} queryBlockList block types
   * @param {Object} callBack
   * @param {Object} context
   */
  async isInStartWithBlock(phoneNumber: string,
    context: common.UIAbilityContext, callBack?: Function) {
    try {
      let task = new taskpool.Task(isInStartWithBlock, context, phoneNumber);
      taskpool.execute(task).then((result: Object) => {
        HiLog.w(TAG, 'isInStartWithBlock result: ' + result);
        if (callBack != undefined) {
          callBack(result);
        }
      });
    } catch (err) {
      HiLog.e(TAG, 'isInStartWithBlock failed err: ' + (err as BusinessError).message);
      if (callBack != undefined) {
        callBack(false);
      }
    }
  }

  /**
   * Check whether the number in the call record is marked.
   *
   * @param phoneNumber
   * @param context
   * @param callBack
   */
  isPhoneNumberMarkedOrNot(phoneNumber: string,
    context: common.UIAbilityContext, callBack?: Function) {
    try {
      HiLog.w(TAG, 'isPhoneNumberMarkedOrNot start');
      let task = new taskpool.Task(getNumberMarkInfoTask, context, phoneNumber);
      taskpool.execute(task).then((numberMarkInfo: LooseObject) => {
        HiLog.w(TAG, 'isPhoneNumberMarkedOrNot getNumberMarkInfoTask end');
        let isMarked: boolean = !numberMarkInfo?.isCloud && numberMarkInfo.markType &&
          numberMarkInfo.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
          numberMarkInfo.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
          numberMarkInfo.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC;
        let result: LooseObject = {
          isMarked: isMarked ? isMarked : false,
          markType: numberMarkInfo.markType ? numberMarkInfo.markType : NumberMarkUtil.PRE_NONE_PHONE_DESC,
          markContent: numberMarkInfo?.markContent,
          markCount: numberMarkInfo?.markCount,
          markSource: numberMarkInfo?.markSource,
          isCloud: numberMarkInfo?.isCloud as boolean,
          markDetails: numberMarkInfo?.markDetails
        };
        if (callBack != undefined) {
          callBack(result);
        }
      });
    } catch (err) {
      if (callBack != undefined) {
        callBack(false);
      }
      HiLog.e(TAG, 'isPhoneNumberMarkedOrNot failed err: ' + (err as BusinessError).message);
    }
  }

  /**
   * Query YellowPage
   *
   * @param {Object} queryYellowPage phone numbers
   * @param {Object} context
   * @param {Object} callBack
   */
  async queryIsInYellowPage(number: string, context: common.UIAbilityContext, callBack?: Function) {
    let task = new taskpool.Task(queryIsInYellowPageByNumber, context, number);
    taskpool.execute(task).then((result: object) => {
      if (callBack != undefined) {
        callBack(result);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryIsInYellowPage failed: %s', error?.message);
      if (callBack != undefined) {
        callBack(false);
      }
    });
  }

  deleteCallLogItemPage(callLogID: number[]) {
    if (AppStorage.get('breakpoint') === 'sm' || AppStorage.get('isShowSmartWindow')) {
      HiLog.w(TAG, 'deleteCallLogItemPage Screen size: ' + AppStorage.get('breakpoint') +
        '    Is Small window:' + AppStorage.get('isShowSmartWindow'));
      return;
    }

    if (!EnvironmentProp.isPC() && (!call.hasVoiceCapability() || (AppStorage.get('mainTabsIndex') !== 0))) {
      HiLog.w(TAG, 'deleteCallLogItemPage mainTabsIndex: ' + AppStorage.get('mainTabsIndex'));
      return;
    }

    HiLog.w(TAG, 'deleteCallLogItemPage Include Element: ' + callLogID.includes(this.deleteCallLogItemID));
    if (callLogID.includes(this.deleteCallLogItemID)) {
      this.pathInfos.replacePathByName('DialerPad', '', false);
      this.deleteCallLogItemID = -1;
      AppStorage.setOrCreate('isShowDial', false);
    }
  }

  public static unInstance(): void {
    HiLog.w(TAG, 'unInstance...');
    CallRecordPresenter.mPresenter = null;
  }

  //首屏预加载通话记录
  preRequestCallLog(): void {
    HiLog.w(TAG, 'start preRequestCallLog');
    // 提前获取前50条数据，铺满一页
    let actionData: GetAllCallActionData = {
      page: 1,
      limit: 50,
      mergeRule: CallLogSetting.getInstance().getMergeRule(),
      favoriteForm: JSON.stringify(new FavoriteFormType()),
      isNeedQueryContact: false
    };
    const reqData: ReqData<GetAllCallActionData> = {
      actionData: actionData
    };
    hiTraceMeter.startTrace('preRequestCallLog', 1101);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      // 预加载数据，使用静默访问方式查询数据库，优化在数据库进程处于kill状态，查询需要拉起数据库，查询很慢问题
      // 静默访问方式查询，不需要拉起数据库进程，走datashare代理
      .sendRequestUiThread('getAllCallsProxy', reqData, (result: CallInfoGetParamsInCallback) => {
        // 如果
        HiLog.w(TAG, 'preRequestCallLog result size : ' + result.callLogList.length + ',last calllog :' +
        this.mAllCallRecordListDataSource.getCallLogData().length);
        if (this.mAllCallRecordListDataSource.getCallLogData().length === 0 &&
          result.callLogList.length > 0) {
          AppStorage.setOrCreate('callRecordInit', true);
          // 将datasource的元素替换为result的
          if (result.callLogList.length >= 4 && AppStorage.get('breakpoint') === 'sm') {
            this.mAllCallRecordListDataSource.refresh(0, result.callLogList.slice(0, 4), true);
          } else {
            this.mAllCallRecordListDataSource.refresh(0, result.callLogList, true);
          }
        }
        if (this.refreshState) {
          this.refreshState('preRequestCallLog ');
        }
        hiTraceMeter.finishTrace('preRequestCallLog', 1101);
      });
  }
};