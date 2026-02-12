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
import IndexPresenter from '../../../../../main/ets/presenter/IndexPresenter';
import StringFormatUtil from '../../../../../main/ets/util/StringFormatUtil';
import CallRecordPresenter from '../../../../../main/ets/presenter/dialer/callRecord/CallRecordPresenter';
import { HiLog } from '../../../../../../../feature/call/oh_modules/common'
import { DisplaySplitUtil, SplitStatus } from '../../../../../main/ets/util/DisplaySplitUtil';
import ContactListPresenter from '../../../../../main/ets/presenter/contact/ContactListPresenter';
import EnvironmentProp from '../../../../../main/ets/feature/EnvironmentProp';
import { display } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { SearchUtil } from '../../../../../main/ets/util/SearchUtil';
import { ResourceUtil } from '../../../../../main/ets/util/ResourceUtil';

export default function IndexPresenterTest() {
  const TAG = 'IndexPresenter  '
  describe('IndexPresenterTest', () => {

    beforeEach(() => {
      AppStorage.clear();
    })

    it('IndexPresenterTest_goPageShow1', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(CallRecordPresenter.getInstance(), CallRecordPresenter.getInstance().requestItem);
      AppStorage.setOrCreate('is24HourClock', i18n.System.is24HourClock());
      IndexPresenter.getInstance().onPageShow();
      mocker.verify('requestItem', []).never();

      AppStorage.setOrCreate('is24HourClock', !i18n.System.is24HourClock());
      IndexPresenter.getInstance().onPageShow();
      mocker.verify('requestItem', []).once();

      mocker.clear(CallRecordPresenter.getInstance());
    })

    it('IndexPresenterTest_goToPage_01', 0, () => {
      let url = 'pages/index';
      IndexPresenter.getInstance().goToPage(url, 1);
      expect(IndexPresenter.getInstance().isFirstUpdateIndex).assertTrue();
    })

    it('IndexPresenterTest_goToPage_02', 0, () => {
      IndexPresenter.getInstance().pathInfos = new NavPathStack();
      IndexPresenter.getInstance().pathInfos.pushPathByName('test/url/01', '');
      IndexPresenter.getInstance().goToPage("test/url/01");
      expect(IndexPresenter.getInstance().pathInfos.getAllPathName().toString())
        .assertEqual(['test/url/01'].toString());
    })

    it('IndexPresenterTest_goToPage_03', 0, () => {
      IndexPresenter.getInstance().pathInfos = new NavPathStack();
      IndexPresenter.getInstance().pathInfos.pushPathByName('test/url/01', '');
      IndexPresenter.getInstance().pathInfos.pushPathByName('test/url/02', '');
      let params: Record<string, string> = {};
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      when(mockFunc)('Accountants').afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(IndexPresenter.getInstance().pathInfos?.pushPathByName('Accountants', params, false))
      }))
      IndexPresenter.getInstance().goToPage('Accountants', 0, params);
      expect(JSON.stringify(IndexPresenter.getInstance().pathInfos?.getParamByName('Accountants')))
        .assertEqual(JSON.stringify([params]));

      IndexPresenter.getInstance().goToPage('123', 0, params);
      expect(JSON.stringify(IndexPresenter.getInstance().pathInfos?.getParamByName('123')))
        .assertEqual(JSON.stringify([params]));
      mocker.clear(DynamicLoader.getInstance());
    })

    it('IndexPresenterTest_aboutToAppear', 0, () => {
      let mocker: MockKit = new MockKit();
      let judgeSysTime: Function = mocker.mockFunc(StringFormatUtil, StringFormatUtil.judgeSysTime);
      when(judgeSysTime)().afterReturn('12');

      IndexPresenter.getInstance().aboutToAppear();

      expect(AppStorage.get('sysTime')).assertEqual(12);

      mocker.clear(StringFormatUtil);
    })

    it('IndexPresenterTest_getCopy', 0, () => {
      let phoneNumber = '570977632';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      IndexPresenter.getInstance().getCopy(phoneNumber);
      mocker.verify('e', [TAG, 'Failed to set PasteData. Cause: '])
      mocker.verify('e', [TAG, 'Failed to set PasteData. Cause: ']).never()
      mocker.clear(HiLog);
    })

    it('IndexPresenterTest_getCurrentUrl', 0, () => {
      let url = 'testability/pages/Index'
      expect(IndexPresenter.getInstance().getCurrentUrl()).assertEqual(url)
    })

    it('IndexPresenterTest_isNeedDefaultSelectedDevice', 0, () => {
      let mocker: MockKit = new MockKit();
      let isVerticalSplit: Function = mocker.mockFunc(DisplaySplitUtil, DisplaySplitUtil.isVerticalSplit);
      when(isVerticalSplit)().afterReturn(true);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertFalse();

      when(isVerticalSplit)().afterReturn(false);
      AppStorage.setOrCreate('breakpoint', 'lg');
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertTrue();

      AppStorage.setOrCreate('breakpoint', 'sm');
      AppStorage.setOrCreate('FoldStatus', display.FoldStatus.FOLD_STATUS_UNKNOWN);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertFalse();

      AppStorage.setOrCreate('breakpoint', 'll');
      let mockfunc: Function =
        mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().getDeviceDisplayInfo);
      let deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();
      deviceDisplayInfo.width = 100;
      deviceDisplayInfo.densityPixels = 1;
      when(mockfunc)().afterReturn(deviceDisplayInfo);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertFalse();

      deviceDisplayInfo.width = 600;
      when(mockfunc)().afterReturn(deviceDisplayInfo);
      AppStorage.setOrCreate('isShowSmartWindow', true);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertFalse();

      AppStorage.setOrCreate('isShowSmartWindow', false);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertTrue();
      mocker.clear(DisplaySplitUtil);
      mocker.clear(IndexPresenter.getInstance());
    })

    it('IndexPresenterTest_updateMainTabIndex', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().hasVoiceCapability);
      when(mockFunc)().afterReturn(true);
      AppStorage.setOrCreate('isDistributedCallPhoneSharing', true);
      AppStorage.setOrCreate('isDistributedModemState', true);
      AppStorage.setOrCreate('isDistributedCallSourcePhone', true);
      IndexPresenter.getInstance().callIndex = 0;
      IndexPresenter.getInstance().updateMainTabIndex();
      expect(IndexPresenter.getInstance().callIndex).assertEqual(0);

      AppStorage.setOrCreate('mainTabsIndex', 0);
      IndexPresenter.getInstance().callIndex = 1;
      IndexPresenter.getInstance().updateMainTabIndex();
      expect(AppStorage.get('mainTabsIndex')).assertEqual(1);

      when(mockFunc)().afterReturn(false);
      AppStorage.setOrCreate('isDistributedCallPhoneSharing', false);
      AppStorage.setOrCreate('isDistributedModemState', false);
      AppStorage.setOrCreate('isDistributedCallSourcePhone', false);
      IndexPresenter.getInstance().callIndex = -1;
      IndexPresenter.getInstance().updateMainTabIndex();
      expect(IndexPresenter.getInstance().callIndex).assertEqual(-1);

      AppStorage.setOrCreate('mainTabsIndex', 0);
      IndexPresenter.getInstance().callIndex = 1;
      mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().emitDefaultSelectedContact);
      IndexPresenter.getInstance().updateMainTabIndex();
      mocker.verify('emitDefaultSelectedContact', []).once();

      AppStorage.setOrCreate('mainTabsIndex', 1);
      IndexPresenter.getInstance().callIndex = 1;
      IndexPresenter.getInstance().updateMainTabIndex();
      expect(AppStorage.get('mainTabsIndex')).assertEqual(0);

      AppStorage.setOrCreate('mainTabsIndex', -1);
      IndexPresenter.getInstance().callIndex = 1;
      IndexPresenter.getInstance().updateMainTabIndex();
      expect(IndexPresenter.getInstance().callIndex).assertEqual(-1);
      mocker.clear(IndexPresenter.getInstance());
    })

    it('IndexPresenterTest_updateCurIndex', 0, () => {
      IndexPresenter.getInstance().updateCurIndex(0);
      expect(IndexPresenter.getInstance().curIndex).assertEqual(0);
    })

    it('IndexPresenterTest_updateMainTabIndexId', 0, () => {
      AppStorage.setOrCreate('isDistributedCallPhoneSharing', true);
      AppStorage.setOrCreate('isDistributedModemState', true);
      AppStorage.setOrCreate('isDistributedCallSourcePhone', true);
      IndexPresenter.getInstance().updateMainTabIndexId();
      expect(AppStorage.get('tabContactCall')).assertEqual('tab_item_1')
      expect(AppStorage.get('tabContactList')).assertEqual('tab_item_2')
      expect(AppStorage.get('tabContactFavorite')).assertEqual('tab_item_3')

      AppStorage.setOrCreate('isDistributedCallPhoneSharing', false);
      AppStorage.setOrCreate('isDistributedModemState', false);
      AppStorage.setOrCreate('isDistributedCallSourcePhone', false);
      IndexPresenter.getInstance().updateMainTabIndexId();
      expect(AppStorage.get('tabContactCall')).assertEqual('tab_item_0')
      expect(AppStorage.get('tabContactList')).assertEqual('tab_item_1')
      expect(AppStorage.get('tabContactFavorite')).assertEqual('tab_item_2')
    })

    it('IndexPresenterTest_emitDefaultSelectedContact', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);

      mocker.mockFunc(ContactListPresenter.getInstance(), ContactListPresenter.getInstance().openDefaultContactsDetail);
      AppStorage.setOrCreate('maintenanceMode', true);
      IndexPresenter.getInstance().emitDefaultSelectedContact();
      mocker.verify('openDefaultContactsDetail', []).never();

      AppStorage.setOrCreate('maintenanceMode', false);
      let isNeed: Function = mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isNeedDefaultSelectedDevice);
      when(isNeed)().afterReturn(false);
      let mockFunc: Function = mocker.mockFunc(IndexPresenter.getInstance().pathInfos, IndexPresenter.getInstance().pathInfos.getAllPathName);
      when(mockFunc)().afterReturn(['1', '2']);
      IndexPresenter.getInstance().emitDefaultSelectedContact();
      mocker.verify('openDefaultContactsDetail', []).never();
      when(mockFunc)().afterReturn(['1']);
      let isExist: Function = mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isExistTargetPath);
      when(isExist)(['1']).afterReturn(true);
      IndexPresenter.getInstance().emitDefaultSelectedContact();
      mocker.verify('openDefaultContactsDetail', []).never();
      when(isNeed)().afterReturn(true);
      when(mockFunc)().afterReturn(['1']);
      when(isExist)(['1']).afterReturn(false);
      IndexPresenter.getInstance().emitDefaultSelectedContact();
      mocker.verify('openDefaultContactsDetail', []).once();
      mocker.clear(IndexPresenter.getInstance());
      mocker.clear(IndexPresenter.getInstance().pathInfos);
      mocker.clear(ContactListPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })

    it('IndexPresenterTest_emitDefaultSelectedContact_error', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      when(mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().isNeedDefaultSelectedDevice))()
        .afterThrow('error');
      mocker.mockFunc(ContactListPresenter.getInstance(), ContactListPresenter.getInstance().openDefaultContactsDetail);
      IndexPresenter.getInstance().emitDefaultSelectedContact();
      mocker.verify('openDefaultContactsDetail', []).never();
      mocker.clear(IndexPresenter.getInstance());
      mocker.clear(ContactListPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })



    it('IndexPresenterTest_isExistTargetPath_00', 0, () => {
      expect(IndexPresenter.getInstance().isExistTargetPath(['aaa'])).assertFalse();

      let allPaths:string[] =  ['ContactDetail', 'GroupList', 'Settings', 'BatchSelectContactsPage', 'SingleSelectContactPage'];
      let result = IndexPresenter.getInstance().isExistTargetPath(allPaths);
      expect(result).assertTrue();

    })

    it('IndexPresenterTest_isOnCallSharing', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(EnvironmentProp, EnvironmentProp.isDeviceTypeTablet);
      when(mockFunc)().afterReturn(true);
      AppStorage.setOrCreate('isDistributedCallPhoneSharing', true);
      AppStorage.setOrCreate('isDistributedModemState', true);
      IndexPresenter.getInstance().isOnCallSharing();
      mocker.verify('isDeviceTypeTablet', []).once();

      AppStorage.setOrCreate('isDistributedCallPhoneSharing', false);
      AppStorage.setOrCreate('isDistributedModemState', false);
      IndexPresenter.getInstance().isOnCallSharing();
      expect(AppStorage.get('isOnCallSharingValue')).assertTrue();

      when(mockFunc)().afterReturn(false);
      IndexPresenter.getInstance().isOnCallSharing();
      expect(AppStorage.get('isOnCallSharingValue')).assertTrue();
      mocker.clear(IndexPresenter.getInstance());
      mocker.clear(EnvironmentProp);
    })

    it('IndexPresenterTest_initMainTabIndex', 0, () => {
      AppStorage.setOrCreate('isNoMissFormCard', true);
      IndexPresenter.getInstance().callIndex = -1;
      IndexPresenter.getInstance().initMainTabIndex();
      expect(AppStorage.get('isNoMissFormCard')).assertFalse();

      IndexPresenter.getInstance().callIndex = 1;
      IndexPresenter.getInstance().initMainTabIndex();
      expect(AppStorage.get('isNoMissFormCard')).assertFalse();
    })

    it('IndexPresenterTest_isNeedDefaultSelectedDevice01', 0, () => {
      AppStorage.setOrCreate('splitStatus', SplitStatus.HALF_SPLIT);
      AppStorage.setOrCreate('breakpoint', 'md');
      AppStorage.setOrCreate('isShowSmartWindow', true);
      let mocker: MockKit = new MockKit();
      let mockfunc: Function =
        mocker.mockFunc(IndexPresenter.getInstance(), IndexPresenter.getInstance().getDeviceDisplayInfo);
      let deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();
      deviceDisplayInfo.width = 600;
      deviceDisplayInfo.densityPixels = 1;
      when(mockfunc)().afterReturn(deviceDisplayInfo);
      expect(IndexPresenter.getInstance().isNeedDefaultSelectedDevice()).assertFalse();
      mocker.clear(IndexPresenter.getInstance());
    })

    it('IndexPresenterTest_onBackPressIsContactSearch', 0, () => {
      AppStorage.setOrCreate<boolean>('isVerde', true);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByResource);
      mocker.mockFunc(SearchUtil.getInstance(), SearchUtil.getInstance().disconnectSearchSession);
      mocker.mockFunc(ContactListPresenter.getInstance(), ContactListPresenter.getInstance().sendEmitter);
      mocker.mockFunc(ContactListPresenter.getInstance(), ContactListPresenter.getInstance().getSearchContactResult);
      IndexPresenter.getInstance().onBackPressIsContactSearch();
      expect(AppStorage.get('isContactSearch')).assertFalse();
      mocker.verify('sendEmitter', [false]).once();
      mocker.clear(SearchUtil.getInstance());
      mocker.clear(ContactListPresenter.getInstance());
      mocker.clear(ResourceUtil);
    })

    it('IndexPresenterTest_getProperEnhance', 0, () => {
      expect(IndexPresenter.getInstance().getProperEnhance()).assertTrue();
    })
  })
}