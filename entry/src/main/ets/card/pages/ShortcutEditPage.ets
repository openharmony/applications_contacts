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
import router from '@ohos.router';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import ShortcutEditCommon from '../common/ShortcutEditCommon';
import { FormCardController } from '../common/FormCardController';
import { ShortcutDataType, UpdateToCardType } from '../type/shortcut';
import { CustomContentDialog } from '@kit.ArkUI';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { LengthMetrics } from '@ohos.arkui.node';
import { FontScaleState } from '../../util/fontScaleState';
import DotUtil from '../../util/DotUtil';
import dotCommon, { contactParams } from '../../util/DotCommon';
import { TextModifier } from '@ohos.arkui.modifier';
import IndexPresenter from '../../presenter/IndexPresenter'
import { systemParameter } from '@kit.BasicServicesKit';
import MaintenanceModeDialog from '../../pages/dialog/MaintenanceModeDialog';
import { i18n } from '@kit.LocalizationKit';
import { ExtensionEvent } from '../model/FormExtensionEvent';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../util/AccessibilityUtil';

const TAG = 'ShortcutEditPage';
const INITDATA: ShortcutDataType[] = [];
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
export struct ShortcutEditPage {
  @State common: ShortcutEditCommon = new ShortcutEditCommon();
  @LocalStorageLink('shortcutData') @Watch('updateShortCardContactFormId') shortcutData: ShortcutDataType[] = INITDATA;
  @LocalStorageLink('formId') formId: string = '';
  @LocalStorageLink('previewFormId') previewFormId: string = '';
  @LocalStorageProp('curBpCard') curBpCard: string = 'sm'
  @StorageProp('shortcutCardData') @Watch('shortcutCardDataPicker') shortcutCardData: Record<string, Object> = {}
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack();
  mFormCardController: FormCardController = FormCardController.getInstance();
  @State contactId: string | undefined = ''
  @State maintenanceMode: string = '';
  private extensionEvent: ExtensionEvent | undefined = storage.get<ExtensionEvent>('extensionEvent');
  @State deleteContact: ShortcutDataType[] = [];
  // v小折叠外屏需要限制
  private maxFontScale: number = 2;
  private context: Context = getContext(this)
  private uiExtensionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();
  private scroller: Scroller = new Scroller();
  @StorageProp('isVerde') isVde: boolean = false;

  async aboutToAppear() {
    HiLog.w(TAG, `aboutToAppear start formId: ${this.formId}, previewFormId: ${this.previewFormId}`)
    systemParameter.get('persist.hiviewcare.maintenancemode').then(value => {
      this.maintenanceMode = value;
    });
    this.updatePreviewCard()
  }

  aboutToDisappear() {
    this.maintenanceModeDialogController = null;
  }

  shortcutCardDataPicker() {
    this.common.parseContactForResult(this.shortcutCardData).then(() => {
      this.shortcutData = this.common.contact
      this.updatePreviewCard()
    })
  }

  // 更新添加到shortCard卡片联系人的formId
  async updateShortCardContactFormId() {
    if (this.shortcutData.length > 0) {
      for (let item of this.shortcutData) {
        item.formId = await this.common.queryContactFormId(item.contactId, this.context)
        if (item.formId === '') {
          item.formId = this.formId
        } else if (item.formId && item.formId.includes(this.formId)) {
          item.formId = item.formId
        } else if (item.formId && !item.formId.includes(this.formId)) {
          item.formId = item.formId.concat('//', this.formId)
        }
        await this.common.updateContactFormId(item.contactId, this.context, item.formId)
      }
    }

    let obj: UpdateToCardType = {
      title: 'update',
      formId: this.formId,
      editContacts: JSON.stringify(this.shortcutData),
    };
    let formBinding = formBindingData.createFormBindingData(obj);
    this.common.updateToCard(this.formId, formBinding);
  }

  // 更新预览卡片
  updatePreviewCard() {
    HiLog.w(TAG, `updatePreviewCard, previewFormId: ${this.previewFormId}`)
    let obj: UpdateToCardType = {
      title: 'onAddDataToShortcut',
      formId: this.previewFormId,
      contact: JSON.stringify(this.shortcutData),
    };
    let formBinding = formBindingData.createFormBindingData(obj);
    this.common.updateToCard(this.previewFormId, formBinding);
  }

  maintenanceModeDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.maintenanceModeDialogBuilder();
      },
      buttons: [{
        value: $r('app.string.got_it'), action: () => {
          router.back();
        }
      }]
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      dismissDialogAction.reason == DismissReason.PRESS_BACK
    },
  });

  // 点击删除联系人
  async resetContact() {
    this.shortcutData = INITDATA;
    if (this.deleteContact.length > 0) {
      for (const item of this.deleteContact) {
        if (item.contactId && this.contactId !== item.contactId) {
          item.formId = await this.common.queryContactFormId(item.contactId, this.context)
          item.formId = item.formId.split('//').filter(item => !item.includes(this.formId)).join('//')
          this.common.updateContactFormId(item.contactId, this.context, item.formId)
        }
      }
    }
    let obj: UpdateToCardType = {
      title: 'update',
      formId: this.formId,
      editContacts: JSON.stringify(this.shortcutData),
    };
    let formBinding = formBindingData.createFormBindingData(obj);
    this.common.updateToCard(this.formId, formBinding);
    this.updatePreviewCard()
  }

  @Builder
  maintenanceModeDialogBuilder() {
    MaintenanceModeDialog();
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

  @Styles
  closeImagePressedStyles() {
    .backgroundColor($r('app.color.skin_ohos_id_color_tertiary'))
    .height($r('app.float.id_item_height_mid'))
    .width($r('app.float.id_item_height_mid'))
    .borderRadius($r('sys.float.padding_level4'))
  }

  build() {
    Column() {
      // subheader深色模式
      SubHeader({
        secondaryTitle: $r('app.string.card_shortcut_msg'),
        contentMargin: { start: LengthMetrics.vp(0), end: LengthMetrics.vp(0) },
        secondaryTitleModifier: IndexPresenter.isThemeActiveCard
          ? new TextModifier().fontColor($r('app.color.skin_font_secondary')).maxFontScale(this.maxFontScale)
          : new TextModifier().maxFontScale(this.maxFontScale)
      })

      List() {
        if (this.shortcutData.length > 0) {
          ListItem() {
            Flex({
              direction: FlexDirection.Row,
              wrap: FlexWrap.NoWrap,
              justifyContent: FlexAlign.SpaceBetween,
              alignItems: ItemAlign.Center
            }) {
              Text(this.shortcutData[0]?.showName)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Subtitle_M'))
                .margin(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level4') } :
                  { left: $r('sys.float.padding_level4') })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(FontScaleState.isStandardGeer(FontScaleState.fontSizeScaleCard) ? 1 : 10)
                .constraintSize({ minHeight: 24 })
                .maxFontScale(this.maxFontScale)

              Button() {
                SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
              }
              .accessibilityText($r('app.string.accessibility_delete'))
              .height($r('app.float.id_item_height_mid'))
              .width($r('app.float.id_item_height_mid'))
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                // 联系人打点-快捷方式卡片-卡片编辑页面-移除常用联系人
                contactParams.ENC = 0;
                DotUtil.getInstance().contactDot(contactParams,
                  dotCommon.eventName.CARD_EDIT_DELETE_CONTACT_EVENT);
                  this.shortcutData.forEach(item => {
                    this.deleteContact.push(item)
                  })
                  this.resetContact();
                if (this.shortcutData.length === 0) {
                  AccessibilityUtil.getInstance().sendAccessibilityNotInterruptEvent(true, 'add_contact_bnt', 500);
                }
              })
            }
          }
          .stateStyles({
            normal: this.normalStylesTransparent,
            pressed: this.pressedStyles
          })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
          .width('100%')
        } else {
          ListItem() {
            Flex({
              direction: FlexDirection.Row,
              wrap: FlexWrap.NoWrap,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center
            }) {
              SymbolGlyph($r('sys.symbol.plus_circle'))
                .fontSize($r('app.float.id_width_24'))
                .fontColor([$r('app.color.skin_font_emphasize')])
                .margin({
                  start: LengthMetrics.resource($r('sys.float.padding_level4'))
                })

              Text($r('app.string.Card_add'))
                .fontColor($r('app.color.skin_font_emphasize'))
                .margin(i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: $r('sys.float.padding_level8') } :
                  { left: $r('sys.float.padding_level8') })
                .fontWeight(FontWeight.Medium)
                .align(Alignment.Center)
                .maxFontScale(this.maxFontScale)
            }
            .id('add_contact_bnt')
            .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
            .onClick(() => {
              HiLog.w(TAG, 'onClick to add contact');
              this.extensionEvent?.startFormEditSecondPage();
              // 联系人打点-快捷方式卡片-卡片编辑页面-添加常用联系人
              contactParams.ENC = 0;
              DotUtil.getInstance()
                .contactDot(contactParams, dotCommon.eventName.CARD_EDIT_ADD_CONTACT_EVENT);
            })
          }
          .stateStyles({
            normal: this.normalStylesTransparent,
            pressed: this.pressedStyles
          })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
          .width('100%')
        }
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .padding({
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2'),
        top: $r('sys.float.padding_level2'),
        bottom: $r('sys.float.padding_level2')
      })
    }
    .backgroundColor(Color.Transparent)
    .onAppear(this.isVde ? () => {
      let resultData: Record<string, Object> = {
        'uecHeight': 120,
      };
      HiLog.i(TAG, `ShortcutEditPage onAppear, uecHeight: ${resultData.uecHeight}`);
      this.uiExtensionSession?.sendData(resultData);
    } : undefined)
  }
}