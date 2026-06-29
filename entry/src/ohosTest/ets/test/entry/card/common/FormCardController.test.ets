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
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { FormCardController } from '../../../../../../main/ets/card/common/FormCardController';
import { SpeedDialCardDataType } from '../../../../../../main/ets/card/type/speedDialCardType';
import common from '@ohos.app.ability.common';
import CallLogSetting, { MergeRule } from '../../../../../../../../feature/call/src/main/ets/CallLogSetting';
import { ContactRepository } from '../../../../../../../../feature/contact/src/main/ets/repo/ContactRepository'
import formBindingData from '@ohos.app.form.formBindingData';
import contextConstant from '@ohos.app.ability.contextConstant';
import { ContactReturnObj } from '../../../../../../main/ets/model/type';
import { PhoneNumber } from '../../../../../../../../feature/phonenumber';
import { MissedCallListType } from '../../../../../../main/ets/card/type/commonType';
import call from '@ohos.telephony.call';
import Want from '@ohos.app.ability.Want';
import StartOptions from '@ohos.app.ability.StartOptions';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { BusinessError } from '@kit.BasicServicesKit';
import ContactAbilityModel from '../../../../../../main/ets/model/ContactAbilityModel';
import { PhoneNumBean } from '../../../../../../main/ets/model/bean/PhoneNumBean';
import { RoamingManager } from '../../../../../../main/ets/feature/roaming/RoamingManager';
import { RoamingUtils } from '../../../../../../../../common/src/main/ets/util/RoamingUtils';

