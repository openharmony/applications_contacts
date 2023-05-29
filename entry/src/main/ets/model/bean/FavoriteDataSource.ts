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
import type { FavoriteBean } from '../bean/FavoriteBean';
import { FavoriteListBean } from '../bean/FavoriteListBean';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = 'FavoriteDataSource ';

export default class FavoriteDataSource extends BasicDataSource {
  private favoriteList: FavoriteBean[] = [];

  public totalCount(): number {
    return this.favoriteList.length;
  }

  public getFavoriteList(): FavoriteBean[] {
    return this.favoriteList;
  }

  public getData(index: number): FavoriteListBean {
    if (ArrayUtil.isEmpty(this.favoriteList) || index >= this.favoriteList.length) {
      HiLog.i(TAG, 'getData contactlist is empty');
      return null;
    } else {
      let favorite: FavoriteBean = this.favoriteList[index];
      let preContact: FavoriteBean = this.favoriteList[index - 1];
      let addContact: FavoriteBean = this.favoriteList[index + 1];
      let showIndex: boolean = (index === 0 || !(favorite.namePrefix === preContact.namePrefix));
      let showDivider: boolean = false;
      if (index < this.favoriteList.length - 1) {
        showDivider = !addContact.isUsuallyShow;
      } else {
        showDivider = false;
      }
      return new FavoriteListBean(index, showIndex, showDivider, favorite, null);
    }
  }

  public refresh(favoriteList: FavoriteBean[]): void {
    HiLog.i(TAG, 'refresh!');
    this.favoriteList = favoriteList;
    this.notifyDataReload();
  }
}