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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { BatchSelectContact, PhoneNumberInterface } from '../../model/type';
import { ContactVo } from '../../model/bean/ContactVo';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import { ResourceUtil } from '../../util/ResourceUtil';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { FontScaleState } from '../../util/fontScaleState';
import {
  DividerModifier,
  LengthMetrics,
  SymbolGlyphModifier,
  TextModifier,
  ToolBar,
  ItemState,
  ToolBarModifier,
  ToolBarOptions,
  SubHeader,
  ColorMetrics
} from '@kit.ArkUI';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import IntelligenceGroupSelectMemSendMsgPresenter, {
  AddSelectMemSendMsgUpdateToolbar
} from '../../presenter/intelligencegroup/IntelligenceGroupSelectMemSendMsgPresenter';
import { emitter } from '@kit.BasicServicesKit';
import { AlphabetIndexerPage } from '../contacts/alphabetindex/AlphabetIndexerPage';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AlphabetIndexerPresenter from '../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import MockResource from '../../model/bean/MockResource';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import LooseObject from '../../model/type/LooseObject';
import { ObjectUtil } from '../../../../../../feature/call/oh_modules/common';
import { Constants } from '../../data/Constants';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import IntelligenceGroupPhoneNumberContactItemSendMsg
  from '../../component/intelligencegroup/IntelligenceGroupPhoneNumberContactItemSendMsg';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { IntelligenceGroupAlphabetIndexerPage } from '../contacts/alphabetindex/IntelligenceGroupAlphabetIndexerPage';

const TAG = 'IntelligenceGroupSelectMemSendMsg';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function IntelligenceGroupSelectMemSendMsgLoader($$: Params): void {
  IntelligenceGroupSelectMemSendMsg();
}

