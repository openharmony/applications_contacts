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
import CantactColumnUtils from '../../../../../main/ets/util/CantactColumnUtils'

export default function CantactColumnUtilsTest() {
  describe('CantactColumnUtilsTest', () => {

    it('contentColumnUtilsTest_getInstance', 0, () => {
      let cantactColumnUtils: CantactColumnUtils = CantactColumnUtils.getTestInstance();
      expect(typeof cantactColumnUtils).assertEqual(typeof CantactColumnUtils.getInstance());
    })

    it("contentColumnUtilsTest_updateBreakpoint_xs", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      contentColumnUtils.updateBreakpoint(320);
      expect(AppStorage.get('curBpCard')).assertUndefined();
    })

    it("contentColumnUtilsTest_updateBreakpoint_sm", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(contentColumnUtils, contentColumnUtils.getWindowProperties);
      when(mockFunc)().afterReturn(0);
      contentColumnUtils.updateBreakpoint(1680);
      expect(AppStorage.get('curBpCard')).assertEqual('sm');
      mocker.clear(contentColumnUtils);
    })

    it("contentColumnUtilsTest_updateBreakpoint_md", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      contentColumnUtils.updateBreakpoint(2720);
      expect(AppStorage.get('curBpCard')).assertEqual('sm');
    })

    it("contentColumnUtilsTest_updateBreakpoint_else", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      contentColumnUtils.updateBreakpoint(2770);
      expect(AppStorage.get('curBpCard')).assertEqual('sm');
    })

    it("contentColumnUtilsTest_getDialogGridCount", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      let result = contentColumnUtils.getDialogGridCount('xs', 1);
      expect(result).assertEqual(4);
    })

    it("contentColumnUtilsTest_getDialogGridCount_sm", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      let result = contentColumnUtils.getDialogGridCount('sm', 1);
      expect(result).assertEqual(3);

      let result1 = contentColumnUtils.getDialogGridCount('sm', 0.2);
      expect(result1).assertEqual(4);
    })

    it("contentColumnUtilsTest_getDialogGridCount_md", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      let result = contentColumnUtils.getDialogGridCount('md', 1);
      expect(result).assertEqual(4);
      let result1 = contentColumnUtils.getDialogGridCount('md', 0.5);
      expect(result1).assertEqual(5);
    })

    it("contentColumnUtilsTest_getDialogGridCount_lg", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      let result = contentColumnUtils.getDialogGridCount('lg', 1);
      expect(result).assertEqual(6);
      let result1 = contentColumnUtils.getDialogGridCount('lg', 2);
      expect(result1).assertEqual(5);
    })

    it("contentColumnUtilsTest_getDialogAlignment", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(contentColumnUtils.getDialogAlignment('sm')).assertEqual(3);
    })

    it("contentColumnUtilsTest_getDialogAlignment_else", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(contentColumnUtils.getDialogAlignment('test')).assertEqual(1);
    })

    it("contentColumnUtilsTest_getPaddingSpace01", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(JSON.stringify(contentColumnUtils.getPaddingSpace('xs')))
        .assertEqual(JSON.stringify($r('sys.float.padding_level8')));
    })

    it("contentColumnUtilsTest_getPaddingSpace02", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(JSON.stringify(contentColumnUtils.getPaddingSpace('sm')))
        .assertEqual(JSON.stringify($r('sys.float.padding_level8')));
    })

    it("contentColumnUtilsTest_getPaddingSpace03", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(JSON.stringify(contentColumnUtils.getPaddingSpace('md')))
        .assertEqual(JSON.stringify($r('sys.float.padding_level12')));
    })

    it("contentColumnUtilsTest_getPaddingSpace04", 0, () => {
      let contentColumnUtils: CantactColumnUtils = new CantactColumnUtils();
      expect(JSON.stringify(contentColumnUtils.getPaddingSpace('ls')))
        .assertEqual(JSON.stringify($r('sys.float.padding_level16')));
    })

  })
}