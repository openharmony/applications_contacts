/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../../common/phonecommon';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { SyncDialogInfo } from '../SyncContactsExtAbility';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { hdsMaterial } from '@kit.UIDesignKit';
import { CustomContentDialog, uiMaterial } from '@kit.ArkUI';
import { FontScaleState } from '../../util/fontScaleState';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { i18n } from '@kit.LocalizationKit';

const TAG = 'SyncContactsDialog';

let storage = LocalStorage.GetShared();

@Entry(storage)
@Component
struct Index {
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @LocalStorageLink('dialogInfo') dialogInfo: SyncDialogInfo = {
    syncMode: 0,
    syncId: '',
    localCount: 0,
    cloudCount: 0,
    confirmAction: 0,
    appName: '',
    bundleName: ''
  };
  @LocalStorageLink('session') session: UIExtensionContentSession | null = null;

  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 倒计时
  @State countdown: number = 3;
  // 是否可点击同步
  @State canConfirm: boolean = false;
  // 同步按钮文字
  @State syncButtonText: string = '';
  // 弹窗控制器

  private dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: getContext(this).resourceManager.getStringSync($r('app.string.sync_contacts_dialog_title').id),
      contentBuilder: () => {
        this.SyncContactDialog();
      },
      contentAreaPadding: { left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') }
    }),
    autoCancel: false,
    closeAnimation: { duration: 100 },
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    backgroundColor: (hdsMaterial.getSystemMaterialTypes().length === 0 && this.isThemeActive) ?
      $r('app.color.contact_comp_background_primary') : undefined,
    systemMaterial: hdsMaterial.getSystemMaterialTypes().length === 0 ? undefined :
      new uiMaterial.ImmersiveMaterial({
        style: uiMaterial.ImmersiveStyle.ULTRA_THICK,
        materialColor: this.isThemeActive ? $r('app.color.contact_comp_background_primary') : Color.Transparent
      }),
    distortionMode: DistortionMode.DISTORTION_AUTO,
    edgeLightMode: EdgeLightMode.EDGELIGHT_AUTO
  });

  // 倒计时定时器
  private timer: number = -1;

  private isPC: boolean = EnvironmentProp.isPC();

  private isSystemLanguage(lang: string): boolean {
    return i18n.System.getSystemLanguage() === lang;
  }

  isErrorConfirmButton: boolean = false;

  private calculateFontSize(): Resource | string {
    if (this.isSystemLanguage('es') || this.isSystemLanguage('ru')) {
      return FontScaleState.isSmallerThirdGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '22vp';
    }
    if (this.isSystemLanguage('fr')) {
      return FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '24vp';
    }
    return FontScaleState.isSmallerSixGeer(this.fontSizeScale) ? $r('sys.float.Body_L') :
      $r('app.float.rounded_corners_width_32');
  }

  getDialogDesc(): Resource {
    if (this.dialogInfo.syncMode === 2) {
      return $r('app.string.coverage_sync_contacts_dialog_desc', this.dialogInfo.appName);
    } else {
      return $r('app.string.bidirectional_sync_contacts_dialog_desc', this.dialogInfo.appName);
    }
  }

  startCountdown(): void {
    this.updateButtonText();
    this.timer = setInterval((): void => {
      this.countdown--;
      if (this.countdown <= 0) {
        this.canConfirm = true;
        this.syncButtonText = getContext(this).resourceManager.getStringSync(
          $r('app.string.sync_contacts_button_desc').id);
        clearInterval(this.timer);
        this.timer = -1;
      } else {
        this.syncButtonText = getContext(this).resourceManager.getStringSync(
          $r('app.string.sync_contacts_countdown_button_desc').id, this.countdown);
      }
    }, 1000);
  }

  updateButtonText(): void {
    if (this.canConfirm) {
      this.syncButtonText = getContext(this).resourceManager.getStringSync(
        $r('app.string.sync_contacts_button_desc').id);
    } else {
      this.syncButtonText = getContext(this).resourceManager.getStringSync(
        $r('app.string.sync_contacts_countdown_button_desc').id, this.countdown);
    }
  }

  aboutToAppear(): void {
    HiLog.i(TAG, `SyncContactsDialog aboutToAppear, syncMode=${this.dialogInfo.syncMode}`);
    this.updateButtonText();
    this.startCountdown();
    this.openDialog();
  }

  aboutToDisappear(): void {
    if (this.dialogController) {
      this.dialogController.close();
      this.dialogController = null;
    }
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    DialogControllerManager.getInstance().dialogControllerSet.clear();
  }

  // 打开弹窗 - 参考 BatchDeleteContacts deleteDialogControler 样式
  openDialog(): void {
    this.dialogController?.open();
    DialogControllerManager.getInstance().addDialogController(this.dialogController);
  }

  handleConfirm(): void {
    HiLog.i(TAG, `SyncContactsDialog handleConfirm, syncMode=${this.dialogInfo.syncMode}`);
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    if (this.session) {
      let result: Record<string, Object> = {
        'syncId': this.dialogInfo.syncId,
        'confirmResult': 1,
        'syncMode': this.dialogInfo.syncMode
      };
      this.session.sendData(result);
      this.session.terminateSelf();
    }
  }

  handleCancel(): void {
    HiLog.i(TAG, `SyncContactsDialog handleCancel, syncMode=${this.dialogInfo.syncMode}`);
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    if (this.session) {
      let result: Record<string, Object> = {
        'syncId': this.dialogInfo.syncId,
        'confirmResult': 2,
        'syncMode': this.dialogInfo.syncMode
      };
      this.session.sendData(result);
      this.session.terminateSelf();
    }
  }

  @Builder
  SyncContactDialog() {
    Column() {
      Scroll() {
        Column() {
          // 描述文本 - 支持超大字体下滑动
          Scroll() {
            Text(this.getDialogDesc())
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Regular)
              .width('100%')
              .fontColor($r('app.color.contact_font_primary'))
              .textAlign(TextAlign.Center)
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .constraintSize({ minHeight: $r('app.float.id_setting_22') })
          .padding({
            left: $r('sys.float.padding_level12'),
            right: $r('sys.float.padding_level12'),
          })

          Column() {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceAround }) {
              Button() {
                Text($r('app.string.dialog_cancel'))
                  .maxLines(1)
                  .maxFontScale(2)
              }
              .onClick(() => {
                this.handleCancel();
              })
              .type(this.isPC ? ButtonType.Normal : undefined)
              .buttonStyle(this.isPC ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL)
              .fontColor($r('app.color.contact_font_emphasize'))
              .fontSize(this.calculateFontSize())
              .fontWeight(FontWeight.Medium)
              .width('50%')
              .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
              .borderRadius(this.isPC ? $r('sys.float.corner_radius_level4') : undefined)

              Divider()
                .vertical(true)
                .height(24)
                .width(0.5)
                .color($r('app.color.contact_comp_divider'))
                .opacity($r('sys.float.alpha_secondary'))
                .margin({ left: $r('app.float.id_card_margin_large'), right: $r('app.float.id_card_margin_large') })

              Button() {
                Text(this.syncButtonText)
                  .maxLines(1)
                  .maxFontScale(2)
              }
              .onClick(() => {
                this.handleConfirm();
              })
              .type(this.isPC ? ButtonType.Normal : undefined)
              .buttonStyle(this.isPC ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL)
              .fontColor(this.isErrorConfirmButton ? $r('app.color.contact_font_warning') :
                $r('app.color.contact_font_emphasize'))
              .fontSize(this.calculateFontSize())
              .fontWeight(FontWeight.Medium)
              .enabled(this.canConfirm)
              .width('50%')
              .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
              .borderRadius(this.isPC ? $r('sys.float.corner_radius_level4') : undefined)
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
          }
          .justifyContent(FlexAlign.Center)
          .padding({
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          })
          .width('100%')
          .constraintSize({ minHeight: '56vp' })
        }
        .width('100%')
        .margin({
          bottom: $r('sys.float.padding_level4')
        })
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .constraintSize({ maxHeight: '50%' })
    }
    .width('100%')
  }

  build() {
    // 空构建，弹窗在 aboutToAppear 中打开
  }
}