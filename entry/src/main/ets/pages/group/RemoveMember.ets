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
import RemoveMemberPresenter from '../../presenter/group/RemoveMemberPresenter';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { GroupMemberListBean } from '../../model/bean/GroupMemberListBean';
import { MemberInfo } from '../../model/bean/ContactVo';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import { ResourceUtil } from '../../util/ResourceUtil';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { FontScaleState } from '../../util/fontScaleState';
import { DividerModifier, LengthMetrics, SymbolGlyphModifier, TextModifier,
  ToolBar, ToolBarModifier, ToolBarOptions, ItemState } from '@kit.ArkUI';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { i18n } from '@kit.LocalizationKit';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../data/EmitterConstant';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { SlidingMultipleSelectionsUtil } from '../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'RemoveMember ';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function RemoveMemberLoader($$: Params): void {
  RemoveMember();
}

@Component
export default struct RemoveMember {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State @Watch('selectCountChange') removeMemberPresenter: RemoveMemberPresenter = RemoveMemberPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.removeMemberPresenter.pathInfos = this.pathInfos;
    this.removeMemberPresenter.checkedStatus.clear();
    this.removeMemberPresenter.sendSelectedEvent(null);
    this.removeMemberPresenter.initMemberData();
    this.selectCountChange();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    this.removeMemberPresenter.resetData();
  }


  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(52)).backgroundColor(Color.Transparent).stateEffect(true);
  @State dividerModifier: DividerModifier = new DividerModifier().height(0);

  selectCountChange() {
    this.toolbarList = [];
    this.toolbarList.push(
      {
        content: $r('app.string.favorite_remove'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.xmark_circle')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        state: this.removeMemberPresenter.selectedCount > 0 ? 1 : 2,
        action: () => {
          this.removeMemberPresenter.deleteEvent();
        }
      },
      {
        content: this.removeMemberPresenter.isSelectAll ? $r('app.string.unselect_all') : $r('app.string.select_all'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('app.color.skin_font_primary')]),
          activated: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill')).fontColor([$r('app.color.skin_icon_emphasize')]),
        },
        state: ItemState.ACTIVATE,
        action: () => {
          this.removeMemberPresenter.checkAll();
        },

      }
    )

  }

  @Builder
  PCMenu() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark_circle'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.favorite_remove')))
      .type(ButtonType.Normal)
      .borderRadius($r('sys.float.corner_radius_level2'))
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(Color.Transparent)
      .margin({
        end: LengthMetrics.resource($r('sys.float.padding_level4'))
      })
      .enabled(this.removeMemberPresenter.selectedCount > 0)
      .onClick(() => {
        this.removeMemberPresenter.deleteEvent();
      })

      Button() {
        SymbolGlyph(this.removeMemberPresenter.isSelectAll
          ? $r('sys.symbol.checkmark_square_on_square_fill')
          : $r('sys.symbol.checkmark_square_on_square'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([this.removeMemberPresenter.isSelectAll ?
          $r('app.color.skin_font_emphasize') : $r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility,
          this.removeMemberPresenter.isSelectAll ? $r('app.string.unselect_all') : $r('app.string.select_all')))
      .type(ButtonType.Normal)
      .borderRadius($r('sys.float.corner_radius_level2'))
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(Color.Transparent)
      .margin({
        end: LengthMetrics.resource($r('sys.float.padding_level4'))
      })
      .onClick(() => {
        this.removeMemberPresenter.checkAll();
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
        this.removeMemberBuilder()
      }
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .title(this.removeMemberPresenter.selectedCount > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.removeMemberPresenter.selectedCount)
        : ResourceUtil.getStringByResource($r('app.string.not_selected')),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: LengthMetrics.vp(16)
        })
      .menus(this.PCMenu())
      .onBackPressed(() => {
        this.removeMemberPresenter.back();
        return true;
      })
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    } else {
     NavDestination() {
        this.removeMemberBuilder()
      }
      .bindToScrollable([this.scroller])
      .title(this.removeMemberPresenter.selectedCount > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.removeMemberPresenter.selectedCount)
        : ResourceUtil.getStringByResource($r('app.string.not_selected')),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined)
        })
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.onBack();
      // }))
      .onBackPressed(() => {
        this.removeMemberPresenter.back();
        return true;
      })
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    }
  }

  @Builder
  removeMemberBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
          Flex({
            direction: FlexDirection.Column,
            alignItems: ItemAlign.Start,
          }) {
            List({ scroller: this.scroller }) {
              LazyForEach(this.removeMemberPresenter.groupMemberDataSource,
                (item: GroupMemberListBean, index?: number | undefined) => {
                  ListItem() {
                    MemberItem({
                      item: item.member,
                      removeMemberPresenter: $removeMemberPresenter,
                      index: index,
                    })
                  }
                }, (item: GroupMemberListBean) => JSON.stringify(item));
            }
            .onScrollIndex((start: number, end: number) => {
              this.slidingMultipleSelectionsUtil.scrollStartIndex = start;
              this.slidingMultipleSelectionsUtil.scrollEndIndex = end;

              this.removeMemberPresenter.sceillOnlenth = (end - start) + 1;
            })
            .divider({
              strokeWidth: 0.3,
              color: $r('app.color.skin_comp_divider'),
              startMargin: $r('app.float.id_records_divider_max'),
            })
            .width('100%')
            .margin({ bottom: this.isPC ? 0 : $r('app.float.id_item_height_large') })
            .backgroundColor($r('app.color.skin_background_primary'))
            .listDirection(Axis.Vertical)
            .scrollBar(BarState.Off)
            .clipContent(ContentClipMode.SAFE_AREA)
            .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
            .gesture(PanGesture({ direction: PanDirection.Vertical })
              .onActionStart((event: GestureEvent) => {
                for (let i = 0; i < this.removeMemberPresenter.groupMemberDataSource.totalCount(); ++i) {
                  let item = this.removeMemberPresenter.groupMemberDataSource.getData(i);
                  let contactId = Number(item?.member.member.contactId)
                  let selectStatus = this.removeMemberPresenter.checkedStatus.has(contactId);
                  this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
                  this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
                }
                this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
              })
              .onActionUpdate((event: GestureEvent) => {
                let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0],
                  (index) => {
                    let curSelectStatus = false;
                    if (index >= 0) {
                      let item = this.removeMemberPresenter.groupMemberDataSource.getData(index);
                      let contactId = Number(item?.member.member.contactId);
                      curSelectStatus = this.removeMemberPresenter.checkedStatus.has(contactId);
                    }
                    return curSelectStatus;
                  });
                updateIndexes.forEach((index) => {
                  if (index >= 0) {
                    let item = this.removeMemberPresenter.groupMemberDataSource.getData(index);
                    this.removeMemberPresenter.itemOnClick(item?.member.member, index);
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
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number;
              this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
              this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
            })
          }
          .padding({
            left: $r('app.float.id_card_margin_xxl'),
            right: $r('app.float.id_card_margin_xxl')
          })
        }
      }

      if (!this.isPC) {
        WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
          ToolBar({
            toolBarModifier: this.toolBarModifier,
            dividerModifier: new DividerModifier().height(0),
            activateIndex: this.removeMemberPresenter.memberList.length ===
            this.removeMemberPresenter.selectedCount ? 1 : -1,
            toolBarList: this.toolbarList,
          })
            .height($r('app.float.id_toolbar_height'))
            .width('100%')
            .backgroundColor($r('app.color.skin_background_primary'));
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.skin_background_primary'))
  }

  private onBack() {
    this.removeMemberPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.removeMemberPresenter.selectedCount },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }

  @Builder
  memberItemBuilder(item: GroupMemberListBean, index: number | undefined) {
    MemberItem({
      item: item.member,
      removeMemberPresenter: $removeMemberPresenter,
      index
    })
  }
}

