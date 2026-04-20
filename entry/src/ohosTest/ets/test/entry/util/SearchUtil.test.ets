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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { SearchUtil } from '../../../../../main/ets/util/SearchUtil'

export default function SearchUtilTest() {
  describe('SearchUtilTest', () => {
    let searchUtil: SearchUtil;

    beforeEach(() => {
      searchUtil = new SearchUtil();
    })

    it('SearchUtilTest_getInstance', 0, () => {
      expect(typeof SearchUtil.getInstance()).assertEqual(typeof searchUtil);
    })

    it('SearchUtilTest_getSearchSession', 0, async () => {
      expect(typeof searchUtil.getSearchSession()).not().assertUndefined();
    })

    it('SearchUtilTest_initSearchSession', 0, async () => {
      expect(typeof searchUtil.initSearchSession()).not().assertUndefined();
    })
  })
}