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
import HiCarUtil from '../../../../../main/ets/util/HiCarUtil'
import { display, UIContext } from '@kit.ArkUI'
import { Constants } from '../../../../../main/ets/data/Constants'
import hilog from '@ohos.hilog'
import { RoamingManager } from '../../../../../main/ets/feature/roaming/RoamingManager'

export default function HiCarUtilTest() {
  describe('HiCarUtilTest', async () => {
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
      HiCarUtil.release();
    })

    it('HiCarUtilTest_test01', 0, () => {
      expect(HiCarUtil.getInstance().getWindowDisplayAreaWidthPx()).assertEqual(0);
      expect(HiCarUtil.getInstance().getWindowDisplayAreaHeightPx()).assertEqual(0);
      expect(HiCarUtil.getInstance().getIsBarOnLeft()).assertEqual(true);
      expect(HiCarUtil.getInstance().getIsDialButtonOnRight()).assertEqual(false);
      expect(HiCarUtil.getInstance().getTabContentWidth()).assertEqual(0);
      expect(HiCarUtil.getInstance().getDialPadWidth()).assertEqual(0);
      expect(HiCarUtil.getInstance().getDialPadButtonHeight()).assertEqual(0);
      expect(HiCarUtil.getInstance().getDialFontSize()).assertEqual('');
      expect(HiCarUtil.getInstance().getTabContentPadding()).assertEqual(0);
      expect(HiCarUtil.getInstance().getContactSearchBoxWidth()).assertEqual(0);
    })

    it('HiCarUtilTest_refreshAttributes1', 0, async () => {
      const uiContext = new UIContext();
      const displayList: display.Display[] = await display.getAllDisplays();
      // const dpi = displayList[0].densityPixels;
      const dpi = 3.5;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(dpi);
      //4格栅
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(100 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(50 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getWindowDisplayAreaWidthPx()).assertEqual(350);
      expect(HiCarUtil.getInstance().getWindowDisplayAreaHeightPx()).assertEqual(175);
      expect(HiCarUtil.getInstance().getIsBarOnLeft()).assertEqual(true);
      expect(HiCarUtil.getInstance().getIsDialButtonOnRight()).assertEqual(false);
      expect(HiCarUtil.getInstance().getTabContentWidth()).assertEqual(-20);
      expect(HiCarUtil.getInstance().getDialPadWidth()).assertEqual(49);
      expect(HiCarUtil.getInstance().getDialPadButtonHeight()).assertEqual(32);
      expect(HiCarUtil.getInstance().getDialFontSize()).assertEqual('24vp');
      expect(HiCarUtil.getInstance().getTabContentPadding()).assertEqual(16);
      expect(HiCarUtil.getInstance().getContactSearchBoxWidth()).assertEqual(68);
      //高度大于280vp,小于360
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(100 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(300 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getDialPadButtonHeight()).assertEqual(40);
      expect(HiCarUtil.getInstance().getDialFontSize()).assertEqual('24vp');
      //高度大于宽度，高度大于360vp
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(100 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(400 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getIsBarOnLeft()).assertEqual(false);
      expect(HiCarUtil.getInstance().getIsDialButtonOnRight()).assertEqual(false);
      expect(HiCarUtil.getInstance().getDialPadButtonHeight()).assertEqual(48);
      expect(HiCarUtil.getInstance().getDialFontSize()).assertEqual('26vp');
      HiCarUtil.release();
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshAttributes2', 0, async () => {
      //8格栅
      const uiContext = new UIContext();
      const displayList: display.Display[] = await display.getAllDisplays();
      const dpi = displayList[0].densityPixels;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(800 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(100 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getTabContentWidth()).assertEqual(561);
      expect(HiCarUtil.getInstance().getContactSearchBoxWidth()).assertEqual(561);
      expect(HiCarUtil.getInstance().getDialPadWidth()).assertEqual(465.5);
      HiCarUtil.release();
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshAttributes3', 0, async () => {
      //12格栅
      const uiContext = new UIContext();
      const displayList: display.Display[] = await display.getAllDisplays();
      const dpi = displayList[0].densityPixels;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(1200 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(100 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getTabContentWidth()).assertEqual(944);
      expect(HiCarUtil.getInstance().getContactSearchBoxWidth()).assertEqual(944);
      expect(HiCarUtil.getInstance().getDialPadWidth()).assertEqual(656);
      HiCarUtil.release();
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshAttributes4', 0, async () => {
      const uiContext = new UIContext();
      //12+格栅
      const displayList: display.Display[] = await display.getAllDisplays();
      const dpi = displayList[0].densityPixels;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_WIDTH_PX).afterReturn(1500 * dpi);
      when(funcAppGet)(Constants.KEY_WINDOW_HEIGHT_PX).afterReturn(100 * dpi);
      HiCarUtil.getInstance().refreshAttributes(0, 0, uiContext);
      expect(HiCarUtil.getInstance().getTabContentWidth()).assertEqual(1180);
      expect(HiCarUtil.getInstance().getContactSearchBoxWidth()).assertEqual(1180);
      expect(HiCarUtil.getInstance().getDialPadWidth()).assertEqual(820);
      HiCarUtil.release();
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_other', 0, () => {
      HiCarUtil.release();
      const dialPadHeight = HiCarUtil.getInstance().getDialPadHeight();
      const buttonWidth = HiCarUtil.getInstance().getButtonWidth();
      expect(dialPadHeight).assertEqual(12);
    })

    it('HiCarUtilTest_dialClick', 0, () => {
      const uiContext = new UIContext();
      const phoneNum = '111';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().handleRoaming);
      HiCarUtil.release();
      HiCarUtil.getInstance().dialClick(uiContext, phoneNum, false, -1, 0);
      HiCarUtil.getInstance().dialClick(uiContext, phoneNum, true, -1, 0);
      HiCarUtil.getInstance().dialClick(uiContext, phoneNum, true, 1, 0);
      mocker.verify('handleRoaming', [uiContext, phoneNum]).once();
      mocker.clear(RoamingManager.getInstance());
    })

    it('HiCarUtilTest_refreshTabContentWidth', 0, () => {
      const uiContext = new UIContext();
      const testingDpi: number = 2;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().refreshTabContentWidth(600, uiContext)).assertEqual(180);
      expect(HiCarUtil.getInstance().refreshTabContentWidth(1680, uiContext)).assertEqual(644);
      expect(HiCarUtil.getInstance().refreshTabContentWidth(2880, uiContext)).assertEqual(1130);
      expect(HiCarUtil.getInstance().refreshTabContentWidth(4320, uiContext)).assertEqual(1730);
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshContactSearchBoxWidth', 0, () => {
      const uiContext = new UIContext();
      const testingDpi: number = 2;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().refreshContactSearchBoxWidth(600, uiContext)).assertEqual(268);
      expect(HiCarUtil.getInstance().refreshContactSearchBoxWidth(1680, uiContext)).assertEqual(644);
      expect(HiCarUtil.getInstance().refreshContactSearchBoxWidth(2880, uiContext)).assertEqual(1130);
      expect(HiCarUtil.getInstance().refreshContactSearchBoxWidth(4320, uiContext)).assertEqual(1730);
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshDialPadButtonHeight', 0, () => {
      const uiContext = new UIContext();
      const testingDpi: number = 2;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().refreshDialPadButtonHeight(280, uiContext)).assertEqual(32);
      expect(HiCarUtil.getInstance().refreshDialPadButtonHeight(720, uiContext)).assertEqual(40);
      expect(HiCarUtil.getInstance().refreshDialPadButtonHeight(1080, uiContext)).assertEqual(48);
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshDialFontSize', 0, () => {
      const uiContext = new UIContext();
      const testingDpi: number = 2;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().refreshDialFontSize(280, uiContext)).assertEqual('24vp');
      expect(HiCarUtil.getInstance().refreshDialFontSize(720, uiContext)).assertEqual('24vp');
      expect(HiCarUtil.getInstance().refreshDialFontSize(1080, uiContext)).assertEqual('26vp');
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_refreshDialPadWidth', 0, () => {
      const uiContext = new UIContext();
      const testingDpi: number = 2;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().refreshDialPadWidth(600, uiContext)).assertEqual(199);
      expect(HiCarUtil.getInstance().refreshDialPadWidth(1680, uiContext)).assertEqual(446);
      expect(HiCarUtil.getInstance().refreshDialPadWidth(2880, uiContext)).assertEqual(785);
      expect(HiCarUtil.getInstance().refreshDialPadWidth(4320, uiContext)).assertEqual(1205);
      mocker.clear(AppStorage);
    })

    it('HiCarUtilTest_px2vp', 0, () => {
      const testingDpi: number = 0;
      let mocker: MockKit = new MockKit();
      let funcAppGet: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(funcAppGet)(Constants.KEY_DPI).afterReturn(testingDpi);
      expect(HiCarUtil.getInstance().px2vp(1)).assertEqual(-1);
      mocker.clear(AppStorage);
    })
  })
}