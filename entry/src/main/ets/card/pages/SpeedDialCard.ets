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
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
import dotCommon from '../../util/DotCommon';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { infoString, contactPage } from '../data/cardData';

let storageSD = new LocalStorage();
const TAGSD = 'SpeedDialWidgetCard';
type objTypeSD = Record<string, string | number>;
const FORMNAMESD = 'SpeedDial';
const abilityName = 'ability://SpeedDialCardAbility'

/**
 * Speed Dial
 */
@Entry(storageSD)
@Component
struct SpeedDial {
  readonly MAX_LINES: number = 1;
  readonly ADD_BTN_SIZE_RATION: number = 0.3;
  readonly ADD_BTN_SYMBOL: number = 0.5
  readonly BOTTOM_PERCENTAGE: number = 16 / 140;
  // 联系人列表
  @State ContactsList: SpeedDialDataType[] = [];
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('title') title: string = '';
  @LocalStorageProp('isHasVoiceCapability') isHasVoiceCapability: boolean = true;
  @LocalStorageProp('contact') @Watch('contactListChange') contacts: string = '';
  @LocalStorageProp('subscriptionList') @Watch('onSubscriptionListDebounce') subscriptionList: Array<objTypeSD> | null = null;
  @LocalStorageProp('editContacts') @Watch('onEditContacts') editContacts: string = '';
  @LocalStorageProp('speedDialCardH') speedDialCardH: number = 0;

