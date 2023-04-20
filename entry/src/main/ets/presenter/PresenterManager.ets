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
import ContactListPresenter from './contact/ContactListPresenter';
import CallRecordPresenter from './dialer/callRecord/CallRecordPresenter';
import WorkerWrapper from "../workers/base/WorkerWrapper";

const TAG = 'PageManager'

export default class PresenterManager {
  static MAIN_PAGE: string = 'pages/index'
  context: Context;
  worker: WorkerWrapper;
  callRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  contactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();

  constructor(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
  }

  onCreate() {
    HiLog.i(TAG, "onCreate")
    this.callRecordPresenter.onCreate(this.context, this.worker);
    this.contactListPresenter.onCreate(this.context, this.worker);
    if (globalThis.config.needCache) {
      this.initDataCache();
    }
  }

  initDataCache() {
    CallRecordPresenter.getInstance().cachePageOne();
    ContactListPresenter.getInstance().cachePageOne();
  }

  onDestroy() {
    HiLog.i(TAG, "onDestroy")
    this.callRecordPresenter.onDestroy();
    this.contactListPresenter.onDestroy();
  }
}