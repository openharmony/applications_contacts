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

import EnvironmentProp from '../../feature/EnvironmentProp';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { MutiDialerButtonView } from "../mutisim/MutiDialerButtonView"
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'DialerButtonView';
@Component
export struct DialerButtonView {
  emergencyNum: string;
  @Link mPresenter: DialerPresenter;
  @StorageLink("tele_number") tele_number: string = "";
  @StorageLink("haveSimCard") haveSimCard: boolean = false;
  @StorageLink("haveMultiSimCard") haveMultiSimCard: boolean = false;
  @StorageLink("haveVoLteReg") haveVoLteReg: boolean = false;

  dialClick() {
    this.mPresenter.callBtnClick = true;
    if (!this.haveSimCard) {
      HiLog.i(TAG, "No SIM card!");
      this.emergencyNum = this.mPresenter.all_number;
      //TODO Pop-up window for dialing without a SIM card
      PhoneNumber.fromString(this.mPresenter.all_number).isDialEmergencyNum().then((res) => {
        this.mPresenter.isEmergencyNum = res;
        if (!this.mPresenter.isEmergencyNum) {
          HiLog.i(TAG, "Is not Emergency Phone Number!");
          return;
        } else {
          this.mPresenter.dialing(this.emergencyNum);
        }
      })
    } else {
      if (this.tele_number.length > 0) {
        this.mPresenter.dialing(this.mPresenter.all_number);
      }
    }
    AppStorage.SetOrCreate("tele_number", '');
    this.mPresenter.all_number = '';
    this.mPresenter.callBtnClick = false;
  }

  build() {
    Row() {
      if (!this.haveMultiSimCard) {
        if (this.haveSimCard && this.haveVoLteReg) {
          Button() {
            Image($r('app.media.dial_single_button_hd'))
              .width($r("app.float.id_item_height_large"))
              .height($r("app.float.id_item_height_large"))
          }
          .width(this.mPresenter.dialerButtonHeight)
          .height(this.mPresenter.dialerButtonHeight)
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
            ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
          .onClick(() => {
            this.dialClick();
          })
        } else {
          Button() {
            Image($r("app.media.ic_public_phone_filled_white"))
              .width($r("app.float.id_card_margin_xxxxl"))
              .height($r("app.float.id_card_margin_xxxxl"))
          }
          .width(this.mPresenter.dialerButtonHeight)
          .height(this.mPresenter.dialerButtonHeight)
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
            ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
          .onClick(() => {
            this.dialClick();
          })
        }
      } else {
        MutiDialerButtonView({
          mPresenter: $mPresenter,
        }).height(this.mPresenter.dialerButtonHeight)
      }
    }.width(this.mPresenter.dialerButtonWidth)
    .height(this.mPresenter.dialerButtonHeight)
    .justifyContent(FlexAlign.Center)
  }
}