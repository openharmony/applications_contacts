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
import GroupListDetailPresenter, { UpdateGroupDetailInfo } from '../../presenter/group/GroupListDetailPresenter';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import GroupListPresenter from '../../presenter/group/GroupListPresenter';
import promptAction from '@ohos.promptAction';
import { CustomizedParams, GroupParams } from '../../model/type';
import { GroupMemberListBean } from '../../model/bean/GroupMemberListBean';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import DotUtil from '../../util/DotUtil';
import call from '@ohos.telephony.call';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomTextInputContent from '../dialog/CustomTextInputContent';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { ComponentContent, LengthMetrics, SubHeader, ToolBar, ToolBarModifier, ToolBarOptions } from '@kit.ArkUI';
import { DividerModifier, SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { VibrationEffect } from '../../model/type/EnumUtil';
import VibrationUtils from '../../util/VibrationUtils';
import { FontScaleState } from '../../util/fontScaleState';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { i18n } from '@kit.LocalizationKit';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { ResourceUtil } from '../../util/ResourceUtil';

const TAG = 'GroupListDetail';
const CLICK_GROUP_CONTACT_EVENT = 'CLICK_GROUP_CONTACT_EVENT';
const GROUP_CLICK_MORE_EVENT = 'GROUP_CLICK_MORE_EVENT';
const GROUP_MORE_EVENT = 'GROUP_MORE_EVENT';
const CREATE_GROUP_EVENT = 'CREATE_GROUP_EVENT';
const GROUP_SEND_MESSAGE_EVENT = 'GROUP_SEND_MESSAGE_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

interface ParamsInterface {
  isThemeActive: boolean,
  removeMember: Function,
  deletingGroup: Function,
  rename: Function,
}

@Builder
export function GroupListDetailLoader($$: Params): void {
  GroupListDetail();
}

/**
 * Group List Detail
 */
@Component
export default struct GroupListDetail {
  @State groupListDetailPresenter: GroupListDetailPresenter = new GroupListDetailPresenter();
  groupListPresenter: GroupListPresenter = GroupListPresenter.getInstance();
  @State mPresenter: GroupListPresenter = GroupListPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 成员数量
  @State groupMemberListLen: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 路径信息
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('contactCount') @Watch('updateGroupListDetail') contactCount: number = -1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @State isMore: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  scroller: Scroller = new Scroller();
  groupMoreParams: CustomizedParams = {
    ITEM: 0
  };
  // 群组查询结束标记位
  @State isFinish: boolean = false;
  // 群组查询结束回调
  @State updateGroupDetailInfo: UpdateGroupDetailInfo = {
    updateGroupDetail: (): void => {
      this.isFinish = true;
    }
  };

  updateGroupListDetail() {
    HiLog.w(TAG, `refresh contactCount: ${this.contactCount}`);
    this.groupMemberListLen = this.contactCount;
    this.groupListDetailPresenter.groupListDataSource = this.mPresenter.groupListDataSource;
    this.groupListDetailPresenter.aboutToAppear();
  }

  destinationPageShow() {
    HiLog.w(TAG, 'destinationPageShow');
    this.groupListDetailPresenter.setPageShow();//
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    this.mPresenter.initNavPaths(this.pathInfos);
    this.groupListDetailPresenter.initNavPaths(this.pathInfos);
    this.groupListDetailPresenter.groupListDataSource = this.mPresenter.groupListDataSource;
    this.groupListDetailPresenter.updateGroupDetailInfoCallBack = this.updateGroupDetailInfo;
    this.groupListDetailPresenter.aboutToAppear();
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.groupListDetailPresenter.resetData()
    this.groupListPresenter.refreshGroup()
  }

  fixGroupNameDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.rename'),
      contentBuilder: () => {
        this.TextInputBuilder();
      },
      contentAreaPadding: { left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') :
    $r('app.color.skin_comp_background_primary'),
    backgroundBlurStyle: this.isPC ? BlurStyle.COMPONENT_ULTRA_THICK :
      this.isThemeActive ? BlurStyle.NONE : undefined,
    shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_MD : undefined
  });

  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.delete_group'),
      contentBuilder: () => {
        this.DeleteDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.deleteDialogController.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        },
        {
          value: $r('app.string.dialog_delete'),
          action: () => {
            HiLog.w(TAG, 'confirm start')
            this.groupListDetailPresenter.removeGroup(this.groupListDetailPresenter.id)
            this.groupListDetailPresenter.removeMember(this.groupListDetailPresenter.id)
            this.groupListDetailPresenter.back()
            this.groupListDetailPresenter.aboutToAppear()
          },
          role: ButtonRole.ERROR
        }
      ]
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle:  this.isPC ? BlurStyle.COMPONENT_ULTRA_THICK :
      this.isThemeActive ? BlurStyle.NONE : undefined,
    closeAnimation: { duration: 100 },
    shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_MD : undefined
  });

  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: this.groupListDetailPresenter.groupItemInfo.groupName,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.fixGroupNameDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          if (value.trim().length == 0) {
            return;
          } else {
            if (value == this.groupListDetailPresenter.groupItemInfo.groupName) {
              this.fixGroupNameDialog?.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              return;
            }
            if (this.groupListDetailPresenter.ifGroupExist(value)) {
              promptAction.showToast({
                message: $r('app.string.group_existed'),
                duration: 2000
              });
              return
            } else {
              HiLog.w(TAG, 'AlertDialog saveGroupName');
              let params: GroupParams = {
                id: this.groupListDetailPresenter.id,
                groupName: value,
              }
              this.groupListDetailPresenter.renameGroup(params)
            }
            this.fixGroupNameDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      })
    }
    .width('100%')
  }

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

  @Builder
  MyMenu() {
    Column() {
      Menu() {
        MenuItem({ content: $r('app.string.remove_member') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择移除成员
          this.groupMoreParams.ITEM = 0;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.groupListDetailPresenter.toRemoveMember()
        })
          .height($r('app.float.id_item_height_sm'))
          .id('GrouoListDetail_MyMenu_removeMember_MenuItem')

        MenuItem({ content: $r('app.string.deleting_group') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择移除成员
          this.groupMoreParams.ITEM = 1;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.deleteDialogController.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
        })
          .id('GrouoListDetail_MyMenu_deletingGroup_MenuItem')
          .height($r('app.float.id_item_height_sm'))
          .margin({ top: LengthMetrics.resource($r('sys.float.padding_level1')) })

        MenuItem({ content: $r('app.string.rename') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择重命名
          this.groupMoreParams.ITEM = 2;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.fixGroupNameDialog.open();
          DialogControllerManager.getInstance().addDialogController(this.fixGroupNameDialog);
        })
          .id('GrouoListDetail_MyMenu_rename_MenuItem')
          .height( $r('app.float.id_item_height_sm'))
          .margin({ top: LengthMetrics.resource($r('sys.float.padding_level1')) })
      }
      .width($r('app.float.account_MenuBuilder_width_xl'))
      .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
    }.onDisAppear(() => {
      this.isMore = false
    })
  }

  @Builder
  PCMenu() {
    if (this.groupListDetailPresenter.groupMemberListLen != 0) {
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.add_member')))
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
          HiLog.i(TAG, 'AlertDialog addMem23ber')
          this.groupListDetailPresenter.toAddMember();
        })

        Button() {
          SymbolGlyph($r('sys.symbol.envelope'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.send_email')))
        .type(ButtonType.Normal)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor( Color.Transparent)
        .enabled(false)
        .margin({
          end: LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .onClick(() => {
          // ToDo
        })

        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.more')))
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(Color.Transparent)
        .margin({
          end: LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .onClick(() => {
          this.isMore = true;
        })
        .bindMenu(this.isMore, this.MyMenu, {
          placement: Placement.Bottom,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
        })
      }
      .height($r('app.float.id_item_height_large'))
      .width('180vp')
      .alignItems(VerticalAlign.Center)
      .padding({ end: LengthMetrics.vp(280) })
    } else {
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.add_member')))
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
          // 联系人打点--进入某群组点击更多-选择添加成员
          this.groupListDetailPresenter.toAddMember()
        })

        Button() {
          SymbolGlyph($r('sys.symbol.rename'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.rename')))
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
          this.fixGroupNameDialog.open()
          DialogControllerManager.getInstance().addDialogController(this.fixGroupNameDialog);
        })

        Button() {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.deleting_group')))
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
          this.deleteDialogController.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
        })
      }
      .height($r('app.float.id_item_height_large'))
      .width('240vp')
      .alignItems(VerticalAlign.Center)
      .padding({ end: LengthMetrics.vp(332) })
    }
  }

  build() {
    if (this.isPC) {
      NavDestination() {
        this.groupListDetailBuilder()
      }
      .title(this.groupListDetailPresenter.groupName, {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: LengthMetrics.vp(8)
      })
      .id('GrouoListDetail_Navi_onBackPressed_NavDestination')
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .onBackPressed(() => {
        this.groupListDetailPresenter.back();
        return true;
      })
      .menus(this.PCMenu())
      .onShown(() => {
        this.destinationPageShow();
      })
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    } else {
      NavDestination() {
        this.groupListDetailBuilder()//其他群组详情页
      }
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.onBack();
      // }))
      .title(this.groupListDetailPresenter.groupName)
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .onBackPressed(() => {
        this.groupListDetailPresenter.back();
        return true;
      })
      .bindToScrollable([this.scroller])
      .id('GrouoListDetail_Navi_onBackPressed_NavDestination')
      .onShown(() => {
        this.destinationPageShow();
      })
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .backgroundColor($r('app.color.skin_background_primary'))
      .padding({
        top:this.isPC? 0:px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    }
  }


  @Builder
  groupListDetailBuilder() {
    Column() {
      Column() {
        if (this.groupListDetailPresenter.groupMemberListLen === 0 && this.isFinish) {
          ContactEmptyPage();
        } else if (this.groupListDetailPresenter.groupMemberListLen > 0 && this.isFinish) {
          DetailContent({ presenter: $groupListDetailPresenter, scroller: this.scroller });
        }
      }
      .layoutWeight(1)
      .flexShrink(1);

      if (!this.isPC) {
        BottomContent({
          presenter: $groupListDetailPresenter,
          fixGroupNameDialog: this.fixGroupNameDialog,
          deleteDialogController: this.deleteDialogController
        })
          .flexShrink(0);
      }
    }
    .flexShrink(1)
    .width('100%')
    .height('100%')
  }

  private onBack() {
    this.groupListDetailPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: this.groupListDetailPresenter.groupName },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }
}

@Component
struct DetailContent {
  @State longPressIndex: number = -1;
  @State isMenuShown: boolean = false;
  @State isPressed: boolean = false;
  @Link private presenter: GroupListDetailPresenter;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  nameTitle: string = ContactsGlobalThisHelper.GetGlobalThis()
    .getDefaultUIContext()
    .resourceManager
    .getStringSync($r('app.string.noName').id);
  viewContactDetailParams: CustomizedParams = {
    LEVELONE: 3,
    LEVELTWO: -1,
    ISSAVE: 1,
  };
  customParams: CustomizedParams = {};
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  // Menu Divider
  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
  }

  @Builder
  MenuPreview(item: GroupMemberListBean) {
    Scroll() {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        ContactPhotoView({
          item: item
        })

        Text(item.member.member.title !== '' ? item.member.member.title : this.nameTitle)
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .margin({
            start: LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
          })
          .flexShrink(1)
          .flexGrow(1)
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
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
    .width(DisplaySplitUtil.isHorizonSplit(this.splitStatus) && deviceInfo.deviceType == 'tablet' ? '40%' : '100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
  }

  @Builder
  MenuBuilder(item: GroupMemberListBean) {
    Menu() {
      MenuItem({ content: $r('app.string.remove_from_group') })
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactListView_Contacts_delete_MenuItem')
        .onClick(() => {
          //从群组移除
          if (typeof item.member.member.contactId === 'string' && item.member.member.contactId !== '') {
            this.presenter.removeMemberByContactId(Number(item.member.member.contactId))
          } else {
            HiLog.e(TAG, 'contactId is null or contactId !== string ')
          }
          this.longPressIndex = -1;
        })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
  }

  build() {
    GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        List({ scroller: this.scroller}) {
          SubHeader({
            secondaryTitle: this.isPC ?
              ResourceUtil.getPluralStringByResource($r('app.plural.people_number_from_computer'),
                this.presenter.groupMemberListLen) : this.curBp === 'lg'
                ? ResourceUtil.getPluralStringByResource($r('app.plural.people_number_from_tablet'),
                  this.presenter.groupMemberListLen)
                : ResourceUtil.getPluralStringByResource($r('app.plural.people_number_from_phone'),
                  this.presenter.groupMemberListLen),
            secondaryTitleModifier: this.isThemeActive ?
              new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
          })
            .margin({
              start: this.isPC ? LengthMetrics.vp(-27.5) :
                this.curBp === 'lg' ? LengthMetrics.vp(-4) : LengthMetrics.resource($r('app.float.Dialog_bottom'))
            })
          ListItemGroup() {
            LazyForEach(this.presenter.groupMemberDataSource,
              (item: GroupMemberListBean, index: number) => {
                ListItem() {
                  Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                    ContactPhotoView({
                      item: item
                    })
                    Text(item.member.member.title !== '' ? item.member.member.title : this.nameTitle)
                      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
                      .margin({
                        start: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
                        LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
                        top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.dialer_button_text_font_size')),
                        bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.dialer_button_text_font_size')),
                      })
                      .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
                      .flexShrink(1)
                      .flexGrow(1)
                  }
                  .constraintSize({ minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                    $r('app.float.id_item_height_max') })
                  .bindContextMenu(this.isMenuShown && this.longPressIndex === index, this.MenuBuilder(item), {
                    preview: this.MenuPreview(item),
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
                    offset: {
                      x: 0,
                      y: $r('sys.float.padding_level4')
                    },
                    onDisappear: () => {
                      this.longPressIndex = -1;
                      this.isMenuShown = false;
                    },
                    placement: Placement.BottomLeft,
                  })
                  .onTouch((event: TouchEvent) => {
                    switch (event.type) {
                      case TouchType.Down:
                        this.isPressed = true;
                        break;
                      case TouchType.Up:
                      case TouchType.Cancel:
                        this.isPressed = false;
                        break;
                    }
                  })
                  .onMouse((event: MouseEvent) => {
                    if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
                      this.longPressIndex = index;
                      VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                    }
                  })
                  .gesture(LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
                    .onAction((event: GestureEvent) => {
                      this.longPressIndex = index;
                      VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                      this.isMenuShown = true
                    })
                  )
                  .onClick(() => {
                    // 联系人打点-进入某群组点击某联系人
                    DotUtil.getInstance().contactDot(this.customParams, CLICK_GROUP_CONTACT_EVENT);
                    let params: Record<string, boolean | string> = {
                      'sourceHasId': true,
                      'contactId': item.member.member.contactId,
                      'pageTag': 'groupListDetail'
                    }
                    DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
                      this.pathInfos.pushPathByName('ContactDetail', params);
                    });
                  })
                }
                .padding({
                  left: this.spaceLR,
                  right: this.spaceLR,
                })
                .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
                .stateStyles({
                  pressed: this.pressedStyles,
                })
                .id('GrouoListDetail_ListItemGroup_groupListDetail_ListItem')
                .focusBox({ margin: this.isPC ? LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) :
                  LengthMetrics.vp(0)})
              }, (item: GroupMemberListBean) => JSON.stringify(item))
          }.divider({
            strokeWidth: '1px',
            color: $r('app.color.skin_ohos_id_color_list_separator'),
            startMargin: this.curBp === 'lg' ? 80 : $r('app.float.account_listItem_text_common_width'),
            endMargin: this.spaceLR
          })
          .margin({ bottom: $r('app.float.id_card_margin_xxl') })

        }
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .editMode(true)
        .width('100%')
        .height('100%')
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: this.isPC ? 0 : $r('app.float.id_hds_title_margin') })
        .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
      }
    }
    .height('100%')
    .flexShrink(1)
  }
}

