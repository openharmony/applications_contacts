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
import CallRecord from '../../dialer/callRecord/CallRecord';
import DialerSearchList from './DialerSearchList';
import DialerPresenter from './../../../presenter/dialer/DialerPresenter';
import { DialerButtonView } from '../../../component/dialer/DialerButtonView';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { Controller, SelectDialogBuilder, SelectSimIdDialog } from '../../dialog/SelectSimIdDialog';
import VibrationUtils from '../../../util/VibrationUtils';
import performanceMonitor from '@ohos.arkui.performanceMonitor';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import curves from '@ohos.curves';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { DialPad } from '../../../component/dialer/DialPad';
import { TelNumber } from '../../../component/dialer/TelNumber';
import DialerConstant from '../../../data/DialerConstant';
import { FontScaleState } from '../../../util/fontScaleState';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { numFormat } from '../../../util/NumFormat';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { ComponentContent, display, TextModifier } from '@kit.ArkUI';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import deviceInfo from '@ohos.deviceInfo';
import { i18n } from '@kit.LocalizationKit';
import { DialBindSheetBuilder } from '../../../component/dialer/DialBindSheetBuilder';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { ResourceUtil } from '../../../util/ResourceUtil';
import dotCommon, { customParams } from '../../../util/DotCommon';
import { showToast, SystemModeController } from '../../../util/SystemModeController';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import prompt from '@ohos.promptAction';
import { ItemRestriction, SegmentButton, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { SegmentButtonOptions } from '@kit.ArkUI';
import { isCallRecorderEnable, toastForCallRecorderDisable } from '../../../util/CheckRestoreUtils';

const TAG = 'Dialer';
const CONTACT_ADD_EVENT = 'CONTACT_ADD_EVENT';
const MESSAGE_SENDING_EVENT = 'MESSAGE_SENDING_EVENT';
const CLICK_SAVE_EXIST_EVENT = 'CLICK_SAVE_EXIST_EVENT';
const CLICK_CALL_LOG_MORE_EVENT = 'CLICK_CALL_LOG_MORE_EVENT';
const CALL_MORE_CHOOSE_EVENT = 'CALL_MORE_CHOOSE_EVENT';
const CLICK_DIALER_SHOW_EVENT = 'CLICK_DIALER_SHOW_EVENT';
const DELETE_NUM_EVENT = 'DELETE_NUM_EVENT';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';
const EMPTY_STR = '';
const POPUP_PITCH_WIDTH: number = 32;
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

interface openPopupParam {
  curBp: string
}

interface ParamsInterface {
  localAccountId: boolean,
  isHasPateDate: boolean,
  hasCallRecord: boolean,
  isThemeActive: boolean,
  menuTitles: Array<Resource>,
  setCallSetting: Function,
  moreChooseParams: CustomizedParams,
  mPresenter: DialerPresenter,
}

/**
 * Dialer Call
 */
@Component
export default struct Call {
  // 透明度
  @State opacityValue: number = 1;
  @State animationFinished: boolean = false;
  @State showNumber: boolean = false;
  // DialerPresenter
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance()
  @StorageLink('activeCallId') activeCallId: number = -1;
  //仅限于用于展示号码 带格式化
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('breakpoint') @Watch('multiSimCardUpdataWidth') curBp: string = 'sm';
  // 显示拨号盘
  @StorageLink('showDialBtn') @Watch('onShowDialBtnChange') showDialBtn: boolean = true;
  @StorageLink('dialerShow') dialerShow: boolean = false;
  @StorageLink('haveMultiSimCard') @Watch('onSimChanged') haveMultiSimCard: boolean = false;
  @StorageLink('defaultSlot') @Watch('onSimChanged') defaultSlot: number = simId_DEFAULT;
  @StorageLink('hasCallRecord') hasCallRecord: boolean = false;
  @StorageLink('isMultiCardSelected') @Watch('selectedMultiCardEvent') isMultiCardSelected: boolean = false;
  @StorageLink('callLogListEmpty') @Watch('onHideIndexTitleTabBar') callLogListEmpty: boolean = true;
  @StorageLink('missedListEmpty') missedListEmpty: boolean = true;
  @StorageLink('clearAllRecord') clearAllRecord: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('isAirplaneMode') @Watch('onAirplaneModeChange') isAirplaneMode: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  // 剪切板过滤之后是否有数据
  @StorageLink('isHasDate') isHasPateDate: boolean = false;
  // 剪切板过滤之后的数据
  @StorageLink('pasteData') pasteData: string = '';
  // 剪切板前后两次剪切板内容是否一致
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @StorageLink('dialerHideActionType') dialerHideActionType: performanceMonitor.ActionType =
    performanceMonitor.ActionType.LAST_UP;
  @State menuTitles: Array<Resource> = [$r('app.string.call_setting_type_paste'), $r('app.string.call_recorder_list'),
    $r('app.string.call_setting_type_batch_delete'), $r('app.string.commotion_intercept'),
    $r('app.string.call_setting_type_setting'), /*$r('app.string.Help_and_feedback')*/];
  @State builder: SelectDialogBuilder = this.mPresenter.builder;
  @State dialerButtonICurve: ICurve = curves.interpolatingSpring(0, 1, 342, 37);
  @State dialerClickICurve: ICurve = curves.interpolatingSpring(0, 1, 280, 33);
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageLink(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 是否拉起通话设置模态窗口
  @Consume('isShowCallSetting') isShowCallSetting: boolean;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageLink('isDialerShowImeiPanel') isShowImeiPanel: boolean = false;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('isShowHarassmentPop') isShowHarassmentPop: boolean = false;
  @StorageLink('isAppear') isAppear: boolean = false;
  createContactParams: CustomizedParams = {
    ENC: 2,
  };
  sendMsgParams: CustomizedParams = {
    ENC: 0,
    ISKNOW: 0
  };
  saveExistParams: CustomizedParams = {
    ENC: 2,
  };
  customizedParams: CustomizedParams = {};
  moreChooseParams: CustomizedParams = {
    ITEM: 0
  };
  showDialerParams: CustomizedParams = {
    ISSHOW: 0
  };
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };
  mSelectSlotIdDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.builder.title,
      contentBuilder: () => {
        this.SelectSlotIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.callDialogParams.ITEM = -1;
            this.callDialogParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.mSelectSlotIdDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })
  textInputController: TextInputController = new TextInputController();
  @State numberLocation: string = '';
  // 是否显示拨号盘拨的号码
  @StorageLink('showTelNumber') showTelNumber: boolean = true;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageLink('isShowBtn') isShowBtn: boolean = true;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('mainTabsIndex') @Watch('isTabsChange') mainTabsIndex: number = 0;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp('windowHeightPx') windowHeightPx: number = 0;
  downY: number = 0;
  @StorageLink('isPrimaryAccount') localAccountId: boolean = false;
  @StorageProp('isVerde') @Watch('onForegroundChange') isVerde: boolean = false;
  @StorageProp('isVerdeModel') isVerdeModel: boolean = false;
  @StorageProp('isMainAbilityForeground') @Watch('onForegroundChange') isMainAbilityForeground: boolean = true;
  @StorageLink('hideIndexTitleTabBar') @Watch('onHideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageLink('verdeDialerPadMoveY') verdeDialerPadMoveY: number = 0;
  @StorageLink('isNavigationModeSplit') isNavigationModeSplit: boolean = false;
  // 拨号盘搜索返回通话记录页面状态
  @StorageLink('backCallLogPage') @Watch('isBackCallLogPage') backCallLogPage: number = -1;
  @StorageLink('callRecordIsDeleted') @Watch('toastForCallRecordNotExist') callRecordIsDeleted: boolean = false;
  private mSystemModeController: SystemModeController = SystemModeController.getInstance();
  private listScroller: ListScroller = new ListScroller();
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State @Watch('onSegmentButtonIndexChanged') segmentButtonSelectedIndexes: number[] = [0]
  private controller: TabsController = new TabsController();
  @State isShowSegmentBtn: boolean = false;
  private missedScroller: ListScroller = new ListScroller();
  private scroller: ListScroller = new ListScroller();
  @State @Watch('isSearchList') isSearch: boolean = false;
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  // bottomTabsController: HdsTabsController = new HdsTabsController();
  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.color_paste_press_background'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('app.color.color_paste_background'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }

  onSegmentButtonIndexChanged() {
    let seletedIndex: number = this.segmentButtonSelectedIndexes[0];
    this.controller.changeIndex(seletedIndex);
    // 底部tabs电话页签绑定对应列表，解绑其他列表：全部通话/未接来电
    // if (seletedIndex === 0) {
    //   this.bottomTabsController.unbindScroller(this.missedScroller);
    //   this.bottomTabsController.bindScroller(0, this.listScroller);
    // } else {
    //   this.bottomTabsController.unbindScroller(this.listScroller);
    //   this.bottomTabsController.bindScroller(0, this.missedScroller);
    // }
  }

  /**
   * 通过监听搜索状态，底部tabs电话页签绑定对应列表，解绑其他列表：搜索列表/全部通话/未接来电
   *
   **/
  isSearchList(): void {
    // if (this.isSearch) {
    //   this.bottomTabsController.unbindScroller(this.missedScroller);
    //   this.bottomTabsController.unbindScroller(this.listScroller);
    //   this.bottomTabsController.bindScroller(0, this.scroller);
    // } else {
    //   this.bottomTabsController.unbindScroller(this.scroller);
    //   if (this.segmentButtonSelectedIndexes[0] === 0) {
    //     this.bottomTabsController.bindScroller(0, this.listScroller);
    //   } else {
    //     this.bottomTabsController.bindScroller(0, this.missedScroller);
    //   }
    // }
  }


  isTabsChange() {
    // 判断当前是否在电话页面在电话页面检查是否播报粘贴弹窗
    if (this.mainTabsIndex === IndexPresenter.getInstance().callIndex) {
      if (this.isOpenAccessibility && this.isAppear) {
        // 2.场景2 当前弹窗变化已经显示,刚切换到电话页面
        HiLog.w(TAG, `isCallPage change and isappear`);
        AccessibilityUtil.getInstance()
          .sendAccessibilityEvent(this.isOpenAccessibility, 'paste_data');
      }
    }
  }

  voiceMailMultiCardDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.voicemail'),
      contentBuilder: () => {
        this.VoiceMailMultiCardDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.voiceMailMultiCardDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  /**
   * Triggered when the multi-card selection event is triggered.
   * If multi-card selection has been made, the voice mail multi-card dialog is opened,
   * and the multi-card selection status is set to unselected.
   */
  selectedMultiCardEvent() {
    if (this.isMultiCardSelected) {
      this.voiceMailMultiCardDialog?.open();
      AppStorage.setOrCreate('isMultiCardSelected', false);
      DialogControllerManager.getInstance().addDialogController(this.voiceMailMultiCardDialog);
    }
  }

  onForegroundChange() {
    // v小折叠 外屏展示回到前台的时候，通话设置页面收起
    if ((this.isVerde && this.isMainAbilityForeground)) {
      this.isShowCallSetting = false;
    }
  }

  multiSimCardUpdataWidth() {
    HiLog.w(TAG, `Dialer breakpoint change:${this.curBp}, ${this.mPresenter.moveY},${this.mPresenter.buttonMoveY},${this.showDialBtn}`);
    this.mPresenter.updatePhoneWidth();
    this.onSimChanged();
  }

  onAirplaneModeChange() {
    HiLog.w(TAG, 'isAirplaneMode change:' + this.isAirplaneMode);
    // 刷新拨号盘样式
    if (this.isAirplaneMode) { //不管单卡双卡 只要开飞行 都变为无卡状态下的拨号按钮样式
      this.mPresenter.dialerButtonWidth = '60vp';
    } else {
      // 关闭飞行模式重新给按钮宽度赋值
      this.onSimChanged();
    }
  }

  // sim change
  onSimChanged() {
    HiLog.w(TAG, 'haveMultiSimCard change:' + this.haveMultiSimCard);
    this.mPresenter.dialerButtonWidth = this.haveMultiSimCard && !this.isAirplaneMode ?
      ((this.hasDefaultSlot()) ? '192vp' : (px2vp(this.mPresenter.dialerButtonWidthInMulti) + 16) + 'vp') : '60vp';
  }

  onShowDialBtnChange() {
    // 拨号盘收起时，粘贴弹窗也要消失
    HiLog.w(TAG, `onShowDialBtnChange: ${this.showDialBtn}, pasteStatus: ${this.pasteStatus}`);
    if (!this.showDialBtn && this.pasteStatus) {
      HiLog.w(TAG, `dialer cover pasteStatus disappeear`);
      this.pasteStatus = false;
    }
    if (this.showDialBtn != this.mPresenter.btnShow) {
      HiLog.w(TAG,
        `onShowDialBtnChange not change showdialbtn is ${this.showDialBtn} btnShow is ${this.mPresenter.btnShow}`);
      return;
    }
    if (this.showDialBtn) {
      HiLog.i(TAG,`showDialBtn value is ${this.showDialBtn},btnShow value is ${this.mPresenter.btnShow}`)
      HiLog.w(TAG, 'show DialBtn ');
      this.mPresenter.callBtnClick = true;
      performanceMonitor.begin('CONTACTS_DIALER_SHOW', performanceMonitor.ActionType.LAST_UP);
      this.dialerButtonICurve = curves.interpolatingSpring(0, 1, 342, 37);
      this.dialerClickICurve = curves.interpolatingSpring(0, 1, 280, 33);
      this.mPresenter.moveY = 0;
      this.verdeDialerPadMoveY = 0;
      this.mPresenter.buttonMoveY = 112;
      this.mPresenter.btnShow = false;
      this.mPresenter.dialerButtonWidth = this.haveMultiSimCard && !this.isAirplaneMode ?
        ((this.hasDefaultSlot()) ? '192vp' : (px2vp(this.mPresenter.dialerButtonWidthInMulti) + 16) + 'vp') : '60vp';
      this.mPresenter.callBtnClick = false;
    } else {
      HiLog.i(TAG,`showDialBtn value is ${this.showDialBtn},btnShow value is ${this.mPresenter.btnShow}`)
      HiLog.w(TAG, 'cover DialBtn ');
      this.mPresenter.btnShow = true;
      performanceMonitor.begin('CONTACTS_DIALER_HIDE', this.dialerHideActionType);
      this.dialerButtonICurve = curves.interpolatingSpring(4, 1, 342, 37);
      this.dialerClickICurve = curves.interpolatingSpring(0, 1, 380, 39);
      this.mPresenter.moveY = 392;
      this.verdeDialerPadMoveY = 392;
      this.mPresenter.buttonMoveY = 0;
    }
    AppStorage.setOrCreate('dialerVisible', this.showDialBtn);
  }


  onHideIndexTitleTabBar() {
    if (this.isVerde) {
      if (this.hideIndexTitleTabBar) {
        this.mPresenter.buttonMoveY = 112;
      } else if (!this.showDialBtn) {
        this.mPresenter.buttonMoveY = 0;
      }
    } else {
      if (this.showDialBtn) {
        this.mPresenter.buttonMoveY = 112;
      } else {
        this.mPresenter.buttonMoveY = 0;
      }
    }
  }



  hasDefaultSlot() {
    return this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO
  }

  private getNavigationTitleMode(splitStatus: SplitStatus) {
    //如果是悬浮窗走原来的逻辑
    if (this.isShowSmartWindow) {
      return ((this.callLogListEmpty && this.missedListEmpty) || this.clearAllRecord) &&
        this.telNumberWithSpace.length === 0 ? NavigationTitleMode.Full : NavigationTitleMode.Free;
    }
    if (DisplaySplitUtil.isFixedTitleBar(splitStatus)) {
      return NavigationTitleMode.Mini;
    }
    return ((this.callLogListEmpty && this.missedListEmpty) || this.clearAllRecord) &&
      this.telNumberWithSpace.length === 0 ? NavigationTitleMode.Full : NavigationTitleMode.Free;
  }

  toastForCallRecordNotExist() {
    if (this.callRecordIsDeleted) {
      // 页面加载完成后显示 Toast 提示框
      prompt.showToast({
        message: $r('app.string.delete_call_record'),
        duration: 3000, // 提示框显示 3 秒
        bottom: 80 // 距离底部的距离
      });
      HiLog.i(TAG, `call record delete flag is: ${AppStorage.get('callRecordIsDeleted')}`)
      AppStorage.setOrCreate('callRecordIsDeleted', false)
    }
  }

  //aboutToAppear
  aboutToAppear() {
    this.toastForCallRecordNotExist()
    HiLog.w(TAG, 'aboutToAppear CallTablet ');
    this.mPresenter.updatePhoneWidth();
    this.mPresenter.dialerButtonWidth = this.haveMultiSimCard && !this.isAirplaneMode ?
      ((this.hasDefaultSlot()) ? '192vp' : (px2vp(this.mPresenter.dialerButtonWidthInMulti) + 16) + 'vp') : '60vp';
    this.onShowDialBtnChange();
    this.mPresenter.aboutToAppear();
    if (this.mainTabsIndex === IndexPresenter.getInstance().callIndex && this.pathInfos.size() <= 0) {
      HiLog.w(TAG, 'pathInfos aboutToAppear: DialerPad');
      CallRecordPresenter.getInstance().toDefaultPage();
    }
    // this.bottomTabsController.bindScroller(0, this.listScroller);
    let that = this;
    const controller: Controller = new Controller();
    controller.open = () => {
      that.mSelectSlotIdDialog?.open();
      DialogControllerManager.getInstance().addDialogController(this.mSelectSlotIdDialog);
    };
    controller.close = () => {
      that.mSelectSlotIdDialog?.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    };
    this.mPresenter.builder.controller = controller;
  }

  aboutToDisappear() {
    this.mSelectSlotIdDialog = null;
    this.mPresenter.aboutToDisappear();
    this.voiceMailMultiCardDialog = null;
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .height('1px')
      .lineCap(LineCapStyle.Square)
      .padding({
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6')
      })
  }

  @Builder
  MenuBuilder() {
    Column() {
      Menu() {
        ForEach(this.menuTitles, (item: Resource, index?: number) => {
          // if (this.localAccountId || index != 3) {
          /*
           * 这里暂时隐藏骚扰拦截入口
           */
          if ((this.localAccountId || index != 3) && index !== 3) {
            if (index !== 0) {
              this.MenuDivider()
            }
            if (index === 1 && !this.mSystemModeController.getIsEnableCallRecordEntry()) {
              MenuItem() { //禁用通话录音
                MenuItem({ content: item })
                  .id('dialer_set_bnt')
                  .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                  .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.ohos_id_text_size_body1') })
                  .contentFontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
                  .enabled(false)
              }.onClick(() => {
                showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
              })
            } else {
              MenuItem({ content: item })
                .onClick(() => {
                  if (index === 0) {
                    this.mPresenter.pasteFunc();//粘贴
                  } else if (index === 1) {
                    // 联系人打点--通话记录更多选项卡-通话录音
                    this.moreChooseParams.ITEM = 0;
                    DotUtil.getInstance().contactDot(this.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                    this.mPresenter.jumpToRecordList();
                  } else if (index === 2) {
                    // 联系人打点--通话记录更多选项卡-批量删除
                    this.moreChooseParams.ITEM = 1;
                    DotUtil.getInstance().contactDot(this.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                    this.mPresenter.jumpBatchDeleteView();
                  } else if (index === 3) {
                    //跳转通话防护界面
                    this.mPresenter.jumpToHarassmentFilter();//跳转骚扰拦截
                  } else if (index === 4) {
                    // 联系人打点--通话记录更多选项卡-设置
                    this.moreChooseParams.ITEM = 2;
                    DotUtil.getInstance().contactDot(this.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                    this.isShowCallSetting = true;
                  } else {
                    // 跳转帮助和反馈
                    this.mPresenter.jumpToFeedbackMenu();
                  }
                })
                .id('dialer_set_bnt')
                .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.ohos_id_text_size_body1') })
                .contentFontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
                .enabled((index === 3 || index === 4 || index === 5) ?
                  ((!this.localAccountId && index === 4) ? false : true) :
                  ((index === 0 ? this.isHasPateDate : (this.hasCallRecord ? true : false))))
            }
          }
        }, (item: Resource) => item.id.toString())
      }
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  marginTopOfSearchList() {
    let top = $r('app.float.id_margin_dialer_search_19')
    return top
  }
  private getDialButtonMargin(): number {
    let dialHeight: number = 0;
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = 16;
    } else {
      dialHeight = 0;
    }
    return dialHeight;
  }

  private getDialButtonMarginBottom(): number {
    let dialHeight: number = 0;
    if ((this.splitStatus === SplitStatus.HALF_SPLIT) || (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
    DisplaySplitUtil.isSmLeft(this.splitStatus)) {
      dialHeight = 12;
    } else {
      dialHeight = 0;
    }
    return dialHeight;
  }

  private getDialHeight(splitStatus: SplitStatus): number {
    let dailHeight: number = 0;
    if (splitStatus === SplitStatus.HALF_SPLIT) {
      dailHeight = px2vp(this.windowHeightPx) - 152;
    } else if (deviceInfo.deviceType == 'phone' && splitStatus === SplitStatus.ONE_THREE_SPLIT ) {
      dailHeight = px2vp(this.windowHeightPx) - 32;
    } else if ((this.splitStatus === SplitStatus.TWO_THREE_SPLIT || this.splitStatus === SplitStatus.DEFAULT)) {
      dailHeight = 336;
    } else if ((deviceInfo.deviceType === 'phone' && !display.isFoldable()) ||
      (display.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) &&
        splitStatus === SplitStatus.VERTICAL_SPLIT) {
      dailHeight = px2vp(this.windowHeightPx) - 152;
    } else {
      dailHeight = 336;
    }
    return dailHeight;
  }

  /**
   * 判断是否是分屏场景。在分屏场景下调整部分UI
   * @param splitStatus
   * @returns
   */
  private isSplitScene(splitStatus: SplitStatus): boolean {
    let result: boolean = false;
    //上下分屏
    if (DisplaySplitUtil.isHorizonSplit(splitStatus)) {
      result = true;
    }
    //直板机左右分屏、折叠机折叠态左右分屏
    if ((deviceInfo.deviceType === 'phone') && DisplaySplitUtil.isVerticalSplit(splitStatus)) {
      if (!display.isFoldable() || (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED)) {
        result = true;
      }
    }
    return result;
  }

  deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();

  isShowTelNumber(): boolean {
    if (AppStorage.get('isVideoDialing') as boolean) {
      return true;
    }

    if (this.telNumberWithSpace.startsWith('*') || this.telNumberWithSpace.startsWith('#')) {
      return true;
    }

    if (this.telNumberWithSpace.length > 0 && this.showTelNumber &&
      (this.isVerde || this.curBp === 'sm' || (this.isShowSmartWindow && !this.isNavigationModeSplit))) {
      return true;
    }
    return false;
  }

  isBackCallLogPage() {
    if (this.isNavigationModeSplit || this.backCallLogPage == -1) {
      return
    }
    if (this.backCallLogPage == 0) {
      this.opacityChange();
      this.backCallLogPage = -1;
    }
    if (this.backCallLogPage == 1) {
      this.showNumber = true;
      this.opacityValue = 1;
      this.getUIContext()?.animateTo({ duration: 100, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }, () => {
        this.opacityValue = 0.5;
        this.animationFinished = true;
      })
      this.getUIContext()?.animateTo({ duration: 100, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }, () => {
        this.opacityValue = 1;
      })
    }
  }

  opacityChange() {
    if (!(AppStorage.get('isVideoDialing') as boolean)) {
      this.getUIContext()?.animateTo({ duration: 200, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }, () => {
        this.opacityValue = 0.3;
      })
      this.getUIContext()?.animateTo({ duration: 350, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1), delay: 200 },
        () => {
          this.opacityValue = 1;
          this.animationFinished = false;
        })
    }
  }

  //   dialerGuide: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.accessibility_more'),
  //       icon: $r('sys.symbol.dot_grid_2x2'),
  //       isEnabled: true,
  //       componentId: 'dialerMenuHds',
  //       action: () => {
  //         DotUtil.getInstance().contactDot(this.customizedParams, CLICK_CALL_LOG_MORE_EVENT);
  //         if (this.pasteStatus) {
  //           HiLog.w(TAG, 'more pasteStatus disappear');
  //           this.pasteStatus = false;
  //         }
  //         let uiContext = this.getUIContext();
  //         let promptAction = uiContext.getPromptAction();
  //         let contentNode = new ComponentContent<ParamsInterface>(uiContext,
  //           wrapBuilder<[ParamsInterface]>(menuComponent),
  //           { localAccountId: this.localAccountId,
  //             isHasPateDate: this.isHasPateDate,
  //             hasCallRecord: this.hasCallRecord,
  //             isThemeActive: this.isThemeActive,
  //             menuTitles: this.menuTitles,
  //             setCallSetting: () => {
  //               this.isShowCallSetting = true;
  //             },
  //             moreChooseParams: this.moreChooseParams,
  //             mPresenter: this.mPresenter,
  //           });
  //         try {
  //           promptAction.openMenu(
  //             contentNode,
  //             { id: 'dialerMenuHds' },
  //             { placement:Placement.BottomRight })
  //         } catch (error) {
  //           let err = error as BusinessError;
  //           HiLog.e(TAG, 'dialerGuide open menu message: ' + err.message + ', error code: ' + err.code);
  //         }
  //       }
  //     }
  //   }
  // ]

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.dialer')) },
  //     bottomBuilder: { builder: this.isVerde || this.clearAllRecord || this.telNumberWithSpace.length > 0 ? undefined :
  //       this.segmentButtonBuilder.bind(this) }
  //   };
  // }

  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.all_call_logs') },
      { text: $r('app.string.missed_call') }] as ItemRestriction<SegmentButtonTextItem>,
    textPadding: {
      left: $r('app.float.id_card_margin_large'),
      right: $r('app.float.id_card_margin_large'),
      bottom: $r('app.float.dialer_common_very_small_margin2'),
      top: $r('app.float.dialer_common_very_small_margin2'),
    },
    selectedFontSize: $r('sys.float.Body_M'),
    selectedFontColor: $r('app.color.skin_ohos_id_color_text_primary'),
    selectedBackgroundColor: $r('app.color.skin_ohos_id_color_foreground_contrary_disable'),
    fontSize: $r('sys.float.Body_M'),
    fontColor: $r('app.color.skin_ohos_id_color_text_secondary'),
    backgroundColor: $r('app.color.skin_ohos_id_color_button_normal'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Medium,
  })

  @Builder
  segmentButtonBuilder() {
    SegmentButton({
      options: this.singleSelectCapsuleOptions,
      selectedIndexes: $segmentButtonSelectedIndexes
    })
      .defaultFocus(false)
      .focusable(false)
      .height(this.isVerde ? 0 : '64vp')
      .padding(this.isVerde ? 0 : {
        top: $r('app.float.id_card_margin_large'),
        bottom: $r('app.float.id_card_margin_large'),
        left: this.spaceLR,
        right: this.spaceLR
      })
      .id('callRecord_contacts_allCalls_segmentButton')
      .animation({ curve: curves.interpolatingSpring(0, 1, 420, 41) })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
       Navigation() {
          Column() {
            if (!(this.isVerde || this.clearAllRecord || this.telNumberWithSpace.length > 0)) {
              this.segmentButtonBuilder()
            }

            // Blank().height(!this.isVerde && this.curBp === 'sm' && this.telNumberWithSpace.length > 0 ?
            //   $r('app.float.account_ItemList_text_width') : 0)
            // 没有拨号号码，显示通话记录，使用visibility 方式，如果使用if else 方式，从拨号页面右滑回到通话记录页面，会重新绘制通话记录，时间长，响应时延不达标
            CallRecord({
              listScroller: this.listScroller,
              controller: this.controller,
              isShowSegmentBtn: this.isShowSegmentBtn,
              missedScroller: this.missedScroller,
            })
              .onAppear(() => {
                HiLog.w(TAG, `CallRecord appear...`);
              })
              .transition(this.isNavigationModeSplit ? TransitionEffect.IDENTITY :
                TransitionEffect.asymmetric(this.backCallLogPage == 0 ? TransitionEffect.opacity(this.opacityValue)
                .animation({ duration: 350, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }) :
                TransitionEffect.IDENTITY, this.backCallLogPage == 1 ? TransitionEffect.OPACITY.animation({
                duration: 350, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }) : TransitionEffect.IDENTITY))
              .visibility(this.telNumberWithSpace.length === 0 ? Visibility.Visible : Visibility.None)
            // 拨号盘拨的电话号码
            Flex({
              direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center
            }) {
              TelNumber({ numberLocation: this.numberLocation })
            }
            .width('100%')
            .height(this.isSplitScene(this.splitStatus) ? 'auto' : this.isVerde ? 'auto' : $r('app.float.dialer_telephone_number_height'))
            .margin(this.isVerde ? {
              top: $r('sys.float.padding_level6'),
              bottom: $r('sys.float.padding_level1')
            } : null)
            .transition(this.isNavigationModeSplit ? TransitionEffect.IDENTITY : TransitionEffect.asymmetric(
              TransitionEffect.OPACITY
                .animation({ duration: 200, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }),
              TransitionEffect.IDENTITY))
            //分栏 左半边输入框要隐藏,未分栏输入框要占位
            .visibility(this.isShowTelNumber() ? Visibility.Visible :
              (this.isNavigationModeSplit && !this.showNumber ? Visibility.None : Visibility.Hidden))

            if (this.telNumberWithSpace.length > 0) {
              // 归属地
              if (this.showTelNumber && ((this.curBp == 'sm' && !this.isVerde) || (this.isVerde && !this.isShowBtn))) {
                Text(StringUtil.isEmpty(this.numberLocation) && this.isVerde ? ' ' : this.numberLocation)
                  .fontSize(this.isVerde ? '14vp' : this.splitStatus === SplitStatus.DEFAULT
                    ? $r('sys.float.ohos_id_text_size_sub_title3') : '14vp')
                  .fontColor($r('sys.color.font_secondary'))
                  .lineHeight(this.isVerde ? '16vp' : FontScaleState.isStandardGeer(this.fontSizeScale) ? '19vp' : 0)
                  .fontWeight(FontWeight.Regular)
                  .offset(this.isVerde ? null : {
                    x: 0,
                    y: this.isSplitScene(this.splitStatus) ? 0 : -25
                  })
                  .maxFontScale(2)
                  .transition(this.isNavigationModeSplit ? TransitionEffect.IDENTITY : TransitionEffect.asymmetric(
                    TransitionEffect.OPACITY
                      .animation({ duration: 200, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }),
                    TransitionEffect.IDENTITY))
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .margin({ bottom: this.isVerde ? $r('sys.float.padding_level3') : 0 })
              }

              if (!this.maintenanceMode) {
                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Center,
                  justifyContent: FlexAlign.Start
                }) {
                  // 拨号盘搜索内容列表
                  DialerSearchList({ mPresenter: $mPresenter, scroller: this.scroller, isSearch: this.isSearch });
                }
                .transition(this.isNavigationModeSplit ? TransitionEffect.IDENTITY : TransitionEffect.asymmetric(
                  TransitionEffect.OPACITY
                    .animation({ duration: 200, curve: curves.cubicBezierCurve(0.2, 0, 0.2, 1) }),
                  TransitionEffect.IDENTITY))
                .onDisAppear(() => {
                  AppStorage.setOrCreate('isVideoDialing', false);
                })
                .offset({
                  y: this.isSplitScene(this.splitStatus) ? 21 : 0
                })
                .margin({ top: this.isVerde ? 0 : this.curBp === 'sm' ? (this.marginTopOfSearchList()) : 0 })
                .width('100%')
                .height('100%')
                .layoutWeight(1)
                .zIndex(1)
                .onTouch(() => {
                  if (this.mPresenter.callBtnClick) {
                    return;
                  }
                  // 点击通话记录搜索空白处隐藏拨号盘，触发打点时机为手指按下时
                  this.dialerHideActionType = performanceMonitor.ActionType.LAST_DOWN;
                  this.showDialBtn = false;
                })
              }
            }
          }
          .layoutWeight(1)
          .zIndex(1)
        }
        .opacity(this.opacityValue)
        .mode(NavigationMode.Stack)
        .hideTitleBar((this.telNumberWithSpace.length > 0 || this.backCallLogPage == 1 || this.animationFinished) &&
          ((this.isVerde && this.showDialBtn) || DisplaySplitUtil.isSmOneThreeSplit(this.splitStatus) ||
          this.telNumberWithSpace.length > 0 &&
            (this.curBp === 'sm' || (this.isShowSmartWindow && !this.isNavigationModeSplit))))
        .onAppear(() => {
          // if (this.curBp === 'md' && this.isShowHarassmentPop || this.curBp != 'md' && this.isShowHarassmentPop &&
          //   this.telNumberWithSpace.length === 0) {
          //   let uiContext = this.getUIContext();
          //   let promptAction = uiContext.getPromptAction();
          //   let contentNode = new ComponentContent<openPopupParam>(uiContext,
          //     wrapBuilder<[openPopupParam]>(popupBuilder), { curBp: this.curBp });
          //   try {
          //     promptAction.openPopup(contentNode,
          //       { id: 'dialerMenuHds' },
          //       { placement: Placement.Bottom,
          //         mask: false,
          //         onStateChange: (e) => {
          //           HiLog.i(TAG, `openPopup isVisible: ${e.isVisible} `);
          //           if (!e.isVisible) {
          //             sharedPreferencesUtils.saveToPreferences('isShowHarassmentPop', false);
          //             this.isShowHarassmentPop = false;
          //           }
          //         }
          //       })
          //   } catch (error) {
          //     let err = error as BusinessError;
          //     HiLog.e(TAG, `openPopup error code is ${err.code}, message is ${err.message}`);
          //   }
          // }
        })
        .titleMode(this.isVerdeModel ? NavigationTitleMode.Mini : this.getNavigationTitleMode(this.splitStatus))
        // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.isVerde ? [] : this.dialerGuide, () => {}))
        // .dynamicHideTitleBar({
        //   hideBottomBuilder: true,
        // })
        // .bindToScrollable(this.curBp === 'md' && this.isSearch ? [this.scroller] :
        //   [this.missedScroller, this.listScroller])
       .hideBackButton(true)
       .title($r('app.string.dialer'),
         { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) })
       .menus(this.TitleGuide())
       .backgroundColor(Color.Transparent)
        .width('100%')
        .height('100%')
       .padding({ top: this.fullScreenPaddingTop })

      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')

      // 拨号按钮
      if (this.curBp === 'sm' || (this.isShowSmartWindow && !this.isNavigationModeSplit) || this.isVerde) {
        Column() {
          Button({ type: ButtonType.Circle }) {
            //white
            SymbolGlyph($r('sys.symbol.dial'))
              .fontSize($r('app.float.id_card_margin_xxxxl'))
              .fontColor([$r('app.color.skin_white')])
          }
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_expand_dialer')))
          .accessibilityLevel(this.showDialBtn ? 'no' : 'auto')
          .width($r('app.float.id_item_height_large'))
          .height((this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
            (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.id_item_height_large'))
          .backgroundColor($r('app.color.skin_confirm'))
          .clickEffect({ level: ClickEffectLevel.LIGHT })
          .onClick(() => {
            // 联系人打点--点击拨号盘按钮显示
            this.showDialerParams.ISSHOW = 1;
            DotUtil.getInstance().contactDot(this.showDialerParams, CLICK_DIALER_SHOW_EVENT);
            this.showDialBtn = true;
            if (!this.haveMultiSimCard || this.isAirplaneMode || (this.haveMultiSimCard && this.hasDefaultSlot())) {
              AccessibilityUtil.getInstance()
                .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dialer_btn_single');
            } else {
              AccessibilityUtil.getInstance()
                .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dialer_btn_multi');
            }
          })
          .id('dialer_contacts_sm_dial_btn')
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: this.isVerde ? $r('sys.float.padding_level4') : $r('sys.float.padding_level12')})
        .safeAreaPadding({ bottom: 48 })
        .zIndex(3)
        .offset({ y: this.mPresenter.buttonMoveY })
        .animation({ curve: this.dialerClickICurve })
      } else {
        Column() {
          if (this.isShowDial) {
            Button({ type: ButtonType.Circle }) {
              //white
              SymbolGlyph($r('sys.symbol.dial'))
                .fontSize($r('app.float.id_card_margin_xxxxl'))
                .fontColor([$r('app.color.skin_white')])
            }
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_expand_dialer')))
            .width($r('app.float.id_item_height_large'))
            .height($r('app.float.id_item_height_large'))
            .backgroundColor($r('app.color.skin_confirm'))
            .onClick(() => {
              // 联系人打点--点击拨号盘按钮显示
              this.showDialerParams.ISSHOW = 1;
              DotUtil.getInstance().contactDot(this.showDialerParams, CLICK_DIALER_SHOW_EVENT);
              HiLog.w(TAG, 'pathInfos onClick: DialerPad');
              this.activeCallId = -1;
              CallRecordPresenter.getInstance().toDefaultPage();
              this.isShowDial = false;
              if (!this.haveMultiSimCard || this.isAirplaneMode || (this.haveMultiSimCard && this.hasDefaultSlot())) {
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dialer_btn_single');
              } else {
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dialer_btn_multi');
              }
            })
            .id('dialer_contacts_sm_dial_btn')
          }
        }
        .justifyContent(FlexAlign.Center)
        .width($r('app.float.dialer_calllog_item_height'))
        .height($r('app.float.dialer_calllog_item_height'))
        .margin({ bottom: $r('sys.float.padding_level32') })
        .safeAreaPadding({ bottom: 48 })
        .zIndex(3)
      }

      // 拨号盘
      if (!this.isVerde && (this.curBp === 'sm' || (this.isShowSmartWindow && !this.isNavigationModeSplit))) {
        if (this.isHasPateDate && this.pasteStatus && !StringUtil.isEmpty(this.pasteData) && this.dialerShow) {
          Column() {
            Column() {
              Text($r('app.string.click_to_paste'))
                .lineHeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? '19vp' : 0)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
                .fontColor($r('app.color.skin_font_emphasize'))
              Text(this.pasteData)
                .lineHeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? '19vp' : 0)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
                .fontColor($r('app.color.skin_font_emphasize'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                .direction(Direction.Ltr)
            }
            .alignItems(HorizontalAlign.Center)
            .padding({
              top: $r('app.float.item_margin_width_4'),
              right: $r('app.float.dialer_keypad_margin1'),
              bottom: $r('app.float.item_margin_width_4'),
              left: $r('app.float.dialer_keypad_margin1')
            })
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles
            })
          }
          .id('paste_data')
          .onAppear(() => {
            HiLog.w(TAG, 'pasteDialog appear');
            this.isAppear = true;
            // 场景1.判断当前弹窗出现的时候刚好在电话页面
            if (this.isOpenAccessibility && (this.mainTabsIndex === IndexPresenter.getInstance().callIndex)) {
              HiLog.w(TAG, `pasteDialog appear and callIndex`);
              AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'paste_data');
            }
            // 联系人打点-粘贴弹窗打点
            DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.STICKER_BOARD_APPEAR_EVENT);
          })
          .onDisAppear(() => {
            HiLog.w(TAG, 'pasteDialog disAppear');
            this.isAppear = false;
          })
          .margin({
            right: $r('app.float.dialer_common_small_margin'),
            bottom: this.getDialHeight(this.splitStatus) + 8,
            left: $r('app.float.dialer_common_small_margin')
          })
          .safeAreaPadding({ bottom: 56 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Sharp }))
          .borderRadius($r('sys.float.corner_radius_level4'))
          .backgroundColor($r('app.color.skin_background_primary'))
          .onClick(() => {
            HiLog.w(TAG, 'pasteDialog Click!!!');
            this.mPresenter.pasteFunc();
            this.pasteStatus = false;
            // 联系人打点-点击粘贴号码
            DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.CLICK_STICKER_BOARD_EVENT);
          })
        }
          Column() {
            // 拨号盘
            DialPad().onAppear(() => {
              HiLog.w(TAG, `DialPad appear...`);
            })
            // 单卡 飞行 设置默认卡(双卡状态下)
            if (!this.haveMultiSimCard || this.isAirplaneMode || (this.haveMultiSimCard && this.hasDefaultSlot())) {
              this.averageBuilder()
            } else {
              // 双卡未设置默认卡
              Row() {
                Row() {
                  Button() {
                    SymbolGlyph($r('sys.symbol.dial'))
                      .fontSize($r('app.float.id_card_image_small'))
                      .fontColor([$r('app.color.skin_icon_primary')])
                      .margin({ top: this.getDialButtonMargin(), bottom: this.getDialButtonMarginBottom() })
                  }
                  .type(ButtonType.Normal)
                  .buttonStyle(ButtonStyleMode.TEXTUAL)
                  .width($r('app.float.id_item_height_large'))
                  .height((this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                    (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.id_item_height_large'))
                  .borderRadius($r('app.float.id_card_image_height'))
                  .onClick(() => {
                    // 联系人打点--点击拨号盘隐藏按钮
                    this.showDialerParams.ISSHOW = 0;
                    DotUtil.getInstance().contactDot(this.showDialerParams, CLICK_DIALER_SHOW_EVENT);
                    // 双卡时点击按钮触发拨号盘隐藏，触发打点时机为手机抬起时
                    this.dialerHideActionType = performanceMonitor.ActionType.LAST_UP;
                    this.showDialBtn = false;
                    AccessibilityUtil.getInstance()
                      .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dial_btn');
                  })
                  .id('dialer_contacts_sm_dialer_btn_multi')
                  .accessibilityText(AccessibilityUtil.getInstance()
                    .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_fold_dialer')))
                }
                .width($r('app.float.id_item_height_large'))
                .height(DisplaySplitUtil.isSmLeft(this.splitStatus) ? 52 :
                  (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                    (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.dialer_calllog_item_height'))
                .margin({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_mid') })
                .alignItems(VerticalAlign.Center)
                .justifyContent(this.haveMultiSimCard && !this.hasDefaultSlot() && !this.isAirplaneMode ?
                FlexAlign.End : FlexAlign.Center)

                // 电话图标
                DialerButtonView({
                  mPresenter: $mPresenter,
                })
                  .layoutWeight(1)

                Row() {
                  Button() {
                    SymbolGlyph($r('sys.symbol.delete_left_fill'))
                      .fontSize($r('app.float.id_card_image_small'))
                      .fontColor([$r('app.color.skin_icon_primary')])
                  }
                  .type(ButtonType.Normal)
                  .buttonStyle(ButtonStyleMode.TEXTUAL)
                  .width($r('app.float.id_item_height_large'))
                  .height(DisplaySplitUtil.isSmLeft(this.splitStatus) ? 52 :
                    (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                      (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.id_item_height_large'))
                  .borderRadius($r('app.float.id_card_image_height'))
                  .enabled(this.telNumberWithSpace.length > 0 ? true : false)
                  .gesture(
                    LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
                      .onAction((event: GestureEvent | undefined) => {
                        this.mPresenter.resetTelNumber();
                        this.mPresenter.editPhoneNumber('');
                        VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                        // 无障碍播报号码已清空
                        AccessibilityUtil.getInstance()
                          .sendAccessibilityEventInfo(ResourceUtil.getStringByResource($r('app.string.accessibility_Text_cleared')));
                      })
                  )
                  .onClick(() => {
                    // 联系人打点--拨号盘删除号码
                    DotUtil.getInstance().contactDot(this.customizedParams, DELETE_NUM_EVENT);
                    let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
                      AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
                    number = this.mPresenter.deleteStr(number); //删除之后的号码
                    AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number)
                  })
                  .id('dialer_contacts_sm_delete_btn')
                  .accessibilityText(AccessibilityUtil.getInstance()
                    .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
                }
                .margin({ top: this.getDialButtonMargin(), bottom: this.getDialButtonMarginBottom() })
                .width($r('app.float.id_item_height_large'))
                .height((this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                  (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.dialer_calllog_item_height'))
                .margin({ left: $r('app.float.id_card_margin_mid'), right: $r('app.float.id_card_margin_large') })
                .alignItems(VerticalAlign.Center)
                .justifyContent(this.haveMultiSimCard && !this.hasDefaultSlot() && !this.isAirplaneMode ?
                FlexAlign.Start : FlexAlign.Center)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(this.haveMultiSimCard && !this.hasDefaultSlot() && !this.isAirplaneMode ?
              FlexAlign.SpaceBetween : FlexAlign.Center)

              .margin({
                left: $r('sys.float.padding_level8'),
                right: $r('sys.float.padding_level8'),
                bottom: $r('app.float.id_setting_22'),
              })
              .padding({
                left: this.haveMultiSimCard && !this.hasDefaultSlot() && !this.isAirplaneMode ?
                $r('sys.float.padding_level0') : $r('sys.float.padding_level8'),
                right: this.haveMultiSimCard && !this.hasDefaultSlot() && !this.isAirplaneMode ?
                $r('sys.float.padding_level0') : $r('sys.float.padding_level8')
              })
            }
          }
          .margin({ bottom: 48 })
          .accessibilityGroup(this.showDialBtn ? false : true)
          .accessibilityLevel(this.showDialBtn ? 'auto' : 'no')
          .width('100%')
          .zIndex(this.showDialBtn ? 2 : -1)
          .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
          $r('app.color.skin_comp_background_primary'))
          .backgroundImage(this.isThemeActive ? $r('app.media.dialer_bg') : undefined)
          .backgroundImageSize({ width: '100%', height: '100%' })
          .onTouch((event: TouchEvent) => {
            switch (event.type) {
            // touch down
              case TouchType.Down:
                this.downY = -1;
                break;

            // touch move
              case TouchType.Move:
                if (this.downY === -1) {
                  this.downY = event.touches[0].y;
                }
                break;
            // touch up
              case TouchType.Up:
              case TouchType.Cancel:
                const upY: number = event.touches[0].y;
                if (this.downY != -1 && upY - this.downY > 100) {
                  this.showDialBtn = false;
                }
                break;
            }
          })
        .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
        $r('app.color.skin_comp_background_primary'))
        .width('100%')
        .clip(new Rect({
          width: '100%',
          height: '336',
          radius: [[DialerPresenter.RADIUS_SIZE, DialerPresenter.RADIUS_SIZE],
            [DialerPresenter.RADIUS_SIZE, DialerPresenter.RADIUS_SIZE], [0, 0], [0, 0]]
        }))
        .shadow({
          radius: 30,
          color: 'rgba(0,0,0,0.12)',
          offsetX: 0,
          offsetY: -2
        })
        .zIndex(2)
        .offset({ y: this.mPresenter.moveY })
        .animation({
          curve: this.dialerButtonICurve,
          onFinish: () => {
            HiLog.i(TAG, `animation complete ${this.showDialBtn} btnShow is ${this.mPresenter.btnShow}`);
            if (this.showDialBtn) {
              this.dialerShow = true;
              performanceMonitor.end('CONTACTS_DIALER_SHOW');
            } else {
              this.dialerShow = false;
              performanceMonitor.end('CONTACTS_DIALER_HIDE');
            }
          }
        })
        .height(this.getDialHeight(this.splitStatus))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
    .bindSheet((this.curBp === 'sm' && this.isShowImeiPanel), DialBindSheetBuilder({ mPresenter: this.mPresenter }), {
      height: 556,
      title: { title: $r('app.string.device_info') },
      detents: [556, 557],
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      onWillAppear: () => {
        HiLog.w(TAG, `ImeiPanel appear`);
        this.mPresenter.resetTelNumber();
      },
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        HiLog.w(TAG, `ImeiPanel shouldDismiss, isShowImeiPanel: ${this.isShowImeiPanel}`);
        this.isShowImeiPanel = !this.isShowImeiPanel;
        DialerPresenter.getInstance().isShowImeiPanel = false;
      },
      onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
      })
    })
  }

  onDidBuild(): void {
    HiLog.w(TAG, `Dialer onDidBuild`);
  }

  @Builder
  averageBuilder() {
    Row() {
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.dial'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
            .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
        }
         .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_fold_dialer')))
        .type(ButtonType.Normal)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .width($r('app.float.id_item_height_large'))
        .height((DisplaySplitUtil.isSmLeft(this.splitStatus)) ? 52 :
          (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
            (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.id_item_height_large'))
        .borderRadius($r('app.float.id_card_image_height'))
        .onClick(() => {
          // 联系人打点--点击拨号盘隐藏按钮
          this.showDialerParams.ISSHOW = 0;
          DotUtil.getInstance().contactDot(this.showDialerParams, CLICK_DIALER_SHOW_EVENT);
          // 单卡时点击按钮触发拨号盘隐藏，触发打点时机为手机抬起时
          this.dialerHideActionType = performanceMonitor.ActionType.LAST_UP;
          this.showDialBtn = false;
          AccessibilityUtil.getInstance()
            .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dial_btn');
        })
        .id('dialer_contacts_sm_dialer_btn_single')
      }.layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // 电话图标
      DialerButtonView({
        mPresenter: $mPresenter,
      }).layoutWeight(1)
        .align(Alignment.Center)

      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.delete_left_fill'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
            .margin({ top : this.getDialButtonMargin(), bottom : this.getDialButtonMarginBottom() })
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
        .type(ButtonType.Normal)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .width($r('app.float.id_item_height_large'))
        .height((DisplaySplitUtil.isSmLeft(this.splitStatus)) ? 52 :
          (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
            (this.splitStatus === SplitStatus.HALF_SPLIT) ? 52 : $r('app.float.id_item_height_large'))
        .borderRadius($r('app.float.id_card_image_height'))
        .enabled(this.telNumberWithSpace.length > 0 ? true : false)
        .gesture(
          LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
            .onAction((event: GestureEvent | undefined) => {
              this.mPresenter.resetTelNumber();
              this.mPresenter.editPhoneNumber('');
              VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
              if (this.pasteStatus) {
                HiLog.w(TAG, `longPressDeleteButton pasteStatus disappear`);
                this.pasteStatus = false;
              }
              // 无障碍播报号码已清空
              AccessibilityUtil.getInstance()
                .sendAccessibilityEventInfo(ResourceUtil.getStringByResource($r('app.string.accessibility_Text_cleared')));
            })
        )
        .onClick(() => {
          // 联系人打点--拨号盘删除号码
          DotUtil.getInstance().contactDot(this.customizedParams, DELETE_NUM_EVENT);
          let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
            AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
          number = this.mPresenter.deleteStr(number); //删除之后的号码
          AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number)
          if (this.pasteStatus) {
            HiLog.w(TAG, `deleteButton pasteStatus disappear`);
            this.pasteStatus = false;
          }
        })
        .id('dialer_contacts_sm_delete_btn')
      }.layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(VerticalAlign.Center)
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) || (this.splitStatus === SplitStatus.HALF_SPLIT) ?
        16 : 22
    })
    .safeAreaPadding({ bottom: 56 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  TitleGuide() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
      Button() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_more')))
      .onClick(() => {
        // 联系人打点--通话记录右上角点击更多
        DotUtil.getInstance().contactDot(this.customizedParams, CLICK_CALL_LOG_MORE_EVENT);
        if (this.pasteStatus) {
          HiLog.w(TAG, 'more pasteStatus disappear');
          this.pasteStatus = false;
        }
      })
      .id('dialer_contacts_titleGuide_btn')
      //菜单弹框
      .bindMenu(this.MenuBuilder, {
        placement: (this.windowHeightPx <= this.deviceDisplayInfo.height / 3) ? Placement.BottomLeft :
          Placement.BottomRight,
        backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
        backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK
      })
      // .bindPopup((this.curBp === 'md' ? this.isShowHarassmentPop :
      //   (this.isShowHarassmentPop && this.telNumberWithSpace.length === 0)), {
      //   radius: $r('sys.float.corner_radius_level9'),
      //   message: ResourceUtil.getStringByResource($r('app.string.disturbing_intercept_boot_bubble')),
      //   messageOptions: {
      //     textColor: $r('sys.color.comp_foreground_primary'),
      //     font: {
      //       size: $r('sys.float.Body_M'),
      //       weight: FontWeight.Regular,
      //       family: 'HarmonyHeiTi',
      //     }
      //   },
      //   arrowPointPosition: ArrowPointPosition.CENTER,
      //   autoCancel: true,
      //   onStateChange: (e) => {
      //     HiLog.w(TAG, `isVisible: ${e.isVisible} `);
      //     if (!e.isVisible) {
      //       sharedPreferencesUtils.saveToPreferences('isShowHarassmentPop', false);
      //       this.isShowHarassmentPop = false;
      //     }
      //   }
      // })
      .margin({ right: $r('app.float.id_card_margin_xxl'), left: $r('app.float.id_card_margin_xxl') })
      .type(ButtonType.Circle)
      .height($r('app.float.id_item_height_sm'))
      .width($r('app.float.id_item_height_sm'))
      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .stateEffect(true)
    }
    .width('50%')
    .width('50%')
    .height($r('app.float.id_item_height_large'))
  }

  @Builder
  VoiceMailMultiCardDialogBuilder() {
    Column() {
      Row() {
        Text($r('app.string.sim_card', numFormat(1)))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.skin_font_primary'))
          .padding({
            top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, 0),
            bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, 0)
          })
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 48 })
      .width('100%')
      .onClick(() => {
        HiLog.i(TAG, 'selected card one')
        this.mPresenter.cardSelected(this.getUIContext(), 0);
        this.voiceMailMultiCardDialog?.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
      })
      .id('dialer_contacts_cardOne_btn')

      Divider()
        .height(0.5)
        .width('100%')
        .backgroundColor($r('app.color.skin_comp_divider'))

      Row() {
        Text($r('app.string.sim_card', numFormat(2)))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.skin_font_primary'))
          .padding({
            top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, 0),
            bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, 0)
          })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({ minHeight: 48 })
      .onClick(() => {
        HiLog.i(TAG, 'selected card two')
        this.mPresenter.cardSelected(this.getUIContext(), 1);
        this.voiceMailMultiCardDialog?.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
      })
      .id('dialer_contacts_cardTwo_btn')
    }
    .width('100%')
  }

  @Builder
  SelectSlotIdDialogBuilder() {
    Column() {
      SelectSimIdDialog({
        builder: this.builder,
        controller: this.mSelectSlotIdDialog as CustomDialogController
      })
    }
    .width('100%')
  }

}

@Builder
function menuComponent(params: ParamsInterface) {
  Column() {
    Menu() {
      ForEach(params.menuTitles, (item: Resource, index?: number) => {
        if (params.localAccountId || index != 3) {
          if (index !== 0) {
            menuDividerHds()
          }
          MenuItem({ content: item })
            .onClick(() => {
              if (index === 0) {
                DialerPresenter.getInstance().pasteFunc();
              } else if (index === 1) {
                // 联系人打点--通话记录更多选项卡-通话录音
                params.moreChooseParams.ITEM = 0;
                DotUtil.getInstance().contactDot(params.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                if (isCallRecorderEnable()) {
                  HiLog.i(TAG, `jumpToRecordList`);
                  DialerPresenter.getInstance().jumpToRecordList();
                } else {
                  HiLog.i(TAG, `pop toastForCallRecorderDisable`);
                  toastForCallRecorderDisable();
                }
              } else if (index === 2) {
                // 联系人打点--通话记录更多选项卡-批量删除
                params.moreChooseParams.ITEM = 1;
                DotUtil.getInstance().contactDot(params.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                DialerPresenter.getInstance().jumpBatchDeleteView();
              } else if (index === 3) {
                //跳转通话防护界面
                DialerPresenter.getInstance().jumpToHarassmentFilter();
              } else if (index === 4) {
                // 联系人打点--通话记录更多选项卡-设置
                params.moreChooseParams.ITEM = 2;
                DotUtil.getInstance().contactDot(params.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                params.setCallSetting();
              } else {
                // 跳转帮助和反馈
                DialerPresenter.getInstance().jumpToFeedbackMenu();
              }
            })
            .id('dialer_set_bnt')
            .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.ohos_id_text_size_body1') })
            .contentFontColor(params.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
            .enabled((index === 3 || index === 4 || index === 5) ? ((!params.localAccountId && index === 4) ? false :
              true) : ((index === 0 ? params.isHasPateDate : (params.hasCallRecord ? true : false))))
        }
      }, (item: Resource) => item.id.toString())
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }
  .width($r('app.float.account_MenuBuilder_width_xl'))
}

@Builder
function menuDividerHds() {
  Divider()
    .color($r('app.color.skin_ohos_id_color_list_separator'))
    .height('1px')
    .lineCap(LineCapStyle.Square)
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
}

@Builder
function popupBuilder(param: openPopupParam) {
    Text($r('app.string.disturbing_intercept_boot_bubble'))
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .padding({
        top: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level6'),
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6')
      })
      .maxFontScale(2)
      .constraintSize({ maxWidth: param.curBp === 'md' ? '400vp' : `calc(100% - ${POPUP_PITCH_WIDTH}vp)` })
}