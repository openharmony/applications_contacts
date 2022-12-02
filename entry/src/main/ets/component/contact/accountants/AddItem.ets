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

import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';

@Component
export struct AddItem {
  @Link mPresent: AccountantsPresenter;
  private labelName: Resource;
  private typeName: string;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Text(this.labelName)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_secondary"))
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)

      Column() {
        Image($r("app.media.ic_public_add_norm_filled"))
          .objectFit(ImageFit.Contain)
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .fillColor($r("sys.color.ohos_id_color_tertiary"))
      }
      .margin({ right: this.curBp === 'lg' ? $r("app.float.id_card_margin_max") : $r("app.float.id_card_margin_xl") })
      .alignItems(HorizontalAlign.End)
    }
    .onClick(() => {
      this.mPresent.addMore(this.typeName);
    })
    .margin({ left: $r("app.float.id_card_margin_xxl") })
    .height(this.curBp === 'lg' ? $r("app.float.id_item_height_large") : $r("app.float.id_item_height_mid"))
  }
}