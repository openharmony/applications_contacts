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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { CountryIdUtil } from '../../../../../../../common/src/main/ets/util/CountryIdUtil'
import i18n from '@ohos.i18n'

export default function CountryIdUtilTest() {
  describe('CountryIdUtilTest', () => {
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

    it('CountryIdUtilTest_getCountryId', 0, () => {
      let mocker: MockKit = new MockKit();
      let getCountryIdForNetWork: Function = mocker.mockFunc(CountryIdUtil, CountryIdUtil.getCountryIdForNetWork);
      when(getCountryIdForNetWork)().afterReturn('UN');
      expect(CountryIdUtil.getCountryId()).assertEqual('UN');

      when(getCountryIdForNetWork)().afterReturn('');
      let getCountryIdForSim: Function = mocker.mockFunc(CountryIdUtil, CountryIdUtil.getCountryIdForSim);
      when(getCountryIdForSim)().afterReturn('UN');
      expect(CountryIdUtil.getCountryId()).assertEqual('UN');

      when(getCountryIdForSim)().afterReturn('');
      let getCountryIdSysReg: Function = mocker.mockFunc(CountryIdUtil, CountryIdUtil.getCountryIdSysReg);
      when(getCountryIdSysReg)().afterReturn('UN');
      expect(CountryIdUtil.getCountryId()).assertEqual('UN');

      when(getCountryIdSysReg)().afterReturn('');
      expect(CountryIdUtil.getCountryId()).assertEqual('CN');
      mocker.clear(CountryIdUtil);
    })

    it('getCountryId_default_CN', 0, () => {
      let country = CountryIdUtil.getCountryId();
      expect(country).assertEqual('CN');
    })
  })
}