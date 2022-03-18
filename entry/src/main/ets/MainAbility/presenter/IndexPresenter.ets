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
import HiLog from '../util/HiLog';
import Utils from '../util/Utils';
import featureAbility from '@ohos.ability.featureAbility';
import AppStorageUtil from '../util/AppStorageUtil';
import PreferencesUtil from '../util/PreferencesUtil';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import bundle from '@ohos.bundle'

const TAG = 'IndexPresenter  ';

export class IndexPresenter {
  /*当前tab页面*/
  uriTabFlag: boolean = false;
  tabsIndex: number = 0;
  private static instance: IndexPresenter

  public static getInstance(): IndexPresenter {
    if (!IndexPresenter.instance) {
      IndexPresenter.instance = new IndexPresenter()
    }
    return IndexPresenter.instance
  }

  onPageShow() {
    HiLog.i(TAG, 'aboutToAppear !!!');
    featureAbility.getWant().then((Want) => {
      HiLog.i(TAG, 'aboutToAppear Want success ');
      if (Utils.isEmpty(Want.uri) && Utils.isEmpty(Want.parameters.pageFlag)) {
        HiLog.i(TAG, 'pageRouteHandler and routeMessage.pageFlag isEmpty ');
      } else if (!Utils.isEmpty(Want.uri)) {
        HiLog.i(TAG, "want uri is not empty!");
        this.pageRouteHandler({
          pageFlag: Want.uri
        });
      } else {
        HiLog.i(TAG, "go pageRouteHandler");
        // 跳转到3方应用所指定的页面
        this.pageRouteHandler(Want.parameters);
      }
    }).catch((error) => {
      HiLog.e(TAG, 'aboutToAppear logMessage Operation failed. Cause:%s ', JSON.stringify(error.message));
    })
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear !!!');
    PreferencesUtil.initDataStorage().then((prefIns) => {
      HiLog.i(TAG, 'initStorage first done');
      AppStorageUtil.setPreferences(prefIns);
    }).catch((err) => {
      HiLog.e(TAG, 'initStorage error : %s', JSON.stringify(err.message));
    });
  }

  pageRouteHandler(routeMessage) {
    HiLog.i(TAG, 'show pageRouteHandler routeMessage ');
    let uri = "";
    let params = {};
    if (Utils.isEmpty(routeMessage.pageFlag)) {
      this.goToContacts();
      HiLog.i(TAG, 'pageRouteHandler and routeMessage.pageFlag isEmpty ');
      return;
    }
    HiLog.i(TAG, 'pageRouteHandler case is ' + routeMessage.pageFlag);
    switch (routeMessage.pageFlag.toString()) {
    // ------------------ 三方跳转 index  start ---------------------
      case 'page_flag_choose_contacts': // 三方跳转至选择联系人
        this.tabsIndex = 1;
        this.uriTabFlag = !this.uriTabFlag;
        return;
      case 'page_flag_dialer': // 三方跳转至拨号盘
        this.tabsIndex = 0;
        this.uriTabFlag = !this.uriTabFlag;
        return;
    // ------------------ 三方跳转 index  end ---------------------

      case 'page_flag_contact_details': // 三方跳转到详情
        uri = "pages/contacts/details/ContactDetail";
        if (routeMessage.contactId) {
          params = {
            'contactId': routeMessage.contactId,
          }
        } else {
          HiLog.i(TAG, 'SHOW pageRouteHandler and routeMessage.phoneNumber ');
          params = {
            'sourceFromCallRecord': true,
            'isNewNumber': true,
            'phoneNumberShow': routeMessage.phoneNumber,
          }
        }
        break;
      case 'page_flag_contact_index':
        uri = "pages/index";
        break;
      case 'page_flag_contacts':
        uri = 'pages/navigation/navigation';
        params = {
          'navigationType': 'contacts' // 跳转至联系人
        }
        break;
      case 'page_flag_edit_before_calling': // 呼叫前编辑
        this.editBeforeCall(routeMessage.phoneNumber);
        break;
      case 'page_flag_save_contact': // 新建联系人
        this.addContacts(routeMessage.phoneNumber);
        break;
      case 'page_flag_save_exist_contact': // 保存至已有联系人
        this.saveToContacts(routeMessage.phoneNumber);
        break;
      case 'page_flag_sms_forward':
        uri = 'pages/contacts/batchselectcontacts/batchselectcontacts';
        params = {
          selectType: 1 // 短信发送跳转到选择联系人界面
        }
        break;
      case 'page_flag_mult_choose':
        uri = 'pages/contacts/batchselectcontacts/BatchSelectContactsPage';
        params = {
          selectType: 0 // 短信发送跳转到选择联系人界面
        }
        break;
      case 'page_flag_call_logs': // 三方跳转至通话记录
        uri = 'pages/navigation/navigation';
        params = {
          'navigationType': 0 // 跳转至拨号盘界面
        }
        break;
      case 'page_flag_missed_calls':
        this.goToMissedCalls();
        break;
      case 'page_flag_card_details': // 跳转我的名片
        this.goToMyCard();
        break;
      default:
        HiLog.e(TAG, 'pageRouteHandler and This page is not open.');
        break;
    }
    HiLog.i(TAG, 'SHOW final uri');
    router.replace({
      uri: uri,
      params: params
    });
  }