@Component
export default struct IntelligenceGroupSelectMemSendMsg {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State private showSubHeaderIndex: Number = 0;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State mPresenter: IntelligenceGroupSelectMemSendMsgPresenter =
    IntelligenceGroupSelectMemSendMsgPresenter.getInstance();
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State toolbarList: ToolBarOptions = new ToolBarOptions();
  @State categoryGroupType: string = '0';
  @State intelliGroupName: string = Constants.EMTPY_STR;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 判断是否数据查询完成,查询完再渲染
  @State isFinishForMsg: boolean = false;
  // 选中的联系人个数,用于控制发送短信按钮的激活状态
  @State selectedCount: number = 0;
  @State lastSelectedCount: number = 0;
  private scroller: Scroller = new Scroller();
  scrollReachEnd: boolean = false;
  isFirstListItem = true;
  private isPC: boolean = EnvironmentProp.isPC();
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(48))
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .padding(LengthMetrics.vp(0));
  //接口回调
  @State updateToolbarInterface: AddSelectMemSendMsgUpdateToolbar = {
    updateToolbar: (): void => {
      HiLog.i(TAG, `updateToolbar :${this.mPresenter.selectedCount},${this.lastSelectedCount},${this.selectedCount}`);
      this.isFinishForMsg = true;
      this.selectedCount = this.mPresenter.selectedCount;

      if ((this.lastSelectedCount === 0 && this.selectedCount > 0) || this.selectedCount === 0) {
        // this.menuItems = [
        //   {
        //     content: {
        //       label: $r('app.string.accessibility_done'),
        //       icon: $r('sys.symbol.checkmark'),
        //       isEnabled: this.selectedCount > 0 ? true : false,
        //       action: () => {
        //         this.mPresenter.sendMessage();
        //       }
        //     }
        //   }
        // ];
      }

      this.lastSelectedCount = this.selectedCount;
      if (this.mPresenter.contactsTotal) {
        this.updateToolbar();
      }
    }
  };

  // hdsnavigation右侧发送短信按钮
  // private menuItems: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.accessibility_done'),
  //       icon: $r('sys.symbol.checkmark'),
  //       isEnabled: false,
  //       action: () => {
  //         this.mPresenter.sendMessage();
  //       }
  //     }
  //   }
  // ];

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear')
    this.mPresenter.pathInfos = this.pathInfos;
    let navParam: LooseObject = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as LooseObject;
    if (!ObjectUtil.isEmpty(navParam)) {
      this.intelliGroupName = navParam.groupName ?? Constants.EMTPY_STR;
      this.categoryGroupType = navParam.categoryGroupType;
      this.mPresenter.categoryIndex = navParam.categoryIndex;
      this.mPresenter.groupName = this.intelliGroupName;
      this.mPresenter.categoryGroupType = this.categoryGroupType;
    }
    this.mPresenter.aboutToAppear();
    this.mPresenter.setUpdateToolbar(this.updateToolbarInterface);
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.mPresenter.resetData()
  }

  updateToolbar() {
    HiLog.i(TAG, 'updateToolbar : ' + this.mPresenter.selectedCount);
    let isSelectAll =
      (this.mPresenter.contactsCount === this.mPresenter.contactsTotal) && this.mPresenter.contactsCount != 0
    this.toolbarList = [{
      content: this.mPresenter.allSelectMessage,
      textColor: isSelectAll ? $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary'),
      activatedTextColor: isSelectAll ? $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier(this.mPresenter.icSelectAll).fontColor([isSelectAll ?
        $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary')]),
        activated: new SymbolGlyphModifier(this.mPresenter.icSelectAll).fontColor([isSelectAll ?
        $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary')]),
      },
      state: ItemState.ACTIVATE,
      action: () => {
        this.mPresenter.clickSelectAll();
      },
    }]
  }

  @Builder
  TitleGuide() {
    if (this.mPresenter.contactsTotal) {
      Row() {
        if (this.isPC) {
          Button() {
            SymbolGlyph(this.mPresenter.isSelectAll ?
            $r('sys.symbol.checkmark_square_on_square_fill') : $r('sys.symbol.checkmark_square_on_square'))
              .fontSize($r('app.float.id_card_image_small'))
              .fontColor([this.mPresenter.isSelectAll ? $r('app.color.skin_font_emphasize')
                : $r('app.color.skin_icon_primary')])
          }
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility,
              this.mPresenter.isSelectAll ? $r('app.string.select_all') : $r('app.string.unselect_all')))
          .type(ButtonType.Normal)
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .stateEffect(true)
          .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
          .margin({
            end: LengthMetrics.resource($r('sys.float.padding_level4'))
          })
          .onClick(() => {
            this.mPresenter.clickSelectAll();
          })
        }

        Button() {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .opacity(this.mPresenter.selectedCount > 0 ? 1 : $r('sys.float.alpha_tertiary'))
        .type(ButtonType.Circle)
        .borderRadius(0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
        .id('IntelligenceGroup_sendMsg_btn')
        .onClick(() => {
          this.mPresenter.sendMessage();
        })
        .enabled(this.mPresenter.selectedCount > 0 ? true : false)
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .height($r('app.float.id_item_height_large'))
      .padding({
        end: this.isPC ? LengthMetrics.vp(144) : LengthMetrics.resource(this.spaceLR),
      })
      .margin({
        left: this.isPC ? '8vp' : ((this.curBp === 'lg') ? '24vp' : undefined)
      })
    }
  }

  @Builder
  ContactMsgEmptyPage() {
    Column() {
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: $r('app.string.no_select_contacts'),
      //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
      //   fullPage: true,
      //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('sys.color.comp_background_gray'),
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

  build() {
    if (this.isPC) {
      NavDestination() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
              // 联系人列表
              if (this.mPresenter.contactsTotal > 0 && this.isFinishForMsg) {
                IntelligenceGroupContactsList({
                  presenter: $mPresenter
                })
                  .layoutWeight(1)
              } else if (this.mPresenter.contactsTotal === 0 && this.isFinishForMsg) {
                this.ContactMsgEmptyPage();
              }
            }
            .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .onBreakpointChange((breakpoint: string) => {
          this.curBp = breakpoint
        })
      }
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .title(this.mPresenter.selectedCount == 0
        ? ResourceUtil.getStringByResource($r('app.string.no_select'))
        : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.mPresenter.selectedCount),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
            ((this.curBp === 'lg') ? LengthMetrics.vp(24) : undefined)
        })
      .menus(this.TitleGuide())
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number),
      })
      .onShown(() => {
        this.mPresenter.setPageShow();
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
    } else {
      NavDestination() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
              // 联系人列表
              if (this.mPresenter.contactsTotal > 0 && this.isFinishForMsg) {
                IntelligenceGroupContactsList({
                  presenter: $mPresenter,
                  scroller: this.scroller
                })
                  .layoutWeight(1)
              } else if (this.mPresenter.contactsTotal === 0 && this.isFinishForMsg) {
                this.ContactMsgEmptyPage();
              }

              GridRow({ columns: { sm: 4, md: 8, lg: 8 }, gutter: { x: 12, y: 0 } }) {
                GridCol({ span: { sm: 4, md: 8, lg: 6 }, offset: { sm: 0, md: 0, lg: 1 } }) {
                  // 判断是全选状态 按钮变蓝.
                  WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
                    ToolBar({
                      toolBarModifier: this.toolBarModifier,
                      dividerModifier: new DividerModifier().height(0),
                      toolBarList: this.toolbarList,
                    })
                      .width('100%')
                      .height($r('app.float.id_item_height_mid')) // 不显示全选，也需要占用此部分空间，否则tab切换，会有上下移动样式问题
                  }
                }
              }
              .margin({
                left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
                right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right')
              })
            }
            .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .onBreakpointChange((breakpoint: string) => {
          this.curBp = breakpoint
        })
      }
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.menuItems, () => {
      //   this.onBack();
      // }))
      .title(this.mPresenter.selectedCount == 0
        ? ResourceUtil.getStringByResource($r('app.string.no_select'))
        : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.mPresenter.selectedCount),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
            ((this.curBp === 'lg') ? LengthMetrics.vp(24) : undefined)
        })
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .padding({
        top: !this.isPC ? px2vp(this.fullScreenPadding.top as number) : 0,
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
      .onShown(() => {
        this.mPresenter.setPageShow();
      })
      .menus(this.TitleGuide())
      .bindToScrollable([this.scroller])
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
  }

  private onBack() {
    HiLog.i(TAG, 'onBack');
    this.pathInfos?.pop();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.mPresenter.selectedCount },
  //     backIcon: { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }
}

