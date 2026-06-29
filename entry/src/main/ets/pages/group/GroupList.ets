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

import { HiLog } from '../../../../../../common';
import GroupListPresenter from '../../presenter/group/GroupListPresenter';
import GroupListItem from '../../component/group/GroupListItem';
import VibrationUtils from '../../util/VibrationUtils';
import { GroupInfo } from '../../model/bean/GroupBean';
import promptAction from '@ohos.promptAction';
import { VibrationEffect } from '../../model/type/EnumUtil';
import NewGroupAccountDialog from '../dialog/NewGroupAccountDialog';
import ArrangeContactsPresenter from '../../../../main/ets/presenter/contact/settings/ArrangeContactsPresenter';
import { AccountVo } from '../../model/bean/AccountVo';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import router from '@ohos.router';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomTextInputContent from '../dialog/CustomTextInputContent';
import { ResourceUtil } from '../../util/ResourceUtil';
import { LengthMetrics, SubHeader, ToolBar, ToolBarModifier, ToolBarOptions } from '@kit.ArkUI';
import { DividerModifier, SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import Curves from '@ohos.curves';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { PCSubTitle } from '../../component/contact/SubHeader';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import IntelligenceGroupListItem from '../../component/intelligencegroup/IntelligenceGroupListItem';
import IntelligenceGroupListPresenter from '../../presenter/intelligencegroup/IntelligenceGroupListPresenter';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import { Constants } from '../../data/Constants';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';
import {
  IntelligenceGroupListInterface
} from '../../presenter/intelligencegroup/IntelligenceGroupSingleCategoryDetailPresenter';
// 注释掉的UIDesignKit组件导入
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// 导入标题栏工具类和参数类型
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';


const TAG = 'GroupList';
const GROUP_CLICK_DELETE_EVENT: string = 'GROUP_CLICK_DELETE_EVENT';
const CREATE_GROUP_EVENT = 'CREATE_GROUP_EVENT';
class MainTitleTextModifier extends TextModifier {

  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

// 群组列表页面主组件
@Component
export default struct GroupListPage {
  @StorageLink('fullScreenPadding')  fullScreenPadding: Padding = {};
  @State mPresenter: GroupListPresenter = GroupListPresenter.getInstance();
  @State intelligenceGroupPresenter: IntelligenceGroupListPresenter = IntelligenceGroupListPresenter.getInstance();
  @State groupListLen: number = 0;
  @State contactListListLen: number = ContactListPresenter.getInstance().total;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State aPresenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @State translateTitle: number | string = '50%'
  @State titleOpacity: number = 0
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State mainTitleModifier: MainTitleTextModifier = new MainTitleTextModifier();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  private isPC: boolean = EnvironmentProp.isPC();
  scroller: Scroller = new Scroller();
  customParams: CustomizedParams = {};
  groupAccountId: String = '';
  createGroupParams: CustomizedParams = {
    ENC: 1,
    ISCREATE: 0
  };


  @State updateGroupList: IntelligenceGroupListInterface = {
    updateIntelligenceGroupList: (): void => {

      this.groupListLen = this.mPresenter.groupCount;
    }
  };

  // 新建群组文本输入对话框控制器
  // 用于显示输入群组名称的对话框
  editDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      // 设置对话框主题
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      // 设置对话框主标题
      primaryTitle: $r('app.string.new_group'),
      // 设置对话框内容构建器
      contentBuilder: () => {
        this.TextInputBuilder();
      },
      // 设置内容区域内边距
      contentAreaPadding: { left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  

  newGroupAccountDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      // 设置对话框主题
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      // 设置对话框主标题
      primaryTitle: $r('app.string.new_group_source'),
      // 设置对话框内容构建器
      contentBuilder: () => {
        this.NewGroupAccountDialog();
      },
      // 设置对话框按钮
      buttons: [
        {
          // 取消按钮
          value: $r('app.string.dialog_cancel'), // 按钮文本
          // 取消按钮点击事件
          action: () => {
            // 清除对话框控制器管理器中的所有对话框控制器
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.w(TAG, 'onShareDialogCancel !!! '); // 记录取消日志
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    closeAnimation: { duration: 100 }
  });



  aboutToAppear() {
    sharedPreferencesUtils.getFromPreferences(Constants.HICALL_USER_ID_STATUS, 0).then((userId)=>{
      AppStorage.setOrCreate(Constants.INTELLIGENCE_GROUP_USER_ID, userId);
    });

    this.aPresenter.initNavPaths(this.pathInfos);
    this.mPresenter.initNavPaths(this.pathInfos);
    this.intelligenceGroupPresenter.initNavPaths(this.pathInfos);

    this.aPresenter.getAllAccountAndContactSize();

    this.mPresenter.updateGroupList = this.updateGroupList;

    this.mPresenter.aboutToAppear();
  }


  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear!');
    this.editDialog = null;
  }


  onPageHide() {
    HiLog.w(TAG, 'onPageCover');
  }


  destinationPageShow() {
    HiLog.w(TAG, 'destinationPageShow'); //
    // 重新调用presenter的aboutToAppear方法，刷新群组列表数据
    this.mPresenter.aboutToAppear();
  }

  @Builder
  TextInputBuilder() {
    Column() {

      CustomTextInputContent({
        inputValue: '',
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        
        // 取消按钮点击事件
        onCancel: () => {
          this.createGroupParams.ISCREATE = 0;
          DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
          this.editDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },

        onConfirm: (value: string) => {
          if (value.trim().length == 0) {
            return;
          } else {
            // 设置创建群组参数为确认状态
            this.createGroupParams.ISCREATE = 1;
            // 打点记录用户确认创建群组事件
            DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
            
            // 检查群组名称是否已存在
            if (this.mPresenter.ifGroupExist(value)) {
              // 显示群组已存在提示信息
              promptAction.showToast({
                message: $r('app.string.group_existed'),
                duration: 2000,
              });
              return;
            } else {
              HiLog.w(TAG, 'AlertDialog CreateGroup');
              
              // 如果只有一个账户，设置默认账户ID为1
              if (this.aPresenter.accountList.length == 1) {
                this.groupAccountId = '1';
              }
              
              // 调用presenter的addGroup方法创建群组
              this.mPresenter.addGroup(value, this.groupAccountId);
            }
            
            // 关闭编辑对话框
            this.editDialog?.close();
            // 清除对话框控制器管理器中的所有对话框控制器
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      })
    }
    .width('100%')
  }


  @Builder
  NewGroupAccountDialog() {
    Column() {

      NewGroupAccountDialog({
        itemList: this.aPresenter.accountList,
        onItemClick: (value) => {
          this.groupAccountId = value[0];
          AppStorage.setOrCreate('groupAccountName', value[1]);
          this.newGroupAccountDialog.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.editDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.editDialog);
        }
      })
    }
    .width('100%')
  }
  build() {

    NavDestination() {
      Navigation(){

        Column() {

          if (this.isPC) {
            // 水平布局容器
            Row() {
              // 群组标题文本
              Text($r('app.string.group'))
                .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                .fontSize($r('sys.float.ohos_id_text_size_headline8')) // 设置字体大小
                .fontWeight(FontWeight.Bold) // 设置字体粗细为粗体
                .padding({
                  start: this.isPC ? LengthMetrics.vp(24) : LengthMetrics.resource(this.spaceLR) // 设置左内边距，PC端为24vp，移动端使用资源值
                })
                .opacity(this.titleOpacity) // 设置透明度
                .translate({ x: this.translateTitle }) // 设置水平平移

              // 按钮容器行布局
              Row() {
                // 新建群组按钮
                Button() {
                  SymbolGlyph($r('sys.symbol.plus')) // 使用加号系统图标
                    .fontSize($r('app.float.id_card_image_small')) // 设置图标大小
                    .fontColor([$r('app.color.skin_icon_primary')]) // 设置图标颜色
                }
                .accessibilityText(AccessibilityUtil.getInstance()
                  .setAccessibilityText(this.isOpenAccessibility, $r('app.string.new_group'))) // 设置辅助功能文本
                .type(this.isPC ? ButtonType.Normal : ButtonType.Circle) // 设置按钮类型，PC端为普通按钮，移动端为圆形按钮
                .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0) // 设置边框半径
                .width($r('app.float.id_card_image_mid')) // 设置按钮宽度
                .height($r('app.float.id_card_image_mid')) // 设置按钮高度
                .buttonStyle(ButtonStyleMode.TEXTUAL) // 设置按钮样式为文本样式
                .stateEffect(true) // 设置点击效果
                .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal')) // 设置背景颜色
                .margin({
                  end: LengthMetrics.resource($r('sys.float.padding_level4')) // 设置右外边距
                })
                .onClick(() => {
                  // 如果有多个账户，打开账户选择对话框
                  if (this.aPresenter.accountList.length > 1) {
                    this.newGroupAccountDialog.open();
                    DialogControllerManager.getInstance().addDialogController(this.newGroupAccountDialog);
                  } else {
                    // 否则直接打开群组名称输入对话框
                    this.editDialog?.open();
                    DialogControllerManager.getInstance().addDialogController(this.editDialog);
                  }
                })

                // 删除群组按钮
                Button() {
                  SymbolGlyph($r('sys.symbol.trash')) // 使用垃圾桶系统图标
                    .fontSize($r('app.float.id_card_image_small')) // 设置图标大小
                    .fontColor([$r('app.color.skin_icon_primary')]) // 设置图标颜色
                }
                .accessibilityText(AccessibilityUtil.getInstance()
                  .setAccessibilityText(this.isOpenAccessibility, $r('app.string.dialog_delete'))) // 设置辅助功能文本
                .type(this.isPC ? ButtonType.Normal : ButtonType.Circle) // 设置按钮类型，PC端为普通按钮，移动端为圆形按钮
                .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0) // 设置边框半径
                .width($r('app.float.id_card_image_mid')) // 设置按钮宽度
                .height($r('app.float.id_card_image_mid')) // 设置按钮高度
                .buttonStyle(ButtonStyleMode.TEXTUAL) // 设置按钮样式为文本样式
                .stateEffect(true) // 设置点击效果
                .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal')) // 设置背景颜色
                .margin({
                  end: LengthMetrics.resource($r('sys.float.padding_level4')) // 设置右外边距
                })
                .onClick(() => {
                  // 打点记录删除群组事件
                  DotUtil.getInstance().contactDot(this.customParams, GROUP_CLICK_DELETE_EVENT);
                  // 调用presenter的批量删除群组方法
                  this.mPresenter.toBatchDeleteGroup()
                })
              }
            }
            .height($r('app.float.id_item_height_large')) // 设置高度
            .width('100%') // 设置宽度为100%
            .alignItems(VerticalAlign.Center) // 垂直居中对齐
            .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
            .padding({ end: LengthMetrics.vp(136) }) // 设置右内边距
          }


          GroupContent({
            presenter: $mPresenter,
            intelligenceGroupPresenter: $intelligenceGroupPresenter,
            aPresenter: $aPresenter,
            editDialog: this.editDialog,
            newGroupAccountDialog: this.newGroupAccountDialog,
            scroller: this.scroller
          })
        }
        .flexShrink(1)
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(this.isPC) // PC端隐藏标题栏
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
    //   this.onBack();
    // }))
    .title(ResourceUtil.getStringByResource($r('app.string.group')))
    .onBackPressed(() => {
      // 调用presenter的backItemClick方法
      this.mPresenter.backItemClick();
      // 如果是小屏幕、智能窗口或垂直分屏状态
      if ((this.curBp === 'sm') || this.isShowSmartWindow ||
        AppStorage.get('splitStatus') === SplitStatus.VERTICAL_SPLIT) {
        this.pathInfos?.pop();
      } else {
        router.back();
      }
      return true;
    })
    .bindToScrollable([this.scroller])
    .id('GrouoList_Contacts_BackPressed_NavDestination')
    .onShown(() => {
      // 页面显示时调用的方法
      this.destinationPageShow();
      // 标题平移动画
      animateTo({ curve: Curves.interpolatingSpring(10, 1, 228, 30) }, () => {
        this.translateTitle = 0
      })
      // 标题透明度动画
      animateTo({ duration: 300, curve: Curve.Sharp }, () => {
        this.titleOpacity = 1
      })
    })
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .padding({
      top: this.isPC ?  0:px2vp(this.fullScreenPadding.top as number) ,
      bottom: px2vp(this.fullScreenPadding.bottom as number),
    })
  }


  private onBack() {
    // 调用presenter的backItemClick方法
    this.mPresenter.backItemClick();
    // 如果是小屏幕、智能窗口或垂直分屏状态
    if ((this.curBp === 'sm') || this.isShowSmartWindow ||
      AppStorage.get('splitStatus') === SplitStatus.VERTICAL_SPLIT) {
      this.pathInfos?.pop();
    } else {
      router.back();
    }
  }


  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.group')) },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }
}


@Component
export struct GroupEmptyPage {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link presenter: GroupListPresenter;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State mPresenter: GroupListPresenter = this.presenter;
  @Link aPresenter: ArrangeContactsPresenter;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  groupAccountId: String = '';
  // 创建群组参数
  createGroupParams: CustomizedParams = {
    ENC: 0,
    ISCREATE: 0
  };

  editDialog: CustomDialogController | null = null;
  newGroupAccountDialog: CustomDialogController | null = null;


  aboutToDisappear() {
    this.editDialog = null;
  }


  build() {

    Column() {
      // 注释掉的空页面组件
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_group'), // 空页面图标
      //   emptyDescription: $r('app.string.no_group'), // 空页面描述
      //   descriptionFontColor: this.isThemeActive ? ($r('app.color.skin_font_tertiary')) : undefined, // 描述文字颜色
      //   buttonName: $r('app.string.new_group'), // 按钮名称
      //   buttonEvent: () => {
      //     // 按钮点击事件
      //     if (this.aPresenter.accountList.length > 1) {
      //       // 多个账户时，打开账户选择对话框
      //       this.newGroupAccountDialog?.open();
      //       DialogControllerManager.getInstance().addDialogController(this.newGroupAccountDialog);
      //     } else {
      //       // 单个账户时，直接打开新建群组对话框
      //       this.editDialog?.open();
      //       DialogControllerManager.getInstance().addDialogController(this.editDialog);
      //     }
      //   },
      //   customBackgroundColor: $r('app.color.skin_background_primary'), // 自定义背景颜色
      //   fullPage: true, // 是否全屏
      //   buttonBackgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') :
      //   $r('sys.color.comp_background_tertiary') // 按钮背景颜色
      // })
    }
    .width('100%')
    .height('100%')
    .padding({ 
      top: EnvironmentProp.isPC() ? 0 : $r('app.float.id_hds_title_margin'),
      bottom: this.curBp === 'sm' ? 0 : $r('app.float.id_item_height_large')
    })
  }


  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: '',
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.createGroupParams.ISCREATE = 0;
          DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
          this.editDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          if (value.trim().length == 0) {
            return;
          } else {
            // 设置创建群组参数为确认状态
            this.createGroupParams.ISCREATE = 1;
            // 打点记录确认创建群组事件
            DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
            HiLog.w(TAG, 'AlertDialog saveGroup');
            
            // 如果只有一个账户，设置默认账户ID为1
            if (this.aPresenter.accountList.length == 1) {
              this.groupAccountId = '1';
            }
            
            // 调用presenter的addGroup方法创建群组
            this.presenter.addGroup(value, this.groupAccountId);
            // 关闭编辑对话框
            this.editDialog?.close();
            // 清除对话框控制器
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      })
    }
    .width('100%')
  }


  @Builder
  NewGroupAccountDialog() {
    Column() {
      NewGroupAccountDialog({
        itemList: this.aPresenter.accountList,
        onItemClick: (value) => {
          this.groupAccountId = value[0]
          AppStorage.setOrCreate('groupAccountName', value[1]);
          this.newGroupAccountDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.editDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.editDialog);
        }
      })
    }
    .width('100%')
  }
}



