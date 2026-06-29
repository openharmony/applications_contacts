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

import rpc from '@ohos.rpc';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import type IIdlMeetimeService from './i_idl_meetime_service';
import type {
  DeregisterServiceCallback,
  GetClientNameListCallback,
  InitClientCapabilityCallback,
  OffLineClientCallback,
  RegisterServiceCallback,
  pushToLoginCallback,
  GetActiveStatus,
} from './i_idl_meetime_service';

const TAG = 'IdlMeetimeServiceProxy';

export default class IdlMeetimeServiceProxy implements IIdlMeetimeService {

  private str: string = '';
  private boolean: boolean = false;

  public getStr(): string {
    return this.str;
  }

  public getBoolean(): boolean {
    return this.boolean;
  }
  constructor(proxy) {
    this.proxy = proxy;
  }

  getActiveStatus(rpcCallback: rpc.IRemoteObject, callback: GetActiveStatus): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageParcel();
    let reply = new rpc.MessageParcel();
    data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    data.writeRemoteObject(rpcCallback);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_GET_ACTIVE_STATUS, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          let returnValue = result.reply.readBoolean();
          callback(errCode, returnValue);
        } else {
          HiLog.e(TAG, 'sendRequest failed, errCode: ' + result.errCode);
        }
      });
  }

  registerService(rpcCallback: rpc.IRemoteObject, callback: RegisterServiceCallback): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageParcel();
    let reply = new rpc.MessageParcel();
    data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    data.writeRemoteObject(rpcCallback);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_REGISTER_SERVICE, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          callback(errCode);
        } else {
          HiLog.e(TAG, 'sendRequest failed, errCode: ' + result.errCode);
        }
      });
  }

  initClientCapability(clientScope: string, clientVersion: string, pkgName: string, type: number, profile: string,
                       callback: InitClientCapabilityCallback): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageParcel();
    let reply = new rpc.MessageParcel();
    data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    data.writeString(clientScope);
    data.writeString(clientVersion);
    data.writeString(pkgName);
    data.writeInt(type);
    data.writeString(profile);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_INIT_CLIENT_CAPABILITY, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          callback(errCode);
        } else {
          HiLog.i(TAG, 'sendRequest failed, errCode: ' + result.errCode);
        }
      });
  }

  getClientNameList(clientScope: string, callback: GetClientNameListCallback): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageParcel();
    let reply = new rpc.MessageParcel();
    data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    data.writeString(clientScope);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_GET_CLIENT_NAME_LIST, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          if (errCode !== 0) {
            let returnValue = undefined;
            callback(errCode, returnValue);
            return;
          }
          let returnValue = result.reply.readString();
          callback(errCode, returnValue);
        } else {
          HiLog.i(TAG, 'sendRequest failed, errCode: ' + result.errCode);
        }
      });
  }

  offLineClient(clientScope: string, deviceId: string, callback: OffLineClientCallback): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageParcel();
    let reply = new rpc.MessageParcel();
    data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    data.writeString(clientScope);
    data.writeString(deviceId);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_OFF_LINE_CLIENT, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          callback(errCode);
        } else {
          HiLog.i(TAG, 'sendRequest failed, errCode: ' + result.errCode);
        }
      });
  }

  deregisterService(clientScope: string, deviceId: string, callback: DeregisterServiceCallback): void {
    let _option = new rpc.MessageOption();
    let _data = new rpc.MessageParcel();
    let _reply = new rpc.MessageParcel();
    _data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    _data.writeString(clientScope);
    _data.writeString(deviceId);
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_OFF_LINE_CLIENT,
      _data, _reply, _option).then(function (result) {
      if (result.errCode === 0) {
        let _errCode = result.reply.readInt();
        callback(_errCode);
      } else {
        HiLog.i(TAG, `sendRequest failed, errCode:${result.errCode}`);
      }
    });
  }

  pushToLogin(callback: pushToLoginCallback): void {
    let _option = new rpc.MessageOption();
    let _data = new rpc.MessageParcel();
    _data.writeInterfaceToken(IdlMeetimeServiceProxy.DESCRIPTOR);
    let _reply = new rpc.MessageParcel();
    this.proxy.sendRequest(IdlMeetimeServiceProxy.COMMAND_PUSH_TO_LOGIN, _data, _reply, _option).then(function (result) {
      if (result.errCode === 0) {
        let _errCode = result.reply.readInt();
        if (_errCode !== 0) {
          callback(_errCode);
          return;
        }
        callback(_errCode);
      } else {
        HiLog.e(TAG, 'sendRequest failed, errCode:' + result.errCode);
      }
    });
  }

  static readonly COMMAND_REGISTER_SERVICE = 1;
  static readonly COMMAND_INIT_CLIENT_CAPABILITY = 3;
  static readonly COMMAND_GET_CLIENT_NAME_LIST = 4;
  static readonly COMMAND_OFF_LINE_CLIENT = 5;
  static readonly COMMAND_DEREGISTER_SERVICE = 8;
  static readonly COMMAND_PUSH_TO_LOGIN = 9;
  static readonly COMMAND_GET_ACTIVE_STATUS = 10;
  static readonly DESCRIPTOR: string = 'idl.IMeetimeService';
  private proxy;
}

