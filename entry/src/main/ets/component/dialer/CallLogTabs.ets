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

@Component
export struct CallLogTabs {
  private controller: TabsController
  @Link bottomTabIndex: number
  @LocalStorageProp('breakpoint') curBp: string = 'sm'

  build() {
    Row() {
      Column() {
        Text($r("app.string.all_call_logs"))
          .fontSize($r("app.float.contact_text_size_body1"))
          .lineHeight('22vp')
          .fontColor(this.bottomTabIndex == 0 ? $r('sys.color.ohos_id_color_connected') : $r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(this.bottomTabIndex == 0 ? FontWeight.Medium : FontWeight.Regular)
          .margin({ top: 17, bottom: 6 })

        Row()
          .width($r("app.float.id_item_height_max"))
          .height($r("app.float.id_card_margin_sm"))
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .visibility(this.bottomTabIndex == 0 ? Visibility.Visible : Visibility.None)
          .borderRadius($r("app.float.id_card_margin_sm"))
      }
      .width(this.curBp === 'lg' ? '84vp' : '78vp')
      .height($r("app.float.id_item_height_large"))
      .margin(this.curBp === 'lg' ? { right: 50 } : { right: 31 })
      .onClick(() => {
        if (this.bottomTabIndex != 0) {
          this.controller.changeIndex(0)
        }
      })

      Column() {
        Text($r("app.string.missed_call"))
          .fontSize($r("app.float.contact_text_size_body1"))
          .lineHeight('22vp')
          .fontColor(this.bottomTabIndex == 1 ? $r('sys.color.ohos_id_color_connected') : $r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(this.bottomTabIndex == 1 ? FontWeight.Medium : FontWeight.Regular)
          .margin({ top: 17, bottom: 6 })

        Row()
          .width($r("app.float.id_item_height_max"))
          .height($r("app.float.id_card_margin_sm"))
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .visibility(this.bottomTabIndex == 1 ? Visibility.Visible : Visibility.None)
          .borderRadius($r("app.float.id_card_margin_sm"))
      }
      .width(this.curBp === 'lg' ? '84vp' : '78vp')
      .height($r("app.float.id_item_height_large"))
      .onClick(() => {
        if (this.bottomTabIndex != 1) {
          this.controller.changeIndex(1)
        }
      })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height($r("app.float.id_item_height_large"))
    .zIndex(3)
  }
}