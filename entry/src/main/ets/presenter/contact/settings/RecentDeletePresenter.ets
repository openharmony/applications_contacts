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
import { HiLog } from '../../../../../../../common';
import RecentDeleteBean from '../../../model/bean/RecentDeleteBean';
import RecentDeleteDataSource from '../../../model/bean/RecentDeleteDataSource';
import { RequestParam } from '../../../model/type';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import { ContactIdsParam } from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import DotUtil from '../../../util/DotUtil';
import dotCommon, { recentDeleteOperateContactParams } from '../../../util/DotCommon';
import EmitterConstant from '../../../data/EmitterConstant';
import AccessibilityUtil from '../../../util/AccessibilityUtil';

const TAG = 'RecentDeletePresenter ';
/**
 * One day for millisecond(60 * 60 * 24 * 1000).
 */
const MS_OF_ONE_DAY = 86400000;
const EXTENDED_DAYS = 30;
const SINGLE_BATCH_NUMBER: number = 500;
const NO_NAME: string = '(无姓名)';

export default class RecentDeletePresenter {
  private static sInstance: RecentDeletePresenter;
  public recentDeleteDataSource: RecentDeleteDataSource = new RecentDeleteDataSource();
  public recentDeleteList: RecentDeleteBean[] = [];
  public recentDeleteTotal: number = 0;
  public pathInfos: NavPathStack = new NavPathStack();
  public isSelectAll: boolean = false;
  public recentDeleteCount: number = 0;
  public selectRecentDeleteChange: boolean = false;
  public allSelectedIds: Array<string> = [];
  public allRestoreIds: Array<string> = [];
  public selectedCount: number = 0;
  public checkedStatus: Set<number> = new Set<number>();
  public resultDT: number = 0
  public refreshUI: () => void = () => {};

  public static getInstance(): RecentDeletePresenter {
    if (RecentDeletePresenter.sInstance == null) {
      HiLog.w(TAG, 'RecentDeletePresenter getInstance!');
      RecentDeletePresenter.sInstance = new RecentDeletePresenter();
    }
    return RecentDeletePresenter.sInstance;
  }

  initRecentDeleteContacts() {
    this.queryAllRecentDeleteContacts();
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  back() {
    this.pathInfos.pop();
  }

  resetData() {
    HiLog.w(TAG, 'resetData.');
    this.isSelectAll = false;
    this.selectedCount = 0;
    this.selectRecentDeleteChange = false;
    this.recentDeleteTotal = 0;
    this.checkedStatus.clear();
    this.sendSelectedEvent(null);
    this.recentDeleteDataSource.refresh(this.recentDeleteList);
  }

  getRecentDeleteCount(): number {
    HiLog.w(TAG, `getRecentDeleteCount count: ${this.recentDeleteCount}`);
    return this.recentDeleteCount;
  }

  queryAllRecentDeleteContacts() {
    HiLog.w(TAG, 'queryAllRecentDeleteContacts start.');
    const actionData: Record<string, number> = {};
    const requestParam: RequestParam<Record<string, number>> = {
      actionData: actionData,
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllRecentDeleteContacts', requestParam, async (result: RecentDeleteBean[]) => {
        let totalCount: number = result.length;
        this.recentDeleteCount = totalCount;
        HiLog.w(TAG, `getAllRecentDeleteContacts totalCount: ${totalCount}`);
        HiLog.w(TAG, `getAllRecentDeleteContacts recentDeleteCount: ${this.recentDeleteCount}`);
        if (totalCount > 0 ) {
          this.recentDeleteList = result;
          this.refreshRecentDeleteList(this.recentDeleteList);
          HiLog.w(TAG, 'refreshRecentDeleteList end.');
        }
     })
  }

  refreshRecentDeleteList(recentDeleteList: RecentDeleteBean[]) {
    HiLog.w(TAG, 'refreshRecentDeleteList start.');
    this.recentDeleteDataSource.refresh(recentDeleteList);
  }

  getDisplayName(displayName: string): string | Resource {
    if (StringUtil.isEmpty(displayName)) {
      return $r('app.string.noName');
    }
    return displayName;
  }

