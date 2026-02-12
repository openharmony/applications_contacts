/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 工具类导入
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { SelectDialogBuilder } from '../dialog/SelectSimIdDialog';
import { MultiNumCardItems, SelectMultiNumDialog } from '../dialog/SelectMultiNumDialog';
import { SelectNumDialogBuilder } from '../dialog/SelectMultiNumDialog';
import { SelectSimIdDialog } from '../dialog/SelectSimIdDialog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common';
import FavoriteListPresenter from '../../presenter/favorite/FavoriteListPresenter';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import emitter from '@ohos.events.emitter';
import { Phone } from '../../../../../../feature/contact/src/main/ets/contract/Phone';
import prompt from '@ohos.promptAction';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';
import { CallLog } from '../../../../../../feature/call';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import LooseObject from '../../model/type/LooseObject';
import { SubHeader } from '../../component/contact/SubHeader'
import { getPixelMapFromFile } from '../../util/UserPhoto'
import { getDialDirectlyAccountId } from '../../model/CallStateModel';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import dotCommon, { contactParams, itemParams } from '../../util/DotCommon';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import IndexPresenter from '../../presenter/IndexPresenter';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { FontScaleState } from '../../util/fontScaleState';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { ProfileUtils } from '../../util/ProfileUtils';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
// import { ListItem, SwipeEdgeEffect } from '@ohos.arkui.advanced.List';
import { display, LengthMetrics, TextModifier, ComponentContent, AtomicServiceWeb } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil'
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { preferences } from '@kit.ArkData';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationBadgeIconOptions,
//   HdsNavigationTitleMode } from '@kit.UIDesignKit'
// import { HdsListItem } from '@hms.hds.HdsStyle';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { contact } from '@kit.ContactsKit';
import SideBarButton from '../SideBarButton';
// import { HdsListItem, HdsNavigationTitleMode } from '@kit.UIDesignKit';

const TAG = 'FavoriteList';
const VIEW_CONTACT_DETAILS_EVENT = 'VIEW_CONTACT_DETAILS_EVENT';
const CALL_EVENT = 'CALL_EVENT';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';
const FAVORITE_CLICK_ADD_CONTACT_EVENT = 'FAVORITE_CLICK_ADD_CONTACT_EVENT';
const FAVORITE_PRESS_CONTACT_EVENT = 'FAVORITE_PRESS_CONTACT_EVENT';
const FAVORITE_CLICK_MORE_EVENT = 'FAVORITE_CLICK_MORE_EVENT';
const FAVORITE_MORE_CHOOSE_EVENT = 'FAVORITE_MORE_CHOOSE_EVENT';
const FAVORITE_NUMBER_GUIDE_EVENT = 'FAVORITE_NUMBER_GUIDE_EVENT';

// 标题栏
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}


interface ParamsInterface {
  editFavorite: Function,
}

