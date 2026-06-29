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
import { FavoriteListBean } from '../bean/FavoriteListBean';
import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { FavoriteBean } from './FavoriteBean';
import MorandiColor from './MorandiColor';
import { SearchContactResult } from '../bean/SearchContactResult';

const TAG = 'SearchContactsSource ';

export default class SearchContactsSource extends BasicDataSource {
  public contactList: SearchContactResult[] = [];
  public contactObj: Record<string, SearchContactResult[]> = {};
  public contactIndexObj: Record<string, number> = {};

  public totalCount(): number {
    return this.contactList.length;
  }

  public getData(index: number): FavoriteListBean | null {
    if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
      HiLog.i(TAG, 'getData contactlist is empty, index Greater than or equal to this.contactList.length: ' + (index >= this.contactList.length));
      HiLog.i(TAG, 'getDatathis.contactList.length: ' + this.contactList.length);
      return null;
    } else {
      let contact: SearchContactResult = this.contactList[index];
      let preContact: SearchContactResult = this.contactList[index - 1];
      let showIndex: boolean = (index === 0 || !(contact.sortFirstLetter === preContact.sortFirstLetter));
      let showDivider: boolean = false;
      if (index < this.contactList.length - 1) {
        let nextContact: SearchContactResult = this.contactList[index + 1];
        showDivider = (contact.sortFirstLetter === nextContact.sortFirstLetter);
      } else {
        showDivider = false;
      }
      let uselessObj: FavoriteBean = new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
      return new FavoriteListBean(index, showIndex, showDivider, uselessObj, contact);
    }
  }

  public refresh(contactList: SearchContactResult[]): void {
    HiLog.i(TAG, ' refresh!');
    this.contactList = contactList;
    this.notifyDataReload();
  }

}