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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from '../../../../../../../main/ets/model/type/LooseObject';
import BatchDeletePresenter from '../../../../../../../main/ets/presenter/dialer/batchdelete/BatchDeletePresenter';
import CallRecordPresenter from '../../../../../../../main/ets/presenter/dialer/callRecord/CallRecordPresenter';
import WorkerWrapper from '../../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../../main/ets/workers/WorkFactory';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../../../testability/TestAbility';
import { dataShare, dataSharePredicates } from '@kit.ArkData';
import { CallLogRepository } from '../../../../../../../../../feature/call';
import { ResourceUtil } from '../../../../../../../../../entry/src/main/ets/util/ResourceUtil';

export default function BatchDeletePresenterTest() {
  describe('BatchDeletePresenterTest', () => {

    let batchDeletePresenter: BatchDeletePresenter;

    beforeEach(() => {
      batchDeletePresenter = new BatchDeletePresenter();
      AppStorage.clear();
    });

    it('BatchDeletePresenterTest_getInstance', 0, () => {
      expect(typeof BatchDeletePresenter.getInstance()).assertEqual(typeof batchDeletePresenter);
    })

    it("BatchDeletePresenterTest_back_01", 0, () => {
      AppStorage.setOrCreate('breakpoint', 'sm');
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeletePresenter.pathInfos, batchDeletePresenter.pathInfos.clear);
      batchDeletePresenter.back();
      mocker.verify("clear", [false]).once();
      mocker.clear(batchDeletePresenter.pathInfos);
    });

    it("BatchDeletePresenterTest_back_012", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CallRecordPresenter.getInstance(), CallRecordPresenter.getInstance().toDefaultPage);
      batchDeletePresenter.back();
      mocker.verify("toDefaultPage", []).once();
      mocker.clear(CallRecordPresenter.getInstance());
    });

    it('BatchDeletePresenterTest_resetData', 0, () => {
      batchDeletePresenter.resetData();
      expect(batchDeletePresenter.isSelectAll).assertFalse();
      const selectedCountId: number = 0;
      batchDeletePresenter.resetData();
      expect(batchDeletePresenter.selectedCount).assertEqual(selectedCountId);
      const recordSelectedId: Array<LooseObject> = [];
      batchDeletePresenter.resetData();
      expect(JSON.stringify(batchDeletePresenter.recordSelected))
        .assertEqual('{}');
    });

    it("BatchDeletePresenterTest_initCallRecordData", 0, () => {
      let callLogData: LooseObject[] = [{
        'checked': true
      }];
      batchDeletePresenter.allRecord = callLogData;

      let mocker: MockKit = new MockKit();
      let getCallLogData: Function = mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.getCallLogData);
      when(getCallLogData)().afterReturn(callLogData);

      mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.refreshAll);

      batchDeletePresenter.initCallRecordData();

      mocker.verify("refreshAll", [batchDeletePresenter.allRecord]).once();
      mocker.clear(batchDeletePresenter.callRecordListDataSource);
    });

    it("BatchDeletePresenterTest_checkAll_01_01", 0, () => {
      batchDeletePresenter.isSelectAll = false;
      let item: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '1',
        'ids': 'ids',
        'count': 0
      }
      batchDeletePresenter.allRecord = [item];
      batchDeletePresenter.recordSelected.set(1, ['1']);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      batchDeletePresenter.checkAll();

      expect(batchDeletePresenter.selectedCount).assertEqual(0);
      mocker.clear(ResourceUtil);
    });

    it("BatchDeletePresenterTest_checkAll_02", 0, () => {
      let item: Record<string, string | number | boolean | Resource | string[]> = {
        'checked': true,
        'id': 1,
        'ids': ['1'],
        'count': 1
      };
      batchDeletePresenter.selectedCount = 1;
      batchDeletePresenter.isSelectAll = false;
      batchDeletePresenter.allRecord = [item];
      batchDeletePresenter.recordSelected.set(item.id as number, item.ids as string[]);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      batchDeletePresenter.checkAll();

      expect(batchDeletePresenter.isSelectAll).assertTrue();
      mocker.clear(ResourceUtil);
    });

    it("BatchDeletePresenterTest_checkAll_if_noIf", 0, () => {
      batchDeletePresenter.isSelectAll = true;
      let item1: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '1',
        'ids': 'ids1',
        'count': 0
      };
      let item2: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '2',
        'ids': 'ids2',
        'count': 0
      };
      let item3: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '3',
        'ids': 'ids3',
        'count': 0
      };
      batchDeletePresenter.allRecord = [item1, item2];
      batchDeletePresenter.recordSelected.set(3, ['3']);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.replacehAll);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      batchDeletePresenter.checkAll();

      mocker.verify('replacehAll', [batchDeletePresenter.allRecord]).once();

      batchDeletePresenter.mergeRule = 'contacts';
      batchDeletePresenter.checkAll();
      expect(batchDeletePresenter.recordSelected.size > 0).assertTrue();
      batchDeletePresenter.mergeRule = 'time';
      mocker.clear(batchDeletePresenter.callRecordListDataSource);
      mocker.clear(ResourceUtil);
    });

    it("BatchDeletePresenterTest_checkboxChanged_if_if", 0, () => {
      let item1: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '1',
        'ids': 'ids1',
        'count': 0
      };
      let item2: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': '2',
        'ids': 'ids2',
        'count': 0
      }
      batchDeletePresenter.allRecord = [item1, item2];

      batchDeletePresenter.recordSelected.set(1, ['1']);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.refreshAll);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      batchDeletePresenter.checkAll();

      expect(batchDeletePresenter.isSelectAll).assertTrue();
      mocker.clear(batchDeletePresenter.callRecordListDataSource);
      mocker.clear(ResourceUtil);
    });

    it("BatchDeletePresenterTest_deleteEvent_if", 0, () => {
      let item: Record<string, string | number | boolean | Resource | string[]> = {
        'checked': false,
        'id': 1,
        'ids': ['1'],
        'count': 1
      };
      batchDeletePresenter.recordSelected.set(item.id as number, item.ids as string[]);

      let item1: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': 'id1',
        'ids': 'ids1',
        'count': 0
      };
      let item2: Record<string, string | number | boolean | Resource> = {
        'checked': true,
        'id': 'id2',
        'ids': 'ids2',
        'count': 0
      };
      batchDeletePresenter.allRecord = [item1, item2];

      batchDeletePresenter.isSelectAll = true;

      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let back: Function = mocker.mockFunc(batchDeletePresenter, batchDeletePresenter.back);
      mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.remove);

      when(back)().afterAction(() => {
        expect(AppStorage.get('clearAllRecord')).assertTrue();
        expect(batchDeletePresenter.isSelectAll).assertFalse();
        mocker.verify('remove', [0, 1]).once();
      })

      batchDeletePresenter.deleteEvent();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(batchDeletePresenter.callRecordListDataSource);
      mocker.clear(batchDeletePresenter);
    });

    it("BatchDeletePresenterTest_deleteEvent_else", 0, () => {
      let item: Record<string, string | number | boolean | Resource | string[]> = {
        'checked': true,
        'id': 1,
        'ids': ['1'],
        'count': 1
      };
      batchDeletePresenter.recordSelected.set(item.id as number, item.ids as string[]);

      let item1: Record<string, string | number | boolean | Resource | string[]> = {
        'checked': true,
        'id': 2,
        'ids': ['2'],
        'count': 1
      };
      let item2: Record<string, string | number | boolean | Resource | string[]> = {
        'checked': true,
        'id': 3,
        'ids': ['3'],
        'count': 1
      };
      batchDeletePresenter.allRecord = [item1, item2];

      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);

      CallLogRepository.getInstance().init(context);
      when(mocker.mockFunc(CallLogRepository.getInstance(), CallLogRepository.getInstance().getDataAbilityHelper))()
        .afterAction(() => new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> => {
            return new Promise<number>(resolve => resolve(1));
          }
        } as dataShare.DataShareHelper)));

      let back: Function = mocker.mockFunc(batchDeletePresenter, batchDeletePresenter.back);
      mocker.mockFunc(batchDeletePresenter.callRecordListDataSource,
        batchDeletePresenter.callRecordListDataSource.refreshAll);
      when(back)().afterAction(() => {
        expect(AppStorage.get('clearAllRecord')).assertUndefined();
        mocker.verify('refreshAll', [batchDeletePresenter.allRecord]).once();
      })

      batchDeletePresenter.deleteEvent();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(batchDeletePresenter.callRecordListDataSource);
      mocker.clear(CallLogRepository.getInstance());
      mocker.clear(batchDeletePresenter);
    });

    it('BatchDeletePresenterTest_getDeleteDialogTitle_1', 0, () => {
      const title = $r("app.string.delete_all_callLog_dialog_title");
      batchDeletePresenter.isSelectAll = true;
      const title1 = batchDeletePresenter.getDeleteDialogTitle();
      expect(JSON.stringify(title1)).assertEqual(JSON.stringify(title));
    });

    it('BatchDeletePresenterTest_getDeleteDialogTitle_2', 0, () => {
      const title2 = $r("app.string.deleteCallLog_dialog_title");
      batchDeletePresenter.isSelectAll = false;
      batchDeletePresenter.selectedCount = 1;
      const title3 = batchDeletePresenter.getDeleteDialogTitle();
      expect(JSON.stringify(title2)).assertEqual(JSON.stringify(title3));
    });

    it('BatchDeletePresenterTest_getDeleteDialogTitle_3', 0, () => {
      const title4 = $r("app.plural.delete_callLog_dialog_title", batchDeletePresenter.selectedCount,
        batchDeletePresenter.selectedCount);
      batchDeletePresenter.isSelectAll = false;
      const title5 = batchDeletePresenter.getDeleteDialogTitle();
      expect(JSON.stringify(title4)).assertEqual(JSON.stringify(title5));
    });
  })
}