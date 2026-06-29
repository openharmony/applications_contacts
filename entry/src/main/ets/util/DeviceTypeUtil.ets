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

export default class DeviceTypeUtil {
  // 平板
  private static TABLET = 'lg';
  // 直板机（普通）
  private static NORMAL_STRAIGHT_BOARD = 'sm';
  // 直板机（小型）
  private static MIN_STRAIGHT_BOARD = 'xs';
  // 大折叠屏（展开）
  private static MAX_FOLD_ABLE_EXPANDED = 'md';

  /**
   *
   * 是否为直板机
   * @param breakpoint
   * @returns boolean
   */
  static isStraightBoard(breakpoint: string) {
    if (DeviceTypeUtil.isFoldable()) {
      return false;
    }
    if ([DeviceTypeUtil.NORMAL_STRAIGHT_BOARD, DeviceTypeUtil.MIN_STRAIGHT_BOARD].includes(breakpoint)) {
      return true;
    }
    return false;
  }

  /**
   *
   * 是否为平板
   * @param breakpoint
   * @returns boolean
   */
  static isTablet(breakpoint: string) {
    if (breakpoint === DeviceTypeUtil.TABLET) {
      return true;
    }
    return false;
  }

  /**
   *
   * 是否为折叠屏
   * @returns boolean
   */
  static isFoldable() {
    return display.isFoldable();
  }

  /**
   *
   * 是否为小折叠屏
   * @param breakpoint
   * @returns boolean
   */
  static isMinFoldAble(breakpoint: string) {
    if (!DeviceTypeUtil.isFoldable()) {
      return false;
    }
    if ([DeviceTypeUtil.NORMAL_STRAIGHT_BOARD, DeviceTypeUtil.MIN_STRAIGHT_BOARD].includes(breakpoint)) {
      return true;
    }
    return false;
  }

  /**
   *
   * 是否为大折叠屏展开态
   * @param breakpoint
   * @returns boolean
   */
  static isMaxFoldAbleExpanded(breakpoint: string) {
    if (!DeviceTypeUtil.isFoldable()) {
      return false;
    }
    return breakpoint === DeviceTypeUtil.MAX_FOLD_ABLE_EXPANDED;
  }
}