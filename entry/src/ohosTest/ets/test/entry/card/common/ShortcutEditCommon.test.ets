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
import { describe, beforeEach, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import ShortcutEditCommon from '../../../../../../main/ets/card/common/ShortcutEditCommon';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { formBindingData } from '@kit.FormKit';
import { commonData } from '../../../../../../main/ets/card/data/commonData';
import { StartOptions } from '@kit.AbilityKit';
import { ContactRepository } from '../../../../../../../../feature/contact';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';
import dataShare from '@ohos.data.dataShare';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import contact from '@ohos.contact';

export default function ShortcutEditCommonTest() {
  describe('ShortcutEditCommonTest', () => {

    let shortcutEditCommon: ShortcutEditCommon;

    beforeEach(() => {
      shortcutEditCommon = new ShortcutEditCommon();
    })

    it('ShortcutEditCommonTest_updateToCard', 0, () => {
      let data: formBindingData.FormBindingData = {
        data: {}
      };
      shortcutEditCommon.updateToCard('1', data);
      expect(shortcutEditCommon.contact.length).assertEqual(0);
    })

    it('ShortcutEditCommonTest_parseContactForResult', 0, async () => {
      let contactObjects =
        "[{\"contactName\":\"哈哈哈\",\"telephone\":\"13801001111\",\"id\":1,\"contactId\":\"1\",\"pickerData\":{\"id\":1," +
          "\"key\":\"1\",\"emails\":[],\"events\":[],\"groups\":[],\"imAddresses\":[]," +
          "\"phoneNumbers\":[{\"phoneNumber\":\"13801001111\",\"labelName\":\"手机\",\"labelId\":1}]," +
          "\"portrait\":{\"uri\":\"\"},\"postalAddresses\":[],\"relations\":[],\"websites\":[]," +
          "\"name\":{\"fullName\":\"哈哈哈\",\"namePrefix\":\"H\",\"nameSuffix\":\"哈\"}," +
          "\"note\":{\"noteContent\":\"\"},\"organization\":{\"name\":\"\",\"title\":\"\"}}}]";
      let pickerData =
        "[{\"id\":1,\"key\":\"1\",\"emails\":[],\"events\":[],\"groups\":[],\"imAddresses\":[]," +
          "\"phoneNumbers\":[{\"phoneNumber\":\"13801001111\",\"labelName\":\"手机\",\"labelId\":1}]," +
          "\"portrait\":{\"uri\":\"\"},\"postalAddresses\":[],\"relations\":[],\"websites\":[]," +
          "\"name\":{\"fullName\":\"哈哈哈\",\"namePrefix\":\"H\",\"nameSuffix\":\"哈\"}," +
          "\"note\":{\"noteContent\":\"\"},\"organization\":{\"name\":\"\",\"title\":\"\"}}]";
      let parameters: Record<string, Object> = {
        'contactObjects': contactObjects,
        'pickerData': pickerData
      }
      let want: Record<string, Object> = {
        'parameters': parameters
      }
      let data: Record<string, Object> = {}
      shortcutEditCommon.parseContactForResult(data);
      expect(shortcutEditCommon.contact.length).assertEqual(0)
    })

    it('ShortcutEditCommonTest_parseContactForResult01', 0, async () => {
      let contactObjects = "";
      let pickerData = "";
      let parameters: Record<string, Object> = {
        'contactObjects': contactObjects,
        'pickerData': pickerData
      }
      let want: Record<string, Object> = {
        'parameters': parameters
      }
      let data: Record<string, Object> = {}
      shortcutEditCommon.parseContactForResult(data);
      expect(shortcutEditCommon.contact.length).assertEqual(0)
    })

    it('ShortcutEditCommonTest_queryContactFormId', 0, async () => {
      let contactId: string = '';
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      conditionArgs.equalTo('contact_id', contactId);
      conditionArgs.and()
      conditionArgs.equalTo('is_deleted', '0');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      when(mockFunc)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => false,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0,
          } as DataShareResultSet))
        }as dataShare.DataShareHelper)));

      // let getData: Function = mocker.mockFunc(daHelper, daHelper.query);
      // when(getData)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));
      // mocker.mockFunc(DAResultSet, DAResultSet.close);
      await shortcutEditCommon.queryContactFormId(contactId, context);
      expect(shortcutEditCommon.contact.length).assertEqual(0);
      mocker.clear(ContactRepository.getInstance());
    })

  })
}