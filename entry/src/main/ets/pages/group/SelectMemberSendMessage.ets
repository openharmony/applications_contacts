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

import SelectMemberSendMessagePresenter from '../../presenter/group/SelectMemberSendMessagePresenter';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { PhoneNumberInterface } from '../../model/type';
import { MemberInfo } from '../../model/bean/ContactVo';
import { GroupMemberListBean } from '../../model/bean/GroupMemberListBean';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import { ResourceUtil } from '../../util/ResourceUtil';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { FontScaleState } from '../../util/fontScaleState';
import { LengthMetrics, SymbolGlyphModifier, TextModifier } from '@kit.ArkUI';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'SelectMemberSendMessage';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function SelectMemberSendMessageLoader($$: Params): void {
  SelectMemberSendMessage();
}

@Component
export default struct SelectMemberSendMessage {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State mPresenter: SelectMemberSendMessagePresenter = SelectMemberSendMessagePresenter.getInstance();
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear')
    this.mPresenter.pathInfos = this.pathInfos;
    this.mPresenter.aboutToAppear()
  }

  destinationPageShow() {
    HiLog.i(TAG, 'onPageShow')
  }

  destinationPageHide() {
    HiLog.i(TAG, 'onPageCover')
    this.mPresenter.onPageHide()
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress')
  }

  @Builder
  EmptyPage() {
    Column() {
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: $r('app.string.no_select_contacts'),
      //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
      //   fullPage: true,
      //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'),
      // })
      Image($r('app.media.ic_empty_page_no_contacts'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.id_card_image_large'))
        .height($r('app.float.id_card_image_large'))
        .margin({ bottom: $r('app.float.id_card_margin_large') })

      Text($r('app.string.no_select_contacts'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_tertiary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.dialer_calllog_item_height') })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MemberListView() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Start,
    }) {
      List({ scroller: this.scroller }) {
        ListItemGroup() {
          LazyForEach(this.mPresenter.groupMemberDataSource, (item: GroupMemberListBean, index?: number |
          undefined) => {
            ListItem() {
              BatchSelectMemberItemView({
                presenter: $mPresenter,
                item: item.member,
                index: item.index,
                onContactItemClicked: (index, indexChild): void =>
                this.mPresenter.onContactItemClicked(index, indexChild),
              })
            }
          }, (item: GroupMemberListBean) => JSON.stringify(item))
        }.divider({
          strokeWidth: 0.3,
          color: $r('app.color.skin_comp_divider'),
          startMargin: 53,
        })
      }
      .width('100%')
      .height('100%')
      .margin({ bottom: $r('app.float.id_toolbar_height') })
      .backgroundColor($r('app.color.skin_background_primary'))
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
    }
    .padding({
      left: $r('app.float.id_card_margin_max'),
      right: $r('app.float.id_card_margin_max')
    })
  }

  build() {
    NavDestination() {
      Column() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
            Stack({ alignContent: Alignment.Bottom }) {
              if (this.mPresenter.groupMemberDataSource.totalCount() === 0) {
                this.EmptyPage();
              } else {
                this.MemberListView();
              }
              Row() {
                Column() {
                  SymbolGlyph($r('sys.symbol.checkmark'))
                    .fontSize($r('app.float.id_card_image_small'))
                    .fontColor([$r('app.color.skin_icon_primary')])
                    .margin({ bottom: $r('app.float.id_card_margin_sm') })
                    .opacity(this.mPresenter.selectedCount > 0 ? 1 : $r('sys.float.alpha_tertiary'))

                  Text($r('app.string.choose'))
                    .fontColor(this.mPresenter.selectedCount > 0 ? $r('app.color.skin_font_primary') : $r('app.color.skin_font_tertiary'))
                    .fontSize(DisplaySplitUtil.isHorizonSplit(this.splitStatus) ||
                    DisplaySplitUtil.isVerticalSplit(this.splitStatus) ? '10vp' : $r('sys.float.Caption_M'))
                    .fontWeight(FontWeight.Medium)
                }
                .enabled(this.mPresenter.selectedCount > 0 ? true : false)
                .width('50%')
                .height('100%')
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.mPresenter.sendMessage();
                })

                Column() {
                  SymbolGlyph(this.mPresenter.isSelectNumber ?
                    (this.mPresenter.isSelectAll ?
                    $r('sys.symbol.checkmark_square_on_square_fill') : $r('sys.symbol.checkmark_square_on_square'))
                  : $r('sys.symbol.checkmark_square_on_square_fill')
                    )
                    .fontSize($r('app.float.id_card_image_small'))
                    .fontColor(
                    [this.mPresenter.isSelectNumber ? (this.mPresenter.isSelectAll ? $r('app.color.skin_font_emphasize')
                      : $r('app.color.skin_icon_primary')) : $r('app.color.skin_font_tertiary')])

                  Text(this.mPresenter.isSelectNumber ?
                    (this.mPresenter.isSelectAll ? $r('app.string.unselect_all') : $r('app.string.select_all')) :
                  $r('app.string.unselect_all')
                    )
                    .fontColor(this.mPresenter.isSelectNumber ?
                      (this.mPresenter.isSelectAll ?
                      $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary')) :
                     $r('app.color.skin_font_tertiary')
                      )
                    .fontSize(DisplaySplitUtil.isHorizonSplit(this.splitStatus) ||
                    DisplaySplitUtil.isVerticalSplit(this.splitStatus) ? '10vp' : $r('sys.float.Caption_M'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: $r('app.float.id_card_margin_sm') })
                }
                .width('50%')
                .height('100%')
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.mPresenter.clickSelectAll();
                })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .height(this.fontSizeScale > 5 && this.isShowSmartWindow ? '60vp' : $r('app.float.id_toolbar_height'))
              .padding({
                left: $r('app.float.id_card_margin_max'),
                right: $r('app.float.id_card_margin_max')
              })
            }
          }
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.skin_background_primary'))
    }
    .backgroundColor($r('app.color.skin_background_primary'))
    .bindToScrollable([this.scroller])
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
    //   this.onBack();
    // }))
    .title(this.mPresenter.selectedCount == 0
      ? ResourceUtil.getStringByResource($r('app.string.no_select'))
      : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.mPresenter.selectedCount))
    .onBackPressed(() => {
      this.mPresenter.back();
      return true;
    })
    .onShown(() => {
      this.destinationPageShow();
    })
    .onHidden(() => {
      this.destinationPageHide();
    })
    .padding({
      top:px2vp(this.fullScreenPadding.top as number),
      bottom: px2vp(this.fullScreenPadding.bottom as number)
    })
  }

  private onBack() {
    this.mPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.mPresenter.selectedCount },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }

  @Builder
  selectMemberItemBuilder(item: GroupMemberListBean) {
    BatchSelectMemberItemView({
      presenter: $mPresenter,
      item: item.member,
      index: item.index,
      onContactItemClicked: (index, indexChild): void => this.mPresenter.onContactItemClicked(index, indexChild),
    })
  }
}

