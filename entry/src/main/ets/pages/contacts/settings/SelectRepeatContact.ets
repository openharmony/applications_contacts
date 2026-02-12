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
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { BatchSelectContact, CustomizedParams } from '../../../model/type';
import { ContactVo } from '../../../model/bean/ContactVo';
import { StringUtil } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import ArrangeContactsPresenter, {
  RepeatContactVo
} from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import emitter from '@ohos.events.emitter';
import { getPixelMapFromFile } from '../../../util/UserPhoto'
import { AlphabetIndexerPage } from '../alphabetindex/AlphabetIndexerPage';
import DotUtil from '../../../util/DotUtil';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomProgressContent from '../../dialog/CustomProgressContent';
import { ResourceUtil } from '../../../util/ResourceUtil';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { FontScaleState } from '../../../util/fontScaleState';
import { SymbolGlyphModifier, TextModifier, ToolBar, ToolBarOptions, ItemState, LengthMetrics } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import EmitterConstant from '../../../data/EmitterConstant';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import LooseObject from '../../../model/type/LooseObject';
import { SlidingMultipleSelectionsUtil } from '../../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit'
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { GlobalContext } from '../../../util/GlobalContext';
import AccessibilityUtil from '../../../util/AccessibilityUtil';

const TAG = 'SelectRepeatContact';
const ORGANIZE_MERGE_CHOOSE_EVENT = 'ORGANIZE_MERGE_CHOOSE_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function selectRepeatContactLoader($$: Params): void {
  SelectRepeatContact();
}

/**
 * Selecting a contact list
 */
