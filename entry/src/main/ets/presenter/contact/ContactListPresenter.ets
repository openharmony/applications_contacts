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

import router from '@ohos.router';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ContactVo } from '../../model/bean/ContactVo';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { CallLogRepository } from '../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import ContactListDataSource from '../../model/bean/ContactListDataSource';
import WorkerWrapper from '../../workers/base/WorkerWrapper';

const TAG = 'ContactListPresenter  ';
const DELAY_TIME: number = 1000;
/**
 * Type of the control that is clicked in the contact list.
 */
export enum ContactClickType {
  LOGIN_IN,
  IMPORT_CONTACT,
  CREATE_CONTACT,
  SCAN_CARD
}

/**
 * Contact List Logical Interface Model
 */
export default class ContactListPresenter {
  private static sInstance: ContactListPresenter;
  indexs: string[] = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '…'];
  contactListPages: Array<number> = [];
  curItem: ContactVo = new ContactVo("", "", "", "", "", "", true, "", "");
  page: number = 0;
  limit: number = 0;
  refreshIndex: number = 0;
  queryContactsType: string = 'all';
  isEmptyGroup: boolean = true;
  shareList: Resource[] = [$r("app.string.qr_code"), $r("app.string.v_card"), $r("app.string.text")];
  settingsMenu: Resource[] = [$r("app.string.contact_setting_type_scancard"), $r("app.string.call_setting_type_setting")];
  contactListDataSource: ContactListDataSource = new ContactListDataSource();
  isShow: boolean = false;
  context: Context;
  worker: WorkerWrapper;
  loading: boolean;
  initStarted: boolean = false;
  taskId: number = undefined;
  refreshState: () => void
  onContactChange = () => {
    HiLog.i(TAG, 'onContactChange refresh');
    this.setDelayTask();
  }

  private constructor() {
  }

  public static getInstance(): ContactListPresenter {
    if (globalThis.presenterManager?.contactListPresenter) {
      return globalThis.presenterManager.contactListPresenter;
    }
    if (ContactListPresenter.sInstance == null) {
      HiLog.i(TAG, 'Contact getInstance!');
      ContactListPresenter.sInstance = new ContactListPresenter();
    }
    return ContactListPresenter.sInstance;
  }

  onCreate(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
  }

  onDestroy() {
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactChange);
  }

  bindUI(refreshState?: () => void) {
    this.refreshState = refreshState;
  }

  startInit() {
    if (this.initStarted) {
      return;
    }
    HiLog.i(TAG, "startInit");
    this.initStarted = true;
    if (this.page == 0) {
      this.page++;
    }
    this.refreshContinue();
  }

  cachePageOne() {
    if (!this.initStarted && !this.loading) {
      HiLog.i(TAG, "cachePageOne")
      this.page = 1;
      this.refreshIndex = 0;
      this.refreshContinue();
    } else {
      HiLog.i(TAG, "no need cachePageOne");
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.startInit();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
  }

  setPageShow(isShow: boolean) {
    if (this.isShow == isShow) {
      return;
    }
    this.isShow = isShow;
    if (this.isShow) {
      this.startInit();
    }
    this.contactListDataSource.setIsShow(isShow);
  }

  requestItem() {
    HiLog.i(TAG, 'Contacts requestItem!');
    if (this.page == 0) {
      this.page++;
      this.refreshContinue();
    } else if (!this.initStarted && !this.loading) {
      this.cachePageOne();
    } else {
      HiLog.i(TAG, 'isLoading');
    }
  }

  setDelayTask() {
    if (this.taskId != undefined) {
      clearTimeout(this.taskId);
      this.taskId = undefined;
    }
    let delay: number = 0;
    if (this.page != 0) {
      delay += DELAY_TIME;
    }
    if (!this.isShow) {
      delay += DELAY_TIME;
    }
    if (delay > 0) {
      this.taskId = setTimeout(() => {
        if (this.page != 0) {
          this.setDelayTask();
        } else {
          this.requestItem();
        }
      }, delay);
    } else {
      this.requestItem();
    }
  }

  refreshContinue() {
    if (this.loading) {
      HiLog.i(TAG, 'refreshContinue is loading');
      return;
    }
    if (this.page == 0) {
      HiLog.i(TAG, 'refreshContinue end');
      return;
    }
    if (this.page == 1) {
      this.limit = 50;
    } else {
      this.limit = 500;
    }
    this.refreshPage(this.page, this.limit, () => {
      if (this.initStarted) {
        setTimeout(() => {
          this.refreshContinue();
        },!this.isShow ? 700 : 1);
      }
    })
  }

  refreshPage(page: number, limit: number, callback?: () => void) {
    this.loading = true;
    let actionData: any = {};
    actionData.page = page;
    actionData.limit = limit;
    this.worker.sendRequest("getAllContact", {
      actionData: actionData,
      context: this.context
    }, (result) => {
      HiLog.i(TAG, `refreshPage ${page} getAllContact, length is: ` + result.length);
      if (Array.prototype.isPrototypeOf(result)) {
        this.contactListDataSource.refresh(this.refreshIndex, this.contactListPages[page -1], result);
      }
      this.contactListPages[page -1] = result.length;
      this.refreshIndex += this.contactListPages[page -1];
      if (this.refreshState) {
        this.refreshState();
      }
      let contactCount = result.length;
      if (contactCount < limit) {
        this.page = 0;
        HiLog.i(TAG, 'Contacts load completed: ' + JSON.stringify(this.contactListDataSource.totalCount()));
        if (this.contactListPages.length > page) {
          this.contactListPages.splice(page, this.contactListPages.length - page);
        }
        if (this.contactListDataSource.totalCount() > this.refreshIndex) {
          this.contactListDataSource.remove(this.refreshIndex, this.contactListDataSource.totalCount() - this.refreshIndex);
        }
        this.refreshIndex = 0;
        this.loading = false;
      } else {
        this.page = page + 1;
        this.loading = false;
        if (callback) {
          callback();
        }
      }
    })
  }


  /**
   * Touch and hold the current contact information saved by a contact item in the contact list.
   * The information can be deleted or shared later.
   *
   * @param curItem
   */
  setCurItem(curItem: ContactVo) {
    HiLog.i(TAG, 'setCurItem');
    this.curItem = curItem;
  }

  /**
   * Cancel button for deleting a dialog box.
   */
  onDeleteDialogCancel() {
    HiLog.i(TAG, 'onDeleteDialogCancel !!!');
  }

  /**
   * Confirm button for deleting a dialog box
   *
   * @param result
   */
  onDeleteDialogConfirm(index, item) {
    HiLog.i(TAG, 'onDeleteDialogConfirm !!! ');
    this.worker.sendRequest("deleteContactById", {
      context: this.context,
      contactId: item.contactId
    }, (result) => {
      if (result) {
        HiLog.w(TAG, "deleteContactById error:" + JSON.stringify(result))
      }
      ContactRepository.getInstance().notifyChange();
    });
    this.contactListDataSource.remove(index);
  }

  /**
   * Share Cancel Button
   */
  onShareDialogCancel() {
    HiLog.i(TAG, 'onShareDialogCancel !!! ');
  }

  /**
   * Share confirmation button
   */
  onShareDialogConfirm() {
    HiLog.i(TAG, 'onShareDialogConfirm !!! ');
  }

  /**
   * Event callback when an item is clicked in the sharing dialog box
   *
   * @param item item
   * @param index index
   */
  onShareItemClick(item: any, index: number | null) {
    HiLog.i(TAG, 'onShareItemClick !!! index is %s' + index);
  }

  /**
   * Log in to Huawei ID.
   */
  loginAccount() {
    HiLog.i(TAG, 'loginAccount !!');
    router.push(
      {
        url: "",
        params: {}
      }
    );
  }

  /**
   * Import Contact dialog box
   */
  importContact() {
    HiLog.i(TAG, 'importContact !!');
    router.push(
      {
        url: "",
        params: {}
      }
    );
  }

  /**
   * New Contact
   */
  createContact() {
    HiLog.i(TAG, 'createContact !!');
    router.push(
      {
        url: "pages/contacts/accountants/Accountants"
      }
    );
  }

  /**
   * Scan the business card.
   */
  scanCard() {
    HiLog.i(TAG, 'scanCard !!');
    router.push(
      {
        url: ""
      }
    );
  }
}