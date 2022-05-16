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

import router from '@system.router';
import HiLog from '../../util/HiLog';
import {ContactVo} from '../../model/bean/ContactVo';
import ArrayUtil from '../../util/ArrayUtil';
import ContactRepository from '../../contact/repo/ContactRepository';
import CallLogRepository from '../../call/repo/CallLogRepository';
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
  limit: number = 20;
  queryContactsType: string = 'all';
  contactCount: number = 0;
  isEmptyGroup: boolean = true;
  shareList: Resource[] = [$r("app.string.qr_code"), $r("app.string.v_card"), $r("app.string.text")];
  settingsMenu: Resource[] = [$r("app.string.contact_setting_type_scancard"), $r("app.string.call_setting_type_setting")];
  contactListDataSource: ContactListDataSource = new ContactListDataSource();
  private constructor() {
  }

  public static getInstance(): ContactListPresenter {
    if (ContactListPresenter.sInstance == null) {
      ContactListPresenter.sInstance = new ContactListPresenter();
    }
    return ContactListPresenter.sInstance;
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.refresh();
    ContactRepository.getInstance().registerDataChangeObserver(() => {
      this.refresh();
    });
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    ContactRepository.getInstance().unRegisterDataChangeObserver(() => {
      this.refresh();
    });
  }

  /**
   * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageShow() {
  }

  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
  }

  refresh() {
    HiLog.i(TAG, 'Contact refresh!');
    let that = this;
    ContactAbilityModel.getAllContact((result) => {
      HiLog.i(TAG, 'getAllContact and refresh, length is %s', result.length);
      if (ArrayUtil.isEmpty(result)) {
        that.contactList = [];
      } else {
        that.contactList = result;
      }
      that.contactCount = result.length;

      this.contactListDataSource.refresh(this.contactList);
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
    ContactRepository.getInstance().deleteById(item.contactId)
      .then((result) => {
        HiLog.i(TAG, 'onDeleteDialogConfirm result is ' + JSON.stringify(result));
        ContactRepository.getInstance().notifyChange();
        CallLogRepository.getInstance().notifyChange();
      })
      .catch((error) => {
        HiLog.e(TAG, "deleteById error %s", JSON.stringify(error.message));
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
    HiLog.i(TAG, 'onShareItemClick !!! index is %s', index);
  }

  /**
   * Log in to Huawei ID.
   */
  loginAccount() {
    HiLog.i(TAG, 'loginAccount !!');
    router.push(
      {
        uri: "",
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
        uri: "",
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
        uri: "pages/contacts/accountants/Accountants"
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
        uri: ""
      }
    );
  }
}