@Component
export default struct SelectRepeatContact {
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  @State presenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  //select number
  @State selectNumbers: number = 0;
  @State percent: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State toolbarList: ToolBarOptions = new ToolBarOptions();
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  exportDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      contentBuilder: () => {
        this.ExportDialogBuilder();
      }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  exitReminderDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.dialog_discard_merge_contacts'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_discard'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.presenter.pathInfos?.pop();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
      }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  organizeMergeChooseParams: CustomizedParams = {
    ISSELECT: 0,
    ISMERGE: 0
  }

  aboutToAppear() {
    HiLog.w(TAG, 'SelectRepeatContacts aboutToAppear!');
    GlobalContext.getContext().setObject('scrollerSelectRepeatContact', this.scroller);
    this.presenter.selectedRepeatContacts.clear();
    this.presenter.initNavPaths(this.contactsSettingsNavStack);
    this.presenter.initContactList(() => {
      HiLog.w(TAG, 'presenter.repeatList length: ' + this.presenter.repeatList.length);
      this.presenter.repeatDataSource.refresh(this.presenter.repeatList);
      this.presenter.onClickAll();
      HiLog.w(TAG, 'this.repeatList length: ' + this.presenter.repeatList.length);
    });
    // monitor merge event
    let mergeEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.MERGE_EVENT_ID,
      priority: emitter.EventPriority.HIGH
    }
    emitter.on(mergeEvent, (data: emitter.EventData) => {
      if (data.data!['percent'] === undefined) {
        this.exportDialogController.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
      } else {
        this.percent = data.data!['percent'];
        if (this.percent == 100) {
          this.exportDialogController.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.presenter.repeatDataSource.refresh(this.presenter.repeatList);
          this.selectNumbers = 0;
          this.percent = 0;
        }
      }
    })

    this.presenter.refreshUI = () => {
      HiLog.i(TAG, 'refreshUI');
      this.selectNumbers = this.presenter.selectCount;
      this.updateToolbar();
    }
    this.presenter.refreshUI();
    this.updateToolbar();
  }

  aboutToDisappear() {
    GlobalContext.getContext().removeObject('scrollerSelectRepeatContact');
    this.presenter.repeatList = [];
    HiLog.i(TAG, 'SelectRepeatContacts aboutToDisappear!');
  }

  destinationPageShow() {
    HiLog.i(TAG, 'SelectRepeatContacts onPageShow')
  }

  destinationPageHide() {
    HiLog.i(TAG, 'SelectRepeatContacts onPageCover')
  }

  updateToolbar() {
    HiLog.i(TAG, 'updateToolbar : ' + this.selectNumbers);
    this.toolbarList = [{
      content: $r('app.string.merge_duplicate'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.arrow_triangle_merge')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      action: () => {
        if (this.selectNumbers > 0) {
          // 联系人打点--手动合并重复联系人
          if (this.presenter.repeatList.length === this.selectNumbers) {
            this.organizeMergeChooseParams.ISSELECT = 2;
          } else if (this.selectNumbers > 1) {
            this.organizeMergeChooseParams.ISSELECT = 1;
          } else if (this.selectNumbers === 1) {
            this.organizeMergeChooseParams.ISSELECT = 0;
          }
          this.organizeMergeChooseParams.ISMERGE = 1;
          DotUtil.getInstance().contactDot(this.organizeMergeChooseParams, ORGANIZE_MERGE_CHOOSE_EVENT);
          this.presenter.arrange();
          this.exportDialogController.open();
          DialogControllerManager.getInstance().addDialogController(this.exportDialogController);
        }
      },
      state: this.selectNumbers > 0 ? ItemState.ENABLE : ItemState.DISABLE
    }, {
      content: this.presenter.repeatList.length === this.selectNumbers ? $r('app.string.unselect_all') :
      $r('app.string.select_all'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('app.color.skin_font_primary')]),
        activated: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill')).fontColor([$r('app.color.skin_icon_emphasize')]),
      },
      state: ItemState.ACTIVATE,
      action: () => {
        this.presenter.onClickAll();
      },
    }]
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress')
    if (this.selectNumbers > 0) {
      this.exitReminderDialogController.open();
      DialogControllerManager.getInstance().addDialogController(this.exportDialogController);
    } else {
      this.presenter.pathInfos?.pop();
    }
    return true;
  }

  build() {
    NavDestination() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
          Column() {
            if (ArrayUtil.isEmpty<RepeatContactVo>(this.presenter.repeatList)) {
              NoContactsEmptyView()
            } else {
              ContactsList({
                presenter: $presenter,
              })
                .flexShrink(1)

              // 判断是全选状态 按钮变蓝.
              WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
                ToolBar({
                  activateIndex: this.presenter.repeatList.length === this.selectNumbers ? 1 : 0,
                  dividerModifier: new DividerModifier().height(0),
                  toolBarList: this.toolbarList,
                })
                  .width('100%')
                  .height($r('app.float.id_toolbar_height'))
                  .backgroundColor($r('app.color.color_bind_sheet_background'))
              }
            }
          }
          .height('100%')
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
    }
    .bindToScrollable([this.scroller])
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.onBack();
    // }))
    .title(this.selectNumbers > 0
      ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectNumbers)
      : ResourceUtil.getStringByResource($r('app.string.not_selected')),
      {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left'))
      })
    .menus(this.TitleGuide())
    .onBackPressed(() => {
      // 联系人打点--手动合并重复联系人
      if (ArrayUtil.isEmpty<RepeatContactVo>(this.presenter.repeatList)) {
        //显示没有重复联系人页面点击x
        this.organizeMergeChooseParams.ISSELECT = -1;
      } else if (this.presenter.repeatList.length === this.selectNumbers) {
        this.organizeMergeChooseParams.ISSELECT = 2;
      } else if (this.selectNumbers > 1) {
        this.organizeMergeChooseParams.ISSELECT = 1;
      } else if (this.selectNumbers === 1) {
        this.organizeMergeChooseParams.ISSELECT = 0;
      } else {
        this.organizeMergeChooseParams.ISSELECT = -1;
      }
      this.organizeMergeChooseParams.ISMERGE = 0;
      DotUtil.getInstance().contactDot(this.organizeMergeChooseParams, ORGANIZE_MERGE_CHOOSE_EVENT);
      this.destinationBackPress();
      return true;
    })
    .onShown(() => {
      this.destinationPageShow();
    })
    .onHidden(() => {
      this.destinationPageHide();
    })
    .padding({
      bottom: !ArrayUtil.isEmpty<RepeatContactVo>(this.presenter.repeatList) && this.curBp !== 'sm'
        ? $r('sys.float.padding_level0') : 50
    })
    .backgroundColor($r('app.color.color_bind_sheet_background'))
  }

  private onBack() {
    // 联系人打点--手动合并重复联系人
    if (ArrayUtil.isEmpty<RepeatContactVo>(this.presenter.repeatList)) {
      //显示没有重复联系人页面点击x
      this.organizeMergeChooseParams.ISSELECT = -1;
    } else if (this.presenter.repeatList.length === this.selectNumbers) {
      this.organizeMergeChooseParams.ISSELECT = 2;
    } else if (this.selectNumbers > 1) {
      this.organizeMergeChooseParams.ISSELECT = 1;
    } else if (this.selectNumbers === 1) {
      this.organizeMergeChooseParams.ISSELECT = 0;
    } else {
      this.organizeMergeChooseParams.ISSELECT = -1;
    }
    this.organizeMergeChooseParams.ISMERGE = 0;
    DotUtil.getInstance().contactDot(this.organizeMergeChooseParams, ORGANIZE_MERGE_CHOOSE_EVENT);
    this.destinationBackPress();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: this.isPC ? {
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.color_bind_sheet_background')
  //         }
  //       }
  //     } : undefined,
  //     avoidLayoutSafeArea: false,
  //     padding: { start: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.selectNumbers },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }

  @Builder
  TitleGuide() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .type(ButtonType.Circle)
      .borderRadius(0)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .id('SelectRepeatContact_close_btn')
      .onClick(() => {
        emitter.emit({
          eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
        });
      })
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .padding({
      end: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource(this.spaceLR),
    })
    .margin({
      left: this.isPC ? '8vp' : ((this.curBp === 'lg') ? '24vp' : undefined)
    })
  }

  @Builder
  ExportDialogBuilder() {
    Column() {
      CustomProgressContent({
        percent: this.percent,
        progressText: $r('app.string.merge_duplicate_contacts')
      })
    }
    .width('100%')
  }
}

