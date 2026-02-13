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
import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import SimIccDiallingNumbers from '../../../../../../main/ets/feature/sim/SimIccDiallingNumbers';
import { sharedPreferencesUtils } from '../../../../../../../../common/src/main/ets/util/SharedPreferencesUtils';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactRepository } from '../../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import sim from '@ohos.telephony.sim';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';

export default function SimIccDiallingNumbersTest() {
  describe('SimIccDiallingNumbersTest', () => {

    it('Contacts_SimIccDiallingNumbersTest_confirmExport', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('isHasContactByPhoneNumAndDisplayName').afterAction(() => {
        result = true;
      });
      let diallingNumbersInfo: sim.DiallingNumbersInfo = {
        alphaTag: '111', number: 'ddd', recordNumber: 1, pin2: 'ddd'
      };
      let localContactData: Array<sim.DiallingNumbersInfo> = [diallingNumbersInfo, diallingNumbersInfo];
      SimIccDiallingNumbers.contactData = localContactData;
      mocker.mockFunc(SimIccDiallingNumbers, SimIccDiallingNumbers.saveSimContactMark);
      SimIccDiallingNumbers.confirmExport();

      mocker.verify('saveSimContactMark', []).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(SimIccDiallingNumbers);
      mocker.clear(workerWrapper);
    })

    it('Contacts_SimIccDiallingNumbersTest_confirmExport_addIccDiallingNumbersToContact_else', 0, () => {
      let mocker: MockKit = new MockKit();
      let num: number = 106;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      SimIccDiallingNumbers.contactData = [{
        alphaTag: 'tag', number: '570977632'
      } as sim.DiallingNumbersInfo];

      SimIccDiallingNumbers.confirmExport();

      expect(SimIccDiallingNumbers.exportEmitterId).assertEqual(num);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })

    it('Contacts_SimIccDiallingNumbersTest_confirmExport_addIccDiallingNumbersToContact_if', 0, () => {
      let mocker: MockKit = new MockKit();

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          },
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise <number>(resolve => resolve(1)),
          batchInsert: (uri: string, values: ValuesBucket[]): Promise<number> => new Promise <number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      SimIccDiallingNumbers.contactData = [{
        alphaTag: 'tag', number: '570977632', recordNumber: 1, pin: ''
      } as sim.DiallingNumbersInfo];

      SimIccDiallingNumbers.confirmExport();

      expect(SimIccDiallingNumbers.cancelImport).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })

    it('Contacts_SimIccDiallingNumbersTest_confirmExport_addIccDiallingNumbersToContact_if2', 0, () => {
      let mocker: MockKit = new MockKit();

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          },
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise <number>(resolve => resolve(1)),
          batchInsert: (uri: string, values: ValuesBucket[]): Promise<number> => new Promise <number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      SimIccDiallingNumbers.contactData = [{
        alphaTag: 'tag', number: '570977632'
      } as sim.DiallingNumbersInfo];

      SimIccDiallingNumbers.confirmExport();

      expect(SimIccDiallingNumbers.cancelImport).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })

    it('Contacts_SimIccDiallingNumbersTest_saveSimContactMark', 0, () => {
      SimIccDiallingNumbers.saveSimContactMark();
      expect(SimIccDiallingNumbers.cancelImport).assertFalse();
    })

    it('Contacts_SimIccDiallingNumbersTest_savePromptSimIccIds', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockerFun: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      when(mockerFun)(ArgumentMatchers.anyString).afterReturn(['aa', 'bb']);
      await SimIccDiallingNumbers.savePromptSimIccIds();
      expect(SimIccDiallingNumbers.cancelImport).assertFalse();
      mocker.clear(sharedPreferencesUtils);
    })

    it('Contacts_SimIccDiallingNumbersTest_dealPromptSimIccIds_001', 0, async () => {
      await SimIccDiallingNumbers.dealPromptSimIccIds(0);
      expect(SimIccDiallingNumbers.cancelImport).assertFalse();
    })

    it('Contacts_SimIccDiallingNumbersTest_dealPromptSimIccIds_002', 0, async () => {
      let localSimSlots: Array<number> = [0, 1];
      SimIccDiallingNumbers.simSlots = localSimSlots;
      SimIccDiallingNumbers.simIccIds = ['0'];
      let mocker: MockKit = new MockKit();
      let mockerFun: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockerFun)(ArgumentMatchers.anyString).afterReturn(['0', '1']);
      await SimIccDiallingNumbers.dealPromptSimIccIds(0);
      expect(SimIccDiallingNumbers.cancelImport).assertFalse();
      mocker.clear(sharedPreferencesUtils);
    })

    it('Contacts_SimIccDiallingNumbersTest_clearContactData', 0, () => {
      SimIccDiallingNumbers.clearContactData();
      expect(SimIccDiallingNumbers.contactData.length).assertEqual(0);
    })

    it('Contacts_SimIccDiallingNumbersTest_sureCancelImport', 0, () => {
      SimIccDiallingNumbers.sureCancelImport();
      expect(SimIccDiallingNumbers.refreshContactsEmitterId).assertEqual(108);
    })

    it('Contacts_SimIccDiallingNumbersTest_getNumbersBySlotId', 0, () => {
      SimIccDiallingNumbers.getNumbersBySlotId(0);
      expect(SimIccDiallingNumbers.exportEmitterId).assertEqual(106);
    })
  })
}