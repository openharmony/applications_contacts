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
import pasteboard from '@ohos.pasteboard';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import StringFormatUtil from '../util/StringFormatUtil';
import { missedCallManager } from '../feature/missedCall/MissedCallManager';
import CallRecordPresenter from './dialer/callRecord/CallRecordPresenter';

const TAG = 'IndexPresenter  ';

export default class IndexPresenter {
  private static instance: IndexPresenter;
  uriTabFlag: boolean = false;
  isEditNum: boolean = false;
  editPhoneNumber: string = "";
  tabsIndex: number = 0;

  public static getInstance(): IndexPresenter {
    if (!IndexPresenter.instance) {
      IndexPresenter.instance = new IndexPresenter();
    }
    return IndexPresenter.instance;
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow !!!');
    if (AppStorage.Get("indexTabs") === 0) {
      this.tabsIndex = 0;
    }
    this.uriTabFlag = !this.uriTabFlag;
    if (this.isEditNum) {
      this.editPhoneNumber = AppStorage.Get("tele_number");
      this.isEditNum = !this.isEditNum;
    }
    this.cancelMissedCallNotification()
    this.getNewWant();
    if (parseInt(StringFormatUtil.judgeSysTime()) !== AppStorage.Get("sysTime")) {
      HiLog.i(TAG, 'DO requestItem cause systemTime changed');
      CallRecordPresenter.getInstance().requestItem();
      AppStorage.SetOrCreate("sysTime", parseInt(StringFormatUtil.judgeSysTime()));
    }
  }

  cancelMissedCallNotification() {
    HiLog.i(TAG, `cancelMissedCallNotification`);
    missedCallManager.cancelNotification()
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear !!!');
    AppStorage.SetOrCreate("sysTime", parseInt(StringFormatUtil.judgeSysTime()));
    AppStorage.SetOrCreate('router', router.getState());
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear !!!');
  }

  getNewWant() {
    let Want = globalThis.abilityWant;
    if (StringUtil.isEmpty(Want)) {
      return;
    }
    globalThis.abilityWant = null;
    HiLog.i(TAG, 'do getNewWant success: want is  ' + JSON.stringify(Want));
    if (StringUtil.isEmpty(Want.uri) && StringUtil.isEmpty(Want.parameters.pageFlag)) {
      HiLog.e(TAG, 'Route message is invalid.');
    } else if (!StringUtil.isEmpty(Want.uri)) {
      HiLog.i(TAG, "want uri is not empty!");
      this.pageRouteHandler({
        pageFlag: Want.uri
      });
    } else {
      HiLog.i(TAG, "go pageRouteHandler");
      this.pageRouteHandler(Want.parameters);
    }
  }

  // Go to a specified page.
  pageRouteHandler(routeMessage) {
    HiLog.i(TAG, 'show pageRouteHandler routeMessage ');
    let uri = "";
    let params = {};
    if (StringUtil.isEmpty(routeMessage.pageFlag)) {
      HiLog.i(TAG, 'pageRouteHandler and routeMessage.pageFlag isEmpty ');
      return;
    }
    HiLog.i(TAG, 'pageRouteHandler case is ' + routeMessage.pageFlag);
    switch (routeMessage.pageFlag.toString()) {
    // jump to index
      case 'page_flag_dialer':
        router.back({
          url: "pages/index"
        });
        this.tabsIndex = 0;
        this.uriTabFlag = !this.uriTabFlag;
        return;
      case 'page_flag_choose_contacts':
        router.back({
          url: "pages/index"
        });
        this.tabsIndex = 1;
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
      case 'page_flag_edit_before_calling':
        router.back({
          url: "pages/index"
        });
        this.tabsIndex = 0;
        this.uriTabFlag = !this.uriTabFlag;
        this.editBeforeCall(routeMessage.phoneNumber);
        this.isEditNum = true;
        return;
      case 'page_flag_save_contact':
        this.addContacts(routeMessage);
        return;
      case 'page_flag_save_exist_contact':
        this.saveToContacts(routeMessage.phoneNumber);
        return;
      case 'page_flag_sms_forward':
        router.push({
          url: 'pages/contacts/batchselectcontacts/BatchSelectContactsPage',
          params: {
            selectType: 1
          }
        });
        return;
      case 'page_flag_multi_choose':
        router.push({
          url: 'pages/contacts/batchselectcontacts/BatchSelectContactsPage',
          params: {
            selectType: 0
          }
        });
        return;
      case 'page_flag_single_choose':
        router.push({
          url: 'pages/contacts/batchselectcontacts/SingleSelectContactPage',
          params: {
            selectType: 0
          }
        });
        return;
      default:
        HiLog.e(TAG, 'pageRouteHandler and This page is not open.');
        break;
    }
    HiLog.i(TAG, 'SHOW final uri');
    router.replace({
      url: uri,
      params: params
    });
  }

  editBeforeCall(phoneNumber) {
    this.editPhoneNumber = phoneNumber;
  }

  saveToContacts(phoneNumber) {
    router.replace({
      url: 'pages/contacts/selectContactsList/selectContactsList',
      params: {
        type: 'saveContacts',
        number: phoneNumber
      }
    });
  }

  addContacts(routeMessage) {
    let phoneNumber = routeMessage.phoneNumber;
    let contactName = routeMessage.contactName
    let number = phoneNumber.replace(/[^0123456789+]*/g, '');
    router.replace({
      url: 'pages/contacts/accountants/Accountants',
      params: {
        phoneNumbers: [
          {
            'phoneNumber': number,
          }
        ],
        'disPlayName': contactName
      }
    });
  }

  getCopy(phoneNumber) {
    HiLog.i(TAG, 'Succeeded PasteData is ' + JSON.stringify(phoneNumber));
    let pasteData = pasteboard.createPlainTextData(phoneNumber);
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setPasteData(pasteData, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'Failed to set PasteData. Cause: ' + JSON.stringify(err.message));
        return;
      }
      HiLog.i(TAG, 'Succeeded in setting PasteData.');
    });
  }

  getTabSrc(tabIndex: number, index: number): Resource {
    let imgSrc = $r('app.media.ic_call_filled_normal');
    if (index === 1) {
      imgSrc = $r("app.media.ic_contacts_normal_filled");
    }
    return imgSrc;
  }

  getTabText(tabIndex: number, index: number): Resource {
    let text = $r('app.string.dialer');
    if (index === 1) {
      text = $r('app.string.contact');
    }
    return text;
  }

  getTabTextColor(tabIndex: number, index: number): Resource {
    let color = $r('sys.color.ohos_id_color_bottom_tab_text_off');
    if (tabIndex === index) {
      color = $r('sys.color.ohos_id_color_connected');
    }
    return color;
  }
}