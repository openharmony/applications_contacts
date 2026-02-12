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
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { FormEditExtensionAbility } from '@kit.FormKit';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ExtensionEvent } from '../model/FormExtensionEvent';

const TAG = 'FormEditExtensionAbility';

export default class FaFormEditExtensionAbility extends FormEditExtensionAbility {
  public storage: LocalStorage = new LocalStorage();

  onCreate() {
    HiLog.i(TAG, `Ability onCreate`);
  }
  onForeground(): void {
    HiLog.i(TAG, `Ability onForeground`);
  }
  onBackground(): void {
    HiLog.i(TAG, `Ability onBackground`);
  }
  onDestroy(): void {
    HiLog.i(TAG, `Ability onDestroy`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    let extensionEvent: ExtensionEvent = new ExtensionEvent();
    this.storage.setOrCreate('extensionEvent', extensionEvent);
    this.storage.setOrCreate('session', session);

    try {
      session.loadContent('card/pages/ContactPicker', this.storage);
      HiLog.i(TAG, `loadContent first edit page success`);
      session.setWindowBackgroundColor('#00000000');
    } catch (e) {
      HiLog.e(TAG, `EntryFormEditAbility loadContent err, want: ${e?.message}`);
    }
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `onSessionDestroy`);
  }

}