@Component
struct BatchSelectMemberItemView {
  @Link presenter: SelectMemberSendMessagePresenter;
  @State private item: MemberInfo = new MemberInfo();
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private index: number = -1;
  private onContactItemClicked: (index: number, indexChild: number) => void = () => {
  };

  aboutToAppear() {
    getPixelMapFromFile(this.item.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  build() {
    Column() {
      Row() {
        Row() {
          if (this.photoPixelMap) {
            Image(this.photoPixelMap)
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Auto)
              .borderRadius($r('app.float.id_card_image_mid'))
              .draggable(false)
          } else if (StringUtil.isEmpty(this.item.member.headChar)) {
            Image(StringUtil.isEmpty(this.item.member.portraitPath) ? $r('app.media.ic_user_portrait') : this.item.member.portraitPath)
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_image_mid'))
              .backgroundColor($r('app.color.skin_icon_fourth'))
              .draggable(false)
          } else {
            Text(this.item.member.headChar)
              .fontSize('16vp')
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.skin_icon_fourth'))
              .height($r('app.float.id_card_image_mid'))
              .width($r('app.float.id_card_image_mid'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.id_card_image_mid'))
          }
        }
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .flexShrink(0)

        Column() {
          Text(StringUtil.isEmpty(this.item.member.showName) ? this.item.member.phoneNum : this.item.member.showName)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .margin({
              start: LengthMetrics.resource($r('app.float.id_card_margin_xl')),
              bottom: LengthMetrics.resource($r('app.float.id_card_margin_sm'))
            })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)

          Text(this.item.member.phoneNumbers[0].labelName)
            .fontColor($r('app.color.skin_font_tertiary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .margin({
              start: LengthMetrics.resource($r('app.float.id_card_margin_xl'))
            })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        .flexShrink(1)
        .padding({ top: $r('app.float.id_card_margin_mid'), bottom: $r('app.float.id_card_margin_mid') })
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })

        Toggle({
          type: ToggleType.Checkbox,
          isOn: (this.item.member.phoneNumbers[0].checked == undefined) ? false :
          this.item.member.phoneNumbers[0].checked
        })
          .width(20)
          .height(20)
          .flexShrink(0)
          .hitTestBehavior(HitTestMode.None)
          .margin({
            start: LengthMetrics.resource($r('app.float.id_card_margin_max'))
          })
          .selectedColor($r('app.color.skin_comp_background_emphasize'))
          .focusable(false)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
      .onClick(() => {
        this.onContactItemClicked(this.index, 0);
      })
      .focusable(true)
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })

      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.item.member.phoneNumbers, (item: PhoneNumberInterface, index: number) => {
          ListItem() {
            if (index != 0) {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Row() {
                }
                .width($r('app.float.id_card_image_mid'))
                .height($r('app.float.id_card_image_mid'))
                .visibility(Visibility.Hidden)

                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Start,
                  justifyContent: FlexAlign.Center
                }) {
                  Text(item.labelName)
                    .fontColor($r('app.color.skin_font_tertiary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .margin({
                      start: LengthMetrics.resource($r('app.float.id_card_margin_xl'))

                    })
                }
                .layoutWeight(1)
                .flexGrow(1)
                .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })

                Toggle({
                  type: ToggleType.Checkbox,
                  isOn: (this.item.member.phoneNumbers[index as number].checked == undefined) ? false :
                  this.item.member.phoneNumbers[index as number].checked
                })
                  .width(20)
                  .height(20)
                  .flexShrink(0)
                  .enabled(true)
                  .hitTestBehavior(HitTestMode.None)
                  .margin({
                    start: LengthMetrics.resource($r('app.float.id_card_margin_max'))
                  })
                  .selectedColor($r('app.color.skin_comp_background_emphasize'))
                  .focusable(false)
              }
              .width('100%')
              .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
              .visibility(StringUtil.isEmpty(item.labelName as string) ? Visibility.None : Visibility.Visible)
              .onClick(() => {
                this.onContactItemClicked(this.index, index);
              })
              .focusable(true)
              .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
            }
          }
        }, (item: PhoneNumberInterface) => JSON.stringify(item))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .divider({
        strokeWidth: 0.3,
        color: $r('app.color.skin_comp_divider'),
        startMargin: 53,
      })
    }
    .backgroundColor($r('app.color.skin_background_primary'))
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_margin_xl')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_margin_xl')),
    })
  }
}

