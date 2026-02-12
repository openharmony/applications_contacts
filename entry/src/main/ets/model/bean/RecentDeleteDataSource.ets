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
import BasicDataSource from './BasicDataSource';
import RecentDeleteBean from './RecentDeleteBean';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'RecentDeleteDataSource ';

export default class RecentDeleteDataSource extends BasicDataSource {
  public recentDeleteList: RecentDeleteBean[] = [];

  public totalCount(): number {
    return this.recentDeleteList.length;
  }

  public getRecentDeleteList(): RecentDeleteBean[] {
    return this.recentDeleteList;
  }

  public getData(index: number): RecentDeleteBean | null {
    if (ArrayUtil.isEmpty(this.recentDeleteList) || index >= this.recentDeleteList.length) {
      HiLog.i(TAG, 'getData recentDeleteList is empty');
      return null;
    } else {
      return this.recentDeleteList[index];
    }
  }

   public refresh(recentDeleteList: RecentDeleteBean[]): void {
     HiLog.w(TAG, 'refresh start!');
     this.recentDeleteList = recentDeleteList;
     this.notifyDataReload();
  }

  public remove(index: number, count?: number) {
    HiLog.w(TAG, `remove index: ${index}`);
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    this.recentDeleteList.splice(index, count ? count : 1);
    this.notifyDataReload();
  }

  public getRecentDeleteData(): RecentDeleteBean[] {
    return this.recentDeleteList;
  }

}