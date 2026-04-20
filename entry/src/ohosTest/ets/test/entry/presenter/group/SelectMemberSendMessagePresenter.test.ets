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
import { describe, beforeEach, afterEach, it, expect, MockKit, when } from '@ohos/hypium';
import { PhoneNumber } from '../../../../../../../../feature/phonenumber';
import { ContactVo, MemberInfo } from '../../../../../../main/ets/model/bean/ContactVo';
import { PhoneNumberInterface } from '../../../../../../main/ets/model/type';
import { SendMessageParams } from '../../../../../../main/ets/model/type/ContactParams';
import SelectMemberSendMessagePresenter
  from '../../../../../../main/ets/presenter/group/SelectMemberSendMessagePresenter';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactRepository } from '../../../../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import resourceManager from '@ohos.resourceManager';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { StringUtil } from '../../../../../../../../common';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';

const TAG = 'SelectMemberSendMessagePresenter ';

export default function SelectMemberSendMessagePresenterTest() {
  describe('SelectMemberSendMessagePresenterTest', () => {

    let selectMemberSendMessagePresenter: SelectMemberSendMessagePresenter;
    let mocker: MockKit;

    beforeEach(() => {
      mocker = new MockKit();
      selectMemberSendMessagePresenter = new SelectMemberSendMessagePresenter();
    })

    afterEach(() => {
      mocker.clear(selectMemberSendMessagePresenter.groupMemberDataSource);
      mocker.clear(selectMemberSendMessagePresenter);
    })

    it('SelectMemberSendMessagePresenterTest_getInstance', 0, () => {
      expect(typeof selectMemberSendMessagePresenter)
        .assertEqual(typeof SelectMemberSendMessagePresenter.getInstance());
    })

    it('SelectMemberSendMessagePresenterTest_aboutToAppear', 0, () => {
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.initParams);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.initContactsList);
      selectMemberSendMessagePresenter.aboutToAppear();
      mocker.verify('initParams', []).once();
      mocker.verify('initContactsList', []).once();
    })

    it('SelectMemberSendMessagePresenterTest_onPageHide', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      selectMemberSendMessagePresenter.onPageHide();
      mocker.verify('i', [TAG, 'onPageHide start.']).never();
      mocker.clear(HiLog);
    })

    it('SelectMemberSendMessagePresenterTest_initParams', 0, () => {
      selectMemberSendMessagePresenter.pathInfos = new NavPathStack();
      selectMemberSendMessagePresenter.pathInfos?.pushPathByName('test', 1);
      selectMemberSendMessagePresenter.initParams();
      expect(selectMemberSendMessagePresenter.groupId).assertEqual(1);
    })

    it('SelectMemberSendMessagePresenterTest_initParams_pathInfos_undefined', 0, () => {
      selectMemberSendMessagePresenter.pathInfos = undefined;
      selectMemberSendMessagePresenter.initParams();
      expect(selectMemberSendMessagePresenter.selectedCount).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_back', 0, () => {
      selectMemberSendMessagePresenter.pathInfos = new NavPathStack();
      selectMemberSendMessagePresenter.pathInfos?.pushPathByName('test', 1);
      selectMemberSendMessagePresenter.back();
      expect(selectMemberSendMessagePresenter.pathInfos?.size()).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_back_pathInfos_undefined', 0, () => {
      selectMemberSendMessagePresenter.pathInfos = undefined;
      selectMemberSendMessagePresenter.back();
      expect(selectMemberSendMessagePresenter.selectedCount).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_getPhoneLabelNameById', 0, () => {
      const phoneNumber = '123456';

      const labelName1 = selectMemberSendMessagePresenter.getPhoneLabelNameById('1', phoneNumber);
      const expectLabelName1 = $r("app.string.phone_type_mobile_expansion", phoneNumber);
      expect(JSON.stringify(labelName1)).assertEqual(JSON.stringify(expectLabelName1));

      const labelName2 = selectMemberSendMessagePresenter.getPhoneLabelNameById('2', phoneNumber);
      const expectLabelName2 = $r("app.string.phone_type_home_expansion", phoneNumber);
      expect(JSON.stringify(labelName2)).assertEqual(JSON.stringify(expectLabelName2));

      const labelName3 = selectMemberSendMessagePresenter.getPhoneLabelNameById('3', phoneNumber);
      const expectLabelName3 = $r("app.string.phone_type_work_expansion", phoneNumber);
      expect(JSON.stringify(labelName3)).assertEqual(JSON.stringify(expectLabelName3));

      const labelName4 = selectMemberSendMessagePresenter.getPhoneLabelNameById('4', phoneNumber);
      const expectLabelName4 = $r("app.string.phone_type_fax_work_expansion", phoneNumber);
      expect(JSON.stringify(labelName4)).assertEqual(JSON.stringify(expectLabelName4));

      const labelName5 = selectMemberSendMessagePresenter.getPhoneLabelNameById('5', phoneNumber);
      const expectLabelName5 = $r("app.string.phone_type_fax_home_expansion", phoneNumber);
      expect(JSON.stringify(labelName5)).assertEqual(JSON.stringify(expectLabelName5));

      const labelName6 = selectMemberSendMessagePresenter.getPhoneLabelNameById('6', phoneNumber);
      const expectLabelName6 = $r("app.string.phone_type_pager_expansion", phoneNumber);
      expect(JSON.stringify(labelName6)).assertEqual(JSON.stringify(expectLabelName6));

      const labelName7 = selectMemberSendMessagePresenter.getPhoneLabelNameById('7', phoneNumber);
      const expectLabelName7 = $r("app.string.phone_type_other_expansion", phoneNumber);
      expect(JSON.stringify(labelName7)).assertEqual(JSON.stringify(expectLabelName7));

      const labelName8 = selectMemberSendMessagePresenter.getPhoneLabelNameById('12', phoneNumber);
      const expectLabelName8 = $r("app.string.phone_type_main_expansion", phoneNumber);
      expect(JSON.stringify(labelName8)).assertEqual(JSON.stringify(expectLabelName8));

      const labelName9 = selectMemberSendMessagePresenter.getPhoneLabelNameById('99', phoneNumber);
      const expectLabelName9 = $r("app.string.phone_type_custom_expansion", phoneNumber);
      expect(JSON.stringify(labelName9)).assertEqual(JSON.stringify(expectLabelName9));

      const labelName10 = selectMemberSendMessagePresenter.getPhoneLabelNameById('100', phoneNumber);
      expect(labelName10).assertNull();
    })

    it('SelectMemberSendMessagePresenterTest_getPhoneLabelNameById_isPrimary_true', 0, () => {
      let phoneNumber = '570977632';
      let context: common.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => ''
        } as resourceManager.ResourceManager
      } as common.UIAbilityContext;

      let phoneNameString = '  ' + phoneNumber;

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let expectLabelName: Resource = $r('app.string.phone_type_mobile_expansion', phoneNameString);

      let labelName = selectMemberSendMessagePresenter.getPhoneLabelNameById('1', phoneNumber, true);

      expect(JSON.stringify(labelName)).assertEqual(JSON.stringify(expectLabelName));
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SelectMemberSendMessagePresenterTest_initContactsList', 0, () => {
      let result = false;

      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('findMemberByPhoneIsNotNull').afterAction(() => {
        result = true;
      });
      selectMemberSendMessagePresenter.initContactsList();

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('SelectMemberSendMessagePresenterTest_initContactsList_callback_else', 0, () => {

      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let refreshPageMessage: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      when(refreshPageMessage)().afterAction(() => {
        expect(result).assertTrue();
        expect(JSON.stringify(selectMemberSendMessagePresenter.memberList)).assertEqual('[]');
      })

      selectMemberSendMessagePresenter.initContactsList();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('SelectMemberSendMessagePresenterTest_initContactsList_callback_if_noIf', 0, () => {
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => '',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);

      let refreshPageMessage: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      when(refreshPageMessage)().afterAction(() => {
        expect(result).assertTrue();
        mocker.verify('addOrUpdateSelectedNumberMap', ['xxx', 'xxx', 'xxx']).never();
      })

      selectMemberSendMessagePresenter.initContactsList();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('SelectMemberSendMessagePresenterTest_initContactsList_callback_if_primary_false', 0, () => {

      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
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

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);

      let refreshPageMessage: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      when(refreshPageMessage)().afterAction(() => {
        expect(result).assertTrue();
        expect(JSON.stringify(selectMemberSendMessagePresenter.memberList)).assertEqual('[]');
        mocker.verify('addOrUpdateSelectedNumberMap', ['xxx', 'xxx', 'xxx']).once();
      })

      selectMemberSendMessagePresenter.initContactsList();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('SelectMemberSendMessagePresenterTest_initContactsList_callback_if_primary_true', 0, () => {
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 1,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => '1',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);

      let refreshPageMessage: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      when(refreshPageMessage)().afterAction(() => {
        expect(result).assertTrue();
        mocker.verify('addOrUpdateSelectedNumberMap', ['1', '1', '1']).once();
      })

      selectMemberSendMessagePresenter.initContactsList();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('SelectMemberSendMessagePresenterTest_onContactItemClicked', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      selectMemberSendMessagePresenter.memberList = [element];

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkStateChange);
      selectMemberSendMessagePresenter.onContactItemClicked(0, 0);
      mocker.verify('checkStateChange', [0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      }]).once();
    })

    it('SelectMemberSendMessagePresenterTest_checkStateChange', 0, () => {
      let element: MemberInfo = new MemberInfo();
      element.member = new ContactVo("", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.contactId = 'contactId';
      selectMemberSendMessagePresenter.memberList = [element];

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkContactsCount);
      selectMemberSendMessagePresenter.checkStateChange(0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      });
      mocker.verify('checkContactsCount', [{
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      }, 'contactId']).once();
    })

    it('SelectMemberSendMessagePresenterTest_checkIfNeedCount_true', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      const result = selectMemberSendMessagePresenter.checkIfNeedCount(element);
      expect(result).assertTrue();
    })

    it('SelectMemberSendMessagePresenterTest_checkIfNeedCount_true_checked_false', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '',
        labelId: '',
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      const result = selectMemberSendMessagePresenter.checkIfNeedCount(element);
      expect(result).assertFalse();
    })

    it('SelectMemberSendMessagePresenterTest_checkIfNeedCount_false', 0, () => {
      let element: MemberInfo = new MemberInfo();
      element.member = new ContactVo("", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');

      const result = selectMemberSendMessagePresenter.checkIfNeedCount(element);

      expect(result).assertFalse();
    })

    it('SelectMemberSendMessagePresenterTest_checkContactsCount_if_if_if', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("contactId", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      element.member.name.fullName = 'fullName';
      selectMemberSendMessagePresenter.memberList = [element];


      let mockFunc: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkIfNeedCount);
      when(mockFunc)(element).afterReturn(false);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);


      selectMemberSendMessagePresenter.checkContactsCount({
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      }, 'contactId');

      expect(element.member.phoneNumbers[0].checked).assertTrue();
      mocker.verify('addOrUpdateSelectedNumberMap', ['phoneNumber', 'fullName', 'contactId']).once();
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(1);
    })

    it('SelectMemberSendMessagePresenterTest_checkContactsCount_if_if_noIf', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("contactId", "", '', "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      element.member.name.fullName = 'fullName';
      selectMemberSendMessagePresenter.memberList = [element];


      let mockFunc: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkIfNeedCount);
      when(mockFunc)(element).afterReturn(true);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);


      selectMemberSendMessagePresenter.checkContactsCount({
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      }, 'contactId');

      expect(element.member.phoneNumbers[0].checked).assertTrue();
      mocker.verify('addOrUpdateSelectedNumberMap', ['phoneNumber', 'fullName', 'contactId']).once();
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_checkContactsCount_if_else_if', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("contactId", "",'',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      element.member.name.fullName = 'fullName';
      selectMemberSendMessagePresenter.memberList = [element];


      let mockFunc: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkIfNeedCount);
      when(mockFunc)(element).afterReturn(false);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.deleteSelectedNumber);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);


      selectMemberSendMessagePresenter.checkContactsCount({
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      }, 'contactId');

      expect(element.member.phoneNumbers[0].checked).assertFalse();
      mocker.verify('deleteSelectedNumber', ['phoneNumber', 'contactId']).once();
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(-1);
    })

    it('SelectMemberSendMessagePresenterTest_checkContactsCount_if_else_noIf', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("contactId", "", '',  "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      element.member.name.fullName = 'fullName';
      selectMemberSendMessagePresenter.memberList = [element];


      let mockFunc: Function = mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.checkIfNeedCount);
      when(mockFunc)(element).afterReturn(true);

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.deleteSelectedNumber);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);


      selectMemberSendMessagePresenter.checkContactsCount({
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      }, 'contactId');

      expect(element.member.phoneNumbers[0].checked).assertFalse();
      mocker.verify('deleteSelectedNumber', ['phoneNumber', 'contactId']).once();
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_checkContactsCount_no_foreach', 0, () => {
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);

      selectMemberSendMessagePresenter.checkContactsCount({
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      }, 'contactId');

      mocker.verify('refresh', [[]]).once();
      mocker.verify('refreshPageMessage', []).once();
    })

    it('SelectMemberSendMessagePresenterTest_deleteSelectedNumber_return', 0, () => {
      selectMemberSendMessagePresenter.selectedNumberMap.set(21, {});
      selectMemberSendMessagePresenter.deleteSelectedNumber('', '');
      expect(selectMemberSendMessagePresenter.selectedNumberMap.has(21)).assertTrue();
    })

    it('SelectMemberSendMessagePresenterTest_deleteSelectedNumber', 0, () => {
      selectMemberSendMessagePresenter.selectedNumberMap.set(21, {});
      selectMemberSendMessagePresenter.deleteSelectedNumber('1', '2');
      expect(selectMemberSendMessagePresenter.selectedNumberMap.has(21)).assertFalse();
    })

    it('SelectMemberSendMessagePresenterTest_addOrUpdateSelectedNumberMap_return', 0, () => {
      selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap('', '', '');
      expect(selectMemberSendMessagePresenter.selectedNumberMap.size).assertEqual(0);
    })

    it('SelectMemberSendMessagePresenterTest_addOrUpdateSelectedNumberMap', 0, () => {
      const expectedValue: Record<string, string | number> = {
        'name': 'name',
        'number': '1',
        "id": 2,
        "contactId": "2"
      }
      selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap('1', 'name', '2');
      expect(JSON.stringify(selectMemberSendMessagePresenter.selectedNumberMap.get(21)))
        .assertEqual(JSON.stringify(expectedValue));
    })

    it('SelectMemberSendMessagePresenterTest_clickSelectAll_else', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      selectMemberSendMessagePresenter.memberList = [element];

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.deleteSelectedNumber);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);

      selectMemberSendMessagePresenter.clickSelectAll();

      expect(element.member.phoneNumbers[0].checked).assertTrue();
      mocker.verify('deleteSelectedNumber', ['phoneNumber', 'contactId']).never();
      expect(selectMemberSendMessagePresenter.isSelectAll).assertFalse();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(0);
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
    })

    it('SelectMemberSendMessagePresenterTest_clickSelectAll_if', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '570977632',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("1", "","", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      selectMemberSendMessagePresenter.memberList = [element];

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.dealSelectedContactsMap);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.deleteSelectedNumber);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      selectMemberSendMessagePresenter.contactsTotal = 1;
      selectMemberSendMessagePresenter.contactsCount = 1;

      selectMemberSendMessagePresenter.clickSelectAll();

      expect(element.member.phoneNumbers[0].checked).assertFalse();
      mocker.verify('dealSelectedContactsMap', [element]).never();
      mocker.verify('deleteSelectedNumber', [phoneNumber.phoneNumber, element.member.contactId]).once();
      expect(selectMemberSendMessagePresenter.isSelectAll).assertFalse();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(0);
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
    })

    it('SelectMemberSendMessagePresenterTest_clickSelectAll_if_checked_false', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: '570977632',
        labelId: '',
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("1", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.contactId = 'contactId';
      selectMemberSendMessagePresenter.memberList = [element];

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.dealSelectedContactsMap);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.deleteSelectedNumber);
      mocker.mockFunc(selectMemberSendMessagePresenter.groupMemberDataSource, selectMemberSendMessagePresenter.groupMemberDataSource.refresh);
      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.refreshPageMessage);
      selectMemberSendMessagePresenter.contactsTotal = 1;
      selectMemberSendMessagePresenter.contactsCount = 1;

      selectMemberSendMessagePresenter.clickSelectAll();

      expect(element.member.phoneNumbers[0].checked).assertFalse();
      mocker.verify('dealSelectedContactsMap', [element]).never();
      mocker.verify('deleteSelectedNumber', [phoneNumber.phoneNumber, element.member.contactId]).never();
      expect(selectMemberSendMessagePresenter.isSelectAll).assertFalse();
      expect(selectMemberSendMessagePresenter.contactsCount).assertEqual(0);
      mocker.verify('refresh', [[element]]).once();
      mocker.verify('refreshPageMessage', []).once();
    })

    it('SelectMemberSendMessagePresenterTest_refreshPageMessage', 0, () => {
      const expectedResult = (selectMemberSendMessagePresenter.contactsCount === selectMemberSendMessagePresenter.contactsTotal) && selectMemberSendMessagePresenter.contactsCount != 0;

      selectMemberSendMessagePresenter.refreshPageMessage();

      expect(selectMemberSendMessagePresenter.selectedCount)
        .assertEqual(selectMemberSendMessagePresenter.selectedNumberMap.size);
      expect(selectMemberSendMessagePresenter.isSelectAll).assertEqual(expectedResult);
    })

    it('SelectMemberSendMessagePresenterTest_dealSelectedContactsMap', 0, () => {
      let element: MemberInfo = new MemberInfo();
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber',
        labelId: '',
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      element.member = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
      element.member.phoneNumbers = [phoneNumber];
      element.member.name.fullName = 'fullName';
      element.member.contactId = 'contactId';

      mocker.mockFunc(selectMemberSendMessagePresenter, selectMemberSendMessagePresenter.addOrUpdateSelectedNumberMap);
      selectMemberSendMessagePresenter.dealSelectedContactsMap(element);
      expect(element.member.phoneNumbers[0].checked).assertTrue();
      mocker.verify('addOrUpdateSelectedNumberMap', ['phoneNumber', 'fullName', 'contactId']).once();
    })

    it('SelectMemberSendMessagePresenterTest_senMessage', 0, () => {
      selectMemberSendMessagePresenter.selectedNumberMap.set(0, {
        'number': '57097732',
        'name': 'roxy'
      } as Record<string, string | number>);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(PhoneNumber, PhoneNumber.groupSendMessage);

      selectMemberSendMessagePresenter.sendMessage();

      let params: SendMessageParams[] = [];
      selectMemberSendMessagePresenter.selectedNumberMap.forEach((value) => {
        params.push(new SendMessageParams(StringUtil.removeSpace(value.number.toString()),
          value.number.toString(), value.name.toString()));
      });
      mocker.verify('groupSendMessage', [params]).once();
      mocker.clear(PhoneNumber);
    })
  })
}