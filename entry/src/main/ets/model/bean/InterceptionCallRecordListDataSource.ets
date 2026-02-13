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
import MergedCallLog from '../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import LooseObject from '../type/LooseObject';

const TAG = 'InterceptionCallRecordListDataSource';

export default class InterceptionCallRecordListDataSource extends BasicDataSource {
  private callLogData: MergedCallLog[] = [];
  private isShow: boolean = false;
  private isDataReload: boolean = false;

  public totalCount(): number {
    return this.callLogData.length;
  }

  public getData(index: number): LooseObject | null {
    if (ArrayUtil.isEmpty(this.callLogData) || index >= this.callLogData.length) {
      HiLog.w(TAG, 'getData callLogData is empty');
      return null;
    } else {
      let callLog: MergedCallLog = this.callLogData[index] as MergedCallLog;
      let preCallLog: MergedCallLog = this.callLogData[index - 1] as MergedCallLog;
      let showTimeIndex: boolean = (index == 0 ||
        !(callLog.createInterceptionTime.toString() === preCallLog.createInterceptionTime.toString()));
      let showDivider: boolean = false;
      if (index < this.callLogData.length - 1) {
        let nextCallLog: MergedCallLog = this.callLogData[index + 1];
        showDivider = (callLog.createInterceptionTime.toString() === nextCallLog.createInterceptionTime.toString());
      } else {
        showDivider = false;
      }
      return {
        showIndex: showTimeIndex,
        showDivider: showDivider,
        callLogData: callLog
      };
    }
  }

  /**
   * 刷新记录
   * @param callLogData
   */
  public refreshAll(callLogData: MergedCallLog[]) {
    HiLog.i(TAG, ' refreshAll callLogData length is ' + callLogData.length);
    this.callLogData = callLogData;
    this.setDataReload(true);
    this.notifyDataReload();
  }

  public setIsShow(isShow: boolean) {
    if (this.isShow == isShow) {
      return;
    }
    this.isShow = isShow;
    HiLog.i(TAG, ' setIsShow:' + this.isShow);
    this.setDataReload(this.isDataReload);
  }

  public refresh(start: number, callLogData: MergedCallLog[], isEnd: boolean) {
    this.callLogData.splice(start, isEnd ? this.totalCount() : callLogData.length, ...callLogData);
    HiLog.i(TAG, 'refresh!' + this.callLogData.length);
    this.setDataReload(true);
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    HiLog.i(TAG, 'remove:' + index);
    this.callLogData.splice(index, count ? count : 1);
    this.notifyDataDelete(index);
  }

  private setDataReload(isDataReload: boolean) {
    if (this.isShow) {
      if (isDataReload) {
        HiLog.i(TAG, 'notifyDataReload');
        this.notifyDataReload();
      }
      this.isDataReload = false;
    } else {
      this.isDataReload = isDataReload;
    }
  }

  public getCallLogData() {
    return this.callLogData;
  }

  public clean(): void {
    this.callLogData = [];
    this.isShow = false;
    this.isDataReload = false;
  }
}