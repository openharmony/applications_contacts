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
import BasicDataSource from './BasicDataSource';
import { FavoriteBean } from '../bean/FavoriteBean';
import { FavoriteListBean } from '../bean/FavoriteListBean';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import MorandiColor from './MorandiColor';
import { StringUtil } from '../../../../../../feature/call/oh_modules/common';
import { SearchContactResult } from './SearchContactResult';

const TAG = 'FavoriteDataSource ';

export default class FavoriteDataSource extends BasicDataSource {
  public favoriteList: FavoriteBean[] = [];
  public favoriteData: FavoriteListBean[] = [];
  public favoriteContactIdList: string[] = [];

  public totalCount(): number {
    return this.favoriteList.length;
  }

  /**
   * 详情页取消收藏,从datasource中删除对应的联系人
   *
   * @param contactId contactId
   */
  public deleteFavoriteContactId(contactId: string): void {
    HiLog.i(TAG, `deleteFavoriteContactId before ${contactId},${this.favoriteContactIdList?.length}`);
    if (!this.favoriteContactIdList.includes(contactId) || !contactId) {
      HiLog.i(TAG, 'deleteFavoriteContactId param invalid.');
      return;
    }
    this.favoriteContactIdList = this.favoriteContactIdList.filter(item => item !== contactId);
    HiLog.i(TAG, `deleteFavoriteContactId after ${contactId},${this.favoriteContactIdList?.length}`);
  }

  public bathDeleteFavoriteContactId(contactIds: string[]): void {
    contactIds.forEach(contactId => {
      this.deleteFavoriteContactId(contactId);
    })
  }

  public getFavoriteList(): FavoriteBean[] {
    return this.favoriteList;
  }

  public getData(index: number): FavoriteListBean | null {
    if (ArrayUtil.isEmpty(this.favoriteList) || index >= this.favoriteList.length) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      return this.favoriteData[index];
    }
  }

  public indexOf(item: FavoriteListBean): number {
    let index: number = -1;
    if (ArrayUtil.isEmpty(this.favoriteList)) {
      HiLog.w(TAG, 'getData favoriteList is empty');
      return index;
    } else {
      for (let i = 0; i < this.totalCount(); ++i) {
        const element: FavoriteListBean | null = this.favoriteData[i];
        if (item.favorite.contactId === element?.favorite.contactId) {
          index = i;
          break;
        }
      }
      return index;
    }
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    this.favoriteData.splice(index, count ? count : 1);
    this.favoriteList.splice(index, count ? count : 1);
    this.notifyDataDeleteOperation(index, count);
  }

  public refresh(favoriteList: FavoriteBean[]): void {
    HiLog.i(TAG, 'refresh!');
    if (ArrayUtil.isEmpty(favoriteList)) {
      HiLog.e(TAG, 'favoriteList is empty');
      return;
    }
    let favoriteData: FavoriteListBean[] = [];
    let favoriteContactIds: string[] = [];
    for (let index = 0; index < favoriteList.length; index++) {
      let favorite: FavoriteBean = favoriteList[index];
      let preContact: FavoriteBean = favoriteList[index - 1];
      let addContact: FavoriteBean = favoriteList[index + 1];
      let showIndex: boolean = (index === 0 || !(favorite.namePrefix === preContact.namePrefix));
      let showDivider: boolean = false;
      if (index < favoriteList.length - 1) {
        showDivider = !addContact.isUsuallyShow;
      } else {
        showDivider = false;
      }
      if (StringUtil.isEmpty(favorite.displayName as string)) {
        favorite.displayName = $r('app.string.noName');
      }
      let portraitColor: Resource = MorandiColor.color[0];
      let uselessObj: SearchContactResult =
        new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      let favoriteListBean = new FavoriteListBean(index, showIndex, showDivider, favorite, uselessObj);
      favoriteData.push(favoriteListBean);
      favoriteContactIds.push(favoriteList[index].contactId);
    }
    this.favoriteData = [...favoriteData];
    this.favoriteList = [...favoriteList];
    this.favoriteContactIdList = [...favoriteContactIds];
  }
}