@Component
struct GroupContent {
  @Link presenter: GroupListPresenter;
  @Link intelligenceGroupPresenter: IntelligenceGroupListPresenter;
  @State intelligenceGroupNameList: string[] = ['origanization', 'city', 'latestcontact'];
  @State mPresenter: GroupListPresenter = this.presenter;
  @State otherIntelligenceGroupPresenter: IntelligenceGroupListPresenter = this.intelligenceGroupPresenter;
  @Link aPresenter: ArrangeContactsPresenter;
  groupAccountName: String | undefined = AppStorage.Get('groupAccountName')
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  private isPC: boolean = EnvironmentProp.isPC();
  editDialog: CustomDialogController | null = null;
  newGroupAccountDialog: CustomDialogController | null = null;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  private scroller: Scroller = new Scroller();

  build() {

    Stack({ alignContent: Alignment.BottomEnd }) {

      Column() {

        GridRow({ 
          columns: { sm: 4, md: 8, lg: 12 },
          gutter: { x: 12, y: 0 }
        }) {

          GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {

            List({ scroller: this.scroller }) {

              if (this.isPC) {
                // PC端子标题
                PCSubTitle({ subtitle: $r('app.string.intelligence_group') })
              } else {
                // 智能群组标题
                SubHeader({
                  secondaryTitle: $r('app.string.intelligence_group'),
                  secondaryTitleModifier: this.isThemeActive ?
                  new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
                })
                  .margin({ left: this.curBp === 'lg' ? '8vp' : 0 })
              }


              ListItemGroup({ style: ListItemGroupStyle.CARD }) {

                ForEach(this.intelligenceGroupNameList, (item: string, index: number) => {
                  ListItem() {
                    // 弹性布局
                    Flex({
                      direction: FlexDirection.Column,
                      justifyContent: FlexAlign.Center,
                      alignItems: ItemAlign.Start
                    }) {
                      // 智能群组列表项组件
                      IntelligenceGroupListItem({
                        item: item, // 智能群组名称
                        type: index, // 智能群组类型索引
                        intelligenceGroupPresenter: $intelligenceGroupPresenter // 智能群组列表presenter引用
                      })
                        .id('IntelligenceGrouoList_Contacts_LongPressGesture_GroupListItem')
                    }
                    .backgroundColor(Color.Transparent)
                    .width('100%')
                  }
                  .backgroundColor(Color.Transparent)
                })
              }

              .borderRadius(this.isPC ? '16vp' : $r('sys.float.corner_radius_level10'))
              .margin({
                left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
                right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right')
              })
              .backgroundColor(this.isPC ? $r('sys.color.comp_background_list_card') :
              $r('app.color.skin_comp_background_list_card'))
              .divider({
                strokeWidth: '1px',
                startMargin: '8vp',
                endMargin: '8vp',
                color: $r('app.color.skin_ohos_id_color_list_separator'),
              })
              .width('100%')


              if (this.presenter.groupCount > 0) {
                ForEach(this.aPresenter.accountList, (item1: AccountVo, index?: number) => {
                  if (this.isPC) {
                    PCSubTitle({ subtitle: $r('app.string.computer') })
                  } else {
                    SubHeader({
                      secondaryTitle: (this.curBp === 'lg' && !this.isInVisionGlass) ? $r('app.string.tablet') :
                      $r('app.string.telep_group'),
                      secondaryTitleModifier: this.isThemeActive ?
                      new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
                    })
                      .margin({ left: this.curBp === 'lg' ? '8vp' : 0 })
                  }

                  ListItemGroup({ style: ListItemGroupStyle.CARD }) {
                    LazyForEach(this.presenter.groupListDataSource, (item: GroupInfo) => {
                      ListItem() {
                        Flex({
                          direction: FlexDirection.Column,
                          justifyContent: FlexAlign.Center,
                          alignItems: ItemAlign.Start
                        }) {
                          if (item1.accountId == item.group.accountId) {
                            GroupListItem({ item: item, mPresenter: $mPresenter })
                              .id('GrouoList_Contacts_LongPressGesture_GroupListItem')
                          }
                        }
                        .backgroundColor(Color.Transparent)
                        .width('100%')
                      }
                      .backgroundColor(Color.Transparent)
                    }, (item: GroupInfo) => JSON.stringify(item))
                  }
                  .borderRadius(this.isPC ? '16vp' : $r('sys.float.corner_radius_level10'))
                   .margin({
                    left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
                    right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right'),
                    bottom: $r('app.float.id_card_margin_xxl')
	                })
                  .backgroundColor(this.isPC ? $r('sys.color.comp_background_list_card') :
                  $r('app.color.skin_comp_background_list_card'))
                  .divider({
                    strokeWidth: '1px',
                    startMargin: '8vp',
                    endMargin: '8vp',
                    color: $r('app.color.skin_ohos_id_color_list_separator'),
                  })
                  .width('100%')
                })
              }
            }
            .scrollBar(BarState.Off)
            .editMode(true)
            .width('100%')
            .height('100%')
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .clipContent(ContentClipMode.SAFE_AREA)
            // .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
          }
        }
        .height('100%')
        .flexShrink(1)

        GridRow({ columns: { sm: 4, md: 8, lg: 8 }, gutter: { x: 12, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 8, lg: 6 }, offset: { sm: 0, md: 0, lg: 1 } }) {
            if (!this.isPC) {
              bottomContent({
                presenter: $mPresenter,
                aPresenter: $aPresenter,
                editDialog: this.editDialog,
                newGroupAccountDialog: this.newGroupAccountDialog
              })
            }
          }
        }
        .margin({
          top: this.isPC ? 0 : '2vp',
          left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
          right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right')
        })
      }
      .padding({

        bottom: this.splitStatus === SplitStatus.VERTICAL_SPLIT || !this.isPC ?
          $r('app.float.id_item_height_large'):0
      })
      .height('100%')
      .width('100%')
    }
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
    .height('100%')
    .width('100%')
  }

  // 分组列表
  @Builder
  groupListBuilder(item1: AccountVo, item: GroupInfo) {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start
    }) {
      if (item1.accountId == item.group.accountId) {
        GroupListItem({ item: item, mPresenter: $mPresenter })
          .id('GrouoList_Contacts_LongPressGesture_GroupListItem');
      }
    }
    .width('100%')
  }
}

