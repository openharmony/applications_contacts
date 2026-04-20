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
import { describe, it, expect, MockKit, when, ArgumentMatchers, beforeEach, afterEach } from '@ohos/hypium';
import { ContackPhoneSubInfoModel, ContactFormModel } from '../../../../../../../main/ets/model/type/ContactParams';
import DetailPresenter, {
  CapabilityInfo,
  DeviceInfo
} from '../../../../../../../main/ets/presenter/contact/detail/DetailPresenter';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { RichContactInfo } from '../../../../../../../main/ets/model/bean/RichContactInfo';
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { CallLog, CallLogRepository, CallType } from '../../../../../../../../../feature/call';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import CallLogBuilder from '../../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import { NumberMatch } from '../../../../../../../../../feature/contact/src/main/ets/cust/NumberMatch';
import { PhoneNumBean } from '../../../../../../../main/ets/model/bean/PhoneNumBean';
import { EmailBean } from '../../../../../../../main/ets/model/bean/EmailBean';
import { AIMBean } from '../../../../../../../main/ets/model/bean/AIMBean';
import { HouseBean } from '../../../../../../../main/ets/model/bean/HouseBean';
import { EventBean } from '../../../../../../../main/ets/model/bean/EventBean';
import { AssociatedPersonBean } from '../../../../../../../main/ets/model/bean/AssociatedPersonBean';
import { GroupBean } from '../../../../../../../main/ets/model/bean/GroupBean';
import { PhoneNumber } from '../../../../../../../../../feature/phonenumber';
import CallDetail from '../../../../../../../main/ets/model/bean/CallDetail';
import { AnswerState, Direction } from '../../../../../../../../../feature/call/src/main/ets/contract/Calls';
import MorandiColor from '../../../../../../../main/ets/model/bean/MorandiColor';
import DetailCallLogDataSource from '../../../../../../../main/ets/model/bean/DetailCallLogDataSource';
import MeeTimeAbilityInfoModel
  from '../../../../../../../../../feature/contact/src/main/ets/entity/MeeTimeAbilityInfoModel';
import LooseObject from '../../../../../../../main/ets/model/type/LooseObject';
import CallServiceManager from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager';
import { sharedPreferencesUtils } from '../../../../../../../../../feature/call/oh_modules/common';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import StartOptions from '@ohos.app.ability.StartOptions';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AsyncCallback, BusinessError } from '@ohos.base';
import { CallTypeMeetime } from '../../../../../../../../../feature/call/src/main/ets/contract/MeetimeCalls';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import { ContactRepository } from '../../../../../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import CallRecordPresenter from '../../../../../../../main/ets/presenter/dialer/callRecord/CallRecordPresenter';
import data_preferences from '@ohos.data.preferences';
import { AccountantParams, SpeedDialItem } from '../../../../../../../main/ets/model/type/index';
import { PixelMapManager } from '../../../../../../../main/ets/util/UserPhoto';
import MeeTimeService from '../../../../../../../../../feature/phonenumber/src/main/ets/MeeTimeService';
import StringFormatUtil from '../../../../../../../main/ets/util/StringFormatUtil';
import { ValuesBucket } from '@kit.ArkData';
import { DataItemType } from '../../../../../../../../../feature/contact';
import { DynamicLoader } from '../../../../../../../../../common/src/main/ets/util/DynamicLoader';
import NumberMarkUtil from '../../../../../../../../../entry/src/main/ets/util/NumberMarkUtil';
import { RingtoneInfo } from '../../../../../../../main/ets/model/ringTone/toneTypes';
import MeeTimeDeviceInfoModel from '../../../../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel';
import { DynamicLoadSoUtil } from '../../../../../../../../../common/src/main/ets/util/DynamicLoadSoUtil';