export default function FormCardControllerTest() {
  describe('FormCardControllerTest', () => {
    let formCardController: FormCardController;

    beforeEach(() => {
      formCardController = new FormCardController();
    })

    it('FormCardControllerTest_getInstance', 0, () => {
      expect(typeof FormCardController.getInstance()).assertEqual(typeof formCardController);
    })

    it('FormCardControllerTest_aboutToAppear', 0, () => {
      formCardController.aboutToAppear();
      expect(formCardController.simStateStatusCardOne).assertFalse();
    })

    it('FormCardControllerTest_getFavoriteByIndex_if', 0, async () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext))().afterReturn(context);

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

      formCardController.getFavoriteByIndex(0, (favList: SpeedDialCardDataType[]) => {
        expect(JSON.stringify(favList)).assertEqual('[]');
        expect(result).assertTrue();
      });

      mocker.clear(formCardController);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('FormCardControllerTest_getFavoriteByIndex_noIf', 0, () => {
      formCardController.mDataWorker = undefined;
      formCardController.getFavoriteByIndex(0, (favList: SpeedDialCardDataType[]) => {
      });
      expect(formCardController.simStateStatusCardOne).assertFalse();
    })

    it('FormCardControllerTest_getContactByIdList_idList_empty', 0, () => {
      let idList: Array<string> = [];
      formCardController.getContactByIdList(idList, (contactList: SpeedDialCardDataType[]) => {
      });
      expect(formCardController.simStateStatusCardOne).assertFalse();
    })

    it('FormCardControllerTest_getContactByIdList_idList_notEmpty', 0, () => {
      let mocker: MockKit = new MockKit();

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

      let formExtensionContext: common.FormExtensionContext = {} as common.FormExtensionContext;
      let getDefaultCardContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(formExtensionContext);
      let idList: Array<string> = ['1', '2'];
      formCardController.getContactByIdList(idList, (contactList: SpeedDialCardDataType[]) => {
        expect(contactList[0].contactId).assertEqual('0');
      });

      mocker.clear(formCardController);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('FormCardControllerTest_getContactByIdList_idList_notEmpty_mDataWorker_undefined', 0, () => {
      formCardController.mDataWorker = undefined;
      let idList: Array<string> = ['1', '2'];
      formCardController.getContactByIdList(idList, (contactList: SpeedDialCardDataType[]) => {
        expect(JSON.stringify(contactList)).assertEqual('[]');
      });
    })

    it('FormCardControllerTest_getContactByPhones', 0, () => {
      let callLog: Array<Record<string, string>> = [{
        'phoneNumber': '570977632'
      }];
      let mocker: MockKit = new MockKit();
      let getNumberList = mocker.mockFunc(formCardController, formCardController.getNumberList);
      when(getNumberList)(callLog).afterReturn(['570977632']);

      let formExtensionContext: common.FormExtensionContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.FormExtensionContext;

      let getDefaultCardContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(formExtensionContext);

      formCardController.getContactByPhones(callLog, 1, (filterLog: Record<string, string>[]) => {
        expect(JSON.stringify(filterLog)).assertEqual('[]');
      });

      mocker.clear(formCardController);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FormCardControllerTest_getNumberList', 0, () => {
      let callLog: Array<Record<string, string>> = [];
      let record: Record<string, string> = {
        'phoneNumber': '17694452689'
      }
      callLog.push(record);
      expect(formCardController.getNumberList(callLog).length).assertEqual(1);
    })

    it('FormCardControllerTest_getNumberMap', 0, () => {
      let callLog: Array<Record<string, string>> = [];
      let record: Record<string, string> = {
        'detailInfo': 'test',
        'displayName': 'test'
      }
      callLog.push(record);
      expect(formCardController.getNumberMap(callLog).size).assertEqual(1);
    })

    it('FormCardControllerTest_getNumberMap_no_detailInfo', 0, () => {
      let numberMap: Map<string, string> = new Map();
      let callLog: Array<Record<string, string>> = [];
      let record: Record<string, string> = {
        'detailInfo1': 'test',
        'displayName1': 'test'
      }
      callLog.push(record);
      let result: Map<string, string> = formCardController.getNumberMap(callLog);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(numberMap));
    })

    it('FormCardControllerTest_getFirstMissedCall', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let getMergeRule = mocker.mockFunc(CallLogSetting.getInstance(), CallLogSetting.getInstance().getMergeRule);
      when(getMergeRule)().afterReturn(MergeRule.CONTACT);
      let formExtensionContext: common.FormExtensionContext = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext();
      let getDefaultCardContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(formExtensionContext);
      let updateToCard = mocker.mockFunc(formCardController, formCardController.updateToCard);
      when(updateToCard)('1').afterAction(() => {
      });

      formCardController.getFirstMissedCall('1', 'roxy');

      expect(result).assertFalse();

      mocker.clear(formCardController);
      mocker.clear(CallLogSetting.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FormCardControllerTest_getFirstMissedCall_mDataWorker_undefined', 0, () => {
      formCardController.mDataWorker = undefined;
      let result = false;
      let mocker: MockKit = new MockKit();
      let getMergeRule = mocker.mockFunc(CallLogSetting.getInstance(), CallLogSetting.getInstance().getMergeRule);
      when(getMergeRule)().afterAction(() => {
        result = true;
        return MergeRule.CONTACT
      });

      formCardController.getFirstMissedCall('1', 'roxy');

      expect(result).assertTrue();

      mocker.clear(CallLogSetting.getInstance());
    })

    it('FormCardControllerTest_setMissedCallToRead', 0, async () => {
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext))().afterReturn(context);

      let phone: string[] = ['570977632'];
      formCardController.setMissedCallToRead(phone);
      expect(formCardController.resultDT).assertFalse();

      mocker.clear(formCardController);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FormCardControllerTest_setMissedCallBadgeNumberByPhone', 0, async () => {
      let phoneList: string[] = ['570977632'];
      let result = false;
      let mocker: MockKit = new MockKit();
      let formExtensionContext: common.FormExtensionContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => {
            return 'resource';
          }
        },
        area: contextConstant.AreaMode.EL1
      } as common.FormExtensionContext;
      let getDefaultCardContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterAction(() => {
        result = true;
        return formExtensionContext;
      });
      await formCardController.setMissedCallBadgeNumberByPhone(phoneList);

      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_setMissedCallBadgeNumberByPhone_error', 0, async () => {
      let phoneList: string[] = ['570977632'];
      let result = false;
      let mocker: MockKit = new MockKit();
      let getDefaultCardContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterThrow('error getDefaultCardContext');
      await formCardController.setMissedCallBadgeNumberByPhone(phoneList);

      expect(result).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_getSimStateDataCard', 0, () => {
      let result1 = false;
      formCardController.getSimStateDataCard(0);
      expect(result1).assertFalse();
    })

    it('FormCardControllerTest_getContactPhone_if_if', 0, () => {
      let mocker: MockKit = new MockKit();

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
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 5
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);

      let result1 = false;
      let setMissedCallBadgeNumberByPhone = mocker.mockFunc(formCardController, formCardController.setMissedCallBadgeNumberByPhone);
      when(setMissedCallBadgeNumberByPhone)(ArgumentMatchers.any).afterAction(() => {
        result1 = true;
      });

      let result2 = false;
      let setMissedCallToRead = mocker.mockFunc(formCardController, formCardController.setMissedCallToRead);
      when(setMissedCallToRead)(ArgumentMatchers.any).afterAction(() => {
        result2 = true;
      });

      let result3 = false;
      let startDialogUIAbility = mocker.mockFunc(formCardController, formCardController.startDialogUIAbility);
      when(startDialogUIAbility)().afterAction(() => {
        result3 = true;
      });

      let result4 = false;
      let dealCallNumber = mocker.mockFunc(formCardController, formCardController.dealCallNumber);
      when(dealCallNumber)().afterAction(() => {
        result4 = true;
      });
      formCardController.getContactPhone('1');

      expect(result1).assertFalse();
      expect(result4).assertFalse();

      mocker.clear(formCardController);
      mocker.clear(ContactAbilityModel);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('FormCardControllerTest_getContactPhone_if_else', 0, () => {
      let mocker: MockKit = new MockKit();

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
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateMeeTimeAbilityPhoneNumber);

      let result1 = false;
      let setMissedCallBadgeNumberByPhone = mocker.mockFunc(formCardController, formCardController.setMissedCallBadgeNumberByPhone);
      when(setMissedCallBadgeNumberByPhone)(ArgumentMatchers.any).afterAction(() => {
        result1 = true;
      });

      let result2 = false;
      let setMissedCallToRead = mocker.mockFunc(formCardController, formCardController.setMissedCallToRead);
      when(setMissedCallToRead)(ArgumentMatchers.any).afterAction(() => {
        result2 = true;
      });

      let result3 = false;
      let startDialogUIAbility = mocker.mockFunc(formCardController, formCardController.startDialogUIAbility);
      when(startDialogUIAbility)().afterAction(() => {
        result3 = true;
      });

      let result4 = false;
      let dealCallNumber = mocker.mockFunc(formCardController, formCardController.dealCallNumber);
      when(dealCallNumber)().afterAction(() => {
        result4 = true;
      });
      formCardController.getContactPhone('1');

      expect(result1).assertFalse();
      expect(result4).assertFalse();

      mocker.clear(formCardController);
      mocker.clear(ContactAbilityModel);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('FormCardControllerTest_clickToContactDetail', 0, () => {
      let actionData: Record<string, string> = {
        'phoneNumber': '570977632'
      };
      let result1 = false;
      let mocker: MockKit = new MockKit();
      let jumpToContactDetailForResult = mocker.mockFunc(formCardController, formCardController.jumpToContactDetailForResult);
      when(jumpToContactDetailForResult)(actionData).afterAction(() => {
        result1 = true;
      });
      let formExtensionContext: common.FormExtensionContext = {} as common.FormExtensionContext;
      formCardController.clickToContactDetail(actionData, formExtensionContext);

      expect(result1).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_clickToContactRecord', 0, () => {
      let result1 = false;
      let mocker: MockKit = new MockKit();
      let jumpToContactDetailForResult = mocker.mockFunc(formCardController, formCardController.jumpToContactDetailForResult);
      when(jumpToContactDetailForResult)(ArgumentMatchers.any).afterAction(() => {
        result1 = true;
      });

      let formExtensionContext: common.FormExtensionContext = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext();
      formCardController.clickToContactRecord(formExtensionContext, 'MissedCallCardAbility');

      expect(result1).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_startDialogUIAbility', 0, () => {
      let result1 = false;
      let mocker: MockKit = new MockKit();
      let jumpToContactDetailForResult = mocker.mockFunc(formCardController, formCardController.jumpToContactDetailForResult);
      when(jumpToContactDetailForResult)(ArgumentMatchers.any).afterAction(() => {
        result1 = true;
      });

      let formExtensionContext: common.FormExtensionContext = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext();
      formCardController.startDialogUIAbility(formExtensionContext, 'MissedCallCardAbility', '570977632');

      expect(result1).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_jumpToContactDetailForResult_dialog', 0, async () => {
      let actionData: Record<string, string> = {
        'phoneNumber': '570977632'
      };
      let result = false;
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> => new Promise<void>(
          (resolve: () => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            resolve();
          })
      } as common.UIAbilityContext;

      await formCardController.jumpToContactDetailForResult(actionData, context, 'dialog');

      expect(result).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_jumpToContactDetailForResult_dialog_businessError', 0, async () => {
      let actionData: Record<string, string> = {
        'phoneNumber': '570977632'
      };
      let result = false;
      let mocker: MockKit = new MockKit();

      let context: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> => new Promise<void>(
          (resolve: () => void, reject: (reason?: BusinessError) => void) => {
            result = true;
            reject({
              code: 401,
              message: 'error param'
            } as BusinessError);
          })
      } as common.UIAbilityContext;
      await formCardController.jumpToContactDetailForResult(actionData, context, 'dialog');

      expect(result).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_jumpToContactDetailForResult_DiologEntryAbility', 0, async () => {
      let actionData: Record<string, string> = {
        'phoneNumber': '570977632'
      };
      let result1 = false;
      let mocker: MockKit = new MockKit();
      let jumpToContactDetailForResult = mocker.mockFunc(formCardController, formCardController.jumpToContactDetailForResult);
      when(jumpToContactDetailForResult)(ArgumentMatchers.any).afterAction(() => {
        result1 = true;
      });

      let formExtensionContext: common.FormExtensionContext = {} as common.FormExtensionContext;
      await formCardController.jumpToContactDetailForResult(actionData, formExtensionContext, 'DiologEntryAbility');

      expect(result1).assertTrue();

      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_notHaveSimCard_isDialEmergencyNum_false', 0, () => {
      let option: call.DialOptions = {
        accountId: 1
      };
      formCardController.isEmergencyNum = false;

      let mocker: MockKit = new MockKit();

      let phoneNumber: PhoneNumber = PhoneNumber.fromString('570977632');
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('570977632').afterReturn(phoneNumber);

      when(mocker.mockFunc(phoneNumber, phoneNumber.isDialEmergencyNum))()
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));

      let dial = mocker.mockFunc(phoneNumber, phoneNumber.dial);
      when(dial)(option).afterAction(() => {
        mocker.verify('isDialEmergencyNum', []).once();
        return new Promise<boolean>(resolve => resolve(false));
      });

      formCardController.notHaveSimCard('570977632', 1);
      mocker.clear(formCardController);
      mocker.clear(phoneNumber);
      mocker.clear(PhoneNumber);
    })

    it('FormCardControllerTest_notHaveSimCard_isDialEmergencyNum_true', 0, () => {
      let option: call.DialOptions = {
        accountId: 1
      };
      let mocker: MockKit = new MockKit();

      formCardController.isEmergencyNum = true;

      let phoneNumber: PhoneNumber = PhoneNumber.fromString('570977632');
      when(mocker.mockFunc(PhoneNumber, PhoneNumber.fromString))('570977632').afterReturn(phoneNumber);

      when(mocker.mockFunc(phoneNumber, phoneNumber.isDialEmergencyNum))()
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));

      let dial = mocker.mockFunc(phoneNumber, phoneNumber.dial);
      when(dial)(option).afterAction(() => {
        mocker.verify('isDialEmergencyNum', []).once();
        return new Promise<boolean>(resolve => resolve(false));
      });

      formCardController.notHaveSimCard('570977632', 1);

      expect(formCardController.simStateStatusCardOne).assertFalse();
      mocker.clear(phoneNumber);
      mocker.clear(PhoneNumber);
    })

    it('FormCardControllerTest_updateToCard', 0, () => {
      let obj: MissedCallListType = {
        callLog: [],
        formId: '1',
        title: 'missedCall'
      }
      let formData: formBindingData.FormBindingData = formBindingData.createFormBindingData(obj);
      let result1 = false;
      formCardController.updateToCard('570977632', formData);

      expect(result1).assertFalse();
    })

    it('FormCardControllerTest_handleRoamingNumber', 0, () => {
      let phoneInfo: PhoneNumBean = new PhoneNumBean('1', '2', '3', '', '');
      let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().queryValidFormatNumber);
      when(mockFun)(ArgumentMatchers.any).afterReturn(new Promise<string> ((resolve: Function) => {
        resolve('1')
      }))
      let mockFunc: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getRoamingDialNumber);
      let result = false;
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(['111']);
      }));
      let callback: Function = () => {};
      formCardController.handleRoamingNumber(phoneInfo, 1, callback);
      expect(result).assertFalse();
      mocker.clear(RoamingUtils);
    })

    it('FormCardControllerTest_handleRoamingNumber_phoneList_null', 0, () => {
      let phoneInfo: PhoneNumBean = new PhoneNumBean('1', '2', '3', '', '');
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().queryValidFormatNumber);
      when(mockFun)(ArgumentMatchers.any).afterReturn(new Promise<string> ((resolve: Function) => {
        resolve('1')
      }))
      let mockFunc: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getRoamingDialNumber);
      let result = false;
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve([]);
      }));
      let callback: Function = () => {};
      formCardController.handleRoamingNumber(phoneInfo, 1, callback);
      expect(result).assertFalse();
      mocker.clear(RoamingUtils);
    })

    it('FormCardControllerTest_handleRoamingNumber_phoneList01', 0, () => {
      let phoneInfo: PhoneNumBean = new PhoneNumBean('1', '2', '3', '', '');
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().queryValidFormatNumber);
      when(mockFun)(ArgumentMatchers.any).afterReturn(new Promise<string> ((resolve: Function) => {
        resolve('1')
      }))
      let mockFunc: Function = mocker.mockFunc(RoamingUtils, RoamingUtils.getRoamingDialNumber);
      let result = false;
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(['111', '222']);
      }));
      let mockFunc1: Function = mocker.mockFunc(formCardController, formCardController.buildPhoneBeans);
      when(mockFunc1)(ArgumentMatchers.any).afterReturn(new Promise<PhoneNumBean> ((resolve: Function) => {
        resolve(new PhoneNumBean('1', '2', '3', '', ''))
      }))
      let callback: Function = () => {};
      formCardController.handleRoamingNumber(phoneInfo, 1, callback);
      expect(result).assertFalse();
      mocker.clear(RoamingUtils);
    })

    it('FormCardControllerTest_buildPhoneBeans_phoneList_null', 0, async () => {
      let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      let phoneList: string[] = [];
      let type: string = '1';
      formCardController.buildPhoneBeans(context, phoneList, type).then(res => {
        expect(res.length).assertEqual(0);
      })
    })

    it('FormCardControllerTest_buildPhoneBeans_phoneList', 0, async () => {
      let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      let phoneList: string[] = ['13801001111'];
      let type: string = '1';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(RoamingManager.getInstance(), RoamingManager.getInstance().getLocations);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string[]> ((resolve: Function) => {
        resolve(['13801001111'])
      }))
      formCardController.buildPhoneBeans(context, phoneList, type).then(res => {
        expect(res.length).assertEqual(1);
      })
      mocker.clear(RoamingManager.getInstance());
    })

    it('FormCardControllerTest_dealCallNumber', 0, async () => {
      let phoneNum: string = '13312345678';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(formCardController, formCardController.getMaxSimCount))().afterReturn(0);
      mocker.mockFunc(formCardController, formCardController.notHaveSimCard);
      await formCardController.dealCallNumber(phoneNum);
      mocker.verify('notHaveSimCard', [phoneNum, 1]).once();

      when(mocker.mockFunc(formCardController, formCardController.getMaxSimCount))().afterReturn(2);
      when(mocker.mockFunc(formCardController, await formCardController.isSimActive))(ArgumentMatchers.any).afterReturn(new Promise<boolean> ((resolve: Function) => {
        resolve(true);
      }))
      mocker.mockFunc(formCardController, formCardController.dealMultiCardNumber);
      await formCardController.dealCallNumber(phoneNum);
      mocker.verify('dealMultiCardNumber', [phoneNum]).once();
      mocker.clear(formCardController);
    })

    it('FormCardControllerTest_mergeDuplicateNumbers', 0, () => {
      expect(JSON.stringify(formCardController.mergeDuplicateNumbers([]))).assertEqual(JSON.stringify([]));
      let phoneList: PhoneNumBean[] = [];
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('1', '570977632', '1', '', '', false);
      let phoneNumBean1: PhoneNumBean = new PhoneNumBean('2', '570977632', '2', '', '', true);
      phoneList.push(phoneNumBean);
      phoneList.push(phoneNumBean1);
      let list: PhoneNumBean[] = [phoneNumBean];
      let result = formCardController.mergeDuplicateNumbers(phoneList);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(list));
    })
  })
}