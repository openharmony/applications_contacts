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
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility'
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession'
import { HiLog, StringUtil } from '../../../../../feature/call/oh_modules/common'
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import WorkerWrapper from '../workers/base/WorkerWrapper'
import WorkFactory, { WorkerType } from '../workers/WorkFactory'
import LooseObject from '../model/type/LooseObject'
import Want from '@ohos.app.ability.Want'
import { FontScaleState } from '../util/fontScaleState'
import { Configuration } from '@ohos.app.ability.Configuration'
import { SearchUtil } from '../util/SearchUtil'
import { display, uiExtensionHost, window } from '@kit.ArkUI'
import ScreenFormUtil from '../util/ScreenFormUtil'
import { HiAppEvent } from '../util/DotUtil'
import { contact } from '@kit.ContactsKit'
import AccessibilityUtil from '../util/AccessibilityUtil'
import DeviceTypeEnum from '../../../../../feature/call/oh_modules/common/src/main/ets/util/DeviceTypeEnum'
import ContactListPresenter from '../presenter/contact/ContactListPresenter'
import CallServiceManager from '../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager'
import { ListenerManager } from '../listeners/ListenerManager'
import EnvironmentProp from '../feature/EnvironmentProp'
import { BreakpointUtil } from '../util/BreakpointUtil'
import { DisplaySplitUtil } from '../util/DisplaySplitUtil'
// import { AppLockManager } from '@hw-hmos/pickersheet'
import { osAccount } from '@kit.BasicServicesKit'
import ContactsPickerPresenter from '../presenter/contact/batchselectcontacts/ContactsPickerPresenter'

const TAG = 'ContactUiExtentionAbility'


// 联系人批量选择
export const URL_TYPE_BATCH_SELECT_CONTACT = 'BatchSelectContactsPage'
// 跳转到联系人列表
export const URL_TYPE_CONTACT_LIST = 'ContactList'

// 跳转到联系人详情
export const URL_TYPE_CONTACT_DETAIL = 'ContactDetail'
export const DEFAULT_MAX_SELECT_CONTACTS: number = 10000;

export class UiExtentionParam {
  public urlType: string = '';
  public phoneNumber: string = '';
  public contactId: number = 0;
  public callerBundleName: string = '';
  public callerToken: number = -1;
  public isContactsPicker: boolean = false;
  public isContactMultiSelect: boolean = true;
  public selectLimit: number = DEFAULT_MAX_SELECT_CONTACTS;
  public isDisplayByName: boolean = false;
  public filter?: contact.ContactSelectionFilter;
  public isSaveExistContact: boolean = false;
  public isSaveContact: boolean = false;
  public contact?: contact.Contact;
  public userId: number = -1;
  public from?: string = '';
  public meetimeDeviceType?: DeviceTypeEnum = 0;
  public source?: string = '';
  public intelliGroupName?: string = '';

  constructor() {
  }
}


export default class ContactUiExtentionAbility extends UIExtensionAbility {
  public mDataWorker: WorkerWrapper = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
  public mContactListPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  public listenerManager: ListenerManager | null = null;
  private processorId: number = 0;
  private runTime: number[] = [];
  private sumTime: number = 0;
  private succCount: number = 0;
  private errCodes: Record<string, number> = {};
  private startTime: number = 0;
  private endTime: number = 0
  private localId: number = 100;
  private userId: number = 100;
  private startAbilityCallerBundleName: string = '';

  constructor() {
    super();
    osAccount.getAccountManager().getOsAccountLocalId().then((localId) => {
      this.localId = localId;
    })
  }

