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

/**
 * 编辑收藏联系人列表页面
 * 功能：管理收藏联系人的编辑操作，包括修改排序、删除联系人、多选操作等
 */

// 导入必要的模块和组件
import EditFavoriteListPresenter from '../../presenter/favorite/EditFavoriteListPresenter';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { FavoriteBean } from '../../model/bean/FavoriteBean';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';
import MorandiColor from '../../model/bean/MorandiColor';
import { SearchContactResult } from '../../model/bean/SearchContactResult';
import { CustomizedParams, EditFavoriteParam } from '../../model/type';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import FavoriteListPresenter from '../../presenter/favorite/FavoriteListPresenter';
import DotUtil from '../../util/DotUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import { Params } from '../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { SymbolGlyphModifier, ToolBar, ToolBarOptions, ItemState, LengthMetrics,
  CustomContentDialog } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { FontScaleState } from '../../util/fontScaleState';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { TextModifier } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import deviceInfo from '@ohos.deviceInfo';
import { DisplaySplitUtil } from '../../util/DisplaySplitUtil';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ToolBarModifier } from '@ohos.arkui.advanced.ToolBar';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { emitter } from '@kit.BasicServicesKit';
import LooseObject from '../../model/type/LooseObject';
import accessibility from '@ohos.accessibility'
import { SlidingMultipleSelectionsUtil } from '../../util/SlidingMultipleSelectionsUtil';
import ProgressBarContent from '../dialog/ProgressBarContent';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit'
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { GlobalContext } from '../../util/GlobalContext';

// 常量定义
const TAG = 'EditFavoriteList';
// 收藏联系人拖拽事件
const FAVORITE_DRAG_CONTACT_EVENT = 'FAVORITE_DRAG_CONTACT_EVENT';
// 收藏联系人删除事件
const FAVORITE_REMOVE_CONTACT_EVENT = 'FAVORITE_REMOVE_CONTACT_EVENT';

/**
 * 主标题文本修饰符类（PC设备使用）
 * 功能：修改标题文本的样式
 */
class MainTitleTextModifier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

// 编辑收藏列表
@Builder
export function EditFavoriteListLoader($$: Params): void {
  EditFavoriteList();
}

/**
 * 编辑收藏列表主页面组件
 * 功能：编辑收藏联系人列表的主页面，管理整体布局和状态
 */
@Component
export default struct EditFavoriteList {
  // 路径信息
  @Consume('pathInfos') pathInfos: NavPathStack;
  // 编辑收藏列表数据管理器，负责处理业务逻辑和数据
  @State mFavoriteListPresenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
  // 收藏列表数据管理器
  @State mListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  // 全屏边距
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 收藏列表数据
  @State favoriteList: FavoriteBean[] = [];
  // 选中数量
  @State selectNumber: number = 0;
  // 纵轴偏移量，用于列表滚动
  @State offsetY: number = -1;
  // 当前断点，用于响应式布局
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 收藏拖拽操作参数，用于打点统计
  @State favoriteDragParams: CustomizedParams = {
    ISDRAG: 0,
    ISSAVE: 0
  };
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否显示确认按钮
  @StorageProp('isDragShow') isDragShow: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModifier = new MainTitleTextModifier();
  // 是否开启无障碍功能
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 全选状态
  @State isSelectAll: boolean = false;
  // 是否是PC设备
  private isPC: boolean = EnvironmentProp.isPC();
  // 列表滚动控制器
  private scroller: Scroller = new Scroller();
  // 收藏删除操作参数，用于打点统计
  favoriteRemoveParams: CustomizedParams = {
    ISREMOVE: 0
  };

  /**
   * 组件即将出现时的生命周期函数
   * 功能：初始化组件状态、设置事件监听
   */
  aboutToAppear() {
    HiLog.i(TAG, 'EditFavoriteList aboutToAppear!');
    GlobalContext.getContext().setObject('scrollerEditFavorite', this.scroller);//设置列表滚动控制器
    this.mFavoriteListPresenter.initNavPaths(this.pathInfos);//设置导航路径
    let obj = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as EditFavoriteParam;//获取导航参数
    this.mFavoriteListPresenter.favoriteList = obj?.favoriteList ?? [];//设置收藏列表数据
    this.mFavoriteListPresenter.selectedContacts.clear();//清空已选联系人
    if (obj?.defaultSelectId) {
      this.mFavoriteListPresenter.selectedContacts.add(obj.defaultSelectId);//设置默认选中联系人
    }
    this.mFavoriteListPresenter.refreshUI = () => {
      HiLog.i(TAG, 'refreshUI')
      this.selectNumber = this.mFavoriteListPresenter.selectNumber;//更新选中数量
    }
    this.mFavoriteListPresenter.aboutToAppear();
    this.mListPresenter.requestItem()
  }

  /**
   * 组件即将消失时的生命周期函数
   * 功能：清理组件状态、取消事件监听
   */
  aboutToDisappear() {
    HiLog.i(TAG, 'EditFavoriteList aboutToDisappear!');
    GlobalContext.getContext().removeObject('scrollerEditFavorite');
    this.mFavoriteListPresenter.aboutToDisappear();
  }

