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
import { describe, beforeEach, it, expect, when, MockKit, ArgumentMatchers, afterEach } from '@ohos/hypium';
import { ContactsGlobalThisHelper } from '../../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import GroupListPresenter from '../../../../../../main/ets/presenter/group/GroupListPresenter';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import common from '@ohos.app.ability.common';
import { ContactRepository } from '../../../../../../../../feature/contact';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { GroupBean, GroupInfo } from '../../../../../../main/ets/model/bean/GroupBean';
import { GroupParams } from '../../../../../../main/ets/model/type';
import { ValuesBucket } from '@kit.ArkData';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
import { DynamicLoader } from '../../../../../../../../common/src/main/ets/util/DynamicLoader';

const TAG = 'GroupListPresenter  ';

export default function GroupListPresenterTest() {
  describe('GroupListPresenterTest', () => {

    let groupListPresenter: GroupListPresenter;
    let mocker: MockKit;

    beforeEach(() => {
      groupListPresenter = GroupListPresenter.getInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(groupListPresenter);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('GroupListPresenter_getInstance', 0, () => {
      expect(typeof GroupListPresenter.getInstance()).assertEqual(typeof groupListPresenter)
    })

    it('GroupListPresenter_refreshGroup', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterReturn(workWrapper);
      let result = false;
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('getAllGroup')
        .afterAction(() => {
          result = true;
        });
      groupListPresenter.refreshGroup();
      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_getMemberLen', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let result = false;
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterAction(() => {
        result = true;
        return workWrapper;
      });
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('queryAllGroupMember')
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.getMemberLen(1);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_getMemberLen_callback', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: Array<string>
            ): Promise<DataShareResultSet> => {
              return new Promise<DataShareResultSet>(resolve => resolve({
                rowCount: 1,
                close: () => {
                  expect(result).assertTrue();
                },
                goToFirstRow: () => {
                  result = true;
                  return true
                },
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 0,
                getLong: (columnIndex: number): number => 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper));
        });

      groupListPresenter.getMemberLen(1);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_getMemberLen_callback_result_empty', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      ContactRepository.getInstance().init(context);

      let result = false;
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => {
          return new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: Array<string>
            ): Promise<DataShareResultSet> => {
              return new Promise<DataShareResultSet>(resolve => resolve({
                rowCount: 0,
                close: () => {},
                goToFirstRow: () => true,
                goToNextRow: () => false,
                getString: (columnIndex: number): string => 'xxx',
                getColumnIndex: (columnName: string): number => 0,
                getLong: (columnIndex: number): number => 0
              } as DataShareResultSet))
            }
          } as dataShare.DataShareHelper));
        });

      groupListPresenter.getMemberLen(1);
      expect(groupListPresenter.groupCount != -1).assertTrue();
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_backItemClick', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      groupListPresenter.backItemClick();
      mocker.verify('i', [TAG, 'backItemClick']).never();
      mocker.clear(HiLog);
    })

    it('GroupListPresenter_refreshGroupList', 0, () => {
      let result = false;
      let groupList: GroupInfo[] = [];
      let refresh: Function = mocker.mockFunc(groupListPresenter.groupListDataSource, groupListPresenter.groupListDataSource.refresh);
      when(refresh)(ArgumentMatchers.any).afterAction(() => {
        result = true;
      });

      groupListPresenter.refreshGroupList(groupList);

      expect(result).assertTrue();
      mocker.clear(groupListPresenter.groupListDataSource);
    })

    it('GroupListPresenter_aboutToAppear', 0, () => {
      let result = false;

      when(mocker.mockFunc(groupListPresenter, groupListPresenter.refreshGroup))()
        .afterAction(() => {
          result = true;
        })
      groupListPresenter.aboutToAppear();
      expect(result).assertTrue();
    })

    it('GroupListPresenter_addGroup', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let result = false;
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName)
        .afterAction(() => {
          result = true;
          return workWrapper;
        });
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('addGroup')
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.addGroup('group1', '1');
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_renameGroup', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      let result = false;
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterAction(() => {
        result = true;
        return workWrapper;
      });
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('renameGroup')
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.renameGroup({
        id: 1, groupName: 'group1'
      } as GroupParams);
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_renameGroup_callback', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);
      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(groupListPresenter, groupListPresenter.refreshGroup))()
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.renameGroup({
        id: 1, groupName: 'group1'
      } as GroupParams);
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_removeMember', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let result = false;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterAction(() => {
          result = true;
          return workWrapper;
        });
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('deleteMemberByGroupID')
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.removeMember(1);
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_removeMember_callback', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      groupListPresenter.removeMember(1);

      expect(groupListPresenter.groupCount).assertEqual(0);
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_removeGroup', 0, () => {
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let result = false;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName)
        .afterAction(() => {
          result = true;
          return workWrapper;
        });
      when(mocker.mockFunc(workWrapper, workWrapper.sendRequest))('removeGroup')
        .afterAction(() => {
          expect(result).assertTrue();
        });
      groupListPresenter.removeGroup(1);
      mocker.clear(workWrapper);
    })

    it('GroupListPresenter_removeGroup_callback', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);

      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);
      ;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext))().afterReturn(context);

      let result = false;
      ContactRepository.getInstance().init(context);
      when(mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(groupListPresenter, groupListPresenter.refreshGroup))()
        .afterAction(() => {
          expect(result).assertTrue();
        });

      groupListPresenter.removeGroup(1);
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_back_pathInfos_null', 0, () => {
      groupListPresenter.pathInfos = undefined;
      groupListPresenter.back();
      expect(groupListPresenter.groupCount).assertEqual(0);
    })

    it('GroupListPresenter_back', 0, () => {
      groupListPresenter.pathInfos = new NavPathStack();
      groupListPresenter.pathInfos.pushPathByName('path1', 'path1');
      expect(JSON.stringify(groupListPresenter.pathInfos.getParamByName('path1'))).assertEqual('["path1"]');
      groupListPresenter.back();
      expect(JSON.stringify(groupListPresenter.pathInfos.getParamByName('path1'))).assertEqual("[]");
    })

    it('GroupListPresenter_refreshGroup_callback', 0, () => {
      mocker.mockFunc(groupListPresenter, groupListPresenter.refreshGroupList);
      when(mocker.mockFunc(groupListPresenter, groupListPresenter.getMemberLen))(0)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      let workWrapper: WorkerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      let getValue: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue);

      when(getValue)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactRepository.getInstance().init(context);

      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      let result = false;
      let getDataAbilityHelper: Function = mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance()
        .getDataAbilityHelper);
      when(getDataAbilityHelper)().afterAction(() => {
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
        } as dataShare.DataShareHelper));
      });

      let refreshGroupList: Function = mocker.mockFunc(groupListPresenter, groupListPresenter.refreshGroupList);
      when(refreshGroupList)(ArgumentMatchers.any).afterAction(() => {
        expect(result).assertTrue();
        mocker.verify('getMemberLen', [0]).once();
      });

      groupListPresenter.refreshGroup();
      mocker.clear(ContactRepository.getInstance());
    })

    it('GroupListPresenter_ifGroupExist_hasGroup', 0, () => {
      groupListPresenter.groupList = [new GroupInfo(new GroupBean(0, '1', 'group1', 'xxx', 'false', 'ringtone', 0, 0, '', ''), 0, false)];
      let result = groupListPresenter.ifGroupExist('group1');
      expect(result).assertTrue();
    })

    it('GroupListPresenter_ifGroupExist_noGroup', 0, () => {
      groupListPresenter.groupList = [new GroupInfo(new GroupBean(0, '1', 'group', 'xxx', 'false', 'ringtone', 0, 0, '', ''), 0, false)];
      let result = groupListPresenter.ifGroupExist('group1');
      expect(result).assertFalse();
    })

    it('GroupListPresenter_toBatchDeleteGroup', 0, () => {
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.BATCH_DELETE_GROUP).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(groupListPresenter.pathInfos?.pushPathByName(DynamicLoader.BATCH_DELETE_GROUP, ''))
      }));
      groupListPresenter.toBatchDeleteGroup();

      expect(groupListPresenter.pathInfos?.getParamByName(DynamicLoader.BATCH_DELETE_GROUP).toString()).assertEqual('');
      mocker.clear(DynamicLoader.getInstance());
    })

    it('GroupListPresenter_toGroupListDetail', 0, () => {
      groupListPresenter.pathInfos = new NavPathStack();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)(DynamicLoader.GROUP_LIST_DETAIL).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(groupListPresenter.pathInfos?.pushPathByName(DynamicLoader.GROUP_LIST_DETAIL, 'group'))
      }));
      groupListPresenter.toGroupListDetail('group');
      expect(groupListPresenter.pathInfos?.getParamByName(DynamicLoader.GROUP_LIST_DETAIL).toString()).assertEqual('group');
      mocker.clear(DynamicLoader.getInstance());
    })
  })
}