  parseContactParam(want: Want) {
    let uiExtentionParam: UiExtentionParam = new UiExtentionParam();
    this.startTime = new Date().getTime()
    HiLog.i(TAG, 'Receive parameters');
    uiExtentionParam.urlType = want.parameters?.targetUrl as string
    uiExtentionParam.phoneNumber = want.parameters?.phoneNumber as string
    uiExtentionParam.contactId = want.parameters?.contactId as number
    uiExtentionParam.callerBundleName = want.parameters!['ohos.aafwk.param.callerBundleName'] as string
    uiExtentionParam.callerToken = want.parameters!['ohos.aafwk.param.callerToken'] as number
    uiExtentionParam.from = want.parameters?.from as string;
    uiExtentionParam.meetimeDeviceType = want.parameters?.meetimeDeviceType as DeviceTypeEnum;
    // 数据库调 picker 标志位
    uiExtentionParam.isContactsPicker = (want.parameters?.isContactsPicker as boolean) ?? false
    uiExtentionParam.isContactMultiSelect = (want.parameters?.isContactMultiSelect as boolean) ?? true;
    uiExtentionParam.selectLimit = (want.parameters?.selectLimit as number) ?? DEFAULT_MAX_SELECT_CONTACTS;
    uiExtentionParam.isDisplayByName = (want.parameters?.isDisplayByName as boolean) ?? false;
    uiExtentionParam.filter = want.parameters?.filter as contact.ContactSelectionFilter;
    uiExtentionParam.isSaveExistContact = (want.parameters?.isSaveExistContact as boolean) ?? false;
    uiExtentionParam.isSaveContact = (want.parameters?.isSaveContact as boolean) ?? false;
    uiExtentionParam.contact = want.parameters?.contact as contact.Contact;
    uiExtentionParam.userId = want.parameters?.userId as number;
    this.userId = want.parameters?.userId as number;
    uiExtentionParam.source = want.parameters?.source as string;
    uiExtentionParam.intelliGroupName = want.parameters?.intelliGroupName as string;

    HiLog.w(TAG, `isContactsPicker: ${want?.parameters?.isContactsPicker},
     isContactMultiSelect: ${want?.parameters?.isContactMultiSelect},
     selectLimit: ${want?.parameters?.selectLimit}, isDisplayByName: ${want?.parameters?.isDisplayByName},
      isSaveExistContact: ${want?.parameters?.isSaveExistContact}, isSaveContact: ${want?.parameters?.isSaveContact},
       source: ${want?.parameters?.source}`);

    this.endTime = new Date().getTime()
    // 统计运行时间和成功次数
    this.runTime.push(this.endTime - this.startTime);
    this.sumTime += this.endTime - this.startTime;
    this.succCount++;
    if (!this.startTime) {
      this.startTime = this.startTime;
    }
    setInterval(() => {
      HiLog.w(TAG, `use DotUtil selectContact`)
      HiAppEvent.getInstance().SchedulerUpload(this.processorId, uiExtentionParam.callerBundleName, this.startTime,
        this.runTime, this.succCount, this.sumTime, -1)
    }, 1000)

    HiLog.i(TAG, 'uiExtentionParam parse finish ')
    return uiExtentionParam
  }

  onCreate() {
    HiLog.i(TAG, `ContactUiExtentionAbility onCreate`)
  }

  onForeground() {
    HiLog.i(TAG, `ContactUiExtentionAbility onForeground`)
    try {
      // AppLockManager.Helper.setPickerProtectedState([{ bundleName: this.startAbilityCallerBundleName, appIndex: 0 }],
      //   4, false, this.localId)
    } catch (err) {
      HiLog.e(TAG, `ContactUiExtentionAbility onForeground err: ${err.message}`)
    }
  }

  onBackground() {
    HiLog.i(TAG, `ContactUiExtentionAbility onBackground`);
    try {
      // AppLockManager.Helper.setPickerProtectedState([{ bundleName: this.startAbilityCallerBundleName, appIndex: 0 }],
      //   4, true, this.localId)
      SearchUtil.getInstance().disconnectSearchSession();
    } catch (err) {
      HiLog.e(TAG, `ContactUiExtentionAbility onBackground err: ${err.message}`)
    }
  }

  onDestroy() {
    HiLog.i(TAG, `ContactUiExtentionAbility onDestroy`)
    try {
      // AppLockManager.Helper.setPickerProtectedState([{ bundleName: this.startAbilityCallerBundleName, appIndex: 0 }],
      //   4, false, this.localId)
    } catch (err) {
      HiLog.e(TAG, `ContactUiExtentionAbility onDestroy err: ${err.message}`)
    }
  }

  updateExtentionLanguage(languageConfig: string | undefined) {
    if (languageConfig && !StringUtil.isEmpty(languageConfig)) {
      let languageConfigs = languageConfig.split('-');
      languageConfig = languageConfigs[0] + '-' + languageConfigs[2];
      AppStorage.setOrCreate('languageConfig', languageConfig);
    }
  }

