/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach } from '@ohos/hypium';
import CallRecordPresenter
  from "../../../../../../../../../entry/src/main/ets/presenter/dialer/callRecord/CallRecordPresenter";
import { missedCallManager } from '../../../../../../../main/ets/feature/missedCall/MissedCallManager';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { CallLog, CallLogRepository, CallLogService } from '../../../../../../../../../feature/call';
import BlockListContact from '../../../../../../../../../feature/contact/src/main/ets/entity/BlockListContact'
import MergedCallLog from '../../../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import CallLogBuilder from '../../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import FavoriteListPresenter from '../../../../../../../main/ets/presenter/favorite/FavoriteListPresenter';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import ContactListPresenter from '../../../../../../../main/ets/presenter/contact/ContactListPresenter';
import call from '@ohos.telephony.call';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import dataShare from '@ohos.data.dataShare';
import { CallInfoGetParamsInCallback } from '../../../../../../../main/ets/model/type/ContactParams';
import { IsBlockContact } from '../../../../../../../../../feature/contact/src/main/ets/entity/BlockListContact';
import { DynamicLoader } from '../../../../../../../../../common/src/main/ets/util/DynamicLoader';
import EnvironmentProp from '../../../../../../../main/ets/feature/EnvironmentProp';
import { HiLog } from '../../../../../../../../../feature/call/oh_modules/common'
import { SingleSelectContact } from '../../../../../../../main/ets/model/type';

const TAG = 'CallRecordPresenter';


