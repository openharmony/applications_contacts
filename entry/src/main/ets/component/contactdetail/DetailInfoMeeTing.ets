/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { SelectDialogBuilder } from '../../pages/dialog/SelectSimIdDialog';
import DetailPresenter from '../../presenter/contact/detail/DetailPresenter';
import connection from '@ohos.net.connection';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import LooseObject from '../../model/type/LooseObject';
import MeeTimeDeviceInfoModel from '../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel'
import DeviceTypeEnum from '../../../../../../common/src/main/ets/util/DeviceTypeEnum'
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog'
import { FontScaleState } from '../../util/fontScaleState';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { showToast, SystemModeController } from '../../util/SystemModeController';

const TAG = 'DetailInfoMeeTime';

@Component
export default struct DetailInfoMeeTing {
  @Link mPresenter: DetailPresenter;
  @Link selectSimBuilder: SelectDialogBuilder;
  // 最大化
  @Link maximum: number;
  @Prop telephoneTotal: number;
  @Prop otherTotal: number;
  @Prop meettingTotal: number;
  @Link moreOptionsFlag: boolean;

  build() {
    Column() {
      // 畅连，最顶层
      DetailInfoItemMeeTime({
        mPresenter: $mPresenter,
        moreOptionsFlag: $moreOptionsFlag,
        maximum: $maximum
      })
    }
    .padding({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })
  }
}

// 畅连信息，第二顶层，内部包含 畅连电话行+所有畅连设备行
@Component
struct DetailInfoItemMeeTime {
  // 畅连能力的类型，用于判断使用哪种能力功能；无网络时提示，弹出选择电话号码时提示信息会判断能力类型
  // 点击能力按钮时设置
  @State abilityType: number = 0
  @Link moreOptionsFlag: boolean;
  @Link maximum: number;
  @Link private mPresenter: DetailPresenter;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // deviceComId，默认为空串
  @State deviceComId: string = '';
  // 没有网络，自定义提示框
  noNetWorkDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.connect_net_title'),
      contentBuilder: () => {
        this.NoNetWorkDialogControllerBuilder();
      },
      buttons: [
        {
          value: $r('app.string.got_it'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.noNetWorkDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: true,
    gridCount: 4,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })
  // 多个电话号码-选择框
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.getText(),
      contentBuilder: () => {
        this.DialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.dialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: true,
    gridCount: 4,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })

  aboutToDisappear() {
    this.dialogController?.close()
    this.noNetWorkDialogController?.close()
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    this.noNetWorkDialogController = null;
    this.dialogController = null;
  }

  // 号码选择弹框标题
  getText() {
    if (this.abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO) {
      return $r('app.string.meetime_audio_title')
    }
    if (this.abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO) {
      return $r('app.string.meetime_video_title')
    }
    return $r('app.string.meetime_chat_title')
  }

  // 获取图像
  getIcon() {
    if (this.abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO) {
      return $r('sys.symbol.phone_badge_waveform_2')
    }
    if (this.abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO) {
      return $r('sys.symbol.video_badge_adiowaves')
    }
    return $r('sys.symbol.message_on_message')
  }

