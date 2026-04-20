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
import { afterAll, afterEach, beforeAll, beforeEach, describe,
  ArgumentMatchers, expect, when, it, MockKit } from '@ohos/hypium'
import common from '@ohos.app.ability.common';
import StartOptions from '@ohos.app.ability.StartOptions';
import MmsService from '../../../../../../../feature/phonenumber/src/main/ets/MmsService'
import { SendMessageParams } from '../../../../../main/ets/model/type/ContactParams';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function MmsServiceTest() {
  const MMS_BUNDLE_NAME = 'com.ohos.mms';
  const MMS_ABILITY_NAME = 'com.ohos.mms.MainAbility';
  const MMS_ENTITIES = 'entity.system.home';

  describe('MmsServiceTest', () => {
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

    it('MmsServiceTest_sendMessage', 0, () => {
      let telephone: string = "17698754215"
      let telephoneFormat: string = "17698754215"
      let params: SendMessageParams[] = [];
      params.push(new SendMessageParams(telephone, telephoneFormat));
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MmsService, MmsService.jumpToMms);
      MmsService.sendMessage(telephone, telephoneFormat)
      mocker.verify('jumpToMms', [params]).once();
      mocker.clear(MmsService);
    })

    it('MmsServiceTest_groupSendMessage', 0, () => {
      let telephone: string = "17698754215"
      let telephoneFormat: string = "17698754215"
      let params: SendMessageParams[] = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MmsService, MmsService.jumpToMms);
      params.push(new SendMessageParams(telephone, telephoneFormat));
      MmsService.groupSendMessage(params);
      mocker.verify('jumpToMms', [params]).once();
      mocker.clear(MmsService);
    })

    it('MmsServiceTest_jumpToMms', 0, () => {
      let telephone: string = "17698754215"
      let telephoneFormat: string = "17698754215"
      let params: SendMessageParams[] = [];
      let actionData: Record<string, string> = {};
      let want: LooseObject = {
        bundleName: MMS_BUNDLE_NAME,
        abilityName: MMS_ABILITY_NAME,
        parameters: actionData,
        entities: [
          MMS_ENTITIES,
        ]
      };

      params.push(new SendMessageParams(telephone, telephoneFormat));
      let mocker: MockKit = new MockKit();
      let context: common.UIExtensionContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> =>
        new Promise <void>(resolve => resolve())
      } as common.UIExtensionContext;
      let helper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      when(mocker.mockFunc(helper, helper.getDefaultUIContext))().afterReturn(context);
      MmsService.jumpToMms(params);
      mocker.verify('startAbility', [want]).atLeast(0);
      mocker.clear(helper);
    })
  })
}