  onSubscriptionListDebounce() {
    HiLog.i(TAGSD, `subscriptionList formId: ${this.formId}, length: ${this.subscriptionList?.length}`);
    if (this.subscriptionList === null) {
      HiLog.w(TAGSD, `[subscriptionList] is empty formId: ${this.formId}`);
      return;
    }
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'updateContactsList',
        formName: FORMNAMESD
      }
    });
  }

  onEditContacts() {
    HiLog.i(TAGSD, `editContacts formId: ${this.formId}, length: ${this.editContacts.length}`);
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'updateTemplate',
        formName: FORMNAMESD
      }
    });
  }

  aboutToAppear() {
    HiLog.i(TAGSD, `aboutToAppear`);
  }

  contactListChange() {
    let contactsData: SpeedDialDataType[] = []
    try {
      contactsData = JSON.parse(this.contacts);
      HiLog.i(TAGSD, `contact formId: ${this.formId} ContactsDataLength: ${contactsData?.length}`);
    } catch (e) {
      HiLog.e(TAGSD, 'parse ContactsData failed');
    }
    if (contactsData === this.ContactsList) {
      return;
    }
    this.ContactsList = [];
    this.ContactsList = contactsData;
  }

  /**
   * 跳转到添加页面
   */
  private jumpToAddPage() {
    HiLog.i(TAGSD, `jumpToAddPage formId: ${this.formId}`);
    postCardAction(this, {
      'action': 'message',
      'params': {
        flag: 'jumpToAddPage',
        abilityName
      }
    })
  }

  /**
   * 调起其他页面
   */
  private clickToDial(contactId: string) {
    HiLog.i(TAGSD, `clickToDial contactId: ${contactId}`);
    const action: LooseObject = {
      'action': 'message',
      'params': {
        'contactId': contactId,
        'flag': 'dialNumber',
        'cardType': dotCommon.eventParam.SPEED_DIAL_CARD_TYPE
      }
    }
    postCardAction(this, action);
  }

  private clickToDetail(item: SpeedDialDataType) {
    HiLog.i(TAGSD, `clickToDetail contactId: ${item.contactId}`);
    const action: LooseObject = {
      'action': 'message',
      'params': {
        'contactId': item.contactId,
        'phoneList': item.phones,
        'flag': 'shortCutCardDetail',
        'cardType': dotCommon.eventParam.SPEED_DIAL_CARD_TYPE
      }
    }
    postCardAction(this, action);
  }

  private clickToDetailNew(item: SpeedDialDataType) {
    HiLog.w(TAGSD, `clickToDetailNew start`);
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
    postCardAction(this, action);
    //处理其他操作
    this.clickToDetail(item);
    HiLog.w(TAGSD, `clickToDetailNew end`);
  }

  @Builder
  cardBg() {
    Column() {
    }.backgroundColor($r('app.color.color_contact_card_bg'))
    .opacity(1)
    .height('100%')
    .width('100%')
  }

  @Builder
  ContactsListLength0() {
    RelativeContainer() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(`${this.speedDialCardH * this.ADD_BTN_SIZE_RATION * this.ADD_BTN_SYMBOL}px`)
          .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
      }
      .backgroundColor($r('app.color.skin_ohos_id_color_activated'))
      .height(`${this.speedDialCardH * this.ADD_BTN_SIZE_RATION}px`)
      .aspectRatio(1)
      .id('card_add_btn')
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        top: { anchor: '__container__', align: VerticalAlign.Top}
      })
      .offset({
        top: `${this.speedDialCardH * this.ADD_BTN_SIZE_RATION}px`
      })

      Text($r('app.string.Speed_dial'))
        .fontSize(FormUtils.ohos_id_text_size_body2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(FormUtils.ohos_id_color_text_primary)
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.id_card_title_margin_top'))
        .height($r('app.float.id_card_title_margin_top'))
        .maxLines(this.MAX_LINES)
        .id('card_speed_dial_text')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .offset({
          bottom: `${this.BOTTOM_PERCENTAGE * this.speedDialCardH}px`
        })
    }
    .height('100%')
    .width('100%')
    .onClick(() => {
      this.jumpToAddPage()
    })
  }

  @Builder
  ContactsListLength1() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        cardHead({contactListItem: this.ContactsList[0], h: `${this.speedDialCardH * 0.4 * 0.4}px`,
          radius: this.speedDialCardH * 0.4 / 2})

        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize(10)
            .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
        }
        .stateEffect(false)
        .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
        .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
        .width(16)
        .height(16)
        .margin({ right: $r('sys.float.padding_level4') })
      }
      .height(`${this.speedDialCardH * 0.4}px`)
      .aspectRatio(1)
      .margin({ top: `${this.speedDialCardH * 0.2}px` })

      Text(this.ContactsList[0]?.showName)
        .fontSize(FormUtils.ohos_id_text_size_body2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(FormUtils.ohos_id_color_text_primary)
        .fontWeight(FontWeight.Medium)
        .lineHeight(19)
        .height(19)
        .minFontSize(FormUtils.ohos_id_text_size_body3)
        .maxLines(this.MAX_LINES)
        .margin({ bottom: $r('sys.float.padding_level8') })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .onClick(() => {
      if (this.ContactsList.length <= 0) {
        return
      }
      let item = this.ContactsList[0]
      HiLog.w('yf1-----', item.contactId, this.title);
      if (this.isHasVoiceCapability) {
        this.clickToDial(item.contactId);
      } else {
        this.clickToDetailNew(item);
      }
    })
  }

  @Builder
  ContactsListLength2() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          cardHead({contactListItem: this.ContactsList[0], h: `${this.speedDialCardH * 0.35 * 0.4}px`,
            radius: this.speedDialCardH * 0.35 / 2})

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.phone_fill'))
              .fontSize(10)
              .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
          }
          .stateEffect(false)
          .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
          .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
          .width(16)
          .height(16)
        }
        .height(`${this.speedDialCardH * 0.35}px`)
        .aspectRatio(1)
        .margin({ top: $r('sys.float.padding_level6') })

        Text(this.ContactsList[0]?.showName)
          .fontSize(FormUtils.ohos_id_text_size_body2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(FormUtils.ohos_id_color_text_primary)
          .fontWeight(FontWeight.Medium)
          .lineHeight(19)
          .height(19)
          .maxLines(this.MAX_LINES)
          .margin({ left: $r('sys.float.padding_level4'), top: $r('sys.float.padding_level6') })
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height('50%')
      .width('100%')
      .onClick(() => {
        let item = this.ContactsList[0]
        HiLog.w(TAGSD, item.contactId, this.title);
        if (this.isHasVoiceCapability) {
          this.clickToDial(item.contactId);
        } else {
          this.clickToDetailNew(item);
        }
      })

      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          cardHead({contactListItem: this.ContactsList[1], h: `${this.speedDialCardH * 0.35 * 0.4}px`,
            radius: this.speedDialCardH * 0.35 / 2})

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.phone_fill'))
              .fontSize(10)
              .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
          }
          .stateEffect(false)
          .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
          .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
          .width(16)
          .height(16)
        }
        .height(`${this.speedDialCardH * 0.35}px`)
        .aspectRatio(1)
        .margin({ bottom: $r('sys.float.padding_level6') })

        Text(this.ContactsList[1]?.showName)
          .fontSize(FormUtils.ohos_id_text_size_body2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(FormUtils.ohos_id_color_text_primary)
          .fontWeight(FontWeight.Medium)
          .lineHeight(19)
          .height(19)
          .maxLines(this.MAX_LINES)
          .margin({ left: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level6') })
          .layoutWeight(1)
      }
      .height('50%')
      .width('100%')
      .onClick(() => {
        let item = this.ContactsList[1]
        HiLog.w(TAGSD, item.contactId, this.title);
        if (this.isHasVoiceCapability) {
          this.clickToDial(item.contactId);
        } else {
          this.clickToDetailNew(item);
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  @Builder
  ContactsListLength3() {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          cardHead({contactListItem: this.ContactsList[0], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
            radius: this.speedDialCardH * 0.25 / 2})

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.phone_fill'))
              .fontSize(10)
              .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
          }
          .stateEffect(false)
          .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
          .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
          .width(16)
          .height(16)
          .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
        }
        .height(`${this.speedDialCardH * 0.25}px`)
        .aspectRatio(1)

        Text(this.ContactsList[0]?.showName)
          .fontSize(FormUtils.ohos_id_text_size_caption)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(FormUtils.ohos_id_color_text_primary)
          .fontWeight(FontWeight.Medium)
          .lineHeight(13)
          .height(14)
          .fontFamily('HarmonyHeiTi')
          .maxLines(this.MAX_LINES)
          .margin({ top: $r('sys.float.padding_level1') })
      }
      .height('50%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.ContactsList.length <= 0) {
          return
        }
        let item = this.ContactsList[0]
        HiLog.w('yf1-----', item.contactId, this.title);
        if (this.isHasVoiceCapability) {
          this.clickToDial(item.contactId);
        } else {
          this.clickToDetailNew(item);
        }
      })

      Row({ space: 4 }) {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[1], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[1]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[1]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })

        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[2], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[2]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[2]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })
      }
      .height('50%')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding($r('sys.float.padding_level6'))
  }

  @Builder
  ContactsListLength4() {
    Column() {
      Row({ space: 4 }) {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[0], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[0]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[0]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })

        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[1], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[1]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[1]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })
      }
      .height('50%')
      .width('100%')

      Row({ space: 4 }) {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[2], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[2]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[2]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })

        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            cardHead({contactListItem: this.ContactsList[3], h: `${this.speedDialCardH * 0.25 * 0.4}px`,
              radius: this.speedDialCardH * 0.25 / 2})

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(10)
                .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
            }
            .stateEffect(false)
            .visibility(this.isHasVoiceCapability ? Visibility.Visible : Visibility.None)
            .backgroundColor($r('app.color.skin_ohos_id_color_connected'))
            .width(16)
            .height(16)
            .margin({ bottom: $r('app.float.SpeedDial_margin_2'), right: $r('app.float.SpeedDial_margin_4') })
          }
          .height(`${this.speedDialCardH * 0.25}px`)
          .aspectRatio(1)

          Text(this.ContactsList[3]?.showName)
            .fontSize(FormUtils.ohos_id_text_size_caption)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .lineHeight(13)
            .height(14)
            .fontFamily('HarmonyHeiTi')
            .maxLines(this.MAX_LINES)
            .margin({ top: $r('sys.float.padding_level1') })
        }
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let item = this.ContactsList[3]
          HiLog.w('yf1-----', item.contactId, this.title);
          if (this.isHasVoiceCapability) {
            this.clickToDial(item.contactId);
          } else {
            this.clickToDetailNew(item);
          }
        })
      }
      .height('50%')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding($r('sys.float.padding_level6'))
  }

  build() {
    Stack() {
      this.cardBg();
      Column() {
        if (this.ContactsList.length === 0) {
          this.ContactsListLength0()
        }
        if (this.ContactsList.length === 1) {
          this.ContactsListLength1()
        }
        if (this.ContactsList.length === 2) {
          this.ContactsListLength2()
        }
        if (this.ContactsList.length === 3) {
          this.ContactsListLength3()
        }
        if (this.ContactsList.length === 4) {
          this.ContactsListLength4()
        }
      }
      .height('100%')
      .width('100%')
    }
    .backgroundColor($r('app.color.color_contact_card_bg'))
    .height('100%')
    .width('100%')
  }
}