@Entry
@Component
export default struct FavoriteList {
  @State mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @StorageLink('fullScreenPadding') @Watch('fullScreenPaddingOnChange') fullScreenPadding: Padding = {};//状态栏高度
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 是否编辑
  @State isEdit: boolean = false;
  // 初始为-1，空白页面，状态变化，从空白转为无收藏或从空白转为列表信息
  @State favoriteListListLen: number = -1;
  // font size scale
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;// 0-1
  @StorageLink('selectFavoriteContact') selectFavoriteContact: string = '';// 选中联系人
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('isVerdeModel') isVerdeModel: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;// 是否隐藏标题栏
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;// 是否显示智能窗口
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('showSideBar') showSideBar: boolean = true;
  listScroller: ListScroller = new ListScroller();// 列表滚动
  emitterId: number = 100;// 事件id
  customParams: CustomizedParams = {};//
  favoriteMoreChooseParams: CustomizedParams = {
    ITEM: 0
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Favorite aboutToAppear!');
    this.mFavoriteListPresenter.aboutToAppear();
    let innerEvent: emitter.InnerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      let oldLen = this.favoriteListListLen
      this.favoriteListListLen = data.data!['favoriteListListLen'];
      HiLog.w(TAG, 'favoriteListListLen refresh from ' + oldLen + ' to ' + this.favoriteListListLen)
      if (this.favoriteListListLen === 0) {
        this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 })
      }
    })
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Favorite aboutToDisappear!');
    if (this.isPC) {
      return;
    }
    emitter.off(this.emitterId);
    this.mFavoriteListPresenter.aboutToDisappear();
  }

  onPageShow() {
    HiLog.i(TAG, 'Favorite onPageShow');
    this.mFavoriteListPresenter.refreshFavorite();
  }

  onPageHide() {
    HiLog.i(TAG, 'Favorite onPageCover');
  }

  // 解决标题栏按钮位置跳动
  fullScreenPaddingOnChange() {
    if (this.fullScreenPadding.top as number < 0) {
      this.fullScreenPaddingTop = px2vp(AppStorage.get('fullScreenPaddingTop') as number);
    } else {
      this.fullScreenPaddingTop = px2vp(this.fullScreenPadding.top as number);
    }
    HiLog.w(TAG, `fullScreenPaddingOnChange! top: ${this.fullScreenPadding.top as number}`);
    HiLog.w(TAG, `fullScreenPaddingOnChange! bottom: ${this.fullScreenPadding.bottom as number}`);
  }

  /**
   * 获取标题栏模式
   * @param splitStatus 分屏状态
   * @returns
   */
  // private getNavigationTitleMode(splitStatus: SplitStatus): HdsNavigationTitleMode {
  //   //如果是悬浮窗走原来的逻辑
  //   if (this.isShowSmartWindow) {
  //     return this.favoriteListListLen <= 0 ? HdsNavigationTitleMode.FULL : HdsNavigationTitleMode.FREE;
  //   }
  //
  //   //如果是分屏则标题固定
  //   if (DisplaySplitUtil.isFixedTitleBar(splitStatus)) {
  //     return HdsNavigationTitleMode.MINI;
  //   }
  //   return this.favoriteListListLen <= 0 ? HdsNavigationTitleMode.FULL : HdsNavigationTitleMode.FREE;
  // };

  deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();
  /*更多菜单*/
  //更多菜单
  // menuMoreDisable: Array<HdsNavigationMenuOptions> = [
  //   {
  //     content: {
  //       componentId: 'addFavoriteButton',
  //       label: $r('app.string.accessibility_new_collect'),
  //       icon: $r('sys.symbol.plus'),
  //       isEnabled: true,
  //       action: () => {
  //         HiLog.w(TAG,
  //           `menuMoreDisable len:${this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length}`);
  //         this.selectFavoriteContact = '';
  //         // 联系人打点--点击添加收藏联系人
  //         DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_ADD_CONTACT_EVENT);
  //         if (this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList &&
  //         this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length) {
  //           contact.selectContacts({
  //             isMultiSelect: true,
  //             isDisplayedByName: true,
  //             filter: {
  //               filterClause: {
  //                 id: [
  //                   {
  //                     filterCondition: contact.FilterCondition.NOT_IN,
  //                     value: this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList
  //                   }
  //                 ],
  //               },
  //               filterType: contact.FilterType.SHOW_FILTER
  //             }
  //           }, (err: BusinessError, data) => {
  //             HiLog.w(TAG, `menuMoreDisable filter err=${err?.message},data=${data?.length}`);
  //             this.mFavoriteListPresenter.parseContactForResult(data);
  //           })
  //         } else {
  //           contact.selectContacts({
  //             isMultiSelect: true,
  //             isDisplayedByName: true,
  //           }, (err: BusinessError, data) => {
  //             HiLog.w(TAG, `menuMoreDisable no filter err=${err?.message},data=${data?.length}`);
  //             this.mFavoriteListPresenter.parseContactForResult(data);
  //           })
  //         }
  //       }
  //     }
  //   },
  //   {
  //     content: {
  //       label: $r('app.string.accessibility_more'),
  //       icon: $r('sys.symbol.dot_grid_2x2'),
  //       isEnabled: false,
  //     }
  //   }
  // ]
  //
  //
  // menuItems: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       componentId: 'addFavoriteButton',
  //       label: $r('app.string.accessibility_new_collect'),
  //       icon: $r('sys.symbol.plus'),
  //       isEnabled: true,
  //       action: () => {
  //         HiLog.w(TAG, `menuItems len:${this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length}`);
  //         this.selectFavoriteContact = '';
  //         // 联系人打点--点击添加收藏联系人
  //         DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_ADD_CONTACT_EVENT);
  //         if (this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList &&
  //         this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length) {
  //           contact.selectContacts({
  //             isMultiSelect: true,
  //             isDisplayedByName: true,
  //             filter: {
  //               filterClause: {
  //                 id: [
  //                   {
  //                     filterCondition: contact.FilterCondition.NOT_IN,
  //                     value: this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList
  //                   }
  //                 ],
  //               },
  //               filterType: contact.FilterType.SHOW_FILTER
  //             }
  //           }, (err: BusinessError, data) => {
  //             HiLog.w(TAG, `menuItems filter err=${err?.message},data=${data?.length}`);
  //             this.mFavoriteListPresenter.parseContactForResult(data);
  //           })
  //         } else {
  //           contact.selectContacts({
  //             isMultiSelect: true,
  //             isDisplayedByName: true,
  //           }, (err: BusinessError, data) => {
  //             HiLog.w(TAG, `menuItems no filter err=${err?.message},data=${data?.length}`);
  //             this.mFavoriteListPresenter.parseContactForResult(data);
  //           })
  //         }
  //       }
  //     }
  //   },
  //   {
  //     content: {
  //       label: $r('app.string.accessibility_more'),
  //       icon: $r('sys.symbol.dot_grid_2x2'),
  //       isEnabled: true,
  // 以下是被注释掉的旧代码，用于收藏页更多菜单功能的实现
  // 包含联系人打点、菜单构建和编辑收藏等功能
  //       componentId: 'HdsFavoriteMore',
  //       action: () => {
  //         // 联系人打点-收藏页点击更多
  //         DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_MORE_EVENT);
  //         let uiContext = this.getUIContext();
  //         let promptAction = uiContext.getPromptAction();
  //         let contentNode = new ComponentContent<ParamsInterface>(uiContext,
  //           wrapBuilder<[ParamsInterface]>(menuHdsBuilder),
  //           { editFavorite: () => {
  //             this.selectFavoriteContact = '';
  //             // 联系人打点--收藏页更多点击编辑
  //             DotUtil.getInstance().contactDot(this.favoriteMoreChooseParams, FAVORITE_MORE_CHOOSE_EVENT);
  //             this.mFavoriteListPresenter.editFavorite();
  //           },
  //           });
  //         try {
  //           promptAction.openMenu(
  //             contentNode,
  //             { id: 'HdsFavoriteMore' },
  //             { placement:Placement.BottomRight})
  //         } catch (error) {
  //           let err = error as BusinessError;
  //           HiLog.e(TAG, 'menuItems openMenu fail error message: ' + err.message + ', error code: ' + err.code);
  //         }
  //       }
  //     }
  //   }
  // ]


  /**
   * 标题栏按钮构建器
   * 用于创建页面顶部的导航按钮区域，包括侧边栏按钮、添加收藏按钮和更多菜单按钮
   */
  @Builder
  TitleGuide() {
    Row() {
      // 仅在PC设备且不显示侧边栏时渲染侧边栏按钮
      if (this.isPC && !this.showSideBar) {
        SideBarButton()
      }
      Row() {
        // 添加收藏联系人按钮
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_new_collect'))) // 设置无障碍文本
        .buttonStyle(ButtonStyleMode.TEXTUAL) // 设置按钮样式为文本型
        .stateEffect(true) // 启用状态效果
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle) // 根据设备类型设置按钮类型
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0) // 根据设备类型设置圆角
        .width(40)
        .id('favoriteList_page_menu')
        .height(40)
        .margin({ 
          end: LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .backgroundColor(this.isPC ? Color.Transparent : 
          this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') : 
            $r('sys.color.comp_background_tertiary')) // 根据设备和主题设置背景色
        .onClick(() => {
          if (this.isPC) {
            this.selectFavoriteContact = '';
            // 联系人打点--点击添加收藏联系人
            DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_ADD_CONTACT_EVENT);
            HiLog.i(TAG,
              `pc addFavorite ${this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList?.length}`);
            // pc如果已有联系人收藏,拉起picker需要传入参数
            if (this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList &&
            this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length) {
              contact.selectContacts({
                isMultiSelect: true,
                isDisplayedByName: true,
                filter: {
                  filterClause: {
                    id: [
                      {
                        filterCondition: contact.FilterCondition.NOT_IN,
                        value: this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList
                      }
                    ],
                  },
                  filterType: contact.FilterType.SHOW_FILTER
                }
              }, (err: BusinessError, data) => {
                HiLog.w(TAG, `pc menuMoreDisable filter err=${err?.message},data=${data?.length}`);
                this.mFavoriteListPresenter.parseContactForResult(data);
              })
            } else {
              contact.selectContacts({
                isMultiSelect: true,
                isDisplayedByName: true,
              }, (err: BusinessError, data) => {
                HiLog.w(TAG, `pc menuMoreDisable err=${err?.message},data=${data?.length}`);
                this.mFavoriteListPresenter.parseContactForResult(data);
              })
            }
          } else {
            HiLog.w(TAG,
              `menuItems len:${this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length}`);
            this.selectFavoriteContact = '';
            // 联系人打点--点击添加收藏联系人
            DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_ADD_CONTACT_EVENT);
            if (this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList &&
            this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList.length) {
              contact.selectContacts({
                isMultiSelect: true,
                isDisplayedByName: true,
                filter: {
                  filterClause: {
                    id: [
                      {
                        filterCondition: contact.FilterCondition.NOT_IN,
                        value: this.mFavoriteListPresenter.favoriteDataSource.favoriteContactIdList
                      }
                    ],
                  },
                  filterType: contact.FilterType.SHOW_FILTER
                }
              }, (err: BusinessError, data) => {
                HiLog.w(TAG, `menuItems filter err=${err?.message},data=${data?.length}`);
                this.mFavoriteListPresenter.parseContactForResult(data);
              })
            } else {
              contact.selectContacts({
                isMultiSelect: true,
                isDisplayedByName: true,
              }, (err: BusinessError, data) => {
                HiLog.w(TAG, `menuItems no filter err=${err?.message},data=${data?.length}`);
                this.mFavoriteListPresenter.parseContactForResult(data);
              })
            }
          }
        });

        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .id('favoriteList_more')
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_more')))
        .enabled(this.favoriteListListLen > 0)
        .bindMenu(this.MenuBuilder, {
          placement: Placement.BottomRight,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined
        }) // 绑定菜单构建器
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width(40)
        .height(40)
        .margin(0)
        .backgroundColor(this.isPC ? Color.Transparent : 
          this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') : 
            $r('sys.color.comp_background_tertiary')) // 根据设备和主题设置背景色
        .onClick(() => {
          // 联系人打点-收藏页点击更多
          HiLog.i(TAG, 'pc menuMore');
          DotUtil.getInstance().contactDot(this.customParams, FAVORITE_CLICK_MORE_EVENT);
        })
        .id('favoriteList_more_button')
      }
      .justifyContent(FlexAlign.End) // 水平对齐方式：右对齐
      .alignItems(VerticalAlign.Center) // 垂直对齐方式：居中
      .height($r('app.float.id_item_height_large'))
      .width('120vp')
      .padding({ 
        end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) : LengthMetrics.resource(this.spaceLR) // 根据设备类型设置右内边距
      })
    }
    .width('100%')
    .justifyContent(this.isPC && !this.showSideBar ? FlexAlign.SpaceBetween : FlexAlign.End) // 根据设备和侧边栏状态设置水平对齐方式
    .margin({ 
      left: this.isPC ? $r('sys.float.padding_level8') : 0, // 根据设备类型设置左外边距
    })
    .padding({ 
      start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level8')) : LengthMetrics.vp(0) // 根据设备类型设置左内边距
    })
  }

  /**
   * 页面主构建方法
   * 定义整个页面的布局结构，根据设备类型（PC/非PC）提供不同的布局实现
   */
  build() {
    // PC设备布局实现
    if (this.isPC) {
      Navigation() {
        this.favoriteBuilder() // 调用收藏联系人列表构建器
      }
      .hideTitleBar(false) // 始终显示标题栏
      .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
      $r('app.color.skin_background_primary')) // 根据主题设置背景色
      .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined) // 根据主题设置背景图片
      .mode(NavigationMode.Stack) // 设置导航模式为栈式
      .titleMode(NavigationTitleMode.Full) // 设置标题栏模式为迷你模式//修改为full
      // 标题配置
      .title($r('app.string.favorite'),
        { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined)
        }
      )
      // 绑定标题栏按钮构建器（添加收藏和更多菜单按钮）
      .menus(this.TitleGuide())
      .hideBackButton(true) // 隐藏返回按钮
      .padding({ top: this.fullScreenPaddingTop }) // 适配全屏内边距
      .width('100%')
      .height('100%')
    // 非PC设备布局实现
    } else {
      Navigation() {
        this.favoriteBuilder() // 调用收藏联系人列表构建器
      }
      // .bindToScrollable([this.listScroller]) // 绑定滚动控制器（已注释）
      .hideTitleBar(false) // 始终显示标题栏
      .backgroundColor(this.isThemeActive ? $r('app.color.background_last_white') :
      $r('app.color.skin_background_primary')) // 根据主题设置背景色
      .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined) // 根据主题设置背景图片
      .mode(NavigationMode.Stack) // 设置导航模式为栈式
      .titleMode(NavigationTitleMode.Full) // 标题栏模式配置
      .title($r('app.string.favorite'),
        { mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined) }
      )
      // 绑定标题栏按钮构建器（添加收藏和更多菜单按钮）
      .menus(this.TitleGuide())
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP]) // 忽略系统安全区域
      .hideBackButton(true) // 隐藏返回按钮
      .padding({ top: this.fullScreenPaddingTop }) // 适配全屏内边距
      .width('100%')
      .height('100%')
    }
  }

  // 收藏列表
  @Builder
  favoriteBuilder() {
    if ((this.favoriteListListLen <= 0) || this.maintenanceMode) {
      FavoriteEmptyPage();// 收藏列表为空
    } else {
      FavoriteContent({ presenter: this.mFavoriteListPresenter, listScroller: this.listScroller })
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.favorite')) },
  //   };
  // }

  @Builder// 菜单
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.edit') })
        .contentFont({
          size: this.isPC ? $r('sys.float.Body_L') : $r('sys.float.ohos_id_text_size_body1'),
          weight: FontWeight.Medium
        })
        .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
        .contentFontColor(this.isPC ? $r('sys.color.font_primary') :
        $r('app.color.skin_ohos_id_color_text_primary'))
        .id('favoriteList_favorite_set_menuItem')
        .onClick(() => {
          this.selectFavoriteContact = '';
          // 联系人打点--收藏页更多点击编辑
          DotUtil.getInstance().contactDot(this.favoriteMoreChooseParams, FAVORITE_MORE_CHOOSE_EVENT);
          this.mFavoriteListPresenter.editFavorite();
          ContextMenu.close();
        })
    }
    .width(224)
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
    .radius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
  }

  onForegroundChange(changedPropertyName: string) {
  }
}