export default function DetailPresenterTest() {
  describe('DetailPresenterTest', () => {

    let mocker: MockKit;
    let detailPresenter: DetailPresenter;
    let callLogRepository: CallLogRepository;

    beforeEach(() => {
      detailPresenter = new DetailPresenter();
      mocker = new MockKit();
      callLogRepository = CallLogRepository.getDTTestInstance();
    })

    afterEach(() => {
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getMeeTimeAbilityPhoneNumList', 0, () => {
      detailPresenter.meeTimeAbilityInfoModel.phoneNumber = '570977632';
      let phoneNumberList: Record<string, string | number | boolean>[] = [{
        'phoneNumber': detailPresenter.meeTimeAbilityInfoModel.phoneNumber,
        'index': 0,
        'lastFlag': true
      }];
      expect(JSON.stringify(detailPresenter.getMeeTimeAbilityPhoneNumList()))
        .assertEqual(JSON.stringify(phoneNumberList));
    })
    
    it('DetailPresenterTest_aboutToAppear_sourceHasId', 0, async () => {
      let registered: Boolean = false;
      detailPresenter.sourceHasId = true;
      detailPresenter.contactId = 1;
      when(mocker.mockFunc(detailPresenter, detailPresenter.getContactDetail) as Function)(1).afterAction(() => {
        detailPresenter.isContactDataReady = true;
      });
      when(mocker.mockFunc(detailPresenter, detailPresenter.registerCallLogObsever))().afterAction(() => {
        registered = true;
      });
      await detailPresenter.aboutToAppear();
      expect(detailPresenter.isNewNumber).assertFalse();
      expect(detailPresenter.isContactDataReady).assertTrue();
      // expect  assert  true
      expect(registered).assertTrue();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_aboutToAppear_sourceHasPhone', 0, async () => {
      let registered = false;
      let contactId = -1;
      detailPresenter.sourceHasId = false;
      detailPresenter.sourceHasPhone = true;

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('getIdByTelephone').afterAction(() => {
        contactId = 1;
      });
      when(mocker.mockFunc(detailPresenter, detailPresenter.registerCallLogObsever))().afterAction(() => {
        registered = true;
      });

      await detailPresenter.aboutToAppear();

      expect(detailPresenter.resultDT).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_aboutToAppear_sourceHasPhone_callback_if1_noIf2', 0, async () => {
      let registered = false;
      detailPresenter.sourceHasId = false;
      detailPresenter.sourceHasPhone = true;
      detailPresenter.phoneNumberShow = '570977632';

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(detailPresenter, detailPresenter.registerCallLogObsever))().afterAction(() => {
        registered = true;
      });

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(uiContext);

      when(mocker.mockFunc(ContactRepository.getInstance().init(uiContext), ContactRepository.getInstance()
        .init(uiContext)
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
              getLong: (columnIndex: number): number => 0,
              goToRow: (position: number): boolean => true
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(detailPresenter, detailPresenter.getContactDetail);
      mocker.mockFunc(detailPresenter, detailPresenter.getNewNumCallLog);

      when(mocker.mockFunc(NumberMatch.getInstance(), NumberMatch.getInstance().getCallerIndex))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      await detailPresenter.aboutToAppear();

      expect(registered).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactRepository.getInstance().init(uiContext));
      mocker.clear(NumberMatch.getInstance());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_aboutToAppear_sourceHasPhone_callback_noIf1_if2', 0, async () => {
      let registered = false;
      detailPresenter.sourceHasId = false;
      detailPresenter.sourceHasPhone = true;
      detailPresenter.phoneNumberShow = '570977632';
      detailPresenter.isNewNumber = true;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      when(mocker.mockFunc(detailPresenter, detailPresenter.registerCallLogObsever))().afterAction(() => {
        registered = true;
      });
      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(uiContext);

      when(mocker.mockFunc(ContactRepository.getInstance().init(uiContext), ContactRepository.getInstance()
        .init(uiContext)
        .getDataAbilityHelper))()
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
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(detailPresenter, detailPresenter.getContactDetail);
      mocker.mockFunc(detailPresenter, detailPresenter.getNewNumCallLog);

      await detailPresenter.aboutToAppear();

      expect(registered).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactRepository.getInstance().init(uiContext));
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_requestContactDetail_sourceHasRawId', 0, () => {
      detailPresenter.sourceHasRawId = true;
      detailPresenter.rawContactId = 1;
      mocker.mockFunc(detailPresenter, detailPresenter.getContactIdByRawId);
      detailPresenter.requestContactDetail();
      mocker.verify('getContactIdByRawId', [detailPresenter.rawContactId]).once();
      mocker.clear(detailPresenter);
    })

    // DetailPresenterTest aboutToDisappear
    it('DetailPresenterTest_aboutToDisappear', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().unRegisterDataChangeObserver);

      detailPresenter.aboutToDisappear();

      mocker.verify('unRegisterDataChangeObserver', [detailPresenter.callLogChange]).times(2);
      mocker.verify('unRegisterDataChangeObserver', [detailPresenter.onCallsChange]).times(2);

      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    // defect density
    it('DetailPresenterTest_callLogChange', 0, () => {
      let refreshed: Boolean = false;

      when(mocker.mockFunc(detailPresenter, detailPresenter.refresh))().afterAction(() => {
        refreshed = true;
      });
      detailPresenter.callLogChange();
      expect(detailPresenter.resultDT).assertFalse();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_onCallsChange', 0, () => {
      detailPresenter.onCallsChange();

      expect(CallRecordPresenter.getInstance().initStarted).assertFalse();
    })

    it('DetailPresenterTest_registerCallLogObserver', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().registerDataChangeObserver)

      detailPresenter.registerCallLogObsever();

      mocker.verify('registerDataChangeObserver', [detailPresenter.callLogChange]).times(2);
      mocker.verify('registerDataChangeObserver', [detailPresenter.onCallsChange]).times(2);

      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it("DetailPresenterTest_refresh_id_not_undefined", 0, () => {
      detailPresenter.contactId = 1;
      let getContactCallLog: Function = mocker.mockFunc(detailPresenter, detailPresenter.getContactCallLog);

      when(getContactCallLog)().afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(true)
      }))
      detailPresenter.refresh();
      mocker.verify('getNewNumCallLog', []).never();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactDetail_callback_result_empty', 0, () => {
      let result = false;

      detailPresenter.displayName = '';
      detailPresenter.contactId = 1;

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterAction(() => {
        result = true;
        return workerWrapper
      });
      let getNewNumCallLog = mocker.mockFunc(detailPresenter, detailPresenter.getNewNumCallLog);
      when(getNewNumCallLog)().afterReturn(new Promise<void>(resolve => resolve()));
      detailPresenter.getContactDetail(-1);
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactDetail_callback_result_notEmpty', 0, () => {
      detailPresenter.contactId = 1;
      detailPresenter.displayName = '';

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let result = false;
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

      mocker.mockFunc(detailPresenter, detailPresenter.dealDetailsData);
      mocker.mockFunc(detailPresenter, detailPresenter.updateMeeTimeAbility);
      mocker.mockFunc(detailPresenter, detailPresenter.syncAndUpdateMeeTimeAbility);

      detailPresenter.getContactDetail(1);
      expect(result).assertTrue();


      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactDetail_callback_result_notEmpty_displayName_xxx', 0, () => {
      detailPresenter.contactId = 1;
      detailPresenter.displayName = '';

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      when(getValue)(ContactsGlobalThisHelper.UiExtentionAbilityFromName).afterReturn('meetime');

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let result = false;
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
                getColumnIndex: (columnName: string): number => columnName === 'type_id' ? 1 : 0,
                getLong: (columnIndex: number): number => columnIndex === 1 ? 6 : 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });

      mocker.mockFunc(detailPresenter, detailPresenter.dealDetailsData);
      mocker.mockFunc(detailPresenter, detailPresenter.updateMeeTimeAbility);
      mocker.mockFunc(detailPresenter, detailPresenter.syncAndUpdateMeeTimeAbility);

      detailPresenter.getContactDetail(1);

      expect(result).assertTrue();


      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactDetail_callback_result_notEmpty_error', 0, () => {
      detailPresenter.contactId = 1;
      detailPresenter.displayName = '';
      detailPresenter.contacts.phones = [new PhoneNumBean('selectedCustom1', '2', '', '', '', true, 9)];

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      when(getValue)(ContactsGlobalThisHelper.UiExtentionAbilityFromName).afterReturn('notmeetime');

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let result = false;
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
                getColumnIndex: (columnName: string): number => columnName === 'type_id' ? 1 : 0,
                getLong: (columnIndex: number): number => columnIndex === 1 ? 6 : 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(detailPresenter, detailPresenter.dealDetailsData);
      mocker.mockFunc(detailPresenter, detailPresenter.updateMeeTimeAbility);
      mocker.mockFunc(detailPresenter, detailPresenter.syncAndUpdateMeeTimeAbility);

      when(mocker.mockFunc(detailPresenter, detailPresenter.formatContactNameIfIsPhone))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>((resolve: (res: string) => void, reject: (reason: BusinessError) => void) => {
          reject({
            code: 401, message: 'error'
          } as BusinessError)
        }));

      detailPresenter.getContactDetail(1);

      expect(result).assertTrue();


      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_updateMeeTimeAbility', 0, () => {
      let meeTimeAbilityInfo = new MeeTimeAbilityInfoModel('id1', 'roxy1', 'address1', 1);
      detailPresenter.updateMeeTimeAbility(meeTimeAbilityInfo);
      expect(detailPresenter.isHasMeeTimeAbilityFlag).assertTrue();
      expect(detailPresenter.meeTimeAbilityBinary).assertEqual(meeTimeAbilityInfo.extra4Binary);
    })

    it('DetailPresenterTest_syncAndUpdateMeeTimeAbility_phoneNumBeans_empty', 0, () => {
      let isMeeTimeLogin: Function = mocker.mockFunc(detailPresenter, detailPresenter.isMeeTimeLogin);
      when(isMeeTimeLogin)().afterReturn(new Promise<Boolean>(resolve => resolve(false)));
      detailPresenter.syncAndUpdateMeeTimeAbility(1, []);
      mocker.verify('isMeeTimeLogin', []).never();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_syncAndUpdateMeeTimeAbility_phoneNumBeans_notEmpty', 0, () => {
      //connection
      let phoneNumBeans = [new PhoneNumBean('selectedCustom1', '2', '', '', '', true, 9)];

      let isMeeTimeLogin: Function = mocker.mockFunc(detailPresenter, detailPresenter.isMeeTimeLogin);
      when(isMeeTimeLogin)().afterReturn(new Promise<Boolean>(resolve => resolve(false)));
      detailPresenter.syncAndUpdateMeeTimeAbility(1, phoneNumBeans);
      let syncMeeTimeAbility = mocker.mockFunc(detailPresenter, detailPresenter.syncMeeTimeAbility);
      when(syncMeeTimeAbility)(1).afterReturn(new Promise<string>(resolve => resolve('')));
      let capabilityInfo: CapabilityInfo = {
        hasVoice: 0, hasVideo: 0, hasMessage: 0
      };
      let meeTimeAbilityInfoModelNew: MeeTimeAbilityInfoModel =
        new MeeTimeAbilityInfoModel(capabilityInfo.accountId,
          capabilityInfo.nickName,
          '',
          capabilityInfo.hasVoice * 4 + capabilityInfo.hasVideo * 2 + capabilityInfo.hasMessage * 1// 能力
        );
      let updateMeeTimeAbility = mocker.mockFunc(detailPresenter, detailPresenter.updateMeeTimeAbility);
      when(updateMeeTimeAbility)(meeTimeAbilityInfoModelNew).afterAction(() => {
      });
      detailPresenter.syncAndUpdateMeeTimeAbility(1, phoneNumBeans);
      mocker.verify('isMeeTimeLogin', phoneNumBeans).never();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_syncMeeTimeAbility', 0, async () => {
      let phoneNumBeans = [new PhoneNumBean('selectedCustom1', '2', '', '', '', true, 9)];
      let recordList: Record<string, string | number>[] = [];
      phoneNumBeans.forEach((element) => {
        let record: Record<string, string | number> = {
          "phoneNumber": element.num,
          "hasMeeTimeCap": DetailPresenter.PHONE_NUMBER_HAS_NO_MEETIME_ABILIBY_FLAG
        };
        recordList.push(record);
      });

      when(mocker.mockFunc(CallServiceManager.getInstance(), CallServiceManager.getInstance()
        .syncContactMeeTimeAbility))(1)
        .afterReturn(new Promise<String>(resolve => resolve("result")));

      let result: string = await detailPresenter.syncMeeTimeAbility(1, phoneNumBeans);

      expect(result).assertEqual("result");
      mocker.verify('syncContactMeeTimeAbility', [1, recordList]).once();

      mocker.clear(CallServiceManager.getInstance());
    })

    it('DetailPresenterTest_syncMeeTimeAbility_meeTimeAbilityFlag_notEmpty', 0, async () => {
      let phoneNumBean: PhoneNumBean = new PhoneNumBean('selectedCustom1', '2', '', '', '', true, 9);
      phoneNumBean.meeTimeAbilityFlag = '2';
      let phoneNumBeans = [phoneNumBean];

      let recordList: Record<string, string | number>[] = [];
      phoneNumBeans.forEach((element) => {
        let record: Record<string, string | number> = {
          "phoneNumber": element.num,
          "hasMeeTimeCap": (element.meeTimeAbilityFlag === '' || element.meeTimeAbilityFlag === undefined)
            ? DetailPresenter.PHONE_NUMBER_HAS_NO_MEETIME_ABILIBY_FLAG : Number.parseInt(element.meeTimeAbilityFlag)
        };
        recordList.push(record);
      });

      when(mocker.mockFunc(CallServiceManager.getInstance(), CallServiceManager.getInstance()
        .syncContactMeeTimeAbility))(1)
        .afterReturn(new Promise<String>(resolve => resolve("result")));

      let result: string = await detailPresenter.syncMeeTimeAbility(1, phoneNumBeans);

      expect(result).assertEqual("result");
      mocker.verify('syncContactMeeTimeAbility', [1, recordList]).once();

      mocker.clear(CallServiceManager.getInstance());
    })

    it('DetailPresenterTest_dealDetailsData', 0, () => {
      let idGot: Boolean = false;
      let dealSuccess: Boolean = false;
      let callLogGot: Boolean = false;

      let getLabelNameByTypeId: Function = mocker.mockFunc(detailPresenter, detailPresenter.getLabelNameByTypeId);
      when(getLabelNameByTypeId)().afterAction(() => {
        idGot = true;
      });
      let dealContactsToForm: Function = mocker.mockFunc(detailPresenter, detailPresenter.dealContactsToForm);
      when(dealContactsToForm)().afterAction(() => {
        dealSuccess = true;
      });
      let getContactCallLog: Function = mocker.mockFunc(detailPresenter, detailPresenter.getContactCallLog);
      when(getContactCallLog)().afterAction(() => {
        callLogGot = true;
      });
      detailPresenter.dealDetailsData();
      expect(idGot).assertTrue();
      expect(dealSuccess).assertTrue();
      expect(callLogGot).assertTrue();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_formatContactNameIfIsPhone_phones_length_0', 0, async () => {
      let result = await detailPresenter.formatContactNameIfIsPhone('570977632', []);
      expect(result).assertEqual('570977632');
    })

    it('DetailPresenterTest_formatContactNameIfIsPhone_phones_length_1', 0, async () => {
      let phone = new PhoneNumBean('1', '570977632', '1', '', '', true);
      let result = await detailPresenter.formatContactNameIfIsPhone('570977632', [phone]);
      expect(result).assertEqual('570 977 632');
    })

    it('DetailPresenterTest_formatContactNameIfIsPhone_phones_length_1_isSamePhoneName_false', 0, async () => {
      let phone = new PhoneNumBean('1', '570977632', '1', '', '', true);
      let result = await detailPresenter.formatContactNameIfIsPhone('570977633', [phone]);
      expect(result).assertEqual('570977633');
    })

    it('DetailPresenterTest_getLabelNameByTypeId', 0, () => {
      let phone = new PhoneNumBean('1', '570977632', '1', '', '', true);
      phone.phoneAddress = 'address';
      let phones: PhoneNumBean[] = [phone];
      let emails: EmailBean[] = [new EmailBean('text', '', '1')];
      let aims: AIMBean[] = [new AIMBean('1', 'text', '1', '')];
      let houses: HouseBean[] = [new HouseBean('1', '', '1', 'home1')];
      let events: EventBean[] = [new EventBean('1', 'data1', '1', 'event')];
      let relationships: AssociatedPersonBean[] = [new AssociatedPersonBean('text', '1', 'relation1', '1')];
      detailPresenter.contacts = new RichContactInfo('1');
      detailPresenter.contacts.phones = phones;
      detailPresenter.contacts.emails = emails;
      detailPresenter.contacts.aims = aims;
      detailPresenter.contacts.houses = houses;
      detailPresenter.contacts.events = events;
      detailPresenter.contacts.relationships = relationships;
      detailPresenter.getLabelNameByTypeId();
      let contacts: RichContactInfo = detailPresenter.contacts;
      expect(contacts.phones[0].phoneAddress).assertEqual("address");
      expect(JSON.stringify(contacts.phones[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.phone_type_mobile")));
      expect(JSON.stringify(contacts.emails[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.email_type_home")));
      expect(JSON.stringify(contacts.aims[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.instant_type_aim")));
      expect(JSON.stringify(contacts.houses[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.house_type_dwelling")));
      expect(JSON.stringify(contacts.events[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.birthday_type_grebirthday")));
      expect(JSON.stringify(contacts.relationships[0].labelName))
        .assertEqual(JSON.stringify($r("app.string.relationship_type_assistant")));
    })

    it('DetailPresenterTest_getLabelNameByTypeId_10000', 0, () => {
      let phone = new PhoneNumBean('1', '570977632', '10000', '', '', true);
      phone.phoneAddress = 'address';
      let phones: PhoneNumBean[] = [phone];
      let emails: EmailBean[] = [new EmailBean('text', '', '10000')];
      let aims: AIMBean[] = [new AIMBean('1', 'text', '10000', '')];
      let houses: HouseBean[] = [new HouseBean('1', '', '10000', 'home1')];
      let relationships: AssociatedPersonBean[] = [new AssociatedPersonBean('text', '1', 'relation1', '10000')];
      detailPresenter.contacts = new RichContactInfo('1');
      detailPresenter.contacts.phones = phones;
      detailPresenter.contacts.emails = emails;
      detailPresenter.contacts.aims = aims;
      detailPresenter.contacts.houses = houses;
      detailPresenter.contacts.relationships = relationships;
      detailPresenter.getLabelNameByTypeId();
      let contacts: RichContactInfo = detailPresenter.contacts;
      expect(contacts.phones[0].phoneAddress).assertEqual("address");
      expect(JSON.stringify(contacts.phones[0].labelName))
        .assertEqual(JSON.stringify(contacts.phones[0].selectTextCustom));
      expect(JSON.stringify(contacts.emails[0].labelName))
        .assertEqual(JSON.stringify(contacts.emails[0].selectTextCustom));
      expect(JSON.stringify(contacts.aims[0].labelName)).assertEqual(JSON.stringify(contacts.aims[0].selectTextCustom));
      expect(JSON.stringify(contacts.houses[0].labelName))
        .assertEqual(JSON.stringify(contacts.houses[0].selectTextCustom));
      expect(JSON.stringify(contacts.relationships[0].labelName))
        .assertEqual(JSON.stringify(contacts.relationships[0].selectTextCustom));
    })

    it('DetailPresenterTest_dealContactsToForm_noIf', 0, () => {
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.display_name = '';
      contacts.photoFirstName = '';
      contacts.company = '';
      contacts.position = '';
      contacts.nickname = 'roxy';
      contacts.websites = [];
      contacts.houses = [];
      contacts.events = [];
      contacts.remarks = 'remarks1';
      contacts.groups = [];
      contacts.relationships = [];
      detailPresenter.dealContactsToForm();
      expect(JSON.stringify(detailPresenter.contactForm.displayName))
        .assertEqual(JSON.stringify($r('app.string.noName')));
      expect(detailPresenter.contactForm.photoFirstName).assertEqual('-1');
      expect(detailPresenter.contactForm.company).assertEqual('');
      expect(detailPresenter.contactForm.position).assertEqual('');
    })

    it('DetailPresenterTest_dealContactsToForm_primary_true', 0, () => {
      let result = false;
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', true)];
      let emails: EmailBean[] = [new EmailBean('text', 'beijing', '1')];
      let aims: AIMBean[] = [new AIMBean('1', 'text', '1', 'aimName')];
      let houses: HouseBean[] = [new HouseBean('1', '', '1', 'home1')];
      let events: EventBean[] = [new EventBean('1', 'data1', '1', 'event')];
      let groups: GroupBean[] = [new GroupBean(1, '1', 'group1', 'note1', '', 'ring1', 0, 111111111, '1', '')];
      let webs: string[] = ['www.web.com'];
      let relationships: AssociatedPersonBean[] = [new AssociatedPersonBean('text', '1', 'relation1', '1')];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.display_name = 'roxy';
      contacts.photoFirstName = 'roxy';
      contacts.company = 'company1';
      contacts.position = 'position1';
      contacts.phones = phones;
      contacts.emails = emails;
      contacts.aims = aims;
      contacts.nickname = 'roxy';
      contacts.websites = webs;
      contacts.houses = houses;
      contacts.events = events;
      contacts.remarks = 'remarks1';
      contacts.groups = groups;
      contacts.relationships = relationships;
      contacts.phoneticName = 'roxy';
      detailPresenter.contacts = contacts;

      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(detailPresenter.contactForm.phones)
        .afterAction(() => {
          result = true;
        });
      detailPresenter.dealContactsToForm();
      expect(detailPresenter.contactForm.displayName).assertEqual('roxy');
      expect(detailPresenter.contactForm.photoFirstName).assertEqual('ROXY');
      expect(detailPresenter.contactForm.company).assertEqual('company1');
      expect(JSON.stringify(detailPresenter.contactForm.phones)).assertEqual(JSON.stringify([{
        data: PhoneNumber.fromString(phones[0].num).getNumber(),
        num: phones[0].num,
        type: phones[0].numType,
        phoneAddress: phones[0].phoneAddress,
        labelName: phones[0].labelName,
        primary: phones[0].primary,
        dataId: phones[0].dataId,
      }]));
      expect(result).assertFalse();
      expect(JSON.stringify(detailPresenter.contactForm.emails)).assertEqual(JSON.stringify([{
        data: emails[0].address,
        type: emails[0].emailType,
        dataType: DataItemType.EMAIL,
        labelName: emails[0].labelName
      }]));
      expect(JSON.stringify(detailPresenter.contactForm.aims)).assertEqual(JSON.stringify([{
        data: aims[0].aimName,
        type: aims[0].aimType,
        dataType: DataItemType.IM,
        labelName: aims[0].labelName
      }]));
      expect(JSON.stringify(detailPresenter.contactForm.nickname)).assertEqual(JSON.stringify([]));
      expect(JSON.stringify(detailPresenter.contactForm.websites)).assertEqual(JSON.stringify([{
        data: webs[0],
        dataType: DataItemType.WEBSITE,
        labelName: $r("app.string.website")
      }]));
      expect(JSON.stringify(detailPresenter.contactForm.houses)).assertEqual(JSON.stringify([{
        data: houses[0].houseName,
        type: houses[0].houseType,
        dataType: DataItemType.SIP_ADDRESS,
        labelName: houses[0].labelName
      }]));
      expect(JSON.stringify(detailPresenter.contactForm.events)).assertEqual(JSON.stringify([]));
      expect(JSON.stringify(detailPresenter.contactForm.remarks)).assertEqual(JSON.stringify('remarks1'));
      expect(JSON.stringify(detailPresenter.contactForm.relationships)).assertEqual(JSON.stringify([{
        data: relationships[0].name,
        type: relationships[0].associatedType,
        dataType: DataItemType.RELATION,
        labelName: relationships[0].labelName
      }]));

      mocker.clear(detailPresenter.phoneDataSources);
    })

    it('DetailPresenterTest_dealContactsToForm_primary_false', 0, () => {
      let result = false;
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', false)];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.display_name = 'roxy';
      contacts.photoFirstName = 'roxy';
      contacts.company = 'company1';
      contacts.position = 'position1';
      contacts.phones = phones;
      detailPresenter.contacts = contacts;

      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(detailPresenter.contactForm.phones)
        .afterAction(() => {
          result = true;
        });
      detailPresenter.dealContactsToForm();
      expect(detailPresenter.contactForm.displayName).assertEqual('roxy');
      expect(detailPresenter.contactForm.photoFirstName).assertEqual('ROXY');
      expect(detailPresenter.contactForm.company).assertEqual('company1');
      expect(JSON.stringify(detailPresenter.contactForm.phones)).assertEqual(JSON.stringify([{
        data: PhoneNumber.fromString(phones[0].num).getNumber(),
        num: phones[0].num,
        type: phones[0].numType,
        phoneAddress: phones[0].phoneAddress,
        labelName: phones[0].labelName,
        primary: phones[0].primary,
        dataId: phones[0].dataId,
      }]));
      expect(result).assertFalse();

      mocker.clear(detailPresenter.phoneDataSources);
    })

    it('DetailPresenterTest_dealContactsToForm_phones_empty', 0, () => {
      detailPresenter.contactForm.phones = [];
      let result = false;
      let phones: PhoneNumBean[] = [new PhoneNumBean('1', '570977632', '1', '', '', false)];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.display_name = 'roxy';
      contacts.photoFirstName = 'roxy';
      contacts.company = 'company1';
      contacts.position = 'position1';
      contacts.phones = phones;
      detailPresenter.contacts = contacts;

      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });

      detailPresenter.dealContactsToForm();

      expect(detailPresenter.contactForm.displayName).assertEqual('roxy');
      expect(detailPresenter.contactForm.photoFirstName).assertEqual('ROXY');
      expect(detailPresenter.contactForm.company).assertEqual('company1');
      expect(JSON.stringify(detailPresenter.contactForm.phones)).assertEqual(JSON.stringify([{
        data: PhoneNumber.fromString(phones[0].num).getNumber(),
        num: phones[0].num,
        type: phones[0].numType,
        phoneAddress: phones[0].phoneAddress,
        labelName: phones[0].labelName,
        primary: phones[0].primary,
        dataId: phones[0].dataId,
      }]));
      expect(result).assertTrue();
      mocker.verify('refresh', [detailPresenter.contactForm.phones]).once();

      mocker.clear(detailPresenter.phoneDataSources);
    })

    it('DetailPresenterTest_dealContactsToForm_phones', 0, () => {
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.phones = [new PhoneNumBean('labelName', '', '10000', '', '')];
      detailPresenter.contacts = contacts;
      mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh);
      detailPresenter.dealContactsToForm();
      mocker.verify('refresh', [[]]).once();
      mocker.clear(detailPresenter.phoneDataSources);
    })

    it('DetailPresenterTest_dealContactsToForm_else', 0, () => {
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.emails = [new EmailBean('', '', '')];
      contacts.aims = [new AIMBean('', '', '', '')];
      contacts.websites = [''];
      contacts.houses = [new HouseBean('1', '', '', '')];
      contacts.events = [new EventBean('1', '', '', '')];
      contacts.relationships = [new AssociatedPersonBean('1', '', '', '')];
      detailPresenter.contacts = contacts;
      mocker.mockFunc(detailPresenter.detailInfoRemarksSources, detailPresenter.detailInfoRemarksSources.refresh);
      detailPresenter.dealContactsToForm();
      mocker.verify('refresh', [[]]).times(6);
      mocker.clear(detailPresenter.detailInfoRemarksSources);
    })

    it('DetailPresenterTest_dealContactsToForm_event', 0, () => {
      detailPresenter.contactForm.events = [];
      let contacts: RichContactInfo = new RichContactInfo('1');
      contacts.events = [new EventBean('1', '1', '', '')];
      let checkEventValid: Function = mocker.mockFunc(StringFormatUtil, StringFormatUtil.checkEventValid);
      when(checkEventValid)('1').afterReturn(true);
      detailPresenter.contacts = contacts;
      detailPresenter.dealContactsToForm();
      expect(JSON.stringify(detailPresenter.contactForm.events)).assertEqual(JSON.stringify([{
          'data':'1',
          'type':'',
          'dataType':11,
          'contactDataId':-1
        }]));
      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_getContactCallLog_phones_empty', 0, async () => {
      detailPresenter.contactForm.phones = [];
      detailPresenter.contactForm.displayName = 'Jorge Armando Nava Vargas';

      when(mocker.mockFunc(detailPresenter, detailPresenter.subStringWithEllipsis))('Jorge Armando Nava Vargas')
        .afterReturn('Jorge A...');
      await detailPresenter.getContactCallLog();
      expect(detailPresenter.showNameLastMenu).assertEqual('Jorge A...');
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactCallLog_phones_notEmpty', 0, async () => {
      let phoneNumber: string = '570977632';
      let phone: ContackPhoneSubInfoModel = {
        num: phoneNumber,
        phoneAddress: 'Warsaw',
        primary: true,
        dataId: 1,
        data: phoneNumber
      };
      detailPresenter.contactForm.phones = [phone];

      await detailPresenter.getContactCallLog();
      expect(detailPresenter.callLogRefreshIndex).assertEqual(0);
    })

    it('DetailPresenterTest_getContactCallLog_phones_notEmpty_callback_1', 0, async () => {
      let phoneNumber: string = '570977632';
      let phone: ContackPhoneSubInfoModel = {
        num: phoneNumber,
        phoneAddress: 'Warsaw',
        primary: true,
        dataId: 1,
        data: phoneNumber
      };
      detailPresenter.contactForm.phones = [phone];

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(detailPresenter, detailPresenter.subStringWithEllipsis))('roxy').afterReturn('roxy');

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let resultSet: DataShareResultSet = {
        rowCount: 1,
        close: () => {
        },
        goToFirstRow: () => false,
        goToNextRow: () => false,
        getString: (columnIndex: number): string => 'xxx',
        getColumnIndex: (columnName: string): number => 0,
        getLong: (columnIndex: number): number => 1
      } as DataShareResultSet;
      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (
            uri: string,
            predicates: dataSharePredicates.DataSharePredicates,
            columns: Array<string>
          ): Promise<DataShareResultSet> => {
            return new Promise<DataShareResultSet>(resolve => resolve(resultSet));
          }
        } as dataShare.DataShareHelper)));

      let getRecorderMessage = mocker.mockFunc(detailPresenter, detailPresenter.getRecorderMessage);
      when(getRecorderMessage)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));

      let getDetailMessage: Function = mocker.mockFunc(detailPresenter, detailPresenter.getDetailMessage);
      when(getDetailMessage)(ArgumentMatchers.any).afterReturn([new CallDetail(
        '1', '570977632', 'roxy', '', '', CallType.IN, '', '', 0, 0, 1, '', null, 1, undefined, undefined, 1,
        -1, -1, "", "", "", "", "", -1, -1, "")]);

      await detailPresenter.getContactCallLog();

      expect(detailPresenter.showNameLastMenu).assertEqual('');
      expect(detailPresenter.lastUsedSlotId).assertEqual(-1);

      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactCallLog_phones_notEmpty_callback_0', 0, async () => {
      let phoneNumber: string = '570977632';
      let phone: ContackPhoneSubInfoModel = {
        num: phoneNumber,
        phoneAddress: 'Warsaw',
        primary: true,
        dataId: 1,
        data: phoneNumber
      };
      detailPresenter.contactForm.phones = [phone];

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
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

      let getDetailMessage = mocker.mockFunc(detailPresenter, detailPresenter.getDetailMessage);
      when(getDetailMessage)(ArgumentMatchers.any).afterReturn([]);

      let getRecorderMessage = mocker.mockFunc(detailPresenter, detailPresenter.getRecorderMessage);
      when(getRecorderMessage)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));

      mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.refresh);

      when(mocker.mockFunc(detailPresenter, detailPresenter.subStringWithEllipsis))('roxy').afterReturn('roxy');

      await detailPresenter.getContactCallLog();

      expect(detailPresenter.showNameLastMenu).assertEqual('');

      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getContactCallLog_isMyCard', 0, async () => {
      detailPresenter.isMyCard = true;
      detailPresenter.contactForm.displayName = '13801001111';
      mocker.mockFunc(detailPresenter, detailPresenter.subStringWithEllipsis);
      await detailPresenter.getContactCallLog();
      mocker.verify('subStringWithEllipsis', ['13801001111', 7]).never();
      mocker.clear(detailPresenter);
    })

    /*it('DetailPresenterTest_getNewNumCallLog_callback_0', 0, async () => {
      detailPresenter.phoneNumberShow = '570977632';

      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.totalCount))()
        .afterReturn(0);
      when(mocker.mockFunc(detailPresenter, detailPresenter.syncAndUpdateMeeTimeAbility))(ArgumentMatchers.any)
        .afterAction(() => {
        });
      mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
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

      let getDetailMessage = mocker.mockFunc(detailPresenter, detailPresenter.getDetailMessage);
      when(getDetailMessage)(ArgumentMatchers.any).afterReturn([]);

      let getRecorderMessage = mocker.mockFunc(detailPresenter, detailPresenter.getRecorderMessage);
      when(getRecorderMessage)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));

      await detailPresenter.getNewNumCallLog();

      expect(detailPresenter.contactForm.phones[0].num).assertEqual(detailPresenter.phoneNumberShow);
      expect(detailPresenter.lastUsedSlotId).assertEqual(-1);

      mocker.clear(detailPresenter.detailCallLogDataSource);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(detailPresenter);
    })*/

    it('DetailPresenterTest_getNewNumCallLog_callback_1', 0, async () => {
      detailPresenter.phoneNumberShow = '570977632';

      mocker.mockFunc(detailPresenter, detailPresenter.syncAndUpdateMeeTimeAbility);
      mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh);

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

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
              goToFirstRow: () => false,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));

      let getRecorderMessage = mocker.mockFunc(detailPresenter, detailPresenter.getRecorderMessage);
      when(getRecorderMessage)(ArgumentMatchers.any).afterReturn(new Promise<void>(resolve => resolve()));
      mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.notifyDataReload);
      mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.refresh);

      let timeDetail: Record<string, Resource | string | undefined> = {};
      timeDetail.date = '3月22日';
      timeDetail.time = '1:08';
      let getCallDetailByCallLog: Function = mocker.mockFunc(detailPresenter, detailPresenter.getCallDetailByCallLog);
      when(getCallDetailByCallLog)(ArgumentMatchers.any).afterReturn(timeDetail);

      await detailPresenter.getNewNumCallLog();

      expect(detailPresenter.contactForm.phones[0].num).assertEqual(detailPresenter.phoneNumberShow);
      expect(detailPresenter.lastUsedSlotId).assertEqual(-1);

      mocker.clear(detailPresenter.detailCallLogDataSource);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(detailPresenter);
      mocker.clear(CallLogRepository.getInstance());
    })

    it('DetailPresenterTest_removeRecorderDataHelperListener_helper_notNull', 0, async () => {
      let result = false;

      detailPresenter.callRecorderHelper = {
        off: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({} as BusinessError);
        }
      } as dataShare.DataShareHelper;
      detailPresenter.addRecorderDataHelperListener();
      detailPresenter.removeRecorderDataHelperListener();
      expect(result).assertTrue();
    })

    it('DetailPresenterTest_removeRecorderDataHelperListener_helper_null', 0, async () => {
      let result = false;

      detailPresenter.callRecorderHelper = null;
      detailPresenter.removeRecorderDataHelperListener();
      expect(result).assertFalse();
    })

    it('DetailPresenterTest_getRecorderMessage', 0, async () => {
      let result = false;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))('getRecorderMessage').afterAction(() => {
        result = true;
      });
      await detailPresenter.getRecorderMessage(0, [new CallDetail(
        '1', '570977632', 'roxy', '1', '', CallType.IN, '', '', 0, 1, 1, '', null, 1, undefined, undefined, 1,
        -1, -1, "", "", "", "", "", -1, -1, "")], true);
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('DetailPresenterTest_getRecorderMessage_callback', 0, async () => {
      let result = false;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterThrow("error context");
      let callDetailList: CallDetail[] = [new CallDetail(
        '1', '570977632', 'roxy', '1', '', CallType.IN, '', '', 0, 1, 1, '', null, 1, undefined, undefined, 1,
        -1, -1, "", "", "", "", "", -1, -1, "")];
      when(mocker.mockFunc(detailPresenter, detailPresenter.detailCallLogDataSource.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
        });
      await detailPresenter.getRecorderMessage(0, callDetailList, true);
      expect(result).assertFalse();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getDetailMessage_emptyList', 0, () => {
      expect(JSON.stringify(detailPresenter.getDetailMessage([]))).assertEqual(JSON.stringify([]));
    })

    it('DetailPresenterTest_getDetailMessage_meetime', 0, () => {
      let resultList: CallDetail[] = [];
      let originList = [new CallLog(new CallLogBuilder(1, '570977632'))];

      let callTimeDetail: Record<string, string | Resource> = {};
      callTimeDetail.time = '中午12:12';
      callTimeDetail.date = '2023年12月12日';
      originList.forEach((element: CallLog) => {
        when(mocker.mockFunc(detailPresenter, detailPresenter.getCallDetailByCallLog))(element)
          .afterReturn(callTimeDetail);
        let contactDetailCallsItem: CallDetail =
          new CallDetail(element.id.toString(), element.phoneNumber, element.displayName
            , element.createTime.toString(), element.beginTime.toString(), element.callType, '',
            element.simType.toString(),
            element.simId, element.isSatellite, element.ringDuration, element.formattedNumber,
            detailPresenter.getTalkTimeMessage(element),
            element.talkDuration, callTimeDetail.date, callTimeDetail.time, 0, -1, -1, "", "", "", "", "", -1, -1, "");
        resultList.push(contactDetailCallsItem);
      });
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))('UiExtentionAbilityFromName')
        .afterReturn('meetime');
      let result: CallDetail[] = detailPresenter.getDetailMessage(originList);
      expect(result[0].phone).assertEqual(undefined);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getDetailMessage_isFromMeeTime_false', 0, () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, '570977632'));
      let originList = [callLog];

      let callTimeDetail: Record<string, string | Resource> = {};
      callTimeDetail.time = '中午12:12';
      callTimeDetail.date = '2023年12月12日';
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))('UiExtentionAbilityFromName').afterReturn('meetime1');
      let callDetail: CallDetail =
        new CallDetail('0', '570977632', 'roxy', '', '', CallType.IN, '', '', 0, 1, 1, '', null, 0, undefined,
          undefined, 0, -1, -1, "", "", "", "", "", -1, -1, "");
      when(mocker.mockFunc(detailPresenter, detailPresenter.getCallDetailByCallLog))(callLog)
        .afterReturn(callDetail);
      let result: CallDetail[] = detailPresenter.getDetailMessage(originList);
      expect(JSON.stringify(result[0])).assertEqual(JSON.stringify(callDetail));

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getCallDetailByCallLog', 0, () => {
      let callLog: CallLog = new CallLog(new CallLogBuilder(1, '570977632'));

      let time = '1:1';
      let date = '2023年1月1日';
      when(mocker.mockFunc(detailPresenter, detailPresenter.getTimeDetailByCallTime))(callLog)
        .afterReturn({
          'time': time,
          'date': date
        });
      when(mocker.mockFunc(detailPresenter, detailPresenter.getTalkTimeMessage))(ArgumentMatchers.any)
        .afterReturn('');
      let result: CallDetail = detailPresenter.getCallDetailByCallLog(callLog, new Date());
      expect(JSON.stringify(result.dateDetail)).assertEqual(JSON.stringify(date));
      expect(JSON.stringify(result.timeDetail)).assertEqual(JSON.stringify(time));
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getTalkTimeMessage_talkDuration_0_callOut', 0, () => {
      let callBuilder = new CallLogBuilder(1, '570977632');
      callBuilder.talkDuration = 0;
      let callLog = new CallLog(callBuilder);
      expect((detailPresenter.getTalkTimeMessage(callLog) as Resource).id).assertEqual($r('app.string.blockCall').id);
    })

    it('DetailPresenterTest_getTalkTimeMessage_talkDuration_10_callOut', 0, () => {
      let callBuilder = new CallLogBuilder(1, '570977632');
      callBuilder.talkDuration = 10;
      let callLog1 = new CallLog(callBuilder);

      when(mocker.mockFunc(detailPresenter, detailPresenter.getDescriptionByDuration))(callLog1.talkDuration)
        .afterReturn($r('app.plural.secondsFormat', callLog1.talkDuration, callLog1.talkDuration));
      expect((detailPresenter.getTalkTimeMessage(callLog1) as Resource).id)
        .assertEqual($r('app.plural.secondsFormat', callLog1.talkDuration, callLog1.talkDuration).id);
      mocker.verify('getDescriptionByDuration', [callLog1.talkDuration]).once();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getTalkTimeMessage_talkDuration_10_callIn', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');

      callBuilder.callDirection = Direction.IN;
      callBuilder.answerState = AnswerState.RECEIVED;
      callBuilder.talkDuration = 10;
      let callLog2: CallLog = new CallLog(callBuilder);
      when(mocker.mockFunc(detailPresenter, detailPresenter.getDescriptionByDuration))(callLog2.talkDuration)
        .afterReturn($r('app.plural.secondsFormat', callLog2.talkDuration, callLog2.talkDuration));
      expect((detailPresenter.getTalkTimeMessage(callLog2) as Resource).id)
        .assertEqual($r('app.plural.secondsFormat', callLog2.talkDuration, callLog2.talkDuration).id);
      mocker.verify('getDescriptionByDuration', [callLog2.talkDuration]).once();
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getTalkTimeMessage_callMissed', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');

      callBuilder.callDirection = Direction.IN;
      callBuilder.answerState = AnswerState.MISSED;
      callBuilder.ringDuration = 10;
      callBuilder.ringDuration = 1;
      let callLog3 = new CallLog(callBuilder);
      when(mocker.mockFunc(detailPresenter, detailPresenter.getDescriptionByDuration))(callLog3.ringDuration)
        .afterReturn($r('app.plural.secondsFormat', 1, 1));
      expect(JSON.stringify(detailPresenter.getTalkTimeMessage(callLog3) as Resource))
        .assertEqual(JSON.stringify($r('app.plural.secondsFormat', 1, 1)));
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_getTalkTimeMessage_callReject', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      callBuilder.answerState = AnswerState.REJECT;
      let callLog4: CallLog = new CallLog(callBuilder);
      callLog4.callType = CallType.REJECTED;
      expect(JSON.stringify(detailPresenter.getTalkTimeMessage(callLog4)))
        .assertEqual(JSON.stringify($r('app.string.reject')));
    })

    it('DetailPresenterTest_getTalkTimeMessage_OTHER', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      callBuilder.answerState = AnswerState.REJECT;
      let callLog4: CallLog = new CallLog(callBuilder);
      callLog4.callType = CallType.OTHER;
      expect(JSON.stringify(detailPresenter.getTalkTimeMessage(callLog4)))
        .assertEqual(JSON.stringify($r('app.string.other_devices_answering_calls')));
    })

    it('DetailPresenterTest_getTalkTimeMessage_default', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      let callLog4: CallLog = new CallLog(callBuilder);
      callLog4.callType = CallTypeMeetime.RECEIVED_BY_OTHER;
      expect(detailPresenter.getTalkTimeMessage(callLog4)).assertEqual('');
    })

    it('DetailPresenterTest_getDescriptionByDuration_50s', 0, () => {
      let result: Resource;
      let timeDurationSeconds = 50;
      //"50秒"
      result = detailPresenter.getDescriptionByDuration(timeDurationSeconds);
      expect(JSON.stringify(result.params)).assertEqual('[50,50]');
    })

    it('DetailPresenterTest_getDescriptionByDuration_1m10s', 0, () => {
      let result: Resource;
      let timeDurationSeconds = 70;
      //"1分10秒"
      result = detailPresenter.getDescriptionByDuration(timeDurationSeconds);
      let minutes = Math.floor(timeDurationSeconds / 60);
      expect(result.id).assertEqual($r('app.string.hous_minute', minutes, timeDurationSeconds % 60).id);
    })

    it('DetailPresenterTest_getDescriptionByDuration_1h0m10s', 0, () => {
      let result: Resource;
      let timeDurationSeconds = 3610;
      //"1时0分10秒"
      result = detailPresenter.getDescriptionByDuration(timeDurationSeconds);
      let minutes = Math.floor(timeDurationSeconds / 60);
      let hours = Math.floor(minutes / 60);
      expect(result.id)
        .assertEqual($r('app.string.hous_minute_sec', hours, minutes % 60, timeDurationSeconds % 3600 % 60)
          .id);
    })

    it('DetailPresenterTest_getTimeDetailByCallTime_20231215_1317', 0, () => {
      let callBuilder = new CallLogBuilder(1, '570977632');
      //2023-12-15  20:17 GMT+0100 (Europe/Warsaw)
      callBuilder.createTime = 1702642676;
      let callLog = new CallLog(callBuilder);
      let timeDetail: Record<string, Resource | string | undefined> = {};
      timeDetail.date = '2023年12月15日';
      timeDetail.time = '20:17';

      when(mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime))().afterReturn('24');

      let result = detailPresenter.getTimeDetailByCallTime(callLog, new Date());
      expect(JSON.stringify(result.date)).assertEqual(JSON.stringify(timeDetail.date));

      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_getTimeDetailByCallTime_20240322_0108', 0, () => {
      let callBuilder = new CallLogBuilder(1, '570977632');
      callBuilder.createTime = 1711066130;
      let callLog = new CallLog(callBuilder);
      let timeDetail: Record<string, Resource | string | undefined> = {};
      timeDetail.date = '3月22日';
      timeDetail.time = {
        "id": $r('app.string.time_morning').id,
        "type": 10003,
        "params": ["8", "08"],
        "bundleName": "com.ohos.contacts",
        "moduleName": "entry_test"
      };

      when(mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime))().afterReturn('24');

      let result = detailPresenter.getTimeDetailByCallTime(callLog, new Date());

      expect(JSON.stringify(result.time)).assertEqual(JSON.stringify(timeDetail.time));

      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_getTimeDetailByCallTime_20221215_1217', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      //2022-12-15  12:17(Europe/Warsaw)
      callBuilder.createTime = 1671103076;
      let callLog: CallLog = new CallLog(callBuilder);
      let timeDetail: Record<string, Resource | string | undefined> = {};
      timeDetail.date = '2022年12月15日';
      timeDetail.time = '上午7:17';
      callLog = new CallLog(callBuilder);

      when(mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime))().afterReturn('12');
      let result = detailPresenter.getTimeDetailByCallTime(callLog, new Date());
      expect(JSON.stringify(result.date)).assertEqual(JSON.stringify(timeDetail.date));

      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_getTimeDetailByCallTime_previous_day', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      let now = new Date();
      callBuilder.createTime = Math.floor((now.getTime() / 1000) - 86400);
      let callLog: CallLog = new CallLog(callBuilder);

      when(mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime))().afterReturn('12');
      let result = detailPresenter.getTimeDetailByCallTime(callLog, new Date());
      const curDate = new Date(); //获取当前时间
      let previousDay = new Date(curDate.getTime() - 24 * 60 * 60 * 1000);
      let yearPrevious = previousDay.getFullYear();
      let monthPrevious = previousDay.getMonth() + 1;
      let datePrevious = previousDay.getDate();
      let datedayPrevious = StringFormatUtil.getMonthmessage(yearPrevious, monthPrevious - 1, datePrevious);
      expect(JSON.stringify(result.date))
        .assertEqual(JSON.stringify(datedayPrevious));

      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_getTimeDetailByCallTime_now', 0, () => {
      let callBuilder: CallLogBuilder = new CallLogBuilder(1, '570977632');
      let now = new Date();
      callBuilder.createTime = Math.floor(now.getTime() / 1000);
      let callLog: CallLog = new CallLog(callBuilder);

      when(mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime))().afterReturn('12');
      let result = detailPresenter.getTimeDetailByCallTime(callLog, new Date());
      expect(JSON.stringify(result.date)).assertEqual(JSON.stringify(""));

      mocker.clear(StringFormatUtil);
    })

    it('DetailPresenterTest_updateContact', 0, () => {
      detailPresenter.isNewNumber = true;
      detailPresenter.phoneNumberShow = '570977632';
      detailPresenter.contactId = 1;
      detailPresenter.contactForm = {
        contactId: 1,
        displayName: 'roxy',
        photoFirstName: 'roxy',
        company: '',
        position: '',
        phones: [{
          num: '570977632', phoneAddress: 'address1', primary: true, dataId: 10
        } as ContackPhoneSubInfoModel],
        emails: [],
        aims: [],
        nickname: [],
        websites: [],
        houses: [],
        events: [],
        phoneticName: [],
        remarks: '',
        relationships: [],
        numRecords: [],
        portraitColor: MorandiColor.color[0],
        detailsBgColor: MorandiColor.detailColor[0],
        favorite: 0,
        personalRingtone: '',
        personalRingtonePath: '',
        personalNotificationRingtone: '',
      } as ContactFormModel;
      detailPresenter.displayName = '123';
      detailPresenter.contacts = new RichContactInfo('2');
      detailPresenter.sourceHasParam = false;
      detailPresenter.isYellowPage = true;
      detailPresenter.markType = NumberMarkUtil.OTHER_PHONE_DESC;
      detailPresenter.markContent = '';
      let phoneNumbers: Record<string, string | undefined>[] = [{
        'phoneNumber': '570977632',
        'phoneAddress': 'address1'
      }];
      let ringtoneInfo : RingtoneInfo = {
        ringtoneName: detailPresenter.contactForm.personalNotificationRingtone,
        ringtoneFilePath: detailPresenter.contactForm.personalRingtonePath,
        ringtonePath: detailPresenter.contactForm.personalRingtone,
      }
      let contacts: AccountantParams = {
        updataShow: true,
        sourceHasParam: detailPresenter.sourceHasParam,
        contactId: Number(detailPresenter.contactId),
        nameRawContactId: Number(detailPresenter.contacts.rowContactID),
        phoneNumbers: phoneNumbers,
        disPlayName: detailPresenter.markContent,
        displayNameHighlight: true,
        relationships: detailPresenter.contacts.relationships,
        ringtoneInfo: ringtoneInfo,
        isEditMyCard: detailPresenter.isMyCard,
        avtarDeletedCallBack: () => {
          detailPresenter.photoPixelMap = null;
          detailPresenter.cardPhotoPixelMap = null;
        }
      } as AccountantParams;
      detailPresenter.updateContact();
      expect(JSON.stringify(detailPresenter.params)).assertEqual(JSON.stringify(contacts));
    })

    it('DetailPresenterTest_clearMissedCallNotificationForCurrentContact_phones_empty', 0, async () => {
      detailPresenter.contactForm.phones = [];
      await detailPresenter.clearMissedCallNotificationForCurrentContact();
      expect(detailPresenter.isNewNumber).assertTrue();
    })

    it('DetailPresenterTest_clearAllCallLog', 0, () => {
      detailPresenter.detailCallLogDataSource = new DetailCallLogDataSource();
      detailPresenter.detailCallLogDataSource.getData(0);

      let callLogBuilder = new CallLogBuilder(1, '570977632');
      callLogBuilder.displayName = 'roxy';
      callLogBuilder.talkDuration = 10;
      callLogBuilder.callDirection = Direction.IN;
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.totalCount))()
        .afterReturn(1);
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.getData))(0)
        .afterReturn({
          callLog: new CallLog(callLogBuilder),
          showTitle: true
        } as LooseObject);
      mocker.mockFunc(detailPresenter, detailPresenter.removeCallLog);

      detailPresenter.clearAllCallLog();

      mocker.verify('totalCount', []).times(2);
      mocker.verify('getData', [0]).once();
      mocker.verify('removeCallLog', [[1]]).once();

      mocker.clear(detailPresenter.detailCallLogDataSource);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_clearAllCallLog_getData_null', 0, () => {
      detailPresenter.detailCallLogDataSource = new DetailCallLogDataSource();
      detailPresenter.detailCallLogDataSource.getData(0);

      let callLogBuilder = new CallLogBuilder(1, '570977632');
      callLogBuilder.displayName = 'roxy';
      callLogBuilder.talkDuration = 10;
      callLogBuilder.callDirection = Direction.IN;
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.totalCount))()
        .afterReturn(1);
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.getData))(0)
        .afterReturn(null);
      mocker.mockFunc(detailPresenter, detailPresenter.removeCallLog);
      mocker.mockFunc(detailPresenter, detailPresenter.clearMissedCallNotificationForCurrentContact);

      detailPresenter.clearAllCallLog();

      mocker.verify('totalCount', []).times(2);
      mocker.verify('getData', [0]).once();
      mocker.verify('removeCallLog', [[undefined]]).once();

      mocker.clear(detailPresenter.detailCallLogDataSource);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_clearAllCallLog_callLog_null', 0, () => {
      detailPresenter.detailCallLogDataSource = new DetailCallLogDataSource();
      detailPresenter.detailCallLogDataSource.getData(0);

      let callLogBuilder = new CallLogBuilder(1, '570977632');
      callLogBuilder.displayName = 'roxy';
      callLogBuilder.talkDuration = 10;
      callLogBuilder.callDirection = Direction.IN;
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.totalCount))()
        .afterReturn(1);
      when(mocker.mockFunc(detailPresenter.detailCallLogDataSource, detailPresenter.detailCallLogDataSource.getData))(0)
        .afterReturn({
          callLog: null,
          showTitle: true
        } as LooseObject);
      mocker.mockFunc(detailPresenter, detailPresenter.removeCallLog);
      mocker.mockFunc(detailPresenter, detailPresenter.clearMissedCallNotificationForCurrentContact);

      detailPresenter.clearAllCallLog();

      mocker.verify('totalCount', []).times(2);
      mocker.verify('getData', [0]).once();
      mocker.verify('removeCallLog', [[undefined]]).once();

      mocker.clear(detailPresenter.detailCallLogDataSource);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_removeCallLog', 0, () => {
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      let deleted = false;
      when(getDefaultUIContext)().afterAction(() => {
        deleted = true;
        return context;
      });
      let removed = false;
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))("deleteCallLogsById").afterAction(() => {
        removed = true;
      });
      detailPresenter.removeCallLog([1]);
      expect(removed).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('DetailPresenterTest_removeCallLog_callback', 0, () => {
      let removed: Boolean = false;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterAction(() => {
        removed = true;
        return context;
      });
      detailPresenter.removeCallLog([]);
      expect(removed).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_backPageByCancelSave', 0, () => {
      let pathInfos: NavPathStack = new NavPathStack();
      pathInfos.pushPath(new NavPathInfo('path1', ''));
      detailPresenter.backPageByCancelSave(pathInfos);
      expect(JSON.stringify(pathInfos.getIndexByName('path1'))).assertEqual('[]')
    })

    it('DetailPresenterTest_doDeleteContact', 0, async () => {
      let deletedId: Boolean = false;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))("deleteContactById").afterAction(() => {
        deletedId = true;
      });
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn({
          area: 0,
        } as common.UIAbilityContext);
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('speedDialObjString')
        .afterReturn(new Promise<String>(resolve => resolve('speedString')));
      await detailPresenter.doDeleteContact(0);
      expect(deletedId).assertFalse();

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('DetailPresenterTest_doDeleteContact_index_default', 0, async () => {
      let deletedId: Boolean = false;

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);
      when(mocker.mockFunc(workerWrapper, workerWrapper.sendRequest))("deleteContactById").afterAction(() => {
        deletedId = true;
      });
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))()
        .afterReturn({
          area: 0,
        } as common.UIAbilityContext);
      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('speedDialObjString')
        .afterReturn(new Promise<String>(resolve => resolve('speedString')));
      await detailPresenter.doDeleteContact();
      expect(deletedId).assertFalse();

      mocker.clear(sharedPreferencesUtils);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('DetailPresenterTest_doDeleteContact_callback_1', 0, async () => {
      let deletedId: Boolean = false;
      detailPresenter.contactId = 1;
      let speedStringObj: Record<string, SpeedDialItem | null> = {
        'speedStr': {
          contactId: '1',
          contactName: 'roxy',
          contactTelephone: '570977632',
        } as SpeedDialItem
      };

      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('speedDialObjString')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve(JSON.stringify(speedStringObj))));

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            deletedId = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let uiExtentionSession: UIExtensionContentSession = {
        sendData: (data) => {
        }
      } as UIExtensionContentSession;

      when(mocker.mockFunc(detailPresenter, detailPresenter.backPageByCancelSave))(uiExtentionSession)
        .afterAction(() => {
          deletedId = true;
        });

      await detailPresenter.doDeleteContact(0);

      expect(deletedId).assertFalse();

      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_doDeleteContact_callback_0_fromSmsList_false', 0, async () => {
      let deletedId: Boolean = false;
      detailPresenter.fromSmsList = false;
      detailPresenter.contactId = 1;

      let speedStringObj: Record<string, SpeedDialItem | null> = {
        'speedStr': {
          contactId: '1',
          contactName: 'roxy',
          contactTelephone: '570977632',
        } as SpeedDialItem
      };

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);

      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('speedDialObjString')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve(JSON.stringify(speedStringObj))));

      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);

      ContactRepository.getInstance().init(uiContext);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            deletedId = true;
            return new Promise<number>(resolve => resolve(0));
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(detailPresenter, detailPresenter.backPageByCancelSave))(ArgumentMatchers.any)
        .afterAction(() => {
          deletedId = true;
        });

      let getAppContext: Function = mocker.mockFunc(uiContext, uiContext.getApplicationContext);
      when(getAppContext)().afterReturn({
        filesDir: ''
      } as common.ApplicationContext);

      mocker.mockFunc(PixelMapManager.getInstance(), PixelMapManager.getInstance().deletePixelMap);

      await detailPresenter.doDeleteContact(0);

      expect(deletedId).assertTrue();
      mocker.clear(PixelMapManager.getInstance());
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(uiContext);
      mocker.clear(detailPresenter);
      AppStorage.clear();
    })

    it('DetailPresenterTest_doDeleteContact_callback_0_fromSmsList_true', 0, async () => {
      detailPresenter.fromSmsList = true;
      detailPresenter.contactId = -1;

      let speedStringObj: Record<string, SpeedDialItem | null> = {
        'speedStr': {
          contactId: '1',
          contactName: 'roxy',
          contactTelephone: '570977632',
        } as SpeedDialItem
      };

      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workerWrapper);

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);

      when(mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences))('speedDialObjString')
        .afterReturn(new Promise<data_preferences.ValueType>(resolve => resolve(JSON.stringify(speedStringObj))));

      mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.saveToPreferences);
      when(mocker.mockFunc(detailPresenter, detailPresenter.cancel))()
        .afterAction(() => {
          expect(AppStorage.get('DetailDeleteContact')).assertEqual(1);
        });

      let getAppContext: Function = mocker.mockFunc(uiContext, uiContext.getApplicationContext);
      when(getAppContext)().afterReturn({
        filesDir: ''
      } as common.ApplicationContext);
      mocker.mockFunc(detailPresenter, detailPresenter.cancel);

      await detailPresenter.doDeleteContact(0);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(uiContext);
      mocker.clear(detailPresenter);
      AppStorage.clear();
    })

    it('DetailPresenterTest_sendMessage', 0, () => {
      let sentMessage: Boolean = false;
      let telephone: string = '570977632';
      let telephoneFormat: string = '570977632';
      let name: string = 'roxy';

      let phoneNumber: PhoneNumber = new PhoneNumber(telephone);
      when(mocker.mockFunc(phoneNumber, phoneNumber.sendMessage))(telephoneFormat);
      let uiContext: common.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions) => {
          sentMessage = true;
          return new Promise<void>(resolve => resolve());
        }
      } as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);
      detailPresenter.sendMessage(telephone, telephoneFormat, name);
      expect(sentMessage).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(phoneNumber);
    })

    it('DetailPresenterTest_linkMeeTimeCall', 0, async () => {
      let isSuccess: Boolean = false;

      when(mocker.mockFunc(CallServiceManager.getInstance(), CallServiceManager.getInstance()
        .placeCall))('570977632')
        .afterAction(() => {
          isSuccess = true;
          return new Promise<boolean>(resolve => resolve(true))
        });
      detailPresenter.linkMeeTimeCall('570977632', 1);
      expect(isSuccess).assertTrue();

      mocker.clear(CallServiceManager.getInstance());
    })

    it('DetailPresenterTest_linkMeeTimeVideo', 0, () => {
      let isSuccess = false;

      when(mocker.mockFunc(CallServiceManager.getInstance(), CallServiceManager.getInstance()
        .placeCall))('570977632')
        .afterAction(() => {
          isSuccess = true;
          return new Promise<boolean>(resolve => resolve(true))
        });
      detailPresenter.linkMeeTimeVideo('570977632', 1);
      expect(isSuccess).assertTrue();

      mocker.clear(CallServiceManager.getInstance());
    })

     it('DetailPresenterTest_isMeeTimeLogin', 0, async () => {
      when(mocker.mockFunc(MeeTimeService, MeeTimeService.isMeeTimeLogin))().afterReturn(false);
      let result: Boolean = await detailPresenter.isMeeTimeLogin();
      expect(result).assertFalse();
      mocker.clear(MeeTimeService);
    })

    it('DetailPresenterTest_setPhonePrimary_isEmpty', 0, () => {
      detailPresenter.contactForm.phones = [];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);
      detailPresenter.setPhonePrimary(1, false);
      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_setPhonePrimary_lengthLessThanIndex', 0, () => {
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: true,
        dataId: 2
      } as ContackPhoneSubInfoModel, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
        dataId: 1
      } as ContackPhoneSubInfoModel];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);
      detailPresenter.setPhonePrimary(3, false);
      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_setPhonePrimary_IndexLessThan0', 0, () => {
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: true,
        dataId: 2
      } as ContackPhoneSubInfoModel, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
        dataId: 1
      } as ContackPhoneSubInfoModel];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);
      detailPresenter.setPhonePrimary(-1, false);
      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_setPhonePrimary_dataPrimaryEqualParamPrimary', 0, () => {
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: true,
        dataId: 2
      } as ContackPhoneSubInfoModel, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
        dataId: 1
      } as ContackPhoneSubInfoModel];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);
      detailPresenter.setPhonePrimary(1, false);
      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_setPhonePrimary_primaryTrue', 0, () => {
      let setSuccess: Boolean = false;
      let refreshSuccess: Boolean = false;
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: false,
        dataId: 1
      }, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
        dataId: 2
      }, {
        num: '570977634',
        phoneAddress: '',
        primary: false,
        dataId: 3
      }];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('setPrimary').afterAction(() => {
        setSuccess = true;
      });
      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          refreshSuccess = true;
        });
      detailPresenter.setPhonePrimary(1, true);
      expect(setSuccess).assertTrue();
      expect(refreshSuccess).assertTrue();
      expect(JSON.stringify(detailPresenter.contactForm.phones))
        .assertEqual('[{"num":"570977633","phoneAddress":"","primary":true,"dataId":2},{"num":"570977632","phoneAddress":"","primary":false,"dataId":1},{"num":"570977634","phoneAddress":"","primary":false,"dataId":3}]');

      mocker.clear(detailPresenter.phoneDataSources);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    it('DetailPresenterTest_setPhonePrimary_primaryTrue_a', 0, () => {
      let setSuccess: Boolean = false;
      let refreshSuccess: Boolean = false;
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: false,
      }, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
      }, {
        num: '570977634',
        phoneAddress: '',
        primary: false,
      }];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('setPrimary').afterAction(() => {
        setSuccess = true;
      });
      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          refreshSuccess = true;
        });
      detailPresenter.setPhonePrimary(1, true);
      expect(setSuccess).assertTrue();
      expect(refreshSuccess).assertTrue();
      expect(JSON.stringify(detailPresenter.contactForm.phones))
        .assertEqual('[{"num":"570977633","phoneAddress":"","primary":true},{"num":"570977634","phoneAddress":"","primary":false},{"num":"570977632","phoneAddress":"","primary":false}]');

      mocker.clear(detailPresenter.phoneDataSources);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    it('DetailPresenterTest_setPhonePrimary_primaryTrue_b', 0, () => {
      let setSuccess: Boolean = false;
      let refreshSuccess: Boolean = false;
      detailPresenter.contactForm.phones = [{
        num: '570977632',
        phoneAddress: '',
        primary: false,
        dataId: 1
      }, {
        num: '570977633',
        phoneAddress: '',
        primary: false,
        dataId: 2
      }, {
        num: '570977634',
        phoneAddress: '',
        primary: false,
      }];

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('setPrimary').afterAction(() => {
        setSuccess = true;
      });
      when(mocker.mockFunc(detailPresenter.phoneDataSources, detailPresenter.phoneDataSources.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          refreshSuccess = true;
        });
      detailPresenter.setPhonePrimary(1, true);
      expect(setSuccess).assertTrue();
      expect(refreshSuccess).assertTrue();
      expect(JSON.stringify(detailPresenter.contactForm.phones))
        .assertEqual('[{"num":"570977633","phoneAddress":"","primary":true,"dataId":2},{"num":"570977634","phoneAddress":"","primary":false},{"num":"570977632","phoneAddress":"","primary":false,"dataId":1}]');

      mocker.clear(detailPresenter.phoneDataSources);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    // defect density
    it('DetailPresenterTest_changeTopBarBackgroundColor_isTopForItem_true', 0, () => {
      detailPresenter.changeTopBarBackgroundColor(true);
      expect(detailPresenter.topbarBackgroundColor).assertEqual(Color.White);
    })

    it('DetailPresenterTest_changeTopBarBackgroundColor_isTopForItem_false', 0, () => {
      detailPresenter.changeTopBarBackgroundColor(false);
      expect(detailPresenter.topbarBackgroundColor).assertEqual(Color.Transparent);
    })

    it('DetailPresenterTest_getTopBarBackgroundColor', 0, () => {
      expect(detailPresenter.getTopBarBackgroundColor()).assertEqual(detailPresenter.topbarBackgroundColor);
    })

    it('DetailPresenterTest_subStringWithEllipsis', 0, () => {
      expect(detailPresenter.subStringWithEllipsis('roxy', 4)).assertEqual('roxy..');
      expect(detailPresenter.subStringWithEllipsis('欧阳小梅', 7)).assertEqual('欧阳小..');
      expect(detailPresenter.subStringWithEllipsis('Jorge Armando Nava Vargas', 7)).assertEqual('Jorge A..');
    })

    it('DetailPresenterTest_updateFavorite', 0, () => {
      detailPresenter.contactId = 1;
      let updateSuccess = false;

      let workWrapper = new WorkerWrapper(WorkerType.DataWorker, false);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('updateFavorite').afterAction(() => {
        updateSuccess = true;
      });

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(uiContext);

      detailPresenter.updateFavorite(1);

      expect(updateSuccess).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    it('DetailPresenterTest_updateFavorite_callback', 0, async () => {
      detailPresenter.contactId = 1;
      let updateSuccess = false;

      let workWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);

      let uiContext: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterAction(() => {
        updateSuccess = true;
        return uiContext;
      });

      when(mocker.mockFunc(ContactRepository.getInstance().init(uiContext), ContactRepository.getInstance()
        .init(uiContext)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      detailPresenter.updateFavorite(1);

      expect(updateSuccess).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(uiContext));
    })

    it('DetailPresenterTest_saveExistingContact', 0, async () => {
      detailPresenter.phoneNumberShow = '570977632';
      // contactParam
      detailPresenter.contactForm = {
        contactId: 1,
        displayName: 'roxy',
        photoFirstName: 'roxy',
        company: '',
        position: '搬砖工',
        phones: [{
          num: '570977632', phoneAddress: 'address1', primary: true, dataId: 10
        } as ContackPhoneSubInfoModel],
        emails: [],
        aims: [],
        nickname: [],
        websites: [],
        houses: [],
        events: [],
        phoneticName: [],
        remarks: '',
        relationships: [],
        numRecords: [],
        portraitColor: MorandiColor.color[0],
        detailsBgColor: MorandiColor.detailColor[0],
        favorite: 0,
        personalRingtone: '',
        personalRingtonePath: '',
        personalNotificationRingtone: '',
      } as ContactFormModel;
      detailPresenter.contactId = 1;
      const params: Record<string, string | number | ContactFormModel | ContackPhoneSubInfoModel[]> = {
        'phoneNumberShow': '570977632',
        'contactForm': detailPresenter.contactForm,
        'contactId': 1,
        'phones': detailPresenter.contactForm.phones,
        'editContact': 1,
        'selectType': 0
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).afterReturn(new Promise<void> ((resolve: Function) =>{
        resolve();
      }))
      detailPresenter.pathInfos?.pushPathByName('SingleSelectContactPage', params)
      detailPresenter.pathInfos?.pushPathByName('SingleSelectContactPage', params)
      detailPresenter.saveExistingContact();
      expect(JSON.stringify(detailPresenter.pathInfos?.getParamByName('SingleSelectContactPage')))
        .assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('DetailPresenterTest_cancel_getDefaultUIContext_null', 0, () => {
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))()
        .afterReturn(null);

      detailPresenter.cancel();

      expect(detailPresenter.contactId).assertEqual(-1);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_cancel', 0, () => {
      let result = false;

      const context: common.UIAbilityContext = {
        terminateSelfWithResult: (parameter: common.AbilityResult) => {
          return new Promise<void>(resolve => resolve());
        }
      } as common.UIAbilityContext;

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))()
        .afterReturn(context);
      when(mocker.mockFunc(context, context.terminateSelfWithResult))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>((resolve: () => void, reject: () => void) => {
          result = true;
          reject();
        }))
      detailPresenter.cancel();
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(context);
    })

    it('DetailPresenterTest_cancel_error', 0, () => {
      let result = false;

      const context: common.UIAbilityContext = {
        terminateSelfWithResult: (parameter: common.AbilityResult) => {
          result = true;
          return new Promise<void>(resolve => resolve());
        }
      } as common.UIAbilityContext;

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))()
        .afterReturn(context);
      detailPresenter.cancel();
      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_getNoNetWorkMsg_audio', 0, () => {
      expect(JSON.stringify(detailPresenter.getNoNetWorkMsg(DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO)))
        .assertEqual(JSON.stringify($r("app.string.meetime_audio_connect_net_msg")));
    })

    it('DetailPresenterTest_getNoNetWorkMsg_video', 0, () => {
      expect(JSON.stringify(detailPresenter.getNoNetWorkMsg(DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO)))
        .assertEqual(JSON.stringify($r("app.string.meetime_video_connect_net_msg")));
    })

    it('DetailPresenterTest_getNoNetWorkMsg_chat', 0, () => {
      expect(JSON.stringify(detailPresenter.getNoNetWorkMsg(DetailPresenter.ABILITY_TYPE_AND_INDEX_CHAT)))
        .assertEqual(JSON.stringify($r("app.string.meetime_chat_connect_net_msg")));
    })

    it('DetailPresenterTest_openMeetimeAbility_audio', 0, () => {
      let type: number = -1;
      when(mocker.mockFunc(detailPresenter, detailPresenter.linkMeeTimeCall))(ArgumentMatchers.any).afterAction(() => {
        type = 0;
      });
      detailPresenter.openMeetimeAbility(DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO, false, undefined, undefined);
      expect(type).assertEqual(0);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_openMeetimeAbility_video', 0, () => {
      let type: number = -1;
      when(mocker.mockFunc(detailPresenter, detailPresenter.linkMeeTimeVideo))(ArgumentMatchers.any).afterAction(() => {
        type = 1;
      });
      detailPresenter.openMeetimeAbility(DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO, true, undefined, undefined);
      expect(type).assertEqual(1);
      mocker.clear(detailPresenter);
    })

    it('DetailPresenterTest_returnDesktop', 0, () => {
      let returned = false;

      let context: common.UIAbilityContext = {
        terminateSelf: () => {
          returned = true;
          return new Promise<void>(resolve => resolve())
        }
      } as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      detailPresenter.returnDesktop();
      expect(returned).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_returnDesktop_error', 0, () => {
      let returned = false;

      let context: common.UIAbilityContext = {
        terminateSelf: () => {
          returned = true;
          return new Promise<void>((resolve: () => void, reject: () => void) => {
            reject()
          });
        }
      } as common.UIAbilityContext;
      let getDefaultUIContext = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      detailPresenter.returnDesktop();
      expect(returned).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DetailPresenterTest_filterContactId_sourceHasId_false', 0, () => {
      detailPresenter.filterContactId();
      expect(detailPresenter.theoryAlltheoryScreenHeight).assertEqual(780);
    })

    it('DetailPresenterTest_filterContactId_sourceHasId_true', 0, () => {
      detailPresenter.sourceHasId = true;
      detailPresenter.filterContactId();
      expect(detailPresenter.theoryBackgroundHeight).assertEqual(202);
    })

    it('DetailPresenterTest_filterContactId_sourceHasId_true_contactId_1', 0, () => {
      detailPresenter.sourceHasId = true;
      detailPresenter.sourceHasPhone = true;
      detailPresenter.phoneNumberShow = '570977632';
      detailPresenter.contactId = 1;
      detailPresenter.filterContactId();
      expect(detailPresenter.changeColor).assertFalse();
    })

    it('DetailPresenterTest_hasVoice', 0, () => {
      let capabilityInfo: CapabilityInfo = new CapabilityInfo();
      expect(capabilityInfo.hasVoice).assertEqual(0);
      expect(capabilityInfo.hasVideo).assertEqual(0);
      expect(capabilityInfo.hasMessage).assertEqual(0);
    })

    it('DetailPresenterTest_getContactIdByRawId', 0, async () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let contactsGlobalThisHelper: ContactsGlobalThisHelper = ContactsGlobalThisHelper.GetGlobalThis();
      let workerWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(contactsGlobalThisHelper, contactsGlobalThisHelper.getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)(ArgumentMatchers.any).afterReturn(() => {
        result = true;
      });
      detailPresenter.getContactIdByRawId(1);
      expect(result).assertFalse();
      mocker.clear(contactsGlobalThisHelper);
      mocker.clear(workerWrapper);
    })

    it('DetailPresenterTest_updateMeetingAbilityStranger', 0, () => {
      detailPresenter.updateMeetimeAbilityStranger('', 1);
      let deviceInfo: DeviceInfo = {
        deviceType: 1,
        deviceTypeName: '1',
        isPrivate: false,
        deviceComId: '1',
        profile: '1',
        policy: '1',
        sdkVersion: '1',
        deviceIndex: 0,
        deviceNotes: '1',
        latestLoginTime: 0,
        registerTime: 0,
        publicName: '1'
      }
      let allDeviceList: DeviceInfo[] = [deviceInfo];
      let capabilityInfo: CapabilityInfo = {
        phoneNumber: '+8613801009999',
        accountId: '1',
        hasVoice: 0,
        hasVideo: 0,
        hasMessage: 0,
        allDeviceList: allDeviceList,
        nickName: 'name'
      };
      detailPresenter.meeTimeAbilityInfoModel.extra4 = 1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(detailPresenter, detailPresenter.updateMeeTimeAbility);
      mocker.mockFunc(detailPresenter, detailPresenter.printMeeTimeAbilityInfo);
      let meeTimeDeviceInfoModel: MeeTimeDeviceInfoModel =
        new MeeTimeDeviceInfoModel(deviceInfo.deviceComId, deviceInfo.deviceType, deviceInfo.profile);
      let meeTimeDeviceInfoModelList: MeeTimeDeviceInfoModel[] = [];
      meeTimeDeviceInfoModelList.push(meeTimeDeviceInfoModel);

      let syncResult: string = JSON.stringify(capabilityInfo);
      let result: MeeTimeAbilityInfoModel = new MeeTimeAbilityInfoModel('1', 'name', '', 0);
      result.phoneNumber = '13801009999';
      result.contactId = 1;
      result.meeTimeDeviceInfoModelArr = meeTimeDeviceInfoModelList;
      detailPresenter.updateMeetimeAbilityStranger(syncResult, 1);
      expect(JSON.stringify(detailPresenter.meeTimeAbilityInfoModel)).assertEqual(JSON.stringify(result));
    })

    it('transmitYellowPage', 0, () => {
      let contact: Map<string, string> = new Map();
      contact.set('13312345671', '13312345671');
      contact.set('2', '13711112222');
      let numbers1: string[] = ['1', '2'];
      detailPresenter.transmitYellowPage(contact, numbers1);
      expect(detailPresenter.contactForm.phones.length > 0).assertTrue();
    })

    it('DetailPresenterTest_transmitYellowPage_02', 0, () => {
      detailPresenter.contactForm = {
        contactId: -1,
        displayName: '',
        photoFirstName: '',
        company: '',
        position: '',
        phones: [{
          num: '1',
          data: '1',
          labelName: '1'
        }],
        emails: [],
        aims: [],
        nickname: [],
        websites: [],
        houses: [],
        events: [],
        phoneticName: [],
        remarks: '',
        relationships: [],
        numRecords: [],
        portraitColor: MorandiColor.color[0],
        detailsBgColor: MorandiColor.detailColor[0],
        favorite: 0,
        personalRingtone: '',
        personalRingtonePath: '',
        personalNotificationRingtone: '',
      }
      let contact: Map<string, string> = new Map();
      contact.set('1', '13801001111');
      let numbers: string[] = ['1'];
      detailPresenter.transmitYellowPage(contact, numbers);
      expect(detailPresenter.contactForm.displayName as string).assertEqual('13801001111');
    })

    it('DetailPresenterTest_filterFamilyDevice', 0, () => {
      let deviceInfoModelArr: MeeTimeDeviceInfoModel[] = [new MeeTimeDeviceInfoModel('contact', 4, '')];
      expect(JSON.stringify(detailPresenter.filterFamilyDevice(deviceInfoModelArr)))
        .assertEqual(JSON.stringify(deviceInfoModelArr));
    })

    it('DetailPresenterTest_delCalendarEvent', 0, async () => {
      let eventBean: EventBean = new EventBean('1', '', '', 'even1');
      eventBean.calendarEventId = '1';
      detailPresenter.contacts.events = [eventBean];
      let mocker: MockKit = new MockKit();
      await mocker.mockFunc(DynamicLoadSoUtil.getInstance(), DynamicLoadSoUtil.getInstance().loadCalendarManager);
      await detailPresenter.delCalendarEvent();
      mocker.verify('loadCalendarManager', []).once();
      mocker.clear(DynamicLoadSoUtil.getInstance());
    })
  })
}