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
import formBindingData from '@ohos.app.form.formBindingData';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import SpeedDialEditCommon from '../common/SpeedDialEditCommon';
import { SpeedDialDataType, UpdateToCardType } from '../type/speedDial';
import router from '@ohos.router';
import { FormCardController } from '../common/FormCardController';
import { CustomContentDialog } from '@kit.ArkUI';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader'
import { LengthMetrics } from '@ohos.arkui.node';
import { FontScaleState } from '../../util/fontScaleState';
import DotUtil from '../../util/DotUtil';
import dotCommon, { contactParams } from '../../util/DotCommon';
import { TextModifier } from '@ohos.arkui.modifier';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import IndexPresenter from '../../presenter/IndexPresenter'
import { systemParameter } from '@kit.BasicServicesKit';
import MaintenanceModeDialog from '../../pages/dialog/MaintenanceModeDialog';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { i18n } from '@kit.LocalizationKit';
import { ExtensionEvent } from '../model/FormExtensionEvent';
import { getHeadChar } from '../../util/UserPhoto';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../util/AccessibilityUtil';

const TAG = 'SpeedDialEdit';
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
export struct SpeedDialEdit {
  @State common: SpeedDialEditCommon = new SpeedDialEditCommon();
  @LocalStorageLink('speedDialData') @Watch('speedDialDataChange') speedDialData: SpeedDialDataType[] = [];
  @LocalStorageLink('formId') formId: string = '';
  @LocalStorageLink('previewFormId') previewFormId: string = '';
  @StorageProp('speedDialCardData') @Watch('speedDialCardDataPicker') speedDialCardData: Record<string, Object> = {}
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack();
  mFormCardController: FormCardController = FormCardController.getInstance();
  @State needInit: boolean = true;
  @State deleteContact: SpeedDialDataType[] = [];
  @State contactIdList: string[] = []
  @State maintenanceMode: string = '';
  // v小折叠外屏需要限制
  private maxFontScale: number = 2;
  private context: Context = getContext(this);
  private uiExtensionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();
  @StorageProp('isVerde') isVde: boolean = false;

  async aboutToAppear() {
    this.common.contacts = this.speedDialData;
    HiLog.w(TAG, `aboutToAppear start formId: ${this.formId}, previewFormId: ${this.previewFormId}`)
    systemParameter.get('persist.hiviewcare.maintenancemode').then(value => {
      this.maintenanceMode = value;
    });
  }

  speedDialCardDataPicker() {
    this.common.parseContactForResult(this.speedDialCardData).then(() => {
      this.speedDialData = this.common.contacts
      this.speedDialData.forEach(item => {
        if (item) {
          (item as SpeedDialDataType).nameSuffix = getHeadChar((item as SpeedDialDataType).showName);
        }
      })
    })
  }

  async speedDialDataChange() {
    if (this.speedDialData.length > 0) {
      for (let index = 0; index < this.speedDialData.length; index++) {
        const item = this.speedDialData[index]
        if (item.contactId) {
          this.contactIdList.push(item.contactId)
          item.formId = await this.common.queryContactFormId(item.contactId, this.context)
          if (item.formId === '') {
            item.formId = this.formId.toString().concat('*', index.toString())
          } else if (item.formId && item.formId.includes(this.formId)) {
            const regex = new RegExp(`${this.formId}\\*\\d+`, 'g');
            item.formId = item.formId.replace(regex, `${this.formId}` + '*' + `${index}`);
          } else if (item.formId && !item.formId.includes(this.formId)) {
            item.formId = item.formId.concat('//', this.formId.toString().concat('*', index.toString()))
          }
          await this.common.updateContactFormId(item.contactId, this.context, item.formId)
        }
      }
    }

    let obj: UpdateToCardType = {
      title: 'update',
      formId: this.formId,
      editContacts: JSON.stringify(this.speedDialData),
    };
    let formBinding = formBindingData.createFormBindingData(obj);
    this.common.updateToCard(this.formId.toString(), formBinding);
    // 适配Vde外屏卡片编辑，联系人数量变化需要通知桌面高度变化
    if (this.isVde) {
      this.notifyUecHeightChange();
    }
  }

  private notifyUecHeightChange() {
    let uecHeight: number = this.speedDialData.length === 0 ? 100 :
      this.speedDialData.length === 4 ? 280 : this.speedDialData.length * 58 + 126;
    let resultData: Record<string, Object> = {
      'uecHeight': uecHeight,
    };
    HiLog.i(TAG, `ShortcutEditPage onAppear, uecHeight: ${resultData.uecHeight}`);
    this.uiExtensionSession?.sendData(resultData);
  }

