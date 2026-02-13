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

import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { ColorMetrics, LengthMetrics } from '@kit.ArkUI';
import { FontScaleState } from '../../util/fontScaleState';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ContactVo } from '../../model/bean/ContactVo';

const TAG = 'IntelligenceGroupPhoneNumberContactItemSendMsg ';

/**
 * The itelligence group contact item component is used to send message.
 */
@Component
@Reusable
export default struct IntelligenceGroupPhoneNumberContactItemSendMsg {
  @State isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State isPhoneNumberItemHover: boolean = false;
  @Link contactItem: ContactVo;
  private contactIndex: number = -1;
  private phoneNumberIndex: number = -1;
  private labelName: string | Resource = '';
  private onContactItemClicked: (index: number, indexChild: number) => void = () => {
  };

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.Center
      }) {
        Text(this.labelName)
          .fontColor($r('app.color.skin_font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .constraintSize({ minHeight: '19vp' })
      }
      .margin({
        start: this.isPC ? LengthMetrics.vp(48) : LengthMetrics.vp(56),
        end: LengthMetrics.vp(8)
      })
      .layoutWeight(1)
      .flexGrow(1)
      .constraintSize({
        minHeight: this.isPC ? '40vp' :
          FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_item_height_mid') :
            undefined
      })
      .padding({
        top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
          undefined,
        bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
          undefined,
        start: this.isPC ? LengthMetrics.vp(24) : LengthMetrics.vp(16)
      })

      Toggle({
        type: ToggleType.Checkbox,
        isOn: (this.contactItem.phoneNumbers[this.phoneNumberIndex as number].checked == undefined) ? false :
        this.contactItem.phoneNumbers[this.phoneNumberIndex as number].checked
      })
        .width('20vp')
        .height('20vp')
        .flexShrink(0)
        .enabled(true)
        .hitTestBehavior(HitTestMode.None)
        .margin({
          start: LengthMetrics.vp(2),
          end: LengthMetrics.vp(2),
          top: LengthMetrics.vp(2),
          bottom: LengthMetrics.vp(2)
        })
        .selectedColor($r('app.color.skin_comp_background_emphasize'))
        .focusable(false)
    }
    .onHover((isHover: boolean) => {
      this.isPhoneNumberItemHover = isHover;
    })
    .stateStyles({
      clicked: {
        .backgroundColor($r('sys.color.interactive_click'))
      },
      normal: {
        .backgroundColor(this.isPhoneNumberItemHover ? $r('sys.color.interactive_hover') :
          'rgba(255,255,255,0)')
      },
      pressed: {
        .backgroundColor($r('sys.color.interactive_pressed'))
        .width('100%')
      },
    })
    .focusBox({
      margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
      strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
    })
    .margin({
      top: FontScaleState.fetchSeniorListSpace(),
      bottom: FontScaleState.fetchSeniorListSpace()
    })
    .padding({
      end: LengthMetrics.vp(32)
    })
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? '40vp' :
        FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_item_height_mid') :
          undefined
    })
    .visibility(StringUtil.isEmpty(this.labelName as string) ? Visibility.None : Visibility.Visible)
    .onClick(() => {
      this.onContactItemClicked(this.contactIndex, this.phoneNumberIndex);
    })
    .focusable(true)
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
  }
}