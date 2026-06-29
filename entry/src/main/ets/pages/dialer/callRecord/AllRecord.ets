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

/**
 * Call Log All Calls
 */
import CallRecordPresenter from './../../../presenter/dialer/callRecord/CallRecordPresenter';
import { HiLog, sharedPreferencesUtils } from '../../../../../../../common';
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import promptAction from '@ohos.promptAction';
import CallRecordListDataSource from '../../../model/bean/CallRecordListDataSource';
import EmptyRecord from './EmptyRecord';
import CallRecordItem from './RecordViewItem';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { performanceMonitor, Popup, PopupTextOptions, PopupButtonOptions } from '@kit.ArkUI';
import { CustomizedParams } from '../../../model/type';
import { ResourceUtil } from '../../../util/ResourceUtil';
import DotUtil from '../../../util/DotUtil';
import { SplitStatus } from '../../../util/DisplaySplitUtil';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { i18n } from '@kit.LocalizationKit';
// import { HdsListItem } from '@hms.hds.HdsStyle';

const TAG = 'AllRecord ';
const MAX_HEAD_ANGLE: number = 17;
const MAX_BODY_ANGLE: number = 10;
const ANGLE_RADIO: number = 12;
const ACTION_AREA_DISTANCE: number = 56;
const DELETE_SWIPE_HEAD_WIDTH: number = 64;
const DELETE_SWIPE_BODY_WIDTH: number = 120;
const MAX_SCALE_RATIO: number = 1.1;
const SWIPE_DELETE_DIALOG_EVENT: string = 'SWIPE_DELETE_DIALOG_EVENT';
const SWIPE_CLICK_DELETE_DIALOG_EVENT: string = 'SWIPE_CLICK_DELETE_DIALOG_EVENT';
PersistentStorage.persistProp('isInitViewShow', true);
const NUMBER_TWENTY_EIGHT: number = 28;
const NUMBER_TEN: number = 10;
const MILLIS_PER_MONTH = 30 * 24 * 60 * 60 * 1000;
//通话风险（智能）识别开关
const SPAMSHIELD_SMART_IDENTITY_SWITCH_ON = '1';
const SPAMSHIELD_SMART_IDENTITY_SWITCH_OFF = '0';

@Component
export default struct AllRecord {
  @Link mPresenter: CallRecordPresenter;
  @Link segmentButtonOffsetY: number;
  @Prop segmentButtonHeight: number;
  @Link isShowSegmentBtn: boolean;
  /*0all 1miss*/
  recordType: number = 0;
  @StorageLink('showDialBtn') showDialBtn: boolean = true;
  @StorageLink('callLogListEmpty') callLogListEmpty: boolean = true;
  @StorageLink('missedListEmpty') missedListEmpty: boolean = true;
  @StorageLink('clearAllRecord') clearAllRecord: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('isInitViewShow') isInitViewShow: boolean = true;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageLink('callRecordInit') @Watch('callRecordInitWatch') callRecordInit: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  // 用来监听分屏状态改变
  @StorageProp('splitStatus') @Watch('needRefresh') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  // 用于刷新页面
  @State refresh: boolean = false;
  private listScroller: ListScroller = new ListScroller();

  callRecordInitWatch() {
    HiLog.w(TAG, 'callRecordInit: ' + this.callRecordInit);
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear,recordType:' + this.recordType)
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear,recordType:' + this.recordType)
  }

  needRefresh() {
    this.refresh = !this.refresh;
  }

  @Builder
  emptyRecorder() {
    EmptyRecord({ recordType: this.recordType })
      .margin({
        bottom: !this.isVerde && this.showDialBtn && this.curBp === 'sm' ? $r('app.float.id_dialer_height') : '4vp'
      })
  }

  build() {
    Column() {
      if (!this.callRecordInit) {

      } else if ((this.recordType === 0 ? this.callLogListEmpty : this.missedListEmpty) || this.clearAllRecord) {
        if (this.refresh) {
          this.emptyRecorder()
        } else {
          this.emptyRecorder()
        }
      } else {
        RecordView({
          mPresenter: $mPresenter,
          recordType: this.recordType,
          segmentButtonOffsetY: this.segmentButtonOffsetY,
          segmentButtonHeight: this.segmentButtonHeight,
          isShowSegmentBtn: this.isShowSegmentBtn,
          listScroller: this.listScroller
        });
      }
    }
  }
}

