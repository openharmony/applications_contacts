/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactPickerListItem } from '../type/ContactParams';

const TAG = 'ContactPickerDataSource';

export default class ContactPickerDataSource extends BasicDataSource {
  public contactList: ContactPickerListItem[] = [];

  public totalCount(): number {
    return this.contactList.length;
  }

  public getData(index: number): ContactPickerListItem | null {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length || index < 0) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let contact: ContactPickerListItem = this.contactList[index];
      let preContact: ContactPickerListItem = this.contactList[index - 1];
      let showIndex: boolean = (index === 0 || (contact.namePrefix !== preContact.namePrefix));
      let isFirst: boolean = (index === 0 || (contact.contactId !== preContact.contactId));
      let showDivifer: boolean = false;
      if (contact.isFavorite) {
        showDivifer = true;
      } else if (index < this.contactList.length - 1) {
        let nextContact: ContactPickerListItem = this.contactList[index + 1];
        showDivifer = (contact.namePrefix === nextContact.namePrefix);
      } else {
        showDivifer = false;
      }
      if (StringUtil.isEmpty(contact.displayName)) {
        contact.displayName = ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()
          .resourceManager
          .getStringSync($r('app.string.noName').id);
      }
      contact.showIndex = showIndex;
      contact.showDivifer = showDivifer;
      contact.isFirst = isFirst;
      return contact;
    }
  }

  public refresh(contactList: ContactPickerListItem[]) {
    HiLog.i(TAG, ' refresh!');
    this.contactList = contactList;
    this.notifyDataReload();
  }
}