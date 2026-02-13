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
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil'

export default function StringUtilTest() {
  describe('StringUtilTest', () => {
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
      // This API supports only one parameter: clear action function
    })
    it('StringUtilTest_isEmpty', 0, () => {
      const result1 = StringUtil.isEmpty(undefined);
      expect(result1).assertTrue();

      const result2 = StringUtil.isEmpty('');
      expect(result2).assertTrue();

      const result3 = StringUtil.isEmpty('      ');
      expect(result3).assertTrue();

      const result4 = StringUtil.isEmpty(null);
      expect(result4).assertTrue();

      const result5 = StringUtil.isEmpty('test');
      expect(result5).assertFalse();

      const result6 = StringUtil.isEmpty('undefined');
      expect(result6).assertTrue();
    })
    it('StringUtilTest_removeSpace', 0, () => {
      const result1 = StringUtil.removeSpace('');
      expect(result1).assertEqual('');

      const result2 = StringUtil.removeSpace('      ');
      expect(result2).assertEqual('');

      const result3 = StringUtil.removeSpace('  t   e     s   t  ');
      expect(result3).assertEqual('test');
    })
    it('StringUtilTest_removeDash', 0, () => {
      const result1 = StringUtil.removeDash('');
      expect(result1).assertEqual('');

      const result2 = StringUtil.removeDash('133-3333-3333');
      expect(result2).assertEqual('13333333333');

      const result3 = StringUtil.removeDash('-13-139060-5-');
      expect(result3).assertEqual('131390605');
    })
    it('StringUtilTest_getMatchedString', 0, () => {
      const result1 = StringUtil.getMatchedString('', '   ');
      expect(result1).assertEqual('');

      const result2 = StringUtil.getMatchedString('hello word', 'test');
      expect(result2).assertEqual('');

      const result3 = StringUtil.getMatchedString('hello word', 'h el lo');
      expect(result3).assertEqual('hello');

      const result4 = StringUtil.getMatchedString('he l lo wo rd', 'w o r d');
      expect(result4).assertEqual('wo rd');
    })
    it("StringUtilTest_transferEmptyStrIfUndefined_01", 0, () => {
      const result = StringUtil.transferEmptyStrIfUndefined(undefined);
      expect(result).assertEqual('')
    })
    it("StringUtilTest_transferEmptyStrIfUndefined_02", 0, () => {
      let str: string = 'hello';
      const result = StringUtil.transferEmptyStrIfUndefined(str);
      expect(result).assertEqual('hello')
    })

    it('StringUtilTest_maskSensitiveInfo', 0, () => {
      let str: string = '';
      let result = StringUtil.maskSensitiveInfo(str);
      expect(result).assertEqual('');
      expect(StringUtil.maskSensitiveInfo('h')).assertEqual('*:1');
      expect(StringUtil.maskSensitiveInfo('he')).assertEqual('h:2');
      expect(StringUtil.maskSensitiveInfo('hello')).assertEqual('h:o:5');
      expect(StringUtil.maskSensitiveInfo('13801001111')).assertEqual('138:1111:11');
      expect(StringUtil.maskSensitiveInfo('+8613801001111')).assertEqual('+86138:1111:14');
      expect(StringUtil.maskSensitiveInfo('00013801001111000')).assertEqual('000:1000:17');
    })

    it('StringUtilTest_maskDeviceId', 0, () => {
      let str: string = '';
      expect(StringUtil.maskDeviceId(str)).assertEqual('');
      expect(StringUtil.maskDeviceId('123456789098765')).assertEqual('1234:8765:15');
      expect(StringUtil.maskDeviceId('123456789')).assertEqual('12:89:9');
    })

    it('StringUtilTest_hasFormatChar', 0, () => {
      expect(StringUtil.hasFormatChar('')).assertFalse();
      expect(StringUtil.hasFormatChar('a b-c')).assertTrue();
      expect(StringUtil.hasFormatChar('111')).assertFalse();
    })
  })
}