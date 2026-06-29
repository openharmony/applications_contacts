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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import { PermissionManager } from '../../../../../../../feature/call/oh_modules/common';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';


export default function PermissionManagerTest() {
  describe('PermissionManagerTest', () => {
    it('PermissionManagerTest_isAllPermissionsGranted', 0, () => {
      const _isAllPermissionsGranted = PermissionManager.getInstance().isAllPermissionsGranted();
      expect(_isAllPermissionsGranted).assertFalse();
    })

    it('PermissionManagerTest_initPermission', 0, async () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      await PermissionManager.getInstance().initPermissions();

      expect(PermissionManager.getInstance().isAllPermissionsGranted()).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
  })
}