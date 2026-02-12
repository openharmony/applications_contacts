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

import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import BatchDeletePresenter from '../../../presenter/dialer/batchdelete/BatchDeletePresenter';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import { AlertDialog, PopoverDialog, PopoverOptions } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { SymbolGlyphModifier, ToolBar, ToolBarOptions, ItemState, LengthMetrics, display,
  ToolBarModifier } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import LooseObject from '../../../model/type/LooseObject';
import { FontScaleState } from '../../../util/fontScaleState';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { accessibility } from '@kit.AccessibilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { TextModifier } from '@kit.ArkUI';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { CallType, FeaturesType, FeaturesUtil } from '../../../../../../../feature/call';
import { CALL_TYPE_CELIA } from '../../../util/CallAssistantUtil';
import { SlidingMultipleSelectionsUtil } from '../../../util/SlidingMultipleSelectionsUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'BatchDeleteRecord ';
const BATCH_DELETE_EVENT = 'BATCH_DELETE_EVENT';
const BATCH_DELETE_DIALOG_EVENT = 'BATCH_DELETE_DIALOG_EVENT';
const ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN = '1';
const ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED = '0';
class MainTitleTextModifier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function BatchDeleteRecordLoader($$: Params): void {
  BatchDeleteRecord();
}

/**
 * Batch Delete Record
 */
