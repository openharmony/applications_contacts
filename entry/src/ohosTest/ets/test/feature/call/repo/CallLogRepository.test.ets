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
import { describe, beforeEach, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium';
import dataShare from '@ohos.data.dataShare';
import { CallLogRepository } from '../../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { CallLog } from '../../../../../../../../feature/call/src/main/ets/entity/CallLog';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import { BusinessError } from '@ohos.base';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';
import { AllCallsGetActionData, CallHistorySearchGetActionData,
  FindByNumberActionData } from '../../../../../../main/ets/model/type';
import { MergeRule } from '../../../../../../../../feature/call/src/main/ets/CallLogSetting';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';
import { sharedPreferencesUtils } from '../../../../../../../../common';
import call from '@ohos.telephony.call';

export default function CallLogRepositoryTest() {
  describe('CallLogRepositoryTest', () => {

    let callLogRepository: CallLogRepository;
    let daHelper: LooseObject;
    let DAResultSet: DataShareResultSet;

    beforeEach(async () => {
      callLogRepository = new CallLogRepository();
      daHelper = {
        on: () => {},
        off: () => {},
        addTemplate: () => {},
        delTemplate: () => {},
        publish: () => {},
        getPublishedData: () => {},
        insert: () => {},
        delete: () => {},
        query: () => {},
        update: () => {},
        batchInsert: () => {},
        normalizeUri: () => {},
        denormalizeUri: () => {},
        notifyChange: () => {},
      };
      DAResultSet = {
        columnNames: [],
        columnCount: 0,
        rowCount: 0,
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

    it('CallLogRepositoryTest_getInstance', 0, () => {
      // expect
      expect(typeof CallLogRepository.getInstance()).assertEqual(typeof callLogRepository);
    })
    it('CallLogRepositoryTest_deleteById', 0, () => {
      const expectedId = false;
      const idBoolean: boolean = callLogRepository.deleteById(1)
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_deleteByNumber', 0, () => {
      const expectedId = false;
      const idBoolean: boolean = callLogRepository.deleteByNumber('1');
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_deleteByLookupUri', 0, () => {
      const expectedId = false;
      const idBoolean: boolean = callLogRepository.deleteByLookupUri('1');
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_readByNumber', 0, () => {
      const expectedId = false;
      const idBoolean: boolean = callLogRepository.readByNumber('1');
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_readById', 0, () => {
      const expectedId = false;
      const idBoolean: boolean = callLogRepository.readById(1);
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_findByFeature', 0, () => {
      const expectedId: Array<CallLog> = [];
      const idBoolean: Array<CallLog> = callLogRepository.findByFeature(1);
      expect(JSON.stringify(idBoolean)).assertEqual(JSON.stringify(expectedId));
    })
    it('CallLogRepositoryTest_registerDataChangeObserver', 0, () => {
      const expectedId: undefined  = undefined;
      let observe: () => void = () => {};
      callLogRepository.registerDataChangeObserver(observe);
      expect(undefined).assertEqual(expectedId);
      // 未测完
    })
    it('CallLogRepositoryTest_unRegisterDataChangeObserver', 0, () => {
      const expectedId: undefined  = undefined;
      let observe: () => void = () => {};
      callLogRepository.unRegisterDataChangeObserver(observe);
      expect(undefined).assertEqual(expectedId);
      // 未测完
    })

    it('CallLogRepositoryTest_init', 0, () => {
      let Data: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      callLogRepository.init(Data);
      expect(JSON.stringify(callLogRepository.context)).assertEqual(JSON.stringify(Data));
    })

    it('CallLogRepositoryTest_getDataAbilityHelper', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(undefined);
      await callLogRepository.getDataAbilityHelper()

      expect(callLogRepository.dataShareHelper).assertEqual(undefined);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_getDataAbilityHelper_error', 0, async () => {
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));
      await callLogRepository.getDataAbilityHelper();
      expect(callLogRepository.dataShareHelper).assertEqual(undefined);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_getDataAbilityHelperProxy', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelperProxy);
      when(getData)().afterReturn(undefined);

      await callLogRepository.getDataAbilityHelperProxy();

      expect(callLogRepository.dataShareHelperProxy).assertEqual(undefined);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_closeDataAbilityHelperProxy', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.closeDataAbilityHelperProxy);
      when(getData)().afterReturn(undefined);
      await callLogRepository.closeDataAbilityHelperProxy()

      expect(callLogRepository.dataShareHelperProxy).assertEqual(undefined);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_saveOne', 0, async () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, ''))
      let callback: (Contact?: number) => void = () => {};

      let mocker: MockKit = new MockKit();
      let saveData: Function = mocker.mockFunc(callLogRepository, callLogRepository.saveOne);
      when(saveData)([callLog, callback]).afterReturn(undefined)
      callLogRepository.saveOne(callLog, callback);
      expect(callLogRepository.result_dt).assertEqual(0);

      callLog = new CallLog(new CallLogBuilder(-1, ''))
      let saveData1: Function = mocker.mockFunc(callLogRepository, callLogRepository.saveOne);
      when(saveData1)([callLog, callback]).afterReturn(undefined)
      callLogRepository.saveOne(callLog, callback);
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_clear', 0, async () => {
      let data = 1;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.delete);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<number>(resolve => resolve(data)));

      callLogRepository.clear((Contact?: number) => {
        expect(Contact).assertEqual(data);
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_clear01', 0, async () => {
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.delete);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));

      callLogRepository.clear((Contact?: number) => {
        expect(Contact).assertEqual(undefined);
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_clear02', 0, async () => {
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      callLogRepository.clear((Contact?: number) => {
        expect(Contact).assertEqual(undefined);
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_saveOne01', 0, async () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(-1, ''))
      let data = 1;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.insert);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<number>(resolve => resolve(data)));

      callLogRepository.saveOne(callLog, (Contact?: number) => {
        expect(Contact).assertUndefined();
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_saveOne02', 0, async () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(-1, ''))
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.insert);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));

      callLogRepository.saveOne(callLog, (Contact?: number) => {
        expect(Contact).assertEqual(undefined);
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_saveOne03', 0, async () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(-1, ''))
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      callLogRepository.saveOne(callLog, (Contact?: number) => {
        expect(Contact).assertEqual(undefined);
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_deleteByIdIn00', 0, async () => {
      let ids: number[] = []
      callLogRepository.deleteByIdIn(ids, [], (Contact?: number) => {
        expect(Contact).assertEqual(undefined);
      })
    })

    /*it('CallLogRepositoryTest_deleteByIdIn01', 0, async () => {
      let ids: number[] = [1, 2, 3]
      let data = 1;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string> (resolve => resolve('contacts')));
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));
      let getData1: Function = mocker.mockFunc(daHelper, daHelper.delete);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<number>(resolve => resolve(data)));

      callLogRepository.deleteByIdIn(ids, [], (Contact?: number) => {
        expect(Contact).assertUndefined();
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
      mocker.clear(sharedPreferencesUtils);
    })*/

    it('CallLogRepositoryTest_deleteByIdIn02', 0, async () => {
      let ids: number[] = [1, 2, 3]
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));
      let getData1: Function = mocker.mockFunc(daHelper, daHelper.delete);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));
      let getData2: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getData2)(ArgumentMatchers.any).afterReturn(new Promise<string> (resolve => resolve('contacts')));

      callLogRepository.deleteByIdIn(ids, [], (Contact?: number) => {
        expect(Contact).assertEqual(0);
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
      mocker.clear(sharedPreferencesUtils);
    })

    it('CallLogRepositoryTest_getSettingDataAbilityHelper00', 0, async () => {
      let data: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper> = callLogRepository.getSettingDataAbilityHelper();
      expect(data).not().assertEqual(undefined);
    })

    it('CallLogRepositoryTest_getSettingDataAbilityHelper01', 0, async () => {
      callLogRepository.settingDataShareHelper = daHelper as dataShare.DataShareHelper;

      let data: dataShare.DataShareHelper | Promise<dataShare.DataShareHelper> = callLogRepository.getSettingDataAbilityHelper();
      expect(JSON.stringify(data)).assertEqual(JSON.stringify(callLogRepository.settingDataShareHelper));
    })

    it('CallLogRepositoryTest_settingCallback00', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getSettingDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      mocker.mockFunc(DAResultSet, DAResultSet.close);
      await callLogRepository.settingCallback();
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
      mocker.clear(DAResultSet);
    })

    it('CallLogRepositoryTest_settingCallback01', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getSettingDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      mocker.mockFunc(DAResultSet, DAResultSet.close)
      await callLogRepository.settingCallback();
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
      mocker.clear(DAResultSet);
    })

    it('CallLogRepositoryTest_registerCallLogDataChangeBySettingData00', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getSettingDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      await callLogRepository.registerCallLogDataChangeBySettingData();
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_unregisterCallLogDataChangeBySettingData00', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getSettingDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      await callLogRepository.registerCallLogDataChangeBySettingData()
      expect(callLogRepository.result_dt).assertEqual(0);;
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_registerSettingDataChangeObserver00', 0, async () => {
      let observer: () => void = () => {};
      callLogRepository.registerSettingDataChangeObserver(observer)
      expect(callLogRepository.result_dt).assertEqual(0)
    })

    it('CallLogRepositoryTest_registerSettingDataChangeObserver01', 0, async () => {
      let observer: () => void = () => {};

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(callLogRepository, callLogRepository.registerCallLogDataChangeBySettingData)
      callLogRepository.registerSettingDataChangeObserver(observer)
      mocker.verify('registerCallLogDataChangeBySettingData', []).once();
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_registerSettingDataChangeObserver02', 0, async () => {
      let observer: () => void = () => 1;
      callLogRepository.settingDataObservers = [() => {}, () => 1, () => 2]

      callLogRepository.registerSettingDataChangeObserver(observer)
      expect(callLogRepository.result_dt).assertEqual(0);
    })

    it('CallLogRepositoryTest_unRegisterSettingDataChangeObserver00', 0, async () => {
      let observer: () => void = () => {};
      callLogRepository.settingDataObservers = [() => {}, () => 1, () => 2]

      callLogRepository.unRegisterSettingDataChangeObserver(observer)
      expect(callLogRepository.result_dt).assertEqual(0);
    })

    it('CallLogRepositoryTest_handleQueryCallLogData00', 0, async () => {
      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME,
        favoriteForm: 'form',
        page: 1,
        limit: 1
      };
      let callback: (Contact: CallLog[]) => void = () => {};
      let groupByValue: string = 'contacts';
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      await callLogRepository.handleQueryCallLogData(actionData, callback, groupByValue);
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_handleQueryCallLogData01', 0, async () => {
      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME,
        favoriteForm: 'form',
        page: 1,
        limit: 1
      };
      let callback: (Contact: CallLog[]) => void = () => [];
      let groupByValue: string = 'contacts';
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      await callLogRepository.handleQueryCallLogData(actionData, callback, groupByValue);
      expect(callLogRepository.result_dt).assertEqual(0)
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_handleQueryCallLogData02', 0, async () => {
      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME,
        favoriteForm: 'form',
        page: 1,
        limit: 1
      };
      let callback: (Contact: CallLog[]) => void
      let groupByValue: string = 'contacts';
      let error: BusinessError;
      let Contact: CallLog[] = [];

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.handleQueryCallLogData(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      }, groupByValue);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_handleQueryCallLogData03', 0, async () => {
      let actionData: AllCallsGetActionData = {
        mergeRule: MergeRule.TIME,
        favoriteForm: 'form',
        page: 1,
        limit: 1
      };
      let groupByValue: string = 'contacts';
      let error: BusinessError;
      let Contact: CallLog[] = [];

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.handleQueryCallLogData(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      }, groupByValue);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_findByNumberIn00', 0, async () => {
      let actionData: FindByNumberActionData = {
        numbers: [],
      };
      await callLogRepository.findByNumberIn(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
    })

    it('CallLogRepositoryTest_findByNumberIn01', 0, async () => {
      let number: string[] = ['1'];
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));
      let actionData: FindByNumberActionData = {
        numbers: number,
      };
      await callLogRepository.findByNumberIn(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findByNumberIn02', 0, async () => {
      let number: string[] = ['1'];
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));
      let actionData: FindByNumberActionData = {
        numbers: number,
      };
      await callLogRepository.findByNumberIn(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findByNumberIn03', 0, async () => {
      let number: string[] = ['1'];
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));
      let actionData: FindByNumberActionData = {
        numbers: number,
      };
      await callLogRepository.findByNumberIn(actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_markMissedCallLogAsRead00', 0, async () => {
      let phoneNum: string = '111111';
      let value: number = 1111;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.update);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<number>(resolve => resolve(value)));

      await callLogRepository.markMissedCallLogAsRead(phoneNum);
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_markMissedCallLogAsRead01', 0, async () => {
      let phoneNum: string = '111111';
      let error: BusinessError;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.update);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.markMissedCallLogAsRead(phoneNum);
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_markMissedCallLogAsRead02', 0, async () => {
      let phoneNum: string = '111111';
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.markMissedCallLogAsRead(phoneNum);
      expect(callLogRepository.result_dt).assertEqual(0);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_findMissedCallLogUnread00', 0, async () => {
      let lastId: number = 1;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      await callLogRepository.findMissedCallLogUnread((Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      }, lastId);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findMissedCallLogUnread01', 0, async () => {
      let lastId: number = 1;
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      await callLogRepository.findMissedCallLogUnread((Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      }, lastId);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findMissedCallLogUnread02', 0, async () => {
      let lastId: number = 1;
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.findMissedCallLogUnread((Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      }, lastId);
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_findSearch00', 0, async () => {
      let isAll: boolean = true;
      let actionData: CallHistorySearchGetActionData = { teleNumber:'11112222333', nameArray: ['1', '2', '3'] };
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(DAResultSet)));

      await callLogRepository.findSearch(isAll, actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findSearch01', 0, async () => {
      let isAll: boolean = false;
      let actionData: CallHistorySearchGetActionData = { teleNumber:'11112222333', nameArray: ['1', '2', '3'] };
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.findSearch(isAll, actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

    it('CallLogRepositoryTest_findSearch02', 0, async () => {
      let isAll: boolean = false;
      let actionData: CallHistorySearchGetActionData = { teleNumber:'11112222333', nameArray: ['1', '2', '3'] };
      let error: BusinessError;

      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<BusinessError>(reject => reject(error)));

      await callLogRepository.findSearch(isAll, actionData, (Contact) => {
        expect(JSON.stringify(Contact)).assertEqual(JSON.stringify([]))
      });
      mocker.clear(callLogRepository);
    })

    it('CallLogRepositoryTest_unInit', 0, () => {
      callLogRepository.unInit();
      expect(callLogRepository.dataShareHelper).assertEqual(undefined);
    })

    it('CallLogRepositoryTest_setSwitchState', 0, async () => {
      await callLogRepository.setSwitchState((value: number) => {
        expect(value).assertEqual(0);
      })
    })

    it('CallLogRepositoryTest_isExistInterceptionCallLog', 0, async () => {
      let mocker: MockKit = new MockKit();
      let getData: Function = mocker.mockFunc(callLogRepository, callLogRepository.getDataAbilityHelper);
      when(getData)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(daHelper as dataShare.DataShareHelper)));

      let getData1: Function = mocker.mockFunc(daHelper, daHelper.query);
      when(getData1)(ArgumentMatchers.any).afterReturn(new Promise<DataShareResultSet>(resolve => resolve(undefined)));

      let isHasInterceptionLog: boolean = await callLogRepository.isExistInterceptionCallLog();
      expect(isHasInterceptionLog).assertEqual(true);
      mocker.clear(callLogRepository);
      mocker.clear(daHelper);
    })

  })
}