  build() {
    Flex({
      direction: FlexDirection.Column,
    }) {
      // subheader深色模式
      SubHeader({
        secondaryTitle: $r('app.string.card_shortcut_msg'),
        contentMargin: { start: LengthMetrics.vp(0), end: LengthMetrics.vp(0) },
        secondaryTitleModifier: IndexPresenter.isThemeActiveCard
          ? new TextModifier().fontColor($r('app.color.skin_font_secondary')).maxFontScale(this.maxFontScale)
          : new TextModifier().maxFontScale(this.maxFontScale)
      })
      contactCard({
        speedDialData: this.speedDialData,
        common: this.common,
        formId: this.formId,
        previewFormId: this.previewFormId,
        needInit: this.needInit,
        deleteContact: this.deleteContact,
        maintenanceMode: this.maintenanceMode,
        maxFontScale: this.maxFontScale,
      })
    }
    .height('100%')
    .onAppear(this.isVde ? () => this.notifyUecHeightChange() : undefined)
  }
}

@Component
struct contactCard {
  @Link @Watch('updatePreviewCard') speedDialData: SpeedDialDataType[];
  @Link common: SpeedDialEditCommon;
  @Link formId: string;
  @Link previewFormId: string;
  @Link needInit: boolean;
  @Link deleteContact: SpeedDialDataType[]
  @State isShowSheet: boolean = false
  @Link maintenanceMode: string;
  @Prop maxFontScale: number;
  @State context: Context = getContext(this)
  private extensionEvent: ExtensionEvent | undefined = storage.get<ExtensionEvent>('extensionEvent');
  maintenanceModeDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.maintenanceModeDialogBuilder();
      },
      buttons: [{
        value: $r('app.string.got_it'),
        action: () => {
          router.back();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      }]
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      dismissDialogAction.reason == DismissReason.PRESS_BACK
    },
  });

  @Builder
  maintenanceModeDialogBuilder() {
    MaintenanceModeDialog();
  }
  aboutToAppear(): void {
    this.context = getContext(this);
    this.updatePreviewCard()
  }

  aboutToDisappear() {
    this.maintenanceModeDialogController = null;
  }

  itemMove(index: number, newIndex: number): void {
    let tmp = this.speedDialData.splice(index, 1)
    if (!ArrayUtil.isEmpty(tmp)) {
      this.speedDialData.splice(newIndex, 0, tmp[0])
    }
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.padding_level8'))
  }

  @Styles
  normalStylesTransparent() {
    .backgroundColor(Color.Transparent)
  }

  // 更新预览卡片
  async updatePreviewCard() {
    HiLog.w(TAG, `updatePreviewCard, previewFormId: ${this.previewFormId}`)
    this.speedDialData = await this.common.onAddImage(this.speedDialData)
    HiLog.w(TAG, `previewFormId: ${this.previewFormId}, speedDialDataLength: ${this.speedDialData?.length}`)
    let obj: UpdateToCardType = {
      title: 'onAddDataToSpeedDial',
      formId: this.previewFormId,
      contact: JSON.stringify(this.speedDialData),
    };
    let formBinding = formBindingData.createFormBindingData(obj);
    setTimeout(() => {
      this.common.updateToCard(this.previewFormId, formBinding);
    })
  }

  // 点击删除联系人
  async resetContact(deleteContact: SpeedDialDataType[]) {
    if (deleteContact.length > 0) {
      for (const item of this.deleteContact) {
        if (item.contactId) {
          item.formId = await this.common.queryContactFormId(item.contactId, this.context)
          item.formId = item.formId.split('//').filter(item => !item.includes(this.formId)).join('//')
          this.common.updateContactFormId(item.contactId, this.context, item.formId)
        }
      }
    }
  }

  @Builder
  ListItemColumn(item: SpeedDialDataType, index: number) {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.NoWrap,
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Center
        }) {

          SymbolGlyph($r('sys.symbol.line_2_horizontal'))
            .fontSize($r('app.float.id_width_24'))
            .fontColor([$r('app.color.skin_icon_secondary')])
            .margin(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level4') } :
              { left: $r('sys.float.padding_level4') })

          Text(item.showName)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .margin(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level8') } :
              { left: $r('sys.float.padding_level8') })
            .constraintSize({ minHeight: 24 })
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(FontScaleState.fontSizeScaleCard) ? 1 : 10)
            .maxFontScale(this.maxFontScale)
            .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
            .direction(Direction.Ltr)

        }

        Button() {
          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
        }
        .accessibilityText($r('app.string.accessibility_delete'))
        .height($r('app.float.id_item_height_mid'))
        .width($r('app.float.id_item_height_mid'))
        .backgroundColor(Color.Transparent)
        .onClick(async () => {
          // 联系人打点-快速拨号卡片-卡片编辑页面-移除常用联系人
          contactParams.ENC = 1;
          DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_EDIT_DELETE_CONTACT_EVENT);
          this.deleteContact.push(item)
          await this.resetContact(this.deleteContact)
          this.speedDialData.splice((index as number), 1)
          this.updatePreviewCard();
          if (this.speedDialData.length === 0) {
            AccessibilityUtil.getInstance().sendAccessibilityNotInterruptEvent(true, 'addSpeedDial');
          }
        })
      }
      .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
    }
    .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
    .animation({ curve: Curve.Sharp, duration: 300 })
  }

  build() {
    Flex({
      direction: FlexDirection.Column
    }) {
      List() {
        ForEach(this.speedDialData, (item: SpeedDialDataType, index) => {
          ListItem() {
            this.ListItemColumn(item, index)
          }
          .stateStyles({
            normal: this.normalStylesTransparent,
            pressed: this.pressedStyles
          })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .width('100%')
        }, (item: number) => JSON.stringify(item))
          .onMove((from: number, to: number) => {
            HiLog.w(TAG, `onMove: ${from}, ${to}`);
            this.itemMove(from, to);
          }, {
            onLongPress: (index: number) => {
              HiLog.w(TAG, `onLongPress`);
              VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
            }
          })
      }
      .divider({
        strokeWidth: '1px',
        color: $r('app.color.skin_ohos_id_color_list_separator'),
        startMargin: i18n.isRTL(i18n.System.getSystemLanguage()) ?
          $r('sys.float.padding_level6') : $r('sys.float.padding_level24'),
        endMargin: i18n.isRTL(i18n.System.getSystemLanguage()) ?
          $r('sys.float.padding_level24'): $r('sys.float.padding_level6')
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.padding_level10'))
      .padding({
        top: this.speedDialData.length > 0 ? $r('sys.float.padding_level2') : 0,
        bottom: this.speedDialData.length > 0 ? $r('sys.float.padding_level2') : 0,
        left: this.speedDialData.length > 0 ? $r('sys.float.padding_level2') : 0,
        right: this.speedDialData.length > 0 ? $r('sys.float.padding_level2') : 0
      })

      Row() {
        Column() {
          if (this.speedDialData.length != 4) {
            this.addItemLayout()
          }
        }
      }
      .flexShrink(0)
    }
  }

  @Builder
  addItemLayout() {
    ListItem() {
      this.addItemColumn()
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level10'))
    .margin({ top: this.speedDialData.length !== 0 ? $r('sys.float.padding_level6') : 0 })
    .padding({
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2'),
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2')
    })
  }

  @Builder
  addItemColumn() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center
      }) {
        SymbolGlyph($r('sys.symbol.plus_circle'))
          .fontSize($r('app.float.id_width_24'))
          .fontColor([$r('app.color.skin_font_emphasize')])

        Text($r('app.string.Card_add'))
          .fontColor($r('app.color.skin_font_emphasize'))
          .margin(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level8') } :
            { left: $r('sys.float.padding_level8') })
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
          .maxFontScale(this.maxFontScale)
      }
      .id('addSpeedDial')
      .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
      .onClick(() => {
        // 联系人打点-快速拨号卡片-卡片编辑页面-添加常用联系人
        contactParams.ENC = 1;
        DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_EDIT_ADD_CONTACT_EVENT);
        if (this.maintenanceMode === 'true') {
          this.maintenanceModeDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.maintenanceModeDialogController);
          return;
        }
        this.common.contacts = this.speedDialData;
        this.extensionEvent?.startFormEditSecondPage();
      })
      .layoutWeight(FontScaleState.isStandardGeer(FontScaleState.fontSizeScaleCard) ? 1 : 0)
    }
    .borderRadius($r('sys.float.padding_level8'))
    .padding(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level4') } :
      { left: $r('sys.float.padding_level4') })
    .stateStyles({
      normal: this.normalStylesTransparent,
      pressed: this.pressedStyles
    })
    .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
  }
}