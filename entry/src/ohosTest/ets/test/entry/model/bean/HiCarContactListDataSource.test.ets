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
import { ContactVo } from '../../../../../../main/ets/model/bean/ContactVo';
import HiCarContactListDataSource from '../../../../../../main/ets/model/bean/HiCarContactListDataSource';
import HiCarContactListShowInfo from '../../../../../../main/ets/model/bean/HiCarContactListShowInfo';
import { common } from '@kit.AbilityKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'

export default function HiCarContactListDataSourceTest() {
  describe('HiCarContactListDataSourceTest', () => {
    it('HiCarContactListDataSourceTest_totalCount', 0, () => {
      let cd = new HiCarContactListDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('HiCarContactListDataSourceTest_refresh_true', 0, () => {
      let cd = new HiCarContactListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, cd.contactList, true);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('HiCarContactListDataSourceTest_refresh_false', 0, () => {
      let cd = new HiCarContactListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(0, cd.contactList, false);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('HiCarContactListDataSourceTest_getData_if_1', 0, () => {
      let cd = new HiCarContactListDataSource();
      cd.refresh(0, [], true);
      let result: HiCarContactListShowInfo | null = cd.getData(1);
      expect(result).assertNull();
    })

    it('HiCarContactListDataSourceTest_getData_if_2', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let cv3 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(4);

      expect(result).assertNull();
    })

    it('HiCarContactListDataSourceTest_getData_if_3', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      cv2.showName = 'showName2';

      let cv3 = new ContactVo("", "", '',  "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(1);

      expect(result?.isShowIndex).assertFalse();
      expect(result?.isShowContactDivifer).assertTrue();
      expect(result?.contactTitle).assertEqual('showName2');
    })

    it('HiCarContactListDataSourceTest_getData_if_4', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv3 = new ContactVo("", "", '',  "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(1);

      expect(result?.isShowIndex).assertFalse();
      expect(result?.isShowContactDivifer).assertTrue();
      expect(result?.contactTitle).assertEqual('570977632');
    })

    it('HiCarContactListDataSourceTest_getData_if_5', 0, () => {
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'title'
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv3 = new ContactVo("", "", '',  "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(2);

      expect(result?.isShowIndex).assertFalse();
      expect(result?.isShowContactDivifer).assertFalse();
      expect(result?.contactTitle).assertEqual('title');
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('GetIsShowIndexTest_getData_if_1', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '1');
      let contactList: ContactVo[] = [cv1];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(0);
      expect(result?.isShowIndex).assertFalse();
    })

    it('GetIsShowIndexTest_getData_if_2', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      let contactList: ContactVo[] = [cv1];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(0);
      expect(result?.isShowIndex).assertTrue();
    })

    it('GetIsShowIndexTest_getData_if_3', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      let contactList: ContactVo[] = [cv1, cv2];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(1);
      expect(result?.isShowIndex).assertFalse();
    })

    it('GetIsShowIndexTest_getData_if_4', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '1');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      let contactList: ContactVo[] = [cv1, cv2];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(1);
      expect(result?.isShowIndex).assertTrue();
    })

    it('GetIsShowContactDiviferTest_getData_if_1', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '1');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      let contactList: ContactVo[] = [cv1, cv2];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(0);
      expect(result?.isShowContactDivifer).assertFalse();
    })

    it('GetIsShowContactDiviferTest_getData_if_2', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      cv1.showName = 'showName1';

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      cv2.showName = 'showName2';

      let contactList: ContactVo[] = [cv1, cv2];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(0);
      expect(result?.isShowContactDivifer).assertTrue();
    })

    it('GetIsShowContactDiviferTest_getData_if_3', 0, () => {
      let cd = new HiCarContactListDataSource();
      let cv1 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv2 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '1');

      let contactList: ContactVo[] = [cv1, cv2];
      cd.refresh(0, contactList, true);

      let result: HiCarContactListShowInfo | null = cd.getData(0);
      expect(result?.isShowContactDivifer).assertFalse();
    })
  })
}