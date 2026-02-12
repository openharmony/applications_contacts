/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { CustomizedParams } from '../../model/type';
import HiCarCallRecordPresenter from '../../presenter/dialer/callRecord/HiCarCallRecordPresenter';
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';
import MergedCallLog from '../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { Constants } from '../../data/Constants';
import { HiLog, StringUtil, } from '../../../../../../common';
import DotUtil from '../../util/DotUtil';
import { HiCarConstants } from '../../data/HiCarConstants';
import HiCarUtil from '../../util/HiCarUtil';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import { CallType, FeaturesType, FeaturesUtil } from '../../../../../../feature/call';
import { getHeadChar, getPixelMapFromFile } from '../../util/UserPhoto';
import LooseObject from '../../model/type/LooseObject';
import NumberMarkUtil from '../../util/NumberMarkUtil';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { CallLogService } from '../../../../../../feature/call';

const TAG = 'HiCarRecordView';
const CALL_EVENT = 'CALL_EVENT';

/**
 * 通话记录不为空时的记录列表
 */
@Component
export struct HiCarRecordView {
  private scroller: Scroller = new Scroller();
  @Link mPresenter: HiCarCallRecordPresenter;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        LazyForEach(this.mPresenter.mAllCallRecordListDataSource, (item: MergedCallLog, index: number) => {
          ListItem() {
            HiCarCallRecordItem({
              mPresenter: $mPresenter,
              item: item,
              index: index
            })
          }
          .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
          .id(`hicar_record_listItem_${index}`)
          .backgroundColor($r('app.color.skin_background_primary'))
        }, (item: MergedCallLog) => JSON.stringify(item))
      }
      .divider({
        strokeWidth: Constants.DIVIFER_HEIGHT,
        startMargin: $r('app.float.id_margin_24_hicar'),
        endMargin: HiCarUtil.getInstance().getTabContentPadding(),
        color: $r('app.color.skin_ohos_id_color_list_separator')
      })
      .width('100%')
      .height('100%')
      .padding({ left: HiCarUtil.getInstance().getTabContentPadding() })
      .flexShrink(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Auto)
    }
  }
}

/**
 * 单条通话记录组件
 */
