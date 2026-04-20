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

import { BusinessError } from '@ohos.base';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG: string = 'RingtoneSelectionUtil';

export const DEFAULT_RING_TONE: string = 'default_ring_tone';

export const SYSTEM_DEFAULT_ALARM_TONE: string = 'system_default_alarm_tone'

type ToneAttrsArray = systemSoundManager.ToneAttrsArray;

type ToneAttrs = systemSoundManager.ToneAttrs;

export interface RingtoneItem {
  id: number,
  name: string,
  path: string
}

export class RingtoneSelectionUtil {

  /**
   * 查询所有系统来电铃声列表
   *
   * @param isForce 是否强制查询列表
   * @returns 系统来电铃声列表
   */
  public static async getRingToneAttrList(isForce?: boolean): Promise<ToneAttrsArray | undefined> {
    HiLog.i(TAG, `getRingToneAttrList isForce:${isForce}`);
    let toneAttrList: ToneAttrsArray | undefined;
    if (isForce === undefined || !isForce) {
      toneAttrList = AppStorage.get<ToneAttrsArray>('ring_tone_attr_list');
      if (toneAttrList && toneAttrList.length > 0) {
        return toneAttrList;
      }
    }
    let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context;
    toneAttrList = await systemSoundManager.getSystemSoundManager()
      .getRingtoneAttrList(context, systemSoundManager.RingtoneType.RINGTONE_TYPE_DEFAULT);
    AppStorage.setOrCreate('ring_tone_attr_list', toneAttrList);
    return toneAttrList;
  }

  /**
   * 从铃声列表中通过uri查询铃声
   *
   * @param ringUri 铃声路径
   * @param isForce 是否强制查询整个铃声列表
   * @returns 铃声
   */
  public static async findRingtoneFromList(ringUri: string | undefined,
    isForce?: boolean): Promise<RingtoneItem | undefined> {
    try {
      HiLog.i(TAG, `findRingtoneFromList ringUri:${ringUri}`);
      if (ringUri === undefined) {
        return undefined;
      }
      let toneAttrList: ToneAttrsArray | undefined = await RingtoneSelectionUtil.getRingToneAttrList(isForce);
      return RingtoneSelectionUtil.findRingtone(toneAttrList, ringUri);
    } catch (error) {
      HiLog.e(TAG,
        `findRingtoneFromList error: ${(error as BusinessError).message} ${(error as BusinessError).code}`);
    }
    return undefined;
  }

  private static findRingtone(toneAttrList: ToneAttrsArray | undefined,
    ringUri: string | undefined): RingtoneItem | undefined {
    if (toneAttrList === undefined || toneAttrList === null || ringUri === undefined) {
      HiLog.e(TAG, `findRingtone toneAttrList is undefined`)
      return undefined;
    }
    let ringtone: ToneAttrs | undefined = toneAttrList.find((item: ToneAttrs) => item.getUri() === ringUri);
    if (ringtone) {
      let ringPath: string = ringtone.getUri();
      let ringName: string = ringtone.getCustomizedType() === systemSoundManager.ToneCustomizedType.PRE_INSTALLED ?
      ringtone.getTitle().replace('_', ' ') : ringtone.getTitle();
      HiLog.i(TAG, `findRingtone.`);
      return {
        id: 0,
        path: ringPath,
        name: ringName
      } as RingtoneItem;
    }
    HiLog.w(TAG, `findRingtone not found`);
    return undefined;
  }
}