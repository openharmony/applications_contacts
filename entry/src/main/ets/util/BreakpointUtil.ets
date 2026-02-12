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
import { display, window } from '@kit.ArkUI';
import { HiLog } from '../../../../../feature/call/oh_modules/common'

const TAG: string = 'BreakpointUtil';


export class BreakpointUtil {
  public static getWidthBreakpoint(windowRect: window.Rect | window.Size | display.Display,
    displayId?: number): string {
    HiLog.w(TAG, `getWidthBreakpoint start, displayId: ${displayId}`);
    let dpi: number = display.getDefaultDisplaySync().densityPixels;
    if (displayId !== undefined) {
      dpi = display.getDisplayByIdSync(displayId).densityPixels;
    }
    let windowWidthVp: number = windowRect.width / dpi;
    HiLog.w(TAG, `getWidthBreakpoint windowWidthVp: ${windowWidthVp}, dpi: ${dpi}`);
    let widthBp: string = '';
    if (windowWidthVp < 320) {
      widthBp = 'sm'; // 目前 xs 未适配 先改为 sm
    } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
      widthBp = 'sm';
    } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
      widthBp = 'md';
    } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
      widthBp = 'lg';
    } else {
      widthBp = 'lg'; // 目前 xl 未适配 先改为 lg
    }
    HiLog.w(TAG, `getWidthBreakpoint end, widthBp: ${widthBp}`);
    return widthBp;
  }

  public static getHeightBreakpoint(windowRect: window.Rect | window.Size | display.Display,
    displayId?: number): string {
    HiLog.w(TAG, `getHeightBreakpoint start, displayId: ${displayId}`);
    let dpi: number = display.getDefaultDisplaySync().densityPixels;
    if (displayId) {
      dpi = display.getDisplayByIdSync(displayId).densityPixels;
    }
    let windowWidthVp: number = windowRect.width / dpi;
    let windowHeightVp: number = windowRect.height / dpi;
    HiLog.w(TAG, `getHeightBreakpoint windowWidthVp: ${windowWidthVp}, windowHeightVp: ${windowHeightVp}, dpi: ${dpi}`);
    let heightBp: string = '';
    let aspectRatio: number = windowHeightVp / windowWidthVp;
    if (aspectRatio < 0.8) {
      heightBp = 'sm';
    } else if (aspectRatio >= 0.8 && aspectRatio < 1.2) {
      heightBp = 'md';
    } else {
      heightBp = 'lg';
    }
    HiLog.w(TAG, `getHeightBreakpoint end, heightBp: ${heightBp}`);
    return heightBp;
  }

  public static judgingVerdeBreakpoint(windowRect: window.Rect | window.Size | display.Display, displayId?: number) {
    let isVerdeModel = AppStorage.get<boolean>('isVerdeModel');
    let widthBp = BreakpointUtil.getWidthBreakpoint(windowRect, displayId);
    let heightBp = BreakpointUtil.getHeightBreakpoint(windowRect, displayId);
    HiLog.w(TAG, `judgingVerdeBreakpoint start, isVModel: ${isVerdeModel}, widthBp: ${widthBp}, heightBp: ${heightBp}`);
    if (widthBp === 'sm' && heightBp === 'md' && isVerdeModel) {
      AppStorage.setOrCreate<boolean>('isVerde', true);
    } else {
      AppStorage.setOrCreate<boolean>('isVerde', false);
    }
    HiLog.w(TAG, `judgingVerdeBreakpoint end, isV: ${AppStorage.get<boolean>('isVerde')}`);
  }
}