@Component
struct ContactEmptyPage {
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Column() {
      Image($r('app.media.ic_empty_page_no_contacts'))
        .width(120)
        .height(120)
      Text($r('app.string.no_contacts'))
        .fontSize(16)
        .fontColor($r('app.color.skin_font_tertiary'))
        .margin({ top: 16 })
    }
    .padding({ top: EnvironmentProp.isPC() ? 0 : $r('app.float.id_hds_title_margin') })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
struct BottomContent {
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link @Watch('refresh') private presenter: GroupListDetailPresenter;
  customParams: CustomizedParams = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  groupMoreParams: CustomizedParams = {
    ITEM: 0
  };
  @State isMore: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  fixGroupNameDialog: CustomDialogController | null = null;
  deleteDialogController: CustomDialogController | null = null;
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier()
      .height(LengthMetrics.vp(48))
      .backgroundColor(Color.Transparent)
      .padding(LengthMetrics.vp(18))
      .stateEffect(true);

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ left: $r('sys.float.padding_level7'), right: $r('sys.float.padding_level7') })
  }

  getMoreStackMenuWidth(): string | Resource {
    if (this.curBp !== 'sm') {
      return '39%';
    }
    const enumFontSizeScale: Record<number, string | Resource> = {
      0: $r('app.float.account_MenuBuilder_width_xl'),
      3: '45%',
      4: '50%',
      5: '55%',
      6: '60%',
    }
    if (enumFontSizeScale[this.fontSizeScale]) {
      return enumFontSizeScale[this.fontSizeScale];
    }
    return '39%';
  }

  @Builder
  MyMenu() {
    Column() {
      Menu() {
        MenuItem({ content: $r('app.string.remove_member') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择移除成员
          this.groupMoreParams.ITEM = 0;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.presenter.toRemoveMember()
        })
          .id('GrouoListDetail_MyMenu_removeMember_MenuItem')

        this.MenuDivider()

        this.MenuDivider()

        MenuItem({ content: $r('app.string.deleting_group') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择移除成员
          this.groupMoreParams.ITEM = 1;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.deleteDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
        })
          .id('GrouoListDetail_MyMenu_deletingGroup_MenuItem')

        this.MenuDivider()

        MenuItem({ content: $r('app.string.rename') }).onClick(() => {
          // 联系人打点--进入某群组点击更多-选择重命名
          this.groupMoreParams.ITEM = 2;
          DotUtil.getInstance().contactDot(this.groupMoreParams, GROUP_MORE_EVENT);
          this.fixGroupNameDialog?.open();
          DialogControllerManager.getInstance().addDialogController(this.fixGroupNameDialog);
        })
          .id('GrouoListDetail_MyMenu_rename_MenuItem')
      }
      .width(this.getMoreStackMenuWidth())
      .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
    }.onDisAppear(() => {
      this.isMore = false
    })
  }

  @State toolbarList: ToolBarOptions = new ToolBarOptions();

  refresh() {
    this.toolbarList = new ToolBarOptions();
    if (this.presenter.groupMemberListLen != 0) {
      this.toolbarList.push({
        content: $r('app.string.add_member'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.plus')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          this.presenter.toAddMember()
        }
      })
      if (call.hasVoiceCapability()) {
        this.toolbarList.push({
          content: $r('app.string.send_information'),
          toolBarSymbolOptions: {
            normal: new SymbolGlyphModifier($r('sys.symbol.message')).fontColor([$r('app.color.skin_icon_primary')]),
          },
          action: () => {
            // 联系人打点-手机群组-发送信息
            DotUtil.getInstance().contactDot(this.customParams, GROUP_SEND_MESSAGE_EVENT);
            this.presenter.toSendMessage()
          }
        })
      }

      this.toolbarList.push({
        content: $r('app.string.send_email'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.envelope')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          // TODO 补充打点 手机群组-发送邮件
        },
        state: 2
      })
      //更多
      this.toolbarList.push({
        content: $r('app.string.more'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.dot_grid_2x2')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          // 手机群组-进入某群组-点击更多
          DotUtil.getInstance().contactDot(this.customParams, GROUP_CLICK_MORE_EVENT);
          this.isMore = true;
        }
      })
    } else {
      this.toolbarList.push({
        content: $r('app.string.add_member'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.plus')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          this.presenter.toAddMember()
        }
      })
      this.toolbarList.push({
        content: $r('app.string.rename'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.rename')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          this.fixGroupNameDialog?.open()
          DialogControllerManager.getInstance().addDialogController(this.fixGroupNameDialog);
        }
      })
      this.toolbarList.push({
        content: $r('app.string.deleting_group'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          this.deleteDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
        }
      })
    }
  }
  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        ToolBar({
          toolBarList: this.toolbarList,
          dividerModifier: new DividerModifier().height(0),
          toolBarModifier: this.toolBarModifier
        }).height($r('app.float.id_item_height_mid')).margin({ left: -8, right: -8 })
          .bindMenu(this.isMore, this.MyMenu, {
            placement: this.isPC ? Placement.TopRight : Placement.BottomRight,
            backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
            backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
          })
      }
    }
  }

  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: this.presenter.groupItemInfo.groupName,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.fixGroupNameDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          if (value.trim().length == 0) {
            return;
          } else {
            if (value == this.presenter.groupItemInfo.groupName) {
              this.fixGroupNameDialog?.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              return;
            }
            if (this.presenter.ifGroupExist(value)) {
              promptAction.showToast({
                message: $r('app.string.group_existed'),
                duration: 2000
              });
              return
            } else {
              HiLog.w(TAG, 'AlertDialog saveGroupName');
              let params: GroupParams = {
                id: this.presenter.id,
                groupName: value,
              }
              this.presenter.renameGroup(params)
            }
            this.fixGroupNameDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      })
    }
    .width('100%')
  }

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
export struct ContactPhotoView {
  @Prop item: GroupMemberListBean;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('contactListUpdated') @Watch('updatePixelMap') contactListUpdated: number = 0;

