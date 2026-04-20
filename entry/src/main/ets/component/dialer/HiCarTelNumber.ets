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

import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import DialerConstant from '../../data/DialerConstant';
import { HiCarConstants } from '../../data/HiCarConstants';
import { Constants } from '../../data/Constants';
import { TelNumberModel } from '../../model/TelNumberModel';

const TAG = 'HiCarTelNumber';

@Component
export struct HiCarTelNumber {
  private readonly MAX_FONT_SIZE = 30;
  private readonly MIN_FONT_SIZE = 24;
  private textInputController: TextInputController = new TextInputController();
  private telNumberModel: TelNumberModel = new TelNumberModel();
  @StorageProp(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) @Watch('telNumberChange') telNumberWithSpace: string = '';
  @StorageProp(HiCarConstants.KEY_IS_IN_HICAR) isInHiCar: boolean = false;
  @StorageProp(Constants.KEY_IS_PASTE_SHOW_CURSOR) isPasteShowCursor: boolean = false;
  @State textInputFocusable: boolean = false;
  @State telNumSize: number = this.MAX_FONT_SIZE;

  private telNumberChange(): void {
    const newTelNumSize = this.telNumberModel.telNumberChange(this.MAX_FONT_SIZE, this.MIN_FONT_SIZE,
      this.telNumberWithSpace);
    if (this.telNumSize != newTelNumSize) {
      this.telNumSize = newTelNumSize;
    }
  }

  @Builder
  CustomKeyboardBuilder() {
    Column() {
    }
  }

  build() {
    Row() {
      TextInput({
        text: this.telNumberWithSpace,
        controller: DialerPresenter.getInstance().textController
      })
        .id('hicar_dialer_contacts_telNumberInput_textInput')
        .fontSize(`${this.telNumSize}vp`)
        .showUnderline(true)
        .underlineColor($r('app.color.skin_ohos_id_color_background'))
        .key('hiCarTelNumberInput')
        .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .backgroundColor($r('app.color.skin_background_primary'))
        .enableKeyboardOnFocus(false)
        .customKeyboard(this.CustomKeyboardBuilder())
        .focusable(this.textInputFocusable)
        .onTextSelectionChange((selectStart: number, selectEnd: number) => {
          HiLog.d(TAG, `selectStart: ${selectStart}, selectEnd: ${selectEnd}`)
          DialerPresenter.getInstance().setTextSelectStatus(selectStart, selectEnd);
        })
        .onChange((value: string) => {
          HiLog.d(TAG, `hicar_dialer_contacts_telNumberInput_textInput onchange value length: ${value.length}`);
          focusControl.requestFocus('hiCarTelNumberInput');
          this.textInputFocusable = this.telNumberModel.setCursor(value, this.isPasteShowCursor,
            this.textInputController, this.textInputFocusable, this.telNumberWithSpace);
        })
        .onCut((value: string) => {
          AppStorage.setOrCreate(Constants.KEY_IS_DIALER_INPUT_CUT, true);
        })
        .onPaste((value: string, event?: PasteEvent) => {
          this.telNumberModel.paste(value, this.telNumberWithSpace, event);
        })
        .onTouch(() => {
          this.textInputFocusable = true;
        })
    }
    .width('100%')
  }
}