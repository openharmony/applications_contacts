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
import {
  ContactsGlobalThisHelper
} from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import fs from '@ohos.file.fs';
import { SymbolGlyphModifier, TextModifier } from '@kit.ArkUI';
import { HiLog, StringUtil } from '../../../../../../common';
import { RingtoneInfo, RingtoneParam, RingtoneType, ToneType } from '../../model/ringTone/toneTypes';
import LooseObject from '../../model/type/LooseObject';
import { systemSoundManager } from '@kit.AudioKit';
import { ArrayList } from '@kit.ArkTS';
import RingTonePresenter from '../../presenter/ringtone/RingTonePresenter';
import GroupIdUtil from '../../util/GroupIdUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'VideoMusicSelection ';

@Builder
export function VideoMusicSelectionLoader($$: Params): void {
  VideoMusicSelection();
}

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Component
export default struct VideoMusicSelection {
  @State mRingTonePresenter: RingTonePresenter = RingTonePresenter.getInstance();
  // path parameter
  @Consume('contactsRingtonePathInfo') contactsRingtonePathInfo: NavPathStack;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @State want: Want | undefined = undefined;
  private selectedRingTonesList: ArrayList<RingtoneInfo> = new ArrayList;
  private preSelectedRingtoneInfo: RingtoneInfo | undefined;

  private ringtoneParam: RingtoneParam = {
    contactId: '',
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
    let navParam: LooseObject = this.contactsRingtonePathInfo.getParamByIndex(
      this.contactsRingtonePathInfo.size() - 1) as LooseObject;

    this.mRingTonePresenter.selectedRingtoneInfo = navParam?.selectedRingtoneInfo;
    let tmpRingtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;

    this.mRingTonePresenter.contactId = navParam?.contactId;
    let ringtoneType: string | undefined = tmpRingtoneInfo.ringtoneType;
    if (ringtoneType == RingtoneType.LOCAL_VIDEO_TYPE || ringtoneType == RingtoneType.LOCAL_TYPE) {
      HiLog.i(TAG, 'selectedRingtoneInfo.ringtoneType is LOCAL_VIDEO_TYPE');
      this.preSelectedRingtoneInfo = tmpRingtoneInfo;
    }

    HiLog.i(TAG, 'selectedRingtonePath: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtonePath));
    HiLog.i(TAG, 'selectedRingtoneFilePath: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtoneFilePath));
    HiLog.i(TAG, 'selectedRingtoneName: ' + StringUtil.maskSensitiveInfo(tmpRingtoneInfo.ringtoneName));
    this.ringtoneParam.toneType = ToneType.CONTACT;
    this.ringtoneParam.selectedRingtoneName = tmpRingtoneInfo.ringtoneName;
    this.ringtoneParam.selectedRingtonePath = tmpRingtoneInfo.ringtoneFilePath;
    this.ringtoneParam.ringtonePath = tmpRingtoneInfo.ringtonePath;

    this.want = {
      bundleName: 'com.ohos.callsetting',
      abilityName: 'VideoRingtoneSettingsAbility',
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'ringtoneParam': this.ringtoneParam
      }
    }
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'aboutToDisappear !!');

    this.preSelectedRingtoneInfo = undefined;
    // 清除铃声库中的数据
    for (const item of this.selectedRingTonesList) {
      if (item.ringtonePath != this.mRingTonePresenter.selectedRingtoneInfo.ringtonePath) {
        this.mRingTonePresenter.removeContactLocalVideoRingtone(getContext(this), item.ringtonePath);
      }
    }
  }

  async removePreSelectedRingtone(): Promise<void> {
    if (this.preSelectedRingtoneInfo) {
      try {
        HiLog.i(TAG, 'preSelectedRingtoneInfo.ringtonePath is: ' +
        this.preSelectedRingtoneInfo.ringtonePath);
        this.mRingTonePresenter.removeContactLocalVideoRingtone(getContext(this),
          this.preSelectedRingtoneInfo.ringtonePath);
      } catch (error) {
        HiLog.e(TAG, 'removeCustomizedTone error: ' + error?.message + ', stack: ' + error?.stack);
      }
      this.preSelectedRingtoneInfo = undefined;
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: false,
  //     backIcon: {isThemeActive: this.isThemeActive, backIcon: true}
  //   };
  // }

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent(this.want as Want)
          .onRemoteReady((proxy: UIExtensionProxy) => {
            HiLog.i(TAG, `onRemoteReady`);
          })
          .onTerminated((data) => {
            HiLog.i(TAG, 'onTerminated data');
            let ringtoneInfo: RingtoneInfo = this.mRingTonePresenter.selectedRingtoneInfo;
            HiLog.i(TAG, `exit music app ringtoneName: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneName)},
             ringtoneFilePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneFilePath)},
              ringtonePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtonePath)}`);
            this.mRingTonePresenter.backFromLocalMusic();
            this.contactsRingtonePathInfo?.clear();
          })
          .onReceive(async (data: Record<string, Object>) => {
            if (data?.isShowUIExtension) {
              // 完整铃声信息key
              HiLog.i(TAG, `videoRingtonepath is: ${data?.path}`);
              HiLog.i(TAG, `videoRingtoneName is: ${data?.ringtoneName}`);

              let ringtone: RingtoneInfo = {
                ringtoneName: data?.ringtoneName ? data?.ringtoneName as string : '',
                ringtoneFilePath: data?.path ? data?.path as string : '',
                ringtonePath: data?.path ? data?.path as string : '',
                ringtoneType: RingtoneType.LOCAL_VIDEO_TYPE,
              }
              this.mRingTonePresenter.selectedRingtoneInfo = ringtone;
              this.mRingTonePresenter.backFromLocalMusic();
              this.mRingTonePresenter.isFromVideoMusic = true;
              this.removePreSelectedRingtone();
              this.selectedRingTonesList.add(ringtone);
            } else {
              HiLog.i(TAG, `isShowUIExtension: ${data?.isShowUIExtension}`)
              this.contactsRingtonePathInfo?.clear();
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
}