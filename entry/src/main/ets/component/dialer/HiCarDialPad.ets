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

import DialerConstant from '../../data/DialerConstant';
import { HiCarConstants } from '../../data/HiCarConstants';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import HiCarUtil from '../../util/HiCarUtil';

const data = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['*', '0', '#']];

@Component
export struct HicarDialPad {

  private setNumber(number: string): void {
    // numberWithSpace带空格 用于展示
    let numberWithSpace: string = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string;
    const newVal = DialerPresenter.getInstance().getInsertStr(numberWithSpace, number);
    AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newVal);
    DialerPresenter.getInstance().all_number = newVal;
  }

  build() {
    Grid() {
      ForEach(data, (items: string[]) => {
        ForEach(items, (item: string) => {
          GridItem() {
            Button(item)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontSize(HiCarUtil.getInstance().getDialFontSize())
              .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .width(HiCarUtil.getInstance().getButtonWidth())
              .height(HiCarUtil.getInstance().getDialPadButtonHeight())
              .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
              .onClick(() => {
                this.setNumber(item)
              })
          }
        })
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr 1fr')
    .columnsGap(HiCarConstants.DIAL_BUTTON_MARGIN)
    .rowsGap(HiCarConstants.DIAL_BUTTON_MARGIN)
    .width(HiCarUtil.getInstance().getDialPadWidth())
    .height(HiCarUtil.getInstance().getDialPadHeight())
  }
}
