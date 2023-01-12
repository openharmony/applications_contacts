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
import ContactAbilityModel from '../../model/ContactAbilityModel';
import ContactListDataSource from '../../model/bean/ContactListDataSource';

const TAG = 'ContactListPresenter  ';

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
  contactList: ContactVo[] = [];
  curItem: ContactVo = new ContactVo("", "", "", "", "", "", true, "", "");
  page: number = 0;
  limit: number = 0;
  total: number = 0;
  queryContactsType: string = 'all';
  contactCount: number = 0;
  isEmptyGroup: boolean = true;
  shareList: Resource[] = [$r("app.string.qr_code"), $r("app.string.v_card"), $r("app.string.text")];
  settingsMenu: Resource[] = [$r("app.string.contact_setting_type_scancard"), $r("app.string.call_setting_type_setting")];
  contactListDataSource: ContactListDataSource = new ContactListDataSource();
  isShow: boolean = false;
  private constructor() {
  }

  public static getInstance(): ContactListPresenter {
    if (ContactListPresenter.sInstance == null) {
      HiLog.i(TAG, 'Contact getInstance!');
      ContactListPresenter.sInstance = new ContactListPresenter();
    }
    return ContactListPresenter.sInstance;
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.isShow = true;
    this.requestItem();
    ContactRepository.getInstance().registerDataChangeObserver(() => {
      HiLog.i(TAG, 'Contact registerDataChangeObserver!');
      this.requestItem();
    });
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    this.isShow = false;
    ContactRepository.getInstance().unRegisterDataChangeObserver(() => {
    });
  }

  onPageShow() {
    HiLog.i(TAG, 'Contact onPageShow!');
    this.isShow = true;
  }

  onPageHide() {
    HiLog.i(TAG, 'Contact onPageHide!');
    this.isShow = false;
  }

  requestItem() {
    HiLog.i(TAG, 'Contacts requestItem!');
    if (this.page == 0) {
      this.contactList = [];
      this.page++;
      this.refresh();
    } else {
      HiLog.i(TAG, 'isLoading');
    }
  }

  refresh() {
    let actionData: any = {};
    if (this.page == 1) {
      this.limit = 50;
    } else {
      this.limit = 500;
    }
    actionData.page = this.page;
    actionData.limit = this.limit;
    ContactAbilityModel.getAllContact(actionData, (result) => {
      HiLog.i(TAG, 'getAllContact and refresh, length is: ' + JSON.stringify(result.length));
      if (!ArrayUtil.isEmpty(result)) {
        this.contactList = this.contactList.concat(result);
      }
      this.contactCount = result.length;
      this.contactListDataSource.refresh(this.contactList);
      if (this.contactCount < this.limit) {
        this.page = 0;
        HiLog.i(TAG, 'Contacts load completed: ' + JSON.stringify(this.contactList.length));
      } else {
        this.page++;
        setTimeout(() => {
          this.refresh();
        }, this.page == 2 ? 700 : 1);
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
    ContactRepository.getInstance().deleteById(item.contactId, (result) => {
      HiLog.i(TAG, 'onDeleteDialogConfirm result is ' + JSON.stringify(result));
      ContactRepository.getInstance().notifyChange();
      CallLogRepository.getInstance().notifyChange();
    });
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