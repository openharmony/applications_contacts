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
export default struct BatchSelectContactItemView {
  @State private single: boolean = false;
  @State private item: { [key: string]: any } = {};
  private onContactItemClicked: Function;
  private onSingleContactItemClick: Function;
  private index: number;
  @State private showIndex: boolean = false;
  @State private showDivifer: boolean = false;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Row() {
          if (StringUtil.isEmpty(this.item.nameSuffix)) {
            Image(StringUtil.isEmpty(this.item.portraitPath) ? $r("app.media.ic_user_portrait") : this.item.portraitPath)
              .width($r("app.float.id_card_image_mid"))
              .height($r("app.float.id_card_image_mid"))
              .objectFit(ImageFit.Contain)
              .borderRadius($r("app.float.id_card_image_mid"))
              .backgroundColor(this.item.portraitColor)
          } else {
            Text(this.item.nameSuffix.toUpperCase())
              .fontSize(30)
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
        .flexShrink(0)

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
          Text(StringUtil.isEmpty(this.item.showName) ? this.item.phoneNum : this.item.showName)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r("app.float.id_card_margin_xl"), bottom: $r("app.float.id_card_margin_sm") })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)

          Text(this.item.phoneNumbers[0].labelName)
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .margin({ left: $r("app.float.id_card_margin_xl") })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
        }
        .flexGrow(1)
        .flexShrink(1)
        .padding({ top: $r("app.float.id_card_margin_mid"), bottom: $r("app.float.id_card_margin_mid") })
        .constraintSize({ minHeight: $r("app.float.id_item_height_max") })

        Toggle({
          type: ToggleType.Checkbox,
          isOn: (this.item.phoneNumbers[0].checked == undefined) ? false : this.item.phoneNumbers[0].checked
        })
          .width(20)
          .height(20)
          .flexShrink(0)
          .enabled(false)
          .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
          .selectedColor($r("sys.color.ohos_id_color_connected"))
          .visibility(!this.single ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height($r("app.float.id_item_height_max"))
      .onClick(() => {
        if (!this.single) {
          this.onContactItemClicked(this.index, 0);
        } else {
          this.onSingleContactItemClick(this.item.phoneNumbers[0].phoneNumber, this.item.showName);
        }
      })

      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.item.phoneNumbers, (item, index) => {
          ListItem() {
            if (index != 0) {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Row() {
                }
                .width($r("app.float.id_card_image_mid"))
                .height($r("app.float.id_card_image_mid"))
                .margin({ left: $r("app.float.id_card_margin_max") })
                .visibility(Visibility.Hidden)

                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Start,
                  justifyContent: FlexAlign.Center
                }) {

                  Text(item.labelName)
                    .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                    .fontSize($r("sys.float.ohos_id_text_size_body2"))
                    .fontWeight(FontWeight.Regular)
                    .margin({ left: $r("app.float.id_card_margin_xl") })
                }
                .flexGrow(1)
                .height($r("app.float.id_item_height_mid"))
              }
              .width('100%')
              .height($r("app.float.id_item_height_mid"))
              .onClick(() => {
                if (!this.single) {
                  this.onContactItemClicked(this.index, index);
                } else {
                  this.onSingleContactItemClick(this.item.phoneNumbers[index].phoneNumber, this.item.showName);
                }
              })
            }
          }
        }, (item, index) => JSON.stringify(item))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: 76,
        endMargin: $r("app.float.id_card_margin_max"),
      })
    }
    .padding({ top: this.showIndex ? 4 : 0,
      bottom: this.showDivifer ? 4 : 0,
    })
    .backgroundColor(Color.White)
    .clip(new Rect({
      width: "100%",
      height: "100%",
      radius: [[this.showIndex ? 24 : 0, this.showIndex ? 24 : 0],
      [this.showIndex ? 24 : 0, this.showIndex ? 24 : 0],
      [this.showDivifer ? 0 : 24, this.showDivifer ? 0 : 24],
      [this.showDivifer ? 0 : 24, this.showDivifer ? 0 : 24]]
    }))
  }
}
