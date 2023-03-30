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

import { StringUtil, HiLog } from '../../../../../../common';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import DetailInfoList from './DetailInfoList';
import call from '@ohos.telephony.call';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { DataItemType } from '../../../../../../feature/contact/src/main/ets/contract/DataType';
import IndexPresenter from '../../presenter/IndexPresenter';
import { SelectDialogBuilder } from '../mutisim/SelectSimIdDialog';

const TAG = "ContactDetail-detailInfoList";

enum MenuType {
  Copy, EditBeforeCall
}

@Component
export default struct DetailInfoListView {
  @Link mPresenter: { [key: string]: any };
  @Link selectSimBuilder: SelectDialogBuilder;

  build() {
    Column() {
      //Phone List
      TelList({
        List: JSON.stringify(this.mPresenter.contactForm.phones),
        mPresenter: $mPresenter,
        selectSimBuilder: $selectSimBuilder
      });

      // email list
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.emails),
        hasArrow: true,
        dataType: DataItemType.EMAIL
      });

      // aim List
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.aims),
        hasArrow: true,
        dataType: DataItemType.IM
      });

      // Nickname
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.nickname),
        hasArrow: false,
        dataType: DataItemType.NICKNAME
      });

      // Websites
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.websites),
        hasArrow: true,
        dataType: DataItemType.WEBSITE
      });

      // residential address
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.houses),
        hasArrow: false,
        dataType: DataItemType.SIP_ADDRESS
      });

      // Remembrance Day
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.events),
        hasArrow: true,
        dataType: DataItemType.EVENT
      });

      // Associated Person
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.relationships),
        hasArrow: true,
        dataType: DataItemType.RELATION
      });

      // Remarks
      DetailInfoList({
        List: JSON.stringify(this.mPresenter.contactForm.remarks),
        hasArrow: false,
        dataType: DataItemType.NOTE
      });
    }
    .margin({ top: $r("app.float.id_card_margin_max") })
  }
}

/**
 * Phone List
 */
@Component
struct TelList {
  @State List: string = '';
  @Link private mPresenter: { [key: string]: any };
  @Link selectSimBuilder: SelectDialogBuilder;

  build() {
    if (!ArrayUtil.isEmpty(JSON.parse(this.List))) {
      List() {
        ForEach(JSON.parse(this.List), item => {
          ListItem() {
            TelListItem({
              message: JSON.stringify(item),
              mPresenter: $mPresenter,
              selectSimBuilder: $selectSimBuilder
            });
          }
        }, item => JSON.stringify(item))
      }
      .divider({ strokeWidth: $r("app.float.id_divide_width"), color: $r("sys.color.ohos_id_color_list_separator") })
      .backgroundColor(Color.White)
    }
  }
}

/**
 * Phone Item
 */
