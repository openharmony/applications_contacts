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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader'

export default function DynamicLoaderTest() {
  describe('DynamicLoaderTest', () => {
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
    it('DynamicLoaderTest_getInstance', 0, () => {
      let dl = DynamicLoader.getInstance();
      expect(dl.tag).assertEqual('DynamicLoader: ');
    })
    it('DynamicLoaderTest_register', 0, () => {
      let dl = DynamicLoader.getInstance();
      let loaderCallback: (key: string) => Promise<boolean> = (async (str: string): Promise<boolean> => {
      return true;
      });
      dl.register(loaderCallback);
      expect(dl.dynamicLoaderCB).not().assertNull();
    })
    it('DynamicLoaderTest_fire1', 0, () => {
      let dl = DynamicLoader.getInstance();
      let resFire = dl.fire("key");
      expect(resFire).not().assertNull();
    })
    it('DynamicLoaderTest_fire2', 0, () => {
      let dl = DynamicLoader.getInstance();
      let loaderCallback: (key: string) => Promise<boolean> = (async (str: string): Promise<boolean> => {
        return true;
      });
      dl.dynamicLoaderCB = loaderCallback;
      let resFire = dl.fire("key");
      expect(resFire).not().assertNull();
    })

    it('DynamicLoaderTest_fire3', 0, async () => {
      DynamicLoader.getInstance().dynamicLoaderSettingsCB = null;
      DynamicLoader.getInstance().dynamicLoaderRingToneCB = null;
      DynamicLoader.getInstance().dynamicLoaderCB = null;
      DynamicLoader.getInstance().fire('key', true, false).then((value: boolean) => {
        expect(value).assertTrue();
      })

      DynamicLoader.getInstance().fire('key', false, true).then((value: boolean) => {
        expect(value).assertTrue();
      })

      DynamicLoader.getInstance().fire('key', false, false).then((value: boolean) => {
        expect(value).assertTrue();
      })
    })

    it('DynamicLoaderTest_fire4', 0, async () => {
      DynamicLoader.getInstance().dynamicLoaderSettingsCB = ()=> new Promise<boolean>(resolve => resolve(true));
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().dynamicLoaderSettingsCB))('key')
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      DynamicLoader.getInstance().fire('key', true, false).then((value: boolean) => {
        expect(value).assertTrue();
      })

      DynamicLoader.getInstance().dynamicLoaderRingToneCB = ()=> new Promise<boolean>(resolve => resolve(true));
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().dynamicLoaderRingToneCB))('key')
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      DynamicLoader.getInstance().fire('key', false, true).then((value: boolean) => {
        expect(value).assertTrue();
      })

      DynamicLoader.getInstance().dynamicLoaderCB = ()=> new Promise<boolean>(resolve => resolve(true));
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().dynamicLoaderCB))('key')
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      DynamicLoader.getInstance().fire('key', false, false).then((value: boolean) => {
        expect(value).assertTrue();
      })
      mocker.clear(DynamicLoader.getInstance());
    })
  })
}