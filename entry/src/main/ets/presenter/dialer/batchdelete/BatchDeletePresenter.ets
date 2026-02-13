/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from '../../../../../../../common';
import {
    ContactsGlobalThisHelper
} from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import CallRecordListDataSource from '../../../model/bean/CallRecordListDataSource';
import LooseObject from '../../../model/type/LooseObject';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import CallRecordPresenter from '../callRecord/CallRecordPresenter';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { emitter } from '@kit.BasicServicesKit';


const TAG = 'BatchDeletePresenter';

export default class BatchDeletePresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  public static BATCH_DELETE_ITEM_CHECKED = 'BatchDeleteRecordChecked';
  private static mPresenter: BatchDeletePresenter;
  public callRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  public recordSelected: Map<number, string[]> = new Map();
  public allRecord: Array<LooseObject> = [];
  public isSelectAll: boolean = false;
  public selectedCount: number = 0;
  public mergeRule: string = 'time';
  public sceillOnlenth: number = 0;

  static getInstance() {
    if (BatchDeletePresenter.mPresenter == null) {
      BatchDeletePresenter.mPresenter = new BatchDeletePresenter();
    }
    return BatchDeletePresenter.mPresenter;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  back() {
    if ((AppStorage.get('breakpoint') === 'sm') ||
      (AppStorage.get('isShowSmartWindow') && !AppStorage.get('isNavigationModeSplit'))) {
      this.pathInfos?.clear(false);
    } else {
      HiLog.w(TAG, 'pathInfos back: DialerPad');
      CallRecordPresenter.getInstance().toDefaultPage();
    }
  }

  resetData() {
    this.isSelectAll = false;
    this.selectedCount = 0;
    this.recordSelected.clear();
  }

  initCallRecordData() {
    this.allRecord = this.callRecordListDataSource.getCallLogData();
    this.allRecord.forEach((item) => {
      item.checked = false;
    });
    this.callRecordListDataSource.refreshAll(this.allRecord);
  }

  itemOnClick(item: Record<string, string | number | boolean | Resource | string[]>) {
    let callLogId: number = item.id as number;
    let count: number = this.selectedCount;
    if (this.recordSelected.has(callLogId)) {
      count = count - Number(item.count);
      this.recordSelected.delete(callLogId);
      this.isSelectAll = false;
    } else {
      if (this.mergeRule === 'contacts') {
        this.recordSelected.set(callLogId, [item.phoneNumber] as string[]);
      } else {
        this.recordSelected.set(callLogId, item.ids as string[]);
      }
      count = count + (item.count as number);
      if (this.recordSelected.size === this.allRecord.length) {
        this.isSelectAll = true;
      }
    }
    this.selectedCount = count;
    let eventData: emitter.EventData = {
      data: { 'contactId': item.id }
    };
    emitter.emit(BatchDeletePresenter.BATCH_DELETE_ITEM_CHECKED, eventData);
  }

  checkAll() {
    this.isSelectAll = !this.isSelectAll;
    let selectedCount = 0;
    if (this.isSelectAll) {
      this.allRecord.forEach((item) => {
        item.checked = true;
        selectedCount += item.count;
        if (this.mergeRule === 'contacts') {
          this.recordSelected.set(item.id as number, [item.phoneNumber] as string[]);
        } else {
          this.recordSelected.set(item.id as number, item.ids as string[]);
        }
      });
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, selectedCount);
    } else {
      this.allRecord.forEach((item) => {
        item.checked = false;
      });
      this.recordSelected.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.selectedCount);
    }
    this.selectedCount = selectedCount;
    emitter.emit(BatchDeletePresenter.BATCH_DELETE_ITEM_CHECKED);
    this.callRecordListDataSource.replacehAll(this.allRecord);
  }

  async deleteEvent() {
    let deleteKeys: string[] = [];
    this.recordSelected.forEach((value: string[], key: number) => {
      deleteKeys = deleteKeys.concat(value);
    })
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteCallLogsById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: deleteKeys,
        phoneNumbers: deleteKeys,
      }, () => {
        HiLog.i(TAG, 'deleteEvent response');
        if (this.isSelectAll) {
          this.callRecordListDataSource.remove(0, this.allRecord.length - 1);
          AppStorage.SetOrCreate('clearAllRecord', true);
        } else {
          let recordArr = this.allRecord.filter((item) => {
            return !this.recordSelected.has(item.id as number);
          });
          this.allRecord = recordArr;
          this.callRecordListDataSource.refreshAll(this.allRecord);
        }
        this.recordSelected.clear();
        this.isSelectAll = false;
        this.selectedCount = 0;
        this.back();
      });
  }

  getDeleteDialogTitle(): Resource {
    let title: Resource;
    if (this.isSelectAll) {
      title = $r('app.string.delete_all_callLog_dialog_title');
    } else if (this.selectedCount === 1) {
      title = $r('app.string.deleteCallLog_dialog_title');
    } else {
      title = $r('app.plural.delete_callLog_dialog_title', this.selectedCount, this.selectedCount);
    }
    return title;
  }
}