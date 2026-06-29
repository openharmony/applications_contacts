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
import { IntelligenceGroupInfo } from '../../model/bean/GroupBean'
import { CustomizedParams, GroupParams } from '../../model/type';
import { FontScaleState } from '../../util/fontScaleState';
import { SplitStatus } from '../../util/DisplaySplitUtil';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { ColorMetrics, LengthMetrics } from '@kit.ArkUI';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import IntelligenceGroupSingleCategoryDetailPresenter
  from '../../presenter/intelligencegroup/IntelligenceGroupSingleCategoryDetailPresenter';
import { numFormat } from '../../util/NumFormat'

const TAG = 'GroupList-group';

/**
 * group
 */
@Component
export default struct IntelligenceGroupSingleCategoryItem {
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link categoryDetailPresenter: IntelligenceGroupSingleCategoryDetailPresenter;
  @Prop item: IntelligenceGroupInfo;
  @State categoryGroupType: string = '0';
  @State categoryIndex: string = '0';
  customParams: CustomizedParams = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  createGroupParams: CustomizedParams = {};
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State isMenuShown: boolean = false;
  @State isCategoryItemHover: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor(Color.Transparent)
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear')
  }

  build() {
    Row() {
      if (this.isPC || FontScaleState.isSmallerThirdGeer(this.fontSizeScale)) {
        Row() {
          if (this.item.isTranslate) {
            if (this.item.categoryType === '0') {
              Text($r('app.string.intelligence_group_no_company'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.categoryType === '1') {
              Text($r('app.string.intelligence_group_no_address'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.categoryType === '2') {
              if (this.item.groupName === 'CONTACT_WEEKLY') {
                Text($r('app.string.intelligence_group_contact_less_than_one_week'))
                  .intelligenceGroupnNameText()
                  .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              } else if (this.item.groupName === 'CONTACT_MONTHLY') {
                Text($r('app.string.intelligence_group_contact_less_than_one_month'))
                  .intelligenceGroupnNameText()
                  .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 3 : 10)
              } else if (this.item.groupName === 'CONTACT_IN_THREE_MONTHS') {
                Text($r('app.string.intelligence_group_contact_less_than_three_month', numFormat(3)))
                  .intelligenceGroupnNameText()
                  .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 3 : 10)
              } else if (this.item.groupName === 'CONTACT_OVER_THREE_MONTHS') {
                Text($r('app.string.intelligence_group_no_contact_more_than_three_month', numFormat(3)))
                  .intelligenceGroupnNameText()
                  .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              }
            }
          } else {
            Text(this.item.groupName)
              .intelligenceGroupnNameText()
              .maxLines(2)
          }
        }
        .flexShrink(1)
        .constraintSize({ minHeight: this.isPC ? 22 : undefined })

        Row() {
          Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            .lineHeight($r('app.float.id_groupList_lineHeight_xl'))
            .margin({
              left: $r('sys.float.padding_level8')
            })

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_fourth')])
            .margin({
              left: $r('sys.float.padding_level2')
            })
        }
      } else {
        // 老年模式
        this.seniorLayout();
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? '40vp' : $r('app.float.id_item_height_mid')
    })
    .padding({
      top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
        '0vp',
      bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
        '0vp',
      left: '8vp',
      right: '8vp'
    })
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
    })
    .onHover((isHover: boolean) => {
      this.isCategoryItemHover = isHover;
    })
    .stateStyles({
      clicked: {
        .backgroundColor($r('sys.color.interactive_click'))
      },
      normal: {
        .backgroundColor(this.isCategoryItemHover ? $r('sys.color.interactive_hover') : 'rgba(255,255,255,0)')
      },
      pressed: this.pressedStyles,
    })
    .borderRadius(this.isPC ? $r('sys.float.corner_radius_level6') : $r('sys.float.corner_radius_level8'))
    .focusBox({
      margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
      strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
    })
    .id('GrouoList_MenuView_toGroupListDetail_Flex')
    .onClick(() => {
      // 联系人打点--手机群组点击进入某群组
      this.categoryDetailPresenter.toIntelliGenceGroupSingleGroupDetail(this.categoryGroupType, this.item.groupName,
        this.categoryIndex, this.item.memberCount)
    })
    .width('100%')
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
  }

  @Builder
  normalLayout() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start,
    }) {
      Row() {
        if (this.item.isTranslate) {
          if (this.item.categoryType === '0') {
            Text($r('app.string.intelligence_group_no_company'))
              .intelligenceGroupnNameText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item.categoryType === '1') {
            Text($r('app.string.intelligence_group_no_address'))
              .intelligenceGroupnNameText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item.categoryType === '2') {
            if (this.item.groupName === 'CONTACT_WEEKLY') {
              Text($r('app.string.intelligence_group_contact_less_than_one_week'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_MONTHLY') {
              Text($r('app.string.intelligence_group_contact_less_than_one_month'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_IN_THREE_MONTHS') {
              Text($r('app.string.intelligence_group_contact_less_than_three_month'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_OVER_THREE_MONTHS') {
              Text($r('app.string.intelligence_group_no_contact_more_than_three_month'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            }
          }
        } else {
          Text(this.item.groupName)
            .intelligenceGroupnNameText()
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
        }
      }
      .constraintSize({ minHeight: this.isPC ? 22 : undefined })
    }
    .width('100%')

    Row() {
      Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
        .lineHeight($r('app.float.id_groupList_lineHeight_xl'))
        .margin({
          right: $r('sys.float.padding_level2')
        })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_fourth')])
    }
    .padding({
      right: '3vp'
    })
    .margin({
      left: $r('sys.float.padding_level8')
    })
  }

  @Builder
  seniorLayout() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start,
    }) {
      Row() {
        if (this.item.isTranslate) {
          if (this.item.categoryType === '0') {
            Text($r('app.string.intelligence_group_no_company'))
              .intelligenceGroupnNameText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item.categoryType === '1') {
            Text($r('app.string.intelligence_group_no_address'))
              .intelligenceGroupnNameText()
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          } else if (this.item.categoryType === '2') {
            if (this.item.groupName === 'CONTACT_WEEKLY') {
              Text($r('app.string.intelligence_group_contact_less_than_one_week'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_MONTHLY') {
              Text($r('app.string.intelligence_group_contact_less_than_one_month'))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_IN_THREE_MONTHS') {
              Text($r('app.string.intelligence_group_contact_less_than_three_month', numFormat(3)))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            } else if (this.item.groupName === 'CONTACT_OVER_THREE_MONTHS') {
              Text($r('app.string.intelligence_group_no_contact_more_than_three_month', numFormat(3)))
                .intelligenceGroupnNameText()
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            }
          }
        } else {
          Text(this.item.groupName)
            .intelligenceGroupnNameText()
            .maxLines(2)
        }
      }
      .constraintSize({ minHeight: this.isPC ? 22 : undefined })

      Blank();

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
      }) {
        Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xl') })
          .margin({ right: 4 })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
      }
      .margin({ top: 2 })
    }
  }
}

@Extend(Text)
function intelligenceGroupnNameText() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
