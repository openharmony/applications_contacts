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
import { describe, it, expect, MockKit,
  ArgumentMatchers,
  when
} from '@ohos/hypium';
import { CallLog } from '../../../../../../../../feature/call';
import CallLogBuilder from '../../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import MergedCallLog from '../../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallLogBean } from '../../../../../../main/ets/model/bean/CallLogBean';
import CallRecordListDataSource from '../../../../../../main/ets/model/bean/CallRecordListDataSource';
import LooseObject from '../../../../../../main/ets/model/type/LooseObject';
import { CallLogService } from '../../../../../../../../feature/call';
import StringFormatUtil from '../../../../../../main/ets/util/StringFormatUtil';

export default function CallRecordListDataSourceTest() {
  describe('CallRecordListDataSourceTest', () => {

    it('CallRecordListDataSourceTest_indexOf', 0, () => {
      let item: LooseObject = {
        id: '0'
      };
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [];
      callLogData.push(new CallLogBean("234242", "action1", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action2", "23424", "1"))
      crd.refreshAll(callLogData);
      expect(crd.indexOf(item)).assertEqual(-1);

      let item1: LooseObject = {
        id: '5'
      };
      expect(crd.indexOf(item1)).assertEqual(-1);
    })

    it('CallRecordListDataSourceTest_indexOf_02', 0, () => {
      let item: LooseObject = {
        id: '1'
      };
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [item];
      crd.refreshAll(callLogData);
      expect(crd.indexOf(item)).assertEqual(0);
    })

    it('CallRecordListDataSourceTest_totalCount', 0, () => {
      let crd = new CallRecordListDataSource();
      expect(crd.totalCount()).assertEqual(0)
    })
    it('CallRecordListDataSourceTest_refreshAll', 0, () => {
      let callLogData: LooseObject[] = [];
      callLogData.push(new CallLogBean("234242", "action", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action", "23424", "1"))
      let crd = new CallRecordListDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(crd,crd.notifyDataReload);
      crd.refreshAll(callLogData)
      mocker.verify('notifyDataReload',[]).once();
      mocker.clear(crd);
    })
    it('CallRecordListDataSourceTest_getData', 0, () => {
      let crd = new CallRecordListDataSource();
      expect(crd.getData(0)).assertEqual(null);
      let callLogData: LooseObject[] = [];
      let item: LooseObject = {
        createTimeSource: 12,
        createTime: '',
        createTimeAccessibilityText: ''
      };
      callLogData.push(item);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(CallLogService.getInstance(),
        CallLogService.getInstance().formatTime))(item.createTimeSource as number).afterReturn('12')

      when(mocker.mockFunc(CallLogService.getInstance(),
        StringFormatUtil.getAccessibilityTextByTime))(item.createTimeSource).afterReturn('123')
      crd.refreshAll(callLogData);
      let result: LooseObject = {
        createTimeSource: 12,
        createTime: '12',
        createTimeAccessibilityText: '123'
      };
      let res: LooseObject | null = crd.getData(0);
      expect(res?.createTimeSource).assertEqual(result?.createTimeSource);
      expect(res?.createTime).assertEqual(result?.createTime);
      mocker.clear(CallLogService.getInstance());
    })

    it('CallRecordListDataSourceTest_getData_else', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [];
      let item: LooseObject = {
        createTimeSource: '',
        createTime: '',
        createTimeAccessibilityText: ''
      };
      callLogData.push(item);
      crd.refreshAll(callLogData);
      let result: LooseObject = {
        createTimeSource: '',
        createTime: '',
        createTimeAccessibilityText: ''
      };
      let res: LooseObject | null = crd.getData(0);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify(result));
    })

    it('CallRecordListDataSourceTest_setIsShow', 0, () => {
      let crd = new CallRecordListDataSource();
      crd.setIsShow(false);
      expect(crd.totalCount()).assertEqual(0)
    })
    it('CallRecordListDataSourceTest_setIsShow_second', 0, () => {
      let crd = new CallRecordListDataSource();
      crd.setIsShow(true);
      expect(crd.totalCount()).assertEqual(0)
    })
    it('CallRecordListDataSourceTest_refresh', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: MergedCallLog[] = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '')))];
      callLogData.push(new MergedCallLog(new CallLog(new CallLogBuilder(1, ''))))
      callLogData.push(new MergedCallLog(new CallLog(new CallLogBuilder(2, ''))))
      crd.refreshAll(callLogData);
      crd.refresh(0,callLogData,true)
      expect(callLogData.length).assertEqual(3)
    })
    it('CallRecordListDataSourceTest_remove', 0, () => {
      let mocker: MockKit = new MockKit();
      let crd = new CallRecordListDataSource();
      mocker.mockFunc(crd, crd.notifyDataReload);
      crd.remove(-1);
      mocker.verify('notifyDataReload', []).never();

      when(mocker.mockFunc(crd, crd.totalCount))().afterReturn(2);
      crd.remove(1);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(crd);
    })
    it('CallRecordListDataSourceTest_setDataReload', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [];
      callLogData.push(new CallLogBean("234242", "action1", "23424", "1"));
      callLogData.push(new CallLogBean("234241", "action2", "23424", "1"));
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(crd, crd.notifyDataReload);
      crd.setIsShow(true);
      crd.refreshAll(callLogData);
      expect(crd.getCallLogData().length).assertEqual(2);
      mocker.clear(crd);
    })

    it('CallRecordListDataSourceTest_refresh_001', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: MergedCallLog[] = [new MergedCallLog(new CallLog(new CallLogBuilder(1, '')))];
      callLogData.push(new MergedCallLog(new CallLog(new CallLogBuilder(1, ''))))
      callLogData.push(new MergedCallLog(new CallLog(new CallLogBuilder(2, ''))))
      crd.refreshAll(callLogData);
      crd.refresh(0,callLogData,false)
      expect(callLogData.length).assertEqual(3)
    })

    it('CallRecordListDataSourceTest_clean', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [];
      callLogData.push(new CallLogBean("234242", "action1", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action2", "23424", "1"))
      crd.refreshAll(callLogData);
      crd.clean()

      expect(crd.totalCount()).assertEqual(0)
    })

    it('CallRecordListDataSourceTest_replaceAll', 0, () => {
      let crd = new CallRecordListDataSource();
      let callLogData: LooseObject[] = [];
      callLogData.push(new CallLogBean("234242", "action1", "23424", "1"))
      callLogData.push(new CallLogBean("234241", "action2", "23424", "1"))
      crd.replacehAll(callLogData);

      expect(callLogData.length).assertEqual(2)
    })
  })
}