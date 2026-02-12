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
import common from '@ohos.app.ability.common';
import { ContactInfo } from '../../../../../main/ets/model/bean/ContactInfo';
import ContactAbilityModel, { dealContactPhoto } from '../../../../../main/ets/model/ContactAbilityModel';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import dataShare from '@ohos.data.dataShare';
import { ContactRepository, DataItem, DataItemType, RawContacts } from '../../../../../../../feature/contact';
import { RichContactInfo } from '../../../../../main/ets/model/bean/RichContactInfo';
import { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket';
import { PhoneNumBean } from '../../../../../main/ets/model/bean/PhoneNumBean';
import { EmailBean } from '../../../../../main/ets/model/bean/EmailBean';
import { AIMBean } from '../../../../../main/ets/model/bean/AIMBean';
import { HouseBean } from '../../../../../main/ets/model/bean/HouseBean';
import { EventBean } from '../../../../../main/ets/model/bean/EventBean';
import { AccountVo } from '../../../../../main/ets/model/bean/AccountVo';
import { AssociatedPersonBean } from '../../../../../main/ets/model/bean/AssociatedPersonBean';
import { GroupBean, IntelligenceGroupInfo } from '../../../../../main/ets/model/bean/GroupBean';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  IContactSearchParams,
  IT9PhoneNumbersQueryParams,
  NameFixInfo,
  ContactSearchResultData,
  CountAlphabetIndex
} from '../../../../../main/ets/model/type/ContactParams';
import { AlphabetIndexObj, CharIndex } from '../../../../../main/ets/model/bean/ContactVo';
import DataShareResultSet, { DataType } from '@ohos.data.DataShareResultSet';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { GroupParams, ContactReturnObj } from '../../../../../main/ets/model/type';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import MeeTimeDeviceInfoModel from '../../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel';
import HashMap from '@ohos.util.HashMap';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import GroupListItem from '../../../../../../../feature/contact/src/main/ets/repo/GroupListItem';
import { sharedPreferencesUtils } from '../../../../../../../common/src/main/ets/util/SharedPreferencesUtils';
import { CallLog } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { FavoriteBean } from '../../../../../main/ets/model/bean/FavoriteBean';
import { ContactVo } from '../../../../../main/ets/model/bean/ContactVo';
import { BusinessError } from '@ohos.base';
import ContactListItem from '../../../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import data_preferences from '@ohos.data.preferences';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common'
import { Data } from '../../../../../../../feature/contact/src/main/ets/contract/Data';
import DataType1 from '../../../../../../../feature/contact/src/main/ets/contract/DataType';
import { RingtoneItem, RingtoneSelectionUtil } from '../../../../../main/ets/util/RingtoneSelectionUtil';
import { systemSoundManager } from '@kit.AudioKit';
import { ContactInfoUtil } from '../../../../../main/ets/util/ContactInfoUtil';
import RawContact from '../../../../../../../feature/contact/src/main/ets/entity/RawContact';

