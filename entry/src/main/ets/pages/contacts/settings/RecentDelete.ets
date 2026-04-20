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
import { ResourceUtil } from '../../../util/ResourceUtil';
import RecentDeletePresenter from '../../../presenter/contact/settings/RecentDeletePresenter';
import { HiLog, StringUtil } from '../../../../../../../feature/call/oh_modules/common';
import RecentDeleteBean from '../../../model/bean/RecentDeleteBean';
import { AlertDialog, CustomContentDialog, LoadingDialog } from '@ohos.arkui.advanced.Dialog';
import promptAction from '@ohos.promptAction';
import emitter from '@ohos.events.emitter';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { ToolBar, ToolBarOptions } from '@kit.ArkUI';
import { ToolBarModifier } from '@ohos.arkui.advanced.ToolBar';
import { DividerModifier, SymbolGlyphModifier } from '@ohos.arkui.modifier';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { LengthMetrics } from '@ohos.arkui.node';
import { FontScaleState } from '../../../util/fontScaleState';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import DotUtil from '../../../util/DotUtil';
import dotCommon, { customParams, recentDeleteDialogContactParams } from '../../../../ets/util/DotCommon';
import { clearContactParams } from '../../../util/DotCommon';
import { TextModifier } from '@kit.ArkUI';
import ProgressBarContent from '../../dialog/ProgressBarContent';
import EmitterConstant from '../../../data/EmitterConstant';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import LooseObject from '../../../model/type/LooseObject';
import { SlidingMultipleSelectionsUtil } from '../../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import { BlurStrategy, HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { i18n } from '@kit.LocalizationKit';
import { GlobalContext } from '../../../util/GlobalContext';
import RecentDeleteDataSource from '../../../model/bean/RecentDeleteDataSource';

const TAG = 'RecentDelete';
const RETENTION_DAYS = 30;
const TITLE_BAR_MARGIN_LG: number = 24;
const TITLE_BAR_MARGIN_SM: number = 16;
const DELETE_TIME_RIGHT_MARGIN: number = 8;
const NAME_RIGHT_MARGIN: number = 16;
const TOOL_BRA_HEIGHT: number = 52;

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

enum ItemState {
  ENABLE = 1,
  DISABLE = 2,
  ACTIVATE = 3
}

interface ToolbarParams {
  selectRecentDeleteChange: boolean;
  selectedCount: number;
  isSelectAll: boolean;
}

@Builder
export function RecentDeleteLoader($$: Params): void {
  RecentDelete();
}

