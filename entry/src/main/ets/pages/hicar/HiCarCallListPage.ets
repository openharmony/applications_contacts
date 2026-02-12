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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { Constants } from '../../data/Constants';
import { ImageType } from '../../data/HiCarConstants';
import HiCarCallRecordPresenter from '../../presenter/dialer/callRecord/HiCarCallRecordPresenter';
import { BlankPage } from './HiCarCommonComponent';
import { HiCarRecordView } from './HiCarRecordView';

const TAG = 'HiCarCallListPage';

@Component
export default struct HiCarCallListPage {
  @StorageLink(Constants.KEY_CALL_LOG_LIST_EMPTY) callLogListEmpty: boolean = true;
  @State @Watch('onChanged') hiCarCallRecordPresenter: HiCarCallRecordPresenter = HiCarCallRecordPresenter.getInstance();
  @StorageLink(Constants.KEY_CALL_RECORD_INIT) @Watch('callRecordInitWatch') callRecordInit: boolean = false;

  /**
   * 通话记录变化时，判断是否清零了，清零了刷新界面显示空白page
   */
  private onChanged(): void {
    let callLogIsEmpty = this.hiCarCallRecordPresenter.mAllCallRecordListDataSource.totalCount() <= 0;
    if (this.callLogListEmpty !== callLogIsEmpty) {
      this.callLogListEmpty = callLogIsEmpty
    }
    if (!callLogIsEmpty) {
      this.callRecordInit = true;
    }
    HiLog.i(TAG, `callLogIsEmpty: ${callLogIsEmpty}, callRecordInit: ${this.callRecordInit}`);
  }

  callRecordInitWatch() {
    HiLog.i(TAG, `callRecordInit: ${this.callRecordInit}`);
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarCallListPage aboutToAppear');
    this.hiCarCallRecordPresenter.initDatabaseListener();
    this.hiCarCallRecordPresenter.bindUI(() => {
      this.hiCarCallRecordPresenter = HiCarCallRecordPresenter.getInstance();
    });
    this.onChanged();
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'HiCarCallListPage aboutToDisappear');
    this.hiCarCallRecordPresenter.releaseDatabaseListener();
  }

  build() {
    Column() {
      if (this.callRecordInit) {
        if (this.callLogListEmpty) {
          BlankPage({ headline: $r('app.string.no_dialer_calllog'), imageType: ImageType.NO_CALL_RECORDS });
        } else {
          HiCarRecordView({ mPresenter: $hiCarCallRecordPresenter });
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}




