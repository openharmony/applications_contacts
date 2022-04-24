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

import ArrayUtil from '../../util/ArrayUtil';
import HiLog from '../../util/HiLog';
import DialUtil from '../../util/DialUtil';
import {CallType} from '../../call/entity/CallLog';

const TAG = "ContactDetail-calllog";

/**
 * Call log
 */
@Component
struct CallLogListItem {
  private message: string;
  private imgRes: Resource;
  @Link private mDetailModel: any;

  aboutToAppear() {
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
        Row() {
          Text(JSON.parse(this.message).dateDetail)
            .fontWeight(FontWeight.Medium)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
          Text(JSON.parse(this.message).timeDetail)
            .fontWeight(FontWeight.Medium)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
        }
        .height("22vp")

        Row() {
          Image(this.imgRes)
            .objectFit(ImageFit.Fill)
            .width($r("app.float.id_card_image_xs"))
            .height($r("app.float.id_card_image_xs"))
            .opacity(0.4)
          Text(JSON.parse(this.message).formatNumber)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .fontColor(JSON.parse(this.message).callType == CallType.MISSED || JSON.parse(this.message).callType
            == CallType.REJECTED ? $r("sys.color.ohos_id_color_handup") : $r("sys.color.ohos_id_color_text_tertiary"))
            .margin({ left: $r("app.float.id_card_margin_mid") })
        }
        .height("19vp")
        .margin({ top: $r("app.float.id_card_margin_sm") })
      }

      Blank();

      Row() {
        Text($r('app.string.Ringing'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .visibility(JSON.parse(this.message).callType == CallType.MISSED ? Visibility.Visible : Visibility.None)

        Text(JSON.parse(this.message).talkTime)
          .fontWeight(FontWeight.Regular)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
      }
      .height("19vp")
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .padding({ top: 5, bottom: 5 })
    .onClick(() => {
      DialUtil.getInstance().dial(JSON.parse(this.message).formatNumber, (data, err, value) => {
        HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
      });
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}
/**
 * Call log
 */
@Component
export default struct DetailCalllog {
  @Link private mDetailModel: any;

  build() {
    Column() {
      Divider()
        .strokeWidth(8)
        .color($r("sys.color.ohos_id_color_subheading_separator"))

      Row() {
        Text($r('app.string.dialer_calllog'))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .margin({ left: $r("app.float.id_card_margin_max") })

        Blank();

        Text($r('app.string.clear'))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .margin({ right: $r("app.float.id_card_margin_max") })
          .onClick(() => {
            this.mDetailModel.clearPhoneRecords()
          })
      }
      .width('100%')
      .height($r("app.float.id_item_height_sm"))

      List() {
        ForEach(this.mDetailModel.contactForm.numRecords, (item, index) => {
          ListItem() {
            CallLogListItem({ message: JSON.stringify(item), mDetailModel: $mDetailModel });
          }

          if (index < this.mDetailModel.contactForm.numRecords.length - 1) {
            ListItem() {
              Divider()
                .color($r("sys.color.ohos_id_color_list_separator"))
            }
          }
        }, item => item.id.toString())
      }.margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
    }
    .width("100%")
    .backgroundColor(Color.White)
    .visibility(ArrayUtil.isEmpty(this.mDetailModel.contactForm.numRecords) ? Visibility.None : Visibility.Visible)
  }
}