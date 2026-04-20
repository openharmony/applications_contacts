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

import { describe, it, expect, MockKit } from '@ohos/hypium';
import { CaretPositionUtil } from '../../../../../main/ets/util/CaretPositionUtil';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';

export default function CaretPositionUtilTest() {
  describe('CaretPositionUtilTest', () => {

    it('CaretPositionUtilTest_processingCaret', 0, () => {
        let controller = new TextInputController();
        let text ='123-456-7890';
        let focusState = 0;
        let index = 0;
        let focusIndex = 0;
        let checkNeedNumberSpace = true;
        let mTextInputValue = '';
        let teleNumberNoSpace ='123-456-7890';
        let lastCaretPosition = 0;
        let lastCaretPositionEnd = text.length;
        let nextText ='123-456-7890';
        let result = CaretPositionUtil.processingCaret(text, focusState, index, focusIndex, checkNeedNumberSpace,
          mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(result).assertEqual(nextText)

    });
    it('CaretPositionUtilTest_processingCaret_002', 0, () => {
      let controller = new TextInputController();
      let text ='123-456-7890';
      let focusState = 0;
      let index = 0;
      let focusIndex = 0;
      let checkNeedNumberSpace = false;
      let mTextInputValue = '';
      let teleNumberNoSpace = '123-456-7890';
      let lastCaretPosition = 0;
      let lastCaretPositionEnd = text.length;
      let nextText ='123-456-7890';
      let result = CaretPositionUtil.processingCaret(text, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
        expect(result).assertEqual(teleNumberNoSpace);
    });
    it('CaretPositionUtilTest_processingCaret_003', 0, () => {
      let controller = new TextInputController();
      let text ='123-456-7890';
      let focusState = 0;
      let index = 0;
      let focusIndex = 2;
      let checkNeedNumberSpace = true;
      let mTextInputValue = '';
      let teleNumberNoSpace = '123-456-7890';
      let lastCaretPosition = 0;
      let lastCaretPositionEnd = text.length;
      let nextText = '123-456-7890';
      let result = CaretPositionUtil.processingCaret(text, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(result).assertEqual(nextText);
    });

    it('CaretPositionUtilTest_processingCaret_setCaret', 0, () => {
      let controller = new TextInputController();
      let text ='138-0100-1234';
      let focusState = 1;
      let index = 2;
      let focusIndex = 2;
      let checkNeedNumberSpace = true;
      let mTextInputValue = '138-0100-1234';
      let teleNumberNoSpace = '138-0100-1234';
      let lastCaretPosition = 0;
      let lastCaretPositionEnd = text.length;
      let nextText = '138-0100-1234';
      CaretPositionUtil.nextCaret = 1;
      let result = CaretPositionUtil.processingCaret(text, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(result).assertEqual(nextText);
    });

    it('CaretPositionUtilTest_processingCaret_calcCaretPosition', 0, () => {
      let controller = new TextInputController();
      let text ='138 0100 1234';
      let focusState = 1;
      let index = 2;
      let focusIndex = 2;
      let checkNeedNumberSpace = true;
      let mTextInputValue = '';
      let teleNumberNoSpace = '138 0100 1234';
      let lastCaretPosition = 0;
      let lastCaretPositionEnd = text.length;
      let nextText = ' 138 0100 1234';
      CaretPositionUtil.nextCaret = 1;
      let result = CaretPositionUtil.processingCaret(text, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(StringUtil.removeSpace(result)).assertEqual(StringUtil.removeSpace(nextText));
    });

    it('CaretPositionUtilTest_processingCaret_calcCaretPosition004', 0, () => {
      let controller = new TextInputController();
      let arg ='138 0100 1235';
      let focusState = 1;
      let index = 2;
      let focusIndex = 2;
      let checkNeedNumberSpace = true;
      let mTextInputValue = '138 0100 1235';
      let teleNumberNoSpace = '1380100 1234';
      let lastCaretPosition = arg.length;
      let lastCaretPositionEnd = arg.length;
      CaretPositionUtil.nextCaret = 1;
      let result = CaretPositionUtil.processingCaret(arg, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(result).assertEqual('1380100 1234');
    });

    it('CaretPositionUtilTest_processingCaret_calcCaretPosition_else', 0, () => {
      let controller = new TextInputController();
      let arg ='138 0100 1236';
      let focusState = 1;
      let index = 2;
      let focusIndex = 2;
      let checkNeedNumberSpace = true;
      let mTextInputValue = '138 0100 1235';
      let teleNumberNoSpace = '138 0100 1';
      let lastCaretPosition = arg.length;
      let lastCaretPositionEnd = arg.length;
      CaretPositionUtil.nextCaret = 1;
      let result = CaretPositionUtil.processingCaret(arg, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd, controller);
      expect(result).assertEqual('138 0100 1');

      let lastCaretPositionEnd1 = arg.length + 1;
      CaretPositionUtil.nextCaret = 1;
      let result1 = CaretPositionUtil.processingCaret(arg, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition, lastCaretPositionEnd1, controller);
      expect(result1).assertEqual('138 0100 1');
      let lastCaretPosition2 = arg.length + 1;
      let lastCaretPositionEnd2 = arg.length + 1;
      CaretPositionUtil.nextCaret = 1;
      let result2 = CaretPositionUtil.processingCaret(arg, focusState, index, focusIndex, checkNeedNumberSpace,
        mTextInputValue, teleNumberNoSpace, lastCaretPosition2, lastCaretPositionEnd2, controller);
      expect(result2).assertEqual('138 0100 1');
    });
  })
}

