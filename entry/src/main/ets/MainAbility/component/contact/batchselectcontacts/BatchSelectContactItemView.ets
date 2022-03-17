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

import {ContactVo} from '../../../model/bean/ContactVo';
import Utils from '../../../util/Utils';

const TAG = 'BatchSelectRecentItemView ';

/**
 * 选择联系人item组件，主要负责单个联系人的显示;
 */
@Component
export default struct BatchSelectRecentItemView {
  @State private item: any = {};
  private onContactItemClicked: Function;
  private index: number;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Row() {
          Text(this.item.name.nameSuffix)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(this.item.portraitColor)
            .height($r("app.float.contact_listpage_icon_width_height"))
            .width($r("app.float.contact_listpage_icon_width_height"))
            .textAlign(TextAlign.Center)
            .clip(new Circle({ width: 40, height: 40 }))
            .border({ width: 0, color: Color.White, radius: 40 })
            .visibility((!Utils.isEmpty(this.item.portraitPath) || (Utils.isEmpty(this.item.portraitPath) && Utils.isEmpty(this.item.showName) && Utils.isEmpty(this.item.phoneNum))) ? Visibility.None : Visibility.Visible)

          Image(Utils.isEmpty(this.item.portraitPath) ? $r("app.media.avatar_filled_honor") : this.item.portraitPath)
            .width($r("app.float.contact_listpage_icon_width_height"))
            .height($r("app.float.contact_listpage_icon_width_height"))
            .clip(new Circle({ width: 40, height: 40 }))
            .objectFit(ImageFit.Contain)
            .visibility((!Utils.isEmpty(this.item.portraitPath) || (Utils.isEmpty(this.item.portraitPath) && Utils.isEmpty(this.item.showName) && Utils.isEmpty(this.item.phoneNum))) ? Visibility.Visible : Visibility.None)
        }
        .width($r("app.float.contact_listpage_icon_width_height"))
        .height($r("app.float.contact_listpage_icon_width_height"))
        .margin({ left: $r("app.float.common_margin") })

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
          Text(this.item.emptyNameData)
            //          .fontColor($r("app.color.textColorPrimary"))
            .fontColor('#182431')
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12, bottom: 2 })

          Text(Utils.isEmpty(this.item.phoneNumbers[0].labelName) ? '' : this.item.phoneNumbers[0].labelName + '  ' + this.item.phoneNumbers[0].phoneNumber)
            //          .fontColor($r("app.color.textColorTertiary"))
            .fontColor('#66182431')
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontWeight(FontWeight.Regular)
              //          .visibility((Utils.isEmpty(this.item.company) && Utils.isEmpty(this.item.position)) ? Visibility.None : Visibility.Visible)
            .margin({ left: 12 })
        }
        .flexGrow(1)
        .height($r("app.float.contact_listitem_height"))

        Toggle({
          type: ToggleType.Checkbox,
          isOn: (this.item.phoneNumbers[0].checked == undefined) ? false : this.item.phoneNumbers[0].checked
        })
          .width($r("app.float.contact_samll_image_width_height"))
          .height($r("app.float.contact_samll_image_width_height"))
          .enabled(false)
          .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
      }
      .width('100%')
      .height($r("app.float.contact_listitem_height"))
      .onClick(() => {
        this.onContactItemClicked(this.index, 0);
      })

      ForEach(this.item.phoneNumbers, (item, index) => {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
          Row() {
          }
          .width($r("app.float.contact_listpage_icon_width_height"))
          .height($r("app.float.contact_listpage_icon_width_height"))
          .margin({ left: $r("app.float.common_margin") })
          .visibility(Visibility.Hidden)

          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {

            Text(Utils.isEmpty(item.labelName) ? '' : item.labelName + '  ' + item.phoneNumber)
              //          .fontColor($r("app.color.textColorTertiary"))
              .fontColor('#66182431')
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontWeight(FontWeight.Regular)
              .margin({ left: 12 })
          }
          .flexGrow(1)
          .height($r("app.float.contact_listitem_height"))

          Toggle({ type: ToggleType.Checkbox, isOn: (item.checked == undefined) ? false : item.checked })
            .width($r("app.float.contact_samll_image_width_height"))
            .height($r("app.float.contact_samll_image_width_height"))
            .enabled(false)
            .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
        }
        .width('100%')
        .height($r("app.float.contact_listitem_height"))
        .visibility(index == 0 ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          this.onContactItemClicked(this.index, index);
        })
      }, (item, index) => item.toString())
    }
    .backgroundColor(Color.White)
  }
}