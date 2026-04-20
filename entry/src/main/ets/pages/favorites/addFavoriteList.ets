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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import AlphabetIndexerPresenter from '../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import { AlphabetIndexerPage } from '../contacts/alphabetindex/AlphabetIndexerPage';
import { BatchSelectContact, CustomizedParams, SelectContactParams } from '../../model/type';
import { ContactVo } from '../../model/bean/ContactVo';
import AddFavoriteListPresenter, {
  AddFavoriteUpdateToolbar,
  PageType
} from '../../presenter/favorite/AddFavoriteListPresenter';
import FavoriteListPresenter from '../../presenter/favorite/FavoriteListPresenter';
import emitter from '@ohos.events.emitter';
import DotUtil from '../../util/DotUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import MockResource from '../../model/bean/MockResource';
import { FontScaleState } from '../../util/fontScaleState';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { ToolBar, ToolBarOptions, SymbolGlyphModifier, LengthMetrics } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { TextModifier } from '@kit.ArkUI';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import EmitterConstant from '../../data/EmitterConstant';
import { ToolBarModifier } from '@ohos.arkui.advanced.ToolBar';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { SlidingMultipleSelectionsUtil } from '../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { GlobalContext } from '../../util/GlobalContext';

const TAG = 'AddFavoriteList';
const FAVORITE_ADD_CONTACT_EVENT = 'FAVORITE_ADD_CONTACT_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

enum ItemState {
  ENABLE = 1, //工具栏子项为正常可点击状态。
  DISABLE = 2, //工具栏子项为不可点击状态。
  ACTIVATE = 3, //工具栏子项为激活状态，可点击。
}

@Builder
export function AddFavoriteListLoader($$: Params): void {
  AddFavoriteList();
}

/**
 * Selecting a contact list by SMS
 */
