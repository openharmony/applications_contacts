/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { BusinessError, systemParameterEnhance } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { PromptAction } from '@kit.ArkUI';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

/**
 * 系统模式
 */
export enum ModeType {
  /** 默认模式 */
  DEFAULT_MODE = 'default',
  /** 蓬莱模式 */
  PENG_LAI_MODE = 'penglai'
}

const TAG = 'SystemModeController';

/** 禁用置灰的不透明度样式，系统资源字符串 */
export const DISABLED_OPACITY_STRING = 'sys.float.interactive_disable';

export class SystemModeController {
  private static sInstance: SystemModeController | null;
  private static readonly BOOT_MODE_KEY = 'ohos.boot.minisys.mode';
  private static readonly SUPPORT_PENG_LAI_KEY = 'const.penglai.feature_enable';
  private static readonly SUPPORT_PENG_LAI_TRUE = 'true';
  private static readonly SUPPORT_PENG_LAI_FALSE = 'false';
  private currentMode: ModeType = ModeType.DEFAULT_MODE;
  /** 是否启用联系人海报 */
  private isEnablePosterAvatar: boolean = true;
  /** 是否启用视频通话 */
  private isEnableVideoCall: boolean = true;
  /** 是否启用联系人头像编辑 */
  private isEnableEditAvatar: boolean = true;
  /** 是否启用畅联视频通话 */
  private isEnableVideoCallOfMeeTime: boolean = true;
  /** 是否启用畅联语音通话 */
  private isEnableAudioCallOfMeeTime: boolean = true;
  /** 是否启用“导入/导出”设置项 */
  private isEnableImportOrExportContact: boolean = true;
  /** 是否启用扫一扫功能 */
  private isEnableScanContact: boolean = true;
  /** 是否跳转前往卫星网络设置项*/
  private isEnableShowDialog: boolean = false;
  /** 当前模式所在系统是否支持日历功能 */
  private isCurrentModeSupportCalendar: boolean = true;
  /**
   * 是否启用通话录音功能入口
   */
  private isEnableCallRecordEntry: boolean = true;
  /**
   * 是否启用小艺通话
   */
  private isEnableCeliaCall: boolean = true;
  /**
   * 是否能跳转到音乐应用
   */
  private isEnableJumpToMusicApp: boolean = true;

  constructor() {
    this.currentMode = SystemModeController.getModeFromSystemParameter();
    if (this.currentMode === ModeType.PENG_LAI_MODE && SystemModeController.getIsSupportPengLai()) {
      HiLog.i(TAG, 'handle penglai mode');
      this.setFeaturesEnableInPengLaiMode();
    }
  }

  public static getInstance() {
    if (!SystemModeController.sInstance) {
      SystemModeController.sInstance = new SystemModeController();
    }
    return SystemModeController.sInstance;
  }

