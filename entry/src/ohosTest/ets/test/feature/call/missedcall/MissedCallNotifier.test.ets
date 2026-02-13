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
import {
  MissedCallNotifier,
  MissedCallNotifyData
} from '../../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import { common } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { sharedPreferencesUtils, NumberAddressUtil } from '../../../../../../../../common';

export default function MissedCallNotifierTest() {
  describe('MissedCallNotifierTest', () => {
    let missedCallNotifier: MissedCallNotifier;

    beforeEach(() => {
      missedCallNotifier = new MissedCallNotifier();
    })

    it('MissedCallNotifierTest_getInstance', 0, () => {
      expect(typeof missedCallNotifier).assertEqual(typeof MissedCallNotifier.getInstance());
    })

    it('MissedCallNotifierTest_init', 0, () => {
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => ''
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.init);

      missedCallNotifier.init(context);

      mocker.verify('init', [context]).once();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallNotifierTest_init2', 0, () => {
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => ''
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.init);
      //先初始化一下，保证context不为空
      missedCallNotifier.init(context);
      //然后进行正式测试context不为空的情况
      missedCallNotifier.init(context);

      mocker.verify('init', [context]).times(2);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications', 0, () => {
      let missedCallNotifyData1: MissedCallNotifyData = new MissedCallNotifyData(1, 'name1', '570977632', 1, 0, 1);
      let missedCallNotifyData2: MissedCallNotifyData = new MissedCallNotifyData(2, 'name2', '570977632', 1, 0, 1);
      let missedCallNotifyDataList: MissedCallNotifyData[] = [missedCallNotifyData1, missedCallNotifyData2];

      let missedData: Map<string, MissedCallNotifyData> = new Map();
      missedData.set('name2', missedCallNotifyData2);

      let mocker: MockKit = new MockKit();
      let getMissedCallNotifyDatas: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas);
      when(getMissedCallNotifyDatas)()
        .afterReturn(new Promise<MissedCallNotifyData[]>(resolve => resolve(missedCallNotifyDataList)));

      let sendNotification: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.sendNotification);
      when(sendNotification)(missedCallNotifyData1).afterReturn(new Promise<void>(resolve => resolve()));
      when(sendNotification)(missedCallNotifyData2).afterReturn(new Promise<void>(resolve => resolve()));

      mocker.mockFunc(missedCallNotifier, missedCallNotifier.setMissedBadgeNumber);

      missedCallNotifier.updateMissedCallNotifications(missedData);

      mocker.verify('getMissedCallNotifyDatas', []).once();

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications_missedId_notEqual_notifyId', 0, () => {
      let missedCallNotifyData1: MissedCallNotifyData = new MissedCallNotifyData(1, 'name1', '570977632', 1, 0, 1);
      let missedCallNotifyData2: MissedCallNotifyData = new MissedCallNotifyData(2, 'name2', '570977632', 1, 0, 1);
      let missedCallNotifyData3: MissedCallNotifyData = new MissedCallNotifyData(3, 'name3', '570977632', 1, 0, 1);
      let missedCallNotifyData4: MissedCallNotifyData = new MissedCallNotifyData(4, 'name4', '570977632', 1, 0, 1);
      let missedCallNotifyDataList: MissedCallNotifyData[] = [missedCallNotifyData1, missedCallNotifyData2];

      let missedData: Map<string, MissedCallNotifyData> = new Map();
      missedData.set('name2', missedCallNotifyData3);
      missedData.set('name4', missedCallNotifyData4);

      let mocker: MockKit = new MockKit();
      let getMissedCallNotifyDatas: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas);
      when(getMissedCallNotifyDatas)()
        .afterReturn(new Promise<MissedCallNotifyData[]>(resolve => resolve(missedCallNotifyDataList)));

      mocker.mockFunc(missedCallNotifier, missedCallNotifier.setMissedBadgeNumber);

      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'title'
        }
      } as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      missedCallNotifier.updateMissedCallNotifications(missedData);

      mocker.verify('getMissedCallNotifyDatas', []).once();

      mocker.clear(missedCallNotifier);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications_missedId_notEqual_notifyId_count_undefined', 0, () => {
      let missedCallNotifyData1: MissedCallNotifyData = new MissedCallNotifyData(1, 'name1', '570977632', 1, 0, 1);
      let missedCallNotifyData2: MissedCallNotifyData = new MissedCallNotifyData(2, 'name2', '570977632', 1, 0, 1);
      let missedCallNotifyData3: MissedCallNotifyData = new MissedCallNotifyData(3, 'name3', '570977632');
      let missedCallNotifyData4: MissedCallNotifyData = new MissedCallNotifyData(4, 'name4', '570977632', 1, 0, 1);
      let missedCallNotifyDataList: MissedCallNotifyData[] = [missedCallNotifyData1, missedCallNotifyData2];

      let missedData: Map<string, MissedCallNotifyData> = new Map();
      missedData.set('name2', missedCallNotifyData3);
      missedData.set('name4', missedCallNotifyData4);

      let mocker: MockKit = new MockKit();
      let getMissedCallNotifyDatas: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas);
      when(getMissedCallNotifyDatas)()
        .afterReturn(new Promise<MissedCallNotifyData[]>(resolve => resolve(missedCallNotifyDataList)));

      mocker.mockFunc(missedCallNotifier, missedCallNotifier.setMissedBadgeNumber);

      missedCallNotifier.updateMissedCallNotifications(missedData);

      mocker.verify('getMissedCallNotifyDatas', []).once();

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_cancelAllNotification', 0, () => {
      let missedBadgeNumberID = 0;
      missedCallNotifier.cancelAllNotification();
      expect(missedCallNotifier.missedBadgeNumber).assertEqual(missedBadgeNumberID);
    })

    it('MissedCallNotifierTest_getMissedBadgeNumber', 0, () => {
      let missedBadgeNumberID = 0;
      missedCallNotifier.missedBadgeNumber = 0;
      missedCallNotifier.getMissedBadgeNumber();
      expect(missedCallNotifier.missedBadgeNumber).assertEqual(missedBadgeNumberID);

      let missedBadgeNumberAsync = 1;
      missedCallNotifier.missedBadgeNumber = -1;
      missedCallNotifier.getMissedBadgeNumber();
      expect(typeof missedCallNotifier.missedBadgeNumber).assertEqual(typeof missedBadgeNumberAsync);
    })

    it('MissedCallNotifierTest_cancelNotificationById', 0, async () => {
      let missedBadgeNumberID = 0;
      missedCallNotifier.missedBadgeNumber = 0;
      await missedCallNotifier.cancelNotificationById(1, 1);
      expect(missedCallNotifier.missedBadgeNumber).assertEqual(missedBadgeNumberID);

      let missedBadgeNumberAsync = 3;
      missedCallNotifier.missedBadgeNumber = 5;
      await missedCallNotifier.cancelNotificationById(2, 2);
      expect(missedCallNotifier.missedBadgeNumber).assertEqual(missedBadgeNumberAsync);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications00', 0, () => {
      let missedDataMap: Map<string, MissedCallNotifyData> = new Map();
      missedDataMap.set('display', new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4))

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas)
      when(mocMergeData)().afterReturn([])

      let missCallData = missedCallNotifier.updateMissedCallNotifications(missedDataMap)
      expect(typeof missCallData).assertEqual('object');

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications01', 0, () => {
      let missedDataMap: Map<string, MissedCallNotifyData> = new Map();
      missedDataMap.set('display', new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4))

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas)
      when(mocMergeData)().afterReturn([new MissedCallNotifyData(2, 'display1', 'phone1', 4, 6, 8)])

      let missCallData = missedCallNotifier.updateMissedCallNotifications(missedDataMap)
      expect(typeof missCallData).assertEqual('object');

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications02', 0, () => {
      let missedDataMap: Map<string, MissedCallNotifyData> = new Map();
      missedDataMap.set('display', new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4))

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas)
      when(mocMergeData)().afterReturn([new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4)])

      let missCallData = missedCallNotifier.updateMissedCallNotifications(missedDataMap)
      expect(typeof missCallData).assertEqual('object');

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_updateMissedCallNotifications03', 0, () => {
      let missedDataMap: Map<string, MissedCallNotifyData> = new Map();
      missedDataMap.set('display', new MissedCallNotifyData(1, 'display', 'phone', 2, 3, 4))

      let mocker: MockKit = new MockKit();
      let mocMergeData: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.getMissedCallNotifyDatas);
      when(mocMergeData)().afterReturn([new MissedCallNotifyData(1, 'display', 'phone', 0, 3, 4)])

      let missCallData = missedCallNotifier.updateMissedCallNotifications(missedDataMap)
      expect(typeof missCallData).assertEqual('object');

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_cancelNotificationById00', 0, async () => {
      let mocker: MockKit = new MockKit();
      missedCallNotifier.missedBadgeNumber = 1
      mocker.mockFunc(missedCallNotifier, missedCallNotifier.setMissedBadgeNumber)

      missedCallNotifier.getMissedBadgeNumber()
      await missedCallNotifier.cancelNotificationById(1, 0);
      mocker.verify('setMissedBadgeNumber', [1]).once();

      mocker.clear(missedCallNotifier);
    })

    it('MissedCallNotifierTest_sendNotification', 0, async () => {
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => ''
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.init);

      missedCallNotifier.init(context);

      let getNumberLocation: Function = mocker.mockFunc(NumberAddressUtil, NumberAddressUtil.getNumberLocation);
      when(getNumberLocation)(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('some address')));

      let createWantAgentForCommonEvent: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.createWantAgentForCommonEvent);
      when(createWantAgentForCommonEvent)(ArgumentMatchers.any).afterReturn({});

      let missedCallNotifyData1: MissedCallNotifyData = new MissedCallNotifyData(1, '570977632', '570977632', 1, 0, 1);

      missedCallNotifier.sendNotification(missedCallNotifyData1);

      expect(missedCallNotifier.missedBadgeNumber).assertEqual(-1);

      mocker.clear(missedCallNotifier);
      mocker.clear(NumberAddressUtil);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
    })

    it('MissedCallNotifierTest_setMissedBadgeNumber', 0, () => {
      missedCallNotifier.setMissedBadgeNumber(1)
      expect(missedCallNotifier.missedBadgeNumber).assertEqual(1);
    })

    it('MissedCallNotifierTest_getWantAgent1', 0, () => {
      const missedCallData: MissedCallNotifyData = new MissedCallNotifyData()
      let action: string = 'notification.event.dialBack';

      let mocker: MockKit = new MockKit();
      let wantAgent: Function = mocker.mockFunc(missedCallNotifier, missedCallNotifier.createWantAgentForCommonEvent)
      when(wantAgent)(missedCallData).afterReturn(1)
      let wantAgentData = missedCallNotifier.getWantAgent(missedCallData, action)
      expect(wantAgentData).assertEqual(1);
      mocker.clear(missedCallNotifier);

    })
  })
}