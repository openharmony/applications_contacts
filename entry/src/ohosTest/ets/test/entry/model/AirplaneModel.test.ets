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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import {
  addAirPlaneModeListener,
  queryAirPlaneMode,
  queryAirPlaneStatus,
  removeAirPlaneModeListener
} from '../../../../../main/ets/model/AirplaneModel';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'AirplaneMode';

export default function AirplaneModelTest() {
  describe('AirplaneModelTest', () => {
    let DAHelper: LooseObject;
    let DAResultSet: DataShareResultSet;

    beforeEach(() => {
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

    it('Contacts_AirplaneModelTest_queryAirPlaneMode_001', 0, () => {
      let result = false;
      queryAirPlaneMode(() => {
        result = true;
      }, true);
      expect(result).assertFalse();
    })

    it('Contacts_AirplaneModelTest_queryAirPlaneMode_002', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
      addAirPlaneModeListener(() => {
      });
      let result = false;
      queryAirPlaneMode(() => {
        result = true;
      }, true);
      expect(result).assertFalse();
    })

    it('Contacts_AirplaneModelTest_removeAirPlaneModeListener', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
      addAirPlaneModeListener(() => {
      });
      removeAirPlaneModeListener();
      mocker.verify('i', [TAG, 'removeAirPlaneModeListener']).once();
      mocker.clear(HiLog);
    })

    it('Contacts_AirplaneModelTest_queryAirPlaneStatus', 0, async () => {
      let result = 0;
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
      addAirPlaneModeListener(() => {
      });
      const ON_SETTING_AIRPLANE_MODE_URI = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=airplane_mode';
      let mocker: MockKit = new MockKit();
      let queryMockerFun: Function = mocker.mockFunc(DAHelper, DAHelper.query);
      when(queryMockerFun)(ON_SETTING_AIRPLANE_MODE_URI)
        .afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));
      mocker.mockFunc(DAResultSet, DAResultSet.close);
      await queryAirPlaneStatus(context, () => {
        result = 1;
      });
      expect(result).assertEqual(0);
      mocker.clear(DAHelper);
      mocker.clear(DAResultSet);
    })
  })
}