@Component
export default struct BatchDeleteRecord {
  // 路径信息
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State mPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  @State @Watch('isSelectAllChange') batchDeletePresenter: BatchDeletePresenter = BatchDeletePresenter.getInstance();
  @StorageLink('recordType') recordType: number = 0;
  // 是否显示拨号盘
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageLink('breakpoint') @Watch('onCurBpChange') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModifier = new MainTitleTextModifier();
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  @State isShow: boolean = false;
  @State changePopoverShow: boolean = true;
  @State popoverOffset: number = 0;
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(48)).backgroundColor(Color.Transparent).stateEffect(true);
  private scroller: Scroller = new Scroller();
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);
  private isPC: boolean = EnvironmentProp.isPC();

  onCurBpChange() {
    HiLog.i(TAG, `onCurBpChange CurBp: ${this.curBp}`)
    if (this.isShow === true) {
      if (this.curBp === 'sm') {
        this.deleteDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
      } else {
        this.deleteDialogController?.close();
      }
      setTimeout(() => {
        this.isShow = true;
      }, 100)
    }
  }

  batchDeleteParams: CustomizedParams = {
    NUM: 0,
    ISDELETE: 0
  };
  batchDeleteDialogParams: CustomizedParams = {
    NUM: 0,
    ISDELETE: 0
  };
  deleteDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: this.batchDeletePresenter.getDeleteDialogTitle(),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          // 批量删除弹窗取消删除
          this.onCancel();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          // 批量删除弹窗删除
          this.onAccept();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  onCancel() {
    if (this.batchDeletePresenter.isSelectAll) {
      this.batchDeleteDialogParams.NUM = 2;
    } else if (this.batchDeletePresenter.selectedCount > 1) {
      this.batchDeleteDialogParams.NUM = 1;
    } else if (this.batchDeletePresenter.selectedCount === 1) {
      this.batchDeleteDialogParams.NUM = 0;
    } else {
      this.batchDeleteDialogParams.NUM = -1;
    }
    this.batchDeleteDialogParams.ISDELETE = 0;
    DotUtil.getInstance().contactDot(this.batchDeleteDialogParams, BATCH_DELETE_DIALOG_EVENT);
    this.deleteDialogController?.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    this.isShow = false;
  }

  onAccept() {
    if (this.batchDeletePresenter.isSelectAll) {
      this.batchDeleteDialogParams.NUM = 2;
    } else if (this.batchDeletePresenter.selectedCount > 1) {
      this.batchDeleteDialogParams.NUM = 1;
    } else {
      this.batchDeleteDialogParams.NUM = 0;
    }
    this.batchDeleteDialogParams.ISDELETE = 1;
    DotUtil.getInstance().contactDot(this.batchDeleteDialogParams, BATCH_DELETE_DIALOG_EVENT);
    this.isShowDial = false;
    this.batchDeletePresenter.deleteEvent();
    this.deleteDialogController?.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    this.isShow = false;
  }

  @Builder dialogBuilder() {
    AlertDialog({
      content: this.batchDeletePresenter.getDeleteDialogTitle(),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor:  this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          // 取消
          this.onCancel();
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        fontColor: $r('sys.color.warning'),
        action: () => {
          // 确认
          this.onAccept();
        }
      },
    });
  }

  async aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.newToolbarList();

    this.batchDeletePresenter.initNavPaths(this.pathInfos);
    AppStorage.SetOrCreate('clearAllRecord', false);
    if (this.mPresenter.tabIndex === 0) {
      this.batchDeletePresenter.callRecordListDataSource = this.mPresenter.mAllCallRecordListDataSource;
    } else {
      this.batchDeletePresenter.callRecordListDataSource = this.mPresenter.mMissCallRecordListDataSource;
    }
    this.batchDeletePresenter.initCallRecordData();
    this.batchDeletePresenter.mergeRule =
      (await sharedPreferencesUtils.getFromPreferences('isCallSettingDataChangeGroupByValue', 'time')) as string;
  }

  newToolbarList() {
    this.toolbarList = [
      {
        content: $r('app.string.delete'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        state: this.batchDeletePresenter.selectedCount > 0 ? 1 : 2,
        action: () => {
          if (this.batchDeletePresenter.isSelectAll) {
            this.batchDeleteParams.NUM = 2;
          } else if (this.batchDeletePresenter.selectedCount > 1) {
            this.batchDeleteParams.NUM = 1;
          } else {
            this.batchDeleteParams.NUM = 0;
          }
          this.batchDeleteParams.ISDELETE = 1;
          DotUtil.getInstance().contactDot(this.batchDeleteParams, BATCH_DELETE_EVENT);
          HiLog.i(TAG, `callLogDeleteButton click curBp == ${this.curBp}`)
          this.isShow = true;
          if (this.curBp === 'sm') {
            this.deleteDialogController?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
          }
        },
      },
      {
        content: this.batchDeletePresenter.isSelectAll ? $r('app.string.unselect_all') : $r('app.string.select_all'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('app.color.skin_font_primary')]),
          activated: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill')).fontColor([$r('app.color.skin_icon_emphasize')]),
        },
        state: ItemState.ACTIVATE,
        action: () => {
          this.batchDeletePresenter.checkAll();
          this.newToolbarList();
        },
      }
    ]
  }

  isSelectAllChange() {
    this.newToolbarList();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    this.batchDeletePresenter.resetData();
    this.deleteDialogController = null;
  }

  @Builder toolBarButton() {
    ToolBar({
      toolBarList: this.toolbarList,
      dividerModifier: new DividerModifier().height(0),
      activateIndex: this.batchDeletePresenter.isSelectAll ? 1 : -1,
      toolBarModifier: this.toolBarModifier,
    })
      .width('100%')
      .height($r('app.float.id_item_height_mid'))
      .onAreaChange((oldValue: Area, newValue: Area) => {
        let popoverOffset = Math.floor((newValue.width as number / 2 - 24) / 2);
        if (this.popoverOffset !== popoverOffset) {
          this.popoverOffset = popoverOffset;
          this.changePopoverShow = !this.changePopoverShow;
        }
      })
  }

  build() {
    if (this.isPC) {
      NavDestination() {
        this.BatchRecordBuilder()
      }
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .title(this.batchDeletePresenter.selectedCount > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.batchDeletePresenter.selectedCount)
        : ResourceUtil.getStringByResource($r('app.string.not_selected')),
        { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) })
      .onBackPressed(() => {
        return this.onBack();
      })
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    } else {
      NavDestination() {
        this.BatchRecordBuilder()
      }
      .bindToScrollable([this.scroller])
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.pathInfos.pop();
      // }))
      .title(this.batchDeletePresenter.selectedCount > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.batchDeletePresenter.selectedCount)
        : ResourceUtil.getStringByResource($r('app.string.not_selected')),
        { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) })
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
        :
        new SymbolGlyphModifier($r('sys.symbol.xmark')))
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    }
  }

  @Builder
  BatchRecordBuilder() {
    Column() {
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        LazyForEach(this.batchDeletePresenter.callRecordListDataSource,
          (item: LooseObject, index?: number | undefined) => {
            ListItem() {
              ContactItem({ batchDeletePresenter: $batchDeletePresenter, item: item, index: index });
            };
          }, (item: Record<string, string | number | boolean | Resource>): string => JSON.stringify(item));
      }
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
        this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;

        this.batchDeletePresenter.sceillOnlenth = (lastIndex - firstIndex) + 1;
      })
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.skin_comp_divider'),
        startMargin: 40,
        endMargin: $r('app.float.id_corner_radius_card_mid')
      })
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.skin_background_primary'))
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .clipContent(ContentClipMode.SAFE_AREA)
      .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
      .flexShrink(1)
      .gesture(PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          for (let i = 0; i < this.batchDeletePresenter.callRecordListDataSource.totalCount(); ++i) {
            let item = this.batchDeletePresenter.callRecordListDataSource.getCallRecord(i);
            let selectStatus = this.batchDeletePresenter.recordSelected.has(item?.id);
            this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
          }
          this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
        })
        .onActionUpdate((event: GestureEvent) => {
          let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
            let curSelectStatus = false;
            if (index >= 0) {
              let item = this.batchDeletePresenter.callRecordListDataSource.getCallRecord(index);
              curSelectStatus = this.batchDeletePresenter.recordSelected.has(item?.id);
            }
            return curSelectStatus;
          });
          updateIndexes.forEach((index) => {
            if (index >= 0) {
              let item = this.batchDeletePresenter.callRecordListDataSource.getCallRecord(index);
              this.batchDeletePresenter.itemOnClick(item);
            }
          });
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
      });

      WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        if (this.curBp !== 'sm') {
          // 形态切换的时候，刷新方位
          if (this.changePopoverShow) {
            PopoverDialog({
              visible: this.isShow,
              popover: {
                width: 323,
                placement: Placement.Bottom,
                autoCancel: true,
                offset: { x: -(this.popoverOffset - 76) },
                arrowOffset: 76,
                builder: () => {
                  this.dialogBuilder();
                }
              },
              targetBuilder: () => {
                this.toolBarButton();
              }
            });
          } else {
            PopoverDialog({
              visible: this.isShow,
              popover: {
                width: 323,
                placement: Placement.Bottom,
                autoCancel: true,
                offset: { x: -(this.popoverOffset - 76) },
                arrowOffset: 76,
                builder: () => {
                  this.dialogBuilder();
                }
              },
              targetBuilder: () => {
                this.toolBarButton();
              }
            });
          }
        } else {
          this.toolBarButton();
        }
      };
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.batchDeletePresenter.selectedCount },
  //     backIcon: { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }

  private onBack(): boolean {
    if (this.batchDeletePresenter.isSelectAll) {
      this.batchDeleteParams.NUM = 2;
    } else if (this.batchDeletePresenter.selectedCount > 1) {
      this.batchDeleteParams.NUM = 1;
    } else if (this.batchDeletePresenter.selectedCount === 1) {
      this.batchDeleteParams.NUM = 0;
    } else {
      this.batchDeleteParams.NUM = -1;
    }
    this.batchDeleteParams.ISDELETE = 0;
    DotUtil.getInstance().contactDot(this.batchDeleteParams, BATCH_DELETE_EVENT);
    this.isShowDial = false;
    this.batchDeletePresenter.back();
    return true;
  }
}

