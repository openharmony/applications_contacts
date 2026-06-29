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
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';
import {
  addSettingModeListener,
  initSettingsDataFiltering, queryInitSettingMode,
  removeSettingModeListener,
  updateMainTabIndex } from '../../../../../main/ets/model/CallSharingModel';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';
import IndexPresenter from '../../../../../main/ets/presenter/IndexPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import EnvironmentProp from '../../../../../main/ets/feature/EnvironmentProp';

const TAG = 'distributedCallPhoneSharingMode';

export default function CallSharingModelTest() {
  describe('CallSharingModelTest', () => {
    let DAHelper: LooseObject;
    let DAResultSet: DataShareResultSet;
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      DAHelper = {
        on: () => {
        },
        off: () => {
        },
        addTemplate: () => {
        },
        delTemplate: () => {
        },
        publish: () => {
        },
        getPublishedData: () => {
        },
        insert: () => {
        },
        delete: () => {
        },
        query: () => {
        },
        update: () => {
        },
        batchInsert: () => {
        },
        normalizeUri: () => {
        },
        denormalizeUri: () => {
        },
        notifyChange: () => {
        },
      }

      DAResultSet = {
        columnNames: [],
        columnCount: 0,
        rowCount: 1,
        isClosed: false,
        goToFirstRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToLastRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToNextRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToPreviousRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goTo: (offset: number): boolean => {
          throw new Error('Function not implemented.');
        },
        goToRow: (position: number): boolean => {
          throw new Error('Function not implemented.');
        },
        getBlob: (columnIndex: number): Uint8Array => {
          throw new Error('Function not implemented.');
        },
        getString: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getLong: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        getDouble: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        close: () => {
          throw new Error('Function not implemented.');
        },
        getColumnIndex: (columnName: string): number => {
          throw new Error('Function not implemented.');
        },
        getColumnName: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getDataType: (columnIndex: number): DataType => {
          throw new Error('Function not implemented.');
        }
      };
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

    it('CallSharingModelTest_queryInitSettingMode_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isOnCallSharing);
      queryInitSettingMode(context, '').finally(() => {
        mocker.verify("isOnCallSharing", []).once();
        mocker.clear(IndexPresenter.getInstance());
      })
    })

    it('CallSharingModelTest_queryInitSettingMode_002', 0, () => {
      let key: string = "distributed_call_sms_sharing_sink";
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isOnCallSharing);
      queryInitSettingMode(context, key).finally(() => {
        mocker.verify("isOnCallSharing", []).once();
        mocker.clear(IndexPresenter.getInstance());
      })
    })

    it('CallSharingModelTest_queryInitSettingMode_003', 0, () => {
      let key: string = "003";
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isOnCallSharing);
      queryInitSettingMode(context, key).finally(() => {
        mocker.verify("isOnCallSharing", []).once();
        mocker.clear(IndexPresenter.getInstance());
      })
    })

    it('CallSharingModelTest_initSettingsDataFiltering_001', 0, () => {
      let keyWord: string = "distributed_modem_state";
      let value: string = '1_sink';
      initSettingsDataFiltering(keyWord, value);
      expect(AppStorage.get('isDistributedModemState')).assertTrue();
    })

    it('CallSharingModelTest_initSettingsDataFiltering_002', 0, () => {
      let keyWord: string = "distributed_call_source_phone";
      let value: string = '1';
      initSettingsDataFiltering(keyWord, value);
      expect(AppStorage.get('isDistributedCallSourcePhone')).assertTrue();
    })

    it('CallSharingModelTest_initSettingsDataFiltering_003', 0, () => {
      let keyWord: string = "distributed_call_phone_sharing_sink";
      let value: string = '1';
      initSettingsDataFiltering(keyWord, value);
      expect(AppStorage.get('isDistributedCallPhoneSharing')).assertTrue();
    })

    it('CallSharingModelTest_initSettingsDataFiltering_004', 0, () => {
      let keyWord: string = "distributed_call_sms_sharing_sink";
      let value: string = '1';
      initSettingsDataFiltering(keyWord, value);
      expect(AppStorage.get('isDistributedCallSMSSharing')).assertTrue();

      initSettingsDataFiltering('1111', value);
      expect(AppStorage.get('isDistributedCallSMSSharing')).assertTrue();
    })

    it('CallSharingModelTest_updateMainTabIndex_001', 0, () => {
      let beforeModemState: boolean = true;
      let beforeCallSharing: boolean = true;
      let beforeCallSource: boolean = true;
      let mocker: MockKit = new MockKit();
      AppStorage.setOrCreate('isDistributedModemState', true);
      AppStorage.setOrCreate('isDistributedCallPhoneSharing', true);
      AppStorage.setOrCreate('isDistributedCallSourcePhone', true);

      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().updateMainTabIndex);
      updateMainTabIndex(beforeModemState, beforeCallSharing, beforeCallSource);
      mocker.verify("updateMainTabIndex", []).never();

      AppStorage.delete('isDistributedModemState');
      AppStorage.delete('isDistributedCallPhoneSharing');
      AppStorage.delete('isDistributedCallSourcePhone');
      let mockFunc: Function = mocker.mockFunc(EnvironmentProp, EnvironmentProp.isDeviceTypeTablet);
      when(mockFunc)().afterReturn(true);
      updateMainTabIndex(beforeModemState, beforeCallSharing, beforeCallSource);
      mocker.verify("updateMainTabIndex", []).never();

      when(mockFunc)().afterReturn(false);
      updateMainTabIndex(beforeModemState, beforeCallSharing, beforeCallSource);
      mocker.verify("updateMainTabIndex", []).once();
      mocker.clear(IndexPresenter.getInstance());
      mocker.clear(EnvironmentProp);
    })

    it('CallSharingModelTest_removeSettingModeListener_001', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let keyWord: string = "distributed_modem_state";
      removeSettingModeListener(keyWord);

      mocker.verify('e', [TAG, 'removeSettingModeListener dataShareHelper null']).never();
      mocker.clear(HiLog);
    })

  })
}