  build() {
    Column() {
      // 展示畅连电话这一行
      List() {
        // 有非家庭设备的设备，才显示畅联电话这一栏
        if (this.mPresenter.isHasNotFamilyDeviceFlag) {
          ListItem() {
            Column() {
              DetailInfoMeeTime({
                mPresenter: $mPresenter,
                dialogController: this.dialogController as CustomDialogController,
                abilityType: this.abilityType,
                noNetWorkDialogController: this.noNetWorkDialogController as CustomDialogController,
                deviceInfoModel: undefined,
                deviceComId: this.deviceComId,
                isFamilyDeviceFlag: false
              });
              Divider()
                .color($r('app.color.skin_comp_divider'))
                .strokeWidth('1px')
                .width('100%')
                .visibility(this.mPresenter.meeTimeDeviceList.totalCount() ? Visibility.Visible : Visibility.Hidden)

            }
          }
        }

        // 展示其他家庭设备
        if (this.moreOptionsFlag ||
          (this.mPresenter.phoneDataSources.totalCount() + (this.mPresenter.isHasNotFamilyDeviceFlag ? 1 : 0) <
          this.maximum)) {
          LazyForEach(this.mPresenter.meeTimeDeviceList,
            (item: MeeTimeDeviceInfoModel, index: number) => {
              if (item !== undefined && this.itemVisible(index)) {
                ListItem() {
                  Column() {
                    DetailInfoMeeTime({
                      mPresenter: $mPresenter,
                      dialogController: this.dialogController as CustomDialogController,
                      abilityType: this.abilityType,
                      noNetWorkDialogController: this.noNetWorkDialogController as CustomDialogController,
                      // 设备信息
                      deviceInfoModel: item,
                      deviceComId: this.deviceComId,
                      isFamilyDeviceFlag: true
                    })

                    Divider()
                      .color($r('app.color.skin_comp_divider'))
                      .strokeWidth('1px')
                      .width('100%')
                      // 分界线根据“下一个”元素是否展示决定
                      .visibility(this.itemVisible(index + 1) ? Visibility.Visible : Visibility.Hidden)
                  }
                }
              }
            })
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .enableScrollInteraction(false)
    }
    .width('100%')
    .visibility((
      this.mPresenter.isMeeTimeLoginFlag &&
      this.mPresenter.isHasMeeTimeAbilityFlag
    ) ? Visibility.Visible : Visibility.None)
  }

  @Builder
  NoNetWorkDialogControllerBuilder() {
    Column() {
      Text(this.mPresenter.getNoNetWorkMsg(this.abilityType))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(TextAlign.Start)
        .height('21vp')
        .width('100%')
        .margin({ bottom: $r('sys.float.padding_level4') })
    }
    .width('100%')
  }

  // index：畅连设备列表中index
  itemVisible(index: number): boolean {
    let meetingCount = this.mPresenter.isHasNotFamilyDeviceFlag ? 1 : 0;
    return this.moreOptionsFlag ?
      (index < this.mPresenter.meeTimeDeviceList.totalCount()) :
      // 电话号码个数 + '畅连‘1个 + 畅连设备index（第index+1个设备） <= 最大数量
      // 即phoneCount + meetingCount + index + 1 < maximum + 1
      (index + this.mPresenter.phoneDataSources.totalCount() + meetingCount < this.maximum);
  }

  @Builder
  DialogBuilder() {
    Column() {
      // 有多个有畅连能力的号码，选择其中一个拨打畅连电话
      ForEach(this.mPresenter.getMeeTimeAbilityPhoneNumList(),
        (item: Record<string, string | number>, index: number) => {
          Row() {
            SymbolGlyph(this.getIcon())
              .fontSize($r('app.float.id_card_image_small'))
              .fontColor([$r('app.color.skin_icon_secondary')])
              .margin({ right: $r('app.float.id_card_margin_xxl') })

            Column() {
              Column() {
                Text(item.phoneNumber as string)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontFamily('HarmonyHeiTi')
                  .textAlign(TextAlign.Start)
                  .height('21vp')
                  .width('100%')
              }
              .justifyContent(FlexAlign.Center)
              .height($r('app.float.id_item_height_large'))

              // 最后一行，没有下划线
              if (!item.lastFlag) {
                Divider()
                  .height($r('app.float.account_Divider_height'))
                  .width('100%')
                  .color($r('app.color.skin_comp_divider'))
              }
            }
            .flexShrink(1)
          }
          .width('100%')
          .height($r('app.float.id_item_height_large'))
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.dialogController?.close()
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            // 如果有网络, 连接畅连
            connection.hasDefaultNet().then(hasNetFlag => {
              if (!hasNetFlag) {
                this.noNetWorkDialogController?.open();
                DialogControllerManager.getInstance().addDialogController(this.noNetWorkDialogController);
              } else {
                // 手机拨打畅连，设备信息为空
                this.mPresenter.openMeetimeAbility(this.abilityType, false, undefined, this.deviceComId);
              }
            }).catch((error: Error) => {
              HiLog.e(TAG, `Error checking network or opening MeetTime ability: ${error?.message}`);
            });
          })
        }, (item: Record<string, string | number>): string => item.index.toString())
    }
    .width('100%')
  }
}

@Component
struct DetailInfoMeeTime {
  @Link private mPresenter: DetailPresenter;
  dialogController?: CustomDialogController;
  noNetWorkDialogController?: CustomDialogController;
  // 畅连能力的类型，用于判断使用哪种能力功能，点击能力按钮时设置
  @Link abilityType: number;
  @Prop deviceInfoModel: MeeTimeDeviceInfoModel;
  @Link deviceComId: string | undefined;
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 是否家庭设备，家庭设备需要传设备id
  // 不是家庭设备（手机通话），不需要传设备id
  isFamilyDeviceFlag: boolean = true;
  private mSystemModeController = SystemModeController.getInstance();

