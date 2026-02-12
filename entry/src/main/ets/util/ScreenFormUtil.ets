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
import { HiLog, StringUtil } from '../../../../../feature/call/oh_modules/common'
import { display } from '@kit.ArkUI';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

const TAG = 'ScreenFormUtil';

export enum FoldedAndContinuedType {
  NULL = -1,

  ACCOUNTANT = 0,
}

export default class ScreenFormUtil {

  static isNewFormSmallFoldScreen(): boolean {
    let foldTypeConfiguration = '';
    try {
      foldTypeConfiguration = systemParameterEnhance.getSync('const.window.foldscreen.type', '');
      HiLog.w(TAG, `get foldTypeConfiguration:${foldTypeConfiguration}`);
    } catch (err) {
      HiLog.e(TAG, `get foldTypeConfiguration err:${err?.code}`);
    }
    const foldType = foldTypeConfiguration.split(',')[0];
    return foldType === '4';
  }

  static getFoldStatus(): display.FoldStatus {
    return display.getFoldStatus();
  }

  // 创建折叠屏形态变更监听
  static addFoldStatusRegister() {
    HiLog.w(TAG, 'addFoldStatusRegister');
    try {
      let foldStatus = ScreenFormUtil.getFoldStatus();
      HiLog.w(TAG, 'getFoldStatus foldStatus = ' + foldStatus);
      if (ScreenFormUtil.isNewFormSmallFoldScreen()) {
        // 新形态 小折叠
        AppStorage.setOrCreate<boolean>('isVerdeModel', true);
      } else {
        AppStorage.setOrCreate<boolean>('isVerdeModel', false);
      }

      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        HiLog.w(TAG, 'foldStatusChange foldStatus = ' + foldStatus);
        if (ScreenFormUtil.isNewFormSmallFoldScreen()) {
          // 新形态 小折叠
          AppStorage.setOrCreate<boolean>('isVerdeModel', true);
        } else {
          AppStorage.setOrCreate<boolean>('isVerdeModel', false);
        }
      })
    } catch (err) {
      HiLog.e(TAG, `foldStatusChange err: ${err?.message}`);
    }
  }
}