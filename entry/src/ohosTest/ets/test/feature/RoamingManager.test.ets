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
import { RoamingManager } from '../../../../main/ets/feature/roaming/RoamingManager'
import { UIContext } from '@kit.ArkUI'
import { RoamingUtils } from '../../../../../../common/src/main/ets/util/RoamingUtils';
import { RoamingNumItem } from '../../../../main/ets/pages/dialog/RoamingSelectNumDialog';
import { call } from '@kit.TelephonyKit';
import { DTGlobalContext } from '../../testability/TestAbility';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { common } from '@kit.AbilityKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { VisionGlassConstants } from '../../../../main/ets/data/VisionGlassConstants';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';

const TAG = 'RoamingManager';

export default function RoamingManagerTest() {
  describe('RoamingManagerTest', () => {
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
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('RoamingManagerTest_updateFormatNumber', 0, async () => {
      let callback = () => {
      };
      let parmaList: string[] = [];
      parmaList[0] = '13801001234';
      parmaList[1] = '13801004321';
      parmaList[2] = '13801004322';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().updateFormatNumberTask)

      mocker.mockFunc(HiLog, HiLog.w);
      await RoamingManager.getInstance().updateFormatNumber('111', '111', '111', callback);
      mocker.verify('w', [TAG, `choose original num, no need to update format number`]).once();
      await RoamingManager.getInstance().updateFormatNumber('111', undefined, '123', callback);
      mocker.verify('w', [TAG, `contacts not found by phone number, no need to update format number`]).once();
      await RoamingManager.getInstance().updateFormatNumber('13801001234', '13801004321', '13801004322', callback);
      mocker.verify('updateFormatNumberTask', [parmaList, callback]).once();
      mocker.clear(RoamingManager.getInstance());
      mocker.clear(HiLog);
    })

    it('RoamingManagerTest_handleDialogCallback', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().roamingCallback);
      RoamingManager.getInstance().handleDialogCallback(undefined, '', '', undefined, undefined);
      mocker.verify('roamingCallback', [undefined, false]).once();

      let item: RoamingNumItem | undefined = {
        number: ''
      }

      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().updateFormatNumber);
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().dialing);
      RoamingManager.getInstance().handleDialogCallback(item, '', '', undefined, undefined);
      mocker.verify('updateFormatNumber', ['', '', '']).once();
      mocker.clear(RoamingManager.getInstance());
    })

    it('RoamingManagerTest_getLocations', 0, async () => {
      let phones: string[] | undefined = [];
      RoamingManager.getInstance().getLocations(phones).then(res => {
        expect(res.length).assertEqual(0);
      })

      phones.push('1234567890');
      phones.push('0987654321');
      RoamingManager.getInstance().getLocations(phones).then(res => {
        expect(res.length).assertEqual(2);
      })
    })

    it('RoamingManagerTest_buildRoamingNumItems', 0, async () => {
      let phoneList: string[] = [];
      await RoamingManager.getInstance().buildRoamingNumItems(phoneList).then(res => {
        expect(res.length).assertEqual(0);
      })
      phoneList.push('13801001234');
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(RoamingManager.getInstance(), await RoamingManager.getInstance().getLocations))(phoneList)
        .afterReturn(new Promise<string[]>((resolve: Function) => {
          resolve(['13312345678', '15112345678']);
        }))
      await RoamingManager.getInstance().buildRoamingNumItems(phoneList).then(res => {
        expect(res.length).assertEqual(1);
      })
      mocker.clear(RoamingManager.getInstance());
    })

    it('RoamingManagerTest_handleRoaming_001', 0, async () => {
      let options: call.DialOptions = {
        accountId: 0,
      }
      let context = DTGlobalContext.getContext().getObject("contactContext") as UIContext;
      await RoamingManager.getInstance().handleRoaming(context, undefined, options, (value: boolean)=>{
        expect(value).assertFalse();
      })
    })

    it('RoamingManagerTest_handleRoaming_002', 0, async () => {
      let options: call.DialOptions = {
        accountId: 0,
      }
      let context = DTGlobalContext.getContext().getObject("contactContext") as UIContext;
      let phoneNum = '13900000000';
      await RoamingManager.getInstance().handleRoaming(context, phoneNum, options, (value: boolean)=>{
        expect(value).assertFalse();
      })
    })

    it('RoamingManagerTest_handleRoaming_003', 0, async () => {
      let options: call.DialOptions = {
        accountId: 0,
      }
      let phoneNum = '+8613900000000';

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(RoamingUtils, RoamingUtils.isNoNeedDealWithRoaming))(phoneNum)
        .afterReturn(new Promise<boolean>((resolve: Function) => {
          resolve(false);
        }));
      let context = DTGlobalContext.getContext().getObject("contactContext") as UIContext;
      await RoamingManager.getInstance().handleRoaming(context, phoneNum, options, (value: boolean)=>{
        expect(value).assertFalse();
      })
    })

    it('RoamingManagerTest_dialing_001', 0, async () => {
      let phoneNum = '00000000';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))(phoneNum).afterReturn(new PhoneNumber(phoneNum));

      RoamingManager.getInstance().dialing(phoneNum, undefined, (ret: boolean)=> {
        expect(ret).assertFalse();
      });
      mocker.clear(PhoneNumber);
    })

    it('RoamingManagerTest_dialing_002', 0, async () => {
      let mocker: MockKit = new MockKit();
      let isInVisionGlass: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(isInVisionGlass)(VisionGlassConstants.KEY_IS_IN_VISION_GLASS).afterReturn(true);

      let phoneNum = '00000000';
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))(phoneNum).afterReturn(new PhoneNumber(phoneNum));

      RoamingManager.getInstance().dialing(phoneNum, undefined, (ret: boolean)=> {
        expect(ret).assertFalse();
      });
      mocker.clear(PhoneNumber);
      mocker.clear(AppStorage);
    })


    it('RoamingManagerTest_dialing_003', 0, async () => {
      let mocker: MockKit = new MockKit();
      let isInVisionGlass: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(isInVisionGlass)(VisionGlassConstants.KEY_IS_IN_VISION_GLASS).afterReturn(true);

      let options: call.DialCallOptions = {
        accountId: 0
      };
      let phoneNum = '00000000';
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))(phoneNum).afterReturn(new PhoneNumber(phoneNum));

      RoamingManager.getInstance().dialing(phoneNum, options, (ret: boolean)=> {
        expect(ret).assertFalse();
      });
      mocker.clear(PhoneNumber);
      mocker.clear(AppStorage);
    })

    it('RoamingManagerTest_dialing_004', 0, async () => {
      let mocker: MockKit = new MockKit();
      let isInVisionGlass: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(isInVisionGlass)(VisionGlassConstants.KEY_IS_IN_VISION_GLASS).afterReturn(true);

      const params: Record<string, Object> = {
        'test': new String('111')
      };
      let options: call.DialCallOptions = {
        accountId: 0,
        extraParams: params
      };
      let phoneNum = '00000000';
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))(phoneNum).afterReturn(new PhoneNumber(phoneNum));

      RoamingManager.getInstance().dialing(phoneNum, options, (ret: boolean)=> {
        expect(ret).assertFalse();
      });
      mocker.clear(PhoneNumber);
      mocker.clear(AppStorage);
    })

    it('RoamingManagerTest_roamingCallback_001', 0, async () => {
      RoamingManager.getInstance().roamingCallback((ret: boolean)=> {
        expect(ret).assertFalse();
      }, false);
    })

    it('RoamingManagerTest_handleRoaming01', 0, async () => {
      let callback: Function = () => {};
      let options: call.DialOptions = {
        accountId: 0,
      }
      let phoneOrigin: string | undefined = '13700001111'
      const uiContext = new UIContext();
      let mocker: MockKit = new MockKit();
      let removeSpace: Function = mocker.mockFunc(StringUtil, StringUtil.removeSpace);
      let removeDash: Function = mocker.mockFunc(StringUtil, StringUtil.removeDash);
      when(removeSpace)(phoneOrigin).afterReturn('');
      when(removeDash)(phoneOrigin).afterReturn('');
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().roamingCallback);
      //await RoamingManager.getInstance().handleRoaming(uiContext, phoneOrigin, options, callback);
      //mocker.verify('roamingCallback', [callback, false]).once();

      when(removeSpace)(phoneOrigin).afterReturn('13700001111');
      when(removeDash)(phoneOrigin).afterReturn('13700001111');
      let isNoNeedDealWithRoaming: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.isNoNeedDealWithRoaming);
      when(isNoNeedDealWithRoaming)(ArgumentMatchers.any).afterReturn(new Promise<boolean> ((resolve: Function) => {
        resolve(true);
      }));
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().dialing);
      RoamingManager.getInstance().handleRoaming(uiContext, phoneOrigin, options);
      mocker.verify('dialing', ['13700001111', options]).never();
      mocker.clear(StringUtil);
      mocker.clear(RoamingManager.getInstance());
      mocker.clear(RoamingUtils);
    })
  })
}
