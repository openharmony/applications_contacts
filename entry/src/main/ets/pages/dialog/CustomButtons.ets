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
import EnvironmentProp from '../../feature/EnvironmentProp';
import { FontScaleState } from '../../util/fontScaleState';
import { i18n } from '@kit.LocalizationKit';

/**
 * The copy dialog box is displayed at the bottom.
 */
@Component
export default struct CustomButtons {
  @Link confirmButtonEnabled: boolean;
  isErrorConfirmButton: boolean = false;

  cancelButtonText: ResourceStr = '';
  confirmButtonText: ResourceStr = '';
  onCancel: () => void = () => {};
  onConfirm: () => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();

  private isSystemLanguage(lang: string): boolean {
    return i18n.System.getSystemLanguage() === lang;
  }

  private calculateFontSize(): Resource | string {
    if (this.isSystemLanguage('es') || this.isSystemLanguage('ru')) {
      return FontScaleState.isSmallerThirdGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '22vp';
    }
    if (this.isSystemLanguage('fr')) {
      return FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '24vp';
    }
    return FontScaleState.isSmallerSixGeer(this.fontSizeScale) ? $r('sys.float.Body_L') :
    $r('app.float.rounded_corners_width_32');
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Button(this.cancelButtonText)
          .onClick(() => {
            this.onCancel();
          })
          .type(this.isPC ? ButtonType.Normal : undefined)
          .buttonStyle(this.isPC ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL)
          .fontColor($r('app.color.skin_font_emphasize'))
          .fontSize(this.calculateFontSize())
          .fontWeight(FontWeight.Medium)
          .width('50%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level4') : undefined)

        Divider()
          .vertical(true)
          .height(24)
          .width(0.5)
          .color($r('app.color.skin_comp_divider'))
          .opacity($r('sys.float.alpha_secondary'))
          .margin({ left: $r('app.float.id_card_margin_mid'), right: $r('app.float.id_card_margin_mid') })

        Button(this.confirmButtonText)
          .onClick(() => {
            this.onConfirm();
          })
          .type(this.isPC ? ButtonType.Normal : undefined)
          .buttonStyle(this.isPC ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL)
          .fontColor(this.isErrorConfirmButton ? $r('app.color.skin_warning') : $r('app.color.skin_font_emphasize'))
          .fontSize(this.calculateFontSize())
          .fontWeight(FontWeight.Medium)
          .enabled(this.confirmButtonEnabled)
          .width('50%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level4') : undefined)
      }
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
    }
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .width('100%')
    .constraintSize({ minHeight: '56vp' })
  }
}