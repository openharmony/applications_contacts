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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { FavoriteBean } from '../../../../../../main/ets/model/bean/FavoriteBean';
import { SingleSelectContact } from '../../../../../../main/ets/model/type';
import EditFavoriteListPresenter from '../../../../../../main/ets/presenter/favorite/EditFavoriteListPresenter';
import FavoriteListPresenter from '../../../../../../main/ets/presenter/favorite/FavoriteListPresenter';
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper';
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import { dataShare, dataSharePredicates, ValuesBucket } from '@kit.ArkData';
import { ContactRepository } from '../../../../../../../../feature/contact';
import { ResourceUtil } from '../../../../../../main/ets/util/ResourceUtil';

export default function EditFavoriteListPresenterTest() {
  describe('EditFavoriteListPresenterTest', () => {
    let presenter: EditFavoriteListPresenter;
    beforeEach(() => {
      AppStorage.clear();
      presenter = EditFavoriteListPresenter.getInstance();
    })

    it('EditFavoriteListPresenter_getInstance', 0, () => {
      expect(typeof EditFavoriteListPresenter.getInstance()).assertEqual(typeof presenter);
    })

    it('EditFavoriteListPresenter_deleteUsuallyInfo', 0, () => {
      let selectedUsuallyList: string[] = ['xx', 'yy'];
      presenter.deleteUsuallyInfo(selectedUsuallyList);
      expect(JSON.stringify(AppStorage.get('deleteUsuallyContactData')))
        .assertEqual(JSON.stringify(selectedUsuallyList));
    })

    it('EditFavoriteListPresenter_deleteUsuallyInfo_noIf', 0, () => {
      presenter.deleteUsuallyInfo([]);
      expect(AppStorage.get('deleteUsuallyContactData')).assertUndefined();
    })

    it('EditFavoriteListPresenter_moveSortFavorite_lastIndex_0_if', 0, () => {
      let result = false;
      let callback = (needCancelFavorite: string[]) => {
        result = true;
      };
      let deleteaDic: Record<string, boolean> = {
        '1': false,
      };

      presenter.moveSortFavorite(callback);

      expect(result).assertTrue();
    })

    it('EditFavoriteListPresenter_moveSortFavorite_lastIndex_0_else', 0, () => {
      let deleteaDic: Record<string, boolean> = {
        '1': false,
      };

      presenter.pathInfos.pushPathByName('name1', '');

      expect(presenter.contactsTotal).assertEqual(0)
    })

    /*it('EditFavoriteListPresenter_moveSortFavorite_lastIndex_1_if', 0, () => {
      let presenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
      let favoriteBean: FavoriteBean = new FavoriteBean('1', 1, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977632'], 1);
      let favoriteBean1: FavoriteBean = new FavoriteBean('2', 1, 'roxy1', '570977633', 'roxy1', 'roxy1', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977633'], 2);
      let favoriteList: FavoriteBean[] = [favoriteBean, favoriteBean1];
      let result = false;
      let callback = () => {
        expect(result).assertTrue();
      };
      let deleteaDic: Record<string, boolean> = {
        '1': false,
      };
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            result = true;
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      presenter.moveSortFavorite(callback);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })*/

    it('EditFavoriteListPresenter_moveSortFavorite_noIf1_lastIndex_1_if', 0, () => {
      let presenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
      let favoriteBean: FavoriteBean = new FavoriteBean('1', 0, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977632'], 1);
      let favoriteBean1: FavoriteBean = new FavoriteBean('2', 1, 'roxy1', '570977633', 'roxy1', 'roxy1', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977633'], 2);

      let favoriteList: FavoriteBean[] = [favoriteBean,favoriteBean1];
      let deleteaDic: Record<string, boolean> = {
        '1': true,
      };
      let callback = (needCancelFavorite: string[]) => {
      };
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      presenter.moveSortFavorite(callback);

      mocker.verify('getValue', []).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })

    it('EditFavoriteListPresenter_moveSortFavorite_noIf2_lastIndex_1_if', 0, () => {
      let presenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
      let favoriteBean: FavoriteBean = new FavoriteBean('1', 0, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977632'], 1);
      favoriteBean.isCommonUseType = 1;
      let favoriteBean1: FavoriteBean = new FavoriteBean('2', 0, 'roxy1', '570977633', 'roxy1', 'roxy1', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977633'], 2);
      favoriteBean1.isCommonUseType = 1;
      let favoriteList: FavoriteBean[] = [favoriteBean, favoriteBean1];

      let callback = () => {
      };
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      mocker.verify('pop', []).never();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
      mocker.clear(presenter.pathInfos);
    })

    it('EditFavoriteListPresenter_moveSortFavorite_lastIndex_1_else', 0, () => {
      let presenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
      let favoriteBean: FavoriteBean = new FavoriteBean('1', 0, 'roxy', '570977632', 'roxy', 'roxy', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977632'], 1);
      favoriteBean.isCommonUseType = 1;
      let favoriteBean1: FavoriteBean = new FavoriteBean('2', 0, 'roxy1', '570977633', 'roxy1', 'roxy1', $r('app.color.detail_main_background'), false, '/', false, 0, '', ['570977633'], 2);
      favoriteBean1.isCommonUseType = 1;
      let favoriteList: FavoriteBean[] = [favoriteBean, favoriteBean1];
      let deleteaDic: Record<string, boolean> = {
        '1': false,
      };
      let mocker: MockKit = new MockKit();
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getValue))(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext))().afterReturn(context);

      when(mocker.mockFunc(ContactRepository.getInstance().init(context), ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper))()
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates, value: ValuesBucket): Promise<number> => {
            return new Promise<number>(resolve => resolve(1))
          }
        } as dataShare.DataShareHelper)));

      presenter.pathInfos.pushPathByName('name1', '');

      expect(presenter.contactsTotal).assertEqual(0);

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(ContactRepository.getInstance().init(context));
      mocker.clear(ContactRepository.getInstance());
    })

    it('EditFavoriteListPresenter_cancelEditFavorite_breakpoint_sm', 0, () => {
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
      AppStorage.SetOrCreate('breakpoint', 'sm');
      presenter.cancelEditFavorite();
      expect(presenter.contactsTotal).assertEqual(0);
    })

    it('EditFavoriteListPresenter_cancelEditFavorite_breakpoint_undefined', 0, () => {
      let mocker: MockKit = new MockKit();
      let result = false;
      let favoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
      when(mocker.mockFunc(favoriteListPresenter, favoriteListPresenter.toDefaultPage))()
        .afterAction(() => {
          result = true;
        });
      presenter.cancelEditFavorite();
      expect(result).assertTrue();

      mocker.clear(favoriteListPresenter);
    })

    it('EditFavoriteListPresenter_aboutToAppear', 0, () => {
      let mocker: MockKit = new MockKit();
      let result = false;
      when(mocker.mockFunc(presenter.favoriteDataSource, presenter.favoriteDataSource.refresh))(presenter.favoriteList)
        .afterAction(() => {
          result = true;
        });
      presenter.aboutToAppear();
      expect(result).assertTrue();

      mocker.clear(presenter.favoriteDataSource);
    })

    it('EditFavoriteListPresenter_aboutToAppear_noIf', 0, () => {

      let mocker: MockKit = new MockKit();
      let result = false;
      when(mocker.mockFunc(presenter.favoriteDataSource, presenter.favoriteDataSource.refresh))(presenter.favoriteList)
        .afterAction(() => {
          result = true;
        });

      presenter.aboutToAppear();

      expect(result).assertTrue();

      mocker.clear(presenter.favoriteDataSource);
    })

    it('EditFavoriteListPresenter_aboutToDisappear', 0, () => {
      presenter.aboutToDisappear();
      expect(presenter.contactsTotal).assertEqual(0);
    })

    it('EditFavoriteListPresenter_onPageShow', 0, () => {
      presenter.onPageShow();
      expect(presenter.contactsTotal).assertEqual(0);
    })

    it('EditFavoriteListPresenter_onPageHide', 0, () => {
      presenter.onPageHide();
      expect(presenter.contactsTotal).assertEqual(0);
    })

    it('EditFavoriteListPresenter_refreshPageMessage01', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      presenter.selectedContacts.add('1');
      presenter.selectedContacts.add('2');
      presenter.selectedContacts.add('3');
      presenter.selectedContacts.add('4');
      presenter.contactsTotal = 4;
      presenter.refreshPageMessage();
      expect(JSON.stringify(presenter.allSelectMessage)).assertEqual(JSON.stringify($r('app.string.unselect_all')));

      mocker.clear(ResourceUtil);

    })
    it('EditFavoriteListPresenter_refreshPageMessage02', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      presenter.contactsTotal = 0;
      presenter.selectNumber = 0
      presenter.refreshPageMessage();
      expect(JSON.stringify(presenter.allSelectMessage)).assertEqual(JSON.stringify($r('app.string.select_all')));

      mocker.clear(ResourceUtil);
    })

    it('EditFavoriteListPresenter_refreshPageMessage03', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      presenter.selectedContacts.add('1');
      presenter.selectedContacts.add('2');
      presenter.selectedContacts.add('3');
      presenter.contactsTotal = -1;
      presenter.refreshPageMessage();
      expect(JSON.stringify(presenter.allSelectMessage)).assertEqual(JSON.stringify($r('app.string.select_all')));

      mocker.clear(ResourceUtil);
    })
  })
}