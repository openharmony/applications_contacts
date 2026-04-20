/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import IndexPresenter from '../presenter/IndexPresenter';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import Constants from '../../../../../common/src/main/ets/Constants';
import Want from '@ohos.app.ability.Want';
import { paramsInterface } from '../model/type';
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { targetPageClass } from '../model/type/ContactParams';

const TAG = 'DialogPageManager';

export default class PageManager {
  public mainUrl: string = 'pages/index';
  public context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  onCreate(want: Want) {
    HiLog.i(TAG, 'onCreate');
    this.onRequest(want.parameters as Record<string, Object>, true);
  }

  onNewWant(want: Want) {
    HiLog.i(TAG, 'onNewWant');
    this.onRequest(want.parameters as Record<string, Object>, false);
  }

  onDestroy() {
    HiLog.i(TAG, 'onDestroy');
  }

  // Go to a specified page.
  onRequest(parameters: Record<string, Object>, isOnCreate: boolean) {
    HiLog.i(TAG, `show pageRouteHandler routeMessage`);
    let url = 'pages/index';
    let urlName = '';
    let params: paramsInterface = {};
    let pageIndex = 1;
    if (parameters && parameters?.pageFlag) {
      HiLog.i(TAG, 'pageRouteHandler case is ' + parameters.pageFlag);
      switch (parameters.pageFlag.toString()) {
        case 'multi_num_dialog':
          url = 'pages/dialogPage/multiNumIndex';
          params = {
            sourceHasPhone: true,
            phoneNumberShow: parameters.phoneNumber,
          };
          break;
        case 'multi_sim_dialog':
          url = 'pages/dialogPage/multiSimIndex';
          params = {
            sourceHasPhone: true,
            phoneNumberShow: parameters.phoneNumber,
          };
          break;
        default:
          HiLog.e(TAG, 'pageRouteHandler and This page is not open.');
          if (isOnCreate) {
            break;
          } else {
            return;
          }
      }
    }
    if (isOnCreate) {
      this.mainUrl = url;
      if (this.mainUrl === 'pages/index') {
        ContactsGlobalThisHelper.GetGlobalThis().set<IndexPresenter>(ContactsGlobalThisHelper.IndexPresenterName,
          IndexPresenter.getInstance());
      }
      AppStorage.SetOrCreate('params', params);
    } else {
      AppStorage.setOrCreate(Constants.storage.targetPage, new targetPageClass(urlName, pageIndex, params));
      HiLog.i(TAG, 'pageRouteHandler finish!');
    }
  }
}