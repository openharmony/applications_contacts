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

/**
 * The copy dialog box is displayed at the bottom.
 */
@Component
export default struct CustomProgressContent {
  @Link percent: number;
  progressText: ResourceStr = '';

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.progressText)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_primary'))

        Text(`${this.percent}%`)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_secondary'))
      }
      .margin({ bottom: $r('app.float.id_card_margin_mid') })
      .constraintSize({ minHeight: $r('app.float.id_card_image_s') })

      Row() {
        Progress({
          value: this.percent,
          total: 100,
          type: ProgressType.Linear
        })
          .backgroundColor($r('app.color.skin_ohos_id_color_component_normal'))
          .style({ enableSmoothEffect: true })
          .color($r('app.color.skin_comp_background_emphasize'))
          .width('100%')
          .height($r('app.float.id_card_image_small'))
      }
    }
    .justifyContent(FlexAlign.End)
    .flexShrink(1)
    .constraintSize({ minHeight: $r('app.float.id_height_48') })
    .width('100%')
  }
}