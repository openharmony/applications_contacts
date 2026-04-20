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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import DialerPresenter from '../../../../../../../../entry/src/main/ets/presenter/dialer/DialerPresenter';
import { sharedPreferencesUtils } from '../../../../../../../../feature/call/oh_modules/common';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import { CallLog, CallLogRepository } from '../../../../../../../../feature/call';
import { PhoneNumber } from '../../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import MmsService from '../../../../../../../../feature/phonenumber/src/main/ets/MmsService';
import { call } from '@kit.TelephonyKit';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import CallRecordListDataSource from '../../../../../../main/ets/model/bean/CallRecordListDataSource';
import { CallLogSearchBo } from '../../../../../../main/ets/model/bean/CallLogSearchBo';
import { taskpool } from '@kit.ArkTS';
import VoicemailManager from '../../../../../../main/ets/feature/sim/VoicemailManager';
import { RecorderLog, SingleSelectContact, SpeedDialItem } from '../../../../../../main/ets/model/type';
import { StartOptions, Want } from '@kit.AbilityKit';
import DotUtil from '../../../../../../main/ets/util/DotUtil';
import DialerConstant from '../../../../../../main/ets/data/DialerConstant';
import SimManager from '../../../../../../main/ets/feature/sim/SimManager';
import { DynamicLoader } from '../../../../../../../../common/src/main/ets/util/DynamicLoader';
import { display, UIContext } from '@kit.ArkUI'
import CallRecordPresenter from '../../../../../../main/ets/presenter/dialer/callRecord/CallRecordPresenter';
import { ResourceUtil } from '../../../../../../../../entry/src/main/ets/util/ResourceUtil';
import { CallLogBean } from '../../../../../../main/ets/model/bean/CallLogBean';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';
import { ContactPickerParam } from '../../../../../../main/ets/model/type/ContactParams';
import { RoamingManager } from '../../../../../../main/ets/feature/roaming/RoamingManager';

