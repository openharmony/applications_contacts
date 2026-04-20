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
import { describe, it, expect } from '@ohos/hypium'
import { AnimateCallback, CustomTransition, TitleAnimation } from '../../../../../main/ets/util/CustomNavigationUtil'

export default function CustomNavigationUtilTest() {
  describe('CustomNavigationUtilTest', () => {
    let titleAnimation: TitleAnimation = {
      titleAnimation: {
        finish: (isPush: boolean, isExit) => {
        },
        onFinish: (isPush: boolean, isExit: boolean) => {
        },
        start: (isPush: boolean, isExit: boolean) => {
        }
      },
      transitionAnimation: {
        finish: (isPush: boolean, isExit) => {
        },
        onFinish: (isPush: boolean, isExit: boolean) => {
        },
        start: (isPush: boolean, isExit: boolean) => {
        }
      },
      opacityAnimation: {
        finish: (isPush: boolean, isExit) => {
        },
        onFinish: (isPush: boolean, isExit: boolean) => {
        },
        start: (isPush: boolean, isExit: boolean) => {
        }
      }
    }
    it("CustomNavigationUtilTest_registerNavParam", 0, () => {
      CustomTransition.getInstance().registerNavParam(0, titleAnimation);
      expect(CustomTransition.getInstance().getAnimateParam(0)).assertEqual(titleAnimation);
    })

    it("CustomNavigationUtilTest_getAnimateParam_undefined", 0, () => {
      expect(CustomTransition.getInstance().getAnimateParam(-1)).assertUndefined();
    })

    it("CustomNavigationUtilTest_getAnimateParam", 0, () => {
      expect(CustomTransition.getInstance().getAnimateParam(0)).assertEqual(titleAnimation);
    })

    it("CustomNavigationUtilTest_unRegisterNavParam", 0, () => {
      CustomTransition.getInstance().unRegisterNavParam(0);
      expect(CustomTransition.getInstance().getAnimateParam(0)).assertUndefined();
    })

  })
}