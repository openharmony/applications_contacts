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
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'MissedCallDataShareTAG';
const PRIVACY_TAG = 'privacy_tag';
let dataShareHelper: dataShare.DataShareHelper;

export class MissedCallDataShare {
  private uri: string = 'datashare:///com.ohos.calllogability/calls/calllog';
  public flag: boolean = true;

  public async initData() {
    await dataShare.createDataShareHelper(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext(),
      this.uri).then((data: dataShare.DataShareHelper) => {
      HiLog.i(TAG, 'createDataShareHelper succeed, data : ' + data);
      dataShareHelper = data;
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `createDataShareHelper error: code: ${err.code}, message: ${err.message} `);
    })
  }

  public async setMissedLogToRead(phone: string[]) {
    let da = new dataSharePredicates.DataSharePredicates();
    da.in('phone_number', phone);
    let data: ValuesBucket = {
      'is_read': 1,
    }
    const va: ValuesBucket = data;
    HiLog.i(TAG, '[dataUpdate] begin');
    await dataShareHelper.update(this.uri, da, va).then((data) => {
      HiLog.i(TAG, 'update succeed, data : ' + data);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `insert error: code: ${err.code}, message: ${err.message} `);
    })
    await this.updatePrivacyTagOfMissedCall(dataShareHelper, phone);
  }

  private async updatePrivacyTagOfMissedCall(dataShareHelper: dataShare.DataShareHelper,
    phone: string[]): Promise<void> {
    const condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(PRIVACY_TAG, 0);
    if (phone.length > 0) {
      condition.and().in('phone_number', phone);
    }
    try {
      const result = await dataShareHelper.update(this.uri, condition, { PRIVACY_TAG: 1 });
      HiLog.i(TAG, 'updatePrivacyTagOfMissedCall update succ :%s', result.toString());
    } catch (error) {
      HiLog.e(TAG, 'updatePrivacyTagOfMissedCall error:%s', error?.message);
    }
  }
}
