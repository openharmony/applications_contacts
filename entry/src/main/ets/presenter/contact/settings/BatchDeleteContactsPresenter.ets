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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import BatchDeleteContactSource from '../../../model/bean/BatchDeleteContactSource';
import AlphabetIndexerPresenter from '../alphabetindex/AlphabetIndexerPresenter';
import ContactListPresenter from '../ContactListPresenter';
import { CountAlphabetIndex } from '../../../model/type/ContactParams';
import { ContactBlobSource, PageLimit } from '../../../model/type';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import { ContactIdsParam } from '../settings/ArrangeContactsPresenter';
import { HashSet, JSON } from '@kit.ArkTS';
import { LimitRefreshDataUtil } from '../../../../../../src/main/ets/util/LimitRefreshDataUtil';
import { AlphabetIndexObj, ContactVo } from '../../../model/bean/ContactVo';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import { initBlobSourceMap } from '../../../util/UserPhoto';
import { emitter } from '@kit.BasicServicesKit';
import ContactListShowInfo from '../../../model/bean/ContactListShowInfo';
import SmsManagerUtils from '../../../util/SmsManagerUtils';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { AuditLogUtils } from '../../../../../../../common/src/main/ets/util/AuditLogUtils';

const TAG = 'BatchDeleteContactsPresenter ';


let auditlogUtils: AuditLogUtils = AuditLogUtils.getInstance();
/**
 * Selecting a contact list by SMS
 */
export default class BatchDeleteContactsPresenter {
  private static sInstance: BatchDeleteContactsPresenter;
  public static BATCH_DELETE_ITEM_CHECKED = 'BatchDeleteItemChecked';
  public static EMITTER_ID_DELETE = 'emitterIdDelete';
  public selectCount: number = 0;
  public contactsTotal: number = 0;
  public contactCount: number = 0;
  public SINGLE_BATCH_NUMBER: number = 500;
  public selectedContacts: HashSet<string> = new HashSet();
  public allSelectedIds: Array<string> = [];

  public icSelectAll: Resource = $r('sys.symbol.checkmark_square_on_square');
  public allSelectMessage: Resource = $r('app.string.select_all');

  public contactsListInited: boolean = false;
  public contactListDataSource: BatchDeleteContactSource = new BatchDeleteContactSource();
  public limitDataRefresh: LimitRefreshDataUtil<PageLimit, ContactVo[]> | undefined = undefined;
  public refreshUI: () => void = () => {
  };

  private constructor() {
  }
  public sceillOnlenth: number = 0;

  public static getInstance(): BatchDeleteContactsPresenter {
    if (BatchDeleteContactsPresenter.sInstance == null) {
      BatchDeleteContactsPresenter.sInstance = new BatchDeleteContactsPresenter();
    }
    return BatchDeleteContactsPresenter.sInstance;
  }

  public static getTestInstance(): BatchDeleteContactsPresenter {
    return new BatchDeleteContactsPresenter();
  }

  /**
   * 判断排序是否错误，打印排序错误的信息
   * @param contactVo
   */
  public judgeAndLogSortError(contactVo: ContactVo) {
    let sortFirstLetter = contactVo.namePrefix;
    let sort = contactVo.sort;
    // 特殊字符排序错误
    if (sortFirstLetter === '#') {
      if (sort !== '-1') {
        this.logSortError('# sort error', contactVo);
      }
      return;
    }
    // 无名氏处理
    if (sortFirstLetter === '...') {
      if (sort !== '99') {
        this.logSortError('... sort error', contactVo);
      }
      return;
    }
    // 字母处理
    if (sortFirstLetter.length > 0) {
      if (sortFirstLetter.charCodeAt(0).toString() !== sort) {
        this.logSortError(sortFirstLetter.charAt(0) + ' sort error', contactVo);
      }
      return;
    } else {
      this.logSortError('sortFirstLetter has no value, sort error', contactVo);
    }
  }

  public logSortError(title: string, contactVo: ContactVo) {
    HiLog.i(TAG, title + ', sort error sortFirstLetter: ' + contactVo.namePrefix + '  sort:' + contactVo.sort);
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.contactListDataSource.refreshAll([]);
    this.contactsListInited = false;
    this.selectedContacts.clear();
    this.initContactsList();
    this.refreshPageMessage();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    this.limitDataRefresh?.release();
    this.limitDataRefresh = undefined;
  }

  // 如果列表刷新数据是进入批量删除，也刷新删除的列表
  refresh() {
    HiLog.i(TAG, 'BatchDeleteContactsPresenter refresh');
    let contactListPresenterDataSource = ContactListPresenter.getInstance().contactListDataSource;
    this.contactCount = contactListPresenterDataSource.totalCount();
    this.contactListDataSource.refreshAll(contactListPresenterDataSource.contactList);
    AlphabetIndexerPresenter.getInstance().initContactList(contactListPresenterDataSource.contactList);
    this.contactsListInited = true;
    this.refreshPageMessage();
  }

  public async initContactsList() {
    HiLog.i(TAG, 'initContactsList!');
    try {
        await this.getAllContactSizeAsync();
    } catch (error) {
        HiLog.e(TAG, `Failed to get contact size: ${error.message}`);
        return;
    }
    this.refresh();
    HiLog.i(TAG, `initContactsList current total: ${this.contactsTotal},
          contactListPresenterDataSource length: ${this.contactListDataSource.contactList.length}`);
  }

