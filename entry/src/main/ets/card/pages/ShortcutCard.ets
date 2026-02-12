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
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject'
import dotCommon from '../../util/DotCommon';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { infoString, contactPage } from '../data/cardData';

let storageSC = new LocalStorage();
const TAG = 'ShortcutWidgetCard';
type objTypeSC = Record<string, string | number>;
const FORMNAMESC = 'shortcut';
const abilityName = 'ability://ShortcutCardAbility'

@Entry(storageSC)
@Component
struct shortcut {
  readonly ABILITY_NAME: string = 'ShortcutCardAbility';
  @State ContactsList: ShortcutDataType[] = [];
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('title') title: string = '';
  @LocalStorageProp('contact') @Watch('contactListChange') contacts: string = '';
  @LocalStorageProp('subscriptionList') @Watch('onSubscriptionListDebounce') subscriptionList: Array<objTypeSC> | null = null;
  @LocalStorageProp('editContacts') @Watch('onEditContacts') editContacts: string = '';
  @LocalStorageProp('isHasVoiceCapability') isHasVoiceCapability: boolean = true;

  onSubscriptionListDebounce() {
    HiLog.w(TAG, `subscriptionList formId: ${this.formId}, length: ${this.subscriptionList?.length}`);
    if (this.subscriptionList === null) {
      return;
    }
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'updateContactsList',
        formName: FORMNAMESC
      }
    });
  }

  onEditContacts() {
    HiLog.i(TAG, `editContacts formId: ${this.formId}, length: ${this.editContacts.length}`);
    if (this.editContacts === null) {
      return;
    }
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'updateTemplate',
        formName: FORMNAMESC
      }
    });
  }

  contactListChange() {
    let contactsData: ShortcutDataType[] = []
    try {
      contactsData = JSON.parse(this.contacts);
      HiLog.w(TAG, `[formId]: ${this.formId} parse ContactsData length: ${contactsData.length}`);
    } catch (e) {
      HiLog.e(TAG, 'parse ContactsData failed');
    }
    if (contactsData == this.ContactsList) {
      return;
    }
    this.ContactsList = contactsData;
  }

  /**
   * 跳转到添加页面
   */
  private jumpToAddPage() {
    HiLog.i(TAG, `jumpToAddPage formId: ${this.formId}`);
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'jumpToAddPage',
        abilityName
      }
    })
  }

  private clickToDial(contactId: string) {
    HiLog.i(TAG, `clickToDial contactId: ${contactId}`);
    const action: LooseObject = {
      'action': 'message',
      'params': {
        'contactId': contactId,
        'flag': 'dialNumber',
        'cardType': dotCommon.eventParam.SHORT_CUT_CARD_TYPE
      }
    }
    postCardAction(this, action);
  }

  private clickToDetailForMessage(item: ShortcutDataType) {
    HiLog.w(TAG, `clickToDetailForMessage contactId: ${item.contactId}`)
    const action: LooseObject = {
      'action': 'message',
      'params': {
        'contactId': item.contactId,
        'phoneList': item.phones,
        'flag': 'shortCutCardDetail',
        'cardType': dotCommon.eventParam.SHORT_CUT_CARD_TYPE
      }
    }
    postCardAction(this, action);
    HiLog.w(TAG, `clickToDetailForMessage end`)
  }

  private clickToDetailForRouter(item: ShortcutDataType) {
    HiLog.w(TAG, `clickToDetailForRouter contactId: ${item.contactId}`)
    let actionData: Record<string, string> = {
      'pageFlag': contactPage.PAGE_FLAG_CONTACT_DETAILS,
      'contactId': item.contactId
    };

    const action: LooseObject = {
      'action': 'router',
      'bundleName': infoString.CONTACT_BUNDLE_NAME,
      'abilityName': infoString.CONTACT_ABILITY_NAME,
      'params': actionData
    }
    HiLog.w(TAG, `clickToDetailForRouter doing`)
    postCardAction(this, action);
    this.clickToDetailForMessage(item);
    HiLog.w(TAG, `clickToDetailForRouter end`)
  }

  @Builder
  cardBg() {
    Column() {
    }
    .backgroundColor($r('app.color.color_contact_card_bg'))
    .opacity(1)
    .height('100%')
    .width('100%')
  }

  build() {
    Stack() {
      this.cardBg()
      Column() {
        if (!(this.ContactsList[0]?.showName && this.ContactsList[0]?.phones)) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Text($r('app.string.Card_add'))
                .margin({ right:$r('sys.float.padding_level2') })
                .lineHeight($r('app.float.id_card_title_margin_top'))
                .height($r('app.float.id_card_title_margin_top'))
                .layoutWeight(1)
                .fontSize($r('sys.float.ohos_id_text_size_button2'))
                .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .fontFamily('HarmonyHeiTi')

              Button() {
                SymbolGlyph($r('sys.symbol.plus'))
                  .fontSize($r('app.float.id_card_margin_xxl'))
                  .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
              }
              .backgroundColor($r('app.color.skin_ohos_id_color_activated'))
              .width($r('app.float.id_card_margin_xxxxl'))
              .aspectRatio(1)
            }
            .padding({
              left: $r('sys.float.padding_level6'),
              right: $r('sys.float.padding_level6')
            })
            .height('100%')
            .width('100%')
          }
          .onClick(() => {
            this.jumpToAddPage()
          })
        } else {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.ContactsList, (item: ShortcutDataType) => {
              Row() {
                Flex({ alignItems: ItemAlign.Center }) {
                  Text(item?.showName)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('app.color.skin_font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .padding({ right: $r('sys.float.padding_level4') })
                    .fontFamily('HarmonyHeiTi')
                }
                .layoutWeight(1)
                .height('100%')
                .onClick(() => {
                  this.clickToDetailForRouter(item);
                })

                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph($r('sys.symbol.phone_fill'))
                    .fontSize(16)
                    .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
                }
                .accessibilityText($r('app.string.accessibility_call'))
                .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
                .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
                .width(32)
                .height(32)
                .onClick(() => {
                  HiLog.w(TAG, `clickToDial: ${item?.contactId}`)
                  this.clickToDial(item.contactId)
                })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
              .height('100%')
              .width('100%')
            })
          }
        }
      }
      .height('100%')
      .width('100%')
    }
    .backgroundColor($r('app.color.color_contact_card_bg'))
  }
}

class ShortcutDataType {
  public contactId: string = '';
  public phones: PhonesType[] = [];
  public showName: string = '';
  public id?: number = 0;
}

class PhonesType {
  public num: string = '';
  public id: string = '';
  public numType: string = '';
  public primary: boolean = false;
  public dataId: number = 0;
}