  /**
   * 页面显示时的回调
   * 功能：初始化页面状态
   */
  destinationPageShow() {
    HiLog.i(TAG, 'EditFavoriteList onPageShow')
    this.mFavoriteListPresenter.onPageShow()
  }

  /**
   * 页面隐藏时的回调
   * 功能：清理页面状态
   */
  destinationPageHide() {
    HiLog.i(TAG, 'EditFavoriteList onPageCover')
    this.mFavoriteListPresenter.onPageHide()
  }

  /**
   * 构建PC端菜单
   * 功能：创建PC设备上的操作菜单
   */
  @Builder
  PCMenu() {
    Row() {
      // 删除按钮
      Button() {
        SymbolGlyph($r('sys.symbol.xmark_circle'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.cancel_favorite')))
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
      .enabled(this.selectNumber > 0)
      .onClick(() => {
        if (this.selectNumber > 0) {
          // 联系人打点-- 收藏页面编辑联系人移除
          if (this.mFavoriteListPresenter.favoriteList.length === this.selectNumber) {
            this.favoriteRemoveParams.ISREMOVE = 2;
          } else if (this.selectNumber > 1) {
            this.favoriteRemoveParams.ISREMOVE = 1;
          } else if (this.selectNumber === 1) {
            this.favoriteRemoveParams.ISREMOVE = 0;
          }
          DotUtil.getInstance().contactDot(this.favoriteRemoveParams, FAVORITE_REMOVE_CONTACT_EVENT);

          // 处理删除收藏联系人逻辑
          this.mFavoriteListPresenter.moveSortFavorite((needCancelFavorite: string[]) => {
            HiLog.w(TAG, `PC needCancelFavorite length: ${needCancelFavorite.length}`)
            this.mFavoriteListPresenter.deleteFavoriteInfo(needCancelFavorite);
            const deviceType: string = deviceInfo.deviceType;
            // 根据设备类型和布局决定页面跳转
            if (this.curBp === 'sm' || AppStorage.get('isShowSmartWindow') ||
              (deviceType === 'tablet') && DisplaySplitUtil.isVerticalSplit()) {
              this.pathInfos?.clear();
            } else {
              HiLog.w(TAG, 'pathInfos onClick: FavoriteDefaultPage');
              FavoriteListPresenter.getInstance().toDefaultPage();
            }
            this.mListPresenter.setPageShow(true);
          });
        }
      })

      // 全选/取消全选按钮
      Button() {
        SymbolGlyph(this.mFavoriteListPresenter.favoriteList.length === this.selectNumber ?
        $r('sys.symbol.checkmark_square_on_square_fill') : $r('sys.symbol.checkmark_square_on_square'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor(this.mFavoriteListPresenter.favoriteList.length === this.selectNumber ?
            [$r('app.color.skin_icon_emphasize')] : [$r('app.color.skin_icon_primary')])
      }
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility,
          this.mFavoriteListPresenter.favoriteList.length === this.selectNumber ?
          $r('app.string.select_all') : $r('app.string.unselect_all')))
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
        // 切换全选状态
        this.isSelectAll = this.mFavoriteListPresenter.favoriteList.length === this.selectNumber;
        if (this.isSelectAll) {
          // 取消全选
          this.mFavoriteListPresenter.selectedContacts.clear()
        } else {
          // 全选
          this.mFavoriteListPresenter.favoriteList.forEach((item: FavoriteBean) => {
            this.mFavoriteListPresenter.selectedContacts.add(item.contactId)
          })
        }
        // 更新选中数量
        this.selectNumber = this.mFavoriteListPresenter.selectedContacts.length;
        // 通知列表项更新选中状态
        emitter.emit(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED);
        // 刷新页面信息
        this.mFavoriteListPresenter.refreshPageMessage()
      })
    }
    .height($r('app.float.id_item_height_large'))
    .width('120vp')
    .alignItems(VerticalAlign.Center)
    .padding({ end: LengthMetrics.vp(232) })
  }

  @Builder
  phMenu() {
    Row(){ 
        Button() {
      SymbolGlyph($r('sys.symbol.checkmark'))
        .fontSize($r('app.float.id_width_24'))
        .fontColor([$r('app.color.skin_icon_secondary')])
    }
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
    .visibility(this.isDragShow ? Visibility.Visible : Visibility.Hidden)
    .onClick(() => {
      // 联系人打点--联系人收藏编辑页拖动保存
      this.mFavoriteListPresenter.selectedContacts.clear();
        this.mFavoriteListPresenter.sortFavorite(this.mFavoriteListPresenter.favoriteDataSource.getFavoriteList());
        this.mFavoriteListPresenter.isOnMoved = false;
      })
    }
    .height('100%')
    .alignItems(VerticalAlign.Center)
  }

  //   menuItem: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.cancel_favorite'),
  //       icon: $r('sys.symbol.xmark_circle'),
  //       isEnabled: this.selectNumber > 0,
  //       action: () => {
  //         if (this.selectNumber > 0) {
  //           // 联系人打点-- 收藏页面编辑联系人移除
  //           if (this.mFavoriteListPresenter.favoriteList.length === this.selectNumber) {
  //             this.favoriteRemoveParams.ISREMOVE = 2;
  //           } else if (this.selectNumber > 1) {
  //             this.favoriteRemoveParams.ISREMOVE = 1;
  //           } else if (this.selectNumber === 1) {
  //             this.favoriteRemoveParams.ISREMOVE = 0;
  //           }
  //           DotUtil.getInstance().contactDot(this.favoriteRemoveParams, FAVORITE_REMOVE_CONTACT_EVENT);
  //
  //           this.mFavoriteListPresenter.moveSortFavorite((needCancelFavorite: string[]) => {
  //             HiLog.w(TAG, `PC needCancelFavorite length: ${needCancelFavorite.length}`)
  //             this.mFavoriteListPresenter.deleteFavoriteInfo(needCancelFavorite);
  //             const deviceType: string = deviceInfo.deviceType;
  //             if (this.curBp === 'sm' || AppStorage.get('isShowSmartWindow') ||
  //               (deviceType === 'tablet') && DisplaySplitUtil.isVerticalSplit()) {
  //               this.pathInfos?.clear();
  //             } else {
  //               HiLog.w(TAG, 'pathInfos onClick: FavoriteDefaultPage');
  //               FavoriteListPresenter.getInstance().toDefaultPage();
  //             }
  //             this.mListPresenter.setPageShow(true);
  //           });
  //         }
  //       }
  //     }
  //   },
  //   {
  //     content: {
  //       label: this.mFavoriteListPresenter.favoriteList.length === this.selectNumber ?
  //       $r('app.string.select_all') : $r('app.string.unselect_all'),
  //       icon: this.mFavoriteListPresenter.favoriteList.length === this.selectNumber ?
  //       $r('sys.symbol.checkmark_square_on_square_fill') : $r('sys.symbol.checkmark_square_on_square'),
  //       isEnabled: true,
  //       action: () => {
  //         this.isSelectAll = this.mFavoriteListPresenter.favoriteList.length === this.selectNumber;
  //         if (this.isSelectAll) {
  //           this.mFavoriteListPresenter.selectedContacts.clear()
  //         } else {
  //           this.mFavoriteListPresenter.favoriteList.forEach((item: FavoriteBean) => {
  //             this.mFavoriteListPresenter.selectedContacts.add(item.contactId)
  //           })
  //         }
  //         this.selectNumber = this.mFavoriteListPresenter.selectedContacts.length;
  //         emitter.emit(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED);
  //         this.mFavoriteListPresenter.refreshPageMessage()
  //       }
  //     }
  //   }
  // ]
  //
  // phMenuItem: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: '',
  //       icon: $r('sys.symbol.checkmark'),
  //       isEnabled: true,
  //       action: () => {
  //         // 联系人打点--联系人收藏编辑页拖动保存
  //         this.mFavoriteListPresenter.selectedContacts.clear();
  //         this.mFavoriteListPresenter.sortFavorite(this.mFavoriteListPresenter.favoriteDataSource.getFavoriteList());
  //         this.mFavoriteListPresenter.isOnMoved = false;
  //       }
  //     }
  //   }
  // ]

  build() {
    if (this.isPC) {
      NavDestination() {
        this.editFavoriteBuilder()
      }
      .title(this.selectNumber > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectNumber)
        : ResourceUtil.getStringByResource($r('app.string.no_select')),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: LengthMetrics.vp(16)
        })
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
      .menus(this.PCMenu())
      .onBackPressed(() => {
        // 联系人打点--联系人收藏编辑页拖动未保存
        this.favoriteDragParams.ISSAVE = 0;
        DotUtil.getInstance().contactDot(this.favoriteDragParams, FAVORITE_DRAG_CONTACT_EVENT);
        this.pathInfos?.pop();
        this.mFavoriteListPresenter.cancelEditFavorite();
        return true;
      })
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
      .backgroundColor($r('app.color.skin_background_primary'))
    } else {
      NavDestination() {
        Navigation() {
          this.editFavoriteBuilder()
        }
        .titleMode(NavigationTitleMode.Full)
      }
      .bindToScrollable([this.scroller])
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), (this.isDragShow ? this.phMenuItem : undefined), () => {
      //
      // }))
      .title(this.selectNumber > 0
        ? ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.selectNumber)
        : ResourceUtil.getStringByResource($r('app.string.no_select')),
        {
          mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
          paddingStart: LengthMetrics.vp(16)
        })
      .menus(this.phMenu())
      .onBackPressed(() => {
         this.onBack();
         return true
      })
      .onShown(() => {
        this.destinationPageShow();
      })
      .onHidden(() => {
        this.destinationPageHide();
      })
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
      .backgroundColor($r('app.color.skin_background_primary'))
    }
  }



  /**
   * 构建编辑收藏列表内容
   * 功能：创建编辑收藏列表的主体内容
   */
  @Builder
  editFavoriteBuilder() {
    Column() {
      if (this.mFavoriteListPresenter.favoriteList.length > 0) {
        FavoriteContent({
          presenter: $mFavoriteListPresenter,// 收藏列表数据源
          selectNumber: $selectNumber,// 已选择的联系人数量
          isSelectAll: $isSelectAll,// 是否全选
          offsetY: $offsetY,// 滚动偏移量
          isDragShow: $isDragShow,// 是否显示拖拽排序功能
        });// 收藏列表内容
      }
    }
    .backgroundColor($r('app.color.skin_background_primary'))
    .width('100%')
    .height('100%')
  }

  private onBack() {
    // 联系人打点--联系人收藏编辑页拖动未保存
    this.favoriteDragParams.ISSAVE = 0;
    DotUtil.getInstance().contactDot(this.favoriteDragParams, FAVORITE_DRAG_CONTACT_EVENT);
    this.mFavoriteListPresenter.cancelEditFavorite();
  }

  // 获取标题参数
  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     padding: { start: this.isPC ? LengthMetrics.vp(16) : undefined },
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.no_select')),
  //       isMultipleSelectState: true, selectedNumber: this.selectNumber },
  //     backIcon: { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }
}

