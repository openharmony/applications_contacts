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
import { privacyManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';


const TAG = 'PermissionUtil';

export function addPermissionUsedRecord(callerToken: number) {
  if (callerToken > 0) {
    HiLog.w(TAG, `addPermissionUsedRecord start`)
    let options: privacyManager.AddPermissionUsedRecordOptions = {
      usedType: privacyManager.PermissionUsedType.PICKER_TYPE
    }
    privacyManager.addPermissionUsedRecord(callerToken, 'ohos.permission.READ_CONTACTS', 1, 0, options).then(() => {
      HiLog.w(TAG, 'addPermissionUsedRecord success');
    }).catch((reason: BusinessError) => {
      HiLog.e(TAG, 'addPermissionUsedRecord error reason == ' + reason?.message);
    })
  }
}
