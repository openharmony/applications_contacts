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
 * Custom pop-up menu
 */
@Component
export struct DetailMenu {
  @State showPopup: boolean = false;
  private menuItems: Array<{ [key: string]: any }>
  private menuImage: Resource = $r("app.media.ic_public_more");
  private sizeType: SizeType = SizeType.LG;
  private placement: Placement = Placement.BottomLeft;
  private menuText: Resource = null;
  private menuTextColor: Resource = $r("sys.color.ohos_id_color_text_primary");

  @Builder PopupBuilder() {
    Column() {
      List() {
        ForEach(this.menuItems, (item, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text(item.value)
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .lineHeight(21)
                .width("100%")
                .height($r("app.float.id_item_height_mid"))
                .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
                .fontWeight(FontWeight.Regular)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
            }
            .width("100%")
            .height($r("app.float.id_item_height_mid"))
            .borderRadius(16)
            .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
            .onClick(() => {
              item.action();
            })
          }
        }, item => JSON.stringify(item))
      }
      .listDirection(Axis.Vertical)
      .divider({ strokeWidth: 0.5, color: $r("sys.color.ohos_id_color_list_separator"),
        startMargin: $r("app.float.id_card_margin_max"), endMargin: $r("app.float.id_card_margin_max") })
      .edgeEffect(EdgeEffect.Spring)
      .chainAnimation(false)
    }
    .backgroundColor(Color.White)
    .width(this.sizeType == SizeType.LG ? 186 : 144)
    .borderRadius(16)
    .padding({ top: $r("app.float.id_card_margin_mid"), bottom: $r("app.float.id_card_margin_mid"),
      left: $r("app.float.id_card_margin_mid"), right: $r("app.float.id_card_margin_mid") })
  }

  build() {
    Column() {
      Image(this.menuImage)
        .width($r("app.float.id_card_image_small"))
        .height($r("app.float.id_card_image_small"))
      if (this.menuText != null) {
        Text(this.menuText)
          .fontSize(10)
          .lineHeight(14)
          .fontColor(this.menuTextColor)
          .margin({ top: $r("app.float.id_card_margin_mid") })
      }
    }
    .margin({ right: $r("app.float.id_card_margin_max") })
    .onClick(() => {
      this.showPopup = !this.showPopup;
    })
    .bindPopup(this.showPopup, {
      builder: this.PopupBuilder,
      placement: this.placement,
      maskColor:"#00ffffff",
      popupColor: $r("sys.color.ohos_id_color_background"),
      enableArrow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showPopup = false;
        }
      }
    })
  }
}