  initSplitInfo(deviceType: DeviceTypeEnum = DeviceTypeEnum.HANDSET) {
    let isNeedSplit: boolean = false;
    if (deviceType === DeviceTypeEnum.PAD || deviceType === DeviceTypeEnum.PC || deviceType === DeviceTypeEnum.TV) {
      isNeedSplit = true;
    } else if (deviceType === DeviceTypeEnum.HANDSET && !ScreenFormUtil.isNewFormSmallFoldScreen()) {
      HiLog.i(TAG, `isFoldable: ${display.isFoldable()} curFoldStatus: ${display.getFoldStatus()}`);
      if (display.isFoldable()) {
        let curFoldStatus = display.getFoldStatus();
        if (curFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED ||
          curFoldStatus === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
          isNeedSplit = true;
        }
      }
    }
    AppStorage.SetOrCreate('isMeetimeNeedSplit', isNeedSplit);
    this.handleJumpToCspButtonVisibility(isNeedSplit);
  }

  handleJumpToCspButtonVisibility(isNeedSplit: boolean) {
    let isShowJumpButton: boolean = true;
    if (!isNeedSplit) {
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (ScreenFormUtil.isNewFormSmallFoldScreen() || foldStatus === display.FoldStatus.FOLD_STATUS_UNKNOWN ||
        foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        isShowJumpButton = false;
      }
    }
    AppStorage.setOrCreate('isShowJumpButton', isShowJumpButton);
  }

  onConfigurationUpdate(newConfig: Configuration) {
    FontScaleState.updateAppFontGearSize(newConfig.fontSizeScale)
    let languageConfig = newConfig.language;
    this.updateExtentionLanguage(languageConfig);
  }

  async onSessionCreate(want: Want, session: UIExtensionContentSession) {
    try {
      HiLog.i(TAG, `ContactUiExtentionAbility onSessionCreate`)
      // 安全截屏设置
      let extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy | undefined =
        session.getUIExtensionHostWindowProxy();
      extensionWindow.hidePrivacyContentForHost(true)

      // 系统颜色、字体大小、语言
      this.isSysColor();
      let fontSizeScale = this.context.config.fontSizeScale;
      FontScaleState.updateAppFontGearSize(fontSizeScale)
      let languageConfig = this.context.config.language;
      this.updateExtentionLanguage(languageConfig);
      //获取应用是否开启无障碍的状态,默认不开启，为false
      AccessibilityUtil.getInstance().getAccessibilitySwitchState();

      // 参数解析
      let uiExtentionParam: UiExtentionParam = this.parseContactParam(want)

      // 设置全局参数
      ContactsGlobalThisHelper.GetGlobalThis()
        .set(ContactsGlobalThisHelper.UIContextName, this.context)
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, this.mDataWorker)
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<UIExtensionContentSession>(ContactsGlobalThisHelper.UiExtentionAbilityUIExtensionContentSession, session)

      this.mDataWorker.sendRequest('init', {
        context: this.context
      });

      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UiExtentionAbilityParams, uiExtentionParam)
      if (uiExtentionParam.callerBundleName !== 'com.ohos.contacts') {
        // 用于判断是否显示横幅 和 picker打点
        AppStorage.setOrCreate('startAbilityCallerBundleName', uiExtentionParam.callerBundleName);
      }
      this.startAbilityCallerBundleName = uiExtentionParam.callerBundleName;

      AppStorage.setOrCreate('isFromSaveContactPicker', uiExtentionParam.isSaveContact);
      AppStorage.setOrCreate('contactFromPicker', uiExtentionParam.contact);
      AppStorage.setOrCreate('isSaveExistContact', uiExtentionParam.isSaveExistContact);
      AppStorage.setOrCreate('currentColorMode', this.context?.config?.colorMode);

      // 设置全局 storage
      let storageParamObj: LooseObject = {
        'uiExtentionSession': session,
        'parameters': uiExtentionParam,
      };
      let storage: LocalStorage = new LocalStorage(storageParamObj);

      // 判断设备形态
      ScreenFormUtil.addFoldStatusRegister();

