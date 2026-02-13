/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import curves from '@ohos.curves';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct ArrowBack {
  public onBackButtonClick = () => {};
  public isTransition: boolean = true;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  build() {
    Stack() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.id_card_margin_max'))
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      }
      .onClick(() => {
        this.onBackButtonClick()
      })
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_back')))
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      .draggable(false)
      .transition(this.isTransition ? TransitionEffect.asymmetric(
        TransitionEffect.OPACITY.animation({
          duration: 200, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), delay: 150
        }),
        TransitionEffect.OPACITY.animation({
          duration: 200, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
        })
      ) : null)
      .id('contactList_contacts_back_arrowBack')
      .margin({ start: EnvironmentProp.isPC() ? LengthMetrics.resource($r('sys.float.padding_level12')) :
      LengthMetrics.resource($r('app.float.id_card_margin_xxl')) })
    }
  }
}