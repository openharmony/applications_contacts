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

import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { HiLog } from '../../../../../../common'
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import {
  CALLING_FLAG} from '../../model/CallStateModel';
import { DSDS_MODE_V3, DSDS_MODE_V2 } from './DsdaConstants';
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';
import DotUtil from '../../util/DotUtil';
import { sim } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { FontScaleState } from '../../util/fontScaleState';
import { numFormat } from '../../util/NumFormat';
import { LengthMetrics } from '@kit.ArkUI';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { curves } from '@kit.ArkUI'
import componentUtils from '@ohos.arkui.componentUtils';
import { i18n } from '@kit.LocalizationKit';
import dotCommon, { slideDialParams } from '../../util/DotCommon';
import { SimCardType } from '../../data/Constants';

const TAG = 'MutiDialerButtonView';
const HALF = 2;

@Component
export struct MutiDialerButtonView {
  @Link mPresenter: DialerPresenter;
  @StorageLink('spnList') simNames: Array<string | Resource> = ['', ''];
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  @StorageLink('simCardStates') mSimStateArray: boolean[] = [false, false];
  @StorageLink('simCardTypes') simCardTypes: SimCardType[] = [SimCardType.PSIM, SimCardType.PSIM];
  @StorageLink('simCardIndexes') mSimIndexArray: Array<number> = [-1, -1];
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  private dialImg = [$r('sys.symbol.phone_badge_1_fill'), $r('sys.symbol.phone_badge_2_fill')];
  private eSimDialImg = $r('app.media.ic_call_eSIM_fill');
  @State incomingState: boolean = false;
  @State incommingInitState: boolean = false;
  @StorageProp('combinedCallState') @Watch('shouldEnableDialButtonForSlot') combinedCallState: number = 0;
  @State callRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  @State enable: boolean[] = [true, true];
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @State isLongPress: boolean = false;
  private swiperController: SwiperController = new SwiperController()
  displayNameWidth: number = 0;
  downX: number = 0;

  aboutToAppear() {
    this.shouldEnableDialButtonForSlot();
  }

  stringForCallBtn(index: number) {
    let text = ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .resourceManager
      .getStringSync($r('app.string.sim_card').id);
    text = text.replace('%s', numFormat(index === 0 ? 1 : 2))
    return text
  }

