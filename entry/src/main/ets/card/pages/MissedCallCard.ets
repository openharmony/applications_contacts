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
import { numFormat } from '../../util/NumFormat'
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { infoString, contactPage } from '../data/cardData';

let storage = new LocalStorage();
const TAG = 'MissedCallCard';

type ObjType = Record<string, string>;

@Entry(storage)
@Component
struct MissedCallCard {
  readonly ACTION_TYPE: string = 'router';
  readonly MESSAGE: string = 'add detail';
  readonly ABILITY_NAME: string = 'MissedCallCardAbility';
  readonly NO_FAVORITE: number = 0;
  readonly FAVORITE: number = 1;
  @State missedCall: ObjType | undefined = {};
  @State displayName: string = '';
  @State phoneNumber: string = '';
  @LocalStorageProp('settings') @Watch('onWatchToData') settings: string = 'all';
  @LocalStorageProp('callLog') @Watch('onWatchToData') callLog: Array<ObjType> = [];
  @LocalStorageProp('callLogForContact') @Watch('onWatchToMissedCall') callLogForContact: Array<ObjType> = [];
  @LocalStorageProp('contacts') @Watch('onWatchToData') favorites: Array<ObjType> = [];
  @LocalStorageProp('isHasVoiceCapability') isHasVoiceCapability: boolean = true;
  @LocalStorageProp('random') @Watch('onWatchToMissedCall') random: Uint8Array | null = null;

  // 监听未接来电显示范围
  onWatchToData() {
    HiLog.w(TAG, 'callLog-onWatchToData length' + this.callLog.length);
    if (this.callLog.length === 0) {
      this.missedCall = {};
      this.displayName = '';
      this.phoneNumber = '';
      return;
    }
    let newCallLog = this.caml(this.callLog);
    HiLog.w(TAG, 'callLog-onWatchToData newCallLog length' + newCallLog.length);
    HiLog.w(TAG, 'callLog-onWatchToData settings' + this.settings);
    switch (this.settings) {
      case 'all':
        this.missedCall = newCallLog[0];
        this.displayName = this.missedCall.displayName;
        this.phoneNumber = this.missedCall.phoneNumber;
        break;
      case 'contacts':
        const actionContacts: LooseObject = {
          'action': 'message',
          'params': {
            'callLog': newCallLog,
            'contactType': this.NO_FAVORITE,
            'flag': 'getContactByPhones'
          }
        }
        postCardAction(this, actionContacts);
        break;
      case 'favorite':
        const actionFavorite: LooseObject = {
          'action': 'message',
          'params': {
            'callLog': newCallLog,
            'contactType': this.FAVORITE,
            'flag': 'getContactByPhones'
          }
        }
        postCardAction(this, actionFavorite);
        break;
      default:
        this.missedCall = {};
    }
  }

  caml(callLog: Array<ObjType>) {
    let newCallLog: ObjType[] = [];
    callLog.map(item => {
      let newItem: ObjType = {};
      Object.keys(item).forEach(key => {
        let newKey = key.replace(new RegExp('_([a-z])', 'g'), (all, letter: string) => {
          return letter.toUpperCase();
        })
        newItem[newKey] = item[key];
      })
      newCallLog.push(newItem);
    })
    return newCallLog;
  }

  onWatchToMissedCall() {
    HiLog.w(TAG, 'callLog-onWatchToMissedCalla length' + this.callLogForContact.length);
    if (this.callLogForContact.length === 0) {
      this.missedCall = {};
      return;
    }
    this.missedCall = this.callLogForContact.find((item: ObjType) => item.displayName !== '');
    if (this.missedCall) {
      this.displayName = this.missedCall.displayName;
      this.phoneNumber = this.missedCall.phoneNumber;
    } else {
      this.missedCall = {};
    }
  }

  aboutToAppear() {
    HiLog.w(TAG, `callLog length :${this.callLog.length}, setting ${this.settings}`);
  }

  addZWSP(str: string): string {
    const regex = new RegExp('.', 'gu');
    return str.replace(regex, '$&\u200B');
  }

  private jumpToCallLog() {
    HiLog.i(TAG, `jumpToCallLog start,this.isHasVoiceCapability: ${this.isHasVoiceCapability}`);
    let actionData: Record<string, string> = this.isHasVoiceCapability ?
      {
        'pageFlag': 'page_flag_dialer',
      } : {
        'pageFlag': 'page_flag_dialer',
        'isNoMissFormCard': 'true'
      };
    const action: LooseObject = {
      'action': 'router',
      'bundleName': infoString.CONTACT_BUNDLE_NAME,
      'abilityName': infoString.CONTACT_ABILITY_NAME,
      'params': actionData
    }
    postCardAction(this, action);
    HiLog.i(TAG, `onClick jumpToCallLog postCardAction end`);
  }

  // 有未接来电跳转通话记录详情
  private clickToDetailForMessage(missedCall: ObjType) {
    HiLog.w(TAG, `clickToDetailForMessage contactId: ${missedCall?.id}`)
    const action: LooseObject = {
      'action': 'message',
      'params': {
        'phone': this.missedCall?.phoneNumber,
        'callId': this.missedCall?.id,
        'flag': 'missedCallCardDetail',
        'cardType': dotCommon.eventParam.MISSED_CALL_CARD_TYPE
      }
    }
    HiLog.w(TAG, `clickToDetailForMessage doing`)
    postCardAction(this, action);
    this.missedCall = {}
    HiLog.w(TAG, `clickToDetailForMessage end`)

  }

