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

import CallRecord from './callRecord/CallRecord'
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import DialerSearchList from '../phone/dialer/DialerSearchList';
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';
import DotUtil from '../../util/DotUtil';
import { CustomizedParams } from '../../model/type';
import IndexPresenter from '../../presenter/IndexPresenter';
import DialerConstant from '../../data/DialerConstant';
import { ComponentContent, curves, CustomContentDialog, TextModifier } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { SplitStatus } from '../../util/DisplaySplitUtil';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ResourceUtil } from '../../util/ResourceUtil';
import { sharedPreferencesUtils } from '../../../../../../common';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { Controller, SelectDialogBuilder, SelectSimIdDialog } from '../dialog/SelectSimIdDialog';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit'
// import { HdsNavigationBadgeIconOptions } from '@hms.hds.hdsBaseComponent';
import { ItemRestriction, SegmentButton, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { SegmentButtonOptions } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import SideBarButton from '../SideBarButton';
import { isCallRecorderEnable, toastForCallRecorderDisable } from '../../util/CheckRestoreUtils';

const TAG = 'DialerTablet';
const CALL_MORE_CHOOSE_EVENT = 'CALL_MORE_CHOOSE_EVENT';
const DIALER_TEL_NUMBER_EMPTY = 0;
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';
class MainTitleTextModifier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

interface callmenuFn {
  value: string,
  action: () => void
}

interface ParamsInterface {
  localAccountId: boolean,
  isHasPateDate: boolean,
  hasCallRecord: boolean,
  isThemeActive: boolean,
  menuRes: Array<Resource>,
  setCallSetting: Function,
  moreChooseParams: CustomizedParams,
  mPresenter: DialerPresenter,
  isOnCallSharingValue: boolean
}

@Component
export default struct CallTablet {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance();
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) telNumber: string = '';
  @State menuRes: Array<Resource> = [$r('app.string.call_setting_type_paste'), $r('app.string.call_recorder_list'),
    $r('app.string.call_setting_type_batch_delete'), $r('app.string.commotion_intercept'),
    $r('app.string.call_setting_type_setting'), $r('app.string.Help_and_feedback')];
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('callLogListEmpty') callLogListEmpty: boolean = true;
  @StorageLink('missedListEmpty') missedListEmpty: boolean = true;
  @StorageLink('clearAllRecord') clearAllRecord: boolean = false;
  @StorageLink('isHasDate') isHasPateDate: boolean = false;
  selectAll: boolean = false;
  textInputController: TextInputController = new TextInputController();
  @State textInputFocusable: boolean = false;
  @StorageLink('isShowDial') isShowDial: boolean = false;
  @StorageLink('hasCallRecord') hasCallRecord: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('breakpoint') curBp: string = '';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageLink('mainTabsIndex') mainTabsIndex: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  safeAreaBottom: number = px2vp(this.fullScreenPadding.top as number) + 24
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModifier = new MainTitleTextModifier();
  @State builder: SelectDialogBuilder = this.mPresenter.builder;
  @StorageLink('isPrimaryAccount') localAccountId: boolean = false;
  // 是否拉起通话设置模态窗口
  @Consume('isShowCallSetting') isShowCallSetting: boolean;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('activeCallId') activeCallId: number = -1;
  @StorageLink('isShowHarassmentPop') isShowHarassmentPop: boolean = false;
  @StorageLink('isOnCallSharingValue') isOnCallSharingValue: boolean = false;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  private controller: TabsController = new TabsController();
  private listScroller: ListScroller = new ListScroller();
  private missedScroller: ListScroller = new ListScroller();
  private scroller: ListScroller = new ListScroller();
  @State @Watch('onSegmentButtonIndexChanged') segmentButtonSelectedIndexes: number[] = [0]
  @State isSearch: boolean = false;
  @Prop isShowOpenMousePopup: boolean; // PC上手型tips是否展示
  @StorageLink('showSideBar') showSideBar: boolean = true;
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

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear CallTablet ');
    this.mPresenter.aboutToAppear();
    if (this.mainTabsIndex === IndexPresenter.getInstance().callIndex && this.pathInfos.size() <= 0) {
      CallRecordPresenter.getInstance().toDefaultPage();
    }

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
    if (this.isPC) {
      return;
    }
    this.mPresenter.onDestroy();
  }

  onSegmentButtonIndexChanged() {
    let seletedIndex: number = this.segmentButtonSelectedIndexes[0];
    this.controller.changeIndex(seletedIndex);
  }

  // CustomKeyboardBuilder
  @Builder
  CustomKeyboardBuilder() {
    Column() {
    }
  }

  moreChooseParams: CustomizedParams = {
    ITEM: 0
  };

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
      .height('64vp')
      .padding({
        top: $r('app.float.id_card_margin_large'),
        bottom: $r('app.float.id_card_margin_large'),
        left: this.spaceLR,
        right: this.spaceLR
      })
      .id('callRecord_contacts_allCalls_segmentButton')
      .animation({ curve: curves.interpolatingSpring(0, 1, 420, 41) })
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.dialer')) },
  //     bottomBuilder: { builder: this.clearAllRecord || this.telNumber.length > DIALER_TEL_NUMBER_EMPTY ? undefined :
  //       this.segmentButtonBuilder.bind(this) }
  //   };
  // }

  // dialerGuide: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.accessibility_more'),
  //       icon: $r('sys.symbol.dot_grid_2x2'),
  //       isEnabled: true,
  //       componentId: 'dialerTabletMenu',
  //       action: () => {
  //         let uiContext = this.getUIContext();
  //         let promptAction = uiContext.getPromptAction();
  //         let contentNode = new ComponentContent<ParamsInterface>(uiContext,
  //           wrapBuilder<[ParamsInterface]>(menuComponent),
  //           { localAccountId: this.localAccountId,
  //             isHasPateDate: this.isHasPateDate,
  //             hasCallRecord: this.hasCallRecord,
  //             isThemeActive: this.isThemeActive,
  //             menuRes: this.menuRes,
  //             setCallSetting: () => {
  //               this.isShowCallSetting = true;
  //             },
  //             moreChooseParams: this.moreChooseParams,
  //             mPresenter: this.mPresenter,
  //             isOnCallSharingValue: this.isOnCallSharingValue
  //           });
  //         try {
  //           promptAction.openMenu(
  //             contentNode, { id: 'dialerTabletMenu' }, { placement:Placement.BottomRight })
  //         } catch (error) {
  //           HiLog.e(TAG, 'dialerGuide open menu message: ' + error?.message + ', error code: ' + error?.code);
  //         }
  //       }
  //     }
  //   }
  // ]

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.isPC) {
        Navigation() {
          this.DialerTabletBuilder()
        }
        .mode(NavigationMode.Stack)
        .backgroundColor(Color.Transparent)
        .titleMode((this.callLogListEmpty && this.missedListEmpty) || this.clearAllRecord ?
          NavigationTitleMode.Full : NavigationTitleMode.Free)
        .title($r('app.string.dialer'),
          { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) })
        .menus(this.TitleGuide())
        .hideTitleBar(this.isPC)
        .width('100%')
        .height('100%')

        if (this.isShowDial) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.dial'))
              .fontSize('32vp')
              .fontColor([$r('app.color.skin_white')])
          }
          .margin({ bottom: this.isTabletLandscape ? this.safeAreaBottom : '24vp' })
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_expand_dialer')))
          .width($r('app.float.id_item_height_large'))
          .height($r('app.float.id_item_height_large'))
          .backgroundColor($r('app.color.skin_confirm'))
          .onClick(() => {
            HiLog.w(TAG, 'pathInfos onClick: DialerPad');
            CallRecordPresenter.getInstance().toDefaultPage();
            this.activeCallId = -1;
          })
        }
      } else {
        Navigation() {
          this.DialerTabletBuilder()
        }
        .mode(NavigationMode.Stack)
        .backgroundColor(Color.Transparent)
        .onAppear(() => {
          // if (this.isShowHarassmentPop) {
          //   let uiContext = this.getUIContext();
          //   let promptAction = uiContext.getPromptAction();
          //   let contentNode = new ComponentContent(uiContext, wrapBuilder(popupBuilder));
          //   try {
          //     promptAction.openPopup(contentNode,
          //       { id: 'dialerTabletMenu' },
          //       { placement: Placement.Bottom,
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
        .titleMode(((this.callLogListEmpty && this.missedListEmpty) || this.clearAllRecord) &&
          this.telNumber.length === DIALER_TEL_NUMBER_EMPTY ? NavigationTitleMode.Full : NavigationTitleMode.Free)
        .title(ResourceUtil.getStringByResource($r('app.string.dialer')),
          { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) })
        .menus(this.TitleGuide())
        // .titleMode(((this.callLogListEmpty && this.missedListEmpty) || this.clearAllRecord) &&
        //   this.telNumber.length === DIALER_TEL_NUMBER_EMPTY ? HdsNavigationTitleMode.FULL : HdsNavigationTitleMode.FREE)
        // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.dialerGuide, () => {
        // }))
        // .dynamicHideTitleBar({
        //   hideBottomBuilder: true
        // })
        // .bindToScrollable(this.isSearch ? [this.scroller] : [this.missedScroller, this.listScroller])
        .hideTitleBar(this.isPC)
        .width('100%')
        .height('100%')

        if (this.isShowDial) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.dial'))
              .fontSize('32vp')
              .fontColor([$r('app.color.skin_white')])
          }
          .margin({ bottom: this.isTabletLandscape ? this.safeAreaBottom : '24vp' })
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_expand_dialer')))
          .width($r('app.float.id_item_height_large'))
          .height($r('app.float.id_item_height_large'))
          .backgroundColor($r('app.color.skin_confirm'))
          .onClick(() => {
            HiLog.w(TAG, 'pathInfos onClick: DialerPad');
            CallRecordPresenter.getInstance().toDefaultPage();
            this.activeCallId = -1;
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.skin_background_primary'))
  }

  @Builder
  DialerTabletBuilder() {
    if (this.isPC) {
      this.TitleGuide();
    }
    if (!this.isInVisionGlass) {
      CallRecord({
        controller: this.controller,
        listScroller: this.listScroller,
        missedScroller: this.missedScroller
      })
        .visibility(this.telNumber.length > DIALER_TEL_NUMBER_EMPTY ? Visibility.None : Visibility.Visible);
      // 拨号码长度
      if (this.telNumber.length > DIALER_TEL_NUMBER_EMPTY) {
        DialerSearchList({ mPresenter: $mPresenter, scroller: this.scroller, isSearch: this.isSearch });
      }
    } else {
      CallRecord({
        controller: this.controller,
        listScroller: this.listScroller,
        missedScroller: this.missedScroller
      })
        .visibility(this.telNumber.length > DIALER_TEL_NUMBER_EMPTY ? Visibility.None : Visibility.Visible);
      // 拨号码长度
      if (this.telNumber.length > DIALER_TEL_NUMBER_EMPTY) {
        DialerSearchList({ mPresenter: $mPresenter, scroller: this.scroller, isSearch: this.isSearch });
      }
    }
  }

  @Builder
  TitleGuide() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: this.isPC && !this.showSideBar ? FlexAlign.SpaceBetween : FlexAlign.End
    }) {
      if (this.isPC && !this.showSideBar) {
        SideBarButton()
      }
      Button() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize($r('app.float.id_card_margin_max'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .height($r('app.float.id_item_height_sm'))
      .width($r('app.float.id_item_height_sm'))
      .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : $r('sys.float.corner_radius_level10'))
      .type(ButtonType.Normal)
      .bindMenu(this.MenuBuilder, {
        placement: Placement.BottomRight,
        backgroundColor: $r('app.color.skin_ohos_id_color_dialog_bg'),
        backgroundBlurStyle: BlurStyle.NONE,
        onAppear: () => {
          if (this.pasteStatus) {
            HiLog.w(TAG, 'dialerTablet more pasteStatus disappear');
            this.pasteStatus = false;
          }
        }
      })
      .onClick(() => {
        // 仅用于支持获焦
      })
      // .bindPopup(this.isShowHarassmentPop, {
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
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_more')))
    }
    .height($r('app.float.id_item_height_large'))
    .margin({
      left: this.isPC ? $r('sys.float.padding_level8') : 0,
      right: this.isPC ? $r('sys.float.padding_level8') : this.spaceLR
    })
    .zIndex(3)
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      ForEach(this.menuRes, (item: Resource, index?: number) => {
        if ((this.localAccountId && call.hasVoiceCapability()) ||
          (!call.hasVoiceCapability() && this.mPresenter.callMenuBoolean(index as number)) ||
          !this.localAccountId && index != 3) {
          if (!this.isPC && index !== 0) {
            this.MenuDivider()
          }
          MenuItem({ content: item })
            .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
            .onClick(() => {
              if (index === 0) {
                this.mPresenter.pasteFunc();
              } else if (index === 1) {
                // 联系人打点--通话记录更多选项卡-通话录音
                this.moreChooseParams.ITEM = 0;
                DotUtil.getInstance().contactDot(this.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                if (this.isOnCallSharingValue) {
                  this.mPresenter.jumpToRecordList();
                }
              } else if (index === 2) {
                // 联系人打点--通话记录更多选项卡-批量删除
                this.moreChooseParams.ITEM = 1;
                DotUtil.getInstance().contactDot(this.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
                this.mPresenter.jumpBatchDeleteView();
              } else if (index === 3) {
                //跳转通话防护界面
                if (this.isOnCallSharingValue) {
                  //跳转通话防护界面
                  this.mPresenter.jumpToHarassmentFilter();
                }
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
            .contentFont({
              weight: FontWeight.Medium,
              size: this.isPC ? $r('sys.float.Body_L') : $r('sys.float.ohos_id_text_size_body1')
            })
            .contentFontColor(this.isPC ? $r('sys.color.font_primary') :
              this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
            .enabled((index === 3 || index === 4 || index === 5) ?
              ((!this.localAccountId && index === 4) ? false : true) :
              (index === 0 ? this.isHasPateDate : (this.hasCallRecord ? true : false)))
            .opacity(((index === 1 && this.hasCallRecord) || index === 3) &&
              !this.isOnCallSharingValue ? $r('sys.float.alpha_tertiary') : 1)
            .id('dialerTablet_contacts_more_menuItem')
            .margin({
              top: this.isPC ? $r('sys.float.padding_level1') : 0
            })
        }
      }, (item: Resource) => item.id.toString())
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
    .radius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
  }
}

@Builder
function menuComponent(params: ParamsInterface) {
  Menu() {
    ForEach(params.menuRes, (item: Resource, index?: number) => {
      if ((params.localAccountId && call.hasVoiceCapability()) ||
        (!call.hasVoiceCapability() && params.mPresenter.callMenuBoolean(index as number)) ||
        !params.localAccountId && index != 3) {
        if (!EnvironmentProp.isPC() && index !== 0) {
          menuDividerHds()
        }
        MenuItem({ content: item })
          .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
          .onClick(() => {
            if (index === 0) {
              DialerPresenter.getInstance().pasteFunc();
            } else if (index === 1) {
              // 联系人打点--通话记录更多选项卡-通话录音
              params.moreChooseParams.ITEM = 0;
              DotUtil.getInstance().contactDot(params.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
              if (params.isOnCallSharingValue) {
                if (isCallRecorderEnable()) {
                  HiLog.i(TAG, `jumpToRecordList`);
                  DialerPresenter.getInstance().jumpToRecordList();
                } else {
                  HiLog.i(TAG, `pop toastForCallRecorderDisable`);
                  toastForCallRecorderDisable();
                }
                DialerPresenter.getInstance().jumpToRecordList();
              }
            } else if (index === 2) {
              // 联系人打点--通话记录更多选项卡-批量删除
              params.moreChooseParams.ITEM = 1;
              DotUtil.getInstance().contactDot(params.moreChooseParams, CALL_MORE_CHOOSE_EVENT);
              DialerPresenter.getInstance().jumpBatchDeleteView();
            } else if (index === 3) {
              //跳转通话防护界面
              if (params.isOnCallSharingValue) {
                //跳转通话防护界面
                DialerPresenter.getInstance().jumpToHarassmentFilter();
              }
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
          .contentFont({
            weight: FontWeight.Medium,
            size: EnvironmentProp.isPC() ? $r('sys.float.Body_L') : $r('sys.float.ohos_id_text_size_body1')
          })
          .contentFontColor(EnvironmentProp.isPC() ? $r('sys.color.font_primary') :
            params.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
          .enabled((index === 3 || index === 4 || index === 5) ?
            ((!params.localAccountId && index === 4) ? false : true) :
            (index === 0 ? params.isHasPateDate : (params.hasCallRecord ? true : false)))
          .opacity(((index === 1 && params.hasCallRecord) || index === 3) &&
            !params.isOnCallSharingValue ? $r('sys.float.alpha_tertiary') : 1)
          .id('dialerTablet_contacts_more_menuItem')
          .margin({
            top: EnvironmentProp.isPC() ? $r('sys.float.padding_level1') : 0
          })
      }
    }, (item: Resource) => item.id.toString())
  }
  .width($r('app.float.account_MenuBuilder_width_xl'))
  .backgroundBlurStyle(EnvironmentProp.isPC() ? BlurStyle.COMPONENT_REGULAR : undefined)
  .shadow({
    radius: EnvironmentProp.isPC() ? $r('sys.float.ohos_id_default_shadow_s') : 0
  })
  .radius(EnvironmentProp.isPC() ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
}

@Builder
function menuDividerHds() {
  Divider()
    .color($r('app.color.skin_comp_divider'))
    .lineCap(LineCapStyle.Square)
    .width(0)
    .alignSelf(ItemAlign.Stretch)
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
}

@Builder
function popupBuilder() {
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
    .constraintSize({ maxWidth: '400vp' })
}
