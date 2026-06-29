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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { SearchContactResult } from '../../../../../../main/ets/model/bean/SearchContactResult'
import SearchContactsSource from '../../../../../../main/ets/model/bean/SearchContactsSource'

export default function SearchContactsSourceTest() {
  describe('SearchContactsSourceTest', () => {
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
    it('SearchContactsSourceTest_totalCount', 0, () => {
      let gd = new SearchContactsSource();
      expect(gd.totalCount()).assertEqual(0)
    })
    it('SearchContactsSourceTest_refresh', 0, () => {
      let contactList: SearchContactResult[] = [];
      let gd = new SearchContactsSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(gd,gd.notifyDataReload);
      gd.refresh(contactList)
      mocker.verify('notifyDataReload',[]).once();
      mocker.clear(gd);
    })
    it('SearchContactsSourceTest_getData_001', 0, () => {
      let gd = new SearchContactsSource();
      expect(gd.getData(0)).assertEqual(null)
    })
    it('SearchContactsSourceTest_getData_002', 0, () => {
      let contactList: SearchContactResult[] = [];
      contactList.push(new SearchContactResult('aa', 'aa', 'aa', 'aa', 'aa', 'aa', [], [], 'aa', 'aa',
        [], [], 'aa', 'aa', [], [], 11, 'aa', 'aa', 'aa'));
      contactList.push(new SearchContactResult('bb', 'bb', 'bb', 'bb', 'bb', 'bb', [], [], 'bb', 'bb',
        [], [], 'bb', 'bb', [], [], 22, 'bb', 'bb', 'bb'));
      let searchContentsSource = new SearchContactsSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(searchContentsSource, searchContentsSource.notifyDataReload);
      searchContentsSource.refresh(contactList);
      expect(searchContentsSource.getData(0)).not().assertNull();
      mocker.clear(searchContentsSource);
    })
    it('SearchContactsSourceTest_getData_003', 0, () => {
      let contactList: SearchContactResult[] = [];
      contactList.push(new SearchContactResult('aa', 'aa', 'aa', 'aa', 'aa', 'aa', [], [], 'aa', 'aa',
        [], [], 'aa', 'aa', [], [], 11, 'aa', 'aa', 'aa'));
      contactList.push(new SearchContactResult('bb', 'bb', 'bb', 'bb', 'bb', 'bb', [], [], 'bb', 'bb',
        [], [], 'bb', 'bb', [], [], 22, 'bb', 'bb', 'bb'));
      let searchContentsSource = new SearchContactsSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(searchContentsSource, searchContentsSource.notifyDataReload);
      searchContentsSource.refresh(contactList);
      expect(searchContentsSource.getData(1)).not().assertNull();
      mocker.clear(searchContentsSource);
    })
  })
}