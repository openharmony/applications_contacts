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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import BatchDeleteGroupPresenter from '../../presenter/group/BatchDeleteGroupPresenter';
import GroupListPresenter from '../../presenter/group/GroupListPresenter';
import { GroupInfo } from '../../model/bean/GroupBean';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../util/ResourceUtil';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { FontScaleState } from '../../util/fontScaleState';
import { ItemState,
  LengthMetrics,
  SubHeader, SymbolGlyphModifier, TextModifier, ToolBar, ToolBarOptions } from '@kit.ArkUI';
import { DividerModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { PCSubTitle } from '../../component/contact/SubHeader';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'BatchDeleteGroup ';
const DELETE_GROUP_EVENT = 'DELETE_GROUP_EVENT';
const GROUP_DELETE_DIALOG_EVENT = 'GROUP_DELETE_DIALOG_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function BatchDeleteGroupLoader($$: Params): void {
  BatchDeleteGroup();
}

@Component
export default struct BatchDeleteGroup {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State @Watch('updateToolbarList') batchDeleteGroupPresenter: BatchDeleteGroupPresenter = BatchDeleteGroupPresenter.getInstance();
  @State mPresenter: GroupListPresenter = GroupListPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  //toolbar 数据
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  private scroller: Scroller = new Scroller();
  // 删除群组按钮、删除群组弹窗参数
  deleteGroupParams: CustomizedParams = {
    NUM: 0,
    ISDELETE: 0
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    this.updateToolbarList();
    this.mPresenter.initNavPaths(this.pathInfos);
    this.batchDeleteGroupPresenter.initNavPaths(this.pathInfos);
    this.batchDeleteGroupPresenter.groupListDataSource = this.mPresenter.groupListDataSource;
    this.batchDeleteGroupPresenter.initGroupData();
    this.batchDeleteGroupPresenter.resetData();
  }

