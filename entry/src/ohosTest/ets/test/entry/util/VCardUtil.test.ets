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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import VCardUtil from '../../../../../main/ets/util/VCardUtil';
import dataSharePredicates from '@ohos.data.dataSharePredicates';

export default function VCardUtilTest() {
  describe('VCardUtilTest', () => {
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
    it('VCardUtilTest_importVCard', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      VCardUtil.importVCard(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        '/data/storage/el4/base/files/00001.vcf', 0, () => {});
      expect(VCardUtil.resultDT).assertEqual('');
    })
    it('VCardUtilTest_exportVCard', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let predicates = new dataSharePredicates.DataSharePredicates()
      predicates.notEqualTo('is_deleted', 1);
      VCardUtil.exportVCard(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), predicates, () => {});
      expect(VCardUtil.resultDT).assertEqual('');
    })

    it('VCardUtilTest_transPatterns', 0, () => {
      let result = VCardUtil.transPatterns(['X-GOOGLE-TALK', 'X-HUANLIAO'].toString(), 1);
      expect(result).assertEqual('X-GOOGLE-TALK,X-GOOGLE-TALK')
    })

  })
}