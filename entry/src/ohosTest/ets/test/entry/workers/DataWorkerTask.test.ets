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
import { describe, it, expect, MockKit, when, beforeEach, afterEach, ArgumentMatchers } from '@ohos/hypium';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { CallLog, CallLogRepository } from '../../../../../../../feature/call';
import CallLogSetting from '../../../../../../../feature/call/src/main/ets/CallLogSetting';
import { ContactInfo } from '../../../../../main/ets/model/bean/ContactInfo';
import { ContactVo } from '../../../../../main/ets/model/bean/ContactVo';
import { FavoriteBean } from '../../../../../main/ets/model/bean/FavoriteBean';
import { PhoneNumBean } from '../../../../../main/ets/model/bean/PhoneNumBean';
import CallLogModel from '../../../../../main/ets/model/calllog/CalllogModel';
import ContactAbilityModel from '../../../../../main/ets/model/ContactAbilityModel';
import { AllCallsGetActionData, ContactBlobSource, ContactReturnObj } from '../../../../../main/ets/model/type';
import {
  AllContactGetParam,
  AllContactWithPhoneNumbersGetParam,
  CallInfoGetParamsInCallback,
  ContactSearchResultData,
  CountAlphabetIndex,
  IContactSearchParams,
  IT9PhoneNumbersQueryParams
} from '../../../../../main/ets/model/type/ContactParams';
import LooseObject from '../../../../../main/ets/model/type/LooseObject';
import { DataWorkerTask } from '../../../../../main/ets/workers/DataWorkerTask';
import { CallLog as CallLogClass, CallType } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { GroupBean } from '../../../../../main/ets/model/bean/GroupBean';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../testability/TestAbility';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import CallDetail from '../../../../../main/ets/model/bean/CallDetail';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';

/**
 *   WorkerWrapper是线程包装类，内部有线程对象信息
 * 发送请求，将请求信息发送给线程，让线程去执行
 * 线程接收消息处理：
 * DataWorkerTask 继承自 WorkerTask；
 * （1）线程收到消息，获得此线程的DataWorkerTask单例对象，并且单例对象与线程绑定；
 * （2）执行WorkerTask.onmessage 方法-》根据请求参数，执行runInWorker，查询数据库操作 -》 操作完成后，触发回调，向线程发送操作结果信息
 */
