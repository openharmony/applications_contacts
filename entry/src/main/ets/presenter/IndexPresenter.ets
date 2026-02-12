/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import pasteboard from '@ohos.pasteboard';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoader } from '../../../../../common/src/main/ets/util/DynamicLoader';
import StringFormatUtil from '../util/StringFormatUtil';
import CallRecordPresenter from './dialer/callRecord/CallRecordPresenter';
import { call } from '@kit.TelephonyKit';
import { curves, display } from '@kit.ArkUI';
import ContactListPresenter from './contact/ContactListPresenter';
import { SearchUtil } from '../util/SearchUtil';
import { DisplaySplitUtil } from '../util/DisplaySplitUtil';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { addSettingModeListener, queryInitSettingMode } from '../model/CallSharingModel';
import { CallSharingClass } from '../card/data/commonData';
import SystemParameterEnhance from '@ohos.systemParameterEnhance';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import EnvironmentProp from '../feature/EnvironmentProp';
import { addAirPlaneModeListener } from '../model/AirplaneModel';
import SimCardState from '../feature/sim/SimCardState';
import { isNotePadAppEnabled } from '../util/NotePadUtil';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';

const TAG = 'IndexPresenter  ';
const CHECK_PATH_FOR_DEFAULT_SELECT_CONTACT =
  ['ContactDetail', 'GroupList', 'Settings', 'BatchSelectContactsPage', 'SingleSelectContactPage'];
// 此常量为sm以及尺寸小于sm设备类型的判断边界，和项目中其他地方判断sm的边界数据一致
const SM_DEVICE_TYPE_WIDTH = 520;
const DEFAULT_COLOR = 'FFFFFFFF';
const AIRPLANE_MODE = 1;

