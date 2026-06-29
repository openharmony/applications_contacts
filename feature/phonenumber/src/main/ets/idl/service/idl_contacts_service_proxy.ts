/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import type {
  BatchQueryContactCapabilityCallback,
  InsertContactsCallback,
  QueryUserInfoByPhoneNumberCallback,
  queryContactCapabilityByPhoneNumbersCallback
} from './i_idl_contacts_service';
import type IIdlContactsService from './i_idl_contacts_service';
import rpc from '@ohos.rpc';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = '[MEETIME_contastServicesApi] IdlContactsServiceProxy';

export default class IdlContactsServiceProxy implements IIdlContactsService {
  constructor(proxy) {
    this.proxy = proxy;
  }

  queryUserInfoByPhoneNumber(data: string, callback: QueryUserInfoByPhoneNumberCallback): void {
    throw new Error('Method not implemented.');
  }

  /**
   * 发送写入数据库请求
   *
   * @param inputData inputData
   * @param callback callback
   */
  public insertContacts(inputData: string, callback: InsertContactsCallback): void {
    if (!inputData || !callback) {
      HiLog.e(TAG, 'insertContacts input params is invalid');
      return;
    }

    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(IdlContactsServiceProxy.DESCRIPTOR);
    data.writeString(inputData);

    this.proxy.sendMessageRequest(IdlContactsServiceProxy.COMMAND_INSERT_CONTACTS, data, reply, option)
      .then(function (result) {
        let returnValue = result.reply.readInt();
        HiLog.i(TAG, 'insertContacts sendRequest reply return');
        callback(returnValue);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  /**
   * 发送联系人能力查询请求
   *
   * @param inputData inputData
   * @param callback callback
   */
  public batchQueryContactCapability(inputData: string, callback: BatchQueryContactCapabilityCallback): void {
    if (!inputData || !callback) {
      HiLog.e(TAG, 'batchQueryContactCapability input params is invalid');
      return;
    }

    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(IdlContactsServiceProxy.DESCRIPTOR);
    data.writeString(inputData);
    this.proxy.sendMessageRequest(IdlContactsServiceProxy.COMMAND_QUERY_CONTACT_ABILITY, data, reply, option)
      .then(function (result) {
        let returnValue = result.reply.readString();
        HiLog.i(TAG, 'batchQueryContactCapability sendRequest reply return');
        callback(returnValue);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  public queryContactCapabilityByPhoneNumbers(contactId: number, phoneNumberList: string, callback: queryContactCapabilityByPhoneNumbersCallback): void {
    if (typeof(contactId) !== 'number' || !phoneNumberList) {
      HiLog.e(TAG, 'queryContactCapabilityByPhoneNumbers parameter is invalid, return.');
      callback('');
      return;
    }

    let _option = new rpc.MessageOption();
    let _data = rpc.MessageSequence.create();
    let _reply = rpc.MessageSequence.create();

    _data.writeInterfaceToken(IdlContactsServiceProxy.DESCRIPTOR);
    _data.writeInt(contactId);
    _data.writeString(phoneNumberList);

    this.proxy.sendMessageRequest(IdlContactsServiceProxy.COMMAND_QUERY_CONTACT_CAPABILIY_BY_PHONE_NUMBERS, _data, _reply, _option)
      .then(function (result) {
        let returnValue = result.reply.readString();
        HiLog.i(TAG, 'queryContactCapabilityByPhoneNumbers sendRequest reply return');
        callback(returnValue);
      })
      .finally(() => {
        _data.reclaim();
        _reply.reclaim();
      });
  }

  static readonly COMMAND_INSERT_CONTACTS = 1;
  static readonly COMMAND_QUERY_CONTACT_ABILITY = 21;
  static readonly COMMAND_QUERY_CONTACT_CAPABILIY_BY_PHONE_NUMBERS = 22;
  private proxy: rpc.IRemoteObject;
  static readonly DESCRIPTOR: string = 'idl.IContactsService';
}