@Component
struct MemberItem {
  @Link removeMemberPresenter: RemoveMemberPresenter;
  @Prop item: MemberInfo;
  @Prop index: number;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private selectCallBack: Callback<emitter.EventData> | undefined = undefined;
  private isPC: boolean = EnvironmentProp.isPC();
  @State isChecked: boolean = false;
  nameTitle:string = ContactsGlobalThisHelper.GetGlobalThis()
    .getDefaultUIContext()
    .resourceManager
    .getStringSync($r('app.string.noName').id);

  aboutToAppear() {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_DELETE_MEMBER_ITEM_CHECKED,
    };
    this.selectCallBack = (eventData: emitter.EventData) => {
      let itemId: number | null = eventData.data?.id;
      if (!itemId || Number(this.item.member.contactId) === itemId) {
        this.isChecked = this.removeMemberPresenter.checkedStatus.has(Number(this.item.member.contactId));
      }
    }
    emitter.on(innerEvent, this.selectCallBack);
    this.isChecked = this.removeMemberPresenter.checkedStatus.has(Number(this.item.member.contactId));
    getPixelMapFromFile(this.item.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  aboutToDisappear(): void {
    if (this.selectCallBack) {
      emitter.off(EmitterConstant.EVENT_LIST_DELETE_MEMBER_ITEM_CHECKED, this.selectCallBack);
    }
  }


  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
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
            .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
            .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
            .draggable(false)
        } else {
          Text(this.item.member.headChar)
            .fontSize('16vp')
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
            .height($r('app.float.id_card_image_mid'))
            .width($r('app.float.id_card_image_mid'))
            .textAlign(TextAlign.Center)
            .borderRadius($r('app.float.id_card_image_mid'))
            .accessibilityLevel('no')
        }
      }
      .height($r('app.float.id_card_image_mid'))
      .width($r('app.float.id_card_image_mid'))
      .flexShrink(0)

        Text(this.item.member.title !== '' ? this.item.member.title : this.nameTitle)
          .fontColor($r('app.color.skin_font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          .flexShrink(1)
          .flexGrow(1)
          .margin({
            left: this.isPC ? $r('app.float.id_card_margin_large') : $r('app.float.id_card_margin_xxl'),
            right: $r('app.float.id_card_margin_xxl'),
            top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
              0, $r('app.float.dialer_button_text_font_size')),
            bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
              0, $r('app.float.dialer_button_text_font_size'))
          })
          .width(this.isPC ? 'cale(100% - 56vp)' : '70%')
          .textAlign(TextAlign.Start)
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)

      Row() {
        Blank();

        Checkbox()
          .margin($r('app.float.id_card_margin_sm'))
          .select(this.isChecked)
          .selectedColor($r('app.color.skin_comp_background_emphasize'))
          .onChange((value: boolean) => {
          })
          .focusable(false)
          .flexShrink(0)
          .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
          .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
          .accessibilityLevel('no')
          .hitTestBehavior(HitTestMode.None)
      }
      .enabled(false)
    }
    .accessibilityRole(AccessibilityRoleType.CHECKBOX)
    .accessibilityChecked(this.isChecked)
    .backgroundColor($r('app.color.skin_background_primary'))
    .onClick(() => {
      this.removeMemberPresenter.itemOnClick(this.item.member, this.index);
    })
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .width('100%')
    .focusable(true)
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
  }
}