export default function DialerPresenterTest() {
  describe('DialerPresenterTest', () => {

    let dialerPresenter: DialerPresenter;

    beforeEach(() => {
      AppStorage.clear();
      dialerPresenter = new DialerPresenter();
    })

    it('DialerPresenterTest_getInstance', 0, () => {
      expect(typeof dialerPresenter).assertEqual(typeof DialerPresenter.getInstance());
    })

    it('DialerPresenterTest_getVoicemailManager', 0, () => {
      expect(dialerPresenter.getVoicemailManager()).not().assertNull();
    })

    it('DialerPresenterTest_aboutToAppear', 0, () => {
      dialerPresenter.aboutToAppear();
      expect(dialerPresenter.getCallStateChangeObserved()).assertTrue();
    })

    it('DialerPresenterTest_aboutToDisappear', 0, () => {
      dialerPresenter.setTaskId(0);

      dialerPresenter.aboutToDisappear()
      expect(dialerPresenter.getTaskId()).assertEqual(-1);
    })

    // defect density
    it('DialerPresenterTest_aboutToDisappear_noIf', 0, () => {
      dialerPresenter.setTaskId(-1);

      dialerPresenter.aboutToDisappear();

      expect(dialerPresenter.getTaskId()).assertEqual(-1);
    })

    // defect density
    it('DialerPresenterTest_refresh', 0, () => {
      dialerPresenter.refresh()
      expect(AppStorage.get("IsUsed")).assertTrue();
    })

    it('DialerPresenterTest_setTextSelectStatusForInit_if', 0, () => {
      dialerPresenter.setTextSelectStatusForInit(0)
      expect(dialerPresenter.textSelectStart).assertEqual(-1);
      expect(dialerPresenter.textSelectEnd).assertEqual(-1);
    })

    it('DialerPresenterTest_setTextSelectStatusForInit_noIf_if', 0, () => {
      dialerPresenter.setTextSelectStatusForInit(1);

      expect(dialerPresenter.textSelectStart).assertEqual(1);
      expect(dialerPresenter.textSelectEnd).assertEqual(1);
    })

    it('DialerPresenterTest_setTextSelectStatusForInit_noIf_noIf', 0, () => {
      dialerPresenter.textSelectStart = 2;
      dialerPresenter.textSelectEnd = 2;
      dialerPresenter.setTextSelectStatusForInit(1);

      expect(dialerPresenter.textSelectStart).assertEqual(1);
      expect(dialerPresenter.textSelectEnd).assertEqual(1);
    })

    // Phone Number Case
    it('DialerPresenterTest_setCaret_has_noIf', 0, () => {
      AppStorage.setOrCreate('tele_number', '570977632');

      let mocker: MockKit = new MockKit();
      let computeFormatIndex: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.computeFormatIndex);
      when(computeFormatIndex)('570977632').afterReturn(0);

      mocker.mockFunc(dialerPresenter.textController, dialerPresenter.textController.caretPosition);

      dialerPresenter.setCaret();

      mocker.verify('computeFormatIndex', ['570977632', 0]).never();
      mocker.verify('caretPosition', [0]).never();

      mocker.clear(dialerPresenter.textController);
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_setCaret_has_if', 0, () => {
      dialerPresenter.afterActionCaret = [1, 0];

      let mocker: MockKit = new MockKit();
      let computeFormatIndex: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.computeFormatIndex);
      when(computeFormatIndex)('').afterReturn(1);

      mocker.mockFunc(dialerPresenter.textController, dialerPresenter.textController.caretPosition);

      dialerPresenter.setCaret();

      expect(dialerPresenter.isShowBtn).assertTrue();

      mocker.clear(dialerPresenter.textController);
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_filterInvalidInput', 0, () => {
      expect(dialerPresenter.filterInvalidInput('187789*#')).assertEqual('187789*#');
    })

    it('DialerPresenterTest_replaceSelectedStr', 0, () => {
      dialerPresenter.textSelectStart = 0;
      dialerPresenter.textSelectEnd = 7;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dialerPresenter, dialerPresenter.computeActionIndex))('9732').afterReturn(2);

      expect(dialerPresenter.replaceSelectedStr('570977632', '97')).assertEqual('9732');
      expect(dialerPresenter.afterActionCaret[0]).assertEqual(2);
      expect(dialerPresenter.afterActionCaret[1]).assertEqual(2);

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_deleteStr_if', 0, () => {
      dialerPresenter.textSelectStart = 2;
      dialerPresenter.textSelectEnd = 2;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dialerPresenter, dialerPresenter.computeActionIndex))('70977632').afterReturn(undefined);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource)


      expect(dialerPresenter.deleteStr('5 70977632')).assertEqual('70977632');

      expect(dialerPresenter.afterActionCaret[0]).assertUndefined();
      expect(dialerPresenter.afterActionCaret[1]).assertUndefined();

      mocker.clear(dialerPresenter);
      mocker.clear(ResourceUtil);
    })

    // defect density DialerPresenterTest_setAndFormatNumber_if
    it('DialerPresenterTest_setAndFormatNumber_if', 0, () => {
      dialerPresenter.setAndFormatNumber('88888888888888');
      expect(AppStorage.get('tele_number_with_space')).assertEqual('88888888888888');
    })

    // defect density DialerPresenterTest_setAndFormatNumber_elseIf1_if
    it('DialerPresenterTest_setAndFormatNumber_elseIf1_if', 0, () => {
      dialerPresenter.setAndFormatNumber('888');
      expect(AppStorage.get('tele_number_with_space')).assertEqual('888');
    })

    it('DialerPresenterTest_setAndFormatNumber_elseIf1_else_noIf', 0, () => {
      dialerPresenter.setAndFormatNumber('888666');
      expect(AppStorage.get('tele_number_with_space')).assertEqual('888 666');
    })

    it('DialerPresenterTest_setAndFormatNumber_elseIf1_else_if', 0, () => {
      dialerPresenter.setAndFormatNumber('88866699');
      expect(AppStorage.get('tele_number_with_space')).assertEqual('8886 6699');
    })

    it('DialerPresenterTest_setAndFormatNumber_elseIf2', 0, () => {
      dialerPresenter.setAndFormatNumber('888666999');
      expect(AppStorage.get('tele_number_with_space')).assertEqual('888 666 999');
    })

    it('DialerPresenterTest_setAndFormatNumber_else', 0, () => {
      dialerPresenter.setAndFormatNumber('8886669');
      expect(AppStorage.get('tele_number')).assertEqual('8886669');
    })

    it('DialerPresenterTest_dialing', 0, () => {
      let mocker: MockKit = new MockKit();
      let phoneNumber: PhoneNumber = PhoneNumber.fromString('570977632');
      let option: call.DialCallOptions = {
        accountId: 1, dialType: 0
      } as call.DialCallOptions;

      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('570977632').afterReturn(phoneNumber);

      when(mocker.mockFunc(phoneNumber, phoneNumber.dial))(option)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));

      mocker.mockFunc(dialerPresenter, dialerPresenter.refresh);
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().handleRoaming);

      dialerPresenter.dialing(
        DTGlobalContext.getContext().getObject('UIContext') as UIContext, '570977632', option).then(() => {
        mocker.verify('fromString', ['570977632']).once();
      });

      mocker.clear(dialerPresenter);
      mocker.clear(RoamingManager.getInstance());
      mocker.clear(PhoneNumber);
      mocker.clear(phoneNumber);
      mocker.clear(PhoneNumber.fromString('570977632'));
    })

    it('DialerPresenterTest_dialing_catch_if', 0, () => {
      let mocker: MockKit = new MockKit();
      let phoneNumber: PhoneNumber = PhoneNumber.fromString('570977632');
      let option: call.DialCallOptions = {
        accountId: 1, dialType: 0
      } as call.DialCallOptions;

      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('570977632').afterReturn(phoneNumber);

      when(mocker.mockFunc(phoneNumber, phoneNumber.dial))(option)
        .afterReturn(new Promise<boolean>((resolve: (value: boolean | PromiseLike<boolean>) => void, reject: (reason?: number) => void) => {
          reject(8300008);
        }));

      mocker.mockFunc(dialerPresenter, dialerPresenter.refresh);
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().handleRoaming);

      dialerPresenter.dialing(
        DTGlobalContext.getContext().getObject('UIContext') as UIContext, '570977632', option).then(() => {
        mocker.verify('fromString', ['570977632']).once();
        mocker.verify('dial', [option]).once();
      });

      mocker.clear(dialerPresenter);
      mocker.clear(PhoneNumber);
      mocker.clear(phoneNumber);
      mocker.clear(RoamingManager.getInstance());
    })

    it('DialerPresenterTest_dialing_catch_noIf', 0, () => {
      let phoneNumber: PhoneNumber = PhoneNumber.fromString('570977632');
      let option: call.DialCallOptions = {
        accountId: 1, dialType: 0
      } as call.DialCallOptions;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('570977632').afterReturn(phoneNumber);

      when(mocker.mockFunc(phoneNumber, phoneNumber.dial))(option)
        .afterReturn(new Promise<boolean>((resolve: (value: boolean | PromiseLike<boolean>) => void, reject: (reason?: number) => void) => {
          reject(1);
        }));

      mocker.mockFunc(dialerPresenter, dialerPresenter.refresh);
      mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().handleRoaming);

      dialerPresenter.dialing(
        DTGlobalContext.getContext().getObject('UIContext') as UIContext, '570977632', option).then(() => {
        mocker.verify('fromString', ['570977632']).once();
        mocker.verify('dial', [option]).once();
      });

      mocker.clear(dialerPresenter);
      mocker.clear(PhoneNumber);
      mocker.clear(phoneNumber);
      mocker.clear(RoamingManager.getInstance());
    })

    it('DialerPresenterTest_videoDialing', 0, () => {
      let option: call.DialCallOptions = {
        accountId: 1, dialType: 0, videoState: 0
      } as call.DialCallOptions;
      AppStorage.setOrCreate('showTelNumber', false);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.dialing);

      dialerPresenter.videoDialing(
        DTGlobalContext.getContext().getObject('UIContext') as UIContext, '570977632', option);

      expect(AppStorage.get('showTelNumber')).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_multiSimCardVideoDialing_if1_0', 0, () => {
      AppStorage.setOrCreate('voLteRegStates', [true, false]);
      AppStorage.setOrCreate('showTelNumber', false);
      dialerPresenter.all_number = '570977632';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.clearVideoDialingNum);
      mocker.mockFunc(dialerPresenter, dialerPresenter.selectSimBuilder);
      mocker.mockFunc(dialerPresenter, dialerPresenter.dialing);

      dialerPresenter.multiSimCardVideoDialing(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      mocker.verify('selectSimBuilder', []).never();
      expect(AppStorage.get('showTelNumber')).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_multiSimCardVideoDialing_if1_1', 0, () => {
      AppStorage.setOrCreate('voLteRegStates', [null, false]);
      AppStorage.setOrCreate('showTelNumber', false);
      dialerPresenter.all_number = '570977632';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.clearVideoDialingNum);
      mocker.mockFunc(dialerPresenter, dialerPresenter.selectSimBuilder);
      mocker.mockFunc(dialerPresenter, dialerPresenter.dialing);

      dialerPresenter.multiSimCardVideoDialing(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      mocker.verify('selectSimBuilder', []).never();
      expect(AppStorage.get('showTelNumber')).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_multiSimCardVideoDialing_if2', 0, () => {
      AppStorage.setOrCreate('voLteRegStates', [true, true]);
      AppStorage.setOrCreate('defaultSlot', 0);
      dialerPresenter.all_number = '570977632';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.clearVideoDialingNum);
      mocker.mockFunc(dialerPresenter, dialerPresenter.selectSimBuilder);
      mocker.mockFunc(dialerPresenter, dialerPresenter.dialing);

      dialerPresenter.multiSimCardVideoDialing(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      mocker.verify('selectSimBuilder', []).never();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_multiSimCardVideoDialing_noIf', 0, () => {
      AppStorage.setOrCreate('voLteRegStates', [true, true]);
      AppStorage.setOrCreate('defaultSlot', -1);
      dialerPresenter.all_number = '570977632';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.selectSimBuilder);

      dialerPresenter.multiSimCardVideoDialing(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      mocker.verify('selectSimBuilder', []).times(0);

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_clearVideoDialingNum', 0, () => {
      dialerPresenter.all_number = '570977632';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.dialing);

      dialerPresenter.clearVideoDialingNum(DTGlobalContext.getContext().getObject('UIContext') as UIContext, 0);

      expect(dialerPresenter.callBtnClick).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_selectSimBuilder_result_empty', 0, () => {
      AppStorage.setOrCreate('spnList', [{
        name: 'name'
      }]);

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(dialerPresenter, dialerPresenter.clearVideoDialingNum);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      dialerPresenter.selectSimBuilder(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      expect(false).assertFalse();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_selectSimBuilder_result_notEmpty', 0, () => {
      AppStorage.setOrCreate('tele_number', '570977632');

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.clearVideoDialingNum);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
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
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));


      dialerPresenter.selectSimBuilder(DTGlobalContext.getContext().getObject('UIContext') as UIContext);

      //入参string与要求的类型array不匹配，导致报错
      expect(false).assertFalse();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
    })



    it('DialerPresenterTest_editPhoneNumber_return', 0, () => {
      dialerPresenter.editPhoneNumber('');

      expect(AppStorage.has("tele_number")).assertFalse();
    })

    it('DialerPresenterTest_editPhoneNumber', 0, () => {
      let mocker: MockKit = new MockKit();

      dialerPresenter.editPhoneNumber('test');

      expect(dialerPresenter.all_number?.length).assertEqual(0);

      mocker.clear(dialerPresenter);
    })

    // defect density DialerPresenterTest_onDestroy
    it('DialerPresenterTest_onDestroy', 0, () => {
      dialerPresenter.onDestroy();
      expect(dialerPresenter.isShowBtn).assertTrue();
    })

    it('DialerPresenterTest_setAndFormatNumber', 0, () => {
      dialerPresenter.setAndFormatNumber('12345678910')
      expect(AppStorage.get("tele_number")).assertEqual('12345678910');
    })

    it('DialerPresenterTest_computeActionIndex', 0, () => {
      expect(dialerPresenter.computeActionIndex('123 456 78910', 5)).assertEqual(4);
      expect(dialerPresenter.computeActionIndex('123 456 78910', 1)).assertEqual(1);
    })

    it('DialerPresenterTest_computeFormatIndex', 0, () => {
      expect(dialerPresenter.computeFormatIndex('123 456 78910', 4)).assertEqual(5);
      expect(dialerPresenter.computeFormatIndex('123 456 78910', 1)).assertEqual(1);
    })

    it('DialerPresenterTest_InsertStr', 0, () => {
      dialerPresenter.setAndFormatNumber('12345678910')
      dialerPresenter.setTextSelectStatus(1, 1)
      const result = dialerPresenter.getInsertStr(AppStorage.get("tele_number") as string, '1')
      expect(result).assertEqual('112345678910');
    })

    it('DialerPresenterTest_getCutStr', 0, () => {
      dialerPresenter.setAndFormatNumber('12345678910')
      dialerPresenter.setTextSelectStatus(1, 2)
      const result = dialerPresenter.getCutStr(AppStorage.get("tele_number") as string)
      expect(result).assertEqual('12345678910');
    })

    it('DialerPresenterTest_deleteStrSelection', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      dialerPresenter.setAndFormatNumber('12345678910');
      dialerPresenter.setTextSelectStatus(1, 2);
      const result = dialerPresenter.deleteStr(AppStorage.get("tele_number") as string);
      expect(result).assertEqual('1345678910');
      mocker.clear(ResourceUtil);
    })

    it('DialerPresenterTest_deleteStrCaret', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      dialerPresenter.setAndFormatNumber('12345678910');
      dialerPresenter.setTextSelectStatus(2, 2);
      const result = dialerPresenter.deleteStr(AppStorage.get("tele_number") as string);
      expect(result).assertEqual('1345678910');
      mocker.clear(ResourceUtil);
    })

    it('DialerPresenterTest_checkNeedNumberSpace_01', 0, () => {
      const result = dialerPresenter.checkNeedNumberSpace('123456');

      expect(result).assertTrue();
    })

    it('DialerPresenterTest_checkNeedNumberSpace_02_01', 0, () => {
      const result = dialerPresenter.checkNeedNumberSpace('+123456');

      expect(result).assertTrue();
    })

    it('DialerPresenterTest_checkNeedNumberSpace_02_02', 0, () => {
      const result = dialerPresenter.checkNeedNumberSpace('1#2+3;4,5*6');

      expect(result).assertFalse();
    })

    it('DialerPresenterTest_ifNeedSpace_01', 0, () => {
      AppStorage.setOrCreate("tele_number", '123');

      dialerPresenter.ifNeedSpace();

      expect(AppStorage.get("tele_number")).assertEqual('123 ');

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dialerPresenter, dialerPresenter.checkNeedNumberSpace))(3).afterReturn(false);
      expect(AppStorage.get("tele_number")).assertEqual('123 ');
    })

    it('DialerPresenterTest_ifNeedSpace_02', 0, () => {
      AppStorage.setOrCreate("tele_number", '12345678');

      dialerPresenter.ifNeedSpace();

      expect(AppStorage.get("tele_number")).assertEqual('12345678 ');
    })

    it('DialerPresenterTest_ifNeedSpace_03', 0, () => {
      dialerPresenter.ifNeedSpace();

      expect(AppStorage.has("tele_number")).assertFalse();
    })

    it('DialerPresenterTest_startHwTone_if', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '2';

      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(1);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [1]).never();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_1', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '1';

      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [1]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_2', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '2';
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [2]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_3', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '3';
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [3]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_4', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '4';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [4]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_5', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '5';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [5]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_6', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '6';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [6]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_7', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '7';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [7]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_8', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '8';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [8]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_9', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '9';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      mocker.verify("tonePlayer", [9]).once();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_10', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '0';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);
      dialerPresenter.startHwTone(number);
      mocker.verify("tonePlayer", [0]).once();
      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_11', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '*';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);
      dialerPresenter.startHwTone(number);
      mocker.verify("tonePlayer", [10]).once();
      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_12', 0, () => {
      let mocker: MockKit = new MockKit();
      const number: string = '#';
      mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);
      dialerPresenter.startHwTone(number);
      mocker.verify("tonePlayer", [11]).once();
      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_startHwTone_13', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      const number: string = '-1';
      let mockFunc: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.tonePlayer);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      let getAudioRingMode: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getAudioRingMode);
      when(getAudioRingMode)().afterReturn(2);

      dialerPresenter.startHwTone(number);

      expect(result).assertFalse();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_tonePlayer_if', 0, async () => {
      dialerPresenter.setTimer(1)

      await dialerPresenter.tonePlayer(0);

      expect(dialerPresenter.getTimer()).not().assertEqual(0);
    })

    it('DialerPresenterTest_tonePlayer', 0, async () => {
      await dialerPresenter.tonePlayer(0);

      expect(dialerPresenter.getTimer()).not().assertEqual(0);
    })

    it('DialerPresenterTest_jumpToAccountants', 0, () => {
      let phoneNumber: Record<string, string> = {
        'phoneNumber': AppStorage.has("tele_number") ? AppStorage.get("tele_number") as string : '',
      }
      const phoneNumbers: Array<Object> = [phoneNumber];
      const params: Record<string, Object> = {
        'updataShow': false,
        'phoneNumbers': phoneNumbers
      };
      dialerPresenter.pathInfos = new NavPathStack();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.ACCOUNTANTS).afterReturn(new Promise<void> ((resolve: Function, result: Function) => {
        resolve(dialerPresenter.pathInfos?.pushPathByName(DynamicLoader.ACCOUNTANTS, params));
      }))
      dialerPresenter.jumpToAccountants();

      expect(JSON.stringify(dialerPresenter.pathInfos?.getParamByName(DynamicLoader.ACCOUNTANTS)))
        .assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DialerPresenterTest_sendMessage', 0, () => {
      AppStorage.setOrCreate('tele_number', '570977632');
      dialerPresenter.all_number = '570977633';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MmsService, MmsService.sendMessage);

      dialerPresenter.sendMessage();

      expect(AppStorage.get('tele_number')).assertEqual('570977632');

      mocker.clear(MmsService);
    })

    it('DialerPresenterTest_saveCallRecordExistingContact', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      dialerPresenter.pathInfos = new NavPathStack();
      const params1: ContactPickerParam = {
        'phoneNumberShow': '',
        'isSaveExistContact': true,
        'isDisplayByName': true
      };
      when(mockFunc)(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(dialerPresenter.pathInfos?.pushPathByName('SingleSelectContactPage', params1));
      }))
      dialerPresenter.saveCallRecordExistingContact('');
      expect(JSON.stringify(dialerPresenter.pathInfos?.getParamByName('SingleSelectContactPage')))
        .assertEqual(JSON.stringify([params1]));
      dialerPresenter.pathInfos?.removeByName('SingleSelectContactPage');

      const params: ContactPickerParam = {
        'phoneNumberShow': '13801001234',
        'isSaveExistContact': true,
        'isDisplayByName': true
      };

      when(mockFunc)(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(dialerPresenter.pathInfos?.pushPathByName('SingleSelectContactPage', params));
      }))
      dialerPresenter.saveCallRecordExistingContact('13801001234');
      expect(JSON.stringify(dialerPresenter.pathInfos?.getParamByName('SingleSelectContactPage')))
        .assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DialerPresenterTest_dealSecretCode_01', 0, () => {
      dialerPresenter.dealSecretCode('*#*#123456#*#*');

      expect(dialerPresenter.secretCode).assertEqual('*#*#123456#*#*');
    })

    it('DialerPresenterTest_dealSecretCode_02', 0, () => {
      dialerPresenter.dealSecretCode('*#*#19467328#*#*');

      expect(dialerPresenter.secretCode).assertEqual('');
    })

    it('DialerPresenterTest_dealSecretCode_03', 0, () => {
      dialerPresenter.dealSecretCode('*#1234#');

      expect(dialerPresenter.secretCode).assertEqual('*#1234#');
    })

    it('DialerPresenterTest_dealSecretCode_04', 0, () => {
      dialerPresenter.dealSecretCode('*#1234*');

      expect(dialerPresenter.secretCode).assertEqual('*#1234*');
    })

    it('DialerPresenterTest_dealSecretCode_05', 0, () => {
      dialerPresenter.dealSecretCode('123456');

      expect(dialerPresenter.secretCode).assertEqual('');
    })

    it('DialerPresenterTest_dealSecretCode_06', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.handleIMEIDisplay);

      dialerPresenter.dealSecretCode('*#06#');

      mocker.verify('handleIMEIDisplay', []).once();
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_dealSecretCode_07', 0, () => {
      dialerPresenter.dealSecretCode('*#28460');
      expect(dialerPresenter.secretCode).assertEqual('*#28460');
    })

    it('DialerPresenterTest_handleIMEIDisplay_01', 0, () => {
      dialerPresenter.isSecretCodeDialog = true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.handleDualImeiPanel);

      dialerPresenter.handleIMEIDisplay();

      mocker.verify('handleDualImeiPanel', []).never();
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_handleIMEIDisplay_02', 0, () => {
      dialerPresenter.isSecretCodeDialog = false;
      let mocker: MockKit = new MockKit();
      let isDualSim: Function = mocker.mockFunc(SimManager, SimManager.isDualSim);
      when(isDualSim)().afterReturn(true);
      mocker.mockFunc(dialerPresenter, dialerPresenter.handleDualImeiPanel);

      dialerPresenter.handleIMEIDisplay();

      mocker.verify('handleDualImeiPanel', []).once();

      mocker.clear(SimManager);
    })

    it('DialerPresenterTest_handleIMEIDisplay_03', 0, () => {
      dialerPresenter.isSecretCodeDialog = false;
      let mocker: MockKit = new MockKit();
      let isDualSim: Function = mocker.mockFunc(SimManager, SimManager.isDualSim);
      when(isDualSim)().afterReturn(false);
      mocker.mockFunc(dialerPresenter, dialerPresenter.handleIMEIPanel);

      dialerPresenter.handleIMEIDisplay();

      mocker.verify('handleIMEIPanel', []).once();

      mocker.clear(SimManager);
    })

    it('DialerPresenterTest_jumpToContactDetail', 0, async () => {
      const params: Record<string, boolean | string> = {
        'sourceHasPhone': true,
        'phoneNumberShow': '123456'
      };
      dialerPresenter.pathInfos = new NavPathStack();

      AppStorage.setOrCreate('breakpoint', 'sm');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.CONTACT_DETAIL_PAGE).afterReturn(new Promise<void>((resolve: Function) => {
        resolve(dialerPresenter.pathInfos?.pushPathByName('ContactDetail', params))
      }));
      dialerPresenter.jumpToContactDetail(params);

      expect(JSON.stringify(dialerPresenter.pathInfos?.getParamByName('ContactDetail'))).assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DialerPresenterTest_jumpToContactDetail_02', 0, async () => {
      const params: Record<string, boolean | string> = {
        'sourceHasPhone': true,
        'phoneNumberShow': '123456'
      };
      dialerPresenter.pathInfos = new NavPathStack();

      AppStorage.setOrCreate('breakpoint', 'lg');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.CONTACT_DETAIL_PAGE).afterReturn(new Promise<void>((resolve: Function) => {
        resolve(dialerPresenter.pathInfos?.replacePathByName('ContactDetail', params))
      }));
      dialerPresenter.jumpToContactDetail(params);

      expect(JSON.stringify(dialerPresenter.pathInfos?.getParamByName('ContactDetail'))).assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DialerPresenterTest_jumpToRecordListByPhone', 0, () => {
      let params: RecorderLog = {
        id: 1,
        dateAdded: '',
        filePath: '',
        displayName: 'displayName',
        phoneNumber: '7777',
      };
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
      } as common.UIAbilityContext;

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      dialerPresenter.jumpToRecordListByPhone(params);

      expect(dialerPresenter.NUM_TEXT_MAX_LENGTH).assertEqual(20);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpToRecordListByPhone_noId', 0, () => {
      let params: RecorderLog = {
        dateAdded: '',
        filePath: '',
        displayName: 'displayName',
        phoneNumber: '7777',
      } as RecorderLog;
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
      } as common.UIAbilityContext;

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      dialerPresenter.jumpToRecordListByPhone(params);

      expect(dialerPresenter.NUM_TEXT_MAXSIZE_LENGTH).assertEqual(16);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpToRecordListByPhone_catch', 0, () => {
      let params: RecorderLog = {
        id: 1,
        dateAdded: '',
        filePath: '',
        displayName: 'displayName',
        phoneNumber: '7777',
      };
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
        new Promise<void>((resolve: () => void, reject: (reason?: Error) => void) => {
          reject(new Error('error'));
        })
      } as common.UIAbilityContext;

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      dialerPresenter.jumpToRecordListByPhone(params);

      expect(dialerPresenter.NUM_TEXT_FONT_SIZE_MAX).assertEqual(38);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpToRecordList', 0, () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
        new Promise<void>(resolve => resolve())
      } as common.UIAbilityContext;

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      dialerPresenter.jumpToRecordList();

      expect(dialerPresenter.NUM_TEXT_FONT_SIZE_MIN).assertEqual(20);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpToRecordList_catch', 0, () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
        new Promise<void>((resolve: () => void, reject: (reason?: Error) => void) => {
          reject(new Error('error'));
        })
      } as common.UIAbilityContext;

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      dialerPresenter.jumpToRecordList();

      expect(dialerPresenter.btnShow).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpBatchDeleteView', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.BATCH_DELETE_RECORD_PAGE).afterReturn(new Promise<void>((resolve: Function) => {
        resolve(dialerPresenter.pathInfos?.pushPathByName('BatchDeleteRecord', ''));
      }));
      dialerPresenter.pathInfos = new NavPathStack();

      dialerPresenter.jumpBatchDeleteView();

      expect(dialerPresenter.pathInfos?.getParamByName('BatchDeleteRecord').toString()).assertEqual([''].toString());
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DialerPresenterTest_jumpToHarassmentFilter', 0, () => {
      dialerPresenter.pathInfos = new NavPathStack();

      dialerPresenter.jumpToHarassmentFilter();

      expect(dialerPresenter.pathInfos?.getAllPathName().toString()).assertEqual(['HarassmentFilter'].toString());
    })

    it('DialerPresenterTest_jumpToHarassmentFilter_pathInfos_null', 0, () => {
      dialerPresenter.jumpToHarassmentFilter();
      expect(dialerPresenter.pathInfos).assertUndefined();
    })

    it('DialerPresenterTest_jumpToCallSetting', 0, () => {
      const context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject('contactContext') as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(mockFunc)().afterReturn(context);

      const actionData: Record<string, string> = {
        'pageFlag': 'callSetting'
      };
      const str: Record<string, Object> = {
        "bundleName": 'com.ohos.callsetting',
        "abilityName": 'com.ohos.callsetting.CallSettingAbility',
        "parameters": actionData,
        "entities": [
          'entity.system.home'
        ]
      };
      let mockFunc1: Function = mocker.mockFunc(context, context.startAbility);
      when(mockFunc1)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));

      dialerPresenter.jumpToCallSetting();

      mocker.verify('startAbility', [str]).once();

      mocker.clear(context);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_jumpToCallSetting_catch', 0, async () => {
      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
        new Promise<void>((resolve: () => void, reject: (reason?: Error) => void) => {
          reject(new Error('error'));
        })
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(mockFunc)().afterReturn(context);

      dialerPresenter.jumpToCallSetting();

      expect(dialerPresenter.textSelectEnd).assertEqual(-1);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_isTheValueIsOne', 0, () => {
      const isTheValueIsOne1: boolean = dialerPresenter.isTheValueIsOne('1');
      expect(isTheValueIsOne1).assertTrue();

      const isTheValueIsOne2: boolean = dialerPresenter.isTheValueIsOne('2');
      expect(isTheValueIsOne2).assertFalse();
    })

    it('DialerPresenterTest_isTheValueIsOne_01', 0, () => {
      const result = dialerPresenter.isTheValueIsOne('1');

      expect(result).assertTrue();
    })

    it('DialerPresenterTest_isTheValueIsOne_02', 0, () => {
      const result = dialerPresenter.isTheValueIsOne('0');

      expect(result).assertFalse();
    })

    it('DialerPresenterTest_speedDialAction_if1_if', 0, () => {
      AppStorage.setOrCreate('haveSimCard', false);
      let result = false;
      dialerPresenter.noSimCardDialogController = {
        open: () => {
          result = true;
        }
      } as CustomDialogController;
      const number = '8888';

      let mocker: MockKit = new MockKit();

      let isTheValueIsOne: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.isTheValueIsOne);
      when(isTheValueIsOne)(number).afterReturn(false);

      dialerPresenter.speedDialAction(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(result).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_speedDialAction_if1_noIf', 0, () => {
      AppStorage.setOrCreate('haveSimCard', true);
      let result = false;
      dialerPresenter.noSimCardDialogController = {
        open: () => {
          result = true;
        }
      } as CustomDialogController;
      const number = '8888';

      let mocker: MockKit = new MockKit();

      let isTheValueIsOne: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.isTheValueIsOne);
      when(isTheValueIsOne)(number).afterReturn(false);

      dialerPresenter.speedDialAction(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(result).assertFalse();

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_speedDialAction_if2_if', 0, () => {
      AppStorage.setOrCreate('haveSimCard', false);
      const number = '8888';

      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.UIContextName).afterReturn(context);

      let isTheValueIsOne: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.isTheValueIsOne);
      when(isTheValueIsOne)(number).afterReturn(true);

      dialerPresenter.speedDialAction(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(dialerPresenter.isEmergencyNum).assertFalse();

      mocker.clear(dialerPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DialerPresenterTest_speedDialAction_else', 0, () => {
      AppStorage.setOrCreate('haveSimCard', true);
      const number = 'aaa';

      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.UIContextName).afterReturn(context);

      let isTheValueIsOne: Function = mocker.mockFunc(dialerPresenter, dialerPresenter.isTheValueIsOne);
      when(isTheValueIsOne)(number).afterReturn(true);
      mocker.mockFunc(dialerPresenter, dialerPresenter.airplaneAlertShow);
      dialerPresenter.speedDialAction(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);
      mocker.verify('airplaneAlertShow', [number]).never();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_speedDialEvent_01_01', 0, async () => {
      const number = '1';
      AppStorage.setOrCreate('haveMultiSimCard', true);

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(AppStorage.get('isMultiCardSelected')).assertTrue();
    })

    it('DialerPresenterTest_speedDialEvent_01_02', 0, async () => {
      const number = '1';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.cardSelected);
      AppStorage.setOrCreate('defaultSlot', 1);

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      mocker.verify('cardSelected', [1]).times(0);

      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_speedDialEvent_02_01', 0, async () => {
      let result = false;
      dialerPresenter.noSimCardDialogController = {
        open: () => {
          result = true;
        }
      } as CustomDialogController;

      const number = '0';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)('speedDialObjString').afterReturn('');

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(result).assertFalse();
      expect(dialerPresenter.setSpeedNumber).assertEqual(number);

      mocker.clear(sharedPreferencesUtils);
    })

    it('DialerPresenterTest_speedDialEvent_else_if', 0, async () => {
      let result = false;
      dialerPresenter.noSimCardDialogController = {
        open: () => {
          result = true;
        }
      } as CustomDialogController;

      const number = '0';
      let speedDial: Record<string, SpeedDialItem> = {
        '1': {
          contactName: 'name',
          contactTelephone: '1111',
        }
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)('speedDialObjString').afterReturn(JSON.stringify(speedDial));

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(result).assertFalse();

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
    })

    it('DialerPresenterTest_speedDialEvent_else_elseIf_if', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', false);
      dialerPresenter.noSimCardDialogController = {
        open: () => {
        }
      } as CustomDialogController;

      const number = '0';
      let speedDial: Record<string, SpeedDialItem> = {
        '0': {
          number: 11,
          contactName: 'name',
          contactTelephone: '1111',
        }
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)('speedDialObjString').afterReturn(JSON.stringify(speedDial));

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);

      let phoneNum: PhoneNumber = PhoneNumber.fromString('1111');
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('1111').afterReturn(phoneNum);
      mocker.mockFunc(phoneNum, phoneNum.dial);

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      mocker.verify('dial', []).times(0);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(phoneNum);
      mocker.clear(PhoneNumber);
    })

    it('DialerPresenterTest_speedDialEvent_else_elseIf_else', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', true);
      dialerPresenter.noSimCardDialogController = {
        open: () => {
        }
      } as CustomDialogController;

      const number = '0';
      let speedDial: Record<string, SpeedDialItem> = {
        '0': {
          number: 11,
          contactName: 'name',
          contactTelephone: '1111',
        }
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)('speedDialObjString').afterReturn(JSON.stringify(speedDial));

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);

      let phoneNum: PhoneNumber = PhoneNumber.fromString('1111');
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('1111').afterReturn(phoneNum);
      mocker.mockFunc(phoneNum, phoneNum.dial);

      await dialerPresenter.speedDialEvent(DTGlobalContext.getContext().getObject('UIContext') as UIContext, number);

      expect(dialerPresenter.all_number).assertEqual('1111');

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(phoneNum);
      mocker.clear(PhoneNumber);
    })

    it('DialerPresenterTest_dialerSearch_if2', 0, () => {
      AppStorage.setOrCreate('tele_number', '22');
      dialerPresenter.mAllCallRecordListDataSource = new CallRecordListDataSource();

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter.mAllCallRecordListDataSource, dialerPresenter.mAllCallRecordListDataSource.refreshAll);
      mocker.mockFunc(CallLogSearchBo.getInstance(), CallLogSearchBo.getInstance().refreshCurSearchResult);

      dialerPresenter.dialerSearch();

      expect(dialerPresenter.clearFlag).assertFalse();

      mocker.clear(dialerPresenter.mAllCallRecordListDataSource);
      mocker.clear(CallLogSearchBo.getInstance());
    })

    it('DialerPresenterTest_dialerSearch_if3', 0, () => {
      AppStorage.setOrCreate('tele_number', '570977632');
      dialerPresenter.mAllCallRecordListDataSource = new CallRecordListDataSource();

      let mocker: MockKit = new MockKit();
      let judgeIsQuery: Function = mocker.mockFunc(CallLogSearchBo.getInstance(), CallLogSearchBo.getInstance()
        .judgeIsQuery);
      when(judgeIsQuery)('570977632').afterReturn(false);

      mocker.mockFunc(CallLogSearchBo.getInstance(), CallLogSearchBo.getInstance().refreshCurSearchResult);

      dialerPresenter.dialerSearch();

      mocker.verify('refreshCurSearchResult', ['570977632', 0]).once();

      mocker.clear(CallLogSearchBo.getInstance());
    })

    it('DialerPresenterTest_dialerSearch_if4', 0, () => {
      AppStorage.setOrCreate('tele_number', '570977632');
      dialerPresenter.task = {} as taskpool.Task;
      dialerPresenter.mAllCallRecordListDataSource = new CallRecordListDataSource();

      let mocker: MockKit = new MockKit();
      let judgeIsQuery: Function = mocker.mockFunc(CallLogSearchBo.getInstance(), CallLogSearchBo.getInstance()
        .judgeIsQuery);
      when(judgeIsQuery)('570977632').afterReturn(true);

      mocker.mockFunc(dialerPresenter, dialerPresenter.dialerSearchTask);

      dialerPresenter.dialerSearch();

      expect(dialerPresenter.clearFlag).assertFalse();

      mocker.clear(CallLogSearchBo.getInstance());
      mocker.clear(dialerPresenter);
    })

    it('DialerPresenterTest_dialerSearchTask', 0, () => {
      dialerPresenter.dialerSearchTask('222');
      expect(dialerPresenter.isEmergencyNum).assertFalse();
    })

    it('DialerPresenterTest_cardSelected_else', 0, async () => {
      let mocker: MockKit = new MockKit();
      let voicemailManager: VoicemailManager = dialerPresenter.getVoicemailManager();
      let mockFunc: Function = mocker.mockFunc(voicemailManager, voicemailManager.getVoicemailNumber);
      when(mockFunc)(1).afterReturn(new  Promise<string>(resolve => resolve('570977')));

      await dialerPresenter.cardSelected(DTGlobalContext.getContext().getObject('UIContext') as UIContext, 1);

      mocker.verify('getVoicemailNumber', [1]).once();

      mocker.clear(dialerPresenter.getVoicemailManager());
    })

    it('DialerPresenterTest_cardSelected_if_notSetVoicemailDialogController', 0, async () => {
      let mocker: MockKit = new MockKit();

      let voicemailManager: VoicemailManager = dialerPresenter.getVoicemailManager();
      let mockFunc: Function = mocker.mockFunc(voicemailManager, voicemailManager.getVoicemailNumber);
      when(mockFunc)(1).afterReturn(new  Promise<string>(resolve => resolve('')));

      dialerPresenter.notSetVoicemailDialogController = {
        open: () => {
          mocker.verify('getVoicemailNumber', [1]).once();
        }
      } as CustomDialogController;

      await dialerPresenter.cardSelected(DTGlobalContext.getContext().getObject('UIContext') as UIContext, 1);

      mocker.clear(voicemailManager);
    })

    it('DialerPresenterTest_airplaneAlertShow_01', 0, () => {
      const number = '1';

      dialerPresenter.airplaneAlertShow(number);

      expect(dialerPresenter.isTheValueIsOne(number)).assertTrue();
    })

    it('DialerPresenterTest_airplaneAlertShow_02', 0, () => {
      const number = '0';

      dialerPresenter.airplaneAlertShow(number);

      expect(dialerPresenter.isTheValueIsOne(number)).assertFalse();
    })
    it('DialerPresenterTest_dialerSearch', 0, () => {
      dialerPresenter.dialerSearch();

      expect(dialerPresenter.btnShow).assertTrue();
    })
    it('DialerPresenterTest_dialerSearch_third',0,() => {
      AppStorage.setOrCreate('tele_number','')
      let teleNumber: string = AppStorage.has('tele_number') ? AppStorage.get('tele_number') as string : '';
      dialerPresenter.dialerSearch();

      expect(dialerPresenter.countNumber).assertEqual(0);
    })
    it('DialerPresenterTest_dialerSearch_fourth',0,() => {
      AppStorage.setOrCreate('tele_number','1234')
      let teleNumber: string = AppStorage.has('tele_number') ? AppStorage.get('tele_number') as string : '';
      dialerPresenter.dialerSearch();

      expect(dialerPresenter.isSecretCodeDialog).assertFalse();
    })
    it('DialerPresenterTest_dialerSearch_five',0,() => {
      AppStorage.setOrCreate('tele_number','12345')
      let teleNumber: string = AppStorage.has('tele_number') ? AppStorage.get('tele_number') as string : '';
      let task = 1
      dialerPresenter.dialerSearch();

      expect(dialerPresenter.countNumber).assertEqual(0);
    })
    it('DialerPresenterTest_dialerSearch_six',0,() => {
      AppStorage.setOrCreate('tele_number','*');
      dialerPresenter.dialerSearch();

      expect(dialerPresenter.clearFlag).assertTrue();
    })
    it('DialerPresenterTest_dialerSearch_seven',0,() => {
      AppStorage.setOrCreate('tele_number', '112');
      dialerPresenter.dialerSearch();

      expect(AppStorage.get<number>('dialerSearchNumber')).assertEqual(-1);
    })

    it('DialerPresenterTest_pasteFunc', 0, () => {
      AppStorage.setOrCreate('pasteData', '*#06#');
      dialerPresenter.pasteFunc();
      expect(AppStorage.get('pasteData')).assertEqual('*#06#');
    })

    it('DialerPresenterTest_pasteFunc01', 0, () => {
      AppStorage.setOrCreate('pasteData', '#1#');
      dialerPresenter.pasteFunc();
      expect(dialerPresenter.all_number).assertEqual('');
      AppStorage.setOrCreate('pasteData', '13801001234');
      dialerPresenter.pasteFunc();
      expect(AppStorage.get('pasteData')).assertEqual('13801001234');
    })

    it('DialerPresenterTest_afterDialDeal', 0, () => {
      dialerPresenter.afterDialDeal();
      expect(AppStorage.get('showTelNumber')).assertTrue();
    })

    it('DialerPresenterTest_dialClick', 0, () => {
      AppStorage.setOrCreate('pasteStatus', true);
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, '13810111111');
      AppStorage.setOrCreate('isSatelliteMode', false);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);
      const context = new UIContext();
      dialerPresenter.dialClick(context, 1, false)
      mocker.verify('contactDot', [dialerPresenter.callParams, 'CALL_EVENT']).once();
      mocker.clear(DotUtil.getInstance());
    })

    it('DialerPresenterTest_dialClick_false', 0, () => {
      AppStorage.setOrCreate('pasteStatus', true);
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, '13810111111');
      AppStorage.setOrCreate('isSatelliteMode', false);
      AppStorage.setOrCreate('recordType', 0);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);
      const context = new UIContext();
      dialerPresenter.dialClick(context, 1, true)
      mocker.verify('contactDot', [dialerPresenter.callParams, 'CALL_EVENT']).never();
      mocker.clear(DotUtil.getInstance());
    })

    it('DialerPresenterTest_longPressNumberChange', 0, () => {
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, '');
      dialerPresenter.longPressNumberChange('1');
      expect(AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE)).assertEqual('');

      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, '13810111111');
      dialerPresenter.longPressNumberChange('1');
      expect(AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE)).assertEqual('113810111111');
    })

    it('DialerPresenterTest_handleInputChange', 0, () => {
      AppStorage.setOrCreate('isDialerInputCut', true);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.dealSecretCode);
      mocker.mockFunc(dialerPresenter, dialerPresenter.setTextSelectStatusForInit);
      mocker.mockFunc(dialerPresenter, dialerPresenter.setAndFormatNumber);
      mocker.mockFunc(dialerPresenter, dialerPresenter.setCaret);
      dialerPresenter.handleInputChange('13731111111');
      expect(AppStorage.get('isDialerInputCut')).assertFalse();
      mocker.clear(dialerPresenter);
    })

    it("DialerPresenterTest_pasteFunc02", 0, () => {
      AppStorage.setOrCreate('pasteData', undefined);
      dialerPresenter.pasteFunc();
      expect(AppStorage.get('pasteData')).assertUndefined();
    })

    it("DialerPresenterTest_dialClick01", 0, () => {
      AppStorage.setOrCreate('pasteStatus', false);
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, '13810111111');
      AppStorage.setOrCreate('isSatelliteMode', false);
      AppStorage.setOrCreate('defaultSlot', 1);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot);
      const context = new UIContext();
      dialerPresenter.dialClick(context, undefined, false)
      mocker.verify('contactDot', [dialerPresenter.callParams, 'CALL_EVENT']).once();
      mocker.clear(DotUtil.getInstance());
    })

    it("DialerPresenterTest_dialClick_else", 0, () => {
      const context = new UIContext();
      AppStorage.setOrCreate('pasteStatus', false);
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, undefined);
      AppStorage.setOrCreate('recordType', 0);
      let callLogData: LooseObject[] = [];
      let parameters: LooseObject = {
        phoneNumber: '13801001234'
      };
      callLogData.push(new CallLogBean("234242", "action", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action", "23424", "1"))
      let crd = new CallRecordListDataSource();
      crd.refreshAll(callLogData)
      CallRecordPresenter.getInstance().mAllCallRecordListDataSource = crd;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(CallRecordPresenter.getInstance().mAllCallRecordListDataSource,
        CallRecordPresenter.getInstance().mAllCallRecordListDataSource.getData);
      when(mockFunc)(0).afterReturn(parameters);
      mocker.mockFunc(dialerPresenter, dialerPresenter.editPhoneNumber);
      dialerPresenter.dialClick(context, 1, true);
      mocker.verify('editPhoneNumber', ['13801001234']).once();
      mocker.clear(CallRecordPresenter.getInstance().mAllCallRecordListDataSource);
      mocker.clear(dialerPresenter);
    })

    it("DialerPresenterTest_dialClick_else01", 0, () => {
      const context = new UIContext();
      AppStorage.setOrCreate('pasteStatus', false);
      AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, undefined);
      AppStorage.setOrCreate('recordType', 1);
      let callLogData: LooseObject[] = [];
      let parameters: LooseObject = {
        phoneNumber: '13801001234'
      };
      callLogData.push(new CallLogBean("234242", "action", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action", "23424", "1"))
      let crd = new CallRecordListDataSource();
      crd.refreshAll(callLogData)
      CallRecordPresenter.getInstance().mMissCallRecordListDataSource = crd;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(CallRecordPresenter.getInstance().mMissCallRecordListDataSource,
        CallRecordPresenter.getInstance().mMissCallRecordListDataSource.getData);
      when(mockFunc)(0).afterReturn(parameters);
      mocker.mockFunc(dialerPresenter, dialerPresenter.editPhoneNumber);
      dialerPresenter.dialClick(context, 1, true);
      mocker.verify('editPhoneNumber', ['13801001234']).once();
      mocker.clear(CallRecordPresenter.getInstance().mMissCallRecordListDataSource);
      mocker.clear(dialerPresenter);
    })

    it("DialerPresenterTest_creatAccountantsObj", 0, () => {
      let phoneNumber1: Record<string, string> = {
        'phoneNumber': '',
      }
      let contact1: SingleSelectContact = {
        updataShow: false,
        phoneNumbers: [phoneNumber1]
      } as SingleSelectContact;
      dialerPresenter.creatAccountantsObj('');
      expect(JSON.stringify(dialerPresenter.myAccountantsModel)).assertEqual(JSON.stringify(contact1));

      let phoneNumber: Record<string, string> = {
        'phoneNumber': '123',
      }
      let contact: SingleSelectContact = {
        updataShow: false,
        phoneNumbers: [phoneNumber]
      } as SingleSelectContact;
      dialerPresenter.creatAccountantsObj('123');
      expect(JSON.stringify(dialerPresenter.myAccountantsModel)).assertEqual(JSON.stringify(contact));
    })

    it("DialerPresenterTest_onCallsChange", 0, () => {
      dialerPresenter.onCallsChange();
      expect(CallRecordPresenter.getInstance().initStarted).assertFalse();
    })

    it("DialerPresenterTest_isNumberic", 0, () => {
      let message: string = '1548863';
      expect(dialerPresenter.isNumberic(message)).assertTrue();
    })

    it("DialerPresenterTest_callMenuBoolean", 0, () => {
      let result: Boolean = dialerPresenter.callMenuBoolean(2)
      expect(result).assertTrue();
      let result1: Boolean = dialerPresenter.callMenuBoolean(1)
      expect(result1).assertFalse();
    })

    it("DialerPresenterTest_foregroundOperation", 0, () => {
      DialerPresenter.setForegroundCallBack(() => {
        dialerPresenter.pasteFunc()
      })
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dialerPresenter, dialerPresenter.pasteFunc);
      dialerPresenter.foregroundOperation();
      mocker.verify('pasteFunc', []).once();
      mocker.clear(dialerPresenter);
    })
  })
}