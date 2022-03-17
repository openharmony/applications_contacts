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

import Utils from '../../util/Utils';
import HiLog from '../../util/HiLog';
import detailModel from '../../model/contactDetailModel';
import DialUtil from '../../util/DialUtil';

const TAG = "ContactDetail-calllog"

/**
 * 通话记录
 */
@Component
struct CallLogListItem {
  private message: string;
  private title: string;
  private detailtime: string;
  private phonenumber: string;
  private talkTime: string;
  private imgRes: Resource;
  @Link private mDetailModel: any;

  aboutToAppear() {
    this.title = JSON.parse(this.message).timeDetail;
    this.phonenumber = JSON.parse(this.message).formatNumber;
    this.talkTime = JSON.parse(this.message).talkTime;
    switch (JSON.parse(this.message).callType) {
      case 1:
        this.imgRes = $r('app.media.ic_contacts_call_in_mini');
        break;
      case 2:
        this.imgRes = $r('app.media.ic_contacts_callout_mini');
        break;
      case 3:
        this.imgRes = $r('app.media.ic_contacts_call_missed_mini');
        break;
      case 5:
        this.imgRes = $r('app.media.ic_contacts_call_rejected_mini');
        break;
    }
  }

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start, }) {
        Text(this.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .fontColor(JSON.parse(this.message).callType == "3" ||
                     JSON.parse(this.message).callType == "5" ? Color.Red : Color.Black)
          .height("22vp")

        Row() {
          Image(this.imgRes)
            .objectFit(ImageFit.Fill)
            .width("12vp")
            .height("12vp")
          Text(this.phonenumber)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor('#182431')
            .margin({ left: 1 })
        }
        .height("19vp")
        .opacity(0.4)
        .margin({ top: 2 })
      }

      Blank();

      Row() {
        Text($r('app.string.noAnswer'))
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .opacity(0.4)
          .visibility(JSON.parse(this.message).callType == "3" ? Visibility.Visible : Visibility.None)

        Text(this.talkTime)
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .opacity(0.4)
      }
      .height("19vp")
    }
    .width('100%')
    .height("64vp")
    .padding({ top: 5, bottom: 5 })
    .onClick(() => {
      DialUtil.getInstance().dial(this.phonenumber, (data, err, value) => {
        HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
      });
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}
/**
 * 通话记录
 */
@Component
export default struct DetailCalllog {
  @Link private mDetailModel: any;

  build() {
    Column() {
      Column().width('100%').height('8vp').backgroundColor($r('app.color.gray_divider'))

      Row() {
        Text($r('app.string.dialer_calllog'))
          .fontSize(16)
          .opacity(0.6)
          .margin({ left: 24 })

        Blank();

        Text($r('app.string.clear'))
          .fontSize(16)
          .fontColor($r('app.color.colorConnected'))
          .margin({ right: 24 })
          .onClick(() => {
            this.mDetailModel.clearPhoneRecords()
          })
      }
      .width('100%')
      .height('40vp')

      List() {
        ForEach(this.mDetailModel.contactForm.numRecords, (item, index) => {
          ListItem() {
            CallLogListItem({ message: JSON.stringify(item), mDetailModel: $mDetailModel });
          }

          if (index < this.mDetailModel.contactForm.numRecords.length - 1) {
            ListItem() {
              Divider()
                .vertical(false)
                .strokeWidth('1vp')
                .color(Color.Gray)
                .opacity(0.6)
            }
          }
        }, item => item.id.toString())
      }.margin({ left: 24, right: 24 })
    }
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.numRecords) ? Visibility.None : Visibility.Visible)
  }
}