/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { HiLog, ArrayUtil } from '../../../../../../../common';
import ContactsPickerPage from './ContactsPickerPage';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit'

const TAG = 'SingleSelectContactsEntry';
/**
 * SingleSelectContacts Entry
 */
let storage = LocalStorage.GetShared()

@Entry(storage)
@Component
export default struct SingleSelectContactsEntry {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  @Builder
  myRouter(name: string) {
    if (name === 'SingleSelectContactPage') {
      ContactsPickerPage({ isContactMultiSelect: false });
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'SingleSelectContactsEntry aboutToAppear!');
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'SingleSelectContactsEntry aboutToDisappear!');
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        ContactsPickerPage({ isContactMultiSelect: false })
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.myRouter)
  }
}