@Component
struct IntelligenceGroupContactsList {
  @Link presenter: IntelligenceGroupSelectMemSendMsgPresenter;
  // Scrolling Parameters
  private scroller: Scroller = new Scroller();
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = false;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;
  @State isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('sceillOnlenth') sceillOnlenth: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        List({ initialIndex: this.presenter.initialIndex, scroller: this.scroller }) {
            LazyForEach(this.presenter.contactsSource, (item: BatchSelectContact) => {
              ListItem() {
                SelectContactItemView({
                  item: item.contact,
                  index: item.index,
                  onContactItemClicked: (index, indexChild): void =>
                  this.presenter.onContactItemClicked(index, indexChild),
                  showIndex: item.showIndex,
                  showDivifer: item.showDivifer
                })
              }
              .width('100%')
            }, (item: BatchSelectContact) => JSON.stringify(item))
        }

        .width('100%')
        .padding({ right: this.isShowSmartWindow ? $r('app.float.id_card_margin_xxl_minus') : 0 })
        .height('100%')
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.presenter.sceillOnlenth = ( lastIndex - firstIndex) + 1
          this.presenter.resetInitialIndex(firstIndex);
          if (!this.isAlphabetClicked && this.dragList) {
            this.alphabetSelected = this.alphabetIndexPresenter.getAlphabetSelected(firstIndex);
          }
        })
        .onScrollStart(() => {
          emitter.emit(AlphabetIndexerPage.innerEvent);
          this.dragList = true;
          this.isAlphabetClicked = false;
        })
        .onScrollStop(() => {
          this.isAlphabetClicked = true;
          this.dragList = false;
        })
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: this.isPC ? 0 : '94' })

        if (DisplaySplitUtil.isShowIndex(this.splitStatus)) {
          IntelligenceGroupAlphabetIndexerPage({
            scroller: this.scroller,
            presenter: $alphabetIndexPresenter,
            selected: this.alphabetSelected,
            isClicked: $isAlphabetClicked,
            isAutoCollapse: true,
            scrollIndexOffset: false
          })
            .margin({
              top: this.isPC ? '16vp' : '110vp',
              bottom: '10%',
              right: this.isPC ? '4vp' : '0vp',
              left: '4vp'
            })
            .visibility((this.presenter.inputKeyword !== '' || this.isShowSmartWindow)
              ? Visibility.None : Visibility.Visible)
        }
      }
    }
    .width('100%')
  }
}

