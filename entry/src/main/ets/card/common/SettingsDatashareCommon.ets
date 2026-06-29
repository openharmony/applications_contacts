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
import dataShare from '@ohos.data.dataShare';
import { BusinessError } from '@ohos.base';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import dataSharePredicates from '@ohos.data.dataSharePredicates';

const TAG = 'SettingsDataStorage';
let dataShareHelper: dataShare.DataShareHelper;

export class SettingsDataStorage {
  private context: Context = ContactsGlobalThisHelper.GetGlobalThis().getCardSpeedDialAbilityContext();
  private uri: string = 'datashare:///com.ohos.contactsdataability/contacts_on_card';
  public str: string = 'test';

  public async initData() {
    await dataShare.createDataShareHelper(this.context, this.uri).then((data: dataShare.DataShareHelper) => {
      HiLog.i(TAG, 'createDataShareHelper succeed, data : ' + data);
      dataShareHelper = data;
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `createDataShareHelper error: code: ${err.code}, message: ${err.message} `);
    })
  }

  public async update(addIds: string, deleteIds: string) {
    let data: ValuesBucket = {
      addIds: addIds,
      deleteIds: deleteIds
    };
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('id', 1);
    dataShareHelper.update(this.uri, predicates, data);
  }
}