const MAX_HEAD_ANGLE: number = 17;
const BODY_HEAD_CRITICAL_ANGLE: number = 12;
const MAX_BODY_ANGLE: number = 10;
const DELETE_SWIPE_HEAD_WIDTH: number = 64;//删除滑动
const DELETE_SWIPE_BODY_WIDTH: number = 120;//删除滑动
const ANGLE_RADIO: number = 12;
const ACTION_AREA_DISTANCE: number = 56;//滑动区域
const MAX_SCALE_RATIO: number = 1.1;//最大缩放比例


// 收藏列表
@Component
struct FavoriteContent {
  @Link presenter: FavoriteListPresenter; //接受presenter（双向）
  @State mPresenter: FavoriteListPresenter = this.presenter;//收藏列表presenter
  isUsuallyShow: boolean = false;
  swipeActionCount: number = 0;// 滑动次数
  @State headAngle: number = 0;
  @State bodyAngle: number = 0;
  @State swipeScale: number = 1;
  @State endOffset: number = 0;// 滑动距离
  // 设备型号
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;//无障碍
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false; //首页标题栏
  @StorageProp('isVerde') isVerde: boolean = false;
  private dustbinAnimationEnabled: boolean = true;//垃圾箱动画
  listScroller: ListScroller = new ListScroller();//列表滚动
  private isPC: boolean = EnvironmentProp.isPC();
  //---------------------------
  @State enterEndDeleteAreaString: string = "not enterEndDeleteArea"
  @State exitEndDeleteAreaString: string = "not exitEndDeleteArea"

