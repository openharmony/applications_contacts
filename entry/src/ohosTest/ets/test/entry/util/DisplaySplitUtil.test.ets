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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { DisplaySplitUtil, SplitStatus } from '../../../../../main/ets/util/DisplaySplitUtil'
import { display } from '@kit.ArkUI';

export default function DisplaySplitUtilTest() {
  describe('DisplaySplitUtilTest', () => {

    let mocker: MockKit = new MockKit();

    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('displaySplitUtil_isVerticalSplit', 0, () => {
      expect(DisplaySplitUtil.isVerticalSplit()).assertFalse();

      AppStorage.setOrCreate('splitStatus', SplitStatus.ONE_THREE_SPLIT);
      expect(DisplaySplitUtil.isVerticalSplit(SplitStatus.ONE_THREE_SPLIT)).assertFalse();

      AppStorage.setOrCreate('splitStatus', SplitStatus.VERTICAL_SPLIT);
      expect(DisplaySplitUtil.isVerticalSplit(SplitStatus.VERTICAL_SPLIT)).assertTrue();
    })

    it('displaySplitUtil_isHorizonSplit', 0, () => {
      AppStorage.setOrCreate('splitStatus', undefined);
      expect(DisplaySplitUtil.isHorizonSplit(undefined)).assertFalse();

      AppStorage.setOrCreate('splitStatus', SplitStatus.ONE_THREE_SPLIT);
      expect(DisplaySplitUtil.isHorizonSplit(SplitStatus.ONE_THREE_SPLIT)).assertTrue();

      AppStorage.setOrCreate('splitStatus', SplitStatus.DEFAULT);
      expect(DisplaySplitUtil.isHorizonSplit(SplitStatus.DEFAULT)).assertFalse();
    })

    it('displaySplitUtil_isFixedTitleBar', 0, () => {
      expect(DisplaySplitUtil.isFixedTitleBar(SplitStatus.VERTICAL_SPLIT)).assertFalse();
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.deviceType);
      when(mockFunc)().afterReturn('phone');
      expect(DisplaySplitUtil.isFixedTitleBar(SplitStatus.ONE_THREE_SPLIT)).assertTrue();
      when(mockFunc)().afterReturn('tablet');
      expect(DisplaySplitUtil.isFixedTitleBar(SplitStatus.ONE_THREE_SPLIT)).assertTrue();
      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_isShowIndex', 0, () => {
      expect(DisplaySplitUtil.isShowIndex(SplitStatus.HALF_SPLIT)).assertFalse();
      expect(DisplaySplitUtil.isShowIndex(SplitStatus.DEFAULT)).assertTrue();
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.isFoldStatus);
      when(mockFunc)().afterReturn(true);
      expect(DisplaySplitUtil.isShowIndex(SplitStatus.VERTICAL_SPLIT)).assertTrue();
      let deviceType: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.deviceType);
      when(deviceType)().afterReturn('phone');
      expect(DisplaySplitUtil.isShowIndex(SplitStatus.TWO_THREE_SPLIT)).assertTrue();
      when(deviceType)().afterReturn('tablet');
      expect(DisplaySplitUtil.isShowIndex(SplitStatus.HALF_SPLIT)).assertTrue();
      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_isMdLeft', 0, () => {
      expect(DisplaySplitUtil.isMdLeft(SplitStatus.DEFAULT)).assertFalse();
      let isFoldStatus: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.isFoldStatus);
      when(isFoldStatus)().afterReturn(true);
      expect(DisplaySplitUtil.isMdLeft(SplitStatus.VERTICAL_SPLIT)).assertTrue();
      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_isSmLeft', 0, () => {
      let isFoldStatus: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.isFoldStatus);
      when(isFoldStatus)().afterReturn(true);
      expect(DisplaySplitUtil.isSmLeft(SplitStatus.VERTICAL_SPLIT)).assertFalse();

      when(isFoldStatus)().afterReturn(false);
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.deviceType);
      when(mockFunc)().afterReturn('phone');
      let getFoldStatus: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.getFoldStatus);
      when(getFoldStatus)().afterReturn(display.FoldStatus.FOLD_STATUS_FOLDED);
      expect(DisplaySplitUtil.isSmLeft(SplitStatus.VERTICAL_SPLIT)).assertTrue();

      when(mockFunc)().afterReturn('pc');
      expect(DisplaySplitUtil.isSmLeft(SplitStatus.DEFAULT)).assertFalse();
      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_isSmOneThreeSplit', 0, () => {
      let isFoldStatus: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.isFoldStatus);
      when(isFoldStatus)().afterReturn(true);
      expect(DisplaySplitUtil.isSmOneThreeSplit(SplitStatus.ONE_THREE_SPLIT)).assertFalse();

      when(isFoldStatus)().afterReturn(false);
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.deviceType);
      when(mockFunc)().afterReturn('phone');
      let getFoldStatus: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.getFoldStatus);
      when(getFoldStatus)().afterReturn(display.FoldStatus.FOLD_STATUS_FOLDED);
      expect(DisplaySplitUtil.isSmOneThreeSplit(SplitStatus.ONE_THREE_SPLIT)).assertTrue();

      when(mockFunc)().afterReturn('pc');
      expect(DisplaySplitUtil.isSmOneThreeSplit(SplitStatus.DEFAULT)).assertFalse();
      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_updateSplitStatus', 0, () => {
      const deviceDisplayInfo: display.Display = DisplaySplitUtil.getDefaultDisplaySync();
      deviceDisplayInfo.height = 1;
      deviceDisplayInfo.width = 2;
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(deviceDisplayInfo);
      DisplaySplitUtil.updateSplitStatus(1, 1);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.VERTICAL_SPLIT);

      deviceDisplayInfo.width = 1;
      when(mockFunc)().afterReturn(deviceDisplayInfo);
      DisplaySplitUtil.updateSplitStatus(1, 1);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.DEFAULT);

      deviceDisplayInfo.height = 3;
      DisplaySplitUtil.updateSplitStatus(1, 1);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.ONE_THREE_SPLIT);

      deviceDisplayInfo.height = 4;
      DisplaySplitUtil.updateSplitStatus(1, 2);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.HALF_SPLIT);

      deviceDisplayInfo.height = 6;
      DisplaySplitUtil.updateSplitStatus(1, 4);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.TWO_THREE_SPLIT);

      DisplaySplitUtil.updateSplitStatus(1, 10);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.DEFAULT);

      DisplaySplitUtil.updateSplitStatus(6, 7);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.DEFAULT);

      mocker.clear(DisplaySplitUtil);
    })

    it('displaySplitUtil_updateSplitStatus_error', 0, () => {
      let mockFunc: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.getDefaultDisplaySync);
      when(mockFunc)().afterThrow('error');
      DisplaySplitUtil.updateSplitStatus(1, 1);
      expect(AppStorage.get('splitStatus')).assertEqual(SplitStatus.DEFAULT);
      mocker.clear(DisplaySplitUtil);
    })
  })
}