  shouldEnableDialButtonForSlot() {
    // 先判断dsdsMode
    sim.getDsdsMode().then(data => {
      HiLog.w(TAG, 'getDsdsMode: ' + data);
      this.mPresenter.dsdsMode = data;
      // 判断当前通话是否为紧急呼叫,双卡时紧急呼叫另外一张卡置灰
      call.isInEmergencyCall().then((result: boolean) => {
        HiLog.w(TAG, `isInEmergencyCallsuccess, data-> ${result}`);
        this.simNames.forEach((value, index) => {
          // 通话状态 如果是0代表空闲 如果是1代表通话中
          HiLog.w(TAG, `Current call status is: ${this.combinedCallState}`);
          /** 置灰情况:1、紧急呼叫情况下
           * 2、dsdsMode (为0或者1)并且在这种情况下通话中时 **/
          if (((this.mPresenter.dsdsMode !== DSDS_MODE_V3 && this.mPresenter.dsdsMode !== DSDS_MODE_V2) ||
            (this.combinedCallState === 0)) && !result) {
            // Should only disable for DSDS V2/V3 or Always enable for no calls cases
            this.enable[index] = true;
          } else {
            let otherSlotId = (index + 1) % 2;
            let callingFlag = CALLING_FLAG << otherSlotId;
            this.enable[index] = (this.combinedCallState & callingFlag) === 0;
          }
        });
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `isInEmergencyCallfail, data-> ${err?.message}, stack: ${err?.stack}`);
      });
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `getDsdsMode fail, data-> ${err?.message}, stack: ${err?.stack}`);
    });
  }


  @Builder
  simNamesBuilder(item: string | Resource, index: number) {
    if (this.defaultSlot === simId_DEFAULT || this.defaultSlot === undefined) {
      Row() {
        Row() {
          if (this.simCardTypes[index] === SimCardType.ESIM) {
            Image(this.eSimDialImg)
              .width('16vp')
              .height('16vp')
          } else {
            SymbolGlyph(this.dialImg[this.getPSimImgIndex(index)])
              .fontSize('16vp')
              .fontColor([$r('app.color.skin_white')])
          }

          Text(item)
            .margin({
              start: LengthMetrics.resource($r('sys.float.padding_level2'))
            })
            .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
            .maxLines(1)
            .minFontSize(`9vp`)
            .maxFontSize(`12vp`)
            .wordBreak(WordBreak.BREAK_WORD)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: `calc(100% - 20vp)` })
        }
      }
      .justifyContent(FlexAlign.Center)
      .opacity(this.enable[index] ? 1 : $r('sys.float.alpha_tertiary'))
      .accessibilityText(this.stringForCallBtn(index))
      .layoutWeight(1)
      .height($r('app.float.id_item_height_sm'))
      .backgroundColor($r('app.color.skin_confirm'))
      .onClick(() => {
        HiLog.w(TAG, `index: ${index}, Clicking the button...`);
        this.mPresenter.dialClick(this.getUIContext(), index);
      })
      .borderRadius($r('app.float.id_corner_radius_card'))
      .enabled(this.enable[index])
      .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      .id('mutiDialerButtonView_contacts_call_row')
    }
  }

  build() {
    Row() {
      if (this.defaultSlot === simId_DEFAULT || this.defaultSlot === undefined) {
        ForEach(this.simNames, (item: string | Resource, index: number) => {
          //DailButton for voLte
          if (index === 1) {
            Row()
              .height('100%')
              .width(8)
          }
          this.simNamesBuilder(item, index);
        })
      }

      if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
        Row() {
          Swiper(this.swiperController) {
            ForEach(this.simNames, (item: string, index: number) => {
              Row({ space: 4 }) {
                if (this.simCardTypes[index] === SimCardType.ESIM) {
                  Image(this.eSimDialImg)
                    .width('16vp')
                    .height('16vp')
                } else {
                  SymbolGlyph(this.dialImg[this.getPSimImgIndex(index)])
                    .fontSize('16vp')
                    .fontColor([$r('app.color.skin_white')])
                }

                Text(item)
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
                  .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ?
                  $r('sys.float.ohos_id_text_size_button3') : '12vp')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .flexShrink(1)
              }
              .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
              .justifyContent(FlexAlign.Center)
            })
          }
          .borderRadius($r('app.float.id_corner_radius_card'))
          .height('100%')
          .disableSwipe(true)
          .index(this.defaultSlot)
          .width('100%')
          .indicator(false)
          .curve(curves.springMotion(0.416, 0.99))
          .onChange((index: number) => {
            HiLog.w(TAG, `defaultSlot onChange slot: ${index}, isAirplaneMode: ${this.isAirplaneMode}`);
            if (!this.isAirplaneMode) {
              sim.setDefaultVoiceSlotId(index).then(() => {
                HiLog.w(TAG, `setDefaultVoiceSlotIdsuccess.`);
              }).catch((err: BusinessError) => {
                HiLog.e(TAG, `setDefaultVoiceSlotId failed, err: ${err.code} - ${err.message}`);
              });
            }
          })
        }
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            case TouchType.Down:
              //   获取按下的x位移
              this.downX = event.touches[0].x;
              break;
            case TouchType.Up:
              if (this.isLongPress) {
                this.isLongPress = false;
                let contactName: componentUtils.ComponentInfo =
                  componentUtils.getRectangleById('mutiDialerButtonView_contacts_call_flex');
                this.displayNameWidth = px2vp(contactName.size.width) / HALF;
                HiLog.w(TAG, `swiper width half: ${this.displayNameWidth} `);
                if (this.downX - event.touches[0].x > this.displayNameWidth) {
                  HiLog.w(TAG, `showNext distance: ${this.downX - event.touches[0].x}`);
                  // 联系人打点-左滑
                  slideDialParams.DIRECTION = 1;
                  DotUtil.getInstance().contactDot(slideDialParams, dotCommon.eventName.PRESS_SLIDE_DIAL_BUTTON_EVENT);
                  if (i18n.isRTL(i18n.System.getSystemLanguage())) {
                    HiLog.w(TAG, 'showPrevious mirror sliding');
                    this.swiperController.showPrevious();
                    return;
                  }
                  this.swiperController.showNext();
                } else if (event.touches[0].x - this.downX > this.displayNameWidth) {
                  HiLog.w(TAG, `showPrevious distance: ${event.touches[0].x - this.downX}`);
                  // 联系人打点-右滑
                  slideDialParams.DIRECTION = 2;
                  DotUtil.getInstance().contactDot(slideDialParams, dotCommon.eventName.PRESS_SLIDE_DIAL_BUTTON_EVENT);
                  if (i18n.isRTL(i18n.System.getSystemLanguage())) {
                    HiLog.w(TAG, 'showNext mirror sliding');
                    this.swiperController.showNext();
                    return;
                  }
                  this.swiperController.showPrevious();
                } else {
                  HiLog.w(TAG, "This swiper can not slide");
                  // 联系人打点-不滑动
                  slideDialParams.DIRECTION = 0;
                  DotUtil.getInstance().contactDot(slideDialParams, dotCommon.eventName.PRESS_SLIDE_DIAL_BUTTON_EVENT);
                }
              }
              break;
            default:
              break;
          }
        })
        .parallelGesture(
          LongPressGesture()
            .onAction((event: GestureEvent) => {
              this.isLongPress = true;
              VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
            }), GestureMask.Normal)
        .justifyContent(FlexAlign.Center)
        .constraintSize({ maxWidth: this.isVerde ? 100 : 108 })
        .width('100%')
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_call')))
        .height($r('app.float.id_item_height_sm'))
        .backgroundColor($r('app.color.skin_confirm'))
        .onClick(() => {
          HiLog.w(TAG, `defaultSlot: ${this.defaultSlot}, Clicking the button...`);
          this.mPresenter.dialClick(this.getUIContext(), this.defaultSlot);
        })
        .borderRadius($r('app.float.id_corner_radius_card'))
        .id('mutiDialerButtonView_contacts_call_flex')
      }
    }
    .width(!(this.defaultSlot === simId_DEFAULT || this.defaultSlot === undefined) ? undefined : '100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(this.isVerde ? 40 : 60)
  }

  private getPSimImgIndex(index: number) {
    if (this.mSimIndexArray[index] === index + 1) {
      // index 0, simIndex 1; index 1, simIndex 2
      return index;
    }
    // index 0, simIndex 2; index 1, simIndex 1(暂不存在此种情况)
    return this.mSimIndexArray[index] >= 1 ? this.mSimIndexArray[index] - 1 : 0;
  }
}