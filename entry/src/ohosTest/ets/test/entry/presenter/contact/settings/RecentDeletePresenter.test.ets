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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import RecentDeleteBean from '../../../../../../../main/ets/model/bean/RecentDeleteBean';
import RecentDeletePresenter from '../../../../../../../main/ets/presenter/contact/settings/RecentDeletePresenter';
import { recentDeleteOperateContactParams } from '../../../../../../../main/ets/util/DotCommon';
import { ResourceUtil } from '../../../../../../../main/ets/util/ResourceUtil';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';

export default function RecentDeletePresenterTest() {
  describe('RecentDeletePresenterTest', () => {

    it("RecentDeletePresenterTest_getRecentDeleteCount", 0, () => {
      let result = RecentDeletePresenter.getInstance().getRecentDeleteCount();
      expect(result).assertEqual(0);
    })

    it("RecentDeletePresenterTest_getDisplayName", 0, () => {
      expect(JSON.stringify(RecentDeletePresenter.getInstance().getDisplayName('')))
        .assertEqual(JSON.stringify($r('app.string.noName')));
      expect(JSON.stringify(RecentDeletePresenter.getInstance().getDisplayName('111')))
        .assertEqual(JSON.stringify('111'));
    })

    it("RecentDeletePresenterTest_getRemainingDays", 0, () => {
      expect(JSON.stringify(RecentDeletePresenter.getInstance().getRemainingDays(1)))
        .assertEqual(ResourceUtil.getPluralStringByResource($r('app.plural.recycle_days_left'), 0));
    })

    it("RecentDeletePresenterTest_deleteSelectedContactItems", 0, () => {
      let array: Array<string> = [];
      array.push('1');
      array.push('2');
      array.push('3');
      RecentDeletePresenter.getInstance().isSelectAll = true;
      RecentDeletePresenter.getInstance().deleteSelectedContactItems(array);
      expect(RecentDeletePresenter.getInstance().resultDT).assertEqual(0);

      RecentDeletePresenter.getInstance().isSelectAll = false;
      RecentDeletePresenter.getInstance().selectRecentDeleteChange = true;
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteList: RecentDeleteBean[] = [];
      recentDeleteList.push(recentDeleteBean);
      let array1: Array<string> = [];
      array.push('1');
      array.push('2');
      array.push('3');
      RecentDeletePresenter.getInstance().recentDeleteList = recentDeleteList;
      RecentDeletePresenter.getInstance().deleteSelectedContactItems(array1);
      expect(RecentDeletePresenter.getInstance().resultDT).assertEqual(0);
    })

    it("RecentDeletePresenterTest_getDeleteDialogTitle", 0, () => {
      let result: Resource;
      RecentDeletePresenter.getInstance().selectRecentDeleteChange = false;
      result = RecentDeletePresenter.getInstance().getDeleteDialogTitle();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.contacts_cleaned_confirm')));
      RecentDeletePresenter.getInstance().selectRecentDeleteChange = true;
      RecentDeletePresenter.getInstance().recentDeleteList.length = RecentDeletePresenter.getInstance().checkedStatus.size;
        result = RecentDeletePresenter.getInstance().getDeleteDialogTitle();
      expect(JSON.stringify(result))
        .assertEqual(JSON.stringify($r('app.string.contacts_recycle_deleted_all_confirm')));
      RecentDeletePresenter.getInstance().checkedStatus.add(1);
      result = RecentDeletePresenter.getInstance().getDeleteDialogTitle();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify($r('app.string.contacts_recycle_deleted_confirm_single')));
      RecentDeletePresenter.getInstance().checkedStatus.add(1);
      RecentDeletePresenter.getInstance().checkedStatus.add(2);
      result = RecentDeletePresenter.getInstance().getDeleteDialogTitle();
      expect(JSON.stringify(result))
        .assertEqual(JSON.stringify($r('app.plural.contacts_recycle_deleted_confirm',
          RecentDeletePresenter.getInstance().checkedStatus.size,
          RecentDeletePresenter.getInstance().checkedStatus.size)));
      RecentDeletePresenter.getInstance().checkedStatus.clear();
    })

    it("RecentDeletePresenterTest_checkAll", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getPluralStringByResource);
      let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      when(mockFunc)($r('app.string.unselect_all')).afterReturn('Deselect all')
      RecentDeletePresenter.getInstance().isSelectAll = false;
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteList: RecentDeleteBean[] = [];
      recentDeleteList.push(recentDeleteBean);
      RecentDeletePresenter.getInstance().recentDeleteList = recentDeleteList;
      RecentDeletePresenter.getInstance().checkAll();
      expect(RecentDeletePresenter.getInstance().checkedStatus.size).assertEqual(1);
      RecentDeletePresenter.getInstance().checkAll();
      expect(RecentDeletePresenter.getInstance().checkedStatus.size).assertEqual(0);
      mocker.clear(ResourceUtil);
    })

    it("RecentDeletePresenterTest_resetDefaultValue", 0, () => {
      RecentDeletePresenter.getInstance().resetDefaultValue();
      expect(RecentDeletePresenter.getInstance().checkedStatus.size).assertEqual(0);
    })

    it("RecentDeletePresenterTest_recentDeleteOperate", 0, () => {
      RecentDeletePresenter.getInstance().isSelectAll = true;
      RecentDeletePresenter.getInstance().recentDeleteOperate(1);
      expect(recentDeleteOperateContactParams.NUM).assertEqual(2);

      RecentDeletePresenter.getInstance().isSelectAll = false;
      RecentDeletePresenter.getInstance().selectedCount = 0;
      RecentDeletePresenter.getInstance().recentDeleteOperate(1);
      expect(recentDeleteOperateContactParams.NUM).assertEqual(-1);
      expect(recentDeleteOperateContactParams.OPERATE).assertEqual(1);

      RecentDeletePresenter.getInstance().selectedCount = 1;
      RecentDeletePresenter.getInstance().recentDeleteOperate(1);
      expect(recentDeleteOperateContactParams.NUM).assertEqual(0);

      RecentDeletePresenter.getInstance().selectedCount = 2;
      RecentDeletePresenter.getInstance().recentDeleteOperate(1);
      expect(recentDeleteOperateContactParams.NUM).assertEqual(1);
    })

    it("RecentDeletePresenterTest_processLongPressedItem", 0, () => {
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteList: RecentDeleteBean[] = [];
      recentDeleteList.push(recentDeleteBean);
      RecentDeletePresenter.getInstance().recentDeleteList = recentDeleteList;
      RecentDeletePresenter.getInstance().processLongPressedItem(recentDeleteBean, 0);
      expect(RecentDeletePresenter.getInstance().checkedStatus.size).assertEqual(1);

      //else
      let item: RecentDeleteBean =
        new RecentDeleteBean(2, 'names', '', 0, false);
      RecentDeletePresenter.getInstance().processLongPressedItem(item, 0);
      expect(RecentDeletePresenter.getInstance().checkedStatus.size).assertEqual(1);
    })

    it("RecentDeletePresenterTest_setRestoreToSelect", 0, () => {
      RecentDeletePresenter.getInstance().setRestoreToSelect();
      expect(RecentDeletePresenter.getInstance().selectRecentDeleteChange).assertTrue();
    })

    it('RecentDeletePresenterTest_getAppNameByPackageName', 0, () => {
      let packageName: string = '';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      when(mockFunc)($r('app.string.unknown')).afterReturn('unknown')
      let result: string = RecentDeletePresenter.getInstance().getAppNameByPackageName(packageName);
      expect(result).assertUndefined();
      packageName = '111';
      expect(RecentDeletePresenter.getInstance().getAppNameByPackageName(packageName)).assertUndefined();
      packageName = 'com.ohos.contacts';
      expect(RecentDeletePresenter.getInstance().getAppNameByPackageName(packageName)).assertEqual('联系人');
      mocker.clear(ResourceUtil);
    })

    it('RecentDeletePresenterTest_deleteContacts', 0, () => {
      RecentDeletePresenter.getInstance().selectRecentDeleteChange = false;
      RecentDeletePresenter.getInstance().isSelectAll = true;
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteList: RecentDeleteBean[] = [];
      recentDeleteList.push(recentDeleteBean);
      RecentDeletePresenter.getInstance().recentDeleteList = recentDeleteList;
      RecentDeletePresenter.getInstance().deleteContacts();
      expect(RecentDeletePresenter.getInstance().allSelectedIds.length).assertEqual(1);
    })

    it('RecentDeletePresenterTest_deleteContacts_else', 0, () => {
      RecentDeletePresenter.getInstance().selectRecentDeleteChange = false;
      RecentDeletePresenter.getInstance().isSelectAll = true;
      let recentDeleteBean: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteBean1: RecentDeleteBean =
        new RecentDeleteBean(1, 'name', '', 0, false);
      let recentDeleteList: RecentDeleteBean[] = [];
      recentDeleteList.push(recentDeleteBean);
      recentDeleteList.push(recentDeleteBean1);
      RecentDeletePresenter.getInstance().recentDeleteList = recentDeleteList;
      RecentDeletePresenter.getInstance().deleteContacts();
      expect(RecentDeletePresenter.getInstance().isSelectAll).assertTrue();
    })

    it('RecentDeletePresenterTest_restoreContacts', 0, () => {
      RecentDeletePresenter.getInstance().isSelectAll = false;
      RecentDeletePresenter.getInstance().checkedStatus.add(1);
      RecentDeletePresenter.getInstance().restoreContacts();
      expect(RecentDeletePresenter.getInstance().isSelectAll).assertFalse();
    })

    it('RecentDeletePresenterTest_getAccessibilityDisplayName_01', 0, () => {
      const NO_NAME: string = '(无姓名)';
      expect(RecentDeletePresenter.getInstance().getAccessibilityDisplayName('')).assertEqual(NO_NAME);
    })

    it('RecentDeletePresenterTest_getAccessibilityDisplayName_02', 0, () => {
      expect(RecentDeletePresenter.getInstance().getAccessibilityDisplayName('张三')).assertEqual('张三');
    })
  })
}