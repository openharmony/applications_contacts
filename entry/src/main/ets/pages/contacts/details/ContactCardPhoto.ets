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
import LooseObject from '../../../model/type/LooseObject'
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper'
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { image } from '@kit.ImageKit';
import Callback from '@ohos.base';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { DisplaySplitUtil } from '../../../util/DisplaySplitUtil';

// 裁剪框直径
const CROP_CIRCLE_L = 268;
// 裁剪框半径
const CROP_CIRCLE_R = 134;

const TAG = 'contactCardPhoto';

@Component
export default struct ContactCardPhoto {
  @Link mPresenter: LooseObject;
  @Link cardPhotoYPos: number;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  context2: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @LocalStorageLink('isPanelCenter') isPanelCenter?: boolean = false;
  // 裁剪框直径
  @State cropCircleL: number = CROP_CIRCLE_L;
  // 裁剪框半径
  @State cropCircleR: number = CROP_CIRCLE_R;
  // 图片初始坐标y
  @State oriY: number = 0;
  @State photoHeight: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('isMainAbilityForeground') @Watch('doDrawMask2') isMainAbilityForeground: boolean = true;
  @StorageProp('currentColorMode') @Watch('doDrawMask2') currentColorMode: boolean = false;
  private updatePhotoHeight: (photoHeight: number) => void = (photoHeight: number) => {};

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Image(this.mPresenter.cardPhotoPixelMap)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height(`calc(100% - 1vp)`)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        let width = newValue.width as number;
        if (EnvironmentProp.isPC() || (this.curBp === 'lg' && DisplaySplitUtil.isLandScape)) {
          this.photoHeight = width / 4 * 3;
        } else {
          this.photoHeight = width / 3 * 4;
        }
        this.updatePhotoHeight?.(this.photoHeight);
      })

      Canvas(this.context2)
        .id('contactCardPhotoContext2')
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .enabled(false)
        .onReady(() => {
          this.doDrawMask2();
        })
    }
    .height(this.photoHeight)
    .position({ y: this.cardPhotoYPos })
  }

  doDrawMask2() {
    this.context2.globalCompositeOperation = 'source-over';
    let canvasX = this.context2.width;
    let canvasY = this.context2.height;
    this.context2.clearRect(0, 0, canvasX, canvasY);


    this.context2.beginPath();
    this.context2.moveTo(0, 350);
    this.context2.lineTo(0, this.photoHeight);
    this.context2.lineTo(canvasX, this.photoHeight);
    this.context2.lineTo(canvasX, 350);
    this.context2.lineTo(0, 350);

    this.context2.strokeStyle = '#00000000';
    this.context2.stroke();

    let gradient: CanvasGradient = this.context2.createLinearGradient(0, 350, 0, this.photoHeight)


    let endColor = $r('app.color.skin_ohos_id_color_sub_background').id;
    let resourceManager = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().resourceManager
    let endColorNum = resourceManager.getColorSync(endColor)
    let endColorStr = endColorNum.toString(16)
    endColorStr = '#' + endColorStr;
    let startColorStr = this.currentColorMode ? '#00000000' : '#00ffffff';

    gradient.addColorStop(0.0, startColorStr);
    gradient.addColorStop(1.0, endColorStr);


    this.context2.fillStyle = gradient;
    this.context2.closePath();
    this.context2.fill();

    this.context2.beginPath();
    const gradientH = 198;
    this.context2.moveTo(0, 0);
    this.context2.lineTo(0, gradientH);
    this.context2.lineTo(canvasX, gradientH);
    this.context2.lineTo(canvasX, 0);
    this.context2.lineTo(0, 0);

    let gradient2: CanvasGradient = this.context2.createLinearGradient(0, 0, 0, gradientH);
    gradient2.addColorStop(0, '#73000000');
    gradient2.addColorStop(1, '#00000000');
    this.context2.fillStyle = gradient2;
    this.context2.closePath();
    this.context2.fill();
  }
}