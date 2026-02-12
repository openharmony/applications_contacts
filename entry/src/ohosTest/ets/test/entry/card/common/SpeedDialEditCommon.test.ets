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
import SpeedDialEditCommon from '../../../../../../main/ets/card/common/SpeedDialEditCommon';
import formBindingData from '@ohos.app.form.formBindingData';
import { SpeedDialDataType } from '../../../../../../main/ets/card/type/speedDial';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { contact } from '@kit.ContactsKit';

const TAG = 'SpeedDialEditCommon';

export default function SpeedDialEditCommonTest() {
  describe('SpeedDialEditCommonTest', () => {

    let speedDialEditCommon: SpeedDialEditCommon;

    beforeEach(() => {
      speedDialEditCommon = new SpeedDialEditCommon();
    })

    it('SpeedDialEditCommonTest_updateToCard', 0, async () => {
      let data: formBindingData.FormBindingData = {
        data: Object
      };
      speedDialEditCommon.updateToCard('154512151', data);
      expect(speedDialEditCommon.constContacts.length).assertEqual(0);
    })

    it('SpeedDialEditCommonTest_updateToCardError', 0, () => {
      let mocker: MockKit = new MockKit();
      let data: formBindingData.FormBindingData = {
        data: Object
      };
      mocker.mockFunc(HiLog, HiLog.w);
      speedDialEditCommon.updateToCard('154512151', data);
      mocker.verify('w', [TAG, `formProvider updateForm success formId: 154512151`]).never();
      mocker.clear(HiLog);
    })

    it('SpeedDialEditCommonTest_updateToSettings', 0, async () => {
      let speedDialDataType: SpeedDialDataType = new SpeedDialDataType();
      speedDialDataType.contactId = '1';
      speedDialDataType.id = 1;
      let contacts: SpeedDialDataType[] = [speedDialDataType];

      let speedDialDataType1: SpeedDialDataType = new SpeedDialDataType();
      speedDialDataType1.contactId = '2';
      speedDialDataType1.id = 2;
      speedDialEditCommon.constContacts = [speedDialDataType1];

      speedDialEditCommon.updateToSettings(contacts);

      expect(speedDialEditCommon.contacts.length).assertEqual(0);
    })

    it('SpeedDialEditCommonTest_speedDailDataSort', 0, () => {
      let formId: string = '10000000'
      let speedDialDataType: SpeedDialDataType = new SpeedDialDataType();
      let contacts: SpeedDialDataType[] = [speedDialDataType, speedDialDataType, speedDialDataType, speedDialDataType];
      contacts[0].formId = '10000000*0'
      contacts[1].formId = '10000000*2'
      contacts[2].formId = '10000000*1'
      contacts[3].formId = '10000000*3'

      let result: SpeedDialDataType[] = [speedDialDataType, speedDialDataType, speedDialDataType, speedDialDataType];
      result[0].formId = '10000000*0'
      result[1].formId = '10000000*1'
      result[2].formId = '10000000*2'
      result[3].formId = '10000000*3'
      expect(JSON.stringify(speedDialEditCommon.speedDailDataSort(contacts, formId))).assertEqual(JSON.stringify(result));
    })

    it('SpeedDialEditCommonTest_parseContactForResult', 0, async () => {
      let want: Record<string, object | string> = {
        "parameters": {
          "contactObjects": "[{\"contactName\":\"出给力听你滴定制什么很明显红色给你\",\"telephone\":\"18734843454\",\"id\":18,\"contactId\":18}]",
          "selectContactCount": 1,
          "selectContactIds": [18]
        } as Record<string, Object>
      }

      let data: Record<string, Object> = {
        "resultCode": 0,
        "want": want
      }
      speedDialEditCommon.parseContactForResult(data);
      expect(speedDialEditCommon.contacts.length).assertEqual(1)
    })

    it('SpeedDialEditCommonTest_updateContactFormId', 0, async () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      let result: boolean = false;
      when(mocker.mockFunc(HiLog, HiLog.w))(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })
      await speedDialEditCommon.updateContactFormId('', context, '')
      expect(result).assertTrue();
      mocker.clear(HiLog);
    })

    it('SpeedDialEditCommonTest_queryContactFormId', 0, async () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let formId: string = await speedDialEditCommon.queryContactFormId('', context)
      expect(formId).assertEqual('');
    })

    it('SpeedDialEditCommonTest_queryContactByFormId', 0, async () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      let result: boolean = false;
      when(mocker.mockFunc(HiLog, HiLog.w))(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })
      await speedDialEditCommon.queryContactByFormId('', context);
      expect(result).assertTrue();
      mocker.clear(HiLog);
    })
  })
}