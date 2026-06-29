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
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import EntryFormAbility from '../../../../../main/ets/entryformability/EntryFormAbility';
import Want from '@ohos.app.ability.Want';
import { SpeedDialCardDataType } from '../../../../../main/ets/card/type/speedDialCardType';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { DTGlobalContext } from '../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import formInfo from '@ohos.app.form.formInfo';
import { contactPage } from '../../../../../main/ets/card/data/cardData';
import { FormCardController } from '../../../../../main/ets/card/common/FormCardController';
import { WorkerType } from '../../../../../main/ets/workers/WorkFactory';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import { dataShare, dataSharePredicates, DataShareResultSet, preferences } from '@kit.ArkData';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { MissedCallNotifier } from '../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import { ContactBlobSource } from '../../../../../main/ets/model/type';
import { formBindingData } from '@kit.FormKit';

export default function EntryFormAbilityTest() {
  describe('EntryFormAbilityTest', () => {
    let entryFormAbility: EntryFormAbility;
    let want: Want;
    let data: LooseObject;
    let mocker: MockKit;

    beforeEach(() => {
      mocker = new MockKit();
      entryFormAbility = new EntryFormAbility();
      entryFormAbility.context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.FormExtensionContext;
      entryFormAbility.mFormCardController = new FormCardController();
      entryFormAbility.mFormCardController.mDataWorker = new WorkerWrapper(WorkerType.DataWorker, false);
      want = {
        deviceId: '123',
        bundleName: 'com.ohos.meetimeservice',
        abilityName: 'CallServiceAbility',
        uri: 'test',
        type: '123',
        flags: 1,
        action: '',
        parameters: {
          'ohos.extra.param.key.form_identity': {
            'aa': 1
          },
          'ohos.extra.param.key.form_name': {
            'bb': 2
          },
          'formWantInfo': '{"intentName": "111", "intentParams": {"entityId": "123"}}'
        },
        entities: ['111', '222', '333'],
        moduleName: 'call'
      };
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [11, 22, 33],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': ['22', '33', '44'],
          'formName': '111',
          'id': 111
        }
      };
    })

    afterEach(() => {
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(entryFormAbility.mFormCardController);
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddForm', 0, () => {
      expect(entryFormAbility.onAddForm(want)).not().assertNull();
    })

    it('Contacts_EntryFormAbilityTest_onAddForm_no_formWantInfo', 0, () => {
      want = {
        deviceId: '123',
        bundleName: 'com.ohos.meetimeservice',
        abilityName: 'CallServiceAbility',
        uri: 'test',
        type: '123',
        flags: 1,
        action: '',
        parameters: {
          'ohos.extra.param.key.form_identity': {
            'aa': 1
          },
          'ohos.extra.param.key.form_name': {
            'bb': 2
          }
        },
        entities: ['111', '222', '333'],
        moduleName: 'call'
      };
      entryFormAbility.onAddForm(want);
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddIntentInfo', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
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

      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToShortcut);
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddDataToShortcut);

      entryFormAbility.onAddIntentInfo('11', 'shortcut');

      expect(entryFormAbility.haveSimCard).assertFalse();
      mocker.clear(entryFormAbility);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('Contacts_EntryFormAbilityTest_onAddIntentInfo_MissedCall', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToMissedCall);
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddToUpdate);
      entryFormAbility.onAddIntentInfo('12', 'MissedCall');
      mocker.verify('onAddTemplateToMissedCall', ['12']).once();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddTemplateToMissedCall', 0, () => {
      entryFormAbility.onAddTemplateToMissedCall('11');
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddTemplateToShortcut', 0, () => {
      let contactsList: SpeedDialCardDataType[] = [new SpeedDialCardDataType(), new SpeedDialCardDataType()];
      entryFormAbility.onAddTemplateToShortcut('11', contactsList);
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddDataToShortcut', 0, async () => {
      let saveToPreferences: Function =
        mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      when(saveToPreferences)('card_shortcut_edit_contact_11')
        .afterReturn(new Promise<preferences.ValueType>(resolve => resolve('str')));

      let contactsList: SpeedDialCardDataType[] = [new SpeedDialCardDataType(), new SpeedDialCardDataType()];

      when(mocker.mockFunc(entryFormAbility, entryFormAbility.onAddImage))(contactsList)
        .afterReturn(new Promise<SpeedDialCardDataType[]>(resolve => resolve([])));

      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.updateToCard);

      await entryFormAbility.onAddDataToShortcut('11', contactsList, 'Shortcut');

      expect(entryFormAbility.haveSimCard).assertFalse();
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddTemplateToSpeedDial', 0, () => {
      let contactsList: SpeedDialCardDataType[] = [new SpeedDialCardDataType(), new SpeedDialCardDataType()];
      entryFormAbility.onAddTemplateToSpeedDial('11', contactsList);
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddDataToSpeedDial', 0, () => {
      let contactsList: SpeedDialCardDataType[] = [new SpeedDialCardDataType(), new SpeedDialCardDataType()];
      expect(entryFormAbility.onAddDataToSpeedDial('11', contactsList, 'SpeedDial')).not().assertNull();
    })

    it('Contacts_EntryFormAbilityTest_onAddDataToSpeedDial_null', 0, () => {
      let oldData: SpeedDialCardDataType[] = [{
        contactId: '1'
      } as SpeedDialCardDataType];

      when(mocker.mockFunc(JSON, JSON.parse))(ArgumentMatchers.any).afterReturn(oldData);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.onAddImage))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>(resolve => resolve(oldData)));
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.updateToCard);

      let speedDialCardDataType: SpeedDialCardDataType = new SpeedDialCardDataType();
      speedDialCardDataType.contactId = '2';
      let contactsList: SpeedDialCardDataType[] = [speedDialCardDataType];

      entryFormAbility.onAddDataToSpeedDial('11', contactsList, 'SpeedDial');

      expect(entryFormAbility.haveSimCard).assertFalse();

      mocker.clear(JSON);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddImage', 0, async () => {
      try {
        let contactsList: SpeedDialCardDataType[] = [new SpeedDialCardDataType(), new SpeedDialCardDataType()];
        await entryFormAbility.onAddImage(contactsList);
      } catch (e) {
      }
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddProxies', 0, () => {
      expect(entryFormAbility.onAddProxies('11', '22')).not().assertNull();
    })

    it('Contacts_EntryFormAbilityTest_onAddProxies_MissedCall', 0, () => {
      let result = entryFormAbility.onAddProxies('11', 'MissedCall');
      const proxies: Array<formBindingData.ProxyData> = [
        {
          'key': 'datashareproxy://com.ohos.contactsdataability/calls/call_setting',
          'subscriberId': '11'
        }
      ];
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({
        "data": "{\"isHasVoiceCapability\":true}",
        "proxies": proxies
      }))
    })

    it('Contacts_EntryFormAbilityTest_onCastToNormalForm', 0, () => {
      entryFormAbility.onCastToNormalForm('11');
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onUpdateForm', 0, () => {
      entryFormAbility.onUpdateForm('11');
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onChangeFormVisibility', 0, () => {
      let newStatus: Record<string, number> = {
        'remarks': -1,
        'nickname': -1,
        'website': -1
      };
      entryFormAbility.onChangeFormVisibility(newStatus);
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_onMissedCallCard', 0, () => {
      let message: string = '{"params":{"flag":"missedCallCard","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';

      mocker.mockFunc(entryFormAbility, entryFormAbility.onMissedCallCard);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onMissedCallCard', [entryFormAbility.context]).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_shortCutCardDetail', 0, () => {
      let message: string = '{"params":{"flag":"shortCutCardDetail","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);
      let flag: string = data.params.flag;

      mocker.mockFunc(entryFormAbility, entryFormAbility.onCardDetail);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onCardDetail', [data, '111', flag, entryFormAbility.context]).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_missedCallCardDetail', 0, () => {
      let message: string = '{"params":{"flag":"missedCallCardDetail","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);
      let flag: string = data.params.flag;

      mocker.mockFunc(entryFormAbility, entryFormAbility.onCardDetail);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onCardDetail', [data, '111', flag, entryFormAbility.context]).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_getContactByPhones', 0, () => {
      let message: string = '{"params":{"flag":"getContactByPhones","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onGetContactByPhones);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onGetContactByPhones', [data, '111', entryFormAbility.context]).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_updateTemplate', 0, () => {
      let message: string = '{"params":{"flag":"updateTemplate","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onUpdateTemplate);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onUpdateTemplate', [data, '111']).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_updateContactsList', 0, () => {
      let message: string = '{"params":{"flag":"updateContactsList","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onUpdateContactsList);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onUpdateContactsList', [data, '111']).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_speedDialByPhone', 0, () => {
      let message: string = '{"params":{"flag":"speedDialByPhone","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onSpeedDialByPhone);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onSpeedDialByPhone', [data]).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_queryMissedCall', 0, () => {
      let message: string = '{"params":{"flag":"queryMissedCall","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onQueryMissedCall);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onQueryMissedCall', ['111']).once();
    })

    it('Contacts_EntryFormAbilityTest_onFormEvent_dialNumber', 0, () => {
      let message: string = '{"params":{"flag":"dialNumber","contactId":1,"phone":123,"callId":123,' +
        '"phoneList":[11,22,33],"callLog":"111","contactType":"ddd","contactsList":["22","33","44"],' +
        '"formName":"111","id":111}}';
      let data: LooseObject = JSON.parse(message);

      mocker.mockFunc(entryFormAbility, entryFormAbility.onDialNumber);
      entryFormAbility.onFormEvent('111', message);
      mocker.verify('onDialNumber', [data]).once();
    })

    it('Contacts_EntryFormAbilityTest_getContactList', 0, () => {
      let idList: Array<Record<string, string | number>> = [{}, {}];
      entryFormAbility.getContactList(idList);
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_getContactList_callback', 0, () => {
      let cardContext: common.FormExtensionContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.FormExtensionContext;
      let getDefaultCardContext: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(cardContext);

      ContactRepository.getInstance().init(cardContext);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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
        }
      } as dataShare.DataShareHelper)));
      let record: Record<string, string | number> = {
        'id': 1
      }
      let idList: Array<Record<string, string | number>> = [record];

      entryFormAbility.getContactList(idList);

      expect(entryFormAbility.haveSimCard).assertFalse();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('Contacts_EntryFormAbilityTest_onRemoveForm', 0, () => {
      entryFormAbility.onRemoveForm('111');
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onConfigurationUpdate', 0, () => {
      entryFormAbility.onConfigurationUpdate();
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAcquireFormState', 0, () => {
      expect(entryFormAbility.onAcquireFormState(want)).assertEqual(formInfo.FormState.READY);
    })

    it('Contacts_EntryFormAbilityTest_onMissedCallCard', 0, () => {
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.clickToContactRecord);
      let startAbilityPage = contactPage.PAGE_FLAG_DIALER;
      entryFormAbility.onMissedCallCard(entryFormAbility.context);
      mocker.verify('clickToContactRecord', [entryFormAbility.context, startAbilityPage]).once();
    })

    it('Contacts_EntryFormAbilityTest_onCardDetail_001', 0, () => {
      entryFormAbility.onCardDetail(data, '11', 'missedCallCardDetail', entryFormAbility.context);
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onCardDetail_002', 0, () => {
      entryFormAbility.onCardDetail(data, '11', '111', entryFormAbility.context);
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onGetContactByPhones', 0, () => {
      entryFormAbility.onGetContactByPhones(data, '11', entryFormAbility.context);
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onUpdateTemplate', 0, () => {
      entryFormAbility.onUpdateTemplate(data, '11');
      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onUpdateTemplate_getContactByIdList', 0, () => {
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': ['22', '33', '44'],
          'formName': '111',
          'id': 111
        }
      };

      entryFormAbility.onUpdateTemplate(data, '11');

      expect(entryFormAbility.haveSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onUpdateTemplate_getContactByIdList_shortcut', 0, () => {
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': [],
          'formName': 'shortcut',
          'id': 111
        }
      };

      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToShortcut);
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddDataToShortcut);

      entryFormAbility.onUpdateTemplate(data, '11');

      expect(entryFormAbility.haveSimCard).assertFalse();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onUpdateTemplate_getContactByIdList_SpeedDial', 0, () => {
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': [],
          'formName': 'SpeedDial',
          'id': 111
        }
      };

      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToSpeedDial);
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddDataToSpeedDial);

      entryFormAbility.onUpdateTemplate(data, '11');

      expect(entryFormAbility.haveSimCard).assertFalse();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onUpdateContactsList', 0, () => {
      entryFormAbility.onUpdateContactsList(data, '11');
      expect(entryFormAbility.haveMultiSimCard).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onUpdateContactsList_getContactByIdList_shortcut', 0, () => {
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': [],
          'formName': 'shortcut',
          'id': 111
        }
      };

      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddDataToShortcut);

      entryFormAbility.onUpdateContactsList(data, '11');

      expect(entryFormAbility.haveMultiSimCard).assertFalse();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onUpdateContactsList_getContactByIdList_SpeedDial', 0, () => {
      data = {
        'params': {
          'flag': 'missedCallCard',
          'contactId': 1,
          'phone': 123,
          'callId': 123,
          'phoneList': [],
          'callLog': '111',
          'contactType': 'ddd',
          'contactsList': [],
          'formName': 'SpeedDial',
          'id': 111
        }
      };

      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddDataToSpeedDial);

      entryFormAbility.onUpdateContactsList(data, '11');

      expect(entryFormAbility.haveMultiSimCard).assertFalse();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onSpeedDialByPhone', 0, () => {
      mocker.mockFunc(entryFormAbility.mFormCardController,
        entryFormAbility.mFormCardController.setMissedCallBadgeNumberByPhone);
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.dealCallNumber);
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.setMissedCallToRead);
      let phone: string = data.params.phone;
      let numList: string[] = [phone];
      entryFormAbility.onSpeedDialByPhone(data);
      mocker.verify('setMissedCallBadgeNumberByPhone', [numList]).once();
      mocker.verify('dealCallNumber', [phone]).once();
      mocker.verify('setMissedCallToRead', [phone]).once();
    })

    it('Contacts_EntryFormAbilityTest_onQueryMissedCall', 0, () => {
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.getFirstMissedCall);
      entryFormAbility.onQueryMissedCall('test');
      mocker.verify('getFirstMissedCall', ['test', 'MissedCall']).once();
    })

    it('Contacts_EntryFormAbilityTest_onDialNumber', 0, () => {
      let contactId: string = data.params.contactId;
      mocker.mockFunc(entryFormAbility.mFormCardController, entryFormAbility.mFormCardController.getContactPhone);
      entryFormAbility.onDialNumber(data);
      mocker.verify('getContactPhone', [contactId]).once();
    })

    it("Contacts_EntryFormAbilityTest_handleRoamingNumber_undefined", 0, async () => {
      let callback: Function = () => {
      };
      entryFormAbility.mFormCardController.handleRoamingNumber(undefined, 0, callback);
      expect(entryFormAbility.mFormCardController.isEmergencyNum).assertFalse();
    })

    it('Contacts_EntryFormAbilityTest_onAddToUpdate_MissedCall', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init);
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToMissedCall);
      entryFormAbility.onAddToUpdate('123', 'aaa');
      mocker.verify('onAddTemplateToMissedCall', ['123']).never();

      await entryFormAbility.onAddToUpdate('111', 'MissedCall');
      mocker.verify('onAddTemplateToMissedCall', ['111']).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddToUpdate_shortcut', 0, async () => {
      let hasData: SpeedDialCardDataType[] = [];
      let obj: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        formId: '183747866'
      }
      hasData.push(obj);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init);
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.queryContactByFormId))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>((resolve: Function) => {
          resolve(hasData);
        }))
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToShortcut);
      await entryFormAbility.onAddToUpdate('183747866', 'shortcut');
      mocker.verify('onAddTemplateToShortcut', ['183747866', hasData]).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddToUpdate_shortcut_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init);
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.queryContactByFormId))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>((resolve: Function) => {
          resolve([]);
        }))
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToShortcut);
      await entryFormAbility.onAddToUpdate('183747866', 'shortcut');
      mocker.verify('onAddTemplateToShortcut', ['183747866', []]).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddToUpdate_SpeedDial', 0, async () => {
      let hasData: SpeedDialCardDataType[] = [];
      let obj: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        formId: '183747866'
      }
      hasData.push(obj);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init);
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.queryContactByFormId))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>((resolve: Function) => {
          resolve(hasData);
        }))
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToSpeedDial);
      await entryFormAbility.onAddToUpdate('183747866', 'SpeedDial');
      mocker.verify('onAddTemplateToSpeedDial', ['183747866', hasData]).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onAddToUpdate_SpeedDial_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MissedCallNotifier.getInstance(), MissedCallNotifier.getInstance().init);
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.queryContactByFormId))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>((resolve: Function) => {
          resolve([]);
        }))
      mocker.mockFunc(entryFormAbility, entryFormAbility.onAddTemplateToSpeedDial);
      await entryFormAbility.onAddToUpdate('183747866', 'SpeedDial');
      mocker.verify('onAddTemplateToSpeedDial', ['183747866', []]).once();
      mocker.clear(MissedCallNotifier.getInstance());
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_compressBase64Data', 0, async () => {
      let formId: string = '123';
      let mocker: MockKit = new MockKit();
      let base64Data: SpeedDialCardDataType[] = [];
      let obj: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        base64Str: '1',
        formId: '123'
      }
      base64Data.push(obj);
      mocker.mockFunc(entryFormAbility, entryFormAbility.compressBase64String);
      await entryFormAbility.compressBase64Data(base64Data, formId);
      expect(JSON.stringify(await entryFormAbility.compressBase64Data(base64Data, formId)))
        .assertEqual(JSON.stringify(base64Data));

      let obj1: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        base64Str: '2',
        formId: '123'
      }
      base64Data.push(obj1);
      mocker.mockFunc(entryFormAbility, entryFormAbility.compressBase64String);
      expect(JSON.stringify(await entryFormAbility.compressBase64Data(base64Data, formId)))
        .assertEqual(JSON.stringify(base64Data));

      let obj2: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        base64Str: '3',
        formId: '123'
      }
      base64Data.push(obj2);
      mocker.mockFunc(entryFormAbility, entryFormAbility.compressBase64String);
      expect(JSON.stringify(await entryFormAbility.compressBase64Data(base64Data, formId)))
        .assertEqual(JSON.stringify(base64Data));

      let obj3: SpeedDialCardDataType = {
        contactId: '',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        base64Str: '4',
        formId: '123'
      }
      base64Data.push(obj3);
      mocker.mockFunc(entryFormAbility, entryFormAbility.compressBase64String);
      expect(JSON.stringify(await entryFormAbility.compressBase64Data(base64Data, formId)))
        .assertEqual(JSON.stringify(base64Data));

      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_onRemoveForm1', 0, async () => {
      let hasData: SpeedDialCardDataType[] = [];
      let obj: SpeedDialCardDataType = {
        contactId: '111',
        displayName: '',
        nameSuffix: '',
        phones: [],
        showName: '',
        id: 1,
        formId: '183747866'
      }
      hasData.push(obj);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(entryFormAbility, entryFormAbility.queryContactByFormId))(ArgumentMatchers.any)
        .afterReturn(new Promise<SpeedDialCardDataType[]>((resolve: Function) => {
          resolve(hasData);
        }))
      mocker.mockFunc(entryFormAbility, entryFormAbility.updateContactFormId);
      await entryFormAbility.onRemoveForm('111');
      mocker.verify('updateContactFormId', ['111', '183747866']).once();
      mocker.clear(entryFormAbility);
    })

    it('Contacts_EntryFormAbilityTest_getContactIdWithBlobNotNullByFilter', 0, () => {
      let item: ContactBlobSource = {
        contactId: '1',
        blobSource: 1,
        rawContactId: '1',
        detailInfo: '1'
      }
      let contactBlobSourceList: ContactBlobSource[] = [item];
      let result = entryFormAbility.getContactIdWithBlobNotNullByFilter(contactBlobSourceList);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(item));

      let item1: ContactBlobSource = {
        contactId: '2',
        blobSource: 2,
        rawContactId: '2',
        detailInfo: '2'
      }
      contactBlobSourceList.push(item1);
      let result1 = entryFormAbility.getContactIdWithBlobNotNullByFilter(contactBlobSourceList);
      expect(JSON.stringify(result1)).assertEqual(JSON.stringify(item1));

      contactBlobSourceList = [];
      item.detailInfo = '';
      item1.detailInfo = '';
      contactBlobSourceList.push(item);
      contactBlobSourceList.push(item1);
      let result2 = entryFormAbility.getContactIdWithBlobNotNullByFilter(contactBlobSourceList);
      expect(JSON.stringify(result2)).assertEqual(JSON.stringify(item1));
    })

    it('Contacts_EntryFormAbilityTest_updateSpeedDialCardIdList', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.removePreferencesFromCache);
      let res: string[] = ['1'];
      when(mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any).afterReturn(res);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await entryFormAbility.updateSpeedDialCardIdList('0', 'add', 'SpeedDial');
      mocker.verify('saveToPreferences', ['speedDialCardIdList', ['1', '0']]).once();
      mocker.clear(sharedPreferencesUtils);
    })

    it('Contacts_EntryFormAbilityTest_updateSpeedDialCardIdList_add_else', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.removePreferencesFromCache);
      let res: string[] = [];
      when(mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any).afterReturn(res);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await entryFormAbility.updateSpeedDialCardIdList('1', 'add', 'SpeedDial');
      mocker.verify('saveToPreferences', ['speedDialCardIdList', ['1']]).once();
      mocker.clear(sharedPreferencesUtils);
    })

    it('Contacts_EntryFormAbilityTest_updateSpeedDialCardIdList_delete', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.removePreferencesFromCache);
      let res: string[] = ['1'];
      when(mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any).afterReturn(res);
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await entryFormAbility.updateSpeedDialCardIdList('1', 'delete', 'SpeedDial');
      mocker.verify('saveToPreferences', ['speedDialCardIdList', []]).once();
      mocker.clear(sharedPreferencesUtils);
    })
  })
}