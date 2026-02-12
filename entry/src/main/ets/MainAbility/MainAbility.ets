/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import dataShare from '@ohos.data.dataShare';
import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'
import WorkFactory, { WorkerType } from '../workers/WorkFactory';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import SimManager from '../feature/sim/SimManager';
import PageManager from './PageManager';
import window from '@ohos.window';
import { ContactWindowsManager, sharedPreferencesUtils } from '../../../../../common';
import display from '@ohos.display';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { ListenerManager } from '../listeners/ListenerManager';
import CallServiceManager from '../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager';
import emitter from '@ohos.events.emitter';
import { Configuration } from '@ohos.app.ability.Configuration'
import { StringUtil } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
// import { PafUiWidget } from '@hms-paf/ui-widget-base';
import commonEventManager from '@ohos.commonEventManager';
import { CommonEventConstants } from '../../../../../feature/call/oh_modules/common/src/main/ets/CommonEventConstants';
import audio from '@ohos.multimedia.audio';
import { CallLogRepository } from '../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { PixelMapManager } from '../util/UserPhoto';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { FontScaleState } from '../util/fontScaleState';
import DialerPresenter from '../presenter/dialer/DialerPresenter';
import { HiCarConstants } from '../data/HiCarConstants';
import { SmartMobilityInfo } from '../model/bean/DeviceInfoBean';
import { Constants, TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND } from '../data/Constants';
import EmitterConstant from '../data/EmitterConstant';
import { DynamicLoadSoUtil } from '../../../../../common/src/main/ets/util/DynamicLoadSoUtil';
import VoicemailManager from '../feature/sim/VoicemailManager';
import { SearchUtil } from '../util/SearchUtil';
import AccessibilityUtil from '../util/AccessibilityUtil'
import { ContactWorkSchedulerUtil } from '../util/ContactWorkSchedulerUtil';
import CallRecordPresenter from '../presenter/dialer/callRecord/CallRecordPresenter';
import ContactListPresenter from '../presenter/contact/ContactListPresenter';
import AlphabetIndexerPresenter from '../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import IndexPresenter from '../presenter/IndexPresenter';
import { pasteboard, systemParameterEnhance, systemParameter, usbManager } from '@kit.BasicServicesKit';
import { DisplaySplitUtil } from '../util/DisplaySplitUtil';
import ScreenFormUtil from '../util/ScreenFormUtil';
import { preferences } from '@kit.ArkData';
import { CountryIdUtil } from '../../../../../common/src/main/ets/util/CountryIdUtil';
import EnvironmentProp from '../feature/EnvironmentProp';
import { VisionGlassConstants } from '../data/VisionGlassConstants';
import account_osAccount from '@ohos.account.osAccount';
import { BreakpointUtil } from '../util/BreakpointUtil';
import settings from '@ohos.settings';
import { ModeType, SystemModeController, terminateUIAbilitySelf } from '../util/SystemModeController';
import { SplitScreenManager } from './SplitScreenManager';
import { i18n } from '@kit.LocalizationKit';
export const intelligentAbstractSwitch = 'const.call.intelligent_callui_enable'

const TAG = 'MainAbility ';
const MAINABILITY = 'com.ohos.contacts.MainAbility';
const ENTRYABILITY = 'com.ohos.contacts.EntryAbility';
const PC_SIDEBAR_WIDTH = 840;
const SMALLPADSIZE = 'MLR';
/**
 * 蓬莱模式下系统联系人应用的MainAbility在后台停留的最长时间
 * 目前是20s
 */
const MAX_TIME_OF_STAY_IN_PENGLAI_BACKGROUND = 20000;

export default class MainAbility extends Ability {
  public static UPDATE_CONTENT: number = 999;
  public static DELAY_TIME_ZERO: number = 0;
  public storage: LocalStorage | null = null;
  public simManager: SimManager | null = null;
  public pageManager: PageManager | null = null;
  public listenerManager: ListenerManager | null = null;
  private windowStage: Window.WindowStage | null = null;
  public audioVolumeGroupManager: audio.AudioVolumeGroupManager | null = null;
  public callLogDataAbilityHelper?: Promise<dataShare.DataShareHelper>;
  private windowObj?: window.Window;
  private systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  // lastColorMode
  private lastColorMode: ConfigurationConstant.ColorMode | undefined = undefined;
  private isPC: boolean = false;
  /**
   * 蓬莱模式系统后台管控定时器id
   * 蓬莱模式系统中的联系人应用的MainAbility在后台超过一定时间后会自销毁
   */
  private timeOutIdOfBackgroundInPengLai: number | null = null;
  /** UIAbility是否在前台 */
  private isAbilityOnForeground: boolean = false;

