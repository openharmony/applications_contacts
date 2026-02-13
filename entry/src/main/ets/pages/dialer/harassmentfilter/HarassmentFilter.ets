/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import router from '@ohos.router';
import LooseObject from '../../../model/type/LooseObject';
import { CallLogRepository } from '../../../../../../../feature/call';

const TAG = 'HarassmentFilter ';

const CONTACTS_SPAMSHIELD_PAGE_EXT_UEC = 'CONTACTS_SPAMSHIELD_PAGE_EXT_UEC';

@Component
export default struct HarassmentFilter {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  @State showPage: boolean = false;
  @StorageLink('harassmentPageAbilityName') pageAbilityName: string = '';
  @StorageLink('harassmentSlotId') slotId: string = '-1';
  @State data: LooseObject = {}
  @State isExistInterceptionCallLog: boolean = true;
  uiExtensionProxy?: UIExtensionProxy;
  @State startTime: number = 0;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.startTime = new Date().getTime();
    CallLogRepository.getInstance().isExistInterceptionCallLog().then((isExist: boolean) => {
      HiLog.w(TAG, `query isExistInterceptionCallLog result: ${isExist} `);
      this.isExistInterceptionCallLog = isExist;
      this.showPage = true;
    })
    if (this.slotId !== '-1') {
      this.data = {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'slot_id': this.slotId
      }
    } else {
      this.data = {
        'ability.want.params.uiExtensionType': 'sys/commonUI'
      }
    }
  }

  aboutToDisappear() {
    this.pageAbilityName = '';
    this.slotId = '-1';
    HiLog.i(TAG, 'aboutToDisappear');
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        this.showDetails()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .backgroundColor($r('app.color.skin_background_secondary'))
    .hideTitleBar(true)
  }

  @Builder
  showDetails() {
    Text('进入了页面。。。')
    Column() {
      LoadingProgress()
        .width(72)
        .height(72);

      // Text($r('app.string.loading'))
      Text('加载')
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontSize('sys.color.ohos_id_text_size_body2')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .margin({ top: 16 });
    }
    .alignItems(HorizontalAlign.Center)
    .visibility(!this.showPage ? Visibility.Visible : Visibility.Hidden)
    .zIndex(1)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.IDENTITY,
      TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Ease })))

    Column() {
      UIExtensionComponent(
        {
          bundleName: 'com.ohos.spamshield',
          abilityName: this.pageAbilityName === '' ?
            (this.isExistInterceptionCallLog ? 'CallProtectRecordAbility' : 'CallSettingsAbility') :
            this.pageAbilityName,
          parameters: this.data
        })
        .id(CONTACTS_SPAMSHIELD_PAGE_EXT_UEC)
        .onResult((data) => {
          HiLog.i(TAG, 'onResult : ' + data?.code);
        })
        .onRelease((code) => {
          HiLog.i(TAG, 'onRelease : ' + code);
        })
        .onError((error: Error) => {
          HiLog.e(TAG, 'spamshield onError：'+JSON.stringify(error));
        })
        .onReceive((data) => {
          // update message
          HiLog.i(TAG, 'onReceive data');
          if ((AppStorage.get('breakpoint') === 'sm') ||
            (AppStorage.get('isShowSmartWindow') && !AppStorage.get('isNavigationModeSplit'))) {
            this.pathInfos?.clear();
          } else {
            HiLog.w(TAG, 'pathInfos onReceive: DialerPad');
            CallRecordPresenter.getInstance().toDefaultPage();
          }
        })
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
          this.requestFocus(CONTACTS_SPAMSHIELD_PAGE_EXT_UEC);
          this.sendTitleAnimationDuration();
          this.uiExtensionProxy?.on('asyncReceiverRegister', () => {
            this.sendTitleAnimationDuration()
          })
        })
        .width('100%')
        .height('100%')
    }
    .zIndex(2)
    .visibility(!this.showPage ? Visibility.Hidden : Visibility.Visible)
  }

  private sendTitleAnimationDuration() {
    let costTime = new Date().getTime() - this.startTime;
    if (costTime >= 0) {
      HiLog.i(TAG, 'title costTime time is: ' + costTime);
      this.uiExtensionProxy?.send({ 'titleAnimationDuration': costTime });
    }
  }

  /**
   * UEC不会主动获焦，这里需要进行适配
   */
  private requestFocus(blockedId: string) {
    // 因 aboutToAppear中设置this.showPage 变量超时250ms,此处获焦需要同步超时
    setTimeout(() => {
      try {
        this.getUIContext().getFocusController().requestFocus(blockedId);
      } catch (error) {
        HiLog.e(TAG, 'requestFocus failed code: {},message: {}', error?.code, error?.message);
      }
    }, 300);
  }
}