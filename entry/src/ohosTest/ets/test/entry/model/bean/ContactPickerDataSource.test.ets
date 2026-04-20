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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import ContactPickerDataSource from '../../../../../../main/ets/model/bean/ContactPickerDataSource';
import { ContactPickerListItem, PickerShowSubData } from '../../../../../../main/ets/model/type/ContactParams';
import { common } from '@kit.AbilityKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';

export default function ContactPickerDataSourceTest() {
  describe('ContactPickerDataSourceTest', () => {

    it('ContactPickerDataSourceTest_totalCount', 0, () => {
      let cd = new ContactPickerDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('ContactPickerDataSourceTest_getData_01', 0, () => {
      let cd = new ContactPickerDataSource();
      let ret = cd.getData(-1)
      expect(ret).assertNull();
    })

    it('ContactPickerDataSourceTest_getData_02_01', 0, () => {
      let cd = new ContactPickerDataSource();
      let mocker: MockKit = new MockKit();

      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        }
      } as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      let contact: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: false,
        headChar: '',
        nameSuffix: '',
        namePrefix: '',
        favoriteOrder: 0,
        isFirst: true
      }
      cd.contactList.push(contact);
      let ret = cd.getData(0)
      expect(JSON.stringify(ret)).assertEqual(JSON.stringify(contact));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactPickerDataSourceTest_getData_02_02', 0, () => {
      let cd = new ContactPickerDataSource();
      let mocker: MockKit = new MockKit();

      let testString = "aaa"
      let context: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return testString;
          }
        }
      } as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let pickerShowSubData: PickerShowSubData = {
        dataId: 0,
        keyValue: '123',
        showValue: '123'
      }
      let contact1: ContactPickerListItem = {
        contactId: 1,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: false,
        headChar: '',
        nameSuffix: '',
        namePrefix: '1',
        favoriteOrder: 0,
        isFirst: true,
      }
      let contact2: ContactPickerListItem = {
        contactId: 2,
        displayName: '',
        pickerShowSubData: pickerShowSubData,
        isFavorite: false,
        headChar: '',
        nameSuffix: '',
        namePrefix: '2',
        favoriteOrder: 0,
        isFirst: true,
      }
      cd.contactList.push(contact1);
      cd.contactList.push(contact2);
      let ret = cd.getData(0)
      expect(JSON.stringify(ret)).assertEqual(JSON.stringify(contact1));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactPickerDataSourceTest_refresh', 0, () => {
      let cd = new ContactPickerDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(cd.contactList)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })
  })
}