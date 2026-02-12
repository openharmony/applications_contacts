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
import { describe, expect, it, MockKit } from '@ohos/hypium';
import AccessibilityUtil from '../../../../../main/ets/util/AccessibilityUtil';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common'

const TAG = 'AccessibilityUtil'

export default function AccessibilityUtilTest() {
  describe('AccessibilityUtilTest', () => {

    it("AccessibilityUtilTest_setAccessibilityPluralStringValueSync_false", 0, () => {
      expect(AccessibilityUtil.getInstance().setAccessibilityPluralStringValueSync(false, $r('app.string.accessibility_delete'), 1)).assertEqual('')
    })

    it("AccessibilityUtilTest_setAccessibilityText_false", 0, () => {
      expect(AccessibilityUtil.getInstance().setAccessibilityText(false, $r('app.string.accessibility_delete'))).assertEqual('')
    })

    it('AccessibilityUtilTest_setAccessibilityTextStr', 0, () => {
      expect(AccessibilityUtil.getInstance().setAccessibilityTextStr(true, 'str')).assertEqual('str');
      expect(AccessibilityUtil.getInstance().setAccessibilityTextStr(false, 'str')).assertEqual('');
    })

    it('AccessibilityUtilTest_releaseAccessibility', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      AccessibilityUtil.getInstance().releaseAccessibility();
      mocker.verify('e', [TAG, 'releaseAccessibility...']).never();
      mocker.clear(HiLog);
    })
  })

}