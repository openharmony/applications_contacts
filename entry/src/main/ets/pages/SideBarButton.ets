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
import { curves, LengthMetrics } from '@kit.ArkUI';
import { HiLog } from '../../../../../common';


const TAG = 'SideBarButton';

@Component
export default struct SideBarButton {
  @State isShowOpenMousePopup: boolean = false; // PC上手型tips是否展示
  @StorageLink('showSideBar') showSideBar: boolean = true;

  // PC上tips组件
  @Builder
  MousePopupBuilder(resource: ResourceStr) {
    Row() {
      Text(resource)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .padding({
          start: LengthMetrics.resource($r('app.float.id_width_8')),
          end: LengthMetrics.resource($r('app.float.id_width_8')),
          top: $r('app.float.id_width_8'),
          bottom: $r('app.float.id_width_8')
        })
    }
    .constraintSize({ minHeight: '36vp' })
  }

  build() {
    Button({ type: ButtonType.Normal }) {
      SymbolGlyph(this.showSideBar ? $r('sys.symbol.open_sidebar') : $r('sys.symbol.close_sidebar'))
        .fontSize('24vp')
        .fontColor([$r('sys.color.icon_primary')])
        .draggable(false)
    }
    .key('PC_sideBar_control_close_button')
    .width('40vp')
    .height('40vp')
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor(Color.Transparent)
    .focusBox({ margin: LengthMetrics.vp(-2), strokeWidth: LengthMetrics.vp(2) })
    .bindPopup(this.isShowOpenMousePopup, {
      builder: this.MousePopupBuilder($r('app.string.accessibility_open')),
      targetSpace: $r('app.float.id_width_8'),
      radius: $r('sys.float.corner_radius_level4'),
      placement: Placement.BottomLeft,
      mask: false,
      enableArrow: false
    })
    .onClick(() => {
      try {
        animateTo({
          curve: curves.interpolatingSpring(0, 1, 300, 35)
        }, () => {
          this.showSideBar = !this.showSideBar;
        });
        this.isShowOpenMousePopup = false;
      } catch (e) {
        HiLog.e(TAG, `click showPcButton err, message: ${e?.message}`);
      }
    })
  }
}