@Component
struct ContactsList {
  @Link presenter: ArrangeContactsPresenter;
  private scroller: Scroller = GlobalContext.getContext().getObject('scrollerSelectRepeatContact') as Scroller;
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);


  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center }) {
      List({ initialIndex: this.presenter.initialIndex, scroller: this.scroller }) {
        LazyForEach(this.presenter.repeatDataSource, (item: RepeatContactVo, index: number) => {
          ListItem() {
            RepeatContactListItem({
              mPresenter: this.presenter,
              item: item,
              index: index
            })
          }
        }, (item: BatchSelectContact) => JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .clipContent(ContentClipMode.SAFE_AREA)
      .safeAreaPadding({ top: $r('app.float.id_item_height_max') })
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
        this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;

        this.presenter.sceillOnlenth = (lastIndex - firstIndex) + 1
        this.presenter.resetInitialIndex(firstIndex);
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
      .divider({
        strokeWidth: '1px',
        color: $r('app.color.skin_comp_divider'),
        startMargin: $r('app.float.account_listItem_text_common_width'),
        endMargin: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      })
      .gesture(PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          for (let i = 0; i < this.presenter.repeatDataSource.totalCount(); ++i) {
            let item = this.presenter.repeatDataSource.getData(i);
            let selectStatus = this.presenter.selectedRepeatContacts.hasKey(item?.repeatId);
            this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
          }
          this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
        })
        .onActionUpdate((event: GestureEvent) => {
          let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
            let curSelectStatus = false;
            if (index >= 0) {
              let item = this.presenter.repeatDataSource.getData(index);
              curSelectStatus = this.presenter.selectedRepeatContacts.hasKey(item?.repeatId);
            }
            return curSelectStatus;
          });
          updateIndexes.forEach((index) => {
            if (index >= 0) {
              let item = this.presenter.repeatDataSource.getData(index);
              this.presenter.onItemClick(item, index);
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_bind_sheet_background'))
  }
}


@Reusable
@Component
struct RepeatContactListItem {
  @Link mPresenter: ArrangeContactsPresenter;
  @Prop item: RepeatContactVo
  @Prop index: number
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State checked: boolean = true;
  private isPC: boolean = EnvironmentProp.isPC();


  aboutToAppear() {
    emitter.on(ArrangeContactsPresenter.ARRANGE_CONTACT_ITEM_CHECKED, (eventData: emitter.EventData) => {
      let repeatId = eventData.data?.repeatId as string;
      if (!repeatId || this.item.repeatId === repeatId) {
        this.checked = this.mPresenter.selectedRepeatContacts.hasKey(this.item.repeatId);
      }
    })
    this.checked = this.mPresenter.selectedRepeatContacts.hasKey(this.item.repeatId);
  }

  aboutToDisappear(): void {
    emitter.off(ArrangeContactsPresenter.ARRANGE_CONTACT_ITEM_CHECKED);
  }

  aboutToReuse(params: LooseObject): void {
    this.checked = this.mPresenter.selectedRepeatContacts.hasKey(this.item.repeatId);
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }


  build() {
    Row() {
      Column() {
        ForEach(this.item.contactList, (contact: ContactVo, subIndex: number) => {
          Row() {
            ContactPhotoView({
              contact: contact
            })

            Column() {
              Text(StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName)
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .margin({
                  bottom: $r('app.float.id_card_margin_sm')
                })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)

              Text(contact.phoneNumbers[0].labelName)
                .fontColor($r('app.color.skin_font_tertiary'))
                .fontSize($r('sys.float.Subtitle_S'))
                .fontWeight(FontWeight.Regular)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            }
            .hitTestBehavior(HitTestMode.None)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .flexGrow(1)
            .flexShrink(1)
            .padding({
              top: (subIndex === 0) ? FontScaleState.fetchSeniorTopAndBottomSpace(
                this.fontSizeScale, $r('app.float.id_card_margin_mid'),
                $r('app.float.id_card_margin_10')) : $r('app.float.id_card_margin_mid'),
              bottom: (subIndex === this.item.contactList.length - 1) ?
              FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                $r('app.float.id_card_margin_mid'), $r('app.float.id_card_margin_10')) :
              $r('app.float.id_card_margin_mid')
            })
            .constraintSize({
              minHeight: this.isPC ? $r('app.float.id_item_height_large') :
              $r('app.float.id_item_height_max')
            })
          }
          .hitTestBehavior(HitTestMode.None)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .constraintSize({
            minHeight: this.isPC ? $r('app.float.id_item_height_large') :
            $r('app.float.id_item_height_max')
          })
        })
      }
      .width(this.isPC ? 'calc(100% - 40vp)' : '83%')
      .margin({
        end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) :
        LengthMetrics.resource($r('sys.float.padding_level0'))
      })
      .hitTestBehavior(HitTestMode.None)

      Toggle({
        type: ToggleType.Checkbox,
        isOn: this.checked
      })
        .size({ width: 20, height: 20 })
        .margin($r('sys.float.padding_level1'))
        .flexShrink(0)
        .enabled(true)
        .hitTestBehavior(HitTestMode.None)
        .selectedColor($r('app.color.skin_icon_emphasize'))
        .visibility(Visibility.Visible)
        .focusable(false)
        .accessibilityLevel('no')
        .onChange(()=>{
          AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.checked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
            : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
        })
    }
    .accessibilityRole(AccessibilityRoleType.CHECKBOX)
    .accessibilityChecked(this.checked)
    .justifyContent(FlexAlign.SpaceBetween)
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .width('100%')
    .padding({
      left: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      right: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
    })
    .onClick(() => {
      this.mPresenter.onItemClick(this.item, this.index);
    })
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
  }
}


