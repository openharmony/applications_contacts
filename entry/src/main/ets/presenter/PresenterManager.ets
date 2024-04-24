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

import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import Constants from '../../../../../common/src/main/ets/Constants';
import ContactListPresenter from './contact/ContactListPresenter';
import CallRecordPresenter from './dialer/callRecord/CallRecordPresenter';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import Want from '@ohos.app.ability.Want';

const TAG = 'PageManager'

export default class PresenterManager {
  mainUrl: string = 'pages/index';
  context: Context;
  worker: WorkerWrapper;
  callRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  contactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();

  constructor(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
  }

  onCreate(want: Want) {
    HiLog.i(TAG, 'onCreate');
    this.onRequest(want.parameters, true);
    this.callRecordPresenter.onCreate(this.context, this.worker);
    this.contactListPresenter.onCreate(this.context, this.worker);
    if (this.mainUrl == 'pages/index' && globalThis.config.needCache) {
      this.initDataCache();
    }
  }

  onNewWant(want: Want) {
    HiLog.i(TAG, 'onNewWant');
    this.onRequest(want.parameters, false);
  }

  initDataCache() {
    CallRecordPresenter.getInstance().cachePageOne();
    ContactListPresenter.getInstance().cachePageOne();
  }

  onDestroy() {
    HiLog.i(TAG, 'onDestroy')
    this.callRecordPresenter.onDestroy();
    this.contactListPresenter.onDestroy();
  }

  // Go to a specified page.
  onRequest(parameters: { [key: string]: Object }, isOnCreate: boolean) {
    HiLog.i(TAG, 'show pageRouteHandler routeMessage ');
    let url = 'pages/index';
    let params = {};
    let pageIndex = 1;
    if (parameters?.pageFlag) {
      HiLog.i(TAG, 'pageRouteHandler case is ' + parameters.pageFlag);
      switch (parameters.pageFlag.toString()) {
      // jump to index
        case 'page_flag_dialer':
          AppStorage.SetOrCreate(Constants.Storage.mainTabsIndex, 0);
          params = {
            mainTabsIndex: 0
          }
          break;
        case 'page_flag_choose_contacts':
          AppStorage.SetOrCreate(Constants.Storage.mainTabsIndex, 1);
          params = {
            mainTabsIndex: 1
          }
          break;
        case 'page_flag_contact_details':
          url = 'pages/contacts/details/ContactDetail';
          pageIndex = 2;
          if (parameters.contactId) {
            params = {
              'sourceHasId': true,
              'contactId': parameters.contactId
            }
          } else {
            HiLog.i(TAG, 'SHOW pageRouteHandler and routeMessage.phoneNumber ');
            params = {
              'sourceHasPhone': true,
              'phoneNumberShow': parameters.phoneNumber,
            }
          }
          break;
        case 'page_flag_edit_before_calling':
          AppStorage.SetOrCreate(Constants.Storage.mainTabsIndex, 0);
          AppStorage.SetOrCreate(Constants.Storage.teleNumber, parameters.phoneNumber);
          params = {
            mainTabsIndex: 0, teleNumber: parameters.phoneNumber
          }
          break;
        case 'page_flag_save_contact':
          url = 'pages/contacts/accountants/Accountants';
          pageIndex = 3;
          params = {
            phoneNumbers: [
              {
                'phoneNumber': parameters.phoneNumber?.toString().replace(/[^0123456789+]*/g, ''),
              }
            ],
            'disPlayName': parameters.contactName
          }
          break;
        case 'page_flag_save_exist_contact':
          url = 'pages/contacts/selectContactsList/selectContactsList';
          pageIndex = 4;
          params = {
            type: 'saveContacts',
            number: parameters.phoneNumber
          }
          break;
        case 'page_flag_sms_forward':
          url = 'pages/contacts/batchselectcontacts/BatchSelectContactsPage'
          pageIndex = 4
          params = {
            selectType: 1
          }
          break;
        case 'page_flag_multi_choose':
          pageIndex = 4;
          url = 'pages/contacts/batchselectcontacts/BatchSelectContactsPage'
          params = {
            selectType: 0
          }

          break;
        case 'page_flag_single_choose':
          pageIndex = 4;
          url = 'pages/contacts/batchselectcontacts/SingleSelectContactPage'
          params = {
            selectType: 0
          }
          break;
        default:
          HiLog.e(TAG, 'pageRouteHandler and This page is not open.');
          break;
      }
    }
    if (isOnCreate) {
      this.mainUrl = url;
      AppStorage.SetOrCreate('params', params);
    } else {
      AppStorage.SetOrCreate(Constants.Storage.targetPage, {
        url: url,
        pageIndex: pageIndex,
        params: params
      })
      HiLog.i(TAG, 'pageRouteHandler finish!');
    }
  }
}