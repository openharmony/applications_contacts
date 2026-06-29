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

import { HiLog } from '../../../../../feature/call/oh_modules/common';
import { accessibility } from '@kit.AccessibilityKit';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { Contacts } from '../../../../../feature/contact';
import { dataShare } from '@kit.ArkData';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../data/Constants';
import { ResourceUtil } from './ResourceUtil';

const TAG = 'AccessibilityUtil'

export default class AccessibilityUtil {
  private static accessibilityUtil: AccessibilityUtil;
  public static ISOPENACCESSIBILITY = 'isOpenAccessibility';
  public static recoveredContactCount = 0

  public static getInstance(): AccessibilityUtil {
    if (AccessibilityUtil.accessibilityUtil == null) {
      AccessibilityUtil.accessibilityUtil = new AccessibilityUtil();
    }
    return AccessibilityUtil.accessibilityUtil;
  }

  public getAccessibilitySwitchState() {
    AppStorage.setOrCreate(AccessibilityUtil.ISOPENACCESSIBILITY, accessibility.isScreenReaderOpenSync());
    accessibility.on('screenReaderStateChange', this.handleAccessibilityStateChange);
  }

  private handleAccessibilityStateChange(isAccessibilityStateChanged: boolean) {
    HiLog.i(TAG, `isOpenAccessibility: ${isAccessibilityStateChanged}`);
    AppStorage.setOrCreate(AccessibilityUtil.ISOPENACCESSIBILITY, isAccessibilityStateChanged);
  }

  public async resumingContactsCount(): Promise<number> {
    let context = getContext(this) as Context;
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, Contacts.CONTENT_URI);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    try {
      let size: number = await dataShareHelper.update(Contacts.QUERY_CONTACT_COUNT_DOUBLE_DB_URI, conditionArgs, {'a': 'b'});
      HiLog.w(TAG, 'double db size：' + size);
      AccessibilityUtil.recoveredContactCount = size;
      return AccessibilityUtil.recoveredContactCount;
    } catch (error) {
      HiLog.e(TAG, `updatexx error: ${error?.message}`);
      return 0; 
    }
  }

  public releaseAccessibility() {
    HiLog.i(TAG, 'releaseAccessibility...')
    accessibility.off('accessibilityStateChange', this.handleAccessibilityStateChange);
  }

  public setAccessibilityText(isOpenAccessibility: boolean, resource: Resource): string {
    if (isOpenAccessibility) {
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().resourceManager.getStringSync(resource.id);
    } else {
      return '';
    }
  }

  public setAccessibilityPluralStringValueSync(isOpenAccessibility: boolean, resource: Resource, num: number): string {
    if (isOpenAccessibility) {
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getPluralStringValueSync(resource, num);
    } else {
      return '';
    }
  }

  // 立即发送主动聚焦 不加延时
  public instantlySendAccessibilityEvent(isOpenAccessibility: boolean, customId: string) {
    if (isOpenAccessibility) {
      setTimeout(() => {
        let eventInfo: accessibility.EventInfo = ({
          type: 'requestFocusForAccessibility',
          bundleName: Constants.CONTACT_BUNDLE_NAME,
          triggerAction: 'common',
          customId: customId
        });
        accessibility.sendAccessibilityEvent(eventInfo).then(() => {
          HiLog.w(TAG, `instantlySendAccessibilityEvent success`);
        }).catch((err: BusinessError) => {
          HiLog.e(TAG, `instantlySendAccessibilityEvent, err is ${err?.message}`);
        });
      });
    }
  }
  public sendAccessibilityEvent(isOpenAccessibility: boolean, customId: string, asyncTime: number = 500) {
    // 非无障碍模式下不重新聚焦
    if (isOpenAccessibility) {
      setTimeout(() => {
        let eventInfo: accessibility.EventInfo = ({
          type: 'requestFocusForAccessibility',
          bundleName: Constants.CONTACT_BUNDLE_NAME,
          triggerAction: 'common',
          customId: customId
        });
        accessibility.sendAccessibilityEvent(eventInfo).then(() => {
          HiLog.i(TAG, `sendAccessibilityEvent success`);
        }).catch((err: BusinessError) => {
          HiLog.e(TAG, `sendAccessibilityEvent, err is ${err?.message}`);
        });
      }, asyncTime);
    }
  }
  // 主动聚焦不打断事件
  public sendAccessibilityNotInterruptEvent(isOpenAccessibility: boolean, customId: string, delay: number = 500) {
    if (!isOpenAccessibility) {
      return;
    }
    if (delay === 0) {
      let eventInfo: accessibility.EventInfo = ({
        type: 'requestFocusForAccessibilityNotInterrupt',
        bundleName: Constants.CONTACT_BUNDLE_NAME,
        triggerAction: 'common',
        customId: customId
      });
      accessibility.sendAccessibilityEvent(eventInfo).then(() => {
        HiLog.i(TAG, `sendAccessibilityNotInterruptEvent success`);
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `sendAccessibilityNotInterruptEvent, err is ${err?.message}`);
      });
      return;
    }
    setTimeout(() => {
      let eventInfo: accessibility.EventInfo = ({
        type: 'requestFocusForAccessibilityNotInterrupt',
        bundleName: Constants.CONTACT_BUNDLE_NAME,
        triggerAction: 'common',
        customId: customId
      });
      accessibility.sendAccessibilityEvent(eventInfo).then(() => {
        HiLog.i(TAG, `sendAccessibilityNotInterruptEvent success`);
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `sendAccessibilityNotInterruptEvent, err is ${err?.message}`);
      });
    }, delay);
  }

  public sendAccessibilityEventInfo(info: string) {
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: Constants.CONTACT_BUNDLE_NAME,
      triggerAction: 'common',
      textAnnouncedForAccessibility: info
    });
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      HiLog.i(TAG, `sendAccessibilityEventSuccess`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `sendAccessibilityEventInfo, err is ${err.message}`);
    });
  }

  public sendAllSelectedOrDeselected(isAllSelected: boolean, itemCount: number) {
    // 播报 已全选/已取消全选
    let broadcastTextMajor: string = isAllSelected ? ResourceUtil.getStringByResource($r('app.string.all_selected')):
      ResourceUtil.getStringByResource($r('app.string.all_selected_cancel'));
    let broadcastTextMinor: string = ResourceUtil.getPluralStringByResource($r('app.plural.select_all_play_button'),
      itemCount);
    accessibility.sendAccessibilityEvent(({
      type: 'announceForAccessibility',
      bundleName: Constants.CONTACT_BUNDLE_NAME,
      triggerAction: 'common',
      textAnnouncedForAccessibility: `${broadcastTextMajor} ${broadcastTextMinor}`
    })).then(() => {
      HiLog.i(TAG, `sendAllSelectedOrDeselected`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `sendAllSelectedOrDeselected, err is ${err.message}`);
    });
  }

  public setAccessibilityTextStr(isOpenAccessibility: boolean, resource: string): string {
    if (isOpenAccessibility) {
      return resource;
    } else {
      return '';
    }
  }
}