@Component
export struct SelectContactItemView {
  @State private single: boolean = false;
  @State private item: ContactVo =
    new ContactVo(Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR,
      Constants.EMTPY_STR, Constants.EMTPY_STR, new MockResource(), false, Constants.EMTPY_STR, Constants.EMTPY_STR,
      Constants.EMTPY_STR);
  private onContactItemClicked: (index: number, indexChild: number) => void = () => {
  };
  private onSingleContactItemClick: Function = () => {
  };
  private index: number = -1;
  @State private showIndex: boolean = false;
  @State private showDivifer: boolean = false;
  @State photoPixelMap: PixelMap | null = null;
  @State isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State isCbChecked: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State isItemHover: boolean = false;
  @State isPhoneNumberItemHover: boolean = false;
  @State checked: boolean = false;
  private selectCallBack: Callback<emitter.EventData> | undefined = undefined;

  aboutToAppear() {
    getPixelMapFromFile(this.item.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res
    })
    this.selectCallBack = () => {
        this.checked = (this.item.phoneNumbers[0].checked == undefined) ? false :
          this.item.phoneNumbers[0].checked;
    }
    emitter.on(IntelligenceGroupSelectMemSendMsgPresenter.INTELLIGENCE_GROUP_SELECT_SENDMSG_CHECKED,
      this.selectCallBack);
    this.checked = (this.item.phoneNumbers[0].checked == undefined) ? false :
      this.item.phoneNumbers[0].checked;
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .width('100%')
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.showIndex) {
          SubHeader({
            secondaryTitle: this.item.namePrefix,
            secondaryTitleModifier: this.isThemeActive ?
            new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined,
            contentPadding: {
              start: this.isPC ? LengthMetrics.vp(-16) : LengthMetrics.vp(0),
              end: LengthMetrics.vp(-16)
            }
          })
        }
        Row() {
          Row() {
            if (this.photoPixelMap) {
              Image(this.photoPixelMap)
                .width($r('app.float.id_card_image_mid'))
                .height($r('app.float.id_card_image_mid'))
                .objectFit(ImageFit.Auto)
                .borderRadius($r('app.float.id_card_image_mid'))
                .draggable(false)
                .onError(() => {
                  this.photoPixelMap = null
                })
            } else if (StringUtil.isEmpty(this.item.headChar)) {
              Image(StringUtil.isEmpty(this.item.portraitPath) ? $r('app.media.ic_user_portrait') :
              this.item.portraitPath)
                .width($r('app.float.id_card_image_mid'))
                .height($r('app.float.id_card_image_mid'))
                .objectFit(ImageFit.Auto)
                .borderRadius($r('app.float.id_card_image_mid'))
                .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
                .backgroundColor(StringUtil.isEmpty(this.item.portraitPath) ?
                $r('app.color.skin_ohos_id_color_fourth') :
                Color.Transparent)
                .draggable(false)
            } else {
              Text(this.item.headChar)
                .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '16vp')
                .fontColor($r('app.color.skin_font_on_primary'))
                .backgroundColor($r('app.color.skin_icon_fourth'))
                .height($r('app.float.id_card_image_mid'))
                .width($r('app.float.id_card_image_mid'))
                .textAlign(TextAlign.Center)
                .borderRadius($r('app.float.id_card_image_mid'))
                .accessibilityLevel('no')
            }
          }
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .margin({
            end: this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(16)
          })

          Column() {
            Text(this.item.title)
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              .constraintSize({ minHeight: '21vp' })
              .fontFamily('HarmonyHeiTi')
              .margin({
                bottom: $r('sys.float.padding_level1')
              })

          Text(this.item.phoneNumbers[0].labelName)
            .fontColor($r('app.color.skin_font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            .constraintSize({ minHeight: '19vp' })
        }
        .margin({
          right: $r('sys.float.padding_level4')
        })
        .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)

          Toggle({
            type: ToggleType.Checkbox,
            isOn: this.checked
          })
            .width('20vp')
            .height('20vp')
            .hitTestBehavior(HitTestMode.None)
            .margin({
              end: LengthMetrics.vp(2),
              start: LengthMetrics.vp(2),
              top: LengthMetrics.vp(2),
              bottom: LengthMetrics.vp(2)
            })
            .accessibilityLevel('no')
            .id('SelectContactItemViewToggle')
            .selectedColor($r('app.color.skin_comp_background_emphasize'))
            .visibility(!this.single ? Visibility.Visible : Visibility.None)
            .onChange(()=>{
              AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.checked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
                : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
            })
        }
        .padding({
          top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
          FontScaleState.fetchSeniorListSpace(),
          bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_width_8') :
          FontScaleState.fetchSeniorListSpace(),
          start: this.isPC ? LengthMetrics.vp(24) : LengthMetrics.vp(16),
          end: LengthMetrics.vp(32)
        })
        .accessibilityChecked(this.checked)
        .accessibilityRole(AccessibilityRoleType.CHECKBOX)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
        })
        .margin({
          start: this.isPC ? LengthMetrics.vp(16) : undefined,
          end: this.isPC ? LengthMetrics.vp(16) : undefined
        })
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
        .focusBox({
          margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
          strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
        })
        .onClick(() => {
          if (!this.single) {
            this.onContactItemClicked(this.index, 0);
          } else {
            this.onSingleContactItemClick(this.item.phoneNumbers[0].phoneNumber,
              this.item.showName, this.item.phoneNumbers[0].dataId);
          }
        })
        .focusable(true)

        List({ space: 0, initialIndex: 0 }) {
          ForEach(this.item.phoneNumbers, (phoneNumberItem: PhoneNumberInterface, index: number) => {
            ListItem() {
              if (index != 0) {
                IntelligenceGroupPhoneNumberContactItemSendMsg({
                  contactItem: $item,
                  contactIndex: this.index,
                  phoneNumberIndex: index,
                  labelName: phoneNumberItem.labelName,
                  onContactItemClicked: this.onContactItemClicked
                })
              }
            }
          }, (item: PhoneNumberInterface) => JSON.stringify(item))
        }
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .divider(((this.item.phoneNumbers.length - 1) === this.index) ? null : {
          strokeWidth: 0.3,
          color: $r('app.color.skin_comp_divider'),
          startMargin: 72,
          endMargin: 32
        })

      }
      .padding({
        bottom: '1px'
      })

      if (this.showDivifer) {
        this.ItemDivider()
      }
    }
  }

  @Builder
  ItemDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .strokeWidth('1px')
      .margin({
        left: '72vp',
        right: '32vp',
      })
  }
}
