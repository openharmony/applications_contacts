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
import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import { AlphabetIndexerPage } from '../alphabetindex/AlphabetIndexerPage';
import { BatchSelectContact, CustomizedParams } from '../../../model/type';
import BatchDeleteContactsPresenter from '../../../presenter/contact/settings/BatchDeleteContactsPresenter';
import { StringUtil } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import emitter from '@ohos.events.emitter';
import DotUtil from '../../../util/DotUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomButtons from '../../dialog/CustomButtons';
import { ResourceUtil } from '../../../util/ResourceUtil';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { LengthMetrics, SubHeader, ToolBar, ToolBarOptions } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { getPixelMapFromFile } from '../../../util/UserPhoto';
import LooseObject from '../../../model/type/LooseObject';
import { FontScaleState } from '../../../util/fontScaleState';
import ContactListShowInfo from '../../../model/bean/ContactListShowInfo';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import AccessibilityUtil from '../../../util/AccessibilityUtil';

import ProgressBarContent from '../../dialog/ProgressBarContent';
import { i18n } from '@kit.LocalizationKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import { SlidingMultipleSelectionsUtil } from '../../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { GlobalContext } from '../../../util/GlobalContext';
import EmitterConstant from '../../../data/EmitterConstant';

const TAG = 'BatchDeleteContacts';
const ORGANIZE_BATCH_DELETE_EVENT = 'ORGANIZE_BATCH_DELETE_EVENT';
const ORGANIZE_BATDEL_DIALOG_EVENT = 'ORGANIZE_BATDEL_DIALOG_EVENT';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function batchDeleteContactsLoader($$: Params): void {
  BatchDeleteContacts();
}

// ItemState
enum ItemState {
  ENABLE = 1,
  DISABLE = 2,
  ACTIVATE = 3
}

interface ToolbarParams {
  isSelected: boolean;
  allSelectMessage: Resource;
  icSelectAll: Resource;
}

