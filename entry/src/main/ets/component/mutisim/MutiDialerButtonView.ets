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

import DialerPresenter from '../../presenter/dialer/DialerPresenter';

@Component
export struct MutiDialerButtonView {
  @Link mPresenter: DialerPresenter;
  @StorageLink("tele_number") tele_number: string = "";
  @Link simNames: string[];

  build() {
    Row() {
      Button() {
        Row() {
          Image($r("app.media.ic_public_phone1_filled"))
            .width("16vp")
            .height("16vp")
          Text(this.simNames[0])
            .fontColor($r("sys.color.ohos_id_color_primary_contrary"))
            .fontSize("16fp")
        }
      }
      .width('100vp')
      .height("48vp")
      .type(ButtonType.Capsule)
      .backgroundColor($r('sys.color.ohos_id_color_connected'))
      .onClick(() => {
        this.mPresenter.callBtnClick = true;
        if (this.tele_number.length > 0) {
          this.mPresenter.dialing(this.mPresenter.all_number, {
            accountId: 0,
          });
          AppStorage.SetOrCreate("tele_number", '');
          this.mPresenter.all_number = '';
        }
        this.mPresenter.callBtnClick = false;
      })

      Button() {
        Row() {
          Image($r("app.media.ic_public_phone2_filled"))
            .width("16vp")
            .height("16vp")
          Text(this.simNames[1])
            .fontColor($r("sys.color.ohos_id_color_primary_contrary"))
            .fontSize("16fp")
        }
      }
      .width('100vp')
      .height("48vp")
      .type(ButtonType.Capsule)
      .backgroundColor($r('sys.color.ohos_id_color_connected'))
      .onClick(() => {
        this.mPresenter.callBtnClick = true;
        if (this.tele_number.length > 0) {
          this.mPresenter.dialing(this.mPresenter.all_number, {
            accountId: 1,
          });
          AppStorage.SetOrCreate("tele_number", '');
          this.mPresenter.all_number = '';
        }
        this.mPresenter.callBtnClick = false;
      })
    }.width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}