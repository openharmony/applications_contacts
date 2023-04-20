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
import EnvironmentProp from '../../../feature/EnvironmentProp';
import DeleteDialogEx from '../../dialog/DeleteDialogEx';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { HiLog } from "../../../../../../../common"

const TAG = "AllRecord ";

@Component
export default struct AllRecord {
  @Link @Watch("onChanged") mPresenter: CallRecordPresenter;
  /*0all 1miss*/
  recordType: number = 0;
  @State callLogListEmpty: boolean = true;
  @State missedListEmpty: boolean = true;

  onChanged() {
    let callLogIsEmpty = this.mPresenter.mAllCallRecordListDataSource.totalCount() <= 0;
    if (this.callLogListEmpty != callLogIsEmpty) {
      this.callLogListEmpty = callLogIsEmpty
    }
    let missLogIsEmpty = this.mPresenter.mMissCallRecordListDataSource.totalCount() <= 0;
    if (this.missedListEmpty != missLogIsEmpty) {
      this.missedListEmpty = missLogIsEmpty
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear,recordType:' + this.recordType)
    this.onChanged();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear,recordType:' + this.recordType)
  }

  build() {
    Stack() {
      if ((this.recordType === 0 ? this.callLogListEmpty : this.missedListEmpty)) {
        EmptyView({ recordType: this.recordType })
      } else {
        RecordView({ mPresenter: $mPresenter, recordType: this.recordType });
      }
    }
  }
}

@Component
struct RecordView {
  @Link private mPresenter: { [key: string]: any }
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  recordType: number = 0;

  build() {
    List({ space: 0, initialIndex: 0 }) {
      LazyForEach(this.recordType === 0 ? this.mPresenter.mAllCallRecordListDataSource :
      this.mPresenter.mMissCallRecordListDataSource, (item, index: number) => {
        ListItem() {
          ContactItem({ mPresenter: $mPresenter, item: item, index: index });
        }
        .height($r("app.float.id_item_height_max"))
      }, item => JSON.stringify(item))
    }
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.id_records_divider_max"),
      endMargin: $r("app.float.id_card_margin_max")
    })
    .width("100%")
    .margin({ bottom: this.curBp === 'lg' ? '110vp' : 0 })
    .flexShrink(1)
    .listDirection(Axis.Vertical)
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
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
    .markAnchor({ x: 0, y: this.curBp === 'sm' ? 60 : 110 })
  }
}

enum MenuType {
  sendMessage, Copy, EditBeforeCall, BlockList, DeleteCallLogs
}

