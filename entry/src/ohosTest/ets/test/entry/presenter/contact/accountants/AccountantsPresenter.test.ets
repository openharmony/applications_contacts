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
import EditType from '../../../../../../../../../feature/account/src/main/ets/type/EditType';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { AccountVo } from '../../../../../../../main/ets/model/bean/AccountVo';
import { AIMBean } from '../../../../../../../main/ets/model/bean/AIMBean';
import { AssociatedPersonBean } from '../../../../../../../main/ets/model/bean/AssociatedPersonBean';
import { ContactInfo } from '../../../../../../../main/ets/model/bean/ContactInfo';
import { EmailBean } from '../../../../../../../main/ets/model/bean/EmailBean';
import { EventBean } from '../../../../../../../main/ets/model/bean/EventBean';
import { GroupBean } from '../../../../../../../main/ets/model/bean/GroupBean';
import { HouseBean } from '../../../../../../../main/ets/model/bean/HouseBean';
import { PhoneNumBean } from '../../../../../../../main/ets/model/bean/PhoneNumBean';
import LooseObject from '../../../../../../../main/ets/model/type/LooseObject';
import ArrangeContactsPresenter from '../../../../../../../main/ets/presenter/contact/settings/ArrangeContactsPresenter';
import AccountantsPresenter, {
  SelectInfoModel
} from '../../../../../../../main/ets/presenter/contact/accountants/AccountantsPresenter';
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import { HiLog } from '../../../../../../../../../feature/call/oh_modules/common';
import { AccountTypeService } from '../../../../../../../../../feature/account/src/main/ets/AccountTypeService';
import { ContactRepository } from '../../../../../../../../../feature/contact';
import PhoneAccountType from '../../../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import DotUtil from '../../../../../../../main/ets/util/DotUtil';
import { SingleSelectContact, SpeedDialItem } from '../../../../../../../main/ets/model/type';
import common from '@ohos.app.ability.common';
import { RichContactInfo } from '../../../../../../../main/ets/model/bean/RichContactInfo';
import { ContackPhoneSubInfoModel } from '../../../../../../../main/ets/model/type/ContactParams';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import ContactAbilityModel from '../../../../../../../main/ets/model/ContactAbilityModel';
import { BusinessError } from '@kit.BasicServicesKit';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import { contact } from '@kit.ContactsKit';
import SpeedDialEditCommon from '../../../../../../../main/ets/card/common/SpeedDialEditCommon';

