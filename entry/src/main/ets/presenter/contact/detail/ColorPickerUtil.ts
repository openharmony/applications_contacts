/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { effectKit } from '@kit.ArkGraphics2D';
import { image } from '@kit.ImageKit';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'ColorPickerUtil';

export async function checkIsLightColor(cardPhotoPixelMap: image.PixelMap | undefined,
  targetArea?: number[]): Promise<boolean> {
  try {
    let colorPicker = targetArea ? await effectKit.createColorPicker(cardPhotoPixelMap, targetArea) :
      await effectKit.createColorPicker(cardPhotoPixelMap);
    // @ts-ignore
    let degree = colorPicker.discriminatePitureLightDegree();
    HiLog.i(TAG, `degree ${degree}`);
    // degree 0-2 为浅色，3-6为深色
    return degree <= 2;
  } catch (e) {
    HiLog.i(TAG, `color picker error ${e?.code}, ${e?.message}.`)
    return false;
  }
}