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
import StringUtil from '../util/StringUtil';
import featureAbility from '@ohos.ability.featureAbility';

const TAG = 'IndexPresenter  ';

export class IndexPresenter {
  uriTabFlag: boolean = false;
  tabsIndex: number = 0;
  editPhoneNumber: string = "";
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
      if (StringUtil.isEmpty(Want.uri) && StringUtil.isEmpty(Want.parameters.pageFlag)) {
        HiLog.i(TAG, 'pageRouteHandler and routeMessage.pageFlag isEmpty ');
      } else if (!StringUtil.isEmpty(Want.uri)) {
        HiLog.i(TAG, "want uri is not empty!");
        this.pageRouteHandler({
          pageFlag: Want.uri
        });
      } else {
        HiLog.i(TAG, "go pageRouteHandler");
        this.pageRouteHandler(Want.parameters);
      }
    }).catch((error) => {
      HiLog.e(TAG, 'aboutToAppear logMessage Operation failed. Cause:%s ', JSON.stringify(error.message));
    })
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear !!!');
  }

  // Go to a specified page.
  pageRouteHandler(routeMessage) {
    HiLog.i(TAG, 'show pageRouteHandler routeMessage ');
    let uri = "";
    let params = {};
    if (StringUtil.isEmpty(routeMessage.pageFlag)) {
      this.goToContacts();
      HiLog.i(TAG, 'pageRouteHandler and routeMessage.pageFlag isEmpty ');
      return;
    }
    HiLog.i(TAG, 'pageRouteHandler case is ' + routeMessage.pageFlag);
    switch (routeMessage.pageFlag.toString()) {
    // jump to index
      case 'page_flag_choose_contacts':
        this.tabsIndex = 1;
        this.uriTabFlag = !this.uriTabFlag;
        return;
      case 'page_flag_dialer':
        this.tabsIndex = 0;
        this.uriTabFlag = !this.uriTabFlag;
        return;

      case 'page_flag_contact_details':
        uri = "pages/contacts/details/ContactDetail";
        if (routeMessage.contactId) {
          params = {
            'sourceHasId': true,
            'contactId': routeMessage.contactId
          }
        } else {
          HiLog.i(TAG, 'SHOW pageRouteHandler and routeMessage.phoneNumber ');
          params = {
            'sourceHasPhone': true,
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
          'navigationType': 'contacts'
        }
        break;
      case 'page_flag_edit_before_calling':
        this.editBeforeCall(routeMessage.phoneNumber);
        break;
      case 'page_flag_save_contact':
        this.addContacts(routeMessage.phoneNumber);
        break;
      case 'page_flag_save_exist_contact':
        this.saveToContacts(routeMessage.phoneNumber);
        break;
      case 'page_flag_sms_forward':
        uri = 'pages/contacts/batchselectcontacts/batchselectcontacts';
        params = {
          selectType: 1
        }
        break;
      case 'page_flag_mult_choose':
        uri = 'pages/contacts/batchselectcontacts/BatchSelectContactsPage';
        params = {
          selectType: 0
        }
        break;
      case 'page_flag_call_logs':
        uri = 'pages/navigation/navigation';
        params = {
          'navigationType': 0
        }
        break;
      case 'page_flag_missed_calls':
        this.goToMissedCalls();
        break;
      case 'page_flag_card_details':
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

  goToMyCard() {
  }

  editBeforeCall(phoneNumber) {
    this.editPhoneNumber = phoneNumber;
    this.tabsIndex = 0;
    this.uriTabFlag = !this.uriTabFlag;
  }

  goToMissedCalls() {
  }

  goToContacts() {
  }

  saveToContacts(phoneNumber) {
    router.replace({
      uri: 'pages/contacts/selectContactsList/selectContactsList',
      params: {
        type: 'saveContacts',
        number: phoneNumber,
      }
    });
  }

  addContacts(phoneNumber) {
    let number = phoneNumber.replace(/[^0123456789+]*/g, '');
    let show = false;
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
    let requestPermissions: Array<string> = [
      "ohos.permission.READ_CONTACTS",
      "ohos.permission.WRITE_CONTACTS",
      "ohos.permission.MANAGE_VOICEMAIL",
      "ohos.permission.READ_CALL_LOG"
    ];
    let context = featureAbility.getContext();
    context.requestPermissionsFromUser(requestPermissions, 1, (result) => {
      let data: any = result;
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