export default function CallRecordPresenterTest() {
  describe('CallRecordPresenterTest', () => {
    let callRecordPresenter: CallRecordPresenter;
    let mockKit: MockKit;

    beforeEach(() => {
      AppStorage.clear();
      callRecordPresenter = new CallRecordPresenter();
      mockKit = new MockKit();
    })

    afterEach(() => {
      mockKit.clear(callRecordPresenter);
    })


    it('CallRecordPresenterTest_onContactChange', 0, () => {
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.requestItem);

      callRecordPresenter.onContactChange();

      expect(callRecordPresenter.debounceTimer != null).assertTrue();
    })

    it('CallRecordPresenterTest_onCallsLogChange', 0, () => {
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.requestItem);

      callRecordPresenter.onCallsLogChange();

      expect(callRecordPresenter.debounceTimer != null).assertTrue();
    })

    it('CallRecordPresenterTest_onInterceptionCallsChange', 0, () => {
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.requestInterceptionCallsItem);

      callRecordPresenter.onInterceptionCallsChange();

      mockKit.verify('requestInterceptionCallsItem', [true]).once();
    })

    it('CallRecordPresenterTest_limitDataRefresh', 0, () => {
      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mAllCallRecordListDataSource.refresh);
      mockKit.mockFunc(callRecordPresenter.mMissCallRecordListDataSource, callRecordPresenter.mMissCallRecordListDataSource.refresh);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setMoreMenuStatus);

      let callLogList: Array<MergedCallLog> = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];
      let missedList: Array<MergedCallLog> = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];
      let callLogSearchList: Array<MergedCallLog> = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];
      let callInfoGetParamsInCallback: CallInfoGetParamsInCallback = {
        callLogList: callLogList,
        missedList: missedList,
        callLogSearchList: callLogSearchList,
        timeStamp: '',
        isEnd: false
      } as CallInfoGetParamsInCallback;

      let result1 = false;
      callRecordPresenter.refreshState = () => {
        result1 = true;
      };

      let result: boolean | undefined = callRecordPresenter.limitDataRefresh?.getResultCallBack()(1, 1, callInfoGetParamsInCallback);

      expect(result).assertUndefined();
      expect(result1).assertFalse();

      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
      mockKit.clear(callRecordPresenter.mMissCallRecordListDataSource);
      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_mPrepareCallBack', 0, () => {
      callRecordPresenter.callLogRefreshIndex = 1;
      callRecordPresenter.missedRefreshIndex = 1;
      callRecordPresenter.mPrepareCallBack();
      expect(callRecordPresenter.callLogRefreshIndex).assertEqual(0);
      expect(callRecordPresenter.missedRefreshIndex).assertEqual(0);
    })

    it('CallRecordPresenterTest_getInstance', 0, () => {
      expect(typeof CallRecordPresenter.getInstance()).assertEqual(typeof callRecordPresenter);
    })

    it('CallRecordPresenterTest_bindUI', 0, () => {
      let refreshState = () => {
        1
      };
      callRecordPresenter.bindUI(refreshState);
      expect(callRecordPresenter.refreshState).assertEqual(refreshState);
    })

    it('CallRecordPresenterTest_startInit_initStarted_false', 0, () => {
      callRecordPresenter.initStarted = false
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.requestItem)
      callRecordPresenter.startInit()
      mockKit.verify("requestItem", ['startInit']).once();

      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_startInit_initStarted_true', 0, () => {
      callRecordPresenter.initStarted = true;

      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.requestItem);

      callRecordPresenter.startInit()

      mockKit.verify("requestItem", []).never();

      mockKit.clear(callRecordPresenter);

    })

    it('CallRecordPresenterTest_setPageShow_return', 0, () => {
      let isShow: boolean = false;
      let isFromOnPageShow: boolean = false;
      callRecordPresenter.isShow = isShow;

      mockKit.mockFunc(callRecordPresenter.limitRefreshInit, callRecordPresenter.limitDataRefresh?.setTaskForeground);

      callRecordPresenter.setPageShow(isShow, isFromOnPageShow);

      mockKit.verify("setTaskForeground", [isShow]).never();

      mockKit.clear(callRecordPresenter.limitRefreshInit);
    })

    it('CallRecordPresenterTest_setPageShow_isShow_false', 0, () => {
      let isShow: boolean = false;
      let isFromOnPageShow: boolean = false;
      callRecordPresenter.isShow = true;

      mockKit.mockFunc(callRecordPresenter.limitRefreshInit, callRecordPresenter.limitDataRefresh?.setTaskForeground);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.startInit);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.cancelMissedCallNotification);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setTabShow);

      callRecordPresenter.setPageShow(isShow, isFromOnPageShow);

      mockKit.verify("startInit", []).never();
      mockKit.verify('cancelMissedCallNotification', []).never();
      mockKit.verify('setTabShow', []).once();

      mockKit.clear(callRecordPresenter.limitRefreshInit);
      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_setPageShow_isShow_true_isFromOnPageShow_true', 0, () => {
      let isShow: boolean = true;
      let isFromOnPageShow: boolean = true;
      callRecordPresenter.isShow = false;

      mockKit.mockFunc(callRecordPresenter.limitRefreshInit, callRecordPresenter.limitDataRefresh?.setTaskForeground);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.startInit);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.cancelMissedCallNotification);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setTabShow);

      callRecordPresenter.setPageShow(isShow, isFromOnPageShow);

      mockKit.verify("startInit", []).once();
      mockKit.verify('cancelMissedCallNotification', []).never();
      mockKit.verify('setTabShow', []).once();

      mockKit.clear(callRecordPresenter.limitRefreshInit);
      mockKit.clear(callRecordPresenter);

    })

    it('CallRecordPresenterTest_setPageShow_isShow_true_isFromOnPageShow_false', 0, () => {
      let isShow: boolean = true;
      let isFromOnPageShow: boolean = false;
      callRecordPresenter.isShow = false;

      mockKit.mockFunc(callRecordPresenter.limitRefreshInit, callRecordPresenter.limitDataRefresh?.setTaskForeground);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.startInit);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.cancelMissedCallNotification);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setTabShow);

      callRecordPresenter.setPageShow(isShow, isFromOnPageShow);

      mockKit.verify("startInit", []).once();
      mockKit.verify('cancelMissedCallNotification', []).once();
      mockKit.verify('setTabShow', []).once();

      mockKit.clear(callRecordPresenter.limitRefreshInit);
      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_setInterceptionCallsPageShow_if1', 0, () => {
      callRecordPresenter.isInterceptionCallRecordShow = false;

      mockKit.mockFunc(callRecordPresenter.limitInterceptionCallsDataRefresh,
        callRecordPresenter.limitInterceptionCallsDataRefresh?.setTaskForeground);

      callRecordPresenter.setInterceptionCallsPageShow(false);

      mockKit.verify('setTaskForeground', [false]).never();
    })

    it('CallRecordPresenterTest_setInterceptionCallsPageShow_true', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(callRecordPresenter, callRecordPresenter.updateInterceptionCallLogDataCreateTime);
      mockKit.mockFunc(callRecordPresenter.limitInterceptionCallsDataRefresh,
        callRecordPresenter.limitInterceptionCallsDataRefresh?.setTaskForeground);
      mockKit.mockFunc(callRecordPresenter.mInterceptionCallRecordListDataSource,
        callRecordPresenter.mInterceptionCallRecordListDataSource.setIsShow);
      callRecordPresenter.isInterceptionCallRecordShow = false;
      callRecordPresenter.setInterceptionCallsPageShow(true);
      mocker.verify('updateInterceptionCallLogDataCreateTime', []).once();
      mocker.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_limitInterceptionCallsDataRefresh_resultCallBack_if', 0, () => {
      mockKit.mockFunc(callRecordPresenter.mInterceptionCallRecordListDataSource, callRecordPresenter.mInterceptionCallRecordListDataSource.refresh);

      let callLogList: Array<MergedCallLog> = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '570977632')))];
      let result: boolean | undefined = callRecordPresenter.limitInterceptionCallsDataRefresh?.getResultCallBack()(1, 1, {
        callLogList: callLogList,
        missedList: callLogList,
        timeStamp: '',
        isEnd: false
      } as CallInfoGetParamsInCallback);

      expect(result).assertUndefined();
      mockKit.verify('refresh', [0, callLogList, false]).never();

      mockKit.clear(callRecordPresenter.mInterceptionCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_setInterceptionCallsPageShow_noIf1_noIf2', 0, () => {
      callRecordPresenter.isInterceptionCallRecordShow = true;

      mockKit.mockFunc(callRecordPresenter.limitInterceptionCallsDataRefresh,
        callRecordPresenter.limitInterceptionCallsDataRefresh?.setTaskForeground);
      mockKit.mockFunc(callRecordPresenter.mInterceptionCallRecordListDataSource,
        callRecordPresenter.mInterceptionCallRecordListDataSource.setIsShow);

      callRecordPresenter.setInterceptionCallsPageShow(false);

      mockKit.verify('setIsShow', [true]).never();
    })

    it('CallRecordPresenterTest_aboutToAppear', 0, () => {
      let callLogRepoInstance: CallLogRepository = CallLogRepository.getInstance();
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.startInit);
      mockKit.mockFunc(callLogRepoInstance, callLogRepoInstance.registerDataChangeObserver);
      mockKit.mockFunc(callLogRepoInstance, callLogRepoInstance.registerSettingDataChangeObserver);

      callRecordPresenter.aboutToAppear();

      mockKit.verify("registerDataChangeObserver", [callRecordPresenter.onCallsChange]).once();
      mockKit.verify("registerDataChangeObserver", [ContactListPresenter.getInstance().onContactChange]).once();
      mockKit.verify("registerSettingDataChangeObserver", [callRecordPresenter.onCallsLogChange]).once();

      mockKit.clear(callRecordPresenter);
      mockKit.clear(callLogRepoInstance);
    })

    it('CallRecordPresenterTest_registerInterceptionCallsDataChangeObserver', 0, () => {
      mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().registerDataChangeObserver);

      callRecordPresenter.registerInterceptionCallsDataChangeObserver();

      expect(callRecordPresenter.debounceTimer).assertNull();

      mockKit.clear(CallLogRepository.getInstance());
    })

    it('CallRecordPresenterTest_unRegisterInterceptionCallsDataChangeObserver', 0, () => {
      mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().unRegisterDataChangeObserver);

      callRecordPresenter.unRegisterInterceptionCallsDataChangeObserver();

      expect(callRecordPresenter.initStarted).assertFalse();

      mockKit.clear(CallLogRepository.getInstance());
    })

    it('CallRecordPresenterTest_aboutToDisappear', 0, () => {
      let callLogRepoInstance: CallLogRepository = CallLogRepository.getInstance();
      mockKit.mockFunc(callLogRepoInstance, callLogRepoInstance.unRegisterSettingDataChangeObserver);

      callRecordPresenter.aboutToDisappear();

      mockKit.verify("unRegisterSettingDataChangeObserver", [callRecordPresenter.onCallsLogChange]).once();
      mockKit.verify("unRegisterSettingDataChangeObserver", [callRecordPresenter.onCallsChange]).once();

      mockKit.clear(callLogRepoInstance);
    })

    it('CallRecordPresenterTest_aboutToDisappear_02', 0, () => {
      callRecordPresenter.appearNumber = 2;

      callRecordPresenter.aboutToDisappear();

      expect(callRecordPresenter.appearNumber).assertEqual(1);
    })

    it('CallRecordPresenterTest_setTabShow_01_01', 0, () => {
      callRecordPresenter.isShow = true
      callRecordPresenter.tabIndex = 0

      mockKit.mockFunc(callRecordPresenter.mMissCallRecordListDataSource,
        callRecordPresenter.mMissCallRecordListDataSource.setIsShow)
      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource,
        callRecordPresenter.mAllCallRecordListDataSource.setIsShow)

      callRecordPresenter.setTabShow();

      mockKit.verify("setIsShow", [false]).once()
      mockKit.verify("setIsShow", [true]).once()

      mockKit.clear(callRecordPresenter.mMissCallRecordListDataSource);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
      mockKit.clear(callRecordPresenter);

    })

    it('CallRecordPresenterTest_setTabShow_01_02', 0, () => {
      callRecordPresenter.isShow = true
      callRecordPresenter.tabIndex = 1

      mockKit.mockFunc(callRecordPresenter.mMissCallRecordListDataSource,
        callRecordPresenter.mMissCallRecordListDataSource.setIsShow)
      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource,
        callRecordPresenter.mAllCallRecordListDataSource.setIsShow)

      callRecordPresenter.setTabShow();

      mockKit.verify("setIsShow", [true]).once()
      mockKit.verify("setIsShow", [false]).once()

      mockKit.clear(callRecordPresenter.mMissCallRecordListDataSource);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_setTabShow_02', 0, () => {
      callRecordPresenter.isShow = false
      mockKit.mockFunc(callRecordPresenter.mMissCallRecordListDataSource,
        callRecordPresenter.mMissCallRecordListDataSource.setIsShow)
      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource,
        callRecordPresenter.mAllCallRecordListDataSource.setIsShow)

      callRecordPresenter.setTabShow();

      mockKit.verify("setIsShow", [false]).times(2)

      mockKit.clear(callRecordPresenter.mMissCallRecordListDataSource);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_setTabIndex', 0, () => {
      callRecordPresenter.tabIndex = 0;

      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setTabShow)
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setMoreMenuStatus)
      callRecordPresenter.setTabIndex(1);
      mockKit.verify("setTabShow", []).once()
      mockKit.verify("setMoreMenuStatus", []).once()

      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_setTabIndex_tabIndex_0', 0, () => {
      callRecordPresenter.tabIndex = 0;

      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setTabShow);
      mockKit.mockFunc(callRecordPresenter, callRecordPresenter.setMoreMenuStatus);

      callRecordPresenter.setTabIndex(0);

      mockKit.verify("setTabShow", []).never();
      mockKit.verify("setMoreMenuStatus", []).never();

      mockKit.clear(callRecordPresenter);
    })

    it('CallRecordPresenterTest_setMoreMenuStatus_01', 0, () => {
      let mockFun1: Function = mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mAllCallRecordListDataSource.totalCount)
      when(mockFun1)().afterReturn(10)
      callRecordPresenter.tabIndex = 0;

      callRecordPresenter.setMoreMenuStatus()

      expect(AppStorage.get("hasCallRecord")).assertTrue();

      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_setMoreMenuStatus_02', 0, () => {
      let mockFun1: Function = mockKit.mockFunc(callRecordPresenter.mMissCallRecordListDataSource, callRecordPresenter.mMissCallRecordListDataSource.totalCount)
      when(mockFun1)().afterReturn(10)
      callRecordPresenter.tabIndex = 1;

      callRecordPresenter.setMoreMenuStatus()

      expect(AppStorage.get("hasCallRecord")).assertTrue();

      mockKit.clear(callRecordPresenter.mMissCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_setMoreMenuStatus_03', 0, () => {
      callRecordPresenter.tabIndex = -1;

      callRecordPresenter.setMoreMenuStatus()

      expect(AppStorage.get("hasCallRecord")).assertFalse();
    })

    it('CallRecordPresenterTest_requestItem', 0, () => {
      mockKit.mockFunc(callRecordPresenter.limitRefreshInit, callRecordPresenter.limitDataRefresh?.requestItem)
      callRecordPresenter.requestItem();
      mockKit.verify('requestItem', []).never();

      mockKit.clear(callRecordPresenter.limitRefreshInit);
    })

    it('CallRecordPresenterTest_requestInterceptionCallsItem', 0, () => {
      mockKit.mockFunc(callRecordPresenter.limitInterceptionCallsDataRefresh, callRecordPresenter.limitInterceptionCallsDataRefresh?.requestItem)

      mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().markInterceptionMissedCallsAsRead);
      callRecordPresenter.requestInterceptionCallsItem(false);

      mockKit.verify('markInterceptionMissedCallsAsRead', []).once()

      mockKit.clear(CallLogRepository.getInstance());
    })

    it('CallRecordPresenterTest_dialing', 0, () => {
      let phoneNumber: string = '570977632';
      let options: call.DialOptions = {
        extras: false,
        accountId: 1,
        videoState: 0,
        dialScene: 0,
        dialType: 0
      };

      callRecordPresenter.dialing(phoneNumber, options);
      expect(callRecordPresenter.interceptionCallRecordChange).assertEqual(1);
    })

    it('CallRecordPresenterTest_deleteCallLog_index_0', 0, () => {
      let result = false;

      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);

      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mockKit.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteCallLogsById').afterAction(() => {
        result = true;
      });

      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mAllCallRecordListDataSource.remove);

      callRecordPresenter.deleteCallLog([], [], 0);

      expect(result).assertTrue();
      mockKit.verify('remove', [0]).once();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(workerWrapper);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_deleteCallLog_index_1', 0, () => {
      let result = false;

      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mockKit.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteCallLogsById').afterAction(() => {
        result = true;
      });

      callRecordPresenter.tabIndex = 1;

      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mMissCallRecordListDataSource.remove);

      callRecordPresenter.deleteCallLog([], [], 1);

      expect(result).assertTrue();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(workerWrapper);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_deleteCallLog_index_undefined', 0, () => {
      let result = false;

      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mockKit.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('deleteCallLogsById').afterAction(() => {
        result = true;
      });

      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mMissCallRecordListDataSource.remove);

      callRecordPresenter.tabIndex = 1;

      callRecordPresenter.deleteCallLog([], []);

      expect(result).assertTrue();
      mockKit.verify('remove', [1]).never();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(workerWrapper);
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_deleteCallLog_index_0_callback', 0, () => {
      let result = false;

      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
              return new Promise<number>(resolve => resolve(1));
            }
          } as dataShare.DataShareHelper))
        });

      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mAllCallRecordListDataSource.remove);

      callRecordPresenter.deleteCallLog([], [], 0);

      expect(result).assertFalse();
      mockKit.verify('remove', [0]).once();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(CallLogRepository.getInstance());
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);

    })

    it('CallRecordPresenterTest_deleteCallLog_index_1_callback', 0, () => {
      let result = false;

      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
              return new Promise<number>(resolve => resolve(1));
            }
          } as dataShare.DataShareHelper))
        });

      mockKit.mockFunc(callRecordPresenter.mAllCallRecordListDataSource, callRecordPresenter.mMissCallRecordListDataSource.remove);

      callRecordPresenter.deleteCallLog([], [], 1);

      expect(result).assertFalse();
      mockKit.verify('remove', [1]).once();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(CallLogRepository.getInstance());
      mockKit.clear(callRecordPresenter.mAllCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_deleteInterceptionCallLog_if', 0, () => {
      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
              return new Promise<number>(resolve => resolve(1));
            }
          } as dataShare.DataShareHelper))
        });

      mockKit.mockFunc(callRecordPresenter.mInterceptionCallRecordListDataSource, callRecordPresenter.mInterceptionCallRecordListDataSource.remove);

      callRecordPresenter.deleteInterceptionCallLog([], 1);

      mockKit.verify('remove', [1]).once();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(CallLogRepository.getInstance());
      mockKit.clear(callRecordPresenter.mInterceptionCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_deleteInterceptionCallLog_noIf', 0, () => {
      let mockFunc: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mockKit.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
              return new Promise<number>(resolve => resolve(1));
            }
          } as dataShare.DataShareHelper))
        });

      mockKit.mockFunc(callRecordPresenter.mInterceptionCallRecordListDataSource, callRecordPresenter.mInterceptionCallRecordListDataSource.remove);

      callRecordPresenter.deleteInterceptionCallLog([]);

      mockKit.verify('remove', [1]).never();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mockKit.clear(CallLogRepository.getInstance());
      mockKit.clear(callRecordPresenter.mInterceptionCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_cancelMissedCallNotification_tele_number_empty', 0, () => {
      AppStorage.SetOrCreate("tele_number", '');

      mockKit.mockFunc(missedCallManager, missedCallManager.cancelNotification);

      callRecordPresenter.cancelMissedCallNotification();

      mockKit.verify('cancelNotification', []).once();

      mockKit.clear(missedCallManager);
    })

    it('CallRecordPresenterTest_cancelMissedCallNotification_tele_number_notEmpty', 0, () => {
      AppStorage.SetOrCreate("tele_number", '570977632');

      mockKit.mockFunc(missedCallManager, missedCallManager.cancelNotification);

      callRecordPresenter.cancelMissedCallNotification();

      mockKit.verify('cancelNotification', []).never();
      mockKit.clear(missedCallManager);
    })

    it('CallRecordPresenterTest_jumpToContactDetail_01', 0, () => {
      let phoneNumber = "16988548546"
      let isMarked = true
      let markType = '0'
      let markCount = 0;
      let markSource = ''
      let isCloud = false;
      let markContent = ''
      let markDetails = ''
      let isYellowPage = false
      let isPrivateNumber = false
      let quickSearchKey = ''
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
      callRecordPresenter.pathInfos = new NavPathStack();
      callRecordPresenter.pathInfos.pushPathByName('ContactDetail', '');

      callRecordPresenter.jumpToContactDetail(phoneNumber, isMarked, markType, markCount, markSource, isCloud,
        markContent, markDetails, isYellowPage, isPrivateNumber);

      expect(callRecordPresenter.pathInfos.getAllPathName().toString()).assertEqual(['ContactDetail'].toString())
      expect(JSON.stringify(callRecordPresenter.pathInfos.getParamByIndex(0))).assertEqual(JSON.stringify(params))
    })

    it('CallRecordPresenterTest_jumpToContactDetail_02', 0, () => {
      let phoneNumber = "16988548546"
      let isMarked = true
      let markType = '0'
      let markCount = 0;
      let markSource = ''
      let isCloud = false;
      let markContent = ''
      let markDetails = ''
      let isYellowPage = false
      let isPrivateNumber = false
      let quickSearchKey = ''
      const params: Record<string, boolean | string> = {
        "sourceHasPhone": true,
        "phoneNumberShow": phoneNumber
      };
      callRecordPresenter.pathInfos = new NavPathStack();

      callRecordPresenter.jumpToContactDetail(phoneNumber, isMarked, markType, markCount, markSource, isCloud,
        markContent, markDetails, isYellowPage, isPrivateNumber);

      expect(callRecordPresenter.pathInfos.getAllPathName().toString()).assertEqual('')
    })

    it('CallRecordPresenterTest_toDefaultPage_breakpoint_sm', 0, () => {
      AppStorage.setOrCreate('breakpoint', 'sm');
      AppStorage.setOrCreate('isShowDial', true);
      callRecordPresenter.pathInfos.clear();
      callRecordPresenter.pathInfos.pushPathByName('DialerPad', 'test', false);

      callRecordPresenter.toDefaultPage();

      expect(AppStorage.get('isShowDial')).assertEqual(true);
      expect(JSON.stringify(callRecordPresenter.pathInfos.getParamByName('DialerPad'))).assertEqual('["test"]');
    })

    it('CallRecordPresenterTest_toDefaultPage_breakpoint_sm1', 0, () => {
      AppStorage.setOrCreate('breakpoint', 'sm1');
      AppStorage.SetOrCreate('isNavigationModeSplit', true);

      callRecordPresenter.toDefaultPage();

      expect(AppStorage.get('isShowDial')).assertEqual(false);
      expect(JSON.stringify(callRecordPresenter.pathInfos.getParamByName('DialerPad'))).assertEqual('[""]');
    })

    it('CallRecordPresenterTest_toDefaultPage_return', 0, () => {
      AppStorage.setOrCreate('isShowSmartWindow', true);
      AppStorage.setOrCreate('isNavigationModeSplit', false);
      AppStorage.setOrCreate('isShowDial', true);
      let isPc: Function = mockKit.mockFunc(EnvironmentProp, EnvironmentProp.isPC);
      when(isPc)().afterReturn(false);

      callRecordPresenter.toDefaultPage();

      expect(AppStorage.get('isShowDial')).assertTrue();
      mockKit.clear(EnvironmentProp);
    })

    it('CallRecordPresenterTest_addToWhiteList', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      callRecordPresenter.addToWhiteList('570977632', (result: boolean) => {
      });

      expect(callRecordPresenter.isShow).assertFalse();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_addToWhiteList_error', 0, () => {
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterThrow('error');

      callRecordPresenter.addToWhiteList('570977632', (result: boolean) => {
        expect(result).assertFalse();
      });

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_updateToWhiteList', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      callRecordPresenter.updateToWhiteList('570977632', (result: boolean) => {
      });

      expect(callRecordPresenter.isShow).assertFalse();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_updateToWhiteList_error', 0, () => {
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterThrow('error');

      callRecordPresenter.updateToWhiteList('570977632', (result: boolean) => {
        expect(result).assertFalse();
      });

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_isInBlockList', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      callRecordPresenter.isInBlockList('570977632', (result: IsBlockContact) => {
      }, false);

      expect(callRecordPresenter.isShow).assertFalse();

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_isInBlockList_error', 0, () => {
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterThrow('error');

      callRecordPresenter.isInBlockList('570977632', (result: IsBlockContact) => {
        expect(result.isInBlock).assertFalse();
      }, false);

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_getBlockReasonResource', 0, () => {
      let builder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder.blockReason = 3;
      let item: MergedCallLog = new MergedCallLog(new CallLog(builder));
      let result: Resource | string = callRecordPresenter.getBlockReasonResource(item);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.interception_rule_blockall_title')));

      let builder1: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder1.blockReason = 1002;
      builder1.markType = '1';
      builder1.isCloudMark = 1;
      let item1: MergedCallLog = new MergedCallLog(new CallLog(builder1));
      let result1: Resource | string = callRecordPresenter.getBlockReasonResource(item1);
      expect(JSON.stringify(result1))
        .assertEqual(JSON.stringify($r('app.plural.harassment_harassing_calls_reason', item1.markCount,
          item1.markCount)));

      let builder2: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder2.blockReason = 1002;
      builder2.markType = '2';
      builder2.isCloudMark = 1;
      let item2: MergedCallLog = new MergedCallLog(new CallLog(builder2));
      let result2: Resource | string = callRecordPresenter.getBlockReasonResource(item2);
      expect(JSON.stringify(result2))
        .assertEqual(JSON.stringify($r('app.plural.harassment_scam_calls_reason', item2.markCount,
          item2.markCount)));

      let builder3: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder3.blockReason = 1002;
      builder3.markType = '3';
      let item3: MergedCallLog = new MergedCallLog(new CallLog(builder3));
      let result3: Resource | string = callRecordPresenter.getBlockReasonResource(item3);
      expect(JSON.stringify(result3))
        .assertEqual(JSON.stringify($r('app.string.number_mark_express')));

      let builder4: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder4.blockReason = 1002;
      builder4.markType = '4';
      builder4.isCloudMark = 1;
      let item4: MergedCallLog = new MergedCallLog(new CallLog(builder4));
      let result4: Resource | string = callRecordPresenter.getBlockReasonResource(item4);
      expect(JSON.stringify(result4))
        .assertEqual(JSON.stringify($r('app.string.harassment_advertising_calls_reason')));

      let builder5: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder5.blockReason = 1002;
      builder5.markType = '5';
      builder5.isCloudMark = 1;
      let item5: MergedCallLog = new MergedCallLog(new CallLog(builder5));
      let result5: Resource | string = callRecordPresenter.getBlockReasonResource(item5);
      expect(JSON.stringify(result5))
        .assertEqual(JSON.stringify($r('app.string.harassment_real_estate_calls_reason')));

      let builder6: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder6.blockReason = 1002;
      builder6.markType = '6';
      let item6: MergedCallLog = new MergedCallLog(new CallLog(builder6));
      let result6: Resource | string = callRecordPresenter.getBlockReasonResource(item6);
      expect(JSON.stringify(result6))
        .assertEqual(JSON.stringify($r('app.string.number_mark_insurance')));

      let builder7: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder7.blockReason = 1002;
      builder7.markType = '7';
      let item7: MergedCallLog = new MergedCallLog(new CallLog(builder7));
      let result7: Resource | string = callRecordPresenter.getBlockReasonResource(item7);
      expect(JSON.stringify(result7)).assertEqual(JSON.stringify($r('app.string.number_mark_taxi')));

      let builder8: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder8.blockReason = 1002;
      builder8.markType = '9';
      builder8.markContent = '11'
      let item8: MergedCallLog = new MergedCallLog(new CallLog(builder8));
      let result8: Resource | string = callRecordPresenter.getBlockReasonResource(item8);
      expect(result8).assertEqual(item8.markContent);

      let builder9: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder9.blockReason = 1002;
      builder9.markType = '77';
      let item9: MergedCallLog = new MergedCallLog(new CallLog(builder9));
      let result9: Resource | string = callRecordPresenter.getBlockReasonResource(item9);
      expect(result9).assertEqual('');
    })

    it('CallRecordPresenterTest_getBlockReasonResource_1', 0, () => {
      let builder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder.blockReason = 1;
      let item: MergedCallLog = new MergedCallLog(new CallLog(builder));

      let result: Resource | string = callRecordPresenter.getBlockReasonResource(item);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.blocklist_number')));
    })

    it('CallRecordPresenterTest_getBlockReasonResource_4', 0, () => {
      let builder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder.blockReason = 4;
      let item: MergedCallLog = new MergedCallLog(new CallLog(builder));

      let result: Resource | string = callRecordPresenter.getBlockReasonResource(item);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.unknown_phonenumber')));
    })

    it('CallRecordPresenterTest_getBlockReasonResource_5', 0, () => {
      let builder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder.blockReason = 5;
      let item: MergedCallLog = new MergedCallLog(new CallLog(builder));

      let result: Resource | string = callRecordPresenter.getBlockReasonResource(item);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.harassment_blockreason_strangenumber')));
    })

    it('CallRecordPresenterTest_getBlockReasonResource_200', 0, () => {
      let builder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      builder.blockReason = 200;
      let item: MergedCallLog = new MergedCallLog(new CallLog(builder));

      let result: Resource | string = callRecordPresenter.getBlockReasonResource(item);

      expect(result).assertEqual('');
    })

    it("CallRecordPresenterTest_createNewContact", 0, async () => {
      let phoneNumber = '13588888888'
      const params: Record<string, Record<string, string>[] | boolean> = {
        'updataShow': false,
        'phoneNumbers': [
          {
            'phoneNumber': phoneNumber
          }
        ]
      };
      callRecordPresenter.pathInfos = new NavPathStack();
      let mockFunc: Function = mockKit.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.ACCOUNTANTS).afterReturn(new Promise<string>((resolve: Function, reject: Function) => {
        resolve(callRecordPresenter.pathInfos?.pushPathByName(DynamicLoader.ACCOUNTANTS, params));
      }))
      callRecordPresenter.createNewContact(phoneNumber);

      expect(JSON.stringify(callRecordPresenter.pathInfos?.getParamByIndex(0))).assertEqual(JSON.stringify(params));
      mockKit.clear(DynamicLoader.getInstance());
    })

    it('CallRecordPresenterTest_updateBlockedCallCountByPhoneNumber_isAdd', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let blockListContact = new BlockListContact();
      blockListContact.phoneNumber = '570977632';
      blockListContact.interceptionCallCount = 0;

      callRecordPresenter.updateBlockedCallCountByPhoneNumber(context, blockListContact, true);

      mockKit.verify('updateBlockedCallCount', []).times(0);

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallRecordPresenterTest_updateBlockedCallCountByPhoneNumber_isNotAdd', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mockKit.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let blockListContact = new BlockListContact();
      blockListContact.phoneNumber = '570977632';
      blockListContact.interceptionCallCount = 1;

      callRecordPresenter.updateBlockedCallCountByPhoneNumber(context, blockListContact, false);

      mockKit.verify('updateBlockedCallCount', []).times(0);

      mockKit.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it("CallRecordPresenterTest_isInBlockOrAccessList", 0, () => {
      let phoneNumber = '13588888888'
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      callRecordPresenter.isInBlockOrAccessList([phoneNumber], 0, context, (result: boolean) => {
        expect(result).assertFalse();
      });
    })


    it("CallRecordPresenterTest_cancelBlockList", 0, () => {
      let phoneNumber = '13588888'
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      callRecordPresenter.cancelBlockList([phoneNumber], context, (result: boolean) => {
        expect(result).assertTrue();
      });
    })

    it("CallRecordPresenterTest_updateBlockList", 0, () => {
      let phoneNumber = '13588888'

      callRecordPresenter.addToBlockList([phoneNumber], '', (data: number) => {
        expect(data).not().assertEqual(-1);
      });
    })

    it('CallRecordPresenterTest_deleteCallLogItemPage', 0, () => {
      AppStorage.setOrCreate('breakpoint', 'sm');
      AppStorage.setOrCreate('isShowSmartWindow', true);
      callRecordPresenter.deleteCallLogItemPage([]);
      expect(AppStorage.get('breakpoint')).assertEqual('sm');

      AppStorage.setOrCreate('breakpoint', 'sm1');
      AppStorage.setOrCreate('isShowSmartWindow', false);
      AppStorage.setOrCreate('mainTabsIndex', 1);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(EnvironmentProp, EnvironmentProp.isPC))().afterReturn(false);
      callRecordPresenter.deleteCallLogItemPage([]);
      expect(AppStorage.get('breakpoint')).assertEqual('sm1');

      when(mocker.mockFunc(EnvironmentProp, EnvironmentProp.isPC))().afterReturn(true);
      callRecordPresenter.deleteCallLogItemPage([-1]);
      expect(AppStorage.get('isShowDial')).assertFalse();
      mocker.clear(EnvironmentProp);
    })

    it("CallRecordPresenterTest_unInstance", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      CallRecordPresenter.unInstance();
      mocker.verify('w', [TAG, 'unInstance...']).once();
      mocker.clear(HiLog);
    });

    it('CallRecordPresenterTest_creatAccountantsObj_01', 0, () => {
      let phoneNumber: string = '13801001111';
      let displayName: string = '张三';
      let phoneNumbers: Record<string, string> = {
        'phoneNumber': phoneNumber,
      };
      callRecordPresenter.creatAccountantsObj(phoneNumber, displayName);
      expect(JSON.stringify(callRecordPresenter.myAccountantsModel)).assertEqual(JSON.stringify({
          updataShow: false,
          phoneNumbers: [phoneNumbers],
          disPlayName: displayName,
          displayNameHighlight: true,
        } as SingleSelectContact));
    })

    it('CallRecordPresenterTest_creatAccountantsObj_02', 0, () => {
      let phoneNumber: string = '13801001111';
      let displayName: string = '';
      let phoneNumbers: Record<string, string> = {
        'phoneNumber': phoneNumber,
      };
      callRecordPresenter.creatAccountantsObj(phoneNumber, displayName);
      expect(JSON.stringify(callRecordPresenter.myAccountantsModel)).assertEqual(JSON.stringify({
        updataShow: false,
        phoneNumbers: [phoneNumbers],
      } as SingleSelectContact));
    })

    it('CallRecordPresenterTest_updateCallLogDataCreateTime_01', 0, () => {
      callRecordPresenter.preSysMinutesTime = Math.floor(new Date().valueOf() / 1000 / 60);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(callRecordPresenter.mMissCallRecordListDataSource,
        callRecordPresenter.mMissCallRecordListDataSource.getCallLogData);
      callRecordPresenter.updateCallLogDataCreateTime(true);
      mocker.verify('getCallLogData', []).never();
      mocker.clear(callRecordPresenter.mMissCallRecordListDataSource);
    })

    it('CallRecordPresenterTest_updateCallLogDataCreateTime_02', 0, () => {
      let callLogData: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '')));
      callLogData.createTimeSource = 1;
      let mocker: MockKit = new MockKit();
      let getCallLogData: Function = mocker.mockFunc(callRecordPresenter.mMissCallRecordListDataSource,
        callRecordPresenter.mMissCallRecordListDataSource.getCallLogData);
      when(getCallLogData)().afterReturn([callLogData]);
      mocker.mockFunc(CallLogService.getInstance(), CallLogService.getInstance().formatTime);
      callRecordPresenter.updateCallLogDataCreateTime(true);
      mocker.verify('formatTime', [1]).atMost(1);
      mocker.clear(callRecordPresenter.mMissCallRecordListDataSource);
      mocker.clear(CallLogService.getInstance());
    })
  })
}