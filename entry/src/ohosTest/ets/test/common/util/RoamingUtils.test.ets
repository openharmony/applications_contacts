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
import {RoamingUtils} from '../../../../../../../common/src/main/ets/util/RoamingUtils'
import { data } from '@kit.TelephonyKit'

export default function RoamingUtilsTest() {
  describe('RoamingUtilsTest', () => {
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

    it("RoamingUtilsTest_isNetworkRoaming01", 0, async () => {
      let simCount: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getMaxSimCount);
      when(simCount)().afterReturn(2);
      RoamingUtils.isNetworkRoaming().then((result) => {
        expect(result).assertFalse()
      })
      mocker.clear(RoamingUtils);
    })

    it("RoamingUtilsTest_isNetworkRoaming02", 0, async () => {
      let simCount: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getMaxSimCount);
      when(simCount)().afterReturn(0);
      RoamingUtils.isNetworkRoaming().then((result) => {
        expect(result).assertFalse();
      })
      mocker.clear(RoamingUtils);
    })

    it("RoamingUtilsTest_isChineseMobileNumber", 0, () => {
      expect(RoamingUtils.isChineseMobileNumber('13801001234')).assertTrue();
    })

    it("RoamingUtilsTest_isChineseHomeNumber", 0, () => {
      expect(RoamingUtils.isChineseHomeNumber('13801001111')).assertTrue();
    })

    it("RoamingUtilsTest_isAmericaNumber", 0, () => {
      expect(RoamingUtils.isAmericaNumber('13801001111')).assertFalse();
    })

    it("RoamingUtilsTest_isNoNeedDealWithRoaming", 0, async  () => {
      let mockFunc: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.isNoNeedDealWithRoaming);
      when(mockFunc)('13801001111').afterReturn(new Promise<boolean>((resolve: Function, reject: Function) => {
        resolve(true);
      }))
      let result = await RoamingUtils.isNoNeedDealWithRoaming('13801001111');
      expect(result).assertEqual(true);
      mocker.clear(RoamingUtils);
    })

    it('RoamingUtilsTest_getValidNumber', 0, () => {
      expect(RoamingUtils.getValidNumber('123456789', '+66123456789')).assertEqual('+66123456789');
      expect(RoamingUtils.getValidNumber('123456789', '+661234567891')).assertUndefined();
      expect(RoamingUtils.getValidNumber('123456789', '+861234567891')).assertEqual('123456789');
      expect(RoamingUtils.getValidNumber('123456789', '+86123456789')).assertEqual('+86123456789');
      expect(RoamingUtils.getValidNumber('123456789', '+8611111111')).assertEqual('123456789');
      expect(RoamingUtils.getValidNumber('13333333333', '+8611111111')).assertEqual('+8613333333333');
    })

    it("RoamingUtilsTest_getValidNumber01", 0, () => {
      expect(RoamingUtils.getValidNumber(undefined, undefined)).assertUndefined();
    })

    it("RoamingUtilsTest_isValidOverseaNumber_undefined", 0, () => {
      expect(RoamingUtils.isValidOverseaNumber(undefined, undefined)).assertFalse();
    })

    it("RoamingUtilsTest_isValidOverseaNumber", 0, () => {
      let phoneNumber: string = '138 0100 1111';
      let formatNumber: string = '138 0100 1111'
      expect(RoamingUtils.isValidOverseaNumber(phoneNumber, formatNumber)).assertTrue();
    })

    it("RoamingUtilsTest_addPrefixForChineseNumber_undefined", 0, () => {
      expect(RoamingUtils.addPrefixForChineseNumber('')).assertUndefined();
    })

    it("RoamingUtilsTest_addPrefixForChineseNumber", 0, () => {
      expect(RoamingUtils.addPrefixForChineseNumber('+86 13801001111')).assertEqual('+86 13801001111');
      expect(RoamingUtils.addPrefixForChineseNumber('013801001234')).assertEqual('+8613801001234');
      expect(RoamingUtils.addPrefixForChineseNumber('099912345678')).assertEqual('+8699912345678');
      expect(RoamingUtils.addPrefixForChineseNumber('0086112345678')).assertEqual('+86112345678');
      expect(RoamingUtils.addPrefixForChineseNumber('00861123456789')).assertEqual('+861123456789');
      expect(RoamingUtils.addPrefixForChineseNumber('4001234567')).assertEqual('+864001234567');
      expect(RoamingUtils.addPrefixForChineseNumber('40012345678')).assertEqual('40012345678');
    })

    it("RoamingUtilsTest_isNetworkRoaming", 0, async () => {
      let mocker: MockKit = new MockKit();
      let simCount: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getMaxSimCount);
      when(simCount)().afterReturn(1);
      RoamingUtils.isNetworkRoaming().then((result) => {
        expect(result).assertFalse()
      })
      mocker.clear(RoamingUtils);
    })

    it("RoamingUtilsTest_getRoamingDialNumber", 0, () => {
      let oriNum: string = '';
      let formatNumber: string = '';
      RoamingUtils.getRoamingDialNumber(oriNum, formatNumber).then((result) => {
        expect(result.length).assertEqual(0);
      })

      let oriNum1: string = '13801001111';
      let formatNumber1: string = '13801001111';
      RoamingUtils.getRoamingDialNumber(oriNum1, formatNumber1).then((result) => {
        expect(JSON.stringify(result)).assertEqual(JSON.stringify(['13801001111']));
      })

      let oriNum2: string = '13333333333';
      let formatNumber2: string = '+8611111111';
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.isNetworkRoaming))().afterReturn(new Promise<boolean> ((resolve: Function) => {
        resolve(true);
      }))
      let mockFunc: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getValidNumber);
      when(mockFunc)(ArgumentMatchers.any).afterReturn('+8613333333333')
      RoamingUtils.getRoamingDialNumber(oriNum2, formatNumber2).then((result) => {
        expect(JSON.stringify(result)).assertEqual(JSON.stringify(['13333333333']));
      })

      let oriNum3: string = '13333333333';
      let formatNumber3: string = '+8611111111';
      let validCallLogNumber: string = '13801001234'
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.isNetworkRoaming))().afterReturn(new Promise<boolean> ((resolve: Function) => {
        resolve(true);
      }))
      let mockFunc1: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getValidNumber);
      when(mockFunc1)(ArgumentMatchers.any).afterReturn('')
      RoamingUtils.getRoamingDialNumber(oriNum3, formatNumber3, validCallLogNumber).then((result) => {
        expect(JSON.stringify(result)).assertEqual(JSON.stringify(['13801001234']));
      })

      let oriNum4: string = '13333333333';
      let formatNumber4: string = '+8611111111';
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.isNetworkRoaming))().afterReturn(new Promise<boolean> ((resolve: Function) => {
        resolve(true);
      }))
      let mockFunc2: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getValidNumber);
      when(mockFunc2)(ArgumentMatchers.any).afterReturn('');
      RoamingUtils.getRoamingDialNumber(oriNum4, formatNumber4).then((result) => {
        expect(JSON.stringify(result)).assertEqual(JSON.stringify(['13333333333']));
      })
      mocker.clear(RoamingUtils);
    })

    it("RoamingUtilsTest_getFormatNumberBySystemRegion", 0, () => {
      let result = RoamingUtils.getFormatNumberBySystemRegion('13801001111');
      expect(result).assertEqual('+8613801001111');
    })

    it('RoamingUtilsTest_isNumberMatchCurrentCountry', 0, () => {
      expect(RoamingUtils.isNumberMatchCurrentCountry('', '')).assertFalse();
      expect(RoamingUtils.isNumberMatchCurrentCountry('123', '123')).assertFalse();
      expect(RoamingUtils.isNumberMatchCurrentCountry('13801001234', '13801001234')).assertFalse();
    })

    it('RoamingUtilsTest_addPrefixForMobileNumber', 0, () => {
      expect(RoamingUtils.addPrefixForMobileNumber('008613801003333')).assertEqual('+8613801003333');
      expect(RoamingUtils.addPrefixForMobileNumber('13801003333')).assertEqual('+8613801003333');
      expect(RoamingUtils.addPrefixForMobileNumber('013801003333')).assertEqual('+8613801003333');
      expect(RoamingUtils.addPrefixForMobileNumber('123')).assertEqual('123');
    })

    it('RoamingUtilsTest_deleteChinaIso', 0, () => {
      expect(RoamingUtils.deleteChinaIso('+8613901234567')).assertEqual('13901234567');
      expect(RoamingUtils.deleteChinaIso('008613901234567')).assertEqual('13901234567');
      expect(RoamingUtils.deleteChinaIso('13901234567')).assertEqual('13901234567');
    })

    it('RoamingUtilsTest_isCreatePhoneNumberInUS', 0, () => {
      expect(RoamingUtils.isCreatePhoneNumberInUS('', '')).assertFalse();
      expect(RoamingUtils.isCreatePhoneNumberInUS('+8613801001111', '+8613801001111')).assertFalse();
    })

    it('RoamingUtilsTest_getFormatNumberFromChinaSim', 0, () => {
      expect(RoamingUtils.getFormatNumberFromChinaSim('')).assertUndefined();
      expect(RoamingUtils.getFormatNumberFromChinaSim('+8613801001111')).assertEqual('+8613801001111');
      expect(RoamingUtils.getFormatNumberFromChinaSim('4001234567')).assertEqual('+864001234567');
      expect(RoamingUtils.getFormatNumberFromChinaSim('123')).assertUndefined();
    })

    it('RoamingUtilsTest_getValidOverseaNumber', 0, () => {
      expect(RoamingUtils.getValidOverseaNumber('13801110000', 12)).assertEqual('13801110000');
      expect(RoamingUtils.getValidOverseaNumber('13801110000', 11)).assertEqual('13801110000');
    })

    it('RoamingUtilsTest_deleteIpHead', 0, () => {
      expect(RoamingUtils.deleteIpHead('008617112345678')).assertEqual('008617112345678');
    })

    it('RoamingUtilsTest_getFormatNumberFromSim', 0, () => {
      let slotId: number = 1;
      expect(RoamingUtils.getFormatNumberFromSim(undefined, slotId)).assertUndefined();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.getISOCountryCodeForSimSync))(slotId).afterReturn('');
      expect(RoamingUtils.getFormatNumberFromSim('13801001234', slotId)).assertUndefined();

      when(mocker.mockFunc(RoamingUtils, RoamingUtils.getISOCountryCodeForSimSync))(slotId).afterReturn('13801001234');
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.isNumberMatchCurrentCountry))(ArgumentMatchers.any).afterReturn(true);
      expect(RoamingUtils.getFormatNumberFromSim('13801001234', slotId)).assertEqual(undefined);
      mocker.clear(RoamingUtils);
    })

    it('RoamingUtilsTest_getFormatNumberFromNetWork', 0, () => {
      let phoneNumber: string = '';
      expect(RoamingUtils.getFormatNumberFromNetWork(phoneNumber)).assertUndefined();

      phoneNumber = '13801002222';
      let mocker: MockKit = new MockKit();
      let getISOCountryCodeForNetworkSync: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getISOCountryCodeForNetworkSync);
      when(getISOCountryCodeForNetworkSync)().afterReturn('');
      expect(RoamingUtils.getFormatNumberFromNetWork(phoneNumber)).assertUndefined();

      when(getISOCountryCodeForNetworkSync)().afterReturn('CN');
      expect(RoamingUtils.getFormatNumberFromNetWork(phoneNumber)).assertEqual('+8613801002222');
      mocker.clear(RoamingUtils);
    })
  })
}