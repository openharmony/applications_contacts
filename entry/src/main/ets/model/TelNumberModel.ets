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

import { Constants } from '../data/Constants';
import DialerConstant from '../data/DialerConstant';
import DialerPresenter from '../presenter/dialer/DialerPresenter';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';

const TAG = 'TelNumberModel';
const NUM_TEXT_MAXSIZE_LENGTH = 14;

export class TelNumberModel {
  // Sets the position of the cursor.
  public setCursor(value: string, isPasteShowCursor: boolean, textInputController: TextInputController,
                   textInputFocusable: boolean, telNumberWithSpace: string): boolean {
    DialerPresenter.getInstance().handleInputChange(value.replaceAll('-',''));
    let initIndex = DialerPresenter.getInstance()
      .computeFormatIndex(telNumberWithSpace, DialerPresenter.getInstance().afterActionCaret[0]);
    HiLog.w(TAG, `initIndex: ${initIndex}, telNumberWithSpace: ${telNumberWithSpace?.length} `);
    if (initIndex === telNumberWithSpace.length) {
      HiLog.w(TAG, `isShowCursor: ${isPasteShowCursor}`);
      if (!isPasteShowCursor && !DialerPresenter.getInstance().isKeyboardInput) {
        textInputController.stopEditing();
        textInputFocusable = false;
      }
      DialerPresenter.getInstance().setTextSelectStatus(telNumberWithSpace.length, telNumberWithSpace.length);
    }
    return textInputFocusable;
  }

  /**
   *处理粘贴逻辑
   */
  public paste(value: string, telNumberWithSpace: string, event?: PasteEvent): void {
    // 先判断粘贴过来的数据合法性
    HiLog.i(TAG, `paste value length: ${value?.length}`);
    if (StringUtil.isEmpty(value)) {
      return;
    }
    // Replace illegal symbols
    const filterResult = value.replace(new RegExp('[^0-9*#＊＃+\\-,;]', 'g'), '')
      .replace(new RegExp('[＊]', 'g'), '*')
      .replace(new RegExp('[＃]', 'g'), '#');
    if (StringUtil.isEmpty(filterResult)) {
      if (event != undefined && event.preventDefault) {
        HiLog.i(TAG, 'paste filter result is null,Prevent System Default Paste');
        // 阻止系统默认粘贴
        event.preventDefault();
      }
      return;
    }
    // Replace the selected content in the text box.
    let result: string = DialerPresenter.getInstance().replaceSelectedStr(telNumberWithSpace, filterResult);
    // 用于格式化显示
    AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, result);
    // Paste function cursor keeps appearing
    AppStorage.setOrCreate(Constants.KEY_IS_PASTE_SHOW_CURSOR, true);
  }

  /**
   * 电话号码fonSize变化逻辑
   *
   * @param maxFontSize-fonSize最大值
   * @param minFontSize-fonSize最小值
   * @param telNumberWithSpace-输入的电话号码
   * @returns 电话号码fonSize
   */
  public telNumberChange(maxFontSize: number, minFontSize: number, telNumberWithSpace: string): number {
    let numLength: number = telNumberWithSpace.length;
    let newTelNumSize = maxFontSize;
    if (numLength > NUM_TEXT_MAXSIZE_LENGTH) {
      newTelNumSize = maxFontSize * NUM_TEXT_MAXSIZE_LENGTH / numLength;
      if (newTelNumSize < minFontSize) {
        newTelNumSize = minFontSize;
      }
    }
    return newTelNumSize;
  }
}