  linkMeeTimeAbility() {
    // 如果有网络, 连接畅连
    connection.hasDefaultNet().then(hasNetFlag => {
      if (!hasNetFlag) {
        this.noNetWorkDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.noNetWorkDialogController);
      } else {
        let phoneNumberList = this.mPresenter.getMeeTimeAbilityPhoneNumList()
        HiLog.w(TAG, `phoneNumberList length: ${phoneNumberList.length}`)
        // 如果仅有一个电话，直接拨打
        if (phoneNumberList.length == 1) {
          this.linkMeeTimeAbilityDirect()
          return
        }
        this.dialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.dialogController);
      }
    })
  }

  linkMeeTimeAbilityDirect(deviceComId?: string) {
    // 如果有网络, 连接畅连
    connection.hasDefaultNet().then(hasNetFlag => {
      this.mPresenter.openMeetimeAbility(this.abilityType, this.isFamilyDeviceFlag,
        this.deviceInfoModel?.deviceType, this.deviceComId)
    })
  }

  getDeviceName() {
    if (this.deviceInfoModel === undefined) {
      return $r('app.string.meetime_title');
    }
    switch (this.deviceInfoModel.deviceType) {
      case DeviceTypeEnum.SPEAKER:
        return $r('app.string.speaker_display_name')
      case DeviceTypeEnum.WATCH:
        return $r('app.string.watch_display_name')
      case DeviceTypeEnum.TV:
        return $r('app.string.tv_display_name')
      case DeviceTypeEnum.CAMERA:
        return $r('app.string.camera_display_name')
      case DeviceTypeEnum.LEARNING_PAD:
        return $r('app.string.learning_pad_display_name')
      case DeviceTypeEnum.DEVICE_VALUE_OHOS_ROBOT:
        return $r('app.string.robot_display_name')
      case DeviceTypeEnum.SMART_CAMERA_HAIQUE:
        return $r('app.string.haique_camera_display_name')
      case DeviceTypeEnum.SMART_PROJECTOR_DEV:
        return $r('app.string.smart_projector_dev_display_name')
      case DeviceTypeEnum.SMART_BOX_DEV:
        return $r('app.string.smart_box_display_name')
      case DeviceTypeEnum.INTELLIGENT_CENTRAL_CONTROL_DEV:
        return $r('app.string.intelligent_central_contral_display_name')
      case DeviceTypeEnum.PORTABLE_SMART_SCREEN_DEV:
        return $r('app.string.portable_smart_screen_display_name')
      case DeviceTypeEnum.OFFICE_TREASURE_DEV:
        return $r('app.string.official_treasure_display_name')
      case DeviceTypeEnum.LEARNING_TABLE_LAMP_DEV:
        return $r('app.string.learning_table_lamp_display_name')
      default:
        return $r('app.string.meetime_title');
    }
  }

  getAbility(abilityTypeIndex: number): boolean {
    // 手机设备判断是否有能力，根据标志位判断
    if (this.deviceInfoModel === undefined) {
      return this.mPresenter.meeTimeAbilityBinary.charAt(abilityTypeIndex) == '1';
    } else {
      // 家庭设备判断是否有能力，根据设备信息的profile中的对应字段判断
      const item: LooseObject = JSON.parse(this.deviceInfoModel.profile);
      switch (abilityTypeIndex) {
        case DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO:
          return item.supportAudio as boolean;
        case DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO:
          return item.supportVideo as boolean;
        default:
          return false;
      }
    }
  }

  build() {

    Column() {

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.getDeviceName())
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 10)
            .fontColor(this.isThemeActive ? $r('app.color.skin_font_primary') : undefined)
        }
        .flexShrink(1)

        Row() {

          if (this.getAbility(DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO)) {
            // 畅连语音
            Row() {
              Button({ stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.phone_badge_waveform_2'))
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_ohos_fa_icon_primary')])
              }
              .type(ButtonType.Normal)
              .height($r('app.float.id_item_height_mid'))
              .width($r('app.float.id_item_height_mid'))
              .borderRadius($r('sys.float.corner_radius_level4'))
              .backgroundColor(Color.Transparent)
              .stateEffect(false)
              .id('changLian_voice')
              .onClick(() => {
                HiLog.i(TAG, `changLian_voice onclick`)
                this.abilityType = DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO
                // 点击按钮时，将deviceComId更新
                this.deviceComId = this.deviceInfoModel?.comId;
                this.linkMeeTimeAbility()
              })
              .accessibilityText(AccessibilityUtil.getInstance()
                .setAccessibilityText(this.isOpenAccessibility, $r('app.string.meetime_audio_title')))
              .enabled(this.mSystemModeController.getIsEnableAudioCallOfMeeTime())
            }.onClick(() => {
              if (!this.mSystemModeController.getIsEnableAudioCallOfMeeTime()) {
                showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
              }
            })
          }

          if (this.getAbility(DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO) && !this.isInVisionGlass) {
            Row() {
              // 畅连视频
              Button({ stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.video_badge_adiowaves'))
                  .padding(0)
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_ohos_fa_icon_primary')])
              }
              .type(ButtonType.Normal)
              .height($r('app.float.id_item_height_mid'))
              .width($r('app.float.id_item_height_mid'))
              .id('changLian_video')
              .borderRadius($r('sys.float.corner_radius_level4'))
              .backgroundColor(Color.Transparent)
              .stateEffect(false)
              .onClick(() => {
                HiLog.i(TAG, `changLian_video onclick`)
                this.abilityType = DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO;
                // 点击按钮时，将deviceComId更新
                this.deviceComId = this.deviceInfoModel?.comId;
                this.linkMeeTimeAbility()
              })
              .accessibilityText(AccessibilityUtil.getInstance()
                .setAccessibilityText(this.isOpenAccessibility, $r('app.string.meetime_video_title')))
              .enabled(this.mSystemModeController.getIsEnableVideoCallOfMeeTime())
            }.onClick(() => {
              if (!this.mSystemModeController.getIsEnableVideoCallOfMeeTime()) {
                showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
              }
            })
          }

        }
        .flexShrink(0)
        .margin({right:$r('app.float.ContactDetail_margin_12')})
      }.width('100%')
      .constraintSize({
        minHeight: EnvironmentProp.isPC() ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_large')
      })
    }
  }
}



