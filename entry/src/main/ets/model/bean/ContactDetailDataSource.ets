/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

const TAG = 'ContactDetailDataSource';



export default class ContactDetailDataSource<T> extends BasicDataSource {
  private mData: T[] = [];

  public totalCount(): number {
    return this.mData.length;
  }

  public getData(index: number): LooseObject | null {
    if (ArrayUtil.isEmpty(this.mData) || index >= this.mData.length || index < 0) {
      HiLog.i(TAG, 'getData empty or index err');
      return null;
    } else {
      return {
        index: index, data: JSON.stringify(this.mData[index])
      };
    }
  }

  public getAllData() {
    return this.mData;
  }

  public refresh(data: Array<T>): void {
    if (!ArrayUtil.isEmpty(data)) {
      this.mData = data;

    } else {
      this.mData = [];
    }

    this.notifyDataReload();
  }
}