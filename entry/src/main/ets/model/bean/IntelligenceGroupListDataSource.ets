/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { IntelligenceGroupInfo } from './GroupBean';

const TAG = 'IntelligenceGroupListDataSource';

export default class IntelligenceGroupListDataSource extends BasicDataSource {
  public groupList: IntelligenceGroupInfo[] = [];

  public totalCount(): number {
    return this.groupList.length;
  }

  public getGroupList(): IntelligenceGroupInfo[] {
    return this.groupList;
  }

  public getData(index: number): IntelligenceGroupInfo | null {
    if (ArrayUtil.isEmpty(this.groupList) || index >= this.groupList.length) {
      HiLog.i(TAG, 'getData groupList is empty');
      return null;
    } else {
      let group: IntelligenceGroupInfo = this.groupList[index];
      return group
    }
  }

  public refresh(groupList: IntelligenceGroupInfo[]): void {
    HiLog.i(TAG, 'refresh!');
    this.groupList = groupList;
    this.notifyDataReload();
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    HiLog.i(TAG, ' remove:' + index);
    this.groupList.splice(index, count ? count : 1);
    this.notifyDataReload();
  }

  public getGroupData() {
    return this.groupList;
  }

  /**
   * 页面销毁清理datasource
   */
  public clearData() {
    HiLog.w(TAG, ' cleargroupData!');
    this.groupList = [];
  }
}