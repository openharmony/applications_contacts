/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { ContactVo } from '../bean/ContactVo';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import HiCarContactListShowInfo from './HiCarContactListShowInfo';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import BasicDataSource from './BasicDataSource';
import { Favorite } from '../../data/Constants';

const TAG = 'HiCarContactListDataSource';

export default class HiCarContactListDataSource extends BasicDataSource {
  public contactList: ContactVo[] = [];

  public totalCount(): number {
    return this.contactList.length;
  }

  private getIsShowContactDivifer(contact: ContactVo, index: number): boolean {
    let isShowContactDivifer: boolean = false;
    if (index === this.contactList.length - 1) {
      return isShowContactDivifer;
    }
    if (contact.favorite === Favorite.FALSE) {
      let nextIndex = index;
      while (nextIndex < this.contactList.length - 1) {
        nextIndex++;
        if (this.contactList[nextIndex].favorite === Favorite.FALSE) {
          break;
        }
      }
      if (this.contactList[nextIndex].favorite === Favorite.FALSE) {
        isShowContactDivifer = (contact.namePrefix === this.contactList[nextIndex].namePrefix);
      } else {
        isShowContactDivifer = false;
      }
    }
    return isShowContactDivifer;
  }

  private getIsShowIndex(index: number, contact: ContactVo): boolean {
    let isShowIndex = false;
    if (contact.favorite === Favorite.FALSE) {
      if (index === 0) {
        return true;
      }
      let preIndex = index;
      while (preIndex > 0) {
        preIndex--;
        if (this.contactList[preIndex].favorite === Favorite.FALSE) {
          break;
        }
      }
      if (this.contactList[preIndex].favorite === Favorite.FALSE) {
        isShowIndex = contact.namePrefix !== this.contactList[preIndex].namePrefix;
      } else {
        isShowIndex = true;
      }
    }
    return isShowIndex;
  }

  /**
   * 获取元素位获取LooseObject
   * @param index
   * @returns
   */
  public getData(index: number): HiCarContactListShowInfo | null {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let contact: ContactVo = this.contactList[index];
      // 当前联系人名字首字母和上个联系人不同，显示首字母
      let isShowIndex: boolean = this.getIsShowIndex(index, contact);
      // 显示hicar联系人下划线
      const isShowContactDivifer = this.getIsShowContactDivifer(contact, index);
      // 显示名字信息
      contact.title = (StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName);
      if (StringUtil.isEmpty(contact.title)) {
        contact.title = ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()
          .resourceManager
          .getStringSync($r('app.string.noName').id);
      }
      return new HiCarContactListShowInfo(isShowIndex, contact.title, contact.contactId, contact.namePrefix,
        contact.favorite, isShowContactDivifer);
    }
  }

  public refresh(start: number, contactList: ContactVo[], isEnd: boolean): void {
    HiLog.i(TAG, ' refresh!');
    this.contactList.splice(start, isEnd ? this.contactList.length : contactList.length, ...contactList);
    this.notifyDataReload();
  }
}