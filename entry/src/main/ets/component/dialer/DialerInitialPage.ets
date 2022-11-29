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

import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter'

@Component
export struct DialerInitialPage {
  @State mPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();

  aboutToAppear() {
    this.mPresenter.aboutToAppear();
  }

  build() {
    Column() {
      Text($r("app.string.support_pinyin"))
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r("app.float.id_card_margin_xxl") })

      Row() {
        Text($r("app.string.search_huaxiaofen"))
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text("H")
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text("ua ")
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text("X")
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text("iao ")
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text("F")
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)

        Text($r("app.string.you_can_enter"))
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Regular)
      }
      .margin({ bottom: $r("app.float.id_card_margin_xxl") })

      Flex({ direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceEvenly,
        alignItems: ItemAlign.Start }) {
        Column() {
          Text("4")
            .fontSize($r("sys.float.ohos_id_text_size_headline8"))
            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
            .fontWeight(FontWeight.Regular)

          Row() {
            Text("G")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontWeight(FontWeight.Regular)

            Text("H")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_connected"))
              .fontWeight(FontWeight.Regular)

            Text("I")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontWeight(FontWeight.Regular)
          }
        }

        Text("+")
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_text_secondary"))
          .fontWeight(FontWeight.Regular)

        Column() {
          Text("9")
            .fontSize($r("sys.float.ohos_id_text_size_headline8"))
            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
            .fontWeight(FontWeight.Regular)

          Row() {
            Text("W")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontWeight(FontWeight.Regular)

            Text("X")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_connected"))
              .fontWeight(FontWeight.Regular)

            Text("YZ")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontWeight(FontWeight.Regular)
          }
        }

        Text("+")
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_text_secondary"))
          .fontWeight(FontWeight.Regular)

        Column() {
          Text("3")
            .fontSize($r("sys.float.ohos_id_text_size_headline8"))
            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
            .fontWeight(FontWeight.Regular)

          Row() {
            Text("DE")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontWeight(FontWeight.Regular)

            Text("F")
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r("sys.color.ohos_id_color_connected"))
              .fontWeight(FontWeight.Regular)
          }
        }
      }
      .padding({ left: $r("app.float.id_item_height_max"), right: $r("app.float.id_item_height_max") })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("sys.color.ohos_id_color_primary_contrary"))
    .markAnchor({ x: 0, y: 60 })
    .position({ x: 0, y: '40%' })
  }
}