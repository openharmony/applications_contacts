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
import { FavoriteBean } from '../../../../../../main/ets/model/bean/FavoriteBean';
import {
  ContactDetailParam,
  EditFavoriteParam,
  SelectContactParam,
  SingleSelectContact
} from '../../../../../../main/ets/model/type';
import FavoriteListPresenter from '../../../../../../main/ets/presenter/favorite/FavoriteListPresenter';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import { ContactVo } from '../../../../../../main/ets/model/bean/ContactVo';
import common from '@ohos.app.ability.common';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { ContactRepository } from '../../../../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ValuesBucket } from '@kit.ArkData';
import IndexPresenter from '../../../../../../main/ets/presenter/IndexPresenter';
import { DynamicLoader } from '../../../../../../../../common';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common'
import { FavoriteListBean } from '../../../../../../main/ets/model/bean/FavoriteListBean';
import { SearchContactResult } from '../../../../../../main/ets/model/bean/SearchContactResult';
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor';

const TAG = 'FavoriteListPresenter  '

export default function FavoriteListPresenterTest() {
  describe('FavoriteListPresenterTest', () => {
    let favoriteListPresenter: FavoriteListPresenter;

    beforeEach(() => {
      AppStorage.clear();
      favoriteListPresenter = new FavoriteListPresenter();
    })

    it('FavoriteListPresenterTest_getInstance', 0, () => {
      expect(typeof FavoriteListPresenter.getInstance()).assertEqual(typeof favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_onContactChange', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);

      favoriteListPresenter.onContactChange();

      expect(typeof favoriteListPresenter.debounceTimer).assertEqual(typeof 1);
    })

    it('FavoriteListPresenterTest_aboutToAppear', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().registerDataChangeObserver);

      favoriteListPresenter.aboutToAppear();

      mocker.verify('registerDataChangeObserver', [favoriteListPresenter.onContactChange]).once();
      mocker.clear(ContactRepository.getInstance());
    })

    it('FavoriteListPresenterTest_aboutToDisappear', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().unRegisterDataChangeObserver);

      favoriteListPresenter.aboutToDisappear();

      mocker.verify('unRegisterDataChangeObserver', [favoriteListPresenter.onContactChange]).once();
      mocker.clear(ContactRepository.getInstance());
    })

    it('FavoriteListPresenterTest_refreshFavorite', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllFavorite').afterAction(() => {
        result = true;
      });
      favoriteListPresenter.refreshFavorite().then(() => {
      })
      expect(result).assertTrue();
      mocker.clear(workerWrapper);
    })

    it('FavoriteListPresenterTest_refreshFavorite_callback', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

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
                result = true
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      favoriteListPresenter.refreshFavorite().then(() => {
        expect(result).assertTrue();
      })
      mocker.clear(ContactRepository.getInstance());
    })

    it('FavoriteListPresenterTest_refreshFavorite_callback_result_empty', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(
          (resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
            reject: () => void) => {
            result = true;
            reject();
          }));
      favoriteListPresenter.refreshFavorite().then(() => {
        expect(result).assertTrue();
      });
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FavoriteListPresenterTest_refreshUsually', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllUsually').afterAction(() => {
        result = true;
      });
      favoriteListPresenter.refreshUsually()
      expect(result).assertTrue();
      mocker.clear(workerWrapper);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultCount_1_usuallySelectArray_0', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 1,
                getLong: (columnIndex: number): number => 1
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultCount_1_usuallySelectArray_1', 0, () => {
      favoriteListPresenter.usuallySelectArray.add('xxx');
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 1,
                getLong: (columnIndex: number): number => 1
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultCount_1_usuallySelectArray_11', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 1,
                getLong: (columnIndex: number): number => 1
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.usuallySelectArray.add('favorite');
      favoriteListPresenter.usuallySelectArray.add('favorite0');
      favoriteListPresenter.usuallySelectArray.add('favorite1');
      favoriteListPresenter.usuallySelectArray.add('favorite2');
      favoriteListPresenter.usuallySelectArray.add('favorite3');
      favoriteListPresenter.usuallySelectArray.add('favorite4');
      favoriteListPresenter.usuallySelectArray.add('favorite5');
      favoriteListPresenter.usuallySelectArray.add('favorite6');
      favoriteListPresenter.usuallySelectArray.add('favorite7');
      favoriteListPresenter.usuallySelectArray.add('favorite8');
      favoriteListPresenter.usuallySelectArray.add('favorite9');
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultCount_12_usuallySelectArray_11', 0, () => {
      let i = 0;
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                rowCount: 10,
                close: () => {
                },
                goToFirstRow: () => false,
                goToNextRow: () => {
                  if (i < 11) {
                    i++;
                    return true;
                  } else {
                    return false;
                  }
                },
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 1,
                getLong: (columnIndex: number): number => 1
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.usuallySelectArray.add('favorite');
      favoriteListPresenter.usuallySelectArray.add('favorite0');
      favoriteListPresenter.usuallySelectArray.add('favorite1');
      favoriteListPresenter.usuallySelectArray.add('favorite2');
      favoriteListPresenter.usuallySelectArray.add('favorite3');
      favoriteListPresenter.usuallySelectArray.add('favorite4');
      favoriteListPresenter.usuallySelectArray.add('favorite5');
      favoriteListPresenter.usuallySelectArray.add('favorite6');
      favoriteListPresenter.usuallySelectArray.add('favorite7');
      favoriteListPresenter.usuallySelectArray.add('favorite8');
      favoriteListPresenter.usuallySelectArray.add('favorite9');
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_usuallyTotalCount_10_usuallyPhoneParameterList_0', 0, () => {
      let i = 0;
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                rowCount: 11,
                close: () => {
                },
                goToFirstRow: () => false,
                goToNextRow: () => {
                  if (i < 11) {
                    i++;
                    return true;
                  } else {
                    return false;
                  }
                },
                getString: (columnIndex: number): string => 'value' + i,
                getColumnIndex: (columnName: string): number => i,
                getLong: (columnIndex: number): number => i
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      when(mocker.mockFunc(favoriteListPresenter.usuallyPhoneParameterList, favoriteListPresenter.usuallyPhoneParameterList.push))(ArgumentMatchers.any)
        .afterAction(() => {
          favoriteListPresenter.usuallyPhoneParameterList = [];
          return 0;
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.usuallySelectArray.add('value21');
      favoriteListPresenter.usuallySelectArray.add('value22');
      favoriteListPresenter.usuallySelectArray.add('value23');
      favoriteListPresenter.usuallySelectArray.add('value24');
      favoriteListPresenter.usuallySelectArray.add('value25');
      favoriteListPresenter.usuallySelectArray.add('value26');
      favoriteListPresenter.usuallySelectArray.add('value27');
      favoriteListPresenter.usuallySelectArray.add('value28');
      favoriteListPresenter.usuallySelectArray.add('value29');
      favoriteListPresenter.usuallySelectArray.add('value20');
      favoriteListPresenter.usuallySelectArray.add('value24');
      favoriteListPresenter.usuallySelectArray.add('value25');
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter.usuallyPhoneParameterList);
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultArray_equal_usuallySelectArray_11', 0, () => {
      let i = 0;
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                rowCount: 11,
                close: () => {
                },
                goToFirstRow: () => false,
                goToNextRow: () => {
                  if (i < 11) {
                    i++;
                    return true;
                  } else {
                    return false;
                  }
                },
                getString: (columnIndex: number): string => 'value' + i,
                getColumnIndex: (columnName: string): number => i,
                getLong: (columnIndex: number): number => i
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.getDisplayNamesFindUsually);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.usuallySelectArray.add('value1');
      favoriteListPresenter.usuallySelectArray.add('value2');
      favoriteListPresenter.usuallySelectArray.add('value3');
      favoriteListPresenter.usuallySelectArray.add('value4');
      favoriteListPresenter.usuallySelectArray.add('value5');
      favoriteListPresenter.usuallySelectArray.add('value6');
      favoriteListPresenter.usuallySelectArray.add('value7');
      favoriteListPresenter.usuallySelectArray.add('value8');
      favoriteListPresenter.usuallySelectArray.add('value9');
      favoriteListPresenter.usuallySelectArray.add('value10');
      favoriteListPresenter.usuallySelectArray.add('value11');
      favoriteListPresenter.usuallySelectArray.add('value12');
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshUsually_callback_resultArray_0', 0, () => {
      let i = 0;
      let result = false;
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                }
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.refreshUsually();
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshNewUsually', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllUsuallyByRawContact').afterAction(() => {
        result = true;
      });
      favoriteListPresenter.refreshNewUsually();
      expect(result).assertTrue();
      mocker.clear(workerWrapper);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FavoriteListPresenterTest_refreshNewUsually_callback', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
              getColumnIndex: (columnName: string): number => 1,
              getLong: (columnIndex: number): number => 1
            } as DataShareResultSet))
          }
        } as dataShare.DataShareHelper)));
      favoriteListPresenter.refreshNewUsually().then(() => {
        expect(result).assertTrue();
      });
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FavoriteListPresenterTest_getDisplayNamesFindUsually', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getDisplayNamesFindUsually').afterAction(() => {
        result = true;
      });
      favoriteListPresenter.getDisplayNamesFindUsually([], []);
      expect(result).assertTrue();
      mocker.clear(workerWrapper);
    })

    it('FavoriteListPresenterTest_getDisplayNamesFindUsually_callback', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);
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
                goToFirstRow: () => false,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'value',
                getColumnIndex: (columnName: string): number => 1,
                getLong: (columnIndex: number): number => 1
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper))
        });
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      favoriteListPresenter.getDisplayNamesFindUsually([], []);
      expect(result).assertTrue();
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_refreshFavoriteList', 0, () => {
      favoriteListPresenter.favoriteCount = 0;
      let favoriteBean: FavoriteBean = new FavoriteBean('1', 0, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977632'], 1);
      favoriteListPresenter.favoriteList = [favoriteBean];
      let mocker: MockKit = new MockKit();
      let result = false;
      when(mocker.mockFunc(favoriteListPresenter.favoriteDataSource, favoriteListPresenter.favoriteDataSource.refresh))(favoriteListPresenter.favoriteList)
        .afterAction(() => {
          result = true;
        });
      favoriteListPresenter.refreshFavoriteList(favoriteListPresenter.favoriteList);
      expect(favoriteListPresenter.favoriteList[0].isUsuallyShow).assertTrue();
      expect(result).assertTrue();
      mocker.clear(favoriteListPresenter.favoriteDataSource);
    })

    it('FavoriteListPresenterTest_goContactDetail_if', 0, () => {
      const params: ContactDetailParam = {
        sourceHasId: true,
        contactId: '123'
      };
      favoriteListPresenter.pathInfos = new NavPathStack();
      favoriteListPresenter.pathInfos.replacePathByName('ContactDetail', '570977632');

      favoriteListPresenter.goContactDetail('123');

      expect(favoriteListPresenter.pathInfos?.getAllPathName().toString()).assertEqual(['ContactDetail'].toString());
      expect(JSON.stringify(favoriteListPresenter.pathInfos?.getParamByIndex(0))).assertEqual(JSON.stringify('570977632'));
    })

    it('FavoriteListPresenterTest_goContactDetail_if_01', 0, () => {
      const params: ContactDetailParam = {
        sourceHasId: true,
        contactId: '123'
      };
      AppStorage.setOrCreate('breakpoint','sm')
      favoriteListPresenter.pathInfos = new NavPathStack();
      favoriteListPresenter.pathInfos.pushPathByName('ContactDetail', '570977632');

      favoriteListPresenter.goContactDetail('123');

      expect(favoriteListPresenter.pathInfos?.getAllPathName().toString()).assertEqual(['ContactDetail'].toString());
      expect(JSON.stringify(favoriteListPresenter.pathInfos?.getParamByIndex(0))).assertEqual(JSON.stringify('570977632'));
    })

    it('FavoriteListPresenterTest_setPageShow_true_00', 0, () => {
      const deleteUsuallyContactData = ['test'];
      AppStorage.setOrCreate<Array<string>>('deleteUsuallyContactData', deleteUsuallyContactData);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.deleteUsually);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('deleteUsually', [deleteUsuallyContactData]).once();
      expect(AppStorage.get<Array<string>>('deleteUsuallyContactData')?.toString()).assertEqual([].toString());
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_01', 0, () => {
      AppStorage.setOrCreate<number>('DetailDeleteContact', 1);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('requestItem', []).once();
      expect(AppStorage.get<number>('DetailDeleteContact')).assertEqual(0);
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_02', 0, () => {
      AppStorage.setOrCreate<number>('editFavoriteDrag', 1);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('requestItem', []).once();
      expect(AppStorage.get<number>('editFavoriteDrag')).assertEqual(0);
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_03_01', 0, () => {
      let contactVo = new ContactVo("", "","", "", "", "", $r("sys.color.ohos_id_color_special1"), true, "", "", '0');
      contactVo.contactId = '1';
      AppStorage.setOrCreate<Array<ContactVo>>('addFavoriteContactData', [contactVo]);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.addFavoriteInfoLocal);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('addFavoriteInfoLocal', [[contactVo], ['1']]).once();
      expect(JSON.stringify(AppStorage.get<Array<ContactVo>>('addFavoriteContactData')))
        .assertEqual(JSON.stringify([]));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_03_02', 0, () => {
      let contactVo = new ContactVo("", "", "", "", "", "", $r("sys.color.ohos_id_color_special1"), true, "", "", '0');
      contactVo.contactId = '1';
      AppStorage.setOrCreate<Array<ContactVo>>('addFavoriteContactData', [contactVo]);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.addFavoriteInfo);
      let favorite: FavoriteBean = new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '');
      favoriteListPresenter.favoriteList = [favorite]
      favoriteListPresenter.setPageShow(true);
      mocker.verify('addFavoriteInfo', [['1']]).times(0);
      expect(JSON.stringify(AppStorage.get<Array<ContactVo>>('addFavoriteContactData')))
        .assertEqual(JSON.stringify([]));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_04', 0, () => {
      AppStorage.setOrCreate<number>('cancelEditFavorite', 2);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.cancelAllFavoriteSelectInfo);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('cancelAllFavoriteSelectInfo', []).once();
      expect(AppStorage.get<number>('cancelEditFavorite')).assertEqual(0);
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_05', 0, () => {
      let favoriteBean = new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '');
      favoriteBean.contactId = '1';
      AppStorage.setOrCreate<Array<FavoriteBean>>('deleteFavoriteContactData', [favoriteBean])
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.deleteFavorite);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('deleteFavorite', [[favoriteBean]]).once();
      expect(JSON.stringify(AppStorage.get<Array<ContactVo>>('deleteFavoriteContactData')))
        .assertEqual(JSON.stringify([]));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_06_01', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      favoriteListPresenter.isShow = true;
      favoriteListPresenter.setPageShow(true);
      mocker.verify('requestItem', []).never();
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_setPageShow_true_06_02', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      favoriteListPresenter.setPageShow(true);
      mocker.verify('requestItem', []).once();
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_cancelAllFavoriteSelectInfo', 0, () => {
      let favoriteBean = new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '');
      favoriteListPresenter.favoriteList = [favoriteBean];
      favoriteListPresenter.cancelAllFavoriteSelectInfo();
      expect(favoriteListPresenter.isEditSelectList.length).assertEqual(0);
    })

    it('FavoriteListPresenterTest_cancelAllFavoriteSelectInfo_noFor', 0, () => {
      favoriteListPresenter.cancelAllFavoriteSelectInfo();
      expect(JSON.stringify(favoriteListPresenter.isEditSelectList)).assertEqual('[]');
    })

    it('FavoriteListPresenterTest_requestItem', 0, async () => {
      let favoriteBeanList = [new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '')];
      let usuallyList = [new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '')];
      let mocker: MockKit = new MockKit();
      let mockFunc1: Function = mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavorite);
      when(mockFunc1)().afterReturn(new Promise<FavoriteBean[]>((resolve) => {
        resolve(favoriteBeanList);
      }));

      let mockFunc2: Function = mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshNewUsually);
      when(mockFunc2)().afterReturn(new Promise<FavoriteBean[]>((resolve) => {
        resolve(usuallyList);
      }));

      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);

      await await favoriteListPresenter.requestItem();

      mocker.verify('refreshFavorite', []).once();
      mocker.verify('refreshNewUsually', []).never();
      mocker.verify('refreshFavoriteList', [favoriteListPresenter.favoriteList]).once();
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_requestItem_01', 0, async () => {
      let favoriteBeanList = [new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '')];
      let usuallyList = [new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '')];
      let mocker: MockKit = new MockKit();
      let mockFunc1: Function = mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavorite);
      when(mockFunc1)().afterReturn(new Promise<FavoriteBean[]>((resolve) => {
        resolve(favoriteBeanList);
      }));

      let mockFunc2: Function = mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshNewUsually);
      when(mockFunc2)().afterReturn(new Promise<FavoriteBean[]>((resolve) => {
        resolve(usuallyList);
      }));

      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);

      AppStorage.setOrCreate('mainTabsIndex',1)
      IndexPresenter.getInstance().favoriteIndex = 1

      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.emitFavoriteDefaultSelectedContact);

      await await favoriteListPresenter.requestItem();

      mocker.verify('emitFavoriteDefaultSelectedContact', []).once();
      mocker.verify('refreshFavorite', []).once();
      mocker.verify('refreshNewUsually', []).never();
      mocker.verify('refreshFavoriteList', [favoriteListPresenter.favoriteList]).once();
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_addFavoriteInfoLocal', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.refreshFavoriteList);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance().init(undefined), ContactRepository.getInstance()
        .init(undefined)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      favoriteListPresenter
        .addFavoriteInfoLocal([new ContactVo("", "", "", "", "", "", $r("sys.color.ohos_id_color_special1"), true, "", "", '0')], ['1']);

      mocker.verify('refreshFavoriteList', [favoriteListPresenter.favoriteList]);

      expect(favoriteListPresenter.favoriteCount).assertEqual(1);
      mocker.clear(ContactRepository.getInstance().init(undefined));
      mocker.clear(favoriteListPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('FavoriteListPresenterTest_addFavoriteInfo', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance().init(undefined), ContactRepository.getInstance()
        .init(undefined)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem))().afterAction(() => {
        expect(result).assertTrue();
      });
      favoriteListPresenter.addFavoriteInfo(['1']);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(undefined));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_deleteFavorite', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance().init(undefined), ContactRepository.getInstance()
        .init(undefined)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem))().afterAction(() => {
        expect(result).assertTrue();
      });

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(undefined));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_deleteUsually', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      when(mocker.mockFunc(ContactRepository.getInstance().init(undefined), ContactRepository.getInstance()
        .init(undefined)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.requestItem))().afterAction(() => {
        expect(result).assertTrue();
      });

      favoriteListPresenter.deleteUsually(['1']);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(undefined));
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_longItemEditFavorite', 0, () => {
      const favoriteBean: FavoriteBean = new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, '');
      const params: EditFavoriteParam = {
        favoriteList: [],
      };
      favoriteListPresenter.pathInfos = new NavPathStack();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire))(DynamicLoader.EDIT_FAVORITE_LIST_PAGE).afterReturn(new Promise<void>((resolve: Function, reject: Function) => {
        resolve(favoriteListPresenter.pathInfos?.pushPathByName('editFavoriteList', params));
      }))
      favoriteListPresenter.longItemEditFavorite([], [], favoriteBean);
      expect(JSON.stringify(favoriteListPresenter.pathInfos?.getParamByName('editFavoriteList'))).assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('FavoriteListPresenterTest_toDefaultPage_if', 0, () => {
      favoriteListPresenter.pathInfos = new NavPathStack();
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
      favoriteListPresenter.pathInfos.pushPathByName('path1', new NavPathInfo('path1', contact));
      AppStorage.SetOrCreate('breakpoint', 'xx');
      favoriteListPresenter.toDefaultPage();
      expect(favoriteListPresenter.pathInfos.getParamByName('FavoriteDefaultPage').toString()).assertEqual('');
    })

    it('FavoriteListPresenterTest_toDefaultPage_if_00', 0, () => {
      let mocker: MockKit = new MockKit();
      AppStorage.setOrCreate('maintenanceMode',true)
      mocker.mockFunc(favoriteListPresenter.pathInfos, favoriteListPresenter.pathInfos?.clear);
      favoriteListPresenter.toDefaultPage();
      mocker.verify('clear', [false]).once();

      AppStorage.setOrCreate('maintenanceMode',false);
      AppStorage.setOrCreate('isShowSmartWindow', true);
      AppStorage.setOrCreate('isNavigationModeSplit', false);
      AppStorage.setOrCreate('splitStatus', 1);
      mocker.mockFunc(favoriteListPresenter.pathInfos, favoriteListPresenter.pathInfos?.pushPathByName);
      favoriteListPresenter.toDefaultPage();
      mocker.verify('pushPathByName', [false]).never();

      AppStorage.setOrCreate('maintenanceMode',false);
      AppStorage.setOrCreate('isShowSmartWindow', false);
      AppStorage.setOrCreate('isNavigationModeSplit', true);
      AppStorage.setOrCreate('splitStatus', 0);
      AppStorage.setOrCreate('breakpoint', 'lg');
      favoriteListPresenter.toDefaultPage();
      mocker.verify('pushPathByName', ['FavoriteDefaultPage', '', false]).once();
      mocker.clear(favoriteListPresenter.pathInfos);
    })

    it('FavoriteListPresenterTest_isExistTargetPath_00', 0, () => {
      expect(favoriteListPresenter.isExistTargetPath(['aaa'])).assertFalse();
      let allPaths:string[] = ['ContactDetail', 'addFavoriteList', 'editFavoriteList'];
      let result = favoriteListPresenter.isExistTargetPath(allPaths);
      expect(result).assertTrue();
    })

    it('FavoriteListPresenterTest_openFavoriteDefaultContactsDetail', 0, () => {
      let favoriteBean: FavoriteBean =
        new FavoriteBean('1', 0, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false,
          '/', false, 0, '', ['570977632'], 1);
      favoriteListPresenter.favoriteList = [favoriteBean];
      let mocker = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(favoriteListPresenter.favoriteDataSource, favoriteListPresenter.favoriteDataSource.getData);
      when(mockFunc)(0).afterReturn(null)
      favoriteListPresenter.openFavoriteDefaultContactsDetail();

      let item: FavoriteBean =
        new FavoriteBean('1', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
      let uselessObj: SearchContactResult =
        new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      let favoriteListBean = new FavoriteListBean(0, true, true, item, uselessObj);

      when(mockFunc)(0).afterReturn(favoriteListBean);
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.toDefaultPage);
      favoriteListPresenter.favoriteListListLen = 0;
      favoriteListPresenter.openFavoriteDefaultContactsDetail();
      mocker.verify('toDefaultPage', []).once();

      favoriteListPresenter.favoriteListListLen = 1;
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.goContactDetail);
      favoriteListPresenter.openFavoriteDefaultContactsDetail();
      mocker.verify('goContactDetail', [favoriteListBean.favorite.contactId]).once();
      mocker.clear(favoriteListPresenter.favoriteDataSource);
      mocker.clear(favoriteListPresenter);
    })

    it('FavoriteListPresenterTest_emitFavoriteDefaultSelectedContact', 0, () => {
      AppStorage.setOrCreate('maintenanceMode', true);
      favoriteListPresenter.emitFavoriteDefaultSelectedContact();

      AppStorage.setOrCreate('maintenanceMode', false);
      let mocker = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isNeedDefaultSelectedDevice);
      when(mockFunc)().afterReturn(false);
      favoriteListPresenter.emitFavoriteDefaultSelectedContact();


      when(mockFunc)().afterReturn(true);
      let mock: Function =
        mocker.mockFunc(favoriteListPresenter.pathInfos, favoriteListPresenter.pathInfos.getAllPathName);
      when(mock)().afterReturn(['111', '222'])
      favoriteListPresenter.emitFavoriteDefaultSelectedContact();

      AppStorage.setOrCreate('maintenanceMode', false);
      when(mockFunc)().afterReturn(false);
      when(mock)().afterReturn([])
      let mockFunc1: Function =
        mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.isExistTargetPath);
      when(mockFunc1)(['111', '222']).afterReturn(true);
      favoriteListPresenter.emitFavoriteDefaultSelectedContact();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.openFavoriteDefaultContactsDetail);
      mocker.verify('openFavoriteDefaultContactsDetail', []).never();

      AppStorage.setOrCreate('maintenanceMode', false);
      when(mockFunc)().afterReturn(true);
      when(mock)().afterReturn([])
      when(mockFunc1)(['111', '222']).afterReturn(false);
      favoriteListPresenter.emitFavoriteDefaultSelectedContact();
      mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.openFavoriteDefaultContactsDetail);
      mocker.verify('openFavoriteDefaultContactsDetail', []).once();

      mocker.clear(IndexPresenter.getInstance());
      mocker.clear(favoriteListPresenter);
      mocker.clear(favoriteListPresenter.pathInfos);
    })
  })
}