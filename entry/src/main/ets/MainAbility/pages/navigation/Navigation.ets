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
import presenter from '../../presenter/navigation/NavigationPresenter';

/**
 * Basic buttons and jump logic on the contact navigation bar
 */
@Component
export struct VerticalTabs {
  private tabSrc: number[] = [0, 1]
  private controller: TabsController
  @Link bottomTabIndex: number
  @State present: typeof presenter = presenter;

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      ForEach(this.tabSrc, item => {
        Flex({ direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center }) {
          Image(this.present.getTabSrc(this.bottomTabIndex, item))
            .objectFit(ImageFit.Contain)
            .width($r("app.float.id_card_image_small"))
            .height($r("app.float.id_card_image_small"))
          Text(this.present.getTabText(this.bottomTabIndex, item))
            .fontWeight(FontWeight.Medium)
            .margin({ top: $r("app.float.id_card_margin_mid") })
            .fontSize($r("sys.float.ohos_id_text_size_caption"))
            .fontColor(this.present.getTabTextColor(this.bottomTabIndex, item))
        }
        .height('130vp')
        .onClick(() => {
          if (this.bottomTabIndex != item) {
            this.controller.changeIndex(item)
          }
        })
      }, item => item.toString())
    }
    .width('96vp')
    .height('100%')
  }
}

/**
 * Basic buttons and jump logic on the contact navigation bar
 */
const DENSITY = 1.5

@Component
export struct HorizontalTabs {
  private tabSrc: number[] = [0, 1]
  private controller: TabsController
  @Link bottomTabIndex: number
  @State present: typeof presenter = presenter;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      ForEach(this.tabSrc, item => {
        Flex({ direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center }) {
          Image(this.present.getTabSrc(this.bottomTabIndex, item))
            .objectFit(ImageFit.Contain)
            .width($r("app.float.id_card_image_small"))
            .height($r("app.float.id_card_image_small"))
          Text(this.present.getTabText(this.bottomTabIndex, item))
            .fontWeight(FontWeight.Medium)
            .fontSize($r("sys.float.ohos_id_text_size_caption"))
            .fontColor(this.present.getTabTextColor(this.bottomTabIndex, item))
        }
        .height($r("app.float.id_item_height_large"))
        .layoutWeight(1)
        .onClick(() => {
          if (this.bottomTabIndex != item) {
            this.controller.changeIndex(item)
          }
        })
      }, item => item.toString())
    }
    .height($r("app.float.id_item_height_large"))
    .width('100%')
    .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
  }
}