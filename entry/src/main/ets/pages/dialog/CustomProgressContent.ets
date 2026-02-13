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
import { numFormat } from '../../util/NumFormat';

/**
 * The copy dialog box is displayed at the bottom.
 */
@Component
export default struct CustomProgressContent {
  @Link percent: number;
  @Prop isShowProgressInfo: boolean = true;
  progressText: ResourceStr = '';

  filledButtonShow: boolean = false;
  filledButtonAction: () => void = () => {};

  build() {
    Row() {
      Column() {
        if (this.isShowProgressInfo){
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.End }) {
            Text(this.progressText)
              .fontSize($r('sys.float.Subtitle_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_font_primary'))

            Text(`${numFormat(this.percent)}%`)
              .fontSize($r('sys.float.Subtitle_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_font_secondary'))
          }
          .height(19)
        }
        Row() {
          Progress({ value: this.percent, total: 100, type: ProgressType.Linear })
            .color($r('app.color.skin_comp_background_emphasize'))
            .width('100%')
            .height($r('app.float.id_card_image_small'))
        }
      }
      .justifyContent(FlexAlign.End)
      .flexShrink(1)
      .height(this.isShowProgressInfo ? $r('app.float.id_item_height_large') : $r('app.float.id_card_image_small'))
      .width('100%')

      if (this.filledButtonShow) {
        Column() {
          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_fourth')])
            .onClick(() => {
              this.filledButtonAction();
            })
        }
        .flexShrink(0)
        .margin({ left: $r('app.float.id_card_margin_xl') })
        .height(this.isShowProgressInfo ? $r('app.float.id_item_height_large') : $r('app.float.id_card_image_small'))
        .justifyContent(FlexAlign.End)
      }
    }
    .height(this.isShowProgressInfo ? $r('app.float.id_item_height_large') : $r('app.float.id_card_image_small'))
    .width('100%')
  }
}