  getAppNameByPackageName(packageName: string): string {
    HiLog.w(TAG, `getAppNameByPackageName packageName: ${packageName}`);
    let appName = '';
    if (StringUtil.isEmpty(packageName)) {
      appName = ResourceUtil.getStringByResource($r('app.string.unknown'));
      HiLog.w(TAG, 'getAppNameByPackageName packageName is empty, return');
      return appName;
    }
    let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
    try {
      let resourceInfo = bundleResourceManager.getBundleResourceInfo(packageName, bundleFlags);
      appName = resourceInfo.label;
      HiLog.w(TAG, `applicationName name : ${appName}`);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.e(TAG, 'getBundleResourceInfo failed: %{public}s', message);
    }
    if (StringUtil.isEmpty(appName)) {
      appName = ResourceUtil.getStringByResource($r('app.string.unknown'));
      HiLog.w(TAG, 'getAppNameByPackageName appName is unknown');
    }
    return appName;
  }

  calcRemainingDays(deleteTime: number): number {
    let now: number = new Date().getTime();
    let diff: number = now - deleteTime;
    let days: number = (diff <= 0) ? 0 : Math.floor(diff / MS_OF_ONE_DAY);
    if (days > EXTENDED_DAYS) {
      days = EXTENDED_DAYS;
    }
    return EXTENDED_DAYS - days;
  }

