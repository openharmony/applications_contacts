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

import { common } from '@kit.AbilityKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import BatchSelectFavoriteSource from '../../../../../../main/ets/model/bean/BatchSelectFavoriteSource';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';

export default function BatchSelectFavoriteSourceTest() {
  describe('BatchSelectFavoriteSourceTest', () => {
    it('BatchSelectFavoriteSourceTest_totalCount', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('BatchSelectFavoriteSourceTest_refresh', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(cd.contactList);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('BatchSelectFavoriteSourceTest_getData_if_1', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      cd.refresh([]);
      let result: LooseObject | undefined | null = cd.getData(1);
      expect(result).assertNull();
    })

    it('BatchSelectFavoriteSourceTest_getData_if_2', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      let cv1 = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let cv2 = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let cv3 = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(contactList);

      let result: LooseObject | undefined | null = cd.getData(4);

      expect(result).assertNull();
    })

    it('BatchSelectFavoriteSourceTest_getData_if_3', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      let cv1 = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '', "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');
      cv2.showName = 'showName2';

      let cv3 = new ContactVo("", "", '', "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(contactList);

      let result: LooseObject | undefined | null = cd.getData(1);

      expect(result?.showIndex).assertFalse();
      expect(result?.showDivifer).assertTrue();
    })

    it('BatchSelectFavoriteSourceTest_getData_if_4', 0, () => {
      let cd = new BatchSelectFavoriteSource();
      let cv1 = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '', "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv3 = new ContactVo("", "", '', "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(contactList);

      let result: LooseObject | undefined | null = cd.getData(1);

      expect(result?.showIndex).assertFalse();
      expect(result?.showDivifer).assertTrue();
    })

    it('BatchSelectFavoriteSourceTest_getData_if_5', 0, () => {
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'title'
        }
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let getDefaultUIContext: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let cd = new BatchSelectFavoriteSource();
      let cv1 = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      let cv2 = new ContactVo("", "", '', "", "", "", {
        id: 1,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "570977632", '0');

      let cv3 = new ContactVo("", "", '', "", "", "", {
        id: 2,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      cd.refresh(contactList);

      let result: LooseObject | undefined | null = cd.getData(2);

      expect(result?.showIndex).assertFalse();
      expect(result?.showDivifer).assertFalse();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
  })
}