@Reusable
@Component
struct HiCarCallRecordItem {
  private index: number = 0;
  private callParams: CustomizedParams = {
    ENC: 2,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  @Link mPresenter: HiCarCallRecordPresenter;
  @Prop item: MergedCallLog;
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;
  @StorageProp('sysMinutesTime') @Watch('updateCallRecordCreateTime') sysMinutesTime: number = -1;
  @State markType: string = this.item.markType;
  @State markCustom: string = this.item.markContent;
  @State showName: string = '';
  @State photoPixelMap: PixelMap | null = null;
  @State isPrivateNumber: boolean = false;
  @State headChar: string = '';
  @StorageLink(Constants.KEY_ACTIVE_CALL_ID) activeCallId: number = -1;
  @State imgRes?: Resource = undefined;
  @State createTime: string | Resource = '';

  updateCallRecordCreateTime() {
    HiLog.i(TAG, `updateCallRecordCreateTime`);
    if (this.item.createTimeSource && this.sysMinutesTime > 0) {
      this.createTime = CallLogService.getInstance().formatTime(this.item.createTimeSource) as string;
    }
  }

  private initShowName(): void {
    this.isPrivateNumber = false;
    if (!StringUtil.isEmpty(this.item.displayName)) {
      this.showName = this.item.displayName;
    } else if (!StringUtil.isEmpty(this.markType) && this.markType ==
    NumberMarkUtil.YELLOW_PAGE_PHONE_DESC || this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      this.showName = this.item.markContent;
    } else if (!StringUtil.isEmpty(this.item.formattedNumber)) {
      this.showName = this.item.formattedNumber;
    } else if (!StringUtil.isEmpty(this.item.phoneNumber)) {
      this.showName = this.item.phoneNumber;
    } else {
      this.isPrivateNumber = true;
      this.showName = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.unknown_phonenumber').id);
    }
  }

  // 通话记录图标记录   
  private initImageRes(): void {
    switch (this.item.callType) {
      case CallType.IN:
      case CallType.MISSED:
        this.imgRes = undefined;
        break;
      case CallType.OUT:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.arrow_up_right_video_fill') : $r('sys.symbol.phone_arrow_up_right_fill');
        break;
      case CallType.REJECTED:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.xmark_video') : $r('sys.symbol.phone_below_xmark');
        break;
    }
  }

  /**
   * 点击通话记录进行拨号，单卡直接拨号；双卡：设置了默认号码，使用默认号码；没设置默认号码，使用当前通话记录卡号进行拨号
   */
  private dial(): void {
    HiLog.i(TAG, 'Dial on hicar.');
    if (this.isPrivateNumber) {
      HiLog.i(TAG, `isPrivateNumber`);
      return;
    }
    HiCarUtil.getInstance()
      .dialClick(this.getUIContext(), this.item.phoneNumber as string, this.haveMultiSimCard, this.defaultSlot,
        this.item.simId);
    this.callParams.ENC = HiCarConstants.CONTACT_DOT_ENC_CALL_RECORDS;
    this.callParams.SLOT = (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) ? this.defaultSlot :
    this.item.simId;
    this.callParams.ISMULTISIMCARD = Number(this.haveMultiSimCard);
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  /**
   * get callLog item secondary text
   */
  private getCallLogItemSecondaryText(): string | Resource {
    if (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
      return $r('app.string.number_mark_fraud_smart_identify');
    }
    // 用户手动标记
    if (this.item.isCloudMark === 0 && !StringUtil.isEmpty(this.markType) &&
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
    } else if (this.item.isCloudMark === 1 && !StringUtil.isEmpty(this.markType) &&
      this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC && this.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC) {
        return this.item.markContent;
      }
      if (this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC) {
        return (!StringUtil.isEmpty(this.item.formattedNumber)) ? this.item.formattedNumber : this.item.phoneNumber;
      }
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().resourceManager
        .getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id) + ' | ' + ContactsGlobalThisHelper
        .GetGlobalThis().getDefaultUIContext().resourceManager
        .getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'), this.item.markCount);
    } else if (FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features)) {
      return $r('app.string.video');
    } else if (this.item.numberLocation && this.item.numberLocation !== 'N') {
      return this.item.numberLocation as string;
    } else {
      return $r('app.string.unknown');
    }
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarCallRecordItem aboutToAppear.')
    this.createTime = this.item.createTime;
    this.initImageRes();
    this.initShowName();
    getPixelMapFromFile(this.item.quickSearchKey, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    });
    this.headChar = getHeadChar(this.showName);
  }

  aboutToReuse(params: LooseObject): void {
    this.item = params.item;
    this.markType = this.item.markType;
    this.markCustom = this.item.markContent;
    this.index = params.index;
    this.initImageRes();
    this.initShowName();
    getPixelMapFromFile(this.item.quickSearchKey, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
    this.headChar = getHeadChar(this.showName);
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('app.color.skin_background_primary'))
  }

  build() {
    Row() {
      Row() {
        Column() {
          SymbolGlyph(this.imgRes == undefined ? $r('sys.symbol.xmark_video') : this.imgRes)
            .visibility(this.imgRes == undefined ? Visibility.Hidden : Visibility.Visible)
            .fontSize($r('app.float.dialer_common_small_margin'))
            .fontColor([$r('app.color.skin_icon_tertiary')])
        }
        .width($r('app.float.dialer_common_small_margin'))
        .margin({
          right: $r('app.float.id_card_margin_large'),
          top: $r('app.float.id_card_item_margin_top'),
        })

        Column() {
          Row() {
            Text(this.showName)
              .fontSize($r('app.float.id_text_size_body1_hicar'))
              .fontWeight(FontWeight.Medium)
              .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
              $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .flexShrink(1)

            if (this.item.count != 1) {
              Text('(' + this.item.count + ')')
                .fontSize($r('app.float.id_text_size_body1_hicar'))
                .fontColor((this.item.callType == 3 || this.item.callType == 5) ?
                $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
                .fontWeight(FontWeight.Medium)
                .padding({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })
                .maxLines(1)
            }
          }
          .width('100%')
          .height($r('app.float.id_groupList_lineHeight_xxl'))
          .margin({
            top: $r('sys.float.padding_level5'),
          })

          Row() { //卡判断
            if (this.haveMultiSimCard) {
              SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
                .fontSize($r('app.float.id_text_size_body3_hicar'))
                .fontColor([$r('app.color.skin_icon_tertiary')])
                .margin({
                  right: $r('app.float.id_card_margin_mid'),
                  top: $r('sys.float.padding_level1'),
                })
            }

            if (this.item.isSatellite === 1) {
              SymbolGlyph($r('sys.symbol.satellite'))
                .fontSize(10)
                .maxFontScale(1)  //不放大
                .fontColor([$r('app.color.skin_white')])
                .padding({
                  left: 2,
                  top: 1,
                  right: 1,
                  bottom: 2
                })
                .backgroundImage($r('app.media.satellite_backgroud_img'))
                .backgroundColor($r('sys.color.ohos_id_color_alert'))
                .margin({
                  right: $r('app.float.id_card_margin_mid'),
                  top: '2vp',
                })
                .flexShrink(0)
                .borderRadius($r('sys.float.Body_S'))
            }
            if (this.item.isSatellite === 2) { //通话记录中渲染风信子图标
              Image($r('app.media.hyacinth_call_log'))
                .draggable(false)
                .margin({
                  right: $r('app.float.id_card_margin_mid'),
                  top: '2vp',
                })
                .size({ width: 10, height: 10 })
                .backgroundImage($r('app.media.satellite_backgroud_img'))
                .backgroundImageSize({ width: 12, height: 12 })
                .backgroundColor($r('sys.color.ohos_id_color_alert'))
                .borderRadius($r('sys.float.Body_S'))
            }

            if (StringUtil.isEmpty(this.item.displayName)) {
              Text(this.getCallLogItemSecondaryText())
                .fontSize($r('app.float.id_text_size_body2_hicar'))
                .fontColor($r('app.color.skin_font_secondary'))
                .margin({ top: $r('app.float.id_card_margin_sm') })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            } else {
              Text(FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ? $r('app.string.video') :
                (this.item.numberLocation && this.item.numberLocation !== 'N') ? this.item.numberLocation as string :
                  this.item.phoneNumber as string)
                .fontSize($r('app.float.id_text_size_body2_hicar'))
                .fontColor($r('app.color.skin_font_secondary'))
                .margin({ top: $r('app.float.id_card_margin_sm') })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
          .height($r('app.float.id_groupList_lineHeight_xl'))
          .margin({
            top: $r('sys.float.padding_level1'),
          })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ right: $r('app.float.id_card_margin_large') })
        .height($r('app.float.id_item_height_max'))

        Row() {
          Text(this.createTime)
            .fontSize($r('app.float.id_text_size_body2_hicar'))
            .margin({ top: $r('app.float.id_card_margin_sm') })
            .fontColor($r('app.color.skin_font_secondary'))
            .textAlign(TextAlign.End)
        }
        .height($r('app.float.id_item_height_max'))
      }
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({ right: HiCarUtil.getInstance().getTabContentPadding() })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles
    })
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    .onClick(() => {
      this.dial();
    })
  }
}