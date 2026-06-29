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
import ContactDetail from './ContactDetail';
import Accountants from '../accountants/Accountants';
import CallRecord from '../../dialer/callRecord/CallRecord';
import DialerTablet from '../../dialer/DialerTablet';
import editFavoriteList from '../../favorites/editFavoriteList';
import BatchDeleteRecord from '../../dialer/batchdelete/BatchDeleteRecord';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import BatchDeletePresenter from '../../../presenter/dialer/batchdelete/BatchDeletePresenter';
import EditFavoriteListPresenter from '../../../presenter/favorite/EditFavoriteListPresenter';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import FavoriteListPresenter from '../../../presenter/favorite/FavoriteListPresenter';
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import ContactsPickerPage from '../batchselectcontacts/ContactsPickerPage';


const TAG = 'ContactDetailEntry';
/**
 * Contact list Entry
 */
let storage = LocalStorage.GetShared()

@Entry(storage)
@Component
export default struct ContactDetailEntry {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @State mAccountantsPresenter: AccountantsPresenter = new AccountantsPresenter();
  mDialerPresenter: DialerPresenter = DialerPresenter.getInstance();
  mBatchDeletePresenter: BatchDeletePresenter = BatchDeletePresenter.getInstance();
  mEditFavoriteListPresenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
  mContactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  mCallRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @State isShowAccountants : boolean = false;
  private controller: TabsController = new TabsController();
  private listScroller: ListScroller = new ListScroller();

  @Builder
  myRouter(name: string) {
    if (name === 'Accountants') {
      Accountants({isShowAccountants:$isShowAccountants});
    } else if (name === 'CallRecord') {
      CallRecord({ controller: this.controller, listScroller: this.listScroller });
    } else if (name === 'ContactDetail') {
      ContactDetail();
    } else if (name === 'DialerTablet') {
      DialerTablet();
    } else if (name === 'BatchSelectContactsPage') {
      ContactsPickerPage();
    } else if (name === 'SingleSelectContactPage') {
      ContactsPickerPage({ isContactMultiSelect: false });
    } else if (name === 'editFavoriteList') {
      editFavoriteList();
    } else if (name === 'BatchDeleteRecord') {
      BatchDeleteRecord();
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'ContactDetailEntry aboutToAppear!');
    this.mDialerPresenter.pathInfos = this.pathInfos;
    this.mBatchDeletePresenter.pathInfos = this.pathInfos;
    this.mEditFavoriteListPresenter.pathInfos = this.pathInfos;
    this.mContactListPresenter.pathInfos = this.pathInfos;
    this.mCallRecordPresenter.pathInfos = this.pathInfos;
    this.mFavoriteListPresenter.pathInfos = this.pathInfos;
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'ContactDetailEntry aboutToDisappear!');
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        ContactDetail()
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.myRouter)
  }
}