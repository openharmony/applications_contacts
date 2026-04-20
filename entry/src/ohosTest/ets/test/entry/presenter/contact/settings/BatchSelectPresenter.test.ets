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
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactVo, ContactVoName } from '../../../../../../../main/ets/model/bean/ContactVo';
import MorandiColor from '../../../../../../../main/ets/model/bean/MorandiColor';
import { PhoneNumberInterface } from '../../../../../../../main/ets/model/type';
import BatchSelectPresenter, {
  EventInterface
} from '../../../../../../../main/ets/presenter/contact/settings/BatchSelectPresenter'
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';

export default function BatchSelectPresenterTest() {
  describe('BatchSelectPresenterTest', () => {

    let batchSelectPresenter: BatchSelectPresenter;

    beforeEach(() => {
      AppStorage.clear();
      batchSelectPresenter = new BatchSelectPresenter();
    })

    it('BatchSelectPresenterTest_getInstance', 0, () => {
      expect(typeof batchSelectPresenter).assertEqual(typeof BatchSelectPresenter.getInstance());
    })

    it('BatchSelectPresenterTest_aboutToAppear', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllContactWithPhoneNumbers').afterAction(() => {
        return;
      });
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.initParams);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.initContactsList);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.clearSelection);
      batchSelectPresenter.aboutToAppear();
      mocker.verify('initParams', []).once();
      mocker.verify('initContactsList', []).once();
      mocker.verify('clearSelection', []).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_aboutToDisappear', 0, () => {
      batchSelectPresenter.aboutToDisappear();
      expect(batchSelectPresenter.selectDisabled).assertTrue();
    })

    it('BatchSelectPresenterTest_onPageShow', 0, () => {
      batchSelectPresenter.onPageShow();
      expect(batchSelectPresenter.selectDisabled).assertTrue();
    })

    it('BatchSelectPresenterTest_onPageHide', 0, () => {
      batchSelectPresenter.onPageHide();
      expect(batchSelectPresenter.selectDisabled).assertTrue();
    })

    it('BatchSelectPresenterTest_initParams_pathInfos_and_params_undefined', 0, () => {
      batchSelectPresenter.initParams();
      expect(batchSelectPresenter.selectDisabled).assertTrue();
    })

    it('BatchSelectPresenterTest_initParams_pathInfos_undefined', 0, () => {
      AppStorage.setOrCreate('params', {
        contactCount: 1, isLimit: false
      });
      batchSelectPresenter.initParams();
      expect(batchSelectPresenter.countFromWantParam).assertEqual(1);
      expect(batchSelectPresenter.isLimit).assertFalse();
    })

    it('BatchSelectPresenterTest_initParams_contactCount_and_isLimit_undefined', 0, () => {
      class ObjInterface {
        contactCount?: number
        isLimit?: boolean
      }

      let objInterface: ObjInterface = new ObjInterface();
      batchSelectPresenter.pathInfos = new NavPathStack();
      batchSelectPresenter.pathInfos.pushPathByName('contactCount', objInterface);

      AppStorage.setOrCreate('params', {});
      batchSelectPresenter.initParams();
      expect(batchSelectPresenter.countFromWantParam).assertEqual(0);
    })

    it('BatchSelectPresenterTest_initParams_obj', 0, () => {
      class ObjInterface {
        contactCount?: number
        isLimit?: boolean
      }

      let objInterface: ObjInterface = new ObjInterface();
      objInterface.contactCount = 3;
      objInterface.isLimit = false;
      batchSelectPresenter.pathInfos = new NavPathStack();
      batchSelectPresenter.pathInfos.pushPathByName('contactCount', objInterface);
      batchSelectPresenter.initParams();
      expect(batchSelectPresenter.countFromWantParam).assertEqual(3);
    })

    it('BatchSelectPresenterTest_initParams_params', 0, () => {
      class ObjInterface {
        contactCount?: number
        isLimit?: boolean
      }

      let objInterface: ObjInterface = new ObjInterface();
      objInterface.contactCount = 3;
      objInterface.isLimit = false;
      AppStorage.setOrCreate('params', objInterface);
      batchSelectPresenter.initParams();
      expect(batchSelectPresenter.countFromWantParam).assertEqual(3);
    })

    it('BatchSelectPresenterTest_backCancel_pathInfos_undefined', 0, () => {
      batchSelectPresenter.backCancel();
      expect(batchSelectPresenter.pathInfos).assertUndefined();
    })

    it('BatchSelectPresenterTest_backCancel', 0, () => {
      batchSelectPresenter.pathInfos = new NavPathStack();
      batchSelectPresenter.pathInfos.pushPathByName('name', '');
      expect(JSON.stringify(batchSelectPresenter.pathInfos.getParamByName('name'))).assertEqual('[""]');
      batchSelectPresenter.backCancel();
      expect(JSON.stringify(batchSelectPresenter.pathInfos.getParamByName('name'))).assertEqual('[]');
    })

    it('BatchSelectPresenterTest_resetInitialIndex', 0, () => {
      batchSelectPresenter.resetInitialIndex(1);
      expect(batchSelectPresenter.initialIndex).assertEqual(1);
    })

    it('BatchSelectPresenterTest_initContactsList', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);

      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);

      batchSelectPresenter.initContactsList();

      expect(batchSelectPresenter.isSelectAll).assertFalse();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('BatchSelectPresenterTest_clearSelection', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.unSelectAllContactProc);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.refreshPageMessage);
      batchSelectPresenter.clearSelection();
      mocker.verify('unSelectAllContactProc', []).once();
      mocker.verify('refreshPageMessage', []).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_refreshPageMessage', 0, () => {
      const expectedTitle = $r('app.color.skin_icon_primary');
      batchSelectPresenter.allSelectTextStyle = $r('app.string.select_all');
      batchSelectPresenter.refreshPageMessage();
      expect(JSON.stringify(batchSelectPresenter.allSelectTextStyle)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchSelectPresenterTest_refreshPageMessage_selectedNumberMap', 0, () => {
      let selectedNumberMap: Map<number, Record<string, string | number>> = new Map();
      selectedNumberMap.set(1, {});
      selectedNumberMap.set(2, {});
      batchSelectPresenter.selectedNumberMap = selectedNumberMap;
      batchSelectPresenter.refreshPageMessage();
      expect(batchSelectPresenter.tabInfo.allClickedContacts).assertTrue();
    })

    it('BatchSelectPresenterTest_checkAllClickButtonStyle', 0, () => {
      const expectedTitle = $r('app.color.skin_icon_primary');
      batchSelectPresenter.allSelectTextStyle = $r('app.string.select_all');
      batchSelectPresenter.tabInfo.contactsTotal = 1;
      batchSelectPresenter.checkAllClickButtonStyle();
      expect(JSON.stringify(batchSelectPresenter.allSelectTextStyle)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchSelectPresenterTest_checkAllClickButtonStyle_contactSelectAll', 0, () => {
      batchSelectPresenter.checkAllClickButtonStyle();
      expect(batchSelectPresenter.tabInfo.allClickedContacts).assertTrue();
    })

    it('BatchSelectPresenterTest_changeToFullSelect', 0, () => {
      const expectedTitle = $r('app.color.skin_confirm');
      batchSelectPresenter.allSelectTextStyle = $r('app.string.select_all');
      batchSelectPresenter.changeToFullSelect();
      expect(JSON.stringify(batchSelectPresenter.allSelectTextStyle)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchSelectPresenterTest_changeToUnFullSelect', 0, () => {
      const expectedTitle = $r('app.color.skin_icon_primary');
      batchSelectPresenter.allSelectTextStyle = $r('app.string.select_all');
      batchSelectPresenter.changeToUnFullSelect();
      expect(JSON.stringify(batchSelectPresenter.allSelectTextStyle)).assertEqual(JSON.stringify(expectedTitle));
    })

    it('BatchSelectPresenterTest_unSelectAllContactProc_searchLayoutShow_false', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.unSelectAllContactProc();
      expect(batchSelectPresenter.contactsList[0].phoneNumbers[0].checked).assertFalse();
    })

    it('BatchSelectPresenterTest_unSelectAllContactProc_searchLayoutShow_false_checked_false', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.deleteSelectedNumber);

      batchSelectPresenter.unSelectAllContactProc();
      mocker.verify('deleteSelectedNumber', ['phoneNumber', 12]).never();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_unSelectAllContactProc_searchLayoutShow_true', 0, () => {
      batchSelectPresenter.contactsInfo.searchLayoutShow = true;
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.unSelectAllContactProc();
      expect(batchSelectPresenter.contactsInfo.searchContactList[0].phoneNumbers[0].checked).assertFalse();
    })

    it('BatchSelectPresenterTest_unSelectAllContactProc_searchLayoutShow_true_checked_false', 0, () => {
      batchSelectPresenter.contactsInfo.searchLayoutShow = true;
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.deleteSelectedNumber);

      batchSelectPresenter.unSelectAllContactProc();

      mocker.verify('deleteSelectedNumber', ['phoneNumber', 12]).never();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_deleteSelectedNumber', 0, () => {
      let key = 1;
      let value: Record<string, string | number> = {
        'name': 'name',
        'number': 1,
        'id': 1,
        'contactId': 1
      }
      batchSelectPresenter.selectedNumberMap.set(key, value);
      batchSelectPresenter.deleteSelectedNumber('1', '');
      expect(batchSelectPresenter.selectedNumberMap.size).assertEqual(0);
    })

    it('BatchSelectPresenterTest_deleteSelectedNumber_number_empty', 0, () => {
      batchSelectPresenter.deleteSelectedNumber('', '');
      expect(batchSelectPresenter.selectCount).assertEqual(0);
    })

    it('BatchSelectPresenterTest_initVariableSpan', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      batchSelectPresenter.initVariableSpan(contactVo);
      expect(contactVo.phoneNumbers[0].endPhone).assertEqual('phoneNumber');
    })

    it('BatchSelectPresenterTest_initVariableSpan_withSearchText', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      batchSelectPresenter.searchText = '1';
      batchSelectPresenter.initVariableSpan(contactVo);
      expect(contactVo.phoneNumbers[0].middlePhone).assertEqual('1');
    })

    it('BatchSelectPresenterTest_getPhoneLabelNameById', 0, () => {
      const mobile = $r('app.string.phone_type_mobile_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('1', ''))).assertEqual(JSON.stringify(mobile));
      const home = $r('app.string.phone_type_home_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('2', ''))).assertEqual(JSON.stringify(home));
      const work = $r('app.string.phone_type_work_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('3', ''))).assertEqual(JSON.stringify(work));
      const faxWork = $r('app.string.phone_type_fax_work_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('4', ''))).assertEqual(JSON.stringify(faxWork));
      const faxHome = $r('app.string.phone_type_fax_home_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('5', ''))).assertEqual(JSON.stringify(faxHome));
      const pager = $r('app.string.phone_type_pager_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('6', ''))).assertEqual(JSON.stringify(pager));
      const other = $r('app.string.phone_type_other_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('7', ''))).assertEqual(JSON.stringify(other));
      const main = $r('app.string.phone_type_main_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('12', ''))).assertEqual(JSON.stringify(main));
      const custom = $r('app.string.phone_type_custom_expansion', '');
      expect(JSON.stringify(batchSelectPresenter.getPhoneLabelNameById('99', ''))).assertEqual(JSON.stringify(custom));
      expect(batchSelectPresenter.getPhoneLabelNameById('0', '')).assertNull();
    })

    it('BatchSelectPresenterTest_selectBatchContact', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.comfirm);
      batchSelectPresenter.selectBatchContact();
      mocker.verify('comfirm', []).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_comfirm', 0, () => {
      batchSelectPresenter.comfirm();
      expect(batchSelectPresenter.initialIndex).assertEqual(0);
    })

    it('BatchSelectPresenterTest_clickSelectAll', 0, () => {
      batchSelectPresenter.tabInfo.contactsCount = 1;
      batchSelectPresenter.tabInfo.contactsTotal = 1;
      batchSelectPresenter.clickSelectAll();
      expect(batchSelectPresenter.tabInfo.allClickedContacts).assertFalse();
    })

    it('BatchSelectPresenterTest_clickSelectAll_false', 0, () => {
      batchSelectPresenter.clickSelectAll();
      expect(batchSelectPresenter.tabInfo.allClickedContacts).assertTrue();
    })

    it('BatchSelectPresenterTest_unSelectAll', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.unSelectAllContactProc);
      batchSelectPresenter.unSelectAll();
      mocker.verify('unSelectAllContactProc', []).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_selectAll', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.unSelectAllContactProc);
      batchSelectPresenter.unSelectAll();
      mocker.verify('unSelectAllContactProc', []).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_selectAll_isSelectContactExceededLimit_true', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.isSelectContactExceededLimit))()
        .afterReturn(true);

      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.selectAllContactProc);

      batchSelectPresenter.selectAll();

      mocker.verify('selectAllContactProc', [true]).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_selectAll_isSelectContactExceededLimit_false', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.isSelectContactExceededLimit))()
        .afterReturn(false);

      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.selectAllContactProc);

      batchSelectPresenter.selectAll();

      mocker.verify('selectAllContactProc', [false]).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_selectAllContactProc_01', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.countFromWantParam = 1000;
      batchSelectPresenter.selectAllContactProc(true);
      expect(batchSelectPresenter.countFromWantParam).assertEqual(1000);

      batchSelectPresenter.countFromWantParam = 1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.dealSelectedContactsMap);
      batchSelectPresenter.selectAllContactProc(true);
      mocker.verify('dealSelectedContactsMap', [contactVo]).once();
      batchSelectPresenter.selectAllContactProc(false);
      mocker.verify('dealSelectedContactsMap', [contactVo]).times(2);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_selectAllContactProc_searchLayoutShow', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.dealSelectedContactsMap);
      batchSelectPresenter.contactsInfo.searchLayoutShow = true;
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.selectAllContactProc(true);
      mocker.verify('dealSelectedContactsMap', [contactVo]).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_dealSelectedContactsMap', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      batchSelectPresenter.dealSelectedContactsMap(contactVo);
      expect(contactVo.phoneNumbers[0].checked).assertTrue();
    })

    it('BatchSelectPresenterTest_dealSelectedContactsMap_checked_true', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      batchSelectPresenter.dealSelectedContactsMap(contactVo);
      expect(batchSelectPresenter.searchLayoutShow).assertFalse();
    })

    it('BatchSelectPresenterTest_addOrUpdateSelectedNumberMap', 0, () => {
      batchSelectPresenter.addOrUpdateSelectedNumberMap('1', '1', '1');
      expect(batchSelectPresenter.selectedNumberMap.size).assertEqual(1);
    })

    it('BatchSelectPresenterTest_addOrUpdateSelectedNumberMap_number_empty', 0, () => {
      batchSelectPresenter.addOrUpdateSelectedNumberMap('', '1', '1');
      expect(batchSelectPresenter.selectCount).assertEqual(0);
    })

    it('BatchSelectPresenterTest_updataConnectedContact', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.updataConnectedContact('phoneNumber', '', '12', true);
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(1);
      batchSelectPresenter.updataConnectedContact('phoneNumber', '', '12', false);
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(0);
      batchSelectPresenter.updataConnectedContact('phoneNumber', '', '13', false);
      expect(batchSelectPresenter.contactsSource.totalCount()).assertEqual(1);
    })

    it('BatchSelectPresenterTest_updataConnectedContact_isAdd_false_checkIfNeedCount_true', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(true);

      batchSelectPresenter.updataConnectedContact('phoneNumber', '', '12', false);

      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(-1);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_updataConnectedContact_phoneNumber_notEqual', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;

      batchSelectPresenter.updataConnectedContact('phoneNumber1', '', '12', true);
      expect(batchSelectPresenter.editContact).assertEqual(-1);
    })

    it('BatchSelectPresenterTest_updataConnectedContact_name_undefined', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', undefined, '2', '1',
        '1', '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;

      batchSelectPresenter.updataConnectedContact('phoneNumber', '', '12', true);
      expect(batchSelectPresenter.editContact).assertEqual(-1);
    })

    it('BatchSelectPresenterTest_checkIfNeedCount', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      expect(batchSelectPresenter.checkIfNeedCount(contactVo)).assertTrue();
    })

    it('BatchSelectPresenterTest_checkIfNeedCount_length_0', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let phoneNumbers: PhoneNumberInterface[] = []
      contactVo.setphoneNumbers(phoneNumbers);
      expect(batchSelectPresenter.checkIfNeedCount(contactVo)).assertFalse();
    })

    it('BatchSelectPresenterTest_isSelectContactExceededLimit', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let contactsList: Array<ContactVo> = [];
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: false,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      expect(batchSelectPresenter.isSelectContactExceededLimit()).assertFalse();
    })

    it('BatchSelectPresenterTest_isSelectContactExceededLimit_item_checked_true', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let contactsList: Array<ContactVo> = [];
      let phoneNumber: PhoneNumberInterface = {
        dataId: 0,
        phoneNumber: 'phoneNumber1',
        labelId: '',
        numType: '',
        labelName: '',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: ''
      }
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers);
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      expect(batchSelectPresenter.isSelectContactExceededLimit()).assertFalse();
    })

    it('BatchSelectPresenterTest_isSelectContactExceededLimit_isLimit_true', 0, () => {
      batchSelectPresenter.isLimit = true;
      batchSelectPresenter.countFromWantParam = 1001;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.maximumSelectedContactShow);

      expect(batchSelectPresenter.isSelectContactExceededLimit()).assertTrue();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_maximumSelectedContactShow', 0, () => {
      batchSelectPresenter.maximumSelectedContactShow();
      expect(batchSelectPresenter.selectDisabled).assertTrue();
    })

    it('BatchSelectPresenterTest_getEmptyText', 0, () => {
      const emptyViewText = $r('app.string.no_contacts');
      expect(JSON.stringify(batchSelectPresenter.getEmptyText())).assertEqual(JSON.stringify(emptyViewText));
    })

    it('BatchSelectPresenterTest_onContactItemClicked', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.searchLayoutShow = false;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkStateChange);
      batchSelectPresenter.onContactItemClicked(0, 0);
      let event1: EventInterface = {
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      }
      mocker.verify('checkStateChange', [0, event1]).once();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_onContactItemClicked_searchLayoutShow_true', 0, () => {
      batchSelectPresenter.searchLayoutShow = true;

      batchSelectPresenter.onContactItemClicked(0, 0);

      expect(batchSelectPresenter.searchContactList.length).assertEqual(0);
    })

    it('BatchSelectPresenterTest_checkStateChange_if', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.maximumSelectedContactShow);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.changeContactsItemState);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.refreshPageMessage);

      batchSelectPresenter.countFromWantParam = 1001;
      batchSelectPresenter.isLimit = true;

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: true
      };

      batchSelectPresenter.checkStateChange(0, event);

      mocker.verify('maximumSelectedContactShow', []).once();
      mocker.verify('changeContactsItemState', [0, event]).never();
      mocker.verify('refreshPageMessage', []).never();
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_checkStateChange_noIf', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.maximumSelectedContactShow);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.changeContactsItemState);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.refreshPageMessage);

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: false
      };

      batchSelectPresenter.checkStateChange(0, event);

      mocker.verify('maximumSelectedContactShow', []).never();
      mocker.verify('changeContactsItemState', [0, event]).once();
      mocker.verify('refreshPageMessage', []).once();
    })

    it('BatchSelectPresenterTest_checkContactsCount_if_noIf', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];

      batchSelectPresenter.searchLayoutShow = true;

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: false
      };

      batchSelectPresenter.checkContactsCount(event, '0');

      expect(batchSelectPresenter.isLimit).assertFalse();

    })

    it('BatchSelectPresenterTest_checkContactsCount_if_if_if', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];
      batchSelectPresenter.searchLayoutShow = true;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.addOrUpdateSelectedNumberMap);

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: true
      };

      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);

      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(true);
      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_checkContactsCount_if_if_else', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];
      batchSelectPresenter.searchLayoutShow = true;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.addOrUpdateSelectedNumberMap);

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: false
      };

      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);

      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.deleteSelectedNumber);
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(true);
      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_checkContactsCount_else_noIf', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];
      batchSelectPresenter.searchLayoutShow = true;

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: false
      };

      batchSelectPresenter.checkContactsCount(event, '0');

      expect(batchSelectPresenter.selectDisabled).assertTrue();

    })

    it('BatchSelectPresenterTest_checkContactsCount_else_if_if', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      };
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber];
      contactVo.setphoneNumbers(phoneNumbers);
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];
      batchSelectPresenter.searchLayoutShow = true;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.addOrUpdateSelectedNumberMap);

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: true
      };

      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);

      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(true);
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_checkContactsCount_else_if_else', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.contactsInfo.searchContactList = [new ContactVo('1', '2', '', '1', '2', '1', portraitColor, true,
        '1', '1', '0', name, '2', '1', '1', '2')];
      batchSelectPresenter.searchLayoutShow = true;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.addOrUpdateSelectedNumberMap);

      let event: EventInterface = {
        contactIndex: 0,
        numberIndex: 1,
        checked: false
      };

      batchSelectPresenter.checkContactsCount(event, '1');
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);

      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.deleteSelectedNumber);
      when(mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.checkIfNeedCount))(ArgumentMatchers.any)
        .afterReturn(true);
      expect(batchSelectPresenter.tabInfo.contactsCount).assertEqual(0);
      mocker.clear(batchSelectPresenter);
    })

    it('BatchSelectPresenterTest_changeContactsItemState', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0',
        name, '2', '1', '1', '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.changeContactsItemState(0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      });
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(-1);
    })

    it('BatchSelectPresenterTest_changeContactsItemState_eventChecked', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.changeContactsItemState(0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      });
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(2);
    })

    it('BatchSelectPresenterTest_changeContactsItemState_searchLayoutShow', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.contactsInfo.searchLayoutShow = true;
      batchSelectPresenter.changeContactsItemState(0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: false
      });
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(-1);
    })

    it('BatchSelectPresenterTest_changeContactsItemState_searchLayoutShow_eventChecked', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('12', '2', '', '1', '2', '1', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
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
      let phoneNumbers: PhoneNumberInterface[] = [phoneNumber]
      contactVo.setphoneNumbers(phoneNumbers)
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      let searchContactList: Array<ContactVo> = [];
      searchContactList.push(contactVo);
      batchSelectPresenter.contactsInfo.searchContactList = searchContactList;
      batchSelectPresenter.contactsInfo.searchLayoutShow = true;
      batchSelectPresenter.changeContactsItemState(0, {
        contactIndex: 0,
        numberIndex: 0,
        checked: true
      });
      expect(batchSelectPresenter.contactsInfo.contactsNumberCount).assertEqual(2);
    })

    it('BatchSelectPresenterTest_selectAllContactProc_02', 0, () => {
      let portraitColor: Resource = MorandiColor.color[0];
      let name: ContactVoName = new ContactVoName();
      let contactVo = new ContactVo('1', '2', '', '3', '4', '5', portraitColor, true, '1', '1', '0', name, '2', '1', '1',
        '2');
      let contactsList: Array<ContactVo> = [];
      contactsList.push(contactVo);
      batchSelectPresenter.contactsList = contactsList;
      batchSelectPresenter.countFromWantParam = 1000;
      batchSelectPresenter.selectAllContactProc(true);
      expect(batchSelectPresenter.selectCount).assertEqual(0);

      batchSelectPresenter.countFromWantParam = 1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchSelectPresenter, batchSelectPresenter.dealSelectedContactsMap);
      batchSelectPresenter.selectAllContactProc(true);
      mocker.verify('dealSelectedContactsMap', [contactVo]).once();
      batchSelectPresenter.selectAllContactProc(false);
      mocker.verify('dealSelectedContactsMap', [contactVo]).times(2);
      mocker.clear(batchSelectPresenter);
    })
  })
}