  private clickToDetailForRouter(missedCall: ObjType | undefined) {
    HiLog.w(TAG, `clickToDetailForRouter contactId: ${missedCall?.id}`)
    if (missedCall && this.missedCall?.phoneNumber) {
      let actionData: Record<string, string> = {
        'pageFlag': contactPage.PAGE_FLAG_CONTACT_DETAILS,
        'missedCallId': missedCall?.id,
        'phoneNumber': this.missedCall?.phoneNumber,
        'isFormCard': 'true'
      };

      const action: LooseObject = {
        'action': 'router',
        'bundleName': infoString.CONTACT_BUNDLE_NAME,
        'abilityName': infoString.CONTACT_ABILITY_NAME,
        'params': actionData
      }
      HiLog.w(TAG, `clickToDetailForRouter doing`)
      postCardAction(this, action);
      this.clickToDetailForMessage(missedCall);
      HiLog.w(TAG, `clickToDetailForRouter end`)
    }
  }

  @Builder
  cardIphoneBg() {
    SymbolGlyph($r('sys.symbol.phone_fill'))
      .fontSize($r('app.float.id_card_image_mid'))
      .fontColor([$r('app.color.skin_ohos_id_color_connected')])
      .margin({ right: $r('app.float.SpeedDial_margin_5') })
      .opacity($r('app.float.SpeedDial_opacity_15'))
      .visibility(this.missedCall && this.missedCall.phoneNumber ? Visibility.None : Visibility.Visible)
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

  @Builder
  noMissCall() {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Column() {
          Text(FormUtils.card_missed_call)
            .width('100%')
            .lineHeight($r('app.float.id_card_title_margin_top'))
            .height($r('app.float.id_card_title_margin_top'))
            .minFontSize(JSON.stringify(FormUtils.card_time_msg).length > 16 ? $r('sys.float.Caption_M') :
              FormUtils.ohos_id_text_size_body3)
            .maxFontSize(FormUtils.ohos_id_text_size_body2)
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .maxLines(1)
          Text($r('app.string.card_time_msg', numFormat(24)))
            .width('100%')
            .lineHeight($r('app.float.id_card_margin_xxl'))
            .height($r('app.float.id_card_margin_xxl'))
            .fontSize(FormUtils.ohos_id_text_size_body3)
            .fontColor(FormUtils.ohos_id_color_text_secondary)
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .maxLines(1)
            .minFontSize(FormUtils.ohos_id_text_size_body3)
        }
        .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
      }
      .width('100%')
      .onClick(() => {
        this.jumpToCallLog();
      })
    }
  }

  @Builder
  hasMissCall() {
    Column() {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.addZWSP(this.displayName ? this.displayName : this.phoneNumber))
            .height($r('app.float.id_card_title_margin_top'))
            .fontSize(FormUtils.ohos_id_text_size_body2)
            .fontColor(FormUtils.ohos_id_color_text_primary)
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .minFontSize(FormUtils.ohos_id_text_size_body3)
            .margin({ right:$r('sys.float.padding_level2') })
          Text(FormUtils.missed_call)
            .height($r('app.float.id_card_margin_xxl'))
            .fontSize(FormUtils.ohos_id_text_size_body3)
            .fontColor(FormUtils.ohos_id_color_handup)
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .minFontSize(FormUtils.ohos_id_text_size_body3)
        }.onClick(() => {
          this.clickToDetailForRouter(this.missedCall)
        })
        .layoutWeight(1)

        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize($r('app.float.SpeedDial_height_20'))
            .fontColor([$r('app.color.skin_ohos_id_color_primary_contrary')])
        }
        .width($r('app.float.id_card_margin_xxxxl'))
        .height($r('app.float.id_card_margin_xxxxl'))
        .backgroundColor(FormUtils.ohos_id_color_connected)
        .accessibilityText($r('app.string.accessibility_call'))
        .onClick(() => {
          const action: LooseObject = {
            'action': 'message',
            'params': {
              'phone': this.missedCall?.phoneNumber,
              'id': this.missedCall?.id,
              'flag': 'speedDialByPhone',
              'cardType': dotCommon.eventParam.MISSED_CALL_CARD_TYPE
            }
          }
          postCardAction(this, action);
          HiLog.w(TAG, `onClickToDail id: ${this.missedCall?.id}`)
        })
      }.padding({
        right:$r('sys.float.padding_level6'),
        left:$r('sys.float.padding_level6')
      })
      .width('100%')
    }
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      this.cardBg();
      this.cardIphoneBg()
      if (this.missedCall && this.missedCall.phoneNumber) {
        this.hasMissCall()
      } else {
        this.noMissCall()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_contact_card_bg'))
  }
}

export class FormUtils {
  public static card_time_msg: Resource = $r('app.string.card_time_msg', 24);
  public static card_missed_call: Resource = $r('app.string.card_missed_call');
  public static missed_call: Resource = $r('app.string.missed_call');
  public static ohos_id_text_size_body1: Resource = $r('sys.float.Body_L');
  public static ohos_id_text_size_body2: Resource = $r('sys.float.Body_M');
  public static ohos_id_text_size_body3: Resource = $r('sys.float.Body_S');
  public static ohos_id_color_text_primary: Resource = $r('app.color.skin_ohos_id_color_text_primary');
  public static ohos_id_color_text_secondary: Resource = $r('app.color.skin_ohos_id_color_text_secondary');
  public static ohos_id_color_badge_red: Resource = $r('app.color.skin_warning');
  public static ohos_id_color_handup: Resource = $r('app.color.skin_ohos_id_color_handup');
  public static ohos_id_color_connected: Resource = $r('app.color.skin_ohos_id_color_connected');
}

export class PhonesType {
  public num: string = '';
  public id: string = '';
  public numType: string = '';
  public primary: boolean = false;
  public dataId: number = 0;
}