  @Styles
  buttonStyle()
  {
    .borderRadius(20)
    .height($r('app.float.id_item_height_sm'))
    .width($r('app.float.id_item_height_sm'))
    .margin($r('app.float.id_card_margin_xl'))
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'favoriteList aboutToDisappear!');
  }

//删除方法
  deleteAction(item: FavoriteListBean, index: number | undefined) {
    this.dustbinAnimationEnabled = false;//垃圾箱动画
    if (index === undefined) {//删除
      HiLog.i(TAG, 'deleteAction index is undefined')
      return;
    }
    let totalCount = this.presenter.favoriteDataSource.totalCount();//总数
    if (totalCount === 1) {
      // 只有一个联系人时，添加按钮
      AccessibilityUtil.getInstance().sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'addFavoriteButton');
    } else {
    // 多个联系人时，删除按钮
      AccessibilityUtil.getInstance()
        .sendAccessibilityNotInterruptEvent(this.isOpenAccessibility, 'favorite' + (index + 1), 0);
    }

    animateTo({
      duration: 400,
      curve: Curve.Friction,
      onFinish: () => {
        this.dustbinAnimationEnabled = true;
      }
    }, () => {
      if (index !== undefined) {
        this.presenter.updateFavorite(0, Number(item.favorite.contactId), item);//
      }
    })
  }
  @Builder itemEnd(item: FavoriteListBean, index: number | undefined) {
    Row() {
      Button($r('app.string.accessibility_delete'))
        .margin("4vp")
        .onClick(()=>{
          this.deleteAction(item, index);
        })
    }
  }

  /**
   * FavoriteContent组件的构建方法
   * 使用响应式布局实现不同屏幕尺寸的适配
   */
  build() {
    // 使用GridRow实现响应式布局，根据屏幕尺寸设置不同的列数
    GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
      // GridCol设置为占据所有列宽，确保在不同屏幕尺寸下都能自适应
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        // 列表组件，用于展示收藏联系人列表
        // space: 列表项间距为0
        // initialIndex: 初始显示第0项
        // scroller: 列表滚动控制器
        List({ space: 0, initialIndex: 0, scroller: this.listScroller }) {
          // 使用LazyForEach实现列表的懒加载，提高性能
          // favoriteDataSource: 收藏联系人数据源
          // item: 当前循环的收藏联系人数据
          // index: 当前项的索引
          LazyForEach(this.presenter.favoriteDataSource, (item: FavoriteListBean, index?: number | undefined) => {
            // 列表项组件，定义单个联系人的展示和交互
            ListItem(
              // customItemBuilder: this.favoriteListBuilder(item, index),
              //
              // swipeActionOptions: {//删除按钮
              //   deleteIconOptions: {//删除图标
              //     onAction: () => {//删除按钮点击事件
              //       this.deleteAction(item, index);//通过下标删除
              //     },
              //     iconOptions: {//删除图标属性
              //       accessibilityText: ResourceUtil.getStringByResource($r('app.string.accessibility_delete')) +
              //         ' ' + ResourceUtil.getStringByResource($r('app.string.accessibility_button'))//删除图标的辅助文本
              //     }
              //   },
              // 列表项的滑动删除
              //   fullDeleteOptions: {
              //     isFullDelete: true,//开启滑动超阈值自动删除
              //
              //     onFullDeleteAction: () => {
              //       animateTo({//删除动画
              //         duration: 350,
              //       }, () => {
              //         this.deleteAction(item, index); //通过下标删除
              //       })
              //     }
              //   }
              // }
            ) {
                // 调用列表项构建器，渲染联系人信息
                this.favoriteListBuilder(item, index)


            }
            // 配置列表项的滑动操作
            .swipeAction({
              // 配置列表项右侧滑动操作
              end:{
                // 滑动操作按钮构建器
                builder:()=>{
                  // 调用itemEnd方法构建删除和设置按钮
                  this.itemEnd(item, index)
                },
                // 滑动操作触发时的回调函数
                onAction:()=>{
                  // 使用animateTo实现动画效果
                  animateTo({
                    duration: 400, // 动画持续时间400ms
                  }, () => {
                    this.deleteAction(item, index);
                  })
                },

              }
            })

          }, (item: FavoriteListBean) => JSON.stringify(item))
        }

        // 配置列表的内容裁剪模式为安全区域
        .clipContent(ContentClipMode.SAFE_AREA)
        // 启用编辑模式
        .editMode(true)
        // 设置列表宽高为100%
        .width('100%')
        .height('100%')
        // 设置列表方向为垂直
        .listDirection(Axis.Vertical)
        // 设置边缘效果为弹性效果，并始终启用
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        // 列表滚动事件回调
        .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
          // 当列表向下滚动时隐藏标题栏，向上滚动时显示标题栏
          if (scrollState === ScrollState.Scroll) {
            if (scrollOffset > 0 && !this.hideIndexTitleTabBar) {
              this.hideIndexTitleTabBar = true;
            } else if (scrollOffset < 0 && this.hideIndexTitleTabBar) {
              this.hideIndexTitleTabBar = false;
            }
          }
        })
        // 设置安全区域底部内边距为48vp
        .safeAreaPadding({ bottom: 48 })
      }
    }
    .flexShrink(1)
    // 设置左右内边距，根据设备类型和屏幕尺寸自适应
    .padding({
      left: this.isPC ? $r('sys.float.padding_level8') :
        this.curBp === 'lg' ? $r('sys.float.padding_level6') : 0,
      right: this.isPC ? $r('sys.float.padding_level8') :
        this.curBp === 'lg' ? $r('sys.float.padding_level12') : 0
    })
    // 可见区域变化事件回调
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      // 当组件完全可见时，增加滑动操作计数
      if (isVisible && currentRatio === 1) {
        this.swipeActionCount++;
      } 
      // 当组件完全不可见时，减少滑动操作计数
      else if (!isVisible && currentRatio === 0) {
        this.swipeActionCount--;
        // 当没有可见的滑动操作时，关闭所有滑动操作
        if (this.swipeActionCount <= 0) {
          this.swipeActionCount = 0;
          this.listScroller?.closeAllSwipeActions();
        }
      }
    })
    .height('100%')
    .width('100%')
  }

  /**
   * 收藏联系人列表项构建器
   * @param item 当前收藏联系人数据
   * @param index 当前项的索引
   */
  @Builder
  favoriteListBuilder(item: FavoriteListBean, index?: number | undefined) {

      // 列表项在顶层，可以滑动
      FavoriteListItem({ 
        presenter: $mPresenter, // 双向绑定的收藏列表presenter
        item: item, // 当前收藏联系人数据
        index: index // 当前项的索引
      })//列表项
        // 设置列表项的约束尺寸，根据设备类型设置不同的最小和最大高度
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max'),
          maxHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
        })
        // 设置zIndex确保列表项按照索引顺序显示
        .zIndex(index!)
  }

}


