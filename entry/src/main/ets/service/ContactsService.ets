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
import { ContactRepository } from '../../../../../feature/contact';
import { HiLog, ArrayUtil } from '../../../../../common';
import { ContactVo } from '../model/bean/ContactVo';
import WorkerWrapper from "../workers/base/WorkerWrapper";
import { DataWorkerConstant } from "../workers/DataWorkerWrapper";
import emitter from '@ohos.events.emitter'
import Constants from '../../../../../common/src/main/ets/Constants';

const TAG = "ContactsService"

export default class ContactsService {
  page: number = 0;
  limit: number = 50;
  contactList: ContactVo[] = [];
  context: Context;
  worker: WorkerWrapper;
  innerEvent = {
    eventId: Constants.Event.CONTACTS_CHANGE,
    priority: emitter.EventPriority.HIGH
  };
  onContactsChange = () => {
    HiLog.i(TAG, 'onContactsChange refresh');
    this.requestItem();
  }

  constructor(context: Context, worker: WorkerWrapper) {
    this.context = context;
    this.worker = worker;
    this.requestItem();
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactsChange);
  }

  onDestroy() {
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactsChange);
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
    this.worker.sendRequest(DataWorkerConstant[DataWorkerConstant.getAllContact], {
      actionData: actionData,
      context: this.context
    }, (result) => {
      HiLog.i(TAG, 'getAllContact and refresh, length is: ' + JSON.stringify(result.length));
      if (!ArrayUtil.isEmpty(result)) {
        this.contactList = this.contactList.concat(result);
      }
      const contactCount = result.length;
      AppStorage.SetOrCreate<ContactVo[]>('contactList', this.contactList);
      emitter.emit(this.innerEvent);
      if (contactCount < this.limit) {
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
}