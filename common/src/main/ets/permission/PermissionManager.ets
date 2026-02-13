/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { HiLog } from '../util/HiLog';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import { ContactsGlobalThisHelper } from '../util/ContactsGlobalThisHelper';

const TAG = 'PermissionManager';

export class PermissionManager {
  private _isAllPermissionsGranted: boolean = false;
  private static instance: PermissionManager;

  private constructor() {
  }

  public static getInstance(): PermissionManager {
    if (!PermissionManager.instance) {
      PermissionManager.instance = new PermissionManager();
    }
    return PermissionManager.instance;
  }

  public isAllPermissionsGranted() {
    return this._isAllPermissionsGranted;
  }

  async initPermissions() {
    let requestPermissions: Permissions[] = [
      'ohos.permission.READ_CONTACTS',
      'ohos.permission.WRITE_CONTACTS',
      // 'ohos.permission.MANAGE_VOICEMAIL',
      'ohos.permission.READ_CALL_LOG',
      'ohos.permission.WRITE_CALL_LOG'
    ];
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      requestPermissions)
      .then((data) => {
        HiLog.i(TAG, 'AuthResult is: ' + data?.authResults);
        let authFlag = true;
        for (let i = 0; i < data.authResults.length; i++) {
          if (data.authResults[i] == -1) {
            authFlag = authFlag && false;
          }
        }
        HiLog.i(TAG, 'authFlag: ' + authFlag);
        this._isAllPermissionsGranted = authFlag;
      })
      .catch((err: BusinessError) => {
        HiLog.e(TAG, 'requestPermissionsFromUser err:' + err?.message + ', stack: ' + err?.stack);
      });
    HiLog.i(TAG, 'Application requestPermissionsFromUser end');
  }
}