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

@Component
export struct CallLogTabs {
  private controller: TabsController
  @Link bottomTabIndex: number

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Column() {
        Text($r("app.string.all_call_logs"))
          .fontSize('16vp')
          .lineHeight('22vp')
          .fontColor(this.bottomTabIndex == 0 ? '#00CB87' : '#99182431')
          .margin({ top: 17, bottom: 6  })

        Row()
          .width('64vp')
          .height('2vp')
          .backgroundColor('#00CB87')
          .visibility(this.bottomTabIndex == 0 ? Visibility.Visible : Visibility.None)
      }
      .width('84vp')
      .height('56vp')
      .margin({ right: 50 })
      .onClick(() => {
        if (this.bottomTabIndex != 0) {
          this.controller.changeIndex(0)
        }
      })

      Column() {
        Text($r("app.string.missed_call"))
          .fontSize('16vp')
          .lineHeight('22vp')
          .fontColor(this.bottomTabIndex == 1 ? '#00CB87' : '#99182431')
          .margin({ top: 17, bottom: 6 })

        Row()
          .width('64vp')
          .height('2vp')
          .backgroundColor('#00CB87')
          .visibility(this.bottomTabIndex == 1 ? Visibility.Visible : Visibility.None)
      }
      .width('84vp')
      .height('56vp')
      .onClick(() => {
        if (this.bottomTabIndex != 1) {
          this.controller.changeIndex(1)
        }
      })
    }
    .width('100%')
    .height('56vp')
    .zIndex(3)
  }
}