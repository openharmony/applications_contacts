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
import { CallLogService } from '../../../../../../feature/call';
import StringFormatUtil from '../../util/StringFormatUtil';

const TAG = 'CallRecordListDataSource';

export default class CallRecordListDataSource extends BasicDataSource {
  private callLogData: LooseObject[] = [];
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
      let callLog = this.callLogData[index];
      if (callLog.createTimeSource) {
        callLog.createTime = CallLogService.getInstance().formatTime(callLog.createTimeSource as number) as string;
        callLog.createTimeAccessibilityText =
          StringFormatUtil.getAccessibilityTextByTime(callLog.createTimeSource) as string;
      }
      return callLog;
    }
  }

  public getCallRecord(index: number): LooseObject | null {
    if (ArrayUtil.isEmpty(this.callLogData) || index >= this.callLogData.length) {
      HiLog.w(TAG, 'getCallRecord callLogData is empty');
      return null;
    } else {
      let callLog = this.callLogData[index];
      return callLog;
    }
  }

  public indexOf(item: LooseObject): number {
    let index: number = -1;
    for (let i = 0; i < this.callLogData.length; ++i) {
      if (item.id === this.callLogData[i].id) {
        index = i;
        break;
      }
    }
    return index;
  }

  /**
   * 刷新通话记录
   * @param callLogData
   * @param isNeedGetLocation 是否需要获取归属地信息
   */
  public refreshAll(callLogData: LooseObject[]) {
    HiLog.w(TAG, ' refreshAll callLogData length is ' + callLogData.length);
    this.callLogData = callLogData;
    this.setDataReload(true);
    this.notifyDataReload();
  }

  /**
   * 刷新通话记录
   * @param callLogData
   * @param isNeedGetLocation 是否需要获取归属地信息
   */
  public replacehAll(callLogData: LooseObject[]) {
    HiLog.w(TAG, ' refreshAll callLogData length is ' + callLogData.length);
    this.callLogData = callLogData;
  }

  public setIsShow(isShow: boolean) {
    if (this.isShow == isShow) {
      return;
    }
    this.isShow = isShow;
    HiLog.w(TAG, ' setIsShow:' + this.isShow);
    this.setDataReload(this.isDataReload);
  }

  public refresh(start: number, callLogData: MergedCallLog[], isEnd: boolean) {
    HiLog.w(TAG, ' refresh!' + ' time:' + (new Date()).valueOf());
    this.callLogData.splice(start, isEnd ? this.totalCount() : callLogData.length, ...callLogData);
    this.setDataReload(true);
  }

  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    HiLog.w(TAG, ' remove:' + index);
    this.callLogData.splice(index, count ? count : 1);
    this.notifyDataReload();
  }

  public setDataReload(isDataReload: boolean) {
    if (this.isShow) {
      if (isDataReload) {
        HiLog.w(TAG, 'notifyDataReload time:' + (new Date()).valueOf());
        this.notifyDataReload();
      }
      this.isDataReload = false;
    } else {
      this.isDataReload = isDataReload;
    }
  }

  /**
   * 删除通话记录DataSource
   *
   * @param ids 通话记录id
   */
  public removeCallLog(ids: string[]) {
    if (!ids || ids.length === 0) {
      HiLog.e(TAG, `removeCallLog ids empty.`);
      return;
    }
    HiLog.w(TAG, `before removeCallLog ids=${this.callLogData?.length}`);
    this.callLogData = this.callLogData.filter(item => !ids.includes((item as MergedCallLog).id.toString()));
    HiLog.w(TAG, `after removeCallLog ids=${this.callLogData?.length}`);
    this.notifyDataReload();
  }

  public getCallLogData() {
    return this.callLogData;
  }

  public clean() {
    HiLog.w(TAG, 'clean');
    this.callLogData = [];
    this.isShow = false;
    this.isDataReload = false;
  }
}