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
import Constants from '../../model/common/Constants';
import {ContactVo} from '../../model/bean/ContactVo';
import {ContactInfo} from '../../model/bean/ContactInfo'
import common from '../../model/common';
import dbChangeHelper from '../../model/common/DbChangeHelper';
import utils from '../../util/Utils';
import appStorageUtil from '../../util/AppStorageUtil';
import preferencesUtil from '../../util/PreferencesUtil';
import prompt from '@system.prompt';
import ContactRepository from '../../contact/repo/ContactRepository';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import ContactListDataSource from '../../model/bean/ContactListDataSource';

const TAG = 'ContactListPresenter  ';

/**
 * 联系人列表被点击的控件类型
 */
export enum ContactClickType {
  LOGIN_IN,
  IMPORT_CONTACT,
  CREATE_CONTACT,
  SCAN_CARD
}

/**
 * 联系人列表逻辑接口模型
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
  layoutState: boolean = true;
  settingsMenu: Resource[] = [$r("app.string.contact_setting_type_scancard"), $r("app.string.call_setting_type_setting")];
  contactListDataSource: ContactListDataSource = new ContactListDataSource();
  private constructor() {
    this.refresh();
  }

  public static getInstance(): ContactListPresenter {
    if (ContactListPresenter.sInstance == null) {
      ContactListPresenter.sInstance = new ContactListPresenter();
    }
    return ContactListPresenter.sInstance;
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');

    var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    dbChangeHelper.getInstance().registerDbChangeLister(DAHelper, Constants.uri.CONTACT_DATA_URI, (data) => {
      this.refresh();
    });
    dbChangeHelper.getInstance().registerDbChangeLister(DAHelper, Constants.uri.CONTACT_URI, (data) => {
      this.refresh();
    });
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    dbChangeHelper.getInstance().unRegisterDbChangeLister(DAHelper, Constants.uri.CONTACT_DATA_URI, (data) => {
      HiLog.i(TAG, 'Contact aboutToDisappear!');
    });
    dbChangeHelper.getInstance().unRegisterDbChangeLister(DAHelper, Constants.uri.CONTACT_URI, (data) => {
      HiLog.i(TAG, 'Contact aboutToDisappear!');
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
    var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    ContactAbilityModel.getAllContact(DAHelper, (result) => {
      HiLog.i(TAG, 'getAllContact and refresh, length is %s', result.length);
      if (utils.isEmptyList(result)) {
        this.contactList = [];
      } else {
        this.contactList = result;
      }

      this.contactListDataSource.refresh(this.contactList);
    })
  }

  // 简洁布局选项初始化
  conciseLayoutInit() {
    let data = preferencesUtil.getConciseLayout();
    this.layoutState = data == 'true' ? false : true;
  }

  /**
   * 联系人列表长按联系人item保存的当前联系人信息，提供给后面删除和分享的操作
   *
   * @param curItem
   */
  setCurItem(curItem: ContactVo) {
    HiLog.i(TAG, 'setCurItem');
    this.curItem = curItem;
  }

  /**
   * 删除弹框取消按钮
   */
  onDeleteDialogCancel() {
    HiLog.i(TAG, 'onDeleteDialogCancel !!!');
  }

  /**
   * 删除弹框确认按钮
   * @param result
   */
  onDeleteDialogConfirm(index, item) {
    HiLog.i(TAG, 'onDeleteDialogConfirm !!! ');
    ContactRepository.getInstance().deleteById(item.contactId)
      .then((result) => {
        HiLog.i(TAG, 'onDeleteDialogConfirm result is ' + JSON.stringify(result));
        dbChangeHelper.getInstance()
          .notifyChange(common.getDAHelper(Constants.uri.CONTACT_DB_URI), Constants.uri.CONTACT_URI);
        dbChangeHelper.getInstance()
          .notifyChange(common.getDAHelper(Constants.uri.CALLLOG_DB_URI), Constants.uri.CALL_LOG_URI);
      })
      .catch((error) => {
        HiLog.e(TAG, "deleteById error %s", JSON.stringify(error.message));
      });
  }

  /**
   * 分享取消按钮
   */
  onShareDialogCancel() {
    HiLog.i(TAG, 'onShareDialogCancel !!! ');
  }

  /**
   * 分享确认按钮
   */
  onShareDialogConfirm() {
    HiLog.i(TAG, 'onShareDialogConfirm !!! ');
  }

  /**
   * 分享弹框item点击事件回调
   *
   * @param item 点击条目的string
   * @param index 索引
   */
  onShareItemClick(item: any, index: number | null) {
    HiLog.i(TAG, 'onShareItemClick !!! index is %s', index);
  }

  /**
   * 登录华为账号
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
   * 导入联系人弹框
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
   * 新建联系人
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
   * 扫名片
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