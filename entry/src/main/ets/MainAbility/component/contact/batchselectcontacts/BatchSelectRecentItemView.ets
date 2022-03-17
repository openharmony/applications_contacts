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
import {CallBean} from '../../../model/bean/CallBean';
import Utils from '../../../util/Utils';
import HiLog from '../../../util/HiLog';

const TAG = 'BatchSelectRecentItemView ';

/**
 * 选择联系人item组件，主要负责单个联系人的显示;
 */
@Component
export default struct BatchSelectRecentItemView {
  private onRecentItemClicked: Function;
  @State private item: any = {};
  private index: number;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Row() {
        Text(this.item.suffix)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(this.item.portraitColor)
          .height($r("app.float.contact_listpage_icon_width_height"))
          .width($r("app.float.contact_listpage_icon_width_height"))
          .textAlign(TextAlign.Center)
          .clip(new Circle({ width: 40, height: 40 }))
          .border({ width: 0, color: Color.White, radius: 40 })
          .visibility(Utils.isEmpty(this.item.suffix) ? Visibility.None : Visibility.Visible)

        Image($r("app.media.avatar_filled_honor"))
          .width($r("app.float.contact_listpage_icon_width_height"))
          .height($r("app.float.contact_listpage_icon_width_height"))
          .backgroundColor(this.item.portraitColor)
          .clip(new Circle({ width: 40, height: 40 }))
          .border({ width: 0, color: Color.White, radius: 40 })
          .objectFit(ImageFit.Contain)
          .visibility(Utils.isEmpty(this.item.suffix) ? Visibility.Visible : Visibility.None)
      }
      .width($r("app.float.contact_listpage_icon_width_height"))
      .height($r("app.float.contact_listpage_icon_width_height"))
      .margin({ left: $r("app.float.common_margin") })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text(Utils.isEmpty(this.item.displayName) ? this.item.phoneNumber : this.item.displayName)
          //          .fontColor($r("app.color.textColorPrimary"))
          .fontColor('#182431')
          .fontSize($r("app.float.contact_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12, bottom: 2 })

        Row() {
          Text(this.item.formattedNumber)
            //          .fontColor($r("app.color.textColorTertiary"))
            .fontColor('#66182431')
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontWeight(FontWeight.Regular)
            .visibility(Utils.isEmpty(this.item.formattedNumber) ? Visibility.None : Visibility.Visible)
            .margin({ left: 12 })

          Text(this.item.numberLocation)
            //          .fontColor($r("app.color.textColorTertiary"))
            .fontColor('#66182431')
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontWeight(FontWeight.Regular)
            .visibility(Utils.isEmpty(this.item.numberLocation) ? Visibility.None : Visibility.Visible)
            .margin({ left: 12 })

          if (Utils.isEmpty(this.item.displayName) && Utils.isEmpty(this.item.numberLocation)) {
            Text($r("app.string.unknow_location"))
              //          .fontColor($r("app.color.textColorTertiary"))
              .fontColor('#66182431')
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontWeight(FontWeight.Regular)
              .margin({ left: 12 })
          }
        }
      }
      .flexGrow(1)
      .height($r("app.float.contact_listitem_height"))

      Toggle({ type: ToggleType.Checkbox, isOn: this.item.checked })
        .width($r("app.float.contact_samll_image_width_height"))
        .height($r("app.float.contact_samll_image_width_height"))
        .enabled(false)
        .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })

    }
    .height($r("app.float.contact_listitem_height"))
    .width('100%')
    .onClick(() => {
      this.onRecentItemClicked(this.index);
    })
  }
}