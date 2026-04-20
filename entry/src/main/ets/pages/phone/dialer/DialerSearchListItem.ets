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
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import NameDisposal from '../../../feature/NameDisposal';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import LooseObject from '../../../model/type/LooseObject';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { LengthMetrics } from '@kit.ArkUI';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { FontScaleState } from '../../../util/fontScaleState';

const TAG = 'DialerSearchListItem ';
const hasComma: RegExp = new RegExp(',', 'g');
const COMMA_REPLACE: string = '&comma;';
const labelMatch: RegExp = new RegExp('<|>', 'gi');

// 拨号盘搜索出的通话记录或联系人的一行
@Reusable
@Component
export struct DialerSearchListItem {
  // 点击内容触发调用，拨打电话
  onClickContentCallBack?: (name: string, phoneNumber: string) => void;
  onClickIntoDetailCallBack?: (detailParam: Record<string, boolean | string>) => void;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @State entityId: string = '';
  // 名称
  @State displayName: string = '';
  // 电话号码
  @State phoneNumberWithHighLight: string = '';
  @State numberLocation: string = '';
  @State organization: string = '';
  @State markType: string = '';
  @State markCustom: string = '';
  @State isCloudMark: number = 0;
  @State markCount: number = 0;
  @State formatNumber: string = '';
  @State highlight: number[] = [-1, -1];
  @State dataType: number = 0;
  @Link selectIndex: number;
  curIndex: number = -1

  aboutToAppear() {
  }

  aboutToReuse(item: LooseObject): void {
    this.displayName = item.displayName;
    this.phoneNumberWithHighLight = item.phoneNumberWithHighLight;
    this.markType = item.markType;
    this.markCustom = item.markCustom;
    this.isCloudMark = item.isCloudMark;
    this.markCount = item.markCount;
    this.numberLocation = item.numberLocation;
    this.organization = item.organization;
    this.entityId = item.entityId;
    this.formatNumber = item.formatNumber;
    this.highlight = item.highlight;
    this.dataType = item.dataType;
  }

  getCallLogItemSecondaryText(): string | Resource {
    if (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
      return $r('app.string.number_mark_fraud_smart_identify');
    }
    // 用户手动标记
    if (this.isCloudMark === 0 && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        return $r('app.string.number_marked',
          this.markCustom);
      }
      return $r('app.string.number_marked',
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id));
    } else if (this.isCloudMark === 1 && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC) {
        return this.markCustom;
      }
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id) +
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getStringSync($r('app.plural.harassment_blockreason_mark_by_other', this.markCount,
        this.markCount));
    } else if (this.numberLocation && this.numberLocation !== 'N') {
      return this.numberLocation as string;
    } else {
      return $r('app.string.unknown');
    }
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Column() {
        // 通话记录搜索
        Row() {
          if (StringUtil.isEmpty(this.displayName)) {
            Text() {
              ForEach(Array.from(this.formatNumber), (item: string, index: number) => {
                if (index >= this.highlight[0] && index <= this.highlight[1]) {
                  Span(item)
                    .fontColor($r('app.color.skin_font_emphasize'))
                } else {
                  Span(item)
                    .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                }
                })
            }
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
            .maxLines(this.fontSizeScale < 1 ? 1 : 10)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .direction(Direction.Ltr)
          } else {
            Text() {
              ForEach(NameDisposal.charEscape(this.displayName.replace(hasComma, COMMA_REPLACE).split(labelMatch)),
                (items: string, index: number) => {
                  if (!(items === 'em' || items === '/em')) {
                    if (index != 0) {
                      if (this.displayName.split(labelMatch)[index - 1] === 'em') {
                        Span(items)
                          .fontColor($r('app.color.skin_font_emphasize'))
                      } else {
                        Span(items)
                          .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                      }
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                    }
                  }
                })
            }
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxLines(this.fontSizeScale < 1 ? 1 : 10)
            .maxFontScale(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }.constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xxl') })
        .padding({top: FontScaleState.fetchSeniorListSpace()})

        //
        Row() {
          if (StringUtil.isEmpty(this.displayName)) {
            Text(this.getCallLogItemSecondaryText())
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))// .lineHeight('19vp')
              .fontWeight(FontWeight.Regular)
              .maxFontScale(2)
          } else {
            Text() {
              ForEach(Array.from(this.formatNumber), (item: string, index: number) => {
                if (index >= this.highlight[0] && index <= this.highlight[1]) {
                  Span(item)
                    .fontColor($r('app.color.skin_font_emphasize'))
                } else {
                  Span(item)
                    .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                }
              })
              if (!StringUtil.isEmpty(this.organization)) {
                Span('\xa0')
                Span(this.organization)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              }
            }
            .fontSize($r('sys.float.Body_M'))
            .maxFontScale(2)
            .fontWeight(FontWeight.Regular)
            .maxLines(this.fontSizeScale < 1 ? 1 : 10)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .direction(Direction.Ltr)
          }
        }
          .margin({
            top: $r('sys.float.padding_level1')
          })
          .constraintSize({ minHeight: $r('app.float.id_card_title_margin_top') })
        .padding({bottom: FontScaleState.fetchSeniorListSpace()})
      }
      .onClick(() => {
        if (this.onClickContentCallBack) {
          HiLog.w(TAG, 'onClickContentCallBack highlight ' + this.highlight);
          this.onClickContentCallBack(this.displayName, this.phoneNumberWithHighLight);
        }
      })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: EnvironmentProp.isPC() ? $r('app.float.id_item_height_large') :
          this.isVerde ? 56 : $r('app.float.id_item_height_max')
      })
      .focusable(true)
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })

      // 通话记录搜索，进入联系人详情
      Button() {
        SymbolGlyph($r('sys.symbol.info_circle'))
          .fontSize($r('app.float.id_card_margin_max'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .hitTestBehavior(HitTestMode.Block)
      .type(ButtonType.Normal)
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .width($r('app.float.id_item_height_mid'))
      .height($r('app.float.id_item_height_mid'))
      .width($r('app.float.id_item_height_mid'))
      .margin({ right: $r('app.float.Dialog_bottom') })
      .id('dialerSearchList_contacts_detail_btn')
      .onClick(() => {
        this.selectIndex = this.curIndex;
        if (this.onClickIntoDetailCallBack) {
          let detailParam: Record<string, boolean | string> = {};
          // 使用dataType区分已知联系人(1)使用contactId查询详情页信息，陌生联系人通话记录(0)使用phoneNumber查询详情页
          if (this.dataType === 1) {
            HiLog.w(TAG, 'dialerSearchResult intoDetail byContactId');
            detailParam = {
              'sourceHasId': true,
              'contactId': this.entityId,
            };
          } else {
            HiLog.w(TAG, 'dialerSearchResult intoDetail byPhoneNumber');
            detailParam = {
              'sourceHasPhone': true,
              'phoneNumberShow': this.phoneNumberWithHighLight.replace(new RegExp('<\/?.+?>', 'g'), '')
            }
          }
          this.onClickIntoDetailCallBack(detailParam);
        }
      })
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_detail')))
    }
  }
}