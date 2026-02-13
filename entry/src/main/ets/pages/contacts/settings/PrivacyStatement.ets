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
import { HiLog, StringUtil } from '../../../../../../../feature/call/oh_modules/common';
import LooseObject from '../../../model/type/LooseObject';
import common from '@ohos.app.ability.common';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import Configuration from '@system.configuration';
// import { PafPrivacyStatement } from '@hms-paf/ui-widget-permission'
// import { PafWebViewController } from '@hms-paf/ui-widget-webview';
import { PrivacyStatementContentTag } from '../../../presenter/contact/settings/PrivacyStatementPresenter';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { LengthMetrics } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { webview } from '@kit.ArkWeb';
import { connection } from '@kit.NetworkKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'PrivacyStatement';

const PRIVACY_STATE_URL_PATH = 'privacy-statement.htm';
const PRIVACY_DIR = 'privacy-statement';
const PRIVACY_RESOURCE_DIR = 'resource://rawfile';
const CODE = 'CN';
const BRANCH_ID = 500;
const DARK_MODE_FLAG = '&bgmode=black';

@Builder
export function PrivacyStatementLoader($$: Params): void {
  PrivacyStatement();
}

@Component
export default struct PrivacyStatement {
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  public contentTag: PrivacyStatementContentTag = PrivacyStatementContentTag.ErrorNetwork;
  // private privacyStateUrlDomainName =
  //   ResourceUtil.getStringByResource($r('app.string.privacy_state_url_domain_name'));
  private privacyStateUrlDomainName =
    ResourceUtil.getStringByResource($r('app.string.delete_all_callLog_dialog_title'));
  private controller?: webview.WebviewController;
  private isHasVoiceCapability: boolean = true;
  @State private privacyStatementUrl: string = '';
  private blackMode: string = '?bgmode=black';
  // @Provide('Paf.WebViewController') pafController: PafWebViewController = new PafWebViewController()
  @StorageProp('languageConfig') @Watch('updatePrivacyStatementUrl') private language: string = 'en-us';
  @StorageProp('currentColorMode') @Watch('updatePrivacyStatementUrl') currentColorMode: number = 1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageProp('fontScale') fontScale: number = 0;
  // 标记是否应用内部页面(PrivacyIndex对外提供入口调用时为false)调用
  @State isFromInner: boolean = true;
  backPressCallback?: () => boolean
  backgroundColorCustom: Resource = $r('app.color.color_bind_sheet_background')
  // private hdsNavigationBadgeIconOptions: HdsNavigationBadgeIconOptions[] | undefined = undefined;

  aboutToAppear() {
    HiLog.i(TAG, `aboutToAppear, connection.hasDefaultNetSync: ${connection.hasDefaultNetSync()}`);

    // if (this.isFromInner) {
    //   this.hdsNavigationBadgeIconOptions = TitleBarUtil.getBindSheetCloseButton();
    // }

    let navParam: LooseObject =
      this.contactsSettingsNavStack.getParamByIndex(this.contactsSettingsNavStack.size() - 1) as LooseObject;
    if (navParam) {
      this.contentTag = navParam.contentTag;
    }
    this.isHasVoiceCapability = call.hasVoiceCapability();
    if (!this.isHasVoiceCapability) {
      this.controller = new webview.WebviewController();
    }
    this.updatePrivacyStatementUrl();
    HiLog.i(TAG, `aboutToAppear end, isHasVoiceCapability: ${this.isHasVoiceCapability}`);
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear')
  }

  destinationPageShow() {
    HiLog.i(TAG, 'onPageShow')
  }

  destinationPageHide() {
    HiLog.i(TAG, 'onPageCover')
  }

  destinationBackPress() {
    HiLog.i(TAG, `onBackPress isFromInner: ${this.isFromInner}`);
    try {
      // 系统设置-隐私和安全-业务与隐私的声明返回实现
      if (this.backPressCallback) {
        HiLog.i(TAG, `onBackPress backPressCallback`);
        if (EnvironmentProp.isPC()) {
          // 从个人信息收集清单返回到隐私声明
          if (this.controller?.accessBackward()) {
            this.controller?.backward();
            return true;
          }

          // 从隐私声明返回到业务与隐私的声明设置
          return this.backPressCallback();
        } else {
          return false;
          // return this.pafController.onBackPress();
        }
      } else if (this.isHasVoiceCapability) {
        HiLog.i(TAG, `onBackPress isHasVoiceCapability`);
        return false;
        // return this.pafController.onBackPress();
      } else if (this.controller?.accessBackward()) {
        HiLog.i(TAG, `onBackPress webController`);
        this.controller?.backward();
        return true;
      } else {
        HiLog.i(TAG, `onBackPress else`);
        if (EnvironmentProp.isPC()) {
          this.contactsSettingsNavStack?.pop();
        }
        return false;
      }
    } catch (err) {
      HiLog.e(TAG, `onBackPress err: ${err.message}`);
      return false;
    }
  }