export default function DataWorkerTaskTest() {

  // 执行所有用例
  describe('DataWorkerConstantTest', () => {

    let context: common.UIAbilityContext;
    let mocker: MockKit;
    let contactRepository: ContactRepository;

    beforeEach(() => {
      context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      mocker = new MockKit();
      contactRepository = ContactRepository.getDTTestInstance();
      when(mocker.mockFunc(ContactRepository, ContactRepository.getInstance))().afterReturn(contactRepository);
    })

    afterEach(() => {
      mocker.clear(ContactRepository);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
    })

    // defect density
    it('DataWorkerConstantTest_getInstance', 0, () => {
      expect(DataWorkerTask.getInstance() instanceof DataWorkerTask).assertTrue();
    })

    // 获取所有电话
    it('DataWorkerConstantTest_getAllCalls', 0, () => {
      let actionData: AllCallsGetActionData = {};

      let favoriteForm: Record<string, number> = {
        'favorite': (true) ? 0 : -1
      };

      actionData.mergeRule = CallLogSetting.getInstance().getMergeRule();
      actionData.favoriteForm = JSON.stringify(favoriteForm);
      actionData.page = 1;
      actionData.limit = 50;

      let param: Record<string, Context | AllCallsGetActionData> = {
        'context': context,
        'actionData': actionData,
      };
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences))('isCallSettingDataChangeGroupByValue')
        .afterReturn('contacts');

      CallLogRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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
      when(mocker.mockFunc(CallLogModel, CallLogModel.getAllCalls))(ArgumentMatchers.any).afterAction(() => {
        result = true;
      })
      DataWorkerTask.getInstance().runInWorker("getAllCalls", (data: CallInfoGetParamsInCallback) => {
        callback();
      }, param);
      mocker.clear(CallLogModel);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DataWorkerConstantTest_getAllCalls_prams_undefined', 0, () => {
      let actionData: AllCallsGetActionData = {};

      let favoriteForm: Record<string, number> = {
        'favorite': (true) ? 0 : -1
      };

      actionData.mergeRule = CallLogSetting.getInstance().getMergeRule();
      actionData.favoriteForm = JSON.stringify(favoriteForm);
      actionData.page = 1;
      actionData.limit = 50;

      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      when(mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences))('isCallSettingDataChangeGroupByValue')
        .afterReturn('contacts');

      CallLogRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getAllCalls", (data: CallInfoGetParamsInCallback) => {
        callback();
      });
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DataWorkerConstantTest_getFirstMissedCall', 0, () => {
      let param: LooseObject = {
        'actionData': {
          favoriteForm: ''
        },
        "context": context,
      };
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getFirstMissedCall", (data: CallInfoGetParamsInCallback) => {
        callback()
      }, param);
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    // defect density DataWorkerConstantTest_getFirstMissedCall_prams_undefined
    it('DataWorkerConstantTest_getFirstMissedCall_prams_undefined', 0, () => {
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getFirstMissedCall", (data: CallInfoGetParamsInCallback) => {
        callback()
      });
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
    // 根据手机号查通话记录
    it('DataWorkerConstantTest_findByNumberIn', 0, () => {
      let param: LooseObject = {
        'context': context,
        'actionData': {
          'numbers': []
        },
      };
      let result = false;
      let callBack = (data: CallLog[]) => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("findByNumberIn", callBack, param);

      expect(result).assertTrue();
    })

    // defect density DataWorkerConstantTest_findByNumberIn_prams_undefined
    it('DataWorkerConstantTest_findByNumberIn_prams_undefined', 0, () => {
      let numbers: string[] = [];
      let param: LooseObject = {
        'context': context,
        'actionData': numbers,
      };
      let result = false;
      let callBack = (data: CallLog[]) => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("findByNumberIn", callBack, param);

      expect(result).assertTrue();
    })
    // 根据id删除通话记录
    it('DataWorkerConstantTest_deleteContactById', 0, () => {
      let param: LooseObject = {
        'context': context,
        'contactId': -1,
      };

      let result = false;
      let callback = () => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("deleteContactById", (data: CallInfoGetParamsInCallback) => {
        callback()
      }, param);

      expect(result).assertTrue();
    })

    // defect density DataWorkerConstantTest_deleteContactById_prams_undefined
    it('DataWorkerConstantTest_deleteContactById_prams_undefined', 0, () => {
      let callback = () => {
      };

      DataWorkerTask.getInstance().runInWorker("deleteContactById", (data: CallInfoGetParamsInCallback) => {
        callback()
      });

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');
    })

    it('DataWorkerConstantTest_deleteContactByIds', 0, () => {
      let param: LooseObject = {
        'context': context,
        'ids': []
      };

      let result = false;
      let callback = () => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("deleteContactByIds", (data: CallInfoGetParamsInCallback) => {
        callback()
      }, param);
      expect(result).assertTrue();
    })

    it('DataWorkerConstantTest_deleteContactByIds_prams_undefined', 0, () => {
      let result = false;
      let callback = () => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("deleteContactByIds", (data: CallInfoGetParamsInCallback) => {
        callback()
      });

      expect(result).assertTrue();
    })

    it('DataWorkerConstantTest_deleteCallLogsById', 0, () => {
      let param: LooseObject = {
        "ids": [],
        "context": context,
      }
      let result = false;
      let callback = () => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("deleteCallLogsById", callback, param)

      expect(result).assertTrue();
    })

    it('DataWorkerConstantTest_deleteCallLogsById_prams_undefined', 0, () => {
      let result = false;
      let callback = () => {
        result = true;
      }

      DataWorkerTask.getInstance().runInWorker("deleteCallLogsById", callback);

      expect(result).assertTrue();
    })
    // 添加联系人
    it('DataWorkerConstantTest_addContact', 0, () => {
      let contactInfo: ContactInfo =
        new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      contactInfo.display_name = "DTTest联系人名称"

      let phoneNumBean1: PhoneNumBean = new PhoneNumBean("", "18515009431", "1", "", "")
      let phoneNumBean2: PhoneNumBean = new PhoneNumBean("", "18515009431", "2", "", "")
      contactInfo.phones = [phoneNumBean1, phoneNumBean2]

      let param: LooseObject = {
        "contactInfoAfter": JSON.stringify(contactInfo),
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        'isMyCard': '111'
      }

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addContact);

      let callback = () => {
      }

      DataWorkerTask.getInstance().runInWorker("addContact", (id: number) => {
        callback();
      }, param)

      mocker.verify('addContact', [contactInfo, (arg: string[]) => {
        callback();
      }, param.isMyCard, param.context]).once();

      mocker.clear(ContactAbilityModel);
    })

    // 复制联系人
    it('DataWorkerConstantTest_copyContact', 0, () => {
      let contactInfo: ContactInfo =
        new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      contactInfo.display_name = "DTTest联系人名称"

      let phoneNumBean1: PhoneNumBean = new PhoneNumBean("", "18515009431", "1", "", "")
      let phoneNumBean2: PhoneNumBean = new PhoneNumBean("", "18515009431", "2", "", "")
      contactInfo.phones = [phoneNumBean1, phoneNumBean2]

      let param: LooseObject = {
        "contactInfoAfter": JSON.stringify(contactInfo),
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addContact);

      let callback = () => {
      }

      DataWorkerTask.getInstance().runInWorker("copyContact", (id: number) => {
        callback();
      }, param)

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');

      mocker.clear(ContactAbilityModel);
    })

    // defect density copyContact prams undefined
    it('DataWorkerConstantTest_copyContact_prams_undefined', 0, () => {
      let contactInfo: ContactInfo =
        new ContactInfo("", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      contactInfo.display_name = "DTTest联系人名称"

      let phoneNumBean1: PhoneNumBean = new PhoneNumBean("", "18515009431", "1", "", "")
      let phoneNumBean2: PhoneNumBean = new PhoneNumBean("", "18515009431", "2", "", "")
      contactInfo.phones = [phoneNumBean1, phoneNumBean2]

      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addContact);

      let callback = () => {
      }

      DataWorkerTask.getInstance().runInWorker("copyContact", (id: number) => {
        callback();
      })

      expect(DataWorkerTask.getInstance().getBoolean()).assertFalse();

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_getAllAccount', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      contactRepository.init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getAllAccount", (data: CallInfoGetParamsInCallback) => {
        callback()
      }, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllAccount_prams_undefined', 0, () => {
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getAllAccount", (data: CallInfoGetParamsInCallback) => {
        callback()
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })
    // 添加联系人
    /*it('DataWorkerConstantTest_getAllContact', 0, () => {
      let actionData: AllContactGetParam = new AllContactGetParam(1, 50);

      let param: LooseObject = {
        "actionData": actionData,
        "context": context
      };

      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getAllContact", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })*/

    it('DataWorkerConstantTest_getAllContact_prams_undefined', 0, () => {
      let actionData: AllContactGetParam = new AllContactGetParam(1, 50);

      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
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

      DataWorkerTask.getInstance().runInWorker("getAllContact", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllContactWithPhoneNumbers', 0, () => {
      let addParams: AllContactWithPhoneNumbersGetParam = new AllContactWithPhoneNumbersGetParam(1, 1, 1, 'group');
      let param: LooseObject = {
        "favoriteForm": JSON.stringify(addParams),
        "context": context,
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result1 = false;
      let callback = () => {
        expect(result1).assertTrue();
      };

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllContactWithPhoneNumbers", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    // 根据id查询
    it('DataWorkerConstantTest_getContactById', 0, () => {
      let param: LooseObject = {
        "contactId": "1",
        "context": context,
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result1 = false;
      let callback = (result: ContactReturnObj) => {
        expect(result1).assertTrue();
      };

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactById", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactById_prams_undefined', 0, () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result1 = false;
      let callback = (result: ContactReturnObj) => {
        expect(result1).assertTrue();
      };

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactById", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactMeeTimeAbilityById', 0, () => {
      let param: LooseObject = {
        "contactId": -1,
        "context": context,
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let callback = (result: ContactReturnObj) => {
        expect(result.data).assertUndefined();
      }

      ContactRepository.getInstance().init(context);
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

      DataWorkerTask.getInstance().runInWorker("getContactMeeTimeAbilityById", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactMeeTimeAbilityById_prams_undefined', 0, () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let callback = (result: ContactReturnObj) => {
      };

      ContactRepository.getInstance().init(context);
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

      DataWorkerTask.getInstance().runInWorker("getContactMeeTimeAbilityById", callback);

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactByIdList', 0, () => {
      let param: LooseObject = {
        "contactId": ["1"],
        "context": context,
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result1 = false;
      let callback = (result: ContactReturnObj) => {
        expect(result1).assertTrue();
      }

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactByIdList", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactByIdList_prams_undefined', 0, () => {
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result1 = false;
      let callback = (result: ContactReturnObj) => {
        expect(result1).assertTrue();
      }

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactByIdList", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getIdByTelephone', 0, () => {
      let param: LooseObject = {
        "phoneNumber": "13434534",
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      };
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.getIdByTelephone);

      let callback = (result: string[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("getIdByTelephone", callback, param)

      mocker.verify(
        'getIdByTelephone', [param.phoneNumber, -1,
        (result: string[]) => {
          callback(result);
        }, param.context]).once();

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_getIdByTelephone_prams_undefined', 0, () => {
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.getIdByTelephone);

      let callback = (result: string[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("getIdByTelephone", callback)

      expect(DataWorkerTask.getInstance().getBoolean()).assertFalse();

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_isHasContactByPhoneNumAndDisplayName', 0, () => {
      let param: LooseObject = {
        "phoneNumber": "13434534",
        "displayName": "ssxxxx",
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.isHasContactByPhoneNumAndDisplayName);

      let callback = (result: boolean) => {
      };

      DataWorkerTask.getInstance().runInWorker("isHasContactByPhoneNumAndDisplayName", callback, param)

      mocker.verify(
        'isHasContactByPhoneNumAndDisplayName', [param.phoneNumber, param.displayName,
        (result: boolean) => {
          callback(result);
        }, param.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_isHasContactByPhoneNumAndDisplayName_prams_undefined', 0, () => {
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.isHasContactByPhoneNumAndDisplayName);

      let callback = (result: boolean) => {
      };

      DataWorkerTask.getInstance().runInWorker("isHasContactByPhoneNumAndDisplayName", callback);

      expect(DataWorkerTask.getInstance().getBoolean()).assertFalse()

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_updateContact', 0, () => {
      let contactInfo: ContactInfo =
        new ContactInfo("1", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      contactInfo.display_name = "DTTest联系人名称"

      let phoneNumBean1: PhoneNumBean = new PhoneNumBean("", "18515009431", "1", "", "")
      let phoneNumBean2: PhoneNumBean = new PhoneNumBean("", "18515009431", "2", "", "")
      contactInfo.phones = [phoneNumBean1, phoneNumBean2]

      let contactBefore: ContactInfo =
        new ContactInfo("1", "", "", [], [], "", "", "", [], [], [], [], [], [], 0, "", "", "", null);
      contactBefore.display_name = "DTTest联系人名称"

      let param: LooseObject = {
        "contactInfoAfter": contactInfo,
        "contactInfoBefore": contactBefore,
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        "deletePhoto": false,
        "photoBlob": null,
        "isMyCard": '111'
      };
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateContact);

      let callback = (result: string) => {
      };

      DataWorkerTask.getInstance().runInWorker("updateContact", callback, param)

      mocker.verify(
        'updateContact', [null, contactBefore, contactInfo, false,
        (result: string) => {
          callback(result);
        }, param.isMyCard, param.context]).once();

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_updateFavorite', 0, () => {
      let addParams: Record<string, string | number> = {
        "favorite": 1,
        "favoriteOrder": 1,
      }

      let param: LooseObject = {
        "favoriteForm": JSON.stringify(addParams),
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateFavorite);

      let callback = (result: number) => {

      }

      DataWorkerTask.getInstance().runInWorker("updateFavorite", callback, param)

      mocker.verify(
        'updateFavorite', [null, addParams,
        (result: number) => {
          callback(result);
        }, param.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_updateFavoriteList', 0, () => {
      let param: LooseObject = {
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      };

      let favoriteList: LooseObject = {
        "length": 0
      }

      param.favoriteList = JSON.stringify(favoriteList)
      param.favorite = false
      param.favoriteOrder = 1
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateFavoriteList);

      let callBack = (result: undefined) => {

      }

      DataWorkerTask.getInstance().runInWorker("updateFavoriteList", callBack, param)

      mocker.verify(
        'updateFavoriteList',
        [null, JSON.parse(param?.favoriteList), param?.favorite, param?.favoriteOrder, (arg: undefined) => {
          callBack(arg);
        }, param?.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_updateUsuallyList', 0, () => {
      let usuallyList: string[] = ["123234"]

      let param: LooseObject = {
        "usuallyList": JSON.stringify(usuallyList),
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateUsuallyList);

      let callback = (result: undefined) => {

      };

      DataWorkerTask.getInstance().runInWorker("updateUsuallyList", callback, param)

      mocker.verify(
        'updateUsuallyList', [null, usuallyList,
        (result: undefined) => {
          callback(result);
        }, param.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_getAllFavorite', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllFavorite", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllFavorite_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);

      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllFavorite", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getFavoriteByIndex', 0, () => {
      let param: LooseObject = {
        "context": context,
        "actionData": '',
        "index": 0
      };
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getFavoriteByIndex", callback, param)
    })

    it('DataWorkerConstantTest_getFavoriteByIndex_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getFavoriteByIndex", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllUsually', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      let result1 = false;
      let callback = (result: CallLogClass[]) => {
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllUsually", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllUsually_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: CallLogClass[]) => {
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllUsually", callback);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllUsuallyByRawContact', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      let result1 = false;
      let callback = (result: Array<LooseObject>) => {
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllUsuallyByRawContact", callback, param);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getAllUsuallyByRawContact_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: Array<LooseObject>) => {
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllUsuallyByRawContact", callback);
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DataWorkerConstantTest_getDisplayNamesFindUsually', 0, () => {
      let param: LooseObject = {
        "displayName": ["ma"],
        "usuallyPhone": ["123324"],
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getDisplayNamesFindUsually", callback, param);
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DataWorkerConstantTest_getDisplayNamesFindUsually_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: FavoriteBean[]) => {
        expect(result1).assertTrue();
      }
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getDisplayNamesFindUsually", callback);
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('DataWorkerConstantTest_moveSortFavorite', 0, () => {
      let addParams: LooseObject = {
        "id": 1,
        "favoriteOrder": 1
      }

      let param: LooseObject = {
        "favoriteForm": JSON.stringify(addParams),
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.moveSortFavorite);

      let callback = (result: string) => {
      };

      DataWorkerTask.getInstance().runInWorker("moveSortFavorite", callback, param)

      mocker.verify(
        'moveSortFavorite', [null, addParams,
        (result: string) => {
          callback(result);
        }, param.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_getSearchContact', 0, () => {
      let actionData: IContactSearchParams = {
        value: "1",
        loopRequest: false,
        startIndex: 1,
        limitNumber: 50,
      };

      let param: LooseObject = {
        "actionData": actionData,
        "context": context,
      };

      let result1 = false;
      let callback = (result: ContactSearchResultData) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getSearchContact", callback, param);
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getSearchContact_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: ContactSearchResultData) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getSearchContact", callback);
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getQueryT9PhoneNumbers', 0, () => {
      let addParams: IT9PhoneNumbersQueryParams = {
        favorite: {
          "teleNumber": "123234"
        }
      };

      let param: LooseObject = {
        "favoriteForm": JSON.stringify(addParams),
        "context": context,
      }

      let result1 = false;
      let callback = (result: ContactVo[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getQueryT9PhoneNumbers", callback, param);
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_handleCallLogSearchList', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.data = {
        "callLogList": [],
        "missedList": [],
        "callLogSearchList": [],
        "timeStamp": "1231232"
      };
      param.result = [];
      param.nameArray = [];
      param.callLogSearchList = [];
      param.timeStamp = "12321432";

      let result1 = false;
      let callback = (result: CallInfoGetParamsInCallback) => {
        result1 = true;
      };

      DataWorkerTask.getInstance().runInWorker("handleCallLogSearchList", callback, param)

      expect(result1).assertTrue();
    })

    it('DataWorkerConstantTest_handleCallLogSearchList_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: CallInfoGetParamsInCallback) => {
        result1 = true;
      };

      DataWorkerTask.getInstance().runInWorker("handleCallLogSearchList", callback)

      expect(result1).assertTrue();
    })

    /*it('DataWorkerConstantTest_getAllContactSizeAndIndex', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      let result1 = false;
      let callback = (result: CountAlphabetIndex) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllContactSizeAndIndex", callback, param);
      mocker.clear(ContactRepository.getInstance());
    })*/

    /*it('DataWorkerConstantTest_getAllContactSizeAndIndex_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: CountAlphabetIndex) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      // callback
      DataWorkerTask.getInstance().runInWorker("getAllContactSizeAndIndex", callback);
      mocker.clear(ContactRepository.getInstance());
    })*/

    it('DataWorkerConstantTest_getContactIdWithBlobNotNull', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      let result1 = false;
      let callback = (result: ContactBlobSource[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactIdWithBlobNotNull", callback, param);
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_getContactIdWithBlobNotNull_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: ContactBlobSource[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactIdWithBlobNotNull", callback);
      mocker.clear(ContactRepository.getInstance());
    })

    it('DataWorkerConstantTest_setPrimary', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      param.contactId = 1;
      param.dataType = 1;
      param.dataId = 1;
      param.primary = false;

      let result1 = false;
      let callback = (result: CountAlphabetIndex) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("setPrimary", callback, param)
    })

    it('DataWorkerConstantTest_setPrimary_prams_undefined', 0, () => {
      let result1 = false;
      let callback = (result: CountAlphabetIndex) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("setPrimary", callback)
    })

    it('DataWorkerConstantTest_addGroup', 0, () => {
      let param: LooseObject = {
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      };

      param.groupName = '234234'
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addGroup);

      let callBack = (result: string) => {

      };

      DataWorkerTask.getInstance().runInWorker("addGroup", callBack, param)

      mocker.verify('addGroup', [param?.groupName, param?.groupAccountId, (arg: string) => {
        callBack(arg);
      }, param?.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_addGroup_prams_undefined', 0, () => {
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.addGroup);

      let callBack = (result: string) => {

      };

      DataWorkerTask.getInstance().runInWorker("addGroup", callBack)

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_getAllGroup', 0, () => {
      let param: LooseObject = {
        "context": context,
      };

      param.groupName = '234234';

      let result1 = false;
      let callBack = (result: GroupBean[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllGroup", callBack, param)
    })

    it('DataWorkerConstantTest_getAllGroup_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: GroupBean[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getAllGroup", callBack)
    })

    it('DataWorkerConstantTest_renameGroup', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupInfo = {
        id: 1,
        groupName: "xxff",
      };

      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("renameGroup", callBack, param)
    })

    it('DataWorkerConstantTest_renameGroup_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("renameGroup", callBack)
    })

    it('DataWorkerConstantTest_removeGroup', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.id = 1;

      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("removeGroup", callBack, param);
    })

    it('DataWorkerConstantTest_removeGroup_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("removeGroup", callBack);
    })

    it('DataWorkerConstantTest_deleteGroupsById', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.ids = [1];

      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
          value: ValuesBucket): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1));
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("deleteGroupsById", callBack, param)
    })

    it('DataWorkerConstantTest_queryGroupItemByName', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupName = "xxdd";

      let result1 = false;
      let callBack = (result: GroupBean) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("queryGroupItemByName", callBack, param)
    })

    it('DataWorkerConstantTest_queryGroupItemByName_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: GroupBean) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("queryGroupItemByName", callBack)
    })

    it('DataWorkerConstantTest_updateGroupMemberList', 0, () => {
      let param: LooseObject = {
        "context": ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      }
      param.selectMemberList = JSON.stringify(["1234xx", "345xx"])
      param.groupId = "1"
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.updateGroupMemberList);

      let callBack = (result: string) => {
      };

      DataWorkerTask.getInstance().runInWorker("updateGroupMemberList", callBack, param)

      mocker.verify(
        'updateGroupMemberList', [JSON.parse(param?.selectMemberList), param?.groupId, (arg: string) => {
        callBack(arg);
      }, param?.context]).once();

      mocker.clear(ContactAbilityModel)
    })

    it('DataWorkerConstantTest_queryAllGroupMember', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupId = "1";

      let result1 = false;
      let callBack = (result: ContactVo[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("queryAllGroupMember", callBack, param);
    })

    it('DataWorkerConstantTest_queryAllGroupMember_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: ContactVo[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("queryAllGroupMember", callBack);
    })

    it('DataWorkerConstantTest_deleteMemberByGroupId', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupId = "1";

      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1))
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("deleteMemberByGroupId", callBack, param)
    })

    it('DataWorkerConstantTest_deleteMemberByGroupId_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: string) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1))
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("deleteMemberByGroupId", callBack);
    })

    it('DataWorkerConstantTest_deleteMembers', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupId = "1";
      param.rawContactId = [1];

      let result1 = false;
      let callBack = (result: number) => {
        expect(result1).assertFalse();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          result1 = true;
          return new Promise<number>(resolve => resolve(1))
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("deleteMembers", callBack, param)
    })

    it('DataWorkerConstantTest_deleteMembers_prams_undefined', 0, () => {
      let callBack = (result: number) => {
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
          return new Promise<number>(resolve => resolve(1))
        }
      } as dataShare.DataShareHelper)));

      DataWorkerTask.getInstance().runInWorker("deleteMembers", callBack);

      expect(DataWorkerTask.getInstance().getBoolean()).assertFalse();

    })

    it('DataWorkerConstantTest_findMemberByPhoneIsNotNull', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      param.groupId = "1";

      let result1 = false;
      let callBack = (result: ContactVo[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("findMemberByPhoneIsNotNull", callBack, param)
    })

    it('DataWorkerConstantTest_findMemberByPhoneIsNotNull_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: ContactVo[]) => {
        expect(result1).assertTrue();
      };
      ContactRepository.getInstance().init(context);
      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("findMemberByPhoneIsNotNull", callBack)
    })

    it('DataWorkerConstantTest_getContactSize', 0, () => {
      let param: LooseObject = {
        "context": context,
        "accountId": 1
      };

      let result1 = false;
      let callBack = (result: number) => {
        // expect true
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactSize", callBack, param);
    })

    it('DataWorkerConstantTest_getContactSize_prams_undefined', 0, () => {
      let result1 = false;
      let callBack = (result: number) => {
        expect(result1).assertTrue();
      };
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let getDataAbilityHelper: Function =
        mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
          .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
        query: (
          uri: string,
          predicates: dataSharePredicates.DataSharePredicates,
          columns: Array<string>
        ): Promise<DataShareResultSet> => {
          result1 = true;
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

      DataWorkerTask.getInstance().runInWorker("getContactSize", callBack);
    })

    it('DataWorkerConstantTest_getRecorderMessage', 0, () => {
      let callDetailList: CallDetail[] =
        [new CallDetail('1', '570977632', 'roxy', '', '', CallType.IN, 'tag', '0', 0, 1, 1, '', '', 1, '', '', 0,
          -1, -1, "", "", "", "", "", -1, -1, "")];
      let param: LooseObject = {
        "callDetailList": callDetailList,
      };
      mocker.mockFunc(CallLogModel, CallLogModel.getRecorderMessage);

      let callback = (result: CallDetail[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("getRecorderMessage", callback, param);

      mocker.verify(
        'getRecorderMessage', [param.CallDetailList,
        (result: CallDetail[]) => {
          callback(result);
        }]).never();
      mocker.clear(CallLogModel);
    })

    it('DataWorkerConstantTest_getRecorderMessage_prams_undefined', 0, () => {
      mocker.mockFunc(CallLogModel, CallLogModel.getRecorderMessage);

      let callback = (result: CallDetail[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("getRecorderMessage", callback);

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');

      mocker.clear(CallLogModel);
    })

    it('DataWorkerConstantTest_activateRestore', 0, () => {
      let param: LooseObject = {
        "context": context,
      };
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.activateRestore);

      let callback = (result: CallDetail[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("activateRestore", callback, param);

      // expect once
      mocker.verify(
        'activateRestore', [param.context]).once();

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_activateRestore_prams_undefined', 0, () => {
      mocker.mockFunc(ContactAbilityModel, ContactAbilityModel.activateRestore);

      let callback = (result: CallDetail[]) => {
      };

      DataWorkerTask.getInstance().runInWorker("activateRestore", callback);

      expect(DataWorkerTask.getInstance().getStr()).assertEqual('');

      mocker.clear(ContactAbilityModel);
    })

    it('DataWorkerConstantTest_default', 0, () => {
      let param: LooseObject = {};

      let callback = (arg: number) => {
      };

      DataWorkerTask.getInstance().runInWorker("", callback, param);

      // expect false
      expect(DataWorkerTask.getInstance().getBoolean()).assertFalse();
    })
  })
}