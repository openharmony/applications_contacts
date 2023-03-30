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
import { EventBean } from "../../../model/bean/EventBean";
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import StringFormatUtil from "../../../util/StringFormatUtil"
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';

@CustomDialog
export struct ShowDayTime {
  private date = new Date(2000, 0, 1);
  @Link mPresent: AccountantsPresenter;
  @Prop itemIndex: number;
  @Prop itemType: number;
  @State showTime: Resource = $r("app.string.yearMonthDay", this.date.getFullYear(),
    (this.date.getMonth() + 1), this.date.getDate());
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column() {
      Row() {
        Text(this.showTime)
          .height("56vp")
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
      }
      .width("85%")

      DatePicker({ selected: this.date })
        .width("85%")
        .height("200vp")
        .margin({ bottom: 8 })
        .lunar(this.itemType == Birthday.TYPE_LUNARBIRTHDAY)
        .onChange((value: DatePickerResult) => {
          this.date = new Date(value.year, value.month, value.day);
          this.showTime = $r("app.string.yearMonthDay", value.year, (value.month + 1), value.day);
        })

      Row() {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          Text($r("app.string.dialog_cancel"))
            .fontColor('#007DFF')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .height(40)
        .onClick(() => {
          this.controller.close()
          this.cancel()
        })

        Line().width(1).height(40).backgroundColor($r("sys.color.ohos_id_color_list_separator")).margin({
          left: 4,
          right: 4
        })

        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          Text($r("app.string.save"))
            .fontColor('#007DFF')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .height(40)
        .onClick(() => {
          this.mPresent.addState = true;
          this.date.setFullYear(this.date.getFullYear(), this.date.getMonth(), this.date.getDate());
          if (StringUtil.isEmpty(this.mPresent.contactInfoAfter.events[this.itemIndex].eventType)) {
            this.mPresent.contactInfoAfter.events[this.itemIndex] = new EventBean("", "", "1", "");
          }
          this.mPresent.contactInfoAfter.events[this.itemIndex].data = StringFormatUtil.numberFormatDateString(this.date.getFullYear(), this.date.getMonth() + 1, this.date.getDate());
          this.mPresent.refresh();
          this.controller.close();
          this.confirm();
        })
      }
      .alignItems(VerticalAlign.Top)
      .height("56vp")
      .width('85%')
    }.height("320vp")
  }
}