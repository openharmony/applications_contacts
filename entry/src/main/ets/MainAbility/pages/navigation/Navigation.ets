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
 * 联系人导航栏页面基础按钮&跳转逻辑;
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
        Flex({direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center}) {
          Image(this.present.getTabSrc(this.bottomTabIndex, item))
            .objectFit(ImageFit.Contain)
            .width($r("app.float.contact_samll_image_width_height"))
            .height($r("app.float.contact_samll_image_width_height"))
            .fillColor(this.present.getTabTextColor(this.bottomTabIndex, item))
          Text(this.present.getTabText(this.bottomTabIndex, item))
            .fontSize($r("app.float.contact_text_size_body3"))
            .fontColor(this.present.getTabTextColor(this.bottomTabIndex, item))
        }
        .width($r("app.float.contact_navigation_width"))
        .height($r("app.float.contact_navigation_element_height"))
        .onClick(() => {
          if (this.bottomTabIndex != item) {
            this.controller.changeIndex(item)
          }
        })
      }, item => item.toString())
    }
    .width($r("app.float.contact_navigation_width"))
    .height('100%')
  }
}

/**
 * 联系人导航栏页面基础按钮&跳转逻辑;
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
        Flex({direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center}) {
          Image(this.present.getTabSrc(this.bottomTabIndex, item))
            .objectFit(ImageFit.Contain)
            .width($r("app.float.contact_samll_image_width_height"))
            .height($r("app.float.contact_samll_image_width_height"))
            .fillColor(this.present.getTabTextColor(this.bottomTabIndex, item))
          Text(this.present.getTabText(this.bottomTabIndex, item))
            .fontSize($r("app.float.contact_text_size_body3"))
            .fontColor(this.present.getTabTextColor(this.bottomTabIndex, item))
        }
        .height($r("app.float.contact_titleguide_height"))
        .layoutWeight(1)
        .onClick(() => {
          if (this.bottomTabIndex != item) {
            this.controller.changeIndex(item)
          }
        })
      }, item => item.toString())
    }
    .height($r("app.float.contact_titleguide_height"))
    .width('100%')
    .padding({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
  }
}