/**
 * 收藏列表内容组件
 * 功能：显示收藏联系人列表，处理列表的拖拽排序、多选等功能
 */
@Component
struct FavoriteContent {
  // 导航路径栈，用于页面导航
  @Consume('pathInfos') pathInfos: NavPathStack;
  // 编辑收藏列表数据管理器，通过双向绑定获取
  @Link presenter: EditFavoriteListPresenter;
  // 是否显示常用联系人
  isUsuallyShow: boolean = false;
  // 选中数量，通过双向绑定获取并监听变化
  @Link @Watch('updateToolbar') selectNumber: number;
  // 纵轴偏移量，用于列表滚动
  @Link offsetY: number;
  // 选中的收藏联系人ID列表
  @State selectFavoriteIdList: string[] = [];
  // 收藏列表数据管理器
  @State favoriteListPresenter: EditFavoriteListPresenter = this.presenter;
  // 全选状态，通过双向绑定获取
  @Link isSelectAll: boolean;
  // 全选状态内部变量
  @State isSelectAllStatus: boolean = false;
  // 文本内容
  @State text: string = '';
  // 是否是编辑拖拽模式
  @State isEditDrag: boolean = false;
  // 选中数量
  @State select: number = 0;
  // 当前索引
  @State currentIndex: number = 0;
  // 是否显示拖拽保存按钮，通过双向绑定获取
  @Link isDragShow: boolean;
  // 当前拖拽项索引
  @State curDragItemIndex: number = -1;
  // 拖拽项Y轴偏移量
  @State translateY: number = 0;
  // 拖拽项透明度
  @State dragItemOpacity: number = 1;
  // 焦点索引
  @State focusIndex: number = -1;
  // 收藏列表数据管理器实例
  @State mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  // 当前断点，用于响应式布局
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 列表项交换状态
  @State listItemExchange: boolean = false;
  // 左右边距
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 可见列表长度
  public sceillOnlenth: number = 0;
  // 全选文本
  public selectAll: string = ResourceUtil.getStringByResource($r('app.string.select_all'));
  // 收藏拖拽操作参数，用于打点统计
  @State favoriteDragParams: CustomizedParams = {
    ISDRAG: 0,
    ISSAVE: 0
  };
  // 收藏删除操作参数，用于打点统计
  favoriteRemoveParams: CustomizedParams = {
    ISREMOVE: 0
  };
  // 工具栏选项
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  // 工具栏修饰符
  private toolBarModifier: ToolBarModifier = 
    new ToolBarModifier().height(LengthMetrics.vp(48)).backgroundColor(Color.Transparent).stateEffect(true);
  // 分隔线修饰符
  @State dividerModifier: DividerModifier = new DividerModifier().height(0);
  // 进度计数
  @State progressCount: number = 0;
  // 进度百分比
  @State percent: number = 0;
  // 是否是PC设备
  private isPC: boolean = EnvironmentProp.isPC();
  // 列表滚动控制器
  private scroller: Scroller = GlobalContext.getContext().getObject('scrollerEditFavorite') as Scroller;
  // 滑动多选工具类
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil = 
    new SlidingMultipleSelectionsUtil(this.scroller, 56);
  // 需要取消收藏的数量
  private needCancelFavorite: number = 0;
  // 是否收到真实数据
  private isRealDataReceived: boolean = false;
  // 可拖拽项索引
  private indexDraggableItem: number = -1;

