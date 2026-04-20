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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import SpeedDialPresenter from '../../../../../../main/ets/presenter/speeddial/SpeedDialPresenter';
import common from '@ohos.app.ability.common';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import resmgr from '@ohos.resourceManager';
import { SingleSelectContact, SpeedDialItem, VoiceMailItem } from '../../../../../../main/ets/model/type';
import { EnterSingleSelectedMode } from '../../../../../../main/ets/model/type/EnumUtil';
import { BusinessError } from '@ohos.base';
import { contact } from '@kit.ContactsKit';
import { sharedPreferencesUtils } from '../../../../../../../../feature/call/oh_modules/common';
import { ValueType } from '@kit.ArkData';
import { ContactsConstants } from '../../../../../../../../common/src/main/ets/ContactsConstants';

let presenter: SpeedDialPresenter;

export default function SpeedDialPresenterTest() {
  describe('SpeedDialPresenterTest', () => {

    beforeEach(() => {
      AppStorage.clear();
      presenter = SpeedDialPresenter.getInstance();
    })

    it('SpeedDialPresenter_getInstance', 0, () => {
      expect(typeof SpeedDialPresenter.getInstance()).assertEqual(typeof presenter);
    })

    it('SpeedDialPresenter_getTitleString', 0, () => {
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return 'xxx';
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.SpeedDialContextName)
        .afterReturn(uiContext);

      let titleString = presenter.getTitleString($r('app.string.speed_dial'));

      expect(titleString).assertEqual('xxx');
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SpeedDialPresenter_initSpeedList', 0, () => {
      let speedDialObj: Record<string, SpeedDialItem> = {
        '1': {
          number: 1,
          contactName: 'roxy',
          contactTelephone: '570977632'
        } as SpeedDialItem
      };
      let speedDial: string = JSON.stringify(speedDialObj);

      let result = presenter.initSpeedList(speedDial);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify([{
        "number": 1, "contactName": "roxy", "contactTelephone": "570977632"
      }, {
        "number": 2, "contactName": "", "contactTelephone": ""
      }, {
        "number": 3, "contactName": "", "contactTelephone": ""
      }, {
        "number": 4, "contactName": "", "contactTelephone": ""
      }, {
        "number": 5, "contactName": "", "contactTelephone": ""
      }, {
        "number": 6, "contactName": "", "contactTelephone": ""
      }, {
        "number": 7, "contactName": "", "contactTelephone": ""
      }, {
        "number": 8, "contactName": "", "contactTelephone": ""
      }, {
        "number": 9, "contactName": "", "contactTelephone": ""
      }]));
    })

    it('SpeedDialPresenter_initVoiceMailList', 0, () => {
      presenter.slotId = 0;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.getVoicemailNumber))(0)
        .afterReturn(new Promise<string>(resolve => resolve('570977632')));

      presenter.initVoiceMailList((param: Array<VoiceMailItem>) => {
        expect(param[1].voiceMailItemValue).assertEqual('570977632');
      });

      mocker.clear(presenter.voicemailManager);
    })

    it('SpeedDialPresenter_speedDialToContact', 0, () => {
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
      let params: Record<string, number | string> =
        {
          'fromSpeedDial': EnterSingleSelectedMode.SpeedDial, 'selectedNumber': String(1)
        };

      presenter.speedDialToContact(0);

      expect(JSON.stringify([presenter.sheetParams])).assertEqual(JSON.stringify([params]));
    })

    it('SpeedDialPresenter_speedDialToContact_pathInfos_undefined', 0, () => {
      presenter.pathInfos = undefined

      presenter.speedDialToContact(0);

      expect(presenter.pathInfos).assertUndefined();
    })

    it('SpeedDialPresenter_clickVoiceMailEvent_haveSimCard_false', 0, () => {
      let result = false;
      presenter.noSimCardDialogController = {
        open: () => {
          result = true;
        }
      } as CustomDialogController;
      AppStorage.setOrCreate('haveSimCard', false);
      let mocker: MockKit = new MockKit();

      presenter.clickVoiceMailEvent();

      expect(result).assertTrue();

      mocker.clear(presenter);
    })

    it('SpeedDialPresenter_clickVoiceMailEvent_haveSimCard_true', 0, async () => {
      AppStorage.setOrCreate('haveSimCard', true);
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return 'xxx';
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.SpeedDialContextName)
        .afterReturn(uiContext);

      let result = false;
      when(mocker.mockFunc(presenter, presenter.setVoiceMail))().afterAction(() => {
        result = true;
      });

      presenter.clickVoiceMailEvent();

      expect(result).assertTrue();

      mocker.clear(presenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SpeedDialPresenter_setVoiceMail_haveMultiSimCard_false', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', false);
      AppStorage.setOrCreate('defaultSlot', 0);
      let mocker: MockKit = new MockKit();
      let result0 = false;

      when(mocker.mockFunc(presenter, presenter.pushToVoicemail))(AppStorage.get('defaultSlot'))
        .afterAction(() => {
          result0 = true;
        });

      await presenter.setVoiceMail();

      expect(result0).assertTrue();

      mocker.clear(presenter);
    })

    it('SpeedDialPresenter_setVoiceMail_number1_empty_number2_50977633', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', true);
      let mocker: MockKit = new MockKit();
      let voicemailManager = presenter.voicemailManager;
      let getVoicemailNumber: Function = mocker.mockFunc(voicemailManager, voicemailManager.getVoicemailNumber);
      when(getVoicemailNumber)(0).afterReturn(new Promise<string>(resolve => resolve('')));
      when(getVoicemailNumber)(1).afterReturn(new Promise<string>(resolve => resolve('570977633')));

      let result0 = false;
      when(mocker.mockFunc(presenter, presenter.pushToVoicemail))(1).afterAction(() => {
        result0 = true;
      });

      await presenter.setVoiceMail();

      expect(result0).assertTrue();

      mocker.clear(voicemailManager);
      mocker.clear(presenter);
    })

    it('SpeedDialPresenter_setVoiceMail_number1_50977632', 0, async () => {
      presenter.pathInfos = new NavPathStack();
      AppStorage.setOrCreate('haveMultiSimCard', true);
      let mocker: MockKit = new MockKit();
      let getVoicemailNumber: Function = mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.getVoicemailNumber);
      when(getVoicemailNumber)(0).afterReturn(new Promise<string>(resolv => resolv('570977632')));
      when(getVoicemailNumber)(1).afterReturn(new Promise<string>(resolv => resolv('570977633')));

      let result = false;
      when(mocker.mockFunc(presenter, presenter.pushToVoicemail))(0).afterAction(() => {
        result = true;
      });

      await presenter.setVoiceMail();

      expect(result).assertTrue();

      mocker.clear(presenter.voicemailManager);
      mocker.clear(presenter);
    })

    it('SpeedDialPresenter_setVoiceMail_number1_empty_number2_empty', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', true);
      let result = false;
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        terminateSelf: () => new Promise<void>(resolve => resolve()),
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return 'xxx';
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.SpeedDialContextName)
        .afterReturn(uiContext);

      let getVoicemailNumber: Function = mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.getVoicemailNumber);
      when(getVoicemailNumber)(0).afterReturn(new Promise<string>(resolve => resolve('')));
      when(getVoicemailNumber)(1).afterReturn(new Promise<string>(resolve => resolve('')));

      await presenter.setVoiceMail();

      expect(result).assertFalse();

      mocker.clear(presenter.voicemailManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SpeedDialPresenter_setVoiceMail_businessError', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', true);
      let result = false;
      let uiContext: common.UIAbilityContext = {
        abilityInfo: {},
        getApplicationContext: () => {
        },
        terminateSelf: () => new Promise<void>(
          (resolve: () => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          }),
        resourceManager: {
          getStringSync: (resource: Resource) => {
            return 'xxx';
          }
        } as resmgr.ResourceManager
      } as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.SpeedDialContextName)
        .afterReturn(uiContext);

      mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.getVoicemailNumber);

      await presenter.setVoiceMail();

      expect(result).assertTrue();

      mocker.clear(presenter.voicemailManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SpeedDialPresenter_setVoiceMail_context_undefined', 0, async () => {
      AppStorage.setOrCreate('haveMultiSimCard', true);

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.SpeedDialContextName)
        .afterReturn(undefined);

      mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.getVoicemailNumber);

      await presenter.setVoiceMail();

      expect(presenter.slotId).assertEqual(0);

      mocker.clear(presenter.voicemailManager);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('SpeedDialPresenter_pushToVoicemail', 0, () => {
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
      let param: Record<string, number> = {
        'slotId': 0
      };

      presenter.pushToVoicemail(0);

      expect(AppStorage.get('toVoicemailFromSetting') as boolean).assertFalse();
      expect(JSON.stringify(presenter.pathInfos.getParamByName('VoiceMail'))).assertEqual(JSON.stringify([param]));
    })

    it('SpeedDialPresenter_pushToVoicemail_pathInfos_undefined', 0, () => {
      presenter.pathInfos = undefined

      presenter.pushToVoicemail(0);

      expect(AppStorage.get('toVoicemailFromSetting') as boolean).assertFalse();
    })

    it('SpeedDialPresenter_confirmVoiceMail', 0, () => {
      presenter.slotId = 0;
      let result = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(presenter.voicemailManager, presenter.voicemailManager.setVoicemailInfo))(0)
        .afterAction(() => {
          result = true;
        });

      presenter.confirmVoiceMail('xx', (res: boolean) => {
      });

      expect(result).assertTrue();

      mocker.clear(presenter.voicemailManager);
    })

    it('SpeedDialPresenter_confirmVoiceMail_callback', 0, () => {
      presenter.slotId = 0;

      presenter.confirmVoiceMail('xx', (res: boolean) => {
        expect(res).assertFalse();
      });
    })

    it('SpeedDialPresenter_parseContactForResult_if', 0, () => {
      let data: contact.Contact[] = [];
      let speedObj: Record<string, SpeedDialItem> = {};
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      presenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL);
      mocker.verify('saveToPreferences', [speedObj]).never();
      mocker.clear(sharedPreferencesUtils)
    })

    it('SpeedDialPresenter_parseContactForResult_else', 0, async () => {
      let phone: contact.PhoneNumber = {phoneNumber: '123'};
      let phones: contact.PhoneNumber[] = [];
      phones.push(phone);
      let contact: contact.Contact = {phoneNumbers: phones};
      let data: contact.Contact[] = [];
      data.push(contact);
      let obj: SpeedDialItem = {
        nameSuffix: '',
        namePrefix: '',
        portraitColor: '',
        contactTelephone: '123',
        portraitPath: '',
        number: 123
      }
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<ValueType> ((resolve: Function) => {
        resolve('')
      }));
      let params: Record<string, number | string> = {'fromSpeedDial': 1, 'selectedNumber': '123'}
      presenter.sheetParams = params;
      let speedObj: Record<string, SpeedDialItem> = {'123': obj};
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await presenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL);
      mocker.verify('saveToPreferences', ['speedDialObjString', JSON.stringify(speedObj)]).once();
      mocker.clear(sharedPreferencesUtils)
    })

    it('SpeedDialPresenter_parseContactForResult_else1', 0, async () => {
      let phone: contact.PhoneNumber = {phoneNumber: '123'};
      let phones: contact.PhoneNumber[] = [];
      phones.push(phone);
      let contact: contact.Contact = {phoneNumbers: phones};
      let data: contact.Contact[] = [];
      data.push(contact);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<ValueType> ((resolve: Function) => {
        resolve('111')
      }));
      let params: Record<string, number | string> = {'fromSpeedDial': 1, 'selectedNumber': '123'}
      presenter.sheetParams = params;
      let speedObj = JSON.parse('111') as Record<string, SpeedDialItem>;
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await presenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL);
      mocker.verify('saveToPreferences', ['speedDialObjString', JSON.stringify(speedObj)]).once();
      mocker.clear(sharedPreferencesUtils)
    })

    it('SpeedDialPresenter_parseContactForResult_error', 0, async () => {
      let phone: contact.PhoneNumber = {phoneNumber: '123'};
      let phones: contact.PhoneNumber[] = [];
      phones.push(phone);
      let contact: contact.Contact = {phoneNumbers: phones};
      let data: contact.Contact[] = [];
      data.push(contact);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<ValueType> ((resolve: Function) => {
        resolve('111')
      }));
      let params: Record<string, number | string> = {'fromSpeedDial': 1, 'selectedNumber': '123'}
      presenter.sheetParams = params;
      let speedObj = JSON.parse('111') as Record<string, SpeedDialItem>;
      let json: Function = mocker.mockFunc(JSON, JSON.parse);
      when(json)(speedObj).afterThrow('error');
      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      await presenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL);
      mocker.verify('saveToPreferences', ['speedDialObjString', JSON.stringify(undefined)]).once();
      mocker.clear(JSON);
      mocker.clear(sharedPreferencesUtils);
    })
  })
}