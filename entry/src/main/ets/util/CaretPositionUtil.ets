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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import { PhoneNumber } from '../../../../../feature/phonenumber/src/main/ets/PhoneNumber';

const TAG = 'CaretPositionUtil';

const NUM_TEXT_MAXSIZE_LENGTH = 14;

export class CaretPositionUtil {
  public static nextCaret: number = -1; // 用于记录下次光标设置的位置
  public static actualCh: number = -1; // 用于记录光标在第i个数字后插入或者第i个数字前删除

  static processingCaret(
    arg: string,
    focusState: number,
    index: number,
    focusIndex: number,
    checkNeedNumberSpace: boolean,
    mTextInputValue: string,
    teleNumberNoFormatChar: string,
    lastCaretPosition: number,
    lastCaretPositionEnd: number,
    controller: TextInputController): string {
    let nextText: string = '';
    // 未格式化之前的号码大于16或者带有特殊字符或者长度小于等于3的均不格式化
    if (teleNumberNoFormatChar.length > NUM_TEXT_MAXSIZE_LENGTH ||
      !checkNeedNumberSpace || teleNumberNoFormatChar.length <= 3) {
      nextText = teleNumberNoFormatChar;
    } else {
      nextText = new PhoneNumber(teleNumberNoFormatChar).dynamicPhoneFormat();
    }
    //当为编辑和不是编辑当前号码的一行时，不计算光标，只格式化代码
    if (focusState === 0 || index !== focusIndex) {
      return nextText;
    }
    if (mTextInputValue === nextText && nextText === arg) {
      // 此时说明数字已经格式化完成了 在这个时候改变光标位置不会被重置掉
      CaretPositionUtil.setCaret(controller);
    } else {
      CaretPositionUtil.nextCaret = CaretPositionUtil.calcCaretPosition(arg, mTextInputValue,
        teleNumberNoFormatChar, lastCaretPosition, lastCaretPositionEnd, nextText);
    }
    return nextText
  }

  public static setCaret(controller: TextInputController): void {
    if (CaretPositionUtil.nextCaret != -1) {
      controller.caretPosition(CaretPositionUtil.nextCaret);
      CaretPositionUtil.nextCaret = -1;
    }
  }

  private static calcCaretPosition(
    arg: string,
    mTextInputValue: string,
    teleNumberNoFormatChar: string,
    lastCaretPosition: number,
    lastCaretPositionEnd: number,
    nextText: string): number {
    //当输入值和文本框值相等时，相当于未修改，返回之前计算的光标位置
    if (arg === mTextInputValue) {
      return CaretPositionUtil.nextCaret;
    }
    let befNumberNoSpace: string = StringUtil.removeFormatChar(mTextInputValue);
    CaretPositionUtil.actualCh = 0;
    let nextCaret: number = -1;
    if (befNumberNoSpace.length < teleNumberNoFormatChar.length) { // 插入场景
      let lastCaretPositionStr: string = mTextInputValue.substring(0, lastCaretPosition);
      lastCaretPositionStr = StringUtil.removeFormatChar(lastCaretPositionStr);
      CaretPositionUtil.actualCh =
        lastCaretPositionStr.length + teleNumberNoFormatChar.length - befNumberNoSpace.length;
      for (let i = 0; i < nextText.length; i++) {
        if (!StringUtil.hasFormatChar(nextText[i])) {
          CaretPositionUtil.actualCh -= 1;
          if (CaretPositionUtil.actualCh <= 0) {
            nextCaret = i + 1;
            break;
          }
        }
      }
    } else if (befNumberNoSpace.length > teleNumberNoFormatChar.length) { // 删除场景
      if (lastCaretPosition === mTextInputValue.length) {
        HiLog.i(TAG, 'Caret at last, no need to change');
      } else if (lastCaretPosition === lastCaretPositionEnd) {
        // 按键盘上回退键一个一个删的情况
        let lastCaretPositionStr: string = mTextInputValue.substring(lastCaretPosition,
          mTextInputValue.length);
        lastCaretPositionStr = StringUtil.removeFormatChar(lastCaretPositionStr);
        CaretPositionUtil.actualCh = lastCaretPositionStr.length;
        for (let i = nextText.length - 1; i >= 0; i--) {
          if (!StringUtil.hasFormatChar(nextText[i])) {
            CaretPositionUtil.actualCh -= 1;
            if (CaretPositionUtil.actualCh <= 0) {
              nextCaret = i;
              break;
            }
          }
        }
      }
    } else {
      // 剪切/手柄选择 一次删多个字符
      nextCaret = lastCaretPosition; // 保持光标位置
    }
    return nextCaret
  }
}