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
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import CalendarUtil from '../../../util/CalendarUtil';

@CustomDialog
export struct ShowDayTime {
  private date = new Date(2000, 0, 1);
  @Link mPresent: AccountantsPresenter;
  @Prop itemIndex: number;
  @Prop itemType: number;
  showTime: ResourceStr = $r("app.string.yearMonthDay", this.date.getFullYear(),
                            (this.date.getMonth() + 1), this.date.getDate());
  private finalDate: string = StringFormatUtil.numberFormatDateString(this.date.getFullYear(), this.date.getMonth() + 1,
                              this.date.getDate())
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void
  onChangeStatus: number = 0;

  aboutToAppear() {
    const data = this.mPresent.contactInfoAfter?.events[this.itemIndex]?.data;
    if(!StringUtil.isEmpty(data)) {
      const dataArray = data.split("-");
      if(!ArrayUtil.isEmpty(dataArray) && dataArray.length == 3) {
        this.date = new Date(Number.parseInt(dataArray[0]), Number.parseInt(dataArray[1])-1, Number.parseInt(dataArray[2]))
      }
    }

    this.showTime = this.formatDateShowTime(this.date)
  }

  aboutToDisappear() {
    this.onChangeStatus = 0;
  }

  isLunarDateType() {
    return this.itemType == Birthday.TYPE_LUNARBIRTHDAY
  }

  formatLunarShowTime(date: Date) {
    const lunarStr = CalendarUtil.formatLunarDate(CalendarUtil.getLunarDate(date));
    return lunarStr
  }

  formatDateShowTime(finalDate: Date | string): ResourceStr {
    let isLunar = this.isLunarDateType();
    let showTime: ResourceStr;
    let date = new Date(finalDate);
    let weekList = [$r("app.string.sunday"), $r("app.string.monday"), $r("app.string.tuesday"), $r("app.string.wednesday"),
                    $r("app.string.thursday"), $r("app.string.friday"), $r("app.string.saturday")]
    let weekIndex = date.getDay();
    let week = weekList[weekIndex];
    let resourceStr: string = globalThis.context.resourceManager.getStringSync(week);
    if(isLunar) {
      showTime = this.formatLunarShowTime(date);
      showTime += '' + resourceStr;
    } else {
      showTime = $r("app.string.yearMonthDay", this.date.getFullYear(), (this.date.getMonth() + 1),
                    this.date.getDate())
    }
    return showTime
  }

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
          this.onChangeStatus = 1
          this.finalDate = StringFormatUtil.numberFormatDateString(value.year, value.month as number + 1, value.day)
          this.showTime = this.formatDateShowTime(this.finalDate)
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
          if (StringUtil.isEmpty(this.mPresent.contactInfoAfter.events[this.itemIndex].eventType)) {
            this.mPresent.contactInfoAfter.events[this.itemIndex] = new EventBean("", "", "1", "");
          }
          if(this.mPresent.contactInfoAfter?.events[this.itemIndex]?.data == "") {
            this.mPresent.contactInfoAfter.events[this.itemIndex].data = this.finalDate;
          }
          if(this.onChangeStatus === 1) {
            this.mPresent.contactInfoAfter.events[this.itemIndex].data = this.finalDate;
          }
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