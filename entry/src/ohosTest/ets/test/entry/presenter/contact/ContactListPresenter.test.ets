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
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import { ContactRepository } from '../../../../../../../../feature/contact'
import { ContactVo, ContactVoName } from '../../../../../../main/ets/model/bean/ContactVo'
import ContactListPresenter from '../../../../../../main/ets/presenter/contact/ContactListPresenter'
import WorkerWrapper from '../../../../../../main/ets/workers/base/WorkerWrapper'
import { WorkerType } from '../../../../../../main/ets/workers/WorkFactory'
import { ArrayUtil, DynamicLoader, sharedPreferencesUtils } from '../../../../../../../../common';
import { PhoneNumberInterface, SpeedDialItem } from '../../../../../../main/ets/model/type'
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor'
import preferences from '@ohos.data.preferences'
import { PhoneNum } from '../../../../../../../../feature/call/src/main/ets/entity/CallLogTemp'
import { CallLogSearchBo } from '../../../../../../main/ets/model/bean/CallLogSearchBo'
import LooseObject from '../../../../../../main/ets/model/type/LooseObject'
import { ChangeIdInfo, ListenChangeContactUtil } from '../../../../../../main/ets/util/ListenChangeContactUtil'
import { CommonEventUtil } from '../../../../../../../../common/src/main/ets/util/CommonEventUtil';
import { ProfileUtils } from '../../../../../../main/ets/util/ProfileUtils'
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
import { dataShare } from '@kit.ArkData'
import ContactListShowInfo from '../../../../../../main/ets/model/bean/ContactListShowInfo'
import { PixelMapManager } from '../../../../../../main/ets/util/UserPhoto'
import IndexPresenter from '../../../../../../main/ets/presenter/IndexPresenter'
import { PhoneNumBean } from '../../../../../../main/ets/model/bean/PhoneNumBean'
import { PreDefinedContactUtil } from '../../../../../../main/ets/util/PreDefineContactUtil'
import { PhoneNumber } from '../../../../../../../../feature/phonenumber';
import { asset } from '@kit.AssetStoreKit'
import { SearchContactResult } from '../../../../../../main/ets/model/bean/SearchContactResult'

const TAG = 'SpeedDialCardAbilityTAG';

