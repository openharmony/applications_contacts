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
import { AllCallsGetActionData, FindByNumberActionData } from '../../../../../../entry/src/main/ets/model/';
import { CallLog } from '../entity/CallLog';

/**
 * Call record warehouse operation interface, which provides database operation methods and shields the persistence layer logic.
 */
export default interface ICallLogRepository {
  saveOne: (callLog: CallLog, callback: (Contact?: number) => void) => void;
  clear: (callback: (Contact?: number) => void) => void;
  deleteById: (id: number) => boolean;
  deleteByIdIn: (ids: number[], callback: (Contact?: number) => void) => void;
  deleteByNumber: (number: string) => boolean;
  deleteByLookupUri: (lookupUri: string) => boolean;
  readByNumber: (number: string) => boolean;
  readById: (id: number) => boolean;
  findAll: (actionData: AllCallsGetActionData, callback: (Contact: CallLog[]) => void) => void;
  findByFeature: (feature: number) => CallLog[];
  findByNumberIn: (actionData: FindByNumberActionData, callback: (Contact: CallLog[]) => void) => void;
  notifyChange: () => void;
  registerDataChangeObserver: (callback: () => void) => void;
  unRegisterDataChangeObserver: (callback: () => void) => void;
}