/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import numberLookup from '@ohos.telephony.numberLookup';
import { HiLog } from './HiLog';
import call from '@ohos.telephony.call';

const TAG = 'NumberAddressUtil';

export class NumberAddressUtil {
  static async getNumberLocation(context, number: string, isExactMatch?: boolean): Promise<string> {
    HiLog.w(TAG, 'getNumberLocation');
    try {
      let location = await numberLookup.getNumberLocation(context, number, isExactMatch);
      return location;
    } catch (err) {
      HiLog.e(TAG, 'getNumberLocation, failed: ');
      return '';
    }
  }

  static async getNumberLocationArr(context, arr: Array<string>): Promise<Array<string>> {
    HiLog.i(TAG, 'getNumberLocationArr');
    try {
      let locations = await numberLookup.getNumberLocations(context, arr);
      return locations;
    } catch (err) {
      HiLog.e(TAG, 'getNumberLocationArr, failed: ');
      return [];
    }
  }

  static async setNumberMarkInfo(context, number: string,
    markType: call.MarkType, markContent?: string): Promise<void> {
    HiLog.i(TAG, 'setNumberMarkInfo: ' + ' markType: ' + markType + ' markContent: ' + markContent);
    try {
      await numberLookup.setNumberMarkInfo(context, number, markType, markContent);
    } catch (err) {
      HiLog.e(TAG, 'setNumberMarkInfo, failed: ' + err?.message + ', stack: ' + err?.stack);
    }
  }

  static async getNumberMarkInfo(context, number: string): Promise<call.NumberMarkInfo> {
    HiLog.i(TAG, 'getNumberMarkInfo');
    try {
      let numberMarkInfo = await numberLookup.getNumberMarkInfo(context, number);
      return numberMarkInfo;
    } catch (err) {
      HiLog.e(TAG, 'getNumberMarkInfo, failed: ' + err?.message + ', stack: ' + err?.stack);
      return {
        markType: call.MarkType.MARK_TYPE_NONE
      };
    }
  }
}