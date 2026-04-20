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
// @ts-ignore
import type common from '@ohos.app.ability.common';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoadSoUtil } from '../../../../../common/src/main/ets/util/DynamicLoadSoUtil';
import type dataSharePredicates from '@ohos.data.dataSharePredicates';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';

const TAG = 'VCardUtil';
const FLAG_STR = 'END:VCARD';
const FLAG_LENGTH = FLAG_STR.length;
const BUFFER_SIZE = 4096;
const TRANS_PATTERNS = [
  ['X-GOOGLE-TALK', 'X-HUANLIAO'],
  ['X-ANDROID-CUSTOM', 'X-OHOS-CUSTOM'],
  ['vnd.ohos.cursor.item/relation', 'RELATION'],
  ['vnd.ohos.cursor.item/contact_event', 'CONTACT_EVENT']
];


export default class VCardUtil {
  public static resultDT: string = '';
  static async importVCard(context: common.UIAbilityContext, filePath: string, accountId: number, callback: Function): Promise<void> {
    HiLog.w(TAG, 'importVCard start');
    try {
      let vcard = await DynamicLoadSoUtil.getInstance().loadVcard();
      vcard?.default?.importVCard(context, filePath, accountId).then(data => {
        HiLog.w(TAG, 'importVCard success');
        callback(true);
      }).catch(error => {
        HiLog.e(TAG, `importVCard err ${error?.message}, stack: ${error?.stack}`);
        callback(false);
      });
    } catch (error) {
      HiLog.e(TAG, `importVCard err ${error?.message}, stack: ${error?.stack}`);
      callback(false);
    }
  }

  static async exportVCard(context: common.UIAbilityContext, predicates: dataSharePredicates.DataSharePredicates, callback: Function): Promise<void> {
    HiLog.w(TAG, 'exportVCard start');
    try {
      let vcard = await DynamicLoadSoUtil.getInstance().loadVcard();
      vcard?.default?.exportVCard(context, predicates).then(data => {
        HiLog.w(TAG, 'exportVCard success');
        callback(true);
      }).catch(error => {
        HiLog.e(TAG, 'exportVCard err');
        callback(false);
      });
    } catch (error) {
      HiLog.e(TAG, 'exportVCard err!');
      callback(false);
    }
  }

  public static transPatterns(src: string, transFlag: number): string {
    let tmpStr = src;
    for (const patterns of TRANS_PATTERNS) {
      if (tmpStr.includes(patterns[transFlag])) {
        tmpStr = tmpStr.replace(patterns[transFlag], patterns[transFlag ^ 1]);
      }
    }
    return tmpStr;
  }

  static getContactCntFromVcard(filePath: string): number {
    let cnt = 0;
    let f: fs.File = null;
    try {
      f = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      let buffer = new ArrayBuffer(BUFFER_SIZE);
      let offset = 0;
      let lastStr: string = '';
      while (fs.readSync(f.fd, buffer, {
        'offset': offset
      })) {
        offset += BUFFER_SIZE;
        const decoder = util.TextDecoder.create('utf-8', {
          ignoreBOM: true
        });
        let currentStr = decoder.decodeWithStream(new Uint8Array(buffer));
        const lastStrTail = lastStr.substring(lastStr.length - FLAG_LENGTH + 1);
        const currentStrHead = currentStr.substring(0, FLAG_LENGTH - 1);
        const midStr = lastStrTail + currentStrHead;
        cnt += currentStr.split(FLAG_STR).length - 1 + midStr.split(FLAG_STR).length - 1;
        lastStr = currentStr;
      }
      HiLog.i(TAG, 'getContactCntFromFile cnt:' + cnt);
    } catch (error) {
      HiLog.e(TAG, 'getContactCntFromVcard err');
    } finally {
      fs.closeSync(f);
    }
    return cnt;
  }
}