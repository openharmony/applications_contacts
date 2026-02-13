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


import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { FontScaleState } from '../../util/fontScaleState';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { ColorMetrics, LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import IntelligenceGroupListPresenter from '../../presenter/intelligencegroup/IntelligenceGroupListPresenter';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';

const TAG = 'IntelligenceGroupList-group';
const INTELLIGENCE_GROUP_CATEGORY_CLICK_EVENT = 'SMART_GROUP_CATEGORY_EVENT';

/**
 * group
 */
@Component
export default struct IntelligenceGroupListItem {
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link intelligenceGroupPresenter: IntelligenceGroupListPresenter;
  @Prop item: string;
  @Prop type: number;
  intelligenceGroupCategoryCustomParams: CustomizedParams = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  createGroupParams: CustomizedParams = {};
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State isMenuShown: boolean = false;
  @State isItemHover: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
  }

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Start,
      }) {
        Row() {
          if (this.item === 'origanization') {
            Text($r('app.string.intelligence_group_company'))
              .intelligenceGroupText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item === 'city') {
            Text($r('app.string.intelligence_group_city'))
              .intelligenceGroupText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item === 'latestcontact') {
            Text($r('app.string.intelligence_group_latest_contact'))
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              .intelligenceGroupText()
          }
        }
        .width('100%')
        .constraintSize({ minHeight: this.isPC ? 22 : undefined })
      }

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_fourth')])
        .flexShrink(0)
        .margin({
          left: $r('sys.float.padding_level4')
        })
    }
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? '40vp' :
        FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_item_height_mid') : undefined
    })
    .padding({
      top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      left: '8vp',
      right: '8vp'
    })
    .focusBox({ margin: LengthMetrics.vp(-2) })
    .onHover((isHover: boolean) => {
      this.isItemHover = isHover;
    })
    .stateStyles({
      clicked: {
        .backgroundColor($r('sys.color.interactive_click'))
      },
      normal: {
        .backgroundColor(this.isItemHover ? $r('sys.color.interactive_hover') : 'rgba(255,255,255,0)')
      },
      pressed: this.pressedStyles,
    })
    .borderRadius(this.isPC ? $r('sys.float.corner_radius_level6') : $r('sys.float.corner_radius_level8'))
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
    })
    .id('GrouoList_MenuView_toGroupListDetail_Flex')
    .onClick(() => {
      // 联系人打点--点击单位 城市 最近联系人
      this.intelligenceGroupCategoryCustomParams.CATEGORYTYPE = this.type;
      DotUtil.getInstance()
        .contactDot(this.intelligenceGroupCategoryCustomParams, INTELLIGENCE_GROUP_CATEGORY_CLICK_EVENT);
      this.intelligenceGroupPresenter.toIntelliGenceGroupListDetail(this.item, this.type + '')
    })
    .width('100%')
    .focusBox({
      margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
      strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
    })
    .onMouse((event: MouseEvent) => {
      // 鼠标右键响应长按事件
      if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
        VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
        this.isMenuShown = true
      }
    })
  }

  @Builder
  MenuPreview() {
    Scroll() {
      Row() {
        Text('test')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid'),
    })
    .align(Alignment.Start)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width(DisplaySplitUtil.isHorizonSplit(this.splitStatus) && deviceInfo.deviceType === 'tablet' ? '40%' : '100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
  }
}

@Extend(Text)
function intelligenceGroupText() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