export default function ContactAbilityModelTest() {
  describe('ContactAbilityModelTest', () => {

    let mocker: MockKit;
    let context: common.UIAbilityContext;
    const TAG = 'ContactAbility: ';

    beforeEach(() => {
      context = DTGlobalContext.getContext().getObject("contactContext") as common.UIAbilityContext;
      mocker = new MockKit();
    });

    afterEach(() => {
      mocker.clear(ContactAbilityModel);
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('ContactAbilityModelTest_getContext_01', 0, () => {
      const context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      expect(JSON.stringify(context)).assertEqual(JSON.stringify(ContactAbilityModel.getContext(context)));
    });

    it("ContactAbilityModelTest_getContext_02", 0, () => {
      const context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      expect(JSON.stringify(context)).assertEqual(JSON.stringify(ContactAbilityModel.getContext()));
    });

    // it('ContactAbilityModelTest_addContact', 0, async () => {
    //   let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
    //     [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
    //     [], '', '', '',
    //     [new AIMBean('1', '', '', '')],
    //     [new HouseBean('1', '', '', '')],
    //     ['www.xxxx.com'],
    //     [new AssociatedPersonBean('1', '2', 'person', '')],
    //     [new EventBean('1', '', '', 'even1')],
    //     [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
    //     1, '', '', '', null
    //   );
    //   let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance().init(),
    //     ContactRepository.getInstance().init(context).getDataAbilityHelper);
    //
    //   let result = false;
    //   await ContactAbilityModel.addContact(addParams, (param: number) => {
    //   }, false, context).then(() => {
    //     result = true;
    //   });
    //   expect(result).assertTrue();
    //   mocker.clear(sharedPreferencesUtils);
    // })

    // it('ContactAbilityModelTest_addContact_businessError', 0, async () => {
    //   let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
    //     [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
    //     [], '', '', '',
    //     [new AIMBean('1', '', '', '')],
    //     [new HouseBean('1', '', '', '')],
    //     ['www.xxxx.com'],
    //     [new AssociatedPersonBean('1', '2', 'person', '')],
    //     [new EventBean('1', '', '', 'even1')],
    //     [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
    //     1, '', '', '', null
    //   );
    //   when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('accountType')
    //     .afterReturn(1);
    //   let result = false;
    //   await ContactAbilityModel.addContact(addParams, (param: number) => {
    //   }, false, context).then(() => {
    //     result = true;
    //   });
    //   expect(result).assertTrue();
    //   mocker.clear(sharedPreferencesUtils);
    // })

    it('ContactAbilityModelTest_updateRingToneToContact_01', 0, async () => {
      let result = false;
      let mockFun1 = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.saveRingToneToContact);

      when(mockFun1)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });

      await ContactAbilityModel.updateRingToneToContact(false, '', 'personalRingtone', 'personalNotificationRingtone', 'contactBeforePersonalRingtone', 'personalRingtonePath');

      expect(result).assertTrue();

      mocker.clear(ContactAbilityModel);
    });

    it('ContactAbilityModelTest_updateRingToneToContact_02', 0, async () => {
      let result = false;
      let mockFun1 = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.saveRingToneToContact);

      when(mockFun1)(ArgumentMatchers.any).afterThrow('error')

      await ContactAbilityModel.updateRingToneToContact(false, '', 'personalRingtone', 'personalNotificationRingtone', 'contactBeforePersonalRingtone', 'personalRingtonePath');

      expect(result).assertFalse();

      mocker.clear(ContactAbilityModel);
    });

    it('ContactAbilityModelTest_removeContactLocalRingtone_01', 0, async () => {
      let mockFun1 = mocker.mockFunc(RingtoneSelectionUtil, RingtoneSelectionUtil.findRingtoneFromList);
      let ringtoneResult: RingtoneItem = {
        id: 0,
        name: 'name',
        path: 'path'
      }

      when(mockFun1)(ArgumentMatchers.any).afterReturn(ringtoneResult)

      await ContactAbilityModel.removeContactLocalRingtone('1', '', 'personalRingtone');

      mocker.verify('findRingtoneFromList', ['']).once();

      mocker.clear(RingtoneSelectionUtil);
    });

    it('ContactAbilityModelTest_removeContactLocalRingtone_02', 0, async () => {
      let mockFun1 = mocker.mockFunc(RingtoneSelectionUtil, RingtoneSelectionUtil.findRingtoneFromList);
      let ringtoneResult: RingtoneItem = {
        id: 0,
        name: 'name',
        path: 'path'
      }

      when(mockFun1)(ArgumentMatchers.any).afterReturn(ringtoneResult)

      await ContactAbilityModel.removeContactLocalRingtone('1', 'personalRingtone', 'personalRingtone');

      mocker.verify('findRingtoneFromList', ['personalRingtone']).once();

      mocker.clear(RingtoneSelectionUtil);
    });

    it('ContactAbilityModelTest_removeContactLocalRingtone_03', 0, async () => {
      let mockFun1 = mocker.mockFunc(RingtoneSelectionUtil, RingtoneSelectionUtil.findRingtoneFromList);
      let ringtoneResult: RingtoneItem = {
        id: 0,
        name: 'name',
        path: 'path'
      }

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mockFun1)(ArgumentMatchers.any).afterReturn(ringtoneResult)

      await ContactAbilityModel.removeContactLocalRingtone('1', 'originalContactRingtoneInfo', 'personalRingtone');

      mocker.verify('findRingtoneFromList', ['originalContactRingtoneInfo']).once();
      mocker.clear(RingtoneSelectionUtil);
    });

    it('ContactAbilityModelTest_saveRingToneToContact_01', 0, async () => {
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().saveRingToneToContact);

      await ContactAbilityModel.saveRingToneToContact('id', 'uri', 'ringToneName', 'ringToneFilePath', () => {});

      mocker.verify('saveRingToneToContact', ['id', 'uri', 'ringToneName', 'ringToneFilePath', () => {}]).once();
      mocker.clear(ContactRepository.getInstance());
    });

    it('ContactAbilityModelTest_findNewestContact_01', 0, () => {
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().findNewestContact);

      ContactAbilityModel.findNewestContact(() => {}, context);

      mocker.verify('init', [context]).once();
      mocker.verify('findNewestContact', [() => {}]).once();
      mocker.clear(ContactRepository.getInstance());
    });

    it('ContactAbilityModelTest_markContactAsPoster_01', 0, () => {
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().markContactAsPoster);

      ContactAbilityModel.markContactAsPoster([], () => {}, context);

      mocker.verify('init', [context]).once();
      mocker.verify('markContactAsPoster', [[], () => {}]).once();
      mocker.clear(ContactRepository.getInstance());
    });

    it('ContactAbilityModelTest_getDisplayName', 0, () => {
      const contactInfoInstance: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      expect(JSON.stringify(contactInfoInstance.getDisplayNameByRule()))
        .assertEqual(JSON.stringify(ContactAbilityModel.getDisplayName(contactInfoInstance)));
    });

    it('ContactAbilityModelTest_dealParam', 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        batchInsert: (uri: string, values: ValuesBucket[]) => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
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
      addParams.contactID = '123';
      const result = addParams.rowContactID;
      const url = 'datashare:///com.ohos.contactsdataability/profile/contact_data';
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dataContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'roxy',
          'alpha_name': 'roxy',
          'phonetic_name': 'roxy',
          'other_lan_last_name': 'zhang',
          'other_lan_first_name': 'roxy',
          'type_id': 6,
          'extend7': 1
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.organizationContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'company',
          'position': 'position',
          'type_id': 4,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.noteContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'remarks1',
          'type_id': 10,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.phoneContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': '570977632',
          'extend7': '',
          'custom_data': '',
          'type_id': 5,
          'extend5': '1',
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.emailContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'roxy@ohos.com',
          'extend7': '',
          'custom_data': '',
          'type_id': 1,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.postalContact))(addParams)
        .afterReturn({});
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.eventContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': '',
          'extend7': 1,
          'custom_data': '',
          'type_id': 11
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.imContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': '',
          'extend7': '',
          'custom_data': '',
          'type_id': 2,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.groupsContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': '',
          'extend7': '1',
          'custom_data': '',
          'type_id': 9,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.websiteContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'www.xxx.com',
          'type_id': 12,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.nickContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'roxy',
          'type_id': 3,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.relationsContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'detail_info': 'roxy',
          'extend7': '',
          'custom_data': '',
          'type_id': 13,
        });
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.photoContact))(addParams)
        .afterReturn({
          'raw_contact_id': '1',
          'blob_data': '',
          'type_id': 8
        });

      await ContactAbilityModel.dealParam(DAHelper, addParams, true);
      mocker.verify('dataContact', [addParams, DAHelper, result, url]).once();
      mocker.clear(ContactAbilityModel)
    });

    it('ContactAbilityModelTest_dealParam_undefined', 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        batchInsert: (uri: string, values: ValuesBucket[]) => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
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
      addParams.contactID = '123';
      const result = addParams.rowContactID;
      const url = 'datashare:///com.ohos.contactsdataability/profile/contact_data';
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dataContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.organizationContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.noteContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.phoneContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.emailContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.postalContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.eventContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.imContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.groupsContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.websiteContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.nickContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.relationsContact))(addParams)
        .afterReturn(undefined);
      when(mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.photoContact))(addParams)
        .afterReturn(undefined);

      await ContactAbilityModel.dealParam(DAHelper, addParams, true);
      mocker.verify('dataContact', [addParams, DAHelper, result, url]).once();
      mocker.clear(ContactAbilityModel)
    });

    it("ContactAbilityModelTest_dataContact_display_name_notEmpty", 0, async () => {
      let contactInfo: ContactInfo = new ContactInfo("", "display_name", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      let DAHelper: LooseObject = {
        insert: () => {
        }
      }
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.getDisplayName);
      ContactAbilityModel.dataContact(contactInfo, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify("getDisplayName", [contactInfo]).never();

      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_dataContact_display_name_empty", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let contactInfo: ContactInfo = new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      let mockerFun: Function = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.getDisplayName);
      when(mockerFun)(contactInfo).afterReturn('');

      ContactAbilityModel.dataContact(contactInfo, DAHelper as dataShare.DataShareHelper, 'result', 'url');

      mocker.verify("getDisplayName", [contactInfo]).once();
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_nickContact_nickname_notEmpty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let nickContact: Record<string, string | number> = {
        'raw_contact_id': 'result',
        'detail_info': 'nickname',
        'type_id': 3,
      };
      let contactInfo: ContactInfo = new ContactInfo("", "display_name", "nickname", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      let result = ContactAbilityModel.nickContact(contactInfo, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(nickContact));
    });

    it("ContactAbilityModelTest_nickContact_nickname_empty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let contactInfo: ContactInfo = new ContactInfo("", "display_name", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      let result = ContactAbilityModel.nickContact(contactInfo, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_organizationContact_company_position_notEmpty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], 'position1', 'company1', 'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let organizationContact: Record<string, string | number> = {
        'raw_contact_id': 'result',
        'detail_info': 'company1',
        'position': 'position1',
        'type_id': 4,
      };
      let result = ContactAbilityModel.organizationContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(organizationContact));
    });

    it("ContactAbilityModelTest_organizationContact_company_position_empty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', 'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.organizationContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_noteContact_remarks_notEmpty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let noteContact: Record<string, number | string> = {
        'raw_contact_id': 'result',
        'detail_info': 'remarks',
        'type_id': 10,
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', 'remarks',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.noteContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(noteContact));
    });

    it("ContactAbilityModelTest_noteContact_remarks_empty", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.noteContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_phoneContact_return", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.phoneContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'phoneContact, add phones size is ' + addParams.phones.length]).never();
      mocker.clear(HiLog)
    });

    it("ContactAbilityModelTest_phoneContact_primary_true", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let phoneContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': '570977632',
        'extend7': '',
        'custom_data': '',
        'type_id': 5,
        'extend5': '1',
      };
      let phoneDataArr: LooseObject [] = [phoneContact];
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.phoneContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(phoneDataArr));
    });

    it("ContactAbilityModelTest_phoneContact_primary_false", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let phoneContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': '570977632',
        'extend7': '',
        'custom_data': '',
        'type_id': 5,
        'extend5': '0',
      };
      let phoneDataArr: LooseObject [] = [phoneContact];
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', false, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.phoneContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(phoneDataArr));
    });

    it("ContactAbilityModelTest_phoneContact_noPhones", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.phoneContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_emailContact", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let emailContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': 'roxy@ohos.com',
        'extend7': '',
        'custom_data': '',
        'type_id': 1,
      };
      let emailDataArr: LooseObject [] = [emailContact];
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.emailContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(emailDataArr))
    });

    it("ContactAbilityModelTest_emailContact_return", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', '', '')], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.emailContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'emailContact, add emails size is ' + addParams.emails.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_emailContact_noEmails", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.emailContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_postalContact_return", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.postalContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'emailContact, add emails size is ' + addParams.emails.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_postalContact", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let postalContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': 'house',
        'extend7': '',
        'custom_data': '',
        'type_id': 7,
      };
      let houseDataArr: LooseObject [] = [postalContact];
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', 'house')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.postalContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(houseDataArr))
    });

    it("ContactAbilityModelTest_postalContact_noHouse", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [new AIMBean('1', '', '', '')],
        [],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.postalContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_eventContact_return", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '', [new AIMBean('1', '', '', '')], [],
        ['www.xxxx.com'], [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'event')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.eventContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'eventContact, add events size is ' + addParams.events.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_eventContact", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let eventContact: Record<string, string | number> = {
        'raw_contact_id': 'result',
        'detail_info': 'event',
        'custom_data': '',
        'type_id': 11,
        'calendar_event_id': ''
      };
      let eventDataArr: LooseObject [] = [eventContact];
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '', [new AIMBean('1', '', '', '')], [],
        ['www.xxxx.com'], [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', 'event', '', 'event')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.eventContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(eventDataArr));
    });

    it("ContactAbilityModelTest_eventContact_noEvent", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [new AIMBean('1', '', '', '')],
        [],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.eventContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_imContact_return", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
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
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.imContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'imContact, add aims size is ' + addParams.aims.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_imContact", 0, () => {
      let imContact: Record<string, number | string | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': 'aim',
        'extend7': '',
        'custom_data': '',
        'type_id': 2,
      };
      let imDataArr: LooseObject [] = [imContact];
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', 'aim')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.imContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(imDataArr));
    });

    it("ContactAbilityModelTest_imContact_noAim", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '',
        [],
        [],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.imContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_groupsContact", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
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
      let groupsContact: Record<string, number | string> = {
        'raw_contact_id': 'result',
        'detail_info': 'group1',
        'extend7': '1',
        'custom_data': '',
        'type_id': 9,
      };
      let groupDataArr: LooseObject [] = [groupsContact];
      let result = ContactAbilityModel.groupsContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(groupDataArr));
    });

    it("ContactAbilityModelTest_groupsContact_noGroup", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [], '', '', '', [], [], ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', '')], [], [], 1, '', '', '', null
      );
      let result = ContactAbilityModel.groupsContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_websiteContact_return", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        [''],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.websiteContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'websiteContact, add websites size is ' + addParams.websites.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_websiteContact", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
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
      let websiteContact: Record<string, string | number> = {
        'raw_contact_id': 'result',
        'detail_info': 'www.xxxx.com',
        'type_id': 12,
      };
      let websiteArr: LooseObject [] = [websiteContact];
      let result = ContactAbilityModel.websiteContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(websiteArr));
    });

    it("ContactAbilityModelTest_websiteContact_noWeb", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        [],
        [new AssociatedPersonBean('1', '2', 'person', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.websiteContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_relationsContact_return", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', '', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let relationsContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': 'name',
        'extend7': '',
        'custom_data': '',
        'type_id': 13,
      };
      let relationArr: LooseObject [] = [relationsContact];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.relationsContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      mocker.verify('i', [TAG, 'relationsContact, add relationships size is ' + addParams.relationships.length]).never();
      mocker.clear(HiLog);
    });

    it("ContactAbilityModelTest_relationsContact", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let relationsContact: Record<string, string | number | undefined> = {
        'raw_contact_id': 'result',
        'detail_info': 'person',
        'extend7': '1',
        'custom_data': 'name',
        'type_id': 13,
      };
      let relationArr: LooseObject [] = [relationsContact];
      let result = ContactAbilityModel.relationsContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(relationArr));
    });

    it("ContactAbilityModelTest_relationsContact_noRelation", 0, () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      let result = ContactAbilityModel.relationsContact(addParams, DAHelper as dataShare.DataShareHelper, 'result', 'url');
      expect(result).assertUndefined();
    });

    it("ContactAbilityModelTest_photoContact", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', new Uint8Array()
      );
      let photoContact: Record<string, number | string | Uint8Array> = {
        'raw_contact_id': '1',
        'blob_data': new Uint8Array(),
        'type_id': 8,
        'blob_source': 3
      };
      const url = 'datashare:///com.ohos.contactsdataability/profile/contact_data';
      let result = ContactAbilityModel.photoContact(addParams, DAHelper as dataShare.DataShareHelper, '1', url);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(photoContact));
    });

    it("ContactAbilityModelTest_photoContact_noPhoto", 0, async () => {
      let DAHelper: LooseObject = {
        insert: () => {
        }
      };
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1', 'company1', 'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );
      const url = 'datashare:///com.ohos.contactsdataability/profile/contact_data';
      let result = ContactAbilityModel.photoContact(addParams, DAHelper as dataShare.DataShareHelper, '1', url);
      expect(JSON.stringify(result)).assertUndefined();
    });

    it("ContactAbilityModelTest_getAllAccount", 0, async () => {
      let result = false;
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAllAcount);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })
      await ContactAbilityModel.getAllAccount(() => {
      });
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllAccount_callback_return", 0, async () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

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

      await ContactAbilityModel.getAllAccount((emptyResult: AccountVo[]) => {
        expect(result).assertTrue();
        expect(emptyResult.length).assertEqual(0);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it("ContactAbilityModelTest_getAllAccount_callback", 0, async () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

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

      await ContactAbilityModel.getAllAccount((emptyResult: AccountVo[]) => {
        expect(result).assertTrue();
        expect(emptyResult.length).assertEqual(1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it("ContactAbilityModelTest_getAllContact", 0, async () => {
      let result = false;
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAll);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })
      const actionData = new AllContactGetParam(0, 0);

      await ContactAbilityModel.getAllContact(actionData, () => {
      });

      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_getAllContact_callback_result_empty", 0, async () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

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

      const actionData = new AllContactGetParam(0, 0);

      await ContactAbilityModel.getAllContact(actionData, (contactList: ContactListItem[]) => {
        expect(result).assertTrue();
        expect(contactList.length).assertEqual(0);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it("ContactAbilityModelTest_getAllContact_callback_result_not_empty", 0, async () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

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

      const actionData = new AllContactGetParam(0, 0);

      ContactAbilityModel.getAllContact(actionData, (contactList: ContactListItem[]) => {
        expect(result).assertTrue();
        expect(contactList.length).assertEqual(1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    });

    it('ContactAbilityModelTest_getContactSize', 0, () => {
      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getContactSize))(1)
        .afterAction(() => {
          result = true;
        });
      ContactAbilityModel.getContactSize(1, () => {
      });
      expect(result).assertTrue();
    })

    it("ContactAbilityModelTest_getAllContactSizeAndIndex_callback", 0, () => {
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

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve(1)));

      ContactAbilityModel.getAllContactSizeAndIndex((countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(1);
        expect(result).assertTrue();
      });
      mocker.clear(sharedPreferencesUtils);
    });

    it("ContactAbilityModelTest_getAllContactSizeAndIndex_callback_error", 0, () => {
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

      let getFromPreferences: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('accountType')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve(1)));

      let addAlphabetIndexObj: Function = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addAlphabetIndexObj);
      when(addAlphabetIndexObj)(ArgumentMatchers.any).afterThrow('error');

      ContactAbilityModel.getAllContactSizeAndIndex((countAlphabetIndex: CountAlphabetIndex) => {
        expect(countAlphabetIndex.count).assertEqual(1);
        expect(result).assertTrue();
      });
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_addAlphabetIndexObj_01", 0, () => {
      let jsonObj = new NameFixInfo('namePrefix', '测试');
      const index = 0;
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [new CharIndex(jsonObj.nameSuffix, index, index)];
      let alphabetIndex: Record<string, AlphabetIndexObj> = {
        'namePrefix': alphabetIndexObj
      }

      ContactAbilityModel.addAlphabetIndexObj(jsonObj, index, alphabetIndex, true);

      let expectedAlphabetIndexObj: AlphabetIndexObj = new AlphabetIndexObj();
      expectedAlphabetIndexObj.enPrefix.end = index;
      expectedAlphabetIndexObj.zhPrefix = [new CharIndex(jsonObj.nameSuffix, index, index)];

      expect(JSON.stringify(alphabetIndex[jsonObj.namePrefix])).assertEqual(JSON.stringify(expectedAlphabetIndexObj));
    });

    it("ContactAbilityModelTest_addAlphabetIndexObj_02", 0, () => {
      let jsonObj = new NameFixInfo('namePrefix', '测试');
      const index = 0;
      let alphabetIndex: Record<string, AlphabetIndexObj> = {}
      try {
        ContactAbilityModel.addAlphabetIndexObj(jsonObj, index, alphabetIndex, true);
      } catch (e) {
      }
      let expectedAlphabetIndexObj: AlphabetIndexObj = {
        enPrefix: new CharIndex(jsonObj.nameSuffix, index, index),
        zhPrefix: []
      };
      expectedAlphabetIndexObj.enPrefix.end = index;
      expectedAlphabetIndexObj.zhPrefix = [];
      expect(JSON.stringify(alphabetIndex[jsonObj.namePrefix]))
        .assertEqual('{"enPrefix":{"char":"测试","start":0,"end":0},"zhPrefix":[]}');
    });

    it("ContactAbilityModelTest_addAlphabetIndexObj_03", 0, () => {
      let jsonObj = new NameFixInfo('namePrefix', '测试', '测试');
      let index = 0;
      let alphabetIndex: Record<string, AlphabetIndexObj> = {
        'namePrefix': {
          enPrefix: new CharIndex('ce', 0, 0),
          zhPrefix: [new CharIndex('测', 0, 0)],
        } as AlphabetIndexObj
      } as Record<string, AlphabetIndexObj>;

      ContactAbilityModel.addAlphabetIndexObj(jsonObj, index, alphabetIndex, true);

      expect(JSON.stringify(alphabetIndex[jsonObj.namePrefix]))
        .assertEqual('{"enPrefix":{"char":"ce","start":0,"end":0},"zhPrefix":[{"char":"测","start":0,"end":0},{"char":"测试","start":0,"end":0}]}');
    });

    it("ContactAbilityModelTest_addAlphabetIndexObj_04", 0, () => {
      let jsonObj = new NameFixInfo('namePrefix', '测试', '测试');
      let index = 0;
      let expectedAlphabetIndexObj: AlphabetIndexObj = {
        enPrefix: new CharIndex('ce', 0, 0),
        zhPrefix: [new CharIndex('测试', 0, 0)],
      } as AlphabetIndexObj;

      let alphabetIndex: Record<string, AlphabetIndexObj> = {
        'namePrefix': expectedAlphabetIndexObj
      } as Record<string, AlphabetIndexObj>;

      ContactAbilityModel.addAlphabetIndexObj(jsonObj, index, alphabetIndex, true);

      expect(JSON.stringify(alphabetIndex[jsonObj.namePrefix])).assertEqual(JSON.stringify(expectedAlphabetIndexObj));
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByOrganization", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryIntelligenceGroupContactsByOrganization);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.queryIntelligenceGroupContactsByOrganization('test', 1, () => {
      }, context);

      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByOrganization_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByOrganization('test', 1, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByOrganization_not_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

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
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByOrganization('test', 1, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByTimestamp", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryIntelligenceGroupContactsByTimestamp);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.queryIntelligenceGroupContactsByTimestamp('0', 1, () => {
      }, context);

      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByTimestamp_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByTimestamp('0', 1, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByTimestamp_not_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

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
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByTimestamp('0', 1, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByCity", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryIntelligenceGroupContactsByCity);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.queryIntelligenceGroupContactsByCity('test', 1, () => {
      }, context);

      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByCity_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByCity('test', 1, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_queryIntelligenceGroupContactsByCity_not_empty", 0, () => {
      let result = false;
      ContactRepository.getInstance().init(context);

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
              getString: (columnIndex: number): string => '00',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.queryIntelligenceGroupContactsByCity('test', 1, () => {
        expect(result).assertTrue();
      }, context);
    });


    it("ContactAbilityModelTest_getAllContactWithPhoneNumbers", 0, () => {
      let result = false;
      const addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0, -1);
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findByPhoneIsNotNull);
      when(mockFunc)(addParams).afterAction(() => {
        result = true;
      })

      ContactAbilityModel.getAllContactWithPhoneNumbers(() => {
      }, addParams, context);

      mocker.verify('init', [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllContactWithPhoneNumbers_callback_contactList_empty", 0, () => {
      let result = false;
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0, -1);

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
      conditionArgs.and();
      conditionArgs.equalTo(RawContacts.FAVORITE, 0);
      conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);

      let initConditionArgs: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
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

      ContactAbilityModel.getAllContactWithPhoneNumbers(() => {
        expect(result).assertTrue();
      }, addParams, context);
    });

    it("ContactAbilityModelTest_getAllContactWithPhoneNumbers_callback_contactList_not_empty", 0, () => {
      let result = false;
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(0, 0, -1);
      let callback = () => {
        expect(result).assertTrue();
      };

      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0');
      conditionArgs.and();
      conditionArgs.equalTo(RawContacts.FAVORITE, 0);
      conditionArgs.orderByAsc(RawContacts.SORT).orderByAsc(RawContacts.SORT_KEY);

      let initConditionArgs: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .initConditionArgs);
      when(initConditionArgs)(addParams)
        .afterReturn(new Promise<dataSharePredicates.DataSharePredicates>(resolve => resolve(conditionArgs)));

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addAlphabetIndexObj);

      ContactRepository.getInstance().init(context);
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

      ContactAbilityModel.getAllContactWithPhoneNumbers(callback, addParams, context);
    });

    it("ContactAbilityModelTest_getContactById", 0, () => {
      let result = false;
      const contactId: number = 1;

      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findById);
      when(mockFunc)(contactId).afterAction(() => {
        result = true;
      });
      ContactAbilityModel.getContactById(contactId, () => {
      }, context);

      mocker.verify('init', [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getContactById_callback_contact_undefined", 0, () => {
      const contactId: number = -1;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let contactReturnObj: ContactReturnObj = new ContactReturnObj();

      ContactAbilityModel.getContactById(contactId, (res: ContactReturnObj) => {
        expect(JSON.stringify(res)).assertEqual(JSON.stringify(contactReturnObj));
      }, context);
    });

    it("ContactAbilityModelTest_getContactById_callback_contact_not_undefined", 0, () => {
      let result = false;
      const contactId: number = 1;

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealResult);
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);
      ContactRepository.getInstance().init(context);
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

      ContactAbilityModel.getContactById(contactId, (res: ContactReturnObj) => {
        expect(result).assertTrue();
      }, context);
    });

    it('ContactAbilityModelTest_getContactByIdList_context_undefined', 0, () => {
      let contactIdList: Array<string> = ['570977632'];
      ContactAbilityModel.getContactByIdList(contactIdList, () => {
      }, undefined);
      expect(ContactAbilityModel.str).assertEqual('')
    })

    it('ContactAbilityModelTest_getContactByIdList', 0, () => {
      let contactIdList: Array<string> = [];
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findListById))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });
      ContactAbilityModel.getContactByIdList(contactIdList, () => {
      }, context);
      expect(result).assertTrue();
    })

    it('ContactAbilityModelTest_getContactByIdList_callback_contactList_empty', 0, () => {
      let contactIdList: Array<string> = [];
      ContactRepository.getInstance().init(context);
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

      ContactAbilityModel.getContactByIdList(contactIdList, (resultList: FavoriteBean[]) => {
        expect(result).assertTrue();
      }, context);
    })

    it('ContactAbilityModelTest_getContactByIdList_callback_contactList_not_empty', 0, () => {
      let contactIdList: Array<string> = [];
      ContactRepository.getInstance().init(context);
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

      ContactAbilityModel.getContactByIdList(contactIdList, () => {
        expect(result).assertTrue();
      }, context);
    })

    it("ContactAbilityModelTest_getContactMeeTimeAbilityById", 0, () => {
      let result = false;
      const contactId: number = 1;

      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findContactMeeTimeAbilityById);
      when(mockFunc)(contactId).afterAction(() => {
        result = true;
      })

      ContactAbilityModel.getContactMeeTimeAbilityById(contactId, () => {
      }, context);

      mocker.verify('init', [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getContactMeeTimeAbilityById_callback_contact_undefined", 0, () => {
      let result = false;
      let contactId: number = 1;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            result = true;
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
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.getContactMeeTimeAbilityById(contactId, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getContactMeeTimeAbilityById_callback_contact_not_undefined", 0, () => {
      let result = false;
      let contactId: number = 1;

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealResult);
      ContactRepository.getInstance().init(context);
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

      ContactAbilityModel.getContactMeeTimeAbilityById(contactId, () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_updateMeeTimeAbilityPhoneNumber_01", 0, () => {
      let phone1: PhoneNumBean = new PhoneNumBean("", "", "", "", "");
      phone1.meeTimeAbilityFlag = '1';
      phone1.num = '1';

      let phone2: PhoneNumBean = new PhoneNumBean("", "", "", "", "");
      phone2.meeTimeAbilityFlag = '2';
      phone2.num = '2';
      let contactDetailInfo: RichContactInfo = new RichContactInfo('id');
      contactDetailInfo.meeTimeAbilityInfoModel.extra4 = 1;
      contactDetailInfo.phones = [phone1, phone2];

      ContactAbilityModel.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);

      expect(ContactAbilityModel.result_dt).assertTrue();
    });

    it("ContactAbilityModelTest_updateMeeTimeAbilityPhoneNumber_02", 0, () => {
      let phoneNumBean: PhoneNumBean = new PhoneNumBean("", "num", "", "", "");
      let contactDetailInfo: RichContactInfo = new RichContactInfo('id');
      contactDetailInfo.meeTimeAbilityInfoModel.extra4 = 1;
      contactDetailInfo.phones = [phoneNumBean];

      ContactAbilityModel.updateMeeTimeAbilityPhoneNumber(contactDetailInfo);

      expect(ContactAbilityModel.result_dt).assertTrue();
    });

    it("ContactAbilityModelTest_dealResult_01", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      // const mockerFun1: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // when(mockerFun1)('detail_info').afterReturn('detail_info');
      // const mockerFun2: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // when(mockerFun2)('extend7').afterReturn('extend7');
      // const mockerFun3: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // when(mockerFun3)('phonetic_name').afterReturn('phonetic_name');
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(6);
      mocker.mockFunc(dataItem, dataItem.getData);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      expect(contactDetailInfo.display_name).assertUndefined();
      mocker.clear(dataItem);
    });

    it("ContactAbilityModelTest_dealResult_02_01", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const phoneElement: PhoneNumBean = new PhoneNumBean(dataItem.getLabelId() as string, dataItem.getData() as string,
        dataItem.getLabelName() as string, '', '', dataItem.getSuperPrimary() == '1', Number(dataItem.getId()));
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(5);
      mocker.mockFunc(contactDetailInfo.phones, contactDetailInfo.phones.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [phoneElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.phones);
    });

    it("ContactAbilityModelTest_dealResult_03", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const emailElement: EmailBean =
        new EmailBean(dataItem.getLabelId() as string, dataItem.getData() as string, dataItem.getLabelName() as string);
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(1);
      mocker.mockFunc(contactDetailInfo.emails, contactDetailInfo.emails.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [emailElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.emails);
    });

    it("ContactAbilityModelTest_dealResult_04", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(10);
      mocker.mockFunc(dataItem, dataItem.getData);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("get", [Data.TYPE_ID]).once();
      mocker.clear(dataItem.values);
    });

    it("ContactAbilityModelTest_dealResult_05", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(4);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("get", [Data.TYPE_ID]).once();
      mocker.clear(dataItem.values);
    });

    it("ContactAbilityModelTest_dealResult_06", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const aimElement: AIMBean = new AIMBean('', dataItem.getLabelId() as string, dataItem.getLabelName() as string, dataItem.getData() as string);
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(2);
      mocker.mockFunc(contactDetailInfo.aims, contactDetailInfo.aims.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [aimElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.aims);
    });

    it("ContactAbilityModelTest_dealResult_07", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const houseElement: HouseBean =
        new HouseBean('', dataItem.getLabelId() as string, dataItem.getLabelName() as string,
          dataItem.getData() as string);
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(7);
      mocker.mockFunc(contactDetailInfo.houses, contactDetailInfo.houses.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [houseElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.houses);
    });

    it("ContactAbilityModelTest_dealResult_08", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // DataItemType.NICKNAME
      when(mockerFun)(Data.TYPE_ID).afterReturn(3);
      mocker.mockFunc(dataItem, dataItem.getData);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("get", [Data.TYPE_ID]).once();
      mocker.clear(dataItem.values);
      mocker.clear(dataItem);
    });

    it("ContactAbilityModelTest_dealResult_09", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const eventElement: EventBean =
        new EventBean(dataItem.getLabelId() as string, dataItem.getData() as string, dataItem.getLabelName() as string,
          '');
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // DataItemType.EVENT
      when(mockerFun)(Data.TYPE_ID).afterReturn(11);
      mocker.mockFunc(contactDetailInfo.events, contactDetailInfo.events.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [eventElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.events);
    });

    it("ContactAbilityModelTest_dealResult_10", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      let websiteElement = dataItem.getData();
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // DataItemType.WEBSITE
      when(mockerFun)(Data.TYPE_ID).afterReturn(12);
      mocker.mockFunc(contactDetailInfo.websites, contactDetailInfo.websites.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [websiteElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.websites);
    });

    it("ContactAbilityModelTest_dealResult_11", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const relationElement: AssociatedPersonBean =
        new AssociatedPersonBean(dataItem.getLabelId() as string, '', dataItem.getData() as string,
          dataItem.getLabelName() as string);
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // DataItemType.RELATION
      when(mockerFun)(Data.TYPE_ID).afterReturn(13);
      mocker.mockFunc(contactDetailInfo.relationships, contactDetailInfo.relationships.push);
      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);
      mocker.verify("push", [relationElement]).once();
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.relationships);
    });

    it("ContactAbilityModelTest_dealResult_12", 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const meeTimeDeviceInfoModel: MeeTimeDeviceInfoModel[] =
        [new MeeTimeDeviceInfoModel(dataItem.getExtend4(), Number.parseInt(dataItem.getExtend1()))];

      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      // DataItemType.HI_CALL_DEVICE
      when(mockerFun)(Data.TYPE_ID).afterReturn(15);

      ContactAbilityModel.dealResult(dataItem, contactDetailInfo);

      expect(JSON.stringify(meeTimeDeviceInfoModel))
        .assertEqual(JSON.stringify([{"comId":"","deviceType":null,"profile":""}]));
      mocker.clear(dataItem.values);
    });

    it("ContactAbilityModelTest_setPrimary", 0, () => {
      const contactId: ValueType = '';
      const dataType: ValueType = '';
      const dataId: ValueType = '';
      const primary: boolean = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().setPrimary);

      ContactAbilityModel.setPrimary(contactId, dataType, dataId, primary);

      mocker.verify("setPrimary", [contactId, dataType, dataId, primary]).once();
    });

    it('ContactAbilityModelTest_updateContact_dahelper_null', 0, () => {
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', new Uint8Array()
      );

      ContactAbilityModel.updateContact(null, addParams, addParams, false, () => {
      }, false, context);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.updateContact(null, addParams, addParams, false, () => {
      }, false, context);
      mocker.verify('i', [TAG, 'Start to update contacts.']).never();
      mocker.clear(HiLog);
    })

    it("ContactAbilityModelTest_updateContact", 0, async () => {
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', new Uint8Array()
      );
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(-1)),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;
      let result = false;
      let dealParamFun: Function = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(dealParamFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.updateContact(DAHelper as dataShare.DataShareHelper,  addParams, addParams, false, () => {
      }, false, context);
      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_updateContact_photo_null", 0, async () => {
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', null
      );

      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(-1)),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      let result = false;
      let dealParamFun: Function = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(dealParamFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.updateContact(DAHelper, addParams,addParams, false, () => {
        expect(result).assertFalse();
      }, false, context);
    });

    it("ContactAbilityModelTest_updateContact_businessError", 0, async () => {
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', new Uint8Array()
      );

      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1)),
        batchInsert: (uri: string, values: ValuesBucket[]) => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      await ContactAbilityModel.updateContact(DAHelper,addParams, addParams, false, (id: string) => {
      }, false, context);
      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_updateContact_businessError2", 0, async () => {
      let addParams: ContactInfo = new ContactInfo('1', 'roxy', 'roxy',
        [new PhoneNumBean('', '570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy@ohos.com', '')],
        'position1',
        'company1',
        'remarks1',
        [new AIMBean('1', '', '', '')],
        [new HouseBean('1', '', '', '')],
        ['www.xxxx.com'],
        [new AssociatedPersonBean('1', '2', 'person', 'name')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '', '', '', new Uint8Array()
      );
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1)),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;
      let result = false;
      let dealParamFun: Function = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(dealParamFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });

      await ContactAbilityModel.updateContact(DAHelper as dataShare.DataShareHelper, addParams, addParams, false, () => {
      }, false, context);
      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_distinctForPhoneNum", 0, () => {
      let contactInfoMap: HashMap<string, ValuesBucket[]> = new HashMap();
      contactInfoMap.set('1', [
        {
          'type_id': 5,
          'detail_info': 'buket1 detail'
        }
      ]);

      contactInfoMap.set('2', [
        {
          'type_id': 5,
          'detail_info': 'buket2 detail'
        }
      ]);

      let result: ValuesBucket[] = ContactAbilityModel.distinctForPhoneNum('1', contactInfoMap);
      expect(JSON.stringify(result)).assertEqual('[{"type_id":5,"detail_info":"buket2 detail"}]');
    })

    it("ContactAbilityModelTest_distinctForPhoneNum_phoneSet", 0, () => {
      let contactInfoMap: HashMap<string, ValuesBucket[]> = new HashMap();
      contactInfoMap.set('1', [
        {
          'type_id': 5,
          'detail_info': 'buket1 detail'
        }
      ]);
      contactInfoMap.set('2', [
        {
          'type_id': 5,
          'detail_info': 'buket1 detail'
        }
      ]);

      let result: ValuesBucket[] = ContactAbilityModel.distinctForPhoneNum('1', contactInfoMap);
      expect(JSON.stringify(result)).assertEqual('[]');
    })

    /*it("ContactAbilityModelTest_getIdByTelephone_number_length_9", 0, async () => {
      await ContactAbilityModel.getIdByTelephone('570977632', -1, (data: Boolean) => {
        expect(data).not().assertEqual(undefined);
      }, context);
    });*/

    it("ContactAbilityModelTest_getIdByTelephone_number_length_6", 0, async () => {
      ContactAbilityModel.getIdByTelephone('666666', -1, (data: Boolean) => {
        expect(data).not().assertEqual(undefined);
      }, context);
    });

    it("ContactAbilityModelTest_getIdByTelephone_number_empty", 0, async () => {
      ContactAbilityModel.getIdByTelephone('', -1, (data: Boolean) => {
        expect(data).not().assertEqual(undefined);
      }, context);
    });

    it("ContactAbilityModelTest_isHasContactByPhoneNumAndDisplayName", 0, async () => {
      ContactAbilityModel.isHasContactByPhoneNumAndDisplayName([], '', (data: Boolean) => {
        expect(data).not().assertEqual(undefined);
      }, context);
    });

    it("ContactAbilityModelTest_updateFavorite", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new Promise<number>(resolve => resolve(-1))
      } as dataShare.DataShareHelper;
      const addParams: Record<string, string | number> = {
        'favorite': 'favorite'
      };
      await ContactAbilityModel.updateFavorite(DAHelper as dataShare.DataShareHelper, addParams, (data: string) => {
        expect(data).assertEqual('favorite');
      }, context);
    });

    it("ContactAbilityModelTest_updateFavorite_businessError", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
        new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;
      const addParams: Record<string, string | number> = {
        'favorite': 'favorite'
      };
      await ContactAbilityModel.updateFavorite(DAHelper as dataShare.DataShareHelper, addParams, (data: string) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_updateFavoriteList_true", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          return new Promise<number>(resolve => resolve(-1));
        }
      } as dataShare.DataShareHelper;
      const favoriteList: LooseObject = {
        'length': 3,
        '0': 'contact_id',
        '1': 'contact_id',
        '2': 'contact_id'
      };
      await ContactAbilityModel.updateFavoriteList(DAHelper as dataShare.DataShareHelper, favoriteList, true, 0, (data?: string) => {
        result = true;
      }, context);
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_updateFavoriteList_true_businessError", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;
      const favoriteList: LooseObject = {
        'length': 3,
        '0': 'contact_id',
        '1': 'contact_id',
        '2': 'contact_id'
      };
      await ContactAbilityModel.updateFavoriteList(DAHelper as dataShare.DataShareHelper, favoriteList, true, 0, (data?: string) => {
        result = true;
      }, context);
      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_updateFavoriteList_false", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          return new Promise<number>(resolve => resolve(-1))
        }
      } as dataShare.DataShareHelper;
      const favoriteList: LooseObject = {
        'length': 2,
        '0': {
          contactId: 'contact_id'
        },
        '1': {
          contactId: 'contact_id'
        },
        '2': {
          contactId: 'contact_id'
        }
      };
      await ContactAbilityModel.updateFavoriteList(DAHelper as dataShare.DataShareHelper, favoriteList, false, 0, (data?: string) => {
        result = true;
      }, context);

      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_updateFavoriteList_businessError", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;
      const favoriteList: LooseObject = {
        'length': 2,
        '0': {
          contactId: 'contact_id'
        },
        '1': {
          contactId: 'contact_id'
        },
        '2': {
          contactId: 'contact_id'
        }
      };
      await ContactAbilityModel.updateFavoriteList(DAHelper as dataShare.DataShareHelper, favoriteList, false, 0, (data?: string) => {
        result = true;
      }, context);
      expect(result).assertFalse();
    });

    /*it("ContactAbilityModelTest_updateFavoriteList_dahelper_null", 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      await ContactAbilityModel.updateFavoriteList(null, [], true, 0, (data?: string) => {
      }, context);
      mocker.verify('i', [TAG, 'updateFavoriteList start.']).never();
      mocker.clear(HiLog);
    });*/

    it("ContactAbilityModelTest_getFavoriteByIndex_context_null", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findFavoriteByIndex);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.getFavoriteByIndex({}, 3, () => {
      });

      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_getFavoriteByIndex", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findFavoriteByIndex);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getFavoriteByIndex({}, 3, () => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getFavoriteByIndex_callback_favoriteList_empty", 0, async () => {
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getFavoriteByIndex({}, 3, (resultList: FavoriteBean[]) => {
        expect(resultList.length).assertEqual(0);
      }, context);
    });

    it("ContactAbilityModelTest_getFavoriteByIndex_callback_favoriteList_not_empty", 0, async () => {
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => {
                if (columnIndex === 0) {
                  return 'phone';
                } else {
                  return 'xxx';
                }
              },
              getColumnIndex: (columnName: string): number => columnName === 'content_type' ? 0 : 1,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getFavoriteByIndex({}, 3, (resultList: FavoriteBean[]) => {
        expect(resultList.length).assertEqual(1);
      }, context);
    });

    it("ContactAbilityModelTest_updateUsuallyList", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          return new Promise<number>(resolve => resolve(-1))
        }
      } as dataShare.DataShareHelper;
      await ContactAbilityModel.updateUsuallyList(DAHelper as dataShare.DataShareHelper, [], (data?: string) => {
        expect(data).assertEqual(undefined);
      }, context);
    });

    it("ContactAbilityModelTest_updateUsuallyList_businessError", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;

      let result = false;
      await ContactAbilityModel.updateUsuallyList(DAHelper as dataShare.DataShareHelper, [], (data?: string) => {
        result = true;
      }, context);
      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_getAllFavorite", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAllFavorite);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getAllFavorite(() => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllFavorite_callback1", 0, async () => {
      let result = false;

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
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)))
      await ContactAbilityModel.getAllFavorite((rst: FavoriteBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getAllFavorite_callback2", 0, async () => {
      let result = false;

      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)))
      await ContactAbilityModel.getAllFavorite((rst: FavoriteBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getAllUsually", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAllUsually);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getAllUsually(() => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllUsually_callback_callLog_empty", 0, async () => {
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(0);
        ;
      }, context);
    });

    it("ContactAbilityModelTest_getAllUsually_callback_callLog_notEmpty", 0, async () => {
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getAllUsually((rst: CallLog[]) => {
        expect(rst.length).assertEqual(1);
      }, context);
    });

    it("ContactAbilityModelTest_getAllUsuallyByRawContact", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAllUsuallyByRawContact);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getAllUsuallyByRawContact(() => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllUsuallyByRawContact_callback1", 0, async () => {
      let result = false;

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
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.getAllUsuallyByRawContact((rst: FavoriteBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getAllUsuallyByRawContact_callback2", 0, async () => {
      let result = false;

      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.getAllUsuallyByRawContact((rst: FavoriteBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getDisplayNamesFindUsually", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .getDisplayNameByFavorite);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getDisplayNamesFindUsually([], [], () => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getDisplayNamesFindUsually_callback1", 0, async () => {
      let result = false;

      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getDisplayNamesFindUsually([], [], () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getDisplayNamesFindUsually_callback2", 0, async () => {
      let result = false;

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
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getDisplayNamesFindUsually([], [], () => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_moveSortFavorite", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          return new Promise<number>(resolve => resolve(-1));
        }
      } as dataShare.DataShareHelper;
      let addParams: LooseObject = {};
      await ContactAbilityModel.moveSortFavorite(DAHelper as dataShare.DataShareHelper, addParams, (data: string) => {
        expect(data).assertEqual('');
      }, context);
    });

    it("ContactAbilityModelTest_moveSortFavorite_02", 0, async () => {
      let addParams: LooseObject = {
        favoriteOrder: 'favoriteOrder'
      };
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          return new Promise<number>(resolve => resolve(0));
        }
      } as dataShare.DataShareHelper;
      await ContactAbilityModel.moveSortFavorite(DAHelper as dataShare.DataShareHelper, addParams, (data: string) => {
        expect(data).assertEqual('favoriteOrder');
      }, context);
    });

    it("ContactAbilityModelTest_moveSortFavorite_businessError", 0, async () => {
      let addParams: LooseObject = {
        favoriteOrder: 'favoriteOrder'
      };
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(
          (resolve: (value: number | PromiseLike<number>) => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as dataShare.DataShareHelper;
      await ContactAbilityModel.moveSortFavorite(DAHelper as dataShare.DataShareHelper, addParams, (data: string) => {
      }, context);
      expect(result).assertTrue();
    });

    /*it("ContactAbilityModelTest_moveSortFavorite_dahelper_null", 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ContactAbilityModel.moveSortFavorite(null, {}, (data: string) => {
      }, context);
      mocker.verify('i', [TAG, 'moveSortFavorite start.']).once();
      mocker.clear(HiLog);
    });*/

    it("ContactAbilityModelTest_getSearchContact", 0, async () => {
      let result = false;
      const addParams: IContactSearchParams = {
        value: '',
        loopRequest: false,
        startIndex: 0,
        limitNumber: 0
      };
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .searchContact);
      when(mockFunc)(addParams).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getSearchContact(addParams, () => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getSearchContact_callback1", 0, async () => {
      let result = false;
      const addParams: IContactSearchParams = {
        value: 'contact1',
        loopRequest: false,
        startIndex: 0,
        limitNumber: 0
      };
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.getSearchContact(addParams, (contactList: ContactSearchResultData) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getSearchContact_callback2", 0, async () => {
      let result = false;
      const addParams: IContactSearchParams = {
        value: 'contact1',
        loopRequest: false,
        startIndex: 0,
        limitNumber: 0
      };

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
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.getSearchContact(addParams, (contactList: ContactSearchResultData) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getQueryT9PhoneNumbers", 0, () => {
      let result = false;
      const addParams: IT9PhoneNumbersQueryParams = {
        favorite: {
          'teleNumber': ''
        }
      };
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryT9PhoneIsNotNull);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      ContactAbilityModel.getQueryT9PhoneNumbers(() => {
      }, addParams, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getQueryT9PhoneNumbers_callback_emptyResult", 0, () => {
      const addParams: IT9PhoneNumbersQueryParams = {
        favorite: {
          'teleNumber': '570977632'
        }
      };

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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.getQueryT9PhoneNumbers((res: ContactVo[]) => {
        expect(res.length).assertEqual(0);
      }, addParams, context);
    });

    it("ContactAbilityModelTest_getQueryT9PhoneNumbers_callback_resultList", 0, () => {
      const addParams: IT9PhoneNumbersQueryParams = {
        favorite: {
          'teleNumber': '570977632'
        }
      };

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
              getLong: (columnIndex: number): number => 0,
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      ContactAbilityModel.getQueryT9PhoneNumbers((res: ContactVo[]) => {
        expect(res.length).assertEqual(1);
      }, addParams, context);
    });

    it('ContactAbilityModelTest_addGroup_name_empty', 0, async () => {
      let result = false;
      await ContactAbilityModel.addGroup('', '1').then(() => {
        result = true;
      });
      expect(result).assertTrue();
    })

    // it('ContactAbilityModelTest_addGroup', 0, async () => {
    //   let result = false;
    //
    //   await ContactAbilityModel.addGroup('group1', '1', () => {
    //   }, context).then(() => {
    //     result = true;
    //   });
    //   expect(result).assertTrue();
    // })

    it("ContactAbilityModelTest_getAllGroup", 0, async () => {
      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockFunc: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .findAllGroup);
      when(mockFunc)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });
      await ContactAbilityModel.getAllGroup(() => {
      }, context);

      mocker.verify("init", [context]).once();
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_getAllGroup_callback1", 0, async () => {
      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0,
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getAllGroup((res: GroupBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it("ContactAbilityModelTest_getAllGroup_callback2", 0, async () => {
      let result = false;
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
                result = true;
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0,
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.getAllGroup((res: GroupBean[]) => {
        expect(result).assertTrue();
      }, context);
    });

    it('ContactAbilityModelTest_changeGroupListItemToGroupBeanList', 0, () => {
      let listItem: GroupListItem[] = [new GroupListItem({
        getLong: (columnIndex: number) => 1,
        getColumnIndex: (columnName: string) => 0,
        getString: (columnIndex: number) => 'xx'
      } as DataShareResultSet)];
      let result: GroupBean[] = ContactAbilityModel.changeGroupListItemToGroupBeanList(listItem);
      expect(JSON.stringify(result))
        .assertEqual('[{"groupId":"","groupType":"","pickerData":{"title":""},"id":1,"accountId":"xx","groupName":"xx","groupNotes":"xx","isDeleted":"xx","groupRingtone":"xx","ringtoneModifyTime":1,"lastestModifyTime":1}]');
    });

    it("ContactAbilityModelTest_renameGroup_callback", 0, async () => {
      let result = false;
      const groupParams: GroupParams = {
        groupName: ''
      };

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.renameGroup(groupParams, (result: number) => {
        expect(result).assertEqual(undefined);
      }, context);
    });

    it("ContactAbilityModelTest_removeGroup_callback", 0, async () => {
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.removeGroup(-1, (res: number) => {
        expect(res).assertUndefined();
      }, context);
    });

    it("ContactAbilityModelTest_deleteGroupsById_callback", 0, async () => {
      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.deleteGroupsById([], (res: number) => {
        result = true;
      }, context);
      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_queryGroupItemByName_callback1", 0, async () => {
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            close: () => {
            },
            goToFirstRow: () => false,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0,
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));
      let rst: GroupBean = new GroupBean(-1, '', '', '', '', '', 0, 0);

      await ContactAbilityModel.queryGroupItemByName('addParams', (result: GroupBean) => {
        expect(result.id).assertEqual(-1);
      }, context);
    });

    it("ContactAbilityModelTest_queryGroupItemByName_callback2", 0, async () => {
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => false,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0,
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.queryGroupItemByName('group', (result: GroupBean) => {
        expect(result.id).assertEqual(0);
      }, context);
    });

    it("ContactAbilityModelTest_updateGroupMemberList", 0, async () => {
      let mocker: MockKit = new MockKit();
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
      mocker.mockFunc(HiLog, HiLog.i);
      await ContactAbilityModel.updateGroupMemberList([], 'group1', () => {
      }, context);
      mocker.verify('i', [TAG, 'updateGroupMemberList start.']).once();
      mocker.clear(HiLog);
      mocker.clear(ContactRepository.getInstance().init(context));
    });

    it("ContactAbilityModelTest_queryAllGroupMember_callback1", 0, async () => {
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => false,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0,
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.queryAllGroupMember('addParams', (result: ContactVo[]) => {
        expect(result[0].nameSuffix).assertEqual('xxx');
      }, context);
    });

    it("ContactAbilityModelTest_queryAllGroupMember_callback2", 0, async () => {
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
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
              goToFirstRow: () => false,
              goToNextRow: () => false
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.queryAllGroupMember('addParams', (resultList: ContactVo[]) => {
        expect(JSON.stringify(resultList)).assertEqual('[]');
      }, context);
    });

    it("ContactAbilityModelTest_updateContactOrganizationInfo", 0, async () => {
      let result = false;
      await ContactAbilityModel.updateContactOrganizationInfo([], '', () => {}, context);

      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .updateOrganizationToContact);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.updateContactOrganizationInfo([1,2,3], '', (res: boolean) => {
        result = res;
      }, context);
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_intelligenceGroupQueryContactsForSendMsgByOrganization", 0, async () => {
      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByOrganization((res: object[]) => {
        expect(res.length).assertEqual(0);
      }, '', undefined);

      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryContactsByOriganizationForSendMsg);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByOrganization(() => {}, '', context);
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_intelligenceGroupQueryContactsForSendMsgByCity", 0, async () => {
      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByCity((res: object[]) => {
        expect(res.length).assertEqual(0);
      }, '', undefined);

      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryContactsByCityForSendMsg);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByCity(() => {}, '', context);
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_intelligenceGroupQueryContactsForSendMsgByTimestamp", 0, async () => {
      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByTimestamp((res: object[]) => {
        expect(res.length).assertEqual(0);
      }, '', undefined);

      let result = false;
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);
      let mockerFun: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .queryContactsByTimestampForSendMsg);
      when(mockerFun)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })

      await ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByTimestamp(() => {}, '', context);
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    });

    it("ContactAbilityModelTest_findMemberByPhoneIsNotNull_callback_memberList_empty", 0, async () => {
      const context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let repo: ContactRepository = ContactRepository.getInstance();
      when(mocker.mockFunc(repo, repo.getDataAbilityHelper))()
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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0,
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.findMemberByPhoneIsNotNull(1, (rst: ContactVo[]) => {
        expect(rst.length).assertEqual(0);
      }, context);
      mocker.clear(repo);
    });

    it("ContactAbilityModelTest_findMemberByPhoneIsNotNull_callback_memberList_notEmpty", 0, async () => {
      ContactRepository.getInstance().init(context);

      let repo: ContactRepository = ContactRepository.getInstance();
      when(mocker.mockFunc(repo, repo.getDataAbilityHelper))()
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
              getColumnIndex: (columnName: string): number => columnName === 'contact_id' ? 0 : 1,
              getLong: (columnIndex: number): number => 0,
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      await ContactAbilityModel.findMemberByPhoneIsNotNull(1, (rst: ContactVo[]) => {
        expect(rst.length).assertEqual(0);
      }, context);
      mocker.clear(repo);
    });

    it("ContactAbilityModelTest_deleteMemberByGroupId_callback", 0, async () => {
      ContactRepository.getInstance().init(context);

      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      await ContactAbilityModel.deleteMemberByGroupId('id', (result: number | boolean) => {
        expect(result).assertEqual(1);
      }, context);
    })

    it("ContactAbilityModelTest_deleteMembers_callback", 0, async () => {
      ContactRepository.getInstance().init(context);
      await ContactAbilityModel.deleteMembers('groupId', [], (result: number) => {
        expect(result).assertUndefined();
      }, context);
    });

    it('ContactAbilityModelTest_activateRestore', 0, () => {
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init))(context)
        .afterAction(() => {
          result = true;
        });
      ContactAbilityModel.activateRestore(context);
      expect(result).assertTrue();
    });

    it('ContactAbilityModelTest_activateRestore_context_undefined', 0, async () => {
      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().activateRestore))()
        .afterAction(() => {
          result = true;
        });
      ContactAbilityModel.activateRestore(undefined);
      expect(result).assertTrue();
    });

    it('ContactAbilityModelTest_copyContact', 0, async () => {
      let copyList: LooseObject[] = [{
        'name': 'roxy',
        'contactId': '1'
      }]
      let result = false;

      ContactAbilityModel.copyContact(copyList, context, 1, (param: number) => {
      }).then(() => {
        result = true;
      });
      expect(ContactAbilityModel.result_dt).assertTrue();
    });

    it("ContactAbilityModelTest_setContactData_if1", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '123456';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 6;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);

      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);

      mocker.verify('goToFirstRow', []).once();
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_setContactData_if2", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '123456';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 5;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);

      let vbs: ValuesBucket[] = [];

      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);

      mocker.verify('goToFirstRow', []).once();
      expect(JSON.stringify(vbs)).assertEqual(JSON.stringify(result));
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_setContactData_if3", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 3;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);

      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);
      mocker.verify('goToFirstRow', []).once();
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_setContactData_if3_2", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '2';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 3;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);
      let vbs: ValuesBucket[] = [];
      let contactData: ValuesBucket = {}
      contactData.type_id = getLongData;
      contactData.raw_contact_id = 0;
      contactData.read_only = getLongData;
      contactData.version = getLongData;
      contactData.is_preferred_number = getLongData;
      contactData.detail_info = getStringData;
      contactData.family_name = getStringData;
      contactData.middle_name_phonetic = getStringData;
      contactData.given_name = getStringData;
      contactData.given_name_phonetic = getStringData;
      contactData.alias_detail_info = getStringData;
      contactData.phonetic_name = getStringData;
      contactData.position = getStringData;
      contactData.extend1 = getStringData;
      contactData.extend2 = getStringData;
      contactData.extend3 = getStringData;
      contactData.extend4 = getStringData;
      contactData.city = getStringData;
      contactData.country = getStringData;
      contactData.neighborhood = getStringData;
      contactData.pobox = getStringData;
      contactData.postcode = getStringData;
      contactData.region = getStringData;
      contactData.street = getStringData;
      contactData.alpha_name = getStringData;
      contactData.other_lan_last_name = getStringData;
      contactData.other_lan_first_name = getStringData;
      contactData.extend5 = getStringData;
      contactData.lan_style = getStringData;
      contactData.custom_data = getStringData;
      contactData.extend6 = getStringData;
      contactData.extend7 = getStringData;
      contactData.blob_data = null;
      contactData.syn_1 = getStringData;
      contactData.syn_2 = getStringData;
      contactData.syn_3 = getStringData;
      contactData.extend8 = getStringData;
      contactData.extend9 = getStringData;
      contactData.extend10 = getStringData;
      contactData.extend11 = getStringData;
      vbs.push(contactData);

      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);
      mocker.verify('goToFirstRow', []).once();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(vbs));
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_setContactData_if4", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 4;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);
      ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);
      mocker.verify('goToFirstRow', []).once();
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_setContactData_if4_2", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '2';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 4;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);

      let vbs: ValuesBucket[] = [];
      let contactData: ValuesBucket = {}
      contactData.type_id = getLongData;
      contactData.raw_contact_id = 0;
      contactData.read_only = getLongData;
      contactData.version = getLongData;
      contactData.is_preferred_number = getLongData;
      contactData.detail_info = getStringData;
      contactData.family_name = getStringData;
      contactData.middle_name_phonetic = getStringData;
      contactData.given_name = getStringData;
      contactData.given_name_phonetic = getStringData;
      contactData.alias_detail_info = getStringData;
      contactData.phonetic_name = getStringData;
      contactData.position = getStringData;
      contactData.extend1 = getStringData;
      contactData.extend2 = getStringData;
      contactData.extend3 = getStringData;
      contactData.extend4 = getStringData;
      contactData.city = getStringData;
      contactData.country = getStringData;
      contactData.neighborhood = getStringData;
      contactData.pobox = getStringData;
      contactData.postcode = getStringData;
      contactData.region = getStringData;
      contactData.street = getStringData;
      contactData.alpha_name = getStringData;
      contactData.other_lan_last_name = getStringData;
      contactData.other_lan_first_name = getStringData;
      contactData.extend5 = getStringData;
      contactData.lan_style = getStringData;
      contactData.custom_data = getStringData;
      contactData.extend6 = getStringData;
      contactData.extend7 = getStringData;
      contactData.blob_data = null;
      contactData.syn_1 = getStringData;
      contactData.syn_2 = getStringData;
      contactData.syn_3 = getStringData;
      contactData.extend8 = getStringData;
      contactData.extend9 = getStringData;
      contactData.extend10 = getStringData;
      contactData.extend11 = getStringData;
      vbs.push(contactData);
      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);
      mocker.verify('goToFirstRow', []).once();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(vbs));
    });

    it("ContactAbilityModelTest_setContactData_if5", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '123456';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 1;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);
      ContactAbilityModel.setContactData(DAResultSet, 1, 1, true, true);
      mocker.verify('goToFirstRow', []).once();
      mocker.clear(DAResultSet);

    });

    it("ContactAbilityModelTest_setContactData_if6", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '123456';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 1;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);
      ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);
      mocker.verify('goToFirstRow', []).once();
      mocker.clear(DAResultSet);

    });

    it("ContactAbilityModelTest_setContactData_noIf_blob_null", 0, () => {
      let DAResultSet: DataShareResultSet = {
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
      mocker.mockFunc(DAResultSet, DAResultSet.goToFirstRow);

      let goToNextRowMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.goToNextRow);
      when(goToNextRowMockFunc)(ArgumentMatchers.any).afterReturn(false);

      let getColumnIndexMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getColumnIndex);
      when(getColumnIndexMockFunc)(ArgumentMatchers.any).afterReturn(1);

      let getStringMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getString);
      const getStringData = '123456';
      when(getStringMockFunc)(1).afterReturn(getStringData);

      let getLongMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getLong);
      const getLongData = 123;
      when(getLongMockFunc)(1).afterReturn(getLongData);

      let getBlobMockFunc: Function = mocker.mockFunc(DAResultSet, DAResultSet.getBlob);
      when(getBlobMockFunc)(1).afterReturn(null);

      let vbs: ValuesBucket[] = [];
      let contactData: ValuesBucket = {}
      contactData.type_id = getLongData;
      contactData.raw_contact_id = 0;
      contactData.read_only = getLongData;
      contactData.version = getLongData;
      contactData.is_preferred_number = getLongData;
      contactData.detail_info = getStringData;
      contactData.family_name = getStringData;
      contactData.middle_name_phonetic = getStringData;
      contactData.given_name = getStringData;
      contactData.given_name_phonetic = getStringData;
      contactData.alias_detail_info = getStringData;
      contactData.phonetic_name = getStringData;
      contactData.position = getStringData;
      contactData.extend1 = getStringData;
      contactData.extend2 = getStringData;
      contactData.extend3 = getStringData;
      contactData.extend4 = getStringData;
      contactData.city = getStringData;
      contactData.country = getStringData;
      contactData.neighborhood = getStringData;
      contactData.pobox = getStringData;
      contactData.postcode = getStringData;
      contactData.region = getStringData;
      contactData.street = getStringData;
      contactData.alpha_name = getStringData;
      contactData.other_lan_last_name = getStringData;
      contactData.other_lan_first_name = getStringData;
      contactData.extend5 = getStringData;
      contactData.lan_style = getStringData;
      contactData.custom_data = getStringData;
      contactData.extend6 = getStringData;
      contactData.extend7 = getStringData;
      contactData.blob_data = null;
      contactData.syn_1 = getStringData;
      contactData.syn_2 = getStringData;
      contactData.syn_3 = getStringData;
      contactData.extend8 = getStringData;
      contactData.extend9 = getStringData;
      contactData.extend10 = getStringData;
      contactData.extend11 = getStringData;
      vbs.push(contactData)

      const result = ContactAbilityModel.setContactData(DAResultSet, 0, 0, true, true);

      mocker.verify('goToFirstRow', []).once();
      expect(JSON.stringify(vbs)).assertEqual(JSON.stringify(result));
      mocker.clear(DAResultSet);
    });

    it("ContactAbilityModelTest_dealContactPhoto", 0, () => {
      const contactId: ValueType = "2";
      const photo: Uint8Array = new Uint8Array();

      dealContactPhoto(contactId, context, photo, true, false, false, 3);

      expect(ContactAbilityModel.str).assertEqual('');
    });

    it('ContactAbilityModelTest_addToMaster_name', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(6);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_phone', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(5);
      mocker.mockFunc(contactDetailInfo.phones, contactDetailInfo.phones.push);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
      mocker.clear(contactDetailInfo.phones);
    })

    it('ContactAbilityModelTest_addToMaster_email', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(1);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_NOTE', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(10);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_ORGANIZATION', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(4);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_IM', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(2);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_STRUCTURED_POSTAL', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(7);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_NICKNAME', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(3);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_EVENT', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(11);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_WEBSITE', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(12);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_RELATION', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(13);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_HI_CALL_DEVICE', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(15);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_GROUP_MEMBERSHIP', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterReturn(9);
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.str).assertEqual('');
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_addToMaster_error', 0, () => {
      const dataItem: DataItem = new DataItem(new Map<string, string | number>());
      const contactDetailInfo: RichContactInfo = new RichContactInfo("");
      const mockerFun: Function = mocker.mockFunc(dataItem.values, dataItem.values.get);
      when(mockerFun)(Data.TYPE_ID).afterThrow('error')
      ContactAbilityModel.addToMaster(dataItem, contactDetailInfo);
      expect(ContactAbilityModel.result_dt).assertTrue();
      mocker.clear(dataItem.values);
    })

    it('ContactAbilityModelTest_getContactIdByRawId', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let rawContactId: number = 1;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      ContactAbilityModel.getContactIdByRawId(rawContactId, () => {}, context);
      mocker.verify('init', [context]).once();
      mocker.clear(ContactRepository.getInstance());
    })

    it('ContactAbilityModelTest_queryLocalRingToneUsedTimes', 0, () => {
      ContactAbilityModel.queryLocalRingToneUsedTimes('1', '1', (value: number) => {
        expect(value).assertEqual(0);
      });
    })

    it('ContactAbilityModelTest_findNewestContact', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      ContactAbilityModel.findNewestContact(() => {}, context);
      mocker.verify('init', [context]).never();
      mocker.clear(ContactRepository.getInstance());
    })

    it('ContactAbilityModelTest_markContactAsPoster', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let ids: string[] = ['1', '2'];

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().init);

      ContactAbilityModel.markContactAsPoster(ids, () => {}, context);
      mocker.verify('init', [context]).never();
      mocker.clear(ContactRepository.getInstance());
    })


    it('ContactAbilityModelTest_handleGroups', 0, () => {
      let groupBean: GroupBean[] = [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')];
      let saveBean: GroupBean[] = [new GroupBean(2, '', 'group2', '', '', '', 1702642674, 1702642672, '2', '')];
      let a = ContactAbilityModel.handleGroups(groupBean, saveBean);
      expect(a.length).assertEqual(1)
    })

    it('ContactAbilityModelTest_handleEvents', 0, () => {
      let groupBean: EventBean[] = [new EventBean('1', '', '', 'even1')];
      let saveBean: EventBean[] = [new EventBean('2', '', '', 'even2')];
      let a = ContactAbilityModel.handleEvents(groupBean, saveBean);
      expect(a.length).assertEqual(1)
    })

    it('ContactAbilityModelTest_handleRelationships', 0, () => {
      let groupBean: AssociatedPersonBean[] = [new AssociatedPersonBean('1', '2', 'person', '')];
      let saveBean: AssociatedPersonBean[] = [new AssociatedPersonBean('2', '3', 'person1', '')];
      let a = ContactAbilityModel.handleRelationships(groupBean, saveBean);
      expect(a.length).assertEqual(1)
    })

    it('ContactAbilityModelTest_handleAddContactInfo', 0, () => {
      let originalInfo: ContactInfo = new ContactInfo('1', 'roxy1', 'roxy1',
        [new PhoneNumBean('', '1570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy1@ohos.com', '')], '1', '1', '1',
        [new AIMBean('1', '1', '1', '1')],
        [new HouseBean('1', '1', '1', '1')],
        ['www.xxxx1.com'],
        [new AssociatedPersonBean('11', '21', 'person1', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '1', '1', '1', null
      );

      let saveContactInfo: ContactInfo = new ContactInfo('2', 'roxy2', 'roxy2',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '2', '2', '2',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '2', '2', '2', null
      );

      let contactBefore: ContactInfo = new ContactInfo('3', 'roxy3', 'roxy3',
        [new PhoneNumBean('', '3570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy3@ohos.com', '')], '3', '3', '3',
        [new AIMBean('3', '3', '3', '3')],
        [new HouseBean('3', '3', '3', '3')],
        ['www.xxxx3.com'],
        [new AssociatedPersonBean('13', '23', 'person3', '')],
        [new EventBean('3', '', '', 'even3')],
        [new GroupBean(3, '', 'group3', '', '', '', 1702642678, 1702642678, '3', '')],
        1, '3', '3', '3', null
      );

      ContactAbilityModel.handleAddContactInfo(originalInfo, saveContactInfo, contactBefore);

      expect(originalInfo.phones.length).assertEqual(2);
      expect(originalInfo.emails.length).assertEqual(2);
      expect(originalInfo.aims.length).assertEqual(2);
      expect(originalInfo.houses.length).assertEqual(2);
      expect(originalInfo.websites.length).assertEqual(2);
      expect(originalInfo.relationships.length).assertEqual(2);
      expect(originalInfo.events.length).assertEqual(2);
      expect(originalInfo.groups.length).assertEqual(2);
      expect(originalInfo.display_name).assertEqual('roxy2');
      expect(originalInfo.nickname).assertEqual('roxy2');
      expect(originalInfo.remarks).assertEqual('2');
      expect(originalInfo.position).assertEqual('2');
      expect(originalInfo.company).assertEqual('2');
      expect(originalInfo.phoneticName).assertEqual('2');
      expect(originalInfo.otherLanLastName).assertEqual('2');
      expect(originalInfo.otherLanFirstName).assertEqual('2');
      expect(originalInfo.favorite).assertEqual(0);

    })

    it('ContactAbilityModelTest_handleDelContactInfo', 0, () => {
      let originalInfo: ContactInfo = new ContactInfo('1', 'roxy1', 'roxy1',
        [new PhoneNumBean('', '1570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy1@ohos.com', '')], '1', '1', '1',
        [new AIMBean('1', '1', '1', '1')],
        [new HouseBean('1', '1', '1', '1')],
        ['www.xxxx1.com'],
        [new AssociatedPersonBean('11', '21', 'person1', '')],
        [new EventBean('1', '', '', 'even1')],
        [new GroupBean(1, '', 'group1', '', '', '', 1702642676, 1702642676, '1', '')],
        1, '1', '1', '1', null
      );

      let saveContactInfo: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let needRemovePhones: PhoneNumBean[] =
        ContactAbilityModel.handlePhones(originalInfo.phones, saveContactInfo.phones);
      let needRemoveEmails: EmailBean[] = ContactAbilityModel.handleEmails(originalInfo.emails, saveContactInfo.emails);
      let needRemoveAims: AIMBean[] = ContactAbilityModel.handleAims(originalInfo.aims, saveContactInfo.aims);
      let needRemoveHouses: HouseBean[] = ContactAbilityModel.handleHouses(originalInfo.houses, saveContactInfo.houses);
      let needRemoveWebsites: string[] =
        ContactAbilityModel.handleWebsites(originalInfo.websites, saveContactInfo.websites);
      let needRemoveRelationships: AssociatedPersonBean[] =
        ContactAbilityModel.handleRelationships(originalInfo.relationships, saveContactInfo.relationships);
      let needRemoveEvents: EventBean[] = ContactAbilityModel.handleEvents(originalInfo.events, saveContactInfo.events);
      let needRemoveGroups: GroupBean[] = ContactAbilityModel.handleGroups(originalInfo.groups, saveContactInfo.groups);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemovePhones);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveEmails);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveAims);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveHouses);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveWebsites);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveRelationships);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveEvents);
      mocker.mockFunc(ContactInfoUtil, ContactInfoUtil.filterRemoveGroups);

      ContactAbilityModel.handleDelContactInfo(originalInfo, saveContactInfo);

      mocker.verify('filterRemovePhones', [originalInfo.phones, needRemovePhones]).never();
      mocker.verify('filterRemoveEmails', [originalInfo.emails, needRemoveEmails]).never();
      mocker.verify('filterRemoveAims', [originalInfo.aims, needRemoveAims]).never();
      mocker.verify('filterRemoveHouses', [originalInfo.houses, needRemoveHouses]).never();
      mocker.verify('filterRemoveWebsites', [originalInfo.websites, needRemoveWebsites]).never();
      mocker.verify('filterRemoveRelationships', [originalInfo.relationships, needRemoveRelationships]).never();
      mocker.verify('filterRemoveEvents', [originalInfo.events, needRemoveEvents]).never();
      mocker.verify('filterRemoveGroups', [originalInfo.groups, needRemoveGroups]).never();

      expect(originalInfo.display_name).assertEqual('roxy222');
      expect(originalInfo.nickname).assertEqual('');
      expect(originalInfo.remarks).assertEqual('');
      expect(originalInfo.position).assertEqual('');
      expect(originalInfo.company).assertEqual('');
      expect(originalInfo.phoneticName).assertEqual('');
      expect(originalInfo.otherLanLastName).assertEqual('');
      expect(originalInfo.otherLanFirstName).assertEqual('');
      expect(originalInfo.favorite).assertEqual(0);

      mocker.clear(ContactInfoUtil);
    })

    it("ContactAbilityModelTest_updateMeetTime_01", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
          result = true;
          resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      await ContactAbilityModel.updateMeetTime(DAHelper, [], false);

      expect(result).assertFalse();
    });

    it("ContactAbilityModelTest_updateMeetTime_02", 0, async () => {
      let result = false;
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
          result = true;
          resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
      } as dataShare.DataShareHelper;

      await ContactAbilityModel.updateMeetTime(DAHelper, ['1'], false);

      expect(result).assertTrue();
    });

    it("ContactAbilityModelTest_updateRawContacts_01", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
            resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => {
            resolve(1)
        })
      } as dataShare.DataShareHelper;

      let contact: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(true)));

      let updateFlag = await ContactAbilityModel.updateRawContacts([contact], DAHelper, false);

      expect(updateFlag).assertTrue();
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_updateRawContacts_02", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
          resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => {
          resolve(-1)
        })
      } as dataShare.DataShareHelper;

      let contact: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(true)));

      let updateFlag = await ContactAbilityModel.updateRawContacts([contact], DAHelper, false);

      expect(updateFlag).assertFalse();
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_filterRawContact_01", 0, () => {

      let contactBefore: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let saveContactInfo: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );
      saveContactInfo.rawContacts = [new RawContact(1, new Map())];

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.handleDelContactInfo);
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.handleAddContactInfo);

      let result = ContactAbilityModel.filterRawContact(contactBefore, saveContactInfo);

      expect(result.length).assertLarger(0)
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_convertRawToContactInfo_01", 0, () => {

      let value: Map<string, string | number> = new Map();
      let rawContact: RawContact = new RawContact(1, value);
      rawContact.dataItems.push(new DataItem(new Map()));

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealResult);
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);

      let contactDetailInfo = ContactAbilityModel.convertRawToContactInfo(rawContact as RawContact, '1', null);

      expect(contactDetailInfo.contactID).assertEqual('1')
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_updateMasterRawContact_01", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
          resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => {
          resolve(1)
        })
      } as dataShare.DataShareHelper;

      let contact: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(true)));

      let updateFlag = await ContactAbilityModel.updateMasterRawContact(contact, DAHelper, false);

      expect(updateFlag).assertTrue();
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_updateMasterRawContact_02", 0, async () => {
      let DAHelper: dataShare.DataShareHelper = {
        update: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => new Promise<number>(resolve => {
          resolve(-1)
        }),
        delete: (uri: string,
          predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => {
          resolve(-1)
        })
      } as dataShare.DataShareHelper;

      let contact: ContactInfo = new ContactInfo('1', 'roxy222', '',
        [new PhoneNumBean('', '2570977632', '', '', '', true, 1)],
        [new EmailBean('', 'roxy2@ohos.com', '')], '', '', '',
        [new AIMBean('2', '2', '2', '2')],
        [new HouseBean('2', '2', '2', '2')],
        ['www.xxxx2.com'],
        [new AssociatedPersonBean('12', '22', 'person2', '')],
        [new EventBean('2', '', '', 'even2')],
        [new GroupBean(2, '', 'group2', '', '', '', 1702642677, 1702642677, '2', '')],
        0, '', '', '', null
      );

      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.dealParam);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(true)));

      let updateFlag = await ContactAbilityModel.updateMasterRawContact(contact, DAHelper, false);

      expect(updateFlag).assertFalse();
      mocker.clear(ContactAbilityModel);
    });

    it("ContactAbilityModelTest_handleSimpleData", 0, () => {
      expect(ContactAbilityModel.handleSimpleData('', '1')).assertFalse();
    });

    it("ContactAbilityModelTest_handleFavorite", 0, () => {
      expect(ContactAbilityModel.handleFavorite(1, 1)).assertFalse();
    });
  })
}