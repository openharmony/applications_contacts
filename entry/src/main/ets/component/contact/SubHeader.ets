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
@Component
export struct SubHeader {
  @State titleContent: Resource = $r('app.string.favorite');
  @Prop subTitleContent: string = '';
  @Prop maxFontScale: number | null = null;

  build() {
    Row() {
      Text(this.titleContent)
        .fontSize(14)
        .fontColor($r('app.color.skin_font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .maxFontScale(this.maxFontScale)
      Text(this.subTitleContent)
        .fontSize(14)
        .fontColor($r('app.color.skin_font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .maxFontScale(this.maxFontScale)
    }
    .width('100%')
    .constraintSize({
      minHeight: 48
    })
    .alignItems(VerticalAlign.Bottom)
    .padding({
      bottom: 9,
      top: 19.5,
    })
  }
}

@Component
export struct PCSubTitle {
  @Prop subtitle: ResourceStr
  titleMargin: Margin | Length | LocalizedMargin =
    { left: $r('sys.float.padding_level12'), right: $r('sys.float.padding_level12') }
  build() {
    Row() {
      Text(this.subtitle)
        .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
        .lineHeight(19)
        .fontSize($r('sys.float.Body_M'))
        .width('100%')
    }
    .height($r('app.float.id_item_height_sm'))
    .alignItems(VerticalAlign.Bottom)
    .padding({ bottom: $r('sys.float.padding_level4') })
    .margin(this.titleMargin)
  }
}


