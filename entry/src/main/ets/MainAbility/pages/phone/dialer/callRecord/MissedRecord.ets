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
 * call log miss record
 */
import CallRecordPresenter from './../../../../presenter/dialer/callRecord/CallRecordPresenter'

const TAG = "MissedRecord ";

const DENSITY = 1.5

@Component
export default struct MissedRecord {
  @Link mPresenter: CallRecordPresenter;

  aboutToAppear() {
    this.mPresenter.aboutToAppear();
  }

  aboutToDisappear() {
    this.mPresenter.aboutToDisappear();
  }

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
  @Link private mPresenter: CallRecordPresenter;

  build() {
    List() {
      LazyForEach(this.mPresenter.mMissCallRecordListDataSource, (item, index: number) => {
        ListItem() {
          ContactItem({ mPresenter: $mPresenter, item: item });
        }
        .height($r("app.float.dialer_calllog_item_height"))
      }, item => item.id)
    }
    .divider({
      strokeWidth: 1,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.id_item_height_sm"),
      endMargin: $r("app.float.id_card_margin_max"),
    })
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
        .margin({ bottom: 8 * DENSITY })
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
  @Link mPresenter: CallRecordPresenter;
  @State item: any = {};

  build() {
    Flex({ direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center }) {

      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Center }) {

          Image(this.item.callType == 5 ?
          $r('app.media.ic_contacts_Reject') : "")
            .height($r("app.float.dialer_common_small_margin"))
            .width($r("app.float.dialer_common_small_margin"))

        }
        .margin({
          right: $r("app.float.dialer_keypad_margin1"),
          top: $r("app.float.dialer_keypad_margin1"),
          left: $r("app.float.dialer_keypad_margin1")
        })
        .height($r("app.float.id_item_height_mid"))

        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Start }) {

          Flex({ direction: FlexDirection.Row,
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center }) {

            Text(this.item.displayName
              ? this.item.displayName
              : this.item.phoneNumber)
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
              .fontColor((this.item.callType === 5) ? $r('sys.color.ohos_id_color_warning')
                                                    : $r('sys.color.ohos_id_color_text_primary'))

            if (this.item.count != 1) {
              Text('(' + this.item
              .count + ')')
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .fontColor((this.item.callType === 5)
                  ? $r('sys.color.ohos_id_color_warning')
                  : $r('sys.color.ohos_id_color_text_primary'))
            }
          }

          Text(this.item.numberLocation
            ? this.item.numberLocation
            : $r("app.string.unknown"))
            .fontSize($r("sys.float.ohos_id_text_size_body3"))
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .margin({ top: $r("app.float.dialer_common_very_small_margin1") })

        }
        .height($r("app.float.id_item_height_max"))
      }

      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center }) {
          Text(this.item
          .createTime)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .margin({ right: $r("app.float.dialer_keypad_margin1") })
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        }

        Image($r('app.media.ic_public_detail'))
          .height($r("app.float.id_card_margin_max"))
          .width($r("app.float.id_card_margin_max"))
          .margin({ right: 36 })
          .onClick(() => {
            this.mPresenter.jumpToContactDetail(this.item.phoneNumber);
          })
      }
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .onClick((event: ClickEvent) => {
      this.mPresenter.dialing(this.item.phoneNumber);
    })
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress)
  }

  @Builder MenuBuilder() {
    Column() {
      Text(this.item
           .displayName ? this.item
                          .displayName : this.item
                                         .phoneNumber)
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      Text($r("app.string.send_message"))
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      Text($r("app.string.copy_phoneNumber"))
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      Text($r("app.string.edit_beforeCall"))
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      Text($r("app.string.add_to_blockList"))
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
      Text($r("app.string.delete_call_logs"))
        .width('100%')
        .textAlign(TextAlign.Start)
        .height($r("app.float.id_item_height_mid"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
        .onClick(() => {
          this.mPresenter.deleteCallLog(this.item.ids);
        })
    }
    .width($r("app.float.account_MenuBuilder_width"))
    .padding({ left: $r("app.float.id_card_margin_xxl"),
      right: $r("app.float.id_card_margin_xxl") })
    .height($r("app.float.dialer_calllog_bindmenu_height"))
    .padding($r("app.float.dialer_common_very_small_margin1"))
    .borderRadius($r("app.float.id_corner_radius_card_mid"))

  }
}

