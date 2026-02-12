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
@Component
export default struct ButtonItem {
  mImage: Resource | null = null;
  labelName: Resource | string = '';
  widthPercent?: Resource | string;
  ifEnabled: boolean = true
  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }
  build() {
    Column() {
      Image(this.mImage)
        .objectFit(ImageFit.Contain)
        .height($r('app.float.id_card_image_small'))
        .width($r('app.float.id_card_image_small'))
        .margin({ bottom: $r('app.float.id_card_margin_sm') })
        .draggable(false)
        .fillColor($r('app.color.skin_icon_primary'))
      Text(this.labelName)
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor('ohos_id_color_text_primary')
    }
    .stateStyles({
      pressed: {
      .backgroundColor($r('app.color.skin_interactive_click'))
      .borderRadius($r('sys.float.corner_radius_level7'))
    },
      normal: {
        .backgroundColor($r('app.color.skin_background_primary'))
      }
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.skin_background_primary'))
    .width(this.widthPercent)
    .enabled(this.ifEnabled)
    .height($r('app.float.id_item_height_large'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }
}