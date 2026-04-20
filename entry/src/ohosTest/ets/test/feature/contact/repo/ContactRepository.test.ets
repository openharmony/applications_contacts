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
import dataShare from '@ohos.data.dataShare';
import { ContactRepository } from '../../../../../../../../feature/contact';
import { CallLog } from '../../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import GroupMemberItem from '../../../../../../../../feature/contact/src/main/ets/repo/GroupMemberItem';
import ContactListItem from '../../../../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import GroupListItem from '../../../../../../../../feature/contact/src/main/ets/repo/GroupListItem';
import SearchContactListItem from '../../../../../../../../feature/contact/src/main/ets/repo/SearchContactListItem';
import ContactUsuallyListItemHasPhones
  from '../../../../../../../../feature/contact/src/main/ets/repo/ContactUsuallyListItem';
import ContactUsuallyListItem from '../../../../../../../../feature/contact/src/main/ets/repo/ContactUsuallyListItem';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';
import { common } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { dataSharePredicates, preferences, ValuesBucket } from '@kit.ArkData';
import Contact from '../../../../../../../../feature/contact/src/main/ets/entity/Contact';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import {
  sharedPreferencesUtils
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/SharedPreferencesUtils';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  CountAlphabetIndex,
  NameFixInfo
} from '../../../../../../main/ets/model/type/ContactParams';
import { AlphabetIndexObj } from '../../../../../../main/ets/model/bean/ContactVo';
import { AccountVo } from '../../../../../../main/ets/model/bean/AccountVo';
import { IContactSearchParams, ContactSearchResultData } from '../../../../../../main/ets/model/type/ContactParams';
import { ContactBlobSource, GroupParams, PhoneNumberInterface } from '../../../../../../main/ets/model/type';
import { NumberMatch } from '../../../../../../../../feature/contact/src/main/ets/cust/NumberMatch';
import { GroupBean } from '../../../../../../main/ets/model/bean/GroupBean';
import { contact } from '@kit.ContactsKit';


