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

import { HiLog } from '../../../../../../common'
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import HiCarUtil from '../../util/HiCarUtil';
import { HiCarConstants } from '../../data/HiCarConstants';
import { Constants } from '../../data/Constants';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { simId_DEFAULT } from '../../feature/sim/SimCardState';

const TAG = 'DialerButtonViewHiCar';
const CALL_EVENT = 'CALL_EVENT';

@Component
export struct DialerButtonViewHiCar {
  private static TAB_WIDTH = 88;
  private static DIAL_BUTTON_MARGIN_MINIMUM = 24;
  private static DIAL_BUTTON_WIDTH = 116;
  private static CARD_MARGIN = 8;
  private static MARGIN_24 = 24;
  private dailImg = [$r('sys.symbol.phone_badge_1_fill'), $r('sys.symbol.phone_badge_2_fill')];
  @StorageLink(Constants.KEY_SPN_LIST) simNames: Array<string | Resource> = ['', ''];
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;

  /**
   * 点击拨号按钮，拨打电话
   **/
  private dialClick(slot?: number): void {
    //按钮打点
    const callParams: CustomizedParams = {
      ENC: HiCarConstants.CONTACT_DOT_ENC_DIALING,
      SLOT: slot !== undefined ? slot : 0,
      ISMULTISIMCARD: Number(this.haveMultiSimCard)
    };
    DotUtil.getInstance().contactDot(callParams, CALL_EVENT);
    DialerPresenter.getInstance().dialClick(this.getUIContext(), slot, true);
  }

  /**
   * 打电话按钮在右侧，按钮宽度取安全边距下的宽度与116vp之间的最小值；打电话按钮在下侧，宽度同拨号按钮的宽度
   *
   * @returns 按钮宽度,单位vp
   */
  private getWidthofButton(): number {
    if (HiCarUtil.getInstance().getIsDialButtonOnRight()) {
      const maxWidth = px2vp(HiCarUtil.getInstance().getWindowDisplayAreaWidthPx()) -
        HiCarUtil.getInstance().getDialPadWidth() - DialerButtonViewHiCar.TAB_WIDTH -
        DialerButtonViewHiCar.DIAL_BUTTON_MARGIN_MINIMUM - DialerButtonViewHiCar.CARD_MARGIN -
        DialerButtonViewHiCar.MARGIN_24;
      return Math.min(maxWidth, DialerButtonViewHiCar.DIAL_BUTTON_WIDTH);
    }
    return (HiCarUtil.getInstance().getDialPadWidth() - 2 * HiCarConstants.DIAL_BUTTON_MARGIN) / 3;
  }

  @Builder
  simNamesBuilder(item: string | Resource, index: number) {
    Row() {
      Row() {
        SymbolGlyph(this.dailImg[index])
          .fontSize($r('app.float.id_width_16_hicar'))
          .fontColor([$r('app.color.skin_white')])
          .margin({ right: $r('app.float.id_card_margin_mid_hicar') })

        Text(item)
          .fontFamily('HarmonyHeiTi')
          .fontWeight('Medium')
          .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .fontSize($r('sys.float.Body_S'))
          .maxLines(2)
          .constraintSize({ maxWidth: `calc(100% - 20vp)` })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .justifyContent(FlexAlign.Center)
    .borderRadius(this.getWidthofButton() > 40 ? 20 : this.getWidthofButton() / 2)
    .height($r('app.float.id_dial_button_height_hicar'))
    .width(this.getWidthofButton())
    .backgroundColor($r('app.color.skin_confirm'))
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .onClick(() => {
      this.dialClick(index);
    })
  }

  /**
   * 双卡时，拨号按钮组件-拨号按钮在拨号盘的右边
   */
  @Builder
  multiSimCardDialerButtonColumn() {
    Column() {
      ForEach(this.simNames, (item: string | Resource, index: number) => {
        if (index === 1) {
          Column()
            .height($r('app.float.id_width_16_hicar'))
            .width(this.getWidthofButton())
        }
        this.simNamesBuilder(item, index);
      })
    }
  }

  /**
   * 双卡时，拨号按钮组件-拨号按钮在拨号盘的下方
   */
  @Builder
  multiSimCardDialerButtonRow() {
    Row() {
      ForEach(this.simNames, (item: string | Resource, index: number) => {
        if (index === 1) {
          Row()
            .height($r('app.float.id_dial_button_height_hicar'))
            .width($r('app.float.id_margin_4_hicar'))
        }
        this.simNamesBuilder(item, index);
      })
    }
  }

  build() {
    if (!this.haveMultiSimCard || this.defaultSlot !== simId_DEFAULT) {
      //单卡或者设置默认拨号卡
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.phone_fill'))
          .fontSize($r('app.float.id_dial_button_image_hicar'))
          .fontColor([$r('app.color.skin_white')])
      }
      .width($r('app.float.id_dial_button_hicar'))
      .height($r('app.float.id_dial_button_hicar'))
      .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
      .onClick(() => {
        this.dialClick();
      })
    } else {
      if (HiCarUtil.getInstance().getIsDialButtonOnRight()) {
        this.multiSimCardDialerButtonColumn()
      } else {
        this.multiSimCardDialerButtonRow()
      }
    }
  }
}