@Component
struct cardHead {
  @Prop contactListItem: SpeedDialDataType;
  @Prop h: string;
  @Prop radius: number;
  build() {
    Button({ type: ButtonType.Circle }) {
      Stack() {
        if (!StringUtil.isEmpty(this.contactListItem.base64Str)) {
          Image(this.contactListItem.base64Str)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Fill)
            .backgroundColor(this.contactListItem.portraitColor)
            .borderRadius(this.radius)
            .onError(() => {
              HiLog.w(TAGSD, `Image onError`)
              this.contactListItem.base64Str = '';
            })
        }
        if (StringUtil.isEmpty(this.contactListItem.nameSuffix) && StringUtil.isEmpty(this.contactListItem.base64Str)) {
          Image(StringUtil.isEmpty(this.contactListItem.portraitPath) ?
          FormUtils.ic_user_portrait : this.contactListItem.portraitPath)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
            .borderRadius(this.radius)
        }
        if (!StringUtil.isEmpty(this.contactListItem.nameSuffix) &&
        StringUtil.isEmpty(this.contactListItem.base64Str)) {
          Text(this.contactListItem.nameSuffix.toUpperCase())
            .fontSize(this.h)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
            .fontFamily('HarmonyHeiTi')
            .textAlign(TextAlign.Center)
            .width('100%')
            .height('100%')
        }
      }
      .opacity($r('app.float.float_cardHead_opacity'))
    }
    .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
  }
}