@Component
struct ContactItem {
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @Link mPresenter: CallRecordPresenter
  @State item: { [key: string]: any } = {};
  index: number;
  @State isEmergencyNum: boolean = false;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @StorageLink("haveMultiSimCard") haveMultiSimCard: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  deleteDialogController: CustomDialogController = new CustomDialogController({
    //Components shared by the TIP for creating or updating a contact by mistake and the TIP for deleting a contact
    builder: DeleteDialogEx({
      cancel: () => {
        this.deleteDialogController.close();
      },
      confirm: () => {
        this.mPresenter.deleteCallLog(this.item.ids, this.index);
      },
      title: $r("app.string.deleteCallLog_dialog_title"),
      cancalText: $r("app.string.cancel"),
      confrimText: $r("app.string.dialog_delete")
    }),
    autoCancel: true,
    alignment: (EnvironmentProp.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom),
    offset: { dx: 0, dy: -16 }
  });

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
            bottom: "35vp"
          })

        Column() {
          Row() {
            Text(this.item.displayName ?
            this.item.displayName : PhoneNumber.fromString(this.item.phoneNumber).format())
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .fontWeight(FontWeight.Medium)
              .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
              $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_primary'))
              .constraintSize({ maxWidth: this.curBp == "sm" ? 160 : 260 })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)

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

          Row() {
            Image(this.item.simId == 0 ? $r('app.media.stat_sys_sim1') : $r('app.media.stat_sys_sim2'))
              .height($r("app.float.dialer_common_small_margin"))
              .width($r("app.float.dialer_common_small_margin"))
              .margin({
                right: $r("app.float.id_card_margin_mid"),
                top: "4vp",
              }).visibility(this.haveMultiSimCard ? Visibility.Visible : Visibility.None);

            Image($r('app.media.ic_public_contacts_hd'))
              .height($r("app.float.dialer_common_small_margin"))
              .width($r("app.float.dialer_common_small_margin"))
              .onError((event => {
                HiLog.e(TAG, "ic_public_contacts_hd Image onError" + JSON.stringify(event))
              }))
              .margin({
                right: $r("app.float.id_card_margin_mid"),
                top: "4vp",
              })
              .visibility(this.item.isHD ? Visibility.Visible : Visibility.None);

            Text(this.item.numberLocation
              ? this.item.numberLocation
              : $r("app.string.unknown"))
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .margin({ top: $r("app.float.id_card_margin_mid") })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ right: $r("app.float.id_card_margin_xl") })
        .justifyContent(FlexAlign.Center)
        .height($r("app.float.id_item_height_max"))

        Row() {
          Text(this.item.createTime)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .margin({ right: this.curBp === 'lg' ? '6vp' : $r("app.float.id_card_margin_xl"),
              top: $r("app.float.id_card_margin_sm") })
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .textAlign(TextAlign.End)
          Image($r('app.media.ic_public_detail'))
            .height($r("app.float.id_card_margin_max"))
            .width($r("app.float.id_card_margin_max"))
            .margin({ top: $r("app.float.id_card_margin_sm"), right: 24 })
            .onClick(() => {
              this.mPresenter.jumpToContactDetail(this.item.phoneNumber);
              DialerPresenter.getInstance().panelShow = true;
              AppStorage.SetOrCreate<boolean>("showDialBtn", true);
            })
        }
        .height($r("app.float.id_item_height_max"))
        .margin({ right: 24 })
      }
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .margin({ left: 24 })
    .onClick((event: ClickEvent) => {
      if (!this.haveSimCard) {
        HiLog.i(TAG, "No SIM card!");
        //TODO Pop-up window for dialing without a SIM card
        PhoneNumber.fromString(this.item.phoneNumber).isDialEmergencyNum().then((res) => {
          this.isEmergencyNum = res;
          if (!this.isEmergencyNum) {
            HiLog.i(TAG, "Is not Emergency Phone Number!");
            return;
          } else {
            HiLog.i(TAG, "No SIM card, but is Emergency Phone Number");
            this.mPresenter.dialing(this.item.phoneNumber);
          }
        })
      } else {
        if (this.haveMultiSimCard) {
          DialerPresenter.getInstance().editPhoneNumber(this.item.phoneNumber);
          AppStorage.SetOrCreate<boolean>("showDialBtn", true);
        } else {
          this.mPresenter.dialing(this.item.phoneNumber);
        }
      }
      DialerPresenter.getInstance().panelShow = true;
      AppStorage.SetOrCreate<boolean>("showDialBtn", true);
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
          .margin({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
          .textAlign(TextAlign.Start)
          .lineHeight('28vp')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .height($r("app.float.id_item_height_max"))
      }

      this.MenuView($r("app.string.send_message"), MenuType.sendMessage)
      this.MenuDivider()
      this.MenuView($r("app.string.copy_phoneNumber"), MenuType.Copy)
      this.MenuDivider()
      this.MenuView($r("app.string.edit_beforeCall"), MenuType.EditBeforeCall)
      this.MenuDivider()
      this.MenuView($r("app.string.delete_call_logs"), MenuType.DeleteCallLogs)
    }
    .width("150vp")
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
    .width("100%")
    .height($r("app.float.id_item_height_mid"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
    .onClick(() => {
      switch (itemType) {
        case MenuType.DeleteCallLogs:
          this.deleteDialogController.open();
          break;
        case MenuType.EditBeforeCall:
          DialerPresenter.getInstance().isClickDelete = false;
          DialerPresenter.getInstance().editPhoneNumber(this.item.phoneNumber);
          AppStorage.SetOrCreate<boolean>("showDialBtn", true);
          break;
        case MenuType.sendMessage:
          let formatnum = PhoneNumber.fromString(this.item.phoneNumber).format();
          DetailPresenter.getInstance()
            .sendMessage(this.item.phoneNumber, formatnum,
              this.item.displayName ? this.item.displayName : this.item.phoneNumber);
          break;
        case MenuType.Copy:
          this.mIndexPresenter.getCopy(this.item.phoneNumber);
          break;
      }
    })
  }

  @Builder MenuDivider() {
    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_xxl") })
  }
}