@Component
struct bottomContent {
  @Link presenter: GroupListPresenter;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link aPresenter: ArrangeContactsPresenter;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  groupAccountId: String = '';
  createGroupParams: CustomizedParams = {
    ENC: 1,
    ISCREATE: 0
  };
  customParams: CustomizedParams = {};
  editDialog: CustomDialogController | null = null;
  newGroupAccountDialog: CustomDialogController | null = null;
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(48))
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .padding(LengthMetrics.vp(0));

  aboutToAppear() {
    this.toolbarList = new ToolBarOptions()
    this.toolbarList.push({
      content: $r('app.string.new_group'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.plus')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      action: () => {
        if (this.aPresenter.accountList.length > 1) {
          this.newGroupAccountDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.newGroupAccountDialog);
        } else {
          this.editDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.editDialog);
        }
      }
    })
    this.toolbarList.push({
      content: $r('app.string.dialog_delete'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      action: () => {
        DotUtil.getInstance().contactDot(this.customParams, GROUP_CLICK_DELETE_EVENT);
        this.presenter.toBatchDeleteGroup()
      }
    })
  }

  aboutToDisappear() {
    this.editDialog = null;
  }

  build() {
    WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
      ToolBar({
        toolBarList: this.toolbarList,
        dividerModifier: new DividerModifier().height(0),
        toolBarModifier: this.toolBarModifier
      }).height($r('app.float.id_item_height_mid'))
    }
  }

  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: '',
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.createGroupParams.ISCREATE = 0;
          DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
          this.editDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          if (value.trim().length == 0) {
            return;
          } else {
            this.createGroupParams.ISCREATE = 1;
            DotUtil.getInstance().contactDot(this.createGroupParams, CREATE_GROUP_EVENT);
            if (this.presenter.ifGroupExist(value)) {
              promptAction.showToast({
                message: $r('app.string.group_existed'),
                duration: 2000,
              });
              return;
            } else {
              HiLog.w(TAG, 'AlertDialog CreateGroup');
              if (this.aPresenter.accountList.length == 1) {
                this.groupAccountId = '1';
              }
              this.presenter.addGroup(value, this.groupAccountId);
            }
            this.editDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      })
    }
    .width('100%')
  }

  @Builder
  NewGroupAccountDialog() {
    Column() {
      NewGroupAccountDialog({
        itemList: this.aPresenter.accountList,
        onItemClick: (value) => {
          this.groupAccountId = value[0];
          AppStorage.setOrCreate('groupAccountName', value[1]);
          this.newGroupAccountDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.editDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.editDialog);
        }
      })
    }
    .width('100%')
  }
}