@Extend(Text)
function contentGeneraStyle() {
  .fontColor($r('app.color.skin_font_primary'))
  .fontSize($r('sys.float.Subtitle_M'))
  .fontWeight(FontWeight.Medium)
  .margin({
    start: LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
    bottom: LengthMetrics.resource($r('sys.float.padding_level5')),
    top: LengthMetrics.resource($r('sys.float.padding_level5'))
  })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

/**
 * Selecting a contact list
 */
@Component
export default struct BatchDeleteContacts {
  @StorageLink('toBatchDeleteContactsNavStack') toBatchDeleteContactsNavStack: NavPathStack = new NavPathStack;
  @State isFromArrangeContactsPage: boolean =
    this.toBatchDeleteContactsNavStack.getIndexByName('ArrangeContacts').length === 0 ? false : true;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('allSelectedIdCount') allSelectedIdCount: number = 0;
  @State mPresenter: BatchDeleteContactsPresenter = BatchDeleteContactsPresenter.getInstance();
  // 联系人列表长度
  @StorageProp('contactListListLen') @Watch('contactListListLenChange') contactListListLen: number = 0;
  @State currentIndex: number = 0;
  @State curBp: string = 'sm';
  @State contactsListInited: boolean = false;
  @State contactsTotal: number = -1;
  @State selectCount: number = 0;
  @State progressCount: number = 0;
  @State percent: number = 0;
  @State private checkState: boolean = false;
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 左右间距，根据设备类型动态调整
  @StorageLink('spaceLR') spaceLR: Resource =
    EnvironmentProp.isPC() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8');
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @State @Watch('updateToolbar') toolbarParams: ToolbarParams = {
    isSelected: this.mPresenter.selectCount > 0,
    allSelectMessage: this.mPresenter.allSelectMessage,
    icSelectAll: this.mPresenter.icSelectAll
  }
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  private scroller: Scroller = new Scroller();
  batchDeleteParams: CustomizedParams = {
    NUM: 0,
    ISCLICK: 0
  };
  organizeBatDelDialogParams: CustomizedParams = {
    NUM: 0,
    ISDELETE: 0
  };
  @StorageLink('longPressSelectContactId') longPressSelectContactId: string | undefined = undefined;

  contactListListLenChange() {
    HiLog.i(TAG, `contactListListLenChange len is ${this.contactListListLen}`);
    this.mPresenter.refresh();
  }

  aboutToAppear() {
    HiLog.i(TAG, `aboutToAppear, longPressSelectContactId: ${this.longPressSelectContactId}}`)
    GlobalContext.getContext().setObject('scrollerDeleteContacts', this.scroller);
    emitter.on(BatchDeleteContactsPresenter.EMITTER_ID_DELETE, (eventData: emitter.EventData) => {
      if (eventData.data) {
        this.progressCount += eventData.data.selectedCounts;
        this.percent = Math.min(Math.round((this.progressCount / this.allSelectedIdCount) * 100), 100);
        // 如果进度完成,弹窗关闭
        if (this.progressCount >= this.allSelectedIdCount) {
          this.progressDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.toBatchDeleteContactsNavStack.pop(this.isFromArrangeContactsPage);
          setTimeout(() => {
            this.progressCount = 0;
            this.percent = 0;
          }, 1000);
        }
      }
    });
    this.mPresenter.refreshUI = () => {
      HiLog.i(TAG, 'refreshUI')
      this.toolbarParams = {
        isSelected: this.mPresenter.selectCount > 0,
        allSelectMessage: this.mPresenter.allSelectMessage,
        icSelectAll: this.mPresenter.icSelectAll
      }
      this.contactsListInited = this.mPresenter.contactsListInited;
      this.contactsTotal = this.mPresenter.contactsTotal;
      this.selectCount = this.mPresenter.selectCount;
    }
    this.mPresenter.aboutToAppear();
    this.updateToolbar();
  }

  aboutToDisappear() {
    let res: boolean = AppStorage.set('longPressSelectContactId', undefined);
    HiLog.i(TAG, `delete longPressSelectContactId result: ${res}`);
    GlobalContext.getContext().removeObject('scrollerDeleteContacts');
    emitter.off(BatchDeleteContactsPresenter.EMITTER_ID_DELETE);
    HiLog.i(TAG, 'aboutToDisappear')
  }

  destinationPageShow() {
    HiLog.i(TAG, 'onPageShow')
  }

  destinationPageHide() {
    HiLog.i(TAG, 'onPageCover')
  }

  deleteDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.plural.delete_or_not', this.mPresenter.selectCount, this.mPresenter.selectCount),
      contentBuilder: () => {
        this.DeleteContactDialog();
      },
      contentAreaPadding: { left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') }
    }),
    autoCancel: false,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  updateToolbar() {
    HiLog.i(TAG, 'updateToolbar');
    this.toolbarList = [{
      content: $r('app.string.dialog_delete'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      action: () => {
        if (this.mPresenter.selectCount > 0) {
          // 联系人打点--整理联系人批量删除点击批量删除按钮
          if (this.mPresenter.contactsTotal === this.mPresenter.selectCount) {
            this.batchDeleteParams.NUM = 2;
            this.organizeBatDelDialogParams.NUM = 2;
          } else if (this.mPresenter.selectCount > 1) {
            this.batchDeleteParams.NUM = 1;
            this.organizeBatDelDialogParams.NUM = 1;
          } else if (this.mPresenter.selectCount === 1) {
            this.batchDeleteParams.NUM = 0;
            this.organizeBatDelDialogParams.NUM = 0;
          } else {
            this.batchDeleteParams.NUM = -1;
            this.organizeBatDelDialogParams.NUM = -1;
          }
          this.batchDeleteParams.ISCLICK = 1;
          DotUtil.getInstance().contactDot(this.batchDeleteParams, ORGANIZE_BATCH_DELETE_EVENT);
          this.checkState = false;
          this.deleteDialogControler?.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
        }
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
        this.mPresenter.onClickAll();
      },
    }]
  }

  @Builder
  PCMenu() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.dialog_delete')))
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
      .enabled(this.selectCount > 0)
      .onClick(() => {
        if (this.mPresenter.selectCount > 0) {
          // 联系人打点--多选删除点击删除按钮
          if (this.mPresenter.contactsTotal === this.mPresenter.selectCount) {
            this.batchDeleteParams.NUM = 2;
            this.organizeBatDelDialogParams.NUM = 2;
          } else if (this.mPresenter.selectCount > 1) {
            this.batchDeleteParams.NUM = 1;
            this.organizeBatDelDialogParams.NUM = 1;
          } else if (this.mPresenter.selectCount === 1) {
            this.batchDeleteParams.NUM = 0;
            this.organizeBatDelDialogParams.NUM = 0;
          } else {
            this.batchDeleteParams.NUM = -1;
            this.organizeBatDelDialogParams.NUM = -1;
          }
          this.batchDeleteParams.ISCLICK = 1;
          DotUtil.getInstance().contactDot(this.batchDeleteParams, ORGANIZE_BATCH_DELETE_EVENT);
          this.checkState = false;
          this.deleteDialogControler?.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
        }
      })

      Button() {
        SymbolGlyph((this.selectCount === this.contactsTotal && this.contactsTotal > 0) ?
        $r('sys.symbol.checkmark_square_on_square_fill') : $r('sys.symbol.checkmark_square_on_square'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor((this.selectCount === this.contactsTotal && this.contactsTotal > 0) ?
            [$r('app.color.skin_icon_emphasize')] : [$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility,
          (this.selectCount === this.contactsTotal && this.contactsTotal > 0) ? $r('app.string.select_all') :
          $r('app.string.unselect_all')))
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
        this.mPresenter.onClickAll();
      })
    }
    .height($r('app.float.id_item_height_large'))
    .width('120vp')
    .alignItems(VerticalAlign.Center)
    .padding({ end: LengthMetrics.vp(232) })
  }

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
      .id('Settings_close_btn')
      .onClick(() => {
        let event: emitter.InnerEvent = {
          // 通知关闭设置半模态页面
          eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
        }
        emitter.emit(event);
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

  build() {
    if (this.isPC) {
      NavDestination() {
        this.BatchDeleteBuilder()
      }
      .menus(!this.isFromArrangeContactsPage ? this.PCMenu() : undefined)
      .backgroundColor($r('app.color.color_bind_sheet_background'))
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier(this.isFromArrangeContactsPage ? $r('sys.symbol.chevron_backward') :
          $r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')]) :
        new SymbolGlyphModifier(this.isFromArrangeContactsPage ? $r('sys.symbol.chevron_backward') :
          $r('sys.symbol.xmark')))
      .title(this.selectCount > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectCount)
        : ResourceUtil.getStringByResource($r('app.string.not_selected')),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: EnvironmentProp.isPC() ? LengthMetrics.vp(16)
            : LengthMetrics.resource($r('sys.float.margin_left'))
        })
      .onBackPressed(() => {
        return this.onBack();
      })
      .onShown(() => {
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.destinationPageHide();
      })
      .padding({
        top: this.isFromArrangeContactsPage ? 8 : px2vp(this.fullScreenPadding.top as number),
        bottom: this.contactsTotal === 0 ? 0 : 50
      })
    } else {
     NavDestination() {
        this.BatchDeleteBuilder()
      }
      .bindToScrollable([this.scroller])
      // .titleMode(this.isFromArrangeContactsPage ? HdsNavDestinationTitleMode.MODAL : HdsNavDestinationTitleMode.MINI)
      .backgroundColor($r('app.color.color_bind_sheet_background'))
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(),
      //     this.isFromArrangeContactsPage ? TitleBarUtil.getBindSheetCloseButton() : undefined, () => {
      //     this.onBack();
      //   }))
     .menus(this.isFromArrangeContactsPage ?  this.TitleGuide() : undefined)
     .title(this.selectCount > 0
       ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectCount)
       : ResourceUtil.getStringByResource($r('app.string.not_selected')),
       {
         mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
         paddingStart: EnvironmentProp.isPC() ? LengthMetrics.vp(16)
           : LengthMetrics.resource($r('sys.float.margin_left'))
       })
      .onShown(() => {
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.destinationPageHide();
      })
      .padding({
        top: this.isFromArrangeContactsPage ? 8 : px2vp(this.fullScreenPadding.top as number),
        bottom: this.contactsTotal === 0 ? 0 : px2vp(this.fullScreenPadding.bottom as number)
      })
    }
  }

  // 删除进度条的弹窗
  progressDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      contentBuilder: () => {
        this.ProgressDialogBuilder();
      }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        HiLog.w(TAG, `delete press_back do not close`);
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        HiLog.w(TAG, `delete touch_outside do not close`);
      }
    }
  });

  @Builder
  BatchDeleteBuilder() {
    if (this.contactsListInited || this.contactsTotal === -1) {
      Column() {
        if (this.contactsTotal === 0) {
          NoContactsEmptyView()
        } else {
          ContactsList({
            presenter: $mPresenter,
            longPressSelectContactId: this.longPressSelectContactId,
            isFromArrangeContactsPage: this.isFromArrangeContactsPage
          })
            .layoutWeight(1)
          if (!this.isPC || this.isFromArrangeContactsPage) {
            WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
              ToolBar({
                activateIndex: (this.selectCount === this.contactsTotal && this.contactsTotal > 0) ? 1 : -1,
                dividerModifier: new DividerModifier().height(0),
                toolBarList: this.toolbarList,
              })
                .id('batch_select_contacts_tool_bar')
                .width('100%')
                .height($r('app.float.id_toolbar_height'))
                .backgroundColor($r('app.color.color_bind_sheet_background'))
            }
          }
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: EnvironmentProp.isPC() ? {
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.color_bind_sheet_background')
  //         }
  //       }
  //     } : undefined,
  //     avoidLayoutSafeArea: this.isFromArrangeContactsPage ? false : true,
  //     padding: { start: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
  //       LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.selectCount },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }

  private onBack() {
    HiLog.i(TAG, 'onBackPressed')
    // 联系人打点--整理联系人批量删除取消批量删除
    if (this.mPresenter.contactsTotal === this.mPresenter.selectCount) {
      this.batchDeleteParams.NUM = 2;
    } else if (this.selectCount > 1) {
      this.batchDeleteParams.NUM = 1;
    } else if (this.selectCount === 1) {
      this.batchDeleteParams.NUM = 0;
    } else {
      this.batchDeleteParams.NUM = -1;
    }
    this.batchDeleteParams.ISCLICK = 0;
    DotUtil.getInstance().contactDot(this.batchDeleteParams, ORGANIZE_BATCH_DELETE_EVENT);
    this.toBatchDeleteContactsNavStack.pop(this.isFromArrangeContactsPage);
    return true;
  }

  @Builder
  ProgressDialogBuilder() {
    Column() {
      ProgressBarContent({
        percent: this.percent,
        progressText: $r('app.string.deleting_contacts'),
      })
    }
    .width('100%')
  }

  @Builder
  DeleteContactDialog() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text((this.mPresenter.selectCount == 1 ? $r('app.string.delete_contact_tips_one') :
              $r('app.string.delete_contact_tips')))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Regular)
              .width('100%')
              .fontColor($r('app.color.skin_font_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 4 : 10)
              .textAlign(TextAlign.Start);
          }
          .constraintSize({ minHeight: $r('app.float.id_setting_22') })

          Row() {
            Column() {
              Checkbox()
                .height($r('app.float.id_card_margin_max'))
                .width($r('app.float.id_card_margin_max'))
                .select(false)
                .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
                .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                .margin($r('sys.float.padding_level0'))
                .padding($r('sys.float.padding_level1'))
                .selectedColor($r('app.color.skin_comp_background_emphasize'))
                .onChange((value: boolean) => {
                  this.checkState = value;
                })
            }
            .padding({
              end: LengthMetrics.resource($r('sys.float.padding_level6'))
            })

            Column() {
              Text($r('app.string.read_and_understand'))
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_card_title_margin_top') })
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Subtitle_S'))
                .fontWeight(FontWeight.Regular)
            }
            .layoutWeight(1)
          }
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })

          //为了分屏状态下,开启关怀模式弹出框显示正常
          CustomButtons({
            confirmButtonEnabled: this.checkState,
            isErrorConfirmButton: true,
            cancelButtonText: $r('app.string.dialog_cancel'),
            confirmButtonText: $r('app.string.dialog_delete'),
            onCancel: () => {
              // 整理联系人-批量删除-删除弹窗-取消
              this.organizeBatDelDialogParams.ISDELETE = 0;
              DotUtil.getInstance().contactDot(this.organizeBatDelDialogParams, ORGANIZE_BATDEL_DIALOG_EVENT);
              this.deleteDialogControler?.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              HiLog.i(TAG, 'onDeleteDialogCancel !!!');
            },
            onConfirm: () => {
              if (this.checkState) {
                // 整理联系人-批量删除-删除弹窗-确定
                this.organizeBatDelDialogParams.ISDELETE = 1;
                DotUtil.getInstance().contactDot(this.organizeBatDelDialogParams, ORGANIZE_BATDEL_DIALOG_EVENT);
                this.deleteDialogControler?.close();
                DialogControllerManager.getInstance().dialogControllerSet.clear();
                this.mPresenter.delete();
                if (Number(this.mPresenter.selectCount) > 500) {
                  this.percent = 0;
                  this.progressCount = 0;
                  this.progressDialog.open();
                  DialogControllerManager.getInstance().addDialogController(this.progressDialog);
                } else {
                  this.isFromArrangeContactsPage ? this.toBatchDeleteContactsNavStack.pop() :
                  this.toBatchDeleteContactsNavStack?.clear(false);
                }
              }
            }
          })
            .padding({ bottom: this.splitStatus === SplitStatus.ONE_THREE_SPLIT ? 24 : 0 })
            .visibility((DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ||
              (this.splitStatus === SplitStatus.VERTICAL_SPLIT) ?
            Visibility.Visible : Visibility.None)
        }
        .width('100%')
        .padding({
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        })
        .margin({
          bottom: $r('sys.float.padding_level4')
        })
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .constraintSize({ maxHeight: '67%' })

      CustomButtons({
        confirmButtonEnabled: this.checkState,
        isErrorConfirmButton: true,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.dialog_delete'),
        onCancel: () => {
          // 整理联系人-批量删除-删除弹窗-取消
          this.organizeBatDelDialogParams.ISDELETE = 0;
          DotUtil.getInstance().contactDot(this.organizeBatDelDialogParams, ORGANIZE_BATDEL_DIALOG_EVENT);
          this.deleteDialogControler?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          HiLog.i(TAG, 'onDeleteDialogCancel !!!');
        },
        onConfirm: () => {
          if (this.checkState) {
            // 整理联系人-批量删除-删除弹窗-确定
            this.organizeBatDelDialogParams.ISDELETE = 1;
            DotUtil.getInstance().contactDot(this.organizeBatDelDialogParams, ORGANIZE_BATDEL_DIALOG_EVENT);
            this.deleteDialogControler?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.mPresenter.delete();
            if (Number(this.mPresenter.selectCount) > 500) {
              this.percent = 0;
              this.progressCount = 0;
              this.progressDialog.open();
              DialogControllerManager.getInstance().addDialogController(this.progressDialog);
            } else {
              this.isFromArrangeContactsPage ? this.toBatchDeleteContactsNavStack.pop() :
              this.toBatchDeleteContactsNavStack?.clear(false);
            }
          }
        }
      })
        .visibility((DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ||
          (this.splitStatus === SplitStatus.VERTICAL_SPLIT) ?
        Visibility.None : Visibility.Visible)
    }
    .width('100%')
  }
}