  private getAllContactSizeAsync(): Promise<boolean> {
    HiLog.i(TAG, 'getAllContactSizeAsync start');
    return new Promise((resolve, reject) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequestUiThread('getAllContactSize', {
          hasMyCard: false
        }, (result: CountAlphabetIndex) => {
          this.contactsTotal = result.count;
          HiLog.w(TAG, `getAllContactSize contactsTotal is ${this.contactsTotal}`);
          resolve(true);
        })
    });
  }

  /**
   * 获取头像信息
   * @returns
   */
  getPhotosInfoAsync(): Promise<boolean> {
    HiLog.i(TAG, 'getPhotosInfoAsync start');
    return new Promise((resolve, reject) => {
      // 查询有头像信息的记录
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequestUiThread('getContactIdWithBlobNotNull', {}, (result: ContactBlobSource[]) => {
          if (result) {
            let map = new Map<string, ContactBlobSource>();
            result.forEach((item: ContactBlobSource) => {
              map.set(item.contactId, item);
            })
            initBlobSourceMap(map);
            // 联系人列表更新，触发头像查询
            AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
          }
          resolve(true);
        });
    });
  }

  // 删除按钮
  async delete() {
    HiLog.w(TAG, 'delete start, size is :' + this.selectedContacts.length);
    if (this.selectedContacts.length === 0) {
      HiLog.e(TAG, 'delete size can not be 0');
    } else {
      this.selectedContacts.forEach((contactId: string) => {
        this.allSelectedIds.push(contactId.toString());
      });
      AppStorage.setOrCreate('isBatchDeleting', true);
      HiLog.w(TAG, 'delete ids is :' + this.allSelectedIds);
      let allSelectedIdCount: number = this.selectedContacts.length;
      AppStorage.setOrCreate('allSelectedIdCount', allSelectedIdCount);
      let array: string[][] = ArrayUtil.cutArray(this.allSelectedIds, this.SINGLE_BATCH_NUMBER);
      // 联系人列表下滑保存当前页, 批量删除前把当前页设置1, 便于从第一页请求数据
      ContactListPresenter.getInstance().setCurrentPage(1);
      for (let i = 0; i < array.length; i++) {
        await this.batchDeletionBasic(array[i], array.length, i)
      }
      HiLog.i(TAG, 'batchDelete execute end');
      this.contactListDataSource.notifyDataReload();
    }
  }

  //数量过多时，分批删除的方法
  batchDeletionBasic(array: string[], arrayLength: number, index: number) {
    return new Promise<void>(resolve => {
      let contactIdParam: ContactIdsParam = {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        ids: array,
        operationScenario: 'manul batch delete',
      }
      HiLog.w(TAG, 'restoreContacts ids is : ' + contactIdParam.ids);
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('deleteContactByIds', contactIdParam, (result: number | undefined) => {
          SmsManagerUtils.notifyMmsWhenDeleteContact(contactIdParam.ids.map(Number), result === 0 ? 0 : -1);
          if (result) {
            HiLog.w(TAG, 'deleteContactById error:' + result);
          }

          if (arrayLength > 1) {
            this.sendProgressSubscription(contactIdParam.ids.length);
          }
          // Reset data for next use when executing the last batch
          if (index === (arrayLength - 1)) {
            this.allSelectedIds = [];
            HiLog.w(TAG, 'deleteContacts end');
          }
          resolve();
        });
    })

  }

  sendProgressSubscription(selectedCounts: number) {
    let eventData: emitter.EventData = {
      data: {
        selectedCounts: selectedCounts,
      }
    }
    emitter.emit(BatchDeleteContactsPresenter.EMITTER_ID_DELETE, eventData);
  }

  // 单选checkbox
  onItemClick(item: ContactListShowInfo, index: number) {
    HiLog.w(TAG, 'contactId: ' + item.contactId + ',  index: ' + index);
    if (this.selectedContacts.has(item.contactId)) {
      this.selectedContacts.remove(item.contactId);
    } else {
      this.selectedContacts.add(item.contactId);
    }
    let eventData: emitter.EventData = {
      data: {
        'contactId': item.contactId
      }
    };
    emitter.emit(BatchDeleteContactsPresenter.BATCH_DELETE_ITEM_CHECKED, eventData);
    this.refreshPageMessage();
  }

  // 全选按钮
  onClickAll() {
    HiLog.w(TAG, 'onClickAll')
    let isSelectedAll = this.selectedContacts.length === this.contactsTotal;
    if (isSelectedAll) {
      // 取消全选
      this.selectedContacts.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.contactsTotal);
    } else {
      // 全选
      this.contactListDataSource.contactList.forEach((item: ContactVo) => {
        this.selectedContacts.add(item.contactId);
      })
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.contactsTotal);
    }
    emitter.emit(BatchDeleteContactsPresenter.BATCH_DELETE_ITEM_CHECKED);
    this.refreshPageMessage();
  }

  // 更新页面底部工具栏
  refreshPageMessage() {
    HiLog.i(TAG, 'refreshPageMessage start !')
    this.selectCount = this.selectedContacts.length;
    if (this.selectCount === this.contactsTotal && this.contactsTotal > 0) {
      HiLog.w(TAG, `1 this.selectCount: ${this.selectCount}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square_fill');
      this.allSelectMessage = $r('app.string.unselect_all');
    } else if (this.selectCount === 0) {
      HiLog.w(TAG, `2 this.selectCount: ${this.selectCount}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    } else {
      HiLog.w(TAG, `3 this.selectCount: ${this.selectCount}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    }
    this.refreshUI();
  }
}
