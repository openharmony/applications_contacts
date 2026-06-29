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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium'
import MainAbility from '../../../../../main/ets/MainAbility/MainAbility'
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { DTGlobalContext } from '../../../testability/TestAbility';
import PageManager from '../../../../../main/ets/MainAbility/PageManager';
import common from '@ohos.app.ability.common';
import CallServiceManager from '../../../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { ListenerManager } from '../../../../../main/ets/listeners/ListenerManager';
import Window from '@ohos.window'
import { AsyncCallback, BusinessError, Callback } from '@ohos.base';
import { ContactWindowsManager, sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import { Rect } from '@ohos.application.AccessibilityExtensionAbility';
import SimManager from '../../../../../main/ets/feature/sim/SimManager';
import { Configuration } from '@ohos.app.ability.Configuration'
import { PafUiWidget } from '@hms-paf/ui-widget-base';
import { display } from '@kit.ArkUI';
import { CountryIdUtil } from '../../../../../../../common/src/main/ets/util/CountryIdUtil';
import EnvironmentProp from '../../../../../main/ets/feature/EnvironmentProp';
import { VisionGlassConstants } from '../../../../../../../entry/src/main/ets/data/VisionGlassConstants';
import { StartOptions } from '@kit.AbilityKit';

export default function MainAbilityTest() {
  describe('MainAbilityTest', () => {

    let mainAbility: MainAbility;

    beforeEach(() => {
      AppStorage.clear();
      mainAbility = new MainAbility();
      mainAbility.context = DTGlobalContext.getContext().getObject("contactContext") as common.UIAbilityContext;
      mainAbility.pageManager = new PageManager(mainAbility.context);
    })

    /*it('MainAbility_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().set))(ContactsGlobalThisHelper.UIContextName).afterAction(() => {
      });
      when(mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().set))(ContactsGlobalThisHelper.DataWorkerName).afterAction(() => {
      })
      let updateMeetimeLoginFlag: Function =
        mocker.mockFunc(CallServiceManager.getInstance(), CallServiceManager.getInstance()
          .updateMeetimeLoginFlag);
      when(updateMeetimeLoginFlag)().afterReturn(new Promise<void>(resolve => resolve()));
      let result = false;
      let manageCreate: Function = mocker.mockFunc(mainAbility.pageManager, mainAbility.pageManager?.onCreate);
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      when(manageCreate)(want).afterAction(() => {
        result = true;
      });
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.START_ABILITY,
        lastExitReason: AbilityConstant.LastExitReason.NORMAL
      } as AbilityConstant.LaunchParam;
      mocker.mockFunc(mainAbility, mainAbility.getAndListenAudioRingModeInfo);
      mocker.mockFunc(mainAbility, mainAbility.updateWindowStageContent);

      mainAbility.onCreate(want, launchParam);
      expect(result).assertTrue();

      mocker.clear(mainAbility.pageManager);
      mocker.clear(CallServiceManager.getInstance());
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
      mocker.clear(mainAbility);
    })*/

    it('MainAbility_getAndListenAudioRingModeInfo', 0, () => {
      mainAbility.getAndListenAudioRingModeInfo();

      expect(mainAbility.listenerManager).assertNull();
    })

    it('MainAbility_onNewWant', 0, async () => {
      let want: Want = {
        deviceId: '',
        bundleName: 'com.ohos.contacts',
        abilityName: 'MainAbility',
      } as Want;
      let mocker: MockKit = new MockKit();
      let onNewWant: Function = mocker.mockFunc(mainAbility.pageManager, mainAbility.pageManager?.onNewWant);
      let result = false;
      when(onNewWant)(want).afterAction(() => {
        result = true;
      });
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: AbilityConstant.LaunchReason.START_ABILITY,
        lastExitReason: AbilityConstant.LastExitReason.NORMAL
      } as AbilityConstant.LaunchParam;
      mainAbility.onNewWant(want, launchParam);
      expect(result).assertTrue();

      mocker.clear(mainAbility.pageManager);
    });

    it('MainAbility_onWindowStageCreate_exception', 0, () => {
      let windowStage: Window.WindowStage = {} as Window.WindowStage;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(PafUiWidget, PafUiWidget.init))(windowStage)
        .afterThrow('error');

      mocker.mockFunc(mainAbility, mainAbility.updateWindowStageContent);

      mainAbility.onWindowStageCreate(windowStage);

      mocker.verify('updateWindowStageContent', []).once();

      mocker.clear(mainAbility);
      mocker.clear(PafUiWidget);
    })

    it('MainAbility_onWindowStageCreate', 0, () => {
      let windowStage: Window.WindowStage = {
        getMainWindow: () => {
          let window: Window.Window = {
            getProperties: () => new Promise<Window.WindowProperties>(resolve => resolve({
              windowRect: {
                left: 0,
                top: 0
              } as Rect,
            } as Window.WindowProperties))
          } as Window.Window;
          return new Promise<Window.Window>(resolve => resolve(window));
        },
        on: (eventType: 'windowStageEvent', callback: Callback<Window.WindowStageEventType>) => {
        }
      } as Window.WindowStage;
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(mainAbility, mainAbility.updateWindowStageContent);

      mainAbility.onWindowStageCreate(windowStage);

      mocker.verify('updateWindowStageContent', []).once();

      mocker.clear(ContactWindowsManager.getInstance());
      mocker.clear(mainAbility);
    })

    it('MainAbility_updateWindowStageContent_noWindowState', 0, () => {
      mainAbility.updateWindowStageContent();
      expect(mainAbility.listenerManager).assertNull();
    })

    it('MainAbility_updateWindowStageContent_loadContent_error', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 1400001
          } as BusinessError);
        }
      } as Window.WindowStage;
      mainAbility.onWindowStageCreate(windowStage);
      mainAbility.updateWindowStageContent();
      expect(result).assertTrue();
    })

    it('MainAbility_updateWindowStageContent_reportDrawnCompleted_error', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'success'
          } as BusinessError);
        }
      } as Window.WindowStage;
      mainAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            code: 1400001
          } as BusinessError);
        }
      } as common.UIAbilityContext;
      mainAbility.onWindowStageCreate(windowStage);
      mainAbility.updateWindowStageContent();
      expect(result).assertTrue();
    })

    it('MainAbility_updateWindowStageContent_reportDrawnCompleted_error2', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'success'
          } as BusinessError);
        }
      } as Window.WindowStage;
      mainAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          result = true;
          let error: BusinessError = {
            code: 1400001, message: 'error', name: 'unknown'
          };
          throw error as Error;
        }
      } as common.UIAbilityContext;
      mainAbility.onWindowStageCreate(windowStage);
      mainAbility.updateWindowStageContent();
      expect(result).assertTrue();
    })

    it('MainAbility_updateWindowStageContent', 0, () => {
      let result = false;
      let windowStage: Window.WindowStage = {
        loadContent: (path: string, storage: LocalStorage, callback: AsyncCallback<void, void>): void => {
          result = true;
          callback({
            message: 'success'
          } as BusinessError);
        }
      } as Window.WindowStage;
      mainAbility.context = {
        reportDrawnCompleted: (callback: AsyncCallback<void, void>): void => {
          callback({
            message: 'success'
          } as BusinessError);
        }
      } as common.UIAbilityContext;
      mainAbility.onWindowStageCreate(windowStage);
      mainAbility.updateWindowStageContent();
      expect(result).assertTrue();
    })

    it('MainAbility_updateWindowSize', 0, () => {
      let width: number = 720;
      let height: number = 1920;
      let mocker: MockKit = new MockKit();
      mainAbility.storage = new LocalStorage();
      mainAbility.updateWindowSize(width, height);
      expect(mainAbility.storage.get('windowHeightPx')).assertEqual(height);

      mocker.clear(mainAbility);
    })

    it('MainAbility_isSmartWindow_1240', 0, () => {
      mainAbility.isSmartWindow(4);

      expect(AppStorage.get('isShowSmartWindow')).assertTrue();

      mainAbility.isSmartWindow(1);
      expect(AppStorage.get('isShowSmartWindow')).assertFalse();
    })

    it('MainAbility_updateWindowAvoidAreaHeight', 0, () => {
      let height: number = 1920;
      mainAbility.storage = new LocalStorage();
      mainAbility.updateWindowAvoidAreaHeight(height);
      expect(mainAbility.storage.get('windowAvoidAreaHeightPx')).assertEqual(height);
    })

    it('MainAbility_updateWindowFullScreenPadding_paddingTop', 0, () => {
      AppStorage.setOrCreate('fullScreenPadding', {
        top: 1,
        bottom: 1
      } as Padding);

      let top = -10;
      let bottom = -10;
      let padding: Padding = {
        top: 1,
        bottom: 1,
        left: 0,
        right: 0
      };

      mainAbility.updateWindowFullScreenPadding(top, bottom);

      let fullScreenPadding: Padding | undefined = AppStorage.get('fullScreenPadding');

      expect(JSON.stringify(fullScreenPadding)).assertEqual(JSON.stringify(padding));
    })

    it('MainAbility_updateWindowFullScreenPadding_prePadding_undefined', 0, () => {
      let top = -10;
      let bottom = -10;
      let padding: Padding = {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      };

      mainAbility.updateWindowFullScreenPadding(top, bottom);
      let fullScreenPadding: Padding | undefined = AppStorage.get('fullScreenPadding');
      expect(JSON.stringify(fullScreenPadding)).assertEqual(JSON.stringify(padding));
    })

    it('MainAbility_updateWindowFullScreenPadding_top_10', 0, () => {
      AppStorage.setOrCreate('fullScreenPadding', {
        top: 0,
        bottom: 0
      } as Padding);
      let top = 10;
      let bottom = 10;
      let padding: Padding = {
        top: top,
        bottom: bottom,
        left: 0,
        right: 0
      };
      mainAbility.updateWindowFullScreenPadding(top, bottom);
      let fullScreenPadding: Padding | undefined = AppStorage.get('fullScreenPadding');
      expect(JSON.stringify(fullScreenPadding)).assertEqual(JSON.stringify(padding));
    })

    it('MainAbility_updateWindowFullScreenPadding_11', 0, () => {
      AppStorage.setOrCreate('fullScreenPadding', {
        top: 11,
        bottom: 11
      } as Padding);
      let top = -1;
      let bottom = -1;
      let padding: Padding = {
        top: 11,
        bottom: 11,
        left: 0,
        right: 0
      };
      mainAbility.updateWindowFullScreenPadding(top, bottom);
      let fullScreenPadding: Padding | undefined = AppStorage.get('fullScreenPadding');
      expect(JSON.stringify(fullScreenPadding)).assertEqual(JSON.stringify(padding));
    })

    it('MainAbility_updateWindowFullScreenPadding_0', 0, () => {
      AppStorage.setOrCreate('fullScreenPadding', {} as Padding);
      let top = -1;
      let bottom = -1;
      let padding: Padding = {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      };
      mainAbility.updateWindowFullScreenPadding(top, bottom);
      let fullScreenPadding: Padding | undefined = AppStorage.get('fullScreenPadding');
      expect(JSON.stringify(fullScreenPadding)).assertEqual(JSON.stringify(padding));
    })

    it('MainAbility_onWindowStageDestroy', 0, () => {
      mainAbility.onWindowStageDestroy();
      expect(mainAbility.audioVolumeGroupManager).assertNull();
    })

    it('MainAbility_onForeground', 0, () => {
      mainAbility.simManager = new SimManager();

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(mainAbility, mainAbility.publishPageStateChangeEvent);

      mocker.mockFunc(mainAbility.simManager, mainAbility.simManager.init);

      mainAbility.onForeground();

      expect(mainAbility.audioVolumeGroupManager).assertNull();

      mocker.clear(mainAbility);
    })

    it('MainAbility_onForeground_foregroundCallBack', 0, () => {
      mainAbility.simManager = new SimManager();

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(mainAbility, mainAbility.publishPageStateChangeEvent);

      mocker.mockFunc(mainAbility.simManager, mainAbility.simManager.init);

      mainAbility.onForeground();

      expect(mainAbility.audioVolumeGroupManager).assertNull();

      mocker.clear(mainAbility.simManager);
      mocker.clear(mainAbility);
    })

    it('MainAbility_onBackground', 0, () => {
      mainAbility.simManager = new SimManager();
      mainAbility.onBackground();
      expect(AppStorage.get('isMainAbilityForeground')).assertFalse();
      mainAbility.simManager = null;
    })

    it('MainAbility_px2vp_0_error', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(display.getAllDisplays(), display.getAllDisplays().then))()
        .afterReturn((resolve: (value: void | PromiseLike<void>) => void, reject: (reason?: BusinessError) => void) => {
          reject({
            code: 0, message: 'error'
          } as BusinessError);
        });

      let result: number = px2vp(0);
      expect(result).assertEqual(0);
      mocker.clear(display.getAllDisplays());
    })


    it('MainAbility_onConfigurationUpdate_no_if', 0, () => {
      let newConfig: Configuration = {
        language: ''
      } as Configuration;
      mainAbility.onConfigurationUpdate(newConfig);
      let languageConfig: string | undefined = AppStorage.get('languageConfig');
      expect(languageConfig).assertEqual(newConfig.language);
    })

    it('MainAbility_onConfigurationUpdate_if', 0, () => {
      let newConfig: Configuration = {
        language: 'zh-cn'
      } as Configuration;
      mainAbility.onConfigurationUpdate(newConfig);
      expect(AppStorage.get('languageConfig')).assertEqual('zh-cn');
    })

    it('MainAbility_onConfigurationUpdate_appMigrationgit', 0, () => {
      let newConfig: Configuration = {
        displayId: 1
      } as Configuration;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CountryIdUtil, CountryIdUtil.getCountryId);
      mocker.mockFunc(sharedPreferencesUtils,
        sharedPreferencesUtils.getFromPreferences('lastLanguage', 'zh-Hans-CN').then);
      mainAbility.onConfigurationUpdate(newConfig);
      expect(AppStorage.get('isDarkMode')).assertFalse();
      mocker.clear(CountryIdUtil);
      mocker.clear(sharedPreferencesUtils);
    })

    it('MainAbility_processHiCarStartUp', 0, () => {
      let parameters: Record<string, Object> = {
        'hiCarDeviceType': 'Car'
      }
      let want: Want = {
        parameters: parameters
      }
      mainAbility.processHiCarStartUp(want);
      expect(AppStorage.get('isInHiCar')).assertTrue();

      let want1: Want = {}
      mainAbility.processHiCarStartUp(want1);
      expect(AppStorage.get('isInHiCar')).assertTrue();
    })

    it('MainAbility_getWindowSwitchStatus', 0, () => {
      let mocker: MockKit = new MockKit();
      let isDeviceTypeTablet: Function =
        mocker.mockFunc(EnvironmentProp, EnvironmentProp.isDeviceTypeTablet);
      when(isDeviceTypeTablet)().afterReturn(true);

      mainAbility.getWindowSwitchStatus();
      expect(AppStorage.get('isWindowPcMode')).assertFalse();

      mocker.clear(EnvironmentProp);
    })

    it('MainAbility_processVisionGlassStartUp', 0, () => {
      let parameters: Record<string, Object> = {
        'ohos.aafwk.param.callerBundleName': VisionGlassConstants.VISION_GLASS
      }
      let want: Want = {
        parameters: parameters
      };
      mainAbility.processVisionGlassStartUp(want);
      expect(AppStorage.get(VisionGlassConstants.KEY_IS_IN_VISION_GLASS)).assertTrue();

      let want1: Want = {}
      mainAbility.processVisionGlassStartUp(want1);
      expect(AppStorage.get(VisionGlassConstants.KEY_IS_IN_VISION_GLASS)).assertTrue();
    })

    it('MainAbility_terminateAbility', 0, () => {
      let want: Want = {
        bundleName: 'com.ohos.sceneboard',
        abilityName: 'abilityName'
      };
      mainAbility.terminateAbility(want, '', 'contextName', '');
      expect(AppStorage.get('contextName')).assertUndefined();

      let context: common.UIExtensionContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> =>
        new Promise <void>(resolve => resolve())
      } as common.UIExtensionContext;
      AppStorage.setOrCreate('preAbilityName', context);
      mainAbility.terminateAbility(want, 'abilityName', 'contextName', 'preAbilityName');
      expect(AppStorage.get('TerminateSelfFlag')).assertTrue();
    })

    it('MainAbility_onDestroy', 0, () => {
      AppStorage.setOrCreate('TerminateSelfFlag', true);
      mainAbility.onDestroy();
      expect(AppStorage.get('TerminateSelfFlag')).assertFalse();

      AppStorage.setOrCreate('TerminateSelfFlag', false);
      mainAbility.onDestroy();
      expect(mainAbility.callLogDataAbilityHelper).assertUndefined();
    })
  })
}