@Component
export default struct AddFavoriteList {
  // path parameter
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State mPresenter: AddFavoriteListPresenter = AddFavoriteListPresenter.getInstance();
  @State curBp: string = 'sm';
  @State mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @State toolbarList: ToolBarOptions = new ToolBarOptions();
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(48)).backgroundColor(Color.Transparent).stateEffect(true);
  @State dividerModifier: DividerModifier = new DividerModifier().height(0);
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  //接口回调
  @State updateToolbarInterface: AddFavoriteUpdateToolbar = {
    updateToolbar: (): void => {
      this.updateToolbar();
    }
  };
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  addFavoriteParams: CustomizedParams = {
    ISSELECT: 0,
    ISADD: 1
  };

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear')
    GlobalContext.getContext().setObject('scroller', this.scroller);
    this.mPresenter.initNavPaths(this.pathInfos);
    let obj: SelectContactParams = this.pathInfos?.getParamByIndex(this.pathInfos?.size() - 1) as SelectContactParams;

    if (obj) {
      if (obj.addFavorite !== undefined) {
        this.mPresenter.pageType = PageType.Favorite;
      }
      if (obj.pageTag == 'groupListDetail') {
        this.mPresenter.pageType = PageType.Group;
        if (obj.groupId) {
          this.mPresenter.groupId = obj.groupId;
        }
      }
    }
    //加载toolbar。
    this.mPresenter.setUpdateToolbar(this.updateToolbarInterface);
    this.updateToolbar();
    HiLog.i(TAG, 'pageType : ' + this.mPresenter.pageType);
    this.mPresenter.aboutToAppear()
  }

  updateToolbar() {
    HiLog.i(TAG, 'updateToolbar : ' + this.mPresenter.selectCount);
    this.toolbarList = [{
      content: this.mPresenter.addMessage,
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      action: () => {
        this.onClickToolBar();
      },
      state: this.mPresenter.selectCount > 0 ? ItemState.ENABLE : ItemState.DISABLE
    }, {
      content: this.mPresenter.allSelectMessage,
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier(this.mPresenter.icSelectAll).fontColor([$r('app.color.skin_font_primary')]),
        activated: new SymbolGlyphModifier(this.mPresenter.icSelectAll).fontColor([$r('app.color.skin_icon_emphasize')]),
      },
      state: ItemState.ACTIVATE,
      action: () => {
        this.mPresenter.clickSelectAll();
      },
    }]
  }

  onClickToolBar() {
    if (this.mPresenter.pageType === PageType.Favorite) {
      // 联系人打点--收藏联系人添加
      if (this.mPresenter.selectCount == this.mPresenter.contactsTotal) {
        this.addFavoriteParams.ISSELECT = 2;
      } else if (this.mPresenter.selectCount > 1) {
        this.addFavoriteParams.ISSELECT = 1;
      } else if (this.mPresenter.selectCount === 1) {
        this.addFavoriteParams.ISSELECT = 0;
      }
      this.addFavoriteParams.ISADD = 1;
      DotUtil.getInstance().contactDot(this.addFavoriteParams, FAVORITE_ADD_CONTACT_EVENT);
      this.mPresenter.addFavoriteContacts();
      this.mFavoriteListPresenter.setPageShow(true);
    } else if (this.mPresenter.pageType === PageType.Group) {
      this.mPresenter.addGroupContacts();
    }
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear')
    GlobalContext.getContext().setObject('scroller', null);
    this.mPresenter.aboutToDisappear()
    this.mPresenter.resetInitialIndex(0)
  }

  destinationPageShow() {
    HiLog.i(TAG, 'onPageShow')
    this.mPresenter.onPageShow()
  }

  destinationPageHide() {
    HiLog.i(TAG, 'onPageCover')
    this.mPresenter.onPageHide()
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress')
    this.mPresenter.backCancel();
    this.mPresenter.checkedStatus.clear();
    return true;
  }

  @Builder
  PCMenu() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, this.mPresenter.addMessage))
      .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
      .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .margin({
        end: LengthMetrics.resource($r('sys.float.padding_level4'))
      })
      .enabled(this.mPresenter.selectCount > 0)
      .onClick(() => {
        this.onClickToolBar();
      })

      Button() {
        SymbolGlyph(this.mPresenter.icSelectAll)
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor(this.mPresenter.selectCount === this.mPresenter.contactsTotal ?
            [$r('app.color.skin_icon_emphasize')] : [$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, this.mPresenter.allSelectMessage))
      .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
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
    .height($r('app.float.id_item_height_large'))
    .width('120vp')
    .alignItems(VerticalAlign.Center)
    .padding({ end: LengthMetrics.vp(232) })
  }

  build() {
    if (this.isPC) {
      NavDestination() {
        this.addFavoriteListBuilder()
      }
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .title(this.mPresenter.selectCount == 0
        ? ResourceUtil.getStringByResource($r('app.string.no_select'))
        : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.mPresenter.selectCount),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: LengthMetrics.vp(16)
        })
      .onShown(() => {
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.destinationPageHide();
      })
      .menus(this.PCMenu())
      .onBackPressed(() => {
        if (ArrayUtil.isEmpty<ContactVo>(this.mPresenter.contactsList)) {
          //联系人打点--出现没有联系人页面时点击X
          this.addFavoriteParams.ISSELECT = -1;
        } else if (this.mPresenter.selectCount == this.mPresenter.contactsTotal) {
          this.addFavoriteParams.ISSELECT = 2;
        } else if (this.mPresenter.selectCount > 1) {
          this.addFavoriteParams.ISSELECT = 1;
        } else if (this.mPresenter.selectCount === 1) {
          this.addFavoriteParams.ISSELECT = 0;
        } else {
          this.addFavoriteParams.ISSELECT = -1;
        }
        this.addFavoriteParams.ISADD = 0;
        DotUtil.getInstance().contactDot(this.addFavoriteParams, FAVORITE_ADD_CONTACT_EVENT);
        return this.destinationBackPress();
      })
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number),
      })
      .backgroundColor($r('app.color.skin_background_primary'))
    } else {
      NavDestination() {
          this.addFavoriteListBuilder()
      }
      .bindToScrollable([this.scroller])
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.onBack();
      // }))
      .title(this.mPresenter.selectCount == 0
        ? ResourceUtil.getStringByResource($r('app.string.no_select'))
        : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.mPresenter.selectCount))
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .onShown(() => {
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.destinationPageHide();
      })
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: this.isPC?0:(this.fullScreenPadding.bottom as  number<50?50:px2vp(this.fullScreenPadding.bottom as number)),
      })
      .backgroundColor($r('app.color.skin_background_primary'))
    }
  }


  @Builder
  addFavoriteListBuilder() {
    // 空列表
    if (ArrayUtil.isEmpty<ContactVo>(this.mPresenter.contactsList)) {
      NoContactsEmptyView();
    } else {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
            // 联系人列表
            ContactsList({
              presenter: $mPresenter
            })
              .layoutWeight(1);


            if (!this.isPC) {
              // 判断是全选状态 按钮变蓝.
              WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
                ToolBar({
                  toolBarModifier: this.toolBarModifier,
                  dividerModifier: new DividerModifier().height(0),
                  activateIndex: this.mPresenter.selectCount === this.mPresenter.contactsTotal ? 1 : 0,
                  toolBarList: this.toolbarList,
                })
                  .width('100%')
                  .height($r('app.float.id_item_height_mid')) // 不显示全选，也需要占用此部分空间，否则tab切换，会有上下移动样式问题
                  .visibility(this.mPresenter.contactsList.length <= 0 ? Visibility.Hidden : Visibility.Visible);
              };
            }
          }
          .height('100%');
        };
      }
      .width('100%')
      .height('100%')
      .onBreakpointChange((breakpoint: string) => {
        this.curBp = breakpoint;
      });
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.mPresenter.selectCount },
  //     backIcon: { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }

  private onBack(): boolean {
    if (ArrayUtil.isEmpty<ContactVo>(this.mPresenter.contactsList)) {
      //联系人打点--出现没有联系人页面时点击X
      this.addFavoriteParams.ISSELECT = -1;
    } else if (this.mPresenter.selectCount == this.mPresenter.contactsTotal) {
      this.addFavoriteParams.ISSELECT = 2;
    } else if (this.mPresenter.selectCount > 1) {
      this.addFavoriteParams.ISSELECT = 1;
    } else if (this.mPresenter.selectCount === 1) {
      this.addFavoriteParams.ISSELECT = 0;
    } else {
      this.addFavoriteParams.ISSELECT = -1;
    }
    this.addFavoriteParams.ISADD = 0;
    DotUtil.getInstance().contactDot(this.addFavoriteParams, FAVORITE_ADD_CONTACT_EVENT);
    return this.destinationBackPress();
  }
}