export default function ContactListPresenterTest() {
  describe('ContactListPresenterTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.

    let subject: ContactListPresenter;
    let mocker: MockKit;
    let contactVo: ContactVo;
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      AppStorage.clear();
      subject = ContactListPresenter.getDTTestInstance();
      mocker = new MockKit();
      contactVo = new ContactVo('', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
      mocker.clear(subject);
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('ContactListPresenterTest_getInstance', 0, () => {
      expect(typeof subject).assertEqual(typeof ContactListPresenter.getInstance());
    })
    it('ContactListPresenterTest_onContactChange_02', 0, () => {
      subject.inputKeyword = 'notEmpty';
      mocker.mockFunc(subject, subject.requestItem);
      AppStorage.setOrCreate<boolean>("importingSimContacts", false);
      mocker.mockFunc(CallLogSearchBo.getInstance(), CallLogSearchBo.getInstance().refreshCallChangeFlag)
      mocker.mockFunc(subject, subject.getSearchContactResult)

      subject.onContactChange();

      expect(subject.debounceTimer).assertNull();

      ContactListPresenter.getInstance().localId = 1;
      mocker.mockFunc(ContactListPresenter.getInstance(), ContactListPresenter.getInstance().onContactChangeHandleAfterQueryLocalId);
      subject.onContactChange();
      expect(subject.debounceTimer).assertNull();
      mocker.clear(CallLogSearchBo.getInstance());
      mocker.clear(ContactListPresenter.getInstance());
    })
    it('ContactListPresenterTest_onNewContactToIndex', 0, () => {
      AppStorage.setOrCreate<string>('breakpoint', 'md');

      subject.onNewContactToIndex('1', 0);

      // expect
      expect(AppStorage.get('selectContactId')).assertEqual('1');

      AppStorage.setOrCreate<string>('breakpoint', 'sm');
      subject.onNewContactToIndex('1', 0);
      expect(AppStorage.get('selectContactId')).assertEqual('1');
    })
    it('ContactListPresenterTest_mPrepareCallBack', 0, () => {
      let subject: ContactListPresenter = ContactListPresenter.getDTTestInstance();
      let result = false;
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getAllContactSizeAndIndex').afterAction(() => {
        result = true;
      });
      subject.mPrepareCallBack();
      expect(result).assertFalse();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);
    })

    it('ContactListPresenterTest_bindUI', 0, () => {
      let refreshState = () => {
        1
      };
      let refreshDeleteContact = () => {
        2
      };
      subject.bindUI(refreshState, refreshDeleteContact);
      expect(subject.refreshState).assertEqual(refreshState);
      expect(subject.refreshDeleteContact).assertEqual(refreshDeleteContact);
    })

    // defect density
    it('ContactListPresenterTest_startInit', 0, () => {
      mocker.mockFunc(subject, subject.requestItem);
      subject.startInit();
      expect(subject.initStarted).assertTrue();
      mocker.verify('requestItem', []).once();
    })
    // defect density
    it('ContactListPresenterTest_startInit_already_started', 0, () => {
      subject.initStarted = true
      mocker.mockFunc(subject, subject.requestItem);

      subject.startInit();
      expect(subject.initStarted).assertTrue();
      mocker.verify('requestItem', []).once();
    })
    // it('ContactListPresenterTest_aboutToAppear', 0, () => {
    //   mocker.mockFunc(ContactRepository.getInstance(), ContactRepository.getInstance().registerDataChangeObserver);
    //
    //   AppStorage.setOrCreate('windowHeightPx', 77);
    //   subject.aboutToAppear(genericAutoMergeDialogController())
    //
    //   expect(subject.screenHeight).assertEqual(77);
    //   mocker.clear(ContactRepository.getInstance());
    // })
    it('ContactListPresenterTest_setPageShow_01', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject.limitDataRefresh, subject.limitDataRefresh?.setTaskForeground);
      mocker.mockFunc(subject, subject.startInit);
      let mockFun: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockFun)(ArgumentMatchers.any).afterReturn(new Promise<preferences.ValueType>(resolve => resolve(0)))

      subject.setPageShow(true);
      expect(subject.isShow).assertTrue();

      mocker.clear(subject.limitDataRefresh);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(subject);
    })
    it('ContactListPresenterTest_setPageShow_02', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.startInit);
      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      when(mockedFunc)('accountType').afterReturn(new Promise<number>(resolve => resolve(-1)))
      subject.isShow = true;
      mocker.mockFunc(subject.limitDataRefresh, subject.limitDataRefresh?.setTaskForeground);

      subject.setPageShow(false);

      expect(subject.isShow).assertFalse();
      mocker.clear(subject.limitDataRefresh);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(subject);
    })
    it('ContactListPresenterTest_setPageShow_03', 0, () => {
      subject.isShow = true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.limitRefreshInit);
      subject.setPageShow(true);
      mocker.verify('limitRefreshInit', []).never();
      mocker.clear(subject);
    })
    it('ContactListPresenterTest_setPageShow_04', 0, () => {
      subject.isShow = false;
      subject.setPageShow(true);
      expect(subject.repeatNum).assertEqual(0);
    })
    it('ContactListPresenterTest_requestItem', 0, () => {
      let result = false;
      let mockFunc: Function =
        mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
          .getValue);
      let workerWrapper = new WorkerWrapper(WorkerType.DataWorker, false);
      when(mockFunc)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(workerWrapper);

      let mockSendRequest: Function = mocker.mockFunc(workerWrapper, workerWrapper.sendRequest);
      when(mockSendRequest)('getContactIdToBlobDataMap').afterAction(() => {
        result = true;
      });

      subject.requestItem()

      expect(result).assertTrue();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(workerWrapper);

    })
    it('ContactListPresenterTest_onShareDialogCancel', 0, () => {
      //empty method
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      subject.onShareDialogCancel()
      mocker.verify('i', [TAG, 'onShareDialogCancel !!! ']).never();
      mocker.clear(HiLog);
    })
    it('ContactListPresenterTest_onShareDialogConfirm', 0, () => {
      //empty method
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      subject.onShareDialogConfirm()
      mocker.verify('i', [TAG, 'onShareDialogConfirm !!! ']).never();
      mocker.clear(HiLog);
    })
    it('ContactListPresenterTest_onShareItemClick', 0, () => {
      //empty method
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let index: number = 0;
      subject.onShareItemClick("", index)
      mocker.verify('i', [TAG, 'onShareItemClick !!! index is %s' + index]).never();
      mocker.clear(HiLog);
    })

    it('ContactListPresenterTest_loginAccount', 0, () => {
      subject.pathInfos = new NavPathStack();
      subject.loginAccount();
      expect(subject.pathInfos?.getAllPathName().toString()).assertEqual([''].toString());
    })

    it('ContactListPresenterTest_importContact', 0, () => {
      subject.pathInfos = new NavPathStack();
      subject.importContact();
      expect(subject.pathInfos?.getAllPathName().toString()).assertEqual([''].toString());
    })

    it('ContactListPresenterTest_toSettings', 0, async () => {
      let mockedFun: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire)
      when(mockedFun)('Settings').afterReturn(new Promise<void>(resolve => resolve()));
      let pathStack = new NavPathStack()
      subject.pathInfos = pathStack
      subject.total = 0
      mocker.mockFunc(pathStack, pathStack.pushPathByName)

      await subject.toSettings()

      mocker.verify("pushPathByName", ['Settings', 0]).never()
      mocker.clear(pathStack);
      mocker.clear(DynamicLoader.getInstance());
    })
    it('ContactListPresenterTest_scanCard', 0, () => {
      subject.pathInfos = new NavPathStack();
      subject.scanCard();
      expect(subject.pathInfos?.getAllPathName().toString()).assertEqual([''].toString());
    })

    it('ContactListPresenterTest_toGroupList', 0, () => {
      subject.pathInfos = new NavPathStack();

      subject.toGroupList();

      expect(subject.pathInfos?.getAllPathName().toString()).assertEqual(['GroupList'].toString());
    })
    it("heightConversion", 0, () => {
      subject.theoreticalHeight = 3120;
      subject.screenHeight = 840;
      let heightConversion: number = 552;
      expect(px2vp(heightConversion /
      subject.theoreticalHeight *
      subject.screenHeight)).assertEqual(subject.heightConversion(heightConversion));
    })
    it('ContactListPresenterTest_getSearchContactResult_01', 0, () => {
      let value: string = '0'
      subject.getSearchContactResult(value);
      expect(subject.workerId).assertEqual(0);
    })
    it('ContactListPresenterTest_getSearchContactResult_02', 0, () => {
      let value: string = ''
      subject.getSearchContactResult(value);
      expect(subject.timestamp).assertEqual(0);
    })
    it('ContactListPresenterTest_getSearchContactResult_03', 0, () => {
      let value: string = '1234'
      subject.getSearchContactResult(value);
      expect(subject.emitterId).assertEqual(108);
    })
    it('ContactListPresenterTest_checkCondition', 0, () => {
      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      let num: number = 0
      when(mockFunc)('autoMergeTime').afterReturn(new Promise<number>(resolve => resolve(num)));

      subject.checkCondition()

      mocker.verify("checkContactTaskStart", []).never()
      mocker.clear(sharedPreferencesUtils);
    })
    it('ContactListPresenterTest_checkCondition_expired', 0, () => {
      const TWO_DAY: number = 60 * 60 * 24 * 2 * 1000;
      let result = 0;

      let mockFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences);
      let autoMergeTime = new Date().getTime() - TWO_DAY - 1000
      when(mockFunc)("autoMergeTime").afterReturn(new Promise<number>(resolve => resolve(autoMergeTime)))
      let mockFuncSubscribe: Function = mocker.mockFunc(CommonEventUtil, CommonEventUtil.subscribe);
      when(mockFuncSubscribe)(ArgumentMatchers.any).afterAction(() => {
        result++;
      })

      subject.createSubscriber();
      subject.checkCondition()

      expect(subject.screenHeight).assertEqual(0);
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(CommonEventUtil);
    })
    it('ContactListPresenterTest_createSubscriber', 0, () => {
      ContactListPresenter.getDTTestInstance().createSubscriber()
      expect(subject.deletingContact).assertFalse();
    })
    it("ContactListPresenterTest_processData", 0, () => {
      let phoneNumList: PhoneNum[] = [new PhoneNum('1', '', '<em>职位</em>信息')]
      let expectedResult: string[] = ["", "em", "职位", "/em", "信息"]

      let data: string[] = subject.processData(phoneNumList)

      expect(JSON.stringify(expectedResult)).assertEqual(JSON.stringify(data))
    })
    it("ContactListPresenterTest_checkMerge_isFirstAutoMerge", 0, async () => {
      let autoMergeDialogController: CustomDialogController = genericAutoMergeDialogController()
      mocker.mockFunc(subject, subject.checkRepeatContact)
      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(mockedFunc)('isFirstAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      when(mockedFunc)('isCancel').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      when(mockedFunc)('alwaysAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('autoMergeCancelState').afterReturn(new Promise<boolean>(resolve => resolve(false)))

      await subject.checkMerge(autoMergeDialogController)

      expect(subject.isAutoMerge).assertFalse();
      mocker.clear(sharedPreferencesUtils)
    })
    it("ContactListPresenterTest_checkMerge_alwaysAutoMerge", 0, async () => {
      let autoMergeDialogController: CustomDialogController = genericAutoMergeDialogController()

      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(mockedFunc)('isFirstAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isCancel').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      when(mockedFunc)('alwaysAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      when(mockedFunc)('autoMergeCancelState').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      mocker.mockFunc(subject, subject.checkCondition)

      await subject.checkMerge(autoMergeDialogController)

      expect(subject.repeatNum).assertEqual(0);
      mocker.clear(sharedPreferencesUtils);
    })
    it("ContactListPresenterTest_checkMerge_alwaysAutoMerge_false_autoMergeCancelState_false", 0, async () => {
      let autoMergeDialogController: CustomDialogController = genericAutoMergeDialogController()
      mocker.mockFunc(autoMergeDialogController, autoMergeDialogController.close)
      mocker.mockFunc(subject, subject.checkCondition)
      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(mockedFunc)('isFirstAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isCancel').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('alwaysAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('autoMergeCancelState').afterReturn(new Promise<boolean>(resolve => resolve(false)))

      await subject.checkMerge(autoMergeDialogController)

      expect(subject.total).assertEqual(-1)
      mocker.clear(sharedPreferencesUtils)
      mocker.clear(subject);
      mocker.clear(autoMergeDialogController);
    })
    it("ContactListPresenterTest_checkMerge_alwaysAutoMerge_false_autoMergeCancelState_true", 0, async () => {
      const ONE_MONTH: number = 60 * 60 * 24 * 30 * 1000;
      let autoMergeDialogController: CustomDialogController = genericAutoMergeDialogController()
      mocker.mockFunc(autoMergeDialogController, autoMergeDialogController.close)
      mocker.mockFunc(subject, subject.checkRepeatContact)
      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(mockedFunc)('isFirstAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isCancel').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('alwaysAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('autoMergeCancelState').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      let startTime = new Date().getTime() - ONE_MONTH - 1000
      when(mockedFunc)("checkAutoMergeTime")
        .afterReturn(new Promise<number>(resolve => resolve(startTime)))

      await subject.checkMerge(autoMergeDialogController)

      expect(subject.contactsSize).assertEqual(0)
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(subject);
      mocker.clear(autoMergeDialogController);
    })

    // ContactListPresenterTest refreshContactListByNoIdMsg
    it('ContactListPresenterTest_refreshContactListByNoIdMsg', 0, () => {
      let changeIdInfo = new ChangeIdInfo();
      changeIdInfo.delRawContactIdArr = ['1'];
      ListenChangeContactUtil.getInstance().produceChangeIds(changeIdInfo);
      ContactListPresenter.getInstance().refreshContactListByNoIdMsg();
      let changeIdInfoCunsume = ListenChangeContactUtil.getInstance().consumeChangeIds();
      expect(0).assertEqual(changeIdInfoCunsume.delRawContactIdArr.length);

    })
    it("ContactListPresenterTest_checkMerge_alwaysAutoMerge_false_autoMergeCancelState_true_else", 0, async () => {
      const TWO_DAY: number = 60 * 60 * 24 * 2 * 1000;
      let autoMergeDialogController: CustomDialogController = genericAutoMergeDialogController()
      mocker.mockFunc(autoMergeDialogController, autoMergeDialogController.close)
      mocker.mockFunc(subject, subject.checkRepeatContact)
      let mockedFunc: Function = mocker.mockFunc(sharedPreferencesUtils, sharedPreferencesUtils.getFromPreferences)
      when(mockedFunc)('isFirstAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isCancel').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('isAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('alwaysAutoMerge').afterReturn(new Promise<boolean>(resolve => resolve(false)))
      when(mockedFunc)('autoMergeCancelState').afterReturn(new Promise<boolean>(resolve => resolve(true)))
      let startTime = new Date().getTime() - 1000
      when(mockedFunc)("checkAutoMergeTime").afterReturn(new Promise<number>(resolve => resolve(startTime)))
      let autoMergeTime = new Date().getTime() - TWO_DAY - 1000
      when(mockedFunc)("autoMergeTime").afterReturn(new Promise<number>(resolve => resolve(autoMergeTime)))

      await subject.checkMerge(autoMergeDialogController)

      expect(subject.isAutoMerge).assertFalse();
      mocker.clear(sharedPreferencesUtils);
      mocker.clear(subject);
      mocker.clear(autoMergeDialogController);
    })
    it("ContactListPresenterTest_toDefaultPage", 0, () => {
      subject.pathInfos = new NavPathStack()
      mocker.mockFunc(subject.pathInfos, subject.pathInfos.clear)
      mocker.mockFunc(subject.pathInfos, subject.pathInfos.pushPathByName)
      AppStorage.setOrCreate<string>('breakpoint', 'md');
      AppStorage.SetOrCreate<boolean>('isNavigationModeSplit', true);

      subject.toDefaultPage()

      mocker.verify("clear", []).once()
      mocker.verify("pushPathByName", ['ContactDefaultPage', '', false]).once()
      mocker.clear(subject.pathInfos);
    })
    it("ContactListPresenterTest_isSameAccountWithLocal_if", 0, () => {
      subject.localId = 100;
      expect(subject.isSameAccountWithLocal(100)).assertTrue();
    })
    it("ContactListPresenterTest_isSameAccountWithLocal_else", 0, () => {
      subject.localId = 100;
      expect(subject.isSameAccountWithLocal(101)).assertFalse();
    })
    it("ContactListPresenterTest_searchContactCallBack_01", 0, () => {
      let searchResultsObject: LooseObject = [{
        'emails': [],
        'entityId': '1',
        'familyAddress': [],
        'imInfo': [],
        'name': '张三',
        'nickname': '',
        'note': '',
        'organization': '',
        'phoneNumbers': [{
          'id': '1',
          'label': '',
          'value': '13801001111'
        }],
        'position': ''
      }];
      subject.searchContactCallBack(searchResultsObject, 1)
      expect(AppStorage.get<boolean>('isSearchBackgroundColor')).assertTrue();
    })
    it("ContactListPresenterTest_searchContactCallBack_02", 0, () => {
      let searchResultsObject: LooseObject = [];
      subject.searchContactCallBack(searchResultsObject, 1)
      expect(AppStorage.get<boolean>('isSearchBackgroundColor')).assertFalse();
    })
    it("ContactListPresenterTest_searchContactCallBack_03", 0, () => {
      let searchResultsObject: LooseObject = [{
        'emails': [],
        'entityId': '1',
        'familyAddress': [],
        'imInfo': [],
        'name': '张三',
        'nickname': '',
        'note': '',
        'organization': '',
        'phoneNumbers': [{
          'id': '1',
          'label': '',
          'value': '13801001111'
        }],
        'position': ''
      }];
      let searchResults: LooseObject = Array(100).fill(searchResultsObject).flat();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.contactSearchTask);
      subject.searchContactCallBack(searchResults, 1);
      mocker.verify('contactSearchTask', []).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_searchContactCallBack_04", 0, () => {
      let searchResultsObject: LooseObject = [{
        'emails': [],
        'entityId': '1',
        'familyAddress': [],
        'imInfo': [],
        'name': '张三',
        'nickname': '',
        'note': '',
        'organization': '',
        'phoneNumbers': [{
          'id': '1',
          'label': '',
          'value': '13801001111'
        }],
        'position': ''
      }];
      subject.searchContactCallBack(searchResultsObject, 1);
      expect(subject.searchResultParams.ISRESULT).assertEqual(1);
    })
    it("ContactListPresenterTest_searchContactCallBack_05", 0, () => {
      let searchResultsObject: LooseObject = [];
      subject.searchContactCallBack(searchResultsObject, 1);
      expect(subject.searchResultParams.ISRESULT).assertEqual(0);
    })
    it("ContactListPresenterTest_parseChangeIdInfo_01", 0, () => {
      let changeInfo = undefined;
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(new ChangeIdInfo()));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_02", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': []
      };
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(new ChangeIdInfo()));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_03", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [
          {},
          {
            'delIdStr': '',
            'notifyModifyType': '',
            'updateIdStr': '',
            'userId': 100
          }
        ]
      };
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(new ChangeIdInfo()));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_04", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '',
          'notifyModifyType': '',
          'updateIdStr': '',
          'userId': null
        }]
      };
      let changeIdInfo: ChangeIdInfo = {
        delRawContactIdArr: [],
        updateRawContactIdArr: [],
        notifyModifyType: ''
      }
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(changeIdInfo));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_05", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '',
          'notifyModifyType': '',
          'updateIdStr': '',
          'userId': 100
        }]
      };
      subject.localId = 100;
      let changeIdInfo: ChangeIdInfo = {
        delRawContactIdArr: [],
        updateRawContactIdArr: [],
        notifyModifyType: ''
      }
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(changeIdInfo));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_06", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '',
          'notifyModifyType': '',
          'updateIdStr': '',
          'userId': 101
        }]
      };
      subject.localId = 100;
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(new ChangeIdInfo()));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_07", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '100',
          'notifyModifyType': '',
          'updateIdStr': '',
          'userId': 100
        }]
      };
      subject.localId = 100;
      let changeIdInfo: ChangeIdInfo = {
        delRawContactIdArr: ['100'],
        updateRawContactIdArr: [],
        notifyModifyType: ''
      }
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(changeIdInfo));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_08", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '',
          'notifyModifyType': '',
          'updateIdStr': '100',
          'userId': 100
        }]
      };
      subject.localId = 100;
      let changeIdInfo: ChangeIdInfo = {
        delRawContactIdArr: [],
        updateRawContactIdArr: ['100'],
        notifyModifyType: ''
      }
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(changeIdInfo));
    })
    it("ContactListPresenterTest_parseChangeIdInfo_09", 0, () => {
      let changeInfo: dataShare.ChangeInfo = {
        'type': 1,
        'uri': '',
        'values': [{
          'delIdStr': '',
          'notifyModifyType': '100',
          'updateIdStr': '',
          'userId': 100
        }]
      };
      subject.localId = 100;
      let changeIdInfo: ChangeIdInfo = {
        delRawContactIdArr: [],
        updateRawContactIdArr: [],
        notifyModifyType: '100'
      }
      expect(JSON.stringify(subject.parseChangeIdInfo(changeInfo))).assertEqual(JSON.stringify(changeIdInfo));
    })
    it("ContactListPresenterTest_judgeAndLogSortError_01", 0, () => {
      contactVo.namePrefix = '#';
      contactVo.sort = '1';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['# sort error', contactVo]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_02", 0, () => {
      contactVo.namePrefix = '#';
      contactVo.sort = '-1';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['# sort error', contactVo]).never();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_03", 0, () => {
      contactVo.namePrefix = '...';
      contactVo.sort = '99';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['... sort error', contactVo]).never();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_04", 0, () => {
      contactVo.namePrefix = '...';
      contactVo.sort = '-99';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['... sort error', contactVo]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_05", 0, () => {
      contactVo.namePrefix = '1';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['1 sort error', contactVo]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_06", 0, () => {
      contactVo.namePrefix = '1';
      contactVo.sort = '49';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['1 sort error', contactVo]).never();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_judgeAndLogSortError_07", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.logSortError);
      subject.judgeAndLogSortError(contactVo);
      mocker.verify('logSortError', ['sortFirstLetter has no value, sort error', contactVo]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_compare_01", 0, () => {
      let contactVo1 = new ContactVo('', '', '1', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      let contactVo2 = new ContactVo('', '', '2', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      expect(subject.compare(contactVo1, contactVo2)).assertEqual(-1);
    })
    it("ContactListPresenterTest_compare_02", 0, () => {
      let contactVo1 = new ContactVo('', '1', '1', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVo1.sortKey = '1';
      let contactVo2 = new ContactVo('', '2', '1', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVo2.sortKey = '2';
      expect(subject.compare(contactVo1, contactVo2)).assertEqual(-1);
    })
    it("ContactListPresenterTest_compare_03", 0, () => {
      let contactVo1 = new ContactVo('', '', '1', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVo1.sortKey = '2';
      let contactVo2 = new ContactVo('', '', '1', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVo2.sortKey = '1';
      expect(subject.compare(contactVo1, contactVo2)).assertEqual(1);
    })
    it("ContactListPresenterTest_removeOrReplaceContactBefore_01", 0, () => {
      let contactVoNew: ContactVo = new ContactVo('1', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoNew.sortKey = '1';
      let contactListBefore: ContactVo[] = [contactVoNew];
      subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew);
      expect(subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew)).assertTrue();
    })
    it("ContactListPresenterTest_removeOrReplaceContactBefore_02", 0, () => {
      let contactVoNew: ContactVo = new ContactVo('1', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoNew.sortKey = '1';
      let contactVoOld: ContactVo = new ContactVo('1', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoOld.sortKey = '2';
      let contactListBefore: ContactVo[] = [contactVoOld];
      subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew);
      expect(subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew)).assertFalse();
    })
    it("ContactListPresenterTest_removeOrReplaceContactBefore_03", 0, () => {
      let contactVoNew: ContactVo = new ContactVo('1', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoNew.sortKey = '1';
      let contactVoOld: ContactVo = new ContactVo('2', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoOld.sortKey = '2';
      let contactListBefore: ContactVo[] = [contactVoOld];
      subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew);
      expect(subject.removeOrReplaceContactBefore(contactListBefore, contactVoNew)).assertFalse();
    })
    it("ContactListPresenterTest_addNewContacts", 0, () => {
      let contactListBefore: ContactVo[] = [contactVo];
      let contactListNew: ContactVo[] = [contactVo];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.refreshContactFromStartIndex);
      subject.addNewContacts(contactListBefore, contactListNew);
      mocker.verify('refreshContactFromStartIndex', [contactListBefore, contactVo, 0]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_getCardDataByVo_01", 0, () => {
      contactVo.showName = 'showName';
      let contactListShowInfo: ContactListShowInfo = new ContactListShowInfo(true, false,
        contactVo.contactId, contactVo.nameRawContactId, contactVo.headChar, contactVo.portraitPath,
        contactVo.namePrefix, contactVo.showName, contactVo.subTitle);
      expect(JSON.stringify(subject.getCardDataByVo(contactVo))).assertEqual(JSON.stringify(contactListShowInfo));
    })
    it("ContactListPresenterTest_getCardDataByVo_02", 0, () => {
      contactVo.phoneNum = 'phoneNum';
      contactVo.showName = '';
      let contactListShowInfo: ContactListShowInfo = new ContactListShowInfo(true, false,
        contactVo.contactId, contactVo.nameRawContactId, contactVo.headChar, contactVo.portraitPath,
        contactVo.namePrefix, contactVo.phoneNum, contactVo.subTitle);
      expect(JSON.stringify(subject.getCardDataByVo(contactVo))).assertEqual(JSON.stringify(contactListShowInfo));
    })
    it("ContactListPresenterTest_getCardDataByVo_03", 0, () => {
      contactVo.showName = 'showName';
      contactVo.company = '';
      contactVo.position = '';
      let contactListShowInfo: ContactListShowInfo = new ContactListShowInfo(true, false,
        contactVo.contactId, contactVo.nameRawContactId, contactVo.headChar, contactVo.portraitPath,
        contactVo.namePrefix, 'showName', contactVo.subTitle);
      expect(JSON.stringify(subject.getCardDataByVo(contactVo))).assertEqual(JSON.stringify(contactListShowInfo));
    })
    it("ContactListPresenterTest_getCardDataByVo_04", 0, () => {
      contactVo.showName = 'showName';
      contactVo.company = '';
      contactVo.position = 'position';
      let contactListShowInfo: ContactListShowInfo = new ContactListShowInfo(true, false,
        contactVo.contactId, contactVo.nameRawContactId, contactVo.headChar, contactVo.portraitPath,
        contactVo.namePrefix, 'showName', 'position');
      expect(JSON.stringify(subject.getCardDataByVo(contactVo))).assertEqual(JSON.stringify(contactListShowInfo));
    })
    it("ContactListPresenterTest_getCardDataByVo_05", 0, () => {
      contactVo.showName = 'showName';
      contactVo.company = 'company';
      contactVo.position = 'position';
      let contactListShowInfo: ContactListShowInfo = new ContactListShowInfo(true, false,
        contactVo.contactId, contactVo.nameRawContactId, contactVo.headChar, contactVo.portraitPath,
        contactVo.namePrefix, 'showName', 'company position');
      expect(JSON.stringify(subject.getCardDataByVo(contactVo))).assertEqual(JSON.stringify(contactListShowInfo));
    })
    it("ContactListPresenterTest_removeAndRefreshIndex_01", 0, () => {
      subject.contactListDataSource.contactList = [contactVo, contactVo];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataChange);
      subject.removeAndRefreshIndex(0);
      mocker.verify('notifyDataChange', [0]).once();
      mocker.clear(subject.contactListDataSource);
    })
    it("ContactListPresenterTest_removeAndRefreshIndex_02", 0, () => {
      subject.contactListDataSource.contactList = [contactVo];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataChange);
      subject.removeAndRefreshIndex(2);
      mocker.verify('notifyDataChange', [1]).once();
      mocker.clear(subject.contactListDataSource);
    })
    it("ContactListPresenterTest_refreshContactListDatasourceAndPhotoByDelIds_01", 0, () => {
      subject.contactListDataSource.contactList = [];
      let rawContactIdsDel = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(PixelMapManager.getInstance(), PixelMapManager.getInstance().updateBlobSourceMap);
      subject.refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel);
      mocker.verify('updateBlobSourceMap', [new Map, '1']).never();
      mocker.clear(PixelMapManager.getInstance());
    })
    it("ContactListPresenterTest_refreshContactListDatasourceAndPhotoByDelIds_02", 0, () => {
      contactVo.nameRawContactId = '1';
      subject.contactListDataSource.contactList = [contactVo];
      let rawContactIdsDel = ['1'];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.removeAndRefreshIndex);
      subject.refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel);
      mocker.verify('removeAndRefreshIndex', [0]).once();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_refreshContactListDatasourceAndPhotoByDelIds_03", 0, () => {
      contactVo.nameRawContactId = '2';
      subject.contactListDataSource.contactList = [contactVo];
      let rawContactIdsDel = ['1'];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.removeAndRefreshIndex);
      subject.refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel);
      mocker.verify('removeAndRefreshIndex', [0]).never();
      mocker.clear(subject);
    })
    it("ContactListPresenterTest_refreshContactListDatasourceAndPhotoByDelIds_04", 0, () => {
      contactVo.nameRawContactId = '1';
      subject.contactListDataSource.contactList = [contactVo];
      let rawContactIdsDel = ['1'];
      AppStorage.setOrCreate('mainTabsIndex', 0);
      IndexPresenter.getInstance().contactIndex = 0;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().emitDefaultSelectedContact);
      subject.refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel);
      mocker.verify('emitDefaultSelectedContact', []).once();
      mocker.clear(IndexPresenter.getInstance());
    })
    it("ContactListPresenterTest_refreshContactListDatasourceAndPhotoByDelIds_05", 0, () => {
      contactVo.nameRawContactId = '1';
      subject.contactListDataSource.contactList = [contactVo];
      let rawContactIdsDel = ['1'];
      AppStorage.setOrCreate('mainTabsIndex', 0);
      IndexPresenter.getInstance().contactIndex = 1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().emitDefaultSelectedContact);
      subject.refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel);
      mocker.verify('emitDefaultSelectedContact', []).never();
      mocker.clear(IndexPresenter.getInstance());
    })
    it("ContactListPresenterTest_refreshContactPhotoByIds_01", 0, () => {
      let contactIds: string[] = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(PixelMapManager.getInstance(), PixelMapManager.getInstance().getBlobSourceMapCopy);
      subject.refreshContactPhotoByIds(contactIds);
      mocker.verify('getBlobSourceMapCopy', []).never();
      mocker.clear(PixelMapManager.getInstance());
    })

    it("ContactListPresenterTest_refreshContactListDataSourceByContacts_01", 0, () => {
      contactVo.contactId = '1';
      contactVo.sortKey = '1';
      let contactVoListNew: ContactVo[] = [contactVo];
      subject.contactListDataSource.contactList = [contactVo];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(subject, subject.removeOrReplaceContactBefore))(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(subject, subject.addNewContacts);
      AppStorage.setOrCreate('newContactId', 1);
      AppStorage.setOrCreate('breakpoint', 'lg');
      subject.refreshContactListDataSourceByContacts(contactVoListNew);
      expect(AppStorage.get('selectContactId')).assertEqual('1');
      mocker.clear(subject);
    })

    it("ContactListPresenterTest_refreshContactListDataSourceByContacts_02", 0, () => {
      contactVo.contactId = '1';
      contactVo.sortKey = '1';
      subject.contactListDataSource.contactList = [contactVo];
      let contactVoNew = new ContactVo('', '', '', '', '', '', {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, '', '', '0');
      contactVoNew.sortKey = '2';
      let contactVoListNew: ContactVo[] = [contactVoNew];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.addNewContacts);
      subject.refreshContactListDataSourceByContacts(contactVoListNew);
      mocker.verify('addNewContacts', [[contactVo], [contactVoNew]]).once();
      mocker.clear(subject);
    })

    it('ContactListPresenterTest_refreshContactFromStartIndex', 0, () => {
      let item2: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      expect( subject.refreshContactFromStartIndex([], item2, 0)).assertEqual(-1);

      let item: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      let item1: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      let list: ContactVo[] = [item, item1];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(subject, subject.compare))(ArgumentMatchers.any).afterReturn(-1);
      mocker.mockFunc(subject, subject.addAndRefreshIndex);
      expect(subject.refreshContactFromStartIndex(list, item2, 0)).assertEqual(0);
      mocker.clear(subject);
    })

    it('ContactListPresenterTest_addAndRefreshIndex', 0, () => {
      let item: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataAdd);
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataReload);
      subject.addAndRefreshIndex(item, 0);
      mocker.verify('notifyDataReload', []).once();

      let item1: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      let item2: ContactVo = new ContactVo("", "", "", "", "", "", MorandiColor.color[0], true, "", "", '0');
      let list: ContactVo[] = [item1, item2];
      subject.contactListDataSource.contactList = list;
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataChange);
      subject.addAndRefreshIndex(item, 1);
      mocker.verify('notifyDataChange', [0]).once();
      mocker.clear(subject.contactListDataSource);
    })

    it('ContactListPresenterTest_handleDelContact', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.getIndexByContactId);
      subject.handleDelContact(-1, 1);
      mocker.verify('getIndexByContactId', [1]).once();

      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.removeIndex);
      mocker.mockFunc(subject.contactListDataSource, subject.contactListDataSource.notifyDataReload);
      mocker.mockFunc(subject.alphabetIndexPresenter, subject.alphabetIndexPresenter.initContactList);
      subject.handleDelContact(0);
      mocker.verify('removeIndex', [0]).once();
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(subject.contactListDataSource);
      mocker.clear(subject.alphabetIndexPresenter);
    })

    it('ContactListPresenterTest_startPreInit_01', 0, () => {
      subject.initStarted = true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.refreshState);
      subject.startPreInit();
      mocker.verify('refreshState', []).never();
      mocker.clear(subject);
    })

    it('ContactListPresenterTest_startPreInit_02', 0, () => {
      subject.startPreInitFlag = true;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(subject, subject.refreshState);
      subject.startPreInit();
      mocker.verify('refreshState', []).never();
      mocker.clear(subject);
    })

    it('ContactListPresenterTest_handlePreQueryResult_01', 0, () => {
      subject.startPreInitFlag = true;
      subject.total = -1;
      subject.handlePreQueryResult([]);
      expect(subject.total).assertLess(0);
    })
    it('ContactListPresenterTest_handlePreQueryResult_02', 0, () => {
      subject.startPreInitFlag = true;
      subject.total = -1;
      subject.handlePreQueryResult([contactWithName()]);
      expect(subject.total).assertEqual(1);
    })

    it('ContactListPresenterTest_refreshAlphabetIndexAndCount', 0, () => {
      subject.total = 0;
      subject.contactListDataSource.contactList = [contactVo];
      subject.refreshState = () => {};
      let mocker: MockKit = new MockKit();
      let getPreDefinedContactLoaded: Function = mocker.mockFunc(PreDefinedContactUtil,
        PreDefinedContactUtil.getPreDefinedContactLoaded);
      when(getPreDefinedContactLoaded)().afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(PreDefinedContactUtil, PreDefinedContactUtil.parsePreDefine);
      subject.refreshAlphabetIndexAndCount();
      expect(subject.total).assertEqual(0);
      mocker.verify('parsePreDefine', []).never();
      mocker.clear(PreDefinedContactUtil);
    })

    it('ContactListPresenterTest_cacheContactSearchPixelMap_01', 0, () => {
      let searchContactResult: SearchContactResult =
        new SearchContactResult('1', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      let cacheContactId: string = '1';
      let cacheContactIds: string[] = Array(5).fill(cacheContactId);
      AppStorage.setOrCreate('firstItemIndex', 0);
      AppStorage.setOrCreate('lastItemIndex', 4);
      subject.hasScrollIndexCachePhotoFinish = true;
      subject.contactSearchList = Array(5).fill(searchContactResult);
      subject.hasCachePhotoFinish = false;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(PixelMapManager.getInstance(), PixelMapManager.getInstance().updateContactSearchListMiniPixelMap);
      subject.cacheContactSearchPixelMap(5);
      mocker.verify('updateContactSearchListMiniPixelMap', [cacheContactIds]).once();
      mocker.clear(PixelMapManager.getInstance());
    })

    it('ContactListPresenterTest_cacheContactSearchPixelMap_02', 0, () => {
      let searchContactResult: SearchContactResult =
        new SearchContactResult('1', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      AppStorage.setOrCreate('firstItemIndex', 0);
      AppStorage.setOrCreate('lastItemIndex', 5);
      subject.hasScrollIndexCachePhotoFinish = true;
      subject.contactSearchList = Array(5).fill(searchContactResult);
      subject.hasCachePhotoFinish = false;
      subject.cacheContactSearchPixelMap(5);
      expect(subject.firstItemIndex).assertEqual(0);
    })
  })
}