export class FormUtils {
  public static Speed_dial: Resource = $r('app.string.Speed_dial');
  public static detail_immersive: Resource = $r('app.string.detail_immersive');
  public static Card_add: Resource = $r('app.string.Card_add');
  public static ic_user_portrait: Resource = $r('app.media.ic_user_portrait');
  public static ohos_id_text_size_body1: Resource = $r('sys.float.Body_L');
  public static ohos_id_text_size_body2: Resource = $r('sys.float.Body_M');
  public static ohos_id_text_size_body3: Resource = $r('sys.float.Body_S');
  public static ohos_id_text_size_caption: Resource = $r('sys.float.ohos_id_text_size_caption');
  public static ohos_id_color_text_primary: Resource = $r('app.color.skin_ohos_id_color_text_primary');
  public static ohos_fa_background_blur: Resource = $r('app.color.skin_ohos_fa_background_blur');
  public static ohos_id_color_text_secondary: Resource = $r('app.color.skin_font_secondary')
}

interface NewContactItem {
  displayName: string | number
  id: string
}

class SpeedDialDataType {
  public contactId: string = '';
  public displayName: string = '';
  public nameSuffix: string = '';
  public portraitColor: PortraitColorType = new PortraitColorType();
  public phones: PhonesType[] = [];
  public portraitPath: string = '';
  public showName: string = '';
  public photoFirstName?: string = '';
  public id?: number = 0;
  public base64Str?: string = '';
  public formId: string = ''
}

class PortraitColorType {
  public id: number = 0;
  public type: number = 0;
  public params: string[] = [];
  public bundleName: string = 'com.ohos.contacts';
  public moduleName: string = 'entry';
}

class PhonesType {
  public num: string = '';
  public id: string = '';
  public numType: string = '';
  public primary: boolean = false;
  public dataId: number = 0;
}

class MorandiColor {
  public static readonly Color: Resource[] = [
    $r('sys.color.ohos_id_color_special1'),
    $r('sys.color.ohos_id_color_special2'),
    $r('sys.color.ohos_id_color_special4'),
    $r('sys.color.ohos_id_color_special11'),
    $r('sys.color.ohos_id_color_special9'),
    $r('sys.color.ohos_id_color_special7')];
  public static readonly detailColor: string[] = ['#E1DAED', '#D9E4EE', '#DAE2D5', '#E8E1D0', '#EBDFDA', '#E9DEE4'];
}

class StringUtil {
  static isEmpty(str?: string): boolean {
    return str == 'undefined' || !str || !new RegExp('[^\\s]').test(str);
  }
}