@Component
struct ContactItem {
  @Link batchDeletePresenter: BatchDeletePresenter;
  @Prop item: LooseObject
  @Prop index: number;
  @State isEmergencyNum: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State imgRes?: Resource = undefined;
  @State imgAccessibilityDesc: Resource = $r('app.string.accessibility_dialed_phone');
  @StorageProp('VoiceAppEnabled') @Watch('initImageRes') isVoiceAppEnabled: boolean = true;
  @State checked: boolean = false;
  private selectCallBack: Callback<emitter.EventData> | undefined = undefined;
  private isPC: boolean = EnvironmentProp.isPC();

  aboutToAppear(): void {
    HiLog.i(TAG, 'ContactItem aboutToAppear');
    this.initImageRes();
    this.selectCallBack = (eventData: emitter.EventData) => {
      let contactId = eventData.data?.contactId as number;
      if (!contactId || this.item.id === contactId) {
        this.checked = this.batchDeletePresenter.recordSelected.has(this.item.id as number);
      }
    }
    emitter.on(BatchDeletePresenter.BATCH_DELETE_ITEM_CHECKED, this.selectCallBack);
    this.checked = this.batchDeletePresenter.recordSelected.has(this.item.id as number);
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'ContactItem aboutToDisappear');
    if (this.selectCallBack) {
      emitter.off(BatchDeletePresenter.BATCH_DELETE_ITEM_CHECKED, this.selectCallBack);
    }
  }

  aboutToReuse(): void {
    HiLog.i(TAG, 'ContactItem aboutToReuse');
    this.initImageRes();
    this.checked = this.batchDeletePresenter.recordSelected.has(this.item.id as number);
  }

  build() {
    Row() {
      if (this.fontSizeScale < 1) {
        this.normalLayout()
      } else {
        this.seniorLayout()
      }
    }
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .padding({
      left: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      right: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
    })
  }

  initImageRes() {
    if (this.item.celiaCallType === CALL_TYPE_CELIA && this.isVoiceAppEnabled) {
      this.imgRes = $r('sys.symbol.AI_phone_fill');
      this.imgAccessibilityDesc = $r('app.string.call_assistant_setting_title');
      return;
    }
    switch (this.item.callType) {
      case CallType.IN:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_answered_phone');
        break;
      case CallType.MISSED:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_missed_call');
        break;
      case CallType.OUT:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.arrow_up_right_video_fill') : $r('sys.symbol.phone_arrow_up_right_fill');
        this.imgAccessibilityDesc = $r('app.string.accessibility_dialed_phone');
        break;
      case CallType.REJECTED:
        this.imgRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.item.features) ?
        $r('sys.symbol.xmark_video') : $r('sys.symbol.phone_below_xmark');
        this.imgAccessibilityDesc = $r('app.string.accessibility_rejected_phone');
        break;
      default:
        this.imgRes = undefined;
        this.imgAccessibilityDesc = $r('app.string.accessibility_dialed_phone');
        break;
    }
  }

  @Builder
  normalLayout() {
    Row() {
      SymbolGlyph(this.imgRes == undefined ?
      $r('sys.symbol.xmark_video') : this.imgRes)
        .visibility(this.imgRes == undefined ? Visibility.Hidden : Visibility.Visible)
        .fontSize($r('app.float.dialer_common_small_margin'))
        .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
        .width($r('app.float.dialer_common_small_margin'))
        .margin({
          right: $r('app.float.id_card_margin_large'),
          top: $r('app.float.id_card_item_margin_top'),
          bottom: '35vp'
        })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, this.imgAccessibilityDesc))

      Column() {
        Row() {
          Text(this.getBatchDeleteCallLogItemPrimaryText())
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
            $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
            .constraintSize({ maxWidth: this.curBp == 'sm' ? 160 : 260 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)

          if (this.item.count != 1) {
            Text('(' + this.item.count + ')')
              .fontSize($r('sys.float.Body_L'))
              .fontColor((this.item.callType == 3 || this.item.callType == 5) ?
              $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
              .fontWeight(FontWeight.Medium)
              .padding({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })
              .maxLines(1)
          }
        }
        .constraintSize({ minHeight: this.isPC ? 22 : undefined })

        Row() {
          if (this.haveMultiSimCard) {
            SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize($r('app.float.id_card_image_xs'))
              .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
              .margin({ right: $r('app.float.id_card_margin_mid') })
          }

          if (StringUtil.isEmpty(this.item.displayName)) {
            Text(this.getBatchDeleteCallLogItemSecondaryText())
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_ohos_id_color_secondary'))
          } else {
            Text((this.item.numberLocation && this.item.numberLocation !== 'N') ?
              this.item.numberLocation as string : this.item.phoneNumber as string)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_font_secondary'))
          }
        }
        .margin({ top: $r('sys.float.padding_level1') })
        .constraintSize({ minHeight: this.isPC ? 19 : undefined })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ right: $r('sys.float.padding_level4') })
      .justifyContent(FlexAlign.Center)
      .height(this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max'))

      Row() {
        Text(this.item.createTime as string)
          .fontSize($r('sys.float.Body_M'))
          .margin({
            end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) :
            LengthMetrics.resource($r('sys.float.ohos_id_text_margin_horizontal')),
            top: $r('app.float.id_card_margin_sm') })
          .fontColor($r('app.color.skin_ohos_id_color_secondary'))
          .textAlign(TextAlign.End)
          .fontWeight(FontWeight.Regular)
          .accessibilityText(this.item.createTimeAccessibilityText)

        Toggle({
          type: ToggleType.Checkbox,
          isOn: this.checked
        })
          .padding($r('sys.float.padding_level0'))
          .margin($r('sys.float.padding_level1'))
          .selectedColor($r('app.color.skin_comp_background_emphasize'))
          .width($r('app.float.id_card_Toggle_size'))
          .height($r('app.float.id_card_Toggle_size'))
          .flexShrink(0)
          .hitTestBehavior(HitTestMode.None)
          .accessibilityLevel('no')
          .id('toggle')
          .onClick((event: ClickEvent) => {
            AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.checked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
              : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
          })
      }
      .constraintSize({
        minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
      })
    }
    .onClick(() => {
      this.batchDeletePresenter.itemOnClick(this.item);
    })
    .focusBox({ margin: LengthMetrics.vp(-2) })
    .accessibilityChecked(this.checked ? true: false)
    .accessibilityRole(AccessibilityRoleType.CHECKBOX)
    .accessibilityDescription(this.checked ? $r('app.string.accessibility_checkbox_selected') : $r('app.string.accessibility_checkbox_deselected'))
  }

  @Builder
  seniorLayout() {
    Row() {
      Column() {
        Row() {
          SymbolGlyph(this.imgRes == undefined ?
          $r('sys.symbol.xmark_video') : this.imgRes)
            .visibility(this.imgRes == undefined ? Visibility.Hidden : Visibility.Visible)
            .fontSize($r('app.float.dialer_common_small_margin'))
            .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
            .width($r('app.float.dialer_common_small_margin'))
            .margin({ right: $r('app.float.id_card_margin_large') })
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, this.imgAccessibilityDesc))

          Row() {
            Text(this.getBatchDeleteCallLogItemPrimaryText())
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor((this.item.callType === 3 || this.item.callType === 5) ?
              $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(10)
              .flexShrink(1)

            if (this.item.count != 1) {
              Text('(' + this.item.count + ')')
                .fontSize($r('sys.float.Body_L'))
                .fontColor((this.item.callType == 3 || this.item.callType == 5) ?
                $r('app.color.skin_warning') : $r('app.color.skin_font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .padding({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })
            }
          }
          .width(`calc(100% - 24vp)`)
        }
        .alignItems(VerticalAlign.Center)
        .margin({
          right: $r('app.float.id_card_margin_max')
        })

        Row() {
          if (this.haveMultiSimCard) {
            SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize($r('app.float.id_card_image_xs'))
              .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
              .margin({ right: $r('app.float.id_card_margin_mid') })
          }

          if (StringUtil.isEmpty(this.item.displayName)) {
            Text(this.getBatchDeleteCallLogItemSecondaryText())
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_ohos_id_color_secondary'))
          } else {
            Text((this.item.numberLocation && this.item.numberLocation !== 'N') ?
              this.item.numberLocation as string : this.item.phoneNumber as string)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_font_secondary'))
          }
        }
        .margin({
          top: $r('sys.float.padding_level1'),
          left: $r('app.float.id_card_margin_max'),
          right: $r('app.float.id_card_margin_max'),
        })

        Row() {
          Text(this.item.createTime as string)
            .fontSize($r('sys.float.Body_M'))
            .margin({
              end: LengthMetrics.resource($r('sys.float.ohos_id_text_margin_horizontal')),
              top: $r('app.float.id_card_margin_sm') })
            .fontColor($r('app.color.skin_ohos_id_color_secondary'))
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Regular)
            .accessibilityText(this.item.createTimeAccessibilityText)

          Toggle({
            type: ToggleType.Checkbox,
            isOn: this.checked
          })
            .padding($r('sys.float.padding_level0'))
            .margin($r('sys.float.padding_level1'))
            .selectedColor($r('app.color.skin_comp_background_emphasize'))
            .width($r('app.float.id_card_Toggle_size'))
            .height($r('app.float.id_card_Toggle_size'))
            .flexShrink(0)
            .hitTestBehavior(HitTestMode.None)
            .accessibilityLevel('no')
            .id('toggle')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: $r('app.float.id_card_margin_max'),
        })
        .margin({
          top: $r('sys.float.padding_level1'),
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
    })
    .onClick(() => {
      this.batchDeletePresenter.itemOnClick(this.item);
    })
    .focusBox({ margin: LengthMetrics.vp(-2) })
  }

  getBatchDeleteCallLogItemPrimaryText(): string {
    if (!StringUtil.isEmpty(this.item.displayName)) {
      return this.item.displayName;
    } else if (this.item.markType === NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
      this.item.markType === NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      // 黄页号码 或者 号码标记
      return this.item.markContent;
    } else if (this.item.isCloudMark === 1 && this.item.markType === NumberMarkUtil.PRE_FRAUD_PHONE_DESC &&
      this.item.markSource === NumberMarkUtil.ANTI_FRAUD_CENTER) {
      // 国家反诈中心
      return ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.suspected_fraud').id);
    } else if (!StringUtil.isEmpty(this.item.formattedNumber)) {
      return this.item.formattedNumber;
    } else {
      return this.item.phoneNumber;
    }
  }

  getBatchDeleteCallLogItemSecondaryText(): string | Resource {
    if (this.item.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) {
      return $r('app.string.number_mark_fraud_smart_identify');
    }
    // 用户手动标记
    if (this.item.isCloudMark === 1 && !StringUtil.isEmpty(this.item.markType) &&
      this.item.markType == NumberMarkUtil.PRE_FRAUD_PHONE_DESC) {
      if (this.item.markSource == NumberMarkUtil.ANTI_FRAUD_CENTER) {
        // 国家反诈中心
        let phoneNumber: string =
          !StringUtil.isEmpty(this.item.formattedNumber) ? this.item.formattedNumber : this.item.phoneNumber;
        let numberLocation: string =
          (this.item.numberLocation && this.item.numberLocation !== 'N') ? this.item.numberLocation : ''
        return `${phoneNumber} ${numberLocation}`;
      } else {
        // 高风险电话
        if (this.item.markSource == NumberMarkUtil.ANTIFRAUD_CENTER_MARK_SOURCE) {
          let markType = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id);
          return `${markType}`;
        } else {
          return (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          ?.resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id)) + '  |  ' +
            (ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
            ?.resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
              this.item.markCount));
        }
      }
    } else if (this.item.isCloudMark === 0 && !StringUtil.isEmpty(this.item.markType) &&
      this.item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.OTHER_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.YELLOW_PAGE_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.item.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC) {
        return $r('app.string.number_marked',
          this.item.markContent);
      }
      return $r('app.string.number_marked',
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id));
    } else if (this.item.isCloudMark === 1 && !StringUtil.isEmpty(this.item.markType) &&
      this.item.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC &&
      this.item.markType != NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
      if (this.item.markType == NumberMarkUtil.OTHER_PHONE_DESC) {
        return this.item.markContent;
      }
      if (this.item.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC) {
        return (!StringUtil.isEmpty(this.item.formattedNumber)) ?
        this.item.formattedNumber : this.item.phoneNumber;
      }
      return ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.item.markType).id) + ' | ' +
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
        .resourceManager.getPluralStringValueSync($r('app.plural.harassment_blockreason_mark_by_other'),
        this.item.markCount);
    } else if (this.item.numberLocation && this.item.numberLocation !== 'N') {
      return this.item.numberLocation as string;
    } else {
      return $r('app.string.unknown');
    }
  }
}