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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import { Configuration } from '@ohos.app.ability.Configuration';

/* instrument ignore file */


/**
 * privacy management of Ability.
 */
export default class PrivacyAbility extends UIExtensionAbility {
  /* instrument ignore file */
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    // Main window is created, set main page for this ability
    let param: Record<string, Object> = {
      'session': session
    }

    ContactsGlobalThisHelper.GetGlobalThis()
      .set(ContactsGlobalThisHelper.UIContextName, this.context)

    let storage: LocalStorage = new LocalStorage(param);
    AppStorage.setOrCreate('currentColorMode', this.context?.config?.colorMode);
    session.loadContent('pages/privacyStatement/privacyIndex', storage);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }
}