  sendProgressSubscription(selectedCounts: number) {
    let event: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_RECENT_DELETE_EVENT_ID
    }
    let eventData: emitter.EventData = {
      data: {
        selectedCounts: selectedCounts,
      }
    }
    emitter.emit(event, eventData);
  }

  getRemainingDays(deleteTime: number): string {
    let days = this.calcRemainingDays(deleteTime);
    return ResourceUtil.getPluralStringByResource($r('app.plural.recycle_days_left'), days);
  }

  getAccessibilityDisplayName(displayName: string): string {
    if (StringUtil.isEmpty(displayName)) {
      return NO_NAME;
    }
    return displayName;
  }

  getAccessibilityRemainingDays(deleteTime: number): string {
    let days = this.calcRemainingDays(deleteTime);
    let remainingDays: string = ResourceUtil.getPluralStringByResource($r('app.plural.recycle_days_left'), days)
    return remainingDays;
  }

  async deleteContacts() {
    HiLog.w(TAG,
      `deleteContacts selectRecentDeleteChange: ${this.selectRecentDeleteChange}, isSelectAll: ${this.isSelectAll}`);
    if (!this.selectRecentDeleteChange || this.checkedStatus.size === this.recentDeleteList.length) {
      this.recentDeleteList.forEach((value) => {
        this.allSelectedIds.push(value.id.toString())
      });
    } else {
      this.checkedStatus.forEach((value) => {
        this.allSelectedIds.push(value.toString())
      });
    }
    let allSelectedIdCount: number = this.allSelectedIds.length;
    AppStorage.setOrCreate('allSelectedIdCount', allSelectedIdCount);
    let array: string[][] = ArrayUtil.cutArray(this.allSelectedIds, SINGLE_BATCH_NUMBER);
    /*
     * The progress bar is not displayed when the number of records is less than 200.
     */
    if (array.length <= 1) {
      HiLog.w(TAG, 'the data volume is small, progress bar is not displayed.')
      AppStorage.setOrCreate('isShowProgress', false); //不显示进度条
    } else {
      AppStorage.setOrCreate('isShowProgress', true); //显示进度条
    }
    for (let i = 0; i < array.length; i++) {
      await this.batchDeleteContacts(array[i], array.length, i);
    }
  }

  batchDeleteContacts(array: string[], arrayLength: number, index: number) {
    return new Promise<void>(resolve => {
      let contactIdParam: ContactIdsParam = {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: array,
        operationScenario: 'Delete recently deleted contacts',
      }
      HiLog.w(TAG, 'batchDeleteContacts ids is : ' + contactIdParam.ids);
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('deleteRecycleContactByIds', contactIdParam, (result: number) => {
          HiLog.w(TAG, 'deleteContacts result : ' + result);
          // deleting a single batch succeeded.
          if (result === 0) {
            this.deleteSelectedContactItems(contactIdParam.ids);
          } else {
            HiLog.w(TAG, `the ${index + 1} batch delete fail`);
          }
          /*
           * The progress bar is displayed only when the user data is greater than 200.
           * If the user data is less than 200, no monitoring message is sent and the progress bar is displayed.
           */
          if (arrayLength > 1) {
            this.sendProgressSubscription(contactIdParam.ids.length);
          }
          // Reset data for next use when executing the last batch
          if (index === (arrayLength - 1)) {
            this.recentDeleteDataSource.refresh(this.recentDeleteList);
            this.recentDeleteCount = this.recentDeleteList.length;
            this.resetDefaultValue();
            HiLog.w(TAG, 'deleteContacts end');
          }
          resolve();
        });
    })
  }

  async restoreContacts() {
    //点击恢复的时候获取当前最新的列表数量
    this.recentDeleteTotal = this.recentDeleteList.length;
    HiLog.w(TAG, `current count: ${this.recentDeleteTotal} `);
    this.checkedStatus.forEach((value) => {
      this.allRestoreIds.push(value.toString());
    })
    let array: string[][] = ArrayUtil.cutArray(this.allRestoreIds, SINGLE_BATCH_NUMBER);
    for (let i = 0; i < array.length; i++) {
      await this.batchRestoreContacts(array[i], array.length, i);
    }
  }

  batchRestoreContacts(array: string[], arrayLength: number, index: number) {
    HiLog.i(TAG, 'restore contacts numbers: ' + array.length);
    return new Promise<void>(resolve => {
      let contactIdParam: ContactIdsParam = {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: array,
        operationScenario: 'Restore recently deleted contacts',
      }
      HiLog.w(TAG, 'restoreContacts ids is : ' + contactIdParam.ids);
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('restoreRecycleContacts', contactIdParam, (result: number) => {
          HiLog.w(TAG, 'restoreContacts result: ' + result);
          if (result === 0) {
            this.deleteSelectedContactItems(contactIdParam.ids);
          } else {
            HiLog.w(TAG, `the ${index + 1} batch restore fail`);
          }

          if (index === (arrayLength - 1)) {
            this.recentDeleteDataSource.refresh(this.recentDeleteList);
            this.recentDeleteCount = this.recentDeleteList.length;
            AppStorage.setOrCreate('isRestoreFinish', true);
            HiLog.w(TAG, 'restoreContacts set isRestoreFinish: ' + AppStorage.get('isRestoreFinish'));
          }
          resolve();
        });
    })
  }

  deleteSelectedContactItems(array: Array<string>) {
    HiLog.w(TAG, `allRefreshSelectIds length: ${array.length} `);
    array.forEach((id) => {
      let itemIndex = this.recentDeleteList.findIndex(item => item.id === Number(id));
      if (itemIndex === -1) {
        HiLog.w(TAG, `find itemIndex error: ${id} `);
      } else {
        this.recentDeleteList.splice(itemIndex, 1);
      }
    })
    HiLog.w(TAG, `deleteSelectedContactsItem recentDeleteList: ${this.recentDeleteList.length} `);
  }

  resetDefaultValue() {
    HiLog.w(TAG, 'resetDefaultValue');
    this.isSelectAll = false;
    this.selectRecentDeleteChange = false;
    this.selectedCount = 0;
    this.allSelectedIds = [];
    this.allRestoreIds = [];
    this.recentDeleteTotal = 0;
    this.checkedStatus.clear();
  }

  getDeleteDialogTitle(): Resource {
    HiLog.w(TAG, `getDeleteDialogTitle selectRecentDeleteChange: ${this.selectRecentDeleteChange}`);
    HiLog.w(TAG, `getDeleteDialogTitle isSelectAll: ${this.isSelectAll}`);
    HiLog.w(TAG, `getDeleteDialogTitle selectedCount: ${this.selectedCount}`);
    let title: Resource;
    if (this.selectRecentDeleteChange) {
      if (this.checkedStatus.size === this.recentDeleteList.length) {
        title = $r('app.string.contacts_recycle_deleted_all_confirm');
      } else if (this.checkedStatus.size === 1) {
        title = $r('app.string.contacts_recycle_deleted_confirm_single');
      } else {
        title = $r('app.plural.contacts_recycle_deleted_confirm', this.checkedStatus.size, this.checkedStatus.size);
      }
    } else {
      title = $r('app.string.contacts_cleaned_confirm');
    }
    return title;
  }

  checkAll() {
    HiLog.w(TAG, 'checkAll.');
    if (this.checkedStatus.size !== this.recentDeleteList.length) {
      this.recentDeleteList.forEach((item) => {
        this.checkedStatus.add(item.id);
      });
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.recentDeleteList.length);
    } else {
      this.checkedStatus.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.recentDeleteList.length);
    }
    HiLog.w(TAG, `checkAll selectedIds: ${Array.from(this.checkedStatus)}`);
    HiLog.w(TAG, `checkAll isSelectAll: ${this.isSelectAll}`);
    HiLog.w(TAG, `checkAll selectedCount: ${this.selectedCount}`);
    this.sendSelectedEvent(null);
    this.refreshUI();
  }

  sendBroadcast(checked: boolean) {
    let text1: string = ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .resourceManager
      .getStringSync($r('app.string.accessibility_selected'));

    let text2: string = ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .resourceManager
      .getStringSync($r('app.string.accessibility_unselected'))
    AccessibilityUtil.getInstance()
      .sendAccessibilityEventInfo(checked ? text1 : text2)
  }

  sendSelectedEvent(id: number | null) {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_RECENT_DELETE_ITEM_CHECKED,
    };
    let eventData: emitter.EventData = {
      data: {
        'id': id
      }
    };
    emitter.emit(innerEvent, eventData);
  }

  itemOnClick(item: RecentDeleteBean, index: number) {
    HiLog.w(TAG, `itemOnClick start, index: ${index}`);
    if (this.checkedStatus.has(item.id)) {
      this.isSelectAll = false;
      this.checkedStatus.delete(item.id);
    } else {
      this.checkedStatus.add(item.id);
      if (this.checkedStatus.size === this.recentDeleteList.length) {
        this.isSelectAll = true;
      }
    }
    this.sendSelectedEvent(item.id);
    this.refreshUI();
  }

  recentDeleteOperate(operateType: number) {
    if (this.isSelectAll) {
      recentDeleteOperateContactParams.NUM = dotCommon.eventParam.CHECK_ALL;
    } else if (this.selectedCount === 1) {
      recentDeleteOperateContactParams.NUM = dotCommon.eventParam.CHECK_ONE;
    } else if (this.selectedCount > 1) {
      recentDeleteOperateContactParams.NUM = dotCommon.eventParam.CHECK_MORE;
    } else {
      recentDeleteOperateContactParams.NUM = dotCommon.eventParam.CHECK_NONE;
    }
    recentDeleteOperateContactParams.OPERATE = operateType;
    DotUtil.getInstance().contactDot(recentDeleteOperateContactParams, dotCommon.eventName.RECENT_DELETE_OPERATE_EVENT);
  }

  processLongPressedItem(item: RecentDeleteBean, itemIndex: number) {
    this.selectRecentDeleteChange = true;
    this.checkedStatus.clear();
    this.checkedStatus.add(item.id);
    this.sendSelectedEvent(null);
    this.selectedCount = this.checkedStatus.size;
    this.isSelectAll = this.recentDeleteList.length === this.selectedCount;
    this.recentDeleteDataSource.refresh(this.recentDeleteList);
    HiLog.w(TAG, 'processLongPressedItem selectedIds: ' + Array.from(this.checkedStatus));
    this.sendBroadcast(true);
  }

  setRestoreToSelect() {
    this.resetData()
    this.selectRecentDeleteChange = true;
  }
}