export default function AccountantsPresenterTest() {
  describe('AccountantsPresenterTest', () => {
    let contactInfo: ContactInfo;

    beforeEach(() => {
      let id: string = '';
      let display_name: string = '';
      let nickname: string = '';
      let phones: PhoneNumBean[] = [];
      let emails: EmailBean[] = [];
      let remarks: string = '';
      let position: string = '';
      let company: string = '';
      let aims: AIMBean[] = [];
      let houses: HouseBean[] = [];
      let websites: string[] = [];
      let relationships: AssociatedPersonBean[] = [];
      let events: EventBean[] = [];
      let groups: GroupBean[] = [];
      let favorite: number = -1;
      let phoneticName: string = "";
      let otherLanLastName: string = "";
      let otherLanFirstName: string = "";
      contactInfo = new ContactInfo(id, display_name, nickname, phones, emails, position, company, remarks, aims, houses, websites, relationships, events, groups, favorite, phoneticName, otherLanLastName, otherLanFirstName);
    })

    it('AccountantsPresenterTest_init', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.init();
      expect(presenter.magList.length).assertEqual(1);
    })

    it('AccountantsPresenterTest_cancel', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let context: common.UIAbilityContext = {
        terminateSelfWithResult: (parameter: common.AbilityResult): Promise<void> =>
        new Promise<void>(resolve => resolve())
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      presenter.cancel();

      expect(presenter.clickEnable).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('AccountantsPresenterTest_cancel_error', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let context: common.UIAbilityContext = {
        terminateSelfWithResult: (parameter: common.AbilityResult): Promise<void> =>
        new Promise<void>((resolve: () => void, reject: (reason: BusinessError) => void) => {
          reject({
            code: 1, message: 'error'
          } as BusinessError);
        })
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      presenter.cancel();

      expect(presenter.isShowPosition).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('AccountantsPresenterTest_setDefaultData', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.setDefaultData(contactInfo);
      expect(contactInfo.events[0].eventType).assertEqual("1")
    })

    it('AccountantsPresenterTest_setDefaultData_phones_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      contactInfo.phones = [new PhoneNumBean('', '570977632', '', '', '', false, 1)];
      contactInfo.emails = [new EmailBean('', 'emailAddress', '1')];
      contactInfo.aims = [new AIMBean('', '', '1', 'aimName')];
      contactInfo.houses = [new HouseBean('', '', '1', 'houseName')];
      contactInfo.websites = ['websites']
      contactInfo.events = [new EventBean('', 'eventData', '1', '')];
      contactInfo.relationships = [new AssociatedPersonBean('', '', '', '1')];
      presenter.setDefaultData(contactInfo);
      expect(presenter.sourceHasParam).assertFalse();
    })

    it('AccountantsPresenterTest_refresh', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let state = false;
      presenter.refreshState = (presenter: AccountantsPresenter) => true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(presenter, presenter.refreshAddState);
      mocker.mockFunc(presenter, presenter.refreshState);
      when(mocker.mockFunc(presenter, presenter.refreshState))(ArgumentMatchers.any)
        .afterAction(() => {
          state = true;
        })
      presenter.refresh();

      mocker.verify('refreshAddState', []).once();
      expect(state).assertTrue();

      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_refreshAddState', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter = new ContactInfo('', 'test', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let mocker: MockKit = new MockKit();
      let getExistenceInfoString: Function = mocker.mockFunc(presenter, presenter.getExistenceInfoString);
      when(getExistenceInfoString)(presenter.contactInfoAfter)
        .afterReturn("'', 'test', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null");
      presenter.refreshAddState();
      expect(presenter.addState).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_updatesInit', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactId = '1';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(presenter, presenter.getPageData);
      presenter.updateShow = false;
      presenter.updatesInit();
      mocker.verify('getPageData', [presenter.contactId, undefined]).never();
      presenter.updateShow = true;
      presenter.updatesInit();
      mocker.verify('getPageData', [presenter.contactId, undefined]).once();
      mocker.clear(presenter);
    })

    it('showPhoneAndEmail_showPhoneAndEmail', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      expect(presenter.itemsShowState['phone']).assertFalse();
      expect(presenter.itemsShowState['email']).assertFalse();
      presenter.showPhoneAndEmail();
      expect(presenter.itemsShowState['phone']).assertTrue();
      expect(presenter.itemsShowState['email']).assertTrue();
    })

    it('AccountantsPresenterTest_getExistenceInfoString_afterInfo_properties_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let temp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let result: string = presenter.getExistenceInfoString(contactInfo);
      expect(result).assertEqual(JSON.stringify(temp))
    })

    it('AccountantsPresenterTest_getExistenceInfoString_afterInfo_not_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      contactInfo.display_name = 'display_name';
      contactInfo.phoneticName = 'phoneticName';
      contactInfo.nickname = 'nickname';
      contactInfo.remarks = 'remarks';
      contactInfo.position = 'position';
      contactInfo.company = 'company';
      contactInfo.company = 'company';
      contactInfo.photo = new Uint8Array();
      contactInfo.phones = [new PhoneNumBean('2314', '23', '3434', '23', '1', true, -1)];
      contactInfo.emails = [new EmailBean('', 'emailAddress', '1')];
      contactInfo.aims = [new AIMBean('', '', '1', 'aimName')];
      contactInfo.houses = [new HouseBean('', '', '1', 'houseName')];
      contactInfo.websites = ['websites']
      contactInfo.events = [new EventBean('', 'eventData', '1', '')];
      contactInfo.relationships = [new AssociatedPersonBean('', '', 'associatedPersonBean', '1')];
      presenter.getExistenceInfoString(contactInfo);
      expect(contactInfo.relationships[0].name).assertEqual('associatedPersonBean')
    })

    it('AccountantsPresenterTest_getPageData_id_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getContactById').afterAction(() => {
        result = true;
      });
      presenter.getPageData('');
      expect(result).assertTrue();
      mocker.clear(presenter);
      mocker.clear(workerWrapper);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('AccountantsPresenterTest_getPageData_id_not_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getContactById').afterAction(() => {
        result = true;
      });
      presenter.getPageData('1');
      expect(result).assertTrue();
      mocker.clear(presenter);
      mocker.clear(workerWrapper);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('AccountantsPresenterTest_getPageData_id_not_empty_callback_empty_result', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
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

      presenter.getPageData('-1');

      expect(presenter.clickEnable).assertTrue();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(ContactRepository.getInstance());
    })

    it('AccountantsPresenterTest_getPageData_id_not_empty_callback_notEmpty_result', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let mocker: MockKit = new MockKit();
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

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealResult);
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);
      mocker.mockFunc(presenter, presenter.dealRecordDetailsData);

      let phoneOriginalData: Function = mocker.mockFunc(presenter.originalDataHandleHelper, presenter.originalDataHandleHelper.phoneOriginalData);
      when(phoneOriginalData)(ArgumentMatchers.any).afterAction(() => {
        expect(result).assertTrue();
      });

      presenter.getPageData('1');

      expect(presenter.clickEnable).assertTrue();

      mocker.clear(presenter.originalDataHandleHelper);
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactAbilityModel);
    })

    it('AccountantsPresenterTest_getAccountName_accountId_not_valid', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.accountId = 0;
      expect(presenter.getAccountName() == "").assertTrue();
    })

    it('AccountantsPresenterTest_getAccountName_valid', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountId = '2';
      let accountName = 'test';
      let accountType = 'com.ohos.contacts';
      let dataInfo = '';
      let item: AccountVo = new AccountVo(accountId, accountName, accountType, dataInfo);
      ArrangeContactsPresenter.getInstance().accountList.push(item);
      presenter.accountId = 2;
      expect(presenter.getAccountName() == 'test').assertTrue();
    })

    it('AccountantsPresenterTest_getAccountName_notEqual', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountId = '2';
      let accountName = 'test';
      let accountType = 'com.ohos.contacts';
      let dataInfo = '';
      let item: AccountVo = new AccountVo(accountId, accountName, accountType, dataInfo);
      ArrangeContactsPresenter.getInstance().accountList.push(item);
      presenter.accountId = 1;

      expect(presenter.getAccountName() == '').assertTrue();
    })

    it('AccountantsPresenterTest_dealRecordDetailsData_phones_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = undefined;
      data.display_name = 'roxy';
      data.position = 'position1';
      presenter.contactId = '1';
      presenter.editContact = 0;
      presenter.phones = [];
      let contactTemp = new ContactInfo('1', 'roxy', '', [], [], 'position1', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let saveTemp2: Array<LooseObject> = [{
        'i': 1,
        'item': {
          num: '570977632',
          phoneAddress: 'Warsaw',
          primary: true,
          dataId: 1
        }
      }];
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
      phoneNumBean.id = presenter.callId;
      phoneNumBean.num = presenter.phoneNumberShow;
      phoneNumBean.numType = '';
      phoneNumBean.homeArea = '';
      phoneNumBean.carriers = '';
      presenter.contactInfoBefore.phones = [phoneNumBean];
      let saveTemp3: Array<LooseObject> = [];

      let mocker: MockKit = new MockKit();
      let contactInfo1: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      when(mocker.mockFunc(presenter, presenter.getContactTemp))(data).afterReturn(contactInfo1)
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(contactTemp)
        .afterReturn(JSON.stringify(contactTemp));

      let getArray: Function = mocker.mockFunc(presenter, presenter.getArray);
      when(getArray)(presenter.contactInfoBefore.phones).afterReturn(saveTemp2);
      when(getArray)(presenter.contactInfoBefore.emails).afterReturn(saveTemp3);

      mocker.mockFunc(presenter, presenter.setDefaultData);
      mocker.mockFunc(presenter, presenter.initContactSelectInfoModel);
      mocker.mockFunc(presenter, presenter.updateItemsShowState);
      mocker.mockFunc(presenter, presenter.refreshAddState);

      presenter.dealRecordDetailsData(data);

      expect(presenter.hasInitalPhoto).assertFalse();
      mocker.verify('refreshAddState', []).once();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_dealRecordDetailsData_phones_saveTemp_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = undefined;
      data.display_name = 'roxy';
      data.position = 'position1';
      presenter.contactId = '1';
      presenter.editContact = 0;
      presenter.phones = [{
        num: '570977632',
        phoneAddress: 'Warsaw',
        primary: true,
        dataId: 1
      } as ContackPhoneSubInfoModel];

      let contactTemp = new ContactInfo('1', 'roxy', '', [], [], 'position1', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let saveTemp2: Array<LooseObject> = [{
        'i': 1,
        'item': {
          num: '570977632',
          phoneAddress: 'Warsaw',
          primary: true,
          dataId: 1
        }
      }];
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
      phoneNumBean.id = presenter.callId;
      phoneNumBean.num = presenter.phoneNumberShow;
      phoneNumBean.numType = '';
      phoneNumBean.homeArea = '';
      phoneNumBean.carriers = '';
      presenter.contactInfoBefore.phones = [phoneNumBean];
      let saveTemp3: Array<LooseObject> = [];

      let mocker: MockKit = new MockKit();
      let contactInfo1: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      when(mocker.mockFunc(presenter, presenter.getContactTemp))(data).afterReturn(contactInfo1)
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(contactTemp)
        .afterReturn(JSON.stringify(contactTemp));

      let getArray: Function = mocker.mockFunc(presenter, presenter.getArray);
      when(getArray)(presenter.phones).afterReturn(undefined);

      when(getArray)(presenter.contactInfoBefore.phones).afterReturn(saveTemp2);
      when(getArray)(presenter.contactInfoBefore.emails).afterReturn(saveTemp3);

      mocker.mockFunc(presenter, presenter.setDefaultData);
      mocker.mockFunc(presenter, presenter.initContactSelectInfoModel);
      mocker.mockFunc(presenter, presenter.updateItemsShowState);
      mocker.mockFunc(presenter, presenter.refreshAddState);

      presenter.dealRecordDetailsData(data);

      expect(presenter.hasInitalPhoto).assertFalse();
      mocker.verify('refreshAddState', []).once();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_dealRecordDetailsData_phones_phonesElement_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = undefined;
      data.display_name = 'roxy';
      data.position = 'position1';
      presenter.contactId = '1';
      presenter.editContact = 0;
      presenter.phones = [{
        num: '570977632',
        phoneAddress: 'Warsaw',
        primary: true,
        dataId: 1
      } as ContackPhoneSubInfoModel];

      let contactTemp = new ContactInfo('1', 'roxy', '', [], [], 'position1', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let saveTemp2: Array<LooseObject> = [{
        'i': 1,
        'item': {
          num: '570977632',
          phoneAddress: 'Warsaw',
          primary: true,
          dataId: 1
        }
      }];
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
      phoneNumBean.id = presenter.callId;
      phoneNumBean.num = presenter.phoneNumberShow;
      phoneNumBean.numType = '';
      phoneNumBean.homeArea = '';
      phoneNumBean.carriers = '';
      presenter.contactInfoBefore.phones = [phoneNumBean];
      let saveTemp3: Array<LooseObject> = [];

      let mocker: MockKit = new MockKit();
      let contactInfo1: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      when(mocker.mockFunc(presenter, presenter.getContactTemp))(data).afterReturn(contactInfo1)
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(contactTemp)
        .afterReturn(JSON.stringify(contactTemp));

      let getArray: Function = mocker.mockFunc(presenter, presenter.getArray);

      let itemList: Array<LooseObject> = [{
        'item': undefined
      }];
      when(getArray)(presenter.phones).afterReturn(itemList);

      when(getArray)(presenter.contactInfoBefore.phones).afterReturn(saveTemp2);
      when(getArray)(presenter.contactInfoBefore.emails).afterReturn(saveTemp3);

      mocker.mockFunc(presenter, presenter.setDefaultData);
      mocker.mockFunc(presenter, presenter.initContactSelectInfoModel);
      mocker.mockFunc(presenter, presenter.updateItemsShowState);
      mocker.mockFunc(presenter, presenter.refreshAddState);

      presenter.dealRecordDetailsData(data);

      expect(presenter.hasInitalPhoto).assertFalse();
      mocker.verify('refreshAddState', []).once();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_dealRecordDetailsData_elseIf', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = undefined;
      data.display_name = 'roxy';
      data.position = 'position1';
      presenter.editContact = 1;
      presenter.phoneNumberShow = '';
      let contactInfo1: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let contactTemp = new ContactInfo('1', 'roxy', '', [], [], 'position1', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getContactTemp))(data).afterReturn(contactInfo1);
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(contactTemp)
        .afterReturn(JSON.stringify(contactTemp));
      mocker.mockFunc(presenter, presenter.parseParamsFromSaveExistContact);
      let contactFromPicker: contact.Contact = {
        id: 0,
        key: '',
        emails: [],
        events: [],
        groups: [],
        imAddresses: [],
        phoneNumbers: [],
        portrait: {
          uri: ''
        },
        postalAddresses: [],
        relations: [],
        websites: [],
        name: {
          fullName: ''
        },
        note: {
          noteContent: ''
        },
        organization: {
          name: ''
        }
      };
      presenter.newContactData = contactFromPicker;
      presenter.dealRecordDetailsData(data);
      mocker.verify('parseParamsFromSaveExistContact', [presenter.newContactData]).once();

      presenter.phoneNumberShow = '13312345678';
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
      phoneNumBean.id = presenter.callId;
      phoneNumBean.num = presenter.phoneNumberShow;
      phoneNumBean.numType = '';
      phoneNumBean.homeArea = '';
      phoneNumBean.carriers = '';
      presenter.contactInfoBefore.phones = [phoneNumBean];
      mocker.mockFunc(presenter, presenter.refreshAddState);
      presenter.dealRecordDetailsData(data);
      mocker.verify('refreshAddState', []).once();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_initContactSelectInfoModel', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactInfo: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      presenter.initContactSelectInfoModel(contactInfo);
      expect(JSON.stringify(presenter.contactSelectInfoModel.emails))
        .assertEqual(JSON.stringify([new SelectInfoModel()]));
      expect(JSON.stringify(presenter.contactSelectInfoModel.phones))
        .assertEqual(JSON.stringify([new SelectInfoModel()]));
      expect(JSON.stringify(presenter.contactSelectInfoModel.aims))
        .assertEqual(JSON.stringify([new SelectInfoModel()]));
      expect(JSON.stringify(presenter.contactSelectInfoModel.houses))
        .assertEqual(JSON.stringify([new SelectInfoModel()]));
      expect(JSON.stringify(presenter.contactSelectInfoModel.relationships))
        .assertEqual(JSON.stringify([new SelectInfoModel()]));
    })

    it('AccountantsPresenterTest_getData', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoBefore.phones.push(new PhoneNumBean('', '13801001234', '1', '', ''));
      let phones: Array<LooseObject> = [{
        i: 1,
        item: new PhoneNumBean('', '13801001234', '1', '', '')
      }];
      expect(JSON.stringify(presenter.getData('phone', 0))).assertEqual(JSON.stringify(phones[0]));
      presenter.contactInfoBefore.emails.push(new EmailBean('', '1', '1'));
      let emails: Array<LooseObject> = [{
        i: 1,
        item: new EmailBean('', '1', '1')
      }];
      expect(JSON.stringify(presenter.getData('email', 0))).assertEqual(JSON.stringify(emails[0]));
      presenter.contactInfoBefore.aims.push(new AIMBean('', '', '', 'aims'));
      let aims: Array<LooseObject> = [{
        i: 1,
        item: new AIMBean('', '', '', 'aims')
      }];
      expect(JSON.stringify(presenter.getData('AIM', 0))).assertEqual(JSON.stringify(aims[0]));
      presenter.contactInfoBefore.houses.push(new HouseBean('', '', '', 'houses'));
      let houses: Array<LooseObject> = [{
        i: 1,
        item: new HouseBean('', '', '', 'houses')
      }];
      expect(JSON.stringify(presenter.getData('house', 0))).assertEqual(JSON.stringify(houses[0]));
      presenter.contactInfoBefore.relationships.push(new AssociatedPersonBean('', '', 'relationships', ''));
      let relationships: Array<LooseObject> = [{
        i: 1,
        item: new AssociatedPersonBean('', '', 'relationships', '')
      }];
      expect(JSON.stringify(presenter.getData('relationships', 0))).assertEqual(JSON.stringify(relationships[0]));
      presenter.contactInfoBefore.events.push(new EventBean('', 'data', '', 'events'));
      let events: Array<LooseObject> = [{
        i: 1,
        item: new EventBean('', 'data', '', 'events')
      }];
      expect(JSON.stringify(presenter.getData('events', 0))).assertEqual(JSON.stringify(events[0]));
      presenter.contactInfoBefore.websites.push('websites');
      let websites: Array<LooseObject> = [{
        i: 1,
        item: 'websites'
      }];
      expect(JSON.stringify(presenter.getData('website', 0))).assertEqual(JSON.stringify(websites[0]));
      presenter.updateShow = true;
      presenter.getPhones = phones;
      expect(JSON.stringify(presenter.getData('phone', 0))).assertEqual(JSON.stringify(phones[0]));
      presenter.getEmails = emails;
      expect(JSON.stringify(presenter.getData('email', 0))).assertEqual(JSON.stringify(emails[0]));

      expect(JSON.stringify(presenter.getData('contacts', 0))).assertUndefined();
    })
    /*
    *index = data.length 1=1
    * this.updateShow = false
    */
    it('AccountantsPresenterTest_getData_phone_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "highlighting": false,
          "pickerData": {
            "phoneNumber": ""
          },
          "selectTextCustom": "",
          "num": "570977632",
          "numType": "",
          "homeArea": "",
          "carriers": "",
          "primary": true,
          "dataId": 1
        }
      };
      presenter.contactInfoBefore.phones = [new PhoneNumBean('', '570977632', '', '', '', true, 1)];
      let phones = presenter.contactInfoBefore.phones;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(phones)
        .afterReturn(phones.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('phone', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_phone_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let phones: Array<LooseObject> = [{
        i: 1,
        item: new PhoneNumBean('', '570977632', '', '', '', true, 1)
      }];
      presenter.getPhones = phones;
      presenter.updateShow = true;
      let result = presenter.getData('phone', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(phones[0]));
    })

    /*
     * index = data.length 1=1
     * this.updateShow = false
     */
    it('AccountantsPresenterTest_getData_email_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "pickerData": {
            "email": ""
          },
          "selectTextCustom": "",
          "address": "rongsheng.zhang@ohos.com",
          "emailType": ""
        }
      };
      presenter.contactInfoBefore.emails = [new EmailBean('', 'rongsheng.zhang@ohos.com', '')];
      let emails = presenter.contactInfoBefore.emails;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(emails)
        .afterReturn(emails.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('email', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_email_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let emails: Array<LooseObject> = [{
        i: 1,
        item: new EmailBean('', 'rongsheng.zhang@ohos.com', '')
      }];
      presenter.getEmails = emails;
      presenter.updateShow = true;
      let result = presenter.getData('email', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(emails[0]));
    })
    /*
     * * index = data.length 1=1
     * * this.updateShow = false
     * */
    it('AccountantsPresenterTest_getData_aim_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "pickerData": {
            "imAddress": ""
          },
          "id": "1",
          "selectTextCustom": "",
          "aimType": "",
          "aimName": "aim1"
        }
      };
      let aims = [new AIMBean('1', '', '', 'aim1')];
      presenter.contactInfoBefore.aims = aims;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(aims)
        .afterReturn(aims.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('AIM', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_aim_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let aim: AIMBean = new AIMBean('1', '', '', 'aim1');
      let data: LooseObject = {
        'i': 1, 'item': aim
      };
      presenter.contactInfoBefore.aims = [aim];
      presenter.updateShow = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(presenter.contactInfoBefore.aims).afterReturn([data]);
      let result = presenter.getData('AIM', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /*
     * index = data.length 1=1
     * this.updateShow = false
    */
    it('AccountantsPresenterTest_getData_house_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "houseId": "",
          "pickerData": {
            "postalAddress": ""
          },
          "id": "1",
          "selectTextCustom": "",
          "houseType": "",
          "houseName": "house1"
        }
      };
      let houses = [new HouseBean('1', '', '', 'house1')];
      presenter.contactInfoBefore.houses = houses;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(houses)
        .afterReturn(houses.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('house', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_house_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let house: HouseBean = new HouseBean('1', '', '', 'house1');
      let data: LooseObject = {
        'i': 1, 'item': house
      };
      presenter.contactInfoBefore.houses = [house];
      presenter.updateShow = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(presenter.contactInfoBefore.houses).afterReturn([data]);
      let result = presenter.getData('house', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /*
     * index = data.length 1=1
     * this.updateShow = false
    */
    it('AccountantsPresenterTest_getData_relationship_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "pickerData": {
            "relationName": ""
          },
          "selectTextCustom": "",
          "associatedPersonId": "2",
          "name": "person1",
          "associatedType": ""
        }
      };
      let relationships = [new AssociatedPersonBean('', '2', 'person1', '')];
      presenter.contactInfoBefore.relationships = relationships;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(relationships)
        .afterReturn(relationships.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('relationships', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_relationship_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let relationship: AssociatedPersonBean = new AssociatedPersonBean('', '2', 'person1', '');
      let data: LooseObject = {
        'i': 1, 'item': relationship
      };
      presenter.contactInfoBefore.relationships = [relationship];
      presenter.updateShow = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(presenter.contactInfoBefore.relationships)
        .afterReturn([data]);
      let result = presenter.getData('relationships', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /*
     * index = data.length 1=1
     * this.updateShow = false
    */
    it('AccountantsPresenterTest_getData_event_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': {
          "contactDataId": -1,
          "pickerData": {
            "eventDate": ""
          },
          "id": "1",
          "data": "",
          "eventType": "",
          "eventName": "event1"
        }
      };
      let events = [new EventBean('1', '', '', 'event1')];
      presenter.contactInfoBefore.events = events;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(events)
        .afterReturn(events.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('events', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_event_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let event: EventBean = new EventBean('1', '', '', 'event1');
      let data: LooseObject = {
        'i': 1, 'item': event
      };
      presenter.contactInfoBefore.events = [event];
      presenter.updateShow = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(presenter.contactInfoBefore.events).afterReturn([data]);
      let result = presenter.getData('events', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /*
     * index = data.length 1=1
     * this.updateShow = false
    */
    it('AccountantsPresenterTest_getData_website_index_1_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let index = 0;
      let data: LooseObject = {
        'i': index + 1,
        'item': "www.xxx.com"
      };
      let websites = ['www.xxx.com'];
      presenter.contactInfoBefore.websites = websites;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(websites)
        .afterReturn(websites.map((item, index: number) => {
          let result: LooseObject = {
            i: index + 1,
            item: item
          };
          return result;
        }));
      presenter.updateShow = false;
      let result = presenter.getData('website', index);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })
    /**
     * index < data.length 0<1
     * this.updateShow = true
     */
    it('AccountantsPresenterTest_getData_website_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let website: string = 'www.xxx.com';
      let data: LooseObject = {
        'i': 1, 'item': website
      };
      presenter.contactInfoBefore.websites = [website];
      presenter.updateShow = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(presenter.contactInfoBefore.websites).afterReturn([data]);
      let result = presenter.getData('website', 0);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getSelectInfoModel', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editType: EditType = new EditType(1, 'test');
      let selectInfoModel: SelectInfoModel = new SelectInfoModel();
      let editTypeArray: EditType[] = [];
      editTypeArray.push(editType);
      selectInfoModel.selectInfoArr = editTypeArray;
      let selectInfoModels: SelectInfoModel[] = [];
      selectInfoModels.push(selectInfoModel);
      presenter.contactSelectInfoModel.phones = selectInfoModels;
      presenter.contactSelectInfoModel.emails = selectInfoModels;
      presenter.contactSelectInfoModel.aims = selectInfoModels;
      presenter.contactSelectInfoModel.houses = selectInfoModels;
      presenter.contactSelectInfoModel.relationships = selectInfoModels;
      expect(presenter.getSelectInfoModel('phone', 0).selectInfoArr.length).assertEqual(1);
      expect(presenter.getSelectInfoModel('email', 0).selectInfoArr.length).assertEqual(1);
      expect(presenter.getSelectInfoModel('AIM', 0).selectInfoArr.length).assertEqual(1);
      expect(presenter.getSelectInfoModel('house', 0).selectInfoArr.length).assertEqual(1);
      expect(presenter.getSelectInfoModel('relationships', 0).selectInfoArr.length).assertEqual(1);
      expect(presenter.getSelectInfoModel('test', 0).selectInfoArr.length).assertEqual(0);
    })

    it('AccountantsPresenterTest_getArray_emptyArray', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let array: Array<LooseObject> = [];
      let result = presenter.getArray(array);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(array));
    })

    it('AccountantsPresenterTest_getArray_notEmptyArray', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let item = new EventBean('1', '', '', 'event1');
      let array = [item];
      let items: Array<LooseObject> = [{
        'i': 1,
        'item': item
      }];
      let result = presenter.getArray(array);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(items));
    })

    it('AccountantsPresenterTest_getArrayCommon_arrayEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      expect(JSON.stringify(presenter.getArrayCommon([]))).assertEqual('[]');
    })

    it('AccountantsPresenterTest_getArrayCommon_arrayNotEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoBefore.websites = ['websites'];
      expect(presenter.getArrayCommon(['websites'])[0].item).assertEqual('websites');
    })

    it('AccountantsPresenterTest_getDataArray_phone_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = false;
      let phone = new PhoneNumBean('', '570977632', '', '', '', true, 1);
      let phones = [phone];
      let data: Array<LooseObject> = [{
        i: 1,
        item: phone
      }];
      presenter.contactInfoBefore.phones = phones;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(phones).afterReturn(data);
      let result = presenter.getDataArray('phone');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_phone_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let phones: Array<LooseObject> = [{
        i: 1,
        item: new PhoneNumBean('', '570977633', '', '', '', true, 1)
      }];
      presenter.getPhones = phones;
      presenter.updateShow = true;
      let result = presenter.getDataArray('phone');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(phones));
    })

    it('AccountantsPresenterTest_getDataArray_email_updateshow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = false;
      let email = new EmailBean('', 'rongsheng.zhang@ohos.com', '');
      let emails = [email];
      let data: Array<LooseObject> = [{
        i: 1,
        item: email
      }];
      presenter.contactInfoBefore.emails = emails;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(emails).afterReturn(data);
      let result = presenter.getDataArray('email');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_email_updateshow_true', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let emails: Array<LooseObject> = [{
        i: 1,
        item: new EmailBean('', 'rongsheng.zhang@ohos.com', '')
      }];
      presenter.getEmails = emails;
      presenter.updateShow = true;
      let result = presenter.getDataArray('email');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(emails));
    })

    it('AccountantsPresenterTest_getData_aim', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let aim: AIMBean = new AIMBean('1', '', '', 'aim1');
      let aims = [aim];
      let data: Array<LooseObject> = [{
        'i': 1,
        'item': aim
      }];
      presenter.contactInfoBefore.aims = aims;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(aims).afterReturn(data);
      let result = presenter.getDataArray('AIM');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_house', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let house: HouseBean = new HouseBean('1', '', '', 'house1');
      let data: Array<LooseObject> = [{
        'i': 1,
        'item': house
      }];
      let houses = [house];
      presenter.contactInfoBefore.houses = houses;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(houses).afterReturn(data);
      let result = presenter.getDataArray('house');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_relationship', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let relationship: AssociatedPersonBean = new AssociatedPersonBean('', '2', 'person1', '');
      let data: Array<LooseObject> = [{
        'i': 1,
        'item': relationship
      }];
      let relationships = [relationship];
      presenter.contactInfoBefore.relationships = relationships;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(relationships).afterReturn(data);
      let result = presenter.getDataArray('relationships');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_event', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let event: EventBean = new EventBean('1', '', '', 'event1');
      let data: LooseObject = {
        'i': 1,
        'item': event
      };
      let events = [event];
      presenter.contactInfoBefore.events = events;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(events).afterReturn(data);
      let result = presenter.getDataArray('events');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(data));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray_website', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let website: string = "www.xxx.com"
      let data: LooseObject = {
        "i": 1,
        "item": website
      };
      let websites = [website];
      presenter.contactInfoBefore.websites = websites;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getArray))(websites).afterReturn(data);
      let result = presenter.getDataArray('website');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify([data]));
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getDataArray', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoBefore.phones.push(new PhoneNumBean('', '', '1', '', ''));
      expect(presenter.getDataArray('phone').length).assertEqual(1);
      presenter.contactInfoBefore.emails.push(new EmailBean('', '', '1'));
      expect(presenter.getDataArray('email').length).assertEqual(1);
      presenter.contactInfoBefore.aims.push(new AIMBean('', '', '', 'aims'));
      expect(presenter.getDataArray('AIM').length).assertEqual(1);
      presenter.contactInfoBefore.houses.push(new HouseBean('', '', '', 'houses'));
      expect(presenter.getDataArray('house').length).assertEqual(1);
      presenter.contactInfoBefore.relationships.push(new AssociatedPersonBean('', '', 'relationships', ''));
      expect(presenter.getDataArray('relationships').length).assertEqual(1);
      presenter.contactInfoBefore.events.push(new EventBean('', '', '', 'events'));
      expect(presenter.getDataArray('events').length).assertEqual(1);
      presenter.contactInfoBefore.websites.push('websites');
      expect(presenter.getDataArray('website').length).assertEqual(1);
      presenter.updateShow = true;
      let looseObject: LooseObject = {
        'name': 'test',
      }
      let looseObjects: Array<LooseObject> = [looseObject];
      presenter.getPhones = looseObjects;
      expect(presenter.getDataArray('phone').length).assertEqual(1);
      presenter.getEmails = looseObjects;
      expect(presenter.getDataArray('email').length).assertEqual(1);
    })

    it('AccountantsPresenterTest_addMore', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.addMore('phone');
      expect(presenter.contactInfoAfter.phones[0].numType).assertEqual('1');
      presenter.addMore('email');
      expect(presenter.contactInfoAfter.emails[0].emailType).assertEqual('1');
      presenter.addMore('AIM');
      expect(presenter.contactInfoAfter.aims[0].aimType).assertEqual('1');
      presenter.addMore('house');
      expect(presenter.contactInfoAfter.houses[0].houseType).assertEqual('1');
      presenter.addMore('relationships');
      expect(presenter.contactInfoAfter.relationships[0].associatedType).assertEqual('1');
      let eventBean: EventBean = new EventBean('1', '', '1', 'event1');
      presenter.contactInfoBefore.events.push(eventBean);
      presenter.addMore('events');
      expect(presenter.contactInfoAfter.events[0].eventType).assertEqual('1');
      presenter.contactInfoBefore.events = [];
      presenter.addMore('website');
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('');
      presenter.addMore('test');
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('');
    })

    it('AccountantsPresenterTest_deleteItem_length_1', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      presenter.contactInfoAfter.phones.push(new PhoneNumBean('', '1', '1', '', ''));
      presenter.contactInfoAfter.phones.push(new PhoneNumBean('', '1', '1', '', ''));
      presenter.deleteItem('phone', 0);
      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('1');
      presenter.contactInfoAfter.phones.push(new PhoneNumBean('', '2', '1', '', ''));
      presenter.deleteItem('phone', 0);
      expect(presenter.getPhones.length).assertEqual(1);

      presenter.contactInfoBefore.emails.push(new EmailBean('', '1', '1'));
      presenter.contactInfoBefore.emails.push(new EmailBean('', '1', '1'));
      presenter.deleteItem('email', 0);
      expect(presenter.contactInfoAfter.emails[0].address).assertEqual('1');

      presenter.contactInfoBefore.emails.push(new EmailBean('', '2', '1'));
      presenter.deleteItem('email', 0);
      expect(presenter.getEmails.length).assertEqual(1);

      presenter.contactInfoBefore.aims.push(new AIMBean('', '', '', 'aims'));
      presenter.contactInfoBefore.aims.push(new AIMBean('', '', '', 'aims'));
      presenter.deleteItem('AIM', 0);
      expect(presenter.contactInfoAfter.aims[0].aimName).assertEqual('aims');

      presenter.contactInfoBefore.aims.push(new AIMBean('', '', '', 'aims2'));
      presenter.deleteItem('AIM', 0);
      expect(presenter.contactInfoBefore.aims.length).assertEqual(1);

      presenter.contactInfoBefore.houses.push(new HouseBean('', '', '', 'houses'));
      presenter.contactInfoBefore.houses.push(new HouseBean('', '', '', 'houses'));
      presenter.deleteItem('house', 0);
      expect(presenter.contactInfoAfter.houses[0].houseName).assertEqual('houses');
      presenter.contactInfoBefore.houses.push(new HouseBean('', '', '', 'houses2'));
      presenter.deleteItem('house', 0);
      expect(presenter.contactInfoBefore.houses.length).assertEqual(1);

      presenter.contactInfoBefore.relationships.push(new AssociatedPersonBean('', '', 'relationships', ''));
      presenter.contactInfoBefore.relationships.push(new AssociatedPersonBean('', '', 'relationships', ''));
      presenter.deleteItem('relationships', 0);
      expect(presenter.contactInfoAfter.relationships[0].name).assertEqual('relationships');
      presenter.contactInfoBefore.relationships.push(new AssociatedPersonBean('', '', 'relationships2', ''));
      presenter.deleteItem('relationships', 0);
      expect(presenter.contactInfoBefore.relationships.length).assertEqual(1);

      presenter.contactInfoBefore.events.push(new EventBean('', 'data', '', 'events'));
      presenter.contactInfoBefore.events.push(new EventBean('', 'data', '', 'events'));
      presenter.deleteItem('events', 0);
      expect(presenter.contactInfoAfter.events[0].data).assertEqual('data');
      presenter.contactInfoBefore.events.push(new EventBean('', 'data2', '', 'events'));
      presenter.deleteItem('events', 0);
      expect(presenter.contactInfoBefore.events.length).assertEqual(1);

      presenter.contactInfoBefore.websites.push('websites');
      presenter.contactInfoBefore.websites.push('websites');
      presenter.deleteItem('website', 0);
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('websites');
      presenter.contactInfoBefore.websites.push('websites2');
      presenter.deleteItem('website', 0);
      expect(presenter.contactInfoAfter.websites.length).assertEqual(1);

      presenter.deleteItem('test', 0);
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('websites2');
    })

    it('AccountantsPresenterTest_deleteItem_phone_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '1', '1', '', '', false, 1), new PhoneNumBean('', '2', '1', '', '', false, 2)];
      presenter.deleteItem('phone', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.phones))
        .assertEqual(JSON.stringify([new PhoneNumBean('', '2', '1', '', '', false, 2)]));
    })

    it('AccountantsPresenterTest_deleteItem_email_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.emails = [new EmailBean('', 'rongsheng.zhang@ohos.com', ''), new EmailBean('', 'roxy.zhang@ohos.com', '')];
      presenter.deleteItem('email', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.emails))
        .assertEqual(JSON.stringify([new EmailBean('', 'roxy.zhang@ohos.com', '')]));
    })

    it('AccountantsPresenterTest_deleteItem_AIM_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.aims = [new AIMBean('1', '', '', 'aim1'), new AIMBean('2', '', '', 'aim2')];
      presenter.deleteItem('AIM', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.aims))
        .assertEqual(JSON.stringify([new AIMBean('2', '', '', 'aim2')]));
    })

    it('AccountantsPresenterTest_deleteItem_house_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.houses = [new HouseBean('1', '', '', 'house1'), new HouseBean('2', '', '', 'house2')];
      presenter.deleteItem('house', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.houses))
        .assertEqual(JSON.stringify([new HouseBean('2', '', '', 'house2')]));
    })

    it('AccountantsPresenterTest_deleteItem_relationship_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '2', 'person1', ''), new AssociatedPersonBean('', '3', 'person2', '')];
      presenter.deleteItem('relationships', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.relationships))
        .assertEqual(JSON.stringify([new AssociatedPersonBean('', '3', 'person2', '')]));
    })

    it('AccountantsPresenterTest_deleteItem_events_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.events = [new EventBean('1', '', '', 'event1'), new EventBean('2', '', '', 'event2')];
      presenter.deleteItem('events', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.events))
        .assertEqual(JSON.stringify([new EventBean('2', '', '', 'event2')]));
    })

    it('AccountantsPresenterTest_deleteItem_website_length_2', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.websites = ['www.xxx.com', 'www.yyy.com'];
      presenter.deleteItem('website', 0);
      expect(JSON.stringify(presenter.contactInfoAfter.websites))
        .assertEqual(JSON.stringify(['www.yyy.com']));
    })

    it('AccountantsPresenterTest_getTextDisplay_item_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': undefined,
      }
      expect(presenter.getTextDisplay('phone', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('email', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('AIM', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('house', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('relationships', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('events', looseObject)).assertEqual('');
    })

    it('AccountantsPresenterTest_getTextDisplay_num_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': {
          'num': null,
          'address': null,
          'aimName': null,
          'houseName': null,
          'name': null,
          'data': null,
        }
      }
      expect(presenter.getTextDisplay('phone', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('email', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('AIM', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('house', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('relationships', looseObject)).assertEqual('');
      expect(presenter.getTextDisplay('events', looseObject)).assertEqual('');
    })

    it('AccountantsPresenterTest_getTextDisplay', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': {
          'num': 'phone',
          'address': 'email',
          'aimName': 'aim',
          'houseName': 'house',
          'name': 'relationships',
          'data': 'events',
        },
      }
      expect(presenter.getTextDisplay('phone', looseObject)).assertEqual('phone');

      expect(presenter.getTextDisplay('email', looseObject)).assertEqual('email');

      expect(presenter.getTextDisplay('AIM', looseObject)).assertEqual('aim');

      expect(presenter.getTextDisplay('house', looseObject)).assertEqual('house');

      expect(presenter.getTextDisplay('relationships', looseObject)).assertEqual('relationships');

      expect(presenter.getTextDisplay('events', looseObject)).assertEqual('events');

      let looseObjectWeb: LooseObject = {
        'item': 'website',
      }
      expect(presenter.getTextDisplay('website', looseObjectWeb)).assertEqual('website');

      let testLooseObject: LooseObject = {
        'item': 'test'
      }
      expect(presenter.getTextDisplay('test', testLooseObject)).assertEqual('');
    })

    it('AccountantsPresenterTest_listItemChange', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'i': 1,
      };
      presenter.contactInfoAfter.emails = [new EmailBean('', 'emailAddress', '1')];
      presenter.contactInfoAfter.aims = [new AIMBean('', '', '1', 'aimName')];
      presenter.contactInfoAfter.houses = [new HouseBean('', '', '1', 'houseName')];
      presenter.contactInfoAfter.websites = ['websites']
      presenter.contactInfoAfter.events = [new EventBean('', 'eventData', '1', '')];
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '', 'associatedPersonBean', '1')];
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '570977632', '1', '', '', false, 1)];

      presenter.listItemChange('phone', looseObject, 'phone');
      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('phone');
      expect(presenter.contactInfoAfter.phones[0].numType).assertEqual('1');
      presenter.listItemChange('email', looseObject, 'email');
      expect(presenter.contactInfoAfter.emails[0].address).assertEqual('email');
      presenter.listItemChange('AIM', looseObject, 'AIM');
      expect(presenter.contactInfoAfter.aims[0].aimName).assertEqual('AIM');
      presenter.listItemChange('house', looseObject, 'house');
      expect(presenter.contactInfoAfter.houses[0].houseName).assertEqual('house');
      presenter.listItemChange('relationships', looseObject, 'relationships');
      expect(presenter.contactInfoAfter.relationships[0].name).assertEqual('relationships');
      presenter.listItemChange('website', looseObject, 'website');
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('website');
      presenter.listItemChange('test', looseObject, 'test');
      expect(presenter.contactInfoAfter.websites.length).assertEqual(1);
    })

    it('AccountantsPresenterTest_listItemChange_ifEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'i': 1,
      };
      presenter.contactInfoAfter.emails = [new EmailBean('', 'emailAddress', '')];
      presenter.contactInfoAfter.aims = [new AIMBean('', '', '', 'aimName')];
      presenter.contactInfoAfter.houses = [new HouseBean('', '', '', 'houseName')];
      presenter.contactInfoAfter.websites = ['websites']
      presenter.contactInfoAfter.events = [new EventBean('', 'eventData', '1', '')];
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '', 'associatedPersonBean', '')];
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '570977632', '', '', '', false, 1)];

      presenter.listItemChange('phone', looseObject, 'phone');
      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('phone');
      expect(presenter.contactInfoAfter.phones[0].numType).assertEqual('1');
      presenter.listItemChange('email', looseObject, 'email');
      expect(presenter.contactInfoAfter.emails[0].address).assertEqual('email');
      presenter.listItemChange('AIM', looseObject, 'AIM');
      expect(presenter.contactInfoAfter.aims[0].aimName).assertEqual('AIM');
      presenter.listItemChange('house', looseObject, 'house');
      expect(presenter.contactInfoAfter.houses[0].houseName).assertEqual('house');
      presenter.listItemChange('relationships', looseObject, 'relationships');
      expect(presenter.contactInfoAfter.relationships[0].name).assertEqual('relationships');
      presenter.listItemChange('website', looseObject, 'website');
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('website');
      presenter.listItemChange('test', looseObject, 'test');
      expect(presenter.contactInfoAfter.websites.length).assertEqual(1);
    })

    it('AccountantsPresenterTest_listItemChange_ifEmpty_num_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'i': 1,
      };
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '', '', '', '', false, 1)];

      presenter.listItemChange('phone', looseObject, 'phone');
      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('phone');
      expect(presenter.contactInfoAfter.phones[0].highlighting).assertFalse();
    })

    it('AccountantsPresenterTest_listItemChange_error', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'i': 1,
      };
      let phoneBean: PhoneNumBean = new PhoneNumBean('', '570977632', '', '', '', false, 1);
      presenter.contactInfoAfter.phones = [phoneBean];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refreshAddState))().afterThrow('error refresh');

      presenter.listItemChange('phone', looseObject, 'phone');

      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('phone');

      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuSelectSysAndCustom', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': {
          numType: 1,
          emailType: 1,
          aimType: 1,
          houseType: 1,
          associatedType: 1,
          eventType: 1
        },
      }
      let phoneEditType: EditType = new EditType(0, 'test');
      let phoneResource = presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditType);
      let expectedPhoneResource: Resource = $r('app.string.phone_type_mobile');
      expect(JSON.stringify(phoneResource)).assertEqual(JSON.stringify(expectedPhoneResource));
      let phoneEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditTypeWithSameId)).assertEqual('test');

      let emailEditType: EditType = new EditType(0, 'test');
      let emailResource = presenter.menuSelectSysAndCustom('email', looseObject, emailEditType);
      let expectedEmailResource: Resource = $r('app.string.email_type_home');
      expect(JSON.stringify(emailResource)).assertEqual(JSON.stringify(expectedEmailResource));
      let emailEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('email', looseObject, emailEditTypeWithSameId)).assertEqual('test');

      let aimEditType: EditType = new EditType(0, 'test');
      let aimResource = presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditType);
      let expectedAimResource: Resource = $r('app.string.instant_type_aim');
      expect(JSON.stringify(aimResource)).assertEqual(JSON.stringify(expectedAimResource));
      let aimEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditTypeWithSameId)).assertEqual('test');

      let houseEditType: EditType = new EditType(0, 'test');
      let houseResource = presenter.menuSelectSysAndCustom('house', looseObject, houseEditType);
      let expectedHouseResource: Resource = $r('app.string.house_type_dwelling');
      expect(JSON.stringify(houseResource)).assertEqual(JSON.stringify(expectedHouseResource));
      let houseEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('house', looseObject, houseEditTypeWithSameId)).assertEqual('test');

      let relationshipsEditType: EditType = new EditType(0, 'test');
      let relationshipsResource = presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditType);
      let expectedRelationshipsResource: Resource = $r('app.string.relationship_type_assistant');
      expect(JSON.stringify(relationshipsResource)).assertEqual(JSON.stringify(expectedRelationshipsResource));
      let relationshipsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditTypeWithSameId))
        .assertEqual('test');

      let eventsEditType: EditType = new EditType(0, 'test');
      let eventsResource = presenter.menuSelectSysAndCustom('events', looseObject, eventsEditType);
      let expectedEventsResource: Resource = $r('app.string.birthday_type_grebirthday');
      expect(JSON.stringify(eventsResource)).assertEqual(JSON.stringify(expectedEventsResource));
      let eventsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('events', looseObject, eventsEditTypeWithSameId)).assertEqual('test');

      let testEditType: EditType = new EditType(0, 'test');
      expect(presenter.menuSelectSysAndCustom('test', looseObject, testEditType)).assertEqual('');
    })

    it('AccountantsPresenterTest_menuSelectSysAndCustom_item_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': undefined,
      }
      let phoneEditType: EditType = new EditType(0, 'test');
      let phoneResource = presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditType);
      let expectedPhoneResource: Resource = $r('app.string.phone_type_mobile');
      expect(JSON.stringify(phoneResource)).assertEqual(JSON.stringify(expectedPhoneResource));
      let phoneEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditTypeWithSameId)).assertEqual('test');

      let emailEditType: EditType = new EditType(0, 'test');
      let emailResource = presenter.menuSelectSysAndCustom('email', looseObject, emailEditType);
      let expectedEmailResource: Resource = $r('app.string.email_type_home');
      expect(JSON.stringify(emailResource)).assertEqual(JSON.stringify(expectedEmailResource));
      let emailEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('email', looseObject, emailEditTypeWithSameId)).assertEqual('test');

      let aimEditType: EditType = new EditType(0, 'test');
      let aimResource = presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditType);
      let expectedAimResource: Resource = $r('app.string.instant_type_aim');
      expect(JSON.stringify(aimResource)).assertEqual(JSON.stringify(expectedAimResource));
      let aimEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditTypeWithSameId)).assertEqual('test');

      let houseEditType: EditType = new EditType(0, 'test');
      let houseResource = presenter.menuSelectSysAndCustom('house', looseObject, houseEditType);
      let expectedHouseResource: Resource = $r('app.string.house_type_dwelling');
      expect(JSON.stringify(houseResource)).assertEqual(JSON.stringify(expectedHouseResource));
      let houseEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('house', looseObject, houseEditTypeWithSameId)).assertEqual('test');

      let relationshipsEditType: EditType = new EditType(0, 'test');
      let relationshipsResource = presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditType);
      let expectedRelationshipsResource: Resource = $r('app.string.relationship_type_assistant');
      expect(JSON.stringify(relationshipsResource)).assertEqual(JSON.stringify(expectedRelationshipsResource));
      let relationshipsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditTypeWithSameId))
        .assertEqual('test');

      let eventsEditType: EditType = new EditType(0, 'test');
      let eventsResource = presenter.menuSelectSysAndCustom('events', looseObject, eventsEditType);
      let expectedEventsResource: Resource = $r('app.string.birthday_type_grebirthday');
      expect(JSON.stringify(eventsResource)).assertEqual(JSON.stringify(expectedEventsResource));
      let eventsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('events', looseObject, eventsEditTypeWithSameId)).assertEqual('test');
    })

    it('AccountantsPresenterTest_menuSelectSysAndCustom_numType_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let looseObject: LooseObject = {
        'item': {
          numType: null,
          emailType: null,
          aimType: null,
          houseType: null,
          associatedType: null,
          eventType: null
        }
      }
      let phoneEditType: EditType = new EditType(0, 'test');
      let phoneResource = presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditType);
      let expectedPhoneResource: Resource = $r('app.string.phone_type_mobile');
      expect(JSON.stringify(phoneResource)).assertEqual(JSON.stringify(expectedPhoneResource));
      let phoneEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('phone', looseObject, phoneEditTypeWithSameId)).assertEqual('test');

      let emailEditType: EditType = new EditType(0, 'test');
      let emailResource = presenter.menuSelectSysAndCustom('email', looseObject, emailEditType);
      let expectedEmailResource: Resource = $r('app.string.email_type_home');
      expect(JSON.stringify(emailResource)).assertEqual(JSON.stringify(expectedEmailResource));
      let emailEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('email', looseObject, emailEditTypeWithSameId)).assertEqual('test');

      let aimEditType: EditType = new EditType(0, 'test');
      let aimResource = presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditType);
      let expectedAimResource: Resource = $r('app.string.instant_type_aim');
      expect(JSON.stringify(aimResource)).assertEqual(JSON.stringify(expectedAimResource));
      let aimEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('AIM', looseObject, aimEditTypeWithSameId)).assertEqual('test');

      let houseEditType: EditType = new EditType(0, 'test');
      let houseResource = presenter.menuSelectSysAndCustom('house', looseObject, houseEditType);
      let expectedHouseResource: Resource = $r('app.string.house_type_dwelling');
      expect(JSON.stringify(houseResource)).assertEqual(JSON.stringify(expectedHouseResource));
      let houseEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('house', looseObject, houseEditTypeWithSameId)).assertEqual('test');

      let relationshipsEditType: EditType = new EditType(0, 'test');
      let relationshipsResource = presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditType);
      let expectedRelationshipsResource: Resource = $r('app.string.relationship_type_assistant');
      expect(JSON.stringify(relationshipsResource)).assertEqual(JSON.stringify(expectedRelationshipsResource));
      let relationshipsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('relationships', looseObject, relationshipsEditTypeWithSameId))
        .assertEqual('test');

      let eventsEditType: EditType = new EditType(0, 'test');
      let eventsResource = presenter.menuSelectSysAndCustom('events', looseObject, eventsEditType);
      let expectedEventsResource: Resource = $r('app.string.birthday_type_grebirthday');
      expect(JSON.stringify(eventsResource)).assertEqual(JSON.stringify(expectedEventsResource));
      let eventsEditTypeWithSameId: EditType = new EditType(1, 'test');
      expect(presenter.menuSelectSysAndCustom('events', looseObject, eventsEditTypeWithSameId)).assertEqual('test');
    })

    it('AccountantsPresenterTest_menuSelect', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'item': {
          numType: 1,
          emailType: 1,
          aimType: 1,
          houseType: 1,
          associatedType: 1,
          eventType: 1
        }
      };
      let result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.phone_type_mobile')));
      typename = 'email';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.email_type_home')));
      typename = 'AIM';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.instant_type_aim')));
      typename = 'house';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.house_type_dwelling')));
      typename = 'relationships';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.relationship_type_assistant')));
      typename = 'events';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.birthday_type_grebirthday')));
      typename = 'test';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify(''));
    })

    it('AccountantsPresenterTest_menuSelect_item_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'i': 1,
        'item': null
      };
      let result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.phone_type_mobile')));
      typename = 'email';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.email_type_home')));
      typename = 'AIM';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.instant_type_aim')));
      typename = 'house';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.house_type_dwelling')));
      typename = 'relationships';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.relationship_type_assistant')));
      typename = 'events';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.birthday_type_grebirthday')));
    })

    it('AccountantsPresenterTest_menuSelect_numType_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'i': 1,
        'item': {
          numType: null,
          emailType: null,
          aimType: null,
          houseType: null,
          associatedType: null,
          eventType: null
        }
      };
      let result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.phone_type_mobile')));
      typename = 'email';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.email_type_home')));
      typename = 'AIM';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.instant_type_aim')));
      typename = 'house';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.house_type_dwelling')));
      typename = 'relationships';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.relationship_type_assistant')));
      typename = 'events';
      result = JSON.stringify(presenter.menuSelect(typename, data));
      expect(result).assertEqual(JSON.stringify($r('app.string.birthday_type_grebirthday')));
    })

    it('AccountantsPresenterTest_getSelectType_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'i': 1,
        'item': {
          'numType': 10000,
          'emailType': 10000,
          'aimType': 10000,
          'houseType': 10000,
          'associatedType': 10000,
          'eventType': 10000,
          'selectTextCustom': 'test'
        }
      };
      let result: string = JSON.stringify(new EditType(10000, 'test'));
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'email';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'AIM';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'house';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'relationships';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'events';
      expect(JSON.stringify(presenter.getSelectType(typename, data)))
        .assertEqual(JSON.stringify(new EditType(10000, '')));
      typename = 'default';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(JSON.stringify(new EditType(1, '')));
    })

    it('AccountantsPresenterTest_getSelectType_TYPE_ID_CUSTOM_1', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'i': 1,
        'item': {
          'numType': 1,
          'emailType': 1,
          'aimType': 1,
          'houseType': 1,
          'associatedType': 1,
          'eventType': 1,
        }
      };
      let result: string = JSON.stringify(new EditType(1, ''));
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);

      typename = 'email';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);

      typename = 'AIM';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);

      typename = 'house';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);

      typename = 'relationships';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);

      typename = 'events';
      expect(JSON.stringify(presenter.getSelectType(typename, data)))
        .assertEqual(JSON.stringify(new EditType(1, '')));
    })

    it('AccountantsPresenterTest_getSelectType', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'i': 1,
        'item': {
          selectTextCustom: 'test'
        }
      };
      let result: string = JSON.stringify(new EditType(1, ''));
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'email';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'AIM';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'house';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'relationships';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'events';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'default';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
    })

    it('AccountantsPresenterTest_getSelectType_item_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'item': null
      };
      let result: string = JSON.stringify(new EditType(1, ''));
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'email';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'AIM';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'house';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'relationships';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'events';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'default';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
    })

    it('AccountantsPresenterTest_getSelectType_numType_null', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typename = 'phone';
      let data: LooseObject = {
        'item': {
          numType: null,
          emailType: null,
          aimType: null,
          houseType: null,
          associatedType: null,
          eventType: null
        }
      };
      let result: string = JSON.stringify(new EditType(1, ''));
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'email';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'AIM';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'house';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'relationships';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'events';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
      typename = 'default';
      expect(JSON.stringify(presenter.getSelectType(typename, data))).assertEqual(result);
    })

    it('AccountantsPresenterTest_getSelectTypeId', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let phoneLooseObject: LooseObject = {
        'item': {
          'num': 'phone'
        },
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getSelectType))('phone').afterReturn(new EditType(1, ''));
      expect(presenter.getSelectTypeId('phone', phoneLooseObject)).assertEqual(1);
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_getMenuList_phone', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('phone');
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.phone_type_mobile'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_email', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('email');
      expect(JSON.stringify(result[0])).assertEqual(JSON.stringify(new EditType(1, $r('app.string.email_type_home'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_aim', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('AIM');
      expect(JSON.stringify(result[0])).assertEqual(JSON.stringify(new EditType(1, $r('app.string.instant_type_aim'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_house', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('house');
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.house_type_dwelling'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_relationship', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('relationships');
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.relationship_type_assistant'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_events', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('events');
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.birthday_type_grebirthday'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getMenuList_default', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getMenuList('test');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify([]));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuListByNameAndIndex', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountType: PhoneAccountType = new PhoneAccountType();
      presenter.contactSelectInfoModel.phones = [new SelectInfoModel()];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.getSelectInfoModel))('phone')
        .afterReturn(new SelectInfoModel());
      when(mocker.mockFunc(presenter, presenter.getSysAndCustomMenuList))('phone')
        .afterReturn(accountType.mineKinds.get('phone'));
      expect(presenter.getSysAndCustomMenuListByNameAndIndex('phone', 1))
        .assertEqual(accountType.mineKinds.get('phone'));
      mocker.clear(presenter);
    });

    it('AccountantsPresenterTest_getSysAndCustomMenuList_phone', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.phone_type_mobile'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('phone', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_phone_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('phone', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.phone_type_mobile'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_email', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.email_type_home'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('email', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_email_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('email', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.email_type_home'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_aim', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.instant_type_aim'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('AIM', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_aim_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('AIM', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.instant_type_aim'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_house', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.house_type_dwelling'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('house', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_house_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('house', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.house_type_dwelling'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_relationships', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.relationship_type_assistant'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('relationships', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_relationships_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('relationships', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.relationship_type_assistant'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_events', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let editTypeCustom: EditType = new EditType(1, $r('app.string.birthday_type_grebirthday'));
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('events', editTypeCustom);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(editTypeCustom));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_events_editTypeCustom_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('events', undefined);
      expect(JSON.stringify(result[0]))
        .assertEqual(JSON.stringify(new EditType(1, $r('app.string.birthday_type_grebirthday'))));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_getSysAndCustomMenuList_default', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let accountTypeService: AccountTypeService = new AccountTypeService();
      let accountType: PhoneAccountType = new PhoneAccountType();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(accountTypeService, accountTypeService.getAccountType))('com.ohos.phone')
        .afterReturn(accountType);
      let result: EditType[] = presenter.getSysAndCustomMenuList('test', undefined);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify([]));
      mocker.clear(accountTypeService);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_phone_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('phone', 0, '10000', '');
      expect(JSON.stringify(presenter.contactInfoAfter.phones[0]))
        .assertEqual(JSON.stringify(new PhoneNumBean('', '', '10000', '', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_phones_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let phone1: PhoneNumBean = new PhoneNumBean('', '1', '1', '', '', false, 1);
      let phone1Result: PhoneNumBean = new PhoneNumBean('', '1', '4', '', '', false, 1);
      presenter.contactInfoAfter.phones = [phone1, new PhoneNumBean('', '2', '1', '', '', false, 2)];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('phone', 0, '4', '');
      expect(JSON.stringify(presenter.contactInfoAfter.phones[0])).assertEqual(JSON.stringify(phone1Result));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_email_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('email', 0, '10000', '');
      expect(JSON.stringify(presenter.contactInfoAfter.emails[0]))
        .assertEqual(JSON.stringify(new EmailBean('', '', '10000')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_emails_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let email1 = new EmailBean('', 'rongsheng.zhang@ohos.com', '');
      let email1Result1: EmailBean = new EmailBean('', 'rongsheng.zhang@ohos.com', '2');
      presenter.contactInfoAfter.emails = [email1, new EmailBean('', 'roxy.zhang@ohos.com', '')];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('email', 0, '2', '');
      expect(JSON.stringify(presenter.contactInfoAfter.emails[0])).assertEqual(JSON.stringify(email1Result1));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_aim_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('AIM', 0, '10000', '');
      expect(JSON.stringify(presenter.contactInfoAfter.aims[0]))
        .assertEqual(JSON.stringify(new AIMBean('', '', '10000', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_aims_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let aim1: AIMBean = new AIMBean('1', '', '', 'aim1');
      let aim1Result1: AIMBean = new AIMBean('1', '', '2', 'aim1');
      presenter.contactInfoAfter.aims = [aim1, new AIMBean('2', '', '', 'aim2')];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('AIM', 0, '2', '');
      expect(JSON.stringify(presenter.contactInfoAfter.aims[0])).assertEqual(JSON.stringify(aim1Result1));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_houses_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('house', 0, '10000', '');
      expect(JSON.stringify(presenter.contactInfoAfter.houses[0]))
        .assertEqual(JSON.stringify(new HouseBean('', '', '10000', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_houses_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let house1: HouseBean = new HouseBean('1', '', '', 'house1');
      let house1Result1: HouseBean = new HouseBean('1', '', '2', 'house1');
      presenter.contactInfoAfter.houses = [house1, new HouseBean('2', '', '', 'house2')];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('house', 0, '2', '');
      expect(JSON.stringify(presenter.contactInfoAfter.houses[0])).assertEqual(JSON.stringify(house1Result1));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_relationships_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('relationships', 0, '10000', '');
      expect(JSON.stringify(presenter.contactInfoAfter.relationships[0]))
        .assertEqual(JSON.stringify(new AssociatedPersonBean('', '', '', '10000')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_relationships_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let relation1: AssociatedPersonBean = new AssociatedPersonBean('', '2', 'person1', '');
      let relation1Result1: AssociatedPersonBean = new AssociatedPersonBean('', '2', 'person1', '2');
      presenter.contactInfoAfter.relationships = [relation1, new AssociatedPersonBean('', '3', 'person2', '')];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('relationships', 0, '2', '');
      expect(JSON.stringify(presenter.contactInfoAfter.relationships[0])).assertEqual(JSON.stringify(relation1Result1));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_events_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('events', 0, '1', '');
      expect(JSON.stringify(presenter.contactInfoAfter.events[0]))
        .assertEqual(JSON.stringify(new EventBean('', '', '1', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_events_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let event1: EventBean = new EventBean('1', '', '', 'event1');
      let event1Result1: EventBean = new EventBean('1', '', '5', 'event1');
      presenter.contactInfoAfter.events = [event1, new EventBean('2', '', '', 'event2')];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('events', 0, '5', '');
      expect(JSON.stringify(presenter.contactInfoAfter.events[0]))
        .assertEqual(JSON.stringify(event1Result1));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChangeByCustomDialogClose_default', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChangeByCustomDialogClose('test', 0, '5', '');
      expect(JSON.stringify(presenter.contactInfoAfter))
        .assertEqual(JSON.stringify(new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null)));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_phone_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'phone';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(data.numType).assertEqual('10000');
      expect(JSON.stringify(presenter.contactInfoAfter.phones[data.i-1]))
        .assertEqual(JSON.stringify(new PhoneNumBean('test', '', '10000', '', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_phone_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'phone';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '2', '1', '', '', false, 2)];
      presenter.menuChange(typeName, data, item);
      expect(data.numType).assertEqual('10');
      expect(JSON.stringify(presenter.contactInfoAfter.phones[0]))
        .assertEqual(JSON.stringify(new PhoneNumBean('', '2', '10', '', '', false, 2)));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_email_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'email';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(data.emailType).assertEqual('10000');
      expect(JSON.stringify(presenter.contactInfoAfter.emails[data.i-1]))
        .assertEqual(JSON.stringify(new EmailBean('test', '', '10000')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_email_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'email';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.emails = [new EmailBean('', 'rongsheng.zhang@ohos.com', '')];
      presenter.menuChange(typeName, data, item);
      expect(data.emailType).assertEqual('10');
      expect(JSON.stringify(presenter.contactInfoAfter.emails[0]))
        .assertEqual(JSON.stringify(new EmailBean('', 'rongsheng.zhang@ohos.com', '10')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_aim_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'AIM';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.aims[data.i-1]))
        .assertEqual(JSON.stringify(new AIMBean('', 'test', '10000', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_aim_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'AIM';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.aims = [new AIMBean('1', '', '', 'aim1')];
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.aims[0]))
        .assertEqual(JSON.stringify(new AIMBean('1', '', '10', 'aim1')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_house_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'house';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.houses[data.i-1]))
        .assertEqual(JSON.stringify(new HouseBean('', 'test', '10000', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_house_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'house';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.houses = [new HouseBean('1', 'text', '', 'house1')];
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.houses[0]))
        .assertEqual(JSON.stringify(new HouseBean('1', '', '10', 'house1')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_relationship_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'relationships';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.relationships[data.i-1]))
        .assertEqual(JSON.stringify(new AssociatedPersonBean('test', '', '', '10000')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_relationship_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'relationships';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '2', 'relationship1', '')];
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.relationships[0]))
        .assertEqual(JSON.stringify(new AssociatedPersonBean('', '2', 'relationship1', '10')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_event_emptyObject_TYPE_ID_CUSTOM_10000', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'events';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10000, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.events[data.i-1]))
        .assertEqual(JSON.stringify(new EventBean('', '', '10000', '')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_event_notEmptyObject', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'events';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.contactInfoAfter.events = [new EventBean('1', '', '', 'event1')];
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter.events[0]))
        .assertEqual(JSON.stringify(new EventBean('1', '', '10', 'event1')));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_menuChange_default', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let typeName: string = 'test';
      let data: LooseObject = {
        'i': 1, 'numType': 2
      };
      let item: EditType = new EditType(10, 'test');
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.menuChange(typeName, data, item);
      expect(JSON.stringify(presenter.contactInfoAfter))
        .assertEqual(JSON.stringify(new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null)));
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_saveClickEnable', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.addState = true;
      presenter.clickEnable = true;
      presenter.photoChanged = false;
      expect(presenter.saveClickEnable()).assertTrue();
      presenter.addState = false;
      presenter.clickEnable = false;
      presenter.photoChanged = false;
      expect(presenter.saveClickEnable()).assertFalse();
    })

    it('AccountantsPresenterTest_saveClickEnable_02', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.addState = true;
      presenter.clickEnable = true;
      presenter.isMyCard = true;
      presenter.contactInfoAfter =
        new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '13801001111', '1', '', '')];

      expect(presenter.saveClickEnable()).assertTrue();
    })

    it('AccountantsPresenterTest_saveContact_saveClickEnable_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(false);

      presenter.saveContact({} as UIExtensionContentSession);

      expect(presenter.clickEnable).assertTrue();

      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_saveContact_contactInfoAfter_phones_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = false;
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));

      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '', '', '', '')];

      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);

      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });

      let contactDot = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot))(presenter.saveContactParams)
        .afterAction(() => {
          contactDot = true;
        })
      when(mocker.mockFunc(presenter.pathInfos, presenter.pathInfos.getParamByIndex))(0)
        .afterReturn('');
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('addContact').afterAction(() => {
        presenter.clickEnable = true;
      })
      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(presenter.clickEnable).assertTrue();
      expect(isEmpty).assertFalse();
      expect(contactDot).assertTrue();
      mocker.clear(presenter.pathInfos);
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(DotUtil.getInstance());
    })

    it('AccountantsPresenterTest_saveContact_updateShow_false', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = false;
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);
      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      let contactDot = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().contactDot))(presenter.saveContactParams)
        .afterAction(() => {
          contactDot = true;
        });
      when(mocker.mockFunc(presenter.pathInfos, presenter.pathInfos.getParamByIndex))(0)
        .afterReturn('');
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('addContact').afterAction(() => {
        presenter.clickEnable = true;
      })
      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);
      expect(presenter.clickEnable).assertTrue();
      expect(isEmpty).assertFalse();
      expect(contactDot).assertTrue();
      mocker.clear(presenter.pathInfos);
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(DotUtil.getInstance());
    })

    //this.nullContactInfo == this.getExistenceInfoString(this.contactInfoAfter)
    it('AccountantsPresenterTest_saveContact_updateShow_true_if_result_1', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactId = '1';
      presenter.updateShow = true;
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);

      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn(presenter.nullContactInfo);

      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(isEmpty).assertFalse();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(ContactRepository.getInstance())
    })

    it('AccountantsPresenterTest_saveContact_updateShow_true_if_result_0', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactId = '1';
      presenter.updateShow = true;
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);

      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);

      ContactRepository.getInstance().init(uiContext);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(0))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn(presenter.nullContactInfo);

      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(isEmpty).assertFalse();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(ContactRepository.getInstance())
    })

    it('AccountantsPresenterTest_saveContact_updateShow_true_if_result_undefined', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactId = '1';
      presenter.updateShow = true;
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);

      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            reject({
              code: 401,
              message: 'error'
            } as BusinessError)
          })
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn(presenter.nullContactInfo);

      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(isEmpty).assertFalse();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(ContactRepository.getInstance());
    })

    /*
    * this.nullContactInfo ！= this.getExistenceInfoString(this.contactInfoAfter)
    * this.photoPixelMap !== null
     */
    it('AccountantsPresenterTest_saveContact_updateShow_true_nullContactInfo_empty_pixelMap_notNull', 0, async () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.photoPixelMap = {
        isEditable: true
      } as PixelMap;
      presenter.photoChanged = true;
      presenter.updateShow = true;
      presenter.nullContactInfo = '';
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);
      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn('info');
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let result = false;
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('updateContact').afterAction(() => {
        result = true;
      });
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        }
      } as common.UIAbilityContext;
      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);
      when(mocker.mockFunc(uiContext, uiContext.getApplicationContext))().afterReturn(appContext);
      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);
      expect(result).assertTrue();
      expect(isEmpty).assertFalse();
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(uiContext);
    })
    /*
     * this.nullContactInfo ！= this.getExistenceInfoString(this.contactInfoAfter)
     * this.photoPixelMap == null
      */
    it('AccountantsPresenterTest_saveContact_updateShow_true_nullContactInfo_empty_pixelMap_null', 0, async () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = true;
      presenter.photoChanged = true;
      presenter.nullContactInfo = '';
      presenter.pathInfos = new NavPathStack();
      presenter.pathInfos.pushPath(new NavPathInfo('path1', {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'xx',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact));
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);
      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn('info');
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      let result = false;
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('updateContact').afterAction(() => {
        result = true;
      });
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        }
      } as common.UIAbilityContext;
      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);
      when(mocker.mockFunc(uiContext, uiContext.getApplicationContext))().afterReturn(appContext);

      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(result).assertTrue();
      expect(isEmpty).assertFalse();
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(uiContext);
    })

    it('AccountantsPresenterTest_saveContact_updateShow_true_nullContactInfo_empty_pixelMap_null_pathInfos_undefined', 0, async () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.updateShow = true;
      presenter.photoChanged = true;
      presenter.nullContactInfo = '';
      presenter.pathInfos = undefined;
      let uiExtentionSession: LooseObject = {
        sendData: () => {
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.saveClickEnable))().afterReturn(true);
      let isEmpty = true;
      when(mocker.mockFunc(presenter, presenter.checkValueEmpty))().afterAction(() => {
        isEmpty = false;
      });
      when(mocker.mockFunc(presenter, presenter.getExistenceInfoString))(presenter.contactInfoAfter)
        .afterReturn('info');
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      let result = false;
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('updateContact').afterAction(() => {
        result = true;
      });
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        }
      } as common.UIAbilityContext;
      let appContext: common.ApplicationContext = {
        filesDir: ''
      } as common.ApplicationContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);
      when(mocker.mockFunc(uiContext, uiContext.getApplicationContext))().afterReturn(appContext);

      presenter.saveContact(uiExtentionSession as UIExtensionContentSession);

      expect(result).assertTrue();
      expect(isEmpty).assertFalse();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(uiContext);
    })

    it('AccountantsPresenterTest_textChange', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let isRefresh: boolean = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter, presenter.refresh))().afterAction(() => {
        isRefresh = true;
      });
      presenter.textChange();
      expect(isRefresh).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_hideKeyboard', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.hideKeyboard();
      expect(presenter.sourceHasParam).assertFalse();
    })

    it('AccountantsPresenterTest_updateItemsShowState', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactInfo: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'warsaw', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', 'aim1')],
        [new HouseBean('1', '', '', 'house')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', 'data', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, 'name', 'xxxx', 'xxxx', null
      );
      presenter.updateItemsShowState(contactInfo);
      expect(presenter.itemsShowState['phoneticName']).assertTrue();
      expect(presenter.itemsShowState['aims']).assertTrue();
      expect(presenter.itemsShowState['houses']).assertTrue();
      expect(presenter.itemsShowState['nickname']).assertTrue();
      expect(presenter.itemsShowState['websites']).assertTrue();
      expect(presenter.itemsShowState['events']).assertTrue();
      expect(presenter.itemsShowState['relationships']).assertTrue();
    })

    it('AccountantsPresenterTest_updateItemsShowState_', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactInfo: ContactInfo = new ContactInfo('1', 'roxy', 'roxy', [], [], 'position1', 'company1', 'remarks1', [], [], [], [], [], [], 1);

      presenter.updateItemsShowState(contactInfo);

      expect(presenter.showMore).assertFalse();
    })

    it('AccountantsPresenterTest_checkValueEmpty_empty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '', '1', '', '', false, 2)];
      presenter.contactInfoAfter.emails = [new EmailBean('', '', '')];
      presenter.contactInfoAfter.aims = [new AIMBean('2', '', '', '')];
      presenter.contactInfoAfter.houses = [new HouseBean('2', '', '', '')];
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '3', '', '')];
      presenter.contactInfoAfter.events = [new EventBean('2', '', '', '')];
      presenter.contactInfoAfter.websites = [''];
      presenter.checkValueEmpty();
      expect(presenter.contactInfoAfter.display_name).assertEqual('');
      expect(presenter.contactInfoAfter.phoneticName).assertEqual('');
      expect(presenter.contactInfoAfter.company).assertEqual('');
      expect(presenter.contactInfoAfter.position).assertEqual('');
      expect(presenter.contactInfoAfter.phones[0].num).assertEqual('');
      expect(presenter.contactInfoAfter.emails[0].address).assertEqual('');
      expect(presenter.contactInfoAfter.aims[0].aimName).assertEqual('');
      expect(presenter.contactInfoAfter.houses[0].houseName).assertEqual('');
      expect(presenter.contactInfoAfter.remarks).assertEqual('');
      expect(presenter.contactInfoAfter.nickname).assertEqual('');
      expect(presenter.contactInfoAfter.websites[0]).assertEqual('');
      expect(presenter.contactInfoAfter.relationships[0].name).assertEqual('');
    })

    it('AccountantsPresenterTest_checkValueEmpty_notEmpty', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.display_name = 'roxy';
      presenter.contactInfoAfter.phoneticName = 'roxyxx';
      presenter.contactInfoAfter.company = 'company1';
      presenter.contactInfoAfter.position = 'position1';
      presenter.contactInfoAfter.remarks = 'remarks';
      presenter.contactInfoAfter.nickname = 'nickname';
      presenter.contactInfoAfter.phones = [new PhoneNumBean('', '570977632', '1', '', '', false, 2)];
      presenter.contactInfoAfter.emails = [new EmailBean('', 'rongsheng.zhang@ohos.com', '')];
      presenter.contactInfoAfter.aims = [new AIMBean('2', '', '', 'aim')];
      presenter.contactInfoAfter.houses = [new HouseBean('2', '', '', 'house')];
      presenter.contactInfoAfter.relationships = [new AssociatedPersonBean('', '3', 'name', '')];
      presenter.contactInfoAfter.events = [new EventBean('2', '1', '', '')];
      presenter.contactInfoAfter.websites = ['www.xxx.com'];
      presenter.checkValueEmpty();
      expect(presenter.saveContactParams.ISNAME).assertEqual(1);
      expect(presenter.saveContactParams.ISUNIT).assertEqual(1);
      expect(presenter.saveContactParams.ISPHONE).assertEqual(1);
      expect(presenter.saveContactParams.ISEMAIL).assertEqual(1);
      expect(presenter.saveContactParams.ISMESSAGE).assertEqual(1);
      expect(presenter.saveContactParams.ISADDRESS).assertEqual(1);
      expect(presenter.saveContactParams.ISREMARKS).assertEqual(1);
      expect(presenter.saveContactParams.ISNICKNAME).assertEqual(1);
      expect(presenter.saveContactParams.ISWEBSITE).assertEqual(1);
      expect(presenter.saveContactParams.ISBIRTHDAYDATE).assertEqual(1);
      expect(presenter.saveContactParams.ISASSOCIATED).assertEqual(1);
    })
    it('AccountantsPresenterTest_formatDisplayname', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.contactInfoAfter.display_name = '   ls'
      presenter.formatDisplayname();
      expect(presenter.contactInfoAfter.display_name).assertEqual('ls');
    })

    it('AccountantsPresenterTest_onRingToneChange', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      presenter.originalContactInfoBefore.personalRingtone = 'aaa';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(presenter, presenter.saveClickEnable);
      presenter.onRingToneChange(true, true);
      mocker.verify('saveClickEnable', []).never();

      presenter.contactInfoAfter.personalRingtone = 'aaa';
      presenter.onRingToneChange(true, false);
      mocker.verify('saveClickEnable', []).once();

      presenter.contactInfoAfter.personalRingtone = 'bbb';
      presenter.onRingToneChange(true, false);
      expect(presenter.ringToneChanged).assertTrue();
      mocker.clear(presenter);
    })

    it('AccountantsPresenterTest_parseParamsFromSaveExistContact', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let phoneNumber: contact.PhoneNumber = new contact.PhoneNumber();
      phoneNumber.phoneNumber = '13301001111'
      let email: contact.Email = new contact.Email();
      email.email = 'email';
      let imAddress: contact.ImAddress = new contact.ImAddress();
      imAddress.imAddress = '111';
      let postalAddress: contact.PostalAddress = new contact.PostalAddress();
      postalAddress.postalAddress = '222';
      let eventBean: EventBean = new EventBean('1', '', '1', 'event1');
      presenter.contactInfoBefore.events.push(eventBean);
      let event: contact.Event = new contact.Event();
      event.eventDate = '2025-04-03';
      let relation: contact.Relation = new contact.Relation();
      relation.relationName = 'relationName'
      let contactFromPicker: contact.Contact = {
        id: 0,
        key: '',
        emails: [email],
        events: [event],
        groups: [],
        imAddresses: [imAddress],
        phoneNumbers: [phoneNumber],
        portrait: {
          uri: ''
        },
        postalAddresses: [postalAddress],
        relations: [],
        websites: [],
        name: {
          fullName: 'name'
        },
        note: {
          noteContent: '备注'
        },
        organization: {
          name: 'organizationName',
          title: 'title'
        }
      };
      presenter.newContactData = contactFromPicker;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(presenter.contactInfoBefore, presenter.contactInfoBefore.setDisplayName);
      when(mocker.mockFunc(EventBean, EventBean.getBeanByPickerData))(event).afterReturn(eventBean);
      presenter.parseParamsFromSaveExistContact(contactFromPicker);
      mocker.verify('setDisplayName', [contactFromPicker.name?.fullName]).once();
      mocker.clear(presenter.contactInfoBefore);
      mocker.clear(EventBean);
      presenter.contactInfoBefore.events = [];
    })

    it('AccountantsPresenterTest_parseParamsFromSaveExistContact01', 0, () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let eventBean: EventBean = new EventBean('1', '', '2', 'event1');
      presenter.contactInfoBefore.events.push(eventBean);
      let event: contact.Event = new contact.Event();
      event.eventDate = '2025-04-03';
      let relation: contact.Relation = new contact.Relation();
      relation.relationName = 'relationName'
      let contactFromPicker: contact.Contact = {
        id: 0,
        key: '',
        emails: [],
        events: [event],
        groups: [],
        imAddresses: [],
        phoneNumbers: [],
        portrait: {
          uri: ''
        },
        postalAddresses: [],
        relations: [],
        websites: [],
        name: {
          fullName: 'name'
        },
        note: {
          noteContent: '备注'
        },
        organization: {
          name: 'organizationName',
          title: 'title'
        }
      };
      presenter.newContactData = contactFromPicker;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(EventBean, EventBean.getBeanByPickerData))(event).afterReturn(eventBean);
      presenter.parseParamsFromSaveExistContact(contactFromPicker);
      expect(presenter.contactInfoBefore.events.length).assertEqual(2);
      mocker.clear(presenter.contactInfoBefore);
      mocker.clear(EventBean);
    })

    it('AccountantsPresenterTest_formatPhoneNumber', 0, async () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      expect(await presenter.formatPhoneNumber('')).assertEqual('');
      let val: string = '13801001234'
      expect(await presenter.formatPhoneNumber(val)).assertEqual('138 0100 1234');
    })

    it('AccountantsPresenterTest_getContactTemp', 0, () => {
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = 0;
      data.display_name = 'roxy';
      data.position = 'position1';
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactInfo: ContactInfo = presenter.getContactTemp(data);
      expect(contactInfo.display_name).assertEqual('roxy');
      expect(presenter.isShowPosition).assertTrue();
    })

    it('AccountantsPresenterTest_getContactTemp_undefined', 0, () => {
      let data: RichContactInfo = new RichContactInfo('1');
      data.nameUpdate = 1;
      data.position = 'position1';
      data.setPhoneticName('name');
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactTemp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      contactTemp.setPhoneticName('name');
      contactTemp.setContactID('1');
      contactTemp.setPosition('position1');
      let contactInfo: ContactInfo = presenter.getContactTemp(data);
      expect(JSON.stringify(contactInfo)).assertEqual(JSON.stringify(contactTemp));
    })

    it('AccountantsPresenterTest_deleteCardContact', 0, async () => {
      let presenter: AccountantsPresenter = new AccountantsPresenter();
      let contactId: string = '1';
      let contactInfoAfter: ContactInfo =
        new ContactInfo(contactId, '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
      contactInfoAfter.contactID = contactId;
      let speedDialEditCommon: SpeedDialEditCommon = new SpeedDialEditCommon();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(speedDialEditCommon, speedDialEditCommon.updateContactFormId);
      presenter.deleteCardContact(contactInfoAfter);
      mocker.verify('updateContactFormId', [contactInfoAfter.contactID, '']).never();
      mocker.clear(speedDialEditCommon);
    })
  })
}