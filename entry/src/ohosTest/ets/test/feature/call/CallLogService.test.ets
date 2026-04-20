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
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { CallType } from '../../../../../../../feature/call'
import { CallLogService } from '../../../../../../../feature/call/src/main/ets/CallLogService'
import { MergeRule } from '../../../../../../../feature/call/src/main/ets/CallLogSetting'
import CallLogBuilder from '../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder'
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog'
import { common } from '@kit.AbilityKit'
import StringFormatUtil from '../../../../../main/ets/util/StringFormatUtil'
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import resmgr from '@ohos.resourceManager';
import { CallLog } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { ResourceUtil } from '../../../../../main/ets/util/ResourceUtil'

export default function CallLogServiceTest() {
  describe('CallLogServiceTest', () => {
    let subject: CallLogService;
    let mocker: MockKit;
    const nowDateTimestamp = 1712733906938 // Value for now to mock time for test to avoid randomly failing tests
    beforeAll(() => {
    })
    beforeEach(() => {
      mocker = new MockKit();
      subject = new CallLogService();
    })
    afterEach(() => {
    })
    afterAll(() => {
    })

    it('CallLogServiceTest_getInstance', 0, () => {
      expect(typeof CallLogService.getInstance()).assertEqual(typeof subject);
    })
    it('CallLogServiceTest_init', 0, () => {
      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      subject.init(appContext);

      expect(subject.context).assertEqual(appContext);
    })

    it('CallLogServiceTest_setMergeRule', 0, () => {
      const setMergeRuleTest = MergeRule.TIME;
      subject.setMergeRule(MergeRule.TIME)
      expect(subject.getMergeRule()).assertEqual(setMergeRuleTest);

      const setMergeRuleTestCon = MergeRule.CONTACT;
      subject.setMergeRule(MergeRule.CONTACT)
      expect(subject.getMergeRule()).assertEqual(setMergeRuleTestCon);
    })

    it('CallLogServiceTest_mergeMissedCalls_passing_empty_gives_empty', 0, () => {
      const CallLogList01: Array<CallLog> = [];

      let result = subject.mergeMissedCalls(CallLogList01)

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(CallLogList01));
    })

    it('CallLogServiceTest_mergeMissedCalls_passing_call_not_missed_or_rejected_return_empty', 0, () => {
      const CallLogList01: Array<CallLog> = [new CallLog(new CallLogBuilder(1, ''))];
      const CallLogList02: Array<MergedCallLog> = [];
      CallLogList01[0].callType = CallType.IN

      let result = subject.mergeMissedCalls(CallLogList01)

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(CallLogList02));
    })

    it('CallLogServiceTest_mergeMissedCalls_list_all_types', 0, () => {
      let callLogList: Array<CallLog> = [
        new CallLog(new CallLogBuilder(1, '1')),
        new CallLog(new CallLogBuilder(2, '2')),
        new CallLog(new CallLogBuilder(3, '3')),
        new CallLog(new CallLogBuilder(4, '2')),
        new CallLog(new CallLogBuilder(5, '2')),
        new CallLog(new CallLogBuilder(6, '5'))]
      callLogList[0].callType = CallType.MISSED
      callLogList[1].callType = CallType.IN
      callLogList[2].callType = CallType.REJECTED
      callLogList[3].callType = CallType.IN
      callLogList[4].callType = CallType.IN
      callLogList[5].callType = CallType.OUT
      let mergeCallLogList: Array<MergedCallLog> = [new MergedCallLog(callLogList[0]), new MergedCallLog(callLogList[2])];
      mergeCallLogList[0].ids.push(1)
      mergeCallLogList[0].createTime = '1970/1/1'
      mergeCallLogList[0].count = 1
      mergeCallLogList[0].createTimeSource = -1
      mergeCallLogList[1].ids.push(3)
      mergeCallLogList[1].createTime = '1970/1/1'
      mergeCallLogList[1].count = 1
      mergeCallLogList[1].createTimeSource = -1

      let result = subject.mergeMissedCalls(callLogList)

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(mergeCallLogList))
    })

    it('CallLogServiceTest_mergeMissedCalls_mergeRule_contact', 0, () => {
      subject.setMergeRule(MergeRule.CONTACT)
      let builder1 = new CallLogBuilder(1, '1')
      builder1.createTime = 1712231411 - 10000000
      let builder2 = new CallLogBuilder(2, '2')
      builder2.createTime = 1712231411 - 9000000
      let builder3 = new CallLogBuilder(6, '5')
      builder3.createTime = 1712231499 - 9000000
      let builder4 = new CallLogBuilder(7, '7')
      builder4.createTime = 1712231411 - 10000000
      let callLogList: Array<CallLog> = [
        new CallLog(builder1),
        new CallLog(new CallLogBuilder(2, '2')),
        new CallLog(builder2),
        new CallLog(new CallLogBuilder(4, '2')),
        new CallLog(new CallLogBuilder(5, '2')),
        new CallLog(builder3),
        new CallLog(builder4)]
      callLogList[0].callType = CallType.MISSED
      callLogList[1].callType = CallType.IN
      callLogList[2].callType = CallType.REJECTED
      callLogList[3].callType = CallType.IN
      callLogList[4].callType = CallType.OUT
      callLogList[5].callType = CallType.OUT
      callLogList[6].callType = CallType.MISSED
      let mergeCallLogList: Array<MergedCallLog> = [
        new MergedCallLog(callLogList[0]),
        new MergedCallLog(callLogList[2]),
        new MergedCallLog(callLogList[6])];
      mergeCallLogList[0].ids.push(1)
      mergeCallLogList[0].createTime = '2023/12/11'
      mergeCallLogList[0].count = 1
      mergeCallLogList[0].createTimeSource = 1702231411
      mergeCallLogList[1].ids.push(2)
      mergeCallLogList[1].createTime = '2023/12/22'
      mergeCallLogList[1].count = 1
      mergeCallLogList[1].createTimeSource = 1703231411
      mergeCallLogList[2].ids.push(7)
      mergeCallLogList[2].createTime = '2023/12/11'
      mergeCallLogList[2].count = 1
      mergeCallLogList[2].createTimeSource = 1702231411

      let result = subject.mergeMissedCalls(callLogList)

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(mergeCallLogList))
    })
    it('CallLogServiceTest_displayInterceptionCallsTime_emptyList', 0, () => {
      let callLogList: Array<CallLog> = []
      let mergeCallLogList: Array<MergedCallLog> = [];

      let resultList = subject.displayInterceptionCallsTime(callLogList)

      expect(JSON.stringify(resultList)).assertEqual(JSON.stringify(mergeCallLogList))

    })
    it('CallLogServiceTest_displayInterceptionCallsTime', 0, () => {
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let builder1 = new CallLogBuilder(1, '1')
      builder1.createTime = 1712231411 - 10000000
      let builder2 = new CallLogBuilder(2, '2')
      builder2.createTime = 1712231411 - 9000000
      let callLogList: Array<CallLog> = [
        new CallLog(builder1),
        new CallLog(builder2)]
      callLogList[0].callType = CallType.MISSED
      callLogList[1].callType = CallType.IN
      let mergeCallLogList: Array<MergedCallLog> = [
        new MergedCallLog(callLogList[0]),
        new MergedCallLog(callLogList[1])];
      mergeCallLogList[0].createTime = "2023/12/11"
      mergeCallLogList[0].createInterceptionTime = testString
      mergeCallLogList[0].formattedNumber = '';
      mergeCallLogList[0].createTimeSource = 1702231411;
      mergeCallLogList[0].createInterceptionTimeType = '2';
      mergeCallLogList[1].createTime = "2023/12/22"
      mergeCallLogList[1].createInterceptionTime = testString
      mergeCallLogList[1].formattedNumber = '';
      mergeCallLogList[1].createTimeSource = 1703231411;
      mergeCallLogList[1].createInterceptionTimeType = '2';

      let resultList = subject.displayInterceptionCallsTime(callLogList)

      expect(JSON.stringify(resultList)).assertEqual(JSON.stringify(mergeCallLogList));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());

    })
    it('CallLogServiceTest_mergeByTime00', 0, () => {
      const CallLogList01: Array<CallLog> = [];
      const CallLogList02: MergedCallLog[] = [];

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(subject, subject.mergeByTime)
      when(mocMergeData)(CallLogList01).afterReturn([])

      let CallData = subject.mergeByTime(CallLogList01)
      expect(JSON.stringify(CallData)).assertEqual(JSON.stringify(CallLogList02));
      mocker.clear(subject);
    })

    it('CallLogServiceTest_mergeByTime01', 0, () => {
      const CallLogList01: Array<CallLog> = [new CallLog(new CallLogBuilder(1, ''))];
      const CallLogList02 = 0;

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(subject, subject.mergeByTime)
      when(mocMergeData)(CallLogList01).afterReturn(0)

      let mocMergeCheck: Function = mocker.mockFunc(subject, subject.callLogMergeCheck)
      when(mocMergeCheck)([new MergedCallLog(CallLogList01[0]), CallLogList01[0]]).afterReturn(true)

      let CallData = subject.mergeByTime(CallLogList01)
      expect(CallData).assertEqual(CallLogList02);
      mocker.clear(subject);
    })
    it('CallLogServiceTest_mergeByTime02', 0, () => {
      const CallLogList01: Array<CallLog> = [new CallLog(new CallLogBuilder(1, ''))];
      const CallLogList02 = 0;
      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(subject, subject.mergeByTime)
      when(mocMergeData)(CallLogList01).afterReturn(0)
      let mocMergeCheck: Function = mocker.mockFunc(subject, subject.callLogMergeCheck)
      when(mocMergeCheck)([new MergedCallLog(CallLogList01[0]), CallLogList01[0]]).afterReturn(false)
      let CallData = subject.mergeByTime(CallLogList01)
      expect(CallData).assertEqual(CallLogList02);
      mocker.clear(subject);
    })

    it('CallLogServiceTest_formatTime_nan', 0, () => {
      const dateInput = Number.NaN

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(result).assertNaN()
    })

    it('CallLogServiceTest_formatTime_fulldate', 0, () => {
      const dateInput = 699950210657;

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(result).assertEqual("24150/7/16");
    })

    it('CallLogServiceTest_formatTime_now', 0, () => {
      let dateInput = nowDateTimestamp / 1000;

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.justNow')));
    })
    it('CallLogServiceTest_formatTime_minutes_ago', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - 60;

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(JSON.stringify(result))
        .assertEqual(JSON.stringify(ResourceUtil.getPluralStringByResource($r('app.plural.minutesAgo'), 1)));
    })
    it('CallLogServiceTest_formatTime_hour_ago_24clock', 0, () => {
      const dateInput = nowDateTimestamp / 1000 - 3601;
      let callTime = new Date(dateInput * 1000);

      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      subject.init(appContext)

      let expectResult = "getDAyMessage"
      let mockJudgeSystemTime = mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime)
      when(mockJudgeSystemTime)(appContext).afterReturn("24")

      let mockGetDayMessage = mocker.mockFunc(StringFormatUtil, StringFormatUtil.getDayMessage)
      when(mockGetDayMessage)(callTime.getHours()).afterReturn(expectResult)

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))
      let hour = callTime.getHours();
      let minutes = callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes().toString();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(StringFormatUtil.getDayMessage))
      mocker.clear(StringFormatUtil);
    })
    it('CallLogServiceTest_formatTime_hour_ago_24clock_single_minutes', 0, () => {
      const now = 1712732559000
      const dateInput = now / 1000 - 3601;
      let callTime = new Date(dateInput * 1000);

      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      subject.init(appContext)

      let expectResult = "getDAyMessage"
      let mockJudgeSystemTime = mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime)
      when(mockJudgeSystemTime)(appContext).afterReturn("24")

      let mockGetDayMessage = mocker.mockFunc(StringFormatUtil, StringFormatUtil.getDayMessage)
      when(mockGetDayMessage)(callTime.getHours()).afterReturn(expectResult)

      let result = subject.formatTime(dateInput, new Date(now))
      let hour = callTime.getHours();
      let minutes = callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes().toString();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(StringFormatUtil.getDayMessage));
      mocker.clear(StringFormatUtil);
    })
    it('CallLogServiceTest_formatTime_yesterday', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 24) - 100;

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.yesterday')));
    })
    it('CallLogServiceTest_formatTime_more_than_one_day', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 48) - 100;
      let callTime = new Date(dateInput * 1000);

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(result).assertEqual((callTime.getMonth() + 1) + '/' + callTime.getDate());
    })
    it('CallLogServiceTest_formatTime_more_than_month', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 24 * 31) - 100;
      let callTime = new Date(dateInput * 1000)

      let result = subject.formatTime(dateInput, new Date(nowDateTimestamp))

      expect(result).assertEqual((callTime.getMonth() + 1) + '/' + callTime.getDate());
    })
    it('CallLogServiceTest_callLogMergeCheck00', 0, () => {
      const CallLogData01 = new CallLog(new CallLogBuilder(1, '11111'));
      const CallLogData02 = new MergedCallLog(CallLogData01);
      const CallLogData03 = true;

      CallLogData02.phoneNumber = '11111'
      CallLogData01.callType = CallType.MISSED
      CallLogData02.callType = CallType.MISSED
      let CallData = subject.callLogMergeCheck(CallLogData02, CallLogData01)
      expect(CallData).assertEqual(CallLogData03);

      CallLogData01.callType = CallType.IN
      CallLogData02.callType = CallType.IN
      CallData = subject.callLogMergeCheck(CallLogData02, CallLogData01)
      expect(CallData).assertEqual(CallLogData03);

      subject.mergeRule = MergeRule.CONTACT;
      CallLogData02.phoneNumber = '13801001234'
      CallLogData01.callType = CallType.MISSED
      CallLogData02.callType = CallType.IN
      expect(subject.callLogMergeCheck(CallLogData02, CallLogData01)).assertEqual(false);
    })
    it('CallLogServiceTest_callLogMergeCheck01', 0, () => {
      const CallLogData01 = new CallLog(new CallLogBuilder(1, '11111'));
      const CallLogData02 = new MergedCallLog(CallLogData01);
      const CallLogData03 = false;

      CallLogData02.phoneNumber = '222222'
      CallLogData01.callType = CallType.MISSED
      CallLogData02.callType = CallType.IN
      let CallData = subject.callLogMergeCheck(CallLogData02, CallLogData01)
      expect(CallData).assertEqual(CallLogData03);

      CallLogData02.phoneNumber = '444444'
      CallData = subject.callLogMergeCheck(CallLogData02, CallLogData01)
      expect(CallData).assertEqual(CallLogData03);
    })
    it('CallLogServiceTest_getMergeRule', 0, () => {
      const CallLogData01 = MergeRule.TIME;

      subject.setMergeRule(MergeRule.TIME);
      let CallData = subject.getMergeRule()
      expect(CallData).assertEqual(CallLogData01);
    })
    it('CallLogServiceTest_mergeCallLogs_1', 0, () => {
      let callLogs: CallLog[] = [new CallLog(new CallLogBuilder(123, "456"))]
      let mockedFun: Function = mocker.mockFunc(subject, subject.mergeByTime)
      when(mockedFun)(callLogs).afterReturn(callLogs);

      let result = subject.mergeCallLogs(callLogs);

      mocker.verify("mergeByTime", [callLogs]).once();
      expect(result).assertEqual(callLogs);
      mocker.clear(subject);
    })
    it('CallLogServiceTest_mergeCallLogs_2', 0, () => {
      const CallLogData01: CallLog[] = [new CallLog(new CallLogBuilder(1, ''))];
      const CallLogData02 = true;

      let mocker: MockKit = new MockKit();
      const merLog: Function = mocker.mockFunc(subject, subject.mergeCallLogs)
      when(merLog)(CallLogData01).afterReturn(true)
      let CallData = subject.mergeCallLogs(CallLogData01)
      expect(CallData).assertEqual(CallLogData02);
      mocker.clear(subject);
    })
    it('CallLogServiceTest_formatInterceptionCallsTime', 0, () => {
      let result = subject.formatInterceptionCallsTime(NaN,1,1)
      expect(result).assertEqual(JSON.stringify(NaN));
    })
    it('CallLogServiceTest_updatePreCallLog', 0, () => {
      let callLogData: CallLog[] = [
        new CallLog(new CallLogBuilder(1, '123456')),
        new CallLog(new CallLogBuilder(2, '456789')),
        new CallLog(new CallLogBuilder(2, '456789')),
      ];
      let callLogDataExpect: CallLog[] = [
        new CallLog(new CallLogBuilder(1, '123456'))
      ];
      let preCallLogExpect: CallLog[] = [
        new CallLog(new CallLogBuilder(2, '456789')),
        new CallLog(new CallLogBuilder(2, '456789')),
      ];

      subject.updatePreCallLog(callLogData)

      expect(JSON.stringify(callLogData)).assertEqual(JSON.stringify(callLogDataExpect));
      expect(JSON.stringify(subject.preCallLog)).assertEqual(JSON.stringify(preCallLogExpect));
    })
    it('createInterceptionGroupTime_dateInput_isNaN', 0, () => {
      const dateInput = Number.NaN
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp)

      expect(JSON.stringify(result)).assertEqual(JSON.stringify("null"));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('createInterceptionGroupTime_dateInput_now', 0, () => {
      let dateInput = nowDateTimestamp / 1000 + 2000;
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp, new Date(nowDateTimestamp))

      expect(result).assertEqual("2024/4/10");
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('createInterceptionGroupTime_dateInput_today', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 2);
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp, new Date(nowDateTimestamp))

      expect(result).assertEqual(testString);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('createInterceptionGroupTime_dateInput_yesterday', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 25);
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp, new Date(nowDateTimestamp))

      expect(result).assertEqual("2024/4/9");
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('createInterceptionGroupTime_dateInput_this_week', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 70)
      let callTime = new Date(dateInput * 1000)
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp, new Date(nowDateTimestamp))

      expect(result).assertEqual(callTime.getFullYear() + '/' + (callTime.getMonth() + 1) + '/' + callTime.getDate());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    it('createInterceptionGroupTime_dateInput_week_ago', 0, () => {
      let dateInput = nowDateTimestamp / 1000 - (3600 * 24 * 8)
      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = subject.createInterceptionGroupTime(dateInput, nowDateTimestamp, new Date(nowDateTimestamp))

      expect(result).assertEqual(testString);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CallLogServiceTest_callLogContactMergeCheck', 0, () => {
      let oldElement: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(-1 , '')))
      let newElement: CallLog = new CallLog(new CallLogBuilder(-1, ''));
      let result = CallLogService.getInstance().callLogContactMergeCheck(oldElement, newElement);
      expect(result).assertEqual(true);
    })

    it('CallLogServiceTest_getAccessibilityTextByTime', 0, () => {
      let callTime = new Date().getTime();
      let result = StringFormatUtil.getAccessibilityTextByTime(callTime / 1000);
      expect(result).assertEqual('');
    })
  })
}