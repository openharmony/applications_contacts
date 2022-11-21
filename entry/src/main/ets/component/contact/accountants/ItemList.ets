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

import EnvironmentProp from '../../../feature/EnvironmentProp';

@Component
export struct ItemList {
  @Link mPresent: any;
  private data: any;
  private typeName: any;
  private placeholder: Resource;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Row() {
          Text(this.mPresent.menuSelect(
            this.typeName,
            this.data
          ))
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontWeight(FontWeight.Medium)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .maxLines(1)
            .constraintSize({ minWidth: $r("app.float.account_ItemList_text_width") })
            .bindMenu(this.MenuBuilder)

          Image($r("app.media.ic_public_spinner"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_xs"))
        }
        .height($r("app.float.id_item_height_sm"))
        .constraintSize({ minWidth: $r("app.float.account_listItem_text_common_width") })
      }
      .flexShrink(0)

      Column() {
        Row() {
          Column() {
            TextInput({
              placeholder: this.placeholder,
              text: this.mPresent.getTextDisplay(this.typeName, this.data)
            })
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .caretColor($r("sys.color.ohos_id_color_connected"))
              .type((this.typeName === "phone") ? InputType.PhoneNumber: InputType.Normal)
              .maxLength(256)
              .height("98%")
              .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
              .onChange((arg) => {
                this.mPresent.listItemChange(this.typeName, this.data, arg.toString());
                this.mPresent.textChange(arg);
              })
          }
          .alignItems(HorizontalAlign.Start)
          .flexShrink(1)

          Column() {
            Image($r("app.media.ic_public_close_filled"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
              .fillColor($r("sys.color.ohos_id_color_tertiary"))
              .onClick(() => {
                this.mPresent.deleteItem(this.typeName, this.data.i - 1);
              })
          }
          .flexShrink(0)
        }

        Divider()
          .padding({ left: $r("app.float.id_card_margin_xxl") })
          .height($r("app.float.account_Divider_height"))
          .width("100%")
          .color($r("sys.color.ohos_id_color_list_separator"))
      }
      .alignItems(HorizontalAlign.Start)
      .height($r("app.float.id_item_height_large"))
    }
    .margin({ left: $r("app.float.id_card_margin_xxl"),
      right: this.curBp === 'lg' ? $r("app.float.id_card_margin_max") : $r("app.float.id_card_margin_xl")
    })
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.mPresent.getMenuList(this.typeName),
        (item) => {
          Text(item.labelRes)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .width($r("app.float.account_MenuBuilder_width"))
            .height($r("app.float.id_item_height_mid"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .textAlign(TextAlign.Start)
            .margin({ left: $r("app.float.id_card_margin_xxl") })
            .onClick(() => {
              this.mPresent.menuChange(this.typeName, this.data, item);
            })

          Divider()
            .height($r("app.float.account_Divider_height"))
            .width($r("app.float.account_Divider_width"))
            .color($r("sys.color.ohos_id_color_list_separator"))
        },
        (item) => item.rawValue.toString())
    }
    .width($r("app.float.account_MenuBuilder_width"))
    .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
  }
}