function genericAutoMergeDialogController(): CustomDialogController {
  return new CustomDialogController({builder:null})
}


function contactRandom(): ContactVo {
  return new ContactVo(randomString(), randomString(), '', randomString(), randomString(),
    randomString(), MorandiColor.color[0], randomBoolean(), randomString(), randomString(), '0'
  )
}

function contactWithName(): ContactVo {
  let name: ContactVoName = new ContactVoName();
  return new ContactVo("12", "2", '', "1", "2", "1", MorandiColor.color[0], true, "1", "2", '0', name, "2", "1", "1", "2")
}

function contactWithNameAndPhone(checked: boolean): ContactVo {
  let contact = contactWithName()
  let checkedPhone: PhoneNumberInterface = {
    dataId: randomNumber(),
    phoneNumber: randomString(),
    labelId: randomString(),
    numType: randomString(),
    labelName: randomString(),
    checked: checked,
    startPhone: randomString(),
    middlePhone: randomString(),
    endPhone: randomString(),
  }
  let phoneNumbers: PhoneNumberInterface[] = [checkedPhone]

  contact.setphoneNumbers(phoneNumbers)
  return contact
}

function randomNumber() {
  return Math.floor(Math.random() * 10 ^ 9)
}

function randomString() {
  return (Math.random() + 1).toString(36).substring(7) //random string generated from float
}

function randomBoolean() {
  return Math.random() < 0.5 //50% chance for true
}