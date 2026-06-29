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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

const TAG: string = 'FontScaleState';

export class FontScaleState {
  public static currentGear: number = 0;
  public static topAndBottomMarginOnScale = $r('app.float.id_card_margin_xxl');
  public static fontScale: number = 0;
  public static fontSizeScaleCard = 0
  /**
   * 更新字体档数
   */
  public static updateAppFontGearSize(scale?: number): void {
    FontScaleState.fontScale = scale ?? 1;
    switch (scale) {
      case 1: {
        FontScaleState.currentGear = 0;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_10');
        break;
      }
      case 1.15: {
        FontScaleState.currentGear = 1;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_10');
        break;
      }
      case 1.3: {
        FontScaleState.currentGear = 2;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_10');
        break;
      }
      case 1.45: {
        FontScaleState.currentGear = 3;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_10');
        break;
      }
      case 1.75: {
        FontScaleState.currentGear = 4;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_xxl');
        break;
      }
      case 2: {
        FontScaleState.currentGear = 5;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_image_s');
        break;
      }
      case 2.25: {
        FontScaleState.currentGear = 6;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_max');
        break;
      }
      case 3.2: {
        FontScaleState.currentGear = 6;
        FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_max');
        break;
      }
      default: {
        FontScaleState.currentGear = 0;
        break;
      }
    }
    //无障碍字体档数
    HiLog.i(TAG, `updateAppFontGearSize===>${scale}/${FontScaleState.currentGear}`);
    FontScaleState.fontSizeScaleCard = FontScaleState.currentGear
    AppStorage.setOrCreate('fontSizeScale', FontScaleState.currentGear)
    AppStorage.setOrCreate('fontScale', FontScaleState.fontScale)
  }

  /**
   * 当前字体档数是否为标准档位
   */
  public static isStandardGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 1) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否小于大二挡
   */
  public static isSmallerTwoGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 2) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否小于大三挡
   */
  public static isSmallerThirdGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 3) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否大于大三挡
   */
  public static isBigerThirdGeer(fontSizeScale: number): boolean {
    if (fontSizeScale > 3) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否小于大四挡
   */
  public static isSmallerFourGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 4) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否小于大五挡
   */
  public static isSmallerFiveGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 5) {
      return true
    } else {
      return false
    }
  }

  /**
   * 当前字体档数是否小于大六挡
   */
  public static isSmallerSixGeer(fontSizeScale: number): boolean {
    if (fontSizeScale < 6) {
      return true
    } else {
      return false
    }
  }

  /**
   * 获取关怀模式下上下间距
   */
  public static fetchSeniorTopAndBottomSpace(fontSizeScale: number,
                                             normalSpace: string | number | Resource,
                                             seniorSpace: string | number | Resource): string | number | Resource {
    if (FontScaleState.isStandardGeer(fontSizeScale)) {
      return normalSpace;
    } else if (FontScaleState.isSmallerFourGeer(fontSizeScale)) {
      //代码中很多标准档位都是靠高度撑起来的，大3档及以下档位要使用UX上上下间距
      return seniorSpace;
    } else {
      return FontScaleState.topAndBottomMarginOnScale;
    }
  }

  /**
   * 获取关怀模式列表间距
   */
  public static fetchSeniorListSpace(): number | Resource {
    let currentGear: number = AppStorage.get<number>('fontSizeScale') ?? 0;
    let padding: number | Resource = 0;
    switch (currentGear) {
      case 4: {
        padding = $r('app.float.id_dialog_button_bottom_margin');
        break;
      }
      case 5: {
        padding = $r('app.float.id_card_image_s');
        break;
      }
      case 6: {
        padding = $r('app.float.id_card_margin_max');
        break;
      }
      default: {
        padding = 0;
        break;
      }
    }
    return padding;
  }
}