@Component
struct RecordView {
  customizedParams: CustomizedParams = {};
  @Link private mPresenter: CallRecordPresenter;
  @Link segmentButtonOffsetY: number;
  @Prop segmentButtonHeight: number;
  @Link isShowSegmentBtn: boolean;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('showDialBtn') @Watch('closeAllSwipeActions') showDialBtn: boolean = true;
  recordType: number = 0;
  private listScroller: ListScroller = new ListScroller();
  @State contactItemTouchable: boolean = true;
  swipeActionCount: number = 0;
  downY: number = 0;
  @State headAngle: number = 0;
  @State bodyAngle: number = 0;
  @State swipeScale: number = 1;
  @State endOffset: number = 0;
  @State currentItem: MergedCallLog | null = null;
  private dustbinAnimationEnabled: boolean = true;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State currentRatio: number = 0;
  @State currentIndex: number = 0;
  @State deleteSwipeHeadWidth: number = this.isTabletLandscape ? 88 : 64;
  @State deleteSwipeBodyWidth: number = this.isTabletLandscape ? 144 : 120;
  @State backgroundRecordListItem: Resource = $r('app.color.skin_background_primary');
  @State selectId: number = 0;
  @State isShowedFraudBanners: boolean = true;
  @StorageLink('smartIdentitySwitch') smartIdentitySwitch: string = '';
  @StorageLink('showFraudBanners') showFraudBanners: boolean = false;
  @Consume('showNewCallTip') showNewCallTip: boolean; // 是否显示增强通话气泡
  @Consume('isShowCallSetting') isShowCallSetting: boolean; // 是否显示通话设置
  @Consume('scrollToCardOne') scrollToCardOne: boolean; // 打开通话设置后滚动到卡1
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageLink('dialerHideActionType') dialerHideActionType: performanceMonitor.ActionType =
    performanceMonitor.ActionType.LAST_UP;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('scrollColorStr') scrollColorStr: string = '';
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  prevSegmentButtonOffsetY: number = 0;
  private readonly ANIMATION_DURATION: number = 300;
  private isPC: boolean = EnvironmentProp.isPC();

  aboutToAppear(): void {
    HiLog.w(TAG, `RecordView aboutToAppear, recordType: ${this.recordType}`);
  }

  async checkFraud() {
    this.isShowedFraudBanners = await sharedPreferencesUtils.getFromPreferences('showedFraudBanners', false) as boolean;
    if (!this.isShowedFraudBanners) {
      HiLog.i(TAG, 'smartIdentitySwitch info' + this.smartIdentitySwitch);
      if (this.smartIdentitySwitch === SPAMSHIELD_SMART_IDENTITY_SWITCH_OFF) {
        this.showFraudBanners = true;
      } else if (this.smartIdentitySwitch === SPAMSHIELD_SMART_IDENTITY_SWITCH_ON) {
        this.showFraudBanners = false;
      }
    } else {
      this.showFraudBanners = false;
    }
  }

  aboutToDisappear(): void {
    HiLog.w(TAG, `RecordView aboutToDisappear, recordType: ${this.recordType}`);
    // 清空通话记录时，显示 SegmentBtn
    animateTo({ duration: this.ANIMATION_DURATION, curve: Curve.Smooth }, () => {
      this.isShowSegmentBtn = true;
    });
  }

  @Styles
  buttonStyle()
  {
    .borderRadius(20)
    .height($r('app.float.id_item_height_sm'))
    .width($r('app.float.id_item_height_sm'))
    .margin({
      top: $r('app.float.id_card_margin_xl'),
      bottom: $r('app.float.id_card_margin_xl'),
      left: this.isTabletLandscape ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      right: this.isTabletLandscape ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
    })
  }

  closeAllSwipeActions() {
    if (this.swipeActionCount > 0) {
      this.listScroller?.closeAllSwipeActions();
    }
  }

