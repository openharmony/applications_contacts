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
import { ContactVo } from './ContactVo';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import LooseObject from '../type/LooseObject';
import { StringUtil } from '../../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'BatchSelectFavoriteSource';

export default class BatchSelectFavoriteSource extends BasicDataSource {
  public contactList: ContactVo[] = [];

  public totalCount(): number {
    return this.contactList.length;
  }

  public getData(index: number): LooseObject | undefined | null {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let contact: ContactVo = this.contactList[index];
      let preContact: ContactVo = this.contactList[index - 1];
      let showIndex: boolean = (index == 0 || !(contact.namePrefix === preContact.namePrefix));
      let showDivifer: boolean = false;
      if (index < this.contactList.length - 1) {
        let nextContact: ContactVo = this.contactList[index + 1];
        showDivifer = (contact.namePrefix === nextContact.namePrefix);
      } else {
        showDivifer = false;
      }
      contact.title = (StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName);
      if (StringUtil.isEmpty(contact.title)) {
        contact.title = ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()
          .resourceManager
          .getStringSync($r('app.string.noName').id);
      }
      return {
        showIndex: showIndex,
        showDivifer: showDivifer,
        contact: contact,
        index: index
      };
    }
  }

  public refresh(contactList: ContactVo[]) {
    HiLog.i(TAG, ' refresh!');
    this.contactList = contactList;
    this.notifyDataReload();
  }
}