      // 判断是否显示子窗
      let subWindow: window.Window | undefined = undefined;
      if(this.localId === 100 && this.userId !== undefined && this.userId !== 100) {
        HiLog.i(TAG,'ContactUiExtentionAbility onSessionCreate terminateSelf')
        this.context.terminateSelf()
      }

      // 加载窗口页面
      if (uiExtentionParam.isContactsPicker &&
        (!(uiExtentionParam.isSaveContact || uiExtentionParam.isSaveExistContact))) {
        AppStorage.setOrCreate('callerPid', String(want?.parameters?.['ohos.aafwk.param.callerPid']));
        HiLog.w(TAG, `subWindow`);
        const subWindowName = 'subWindowPicker'
        //创建子窗
        subWindow = await extensionWindow.createSubWindowWithOptions(subWindowName, {
          title: subWindowName,
          decorEnabled: false,
          isModal: false,
        });

        display.on('change', async (data) => {
          HiLog.w(TAG, `Succeeded in enabling the listener for display changes.`);
          let newDisplay: display.Display = display.getDefaultDisplaySync();
          HiLog.w(TAG, `newDisplay.orientation: ${newDisplay.orientation}, newDisplay.width: ${newDisplay.width},
           newDisplay.height: ${newDisplay.height}`);
          await subWindow?.resize(newDisplay.width, newDisplay.height)
        })

        let newDisplay: display.Display = display.getDefaultDisplaySync();
        await subWindow?.resize(newDisplay.width, newDisplay.height)
        await subWindow.setWindowTouchable(true);
        // 在SubWindowPage中拉起PIcker
        await subWindow?.loadContent('pages/ContactUiExtentionIndex', storage);
        subWindow?.setWindowBackgroundColor('#00000000'); //设置窗口透明
        subWindow?.setShadow(0.0); // 禁止子窗阴影边框
        await subWindow?.showWindow();
        await subWindow.setFollowParentWindowLayoutEnabled(true);
      } else if (URL_TYPE_CONTACT_LIST == uiExtentionParam?.urlType ||
        URL_TYPE_CONTACT_DETAIL === uiExtentionParam?.urlType) {
        this.initSplitInfo(uiExtentionParam?.meetimeDeviceType);
        AppStorage.setOrCreate('isFromMeetime', uiExtentionParam?.from === 'meetime');
        AppStorage.setOrCreate('isMeetimePC', uiExtentionParam?.meetimeDeviceType === DeviceTypeEnum.PC);
        AppStorage.setOrCreate('isMeetimePhone', uiExtentionParam?.meetimeDeviceType === DeviceTypeEnum.HANDSET);
        session?.setReceiveDataCallback((data) => {
          const action = data?.action as string;
          const extraInfo = data?.extraInfo as string;
          HiLog.i(TAG, 'receivedata: ' + extraInfo);
          if (action === 'SPLIT_INFO') {
            let isNeedSplit: boolean = JSON.parse(extraInfo).splitInfo as boolean;
            AppStorage.setOrCreate('isMeetimeNeedSplit', isNeedSplit);
            this.handleJumpToCspButtonVisibility(isNeedSplit);
          }
        })
        this.listenerManager = new ListenerManager();
        this.listenerManager.registerListeners();
        CallServiceManager.getInstance().updateMeetimeLoginFlag();
        if (URL_TYPE_CONTACT_DETAIL === uiExtentionParam?.urlType) {
          AppStorage.setOrCreate('isFromMeeTimeDetail', uiExtentionParam?.from === 'meetime');
        }
        // 获取联系人列表第一页的数据后再加载页面，避免闪烁
        this.mContactListPresenter.startPreInit(() => {
          session.loadContent('pages/ContactUiExtentionIndex', storage);
          session.setWindowBackgroundColor('#00000000');
        });
      } else {
        HiLog.w(TAG, `hostWindow`);
        session.loadContent('pages/ContactUiExtentionIndex', storage);
        session.setWindowBackgroundColor('#00000000');
      }

