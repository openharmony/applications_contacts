/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { ResourceUtil } from '../../../../../entry/src/main/ets/util/ResourceUtil';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';

const TAG = 'SyncContactsExtAbility';

/**
 * Sync Contacts UI Extension Ability
 * This ability is used to display the sync contacts confirmation dialog
 */
export default class SyncContactsExtAbility extends UIExtensionAbility {
  private storage: LocalStorage | null = null;

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    HiLog.i(TAG, 'SyncContactsExtAbility onSessionCreate');
    
    let dialogInfo: SyncDialogInfo = {
      syncMode: 0,
      syncId: '',
      localCount: 0,
      cloudCount: 0,
      confirmAction: 0, // 0=unknown, 1=confirmed, 2=cancelled
      bundleName: '',
      appName: '',
    };
    
    // Parse parameters from want
    if (want?.parameters) {
      const params = want.parameters as Record<string, Object>;
      dialogInfo.syncMode = params['syncMode'] as number || 0;
      dialogInfo.syncId = params['syncId'] as string || '';
      dialogInfo.localCount = params['localCount'] as number || 0;
      dialogInfo.cloudCount = params['cloudCount'] as number || 0;
      dialogInfo.bundleName = params['bundleName'] as string || '';
    }

    dialogInfo.appName = getAppNameByPackageName(dialogInfo.bundleName);
    HiLog.i(TAG, `SyncContactsExtAbility dialogInfo: syncMode=${dialogInfo.syncMode}, syncId= ${dialogInfo.syncId}` +
      `localCount=${dialogInfo.localCount}, cloudCount=${dialogInfo.cloudCount}`);
    
    let param: Record<string, Object> = {
      'session': session,
      'dialogInfo': dialogInfo
    };
    
    this.storage = new LocalStorage(param);
    session.loadContent('syncContactsAbility/dialog/SyncContactsDialog', this.storage);
    session.setWindowBackgroundColor('#00000000');
  }

  onSessionDestroy(session: UIExtensionContentSession): void {
    HiLog.i(TAG, 'SyncContactsExtAbility onSessionDestroy');
    if (this.storage) {
      this.storage.clear();
      this.storage = null;
    }
  }
}

/**
 * Sync Dialog Info structure
 */
export interface SyncDialogInfo {
  syncMode: number;       // 1: MODE_INCREMENTAL, 2: MODE_CLOUD_BASED
  syncId: string;         // Sync identifier
  localCount: number;     // Local contacts count
  cloudCount: number;     // Cloud contacts count
  confirmAction: number;  // User confirmation action: 0=unknown, 1=confirmed, 2=cancelled
  bundleName: string;
  appName: string;
}

function getAppNameByPackageName(packageName: string): string {
  HiLog.w(TAG, `getAppNameByPackageName packageName: ${packageName}`);
  let appName = '';
  if (StringUtil.isEmpty(packageName)) {
    appName = ResourceUtil.getStringByResource($r('app.string.unknown'));
    HiLog.w(TAG, 'getAppNameByPackageName packageName is empty, return');
    return appName;
  }
  const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
  try {
    const resourceInfo = bundleResourceManager.getBundleResourceInfo(packageName, bundleFlags);
    appName = resourceInfo.label;
    HiLog.w(TAG, `applicationName name : ${appName}`);
  } catch (err) {
    let message = (err as BusinessError).message;
    HiLog.e(TAG, 'getBundleResourceInfo failed: %{public}s', message);
  }
  if (StringUtil.isEmpty(appName)) {
    appName = ResourceUtil.getStringByResource($r('app.string.unknown'));
    HiLog.w(TAG, 'getAppNameByPackageName appName is unknown');
  }
  return appName;
}