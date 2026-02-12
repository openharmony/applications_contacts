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
import { HiLog } from '../../../../../../../common';
import ContactsPickerPage from './ContactsPickerPage';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit'

const TAG = 'BatchSelectContactsEntry';
/**
 * BatchSelectContacts Entry.
 */
let storage = LocalStorage.getShared()

@Entry(storage)
@Component
export default struct BatchSelectContactsEntry {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  @Builder
  myRouter(name: string) {
    if (name === 'BatchSelectContactsPage') {
      ContactsPickerPage();
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'BatchSelectContactsEntry aboutToAppear!');
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'BatchSelectContactsEntry aboutToDisappear!');
  }

  onPageShow() {
    HiLog.i(TAG, 'BatchSelectContactsEntry onPageShow')
    this.pathInfos.replacePathByName('BatchSelectContactsPage', '', false);
  }

  onPageHide() {
    HiLog.i(TAG, 'BatchSelectContactsEntry onPageCover')
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {

      }
    }
    .onNavBarStateChange((value: boolean) => {
      if (value) {
        this.onPageShow();
      } else {
        this.onPageHide();
      }
    })
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.myRouter)
  }
}