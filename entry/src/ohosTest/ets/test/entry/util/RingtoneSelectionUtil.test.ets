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
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { RingtoneSelectionUtil } from '../../../../../main/ets/util/RingtoneSelectionUtil'
import { systemSoundManager } from '@kit.AudioKit';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';


export default function RingtoneSelectionUtilTest() {
  describe('RingtoneSelectionUtilTest', () => {
    type ToneAttrsArray = systemSoundManager.ToneAttrsArray;
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
    it('RingtoneSelectionUtilTest_getRingToneAttrList', 0, async () => {
      let toneAttrsArr: systemSoundManager.ToneAttrsArray = [];
      let toneAttrs: systemSoundManager.ToneAttrs = {
        getTitle: (): string => {
          throw new Error('Function not implemented.');
        },
        setTitle: (title: string): void => {
          title = '111';
        },
        getFileName: (): string => {
          throw new Error('Function not implemented.');
        },
        setFileName: (name: string): void => {
          name = '222'
        },
        getUri: (): string => {
          throw new Error('Function not implemented.');
        },
        getCustomizedType: (): systemSoundManager.ToneCustomizedType => {
          throw new Error('Function not implemented.');
        },
        setCategory: (category: number): void => {
          throw new Error('Function not implemented.');
        },
        getCategory: (): number => {
          throw new Error('Function not implemented.');
        },
        setMediaType: (type: systemSoundManager.MediaType): void => {
          throw new Error('Function not implemented.');
        },
        getMediaType: (): systemSoundManager.MediaType => {
          throw new Error('Function not implemented.');
        }
      }
      toneAttrsArr.push(toneAttrs);
      AppStorage.setOrCreate('ring_tone_attr_list', toneAttrsArr);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunc)('ring_tone_attr_list').afterReturn(toneAttrsArr);
      await RingtoneSelectionUtil.getRingToneAttrList(false);
      let result = AppStorage.get<ToneAttrsArray>('ring_tone_attr_list');
      expect(JSON.stringify(toneAttrsArr)).assertEqual(JSON.stringify(result));
      mocker.clear(AppStorage);
    })

    it('RingtoneSelectionUtilTest_findRingtoneFromList', 0, async () => {
      expect(await RingtoneSelectionUtil.findRingtoneFromList(undefined)).assertEqual(undefined);
      let toneAttrsArr: systemSoundManager.ToneAttrsArray = [];
      let toneAttrs: systemSoundManager.ToneAttrs = {
        getTitle: (): string => {
          throw new Error('Function not implemented.');
        },
        setTitle: (title: string): void => {
          title = '111';
        },
        getFileName: (): string => {
          throw new Error('Function not implemented.');
        },
        setFileName: (name: string): void => {
          name = '222'
        },
        getUri: (): string => {
          throw new Error('Function not implemented.');
        },
        getCustomizedType: (): systemSoundManager.ToneCustomizedType => {
          throw new Error('Function not implemented.');
        },
        setCategory: (category: number): void => {
          throw new Error('Function not implemented.');
        },
        getCategory: (): number => {
          throw new Error('Function not implemented.');
        },
        setMediaType: (type: systemSoundManager.MediaType): void => {
          throw new Error('Function not implemented.');
        },
        getMediaType: (): systemSoundManager.MediaType => {
          throw new Error('Function not implemented.');
        }
      }
      toneAttrsArr.push(toneAttrs);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(RingtoneSelectionUtil, RingtoneSelectionUtil.getRingToneAttrList);
      when(mockFunc)().afterReturn(new Promise<ToneAttrsArray | undefined> ((resolve: Function) => {
        resolve(undefined);
      }))
      expect(await RingtoneSelectionUtil.findRingtoneFromList('url')).assertEqual(undefined);
      mocker.clear(RingtoneSelectionUtil);
    })

    it('RingtoneSelectionUtilTest_findRingtoneFromList_error', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(RingtoneSelectionUtil, RingtoneSelectionUtil.getRingToneAttrList);
      when(mockFunc)().afterThrow('error');
      expect(await RingtoneSelectionUtil.findRingtoneFromList('url')).assertEqual(undefined);
      mocker.clear(RingtoneSelectionUtil);
    })
  })
}