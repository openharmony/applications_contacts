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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { MissedCallNotifier } from '../../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import { MissedCallService } from '../../../../../../../../feature/call/src/main/ets/missedcall/MissedCallService';
import { CallLogRepository } from '../../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { MissedCallNotifyData } from '../../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier'
import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility';
import { dataShare, dataSharePredicates, DataShareResultSet, preferences } from '@kit.ArkData';
import { sharedPreferencesUtils } from '../../../../../../../../common';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
import { CallLog } from '../../../../../../../../feature/call/src/main/ets/entity/CallLog'
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';

export default function MissedCallServiceTest() {
  const TAG = 'MissedCallService';
  describe('MissedCallServiceTest', () => {
    let missedCallService: MissedCallService;

    beforeEach(() => {
      missedCallService = MissedCallService.getInstance();
    })

    it('MissedCallServiceTest_getInstance', 0, () => {
      expect(typeof missedCallService).assertEqual(typeof MissedCallService.getInstance());
    })

    it('MissedCallServiceTest_cancelMissedNotificationAction', 0, async () => {
      let data: MissedCallNotifyData = new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4)
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().cancelNotificationById)
      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().markMissedCallLogAsRead)
      await missedCallService.cancelMissedNotificationAction(data);
      mocker.verify('cancelNotificationById', [1, 2]).once();
      mocker.verify('markMissedCallLogAsRead', ['phone']).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_cancelAllMissedNotificationAction', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().cancelAllNotification)
      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().markMissedCallLogAsRead)
      await missedCallService.cancelAllMissedNotificationAction();
      mocker.verify('cancelAllNotification', []).once();
      mocker.verify('markMissedCallLogAsRead', []).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_updateAllMissedCallNotifications', 0, async () => {
      let mocker: MockKit = new MockKit();
      let context: Context = new StaticSubscriberExtensionAbility().context;
      mocker.mockFunc(missedCallService, missedCallService.sendMissedCallNotify);
      await missedCallService.updateAllMissedCallNotifications(context);
      mocker.verify('sendMissedCallNotify', []).once();
      mocker.clear(missedCallService);
    })

    it('MissedCallServiceTest_updateMissedCallNotifications', 0, async () => {
      let mocker: MockKit = new MockKit();
      let context: Context = new StaticSubscriberExtensionAbility().context;
      mocker.mockFunc(missedCallService, missedCallService.getLastNotificationId);

      missedCallService.lastMissedId = -1;
      missedCallService.updateMissedCallNotifications(context);
      mocker.verify('getLastNotificationId', []).once();
      mocker.clear(missedCallService);
    })

    it('MissedCallServiceTest_updateMissedCallNotifications00', 0, async () => {
      let mocker: MockKit = new MockKit();
      let context: Context = new StaticSubscriberExtensionAbility().context;
      mocker.mockFunc(missedCallService, missedCallService.getLastNotificationId);

      missedCallService.lastMissedId = 1
      missedCallService.updateMissedCallNotifications(context);
      mocker.verify('getLastNotificationId', []).never();
      mocker.clear(missedCallService);
    })

    it('MissedCallServiceTest_registerDataChangeObserver', 0, async () => {
      const onCallLogChangedData: () => void = missedCallService.onCallLogChanged
      missedCallService.onCallLogChanged = onCallLogChangedData;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().registerDataChangeObserver)

      missedCallService.registerDataChangeObserver();
      mocker.verify('registerDataChangeObserver', [missedCallService.onCallLogChanged]).once();
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_unRegisterDataChangeObserver', 0, async () => {
      const onCallLogChangedData: () => void = missedCallService.onCallLogChanged
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().unRegisterDataChangeObserver)

      missedCallService.unRegisterDataChangeObserver();
      mocker.verify('unRegisterDataChangeObserver', [onCallLogChangedData]).once();
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_getLastNotificationId', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(getFromPreferences)('Last_Missed_id').afterReturn(new Promise<preferences.ValueType>(resolve=>resolve(1)));

      let getLastData: number = await missedCallService.getLastNotificationId();
      expect(getLastData).assertEqual(1);
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallServiceTest_setLastNotificationId', 0, () => {
      missedCallService.lastMissedId = -1;
      missedCallService.lastIncomingCallNotificationTime = -1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(missedCallService, missedCallService.unRegisterDataChangeObserver);
      let getLastData = missedCallService.setLastIdAndIncomingCallNotificationTime(2, 2);
      expect(getLastData).assertTrue();
      mocker.verify('unRegisterDataChangeObserver', []).once();

      let getLastData1 = missedCallService.setLastIdAndIncomingCallNotificationTime(1, 1);
      expect(getLastData1).assertEqual(false);
      mocker.clear(missedCallService);
    })

    it('MissedCallServiceTest_sendMissedCallNotify_if_length_0', 0, async () => {
      let mocker: MockKit = new MockKit();

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

      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.sendMissedCallNotify();
      mocker.verify('i', [TAG, `sendMissedCallNotify in lastId:`]).never();
      mocker.clear(HiLog);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_sendMissedCallNotify_if_length_1', 0, async () => {
      let mocker: MockKit = new MockKit();

      let setLastNotificationId: Function = mocker.mockFunc(missedCallService, missedCallService.setLastNotificationId);
      when(setLastNotificationId)(1).afterReturn(false);

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

      mocker.mockFunc(HiLog, HiLog.i);
      await missedCallService.sendMissedCallNotify();
      mocker.verify('i', [TAG, `sendMissedCallNotify in lastId: ${missedCallService.lastMissedId}`]).never();
      mocker.clear(HiLog);
      mocker.clear(missedCallService);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_sendMissedCallNotify_001', 0, async () => {
      let mocker: MockKit = new MockKit();

      let setLastNotificationId: Function = mocker.mockFunc(missedCallService, missedCallService.setLastIdAndIncomingCallNotificationTime);
      when(setLastNotificationId)(ArgumentMatchers.any).afterReturn(true);

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

      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.sendMissedCallNotify();
      mocker.verify('i', [TAG, `sendMissedCallNotify in lastId: ${missedCallService.lastMissedId}`]).never();
      mocker.clear(HiLog);
      mocker.clear(missedCallService);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('MissedCallServiceTest_sendMissedCallNotify_002', 0, async () => {
      let mocker: MockKit = new MockKit();

      let setLastNotificationId: Function = mocker.mockFunc(missedCallService, missedCallService.setLastIdAndIncomingCallNotificationTime);
      when(setLastNotificationId)(ArgumentMatchers.any).afterReturn(true);

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
              getString: (columnIndex: number): string => '',
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.sendMissedCallNotify();
      mocker.verify('i', [TAG, `sendMissedCallNotify in lastId: ${missedCallService.lastMissedId}`]).never();
      mocker.clear(HiLog);
      mocker.clear(missedCallService);
      mocker.clear(CallLogRepository.getInstance());
    })

    // it('MissedCallServiceTest_sendMissedCallNotify_length_1', 0, async () => {
    //   let context: common.UIAbilityContext = DTGlobalContext.getContext()
    //     .getObject("contactContext") as common.UIAbilityContext;
    //   missedCallService.init(context);
    //
    //   let mocker: MockKit = new MockKit();
    //
    //   when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
    //     .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
    //       query: (
    //         uri: string,
    //         predicates: dataSharePredicates.DataSharePredicates,
    //         columns: Array<string>
    //       ): Promise<DataShareResultSet> => {
    //         return new Promise<DataShareResultSet>(resolve => resolve({
    //           rowCount: 1,
    //           close: () => {},
    //           goToFirstRow: () => true,
    //           goToNextRow: () => false,
    //           getString: (columnIndex: number): string => 'xxx',
    //           getColumnIndex: (columnName: string): number => 1,
    //           getLong: (columnIndex: number): number =>1
    //         } as DataShareResultSet))
    //       }
    //     } as dataShare.DataShareHelper)));
    //
    //   mocker.mockFunc(HiLog, HiLog.i);
    //   missedCallService.sendMissedCallNotify();
    //   mocker.verify('i', [TAG, `sendMissedCallNotify in lastId: ${missedCallService.lastMissedId}`]).never();
    //   mocker.clear(HiLog);
    // })

    it('MissedCallServiceTest_queryContactsName_if',0,()=>{
      let callback = (Contact?: Map<string, string>)=>{
        expect(Contact?.size).assertEqual(0);
      };
      missedCallService.queryContactsName([],callback);
    });

    it('MissedCallServiceTest_getNumberMap', 0, async () => {
      let contacts: Record<string, string>[] = [{
        'displayName': 'displayName'
      }];

      let getMapData = missedCallService.getNumberMap(contacts)
      expect(JSON.stringify(getMapData)).assertEqual(JSON.stringify(new Map()));

      contacts = [{
        'displayName': 'undefined', 'detailInfo': 'displayName'
      }];
      let getMapData1 = missedCallService.getNumberMap(contacts)
      let newMapData: Map<string, string> = new Map()
      newMapData.set('displayName', 'undefined')
      expect(JSON.stringify(getMapData1)).assertEqual(JSON.stringify(newMapData));
    })

    it('MissedCallServiceTest_onCallLogChanged', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(missedCallService, missedCallService.unRegisterDataChangeObserver)
      missedCallService.onCallLogChanged();
      mocker.verify('unRegisterDataChangeObserver', []).once()

      missedCallService.lastMissedId = 1;
      mocker.mockFunc(missedCallService, missedCallService.sendMissedCallNotify)
      missedCallService.onCallLogChanged();
      mocker.verify('sendMissedCallNotify', []).once();
      mocker.clear(missedCallService);
    })

    it('MissedCallServiceTest_init', 0, () => {
      let context: Context = new StaticSubscriberExtensionAbility().context;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init)
      missedCallService.init(context);
      mocker.verify('init', []).once()
      mocker.clear(MissedCallNotifier.getInstance());
    })

    it('MissedCallServiceTest_getMissedCallNumberMarkName', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let item: CallLog = new CallLog(new CallLogBuilder(-1, '123'));
      expect(missedCallService.getMissedCallNumberMarkName(item, context)).assertEqual('123');

      let item1: CallLog = new CallLog(new CallLogBuilder(-1, '13801005555'));
      expect(missedCallService.getMissedCallNumberMarkName(item1)).assertEqual('13801005555');
    })

    it('MissedCallServiceTest_getMissedCallNumberMarkName01', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let itemBuilder = new CallLogBuilder(1, '123');
      itemBuilder.setMarkType('10');
      itemBuilder.setMarkContent('111');
      itemBuilder.setIsCloudMark(1);
      let item1: CallLog = new CallLog(itemBuilder);
      expect(missedCallService.getMissedCallNumberMarkName(item1, context)).assertEqual(itemBuilder.markContent);

      itemBuilder.setMarkType('9');
      itemBuilder.setMarkContent('111');
      let item2: CallLog = new CallLog(itemBuilder);
      expect(missedCallService.getMissedCallNumberMarkName(item2, context)).assertEqual(itemBuilder.markContent);

      itemBuilder.setMarkType('11');
      itemBuilder.setMarkContent('111');
      let item3: CallLog = new CallLog(itemBuilder);
      expect(missedCallService.getMissedCallNumberMarkName(item3, context)).assertEqual(itemBuilder.markContent);
    })

    it('MissedCallServiceTest_getMissedCallNumberMarkInfoOrNumberLocation', 0, () => {
      let itemBuilder = new CallLogBuilder(1, '123');
      itemBuilder.numberLocation = 'N';
      let item: CallLog = new CallLog(itemBuilder);
      expect(missedCallService.getMissedCallNumberMarkInfoOrNumberLocation(item)).assertEqual('');

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let itemBuilder1 = new CallLogBuilder(1, '13112345678');
      itemBuilder1.numberLocation = 'Y';
      itemBuilder1.setMarkType('2');
      itemBuilder1.setMarkSource('5');
      let item1: CallLog = new CallLog(itemBuilder1);
      expect(missedCallService.getMissedCallNumberMarkInfoOrNumberLocation(item1, context)).assertEqual('13112345678 Y');
    })

    it('MissedCallServiceTest_getMissedCallNumberMarkInfoOrNumberLocation_else', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let itemBuilder = new CallLogBuilder(1, '123');
      itemBuilder.setMarkType('8');
      itemBuilder.setIsCloudMark(0);
      itemBuilder.setMarkContent('111')
      let item: CallLog = new CallLog(itemBuilder);
      expect(missedCallService.getMissedCallNumberMarkInfoOrNumberLocation(item, context)).assertEqual('111');

      let itemBuilder1 = new CallLogBuilder(1, '13112345678');
      itemBuilder1.setIsCloudMark(33);
      itemBuilder1.numberLocation = 'N';
      let item1: CallLog = new CallLog(itemBuilder1);
      expect(missedCallService.getMissedCallNumberMarkInfoOrNumberLocation(item1, context)).assertEqual('');
    })

    it('MissedCallServiceTest_setLastNotificationId_true', 0, async () => {
      missedCallService.lastMissedId = -1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(missedCallService, missedCallService.unRegisterDataChangeObserver);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      expect(missedCallService.setLastNotificationId(1)).assertTrue();
      mocker.clear(missedCallService);
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallServiceTest_setLastNotificationId_false', 0, async () => {
      missedCallService.lastMissedId = -0;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(missedCallService, missedCallService.unRegisterDataChangeObserver);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      expect(missedCallService.setLastNotificationId(0)).assertFalse();
      mocker.clear(missedCallService);
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallServiceTest_updateBlockedNotificationAction', 0, () => {
      let context: Context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.updateBlockedNotificationAction('17877777777', context as StaticSubscriberExtensionContext);
      mocker.verify('i', ['MissedCallService', `updateBlockedNotificationAction`]).once();
      mocker.clear(HiLog);
    })

    it('MissedCallServiceTest_sendBlockedCallNotify_001', 0, () => {
      let context: Context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.sendBlockedCallNotify('17877777777', context as StaticSubscriberExtensionContext);
      mocker.verify('i', ['MissedCallService', `sendBlockedCallNotify`]).once();
      mocker.clear(HiLog);
    })

    it('MissedCallServiceTest_sendBlockedCallNotify_002', 0, () => {
      let context: Context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      missedCallService.sendBlockedCallNotify('17877777777', context as StaticSubscriberExtensionContext, 'detectDetails');
      mocker.verify('i', ['MissedCallService', `sendBlockedCallNotify`]).once();
      mocker.clear(HiLog);
    })
  })
}