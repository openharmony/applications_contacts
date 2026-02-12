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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import BatchSelectContactSource from '../../../../../../main/ets/model/bean/BatchSelectContactSource'
import { ContactVo } from '../../../../../../main/ets/model/bean/ContactVo'
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor'
import { PhoneNumberInterface } from '../../../../../../main/ets/model/type'
import LooseObject from '../../../../../../main/ets/model/type/LooseObject'

export default function BatchSelectContactSourceTest() {
  describe('BatchSelectContactSourceTest', () => {

    let batchSelectContactSource: BatchSelectContactSource;

    beforeEach(() => {
      batchSelectContactSource = new BatchSelectContactSource();
    })

    it('BatchSelectContactSourceTest_totalCount', 0, () => {
      let batchSelectContactSource = new BatchSelectContactSource();

      let num = batchSelectContactSource.totalCount();

      expect(num).assertEqual(0)
    })

    it('BatchSelectContactSourceTest_getData_if_1', 0, () => {
      batchSelectContactSource.refresh([]);
      let result: LooseObject | undefined | null = batchSelectContactSource.getData(1);
      expect(result).assertNull();
    })

    it('BatchSelectContactSourceTest_getData_if_2', 0, () => {
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
      batchSelectContactSource.refresh(contactList);

      let result: LooseObject | undefined | null = batchSelectContactSource.getData(4);

      expect(result).assertNull();
    })

    it('BatchSelectContactSourceTest_getData_else_if', 0, () => {
      let cv1 = new ContactVo("", "", '',  "", "", "", {
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
      }, true, "", "570977632", '0');
      cv2.showName = 'showName2';

      let cv3 = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      let contactList: ContactVo[] = [cv1, cv2, cv3];
      batchSelectContactSource.refresh(contactList);

      let result: LooseObject | undefined | null = batchSelectContactSource.getData(1);

      expect(result?.showIndex).assertFalse();
      expect(result?.showDivifer).assertTrue();
      expect(result?.contact.title).assertEqual('showName2');
    })

    it('BatchSelectContactSourceTest_getData_else_else', 0, () => {
      let cv1 = new ContactVo("", "prefix1", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      cv1.showName = 'showName1';

      let cv2 = new ContactVo("", "prefix2", '',  "", "", "", {
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
      }, true, "", "570977632", '0');

      let contactList: ContactVo[] = [cv1, cv2, cv3];
      batchSelectContactSource.refresh(contactList);

      let result: LooseObject | undefined | null = batchSelectContactSource.getData(2);

      expect(result?.showIndex).assertTrue();
      expect(result?.showDivifer).assertFalse();
      expect(result?.contact.title).assertEqual("570977632");
    })

    it('BatchSelectContactSourceTest_refresh', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectContactSource, batchSelectContactSource.notifyDataReload);

      batchSelectContactSource.refresh([]);

      mocker.verify("notifyDataReload", []).once();

      mocker.clear(batchSelectContactSource);
    })

    it('BatchSelectContactSourceTest_needRefreshOthers', 0, () => {
      let phoneNumber1: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '13701111111',
        labelId: '',
        numType: '',
        labelName: 'labelName',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumber2: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '13701111111',
        labelId: '',
        numType: '',
        labelName: 'labelName',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber1, phoneNumber2];
      let vo1 = new ContactVo('1', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      vo1.phoneNumbers = phoneNumbers;
      let contactList: ContactVo[] = [vo1];
      batchSelectContactSource.contactList = contactList;
      expect(batchSelectContactSource.needRefreshOthers(vo1, 0)).assertFalse();

      let vo = new ContactVo('7', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      expect(batchSelectContactSource.needRefreshOthers(vo, 0)).assertTrue();
    })

    it('BatchSelectContactSourceTest_removeAndRefreshIndex', 0, () => {
      let vo = new ContactVo('7', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(batchSelectContactSource, batchSelectContactSource.needRefreshOthers);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      mocker.mockFunc(batchSelectContactSource, batchSelectContactSource.notifyDataReload);
      batchSelectContactSource.removeAndRefreshIndex(vo, 0);
      mocker.verify('notifyDataReload', []).never();

      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      batchSelectContactSource.removeAndRefreshIndex(vo, 0);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(batchSelectContactSource);
    })

    it('BatchSelectContactSourceTest_addAndRefreshIndex', 0, () => {
      let vo = new ContactVo('7', '1', '', '', '', '', MorandiColor.color[0], true, '', '', '0');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(batchSelectContactSource, batchSelectContactSource.needRefreshOthers);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      mocker.mockFunc(batchSelectContactSource, batchSelectContactSource.notifyDataReload);
      batchSelectContactSource.addAndRefreshIndex(vo, 0);
      mocker.verify('notifyDataReload', []).never();

      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      batchSelectContactSource.addAndRefreshIndex(vo, 0);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(batchSelectContactSource);
    })
  })
}