/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { DialButton } from './DialButton';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';

const noCareModeMaxFOnt: number = 1.45;

@Component
export struct DialPad {
  @StorageProp('windowHeightPx') windowHeightPx: number = 0;
  dis: display.Display = display.getDefaultDisplaySync();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageLink('isMaximumZoom') isMaximumZoom: boolean = false;
  @StorageLink('settingFontScale') settingFontScale: string = '0';

  private getDialPadHeight(): number {
    let dialHeight: number = 0;
    if (DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = px2vp(this.windowHeightPx) - 228;
    } else if (DisplaySplitUtil.isMdLeft(this.splitStatus)) {
      dialHeight = 240;
    } else if (this.splitStatus === SplitStatus.HALF_SPLIT) {
      dialHeight = px2vp(this.windowHeightPx) - 228;
    } else if (this.splitStatus === SplitStatus.ONE_THREE_SPLIT && !DisplaySplitUtil.isFoldStatus()) {
      dialHeight = 128
    } else if (this.splitStatus === SplitStatus.ONE_THREE_SPLIT &&
      (deviceInfo.deviceType === 'phone' && !display.isFoldable())) {
      dialHeight = 128
    } else {
      dialHeight = 240;
    }
    return dialHeight;
  }

  build() {
    Column() {
      Row() {
        DialButton({ buttonNumber: '1' })

        DialButton({ buttonNumber: '2' })

        DialButton({ buttonNumber: '3' })
      }.width('100%')
      .layoutWeight(1)
      .direction(Direction.Ltr)

      Row() {
        DialButton({ buttonNumber: '4' })

        DialButton({ buttonNumber: '5' })

        DialButton({ buttonNumber: '6' })
      }.width('100%')
      .layoutWeight(1)
      .direction(Direction.Ltr)

      Row() {
        DialButton({ buttonNumber: '7' })

        DialButton({ buttonNumber: '8' })

        DialButton({ buttonNumber: '9' })
      }.width('100%')
      .layoutWeight(1)
      .direction(Direction.Ltr)

      Row() {
        DialButton({ buttonNumber: '*' })

        DialButton({ buttonNumber: '0' })

        DialButton({ buttonNumber: '#' })
      }.width('100%')
      .layoutWeight(1)
      .direction(Direction.Ltr)
      .constraintSize({ maxHeight: this.isInVisionGlass ? '96vp' : Infinity })
    }
    .height(this.isMaximumZoom || (Number(this.settingFontScale) === noCareModeMaxFOnt) ? undefined :
    this.getDialPadHeight())
    .margin({
      right: this.isInVisionGlass || (Number(this.settingFontScale) === noCareModeMaxFOnt) ? '0vp' :
      $r('sys.float.padding_level8'),
      left: this.isInVisionGlass || (Number(this.settingFontScale) === noCareModeMaxFOnt) ? '0vp' :
      $r('sys.float.padding_level8'),
      top: this.isInVisionGlass || (Number(this.settingFontScale) === noCareModeMaxFOnt) ? '0vp' :
        (this.splitStatus === SplitStatus.HALF_SPLIT) || (DisplaySplitUtil.isSmLeft(this.splitStatus)) ? 8 :
        $r('sys.float.padding_level7')
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}
