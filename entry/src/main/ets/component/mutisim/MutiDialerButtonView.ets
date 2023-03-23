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
import { HiLog } from "../../../../../../common"

const TAG = "MutiDialerButtonView";

@Component
export struct MutiDialerButtonView {
  @Link mPresenter: DialerPresenter;
  @StorageLink("tele_number") tele_number: string = "";
  @StorageLink("spnList") simNames: Array<string | Resource> = ["", ""];
  @StorageLink("voLteRegStates") voLteRegStates: boolean[] = [false, false];
  private dailImg = [$r("app.media.ic_public_phone1_filled"), $r("app.media.ic_public_phone2_filled")]

  dialClick(slot: number) {
    this.mPresenter.callBtnClick = true;
    if (this.tele_number.length > 0) {
      this.mPresenter.dialing(this.mPresenter.all_number, {
        accountId: slot,
      });
      AppStorage.SetOrCreate("tele_number", '');
      this.mPresenter.all_number = '';
    }
    this.mPresenter.callBtnClick = false;
  }

  build() {
    Row() {
      ForEach(this.simNames, (item, index) => {
        //DailButton for voLte
        Row() {
          Column() {
            Image(this.dailImg[index])
              .width(this.voLteRegStates[index] ? "14vp" : "18vp")
              .height(this.voLteRegStates[index] ? "14vp" : "18vp")
              .onError((event => {
                HiLog.e(TAG, "Sim:" + index + " Image onError" + JSON.stringify(event))
              }))
            Image($r('app.media.ic_dail_button_volte'))
              .onError((event => {
                HiLog.e(TAG, "ic_dail_button_volte Image onError" + JSON.stringify(event))
              }))
              .height('10vp')
              .width('16vp')
              .visibility(this.voLteRegStates[index] ? Visibility.Visible : Visibility.None)
          }.width("18vp")
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Text(this.simNames[index])
            .fontColor($r("sys.color.ohos_id_color_primary_contrary"))
            .fontSize("16fp")
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100vp')
        .height("48vp")
        .backgroundColor($r('sys.color.ohos_id_color_connected'))
        .onClick(() => {
          this.dialClick(index);
        })
        .borderRadius('24vp')
      })
    }.width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}