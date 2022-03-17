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

import CallLog from '../entity/CallLog';

/**
 * 通话记录仓库操作接口，提供数据库操作方法，屏蔽持久层逻辑
 */
export default interface ICallLogRepository {
  saveOne: (callLog: CallLog) => Promise<number>;
  save: (callLogs: CallLog[]) => boolean;
  clear: () => Promise<number>;
  deleteById: (id: number) => boolean;
  deleteByIdIn: (ids: number[]) => Promise<number>;
  deleteByNumber: (number: string) => boolean;
  deleteByLookupUri: (lookupUri: string) => boolean;
  readByNumber: (number: string) => boolean;
  readById: (id: number) => boolean;
  findAll: () => Promise<CallLog[]>;
  findByCallDirectionIn: (callTypes: number[]) => Promise<CallLog[]>;
  findByFeature: (feature: number) => CallLog[];
  findByNumberIn: (numbers: number[]) => Promise<CallLog[]>;
}