@Component
export default struct RecentDelete {
  @StorageLink('breakpoint') curBp: string = 'sm';
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State @Watch('isBottomChange') mPresenter: RecentDeletePresenter = RecentDeletePresenter.getInstance();
  @StorageLink('isRestoreFinish') @Watch('isRestoreStateChange') isRestoreFinish: boolean = false;
  @StorageLink('allSelectedIdCount') allSelectedIdCount: number = 0;
  @StorageLink('isShowProgress') isShowProgress: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State toolbarList: ToolBarOptions = new ToolBarOptions();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  public refreshContactsEmitterId: number = 108;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // progressCount
  @State progressCount: number = 0;
  // percent
  @State percent: number = 0;
  @State toolBarModifier: ToolBarModifier =
    new ToolBarModifier()
      .height(LengthMetrics.vp(TOOL_BRA_HEIGHT))
      .backgroundColor(Color.Transparent)
      .padding(this.curBp === 'lg' ? LengthMetrics.vp(TITLE_BAR_MARGIN_LG) : LengthMetrics.vp(TITLE_BAR_MARGIN_SM))
  @State dividerModifier: DividerModifier = new DividerModifier().height(0);
  private recentDeletePresenter: RecentDeletePresenter = RecentDeletePresenter.getInstance()
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State curSelectRecentDelete: boolean = false;
  @State isSelectAll: boolean = false;
  @State selectedCount: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear start!');
    this.mPresenter.refreshUI = () => {
      HiLog.i(TAG, 'refreshUI')
      this.isBottomChange();
    }
    GlobalContext.getContext().setObject('scrollerRecentDeleteContacts', this.scroller);
    this.mPresenter.initNavPaths(this.contactsSettingsNavStack);
    this.mPresenter.initRecentDeleteContacts();
    let event: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_RECENT_DELETE_EVENT_ID
    }
    // 最近删除进度条
    emitter.on(event, (eventData: emitter.EventData) => {
      if (eventData.data) {
        this.progressCount += eventData.data.selectedCounts;
        this.percent = Math.round((this.progressCount / this.allSelectedIdCount) * 100);
        // 如果进度完成,弹窗关闭
        if (this.progressCount === this.allSelectedIdCount) {
          this.progressDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          setTimeout(() => {
            this.progressCount = 0;
            this.percent = 0;
          }, 1000);
        }
      }
    })
    this.mPresenter.resetDefaultValue();
    HiLog.w(TAG, 'aboutToAppear end');
  }

  aboutToDisappear() {
    GlobalContext.getContext().removeObject('scrollerRecentDeleteContacts');
    HiLog.i(TAG, 'aboutToDisappear recentDelete')
  }

  isBottomChange() {
    this.curSelectRecentDelete = this.mPresenter.selectRecentDeleteChange;
    this.isSelectAll = this.mPresenter.checkedStatus.size === this.mPresenter.recentDeleteList.length;
    this.selectedCount = this.mPresenter.checkedStatus.size;
  }

  resetRecentDelete() {
    HiLog.w(TAG, 'resetRecentDelete');
    this.mPresenter.resetData();
    this.deleteDialogController = null;
    emitter.off(EmitterConstant.EMITTER_RECENT_DELETE_EVENT_ID);
  }

  onBackPress(): boolean | void {
    HiLog.w(TAG, 'onBackPress');
    if (this.mPresenter.selectRecentDeleteChange) {
      this.mPresenter.resetDefaultValue();
      this.isRestoreFinish = false;
    } else {
      this.mPresenter.back();
    }
  }

  isRestoreStateChange() {
    HiLog.w(TAG, 'isRestoreStateChange: start isRestoreFinish = ' + this.isRestoreFinish);
    let count: number = 0;
    if (this.isRestoreFinish) {
      // 判断是否全部恢复
      HiLog.w(TAG,
        `recentDeleteCount: ${this.mPresenter.recentDeleteCount}, recentDeleteTotal: ${this.mPresenter.recentDeleteTotal}`);
      if (this.mPresenter.recentDeleteCount === 0) {
        count = this.mPresenter.checkedStatus.size;
      } else {
        count = this.mPresenter.recentDeleteTotal - this.mPresenter.recentDeleteCount;
      }
      HiLog.w(TAG, `isRestoreStateChange recovered: ${count}`);
      setTimeout(() => {
        this.restoreDialog.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
        HiLog.w(TAG, 'restoreDialog close');
        promptAction.showToast({
          message: $r('app.plural.contacts_restored', count, count),
          duration: 2000,
          bottom: 80 + px2vp(this.fullScreenPadding.bottom as number)
        });
        this.mPresenter.resetDefaultValue();
        this.isRestoreFinish = false;
        HiLog.w(TAG, `isRestoreStateChange isRestoreFinish: ${this.isRestoreFinish}`);
        this.refreshContactList();
      }, 800);
    } else {
      HiLog.w(TAG, 'no result, return');
      return;
    }
  }

  refreshContactList() {
    HiLog.w(TAG, 'restore finish, refreshContactList!');
    let refreshContactsEvent: emitter.InnerEvent = {
      eventId: this.refreshContactsEmitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(refreshContactsEvent);
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

  deleteDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: this.mPresenter.getDeleteDialogTitle(),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          if (this.mPresenter.selectRecentDeleteChange) {
            recentDeleteDialogContactParams.ISDELETE = dotCommon.eventParam.DIALOG_CANCEL;
            // 联系人打点-点击删除弹窗-取消
            DotUtil.getInstance().contactDot(recentDeleteDialogContactParams,
              dotCommon.eventName.RECENTDEL_DELETE_DIALOG_EVENT);
          } else {
            // 联系人打点-点击清空弹窗-取消清空
            clearContactParams.CLEAR = dotCommon.eventParam.DIALOG_CANCEL;
            DotUtil.getInstance().contactDot(clearContactParams, dotCommon.eventName.RECENTDEL_CLEAR_DIALOG_EVENT);
          }
          this.deleteDialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: this.mPresenter.selectRecentDeleteChange ? $r('app.string.dialog_delete') :
        $r('app.string.contacts_clean_button'),
        action: () => {
          if (this.mPresenter.selectRecentDeleteChange) {
            recentDeleteDialogContactParams.ISDELETE = dotCommon.eventParam.DIALOG_DELETE;
            // 联系人打点-点击删除弹窗-删除
            DotUtil.getInstance().contactDot(recentDeleteDialogContactParams,
              dotCommon.eventName.RECENTDEL_DELETE_DIALOG_EVENT);
          } else {
            // 联系人打点-点击清空弹窗-清空
            clearContactParams.CLEAR = dotCommon.eventParam.DIALOG_CLEAR;
            DotUtil.getInstance().contactDot(clearContactParams, dotCommon.eventName.RECENTDEL_CLEAR_DIALOG_EVENT);
          }
          this.mPresenter.deleteContacts();
          // 操作点击删除或者清空按钮出现进度条弹窗
          if (this.isShowProgress) {
            this.progressDialog?.open();
            this.isShowProgress = false;
            DialogControllerManager.getInstance().addDialogController(this.progressDialog);
          }
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  restoreDialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.contacts_restoring')
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        HiLog.w(TAG, `restore press_back do not close`);
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        HiLog.w(TAG, `restore touch_outside do not close`);
      }
    }
  });
  // 删除进度条的弹窗
  progressDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      contentBuilder: () => {
        this.ProgressDialogBuilder();
      }
    }),
    maskColor: $r('sys.color.ohos_id_color_mask_thin'),
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

  getContactsRecycleTips(): string {
    let tips: string;
    HiLog.w(TAG, 'getContactsRecycleTips');
    tips = ResourceUtil.getStringByResource($r('app.string.contacts_recycle_tips_normal'), RETENTION_DAYS);
    return tips;
  }

  build() {
   NavDestination() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
            Row() {
              Text(this.getContactsRecycleTips())
                .align(Alignment.Center)
                .textAlign(TextAlign.Start)
                .fontSize(!FontScaleState.isSmallerSixGeer(this.fontSizeScale) ? '24vp' : $r('sys.float.Body_S'))
                .maxFontScale(2)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                .fontWeight(FontWeight.Regular)
                .constraintSize({
                  minHeight: this.curBp === 'lg' ? $r('app.float.id_card_margin_xxl')
                    : $r('app.float.id_recycle_contacts_tips_height')
                })
                .layoutWeight(1)
            }
            .margin({
              top:  $r('app.float.id_card_margin_xxl'),
              bottom: this.mPresenter.getRecentDeleteCount() > 0 ? $r('app.float.id_card_margin_xxl')
                     : $r('sys.float.padding_level0'),
              left: this.curBp === 'lg' ? $r('app.float.id_tips_text_margin_lg')
                     : $r('app.float.id_tips_text_margin_sm'),
              right: this.curBp === 'lg' ? $r('app.float.id_tips_text_margin_lg')
                     : $r('app.float.id_tips_text_margin_sm'),
            })
            .visibility(this.splitStatus === SplitStatus.HALF_SPLIT ||
              this.splitStatus === SplitStatus.ONE_THREE_SPLIT ||
              (this.splitStatus === SplitStatus.VERTICAL_SPLIT && !DisplaySplitUtil.isFoldStatus()) ?
                Visibility.None : Visibility.Visible)

            if (this.mPresenter.getRecentDeleteCount() <= 0) {
              ContactEmptyPage()
            } else {
              RecentDeleteContactList({ presenter: $mPresenter })
              Stack({ alignContent: Alignment.Bottom }) {
                WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
                  if (this.curSelectRecentDelete) {
                    ToolBar({
                      toolBarModifier: this.toolBarModifier,
                      dividerModifier: this.dividerModifier,
                      activateIndex: this.isSelectAll ? 2 : -1,
                      toolBarList: [
                        {
                          content: $r('app.string.delete'),
                          toolBarSymbolOptions: {
                            normal: new SymbolGlyphModifier($r('sys.symbol.trash'))
                              .fontColor([$r('app.color.skin_icon_primary')]),
                          },
                          state: this.selectedCount > 0 ? ItemState.ENABLE : ItemState.DISABLE,
                          action: () => {
                            // 联系人打点-最近删除操作-点击删除
                            this.mPresenter.recentDeleteOperate(dotCommon.eventParam.CLICK_DELETE);
                            this.deleteDialogController?.open();
                          }
                        },
                        {
                          content: $r('app.string.contacts_restore'),
                          toolBarSymbolOptions: {
                            normal: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise'))
                              .fontColor([$r('app.color.skin_icon_primary')]),
                          },
                          state: this.selectedCount > 0 ? ItemState.ENABLE : ItemState.DISABLE,
                          action: () => {
                            HiLog.w(TAG, 'onclick restore in selected page');
                            // 联系人打点-最近删除操作-点击恢复(内部)
                            this.mPresenter.recentDeleteOperate(dotCommon.eventParam.CLICK_RESTORE);
                            this.mPresenter.restoreContacts();
                            this.restoreDialog.open();
                          }
                        },
                        {
                          content: this.isSelectAll ? $r('app.string.unselect_all') : $r('app.string.select_all'),
                          toolBarSymbolOptions: {
                            normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square'))
                              .fontColor([$r('app.color.skin_font_primary')]),
                            activated: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill'))
                              .fontColor([$r('app.color.skin_icon_emphasize')]),
                          },
                          state: ItemState.ACTIVATE,
                          action: () => {
                            this.mPresenter.checkAll();
                          }
                        }
                      ],
                    })
                  } else {
                    ToolBar({
                      toolBarModifier: this.toolBarModifier,
                      dividerModifier: this.dividerModifier,
                      activateIndex: this.isSelectAll ? 2 : -1,
                      toolBarList: [
                        {
                          content: $r('app.string.contacts_clean_button'),
                          toolBarSymbolOptions: {
                            normal: new SymbolGlyphModifier($r('sys.symbol.trash'))
                              .fontColor([$r('app.color.skin_icon_primary')]),
                          },
                          state: ItemState.ENABLE,
                          action: () => {
                            // 联系人打点-最近删除-点击清空
                            DotUtil.getInstance().contactDot(customParams,
                              dotCommon.eventName.RECENT_DELETE_CLEAR_EVENT);
                            this.deleteDialogController?.open();
                          }
                        },
                        {
                          content: $r('app.string.contacts_restore'),
                          toolBarSymbolOptions: {
                            normal: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise'))
                              .fontColor([$r('app.color.skin_icon_primary')]),
                          },
                          state: ItemState.ENABLE,
                          action: () => {
                            HiLog.w(TAG, 'onclick restore in selected page');
                            // 联系人打点-最近删除-点击恢复(外部)
                            DotUtil.getInstance()
                              .contactDot(customParams, dotCommon.eventName.RECENT_DELETE_RESTORE_EVENT);
                            this.mPresenter.setRestoreToSelect();
                          }
                        }
                      ]
                    })
                  }
                }
              }
              .width('100%')
              .height($r('app.float.id_toolbar_height'))
              .flexShrink(0)
            }
          }
          .height('100%')
          .backgroundColor($r('app.color.color_bind_sheet_background'))
        }
      }
      .height('100%')
      .width('100%')
      .padding({top: $r('app.float.id_item_height_max')})
    }
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.onBack();
    // }))
   .title(!this.curSelectRecentDelete ?
           ResourceUtil.getStringByResource($r('app.string.contacts_recycle')) : (this.selectedCount > 0
       ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectedCount)
       : ResourceUtil.getStringByResource($r('app.string.not_selected'))),
     {
       mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
       paddingStart: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
             this.curBp === 'lg' ? LengthMetrics.vp(TITLE_BAR_MARGIN_LG) : LengthMetrics.vp(TITLE_BAR_MARGIN_SM),
       paddingEnd:this.curBp === 'lg' ? LengthMetrics.vp(TITLE_BAR_MARGIN_LG) : LengthMetrics.vp(TITLE_BAR_MARGIN_SM)
     })
   .menus(this.TitleGuide())
   .onBackPressed(() => {
     HiLog.w(TAG, 'onBackPressed TitleBar');
     // 联系人打点-最近删除操作-未点击删除、恢复
     this.mPresenter.recentDeleteOperate(dotCommon.eventParam.NOT_CLICK);
     this.mPresenter.back();
     return true;
   })
    .onWillDisappear(() => {
      HiLog.w(TAG, 'onWillDisappear');
      this.resetRecentDelete();
    })
    .backgroundColor($r('app.color.color_bind_sheet_background'))
    .padding({
      bottom: px2vp(this.fullScreenPadding.bottom as number)
    })
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
      .id('RecentDelete_close_btn')
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

  private onBack() {
    HiLog.w(TAG, 'onBackPressed TitleBar');
    // 联系人打点-最近删除操作-未点击删除、恢复
    this.mPresenter.recentDeleteOperate(dotCommon.eventParam.NOT_CLICK);
    this.mPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: {
  //       blurStrategy: BlurStrategy.DISABLE,
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {2
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.color_bind_sheet_background')
  //         }
  //       }
  //     },
  //     avoidLayoutSafeArea: false,
  //     padding: { start: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
  //       this.curBp === 'lg' ? LengthMetrics.vp(TITLE_BAR_MARGIN_LG) : LengthMetrics.vp(TITLE_BAR_MARGIN_SM),
  //       end: this.curBp === 'lg' ? LengthMetrics.vp(TITLE_BAR_MARGIN_LG) : LengthMetrics.vp(TITLE_BAR_MARGIN_SM)},
  //     title: { title: !this.curSelectRecentDelete ?
  //       ResourceUtil.getStringByResource($r('app.string.contacts_recycle')) : '',
  //       isMultipleSelectState: this.curSelectRecentDelete, selectedNumber: this.selectedCount },
  //     backIcon: {isThemeActive: this.isThemeActive, backIcon: true}
  //   };
  // }
}

@Component
struct ContactEmptyPage {
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Scroll() {
      Column() {
        // PafEmptyPage({
        //   icon: $r('app.media.ic_empty_page_no_contacts'),
        //   emptyDescription: $r('app.string.no_contacts'),
        //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
        //   fullPage: true,
        //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('app.color.color_bind_sheet_background'),
        //   fixedPageHeight: true
        // })
      }
      .width('100%')
    }
    .padding({top:5, bottom:5})
    .layoutWeight(1)
    .flexShrink(1)
  }
}


@Component
struct RecentDeleteContactList {
  @Link presenter: RecentDeletePresenter;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private scroller: Scroller = GlobalContext.getContext().getObject('scrollerRecentDeleteContacts') as Scroller;
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);


  aboutToAppear(): void {
    this.slidingMultipleSelectionsUtil.isSliding = this.presenter.selectRecentDeleteChange;
  }


  build() {
    Column() {
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
          LazyForEach(this.presenter.recentDeleteDataSource, (item: RecentDeleteBean, index: number) => {
            ListItem() {
              RecentDeleteItem({
                item: item,
                index: index,
                presenter: this.presenter,
                isThemeActive: this.isThemeActive,
              })
            }
            .accessibilityLevel(this.presenter.selectRecentDeleteChange ? 'no' : 'yes')
            .onClick(() => {
              if (!this.presenter.selectRecentDeleteChange) {
                return;
              }
              HiLog.w(TAG, 'onClick listitem: ' + item.id.toString());
              this.presenter.itemOnClick(item, index);
            })
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction((event?: GestureEvent) => {
                  this.presenter.processLongPressedItem(item, index);
                })
            )
            .onMouse((event: MouseEvent) => {
              if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
                this.presenter.processLongPressedItem(item, index);
              }
            })
          }, (item: RecentDeleteBean, index: number) => JSON.stringify(item) + index.toString())
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .cachedCount(3)
      .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .margin({
        left: this.curBp === 'lg' ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_margin_xxl'),
        right: this.curBp === 'lg' ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_margin_xxl')
      })
      .divider({
        strokeWidth: '1px',
        color: $r('app.color.skin_ohos_id_color_list_separator'),
        startMargin: $r('app.float.id_card_margin_large'),
        endMargin: $r('app.float.id_card_margin_large')
      })
      .onTouch(() => {
        this.slidingMultipleSelectionsUtil.isSliding = this.presenter.selectRecentDeleteChange;
      })
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
        this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;
      })
      .gesture(PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          for (let i = 0; i < this.presenter.recentDeleteDataSource.totalCount(); ++i) {
            let item = this.presenter.recentDeleteDataSource.getData(i);
            let selectStatus = this.presenter.checkedStatus.has(item?.id);
            this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
          }
          this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
        })
        .onActionUpdate((event: GestureEvent) => {
          let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
            let curSelectStatus = false;
            if (index >= 0) {
              let item = this.presenter.recentDeleteDataSource.getData(index);
              curSelectStatus = this.presenter.checkedStatus.has(item?.id);
            }
            return curSelectStatus;
          });
          updateIndexes.forEach((index) => {
            if (index >= 0) {
              let item = this.presenter.recentDeleteDataSource.getData(index);
              this.presenter.itemOnClick(item, index);
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
    .layoutWeight(1)
    .flexShrink(1)
  }
}

@Reusable
@Component
struct RecentDeleteItem {
  @Prop item: RecentDeleteBean;
  @Prop index: number;
  @Link presenter: RecentDeletePresenter;
  @Prop isThemeActive: boolean;
  @State isChecked: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private selectCallBack: Callback<emitter.EventData> | undefined = undefined;
  private recentDeletePresenter: RecentDeletePresenter = RecentDeletePresenter.getInstance();

  aboutToAppear(): void {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_RECENT_DELETE_ITEM_CHECKED,
    };
    this.selectCallBack = (eventData: emitter.EventData) => {
      let itemId: number | null = eventData.data?.id;
      if (!itemId || this.item.id === itemId) {
        this.isChecked = this.recentDeletePresenter.checkedStatus.has(this.item.id);
      }
    }
    emitter.on(innerEvent, this.selectCallBack);
    this.isChecked = this.recentDeletePresenter.checkedStatus.has(this.item.id);
  }

  aboutToDisappear(): void {
    if (this.selectCallBack) {
      emitter.off(EmitterConstant.EVENT_LIST_RECENT_DELETE_ITEM_CHECKED, this.selectCallBack);
    }
  }

  dataSelectionBroadcast(): string {
    let displayName: string = this.presenter.getAccessibilityDisplayName(this.item.name);
    let remainingDays: string = this.presenter.getAccessibilityRemainingDays(this.item.deleteTime);
    let isCheck: string = '';
    if (this.presenter.selectRecentDeleteChange) {
      isCheck = this.isChecked ? ResourceUtil.getStringByResourceId($r('app.string.accessibility_selected').id) :
      ResourceUtil.getStringByResourceId($r('app.string.accessibility_unselected').id)
    } else {
      isCheck = '';
    }
    return displayName + ' ' + remainingDays + ' ' + isCheck;
  }

  aboutToReuse(params: LooseObject): void {
    this.isChecked = this.recentDeletePresenter.checkedStatus.has(this.item.id);
  }

  build() {
    if (!FontScaleState.isBigerThirdGeer(this.fontSizeScale)) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.presenter.getDisplayName(this.item.name))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .flexShrink(1)
        }
        .flexGrow(1)
        .margin({ right: $r('app.float.id_card_margin_xxl') })
        .alignItems(HorizontalAlign.Start)
        .id('item_name_delete_source')

        if (this.presenter.selectRecentDeleteChange) {
          Text(this.presenter.getRemainingDays(this.item.deleteTime))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .height($r('app.float.id_list_summary_line_height'))
            .margin({ right: $r('app.float.id_card_margin_large') })
            .id('item_delete_time_select')
            .flexShrink(0)
            .padding({
              left: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level4') : 0
            })

          Column() {
            Checkbox()
              .select(this.isChecked)
              .width($r('app.float.id_card_image_small'))
              .height($r('app.float.id_card_image_small'))
              .selectedColor($r('app.color.skin_font_emphasize'))
              .unselectedColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_switch_outline_off') :
                undefined)
              .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_ohos_id_color_primary') } :
                undefined)
              .margin($r('sys.float.padding_level0'))
              .padding($r('sys.float.padding_level1'))
              .onClick((event: ClickEvent) => {
                AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.isChecked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
                  : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
              })
          }
          .enabled(false)
          .flexShrink(0)
          .id('item_checkbox')
        } else {
          Text(this.presenter.getRemainingDays(this.item.deleteTime))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .height($r('app.float.id_list_summary_line_height'))
            .flexShrink(0)
            .id('item_delete_time_no_select')
        }
      }
      .accessibilityLevel(this.presenter.selectRecentDeleteChange ? 'yes' : 'no')
      .accessibilityRole(AccessibilityRoleType.CHECKBOX)
      .accessibilityChecked(this.isChecked)
      .accessibilityDescription(this.presenter.selectRecentDeleteChange ? (this.isChecked ?
        ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_selected')) : ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_deselected'))) : '')
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .padding($r('app.float.id_card_margin_large'))
      .onClick(() => {
        if (!this.presenter.selectRecentDeleteChange) {
          return;
        }
        HiLog.w(TAG, 'onClick listitem: ' + this.item.id.toString());
        this.presenter.itemOnClick(this.item, this.index);
      })
    } else {
      Column() {
        Column() {
          Text(this.item.name)
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .constraintSize({ minHeight: $r('app.float.id_setting_22') })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.presenter.getRemainingDays(this.item.deleteTime))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .margin({ right: $r('app.float.id_card_margin_large') })
            .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })

          if (this.presenter.selectRecentDeleteChange) {
            Column() {
              Checkbox({ name: this.item.id.toString() })
                .select(this.isChecked)
                .width($r('app.float.id_card_image_small'))
                .height($r('app.float.id_card_image_small'))
                .selectedColor($r('app.color.skin_font_emphasize'))
                .unselectedColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_switch_outline_off') :
                  undefined)
                .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_ohos_id_color_primary') } :
                  undefined)
                .margin($r('sys.float.padding_level0'))
                .padding($r('sys.float.padding_level1'))
                .onClick((event: ClickEvent) => {
                  AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.isChecked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
                    : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
                })
            }
            .enabled(false)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: $r('app.float.id_card_margin_sm') })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .flexShrink(0)
      .padding({
        left: $r('app.float.id_card_margin_large'),
        right: $r('app.float.id_card_margin_large'),
        top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
        bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
      })
      .accessibilityLevel(this.presenter.selectRecentDeleteChange ? 'yes' : 'no')
      .accessibilityRole(AccessibilityRoleType.CHECKBOX)
      .accessibilityChecked(this.isChecked)
      .accessibilityDescription(this.presenter.selectRecentDeleteChange ? (this.isChecked ?
        ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_selected')) : ResourceUtil.getStringByResource($r('app.string.accessibility_checkbox_deselected'))) : '')
      .onClick(() => {
        if (!this.presenter.selectRecentDeleteChange) {
          return;
        }
        HiLog.w(TAG, 'onClick listitem: ' + this.item.id.toString());
        this.presenter.itemOnClick(this.item, this.index);
      })
    }

  }
}