@Component
struct ContactsList {
  @Link presenter: BatchDeleteContactsPresenter;
  private scroller: Scroller = GlobalContext.getContext().getObject('scrollerDeleteContacts') as Scroller;
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = false;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State preListItemNum: number = 0;
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);
  @Prop isFromArrangeContactsPage: boolean;
  @Prop longPressSelectContactId: string | undefined;

  private initialIndex: number = 0;

  aboutToAppear(): void {
    HiLog.i(TAG, `longPressSelectContactId: ${this.longPressSelectContactId}`);

    // 如果是从联系人列表中长按某个联系人进入的，默认选中该联系人，并且列表起始位置在该联系人
    if (this.longPressSelectContactId) {
      this.initialIndex = this.presenter.contactListDataSource.contactList.map(contact => contact.contactId)
        .indexOf(this.longPressSelectContactId);
      this.presenter.selectedContacts.add(this.longPressSelectContactId);
      this.presenter.refreshPageMessage();
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        List({ initialIndex: this.initialIndex, scroller: this.scroller }) {
          LazyForEach(this.presenter.contactListDataSource, (item: ContactListShowInfo, index: number) => {
            ListItem() {
              BatchDeleteItemView({
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
        .safeAreaPadding({ top: EnvironmentProp.isPC() ? 0 : this.isFromArrangeContactsPage ? $r('app.float.id_item_height_max') : $r('app.float.id_hds_title_margin') })
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
          this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;

          // 通过长按联系人方式进入批量操作页面，设置当前索引条的位置
          if (this.longPressSelectContactId) {
            if (this.isAlphabetClicked === this.dragList) {
              firstIndex = this.presenter.contactListDataSource.contactList.map(contact => contact.contactId)
                .indexOf(this.longPressSelectContactId);
              this.alphabetSelected = AlphabetIndexerPresenter.getInstance().getAlphabetSelected(firstIndex);
            }
            HiLog.i(TAG, `get by current select contact firstIndex: ${firstIndex}, alphabetSelected: ${this.alphabetSelected}`)
          }

          this.presenter.sceillOnlenth = (lastIndex - firstIndex) + 1
          if (!this.isAlphabetClicked && this.dragList) {
            this.alphabetSelected = AlphabetIndexerPresenter.getInstance().getAlphabetSelected(firstIndex);
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
            for (let i = 0; i < this.presenter.contactListDataSource.totalCount(); ++i) {
              let item = this.presenter.contactListDataSource.getData(i);
              let selectStatus = this.presenter.selectedContacts.has(item?.contactId);
              this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
              this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
            }
            this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
          })
          .onActionUpdate((event: GestureEvent) => {
            let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
              let curSelectStatus = false;
              if (index >= 0) {
                let item = this.presenter.contactListDataSource.getData(index);
                curSelectStatus = this.presenter.selectedContacts.has(item?.contactId);
              }
              return curSelectStatus;
            });
            updateIndexes.forEach((index) => {
              if (index >= 0) {
                let item = this.presenter.contactListDataSource.getData(index);
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
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number
          this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
          this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
        })

        if (DisplaySplitUtil.isShowIndex(this.splitStatus)) {
          AlphabetIndexerPage({
            scroller: this.scroller,
            selected: this.alphabetSelected,
            isClicked: $isAlphabetClicked,
            isAutoCollapse: true,
            preIndexNum: this.preListItemNum,
            scrollIndexOffset: false
          })
            .visibility(this.isShowSmartWindow ? Visibility.None : Visibility.Visible)
            .margin({ top: this.isFromArrangeContactsPage ? 80 :  118})
        }
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.color_bind_sheet_background'))
  }
}

@Component
struct NoContactsEmptyView {
  @State presenter: BatchDeleteContactsPresenter = BatchDeleteContactsPresenter.getInstance();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Column() {
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: $r('app.string.no_contacts'),
      //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
      //   fullPage: true,
      //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('app.color.color_bind_sheet_background'),
      // })
    }
    .width('100%')
    .height('100%')
  }
}

@Reusable
@Component
struct BatchDeleteItemView {
  @Prop private item: ContactListShowInfo
  @Prop private index: number
  @State photoPixelMap: PixelMap | null = null;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State mPresenter: BatchDeleteContactsPresenter = BatchDeleteContactsPresenter.getInstance();
  @State checked: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  aboutToAppear() {
    emitter.on(BatchDeleteContactsPresenter.BATCH_DELETE_ITEM_CHECKED, (eventData: emitter.EventData) => {
      let contactId = eventData.data?.contactId as string;
      if (!contactId || this.item.contactId === contactId) {
        this.checked = this.mPresenter.selectedContacts.has(this.item.contactId);
      }
    })
    getPixelMapFromFile(this.item.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
    this.checked = this.mPresenter.selectedContacts.has(this.item.contactId);
  }

  aboutToDisappear(): void {
    emitter.off(BatchDeleteContactsPresenter.BATCH_DELETE_ITEM_CHECKED);
  }

  aboutToReuse(params: LooseObject): void {
    this.item = params.item;
    this.index = params.index;
    getPixelMapFromFile(this.item.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
    this.checked = this.mPresenter.selectedContacts.has(this.item.contactId);
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
        if (this.item.isShowIndex as boolean && !StringUtil.isEmpty(this.item.namePrefix)) {
          SubHeader({
            secondaryTitle: this.item.namePrefix,
            secondaryTitleModifier: this.isThemeActive ?
            new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
          })
            .width('100%')
            .height($r('app.float.id_item_height_large'))
            .margin({
              start: LengthMetrics.vp(-24)
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
                  this.photoPixelMap = null;
                })
            } else if (StringUtil.isEmpty(this.item.headChar)) {
              Image(StringUtil.isEmpty(this.item.portraitPath) ? $r('app.media.ic_user_portrait') :
              this.item.portraitPath)
                .width($r('app.float.id_card_image_mid'))
                .height($r('app.float.id_card_image_mid'))
                .objectFit(ImageFit.Auto)
                .borderRadius($r('app.float.id_card_image_mid'))
                .draggable(false)
                .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
                .backgroundColor(
                  StringUtil.isEmpty(this.item.portraitPath) ?
                  $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
                )
            } else {
              Text(this.item.headChar)
                .fontSize('16vp')
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
                .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
                .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
                .width($r('app.float.id_card_image_mid'))
                .textAlign(TextAlign.Center)
                .borderRadius($r('app.float.id_card_image_mid'))
                .accessibilityLevel('no')
            }
          }
          .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
          .width($r('app.float.id_card_image_mid'))

          Column() {
            if (FontScaleState.isStandardGeer(this.fontSizeScale)) {
              Text(this.item.contactTitle)
                .contentGeneraStyle()
                .lineHeight('21vp')
                .maxLines(2)
                .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
            } else {
              Row() {
                Text(this.item.contactTitle)
                  .contentGeneraStyle()
                  .margin({
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      $r('sys.float.padding_level5'), $r('app.float.dialer_button_text_font_size')),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      $r('sys.float.padding_level5'), $r('app.float.dialer_button_text_font_size'))
                  })
                  .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
              }
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
              })
            }
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
          .flexShrink(1)
          .constraintSize({ minHeight: $r('app.float.id_item_height_max') })

          Toggle({
            type: ToggleType.Checkbox,
            isOn: this.checked
          })
            .size({ width: 20, height: 20 })
            .margin($r('sys.float.padding_level1'))
            .flexShrink(0)
            .enabled(true)
            .hitTestBehavior(HitTestMode.None)
            .selectedColor($r('app.color.skin_comp_background_emphasize'))
            .focusable(false)
            .accessibilityLevel('no')
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({
          start: LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
          end: LengthMetrics.resource($r('app.float.id_card_margin_xxxxl'))
        })
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
        .id(`BatchSelectSetItemView_${this.index}_chick_Row`)
        .stateStyles({
          pressed: this.pressedStyles,
          normal: this.normalStyles
        })
        .onClick(() => {
          this.mPresenter.onItemClick(this.item, this.index);
        })
        .accessibilityChecked(this.checked)
        .focusable(true)
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
      }

      if (this.item.isShowDivifer) {
        Divider()
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .margin({
            start: LengthMetrics.resource($r('app.float.id_card_divider_left')),
            end: LengthMetrics.resource($r('sys.float.padding_level16'))
          })
      }
    }
  }
}