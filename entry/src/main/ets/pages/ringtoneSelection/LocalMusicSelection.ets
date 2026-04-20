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

import { Params } from '../../../../../../common/src/main/ets/Constants';
import { ComponentContent, SymbolGlyphModifier, TextModifier } from '@kit.ArkUI';
import {
  ContactsGlobalThisHelper
} from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import fs from '@ohos.file.fs';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { HiLog, StringUtil } from '../../../../../../common';
import { RingtoneInfo, RingtoneParam, RingtoneType, ToneType } from '../../model/ringTone/toneTypes';
import LooseObject from '../../model/type/LooseObject';
import { systemSoundManager } from '@kit.AudioKit';
import { ArrayList } from '@kit.ArkTS';
import RingTonePresenter from '../../presenter/ringtone/RingTonePresenter';
import GroupIdUtil from '../../util/GroupIdUtil';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'LocalMusicSelection ';
// 本地音乐
const LOCAL_PAGE_TYPE = 'localMusic';
// 在线铃声
const ONLINE_PAGE_TYPE = 'onlineRingtone'

@Builder
export function LocalMusicSelectionLoader($$: Params): void {
  LocalMusicSelection();
}

@Builder
function loadingProgressBuilder(params: Params) {
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
  .zIndex(1)
  .transition(TransitionEffect.asymmetric(
    TransitionEffect.IDENTITY,
    TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Ease })))
}

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Component
export default struct LocalMusicSelection {
  @State mRingTonePresenter: RingTonePresenter = RingTonePresenter.getInstance();
  // path parameter
  @Consume('contactsRingtonePathInfo') contactsRingtonePathInfo: NavPathStack;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @State want: Want | undefined = undefined;
  @State isMusicExist: boolean = false;
  @State pageType: string = LOCAL_PAGE_TYPE;
  private selectedRingTonesList: ArrayList<RingtoneInfo> = new ArrayList;
  private preSelectedRingtoneInfo: RingtoneInfo | undefined;
  private contentNodeLoadingProgress = new ComponentContent(this.getUIContext(), wrapBuilder(loadingProgressBuilder));

  private ringtoneParam: RingtoneParam = {
    pageType : '',
    toneType : 'contact',
    card : '',
    ringtonePath: '',
    selectedRingtonePath: '',
    selectedRingtoneName: '',
    selectedLibraryRingtonePath: '',
    showTitle: true,
    selectRingtoneContentId: ''
  };

