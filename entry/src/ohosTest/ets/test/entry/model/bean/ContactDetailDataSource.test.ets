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
import ContactDetailDataSource from '../../../../../../main/ets/model/bean/ContactDetailDataSource';

export default function ContactDetailDataSourceTest() {
  describe('ContactDetailDataSourceTest', () => {

    it('ContactDetailDataSourceTest_totalCount', 0, () => {
      let cd = new ContactDetailDataSource<string>();
      expect(cd.totalCount()).assertEqual(0)
    })

    it('ContactDetailDataSourceTest_refresh', 0, () => {
      let callLogData: string[] = [];

      let cd = new ContactDetailDataSource<string>();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(callLogData)
      mocker.verify('notifyDataReload', []).once();
      callLogData.push("12")
      callLogData.push("123")
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(callLogData)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })

    it('ContactDetailDataSourceTest_getData', 0, () => {
      let cd = new ContactDetailDataSource<string>();
      expect(cd.getData(0)?.index).assertUndefined();

      let callLogData: string[] = [];
      callLogData.push("12");
      callLogData.push("123");
      cd.refresh(callLogData);
      expect(cd.getData(1)?.index).assertEqual(1);
    })
  })
}