  aboutToAppear() {
    getPixelMapFromFile(this.item.member.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  updatePixelMap() {
    getPixelMapFromFile(this.item.member.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  build() {
    Row() {
      if (this.photoPixelMap) {
        Image(this.photoPixelMap)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_s'))
          .draggable(false)
      } else if (StringUtil.isEmpty(this.item.member.member.headChar)) {
        Image(StringUtil.isEmpty(this.item.member.member.portraitPath) ?
        $r('app.media.ic_user_portrait') : this.item.member.member.portraitPath
        )
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Contain)
          .borderRadius($r('app.float.id_card_image_s'))
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor(
            StringUtil.isEmpty(this.item.member.member.portraitPath) ?
            $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
          )
          .draggable(false)
      } else {
        Text(this.item.member.member.headChar)
          .fontSize('16vp')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.skin_font_on_primary'))
          .backgroundColor($r('app.color.skin_icon_fourth'))
          .height($r('app.float.id_card_image_mid'))
          .width($r('app.float.id_card_image_mid'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_image_s'))
          .accessibilityLevel('no')
      }
    }
    .height($r('app.float.id_card_image_mid'))
    .width($r('app.float.id_card_image_mid'))
    .flexShrink(0)
  }
}

@Builder
function menuHdsBuilder(params: ParamsInterface) {
  Column() {
    Menu() {
      MenuItem({ content: $r('app.string.remove_member') }).onClick(() => {
        params.removeMember();
      })
        .height($r('app.float.id_item_height_sm'))
        .id('GrouoListDetail_MyMenu_removeMember_MenuItem')

      MenuItem({ content: $r('app.string.group_ringtone') }).enabled(false)
        .height($r('app.float.id_item_height_sm'))
        .margin({ top: LengthMetrics.resource($r('sys.float.padding_level1')) })

      MenuItem({ content: $r('app.string.deleting_group') }).onClick(() => {
        params.deletingGroup();
      })
        .id('GrouoListDetail_MyMenu_deletingGroup_MenuItem')
        .height($r('app.float.id_item_height_sm'))
        .margin({ top: LengthMetrics.resource($r('sys.float.padding_level1')) })

      MenuItem({ content: $r('app.string.rename') }).onClick(() => {
        params.rename();
      })
        .id('GrouoListDetail_MyMenu_rename_MenuItem')
        .height( $r('app.float.id_item_height_sm'))
        .margin({ top: LengthMetrics.resource($r('sys.float.padding_level1')) })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .fontColor(params.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
  }
}