  /**
   * 删除进度条的弹窗
   * 功能：显示大量删除收藏联系人时的进度
   */
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

  /**
   * 拖拽事件处理器
   * 功能：处理列表项的拖拽排序事件
   */
  onMoveEventHandler: ItemDragEventHandler = {
    // 长按开始拖拽
    onLongPress: (index: number) => {
      if (this.indexDraggableItem < 0) {
        this.indexDraggableItem = index;
      }
      // 发送无障碍事件信息
      AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
        ResourceUtil.getStringByResource($r('app.string.sorted_item_pick_up'))
      );
    },
    // 拖拽过程中
    onMoveThrough: (from: number, to: number) => {
      HiLog.i(TAG, `onMoveThrough: ${from}, ${this.indexDraggableItem}, ${to}`);
      if (to >= this.presenter.favoriteList.length) {
        return;
      }
      if (this.indexDraggableItem > to) { // 拖动到上方
        let index: number = from > to ? to : this.indexDraggableItem;
        let target = this.presenter.favoriteDataSource.getFavoriteList()[index];
        let name = target.displayName as string;
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
          ResourceUtil.getStringByResource($r('app.string.sorted_item_move_forward'), name)
        );
      }
      if (this.indexDraggableItem < to) { // 拖动到xx下方
        let index: number = from >= to ? this.indexDraggableItem: to;
        let target = this.presenter.favoriteDataSource.getFavoriteList()[index];
        let name = target.displayName as string;
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
          ResourceUtil.getStringByResource($r('app.string.sorted_item_move_backward'), name)
        );
      }
      this.indexDraggableItem = to;
    },
    // 拖拽结束
    onDrop: (index: number) => {
      AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
        ResourceUtil.getStringByResource($r('app.string.sorted_item_pick_down'))
      );
      this.indexDraggableItem = -1;
    }
  };

  /**
   * 构建进度对话框内容
   * 功能：创建删除进度条的UI
   */
  @Builder
  ProgressDialogBuilder() {
    Column() {
      ProgressBarContent({
        percent: this.percent,
        progressText: $r('app.string.cancelling_favorite_contacts'),
      })
    }
    .width('100%')
  }

  /**
   * 更新工具栏
   * 功能：根据选中数量更新工具栏选项
   */
  updateToolbar() {
    this.toolbarList = [];
    this.toolbarList.push(
      {
        content: $r('app.string.cancel_favorite'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.xmark_circle')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        state: this.selectNumber > 0 ? 1 : 2,
        action: () => {
          if (this.selectNumber > 0) {
            // 联系人打点-- 收藏页面编辑联系人移除
            if (this.presenter.favoriteList.length === this.selectNumber) {
              this.favoriteRemoveParams.ISREMOVE = 2;
            } else if (this.selectNumber > 1) {
              this.favoriteRemoveParams.ISREMOVE = 1;
            } else if (this.selectNumber === 1) {
              this.favoriteRemoveParams.ISREMOVE = 0;
            }
            DotUtil.getInstance().contactDot(this.favoriteRemoveParams, FAVORITE_REMOVE_CONTACT_EVENT);

            // 处理删除收藏联系人逻辑
            this.presenter.moveSortFavorite((needCancelFavorite: string[]) => {
              HiLog.w(TAG, `needCancelFavorite length: ${needCancelFavorite.length}`);
              this.presenter.deleteFavoriteInfo(needCancelFavorite);
              this.mFavoriteListPresenter.favoriteDataSource.bathDeleteFavoriteContactId(needCancelFavorite);
              this.needCancelFavorite = needCancelFavorite.length;
              // 大量数据删除时显示进度对话框
              if (Number(needCancelFavorite.length) > 500) {
                this.percent = 0;
                this.progressCount = 0;
                this.progressDialog.open();
                DialogControllerManager.getInstance().addDialogController(this.progressDialog);
              } else {
                const deviceType: string = deviceInfo.deviceType;
                // 根据设备类型和布局决定页面跳转
                if (this.curBp === 'sm' || AppStorage.get('isShowSmartWindow') ||
                  (deviceType === 'tablet') && DisplaySplitUtil.isVerticalSplit()) {
                  this.pathInfos?.clear();
                } else {
                  HiLog.w(TAG, 'pathInfos onClick: FavoriteDefaultPage');
                  FavoriteListPresenter.getInstance().toDefaultPage();
                }
              }
              this.mFavoriteListPresenter.setPageShow(true);
            });
          }
        }
      },
      {
        content: this.presenter.favoriteList.length === this.selectNumber ? $r('app.string.unselect_all') :
        $r('app.string.select_all'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('app.color.skin_font_primary')]),
          activated: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill')).fontColor([$r('app.color.skin_icon_emphasize')]),
        },
        state: ItemState.ACTIVATE,
        action: () => {
          // 切换全选状态
          this.isSelectAll = this.presenter.favoriteList.length === this.selectNumber;
          if (this.isSelectAll) {
            // 取消全选
            this.presenter.selectedContacts.clear();
            AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.presenter.contactsTotal);
          } else {
            // 全选
            this.presenter.favoriteList.forEach((item: FavoriteBean) => {
              this.presenter.selectedContacts.add(item.contactId);
            });
            AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.presenter.contactsTotal);
          }
          // 更新选中数量
          this.selectNumber = this.presenter.selectedContacts.length;
          // 通知列表项更新选中状态
          emitter.emit(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED);
          // 刷新页面信息
          this.presenter.refreshPageMessage()
        },
      }
    )

  }

  /**
   * 组件即将出现时的生命周期函数
   * 功能：初始化组件状态、设置事件监听
   */
  aboutToAppear(): void {
    HiLog.w(TAG, 'FavoriteContent aboutToAppear');
    // 初始化假进度的定时器
    let fakeProgressTimer: number | undefined;
    // 监听假进度事件
    emitter.on(FavoriteListPresenter.EMITTER_FAKE_FAVORITE_DELETE, () => {
      let maxPercent = Math.round((500 / this.needCancelFavorite) * 100);
        // 如果当前进度为0，启动假进度定时器
        fakeProgressTimer = setInterval(() => {
          if (!this.isRealDataReceived) {
            this.progressCount += 1;
            this.percent = Math.min(this.progressCount, maxPercent);
          } else {
            HiLog.i(TAG, `clearInterval fake percent`);
            clearInterval(fakeProgressTimer);
            fakeProgressTimer = undefined;
          }
        }, 1000);

    })

    // 监听收藏删除事件
    emitter.on(FavoriteListPresenter.EMITTER_FAVORITE_DELETE, (eventData: emitter.EventData) => {
      if (eventData.data) {
        this.isRealDataReceived = true;
        this.progressCount += eventData.data.selectedCounts;
        this.percent = Math.min(Math.round((this.progressCount / this.needCancelFavorite) * 100), 100);
        // 如果进度完成,弹窗关闭
        if (this.progressCount >= this.needCancelFavorite) {
          this.progressDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          const deviceType: string = deviceInfo.deviceType;
          if (this.curBp === 'sm' || AppStorage.get('isShowSmartWindow') ||
            (deviceType === 'tablet') && DisplaySplitUtil.isVerticalSplit()) {
            this.pathInfos?.clear();
          } else {
            HiLog.w(TAG, 'pathInfos onClick: FavoriteDefaultPage');
            FavoriteListPresenter.getInstance().toDefaultPage();
          }
          setTimeout(() => {
            this.isRealDataReceived = false;
            this.progressCount = 0;
            this.percent = 0;
            clearInterval(fakeProgressTimer);
            fakeProgressTimer = undefined;
          }, 1000);
        }
      }
    });
    // 更新工具栏
    this.updateToolbar()
  }

  /**
   * 组件即将消失时的生命周期函数
   * 功能：清理组件状态、取消事件监听
   */
  aboutToDisappear(): void {
    HiLog.w(TAG, 'FavoriteContent aboutToDisappear');
    // 关闭进度对话框
    this.progressDialog?.close();
    // 清除对话框控制器
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    // 取消监听收藏删除事件
    emitter.off(FavoriteListPresenter.EMITTER_FAVORITE_DELETE);
    // 取消监听假进度事件
    emitter.off(FavoriteListPresenter.EMITTER_FAKE_FAVORITE_DELETE);
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
            List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
              LazyForEach(this.presenter.favoriteDataSource, (item: FavoriteListBean, index: number) => {
                ListItem() {
                  Column() {
                    FavoriteListItem({
                      item: item,
                      presenter: $favoriteListPresenter,
                      selectNumber: $selectNumber,
                      isSelectAll: $isSelectAll,
                      curDragItemIndex: $curDragItemIndex,
                      dragItemOpacity: $dragItemOpacity,
                      translateY: $translateY,
                      isEditDrag: $isEditDrag,
                      isDragShow: $isDragShow,
                      index: index,
                      focusIndex: $focusIndex,
                      listItemExchange: $listItemExchange,
                      favoriteDragParams: $favoriteDragParams
                    })
                      .opacity(index === this.curDragItemIndex ? this.dragItemOpacity : 1)
                      .translate({ y: index === this.curDragItemIndex ? this.translateY : 0 })
                  }
                  .alignItems(HorizontalAlign.Start)
                }
              }, (item: FavoriteListBean) => JSON.stringify(item))
                .onMove((from: number, to: number)=>{
                  let tmp = this.presenter.favoriteDataSource.getFavoriteList().splice(from, 1);
                  this.presenter.favoriteDataSource.getFavoriteList().splice(to, 0, tmp[0]);
                  let tempClickitem = this.presenter.favoriteList.splice(from, 1)[0];
                  this.presenter.favoriteList.splice(to, 0, tempClickitem);
                  this.isDragShow = true
                  this.presenter.isOnMoved = true;
                }, this.onMoveEventHandler)
            }
            .width('100%')
            .height('100%')
            .divider({
              strokeWidth: '1px',
              color: $r('app.color.skin_comp_divider'),
              startMargin: $r('app.float.id_card_divider_left'),
              endMargin: $r('sys.float.padding_level8')
            })
            .clipContent(ContentClipMode.SAFE_AREA)
            .scrollBar(BarState.Off)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .onScrollIndex((start: number, end: number) => {
              this.slidingMultipleSelectionsUtil.scrollStartIndex = start;
              this.slidingMultipleSelectionsUtil.scrollEndIndex = end;

              this.sceillOnlenth = (end - start) + 1
            })
            .onScroll((scrollOffset, scrollState) => {
              if (scrollOffset > 0 && this.offsetY < 0 && scrollState !== 2) {
                this.offsetY = scrollOffset;
              }
            })
            .onReachStart(() => {
              this.offsetY = -1;
            })
            .gesture(PanGesture({ direction: PanDirection.Vertical })
              .onActionStart((event: GestureEvent) => {
                for (let i = 0; i < this.presenter.favoriteDataSource.totalCount(); ++i) {
                  let item = this.presenter.favoriteDataSource.getData(i);
                  let selectStatus = this.presenter.selectedContacts.has(item?.favorite.contactId);
                  this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
                  this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
                }
                this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
              })
              .onActionUpdate((event: GestureEvent) => {
                let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
                  let curSelectStatus = false;
                  if (index >= 0) {
                    let item = this.presenter.favoriteDataSource.getData(index);
                    curSelectStatus = this.presenter.selectedContacts.has(item?.favorite.contactId);
                  }
                  return curSelectStatus;
                });
                updateIndexes.forEach((index) => {
                  if (index >= 0) {
                    let item = this.presenter.favoriteDataSource.getData(index);
                    this.presenter.onItemClick(item?.favorite, index)
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
        }
        .layoutWeight(1)
        .flexShrink(1)

        if (!this.isPC) {
          WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
            ToolBar({
              toolBarModifier: this.toolBarModifier,
              dividerModifier: new DividerModifier().height(0),
              activateIndex: this.presenter.favoriteList.length === this.selectNumber ? 1 : -1,
              toolBarList: this.toolbarList,
            })
              .height($r('app.float.id_item_height_mid'))
              .width('100%')
              .backgroundColor($r('app.color.skin_background_primary'))
          }
        }
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}

/**
 * 收藏列表项组件
 * 功能：显示单个收藏联系人的信息，处理点击、拖拽等操作
 */
@Reusable
@Component
export struct FavoriteListItem {
  // 编辑收藏列表数据管理器，通过双向绑定获取
  @Link presenter: EditFavoriteListPresenter;
  // 收藏列表项数据
  @Prop item: FavoriteListBean;
  // 列表项索引
  @Prop index: number
  // 焦点索引，通过双向绑定获取
  @Link focusIndex: number;
  // 选中数量，通过双向绑定获取
  @Link selectNumber: number;
  // 全选状态，通过双向绑定获取
  @Link isSelectAll: boolean;
  // 当前拖拽项索引，通过双向绑定获取
  @Link curDragItemIndex: number;
  // 拖拽项透明度，通过双向绑定获取
  @Link dragItemOpacity: number;
  // 拖拽项Y轴偏移量，通过双向绑定获取
  @Link translateY: number;
  // 是否是编辑拖拽模式，通过双向绑定获取
  @Link isEditDrag: boolean;
  // 是否显示拖拽保存按钮，通过双向绑定获取
  @Link isDragShow: boolean;
  // 纵轴偏移量
  public offsetY: number = 0;
  // 之前的Y轴偏移量
  @State preTranslateY: number = 0;
  // 拖拽项高度
  @State dragItemHeight: number = 64;
  // 拖拽项高度限制
  @State dragItemHeightLimit: number = 42;
  // 照片像素图
  @State photoPixelMap: PixelMap | null = null;
  // 列表项交换状态，通过双向绑定获取并监听变化
  @Link @Watch('updateListItemShow') listItemExchange: boolean;
  // 收藏拖拽操作参数，用于打点统计，通过双向绑定获取
  @Link favoriteDragParams: CustomizedParams;
  // 字体大小缩放
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否是PC设备
  private isPC: boolean = EnvironmentProp.isPC();
  // 复选框选中状态
  @State isCbChecked: boolean = false;
  // 编辑收藏列表数据管理器实例
  private editFavoriteListPresenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
  /**
   * 组件即将出现时的生命周期函数
   * 功能：初始化组件状态、设置事件监听
   */
  aboutToAppear() {
    // 更新列表项显示
    this.updateListItemShow()
    // 监听列表项选中事件
    emitter.on(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED, (eventData: emitter.EventData) => {
      let contactId = eventData.data?.contactId as string;
      if (!contactId || this.item.favorite.contactId === contactId) {
        this.isCbChecked = this.editFavoriteListPresenter.selectedContacts.has(this.item.favorite.contactId);
      }
    })
    // 初始化复选框选中状态
    this.isCbChecked = this.editFavoriteListPresenter.selectedContacts.has(this.item.favorite.contactId);
  }

  /**
   * 组件复用前的生命周期函数
   * 功能：更新组件数据和状态
   * @param params 复用参数
   */
  aboutToReuse(params: LooseObject): void {
    this.item = params.item;
    this.index = params.index;
    // 获取联系人头像
    getPixelMapFromFile(this.item.favorite.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
    // 更新复选框选中状态
    this.isCbChecked = this.editFavoriteListPresenter.selectedContacts.has(this.item.favorite.contactId);
  }

  /**
   * 组件即将消失时的生命周期函数
   * 功能：清理组件状态、取消事件监听
   */
  aboutToDisappear(): void {
    // 取消监听列表项选中事件
    emitter.off(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED);
  }


  /**
   * 组件构建完成后的生命周期函数
   * 功能：处理焦点请求
   */
  onDidBuild(): void {
    if (this.focusIndex == this.index) {
      try {
        // 请求焦点
        this.getUIContext().getFocusController().requestFocus('FavoriteListItem' + this.index)
      } catch (error) {
        HiLog.e('FavoriteListItem', 'requestFocus failed code is ' + error.code + ' message is ' + error.message)
      }
      this.focusIndex = -1
    }
  }

  /**
   * 电话号码格式化
   * 功能：将电话号码格式化为XXX XXXX XXXX的形式
   * @param value 电话号码
   * @returns 格式化后的电话号码
   */
  phonenumberFormat(value: string) {
    if (value) {
      const matches = new RegExp('^(\\d{3})(\\d{4})(\\d{4})$').exec(value);
      if (matches) {
        return matches[1] + '\xa0' + matches[2] + '\xa0' + matches[3];
      }
    }
    return value;
  }

  /**
   * 更新列表项显示
   * 功能：更新列表项的数据和头像
   */
  updateListItemShow() {
    this.item = this.presenter.favoriteDataSource.getData(this.index) as FavoriteListBean;
    // 获取联系人头像
    getPixelMapFromFile(this.item.favorite.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res
    })
  }

  /**
   * 按下状态样式
   * 功能：定义列表项按下时的样式
   */
  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
  }

  /**
   * 正常状态样式
   * 功能：定义列表项正常时的样式
   */
  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Row(){
              if (!this.isPC) {
                Button() {
                  SymbolGlyph($r('sys.symbol.line_2_horizontal'))
                    .fontColor([$r('app.color.skin_icon_secondary')])
                    .fontSize($r('app.float.id_width_24'))
                }
                .accessibilityGroup(true)
                .accessibilityRole(AccessibilityRoleType.TEXT)
                .accessibilityDescription($r('app.string.editfavorite_drag_button'))
                .height($r('app.float.id_width_24'))
                .width($r('app.float.id_width_24'))
                .backgroundColor(Color.Transparent)
              }
            }
            .margin({
              end: LengthMetrics.resource($r('app.float.dialer_common_small_margin'))
            })
            Row(){
              Row() {
                Row() {
                  if (this.photoPixelMap) {
                    Image(this.photoPixelMap)
                      .width($r('app.float.id_card_image_mid'))
                      .height($r('app.float.id_card_image_mid'))
                      .objectFit(ImageFit.Auto)
                      .borderRadius($r('app.float.id_card_image_mid'))
                      .draggable(false)
                  } else if (StringUtil.isEmpty(this.item.favorite.headChar)) {
                    Image(StringUtil.isEmpty(this.item.favorite.portraitPath) ?
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
                  } else {
                    Text(this.item.favorite.headChar)
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
                .margin({
                  end: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
                  LengthMetrics.resource($r('app.float.dialer_common_small_margin'))
                })
                .height($r('app.float.id_card_image_mid'))
                .width($r('app.float.id_card_image_mid'))

                Text(this.item.favorite.displayName)
                  .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 10)
                  .fontSize($r('sys.float.Body_L'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({
                    end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level0')) :
                    LengthMetrics.resource($r('app.float.id_card_image_xs')),
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.dialer_button_text_font_size')),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.dialer_button_text_font_size'))
                  })
                  .fontColor($r('app.color.skin_font_primary'))
                  .textAlign(TextAlign.Start)
                  .fontWeight(FontWeight.Medium)
                  .width(this.isPC ? 'calc(100% - 56vp)' : '65%')
                  .direction(Direction.Ltr)
                  .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              }
              .padding({
                top: FontScaleState.isStandardGeer(this.fontSizeScale) ? 0 : 10,
                bottom: FontScaleState.isStandardGeer(this.fontSizeScale) ? 0 : 10
              })

              Toggle({
                type: ToggleType.Checkbox,
                isOn: this.isCbChecked
              })
                .size({ width: 20, height: 20 })
                .margin($r('sys.float.padding_level1'))
                .flexShrink(0)
                .enabled(true)
                .hitTestBehavior(HitTestMode.None)
                .selectedColor($r('app.color.skin_comp_background_emphasize'))
                .focusable(false)
                .accessibilityLevel('no')
                .onClick((event: ClickEvent) => {
                  AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.isCbChecked ? ResourceUtil.getStringByResource($r('app.string.accessibility_selected'))
                    : ResourceUtil.getStringByResource($r('app.string.accessibility_unselected')))
                })
            }
            .onClick(() => {
              this.focusIndex = this.index
              this.presenter.onItemClick(this.item.favorite, this.index)
            })
            .accessibilityChecked(this.isCbChecked ? true : false)
            .accessibilityRole(AccessibilityRoleType.CHECKBOX)
            .accessibilityDescription(this.isCbChecked ? $r('app.string.accessibility_checkbox_selected') : $r('app.string.accessibility_checkbox_deselected'))
            .width('100%')
          }
        }
        .alignItems(VerticalAlign.Center)
        .direction(Direction.Ltr)
        .justifyContent(FlexAlign.Start)
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
        })
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        right: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
      })
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
      .focusable(true)
      .id('FavoriteListItem' + this.index)
    }
    .margin({ bottom: this.index === this.presenter.contactsTotal - 1 ? $r('app.float.id_card_margin_xxl') : 0 })
  }
}