/**
 * 收藏联系人列表项组件
 * 负责展示单个收藏联系人的详细信息和快捷操作
 */
@Component
export struct FavoriteListItem {
  // 导航路径信息，用于页面跳转
  @Consume('pathInfos') pathInfos: NavPathStack;
  // 收藏列表presenter，用于处理收藏相关业务逻辑
  @Link presenter: FavoriteListPresenter;
  // 索引presenter，用于处理索引相关业务逻辑
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  // 设备断点，用于响应式布局
  @StorageLink('breakpoint') curBp: string = 'sm';
  // default slotId
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  // 是否共享
  @State canBeShared: boolean = false;
  @State isMenuShown: boolean = false;
  @State selectSimBuilder: SelectDialogBuilder = {
    title: '',
    multiSimCardItems: [{
      name: '',
      img: $r('sys.symbol.phone_badge_1'),
    }, {
      name: '',
      img: $r('sys.symbol.phone_badge_2'),
    }],
  };
  @Prop item: FavoriteListBean;
  @Prop index: number;
  @StorageProp('contactsWithModifiedPhoto') @Watch('change') changedId: string = '';
  @StorageProp('contactListUpdated') @Watch('updatePixelMap') contactListUpdated: number = 0;
  @State builder: SelectNumDialogBuilder = {
    title: $r('app.string.contacts_call'),
    multiNumCardItems: [],
    contactId: ''
  };
  customParams: CustomizedParams = {};
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };
  @State favoriteGuideParams: CustomizedParams = {
    ISCLICK: 0,
    ISDEFAULT: 0,
    ISCANCEL: 0
  };
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('isSaveContact') isSaveCon: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;//默认主题
  emitterId: number = 110;

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
            //联系人打点--收藏页面多号码联系人引导窗口--是否取消
            this.favoriteGuideParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.favoriteGuideParams, FAVORITE_NUMBER_GUIDE_EVENT);
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
  mSelectSimIdDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      contentAreaPadding: {
        right: $r('sys.float.padding_level6'),
        left: $r('sys.float.padding_level6'),
      },
      primaryTitle: this.selectSimBuilder.title,
      contentBuilder: () => {
        this.SelectSimIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.callDialogParams.ITEM = -1;
            this.callDialogParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.mSelectSimIdDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    cancel: () => {
      this.callDialogParams.ITEM = -1;
      this.callDialogParams.ISCANCEL = 1;
      DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
    },
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    alignment: DialogAlignment.Center,
    cornerRadius: {
      topLeft: $r('app.float.rounded_corners_width_32'),
      topRight: $r('app.float.rounded_corners_width_32'),
      bottomLeft: $r('app.float.rounded_corners_width_32'),
      bottomRight: $r('app.float.rounded_corners_width_32')
    }
  })
  @State isEmergencyNum: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('selectFavoriteContact') selectFavoriteContact: string = '';
  @State itemHeight: number = 28;
  @State isPressed: boolean = false;
  @State isDetailBtnPressed: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  private defaultHeight: number = this.isPC ? 20 : 28;
  private pre: preferences.Preferences = preferences.getPreferencesSync(getContext(this), { name: 'font_test' });
  private timeId: number = -1;
  viewContactDetailParams: CustomizedParams = {
    LEVELONE: 2,
    LEVELTWO: 2,
    ISSAVE: 1,
    MARKTYPE: 0,
    MARKSOURCE: ''
  };
  callParams: CustomizedParams = {
    ENC: 5,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };

  aboutToAppear() {
    if (this.item.favorite?.contactId) {

      getPixelMapFromFile(this.item.favorite.contactId, (res: PixelMap | null) => {
        this.photoPixelMap = res
      })
    }
    this.itemHeight = this.pre.getSync('h_num', this.defaultHeight) as number;
  }

  change() {
    const id = this.changedId.split('-')[0]
    if (this.item.favorite?.contactId === id) {
      getPixelMapFromFile(this.item.favorite?.contactId, (res: PixelMap | null) => {
        this.photoPixelMap = res;
      })
    }
  }

  updatePixelMap() {
    getPixelMapFromFile(this.item.favorite?.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }
  phonenumberFormat(value: string) {
    if (value) {
      const matches = new RegExp('^(\\d{3})(\\d{4})(\\d{4})$').exec(value);
      if (matches) {
        return matches[1] + '\xa0' + matches[2] + '\xa0' + matches[3];
      }
    }
    return value;
  }

  build() {
    if (this.item) {
      RelativeContainer() {
        if (1 === this.item.favorite.isCommonUseType) {
          SubHeader({ titleContent: $r('app.string.common_use'), subTitleContent: '' })
            .margin({
              start: LengthMetrics.resource($r('sys.float.padding_level6')),
            })
            .visibility(this.item.favorite.isUsuallyShow == true ? Visibility.Visible : Visibility.None)
            .alignRules({
              start: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .id('SubHeader')
        }
        RelativeContainer() {
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
              .alignRules({
                start: { anchor: '__container__', align: HorizontalAlign.Start }
              })
              .id('photoPixelMap')
              .offset({
                start: this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(16),
                top: LengthMetrics.vp((this.itemHeight - 4) / 2)
              })
          } else if (StringUtil.isEmpty(this.item.favorite.headChar)) {
            Image(
              StringUtil.isEmpty(this.item.favorite.portraitPath) ?
                $r('app.media.ic_user_portrait') : this.item.favorite.portraitPath
            )
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_image_mid'))
              .draggable(false)
              .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
              .backgroundColor(
                StringUtil.isEmpty(this.item.favorite.portraitPath) ?
                  $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
              )
              .alignRules({
                start: { anchor: '__container__', align: HorizontalAlign.Start }
              })
              .id('portraitPath')
              .offset({
                start: this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(16),
                top: LengthMetrics.vp((this.itemHeight - 4) / 2)
              })
          } else {
            Text(this.item.favorite.headChar)
              .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '16vp')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
              .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
              .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
              .width($r('app.float.id_card_image_mid'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.id_card_image_mid'))
              .accessibilityLevel('no')
              .offset({
                start: this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(16),
                top: LengthMetrics.vp((this.itemHeight - 4) / 2)
              })
              .alignRules({
                left: { anchor: '__container__', align: HorizontalAlign.Start }
              })
              .id('headChar')
          }
          if (0 === this.item.favorite.isCommonUseType) {
            Text(this.item.favorite.displayName)
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 10)
              .fontSize($r('sys.float.Body_L'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('app.color.skin_font_primary'))
              .textAlign(TextAlign.Start)
              .fontWeight(FontWeight.Medium)
              .width(this.isPC ? 'calc(100% - 56vp)' :
                FontScaleState.isStandardGeer(this.fontSizeScale) ? (this.curBp === 'sm' || this.isShowSmartWindow) ?
                  `calc(100% - 112vp)` : '75%' : `calc(100% - 112vp)`)
              .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
              .constraintSize({ minHeight: this.defaultHeight })
              .alignRules({
                start: { anchor: '__container__', align: HorizontalAlign.Start },
              })
              .offset({
                start: this.isPC ? LengthMetrics.vp(56) : LengthMetrics.vp(72),
                top: LengthMetrics.vp(17.5)
              })
              .onSizeChange((oldSize: SizeOptions, newSize: SizeOptions) => {
                if (this.timeId != -1) {
                  clearTimeout(this.timeId)
                  this.timeId = -1
                }
                this.timeId = setTimeout(() => {
                  this.itemHeight =
                    (newSize.height as number) < this.defaultHeight ? this.defaultHeight : newSize.height as number;
                  this.pre?.putSync('h_num', this.itemHeight);
                }, 0)
              })
          } else {
            Column() {
              Text(this.item.favorite.displayName)
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 10)
                .fontSize($r('sys.float.Body_L'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor($r('app.color.skin_font_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
                .margin({ bottom: 2 })
                .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)

              Text($r('app.string.phone_type_mobile_expansion', this.phonenumberFormat(this.item.favorite.phoneNum)))
                .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
                .fontSize($r('sys.float.Subtitle_S'))
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
            }
            .width(FontScaleState.isStandardGeer(this.fontSizeScale) ? (this.curBp === 'sm' || this.isShowSmartWindow) ?
              `calc(100% - 112vp)` : '75%' : `calc(100% - 92vp)`)
            .margin({
              end: LengthMetrics.resource($r('sys.float.padding_level4')),
              top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                0, $r('app.float.dialer_button_text_font_size')),
              bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                0, $r('app.float.dialer_button_text_font_size'))
            })
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          }
        }
        .id('favorite' + this.index)
        .accessibilityText(this.item.favorite.displayName.toString())
        .width(`calc(100% -  48vp)`)
        .height(this.itemHeight + 36)
        .padding({
          end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level4')) :
            LengthMetrics.resource($r('sys.float.padding_level0'))
        })
        .borderRadius(this.isPC ? $r('sys.float.padding_level4') : 0)
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
        .onClick(() => {
          if (!this.isPC && (this.curBp === 'sm' || this.isShowSmartWindow)) {
            ContactAbilityModel.getContactById(Number(this.item.favorite.contactId), (result: LooseObject) => {
              if (result.data !== undefined && Object.getOwnPropertyNames(result.data).includes('phones') &&
                result.data.phones.length !== 0) {
                if (result.data.phones.length > 1) {
                  this.builder.multiNumCardItems = [];
                  this.builder.contactId = result.data.contactID;
                  let hasDefault = false;
                  result.data.phones.forEach((element: LooseObject) => {
                    let formatNum = PhoneNumber.fromString(element.num).getNumber().replace(new RegExp('\\s+', 'g'), '')
                    if (element.primary == true) {
                      this.dealCallNumber(formatNum);
                      hasDefault = true;
                      return;
                    }
                    const phoneNumber: PhoneNumber = new PhoneNumber(element.num);
                    const item: MultiNumCardItems = new MultiNumCardItems();
                    item.number = phoneNumber.phoneNumFormat();
                    item.img = $r('sys.symbol.phone');
                    item.numType = Phone.getTypeLabelResource(Number.parseInt(element.numType, 10));
                    item.dataId = element.dataId;
                    this.builder.multiNumCardItems.push(item);
                  });
                  this.builder.callback = (item) => {
                    this.dealCallNumber(item.number);
                  }
                  if (!hasDefault) {
                    this.mSelectSlotIdDialog?.open();
                    DialogControllerManager.getInstance().addDialogController(this.mSelectSlotIdDialog);
                  }
                } else if (result.data.phones.length > 0) {
                  this.dealCallNumber(result.data.phones[0].num);
                }
              } else {
                prompt.showToast({ message: $r('app.string.no_number_available') })
                HiLog.e(TAG, ' popupSelectNumber phones null');
              }
            }, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext())
          } else {
            this.presenter.goContactDetail(this.item.favorite.contactId);
          }
        })
        .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
          preview: this.MenuPreview(),
          previewAnimationOptions: {
            scale: [1.0, 1.0], transition: TransitionEffect.OPACITY.animation({
              duration: 200, curve: Curve.Ease,
            })
              .combine(TransitionEffect.scale({
                x: 1.08, y: 1.08
              }))
              .combine(TransitionEffect.translate({
                x: -12, y: 0
              }))
              .combine(TransitionEffect.opacity(10)),
          },
          transition: TransitionEffect.OPACITY.animation({
            duration: 200, curve: Curve.Ease
          }).combine(TransitionEffect.scale({ x: 1.0, y: 1.0 })),
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
          placement: Placement.BottomLeft,
          offset: {
            x: 0,
            y: $r('sys.float.padding_level4')
          },
          onDisappear: () => {
            this.isMenuShown = false;
          }
        })
        .translate({ y: this.item.offsetY })
        .gesture(GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
            .onAction((event: GestureEvent) => {
              VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
              this.isMenuShown = true;
            })
        ))
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            case TouchType.Down:
              this.isPressed = !this.isDetailBtnPressed; // 点击详情按钮时Item背景色不变
              break;
            case TouchType.Up:
            case TouchType.Cancel:
              this.isPressed = false;
              break;
          }
        })
        .onHover((isHover: boolean) => {
          if (isHover) {
            this.isPressed = true;
          } else {
            this.isPressed = false;
          }
        })
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
        .onMouse((event: MouseEvent) => {
          if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
            VibrationUtils.onceVibration(VibrationEffect.Heavy);
          }
        })

        Button() {
          SymbolGlyph($r('sys.symbol.info_circle'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .margin({
          start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
        })
        .width(48)
        .height(48)
        .alignRules({
          end: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isDetailBtnPressed = true;
          } else if (event.type === TouchType.Up) {
            this.isDetailBtnPressed = false;
          }
        })
        .offset({ end: LengthMetrics.vp(4), top: LengthMetrics.vp((this.itemHeight - 12) / 2) })
        .id('SymbolGlyph')
        .borderRadius($r('sys.float.corner_radius_level4'))
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_detail')))
        .visibility((this.curBp === 'sm' || this.isShowSmartWindow) && !this.isPC ? Visibility.Visible :
          Visibility.None)
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .stateEffect(true)
        .onClick(() => {
          // 联系人打点-收藏页点击icon查看联系人详情(收藏/常用)
          if (1 === this.item.favorite.isCommonUseType) {
            this.viewContactDetailParams.LEVELTWO = 3;
          } else {
            this.viewContactDetailParams.LEVELTWO = 2;
          }
          DotUtil.getInstance().contactDot(this.viewContactDetailParams, VIEW_CONTACT_DETAILS_EVENT);
          this.presenter.goContactDetail(this.item.favorite.contactId);
        })

        if (this.item.showDivider) {
          Divider()
            .strokeWidth('1px')
            .color($r('app.color.skin_ohos_id_color_list_separator'))
            .alignRules({
              start: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .margin({
              start: this.isPC ? LengthMetrics.vp(48) : LengthMetrics.vp(72),
              end: this.isPC ? LengthMetrics.vp(0) :
                this.curBp === 'lg' ? LengthMetrics.vp(72) : LengthMetrics.resource($r('sys.float.padding_level8')),
              top: LengthMetrics.vp(this.itemHeight + 35.5)
            })
        }
      }
      .backgroundColor(this.isPressed ? $r('app.color.skin_interactive_click') :
        (this.selectFavoriteContact === this.item.favorite.contactId && this.curBp != 'sm') ?
          'rgba(10,88,246,0.1)' : Color.Transparent)
      .accessibilityLevel('no')
      .width('100%')
      .height(this.itemHeight + 36)
    }
  }

  @Builder
  MenuPreview() {
    Scroll() {
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
              })
          } else if (StringUtil.isEmpty(this.item.favorite.headChar)) {
            Image(
              StringUtil.isEmpty(this.item.favorite.portraitPath) ?
              $r('app.media.ic_user_portrait') : this.item.favorite.portraitPath
            )
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_image_mid'))
              .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
              .backgroundColor(
                StringUtil.isEmpty(this.item.favorite.portraitPath) ?
                $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
              )
              .draggable(false)
          } else {
            Text(this.item.favorite.headChar)
              .fontSize('16vp')
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
              .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
              .height($r('app.float.id_card_image_mid'))
              .width($r('app.float.id_card_image_mid'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.id_card_image_mid'))
          }
        }
        .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
        .width($r('app.float.id_card_image_mid'))
        .layoutWeight(0)

        List() {
          ListItem() {
            Column() {
              if (this.item.favorite.displayName) {
                Text(this.item.favorite.displayName)
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.color.skin_font_primary'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .width('100%')
                  .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
              }
              if (!StringUtil.isEmpty(this.item.favorite.subTitle)) {
                Text(this.item.favorite.subTitle)
                  .width('100%')
                  .fontColor($r('app.color.skin_font_tertiary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
              }
            }
            .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
            .justifyContent(FlexAlign.Center)
          }
        }
        .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
        .width($r('app.float.listItem_width_xl'))
        .margin({
          start: LengthMetrics.resource($r('sys.float.padding_level8')),
        })
        .scrollBarWidth(0)
        .layoutWeight(1)
      }
      .accessibilityLevel('no-hide-descendants')
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid'),
    })
    .align(Alignment.Start)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width(DisplaySplitUtil.isHorizonSplit() ? 'auto' : '100%')
    .height($r('app.float.id_item_height_max'))
  }

  @Builder
  MenuBuilder() {
    Menu() {
      if (!this.isVerde) {
        // v小折叠外屏 不支持 编辑收藏联系人页面
        MenuItem({ content: $r('app.string.multiple_choices') })
          .padding({
            left: $r('app.float.id_card_margin_xxl')
          })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .id('ContactListView_Contacts_delete_MenuItem')
          .onClick(() => {
            // 联系人打点-长按收藏联系人-多选管理收藏联系人
            itemParams.ITEM = dotCommon.eventParam.ITEM_CONTACT_MULTISELECT;
            DotUtil.getInstance().contactDot(itemParams, dotCommon.eventName.FAVORITE_PRESS_CHOOSE_EVENT);
            this.presenter.isEditSelectList = [this.item.favorite];
            this.presenter.longItemEditFavorite(this.presenter.favoriteList, this.presenter.isEditSelectList,
              this.item.favorite);
          })
        this.MenuDivider()
      }
      MenuItem({ content: $r('app.string.cancel_favorite') })
        .padding({
          left: $r('app.float.id_card_margin_xxl')
        })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactListView_Contacts_delete_MenuItem')
        .onClick(() => {
          // 联系人打点-长按收藏联系人-取消收藏
          itemParams.ITEM = dotCommon.eventParam.ITEM_UNFAVORITE;
          DotUtil.getInstance().contactDot(itemParams, dotCommon.eventName.FAVORITE_PRESS_CHOOSE_EVENT);
          this.presenter.updateFavorite(0, Number(this.item.favorite.contactId), this.item);
        })
    }
    .radius($r('sys.float.corner_radius_level10'))
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
  }

  sendAccountSubscription() {
    let event: emitter.InnerEvent = {
      eventId: this.emitterId
    }
    let eventData: emitter.EventData = {
      data: {
        'isAccountants': true
      }
    }
    emitter.emit(event, eventData);
    this.isSaveCon = -1;
  }

  dealCallNumber(phoneNum: string) {
    if (this.haveMultiSimCard) {
      // 双卡下设置默认卡号直接拨打电话
      if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
        HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: this.defaultSlot });
        return;
      }
      const directAccountId = getDialDirectlyAccountId(this.presenter.dsdsMode)
      if (directAccountId !== undefined) {
        // 3.0 case!
        HiLog.w(TAG, 'Call directly through sim ' + directAccountId);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: directAccountId });
        return;
      }
      this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
      this.selectSimBuilder.callback = (value) => {
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: value });
        // 联系人打点-收藏页面处点击呼叫
        if (1 === this.item.favorite.isCommonUseType) {
          this.callParams.ENC = 6;
        } else {
          this.callParams.ENC = 5;
        }
        this.callParams.SLOT = value;
        this.callParams.ISMULTISIMCARD = 1;
        DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
      }
      this.selectSimBuilder.gotoDialer = () => {
        DialerPresenter.getInstance().editPhoneNumber(phoneNum);
        AppStorage.SetOrCreate<boolean>('showDialBtn', true);
        AppStorage.SetOrCreate('mainTabsIndex', this.mIndexPresenter.callIndex);
        this.pathInfos.pop();
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {

        actionData: {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          numbers: [phoneNum],
          limit: 1,
          page: 1
        }
      }, (resultList: CallLog[]) => {
        if (!ArrayUtil.isEmpty(resultList)) {
          this.selectSimBuilder.lastSimId = resultList[0].simId;
        } else {
          this.selectSimBuilder.lastSimId = -1;
        }
        let spnList = AppStorage.Get<Array<string | Resource>>('spnList');
        if (spnList != undefined && this.selectSimBuilder.multiSimCardItems != undefined) {
          for (let index = 0; index < spnList.length; index++) {
            this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
          }
        }
        this.mSelectSimIdDialog?.open();
        DialogControllerManager.getInstance().addDialogController(this.mSelectSimIdDialog);
      });
    } else {
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum);
      this.clickCallDot();
    }
  }

  // 联系人打点
  clickCallDot() {
    // 联系人打点-收藏页面处点击呼叫
    if (1 === this.item.favorite.isCommonUseType) {
      this.callParams.ENC = 6;
    } else {
      this.callParams.ENC = 5;
    }
    this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
    this.callParams.ISMULTISIMCARD = 0;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  aboutToDisappear() {
    this.mSelectSlotIdDialog = null;
    this.mSelectSimIdDialog = null;
  }

  @Builder
  SelectSlotIdDialogBuilder() {
    Column() {
      SelectMultiNumDialog({
        builder: this.builder,
        controller: this.mSelectSlotIdDialog as CustomDialogController,
        favoriteGuideParams: this.favoriteGuideParams
      })
    }
    .width('100%')
  }

  @Builder
  SelectSimIdDialogBuilder() {
    Column() {
      SelectSimIdDialog({
        builder: this.selectSimBuilder,
        controller: this.mSelectSimIdDialog as CustomDialogController
      })
    }
    .width('100%')
  }
}

