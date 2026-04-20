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
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactVo, ContactVoName } from '../../../../../../main/ets/model/bean/ContactVo';
import { PhoneNumberInterface, SingleSelectContact } from '../../../../../../main/ets/model/type';
import AddFavoriteListPresenter, {
  EventInterface,
  PageType
} from '../../../../../../main/ets/presenter/favorite/AddFavoriteListPresenter';
import FavoriteListPresenter from '../../../../../../main/ets/presenter/favorite/FavoriteListPresenter';
import common from '@ohos.app.ability.common';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import { DTGlobalContext } from '../../../../testability/TestAbility'
import { ContactRepository, RawContacts } from '../../../../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { sharedPreferencesUtils } from '../../../../../../../../feature/call/oh_modules/common';
import { preferences } from '@kit.ArkData';
import { ResourceUtil } from '../../../../../../../../entry/src/main/ets/util/ResourceUtil';

export default function AddFavoriteListPresenterTest() {
  describe('AddFavoriteListPresenterTest', () => {
    let presenter: AddFavoriteListPresenter;
    let mocker: MockKit;

    beforeEach(() => {
      AppStorage.clear();
      mocker = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      presenter = new AddFavoriteListPresenter();
    })

    afterEach(() => {
      mocker.clear(presenter.contactsSource);
      mocker.clear(presenter.alphabetIndexPresenter);
      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ResourceUtil);
    })

    it('AddFavoriteListPresenter_getInstance', 0, () => {
      expect(typeof AddFavoriteListPresenter.getInstance()).assertEqual(typeof presenter);
    })

    it('AddFavoriteListPresenter_aboutToAppear_pageType_equal_PageTypeGroup', 0, () => {
      presenter.pageType = PageType.Group;
      let result1 = false;
      when(mocker.mockFunc(presenter, presenter.initContactsListByGroup))()
        .afterAction(() => {
          result1 = true;
        });
      let result2 = false;
      when(mocker.mockFunc(presenter, presenter.clearSelection))()
        .afterAction(() => {
          result2 = true;
        });
      presenter.aboutToAppear();
      expect(result1).assertTrue();
      expect(result2).assertTrue();
    })

    it('AddFavoriteListPresenter_aboutToAppear_pageType_equal_PageTypeFaverite', 0, () => {
      presenter.pageType = PageType.Favorite;

      let result1 = false;
      when(mocker.mockFunc(presenter, presenter.initContactsListByFavorite))()
        .afterAction(() => {
          result1 = true;
        });
      let result2 = false;
      when(mocker.mockFunc(presenter, presenter.clearSelection))()
        .afterAction(() => {
          result2 = true;
        });
      presenter.aboutToAppear();
      expect(result1).assertTrue();
      expect(result2).assertTrue();
    })

    it('AddFavoriteListPresenter_clearSelection', 0, () => {

      mocker.mockFunc(presenter, presenter.refreshPageMessage);
      presenter.clearSelection();
      expect(presenter.selectCount).assertEqual(0);
    })

    it('AddFavoriteListPresenter_aboutToDisappear', 0, () => {
      presenter.aboutToDisappear();
      expect(presenter.selectCount).assertEqual(0);
    })

    it('AddFavoriteListPresenter_onPageShow', 0, () => {
      presenter.onPageShow();
      expect(presenter.selectCount).assertEqual(0);
    })

    it('AddFavoriteListPresenter_onPageHide', 0, () => {
      presenter.onPageHide();
      expect(presenter.selectCount).assertEqual(0);
    })

    it('AddFavoriteListPresenter_backCancel_if', 0, () => {
      presenter.pageType = 1;
      presenter.pathInfos = new NavPathStack();
      let contact: SingleSelectContact = {
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
      } as SingleSelectContact;
      presenter.pathInfos.pushPathByName('path1', contact);
      presenter.backCancel();
      expect(JSON.stringify(presenter.pathInfos.getParamByName('path1'))).assertEqual('[]');
    })

    it('AddFavoriteListPresenter_backCancel_if_pathInfos_null', 0, () => {
      presenter.pageType = 1;
      presenter.backCancel();
      expect(presenter.pathInfos).assertUndefined();
    })

    it('AddFavoriteListPresenter_backCancel_elseif', 0, () => {
      presenter.pathInfos = new NavPathStack();
      let contact: SingleSelectContact = {
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
      } as SingleSelectContact;
      presenter.pathInfos.pushPathByName('path1', contact);
      AppStorage.setOrCreate('breakpoint', 'sm');
      presenter.backCancel();
      expect(JSON.stringify(presenter.pathInfos.getParamByName('path1'))).assertEqual('[]');
    })

    it('AddFavoriteListPresenter_backCancel_elseif__pathInfos_null', 0, () => {
      AppStorage.setOrCreate('breakpoint', 'sm');
      presenter.backCancel();
      expect(presenter.pathInfos).assertUndefined();
    })

    it('AddFavoriteListPresenter_backCancel_else', 0, () => {
      let result = false;
      let instance: FavoriteListPresenter = FavoriteListPresenter.getInstance();
      when(mocker.mockFunc(instance, instance.toDefaultPage))()
        .afterAction(() => {
          result = true;
        });
      AppStorage.setOrCreate('breakpoint', 'xx');
      presenter.backCancel();
      expect(result).assertTrue();
      mocker.clear(instance);
    })

    it('AddFavoriteListPresenter_clickSelectAll_selectCount_0', 0, () => {
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      presenter.selectCount = 0;
      presenter.contactsTotal = 0;

      let result1 = false;
      when(mocker.mockFunc(presenter, presenter.refreshPageMessage))()
        .afterAction(() => {
          result1 = true;
        })
      presenter.clickSelectAll();
      expect(result1).assertTrue();
    })

    it('AddFavoriteListPresenter_clickSelectAll_selectCount_1', 0, () => {
      presenter.selectCount = 1;
      presenter.contactsTotal = 1;
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);

      let result1 = false;
      when(mocker.mockFunc(presenter, presenter.refreshPageMessage))()
        .afterAction(() => {
          result1 = true;
        })
      presenter.clickSelectAll();
      expect(result1).assertTrue();
    })

    it('AddFavoriteListPresenter_refreshMessagePage_selectCount_0', 0, () => {
      presenter.selectCount = 0;

      presenter.refreshPageMessage();
      expect(presenter.selectCount).assertEqual(0);
    })

    it('AddFavoriteListPresenter_refreshMessagePage_selectCount_1', 0, () => {
      presenter.selectCount = 1;
      presenter.checkedStatus.add('1')

      presenter.refreshPageMessage();
      expect(presenter.selectCount).assertEqual(1);
    })

    it('AddFavoriteListPresenter_resetInitialIndex', 0, () => {
      presenter.resetInitialIndex(1);
      expect(presenter.initialIndex).assertEqual(1);
    })

    it('AddFavoriteListPresenter_addGroupContacts_pathInfos_notNull', 0, () => {
      presenter.pathInfos = new NavPathStack();
      let voName: ContactVoName = new ContactVoName();
      voName.fullName = 'roxy';
      voName.namePrefix = 'r';
      voName.nameSuffix = 'y';
      voName.searchTextStart = 'r';
      voName.searchTextMiddle = 'ox';
      voName.searchTextEnd = 'y';
      let contactVo: ContactVo = new ContactVo('1', 'r', '', 'data', 'company', 'position', $r('app.color.detail_main_background'), true, '/', '570977632', '0', voName, 'roxy',
        '570977632', '1', '1');
      contactVo.phoneNumbers = [{
        dataId: 1,
        phoneNumber: '570977632',
        labelId: '1',
        numType: '',
        labelName: 'label1',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        primary: false,
      } as PhoneNumberInterface];
      presenter.contactsList = [contactVo];
      presenter.checkedStatus.add(contactVo.contactId);
      presenter.addGroupContacts();
      expect(JSON.stringify(AppStorage.get('addGroupContactData'))).assertEqual(JSON.stringify(['1']));
    })

    it('AddFavoriteListPresenter_addGroupContacts_pathInfos_null', 0, () => {
      let voName: ContactVoName = new ContactVoName();
      voName.fullName = 'roxy';
      voName.namePrefix = 'r';
      voName.nameSuffix = 'y';
      voName.searchTextStart = 'r';
      voName.searchTextMiddle = 'ox';
      voName.searchTextEnd = 'y';
      let contactVo: ContactVo = new ContactVo('1', 'r', '', 'data', 'company', 'position', $r('app.color.detail_main_background'), true, '/', '570977632', '0', voName, 'roxy',
        '570977632', '1', '1');
      contactVo.phoneNumbers = [{
        dataId: 1,
        phoneNumber: '570977632',
        labelId: '1',
        numType: '',
        labelName: 'label1',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        primary: false,
      } as PhoneNumberInterface];
      presenter.contactsList = [contactVo];
      presenter.checkedStatus.add(contactVo.contactId);
      presenter.addGroupContacts();
      expect(JSON.stringify(AppStorage.get('addGroupContactData'))).assertEqual(JSON.stringify(['1']));
    })

    it('AddFavoriteListPresenter_addFavoriteContacts_breakpoint_sm', 0, () => {
      let voName: ContactVoName = new ContactVoName();
      voName.fullName = 'roxy';
      voName.namePrefix = 'r';
      voName.nameSuffix = 'y';
      voName.searchTextStart = 'r';
      voName.searchTextMiddle = 'ox';
      voName.searchTextEnd = 'y';
      let contactVo: ContactVo = new ContactVo('1', 'r', '', 'data', 'company', 'position', $r('app.color.detail_main_background'), true, '/', '570977632', '0', voName, 'roxy',
        '570977632', '1', '1');
      contactVo.phoneNumbers = [{
        dataId: 1,
        phoneNumber: '570977632',
        labelId: '1',
        numType: '',
        labelName: 'label1',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        primary: false,
      } as PhoneNumberInterface];
      presenter.contactsList = [contactVo];
      presenter.pathInfos = new NavPathStack();
      let contact: SingleSelectContact = {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'roxy',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact;
      presenter.pathInfos.pushPath(new NavPathInfo('path1', contact));
      expect(JSON.stringify(presenter.pathInfos.getParamByIndex(0))).assertEqual(JSON.stringify(contact));
      AppStorage.SetOrCreate('breakpoint', 'sm');
      presenter.addFavoriteContacts();
      expect(JSON.stringify(presenter.pathInfos.getParamByIndex(0))).assertEqual(undefined);
    })

    it('AddFavoriteListPresenter_addFavoriteContacts_breakpoint_sm_pathInfo_notNull', 0, () => {
      presenter.pathInfos = new NavPathStack();
      let voName: ContactVoName = new ContactVoName();
      voName.fullName = 'roxy';
      voName.namePrefix = 'r';
      voName.nameSuffix = 'y';
      voName.searchTextStart = 'r';
      voName.searchTextMiddle = 'ox';
      voName.searchTextEnd = 'y';
      let contactVo: ContactVo = new ContactVo('1', 'r', '', 'data', 'company', 'position', $r('app.color.detail_main_background'), true, '/', '570977632', '0', voName, 'roxy',
        '570977632', '1', '1');
      contactVo.phoneNumbers = [{
        dataId: 1,
        phoneNumber: '570977632',
        labelId: '1',
        numType: '',
        labelName: 'label1',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        primary: false,
      } as PhoneNumberInterface];
      presenter.contactsList = [contactVo];
      presenter.pathInfos = new NavPathStack();
      let contact: SingleSelectContact = {
        editContact: 0,
        contactId: 1,
        callId: '1',
        phones: [],
        phoneNumberShow: '',
        sourceHasParam: false,
        updataShow: false,
        disPlayName: 'roxy',
        phoneNumbers: [],
        relationships: [],
      } as SingleSelectContact;
      presenter.pathInfos.pushPath(new NavPathInfo('path1', contact));
      expect(JSON.stringify(presenter.pathInfos.getParamByIndex(0))).assertEqual(JSON.stringify(contact));
      AppStorage.SetOrCreate('breakpoint', 'sm');
      presenter.addFavoriteContacts();
      expect(JSON.stringify(presenter.pathInfos.getParamByIndex(0))).assertEqual(undefined);
    })

    it('AddFavoriteListPresenter_addFavoriteContacts_breakpoint_xx', 0, () => {
      let voName: ContactVoName = new ContactVoName();
      voName.fullName = 'roxy';
      voName.namePrefix = 'r';
      voName.nameSuffix = 'y';
      voName.searchTextStart = 'r';
      voName.searchTextMiddle = 'ox';
      voName.searchTextEnd = 'y';
      let contactVo: ContactVo = new ContactVo('1', 'r', '', 'data', 'company', 'position', $r('app.color.detail_main_background'), true, '/', '570977632', '0', voName, 'roxy',
        '570977632', '1', '1');
      contactVo.phoneNumbers = [{
        dataId: 1,
        phoneNumber: '570977632',
        labelId: '1',
        numType: '',
        labelName: 'label1',
        checked: true,
        startPhone: '',
        middlePhone: '',
        endPhone: '',
        primary: false,
      } as PhoneNumberInterface];
      presenter.contactsList = [contactVo];

      let result = false;
      let instance: FavoriteListPresenter = FavoriteListPresenter.getInstance();
      when(mocker.mockFunc(instance, instance.emitFavoriteDefaultSelectedContact))()
        .afterAction(() => {
          result = true;
        });
      AppStorage.SetOrCreate('breakpoint', 'xx');
      presenter.addFavoriteContacts();
      expect(result).assertTrue();
      mocker.clear(instance);
    })


    it('AddFavoriteListPresenter_initContactsListByFavorite', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn(context);

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let result = false;
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('getAllContactWithPhoneNumbers')
        .afterAction(() => {
          result = true;
        });

      presenter.initContactsListByFavorite();

      expect(result).assertTrue();
      mocker.clear(workWrapper);
    })

    it('AddFavoriteListPresenter_initContactsListByFavorite_callback', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
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
          } as dataShare.DataShareHelper))
        });

      mocker.mockFunc(presenter.contactsSource, presenter.contactsSource.refresh);
      mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initContactList);

      let initAlphabetIndex: Function = mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initAlphabetIndex);
      when(initAlphabetIndex)(ArgumentMatchers.any).afterAction(() => {
        mocker.verify('getPhoneLabelNameById', ['xxx', 'xxx']).once();
        expect(presenter.contactsTotal).assertEqual(1);
      });

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new Promise<preferences.ValueType>(resolve => resolve(1)));

      presenter.initContactsListByFavorite();

      expect(result).assertTrue();
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(presenter.alphabetIndexPresenter);
    })

    it('AddFavoriteListPresenter_initContactsListByFavorite_callback_contactList_empty', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: Array<string>
            ): Promise<DataShareResultSet> => {
              return new Promise<DataShareResultSet>(resolve => resolve({
                rowCount: 0,
                close: () => {
                },
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 0,
                getLong: (columnIndex: number): number => 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new Promise<preferences.ValueType>(resolve => resolve(1)));

      mocker.mockFunc(presenter.contactsSource, presenter.contactsSource.refresh);
      mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initContactList);
      let initAlphabetIndex: Function = mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initAlphabetIndex);
      when(initAlphabetIndex)(ArgumentMatchers.any).afterAction(() => {
        expect(presenter.contactsTotal).assertEqual(0);
        mocker.verify('refresh', [[]]).once();
        mocker.verify('initContactList', [[]]).once();
      });

      presenter.initContactsListByFavorite();

      expect(result).assertTrue();
      mocker.clear(sharedPreferencesUtils);
    })

    it('AddFavoriteListPresenter_initContactsListByGroup', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      let result = false;
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('getAllContactWithPhoneNumbers')
        .afterAction(() => {
          result = true;
        });
      presenter.initContactsListByGroup();
      expect(result).assertTrue();
      mocker.clear(workWrapper);
    })

    it('AddFavoriteListPresenter_initContactsListByGroup_callback', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: string[]
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
          } as dataShare.DataShareHelper))
        });

      let favoriteForm: Record<string, number | string> = {
        'favorite': -1,
      }
      favoriteForm.pageTag = 'group';
      favoriteForm.groupId = presenter.groupId;

      let conditionArgs: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
      conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
      conditionArgs.and();
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, 1);
      conditionArgs.and();
      conditionArgs.notIn('name_raw_contact_id', [1]);

      let initConditionArgs: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .initConditionArgs);
      when(initConditionArgs)(ArgumentMatchers.any)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      mocker.mockFunc(presenter.contactsSource, presenter.contactsSource.refresh);
      mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initContactList);
      let initAlphabetIndex: Function = mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initAlphabetIndex);
      when(initAlphabetIndex)(ArgumentMatchers.any).afterAction(() => {
        mocker.verify('getPhoneLabelNameById', ['xxx', 'xxx']).once();
        expect(presenter.contactsTotal).assertEqual(1);
      });

      presenter.initContactsListByGroup();

      expect(result).assertTrue();
    })

    it('AddFavoriteListPresenter_initContactsListByGroup_callback_contactList_empty', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          result = true;
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: Array<string>
            ): Promise<DataShareResultSet> => {
              return new Promise<DataShareResultSet>(resolve => resolve({
                rowCount: 0,
                close: () => {
                },
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 0,
                getLong: (columnIndex: number): number => 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });

      let conditionArgs: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
      conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);
      conditionArgs.and();
      conditionArgs.equalTo(RawContacts.ACCOUNT_ID, 1);
      conditionArgs.and();
      conditionArgs.notIn('name_raw_contact_id', [1]);

      let initConditionArgs: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .initConditionArgs);
      when(initConditionArgs)(ArgumentMatchers.any)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      mocker.mockFunc(presenter.contactsSource, presenter.contactsSource.refresh);
      mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initContactList);
      let initAlphabetIndex: Function = mocker.mockFunc(presenter.alphabetIndexPresenter, presenter.alphabetIndexPresenter.initAlphabetIndex);
      when(initAlphabetIndex)(ArgumentMatchers.any).afterAction(() => {
        expect(presenter.contactsTotal).assertEqual(0);
        mocker.verify('refresh', [[]]).once();
        mocker.verify('initContactList', [[]]).once();
      });

      presenter.initContactsListByGroup();

      expect(result).assertTrue();
    })
  })
}