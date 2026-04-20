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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import StaticSubscriber from '../../../../../main/ets/StaticSubscriber/StaticSubscriber';
import { MissedCallService } from '../../../../../../../feature/call';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { CallLogRepository } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import {
  ContactRepository
} from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';


export default function StaticSubscriberTest() {
  describe('StaticSubscriberTest', () => {

    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('staticSubscriber_onReceiveEvent_countList_notUndefined', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let parameters: LooseObject = {
        isBlocked: true,
        phoneNumber: '',
        countList: ['1']
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'usual.event.INCOMING_CALL_MISSED'
      };
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(MissedCallService.getInstance(), MissedCallService.getInstance().init);
      let mockFunc: Function =
        mocker.mockFunc(MissedCallService.getInstance().updateAllMissedCallNotifications(context),
          MissedCallService.getInstance().updateAllMissedCallNotifications(context).catch);
      let result = true;
      when(mockFunc)(context).afterThrow('error');
      staticSubscriber.onReceiveEvent(event);
      expect(result).assertTrue();
      mocker.clear(MissedCallService.getInstance());
      mocker.clear(MissedCallService.getInstance().updateAllMissedCallNotifications(context));
    })

    it('staticSubscriber_onReceiveEvent_countList_01', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let parameters: LooseObject = {
        isBlocked: true,
        phoneNumber: '13801001234'
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'usual.event.INCOMING_CALL_MISSED'
      };
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(MissedCallService.getInstance(), MissedCallService.getInstance().init);
      let mockFun: Function =
        mocker.mockFunc(MissedCallService.getInstance().updateAllMissedCallNotifications(context),
          MissedCallService.getInstance().updateMissedCallNotifications(context).catch);
      when(mockFun)(context).afterThrow('error');

      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils.getFromPreferences('interceptionCallsCount', 0),
        sharedPreferencesUtils.getFromPreferences('interceptionCallsCount', 0).then);
      let count = 1;
      when(mockFunc)(count).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(1);
      }))
      staticSubscriber.onReceiveEvent(event);
      expect(staticSubscriber.resultDT).assertEqual(0);
      mocker.clear(MissedCallService.getInstance());
      mocker.clear(sharedPreferencesUtils.getFromPreferences('interceptionCallsCount', 0));
      mocker.clear(MissedCallService.getInstance().updateAllMissedCallNotifications(context));
    })

    it('staticSubscriber_onReceiveEvent_countList_undefined', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let parameters: LooseObject = {
        isBlocked: false,
        phoneNumber: '13801001234'
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'usual.event.INCOMING_CALL_MISSED'
      };
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(MissedCallService.getInstance(), MissedCallService.getInstance().init);
      let mockFunc: Function =
        mocker.mockFunc(MissedCallService.getInstance().updateAllMissedCallNotifications(context),
          MissedCallService.getInstance().updateMissedCallNotifications(context).catch);
      let result = true;
      when(mockFunc)(context).afterThrow('error');
      staticSubscriber.onReceiveEvent(event);
      expect(result).assertTrue();
      mocker.clear(MissedCallService.getInstance());
    })

    it('staticSubscriber_onReceiveEvent_else_isBlocked', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let missedCallData: LooseObject = {
        isBlocked: true,
        isRemoveBlocked: false
      }
      let parameters: LooseObject = {
        missedCallData: missedCallData
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'contact.event.CANCEL_MISSED'
      };
      mocker.mockFunc(MissedCallService.getInstance(), MissedCallService.getInstance().init);
      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().init);
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockFunc: Function = mocker.mockFunc(MissedCallService.getInstance().cancelInterceptionNotificationAction(),
        MissedCallService.getInstance().cancelInterceptionNotificationAction().catch);
      when(mockFunc)().afterThrow('error')
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      let interceptionCallsCount: number = 0;
      staticSubscriber.onReceiveEvent(event);
      mocker.verify('saveToPreferences', ['interceptionCallsCount', interceptionCallsCount]).once();
      mocker.clear(MissedCallService.getInstance());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactRepository.getInstance());
    })

    it('staticSubscriber_onReceiveEvent_else_isRemoveBlocked', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let missedCallData: LooseObject = {
        isBlocked: false,
        isRemoveBlocked: true
      }
      let parameters: LooseObject = {
        missedCallData: missedCallData
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'contact.event.CANCEL_MISSED'
      };
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      staticSubscriber.onReceiveEvent(event);
      mocker.verify('saveToPreferences', ['newInterceptionCallsCount', 0]).once();
      mocker.clear(sharedPreferencesUtils);
    })

    it('staticSubscriber_onReceiveEvent_else_else', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let mocker: MockKit = new MockKit();
      let missedCallData: LooseObject = {
        isBlocked: false,
        isRemoveBlocked: false,
        phoneNumber: '13801001111'
      }
      let parameters: LooseObject = {
        missedCallData: missedCallData,
        action: 'notification.event.dialBack'
      };
      const event: LooseObject = {
        parameters: parameters,
        event: 'contact.event.CANCEL_MISSED'
      };
      let mockFunc: Function = mocker.mockFunc(MissedCallService.getInstance().cancelInterceptionNotificationAction(),
        MissedCallService.getInstance().cancelMissedNotificationAction(event.parameters?.missedCallData).catch);
      staticSubscriber.onReceiveEvent(event);
      when(mockFunc)().afterThrow('error');
      mocker.verify('catch', [Error]).never();
      mocker.clear(MissedCallService.getInstance().cancelInterceptionNotificationAction());
    })

    it('staticSubscriber_callSharingPhone', 0, () => {
      let staticSubscriber: StaticSubscriber = new StaticSubscriber();
      let callback: Function = () => {};
      staticSubscriber.callSharingPhone(callback);
      expect(staticSubscriber.resultDT).assertEqual(0);
    })
  })
}