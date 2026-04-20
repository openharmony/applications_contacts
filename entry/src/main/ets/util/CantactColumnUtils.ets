/**
 * Copyright (c) 2022-2024 Huawei Device Co., Ltd.
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

import display from '@ohos.display';
import window from '@ohos.window';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
const TAG = 'CantactColumnUtils';

/**
 * @file: Tools
 */

export default class CantactColumnUtils {
  private static sCallColumnUtils: CantactColumnUtils;

  public static getInstance(): CantactColumnUtils {
    if (CantactColumnUtils.sCallColumnUtils == null) {
      CantactColumnUtils.sCallColumnUtils = new CantactColumnUtils();
    }
    return CantactColumnUtils.sCallColumnUtils;
  }

  public static getTestInstance(): CantactColumnUtils {
    return new CantactColumnUtils();
  }

  public getWindowProperties(windowObj?: window.Window): number | undefined {
    return windowObj?.getWindowProperties().displayId;
  }

  /**
   * Update breakpoint based on the current window size
   *
   * @param { number } windowWidth
   */
  public updateBreakpoint(windowWidth: number, windowObj?: window.Window) {
      try {
        let displayId = this.getWindowProperties(windowObj);
        let dpi = display.getDisplayByIdSync(displayId).densityDPI;
        let windowWidthVp = (windowWidth * 160) / dpi;
        HiLog.w(TAG,
          `windowWidthPX: ${windowWidth}, windowWidthVp: ${windowWidthVp}, dpi:${dpi}, displayId:${displayId}`);
        let curBpCard: string = 'lg';
        if (windowWidthVp < 320) {
          curBpCard = 'xs';
        } else if (windowWidthVp < 520) {
          curBpCard = 'sm';
        } else if (windowWidthVp < 840) {
          curBpCard = 'md';
        } else {
          curBpCard = 'lg';
        }
        HiLog.w(TAG, `curBpCard: ${curBpCard}`);
        AppStorage.setOrCreate('curBpCard', curBpCard);
      } catch (err) {
        HiLog.e(TAG, 'getDisplayByIdSync failed err' + err.code)
      }
  }

  /**
   * Obtain the gridCount of dialogs
   *
   * @param { string } curBp
   * @param { number } ratio
   * @return { number } gridCount
   */
  public getDialogGridCount(curBp: string, ratio: number) {
    if (curBp && ratio) {
      if (curBp === 'sm') {
        return ratio > (9 / 16) ? 3 : 4;
      } else if (curBp === 'md') {
        return ratio > (3 / 4) ? 4 : 5;
      } else if (curBp === 'lg') {
        return ratio > (4 / 3) ? 5 : 6;
      }
    }
    return 4;
  }

  /**
   * Obtain the alignment of dialogs
   *
   * @param { string } curBp
   * @return { DialogAlignment } alignment
   */
  public getDialogAlignment(curBp: string) {
    return curBp === 'sm' ? DialogAlignment.Default : DialogAlignment.Center;
  }
  
  /**
   * return padding space
   *
   * @param { string } curBp
   * @return { Resource } resource
   */
  public getPaddingSpace(curBp: string): Resource {
    HiLog.w(TAG, `getPaddingSpace is curBp: ${curBp}`)
    if (curBp === 'xs' || curBp === 'sm') {
      return $r('sys.float.padding_level8');
    }
    if (curBp === 'md') {
      return $r('sys.float.padding_level12');
    }
    return $r('sys.float.padding_level16');
  }
}