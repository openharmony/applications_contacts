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
import { ContactVo } from '../bean/ContactVo';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import ContactListShowInfo from './ContactListShowInfo';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'ContactListDataSource';

export default class ContactListDataSource extends BasicDataSource {
  public contactList: ContactVo[] = [];
  private currentIndex: Array<number> = [];
  private cachedCount: number = 3;

  setCurrentIndex(start: number, end: number) {
    this.currentIndex = [start, end]
  }

  public totalCount(): number {
    return this.contactList.length;
  }

  /**
   * 获取元素位获取LooseObject
   * @param index
   * @returns
   */
  public getData(index: number): ContactListShowInfo | null {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
      HiLog.w(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let contact: ContactVo = this.contactList[index];
      let preContact: ContactVo = this.contactList[index - 1];
      // 当前联系人名字首字母和上个联系人不同，显示首字母
      let showIndex: boolean = (index == 0 || !(contact.namePrefix == preContact.namePrefix));
      // 显示下划线
      let showDivifer: boolean = false;
      if (index < this.contactList.length - 1) {
        let nextContact: ContactVo = this.contactList[index + 1];
        showDivifer = (contact.namePrefix == nextContact.namePrefix);
      } else {
        showDivifer = false;
      }
      // 显示名字信息
      contact.title = (StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName);
      if (StringUtil.isEmpty(contact.company)) {
        contact.subTitle = StringUtil.isEmpty(contact.position) ? '' : contact.position;
      } else {
        contact.subTitle =
          contact.company.concat(' ').concat(StringUtil.isEmpty(contact.position) ? '' : contact.position);
      }
      return new ContactListShowInfo(showIndex, showDivifer, contact.contactId, contact.nameRawContactId,
        contact.headChar, contact.portraitPath, contact.namePrefix, contact.title, contact.subTitle);
    }
  }

  public refreshAll(contactList: ContactVo[]) {
    HiLog.w(TAG, ' refreshAll!');
    this.contactList = contactList;
    this.notifyDataReload();
  }

  /**
   * 页面销毁清理datasource
   */
  public clearData() {
    HiLog.w(TAG, ' clearData!');
    this.contactList = [];
  }

  public refresh(start: number, contactList: ContactVo[], isEnd: boolean) {
    HiLog.w(TAG, ' refresh!');
    this.contactList.splice(start, isEnd ? this.contactList.length : contactList.length, ...contactList);
    this.notifyDataReload();
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      HiLog.e(TAG, `remove index: ${index},contactId=${this.totalCount()}`)
      return;
    }
    HiLog.w(TAG, ' remove:' + index);
    this.contactList.splice(index, count ? count : 1);
    this.notifyDataReload();
  }

  public removeIndex(index: number, count?: number): void {
    if (index < 0 || index >= this.totalCount()) {
      HiLog.e(TAG, `removeIndex index: ${index},contactId=${this.totalCount()}`)
      return;
    }
    HiLog.w(TAG, ' removeIndex:' + index);
    this.contactList.splice(index, count ? count : 1);
    this.notifyDataDelete(index);
  }

  public getIndexByContactId(contactId: number): number {
    HiLog.w(TAG, ' removeContactId:' + contactId);
    let index = -1;
    for (let i = 0; i < this.contactList.length; ++i) {
      if (this.contactList[i].contactId === contactId.toString()) {
        index = i;
        break;
      }
    }
    return index;
  }

  public getCurrentPage(): number {
    if (this.currentIndex.length > 1) {
      return ArrayUtil.getCurrentPage(this.currentIndex[1]);
    }
    return 1;
  }
}