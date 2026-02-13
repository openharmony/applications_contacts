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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium'
import SearchContactListItem from '../../../../../../../../feature/contact/src/main/ets/repo/SearchContactListItem'
import { AlphabetIndexObj, ContactVo } from '../../../../../../main/ets/model/bean/ContactVo'
import { paramsInterface } from '../../../../../../main/ets/model/type'
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  ContactFormModel,
  ContactResultSetQueryParams,
  ContactSearchResultData,
  CountAlphabetIndex,
  FavoriteFormType,
  NameFixInfo,
  SendMessageParams,
  targetPageClass
} from '../../../../../../main/ets/model/type/ContactParams'

export default function ContactParamsTest() {
  describe('ContactParamsTest', () => {
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
    it('ContactParamsTest_constructorAllContactGetParam', 0, () => {
      let cb = new AllContactGetParam(2, 3);
      expect(cb.page).assertEqual(2)
    })
    it('ContactParamsTest_constructorAllContactWithPhoneNumbersGetParam_001', 0, () => {
      let cb = new AllContactWithPhoneNumbersGetParam(2, 3);
      expect(cb.favorite).assertEqual(2)
    })
    it('ContactParamsTest_constructorAllContactWithPhoneNumbersGetParam_002', 0, () => {
      let cb = new AllContactWithPhoneNumbersGetParam(3, 3, 1, '1', 6);
      expect(cb.favorite).assertEqual(3)
    })
    it('ContactParamsTest_constructorContactResultSetQueryParams', 0, () => {
      let resultList: ContactVo[] = [];
      let alphabetIndex: Record<string, AlphabetIndexObj> = {};
      let cb = new ContactResultSetQueryParams(resultList, alphabetIndex);
      expect(cb.resultList.toString()).assertEqual(resultList.toString())
    })
    it('ContactParamsTest_constructorNameFixInfo', 0, () => {
      let cb = new NameFixInfo("1231", "23");
      expect(cb.namePrefix).assertEqual("1231")
    })
    it('ContactParamsTest_constructorCountAlphabetIndex', 0, () => {
      let alphabetIndex: Record<string, AlphabetIndexObj> = {};
      let cb = new CountAlphabetIndex(2, alphabetIndex);
      expect(cb.count).assertEqual(2)
    })
    it('ContactParamsTest_constructorContactSearchResultData', 0, () => {
      let data: Array<SearchContactListItem> = [];
      let cb = new ContactSearchResultData(2, data, "13");
      expect(cb.total).assertEqual(2)
    })
    it('ContactParamsTest_constructortargetPageClass', 0, () => {
      let params: paramsInterface = {};
      let cb = new targetPageClass("1231", 2, params);
      expect(cb.pageIndex).assertEqual(2)
    })
    it('ContactParamsTest_constructorSendMessageParams', 0, () => {
      let cb = new SendMessageParams("1231111", "23");
      expect(cb.telephone).assertEqual("1231111")
    })
    it('ContactParamsTest_constructorContactFormModel', 0, () => {
      let cfm = new ContactFormModel();
      expect(cfm.contactId).assertEqual(-1);
    })
    it('ContactParamsTest_constructorFavoriteFormType', 0, () => {
      let fft = new FavoriteFormType();
      expect(fft.favorite).assertEqual(-1);
    })
  })
}