  /* 跳转到我的名片 */
  goToMyCard() {
  }
  /* 呼叫前编辑 */
  editBeforeCall(phoneNumber) {
    AppStorageUtil.setIsEditNumber(true); // 标识为呼叫前编辑
    AppStorageUtil.setNumTextDialer(phoneNumber); // 赋值电话号码
    this.goToDialer();
  }
  /* 跳转到未接来电界面 */
  goToMissedCalls() {
  }
  /* 跳转至联系人界面 */
  goToContacts() {
  }
  /* 跳转至拨号盘界面 */
  goToDialer() {
    router.replace({ // 跳转至拨号盘
      uri: 'pages/index',
    });

  }
  /* 保存至已有联系人 */
  saveToContacts(phoneNumber) {
    router.replace({
      uri: 'pages/contacts/selectContactsList/selectContactsList',
      params: {
        type: 'saveContacts',
        number: phoneNumber,
      }
    });
  }
  /* 新建联系人 */
  addContacts(phoneNumber) {
    var number = phoneNumber.replace(/[^0123456789+]*/g, ''); // 去除所有空格及非数字或+号的字符
    var show = false;
    let uri = 'pages/contacts/accountants/Accountants';
    router.replace({
      uri: 'pages/contacts/accountants/Accountants',
      params: {
        phoneNumbers: [
          {
            'labelId': 2,
            'labelName': $r('app.string.phone'),
            'phoneNumber': number,
            'phoneAddress': 'N',
            'showP': show,
            'blueStyle': true
          }
        ]
      }
    });
  }
}


export class PermissionsManage {
  applyFlag: boolean = false;
  private static instance: PermissionsManage

  public getApplyFlag() {
    return this.applyFlag
  }

  public static getInstance(): PermissionsManage {
    if (!PermissionsManage.instance) {
      PermissionsManage.instance = new PermissionsManage()
    }
    return PermissionsManage.instance
  }

  async initPermissions() {
    let array: Array<string> = [
      "ohos.permission.READ_CONTACTS",
      "ohos.permission.WRITE_CONTACTS",
      "ohos.permission.MANAGE_VOICEMAIL",
      "ohos.permission.READ_CALL_LOG",
      "ohos.permission.PLACE_CALL"
    ];
    var bundleFlag = 0;
    var tokenID = undefined;
    var userID = 100;
    var appInfo = await bundle.getApplicationInfo('com.ohos.contacts', bundleFlag, userID);
    tokenID = appInfo.accessTokenId;
    var atManager = abilityAccessCtrl.createAtManager();
    let requestPermissions: Array<string> = [];
    for (let i = 0;i < array.length; i++) {
      var result = await atManager.verifyAccessToken(tokenID, array[i]);
      HiLog.i(TAG, 'Application initPermissions result%s', JSON.stringify(result));
      if (result == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        // 执行操作
      } else {
        // 申请动态授权，使用接口：requestPermissionsFromUser
        requestPermissions.push(array[i]);
      }
    }
    HiLog.i(TAG, 'SHOW Application initPermissions');
    if (requestPermissions.length == 0 || requestPermissions == []) {
      this.applyFlag = true;
      return;
    }
    let context = featureAbility.getContext();
    context.requestPermissionsFromUser(requestPermissions, 1, (data) => {
      HiLog.i(TAG, "data authResults:" + JSON.stringify(data.authResults));
      let authflag = true;
      for (let i = 0; i < data.authResults.length; i++) {
        if (data.authResults[i] == -1) {
          authflag = authflag && false;
        }
      }
      HiLog.i(TAG, "data authflag:" + JSON.stringify(authflag));
      this.applyFlag = authflag;
    });
    HiLog.i(TAG, 'Application requestPermissionsFromUser end');
  }
}