export default class IndexPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static instance: IndexPresenter | null;
  public callIndex: number = call.hasVoiceCapability() ? 0 : -1;
  public contactIndex: number = call.hasVoiceCapability() ? 1 : 0;
  public favoriteIndex: number = call.hasVoiceCapability() ? 2 : 1;
  public curIndex: number = this.callIndex;
  public isFirstUpdateIndex: boolean = true;
  public static isThemeActiveCard: boolean = false;
  public targetPageChange: () => void = () => {
  }

  public static getInstance(): IndexPresenter {
    if (!IndexPresenter.instance) {
      IndexPresenter.instance = new IndexPresenter();
    }
    return IndexPresenter.instance;
  }

  isDefaultColor() {
    try {
      let appThemeColor: string = getContext(this)
        .resourceManager
        .getColorSync($r('app.color.index_text_background'))
        .toString();
      let isDefaultColor: boolean = appThemeColor === Number.parseInt(DEFAULT_COLOR, 16).toString();
      IndexPresenter.isThemeActiveCard = !isDefaultColor
      AppStorage.setOrCreate('isThemeActive', !isDefaultColor)
    } catch (err) {
      HiLog.e(TAG, 'getSysColorError:' + err.message)
    }
  }

  onPageShow() {
    let is24HourClockPre = AppStorage.get<boolean>('is24HourClock');
    let is24HourClockNow = i18n.System.is24HourClock();
    HiLog.w(TAG, `onPageShow, is24HourClockPre: ${is24HourClockPre}, is24HourClockNow: ${is24HourClockNow}`);
    if (is24HourClockPre !== is24HourClockNow) {
      AppStorage.setOrCreate<boolean>('is24HourClock', is24HourClockNow);
      if (is24HourClockPre !== undefined) {
        HiLog.w(TAG, 'DO requestItem cause systemTime changed');
        CallRecordPresenter.getInstance().requestItem();
      }
    }
    isNotePadAppEnabled().then((value) => {
      AppStorage.setOrCreate<boolean>('NotePadAppEnabled', value);
    })
  }

  getCurrentUrl() {
    let pathName = router.getState().path + router.getState().name;
    HiLog.i(TAG, `getCurrentUrl:${StringUtil.maskSensitiveInfo(pathName)}`);
    return pathName;
  }

  goToPage(pathName: string, pageIndex?: number, params?: Record<string, string>) {
    HiLog.w(TAG, `goToPage: ${StringUtil.maskSensitiveInfo(pathName)},
     pathInfos infos: ${StringUtil.maskSensitiveInfo(this.pathInfos.getAllPathName().toString())}`);
    // 跳转至根页面
    if (pathName == 'pages/index') {
      return;
    }
    if (this.pathInfos.size() > 0 && this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === pathName) {
      this.pathInfos.replacePathByName(pathName, params, false);
    } else {
      this.pathInfos.popToName(pathName);
      if (pathName === DynamicLoader.ACCOUNTANTS || pathName === DynamicLoader.CONTACT_DETAIL_PAGE ||
        pathName === DynamicLoader.IMPORT_AND_EXPORT_PAGE ||
        pathName === DynamicLoader.BATCH_SELECT_CONTACTS_PAGE ||
        pathName === DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE ||
        pathName === DynamicLoader.ADD_FAVORITE_LIST_PAGE ||
        pathName === 'Settings') {
        DynamicLoader.getInstance().fire(pathName).then(() => {
          this.pathInfos.pushPathByName(pathName, params, false);
        });
      } else {
        this.pathInfos.pushPathByName(pathName, params, false);
      }
    }
    if (pathName === 'ContactDetail' && pageIndex == 2 && AppStorage.get('breakpoint') !== 'sm' &&
      !AppStorage.get('isShowSmartWindow')) {
      setTimeout(() => {
        AppStorage.setOrCreate<number>('newContactId',
          Number(params!.contactId));
        ContactListPresenter.getInstance().refreshContactListDataSourceAndPhotoByIds(
          [params!.contactId]);
      }, 10)
    }
    if ((pathName === 'ContactDetail') && (params !== undefined) && params.isFormCard) {
      setTimeout(() => {
        AppStorage.setOrCreate('isShowDial', true);
      }, 50)
    }
  }

  isSysColor() {
    try {
      // 判断是否是系统色
      let appThemeColor: string = getContext(this)
        .resourceManager
        .getColorSync($r('app.color.skin_contacts_app_theme_color'))
        .toString();
      let isSysColor: boolean = appThemeColor === Number.parseInt('FFFFFFFF', 16).toString();
      let isThemeActiveTemp: boolean = !isSysColor
      AppStorage.setOrCreate('isThemeActive', isThemeActiveTemp)
    } catch (err) {
      HiLog.e(TAG, 'getSysColorError:' + err?.message)
    }
  }

  // 手动更新：主题包启动模式下，切换深浅色模式无法实时更新的颜色
  setDarkThemeColor() {
    try {
      // 获取通话页-全部通话列表滚动条的色值
      let scrollColorStr = '#' + getContext(this)
        .resourceManager
        .getColorSync($r('app.color.skin_list_scroll_color').id)
        .toString(16);
      AppStorage.setOrCreate('scrollColorStr', scrollColorStr)
    } catch (err) {
      HiLog.e(TAG, 'setDarkThemeColorError:' + err?.message)
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear !!!');
    AppStorage.SetOrCreate('sysTime', Number(StringFormatUtil.judgeSysTime()));
  }

  getCopy(phoneNumber: string) {
    let pasteData = pasteboard.createPlainTextData(phoneNumber);
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setPasteData(pasteData, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'Failed to set PasteData. Cause: ' + err?.message);
        return;
      }
      HiLog.i(TAG, 'Succeeded in setting PasteData.');
    });
  }

  isExistTargetPath(allPaths: string[]): boolean {
    if (CHECK_PATH_FOR_DEFAULT_SELECT_CONTACT.some(item => allPaths.includes(item))) {
      return true;
    }
    return false;
  }

  getDeviceDisplayInfo(): display.Display {
    return display.getDefaultDisplaySync();
  }

  isNeedDefaultSelectedDevice() {
    //如果左右分屏且单栏，则默认不跳转联系人详情页
    if (DisplaySplitUtil.isVerticalSplit() && !AppStorage.get('isNavigationModeSplit')) {
      return false;
    }
    // 如果是平板则需要默认选中第一个联系人
    if (AppStorage.get('breakpoint') === 'lg') {
      return true;
    }
    // 如果不是折叠屏或者折叠屏不是展开状态时不需要默认选中第一个联系人
    if ((!display.isFoldable() || AppStorage.get('FoldStatus') !== display.FoldStatus.FOLD_STATUS_EXPANDED) &&
      (AppStorage.get('breakpoint') === 'sm')) {
      return false;
    }
    // 是折叠屏并且当前折叠屏是展开状态
    const deviceDisplayInfo = IndexPresenter.getInstance().getDeviceDisplayInfo();
    // 如果是小折叠屏则不需要默认选中第一个联系人
    if ((deviceDisplayInfo.width / deviceDisplayInfo.densityPixels) < SM_DEVICE_TYPE_WIDTH) {
      return false;
    }
    // 悬浮窗不需要默认选中第一个联系人
    if (AppStorage.get('isShowSmartWindow') && !AppStorage.get('isNavigationModeSplit')) {
      return false;
    }
    return true;
  }

  /**
   *
   * 1 从其他Tab切换到联系人会执行该方法
   * 2 折叠屏从合并态切换到展开态会执行该方法
   */
  emitDefaultSelectedContact() {
    if (AppStorage.get('maintenanceMode')) {
      return;
    }
    try {
      if (!this.isNeedDefaultSelectedDevice()) {
        return;
      }
      const allPaths = this.pathInfos.getAllPathName();
      if (allPaths.length > 1) {
        return;
      }
      if (this.isExistTargetPath(allPaths)) {
        return;
      }
      ContactListPresenter.getInstance().openDefaultContactsDetail();
    } catch (err) {
      HiLog.e(TAG, `emit default selected contact err: ${err?.message}, stack: ${err?.stack}`);
    }
  }

  onBackPressIsContactSearch() {
    HiLog.w(TAG, 'Search onBackPress');
    SearchUtil.getInstance().disconnectSearchSession();
    if (AppStorage.get<boolean>('isVerde')) {
      HiLog.w(TAG, 'v isContactSearch value change: index/onBackPress');
      AppStorage.setOrCreate('isContactSearch', false);
      AppStorage.setOrCreate('contactsList_y', 0);
    } else {
      AppStorage.setOrCreate('isContactSearch', false);
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        HiLog.w(TAG, 'isContactSearch value change: index/onBackPress');
        AppStorage.setOrCreate('contactsList_y', 0);
      });
    }
    ContactListPresenter.getInstance().sendEmitter(false);
    ContactListPresenter.getInstance().inputKeyword = '';
    // ContactListPresenter.getInstance().getSearchContactResult(ContactListPresenter.getInstance().inputKeyword);
    ContactListPresenter.getInstance().getSearchContactResultFromDb(ContactListPresenter.getInstance().inputKeyword);
  }

  public static unInstance(): void {
    HiLog.i(TAG, 'unInstance...');
    IndexPresenter.instance = null;

  }

  public hasVoiceCapability(): boolean {
    return call.hasVoiceCapability();
  }

  updateMainTabIndex() {
    HiLog.i(TAG, 'updateMainTabIndex, updateMainTabIndex success');
    let isCallIndexChange = false;
    if (this.hasVoiceCapability() ||
      (AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState') &&
      AppStorage.get('isDistributedCallSourcePhone'))) {
      if (this.callIndex != 0) {
        isCallIndexChange = true;
      }
      this.callIndex = 0;
      this.contactIndex = 1;
      this.favoriteIndex = 2;
    } else {
      if (this.callIndex != -1) {
        isCallIndexChange = true;
      }
      this.callIndex = -1;
      this.contactIndex = 0;
      this.favoriteIndex = 1;
    }

    if (isCallIndexChange) {
      if (this.callIndex === 0) {
        AppStorage.setOrCreate('mainTabsIndex', AppStorage.get('mainTabsIndex') as number + 1);
      } else if (this.callIndex === -1) {
        if (AppStorage.get('mainTabsIndex') as number === 0) {
          AppStorage.setOrCreate('mainTabsIndex', 0);
          this.pathInfos.clear();
          this.emitDefaultSelectedContact();
        } else if (AppStorage.get('mainTabsIndex') as number > 0) {
          AppStorage.setOrCreate('mainTabsIndex', AppStorage.get('mainTabsIndex') as number - 1);
        }
      }
    }
    HiLog.i(TAG, 'updateMainTabIndex, updateMainTabIndex success' + AppStorage.get('mainTabsIndex') as string);
  }

  updateCurIndex(bottomIndex: number) {
    HiLog.i(TAG, 'updateCurIndex, updateCurIndex success' + bottomIndex);
    this.curIndex = bottomIndex;
  }

  updateMainTabIndexId() {
    if (AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState') &&
    AppStorage.get('isDistributedCallSourcePhone')) {
      AppStorage.setOrCreate('tabContactCall', 'tab_item_1');
      AppStorage.setOrCreate('tabContactList', 'tab_item_2');
      AppStorage.setOrCreate('tabContactFavorite', 'tab_item_3');
    } else {
      AppStorage.setOrCreate('tabContactCall', 'tab_item_0');
      AppStorage.setOrCreate('tabContactList', 'tab_item_1');
      AppStorage.setOrCreate('tabContactFavorite', 'tab_item_2');
    }
  }

  initCallPhoneSharingMode() {
    HiLog.i(TAG, 'initCallPhoneSharingMode');
    try {
      addSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_PHONE_SHARING);
    } catch (err) {
      HiLog.e(TAG, `initCallPhoneSharing err = ${err?.message}, stack: ${err?.stack}`);
    }
  }

  initDistributedModemState() {
    HiLog.i(TAG, 'initDistributedModemState');
    try {
      addSettingModeListener(CallSharingClass.DISTRIBUTED_MODEM_STATE);
    } catch (err) {
      HiLog.e(TAG, `initDistributedModemState err = ${err?.message}, stack: ${err?.stack}`);
    }
  }

  initAirPlaneMode() {
    HiLog.i(TAG, 'initAirPlaneMode');
    try {
      addAirPlaneModeListener((res: Record<string, number | boolean>) => {
        HiLog.i(TAG, 'initAirPlaneMode callback');
        const isAirplane = res?.data == AIRPLANE_MODE;
        AppStorage.setOrCreate('isAirplaneMode', isAirplane);
        // 飞行模式打开 双卡和无卡时需要单独判断下获取蜂窝数据卡 其他不变
        SimCardState.setDefaultSlot();

      });
    } catch (err) {
      HiLog.e(TAG, `initAirPlaneMode err = ${err?.message}, stack: ${err?.stack}`);
    }
  }

  initCallSMSSharingMode() {
    HiLog.i(TAG, 'initCallSMSSharingMode');
    try {
      addSettingModeListener(CallSharingClass.DISTRIBUTED_CALL_SMS_SHARING);
    } catch (err) {
      HiLog.e(TAG, `initCallSMSSharing err = ${err?.message}, stack: ${err?.stack}`);
    }
  }

  getProperEnhance(): boolean {
    HiLog.i(TAG, 'SystemParameterEnhance virtualModemSwitch: ' +
    SystemParameterEnhance.getSync('const.booster.virtual_modem_switch', `${false}`))
    return SystemParameterEnhance.getSync('const.booster.virtual_modem_switch', `${false}`) === 'true';
  }

  isOnCallSharing() {
    let isOnCallSharingValue: boolean = false;
    if (EnvironmentProp.isDeviceTypeTablet() && call.hasVoiceCapability()) {
      if (AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState')) {
        isOnCallSharingValue = true;
      } else {
        isOnCallSharingValue = false;
      }
    } else {
      isOnCallSharingValue = false;
    }

    HiLog.i(TAG, 'isOnCallSharingValue: ' + isOnCallSharingValue);
    AppStorage.setOrCreate('isOnCallSharingValue', !isOnCallSharingValue);
  }

  initMainTabIndex() {
    HiLog.i(TAG, 'update mainTabsIndex');
    if (this.callIndex === -1) {
      AppStorage.setOrCreate('isNoMissFormCard', false);
      AppStorage.setOrCreate('mainTabsIndex', this.contactIndex);
    }
  }
}