@Component
struct ContactsList {
  @Link presenter: AddFavoriteListPresenter;
  // Scrolling Parameters
  private scroller: Scroller = GlobalContext.getContext().getObject('scroller') as Scroller;
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = false;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;
  @State isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State preListItemNum: number = 0;
  @StorageLink('sceillOnlenth') sceillOnlenth: number = 0;
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        List({ initialIndex: this.presenter.initialIndex, scroller: this.scroller }) {
          LazyForEach(this.presenter.contactsSource, (item: BatchSelectContact) => {
            ListItem() {
              AddFavoriteItemView({
                presenter: this.presenter,
                item: item.contact,
                index: item.index,
                showIndex: item.showIndex,
                showDivifer: item.showDivifer
              })
            }
          }, (item: BatchSelectContact) => JSON.stringify(item))
        }
        .width('100%')
        .padding({ right: this.isShowSmartWindow ? $r('app.float.id_card_margin_xxl_minus') : 0 })
        .height('100%')
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
          this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;

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
        .gesture(PanGesture({ direction: PanDirection.Vertical })
          .onActionStart((event: GestureEvent) => {
            for (let i = 0; i < this.presenter.contactsSource.totalCount(); ++i) {
              let item = this.presenter.contactsSource.getData(i);
              let selectStatus = this.presenter.checkedStatus.has(item?.contact.contactId);
              this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
              this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
            }
            this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
          })
          .onActionUpdate((event: GestureEvent) => {
            let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
              let curSelectStatus = false;
              if (index >= 0) {
                let item = this.presenter.contactsSource.getData(index);
                curSelectStatus = this.presenter.checkedStatus.has(item?.contact.contactId);
              }
              return curSelectStatus;
            });
            updateIndexes.forEach((index) => {
              if (index >= 0) {
                let item = this.presenter.contactsSource.getData(index);
                this.presenter.itemOnClick(item?.contact, index);
              }
            })
          })
          .onActionEnd(() => {
            this.slidingMultipleSelectionsUtil.onActionEnd();
          })
          .onActionCancel(() => {
            this.slidingMultipleSelectionsUtil.onActionEnd();
          }),
          GestureMask.Normal
        )
        .onGestureRecognizerJudgeBegin(
          (event: BaseGestureEvent, current: GestureRecognizer, recognizers: Array<GestureRecognizer>) => {
            return this.slidingMultipleSelectionsUtil.onGestureRecognizerJudgeBegin(event.fingerList[0], current);
          })
        .onAreaChange((oldValue: Area, newValue: Area)=>{
          this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number
          this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
          this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
        })

        if (DisplaySplitUtil.isShowIndex(this.splitStatus)) {
          AlphabetIndexerPage({
            scroller: this.scroller,
            selected: this.alphabetSelected, isClicked: $isAlphabetClicked,
            isAutoCollapse:true,
            preIndexNum: this.preListItemNum,
            scrollIndexOffset: false,
            presenter:this.presenter.alphabetIndexPresenter
          })
            .margin({ top: '118vp', bottom: '10%' })
            .visibility(this.isShowSmartWindow ? Visibility.None : Visibility.Visible)
        }
      }
    }
    .width('100%')
  }
}

@Component
export struct AddFavoriteItemView {
  @Link presenter: AddFavoriteListPresenter;
  @Prop item: ContactVo;
  @Prop index: number;
  @Prop showIndex: boolean = false;
  @Prop showDivifer: boolean = false;
  @State photoPixelMap: PixelMap | null = null;
  @State isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State isCbChecked: boolean = false;
  private selectCallBack: Callback<emitter.EventData> | undefined = undefined;
  private addFavoriteListPresenter: AddFavoriteListPresenter = AddFavoriteListPresenter.getInstance();
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');

