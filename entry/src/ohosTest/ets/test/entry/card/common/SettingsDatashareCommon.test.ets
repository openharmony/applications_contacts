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
import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { SettingsDataStorage } from '../../../../../../main/ets/card/common/SettingsDatashareCommon';

export default function SettingsDatashareCommonTest() {
  describe('SettingsDatashareCommonTest', () => {
    let settingsDatashareCommon: SettingsDataStorage;

    beforeEach(() => {
      settingsDatashareCommon = new SettingsDataStorage();
    })

    it('SettingsDatashareCommonTest_initData', 0, async () => {
      settingsDatashareCommon.initData();
      expect(settingsDatashareCommon.str).assertEqual('test');
    })

    it('SettingsDatashareCommonTest_update', 0, async () => {
      settingsDatashareCommon.update('addIds', 'deleteIds');
      expect(settingsDatashareCommon.str).assertEqual('test');
    })
  })
}