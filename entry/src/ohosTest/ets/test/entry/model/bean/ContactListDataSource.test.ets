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
import ContactListDataSource from '../../../../../../main/ets/model/bean/ContactListDataSource';
import { ContactVo } from '../../../../../../main/ets/model/bean/ContactVo';
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { common } from '@kit.AbilityKit';
import resmgr from '@ohos.resourceManager';
import ContactListShowInfo from '../../../../../../main/ets/model/bean/ContactListShowInfo';

export default function ContactListDataSourceTest() {
  describe('ContactListDataSourceTest', () => {

    it('ContactListDataSourceTest_totalCount', 0, () => {
      let cd = new ContactListDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })
    it('ContactListDataSourceTest_setCurrentIndex', 0, () => {
      let cd = new ContactListDataSource();
      cd.setCurrentIndex(1, 2);
      expect(cd.getCurrentPage()).assertEqual(1);
    })
    it('ContactListDataSourceTest_refreshAll', 0, () => {
      let cd = new ContactListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refreshAll(cd.contactList)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })
    it('ContactListDataSourceTest_refresh', 0, () => {
      let cd = new ContactListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, cd.contactList, true)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })
    it('ContactListDataSourceTest_remove_001', 0, () => {
      let cd = new ContactListDataSource();
      cd.remove(-1);
      expect(cd.totalCount()).assertEqual(0);
    })
    it('ContactListDataSourceTest_remove_002', 0, () => {
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.remove(0);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('ContactListDataSourceTest_removeIndex_001', 0, () => {
      let cd = new ContactListDataSource();
      cd.removeIndex(-1);
      expect(cd.totalCount()).assertEqual(0);
    })

    it('ContactListDataSourceTest_removeIndex_002', 0, () => {
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataDelete);
      cd.removeIndex(1);
      mocker.verify("notifyDataDelete", [1]).once();
      mocker.clear(cd);
    })

    it('ContactListDataSourceTest_getCurrentPage', 0, () => {
      let cd = new ContactListDataSource();
      expect(cd.getCurrentPage()).assertEqual(1);
    })

    it('ContactListDataSourceTest_getData_002', 0, () => {
      let cd = new ContactListDataSource();
      expect(cd.getData(1)).assertNull();
    })

    it('ContactListDataSourceTest_getData', 0, () => {
      let mocker: MockKit = new MockKit();
      let testString = 'aaa';
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
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      expect(JSON.stringify(cd.getData(1)))
        .assertEqual(JSON.stringify(new ContactListShowInfo(false, false, '', '', '', '', '', '', '')));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactListDataSourceTest_getData01', 0, () => {
      let mocker: MockKit = new MockKit();
      let testString = '';
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
      let cd = new ContactListDataSource();
      let vo1 = new ContactVo('', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo1.title = 'title';
      vo1.showName = 'showName';
      vo1.company = 'company';
      let vo2 = new ContactVo('', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo2.title = 'title';
      vo2.showName = 'showName';
      vo2.company = 'company';
      let vo3 = new ContactVo('', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo3.title = 'title';
      vo3.showName = 'showName';
      vo3.company = 'company';
      cd.contactList = [vo1, vo2, vo3];
      expect(JSON.stringify(cd.getData(1)))
        .assertEqual(JSON.stringify(new ContactListShowInfo(false, true, '', '', '', '', '1', 'showName', 'company ')));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactListDataSourceTest_getIndexByContactId', 0, () => {
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('1', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('2', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      expect(cd.getIndexByContactId(2)).assertEqual(1);
    })

    it('ContactListDataSourceTest_getData02', 0, () => {
      let mocker: MockKit = new MockKit();
      let testString = '';
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
      let cd = new ContactListDataSource();
      let vo1 = new ContactVo('', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo1.title = 'title';
      vo1.showName = 'showName';
      vo1.company = 'company';
      let vo2 = new ContactVo('', '1', '', '', '', 'bbb', MorandiColor.color[0], true, '', '', '0');
      vo2.title = 'title';
      vo2.showName = 'showName';
      let vo3 = new ContactVo('', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo3.title = 'title';
      vo3.showName = 'showName';
      vo3.company = 'company';
      cd.contactList = [vo1, vo2, vo3];
      expect(JSON.stringify(cd.getData(1)))
        .assertEqual(JSON.stringify(new ContactListShowInfo(false, true, '', '', '', '', '1', 'showName', 'bbb')));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactListDataSourceTest_refresh_01', 0, () => {
      let cd = new ContactListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, cd.contactList, false)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('ContactListDataSourceTest_remove_003', 0, () => {
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.remove(0, 1);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('ContactListDataSourceTest_removeIndex_003', 0, () => {
      let cd = new ContactListDataSource();
      cd.contactList = [new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0'),
        new ContactVo('', '', '', '', '', '', MorandiColor.color[0], true, '', '', '0')];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataDelete);
      cd.removeIndex(1, 1);
      mocker.verify("notifyDataDelete", [1]).once();
      mocker.clear(cd);
    })
  })
}