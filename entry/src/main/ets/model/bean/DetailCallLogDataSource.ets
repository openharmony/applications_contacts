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
import LooseObject from '../type/LooseObject';
import CallDetail from './CallDetail';

const TAG = 'DetailCallLogDataSource';

export default class DetailCallLogDataSource extends BasicDataSource {
  private detailCallLogList: CallDetail[] = [];

  public totalCount(): number {
    return this.detailCallLogList.length;
  }

  public getData(index: number): null | LooseObject {
    if (ArrayUtil.isEmpty(this.detailCallLogList) || index >= this.detailCallLogList.length) {
      HiLog.i(TAG, 'getData detailCallLogList is empty');
      return null;
    } else {
      let callLog = this.detailCallLogList[index];
      let showTitle = false;
      if (index == 0) {
        showTitle = true;
      }
      let item: LooseObject = {
        callLog: callLog,
        showTitle: showTitle
      }
      return item;
    }
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    this.detailCallLogList.splice(index, count ? count : 1);
    this.notifyDataReload();
  }

  public removeById(id: string) {
    for (let i = 0; i < this.detailCallLogList.length; ++i) {
      let item = this.detailCallLogList[i];
      if (item.id === id) {
        this.detailCallLogList.splice(i, 1);
        this.notifyDataReload();
        break;
      }
    }
  }

  public refresh(start: number, callLog: CallDetail[], isEnd: boolean) {
    HiLog.i(TAG, ' refresh!');
    this.detailCallLogList.splice(start, isEnd ? this.detailCallLogList.length : callLog.length, ...callLog);
    this.notifyDataReload();
  }

  public getAllData(): CallDetail[] {
    return this.detailCallLogList;
  }
}