  deleteAction(item: MergedCallLog, itemIndex: number) {
    let totalCount = this.recordType === 0 ? this.mPresenter.mAllCallRecordListDataSource.totalCount() :
      this.mPresenter.mMissCallRecordListDataSource.totalCount();
    if (totalCount === 1) {
      AccessibilityUtil.getInstance().sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dial_btn', 0);
    } else {
      AccessibilityUtil.getInstance().sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'callRecord' + (itemIndex + 1), 0);
    }
    this.dustbinAnimationEnabled = false;
    this.currentItem = item;
    const index = (this.recordType === 0 ? this.mPresenter.mAllCallRecordListDataSource :
    this.mPresenter.mMissCallRecordListDataSource).indexOf(item);

    animateTo({
      duration: 400,
      curve: Curve.Friction,
      onFinish: () => {
        this.dustbinAnimationEnabled = true;
        this.contactItemTouchable = true;
      }
    }, () => {
      this.mPresenter.deleteCallLog(item.ids, [item.phoneNumber], index);
      this.mPresenter.deleteCallLogItemPage(item.ids);
    })
  }

  build() {
    List({ space: '2px', initialIndex: 0, scroller: this.listScroller }) {
      // if (this.showFraudBanners && !this.isVerde) {
      //   ListItemGroup() {
      //     ListItem() {
      //       Row() {
      //         Popup({
      //           showClose: true,
      //           onClose: () => {
      //             HiLog.w(TAG, 'just popup close')
      //             sharedPreferencesUtils.saveToPreferences('showedFraudBanners', true);
      //             this.checkFraud();
      //           },
      //           direction: i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr,
      //           title: {
      //             text: $r('app.string.smart_security_protection'),
      //             fontSize: this.fontSizeScale > 5 ? '32vp' : 16, // 正常到大5档随系统缩放，大6档与大5档保持一致，下同
      //             fontColor: $r('app.color.skin_font_primary'),
      //             fontWeight: FontWeight.Medium
      //           } as PopupTextOptions,
      //           message: {
      //             text: $r('app.string.smart_identify_info'),
      //             fontSize: this.fontSizeScale > 5 ? '28vp' : 14,
      //             fontColor: $r('app.color.skin_font_secondary'),
      //             fontWeight: FontWeight.Regular
      //           } as PopupTextOptions,
      //           maxWidth: '100%',
      //           buttons: [
      //             {
      //               text: $r('app.string.go_to_settings'),
      //               action: async () => {
      //                 HiLog.w(TAG, 'identify fraud enable')
      //                 sharedPreferencesUtils.saveToPreferences('showedFraudBanners', true);
      //                 AppStorage.setOrCreate('isShowSwitchPage', true);
      //                 this.showFraudBanners = false;
      //               },
      //               fontSize: this.fontSizeScale > 5 ? '28vp' : 14,
      //               fontColor: $r('app.color.skin_font_emphasize'),
      //             }] as [PopupButtonOptions?, PopupButtonOptions?]
      //         })
      //       }
      //       .borderRadius($r('app.float.radio_button_width_20'))
      //       .backgroundColor($r('sys.color.comp_background_tertiary'))
      //       .margin({
      //         left: this.spaceLR,
      //         top: $r('app.float.id_dialog_button_top_margin'),
      //         bottom: $r('app.float.id_card_margin_xl'),
      //         right: this.spaceLR
      //       })
      //     }
      //   }
      // }
      if (this.showNewCallTip) {
        ListItem() {
          Row() {
            Popup({
              title: {
                text: $r('app.string.new_call_popup_title'),
                fontSize: this.fontSizeScale > 5 ? '32vp' : 16, // 正常到大5档随系统缩放，大6档与大5档保持一致，下同
              },
              message: {
                text: $r('app.string.new_call_popup_message'),
                fontSize: this.fontSizeScale > 5 ? '28vp' : 14,
              },
              showClose: true,
              onClose: () => {
                this.showNewCallTip = false;
                sharedPreferencesUtils.saveToPreferences('nextShowNewCallTip', Date.now() + MILLIS_PER_MONTH);
              },
              maxWidth: '100%',
              buttons: [
                {
                  text: $r('app.string.new_call_popup_dismiss'),
                  fontSize: this.fontSizeScale > 5 ? '28vp' : 14,
                  action: () => {
                    this.showNewCallTip = false;
                    sharedPreferencesUtils.saveToPreferences('nextShowNewCallTip', Number.MAX_VALUE);
                  },
                },
                {
                  text: $r('app.string.new_call_popup_setting'),
                  fontSize: this.fontSizeScale > 5 ? '28vp' : 14,
                  action: () => {
                    this.showNewCallTip = false;
                    sharedPreferencesUtils.saveToPreferences('nextShowNewCallTip', Number.MAX_VALUE);
                    this.scrollToCardOne = true;
                    this.isShowCallSetting = true;
                  },
                }],
            });
          }.borderRadius($r('app.float.radio_button_width_20'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({
            left: this.spaceLR,
            top: this.showFraudBanners && !this.isVerde ? 0 : $r('app.float.id_dialog_button_top_margin'),
            bottom: $r('app.float.id_card_margin_large'),
            right: this.spaceLR,
          });
        };
      }
      // 显示通话记录
      ListItemGroup() {
        LazyForEach(this.recordType === 0 ? this.mPresenter.mAllCallRecordListDataSource :
        this.mPresenter.mMissCallRecordListDataSource, (item: MergedCallLog, index: number) => {
          ListItem() {
            this.CallRecordBuilder(item, index)
          }
          .swipeAction({
            end:{
              builder:()=>{
                this.itemEnd(() => {
                  this.deleteAction(item, index);
                })
              },
              onAction:()=>{
                animateTo({
                  duration: 400,
                }, () => {
                  this.deleteAction(item, index);
                })
              },
            }
          })
          // HdsListItem({
          //   customItemBuilder: this.CallRecordBuilder(item, index),
          //   swipeActionOptions: {
          //     deleteIconOptions: {
          //       onAction: () => {
          //         this.deleteAction(item, index);
          //         DotUtil.getInstance().contactDot(this.customizedParams, SWIPE_DELETE_DIALOG_EVENT);
          //       },
          //       iconOptions: {
          //         accessibilityText: ResourceUtil.getStringByResource($r('app.string.accessibility_delete')) +
          //           ' ' + ResourceUtil.getStringByResource($r('app.string.accessibility_button'))
          //       }
          //     },
          //     fullDeleteOptions: {
          //       isFullDelete: true,
          //       onFullDeleteAction: () => {
          //         animateTo({
          //           duration: 350,
          //         }, () => {
          //           this.deleteAction(item, index);
          //           DotUtil.getInstance().contactDot(this.customizedParams, SWIPE_DELETE_DIALOG_EVENT);
          //         })
          //       }
          //     }
          //   }
          // })

        }, (item: MergedCallLog) => JSON.stringify(item))
      }.divider({
        strokeWidth: '1px',
        startMargin: this.isTabletLandscape ? '48vp' : '40vp',
        endMargin: this.spaceLR,
        color: $r('app.color.skin_ohos_id_color_list_separator')
      })
    }
    .clip(this.isPC ? true : false)
    .onTouch((event: TouchEvent) => {
      this.closeAllSwipeActions();
      switch (event.type) {
        case TouchType.Down:
          this.downY = -1;
          break;
        case TouchType.Move:
          if (this.downY === -1) {
            this.downY = event.touches[0].y;
          }
          if (this.downY != event.touches[0].y) {
            // 滑动通话记录时隐藏拨号盘，触发打点时机为手指移动时
            this.dialerHideActionType = performanceMonitor.ActionType.FIRST_MOVE;
            this.showDialBtn = false;
          }
          break;
        case TouchType.Up:
        case TouchType.Cancel:
      }
    })
    .width('100%')
    .height('100%')
    .flexShrink(1)
    .listDirection(Axis.Vertical)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    // 联动效果，与上层父组件联动
    .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    .scrollBar(BarState.Auto)
    .scrollBarColor(this.isThemeActive ? this.scrollColorStr : undefined)
    .contentEndOffset(this.isVerde ? 48 : 104)
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      if (scrollState === ScrollState.Scroll) {
        if (scrollOffset > 0 && !this.hideIndexTitleTabBar) {
          this.hideIndexTitleTabBar = true;
        } else if (scrollOffset < 0 && this.hideIndexTitleTabBar) {
          this.hideIndexTitleTabBar = false;
        }
      }
      const scrollOffsetY = this.listScroller?.currentOffset().yOffset ?? 0;
      if (scrollOffsetY > 56 && scrollOffset > 0 && this.isShowSegmentBtn) {
        animateTo({ duration: this.ANIMATION_DURATION, curve: Curve.Smooth }, () => {
          this.isShowSegmentBtn = false;
        });
      }
      // 没有通话记录时，上滑回弹时偶现scrollOffsetY等于-0.00000X的情况，
      // 导致上滑时还会偶现顶部分段按钮为了规避这种情况将判断条件由之前的小于0调整为小于-0.01
      if (scrollOffsetY < -0.01 && !this.isShowSegmentBtn) {
        animateTo({ duration: this.ANIMATION_DURATION, curve: Curve.Smooth }, () => {
          this.isShowSegmentBtn = true;
        });
      }
    })
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (!isVisible && currentRatio === 0) {
        this.swipeActionCount = 0;
        this.contactItemTouchable = true;
        this.listScroller?.closeAllSwipeActions();
      }
    })
  }

  @Builder
  itemEnd(onDeleteBtn: () => void) {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_delete_head'))
          .height(5)
          .width(20)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '100%',
            centerY: '100%',
            angle: this.headAngle,
          })
        Image($r('app.media.ic_delete_body'))
          .height(16)
          .width(16)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '100%',
            centerY: 0,
            angle: this.bodyAngle,
          })
      }
      .width($r('app.float.id_item_height_sm'))
      .height($r('app.float.id_item_height_sm'))
      .borderRadius(20)
      .scale({ x: this.swipeScale, y: this.swipeScale })
      .backgroundColor($r('app.color.skin_ohos_id_color_warning'))
      .onClick(onDeleteBtn)
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
    }
    .draggable(false)
    .backgroundColor($r('app.color.skin_ohos_id_color_sub_background'))
    .onAreaChange((oldValue: Area, newValue: Area) => {
      if (this.dustbinAnimationEnabled) {
        let wid: Length = newValue.width;
        this.headAngle = Math.min(MAX_HEAD_ANGLE,
          Math.max((Number(wid) - DELETE_SWIPE_HEAD_WIDTH) / ACTION_AREA_DISTANCE * ANGLE_RADIO, 0.0));
        this.bodyAngle = Math.min(MAX_BODY_ANGLE,
          Math.max((Number(wid) - DELETE_SWIPE_BODY_WIDTH) / ACTION_AREA_DISTANCE * 24.35, 0.0));
        this.swipeScale = Math.min(MAX_SCALE_RATIO,
          (Number(wid) - DELETE_SWIPE_HEAD_WIDTH) / ACTION_AREA_DISTANCE * 0.05 + 1.0);
        this.bodyAngle = (-1) * this.bodyAngle;
      }
    })
    .height('100%')
    .margin({ left: $r('sys.float.padding_level6') })
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .constraintSize({ minWidth: '72vp' })
  }

  @Builder
  CallRecordBuilder(item: MergedCallLog, index: number) {
    CallRecordItem({
      mPresenter: $mPresenter,
      item: item,
      index: index,
      recordType: this.recordType,
      contactItemTouchable: this.contactItemTouchable
    })
      .padding({
        left: this.isPC ? $r('sys.float.padding_level8') : 0,
        right: this.isPC ? $r('sys.float.padding_level8') : 0
      })
      .constraintSize({
        minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
      })
      .zIndex(-item.id)
      .id('allRecord_contacts_record_listItem')
      .backgroundColor(this.isThemeActive || this.isPC ? Color.Transparent :
      $r('app.color.skin_ohos_id_color_sub_background'))
  }
}

export function showVideoChangeToVoiceToast() {
  try {
    promptAction.showToast({
      message: $r('app.string.cannot_start_video_call_change_to_voice'),
      duration: 2000,
    });
  } catch (err) {
    HiLog.e(TAG, 'showVideoChangeToVoiceToast, promptAction.showToast err: ' + err?.message + ', stack: ' + err?.stack);
  }
}