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
import { window } from '@kit.ArkUI';
import { BreakpointUtil } from '../../../../../main/ets/util/BreakpointUtil';

export default function BreakpointUtilTest() {
  describe('BreakpointUtilTest', () => {
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
    it('BreakpointUtil_getWidthBreakpoint_01', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 0,
        width: 500
      }
      expect(BreakpointUtil.getWidthBreakpoint(windowRect)).assertEqual('sm')
    })

    it('BreakpointUtil_getWidthBreakpoint_02', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 0,
        width: 1500
      }
      expect(BreakpointUtil.getWidthBreakpoint(windowRect)).assertEqual('sm')
    })

    it('BreakpointUtil_getWidthBreakpoint_03', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 0,
        width: 2500
      }
      expect(BreakpointUtil.getWidthBreakpoint(windowRect)).assertEqual('md')
    })

    it('BreakpointUtil_getWidthBreakpoint_04', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 0,
        width: 3000
      }
      expect(BreakpointUtil.getWidthBreakpoint(windowRect)).assertEqual('lg')
    })

    it('BreakpointUtil_getWidthBreakpoint_05', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 0,
        width: 6000
      }
      expect(BreakpointUtil.getWidthBreakpoint(windowRect)).assertEqual('lg')
    })

    it('BreakpointUtil_getHeightBreakpoint_01', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 1000,
        width: 2000
      }
      expect(BreakpointUtil.getHeightBreakpoint(windowRect)).assertEqual('sm')
    })

    it('BreakpointUtil_getHeightBreakpoint_02', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 2000,
        width: 2000
      }
      expect(BreakpointUtil.getHeightBreakpoint(windowRect)).assertEqual('md')
    })

    it('BreakpointUtil_getHeightBreakpoint_03', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 2000,
        width: 1000
      }
      expect(BreakpointUtil.getHeightBreakpoint(windowRect)).assertEqual('lg')
    })

    it('BreakpointUtil_judgingVerdeBreakpoint_01', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 1000,
        width: 1000
      }
      BreakpointUtil.judgingVerdeBreakpoint(windowRect)

      expect(AppStorage.get('isVerde')).assertFalse();
    })

    it('BreakpointUtil_judgingVerdeBreakpoint_02', 0, () => {
      let windowRect: window.Rect = {
        left: 0,
        top: 0,
        height: 1000,
        width: 500
      }
      BreakpointUtil.judgingVerdeBreakpoint(windowRect)

      expect(AppStorage.get('isVerde')).assertFalse();
    })
  })
}