      // 设置窗口监听
      try {
        if (subWindow) {
          // 窗口大小
          AppStorage.setOrCreate('breakpoint', BreakpointUtil.getWidthBreakpoint(
            subWindow.getWindowProperties().windowRect, subWindow.getWindowProperties().displayId));
          BreakpointUtil.judgingVerdeBreakpoint(
            subWindow.getWindowProperties().windowRect, subWindow.getWindowProperties().displayId);
          subWindow.on('windowSizeChange', (data) => {
            AppStorage.setOrCreate('breakpoint',
              BreakpointUtil.getWidthBreakpoint(data, subWindow?.getWindowProperties().displayId));
            BreakpointUtil.judgingVerdeBreakpoint(data, subWindow?.getWindowProperties().displayId);
          });

          // 窗口内容规避区域
          let avoidArea = subWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          let navigationArea = subWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          this.updateWindowFullScreenPadding(avoidArea.topRect.height, navigationArea.bottomRect.height)
          subWindow.on('avoidAreaChange', (data) => {
            if (window.AvoidAreaType.TYPE_SYSTEM === data.type) {
              this.updateWindowFullScreenPadding(data.area.topRect.height, -1);
            }
            if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) {
              this.updateWindowFullScreenPadding(-1, data.area.bottomRect.height)
            }
          });
        } else {
          let windowProxy = session.getUIExtensionHostWindowProxy();

          // 窗口大小
          AppStorage.setOrCreate('breakpoint',
            BreakpointUtil.getWidthBreakpoint(windowProxy.properties.uiExtensionHostWindowProxyRect));
          AppStorage.setOrCreate('meetimeCurBp',
            BreakpointUtil.getWidthBreakpoint(windowProxy.properties.uiExtensionHostWindowProxyRect));
          BreakpointUtil.judgingVerdeBreakpoint(windowProxy.properties.uiExtensionHostWindowProxyRect);
          windowProxy.on('windowSizeChange', (data) => {
            AppStorage.setOrCreate('breakpoint', BreakpointUtil.getWidthBreakpoint(data));
            AppStorage.setOrCreate('meetimeCurBp', BreakpointUtil.getWidthBreakpoint(data));
            BreakpointUtil.judgingVerdeBreakpoint(data);
            DisplaySplitUtil.updateSplitStatus(data.width, data.height);
          });

          // 窗口内容规避区域
          let avoidArea = windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          let navigationArea = windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          this.updateWindowFullScreenPadding(avoidArea.topRect.height, navigationArea.bottomRect.height)
          windowProxy.on('avoidAreaChange', (data) => {
            if (window.AvoidAreaType.TYPE_SYSTEM === data.type) {
              this.updateWindowFullScreenPadding(data.area.topRect.height, -1);
            }
            if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) {
              this.updateWindowFullScreenPadding(-1, data.area.bottomRect.height)
            }
          });
        }
      } catch (err) {
        HiLog.e(TAG, `Failed to obtain the area. err: ${err?.message}`);
      }
    } catch (err) {
      HiLog.e(TAG, `onSessionCreate err: ${err.message} ,err code: ${err.code}`)
    }
  }


  updateWindowFullScreenPadding(top: number, bottom: number): void {
    HiLog.w(TAG, `updateWindowFullScreenPadding top: ${top}, bottom: ${bottom}`);
    let prePadding = AppStorage.get<Padding>('fullScreenPadding');
    let padding: Padding = {
      top: top < 0 ? prePadding?.top ?? 0 : top,
      bottom: bottom < 0 ? prePadding?.bottom ?? 0 : bottom,
      left: 0,
      right: 0
    }
    AppStorage.setOrCreate('fullScreenPadding', padding);
    if (top < 0) {
      AppStorage.setOrCreate('fullScreenPaddingTop', top);
    }
    HiLog.w(TAG, `updateWindowFullScreenPadding padding: {top: ${padding?.top}, bottom: ${padding?.bottom},
     left: ${padding?.left}, right: ${padding?.right}`);
  }

  isSysColor() {
    try {
      // 判断是否是系统色
      let appThemeColor: string = this.context
        .resourceManager
        .getColorSync($r('app.color.skin_contacts_app_theme_color'))
        .toString();
      let isSysColor: boolean = appThemeColor === Number.parseInt('FFFFFFFF', 16).toString();
      let isThemeActiveTemp: boolean = !isSysColor
      AppStorage.setOrCreate('isThemeActive', isThemeActiveTemp)
    } catch (err) {
      HiLog.e(TAG, 'getSysColorError:' + err?.message + ', stack: ' + err?.stack);
    }
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `ContactUiExtentionAbility onSessionDestroy`)
  }
}

