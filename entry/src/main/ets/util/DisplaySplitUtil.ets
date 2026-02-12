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

import { display } from '@kit.ArkUI';
import { HiLog } from '../../../../../common';
import deviceInfo from '@ohos.deviceInfo';
import hiTraceMeter from '@ohos.hiTraceMeter';

const TAG: string = 'DisplaySplitUtil';

export enum SplitStatus {
  VERTICAL_SPLIT = 1, //左右分屏
  ONE_THREE_SPLIT = 2, //上下三分之一分屏
  HALF_SPLIT = 3, //上下二分之一分屏
  TWO_THREE_SPLIT = 4, //上下三分之二分屏
  DEFAULT = 5 //无分屏
}

export class DisplaySplitUtil {

  static getDefaultDisplaySync(): display.Display {
    return display.getDefaultDisplaySync();
  }

  /**
   * 窗口大小变化时，更新分屏状态
   * @param winWidth
   * @param winHeight
   */
  public static updateSplitStatus(winWidth: number, winHeight: number): void {
    try {
      const deviceDisplayInfo: display.Display = DisplaySplitUtil.getDefaultDisplaySync();
      if (winHeight === deviceDisplayInfo.height) {
        if (winWidth < deviceDisplayInfo.width) {
          AppStorage.setOrCreate('splitStatus', SplitStatus.VERTICAL_SPLIT);
        } else {
          AppStorage.setOrCreate('splitStatus', SplitStatus.DEFAULT);
        }
      } else if (winWidth === deviceDisplayInfo.width) {
        if (winHeight <= deviceDisplayInfo.height / 3) {
          AppStorage.setOrCreate('splitStatus', SplitStatus.ONE_THREE_SPLIT);
        } else if (winHeight <= deviceDisplayInfo.height / 2) {
          AppStorage.setOrCreate('splitStatus', SplitStatus.HALF_SPLIT);
        } else if (winHeight <= deviceDisplayInfo.height * 2 / 3) {
          AppStorage.setOrCreate('splitStatus', SplitStatus.TWO_THREE_SPLIT);
        } else {
          AppStorage.setOrCreate('splitStatus', SplitStatus.DEFAULT);
        }
      } else {
        AppStorage.setOrCreate('splitStatus', SplitStatus.DEFAULT);
      }
    } catch (e) {
      HiLog.e(TAG, `update Split status err:${e}`);
    }
  }

  public static deviceType(): string {
    return deviceInfo.deviceType;
  }

  /**
   * 是否需要固定标题栏
   * @param splitStatus
   * @returns
   */
  public static isFixedTitleBar(splitStatus: SplitStatus): boolean {
    const deviceType: string = DisplaySplitUtil.deviceType();
    if (deviceType !== 'tablet' && (splitStatus === SplitStatus.ONE_THREE_SPLIT ||
      splitStatus === SplitStatus.HALF_SPLIT)) {
      return true;
    }
    if (deviceType === 'tablet' && splitStatus === SplitStatus.ONE_THREE_SPLIT) {
      return true;
    }
    return false;
  }

  /**
   * 判断上下分屏
   * @returns
   */
  public static isHorizonSplit(splitStatus?: SplitStatus): boolean {
    const curStatus: SplitStatus = splitStatus ?? AppStorage.get('splitStatus') as SplitStatus;
    if (curStatus) {
      return curStatus !== SplitStatus.DEFAULT && curStatus !== SplitStatus.VERTICAL_SPLIT;
    }
    return false;
  }

  /**
   * 判断左右分屏
   * @returns
   */
  public static isVerticalSplit(splitStatus?: SplitStatus): boolean {
    const curStatus: SplitStatus = splitStatus ?? AppStorage.get('splitStatus') as SplitStatus;
    if (curStatus) {
      return curStatus === SplitStatus.VERTICAL_SPLIT;
    }
    return false;
  }

  /**
   * 是否横屏
   */
  public static isLandScape(): boolean {
    let isLandScape: boolean = false;
    try {
      const deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();
      isLandScape = deviceDisplayInfo.orientation === display.Orientation.LANDSCAPE ||
        deviceDisplayInfo.orientation === display.Orientation.LANDSCAPE_INVERTED;
    } catch (e) {
      HiLog.e(TAG, `getDefaultDisplaySync err:${e}`);
    }
    return isLandScape;
  }

  /**
   * 是否显示索引条
   * @returns
   */
  public static isShowIndex(splitStatus: SplitStatus): boolean {
    //全屏
    if (splitStatus === SplitStatus.DEFAULT) {
      return true;
    }
    //折叠屏展开态左右分屏
    if (DisplaySplitUtil.isFoldStatus() && splitStatus === SplitStatus.VERTICAL_SPLIT) {
      return true;
    }
    //直板机2/3
    if ((DisplaySplitUtil.deviceType() == 'phone' || !DisplaySplitUtil.isFoldStatus()) &&
      splitStatus === SplitStatus.TWO_THREE_SPLIT) {
      return true;
    }
    // 平板除了1/3剩下都显示
    if (DisplaySplitUtil.deviceType() == 'tablet' && splitStatus !== SplitStatus.ONE_THREE_SPLIT) {
      return true;
    }
    return false;
  }

  /**
   * 判断折叠屏是否为展开态:
   *  完全展开和半展开都判定为展开态,包含三折叠设备状态
   */
  public static isFoldStatus(): boolean {
    return display.isFoldable() && (display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_UNKNOWN &&
      display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_FOLDED);
  }

  /**
   * 判断是否为直板机状态
   * @returns
   */
  public static isSmStatus(): boolean {
    return (deviceInfo.deviceType === 'phone' && !display.isFoldable()) ||
      (display.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED);
  }

  /**
   * 折叠屏展开态且左右分屏
   * @returns
   */
  public static isMdLeft(splitStatus: SplitStatus) {
    return DisplaySplitUtil.isFoldStatus() && splitStatus === SplitStatus.VERTICAL_SPLIT;
  }

  static getFoldStatus(): display.FoldStatus {
    try {
      return display.getFoldStatus();
    } catch (err) {
      HiLog.e(TAG, 'getFoldStatus err:' + err?.message + ', stack: ' + err?.stack);
      return display.FoldStatus.FOLD_STATUS_UNKNOWN;
    }
  }

  /**
   * 直板机左右分屏或折叠屏折叠态左右分屏
   * @returns
   */
  public static isSmLeft(splitStatus: SplitStatus) {
    if (DisplaySplitUtil.isFoldStatus()) {
      return false
    }
    if (DisplaySplitUtil.isSmStatus() && splitStatus === SplitStatus.VERTICAL_SPLIT) {
      return true;
    }
    return false;
  }

  /**
   * 直板机1/3或折叠屏折叠态1/3
   */
  public static isSmOneThreeSplit(splitStatus: SplitStatus) {
    if (DisplaySplitUtil.isFoldStatus()) {
      return false
    }
    if (DisplaySplitUtil.isSmStatus() && splitStatus === SplitStatus.ONE_THREE_SPLIT) {
      return true;
    }
    return false;
  }
}