  updatePrivacyStatementUrl() {
    if (this.isHasVoiceCapability) {
      HiLog.w(TAG, `hasVoiceCapability`);
      let language = getContext().resourceManager.getConfigurationSync().locale;
      if (language.startsWith('zh_Hans')) {
        this.language = 'zh_CN';
      } else if (language.startsWith('zh_Hant')) {
        if (language.startsWith('zh_Hant_TW')) {
          this.language = 'zh_TW';
        } else {
          this.language = 'zh_HK';
        }
      }
      HiLog.w(TAG, `language: ${this.language}, contentTag: ${this.contentTag}`);
      this.privacyStatementUrl = `${this.privacyStateUrlDomainName}/${PRIVACY_STATE_URL_PATH}?code=${CODE
      }&language=${this.language}&branchid=${BRANCH_ID}&contenttag=${this.contentTag}&trsp=true`;

      // 深色模式
      if (this.currentColorMode !== 1) {
        this.privacyStatementUrl += DARK_MODE_FLAG;
      }
    } else {
      HiLog.w(TAG, `not hasVoiceCapability`);
      this.language = getContext().resourceManager.getConfigurationSync().locale;
      let localFname = '';
      if (this.language.startsWith('zh_Hans')) {
        localFname =this.currentColorMode !== 1 ? 'privacy-statement-zh-cn.htm' + this.blackMode : 'privacy-statement-zh-cn.htm';
      } else if (this.language.startsWith('zh_Hant')) {
        if (this.language == 'zh_Hant_TW') {
          localFname =this.currentColorMode !== 1 ? 'privacy-statement-zh-tw.htm' + this.blackMode : 'privacy-statement-zh-tw.htm';
        } else {
          localFname =this.currentColorMode !== 1 ? 'privacy-statement-zh-hk.htm' + this.blackMode : 'privacy-statement-zh-hk.htm';
        }
      } else if (this.language.startsWith('bo_Tibt')) {
        localFname =this.currentColorMode !== 1 ? 'privacy-statement-bo-cn.htm' + this.blackMode : 'privacy-statement-bo-cn.htm';
      } else if (this.language.startsWith('ug_Arab')) {
        localFname =this.currentColorMode !== 1 ? 'privacy-statement-ug-cn.htm' + this.blackMode : 'privacy-statement-ug-cn.htm';
      } else {
        localFname =this.currentColorMode !== 1 ? 'privacy-statement-en-us.htm' + this.blackMode : 'privacy-statement-en-us.htm';
      }
      HiLog.w(TAG, `language: ${this.language}, contentTag: ${this.contentTag}`);
      this.privacyStatementUrl = `${PRIVACY_RESOURCE_DIR}/${PRIVACY_DIR}/${this.contentTag}/${localFname}`;
      try {
        this.controller?.loadUrl(this.privacyStatementUrl);
      } catch (err) {
        HiLog.e(TAG, `controller loadUrl err: ${err.message}`);
      }
    }
  }

  onBack(): void {
    HiLog.i(TAG, 'onBack');
    if (this.contactsSettingsNavStack.size() > 0) {
      if (this.backPressCallback) {
        this.backPressCallback();
        return;
      }
    }
    this.contactsSettingsNavStack?.pop();
  }

  build() {
    // HdsNavDestination() {
    //   if (this.isHasVoiceCapability) {
    //     PafPrivacyStatement({
    //       webViewUrl: this.privacyStatementUrl,
    //       isNav: true,
    //       needShowNavigation: false,
    //       hideBackButton: true,
    //       forceDarkAccess: true,
    //       hideTitleBar: true,
    //       autoAvoid: false,
    //       fullPage: false,
    //       customBackgroundColor: Color.Transparent,
    //       navigationEvent: () => {
    //         HiLog.i(TAG, `callBack on navigationEvent.`);
    //         this.onBack();
    //       },
    //     })
    //       .margin({top: $r('app.float.id_item_height_max')})
    //   } else {
    //     Scroll() {
    //       Web({
    //         src: this.privacyStatementUrl,
    //         controller: this.controller,
    //       })
    //         .textZoomRatio(this.fontScale * 100)
    //         .darkMode(WebDarkMode.Auto)
    //         .forceDarkAccess(true)
    //         .zoomAccess(false)
    //         .backgroundColor(Color.Transparent)
    //         .verticalScrollBarAccess(false)
    //     }
    //     .height('100%')
    //     .scrollBar(BarState.Off)
    //     .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    //     .margin({top: $r('app.float.id_item_height_max')})
    //   }
    // }
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.hdsNavigationBadgeIconOptions, () => {
    //   HiLog.i(TAG, `callBack on titleBar.`);
    //   this.destinationBackPress();
    // }))
    // .onShown(() => {
    //   HiLog.i(TAG, `callBack on onShown.`);
    //   this.destinationPageShow();
    // })
    // .onHidden(() => {
    //   HiLog.i(TAG, `callBack on onHidden.`);
    //   this.destinationPageHide();
    // })
    // .onBackPressed((): boolean => {
    //   HiLog.i(TAG, `callBack on onBackPressed.`);
    //   return this.destinationBackPress();
    // })
    // .backgroundColor(this.backgroundColorCustom)
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: false,
  //     padding: { start: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
  //       LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: '' },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }
}