export default function ContactRepositoryTest() {
  describe('ContactRepositoryTest', () => {

    let contactRepository: ContactRepository;

    beforeEach(() => {
      contactRepository = ContactRepository.getDTTestInstance();
    })

    it('ContactRepositoryTest_getInstance', 0, () => {
      expect(typeof contactRepository).assertEqual(typeof ContactRepository.getInstance());
    })

    it('ContactRepositoryTest_init_undefined', 0, () => {
      contactRepository.init();
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_init', 0, () => {
      let context = DTGlobalContext.getContext().getObject("contactContext") as Context;

      contactRepository.init(context);

      expect(JSON.stringify(contactRepository.getContext())).assertEqual(JSON.stringify(context));
    })

    it('ContactRepositoryTest_saveTest', 0, () => {
      let result = contactRepository.saveTest();

      expect(result).assertFalse();
    })

    it('ContactRepositoryTest_getDataAbilityHelper', 0, async () => {
      let dataAbilityHelper: LooseObject = {
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
      };
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
      contactRepository = ContactRepository.getDTTestInstance();

      contactRepository.dataShareHelper = dataAbilityHelper as dataShare.DataShareHelper;

      let result = await contactRepository.getDataAbilityHelper();

      expect(result).assertDeepEquals(contactRepository.dataShareHelper);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('ContactRepositoryTest_triggerContactsSyncDataSwitch', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.triggerContactsSyncDataSwitch();

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setPrimary_true', 0, async () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      await contactRepository.setPrimary(0, 0, 0, true);

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setPrimary_error', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterThrow('error');
      contactRepository.setPrimary(0, 0, 0, true);
      expect(contactRepository.resultDT).assertTrue();
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setPrimary_false', 0, async () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      await contactRepository.setPrimary(0, 0, 0, false);

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findContactMeeTimeAbilityById_if1', 0, async () => {
      contactRepository.findContactMeeTimeAbilityById(-1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });
    })

    it('ContactRepositoryTest_findContactMeeTimeAbilityById_noIf1_if2', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findContactMeeTimeAbilityById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findContactMeeTimeAbilityById_noIf1_noIf2', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findContactMeeTimeAbilityById(1, (contact: Contact) => {
        expect(contact.id).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findContactMeeTimeAbilityById_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findContactMeeTimeAbilityById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findContactMeeTimeAbilityById_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.findContactMeeTimeAbilityById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findById_if', 0, () => {
      contactRepository.findById(-1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });
    })

    it('ContactRepositoryTest_findById_noIf_if', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findById_noIf1_noIf2', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findById(1, (contact: Contact) => {
        expect(contact.id).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findById_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findById_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.findById(1, (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactSize_if', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getContactSize(1, (count: number) => {
        expect(count).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactSize_noIf_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getContactSize(-1, (count: number) => {
        expect(count).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactSize_noIf_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.getContactSize(-1, (count: number) => {
        expect(count).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findListById_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findListById(['1'], (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findListById_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findListById(['1'], (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findListById_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findListById(['1'], (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findListById_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.findListById(['1'], (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllContactSizeAndIndex_if1_count_0', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let process = (jsonObj: NameFixInfo, index: number, alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
      };
      contactRepository.getAllContactSizeAndIndex(process, (countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_getAllContactSizeAndIndex_noIf1_count_1', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(-1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let process = (jsonObj: NameFixInfo, index: number, alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
      };
      contactRepository.getAllContactSizeAndIndex(process, (countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(1);
      });

      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_getAllContactSizeAndIndex_queryError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(-1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let process = (jsonObj: NameFixInfo, index: number, alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
      };
      contactRepository.getAllContactSizeAndIndex(process, (countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_getAllContactSizeAndIndex_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(-1)));

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let process = (jsonObj: NameFixInfo, index: number, alphabetIndex: Record<string, AlphabetIndexObj>, isEnd: boolean) => {
      };
      contactRepository.getAllContactSizeAndIndex(process, (countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(0);
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findAllAcount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllAcount((rst: AccountVo[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllAcount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllAcount((rst: AccountVo[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllAcount_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllAcount((rst: AccountVo[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllAcount_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.findAllAcount((rst: AccountVo[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAll_if1_if2_if3', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let actionData: AllContactGetParam = new AllContactGetParam(1, 10);
      contactRepository.findAll(actionData, (resultSet?: DataShareResultSet) => {
        expect(resultSet?.rowCount).assertEqual(0);
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findAll_noIf1_noIf2_else', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(-1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let actionData: AllContactGetParam = new AllContactGetParam(1, -1);

      contactRepository.findAll(actionData, (resultSet) => {
        expect(resultSet?.rowCount).assertEqual(1);
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findAll_queryError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(1)));

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let actionData: AllContactGetParam = new AllContactGetParam(0, -1);
      contactRepository.findAll(actionData, (resultSet) => {
        expect(resultSet?.rowCount).assertUndefined();
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findAll_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(new  Promise<preferences.ValueType>(resolve => resolve(1)));

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let actionData: AllContactGetParam = new AllContactGetParam(0, -1);
      contactRepository.findAll(actionData, (resultSet) => {
        expect(resultSet?.rowCount).assertEqual(0);
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findByQuickSearchKey_if1', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findByQuickSearchKey('', (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByQuickSearchKey_noIf1_if2_if3', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findByQuickSearchKey('', (contact: Contact) => {
        expect(contact.id).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByQuickSearchKey_noIf1_noIf2_noIf3', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findByQuickSearchKey('', (contact: Contact) => {
        expect(contact.id).assertEqual(-1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByQuickSearchKey_queryError', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findByQuickSearchKey('', (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByQuickSearchKey_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.findByQuickSearchKey('', (contact: Contact) => {
        expect(contact).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByPhoneIsNotNull_rowCount_0', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0);

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByPhoneIsNotNull_rowCount_1_old_equal_new', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
          return columns == ContactListItem.COLUMNS ?
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => true,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 1,
            getLong: (columnIndex: number): number => 1
          } as DataShareResultSet)) : new Promise<DataShareResultSet>(resolve => resolve({
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
      } as dataShare.DataShareHelper;
      contactRepository.dataShareHelper = dataAbilityHelper1;

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0);

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(ContactRepository.getInstance());
    })

    it('ContactRepositoryTest_findByPhoneIsNotNull_rowCount_1_old_notEqual_new', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;
      contactRepository.dataShareHelper = dataAbilityHelper1;

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0);
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findByPhoneIsNotNull_queryError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
          return columns == ContactListItem.COLUMNS ?
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
            code: 1,
            message: 'error'
          } as BusinessError)) : new Promise<DataShareResultSet>(resolve => resolve({
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
      } as dataShare.DataShareHelper;
      contactRepository.dataShareHelper = dataAbilityHelper1;

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0);
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst).assertUndefined();
      });

      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_findByPhoneIsNotNull_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0);

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst).assertUndefined();
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllContactNumbers_if1_1', 0, () => {
      let mocker: MockKit = new MockKit();

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, -1, undefined, 'tag');

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_getAllContactNumbers_if1_2', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 1, undefined, 'tag');

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllContactNumbers_if1_3', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, -1, undefined, 'getAllContact');

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllContactNumbers_else', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('is_deleted', '0');
      conditionArgs.and();
      conditionArgs.equalTo('favorite', 0);
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, -1, undefined, 'getContact');

      let initConditionArgs: Function = mocker.mockFunc(contactRepository, contactRepository.initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      contactRepository.findByPhoneIsNotNull(addParams, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_else1_if_else2_if_noIf', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('accountType')
        .afterReturn(1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, 0, 1);

      await contactRepository.initConditionArgs(addParams);

      expect(contactRepository.resultDT).assertTrue();

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_else1_noIf_if_noIf_noIf', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('accountType')
        .afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, 0, 1, 'arrange');

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_if1_editContact_if_noIf', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, 1);

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(contactRepository);
      mocker.clear(sharedPreferencesUtils);
    })

    it('ContactRepositoryTest_initConditionArgs_if1_favorite_if', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, -1, -1);

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_queryGroups', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, -1, undefined, 'group');

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_queryGroups_goToFirstRow_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, -1, -1, 'group');

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_initConditionArgs_queryGroups_error', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))()
        .afterReturn(-1);

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, -1, -1, 'group');

      await contactRepository.initConditionArgs(addParams);

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setResultSet_if', 0, () => {
      let resultSetOld: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => false,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;

      contactRepository.setResultSet(resultSetOld, (v: Map<number, PhoneNumberInterface[]>) => {
        expect(v.size).assertEqual(0);
      });
    })

    it('ContactRepositoryTest_setResultSet_noIf_if_if', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let resultSetOld: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => 1
      } as DataShareResultSet;

      contactRepository.setResultSet(resultSetOld, (v: Map<number, PhoneNumberInterface[]>) => {
        expect(v.size).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setResultSet_noIf_if_noIf', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let resultSetOld: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => '',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => 1
      } as DataShareResultSet;

      contactRepository.setResultSet(resultSetOld, (v: Map<number, PhoneNumberInterface[]>) => {
        expect(v.size).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_setResultSet_noIf_else', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let resultSetOld: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => 0
      } as DataShareResultSet;

      contactRepository.setResultSet(resultSetOld, (v: Map<number, PhoneNumberInterface[]>) => {
        expect(v.size).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteById_if', 0, () => {
      contactRepository.deleteById(-1, (data: number) => {
        expect(data).assertUndefined();
      })
    })

    /*it('ContactRepositoryTest_deleteById_noIf1', 0, () => {
      let result: number = 0;
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact_data') {
            return new Promise<number>(resolve => resolve(0));
          } else if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact') {
            return new Promise<number>(resolve => resolve(1));
          } else {
            return new Promise<number>(resolve => resolve(2));
          }
        }
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.deleteById(1, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })*/

    it('ContactRepositoryTest_deleteById_noIf_deleteError1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact_data') {
            return new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
              reject({
                code: 0, message: 'error'
              } as BusinessError)
            });
          } else if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact') {
            return new Promise<number>(resolve => resolve(1));
          } else {
            return new Promise<number>(resolve => resolve(2));
          }
        }
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.deleteById(1, (data: number) => {
      });

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteById_noIf_deleteError2', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact_data') {
            return new Promise<number>(resolve => resolve(0));
          } else if (uri = 'datashare:///com.ohos.contactsdataability/contacts/contact') {
            return new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
              reject({
                code: 0, message: 'error'
              } as BusinessError)
            });
          } else {
            return new Promise<number>(resolve => resolve(2));
          }
        }
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.deleteById(1, (data: number) => {
      });

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteById_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.deleteById(1, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteByIdIn_if', 0, () => {
      contactRepository.deleteByIdIn([], (data: number) => {
        expect(data).assertUndefined();
      })
    })

    it('ContactRepositoryTest_deleteByIdIn_noIf', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteByIdIn([1], (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteByIdIn_noIf_deleteError1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
          reject({
            code: 0, message: 'error'
          } as BusinessError)
        })
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteByIdIn([1], (data: number) => {
        expect(data).assertUndefined();
      });

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteByIdIn_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.deleteByIdIn([1], (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_notifyChange_if', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        notifyChange: (uri: string): Promise<void> => new Promise<void>(resolve => resolve())
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.notifyChange();

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_notifyChange_if_notifyChangeError', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        notifyChange: (uri: string): Promise<void> => new Promise<void>((resolve: () => void, reject: (reason: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.notifyChange();

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_notifyChange_noIf', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<void>(resolve => resolve(undefined)));

      contactRepository.notifyChange();

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_notifyChange_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      contactRepository.notifyChange();

      expect(ContactRepository.TYPE_ID_DEVICE).assertEqual(15);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_registerDataChangeObserver_if2', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        on: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
          callback({} as BusinessError);
        }
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let observer = () => {
      };
      contactRepository.registerDataChangeObserver(observer);

      expect(contactRepository.observers[0]).assertDeepEquals(observer);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_registerDataChangeObserver_if2_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let observer = () => {
      };
      contactRepository.registerDataChangeObserver(observer);

      expect(contactRepository.observers[0]).assertDeepEquals(observer);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_registerDataChangeObserver_if2_getDataAbilityHelper_undefined', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<void>(resolve => resolve(undefined)));
      ;

      let observer = () => {
      };
      contactRepository.registerDataChangeObserver(observer);

      expect(contactRepository.observers[0]).assertDeepEquals(observer);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_registerDataChangeObserver_if3', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        on: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
        }
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let observer = () => {
      };
      contactRepository.observers = [observer];
      contactRepository.registerDataChangeObserver(observer);

      expect(contactRepository.observers[0]).assertDeepEquals(observer);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_registerDataChangeObserver_noIf', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        on: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
        }
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let observer = () => {
        let result = false;
      };
      let observer1 = () => {
      };
      contactRepository.observers = [observer];
      contactRepository.registerDataChangeObserver(observer1);

      expect(contactRepository.observers[1]).assertDeepEquals(observer1);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_unRegisterDataChangeObserver_if1', 0, () => {
      let mocker: MockKit = new MockKit();

      let observer1 = () => {
      };
      let observer2 = () => {
        let param = 0;
      };
      contactRepository.observers = [observer2];

      contactRepository.unRegisterDataChangeObserver(observer1);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_unRegisterDataChangeObserver_if2', 0, () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        off: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
          let observer1 = () => {
          };
          contactRepository.observers = [observer1];
          callback({} as BusinessError)
        }
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let observer1 = () => {
      };
      contactRepository.observers = [observer1];

      contactRepository.unRegisterDataChangeObserver(observer1);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_unRegisterDataChangeObserver_if2_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1,
          message: 'error'
        } as BusinessError)));

      let observer1 = () => {
      };
      contactRepository.observers = [observer1];

      contactRepository.unRegisterDataChangeObserver(observer1);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_unRegisterDataChangeObserver_if2_getDataAbilityHelper_undefined', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<void>(resolve => resolve(undefined)));
      ;

      let observer1 = () => {
      };
      contactRepository.observers = [observer1];

      contactRepository.unRegisterDataChangeObserver(observer1);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_unRegisterDataChangeObserver_noIf', 0, () => {
      let observer = () => {
        let result = false;
      };
      let observer1 = () => {
      };
      contactRepository.observers = [observer, observer1];

      contactRepository.unRegisterDataChangeObserver(observer1);

      expect(ContactRepository.TYPE_ID_PHONE_NUMBER).assertEqual(5);
    })

    it('ContactRepositoryTest_queryNameByNumber_if1', 0, async () => {
      let result: DataShareResultSet | undefined = await contactRepository.queryNameByNumber([]);
      expect(result).assertUndefined();
    })

    it('ContactRepositoryTest_queryNameByNumber_if2', 0, async () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(undefined);

      let result: DataShareResultSet | undefined = await contactRepository.queryNameByNumber(['1', '2', '3']);

      expect(result).assertUndefined();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryNameByNumber_for_noIf3', 0, async () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let result: DataShareResultSet | undefined = await contactRepository.queryNameByNumber(['1', '2', '3']);

      expect(result?.rowCount).assertEqual(1);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryNameByNumber_for_if3', 0, async () => {
      let mocker: MockKit = new MockKit();

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let result: DataShareResultSet | undefined = await contactRepository.queryNameByNumber(['1', '2', '3'], 1);

      expect(result?.rowCount).assertEqual(1);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryNameByNumber_getDataAbilityHelperError', 0, async () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new  Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper) => void, reject: (reason?: Error) => void) =>
        reject(new Error('error'))));

      let result: DataShareResultSet | undefined = await contactRepository.queryNameByNumber(['570977632']);

      expect(result).assertUndefined();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_dealContactResultSet_while_if1', 0, async () => {
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => {
          return resultSet.rowCount-- === 0 ? false : true;
        },
        getString: (columnIndex: number): string => '5709',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.queryNameByNumber))(ArgumentMatchers.any)
        .afterReturn(resultSet);
      when(mocker.mockFunc(NumberMatch.getInstance(), NumberMatch.getInstance().getCallerIndex))(resultSet)
        .afterReturn(-1);

      let result: Record<string, string>[] = await contactRepository.dealContactResultSet(resultSet, ['5709']);

      expect(result.length).assertEqual(1);

      mocker.clear(contactRepository);
      mocker.clear(NumberMatch.getInstance());
    })

    it('ContactRepositoryTest_dealContactResultSet_while_noIf1', 0, async () => {
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => {
          return resultSet.rowCount-- === 0 ? false : true;
        },
        getString: (columnIndex: number): string => '5709',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.queryNameByNumber))(ArgumentMatchers.any)
        .afterReturn(resultSet);
      when(mocker.mockFunc(NumberMatch.getInstance(), NumberMatch.getInstance().getCallerIndex))(resultSet)
        .afterReturn(-1);

      let result: Record<string, string>[] = await contactRepository.dealContactResultSet(resultSet, ['5708']);

      expect(result.length).assertEqual(1);

      mocker.clear(contactRepository);
      mocker.clear(NumberMatch.getInstance());
    })

    it('ContactRepositoryTest_dealContactResultSet_noWhile_if2', 0, async () => {
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.queryNameByNumber))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve(undefined)));
      ;

      let result: Record<string, string>[] = await contactRepository.dealContactResultSet(resultSet, ['570977632']);

      expect(result.length).assertEqual(0);

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_dealContactResultSet_noIf2_if3', 0, async () => {
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1,
        goToRow: (position: number): boolean => false
      } as DataShareResultSet;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.queryNameByNumber))(ArgumentMatchers.any)
        .afterReturn(resultSet);

      when(mocker.mockFunc(NumberMatch.getInstance(), NumberMatch.getInstance().getCallerIndex))(resultSet)
        .afterReturn(0);

      let result: Record<string, string>[] = await contactRepository.dealContactResultSet(resultSet, ['570977632', '570977633']);

      expect(result.length).assertEqual(2);

      mocker.clear(contactRepository);
      mocker.clear(NumberMatch.getInstance());
    })

    it('ContactRepositoryTest_dealContactResultSet_noIf2_noIf3', 0, async () => {
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => true,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 1,
        getLong: (columnIndex: number): number => -1,
        goToRow: (position: number): boolean => false
      } as DataShareResultSet;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.queryNameByNumber))(ArgumentMatchers.any)
        .afterReturn(resultSet);

      when(mocker.mockFunc(NumberMatch.getInstance(), NumberMatch.getInstance().getCallerIndex))(resultSet)
        .afterReturn(-1);

      let result: Record<string, string>[] = await contactRepository.dealContactResultSet(resultSet, ['570977632', '570977633']);

      expect(result.length).assertEqual(0);

      mocker.clear(contactRepository);
      mocker.clear(NumberMatch.getInstance());
    })

    it('ContactRepositoryTest_findFavoriteByIndex_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findFavoriteByIndex(0, (rst: ContactUsuallyListItemHasPhones[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findFavoriteByIndex_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findFavoriteByIndex(0, (rst: ContactUsuallyListItemHasPhones[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findFavoriteByIndex_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findFavoriteByIndex(0, (rst: ContactUsuallyListItemHasPhones[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findFavoriteByIndex_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findFavoriteByIndex(0, (rst: ContactUsuallyListItemHasPhones[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllFavorite_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllFavorite((rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllFavorite_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllFavorite((rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllFavorite_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllFavorite((rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllFavorite_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findAllFavorite((rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsually_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsually_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsually_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsually_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsuallyByRawContact_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllUsuallyByRawContact((rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsuallyByRawContact_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllUsuallyByRawContact((rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllUsuallyByRawContact_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findAllUsuallyByRawContact((rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getDisplayNameByFavorite_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getDisplayNameByFavorite(['570977632'], ['570977632'], (rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getDisplayNameByFavorite_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getDisplayNameByFavorite(['570977632'], ['570977632'], (rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getDisplayNameByFavorite_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getDisplayNameByFavorite(['570977632'], ['570977632'], (rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getDisplayNameByFavorite_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.getDisplayNameByFavorite(['570977632'], ['570977632'], (rst: ContactUsuallyListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_searchContact_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let actionData: IContactSearchParams = {
        value: '5709', loopRequest: false, startIndex: 0, limitNumber: 10
      } as IContactSearchParams;
      contactRepository.searchContact(actionData, (rst: ContactSearchResultData) => {
        expect(rst.total).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_searchContact_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let actionData: IContactSearchParams = {
        value: '5709', loopRequest: false, startIndex: 0, limitNumber: 10
      } as IContactSearchParams;
      contactRepository.searchContact(actionData, (rst: ContactSearchResultData) => {
        expect(rst.total).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_searchContact_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      let actionData: IContactSearchParams = {
        value: '5709', loopRequest: false, startIndex: 0, limitNumber: 10
      } as IContactSearchParams;
      contactRepository.searchContact(actionData, (rst: ContactSearchResultData) => {
        expect(rst.total).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_searchContact_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      let actionData: IContactSearchParams = {
        value: '5709', loopRequest: false, startIndex: 0, limitNumber: 10
      } as IContactSearchParams;
      contactRepository.searchContact(actionData, (rst: ContactSearchResultData) => {
        expect(rst.total).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryT9PhoneIsNotNull_rowCount_0', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.queryT9PhoneIsNotNull({
        'teleNumber': '570977632'
      }, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryT9PhoneIsNotNull_rowCount_1_phoneNumbers_undefined', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
          return columns == SearchContactListItem.COLUMNS ?
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => true,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 1,
            getLong: (columnIndex: number): number => 1
          } as DataShareResultSet)) : new Promise<DataShareResultSet>(resolve => resolve({
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
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.queryT9PhoneIsNotNull({
        'teleNumber': '570977632'
      }, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryT9PhoneIsNotNull_rowCount_1_phoneNumbers_undefined_queryError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
          return columns == SearchContactListItem.COLUMNS ?
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError)) : new Promise<DataShareResultSet>(resolve => resolve({
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
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.queryT9PhoneIsNotNull({
        'teleNumber': '570977632'
      }, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryT9PhoneIsNotNull_rowCount_1_phoneNumbers_notUndefined', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
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
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.queryT9PhoneIsNotNull({
        'teleNumber': '570977632'
      }, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryT9PhoneIsNotNull_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.queryT9PhoneIsNotNull({
        'teleNumber': ''
      }, (rst: ContactListItem[]) => {
        expect(rst.length).assertEqual(0)
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllGroup_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllGroup((rst: GroupListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllGroup_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllGroup((rst: GroupListItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllGroup_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.findAllGroup((rst: GroupListItem[]) => {
        expect(rst.length).assertEqual(0);
      });


      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findAllGroup_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findAllGroup((rst: GroupListItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_renameGroup', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new  Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.renameGroup({
        id: 1, groupName: 'group'
      } as GroupParams, () => {
        mocker.verify('getDataAbilityHelper', []).once();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_renameGroup_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.renameGroup({
        id: 1, groupName: 'group'
      } as GroupParams, () => {
        mocker.verify('getDataAbilityHelper', []).once();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroup_if1', 0, () => {
      contactRepository.removeGroup(-1, (data: number) => {
        expect(data).assertUndefined();
      });
    })

    it('ContactRepositoryTest_removeGroup_noIf1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new  Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.removeGroup(1, (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroup_updateError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new  Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) =>
        reject(({
          code: 1, message: 'error'
        } as BusinessError)))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.removeGroup(1, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroup_getDataAbilityHelpError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.removeGroup(1, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteGroupsById_if1', 0, () => {
      contactRepository.deleteGroupsById([], (data: number) => {
        expect(data).assertUndefined();
      });
    })

    it('ContactRepositoryTest_deleteGroupsById_noIf1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new  Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteGroupsById([1], (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteGroupsById_updateError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new  Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) =>
        reject(({
          code: 1, message: 'error'
        } as BusinessError)))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteGroupsById([1], (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteGroupsById_getDataAbilityHelpError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.deleteGroupsById([1], (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryGroupItemByName_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryGroupItemByName('group1', (rst: GroupBean) => {
        expect(rst.id).assertEqual(-1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryGroupItemByName_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryGroupItemByName('group1', (rst: GroupBean) => {
        expect(rst.id).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryGroupItemByName_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryGroupItemByName('group1', (rst: GroupBean) => {
        expect(rst).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryGroupItemByName_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.queryGroupItemByName('group1', (rst: GroupBean | string) => {
        expect(rst).assertEqual('error');
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findMemberByPhoneIsNotNull_rowCount_0', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => -1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;
      contactRepository.findMemberByPhoneIsNotNull(1, (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    let flag = 0
    it('ContactRepositoryTest_findMemberByPhoneIsNotNull_rowCount_1_phoneNumbers_undefined', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
          return flag++ == 0 ?
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => false,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 1,
            getLong: (columnIndex: number): number => 1
          } as DataShareResultSet)) : new Promise<DataShareResultSet>(resolve => resolve({
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
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.findMemberByPhoneIsNotNull(1, (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findMemberByPhoneIsNotNull_rowCount_1_phoneNumbers_undefined_queryError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.findMemberByPhoneIsNotNull(1, (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findMemberByPhoneIsNotNull_rowCount_1_phoneNumbers_notUndefined', 0, () => {
      let mocker: MockKit = new MockKit();

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType').afterReturn(-1);

      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => {
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
      } as dataShare.DataShareHelper;

      contactRepository.dataShareHelper = dataAbilityHelper1;

      contactRepository.findMemberByPhoneIsNotNull(1, (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_findMemberByPhoneIsNotNull_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.findMemberByPhoneIsNotNull(1, () => {
        expect(contactRepository.getContext()).not().assertNull();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllMemberNumbers_if1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getAllMemberNumbers(1, (rst: Map<number, PhoneNumberInterface[]>) => {
        expect(rst.size).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllMemberNumbers_noIf1_if2_if3', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => '570977632',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getAllMemberNumbers(1, (rst: Map<number, PhoneNumberInterface[]>) => {
        expect(rst.get(1)?.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllMemberNumbers_noIf1_if2_noIf3', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => true,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => '',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getAllMemberNumbers(1, (rst: Map<number, PhoneNumberInterface[]>) => {
        expect(rst.get(1)?.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getAllMemberNumbers_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.getAllMemberNumbers(1, (rst: Map<number, PhoneNumberInterface[]>) => {
        expect(rst.size).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryAllGroupMember_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 0,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 0
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryAllGroupMember('group1', (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryAllGroupMember_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryAllGroupMember('group1', (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryAllGroupMember_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.queryAllGroupMember('group1', (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_queryAllGroupMember_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.queryAllGroupMember('group1', (rst: GroupMemberItem[]) => {
        expect(rst.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMemberByGroupId', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteMemberByGroupId('groupId', (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMemberByGroupId_deleteError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason: BusinessError) => void) =>
        reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteMemberByGroupId('groupId', (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMemberByGroupId_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.deleteMemberByGroupId('groupId', (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_activateRestore', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.activateRestore();

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_activateRestore_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.activateRestore();

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_activateRestore_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.activateRestore();

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMembers_if1', 0, () => {
      contactRepository.deleteMembers('groupId', [], (data: number) => {
        expect(data).assertEqual(undefined);
      });
    })

    it('ContactRepositoryTest_deleteMembers_noIf1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteMembers('groupId', [0], (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMembers_deleteError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason: BusinessError) => void) =>
        reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.deleteMembers('groupId', [0], (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_deleteMembers_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.deleteMembers('groupId', [0], (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroupMemberByRawContactId', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.removeGroupMemberByRawContactId(0, (data: number) => {
        expect(data).assertEqual(1);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroupMemberByRawContactId_deleteError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void, reject: (reason: BusinessError) => void) =>
        reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.removeGroupMemberByRawContactId(0, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_removeGroupMemberByRawContactId_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper))()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.removeGroupMemberByRawContactId(0, (data: number) => {
        expect(data).assertUndefined();
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactIdWithBlobNotNull_rowCount_0', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
          rowCount: 1,
          close: () => {
          },
          goToFirstRow: () => false,
          goToNextRow: () => false,
          getString: (columnIndex: number): string => 'xxx',
          getColumnIndex: (columnName: string): number => 1,
          getLong: (columnIndex: number): number => 1
        } as DataShareResultSet))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
        expect(result.length).assertEqual(1);
      });

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactIdWithBlobNotNull_rowCount_1', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
        expect(result.length).assertEqual(0);
      });

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactIdWithBlobNotNull_queryError', 0, () => {
      let dataAbilityHelper1: dataShare.DataShareHelper = {
        query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
        new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError))
      } as dataShare.DataShareHelper;

      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(dataAbilityHelper1 as dataShare.DataShareHelper)));

      contactRepository.getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
        expect(result.length).assertEqual(0);
      });

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_getContactIdWithBlobNotNull_getDataAbilityHelperError', 0, () => {
      let mocker: MockKit = new MockKit();

      let getDataAbilityHelper: Function = mocker.mockFunc(contactRepository, contactRepository.getDataAbilityHelper);
      when(getDataAbilityHelper)()
        .afterReturn(new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      contactRepository.getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
        expect(result.length).assertEqual(0);
      });

      mocker.verify('getDataAbilityHelper', []).once();

      mocker.clear(contactRepository);
    })

    it('ContactRepositoryTest_parsingFilterCondition_IS_NOT_NULL', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.IS_NOT_NULL;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_EQUAL_TO', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.EQUAL_TO;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_NOT_EQUAL_TO', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.NOT_EQUAL_TO;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_IN', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.IN;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_NOT_IN', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.NOT_IN;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_CONTAINS', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.CONTAINS;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })

    it('ContactRepositoryTest_parsingFilterCondition_INDEX_NOT_0', 0, () => {
      let filterClause: contact.FilterClause = {};
      let filterCondition: contact.FilterCondition = contact.FilterCondition.CONTAINS;
      let filterCondition1: contact.FilterCondition = contact.FilterCondition.IS_NOT_NULL;
      filterClause.id = [{
        filterCondition: filterCondition
      }]
      filterClause.name = [{
        filterCondition: filterCondition
      }]
      filterClause.focusModeList = [{
        filterCondition: filterCondition
      }]
      let filterOptions: contact.FilterOptions = {filterCondition}
      let filterOptions1: contact.FilterOptions = {
        filterCondition: filterCondition1
      }
      let options: contact.FilterOptions[] = [];
      options.push(filterOptions, filterOptions1);
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      contactRepository.parsingFilterCondition('', options, condition);
      expect(contactRepository.resultDT).assertTrue();
    })
  })
}