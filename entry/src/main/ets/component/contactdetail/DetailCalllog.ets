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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import EnvironmentProp from '../../feature/EnvironmentProp';

const TAG = "ContactDetail-calllog";

/**
 * Call log
 */
@Component
export default struct CallLogListItem {
  @State message: { [key: string]: any } = {};
  @State isEmergencyNum: boolean = false;
  private imgRes: Resource;
  @StorageLink("haveMultiSimCard") haveMultiSimCard: boolean = false;
  @StorageLink("haveSimCard") haveSimCard: boolean = false;
  @Link private mPresenter: { [key: string]: any };
  private simImgRes: Resource = $r('app.media.stat_sys_sim1');

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
    if (this.haveMultiSimCard) {
      if (this.message.simId == 0) {
        this.simImgRes = $r('app.media.stat_sys_sim1')
      } else {
        this.simImgRes = $r('app.media.stat_sys_sim2')
      }
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
          Image(this.simImgRes)
            .objectFit(ImageFit.Fill)
            .width($r("app.float.id_card_image_xs"))
            .height($r("app.float.id_card_image_xs"))
            .opacity(0.4)
            .visibility(this.haveMultiSimCard ? Visibility.Visible : Visibility.None)
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
      .margin({ right: $r("app.float.id_card_margin_max") })
      .height("19vp")
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .padding({ top: 5, bottom: 5 })
    .onClick(() => {
      HiLog.i(TAG, "CallLogListItem onClick:" + JSON.stringify(this.message))
      if (this.haveMultiSimCard) {
        PhoneNumber.fromString(this.message.formatNumber).dial({
          accountId: this.message.simId,
        });
      } else {
        if (!this.haveSimCard) {
          HiLog.i(TAG, "No SIM card!");
          //TODO Pop-up window for dialing without a SIM card
          PhoneNumber.fromString(this.message.formatNumber).isDialEmergencyNum().then((res) => {
            this.isEmergencyNum = res;
            if (!this.isEmergencyNum) {
              HiLog.i(TAG, "Is not Emergency Phone Number!");
              return;
            } else {
              HiLog.i(TAG, "No SIM card, but is Emergency Phone Number");
              PhoneNumber.fromString(this.message.formatNumber).dial();
            }
          })
        } else {
          PhoneNumber.fromString(this.message.formatNumber).dial();
        }
      }
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}
