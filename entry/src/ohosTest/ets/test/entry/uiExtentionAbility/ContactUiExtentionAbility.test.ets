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
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import ContactUiExtentionAbility, {
  UiExtentionParam
} from '../../../../../main/ets/uiExtentionAbility/ContactUiExtentionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession'
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import DeviceTypeEnum from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/DeviceTypeEnum'
import { SearchUtil } from '../../../../../../../entry/src/main/ets/util/SearchUtil'
import { Configuration } from '@ohos.app.ability.Configuration'
import { uiExtensionHost, window } from '@kit.ArkUI';
import { Callback } from '@ohos.base';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';

const TAG = 'ContactUiExtentionAbility'

export default function ContactUiExtentionAbilityTest() {
  describe('ContactUiExtentionAbilityTest', () => {
    let contactUiExtentionAbility: ContactUiExtentionAbility;
    let uiExtentionParam: UiExtentionParam = new UiExtentionParam();
    beforeEach(() => {
      contactUiExtentionAbility = new ContactUiExtentionAbility();
    })

    it('ContactUiExtentionAbilityTest_parseContactParam_ContactDetail', 0, () => {
      let want: Want = {
        parameters: {
          extraInfo: JSON.stringify({
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog',
            contactId: 0,
            phoneNumber: "1399245855",
          }),
          heightData: "176",
          isFromCard:true,
          targetUrl: "ContactDetail"
        }
      };
      let result = contactUiExtentionAbility.parseContactParam(want);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({
        "urlType": "ContactDetail",
        "isContactsPicker": false,
        "isContactMultiSelect": true,
        "selectLimit": 10000,
        "isDisplayByName": false,
        "isSaveExistContact": false,
        "isSaveContact": false
      }));
    })

    it('ContactUiExtentionAbilityTest_parseContactParam_ContactDetail_contactId_gt_zero', 0, () => {
      let want: Want = {
        parameters: {
          extraInfo: JSON.stringify({
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog',
            contactId: 12,
            phoneNumber: "1399245855",
          }),
          heightData: "176",
          isFromCard:true,
          targetUrl: "ContactDetail"
        }
      };
      let result = contactUiExtentionAbility.parseContactParam(want);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({
        "urlType": "ContactDetail",
        "isContactsPicker": false,
        "isContactMultiSelect": true,
        "selectLimit": 10000,
        "isDisplayByName": false,
        "isSaveExistContact": false,
        "isSaveContact": false
      }));
    })

    it('ContactUiExtentionAbilityTest_parseContactParam_ContactSelect', 0, () => {
      let want: Want = {
        parameters: {
          extraInfo: JSON.stringify({
            contactId: 12,
            phoneNumber: 1762943545
          }),
          heightData: "176",
          isFromCard: false,
          phoneNumber: "1399245855",
          targetUrl: "ContactSelect"
        }
      };
      let result = contactUiExtentionAbility.parseContactParam(want);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({
        "urlType": "ContactSelect",
        "phoneNumber": "1399245855",
        "isContactsPicker": false,
        "isContactMultiSelect": true,
        "selectLimit": 10000,
        "isDisplayByName": false,
        "isSaveExistContact": false,
        "isSaveContact": false
      }));
    })

    it('ContactUiExtentionAbilityTest_parseContactParam_AddContact', 0, () => {
      let want: Want = {
        parameters: {
          extraInfo: JSON.stringify({
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog',
            contactId: "12",
            phoneNumber: "1399245855",
          }),
          heightData: "176",
          isFromCard:true,
          targetUrl: "AddContact"
        }
      };
      let result = contactUiExtentionAbility.parseContactParam(want);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({
        "urlType": "AddContact",
        "isContactsPicker": false,
        "isContactMultiSelect": true,
        "selectLimit": 10000,
        "isDisplayByName": false,
        "isSaveExistContact": false,
        "isSaveContact": false
      }));
    })

    it('ContactUiExtentionAbilityTest_onCreate', 0, () => {
      contactUiExtentionAbility.onCreate();
      expect(uiExtentionParam.userId).assertEqual(-1);
    })

    it('ContactUiExtentionAbilityTest_onForeground', 0, () => {
      contactUiExtentionAbility.onForeground();
      expect(uiExtentionParam.userId).assertEqual(-1);
    })

    it('ContactUiExtentionAbilityTest_onBackground', 0, () => {
      contactUiExtentionAbility.onBackground();
      expect(uiExtentionParam.userId).assertEqual(-1);
    })

    it('ContactUiExtentionAbilityTest_onDestroy', 0, () => {
      contactUiExtentionAbility.onDestroy();
      expect(uiExtentionParam.userId).assertEqual(-1);
    })

    it('ContactUiExtentionAbilityTest_updateExtentionLanguage', 0, () => {
      let languageConfig: string | undefined = "en_zh_ja"
      let languageConfigs = languageConfig.split('-');
      languageConfig = languageConfigs[0] + '-' + languageConfigs[2];
      contactUiExtentionAbility.updateExtentionLanguage(languageConfig);
      expect(AppStorage.get('languageConfig')).assertEqual(languageConfig);
    })

    it('ContactUiExtentionAbilityTest_initSplitInfo_01', 0, () => {
      contactUiExtentionAbility.initSplitInfo(DeviceTypeEnum.PAD);
      expect(AppStorage.get('isMeetimeNeedSplit')).assertTrue();
    })

    it('ContactUiExtentionAbilityTest_initSplitInfo_02', 0, () => {
      contactUiExtentionAbility.initSplitInfo(DeviceTypeEnum.HANDSET);
      expect(AppStorage.get('isMeetimeNeedSplit')).assertFalse();
    })

    it('ContactUiExtentionAbilityTest_onConfigurationUpdate', 0, () => {
      let newConfig: Configuration = {
        language: 'zh--cn'
      } as Configuration;
      contactUiExtentionAbility.onConfigurationUpdate(newConfig);
      expect(AppStorage.get('languageConfig')).assertEqual("zh-cn");
    })

    it('ContactUiExtentionAbilityTest_onSessionCreate_01', 0, async () => {
      let mocker: MockKit = new MockKit();

      let want: Want = {
        parameters: {
          dialogInfo: {
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog'
          }
        }
      };

      let result = false;
      let window1: window.Window = {
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
        getProperties: (): Promise<window.WindowProperties> => {
          return new Promise((resolve) => {
            let windowProperties: window.WindowProperties = {
              windowRect: {
                left: 0,
                top: 0,
                height: 0,
                width: 0
              },
              drawableRect: {
                left: 0,
                top: 0,
                height: 0,
                width: 0
              },
              isFullScreen: false,
              isLayoutFullScreen: false,
              focusable: false,
              touchable: false,
              brightness: 0,
              dimBehindValue: 0,
              isKeepScreenOn: false,
              isPrivacyMode: false,
              isRoundCorner: false,
              isTransparent: false,
              id: 0
            } as window.WindowProperties
            resolve(windowProperties);
          })
        },
        on: (type: 'windowSizeChange', callback: Callback<Size>) => {

        },
        setWindowTouchable: (isTouchable: boolean) => {

        },
        setWindowLayoutFullScreen: (isLayoutFullScreen: boolean) => {

        },
        setWindowBackgroundColor: (color: string) => {

        },
        setShadow: (radius: number, color?: string, offsetX?: number, offsetY?: number) => {

        },
        showWindow: () => {

        },
      } as window.Window;
      let extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy = {
        hidePrivacyContentForHost: (shouldHide: boolean) => {

        },
        createSubWindowWithOptions: (name: string,
          subWindowOptions: window.SubWindowOptions): Promise<window.Window> => {
          return new Promise((resolve) => {
            resolve(window1);
          });
        }
      } as uiExtensionHost.UIExtensionHostWindowProxy;
      let session: UIExtensionContentSession = {
        getUIExtensionHostWindowProxy: () => {
          return extensionWindow
        }
      } as UIExtensionContentSession;


      let uiExtentionParam: UiExtentionParam = {
        urlType: '',
        phoneNumber: '',
        contactId: 0,
        callerBundleName: '',
        callerToken: 0,
        isContactsPicker: true,
        isContactMultiSelect: false,
        selectLimit: 0,
        isDisplayByName: false,
        isSaveExistContact: false,
        isSaveContact: false,
        userId: 0
      }
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.isSysColor);
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.updateExtentionLanguage);
      contactUiExtentionAbility.context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIExtensionContext;
      when(mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.parseContactParam)
      )(ArgumentMatchers.any).afterReturn(uiExtentionParam);

      await contactUiExtentionAbility.onSessionCreate(want, session);

      expect(result).assertFalse();
      mocker.clear(contactUiExtentionAbility);
    })

    it('ContactUiExtentionAbilityTest_onSessionCreate_02', 0, async () => {
      let mocker: MockKit = new MockKit();

      let want: Want = {
        parameters: {
          dialogInfo: {
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog'
          }
        }
      };

      let result = false;
      let extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy = {
        hidePrivacyContentForHost: (shouldHide: boolean) => {

        },
        on: (type: 'windowSizeChange', callback: Callback<Size>) => {

        },
      } as uiExtensionHost.UIExtensionHostWindowProxy;
      let session: UIExtensionContentSession = {
        getUIExtensionHostWindowProxy: () => {
          result = true;
          return extensionWindow
        },
        setReceiveDataCallback: (callback: (data: Record<string, Object>) => void) => {

        },
        setWindowBackgroundColor: (color: string) => {

        },
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
      } as UIExtensionContentSession;


      let uiExtentionParam: UiExtentionParam = {
        urlType: 'ContactDetail',
        phoneNumber: '',
        contactId: 0,
        callerBundleName: '',
        callerToken: 0,
        isContactsPicker: false,
        isContactMultiSelect: false,
        selectLimit: 0,
        isDisplayByName: false,
        isSaveExistContact: false,
        isSaveContact: false,
        userId: 0
      }
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.isSysColor);
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.updateExtentionLanguage);
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.initSplitInfo);
      contactUiExtentionAbility.context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIExtensionContext;
      when(mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.parseContactParam)
      )(ArgumentMatchers.any).afterReturn(uiExtentionParam);

      await contactUiExtentionAbility.onSessionCreate(want, session);

      expect(result).assertTrue();
      mocker.clear(contactUiExtentionAbility);
    })

    it('ContactUiExtentionAbilityTest_onSessionCreate_03', 0, async () => {
      let mocker: MockKit = new MockKit();

      let want: Want = {
        parameters: {
          dialogInfo: {
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog'
          }
        }
      };

      let result = false;
      let extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy = {
        hidePrivacyContentForHost: (shouldHide: boolean) => {

        },
        on: (type: 'windowSizeChange', callback: Callback<Size>) => {

        },
        properties: {
          uiExtensionHostWindowProxyRect: {
            left: 0,
            top: 0,
            height: 0,
            width: 0
          },
        }
      } as uiExtensionHost.UIExtensionHostWindowProxy;
      let session: UIExtensionContentSession = {
        getUIExtensionHostWindowProxy: () => {
          return extensionWindow
        },
        setReceiveDataCallback: (callback: (data: Record<string, Object>) => void) => {

        },
        setWindowBackgroundColor: (color: string) => {

        },
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
      } as UIExtensionContentSession;


      let uiExtentionParam: UiExtentionParam = {
        urlType: '',
        phoneNumber: '',
        contactId: 0,
        callerBundleName: '',
        callerToken: 0,
        isContactsPicker: false,
        isContactMultiSelect: false,
        selectLimit: 0,
        isDisplayByName: false,
        isSaveExistContact: false,
        isSaveContact: false,
        userId: 0
      }
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.isSysColor);
      mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.updateExtentionLanguage);
      contactUiExtentionAbility.context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIExtensionContext;
      when(mocker.mockFunc(contactUiExtentionAbility, contactUiExtentionAbility.parseContactParam)
      )(ArgumentMatchers.any).afterReturn(uiExtentionParam);

      await contactUiExtentionAbility.onSessionCreate(want, session);

      expect(result).assertTrue();
      mocker.clear(contactUiExtentionAbility);
    })

    it('ContactUiExtentionAbilityTest_isSysColor', 0, () => {
      contactUiExtentionAbility.isSysColor();
      expect(AppStorage.get('isThemeActive')).assertUndefined();
    })

    it('ContactUiExtentionAbilityTest_onSessionDestroy', 0, () => {
      let session: UIExtensionContentSession = {
        } as UIExtensionContentSession;
      contactUiExtentionAbility.onSessionDestroy(session);
      expect(uiExtentionParam.userId).assertEqual(-1);
    })

    it('ContactUiExtentionAbilityTest_updateWindowFullScreenPadding', 0, () => {
      let padding: Padding = {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      }
      contactUiExtentionAbility.updateWindowFullScreenPadding(0, 0);
      expect(JSON.stringify(AppStorage.get<boolean>('fullScreenPadding'))).assertEqual(JSON.stringify(padding));

      AppStorage.setOrCreate('fullScreenPadding', false);
      contactUiExtentionAbility.updateWindowFullScreenPadding(-1, 0);
      expect(AppStorage.get<boolean>('fullScreenPaddingTop')).assertEqual(-1);
    })
  })
}