@Component
struct TelListItem {
  @Prop private message: string;
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @State isEmergencyNum: boolean = false;
  @StorageLink("haveSimCard") haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @Link private mPresenter: { [key: string]: any };
  @Link selectSimBuilder: SelectDialogBuilder;

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start }) {
      Text(JSON.parse(this.message).data)
        .fontSize($r("sys.float.ohos_id_text_size_headline8"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .textAlign(TextAlign.Start)
        .lineHeight('28vp')
        .height($r("app.float.id_item_height_max"))

      this.MenuDivider()
      this.MenuView($r("app.string.copy_phoneNumber"), MenuType.Copy)
      this.MenuDivider()
      this.MenuView($r("app.string.edit_beforeCall"), MenuType.EditBeforeCall)
    }
    .padding({ left: $r("app.float.id_card_margin_large"), right: $r("app.float.id_card_margin_large") })
    .width(144)
    .borderRadius($r("app.float.id_card_margin_xxl"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
  }

  @Builder MenuView(menuName, itemType) {
    Row() {
      Text(menuName)
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .textAlign(TextAlign.Start)
    }
    .width("100%")
    .padding({ left: $r("app.float.id_card_margin_large"), right: $r("app.float.id_card_margin_large") })
    .height($r("app.float.id_item_height_mid"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
    .onClick(() => {
      switch (itemType) {
        case MenuType.Copy:
          this.mIndexPresenter.getCopy(JSON.parse(this.message).data);
          break;
        case MenuType.EditBeforeCall:
          AppStorage.SetOrCreate("isRouterBack", true);
          DialerPresenter.getInstance().editPhoneNumber(JSON.parse(this.message).data);
          AppStorage.SetOrCreate<boolean>("showDialBtn", true);
          break;
      }
    })
  }

  @Builder MenuDivider() {
    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .lineCap(LineCapStyle.Square)
      .width('100%')
      .padding({ left: $r("app.float.id_card_margin_large"), right: $r("app.float.id_card_margin_large") })
  }

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(PhoneNumber.fromString(JSON.parse(this.message).data).format())
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
        Row() {
          Text(JSON.parse(this.message).labelName)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontWeight(FontWeight.Regular)
            .visibility(StringUtil.isEmpty(JSON.parse(this.message).labelName) ? Visibility.None : Visibility.Visible)
          Text(" - ")
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontWeight(FontWeight.Regular)
            .visibility(StringUtil.isEmpty(
            JSON.parse(this.message)
              .phoneAddress) ? Visibility.None : Visibility.Visible)
          Text(JSON.parse(this.message).phoneAddress)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontWeight(FontWeight.Regular)
        }
        .margin({ top: $r("app.float.id_card_margin_sm") })
      }
      .flexShrink(1)

      Row() {
        if (call.hasVoiceCapability()) {
          Button({ stateEffect: false }) {
            if (!EnvironmentProp.isTablet()) {
              Image($r("app.media.ic_public_phone"))
                .objectFit(ImageFit.Contain)
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
                .fillColor(this.haveSimCard ? $r('sys.color.ohos_id_color_connected')
                                            : $r('sys.color.ohos_id_color_tertiary'))
            } else {
              Image($r("app.media.ic_public_phone_filled"))
                .objectFit(ImageFit.Contain)
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
                .fillColor(this.haveSimCard ? $r('sys.color.ohos_id_color_connected')
                                            : $r('sys.color.ohos_id_color_tertiary'))
            }
          }
          .backgroundColor(Color.White)
          .margin({ right: $r("app.float.id_card_margin_max") })
        }

        Button({ stateEffect: false }) {
          if (!EnvironmentProp.isTablet()) {
            Image($r("app.media.ic_public_message"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
          } else {
            Image($r("app.media.ic_public_message_filled"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
          }
        }
        .backgroundColor(Color.White)
        .onClick(() => {
          this.mPresenter.sendMessage(JSON.parse(this.message).num,
          JSON.parse(this.message).data, this.mPresenter.contactForm.display_name);
        })
      }
      .flexShrink(0)
    }
    .onClick(() => {
      let phoneNum: string = JSON.parse(this.message).num;
      if (!this.haveSimCard) {
        HiLog.i(TAG, "No SIM card!");
        //TODO Pop-up window for dialing without a SIM card
        PhoneNumber.fromString(phoneNum).isDialEmergencyNum().then((res) => {
          this.isEmergencyNum = res;
          if (!this.isEmergencyNum) {
            HiLog.i(TAG, "Is not Emergency Phone Number!");
            return;
          } else {
            HiLog.i(TAG, "No SIM card, but is Emergency Phone Number");
            PhoneNumber.fromString(phoneNum).dial();
          }
        })
      } else if (this.haveMultiSimCard) {
        this.selectSimBuilder.title = $r("app.string.contacts_call_number", phoneNum);
        this.selectSimBuilder.callback = (value) => {
          PhoneNumber.fromString(phoneNum).dial({
            accountId: value,
          });
        }
        this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
        let spnList = AppStorage.Get<Array<string | Resource>>('spnList');
        for (var index = 0; index < spnList.length; index++) {
          this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
        }
        this.selectSimBuilder.controller?.open();
      } else {
        PhoneNumber.fromString(phoneNum).dial();
      }
    })
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress)
  }
}