  /**
   * 获取当前设备是否支持蓬莱模式
   * @returns boolean
   */
  private static getIsSupportPengLai = (): boolean => {
    let isSupportPengLai: boolean = false;
    try { // 从配置项文件中读取
      let value: string = systemParameterEnhance.getSync(this.SUPPORT_PENG_LAI_KEY, this.SUPPORT_PENG_LAI_FALSE);
      isSupportPengLai = (value === this.SUPPORT_PENG_LAI_TRUE);
    } catch (e) {
      HiLog.e(TAG, `getIsSupportPengLai: get system parameter region failed, error: ${e?.code} ${e?.message}`);
    }
    HiLog.i(TAG, `getIsSupportPengLai: isSupportPengLai ${isSupportPengLai}`);
    return isSupportPengLai;
  }
  /**
   * 蓬莱模式下，设置相关特性的是否启用
   */
  private setFeaturesEnableInPengLaiMode = () => {
    // 联系人海报
    this.isEnablePosterAvatar = false;
    // 联系人头像增删改
    this.isEnableEditAvatar = false;
    // 视频通话
    this.isEnableVideoCall = false;
    // 畅联视频通话
    this.isEnableVideoCallOfMeeTime = false;
    // 畅联语音通话
    this.isEnableAudioCallOfMeeTime = false;
    // “导入/导出”设置项
    this.isEnableImportOrExportContact = false;
    // 扫一扫功能
    this.isEnableScanContact = false;
    // "跳转前往卫星网络设置项"
    this.isEnableShowDialog = true;
    // 当前模式所在系统是否支持日历功能
    this.isCurrentModeSupportCalendar = false;
    // 通话录音入口
    this.isEnableCallRecordEntry = false;
    // 小艺通话
    this.isEnableCeliaCall = false;
    // 跳转到音乐应用
    this.isEnableJumpToMusicApp = false;
  }
  /** 获取是否能跳转到音乐应用 */
  public getIsEnableJumpToMusicApp = () => {
    return this.isEnableJumpToMusicApp;
  }
  /** 获取是否启用联系人海报 */
  public getIsEnablePosterAvatar = () => {
    return this.isEnablePosterAvatar;
  }
  /** 获取是否启用视频通话 */
  public getIsEnableVideoCall = () => {
    return this.isEnableVideoCall;
  }
  /** 获取是否启用联系人头像编辑 */
  public getIsEnableEditAvatar = () => {
    return this.isEnableEditAvatar;
  }
  /** 获取是否启用畅联视频通话 */
  public getIsEnableVideoCallOfMeeTime = () => {
    return this.isEnableVideoCallOfMeeTime;
  }
  /** 获取是否启用畅联视频通话 */
  public getIsEnableAudioCallOfMeeTime = () => {
    return this.isEnableAudioCallOfMeeTime;
  }
  /** 获取是否启用“导入/导出”设置项 */
  public getIsEnableImportOrExportContact = () => {
    return this.isEnableImportOrExportContact;
  }
  /** 获取是否启用扫一扫功能 */
  public getIsEnableScanContact = () => {
    return this.isEnableScanContact;
  }
  /** 获取是否跳转前往卫星网络设置项 */
  public getisEnableShowDialog = () => {
    return this.isEnableShowDialog;
  }
  /** 获取当前系统模式 */
  public getCurrentMode = () => {
    return this.currentMode;
  }
  /**
   * 获取是否启用小艺通话
   */
  public getIsEnableCeliaCall = () => {
    return this.isEnableCeliaCall;
  }
  /**
   * 获取是否启用通话录音功能入口
   */
  public getIsEnableCallRecordEntry = () => {
    return this.isEnableCallRecordEntry;
  }
  /**
   * 获取当前模式所在系统是否支持日历功能
   */
  public getIsCurrentModeSupportCalendar = () => {
    return this.isCurrentModeSupportCalendar;
  }
  /** 从系统配置中读取当前系统模式 */
  private static getModeFromSystemParameter = () => {
    let modeString: string = ModeType.DEFAULT_MODE.toString();
    try {
      modeString = systemParameterEnhance.getSync(this.BOOT_MODE_KEY, ModeType.DEFAULT_MODE.toString());
    } catch (e) {
      HiLog.e(TAG, `getCurrentMode: get system parameter error: ${e?.code} ${e?.message}`);
    }
    HiLog.i(TAG, `getCurrentMode: currentMode: ${modeString}`);
    let mode: ModeType;
    switch (modeString) {
      case ModeType.PENG_LAI_MODE.toString():
        mode = ModeType.PENG_LAI_MODE;
        break;
      default: //Modes without special logic are identified as default modes.
        mode = ModeType.DEFAULT_MODE;
        break;
    }
    return mode;
  }
  /** 获取禁用特性被触发是显示的提示内容 */
  public getDisabledFunctionTip = () => {
    switch (this.currentMode) {
      case ModeType.PENG_LAI_MODE:
        return $r('app.string.not_support_toast');
      default:
        return undefined;
    }
  }
}

/**
 * 显示底部悬浮提示
 * @param uiContext UIContext
 * @param message 提示内容
 * @param duration 持续时间，默认2000ms
 */
export const showToast = (uiContext: UIContext, message: Resource | undefined, duration?: number) => {
  if (!message || !uiContext) {
    return;
  }
  try {
    let promptAction: PromptAction = uiContext.getPromptAction();
    promptAction.showToast({
      message: message,
      duration: duration ?? 2000
    });
  } catch (e) {
    HiLog.e(TAG, `showToast err: ${e?.code} ${e?.message}`);
  }
}

/**
 * 销毁入参的context对应的UIAbility
 * @param context UIAbilityContext
 */
export const terminateUIAbilitySelf = (context: common.UIAbilityContext) => {
  if (!context) {
    HiLog.e(TAG, 'terminateUIAbilitySelf context empty');
    return;
  }
  try {
    context.terminateSelf().then(() => {
      HiLog.i(TAG, 'terminateUIAbilitySelf succeeded');
    }).catch((e: BusinessError) => {
      HiLog.e(TAG, `terminateUIAbilitySelf: terminateSelf error: ${e?.code} ${e?.message}`);
    });
  } catch (e) {
    HiLog.e(TAG, `terminateUIAbilitySelf error: ${e?.code} ${e?.message}`);
  }
}
