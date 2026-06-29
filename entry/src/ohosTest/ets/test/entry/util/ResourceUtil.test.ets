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
import { ResourceUtil } from '../../../../../main/ets/util/ResourceUtil'
import common from '@ohos.app.ability.common'
import { DTGlobalContext } from '../../../testability/TestAbility'
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper'

export default function ResourceUtilTest() {
  describe('ResourceUtilTest', () => {
    let context: common.UIAbilityContext;
    beforeAll(() => {
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      context = DTGlobalContext.getContext().getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
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
    it('Contacts_ResourceUtilTest_resourceToStringById_002', 0, () => {
      expect(ResourceUtil.resourceToStringById('123')).assertEqual('123');
    })
  })
}