  aboutToAppear(): void {
    HiLog.i(TAG, 'aboutToAppear !!');
    if (!this.contactsRingtonePathInfo || this.contactsRingtonePathInfo.size() === 0) {
      HiLog.e(TAG, `contactsRingtonePathInfo is null or size is 0.`);
      return;
    }
    let navParam: LooseObject =
      this.contactsRingtonePathInfo.getParamByIndex(this.contactsRingtonePathInfo.size() - 1) as LooseObject;
    if (!navParam) {
      HiLog.e(TAG, `navParam is null or undefined.`);
      return;
    }
    this.mRingTonePresenter.selectedRingtoneInfo = navParam?.selectedRingtoneInfo;
    this.isMusicExist = navParam?.isMusicExist;
    this.pageType = navParam?.pageType;
    if (this.mRingTonePresenter.selectedRingtoneInfo.ringtoneType == RingtoneType.LOCAL_TYPE ||
      this.mRingTonePresenter.selectedRingtoneInfo.ringtoneType == RingtoneType.LOCAL_VIDEO_TYPE) {
      HiLog.i(TAG, 'selectedRingtoneInfo.ringtoneType is LOCAL_TYPE');
      this.preSelectedRingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
    }
    this.ringtoneParam.pageType = this.isMusicExist ? this.pageType : LOCAL_PAGE_TYPE;
    this.ringtoneParam.toneType = ToneType.CONTACT;
    this.ringtoneParam.showTitle = this.isMusicExist ? true : false;
    if (this.isMusicExist) {
      this.ringtoneParam.ringtonePath = this.mRingTonePresenter.selectedRingtoneInfo.ringtoneFilePath;
    } else {
      this.ringtoneParam.selectedRingtoneName = this.mRingTonePresenter.selectedRingtoneInfo.ringtoneName;
      this.ringtoneParam.selectedRingtonePath = this.mRingTonePresenter.selectedRingtoneInfo.ringtoneFilePath;
    }
    this.want = {
      bundleName: this.isMusicExist ? 'com.ohos.hmsapp.music' : 'com.ohos.hms.musicservice',
      abilityName: 'ringtoneSettingUIExtensionAbility',
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'ringtoneParam': this.ringtoneParam,
        'exitWithTerminateFrom': false
      }
    }
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'aboutToDisappear !!');

    this.preSelectedRingtoneInfo = undefined;
    // 清除铃声库中的数据
    this.selectedRingTonesList.forEach(async item => {
      if (item.ringtonePath != this.mRingTonePresenter.selectedRingtoneInfo.ringtonePath) {
        try {
          HiLog.i(TAG, 'selectedRingTonesList ringtonePath is: ' + StringUtil.maskSensitiveInfo(item.ringtonePath));
          await systemSoundManager.getSystemSoundManager()?.removeCustomizedTone(getContext(this),
            item.ringtonePath);
        } catch (error) {
          HiLog.e(TAG, 'removeCustomizedTone error: ' + error?.message + ', stack: ' + error?.stack);
        }
      }
    });
  }

  async removePreSelectedRingtone(): Promise<void> {
    if (this.preSelectedRingtoneInfo) {
      let tempRingtonePath = this.preSelectedRingtoneInfo.ringtonePath;
      try {
        HiLog.i(TAG, 'tempRingtonePath is: ' + StringUtil.maskSensitiveInfo(tempRingtonePath));
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('queryLocalRingToneUsedTimes', {
            id: this.mRingTonePresenter.contactId,
            uri: tempRingtonePath
          }, (result: number) => {
            HiLog.w(TAG, 'queryLocalRingToneUsedTimes succ: ' + result);
            if (result < 1) {
              if (tempRingtonePath) {
                try {
                  systemSoundManager.getSystemSoundManager()?.removeCustomizedTone(getContext(this),
                    tempRingtonePath);
                } catch (error) {
                  HiLog.e(TAG, 'removePreSelectedRingtone err: ' + error?.message + ', stack: ' + error?.stack);
                  return;
                }
              }
            }
          });
      } catch (error) {
        HiLog.e(TAG, 'removePreSelectedRingtone error: ' + error?.message + ', stack: ' + error?.stack);
        return;
      }
      this.preSelectedRingtoneInfo = undefined;
    }
  }

  build() {
   NavDestination() {
      Column() {
        UIExtensionComponent(
          this.want as Want,
          {
            placeholder: this.contentNodeLoadingProgress,
          })
          .onRemoteReady((proxy: UIExtensionProxy) => {
            HiLog.i(TAG, `onRemoteReady`);
          })
          .onTerminated((data) => {
            HiLog.i(TAG, 'onTerminated data');
            let ringtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
            HiLog.i(TAG, `exit music app ringtoneName: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneName)},
             ringtoneFilePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneFilePath)},
              ringtonePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtonePath)}`);
            this.mRingTonePresenter.isFromLocalMusic = true;
            this.mRingTonePresenter.backFromLocalMusic();
            this.contactsRingtonePathInfo?.clear();
          })
          .onReceive(async (data: Record<string, Object>) => {
            // 完整铃声信息key
            if (data.isShowUIExtension) {
              HiLog.i(TAG, `isShowUIExtension is: ${data?.isShowUIExtension}`);
              HiLog.i(TAG, `ringtoneLibaryPath is: ${StringUtil.maskSensitiveInfo(data?.ringtoneLibaryPath as string)}`);
              HiLog.i(TAG, `ringtoneName is: ${StringUtil.maskSensitiveInfo(data?.ringtoneName as string)}`);
              HiLog.i(TAG, `ringtonePath is: ${StringUtil.maskSensitiveInfo(data?.ringtonePath as string)}`);

              let ringtone: RingtoneInfo = {
                ringtoneName: data?.ringtoneName ? data?.ringtoneName as string : '',
                ringtoneFilePath: data?.ringtonePath ? data?.ringtonePath as string : '',
                ringtonePath: data?.ringtoneLibaryPath ? data?.ringtoneLibaryPath as string : '',
                ringtoneType: RingtoneType.LOCAL_TYPE,
              }
              this.mRingTonePresenter.selectedRingtoneInfo = ringtone;
              this.mRingTonePresenter.isFromLocalMusic = true;
              this.removePreSelectedRingtone();
              this.selectedRingTonesList.add(ringtone);
            } else {
              if (!this.isMusicExist) {
                HiLog.i(TAG, `isShowUIExtension:`)
                if (data?.ringtoneLibaryPath) {
                  let ringtone: RingtoneInfo = {
                    ringtoneName: data?.ringtoneName ? data?.ringtoneName as string : '',
                    ringtoneFilePath: data?.ringtonePath ? data?.ringtonePath as string : '',
                    ringtonePath: data?.ringtoneLibaryPath ? data?.ringtoneLibaryPath as string : '',
                    ringtoneType: RingtoneType.LOCAL_TYPE,
                  }
                  this.mRingTonePresenter.selectedRingtoneInfo = ringtone;
                  this.selectedRingTonesList.add(ringtone);
                  this.removePreSelectedRingtone();
                }
              }
              HiLog.i(TAG, `exit music app ringtoneName:
               ${StringUtil.maskSensitiveInfo(this.mRingTonePresenter.selectedRingtoneInfo.ringtoneName)}`);
              this.mRingTonePresenter.isFromLocalMusic = true;
              this.mRingTonePresenter.backFromLocalMusic();
              this.contactsRingtonePathInfo?.clear();
              this.contactsRingtonePathInfo?.pop();
            }
          })
          .onRelease((releaseCode: number) => {
            HiLog.i(TAG, `onRelease`);
          })
          .onResult((data: Object) => {
            HiLog.i(TAG, `onResult`);
          })
          .onError((error) => {
            HiLog.i(TAG, `onError`);
            this.contactsRingtonePathInfo?.clear();
          })
          .backgroundColor($r('app.color.color_bind_sheet_background'))
          .height('100%')
          .width('100%')
          .id('localRingtoneExtension')
          .gesture(GestureGroup(GestureMode.Sequence, PanGesture()))
          .defaultFocus(true)
      }
      .backgroundColor($r('app.color.color_bind_sheet_background'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_bind_sheet_background'))
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
    //   HiLog.i(TAG, 'onBackPressed !!');
    //   this.contactsRingtonePathInfo?.pop();
    // }))
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: false,
  //     backIcon: {isThemeActive: this.isThemeActive, backIcon: true}
  //   };
  // }
}