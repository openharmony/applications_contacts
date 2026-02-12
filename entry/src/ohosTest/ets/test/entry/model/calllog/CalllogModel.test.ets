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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import CallDetail from '../../../../../../main/ets/model/bean/CallDetail';
import CalllogModel from '../../../../../../main/ets/model/calllog/CalllogModel';
import { AllCallsGetActionData } from '../../../../../../main/ets/model/type';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { CallInfoGetParamsInCallback } from '../../../../../../main/ets/model/type/ContactParams';
import MergedCallLog from '../../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallLog, CallLogRepository, CallType } from '../../../../../../../../feature/call';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { MergeRule } from '../../../../../../../../feature/call/src/main/ets/CallLogSetting';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { sharedPreferencesUtils } from '../../../../../../../../common';

export default function CalllogModelTest() {
  describe('CalllogModelTest', () => {

    /*it('CalllogModelTest_getAllCalls_resultData_isEnd_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME, favoriteForm: ''
      };
      let res = false;
      let mockFunc = mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().findAll);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        res = true;
      })
      let callBack: CallableFunction = (result: CallInfoGetParamsInCallback) => {};
      await CalllogModel.getAllCalls(actionData, callBack);
      expect(res).assertTrue();

      mocker.clear(CallLogRepository.getInstance());
    })*/

    it('CalllogModelTest_getAllCalls_resultData_isEnd_false', 0, async () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME, favoriteForm: '', page: 1, limit: 0
      };

      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('isCallSettingDataChangeGroupByValue')
        .afterReturn(new Promise<string>(resolve => resolve('notContacts')));

      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let callBack: CallableFunction = (result: CallInfoGetParamsInCallback) => {
        expect(JSON.stringify(result))
          .assertEqual('{"callLogList":[],"missedList":[],"callLogSearchList":[],"timeStamp":"","isEnd":false}');
      };

      await CalllogModel.getAllCalls(actionData, callBack);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
    })

    it('CalllogModelTest_getFirstMissedCall_result_isEmpty', 0, async () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let actionData: AllCallsGetActionData = {};
      let callBack: CallableFunction = (resultData: CallLog[]) => {
        expect(JSON.stringify(resultData)).assertEqual('[]');
      };

      await CalllogModel.getFirstMissedCall(actionData, callBack, context);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());

    })

    it('CalllogModelTest_getFirstMissedCall_result_notEmpty', 0, async () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let actionData: AllCallsGetActionData = {};
      let callBack: CallableFunction = (resultData: CallLog[]) => {
        expect(resultData[0].displayName).assertEqual('xxx');
      };

      await CalllogModel.getFirstMissedCall(actionData, callBack, context);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
    })

    it('CalllogModelTest_handleCallLogSearchList', 0, () => {
      let timeStamp: string = '2023-12:06';
      let result = false;
      let callBack: CallableFunction = (resultData: CallInfoGetParamsInCallback) => {
        result = true;
      };
      let mergedCalllogOne = new MergedCallLog(new CallLog(new CallLogBuilder(1, '18196564561')));
      let mergedCalllogTwo = new MergedCallLog(new CallLog(new CallLogBuilder(2, '11111111111')));
      let mergedCalllogThree = new MergedCallLog(new CallLog(new CallLogBuilder(3, '22222222222')));
      let data: CallInfoGetParamsInCallback = {
        callLogList: [mergedCalllogOne, mergedCalllogTwo, mergedCalllogThree],
        missedList: [mergedCalllogThree],
        callLogSearchList: [mergedCalllogOne, mergedCalllogThree],
        timeStamp: timeStamp,
        isEnd: true
      };
      CalllogModel.handleCallLogSearchList(timeStamp, callBack, data,
        data.callLogList, ['1', '2'],
        data.callLogSearchList);
      expect(result).assertTrue();
    })

    it('CalllogModelTest_handleCallLogSearchList_data_noCallLogList', 0, () => {
      let timeStamp: string = '2023-12:06';
      let result = false;
      let callBack: CallableFunction = (resultData: CallInfoGetParamsInCallback) => {
        result = true;
      };
      let mergedCalllogOne = new MergedCallLog(new CallLog(new CallLogBuilder(1, '18196564561')));
      let mergedCalllogThree = new MergedCallLog(new CallLog(new CallLogBuilder(3, '22222222222')));

      let data: CallInfoGetParamsInCallback = {
        missedList: [mergedCalllogThree],
        callLogSearchList: [mergedCalllogOne, mergedCalllogThree],
        timeStamp: timeStamp,
        isEnd: true
      } as CallInfoGetParamsInCallback;

      CalllogModel.handleCallLogSearchList(timeStamp, callBack, data,
        data.callLogList, ['1', '2'],
        data.callLogSearchList);

      expect(result).assertTrue();
    })

    /*it('CalllogModelTest_getRecorderMessage', 0, async () => {
      let callDetailList: CallDetail[] = [new CallDetail("1", "13156421235", "", "", "", CallType.IN,
        "", "", -1, 1, 1,
        "", null, 1, undefined, undefined, -1, -1, -1), new CallDetail("2", "136589745631", "", "", "", CallType.IN,
        "", "", -1, 1, 1, "", null, 1, undefined, undefined, -1, -1, -1),];

      let result = false;
      let callBack: CallableFunction = (callDetailList: CallDetail[]) => {
        result = true;
      };
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      await CalllogModel.getRecorderMessage(callDetailList, (callDetailList: CallDetail[]) => {
        callBack(callDetailList);
      });

      expect(result).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })*/

    it('CalllogModelTest_getRecorderMessage_exception', 0, async () => {
      let callDetailList: CallDetail[] = [new CallDetail("1", "13156421235", "", "", "", CallType.IN,
        "", "", -1, 0, 0,
        "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, ""), new CallDetail("2", "136589745631", "", "", "", CallType.IN,
        "", "", -1, 0, 0,
        "", null, 1, undefined, undefined, -1, -1, -1, "", "", "", "", "", -1, -1, "")];
      let result = false;
      let callBack: CallableFunction = (callDetailList: CallDetail[]) => {
        result = true;
      };
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterThrow('error');

      await CalllogModel.getRecorderMessage(callDetailList, (callDetailList: CallDetail[]) => {
        callBack(callDetailList);
      });

      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CalllogModelTest_updateContactDisplayName', 0, () => {
      let callLog: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '15566667777')));
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [callLog],
        missedList: [callLog],
        callLogSearchList: [callLog],
        timeStamp: ''
      };
      CalllogModel.updateContactDisplayName(resultData, (resultData: CallInfoGetParamsInCallback) => {
        expect(resultData.callLogList[0].phoneNumber).assertEqual('15566667777');
      }, false)
    })

    it('CalllogModelTest_updateContactDisplayName_001', 0, () => {
      let callLog: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '')));
      callLog.formatPhoneNumber = '15566667777';
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [callLog],
        missedList: [callLog],
        callLogSearchList: [callLog],
        timeStamp: ''
      };
      CalllogModel.updateContactDisplayName(resultData, (resultData: CallInfoGetParamsInCallback) => {
        expect(resultData.callLogList[0].formatPhoneNumber).assertEqual('15566667777');
      }, false)
    })

    it('CalllogModelTest_updateContactDisplayName_002', 0, () => {
      let callLog: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '')));
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [callLog],
        missedList: [callLog],
        callLogSearchList: [callLog],
        timeStamp: ''
      };
      CalllogModel.updateContactDisplayName(resultData, (resultData: CallInfoGetParamsInCallback) => {
        expect(resultData.callLogList[0].formatPhoneNumber).assertEqual('');
      }, true)
    })

    it('CalllogModelTest_updateContactDisplayName_003', 0, () => {
      let callLog: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '15566667777')));
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [callLog],
        missedList: [callLog],
        callLogSearchList: [callLog],
        timeStamp: ''
      };
      CalllogModel.updateContactDisplayName(resultData, (resultData: CallInfoGetParamsInCallback) => {
        expect(resultData.missedList[0].displayName).assertEqual('');
      }, true)
    })

    it('CalllogModelTest_updateContactDisplayName_004', 0, () => {
      let callLog: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(1, '')));
      callLog.formatPhoneNumber = '15566667777';
      let resultData: CallInfoGetParamsInCallback = {
        callLogList: [callLog],
        missedList: [callLog],
        callLogSearchList: [callLog],
        timeStamp: ''
      };
      CalllogModel.updateContactDisplayName(resultData, (resultData: CallInfoGetParamsInCallback) => {
        expect(resultData.missedList[0].displayName).assertEqual('');
      }, true)
    })
  })
}