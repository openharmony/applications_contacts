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

import type rpc from '@ohos.rpc';

export default interface IIdlMeetimeService {
  /**
   * 获取畅连app是否登录
   * @param rpcCallback
   * @param callback
   */
  getActiveStatus(rpcCallback: rpc.IRemoteObject, callback: RegisterServiceCallback): void;

  registerService(rpcCallback: rpc.IRemoteObject, callback: RegisterServiceCallback): void;

  initClientCapability(clientScope: string, clientVersion: string, pkgName: string, type: number, profile: string,
    callback: InitClientCapabilityCallback): void;

  getClientNameList(clientScope: string, callback: GetClientNameListCallback): void;

  offLineClient(clientScope: string, deviceId: string, callback: OffLineClientCallback): void;

  deregisterService(clientScope: string, deviceId: string, callback: DeregisterServiceCallback): void;

  pushToLogin(callback: pushToLoginCallback): void;
}

export type GetActiveStatus = (errCode: number, returnValue: boolean) => void;

export type RegisterServiceCallback = (errCode: number) => void;

export type InitClientCapabilityCallback = (errCode: number) => void;

export type GetClientNameListCallback = (errCode: number, returnValue: string) => void;

export type OffLineClientCallback = (errCode: number) => void;

export type DeregisterServiceCallback = (errCode: number) => void;

export type pushToLoginCallback = (errCode: number) => void;