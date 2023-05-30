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
import { SearchContactsBean } from '../bean/SearchContactsBean';
import { FavoriteListBean } from '../bean/FavoriteListBean';
import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = 'SearchContactsSource ';

export default class SearchContactsSource extends BasicDataSource {
  private contactList: SearchContactsBean[] = [];
  public contactObj: { [key: string]: SearchContactsBean[] } = {};
  public contactIndexObj: { [key: string]: number } = {};

  public totalCount(): number {
    return this.contactList.length;
  }

  public getData(index: number): FavoriteListBean {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let contact: SearchContactsBean = this.contactList[index];
      let preContact: SearchContactsBean = this.contactList[index - 1];
      let showIndex: boolean = (index === 0 || !(contact.sortFirstLetter === preContact.sortFirstLetter));
      let showDivider: boolean = false;
      if (index < this.contactList.length - 1) {
        let nextContact: SearchContactsBean = this.contactList[index + 1];
        showDivider = (contact.sortFirstLetter === nextContact.sortFirstLetter);
      } else {
        showDivider = false;
      }
      return new FavoriteListBean(index, showIndex, showDivider, null, contact);
    }
  }

  public refresh(contactList: SearchContactsBean[]): void {
    HiLog.i(TAG, ' refresh!');
    this.contactList = contactList;
    this.notifyDataReload();
  }
}