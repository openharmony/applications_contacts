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

/**
 * Call Log Missed Calls
 */
import CallRecordPresenter from './../../../presenter/dialer/callRecord/CallRecordPresenter'

const TAG = "MissedRecord ";

@Component
export default struct MissedRecord {
  @Link mPresenter: CallRecordPresenter;

  build() {
    Stack() {
      if (this.mPresenter.missedList.length === 0) {
        EmptyView()
      } else {
        RecordView({ mPresenter: $mPresenter });
      }
    }
  }
}

@Component
struct RecordView {
  @Link private mPresenter: any;

  build() {
    List() {
      LazyForEach(this.mPresenter.mMissCallRecordListDataSource, (item, index: number) => {
        ListItem() {
          ContactItem({ mPresenter: $mPresenter, item: item });
        }
        .height($r("app.float.id_item_height_max"))
      }, item => item.id)
    }
    .divider({
      strokeWidth: 1,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.id_item_height_sm"),
      endMargin: $r("app.float.id_card_margin_max"),
    })
    .margin({ bottom: '110vp' })
  }
}


@Component
struct EmptyView {
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Image($r('app.media.no_call_records'))
        .objectFit(ImageFit.Contain)
        .width($r("app.float.id_card_image_large"))
        .height($r("app.float.id_card_image_large"))
        .margin({ bottom: $r("app.float.id_card_margin_large") })
      Text($r("app.string.no_dialer_missed_calllog"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .markAnchor({ x: 0, y: 60 })
  }
}

@Component
struct ContactItem {
  @Link mPresenter: CallRecordPresenter
  @State item: any = {};

  build() {
    Flex({ direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center }) {

      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Center }) {

          if (this.item.callType == 3) {
            Row() {
              Blank(16)
            }
          } else if (this.item.callType == 5) {
            Image($r('app.media.ic_contacts_Reject'))
              .height($r("app.float.id_card_margin_xxl"))
              .width($r("app.float.id_card_margin_xxl"))
          } else {
            Row() {
              Blank(16)
            }
          }
        }
        .margin({
          right: $r("app.float.id_card_margin_xl"),
          top: $r("app.float.id_card_margin_xl"),
          left: $r("app.float.id_card_margin_xl")
        })
        .height($r("app.float.id_item_height_mid"))

        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Start }) {

          Flex({ direction: FlexDirection.Row,
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center }) {

            if (this.item.displayName) {
              Text(this.item.displayName)
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .margin({ right: $r("app.float.id_card_margin_large") })
                .fontColor($r('sys.color.ohos_id_color_warning'))
                .fontWeight(FontWeight.Medium)
            } else {
              Text(this.item.phoneNumber)
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .margin({ right: $r("app.float.id_card_margin_large") })
                .fontColor($r('sys.color.ohos_id_color_warning'))
                .fontWeight(FontWeight.Medium)
            }

            if (this.item.count != 1) {
              Text('(' + this.item.count + ')')
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .fontColor($r('sys.color.ohos_id_color_warning'))
                .fontWeight(FontWeight.Medium)
            }
          }

          if (this.item.numberLocation) {
            Text(this.item.numberLocation)
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .margin({ top: $r("app.float.id_card_margin_mid") })
          } else {
            Text($r("app.string.unknown"))
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .margin({ top: $r("app.float.id_card_margin_mid") })
          }

        }
        .height($r("app.float.id_item_height_max"))
      }

      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center }) {
          Text(this.item.createTime)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .margin({ right: $r("app.float.id_card_margin_xl"), top: $r("app.float.id_card_margin_sm") })
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .width('80vp')
            .textAlign(TextAlign.End)
        }
        .height($r("app.float.id_item_height_max"))

        Image($r('app.media.ic_public_detail'))
          .height($r("app.float.id_card_margin_max"))
          .width($r("app.float.id_card_margin_max"))
          .margin({ right: '80vp', top: $r("app.float.id_card_margin_sm") })
          .onClick(() => {
            this.mPresenter.jumpToContactDetail(this.item.phoneNumber)
          })
      }
      .height($r("app.float.id_item_height_max"))
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .onClick((event: ClickEvent) => {
      this.mPresenter.dialing(this.item.phoneNumber)
    })
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress)
  }

  @Builder MenuBuilder() {
    Column() {
      Row() {
        Text(this.item.displayName ?
          this.item.displayName :
          this.item.phoneNumber)
          .fontSize($r("sys.float.ohos_id_text_size_headline8"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
          .lineHeight('28vp')
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_max"))
      .borderRadius($r("app.float.id_card_margin_xxl"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .width('100%')
        .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
      Row() {
        Text($r("app.string.send_message"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_mid"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .width('100%')
        .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
      Row() {
        Text($r("app.string.copy_phoneNumber"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_mid"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .width('100%')
        .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
      Row() {
        Text($r("app.string.edit_beforeCall"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_mid"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .width('100%')
        .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
      Row() {
        Text($r("app.string.add_to_blockList"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_mid"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .width('100%')
        .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
      Row() {
        Text($r("app.string.delete_call_logs"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ left: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
      }
      .width($r("app.float.dialer_calllog_bindmenu_width"))
      .height($r("app.float.id_item_height_mid"))
      .borderRadius($r("app.float.id_card_margin_xxl"))
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      .onClick(() => {
        this.mPresenter.deleteCallLog(this.item.ids);
      })
    }
    .borderRadius($r("app.float.id_card_margin_xxl"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
  }
}