  aboutToAppear() {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_ADD_MEMBERS_ITEM_CHECKED,
    };
    this.selectCallBack = (eventData: emitter.EventData) => {
      let itemId: string | null = eventData.data?.id;
      if (!itemId || this.item.contactId === itemId) {
        this.isCbChecked = this.addFavoriteListPresenter.checkedStatus.has(this.item.contactId);
      }
    }
    emitter.on(innerEvent, this.selectCallBack);
    this.isCbChecked = this.addFavoriteListPresenter.checkedStatus.has(this.item.contactId);
    getPixelMapFromFile(this.item.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res
    })
  }

  aboutToDisappear(): void {
    if (this.selectCallBack) {
      emitter.off(EmitterConstant.EVENT_LIST_ADD_MEMBERS_ITEM_CHECKED, this.selectCallBack);
    }
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        if (this.showIndex) {
          Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.End,
            alignItems: ItemAlign.Start
          }) {
            Text(this.item.namePrefix)
              .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
              .fontSize($r('sys.float.Subtitle_S'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
          }
          .padding({
            start: LengthMetrics.resource($r('app.float.id_card_margin_max')),
            bottom: LengthMetrics.resource($r('app.float.id_card_margin_large'))
          })
          .width('100%')
          .constraintSize({ minHeight: this.isPC ? $r('app.float.id_item_height_sm') :
          $r('app.float.id_item_height_mid') })
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
                .fontWeight(FontWeight.Bold)
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

          Column() {
            Text(this.item.title)
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .margin({
                start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level0')) :
                LengthMetrics.resource($r('app.float.id_card_margin_xl')),
                top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  0, $r('app.float.dialer_button_text_font_size')),
                bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  $r('app.float.id_card_margin_sm'), $r('app.float.dialer_button_text_font_size'))
              })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          }
          .margin({
            start: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
            LengthMetrics.resource($r('app.float.id_card_margin_xl')),
            end: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) : undefined
          })
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .constraintSize({
            minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
          })

          Toggle({
            type: ToggleType.Checkbox,
            isOn: this.isCbChecked
          })
            .width(20)
            .height(20)
            .hitTestBehavior(HitTestMode.None)
            .margin({
              start: this.isPC ? LengthMetrics.vp(2) : LengthMetrics.resource($r('sys.float.padding_level4')),
              end: this.isPC ? LengthMetrics.vp(2) : LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
              top: this.isPC ? LengthMetrics.vp(2) : undefined,
              bottom: this.isPC ? LengthMetrics.vp(2) : undefined
            })
            .selectedColor($r('app.color.skin_comp_background_emphasize'))
            .focusable(false)
            .accessibilityLevel('no')
            .onClick((event: ClickEvent) => {
              AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.isCbChecked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
                : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
            })
        }
        .accessibilityChecked(this.isCbChecked ? true : false)
        .accessibilityRole(AccessibilityRoleType.CHECKBOX)
        .accessibilityDescription(this.isCbChecked ? $r('app.string.accessibility_checkbox_selected') : $r('app.string.accessibility_checkbox_deselected'))
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
        })
        .padding({
          left: this.spaceLR,
          right: this.spaceLR
        })
        .margin({
          start: this.isPC ? LengthMetrics.vp(16) : undefined,
          end: this.isPC ? LengthMetrics.vp(16) : undefined
        })
        .stateStyles({
          pressed: this.pressedStyles,
          normal: this.normalStyles
        })
        .onClick(() => {
          this.presenter.itemOnClick(this.item, this.index);
        })
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
        .focusable(true)
    }

      if (this.showDivifer) {
        Divider()
          .color($r('app.color.skin_comp_divider'))
          .margin({
            start: LengthMetrics.px(68),
            end: LengthMetrics.resource($r('app.float.id_card_margin_xxxxl')),
            bottom: FontScaleState.isStandardGeer(this.fontSizeScale) ? LengthMetrics.px(0) :
            LengthMetrics.px(0.5)
          })
      }
    }
    .margin({ bottom: this.index === this.presenter.contactsTotal - 1 ? $r('app.float.id_card_margin_xxl') : 0 })
  }
}

@Component
struct NoContactsEmptyView {
  @State presenter: AddFavoriteListPresenter = AddFavoriteListPresenter.getInstance();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Column() {
      Blank().height($r('app.float.id_item_height_large'))
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: $r('app.string.no_contacts'),
      //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
      //   fullPage: true,
      //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'),
      // })
      Image($r('app.media.ic_empty_page_no_contacts'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.id_card_image_large'))
        .height($r('app.float.id_card_image_large'))
        .margin({ bottom: $r('app.float.id_card_margin_large') })

      Text($r('app.string.no_contacts'))
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
    .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'))
  }
}