  constructor() {
    super();
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.w(TAG, 'Application onCreate want abilityName:' + want?.abilityName);
    // 应用启动时判断另一个ability（MainAbility、EntryAbility）是否存在，是否需要终止上一次启动的Ability
    this.terminateAbility(want, MAINABILITY, 'MainAbility', 'EntryAbility');
    this.terminateAbility(want, ENTRYABILITY, 'EntryAbility', 'MainAbility');
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName, this.context)
    this.setSupportProcessCache(this.context);
    let mDataWorker: WorkerWrapper = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, mDataWorker);
    this.storage = new LocalStorage();
    this.simManager = new SimManager();
    this.pageManager = new PageManager(this.context);
    // 提前初始化dataAbilityHelper，dataAbilityHelper创建耗时很长，提前初始化
    CallLogRepository.getInstance().init(this.context);
    ContactRepository.getInstance().init(this.context);
    CallLogRepository.getInstance().getDataAbilityHelperProxy();
    this.callLogDataAbilityHelper = CallLogRepository.getInstance().getDataAbilityHelper();
    this.publishPageStateChangeEvent(true);
    let parameters = want.parameters as Record<string, Object>;
    // 根据打开图标进入页面进行预查寻
    // 联系人图标打开
    if (parameters?.pageFlag &&
      parameters.pageFlag.toString() == 'page_flag_contacts_list') {
      HiLog.i(TAG, 'onCreate from contactIcon');
      ContactListPresenter.getInstance().intoFromContactIconFlag = true;
      ContactListPresenter.getInstance().startPreInit();
      setTimeout(() => {
        CallLogRepository.getInstance().settingCallback();
        CallLogRepository.getInstance().queryCallSharingInitMode(this.context);
      }, 500)
    } else { // 通话图标打开
      HiLog.i(TAG, 'onCreate from callIcon');
      ContactListPresenter.getInstance().intoFromContactIconFlag = false;
      CallRecordPresenter.getInstance().preRequestCallLog();
      setTimeout(() => {
        CallLogRepository.getInstance().settingCallback();
        CallLogRepository.getInstance().queryCallSharingInitMode(this.context);
      }, 0)
    }
    this.listenerManager = new ListenerManager();
    this.listenerManager.registerListeners();
    this.simManager?.init();
    CallServiceManager.getInstance().updateMeetimeLoginFlag();
    CallServiceManager.getInstance().updateStelliteModeSwitch();
    CallServiceManager.getInstance().updateHyacinthModeSwitch();
    this.pageManager.onCreate(want);
    this.getAndListenAudioRingModeInfo();
    emitter.on({
      eventId: MainAbility.UPDATE_CONTENT,
      priority: emitter.EventPriority.HIGH
    }, (data) => {
      this.updateWindowStageContent()
    })
    VoicemailManager.getInstance().updateVoicemailNumber();
    //初次打开联系人，判断是在手机上打开还是在车机打开
    this.processHiCarStartUp(want);
    //初次打开联系人，判断是在手机上打开还是在VisionGlass打开
    this.processVisionGlassStartUp(want);
    //获取应用是否开启无障碍的状态,默认不开启，为false
    AccessibilityUtil.getInstance().getAccessibilitySwitchState();
    // 联系人状态点的延时方法
    ContactWorkSchedulerUtil.getInstance().tryStartStatusReportWorker();
    ContactWorkSchedulerUtil.getInstance().tryBackupLogWorker(this.context);
    this.onFoldDisplayMode();
    AppStorage.setOrCreate('currentColorMode', this.context?.config?.colorMode);
    AppStorage.setOrCreate('isDarkMode', this.context?.config?.colorMode ===
    ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    let isIntelligentContact = (systemParameterEnhance.getSync(intelligentAbstractSwitch, 'false') === 'true')
    AppStorage.setOrCreate(intelligentAbstractSwitch, isIntelligentContact);
    this.getMaintenanceMode();
    this.initOsAccountType();
    //适配GRL三折态自由多窗模式
    if (EnvironmentProp.isPhone()) {
      this.getWindowSwitchStatus();
    } else if (EnvironmentProp.isDeviceTypeTablet()) {
      this.getWindowSwitchStatus();
      this.isSmallPad();
      this.getFontScale();
    }
    SystemModeController.getInstance()
    this.context?.getApplicationContext()?.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }

  initOsAccountType() {
    account_osAccount.getAccountManager().getOsAccountType().then((type: account_osAccount.OsAccountType) => {
      if (type === account_osAccount.OsAccountType.PRIVATE) {
        HiLog.w(TAG, 'is PRIVATE type');
        AppStorage.setOrCreate('isPrivateAccount', true);
      } else {
        HiLog.w(TAG, 'is not PRIVATE type');
        AppStorage.setOrCreate('isPrivateAccount', false);
      }
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `getOsAccountType err: ${err.message}`);
    });
  }

  /*
   * 获取当前维修模式状态
   */
  private getMaintenanceMode() {
    systemParameter.get('persist.hiviewcare.maintenancemode').then(value => {
      if (value === 'true') {
        AppStorage.setOrCreate('maintenanceMode', true);
      } else {
        AppStorage.setOrCreate('maintenanceMode', false);
      }
      HiLog.i(TAG, `persist.hiviewcare.maintenancemode, value is ${value}`);
    }, (error: BusinessError) => {
      HiLog.e(TAG, `Failed to obtain the maintenance mode, code is ${error.code}, message is ${error.message}`);
    })
  }

  private onFoldDisplayMode(): void {
    try {
      AppStorage.setOrCreate<number>('foldDisplayMode', display.getFoldDisplayMode());
      display.on('foldDisplayModeChange', this.foldDisplayModeChangeCallback);
    } catch (e) {
      const err = e as BusinessError;
      HiLog.e(TAG, `onFoldDisplayMode failed: ${err?.code}, ${err?.message}`);
    }
  }

  private offFoldDisplayMode(): void {
    try {
      display.off('foldDisplayModeChange', this.foldDisplayModeChangeCallback);
      AppStorage.delete('foldDisplayMode');
    } catch (e) {
      const err = e as BusinessError;
      HiLog.e(TAG, `offFoldDisplayMode failed: ${err?.code}, ${err?.message}`);
    }
  }

  private foldDisplayModeChangeCallback = (foldDisplayMode: display.FoldDisplayMode) => {
    HiLog.i(TAG, `foldDisplayModeChange FoldDisplayMode: ${foldDisplayMode}`);
    AppStorage.setOrCreate<number>('foldDisplayMode', foldDisplayMode);
  }

  /**
   * 双ability启动判断，如果之前已经启动过另一个Ability，则终止上一次启动的Ability，保证多任务窗口只存在一个联系人应用窗口
   *
   * @param want
   * @param abilityName MainAbility or EntryAbility
   * @param contextName MainAbility or EntryAbility
   * @param preAbilityName previous created ability
   */
  terminateAbility(want: Want, abilityName: string, contextName: string, preAbilityName: string) {
    if (!want || StringUtil.isEmpty(abilityName) || StringUtil.isEmpty(contextName) ||
    StringUtil.isEmpty(preAbilityName)) {
      HiLog.e(TAG, 'Invalid parameters');
      return;
    }
    if (want?.abilityName == abilityName) {
      // 设置 abilityName 的 UIAbilityContext
      AppStorage.setOrCreate(contextName, this.context);
      let abilityContext: common.UIAbilityContext | undefined =
        AppStorage.get(preAbilityName);
      try {
        if (abilityContext) {
          HiLog.i(TAG, `${preAbilityName} already exists `);
          AppStorage.setOrCreate('TerminateSelfFlag', true);
        }
        abilityContext?.terminateSelf((err: BusinessError) => {
          if (err?.code) {
            HiLog.e(TAG, `${preAbilityName} terminateSelf failed, code is ${err?.code}, message is ${err?.message}`);
          }
        });
      } catch (err) {
        HiLog.e(TAG, `${preAbilityName} terminateSelf failed, code: ${err?.code}, message: ${err?.message}`);
      }
    }
  }

  /**
   * 处理在车机上启动联系人的场景
   * @param want
   */
  public processHiCarStartUp(want: Want): void {
    if (want.parameters) {
      const hiCarDeviceType: string = want.parameters[HiCarConstants.HICAR_DEVICE_TYPE] as string;
      AppStorage.setOrCreate(HiCarConstants.KEY_IS_IN_HICAR, hiCarDeviceType === HiCarConstants.HICAR_DEVICE_TYPE_CAR);
    }
  }

  /**
   * 处理在VisionGlass上启动联系人的场景
   * @param want
   */
  public processVisionGlassStartUp(want: Want): void {
    if (want.parameters) {
      const callerBundleName: string = want.parameters[VisionGlassConstants.XR_CALLER_BUNDLENAME] as string;
      AppStorage.setOrCreate(VisionGlassConstants.KEY_IS_IN_VISION_GLASS,
        callerBundleName === VisionGlassConstants.VISION_GLASS);
    }
  }

  /**
   * 获取声音模式，对于振动模式和静音模式，需要控制拨号时，不发送语音
   */
  getAndListenAudioRingModeInfo() {
    // 获取 VolumeGroupManager 回调
    let callBack = (error: BusinessError, audioVolumeGroupManager: audio.AudioVolumeGroupManager) => {
      if (error) {
        HiLog.e(TAG, `Failed to getVolumeGroupManager. err: ${error?.code}-${error?.message}`);
        return;
      }
      if (audioVolumeGroupManager) {
        // 设置获取的值
        this.audioVolumeGroupManager = audioVolumeGroupManager
        // 第一次直接获取，之后通过监听获取变更
        this.audioVolumeGroupManager.getRingerMode((err: BusinessError, value: audio.AudioRingMode) => {
          try {
            if (err) {
              HiLog.e(TAG, `Failed to obtain the ringer mode. err: ${err?.code}-${err?.message}`);
              return;
            }
            HiLog.i(TAG, 'init get ringerMode: ' + value);
            ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.AudioRingMode, value);
          } catch (e) {
            HiLog.e(TAG, `get ringer mode err: ` + (e as BusinessError).message);
          }
        });

        try {
          // 监听
          this.audioVolumeGroupManager.on('ringerModeChange', (value: audio.AudioRingMode) => {
            HiLog.i(TAG, 'state change get ringerMode: ' + value);
            ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.AudioRingMode, value);
          });
        } catch (e) {
          HiLog.e(TAG, `audioVolumeGroupManager register err: ` + (e as BusinessError).message);
        }
      }
    };
    try {
      audio.getAudioManager().getVolumeManager().getVolumeGroupManager(audio.DEFAULT_VOLUME_GROUP_ID, callBack);
    } catch (err) {
      HiLog.e(TAG, `getVolumeGroupManager failed, err: ${err?.code}-${err?.message}`);
    }
  }

  /**
   * 发布事件
   * 目前单框架上拨打电话性能相比双框架还差这个方案没有落，在启动联系人的时候提前通知call_manager绑服务拉起callui，这个方案预估可以优化120ms左右
   * 应用到前台，发布事件isShouldConnect参数为true；应用到后台，发布事件isShouldConnect参数为false
   * @param isShouldConnect
   */
  publishPageStateChangeEvent(isShouldConnect: boolean) {
    try {
      let data: commonEventManager.CommonEventPublishData = {
        subscriberPermissions: [CommonEventConstants.CUSTOM_EVENT_PAGE_STATE_CHANGE_PERMISSION],
        parameters: {
          isShouldConnect: isShouldConnect
        }
      }
      commonEventManager.publish(CommonEventConstants.CUSTOM_EVENT_PAGE_STATE_CHANGE, data, (err) => {
        if (err) {
          HiLog.i(TAG,
            `${CommonEventConstants.CUSTOM_EVENT_PAGE_STATE_CHANGE} publish err: ${err?.code}-${err?.message}, isShouldConnect: ${isShouldConnect}`);
        } else {
          HiLog.i(TAG, CommonEventConstants.CUSTOM_EVENT_PAGE_STATE_CHANGE +
            ' publish success, isShouldConnect=' + isShouldConnect)
        }
      });
    } catch (err) {
      HiLog.e(TAG, `publishPageStateChangeEvent, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
  }

  /**
   * 热启动触发
   * @param want
   * @param launchParam
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    HiLog.w(TAG, 'Application onNewWant want abilityName: ' + want?.abilityName);
    HiLog.w(TAG, `callLogDataChange is ${AppStorage.get('callLogDataChange')}`);
    if (this.pageManager == null) {
      this.pageManager = new PageManager(this.context);
      HiLog.w(TAG, 'Application onNewWant want pageManager is null need init ');
    }
    this.pageManager.onNewWant(want);
  }

  onDestroy() {
    HiLog.w(TAG, 'Ability onDestroy: ' + AppStorage.get('TerminateSelfFlag'));
    this.isAbilityOnForeground = false;
    if (!AppStorage.get('TerminateSelfFlag')) {
      HiLog.w(TAG, 'Ability onDestroy');
      if (this.listenerManager !== null) {
        this.listenerManager.unRegisterListeners();
      }
      this.pageManager?.onDestroy();
      this.audioVolumeGroupManager = null;
      this.callLogDataAbilityHelper = undefined;
      this.windowObj = undefined;
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)?.close();
      CallLogRepository.getInstance().unInit();
      ContactRepository.getInstance().unInit();
      PixelMapManager.getInstance().releaseContactListAllPixelMap(true, true);
      PixelMapManager.getInstance().releaseAllPixelMap();
      AccessibilityUtil.getInstance().releaseAccessibility();
      emitter.off(MainAbility.UPDATE_CONTENT);
      this.offFoldDisplayMode();
      this.cleanStorage();
      this.cleanPresenter();
      this.simManager?.unInit();
      this.storage = null;
      this.simManager = null;
      this.pageManager = null;
    } else {
      AppStorage.setOrCreate('TerminateSelfFlag', false);
    }
    this.clearTimeOutIdOfBackgroundInPengLai();
  }

  cleanPresenter() {
    CallRecordPresenter.unInstance();
    DialerPresenter.unInstance();
    ContactListPresenter.unInstance();
    AlphabetIndexerPresenter.unInstance();
    IndexPresenter.unInstance();
  }

  cleanStorage() {
    this.storage?.clear();
    let keys: IterableIterator<string> = AppStorage.keys();
    for (let key of keys) {
      let res: boolean = AppStorage.delete(key);
      if (!res) {
        // deletion failed
        HiLog.w(TAG, `appStorage delete fail [${key} : ${AppStorage.get(key)}]`);
      }
    }
  }

  /**
   * 打开页面
   * @param windowStage
   */
  onWindowStageCreate(windowStage: Window.WindowStage) {
    // Main window is created, set main page for this ability
    HiLog.w(TAG, 'Ability onWindowStageCreate');
    try {
      // Paf UiWidget 初始化
      // PafUiWidget.init(windowStage, this.context);
      this.fetchSystemFontSizeScale()
      this.isPC = EnvironmentProp.isPC();
      ScreenFormUtil.addFoldStatusRegister();

      windowStage.getMainWindow((err, windowObj) => {
        AppStorage.setOrCreate('windowObj', windowObj)
        if (err.code) {
          HiLog.e(TAG, `Window.getLastWindow errCode: ${err?.code}, errMsg: ${err?.message}`);
          return;
        }
        this.windowObj = windowObj;
        // SplitScreenManager.getInstance().updateWindowStatusType(this.context, this.windowObj?.getWindowStatus() ?? 0);
        const properties = windowObj.getWindowProperties();

        DisplaySplitUtil.updateSplitStatus(properties.windowRect.width, properties.windowRect.height);
        this.updateWindowSize(properties.windowRect.width, properties.windowRect.height);
        AppStorage.setOrCreate('breakpoint',
          BreakpointUtil.getWidthBreakpoint(properties.windowRect, properties.displayId));
        BreakpointUtil.judgingVerdeBreakpoint(properties.windowRect, properties.displayId);
        windowObj.on('windowSizeChange', (data) => {
          DisplaySplitUtil.updateSplitStatus(data.width, data.height);
          this.updateWindowSize(data.width, data.height);
          AppStorage.setOrCreate('breakpoint',
            BreakpointUtil.getWidthBreakpoint(data, windowObj.getWindowProperties().displayId));
          BreakpointUtil.judgingVerdeBreakpoint(data, windowObj.getWindowProperties().displayId);
        });

        // 键盘高度
        windowObj.on('keyboardHeightChange', (data) => {
          HiLog.d(TAG, `keyboardHeightChange data:` + JSON.stringify(data))
          this.storage?.setOrCreate('keyBoardHeightPx', data);
        });

        // AppStorage.setOrCreate<number>('windowStatus', windowObj.getWindowStatus());
        //绑定窗口模式变化监听
        // windowObj.on('windowStatusChange', (windowStatusType) => {
        //   AppStorage.setOrCreate<number>('windowStatus', windowStatusType);
        //   this.isSmartWindow(windowStatusType);
        //   SplitScreenManager.getInstance().updateWindowStatusType(this.context, windowStatusType);
        // });

        // 绑定窗口横竖屏变化监听
        // windowObj.on('windowRectChange', (data) => {
        //   AppStorage.setOrCreate('windowRect', data);
        //   if (this.isPC) {
        //     ContextMenu.close(); // PC设备横竖屏变化时，关闭所有Menu弹窗
        //   }
        // });

        try {
          // 窗口内容规避区域
          let avoidArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          let navigationArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          HiLog.i(TAG, `getWindowAvoidArea systemAoid:` + JSON.stringify(avoidArea))
          HiLog.i(TAG, `getWindowAvoidArea navigationAoid:` + JSON.stringify(navigationArea))

          this.updateWindowAvoidAreaHeight(avoidArea.topRect.height + avoidArea.bottomRect.height);
          this.updateWindowAvoidAreaWidth(avoidArea.leftRect.width + avoidArea.rightRect.width);
          this.updateWindowFullScreenPadding(avoidArea.topRect.height, avoidArea.bottomRect.height)
        } catch (exception) {
          HiLog.e(TAG, `Failed to obtain the area, code: ${exception?.code}, msg: ${exception?.message}`);
        }
        try {
          windowObj.on('avoidAreaChange', (data) => {
            HiLog.i(TAG, `avoidAreaChange change type:` + JSON.stringify(data.type))
            if (window.AvoidAreaType.TYPE_SYSTEM === data.type) {
              this.updateWindowAvoidAreaHeight(data.area.topRect.height + data.area.bottomRect.height);
              this.updateWindowAvoidAreaWidth(data.area.leftRect.width + data.area.rightRect.width);
              this.updateWindowFullScreenPadding(data.area.topRect.height, -1);
            }
            if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) {
              this.updateWindowFullScreenPadding(-1, data.area.bottomRect.height)
            }
          });
        } catch (exception) {
          HiLog.e(TAG, 'Failed to register avoidAreaChange. Cause:' + exception?.message + ', stack: ' + exception?.stack);
        }
        ContactWindowsManager.getInstance().initForPhone(windowObj, this.context);
        this.addWaterMark()
      })
    } catch (exception) {
      HiLog.e(TAG, 'Window.getLastWindow exception: ' + exception?.message + ', stack: ' + exception?.stack);
    }

    this.windowStage = windowStage;
    AppStorage.setOrCreate('windowStage', windowStage);
    this.updateWindowStageContent()
  }

  addWaterMark() {
    if(AppStorage.get(intelligentAbstractSwitch)) {
      let windowObj1: window.Window | undefined = AppStorage.get('windowObj');
      if(windowObj1 !==undefined){
        try{
          windowObj1.setWaterMarkFlag(true, (err: BusinessError) => {
            if(err){
              const errCode: number = err.code;
              if (errCode) {
                HiLog.e(TAG,`Failed to set water mark flag of window. Cause: err:${err?.code})`);
                return;
              }
            } else {
              HiLog.i(TAG,'Succeeded in setting water mark flag of window.');
            }
          });
        } catch (exception) {
          HiLog.e(TAG,`Failed to set water mark flag of window. Cause: exception:${exception?.code}`);
        }
      }
    }
  }

  // 平板、三折叠手机自由多窗状态获取
  getWindowSwitchStatus() {
    try {
      let windowPcModeSwitchStatus = settings.getValueSync(this.context as Context, 'window_pcmode_switch_status', '0',
        settings.domainName.USER_PROPERTY);
      AppStorage.setOrCreate('isWindowPcMode', windowPcModeSwitchStatus === 'true');
      HiLog.w(TAG, 'windowPcModeSwitchStatus value is ' + windowPcModeSwitchStatus);

      settings.registerKeyObserver(this.context as Context, 'window_pcmode_switch_status',
        settings.domainName.USER_PROPERTY, () => {
          settings.getValue(this.context as Context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY)
            .then((value) => {
              AppStorage.setOrCreate('isWindowPcMode', value === 'true');
              HiLog.w(TAG, 'windowPcModeSwitchStatus change value is ' + value);
            })
        });
    } catch (err) {
      HiLog.w(TAG, `set windowPcModeSwitchStatus failed.`);
    }
  }

  /**
   * 初始化版本，当前是不是小平板
   */
  isSmallPad() {
    let isSmallPad = systemParameterEnhance.getSync('const.build.product', '') === SMALLPADSIZE;
    AppStorage.setOrCreate('isSmallPad', isSmallPad);
  }

  // 设置字体大小获取
  getFontScale() {
    let windowPcModeSwitchStatus = settings.getValueSync(this.context as Context, 'font_scale', '0',
      settings.domainName.USER_PROPERTY);
    AppStorage.setOrCreate('settingFontScale', windowPcModeSwitchStatus);
    HiLog.w(TAG, 'settingFontScale value is ' + windowPcModeSwitchStatus);

    settings.registerKeyObserver(this.context as Context, 'font_scale',
      settings.domainName.USER_PROPERTY, () => {
        settings.getValue(this.context as Context, 'font_scale', settings.domainName.USER_PROPERTY)
          .then((value) => {
            AppStorage.setOrCreate('settingFontScale', value);
            HiLog.w(TAG, 'settingFontScale change value is ' + value);
          })
      });
  }

  fetchSystemFontSizeScale() {
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let fontSizeScale = context.config?.fontSizeScale;
    FontScaleState.updateAppFontGearSize(fontSizeScale)
    HiLog.i(TAG, 'FontScaleTrace----')
  }

  // 加载页面，首先看是否有startAbility设置的页面（this.pageManager.mainUrl）
  // 有的话，就是联系人未启动，其他应用通过startAbility方式打开联系人指定页面
  updateWindowStageContent() {
    this.windowStage?.loadContent(this.pageManager ? this.pageManager.mainUrl : 'pages/index', this.storage,
      (err, data) => {
        if (err.code) {
          HiLog.e(TAG, `Failed to load the content. code: ${err.code}, msg: ${err.message}`);
          return;
        }
        try {
          this.context.reportDrawnCompleted((err: BusinessError) => {
            if (err.code) {
              HiLog.e(TAG, `reportDrawnCompleted failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            HiLog.i(TAG, 'reportDrawnCompleted succeed');
          });
          if (this.isPC) {
            try {
              // 设置隐藏窗口的装饰器，只显示右上角三键
              if (this.windowStage) {
                this.windowStage.getMainWindowSync().setWindowDecorVisible(false);
                this.windowStage.getMainWindowSync().setWindowDecorHeight(56);
              }
            } catch (exception) {
              HiLog.e(TAG,
                `Failed to set the visibility of window, code: ${exception?.code}, msg: ${exception?.message}}`);
            }
          }
        } catch (err) {
          // 捕获同步的参数错误
          let code: number = err?.code;
          let message: string = err?.message;
          HiLog.e(TAG, `reportDrawnCompleted failed, code is ${code}, message is ${message}`);
        }
        HiLog.i(TAG, 'Succeeded in loading the content.');
      });
  }

  updateWindowSize(width: number, height: number): void {
    AppStorage.setOrCreate('windowWidthPX', width);
    this.storage?.setOrCreate('windowHeightPx', height);
    AppStorage.setOrCreate('windowHeightPx', height);
    if (px2vp(width) > 0 && px2vp(width) < PC_SIDEBAR_WIDTH) {
      AppStorage.setOrCreate('showSideBar', false);
      AppStorage.setOrCreate('isPcMinWindowWidth', true);
      AppStorage.setOrCreate('isNeedExpandSideBar', true);
      AppStorage.setOrCreate('isNeedOpenBar', true); // 用来标记是否需要在从窗口最小拖动到大时自动打开A栏
    } else {
      AppStorage.setOrCreate('isPcMinWindowWidth', false);
      AppStorage.setOrCreate('isNeedExpandSideBar', false);
      AppStorage.setOrCreate('isNeedMask', false);
      let isNeedOpenBar = AppStorage.get('isNeedOpenBar') || false;
      if (isNeedOpenBar) {
        AppStorage.setOrCreate('showSideBar', true);
        AppStorage.setOrCreate('isNeedOpenBar', false);
      }
    }
  }

  /**
   * 判断当前是否是浮窗状态
   * FLOATING 值为4 表示APP自由悬浮形式窗口模式。
   * @returns true 为悬浮窗状态，否则为false
   * SPLIT_SCREEN  值为5 表示APP分屏模式。
   */
  isSmartWindow(windowStatusType: Window.WindowStatusType): void {
    HiLog.w(TAG, 'Succeeded listener for window status changes. Data: ' + windowStatusType);
    if (windowStatusType === 4) {
      AppStorage.setOrCreate('isShowSmartWindow', !this.isPC); // PC不走悬浮窗口逻辑就
    } else if (windowStatusType === 1) {
      AppStorage.setOrCreate('isShowSmartWindow', false);
    }
  }

  updateWindowAvoidAreaHeight(height: number): void {
    this.storage?.setOrCreate('windowAvoidAreaHeightPx', height);
  }

  updateWindowAvoidAreaWidth(width: number): void {
    this.storage?.setOrCreate(Constants.KEY_WINDOW_AVOID_AREA_WIDTH_PX, width);
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
    HiLog.w(TAG, `windowFullScreenPadding updated, top: ${padding.top}, bottom: ${padding.bottom}`);
  }

  isHaveClipData() {
    // get it first
    this.systemPasteboard.hasData((err: BusinessError, data: boolean) => {
      if (err) {
        AppStorage.setOrCreate('isHasDate', false);
        AppStorage.setOrCreate('pasteData', '');
        AppStorage.setOrCreate('pasteStatus', false);
        HiLog.e(TAG, `failed to get pasteData. Cause: ${err.message}`);
        return;
      }
      HiLog.w(TAG, `succeeded get pasteData. Data: ${data}`);
      if (data) {
        HiLog.w(TAG, 'get data filter...')
        DialerPresenter.getInstance().getDataFromClipBoard();
      } else {
        HiLog.w(TAG, 'the clipboard has no data. ');
        AppStorage.setOrCreate('isHasDate', false);
        AppStorage.setOrCreate('pasteData', '');
        AppStorage.setOrCreate('pasteStatus', false);
      }
    });
  }

  public listener = () => {
    HiLog.w(TAG, 'the system pasteboard has changed');
    this.isHaveClipData()
  };

  isHasPateDate() {
    this.isHaveClipData()
    HiLog.w(TAG, 'hasData on')
    this.systemPasteboard.on('update', this.listener);
  }

  isHasPateDateOff() {
    HiLog.w(TAG, 'hasData off');
    this.systemPasteboard.off('update', this.listener);
    HiLog.w(TAG, `onbackground pasteStatus disappear`);
    AppStorage.setOrCreate('pasteStatus', false);
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    this.windowStage = null;
    HiLog.w(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    this.isAbilityOnForeground = true;
    this.clearTimeOutIdOfBackgroundInPengLai();
    HiLog.w(TAG, 'Ability onForeground');
    AppStorage.setOrCreate('isMainAbilityForeground', true);
    DialerPresenter.getInstance().foregroundOperation();
    // onForeground 执行时间长，导致后续加载通话记录列表丢帧，将此处在异步操作
    this.setSystemBarProps();
    this.publishPageStateChangeEvent(true);
    setTimeout(() => {
      this.callLogDataAbilityHelper?.then(() => {
      });
      this.simManager?.init(false);
    }, MainAbility.DELAY_TIME_ZERO);
    setTimeout(() => {
      this.isHasPateDate();
    }, 100)
    // 如果之前存在查询未完成，重新刷新数据
    let reloadFlag: boolean | undefined = CallLogRepository.getInstance().isQueryTaskFinished;
    HiLog.w(TAG, `isQueryTaskFinished ${ reloadFlag }`);
    if (reloadFlag !== undefined && !reloadFlag) {
      CallRecordPresenter.getInstance().aboutToAppear();
      CallLogRepository.getInstance().isQueryTaskFinished = undefined;
    }
    
    // 如果之前联系人查询存在查询未完成，重新刷新数据
    let createDataHelperFailed = ContactRepository.getInstance().createDataHelperFailed;
    HiLog.w(TAG, `createDataHelperFailed,${createDataHelperFailed}`);
    if (createDataHelperFailed) {
      ContactRepository.getInstance().createDataHelperFailed = false;
      ContactListPresenter.getInstance().initContactListWhenCreateDataHelperFailed();
    }
  }

  /**
   * 清除蓬莱模式系统后台管控定时器
   */
  private clearTimeOutIdOfBackgroundInPengLai() {
    try {
      if (this.timeOutIdOfBackgroundInPengLai !== null) {
        clearTimeout(this.timeOutIdOfBackgroundInPengLai);
        this.timeOutIdOfBackgroundInPengLai = null;
        HiLog.i(TAG, 'clearTimeOutIdOfBackgroundInPengLai: clearTimeout');
      } else {
        HiLog.i(TAG, 'clearTimeOutIdOfBackgroundInPengLai: timeOutIdOfBackgroundInPengLai is empty');
      }
    } catch (e) {
      HiLog.e(TAG, `clearTimeOutIdOfBackgroundInPengLai error: ${e?.code} ${e?.message}`);
    }

    try { // 蓬莱模式下主页的后台管控定时器逻辑处理，当应用侧滑退出应用，又拉起应用时，若此时该定时器尚未执行，则取消该定时器
      let timerId = AppStorage.get<number>(TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND);
      if (timerId != null) {
        clearTimeout(timerId);
        AppStorage.setOrCreate(TIMER_ID_OF_PENG_LAI_PROCESS_BACKGROUND, null);
        HiLog.i(TAG, 'clearTimeOutIdOfBackgroundInPengLai: clearTimeoutInIndex');
      } else {
        HiLog.i(TAG, 'clearTimeOutIdOfBackgroundInPengLai: timerIdOfIndex is empty');
      }
    } catch (e) {
      HiLog.e(TAG, `clearTimeOutIdOfBackgroundInPengLai clearTimeoutInIndex error: ${e?.code} ${e?.message}`);
    }
  }

  onBackground() {
    // Ability has back to background
    this.isAbilityOnForeground = false;
    HiLog.w(TAG, 'Ability onBackground');
    AppStorage.setOrCreate('isMainAbilityForeground', false);
    AppStorage.setOrCreate('isFromExternalApp', false);
    SearchUtil.getInstance().disconnectSearchSession();
    // 30ms延迟可避免控制通话记录显隐的变量清空过快用户在点击拨号过程中看见通话记录
    setTimeout(() => {
      HiLog.i(TAG, `onBackground foregroundOperation...`);
      DialerPresenter.getInstance().foregroundOperation();
    }, 30)
    // 联系人杀进程，settimeout延时任务执行不到；接收方，自己实现延迟1s处理
    this.publishPageStateChangeEvent(false);
    this.isHasPateDateOff();
    PixelMapManager.getInstance().releaseContactListAllPixelMap(true, false);

    this.setTimeOuOfBackgroundInPengLai();
  }

  /**
   * 蓬莱模式系统中设置蓬莱模式系统后台管控定时器
   * 当窗口处于后台超过一定时间时销毁当前的UIAbility
   */
  private setTimeOuOfBackgroundInPengLai() {
    try {
      if (SystemModeController.getInstance().getCurrentMode() !== ModeType.PENG_LAI_MODE) {
        return;
      }
      HiLog.i(TAG, 'setTimeOuOfBackgroundInPengLai: set timeOuOfBackgroundInPengLai');
      this.timeOutIdOfBackgroundInPengLai = setTimeout(() => {
        this.timeOutIdOfBackgroundInPengLai = null;
        this.delayedTerminateUIAbilitySelf();
      }, MAX_TIME_OF_STAY_IN_PENGLAI_BACKGROUND);
    } catch (e) {
      HiLog.e(TAG, `setTimeOuOfBackgroundInPengLai error: ${e?.code} ${e?.message}`);
    }
  }

  private delayedTerminateUIAbilitySelf() {
    setTimeout(() => { //通过setTimeout将执行顺序后置100ms，此时若拉起应用会先执行onForeground
      HiLog.i(TAG, `delayedTerminateUIAbilitySelf: isAbilityOnForeground ${this.isAbilityOnForeground}`);
      if (!this.isAbilityOnForeground) {
        terminateUIAbilitySelf(this.context);
      }
    }, 100);
  }

  setSystemBarProps(config?: Configuration) {
    HiLog.i(TAG, `setSystemBarProps dark mode is: ${config?.colorMode} - ${AppStorage.get('currentColorMode')}`);
    let currentColorMode: ConfigurationConstant.ColorMode | undefined =
      config?.colorMode !== undefined ? config?.colorMode : AppStorage.get('currentColorMode');
    if (this.lastColorMode === currentColorMode) {
      HiLog.w(TAG, 'ColorMode has not changed.')
      return;
    }
    let systemBarProperties: window.SystemBarProperties = {
      statusBarContentColor: currentColorMode ? '#ff000000' : '#ffffffff',
    }
    this.windowObj?.setWindowSystemBarProperties(systemBarProperties);
    this.lastColorMode = currentColorMode;
  }

  /**
   * 处理应用在手机与车机上迁移的场景
   */
  private appMigration(): void {
    const currentDisplayId = this.windowObj?.getWindowProperties().displayId;
    HiLog.i(TAG, `currentDisplayId: ${currentDisplayId}`);
    if (currentDisplayId === undefined) {
      HiLog.w(TAG, 'Failed to obtain currentDisplayId.');
      return;
    }
    const event: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_NOTICE_WHERE_APP_EVENT_ID
    }
    const eventData: emitter.EventData = {
      data: {
        'isPhone': true
      }
    }
    // DynamicLoadSoUtil.getInstance().loadSmartMobility().then((ns: ESObject) => {
    //   const devInfo: SmartMobilityInfo = ns.default.getSmartMobilityAwareness()
    //     .getSmartMobilityStatus(ns.default.SmartMobilityType.HICAR);
    //   if (devInfo === undefined) {
    //     HiLog.w(TAG, 'Error in obtaining devInfo.');
    //     return;
    //   }
    //   if (devInfo.status === ns.default.SmartMobilityStatus.IDLE) {
    //     HiLog.i(TAG, 'Hicar not connected.');
    //     return;
    //   }
    //   const displayId: string = devInfo.data?.['DISPLAY_ID'].toString();
    //   AppStorage.setOrCreate(HiCarConstants.KEY_IS_IN_HICAR, String(currentDisplayId) === displayId);
    //   if (String(currentDisplayId) === displayId) {
    //     HiLog.i(TAG, 'Application migration from mobile phones to hicar.');
    //   } else {
    //     HiLog.i(TAG, 'Application migration from hicar to mobile phones, release HiCarUtil.');
    //     emitter.emit(event, eventData);
    //   }
    // }).catch((error: BusinessError) => {
    //   HiLog.e(TAG, `DynamicImport Fail.ERROR: ${error.message}`);
    // });
  }

  /**
   * 处理应用在手机与VisionGlass上迁移的场景
   */
  private visionGlassAppMigration(newConfig: Configuration): void {
    const currentDisplayId = newConfig.displayId?.toString();
    if (currentDisplayId === undefined) {
      HiLog.w(TAG, 'VisionGlassAppMigration: failed to obtain currentDisplayId.');
      return;
    }
    try {
      let usbDevices: usbManager.USBDevice[] = usbManager.getDevices();
      if (!usbDevices?.length) {
        HiLog.w(TAG, 'VisionGlass not connect.');
        return;
      }
      const usbDevice: usbManager.USBDevice | undefined =
        usbDevices?.find(device => device.vendorId.toString() === VisionGlassConstants.VISION_GLASS_VENDOR_ID &&
          device.productId.toString() === VisionGlassConstants.VISION_GLASS_PRODUCT_ID)
      if (usbDevice === undefined) {
        HiLog.w(TAG, 'VisionGlass not connect.');
        return;
      }
    } catch (err) {
      const businessErr: BusinessError = err as BusinessError;
      HiLog.e(TAG, `usb wrong, errCode: ${businessErr?.code}, errMsg: ${businessErr?.message}`);
      return;
    }
    HiLog.i(TAG, 'VisionGlass is connected.');
    display.getAllDisplays((err: BusinessError, data: Array<display.Display>) => {
      if (err.code) {
        HiLog.e(TAG, 'getAllDisplays wrong');
        return;
      }
      const glassDisplay = data?.find((item) => item.id === 1);
      if (glassDisplay === undefined) {
        HiLog.w(TAG, 'Can not find  glassDisplay.');
        return;
      }
      AppStorage.setOrCreate(VisionGlassConstants.KEY_IS_IN_VISION_GLASS,
        currentDisplayId === glassDisplay?.id?.toString());
    });
  }

  onConfigurationUpdate(newConfig: Configuration) {
    HiLog.w(TAG, 'language change, update to new configuration.');
    FontScaleState.updateAppFontGearSize(newConfig.fontSizeScale)
    sharedPreferencesUtils.getFromPreferences('lastLanguage', 'zh-Hans-CN').then((value: preferences.ValueType) => {
      HiLog.w(TAG, 'getCurrentLanguage: ' + newConfig.language + ' value: ' + value);
      if (newConfig.language) {
        let res = newConfig.language.localeCompare(value as string);
        if (res !== 0) {
          HiLog.w(TAG, `lastLanguage changed...`);
          sharedPreferencesUtils.saveToPreferences('lastLanguage', newConfig.language);
          // 语言和上一次有变化 获取国家码
          let countryId = CountryIdUtil.getCountryId();
          AppStorage.setOrCreate('country', countryId);
        }
      }
    });
    let languageConfig = newConfig.language;
    AppStorage.setOrCreate('languageConfig', languageConfig);
    HiLog.i(TAG, 'languageConfig == ' + languageConfig);
    // PafUiWidget.configurationUpdate(newConfig)
    this.setSystemBarProps(newConfig);
    this.appMigration();
    this.visionGlassAppMigration(newConfig);
    AppStorage.setOrCreate('isDarkMode', newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AppStorage.setOrCreate('currentSystemRegion', i18n.System.getSystemRegion());
  }

  setSupportProcessCache(context: Context) {
    try {
      context.getApplicationContext().setSupportedProcessCache(false);
      HiLog.i(TAG, 'setSupportedProcessCache false.');
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      HiLog.e(TAG, `setSupportedProcessCache fail, code: ${code}, msg: ${message}`);
    }
  }
}