// 收藏页面
@Component
export struct FavoriteEmptyPage {
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;

  aboutToAppear(): void {
    this.hideIndexTitleTabBar = false;
  }

  build() {
    Column() {
      Column() {
        // 星形图标
        Image($r('app.media.ic_empty_page_no_favorites'))
          .width(80)
          .height(80)
          .opacity(0.5)
        
        // "没有收藏"文字
        Text($r('app.string.no_favorite'))
          .fontSize(16)
          .fontColor(this.isThemeActive ? $r('app.color.skin_font_tertiary') : $r('app.color.skin_font_secondary'))
          .margin({ top: 16 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .padding({ bottom: this.curBp === 'lg' ? px2vp(this.fullScreenPadding.bottom as number) : 0 })
    .width('100%')
    .height('100%')
    .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'))
  }
}

// 菜单
@Builder
function menuHdsBuilder(params: ParamsInterface) {
  Menu() {
    MenuItem({ content: $r('app.string.edit') })
      .contentFont({
        size: EnvironmentProp.isPC() ? $r('sys.float.Body_L') : $r('sys.float.ohos_id_text_size_body1'),
        weight: FontWeight.Medium
      })
      .height(EnvironmentProp.isPC() ? $r('app.float.id_card_image_mid') : undefined)
      .contentFontColor(EnvironmentProp.isPC() ? $r('sys.color.font_primary') :
      $r('app.color.skin_ohos_id_color_text_primary'))
      .id('favoriteList_favorite_set_menuItem')
      .onClick(() => {
        params.editFavorite();
      })
  }
  .width('224vp')
  .backgroundBlurStyle(EnvironmentProp.isPC() ? BlurStyle.COMPONENT_REGULAR : undefined)
  .shadow({
    radius: EnvironmentProp.isPC() ? $r('sys.float.ohos_id_default_shadow_s') : 0
  })
  .radius(EnvironmentProp.isPC() ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
}




