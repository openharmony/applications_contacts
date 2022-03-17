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
import HiLog from '../../../util/HiLog';

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
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontColor(this.currentIndex == index ? $r("app.color.colorConnected") : $r("app.color.textColorTertiary"))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 5 })

          Divider()
            .vertical(false)
            .strokeWidth('1vp')
            .color($r("app.color.colorConnected"))
            .visibility(this.currentIndex == index ? Visibility.Visible : Visibility.Hidden)
        }
        .width(60)
        .height($r("app.float.contact_titleguide_height"))
        .margin({ left: 5, right: 5 })
        .onClick(() => {
          HiLog.i(TAG, "item clicked currentIndex is " + this.currentIndex + " index is %d", index);
          if (this.currentIndex != index) {
            this.controller.changeIndex(index);
          }
        })

      }, (item, index) => item.toString())

    }
    .width('100%')
    .height($r("app.float.contact_titleguide_height"))
  }
}