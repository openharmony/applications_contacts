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

import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';

/**
 * Select the contact item component, which is responsible for displaying a single contact.
 */
@Component
export default struct BatchSelectRecentItemView {
  private onRecentItemClicked: Function;
  @State private item: { [key: string]: any } = {};
  private index: number;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Row() {
        if (StringUtil.isEmpty(this.item.suffix)) {
          Image($r("app.media.ic_user_portrait"))
            .width($r("app.float.id_card_image_mid"))
            .height($r("app.float.id_card_image_mid"))
            .backgroundColor(this.item.portraitColor)
            .borderRadius($r("app.float.id_card_image_mid"))
            .objectFit(ImageFit.Contain)
        } else {
          Text(this.item.suffix.toUpperCase())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(this.item.portraitColor)
            .height($r("app.float.id_card_image_mid"))
            .width($r("app.float.id_card_image_mid"))
            .textAlign(TextAlign.Center)
            .borderRadius($r("app.float.id_card_image_mid"))
        }
      }
      .width($r("app.float.id_card_image_mid"))
      .height($r("app.float.id_card_image_mid"))
      .margin({ left: $r("app.float.id_card_margin_max") })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text(StringUtil.isEmpty(this.item.displayName) ? this.item.phoneNumber : this.item.displayName)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .margin({ left: $r("app.float.id_card_margin_xl"), bottom: $r("app.float.id_card_margin_sm") })

        Row() {
          Text(this.item.formattedNumber)
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .visibility(StringUtil.isEmpty(this.item.formattedNumber) ? Visibility.None : Visibility.Visible)
            .margin({ left: $r("app.float.id_card_margin_xl") })

          Text(this.item.numberLocation)
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .visibility(StringUtil.isEmpty(this.item.numberLocation) ? Visibility.None : Visibility.Visible)
            .margin({ left: $r("app.float.id_card_margin_xl") })

          if (StringUtil.isEmpty(this.item.displayName) && StringUtil.isEmpty(this.item.numberLocation)) {
            Text($r("app.string.unknow_location"))
              .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontWeight(FontWeight.Regular)
              .margin({ left: $r("app.float.id_card_margin_xl") })
          }
        }
      }
      .flexGrow(1)
      .height($r("app.float.id_item_height_max"))

      Toggle({ type: ToggleType.Checkbox, isOn: this.item.checked })
        .width($r("app.float.id_card_image_small"))
        .height($r("app.float.id_card_image_small"))
        .enabled(false)
        .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
        .selectedColor($r("sys.color.ohos_id_color_connected"))

    }
    .height($r("app.float.id_item_height_max"))
    .width('100%')
    .onClick(() => {
      this.onRecentItemClicked(this.index);
    })
  }
}