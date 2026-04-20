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
import GroupListPresenter from '../../presenter/group/GroupListPresenter';
import promptAction from '@ohos.promptAction';
import { GroupInfo } from '../../model/bean/GroupBean'
import { CustomizedParams, GroupParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CustomTextInputContent from '../../pages/dialog/CustomTextInputContent';
import { FontScaleState } from '../../util/fontScaleState';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { ColorMetrics, LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';

const TAG = 'GroupList-group';
const ENTER_GROUP_EVENT: string = 'ENTER_GROUP_EVENT';
// 长按时点击事件延时时间（ms），保证组件消失动效执行结束
const DIALOG_CONTROLLER_TIME_OUT: number = 300;

enum MenuType {
  Rename, DeleteGroupItem
}

/**
 * group
 */
@Component
export default struct GroupListItem {
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link mPresenter: GroupListPresenter;
  @Prop item: GroupInfo;
  customParams: CustomizedParams = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  createGroupParams: CustomizedParams = {};
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State isMenuShown: boolean = false;
  @State isItemHover: boolean = false;
  @State itemWidth: number = 0; // 长按菜单宽度
  private isPC: boolean = EnvironmentProp.isPC();

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear')
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width('100%')
      .margin({
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6')
      })
  }

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
            this.mPresenter.removeGroup(this.item.group.id);
            this.mPresenter.removeMember(this.item.group.id);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
          role: ButtonRole.ERROR
        }
      ]
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
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
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.rename') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('GrouoList_MenuView_renameClick_btn')
        .onClick(() => {
          setTimeout(() => {
            this.fixGroupNameDialog.open();
            DialogControllerManager.getInstance().addDialogController(this.fixGroupNameDialog);
          }, DIALOG_CONTROLLER_TIME_OUT)
        })
      this.MenuDivider()
      MenuItem({ content: $r('app.string.dialog_delete') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('GrouoList_MenuView_deleteClick_btn')
        .onClick(() => {
          setTimeout(() => {
            this.deleteDialogController.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
          }, DIALOG_CONTROLLER_TIME_OUT)
        })
    }.width($r('app.float.account_MenuBuilder_width_xl'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  build() {
    Row() {
      if (FontScaleState.isSmallerFourGeer(this.fontSizeScale)) {
          Text(this.item.group.groupName)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .constraintSize({ minHeight: this.isPC ? 22 : undefined })
            .textAlign(TextAlign.Start)
            .flexShrink(1)

          Row() {
            Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .lineHeight($r('app.float.id_groupList_lineHeight_xl'))
              .maxFontScale(1.75)
              .margin({
                left: $r('sys.float.padding_level8')
              })

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize($r('app.float.id_card_image_small'))
              .fontColor([$r('app.color.skin_icon_fourth')])
              .margin({
                left: $r('sys.float.padding_level2')
              })
          }
      } else {
        this.seniorLayout();
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? '40vp' : $r('app.float.id_item_height_mid')
    })
    .padding({
      top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      left: '8vp',
      right: '8vp'
    })
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
    })
    .id('GrouoList_MenuView_toGroupListDetail_Flex')
    .onClick(() => {
      // 联系人打点--手机群组点击进入某群组
      DotUtil.getInstance().contactDot(this.customParams, ENTER_GROUP_EVENT);
      this.mPresenter.toGroupListDetail(this.item.group.groupName)
    })
    .width('100%')
    .focusBox({
      margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
      strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
    })
    .onHover((isHover: boolean) => {
      this.isItemHover = isHover;
    })
    .stateStyles({
      clicked: {
        .backgroundColor($r('sys.color.interactive_click'))
      },
      normal: {
        .backgroundColor(this.isItemHover ? $r('sys.color.interactive_hover') : 'rgba(255,255,255,0)')
      },
      pressed: this.pressedStyles,
    })
    .borderRadius(this.isPC ? $r('sys.float.corner_radius_level6') : $r('sys.float.corner_radius_level8'))
    .onMouse((event: MouseEvent) => {
      // 鼠标右键响应长按事件
      if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
        VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
        this.isMenuShown = true
      }
    })
    .gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
        .onAction((event: GestureEvent) => {
          VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          this.isMenuShown = true
        })
    ))
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.itemWidth = Number(newValue.width);
    })
    .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
      preview: this.MenuPreview(),
      previewAnimationOptions: { scale: [1.0, 0.98] },
      layoutRegionMargin: { left: 0, right: 0, bottom: 0 },
      placement: Placement.BottomLeft,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      offset: {
        x: 0,
        y: $r('sys.float.padding_level4')
      },
      onAppear: () => {

      },
      onDisappear: () => {
        this.isMenuShown = false;
      },
    })
  }

  @Builder
  normalLayout() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start,
    }) {
        Text(this.item.group.groupName)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
          .constraintSize({ minHeight: this.isPC ? 22 : undefined })
          .width('100%')
          .textAlign(TextAlign.Start)
    }


    Row() {
      Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
        .lineHeight($r('app.float.id_groupList_lineHeight_xl'))
        .maxFontScale(1.75)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_fourth')])
        .margin({
          left: $r('sys.float.padding_level2')
        })
    }
    .padding({ right: '3vp' })
    .margin({
      left: $r('sys.float.padding_level8')
    })
  }

  @Builder
  seniorLayout() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start,
    }) {
      Row() {
        Text(this.item.group.groupName)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .margin({
        right: '16vp'
      })
      .constraintSize({ minHeight: this.isPC ? 22 : undefined })

      Blank();

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
      }) {
        Text((this.item.memberCount > 0 ? this.item.memberCount : 0) + '')
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xl') })
          .margin({ right: 4 })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
      }
      .margin({ top: 2 })
    }
  }

  @Builder
  MenuPreview() {
    Row() {
      Text(this.item.group.groupName)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .constraintSize({ minHeight: this.isPC ? 22 : undefined })
        .textAlign(TextAlign.Start)
        .flexShrink(1)
    }
    .accessibilityLevel('no-hide-descendants')
    .padding({
      top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? '8vp' : '0vp',
      left: '8vp',
      right: '8vp'
    })
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        $r('app.float.hide_height'), $r('app.float.hide_height')),
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(this.isPC ? $r('sys.float.corner_radius_level6') : $r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
    .width(this.itemWidth)
    .constraintSize({ minHeight: this.isPC ? '40vp' : $r('app.float.id_item_height_mid') })
  }

  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: this.item.group.groupName,
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
            if (value == this.item.group.groupName) {
              this.fixGroupNameDialog?.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              return;
            }
            let ifExist: boolean = false;
            ifExist = this.mPresenter.groupList.some((item) => {
              return item.group.groupName == value;
            })
            if (ifExist) {
              promptAction.showToast({
                message: $r('app.string.group_existed'),
                duration: 2000
              });
              return;
            } else {
              HiLog.w(TAG, 'AlertDialog saveGroupName');
              let params: GroupParams = {
                id: this.item.group.id,
                groupName: value,
              }
              this.mPresenter.renameGroup(params);
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
          .fontColor($r('app.color.skin_font_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
    }
  }
}
