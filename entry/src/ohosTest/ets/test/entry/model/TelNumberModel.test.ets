/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import { Constants } from '../../../../../main/ets/data/Constants'
import DialerConstant from '../../../../../main/ets/data/DialerConstant'
import { TelNumberModel } from '../../../../../main/ets/model/TelNumberModel'
import DialerPresenter from '../../../../../main/ets/presenter/dialer/DialerPresenter'

export default function TelNumberModelTest() {

  describe('TelNumberModelTest', () => {

    it("telNumberModelTest_telNumberChange", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let maxFontSize: number = 3;
      let minFontSize: number = 1;
      let telNumberWithSpace: string = '13801001234';
      expect(telNumberModel.telNumberChange(maxFontSize, minFontSize, telNumberWithSpace)).assertEqual(3);
    })

    it("telNumberModelTest_telNumberChange_if", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let maxFontSize: number = 3;
      let minFontSize: number = 1;
      let telNumberWithSpace: string = '138010012341111';
      expect(telNumberModel.telNumberChange(maxFontSize, minFontSize, telNumberWithSpace)).assertEqual(2.8);
    })

    it("telNumberModelTest_telNumberChange_if_01", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let maxFontSize: number = 3;
      let minFontSize: number = 3;
      let telNumberWithSpace: string = '138010012341111';
      expect(telNumberModel.telNumberChange(maxFontSize, minFontSize, telNumberWithSpace)).assertEqual(3);
    })

    it("telNumberModelTest_setCursor_01", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let result = telNumberModel.setCursor('13801001234', true, new TextInputController(), false, '138 0100 1234');
      expect(result).assertFalse();
    })

    it("telNumberModelTest_setCursor_02", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let value: string = '13801001234';
      let isPasteShowCursor: boolean = false;
      let textInputFocusable: boolean = true;
      let telNumberWithSpace: string = '138 0100 1234';

      let mocker: MockKit = new MockKit();
      let computeFormatIndex = mocker.mockFunc(DialerPresenter.getInstance(),
        DialerPresenter.getInstance().computeFormatIndex);
      when(computeFormatIndex)(telNumberWithSpace).afterReturn(13);

      let result = telNumberModel.setCursor(value, isPasteShowCursor, new TextInputController(),
        textInputFocusable, telNumberWithSpace);
      expect(result).assertFalse();

      mocker.clear(DialerPresenter.getInstance());
    })

    it("telNumberModelTest_setCursor_03", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let value: string = '13801001234';
      let isPasteShowCursor: boolean = true;
      let textInputFocusable: boolean = true;
      let telNumberWithSpace: string = '138 0100 1234';

      let mocker: MockKit = new MockKit();
      let computeFormatIndex = mocker.mockFunc(DialerPresenter.getInstance(),
        DialerPresenter.getInstance().computeFormatIndex);
      when(computeFormatIndex)(telNumberWithSpace).afterReturn(13);

      let result = telNumberModel.setCursor(value, isPasteShowCursor, new TextInputController(),
        textInputFocusable, telNumberWithSpace);
      expect(result).assertTrue();

      mocker.clear(DialerPresenter.getInstance());
    })

    it("telNumberModelTest_paste", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let telNumberWithSpace: string = '138 0100 1234';
      AppStorage.setOrCreate(Constants.KEY_IS_PASTE_SHOW_CURSOR, false);
      telNumberModel.paste('', telNumberWithSpace, undefined);
      expect(AppStorage.get(Constants.KEY_IS_PASTE_SHOW_CURSOR)).assertFalse();
    })

    it("telNumberModelTest_paste01", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let value: string = '13801001234';
      let telNumberWithSpace: string = '138 0100 1234';
      telNumberModel.paste(value, telNumberWithSpace, undefined);
      expect(AppStorage.get(Constants.KEY_IS_PASTE_SHOW_CURSOR)).assertTrue();
    })

    it("telNumberModelTest_paste02", 0, () => {
      let telNumberModel: TelNumberModel = new TelNumberModel();
      let value: string = '!!!!!';
      let telNumberWithSpace: string = '138 0100 1234';
      AppStorage.setOrCreate(Constants.KEY_IS_PASTE_SHOW_CURSOR, false);
      telNumberModel.paste(value, telNumberWithSpace, undefined);
      expect(AppStorage.get(Constants.KEY_IS_PASTE_SHOW_CURSOR)).assertFalse();
    })
  })
}