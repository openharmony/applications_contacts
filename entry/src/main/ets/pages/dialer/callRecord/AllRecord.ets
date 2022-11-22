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
 * Call Log All Calls
 */
import CallRecordPresenter from './../../../presenter/dialer/callRecord/CallRecordPresenter';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import IndexPresenter from '../../../presenter/IndexPresenter';

const TAG = "AllRecord ";

@Component
export default struct AllRecord {
  @Link mPresenter: CallRecordPresenter;
  /*0all 1miss*/
  recordType: number = 0;

  build() {
    Stack() {
      if (this.recordType === 0 ? this.mPresenter.callLogList.length === 0 :
        this.mPresenter.missedList.length === 0) {
        EmptyView({ recordType: this.recordType })
      } else {
        RecordView({ mPresenter: $mPresenter, recordType: this.recordType });
      }
    }
  }
}

@Component
struct RecordView {
  @Link private mPresenter: any
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  recordType: number = 0;

  build() {
    List({ space: 0, initialIndex: 0 }) {
      LazyForEach(this.recordType === 0 ? this.mPresenter.mAllCallRecordListDataSource :
      this.mPresenter.mMissCallRecordListDataSource, (item, index: number) => {
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
    .width("100%")
    .margin({ bottom: this.curBp === 'lg' ? '110vp' : 0 })
    .flexShrink(1)
    .listDirection(Axis.Vertical)
    .edgeEffect(EdgeEffect.Spring)
  }
}


@Component
struct EmptyView {
  recordType: number = 0;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    Column() {
      Image($r('app.media.no_call_records'))
        .objectFit(ImageFit.Contain)
        .width($r("app.float.id_card_image_large"))
        .height($r("app.float.id_card_image_large"))
        .margin({ bottom: $r("app.float.id_card_margin_large") })
      Text(this.recordType === 0 ? $r("app.string.no_dialer_calllog") :
      $r("app.string.no_dialer_missed_calllog"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .markAnchor({ x: 0, y: this.curBp === 'lg' ? 60 : 110})
  }
}

enum MenuType {
  sendMessage, Copy, EditBeforeCall, BlockList, DeleteCallLogs
}

@Component
struct ContactItem {
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @Link mPresenter: CallRecordPresenter
  @State item: any = {};
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    Row() {
      Row() {
        Image(this.item.callType == 2 ?
        $r('app.media.ic_contacts_Dialled') :
            this.item.callType == 5 ?
          $r('app.media.ic_contacts_Reject') : "")
          .height($r("app.float.dialer_common_small_margin"))
          .width($r("app.float.dialer_common_small_margin"))
          .margin({
            right: $r("app.float.id_card_margin_xl"),
            top: "13vp",
            left: $r("app.float.id_card_margin_xl"),
            bottom: "35vp"
          })

        Column() {
          Row() {
            Text(this.item.displayName ?
            this.item.displayName : this.item.phoneNumber)
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .fontWeight(FontWeight.Medium)
              .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
              $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_primary'))
              .constraintSize({ maxWidth: '260vp' })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(2)

            if (this.item.count != 1) {
              Text('(' + this.item.count + ')')
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .fontColor((this.item.callType == 3 || this.item.callType == 5) ?
                $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .padding({ left: $r("app.float.id_card_margin_large"), right: $r("app.float.id_card_margin_large") })
                .maxLines(1)
            }
          }

          Text(this.item.numberLocation
            ? this.item.numberLocation
            : $r("app.string.unknown"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .margin({ top: $r("app.float.id_card_margin_mid") })

        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .height($r("app.float.id_item_height_max"))
      }

      Row() {
        Text(this.item.createTime)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .margin({ right: this.curBp === 'lg' ? '6vp' : $r("app.float.id_card_margin_xl"),
                    top: $r("app.float.id_card_margin_sm") })
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .width('90vp')
          .textAlign(TextAlign.End)
        Image($r('app.media.ic_public_detail'))
          .height($r("app.float.id_card_margin_max"))
          .width($r("app.float.id_card_margin_max"))
          .margin({ top: $r("app.float.id_card_margin_sm"), right: 24 })
          .onClick(() => {
            this.mPresenter.jumpToContactDetail(this.item.phoneNumber);
          })
      }
      .justifyContent(FlexAlign.End)
      .height($r("app.float.id_item_height_max"))
    }
    .justifyContent(FlexAlign.SpaceBetween)
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
          .height($r("app.float.id_item_height_max"))
      }

      this.MenuDivider()
      this.MenuView($r("app.string.send_message"), MenuType.sendMessage)
      this.MenuDivider()
      this.MenuView($r("app.string.copy_phoneNumber"), MenuType.Copy)
      this.MenuDivider()
      this.MenuView($r("app.string.edit_beforeCall"), MenuType.EditBeforeCall)
      this.MenuDivider()
      this.MenuView($r("app.string.add_to_blockList"), MenuType.BlockList)
      this.MenuDivider()
      this.MenuView($r("app.string.delete_call_logs"), MenuType.DeleteCallLogs)
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r("app.float.id_card_margin_xxl"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
  }

  @Builder MenuView(menuName, itemType) {
    Row() {
      Text(menuName)
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({ left: $r("app.float.id_card_margin_xxl") })
        .textAlign(TextAlign.Start)
    }
    .height($r("app.float.id_item_height_mid"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
    .onClick(() => {
      switch (itemType) {
        case MenuType.DeleteCallLogs:
          this.mPresenter.deleteCallLog(this.item.ids);
          break;
        case MenuType.EditBeforeCall:
          this.mIndexPresenter.editBeforeCall(this.item.phoneNumber);
          break;
        case MenuType.sendMessage:
          let formatnum = PhoneNumber.fromString(this.item.phoneNumber).format();
          DetailPresenter.getInstance()
            .sendMessage(this.item.phoneNumber, formatnum,
              this.item.displayName ? this.item.displayName : this.item.phoneNumber);
          break;
      }
    })
  }

  @Builder MenuDivider() {
    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .lineCap(LineCapStyle.Square)
      .width('100%')
      .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
  }
}