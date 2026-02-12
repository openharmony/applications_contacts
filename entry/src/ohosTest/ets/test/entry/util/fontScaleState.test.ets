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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { FontScaleState } from '../../../../../main/ets/util/fontScaleState'

export default function fontScaleStateTest() {
  describe('fontScaleStateTest', () => {
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
    it('fontScaleStateTest_updateAppFontGearSize', 0, () => {
      FontScaleState.topAndBottomMarginOnScale = $r('app.float.id_card_margin_xxl');
      FontScaleState.updateAppFontGearSize(0);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_xxl')));
      FontScaleState.updateAppFontGearSize(1);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_10')));
      FontScaleState.updateAppFontGearSize(1.15);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_10')));
      FontScaleState.updateAppFontGearSize(1.3);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_10')));
      FontScaleState.updateAppFontGearSize(1.45);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_10')));
      FontScaleState.updateAppFontGearSize(1.75);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_xxl')));
      FontScaleState.updateAppFontGearSize(2);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_image_s')));
      FontScaleState.updateAppFontGearSize(2.25);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_max')));
      FontScaleState.updateAppFontGearSize(3.2);
      expect(JSON.stringify(FontScaleState.topAndBottomMarginOnScale)).assertEqual(JSON.stringify($r('app.float.id_card_margin_max')));
    })

    it('fontScaleStateTest_isStandardGeer', 0, () => {
      expect(FontScaleState.isStandardGeer(0)).assertTrue();
      expect(FontScaleState.isStandardGeer(1)).assertFalse();
    })

    it('fontScaleStateTest_isSmallerTwoGeer', 0, () => {
      expect(FontScaleState.isSmallerTwoGeer(0)).assertTrue();
      expect(FontScaleState.isSmallerTwoGeer(2)).assertFalse();
    })

    it('fontScaleStateTest_isSmallerThirdGeer', 0, () => {
      expect(FontScaleState.isSmallerThirdGeer(0)).assertTrue();
      expect(FontScaleState.isSmallerThirdGeer(3)).assertFalse();
    })
    it('fontScaleStateTest_isBigerThirdGeer', 0, () => {
      expect(FontScaleState.isBigerThirdGeer(4)).assertTrue();
      expect(FontScaleState.isBigerThirdGeer(3)).assertFalse();
    })
    it('fontScaleStateTest_isSmallerFourGeer', 0, () => {
      expect(FontScaleState.isSmallerFourGeer(3)).assertTrue();
      expect(FontScaleState.isSmallerFourGeer(5)).assertFalse();
    })
    it('fontScaleStateTest_isSmallerFiveGeer', 0, () => {
      expect(FontScaleState.isSmallerFiveGeer(4)).assertTrue();
      expect(FontScaleState.isSmallerFiveGeer(6)).assertFalse();
    })
    it('fontScaleStateTest_isSmallerSixGeer', 0, () => {
      expect(FontScaleState.isSmallerSixGeer(0)).assertTrue();
      expect(FontScaleState.isSmallerSixGeer(7)).assertFalse();
    })

    it('fontScaleStateTest_fetchSeniorTopAndBottomSpace', 0, () => {
      let normalSpace = '111';
      let seniorSpace = '222';
      expect(FontScaleState.fetchSeniorTopAndBottomSpace(0, normalSpace, seniorSpace)).assertEqual(normalSpace);
      expect(FontScaleState.fetchSeniorTopAndBottomSpace(2, normalSpace, seniorSpace)).assertEqual(seniorSpace);
      expect(JSON.stringify(FontScaleState.fetchSeniorTopAndBottomSpace(6, normalSpace, seniorSpace))).assertEqual(JSON.stringify($r('app.float.id_card_margin_max')));
    })

    it('fontScaleStateTest_fetchSeniorListSpace', 0, () => {
      AppStorage.setOrCreate('fontSizeScale', 0);
      expect(FontScaleState.fetchSeniorListSpace()).assertEqual(0);
      AppStorage.setOrCreate('fontSizeScale', 4);
      expect(JSON.stringify(FontScaleState.fetchSeniorListSpace())).assertEqual(JSON.stringify($r('app.float.id_dialog_button_bottom_margin')));
      AppStorage.setOrCreate('fontSizeScale', 5);
      expect(JSON.stringify(FontScaleState.fetchSeniorListSpace())).assertEqual(JSON.stringify($r('app.float.id_card_image_s')));
      AppStorage.setOrCreate('fontSizeScale', 6);
      expect(JSON.stringify(FontScaleState.fetchSeniorListSpace())).assertEqual(JSON.stringify($r('app.float.id_card_margin_max')));
    })

    it('fontScaleStateTest_updateAppFontGearSize01', 0, () => {
      const scale = 1.15
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(1);
    })

    it('fontScaleStateTest_updateAppFontGearSize02', 0, () => {
      const scale = 1.3
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(2);
    })

    it('fontScaleStateTest_updateAppFontGearSize03', 0, () => {
      const scale = 1.45
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(3);
    })

    it('fontScaleStateTest_updateAppFontGearSize04', 0, () => {
      const scale = 1.75
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(4);
    })

    it('fontScaleStateTest_updateAppFontGearSize05', 0, () => {
      const scale = 2
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(5);
    })

    it('fontScaleStateTest_updateAppFontGearSize06', 0, () => {
      const scale = 2.25
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(6);
    })

    it('fontScaleStateTest_updateAppFontGearSize07', 0, () => {
      const scale = 3.2
      FontScaleState.updateAppFontGearSize(scale);
      expect(FontScaleState.currentGear).assertEqual(6);
    })
  })
}