  updateToolbarList() {
    HiLog.w(TAG, 'updateToolbarList');
    this.toolbarList = [];
    this.toolbarList.push({
      content: $r('app.string.delete'),
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('app.color.skin_icon_primary')]),
      },
      state: this.batchDeleteGroupPresenter.selectedCount > 0 ? ItemState.ENABLE : ItemState.DISABLE,
      action: () => {
        this.deleteGroupAction();
      },
    })
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.batchDeleteGroupPresenter.resetData();
  }

  deleteGroupAction() {
    // 联系人打点--手机群组点击删除群组
    if (this.batchDeleteGroupPresenter.selectedCount === this.batchDeleteGroupPresenter.groupList.length) {
      this.deleteGroupParams.NUM = 2;
    } else if (this.batchDeleteGroupPresenter.selectedCount > 1) {
      this.deleteGroupParams.NUM = 1;
    } else if (this.batchDeleteGroupPresenter.selectedCount === 1) {
      this.deleteGroupParams.NUM = 0;
    } else {
      this.deleteGroupParams.NUM = -1;
    }
    this.deleteGroupParams.ISDELETE = 1;
    DotUtil.getInstance().contactDot(this.deleteGroupParams, DELETE_GROUP_EVENT);
    this.deleteDialogController.open();
    DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
  }

  // DeleteDialog
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.batchDeleteGroupPresenter.getDeleteDialogTitle(),
      contentBuilder: () => {
        this.DeleteDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            // 联系人打点--手机群组取消删除群组
            if (this.batchDeleteGroupPresenter.selectedCount === this.batchDeleteGroupPresenter.groupList.length) {
              this.deleteGroupParams.NUM = 2;
            } else if (this.batchDeleteGroupPresenter.selectedCount > 1) {
              this.deleteGroupParams.NUM = 1;
            } else if (this.batchDeleteGroupPresenter.selectedCount === 1) {
              this.deleteGroupParams.NUM = 0;
            } else {
              this.deleteGroupParams.NUM = -1;
            }
            this.deleteGroupParams.ISDELETE = 0;
            DotUtil.getInstance().contactDot(this.deleteGroupParams, GROUP_DELETE_DIALOG_EVENT);
            this.deleteDialogController.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        },
        {
          value: $r('app.string.dialog_delete'),
          action: () => {
            // 联系人打点--手机群组删除群组
            if (this.batchDeleteGroupPresenter.selectedCount === this.batchDeleteGroupPresenter.groupList.length) {
              this.deleteGroupParams.NUM = 2;
            } else if (this.batchDeleteGroupPresenter.selectedCount > 1) {
              this.deleteGroupParams.NUM = 1;
            } else if (this.batchDeleteGroupPresenter.selectedCount === 1) {
              this.deleteGroupParams.NUM = 0;
            } else {
              this.deleteGroupParams.NUM = -1;
            }
            this.deleteGroupParams.ISDELETE = 1;
            DotUtil.getInstance().contactDot(this.deleteGroupParams, GROUP_DELETE_DIALOG_EVENT);
            this.batchDeleteGroupPresenter.deleteEvent();
          },
          role: ButtonRole.ERROR
        }
      ]
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isPC ? BlurStyle.COMPONENT_ULTRA_THICK :
      this.isThemeActive ? BlurStyle.NONE : undefined,
    shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_SM : undefined,
    closeAnimation: { duration: 100 }
  });

  // menuItem: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.delete'),
  //       icon: $r('sys.symbol.trash'),
  //       isEnabled: false,
  //     }
  //   }
  // ]
  //
  // menuEnable: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.delete'),
  //       icon: $r('sys.symbol.trash'),
  //       isEnabled: true,
  //       action: () => {
  //         this.deleteGroupAction();
  //       }
  //     }
  //   }
  // ]

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Start,
        }) {
          List({ scroller: this.scroller }) {
            ListItem() {
              if (this.isPC) {
                PCSubTitle({ subtitle: $r('app.string.tablet_group') })
              } else {
                SubHeader({
                  secondaryTitle: (this.curBp === 'lg' && !this.isInVisionGlass) ? $r('app.string.tablet_group') :
                  $r('app.string.telep_group'),
                  secondaryTitleModifier: this.isThemeActive ?
                  new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
                })
                  .margin({ left: this.isTabletLandscape ? '-4vp' : $r('app.float.Dialog_bottom'), })
              }
            }

            ListItemGroup() {
              LazyForEach(this.batchDeleteGroupPresenter.groupListDataSource,
                (item: GroupInfo, index?: number | undefined) => {
                  ListItem() {
                    GroupItem({
                      batchDeleteGroupPresenter: $batchDeleteGroupPresenter,
                      item: item,
                      index
                    });
                  }
                }, (item: GroupInfo) => JSON.stringify(item))
            }.divider({
              strokeWidth: 0.3,
              color: $r('app.color.skin_comp_divider'),
            })
            .padding({
              left: this.spaceLR,
              right: this.spaceLR
            })
            .margin({ bottom: $r('app.float.id_card_margin_xxl') })
          }
          .width('100%')
          .height('100%')
          .margin({ bottom: this.isPC ? 0 : $r('app.float.id_item_height_large') })
          .backgroundColor($r('app.color.skin_background_primary'))
          .listDirection(Axis.Vertical)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .scrollBar(BarState.Off)
        }

        if (!this.isPC) {
          WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
            ToolBar({
              activateIndex: this.batchDeleteGroupPresenter.selectedCount ===
              this.batchDeleteGroupPresenter.groupList.length ? 0 : -1,
              dividerModifier: new DividerModifier().height(0),
              toolBarList: this.toolbarList,
            })
              .width('100%')
              .height($r('app.float.id_toolbar_height'))
          }
        }

      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.skin_background_primary'))
    }
    .bindToScrollable([this.scroller])
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), this.isPC ?
    //   (this.batchDeleteGroupPresenter.selectedCount > 0 ? this.menuEnable : this.menuItem) : undefined, () => {
    //   this.onBack();
    // }))
    .title(this.batchDeleteGroupPresenter.selectedCount == 0
      ? ResourceUtil.getStringByResource($r('app.string.no_select'))
      : ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), this.batchDeleteGroupPresenter.selectedCount),
      {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : undefined,
        paddingEnd:this.isPC ? LengthMetrics.vp(149) : undefined
      })
    .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('app.color.skin_icon_primary')])
      :
      new SymbolGlyphModifier($r('sys.symbol.xmark')))
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
    .backgroundColor($r('app.color.skin_background_primary'))
    .padding({
      bottom: this.curBp !== 'sm' ? $r('sys.float.padding_level0') : 50,
      top: px2vp(this.fullScreenPadding.top as number)
    })
  }

  private onBack() {
    // 联系人打点--手机群组点击取消删除群组()
    if (this.batchDeleteGroupPresenter.selectedCount === this.batchDeleteGroupPresenter.groupList.length) {
      this.deleteGroupParams.NUM = 2;
    } else if (this.batchDeleteGroupPresenter.selectedCount > 1) {
      this.deleteGroupParams.NUM = 1;
    } else if (this.batchDeleteGroupPresenter.selectedCount === 1) {
      this.deleteGroupParams.NUM = 0;
    } else {
      this.deleteGroupParams.NUM = -1;
    }
    this.deleteGroupParams.ISDELETE = 0;
    DotUtil.getInstance().contactDot(this.deleteGroupParams, DELETE_GROUP_EVENT);
    this.batchDeleteGroupPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     enableComponentSafeArea: true,
  //     padding: {
  //       start: this.isPC ? LengthMetrics.vp(16) : undefined,
  //       end: this.isPC ? LengthMetrics.vp(149) : undefined
  //     },
  //     title: { title: '', isMultipleSelectState: true, selectedNumber: this.batchDeleteGroupPresenter.selectedCount },
  //     backIcon: { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }

  @Builder
  DeleteDialogBuilder() {
    Scroll() {
      Column() {
        Text($r('app.string.contacts_not_deleted'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .textAlign(this.isPC ? TextAlign.Center : TextAlign.Start)
          .fontColor($r('app.color.skin_font_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
    }
  }
}

@Component
struct GroupItem {
  @Link batchDeleteGroupPresenter: BatchDeleteGroupPresenter;
  @State item: GroupInfo = new GroupInfo();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  index?: number;

  build() {
    Flex({
      alignItems: ItemAlign.Center
    }) {
      Text(this.item.group.groupName)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
        .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)

      Blank();

      Checkbox({ name: this.item.group.id.toString() })
        .margin($r('app.float.id_card_margin_sm'))
        .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
        .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
        .select(this.item.checked as boolean)
        .selectedColor($r('app.color.skin_comp_background_emphasize'))
        .accessibilityLevel('no')
        .onChange((value: boolean) => {
          this.batchDeleteGroupPresenter.checkboxChanged(this.item.group.id, value, this.index as number);
        })
        .flexShrink(0)
    }
    .accessibilityChecked(this.item.checked)
    .accessibilityRole(AccessibilityRoleType.CHECKBOX)
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(
        this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(
        this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
    })
    .onClick(() => {
      this.item.checked = !this.item.checked;
    })
    .width('100%')
    .constraintSize({
      minHeight: $r('app.float.id_item_height_mid')
    })
  }
}