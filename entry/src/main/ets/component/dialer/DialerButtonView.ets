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

import EnvironmentProp from '../../feature/EnvironmentProp';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { MutiDialerButtonView } from '../mutisim/MutiDialerButtonView'
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import CallRecordListDataSource from '../../model/bean/CallRecordListDataSource';
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';
import { simId_DEFAULT, simId_ONE } from '../../feature/sim/SimCardState';
import MainAbility from '../../MainAbility/MainAbility';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import Calls from '../../../../../../feature/call/src/main/ets/contract/Calls'
import DataShareResultSet from '@ohos.data.DataShareResultSet'
import { Content } from '@kit.ArkUI';


const TAG = 'DialerButtonView';

const satelliteType: number = 0;

@Component
export struct DialerButtonView {
  emergencyNum: string = '';
  @Link mPresenter: DialerPresenter;
  @State callRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  // airplane mode enabled
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('isSatelliteMode') isSatelliteMode: boolean = false;
  @StorageLink('isHyacinthMode') isHyacinthMode: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp('isVerde') isVerde: boolean = false;

  private getDialButtonHeight(): number {
    let dialHeight: number = 0;
    if (this.isVerde) {
      return 40;
    }
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = 44;
    } else {
      dialHeight = 56;
    }
    return dialHeight;
  }

  private getDialButtonMargin(): number {
    let dialHeight: number = 0;
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = 6;
    } else {
      dialHeight = 0;
    }
    return dialHeight;
  }

  private getDialButtonFontSizeMargin(): number | string {
    let dialHeight: number | string = 0;
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = '24vp';
    } else {
      dialHeight = '32vp';
    }
    return dialHeight;
  }

  private getDialButtonMarginBottom(): number {
    let dialHeight: number = 0;
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = 2;
    } else {
      dialHeight = 0;
    }
    return dialHeight;
  }

  build() {
    Row() {
      if (this.isHyacinthMode){    //风信子界面
        Button({ type: ButtonType.Circle }) {
          Image(($r('app.media.hyacinth_call_button'))) //需要替换系统图标id
            .fillColor($r('app.color.skin_white'))
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_satellite_call')))
            .size({ width: 24, height: 24 })
        }
        .width(this.getDialButtonHeight())
        .height(this.getDialButtonHeight())
        .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
        .id('phone_badge_satellite_fill')
        .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
        .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
          ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
        .onClick(async () => {
          HiLog.w(TAG, `HyacinthMode: ${this.isHyacinthMode}, Clicking the button...`);
          this.mPresenter.dialClick(this.getUIContext());
        })
      } else if (this.isSatelliteMode) {        //天通界面
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.phone_badge_satellite_fill'))
              .fontSize(this.isVerde ? $r('app.float.id_card_image_small') : $r('app.float.id_card_margin_xxxxl'))
              .fontColor([$r('app.color.skin_white')])
              .accessibilityText(AccessibilityUtil.getInstance()
                .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_satellite_call')))
          }
          .width(this.getDialButtonHeight())
          .height(this.getDialButtonHeight())
          .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
          .id('phone_badge_satellite_fill')
          .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
          .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
            ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
          .onClick(() => {
            HiLog.w(TAG, `satelliteMode: ${this.isSatelliteMode}, Clicking the button...`);
            this.mPresenter.dialClick(this.getUIContext());
          })
      } else if (this.isAirplaneMode) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize(this.isVerde ? $r('app.float.id_card_image_small') : $r('app.float.id_card_margin_xxxxl'))
            .fontColor([$r('app.color.skin_white')])
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_call')))
        }
        .width(this.getDialButtonHeight())
        .height(this.getDialButtonHeight())
        .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
        .backgroundColor($r('app.color.skin_confirm'))
        .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
          ? 1 : $r('sys.float.alpha_tertiary'))
        .onClick(() => {
          HiLog.w(TAG, `airplaneMode: ${this.isAirplaneMode}, Clicking the button...`);
          this.mPresenter.dialClick(this.getUIContext());
        })
        .id('dialerButtonView_contacts_airplane_btn')
      } else if (!this.haveMultiSimCard) {
        Button({ type: ButtonType.Circle }) { //无论有无通话能力单卡下都不显示hd
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize(this.isVerde ? $r('app.float.id_card_image_small') : this.getDialButtonFontSizeMargin())
            .fontColor([$r('app.color.skin_white')])
        }
        .width(this.getDialButtonHeight())
        .height(this.getDialButtonHeight())
        .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_call')))
        .backgroundColor($r('app.color.skin_confirm'))
        .opacity(!EnvironmentProp.isTablet() || this.mPresenter.btnShow || this.haveSimCard
          ? 1 : $r('sys.float.alpha_tertiary'))
        .onClick(() => {
          HiLog.w(TAG, `multiSimCard: ${this.haveMultiSimCard}, Clicking the button...`);
          this.mPresenter.dialClick(this.getUIContext());
        })
        .id('dialerButtonView_contacts_call_btn')
      } else {
        MutiDialerButtonView({
          mPresenter: $mPresenter,
        })
      }
    }
    .width('100%')
    .height((DisplaySplitUtil.isSmLeft(this.splitStatus)) ? 52 : (this.splitStatus === SplitStatus.HALF_SPLIT) ||
      (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ? 52 : 60)
    .justifyContent(FlexAlign.Center)
  }
}