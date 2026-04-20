/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { DialerButtonViewHiCar } from '../../component/dialer/HiCarDialerButtonView';
import { HicarDialPad } from '../../component/dialer/HiCarDialPad';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import DialerConstant from '../../data/DialerConstant';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { HiCarTelNumber } from '../../component/dialer/HiCarTelNumber';
import HiCarUtil from '../../util/HiCarUtil';
import { Constants } from '../../data/Constants';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { simId_DEFAULT } from '../../feature/sim/SimCardState';

const TAG = 'HiCarDialerPage';
const DELETE_NUM_EVENT = 'DELETE_NUM_EVENT';

@Component
export default struct HiCarDialerPage {
  private static readonly DELETE_BUTTON_PRESS_DURATION: number = 700;
  private customizedParams: CustomizedParams = {};
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';

  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarDialerPage aboutToAppear.');
    DialerPresenter.getInstance().aboutToAppear();
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'HiCarDialerPage aboutToDisappear.');
    DialerPresenter.getInstance().aboutToDisappear();
  }

  private deleteNumber(): void {
    let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
      AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
    number = DialerPresenter.getInstance().deleteStr(number);
    AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number)
  }

  @Builder
  DeleteButton() {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r('sys.symbol.delete_left_fill'))
        .fontSize($r('app.float.id_width_24_hicar'))
        .fontColor([$r('app.color.skin_ohos_id_color_primary')])
    }
    .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
    .width($r('app.float.id_width_48_hicar'))
    .height($r('app.float.id_width_48_hicar'))
    .gesture(
      LongPressGesture({ duration: HiCarDialerPage.DELETE_BUTTON_PRESS_DURATION })
        .onAction(() => {
          DialerPresenter.getInstance().resetTelNumber();
          DialerPresenter.getInstance().editPhoneNumber('');
        })
    )
    .onClick(() => {
      this.deleteNumber();
      DotUtil.getInstance().contactDot(this.customizedParams, DELETE_NUM_EVENT);
    })
    .id('hicar_dialer_contacts_delete_btn')
  }

  @Builder
  NumberDisplay() {
    if (this.telNumberWithSpace.length > 0) {
      Row() {
        Column() {
          HiCarTelNumber()
        }
        .layoutWeight(1)
        .margin({ right: $r('app.float.id_width_16_hicar') })

        this.DeleteButton()
      }
      .width(HiCarUtil.getInstance().getDialPadWidth())
    } else {
      Row() {
        HiCarTelNumber()
      }
      .width(HiCarUtil.getInstance().getDialPadWidth())
    }
  }

  build() {
    if (HiCarUtil.getInstance().getIsDialButtonOnRight()) {
      Column() {
        Column() {
          Column() {
            this.NumberDisplay()
          }
          .height('30%')
          .justifyContent(FlexAlign.End)

          Column() {
            Row() {
              HicarDialPad()

              DialerButtonViewHiCar()
                .margin({
                  left: this.haveMultiSimCard && this.defaultSlot === simId_DEFAULT ? $r('app.float.id_margin_8_hicar') : $r('app.float.id_margin_24_hicar')
                })
            }
          }
          .height('70%')
          .justifyContent(FlexAlign.Center)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
    } else {
      Column() {
        this.NumberDisplay()

        HicarDialPad()
          .margin({ top: $r('app.float.id_margin_8_hicar'), bottom: $r('app.float.id_margin_8_hicar') })

        DialerButtonViewHiCar()
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
  }
}




