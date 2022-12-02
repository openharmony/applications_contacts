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

import { PhoneNumber } from '../../../../../../feature/phonenumber';
import { CallType } from '../../../../../../feature/call/src/main/ets/entity/CallLog';

const TAG = "ContactDetail-calllog";

/**
 * Call log
 */
@Component
struct CallLogListItem {
  @State message: { [key: string]: any } = {};
  private imgRes: Resource;
  @Link private mPresenter: { [key: string]: any };

  aboutToAppear() {
    switch (this.message.callType) {
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
          Text(this.message.dateDetail)
            .fontWeight(FontWeight.Medium)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
          Text(this.message.timeDetail)
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
          Text(this.message.formatNumber)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .fontColor(this.message.callType == CallType.MISSED || this.message.callType
            == CallType.REJECTED ? $r("sys.color.ohos_id_color_handup") : $r("sys.color.ohos_id_color_text_tertiary"))
            .margin({ left: $r("app.float.id_card_margin_mid") })
        }
        .height("19vp")
        .margin({ top: $r("app.float.id_card_margin_sm") })
      }
      .margin({ left: $r("app.float.id_card_margin_max") })

      Blank();

      Row() {
        Text($r('app.string.Ringing'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .visibility(this.message.callType == CallType.MISSED ? Visibility.Visible : Visibility.None)

        Text(this.message.talkTime)
          .fontWeight(FontWeight.Regular)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
      }
      .margin({right: $r("app.float.id_card_margin_max") })
      .height("19vp")
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .padding({ top: 5, bottom: 5 })
    .onClick(() => {
      PhoneNumber.fromString(this.message.formatNumber).dial();
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
  @Link private mPresenter: { [key: string]: any };

  @Builder callLogTitle() {
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
          AlertDialog.show({
            message: $r('app.string.clear_calllog_sure'),
            alignment: DialogAlignment.Bottom,
            autoCancel: true,
            primaryButton: {
              value: $r('app.string.dialog_cancel'),
              action: () => {
              }
            },
            secondaryButton: {
              value: $r('app.string.dialog_delete'),
              fontColor: $r("sys.color.ohos_id_color_handup"),
              action: () => {
                this.mPresenter.clearAllCallLog();
              }
            },
            offset: {
              dx: 0, dy: -15
            },
          })
        })
    }
    .width('100%')
    .height($r("app.float.id_item_height_sm"))
  }

  build() {
    Column() {
      List() {
        LazyForEach(this.mPresenter.detailCallLogDataSource, (item, index) => {
          ListItem() {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
              if ( item.showTitle ) {
                Divider()
                  .strokeWidth(8)
                  .color($r("sys.color.ohos_id_color_subheading_separator"))
                this.callLogTitle()
              }

              CallLogListItem({ message: item.callLog, mPresenter: $mPresenter });
            }
          }
        }, item => JSON.stringify(item))
      }
      .divider({ strokeWidth: $r("app.float.id_divide_width"),color: $r("sys.color.ohos_id_color_list_separator"),
        startMargin: $r("app.float.id_card_margin_max"), endMargin:$r("app.float.id_card_margin_max")})
    }
    .height("100%")
    .width("100%")
    .backgroundColor(Color.White)
  }
}