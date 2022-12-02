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

import BatchSelectContactsPresenter from '../../../presenter/contact/batchselectcontacts/BatchSelectContactsPresenter';

const TAG = 'BatchTabGuide ';

@Component
export default struct BatchTabGuide {
  @State presenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();
  @Link currentIndex: number;
  private controller: TabsController;

  build() {
    Flex({ direction: FlexDirection.Row,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center }) {

      ForEach(this.presenter.tabTextSrc, (item, index) => {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.End,
          alignItems: ItemAlign.Center }) {
          Text(item)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontColor(this.currentIndex == index ? $r("sys.color.ohos_id_color_connected") : $r("sys.color.ohos_id_color_text_tertiary"))
            .textAlign(TextAlign.Center)
            .margin({ top: 17, bottom: 6 })
            .fontWeight(FontWeight.Medium)

          Divider()
            .width(index === 1 ? 56 : 32)
            .vertical(false)
            .strokeWidth(2)
            .borderRadius(1)
            .color($r("sys.color.ohos_id_color_connected"))
            .visibility(this.currentIndex == index ? Visibility.Visible : Visibility.Hidden)
        }
        .width(120)
        .height($r("app.float.id_item_height_large"))
        .margin({ left: $r("app.float.id_card_margin_xl"), right: $r("app.float.id_card_margin_xl") })
        .onClick(() => {
          if (this.currentIndex != index) {
            this.controller.changeIndex(index);
          }
        })

      }, (item, index) => JSON.stringify(item))

    }
    .width('100%')
    .height($r("app.float.id_item_height_large"))
  }
}