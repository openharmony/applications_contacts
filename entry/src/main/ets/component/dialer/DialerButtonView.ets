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

@Component
export struct DialerButtonView {
  @Link mPresenter: DialerPresenter;
  @StorageLink("tele_number") tele_number: string = "";
  @Link haveSimCard: boolean;
  @Link haveMultiSimCard: boolean;
  @Link simNames: string[];

  build() {
    Row() {
      Button() {
        Image($r("app.media.ic_public_phone_filled_white"))
          .width($r("app.float.id_card_margin_xxxxl"))
          .height($r("app.float.id_card_margin_xxxxl"))
      }
      .width(this.mPresenter.dialerButtonHeight)
      .height(this.mPresenter.dialerButtonHeight)
      .visibility(this.haveMultiSimCard ? Visibility.None : Visibility.Visible)
      .backgroundColor($r('sys.color.ohos_id_color_connected'))
      .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
        ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
      .onClick(() => {
        this.mPresenter.callBtnClick = true;
        if (this.tele_number.length > 0) {
          this.mPresenter.dialing(this.mPresenter.all_number);
          AppStorage.SetOrCreate("tele_number", '');
          this.mPresenter.all_number = '';
        }
        this.mPresenter.callBtnClick = false;
      })

      MutiDialerButtonView({
        mPresenter: $mPresenter,
        simNames: $simNames
      }).height(this.mPresenter.dialerButtonHeight)
        .visibility(this.haveMultiSimCard ? Visibility.Visible : Visibility.None)
    }.width(this.mPresenter.dialerButtonWidth)
    .height(this.mPresenter.dialerButtonHeight)
    .justifyContent(FlexAlign.Center)
  }
}