@Component
struct NoContactsEmptyView {
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Column() {
      Image($r('app.media.ic_empty_page_no_contacts'))
        .width(100)
        .height(100)
        .margin({ bottom: 24 })
        .objectFit(ImageFit.Contain)
      Text($r('app.string.no_duplicate_contacts'))
        .fontSize(16)
        .fontColor($r('app.color.skin_font_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .padding({ top: 160})
    .width('100%')
    .height('100%')
    .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.color_bind_sheet_background'))
  }
}

@Component
export struct ContactPhotoView {
  @Prop contact: ContactVo;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();

  aboutToAppear() {
    getPixelMapFromFile(this.contact.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  build() {
    Row() {
      if (this.photoPixelMap) {
        Image(this.photoPixelMap)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_mid'))
          .draggable(false)
      } else if (StringUtil.isEmpty(this.contact.nameSuffix)) {
        Image(StringUtil.isEmpty(this.contact.portraitPath) ? $r('app.media.ic_user_portrait') :
        this.contact.portraitPath)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Contain)
          .borderRadius($r('app.float.id_card_image_mid'))
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor(
            StringUtil.isEmpty(this.contact.portraitPath) ?
            $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
          )
          .draggable(false)
      } else {
        Text(this.contact.nameSuffix.toUpperCase())
          .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '16vp')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .height($r('app.float.id_card_image_mid'))
          .width($r('app.float.id_card_image_mid'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_image_mid'))
          .accessibilityLevel('no')
      }
    }
    .hitTestBehavior(HitTestMode.None)
    .width($r('app.float.id_card_image_mid'))
    .height($r('app.float.id_card_image_mid'))
    .margin({
      end: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
      LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
    })
    .flexShrink(0)
  }
}

