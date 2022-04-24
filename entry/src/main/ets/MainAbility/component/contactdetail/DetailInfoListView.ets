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

import HiLog from '../../util/HiLog';
import StringUtil from '../../util/StringUtil';
import ArrayUtil from '../../util/ArrayUtil';
import DialUtil from '../../util/DialUtil';
import DetailInfoList from './DetailInfoList';

const TAG = "ContactDetail-detailInfoList";

@Component
export default struct DetailInfoListView {
  @Link mDetailModel: any;

  build() {
    Column() {
      //Phone List
      TelList({ mDetailModel: $mDetailModel });

      // email list
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.emails), hasArrow: true });

      // aim List
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.aims), hasArrow: true });

      // Nickname
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.nickname), hasArrow: false });

      // Websites
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.websites), hasArrow: true });

      // residential address
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.houses), hasArrow: false });

      // Remembrance Day
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.events), hasArrow: true });

      // Associated Person
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.relationships), hasArrow: true });

      // Remarks
      DetailInfoList({ List: JSON.stringify(this.mDetailModel.contactForm.remarks), hasArrow: false });
    }
    .margin({ top: $r("app.float.id_card_margin_max") })
  }
}

/**
 * Phone List
 */
@Component
struct TelList {
  @Link private mDetailModel: any;

  @Builder ListDivider() {
    Divider()
      .color($r("sys.color.ohos_id_color_list_separator"))
  }

  build() {
    List() {
      ForEach(this.mDetailModel.contactForm.phones, (item, index) => {
        ListItem() {
          TelListItem({ message: JSON.stringify(item), mDetailModel: $mDetailModel });
        }

        if (index < this.mDetailModel.contactForm.phones.length - 1) {
          ListItem() {
            this.ListDivider()
          }
        }
      }, item => (item.id).toString())
    }
    .visibility(ArrayUtil.isEmpty(this.mDetailModel.contactForm.phones) ? Visibility.None : Visibility.Visible)
    .backgroundColor(Color.White)
  }
}

/**
 * Phone Item
 */
@Component
struct TelListItem {
  private message: string
  @Link private mDetailModel: any;

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(JSON.parse(this.message).data)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
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
            .visibility(StringUtil.isEmpty(JSON.parse(this.message).labelName) ? Visibility.None : Visibility.Visible)
          Text(JSON.parse(this.message).phoneAddress)
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontWeight(FontWeight.Regular)
        }
        .margin({top: $r("app.float.id_card_margin_sm")})
      }

      Blank();

      Image($r("app.media.ic_public_phone_filled"))
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .margin({ right: $r("app.float.id_card_margin_max") })
        .onClick(() => {
          DialUtil.getInstance().dial(StringUtil.removeSpace(JSON.parse(this.message).data), (data, err, value) => {
            HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
          });
        })

      Image($r("app.media.ic_public_message_filled"))
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .onClick(() => {
          this.mDetailModel.sendMessage(JSON.parse(this.message).data, this.mDetailModel.contactForm.display_name);
        })
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
        this.mDetailModel.listItemOnLongPressNumber(JSON.parse(this.message).id);
      }))
  }
}

/**
 * More options
 */
@Component
struct MoreOptions {
  @Link private mDetailModel: any;

  build() {
    Row() {
      Text($r('app.string.more'))
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .margin({ right: $r("app.float.id_card_margin_max") })
        .fontColor($r('sys.color.ohos_id_color_connected'))

      Image($r('app.media.ic_contacts_details_arrow_down'))
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_xs"))
        .width($r("app.float.id_card_image_small"))
    }
    .height($r("app.float.id_item_height_sm"))
    .visibility(this.mDetailModel.contactForm.showMoreButton ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.mDetailModel.getMore();
    })
  }
}
