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
import { describe, it, expect, MockKit } from '@ohos/hypium';
import { ContactVo } from '../../../../../../main/ets/model/bean/ContactVo';
import RepeatDataSource from '../../../../../../main/ets/model/bean/RepeatDataSource';
import { RepeatContactVo } from '../../../../../../main/ets/presenter/contact/settings/ArrangeContactsPresenter';

export default function RepeatDataSourceTest() {
  describe('RepeatDataSourceTest', () => {
    it('RepeatDataSourceTest_totalCount', 0, () => {
      let gd = new RepeatDataSource();
      expect(gd.totalCount()).assertEqual(0)
    })

    it('RepeatDataSourceTest_getRepeatList', 0, () => {
      let gd = new RepeatDataSource();
      expect(gd.getRepeatList().length).assertEqual(0)
    })

    it('RepeatDataSourceTest_refresh', 0, () => {
      let repeatList: RepeatContactVo[] = []
      let gd = new RepeatDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(gd, gd.notifyDataReload);
      gd.refresh(repeatList)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(gd);
    })

    it('RepeatDataSourceTest_getData', 0, () => {
      let contactList: ContactVo[] = [new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0')]
      let repeatList: RepeatContactVo[] = []
      let gd = new RepeatDataSource();
      expect(gd.getData(0)).assertEqual(null)
      repeatList.push(new RepeatContactVo(contactList))
      repeatList.push(new RepeatContactVo(contactList))
      gd.refresh(repeatList)
      expect(gd.getData(0)).assertEqual(repeatList[0])
    })
  })
}