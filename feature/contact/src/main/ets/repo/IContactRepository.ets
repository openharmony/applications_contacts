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

import {
    AllContactGetParam,
    AllContactWithPhoneNumbersGetParam
} from '../../../../../../entry/src/main/ets/model/type/ContactParams';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

/**
 * Contact storage management, shielding dependency on the CP layer
 * Contacts Only
 */
export default interface IContactRepository {
  findById: (id: number, callback: Function) => void;
  findByQuickSearchKey: (searchKey: string, callback: Function) => void;
  findAll: (actionData: AllContactGetParam, callback: (resultSet?: DataShareResultSet) => void) => void;
  findByPhoneIsNotNull: (addParams: AllContactWithPhoneNumbersGetParam, callback: Function) => void;
  deleteByIdIn: (ids: number[], callback: Function) => void;
  deleteById: (id: number, callback: Function) => void;
  notifyChange: () => void;
  registerDataChangeObserver: (callback: () => void) => void;
  unRegisterDataChangeObserver: (callback: () => void) => void;
}