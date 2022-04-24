/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import CallRecord from './callRecord/CallRecord'
import resourceManager from '@ohos.resourceManager';
import HiLog from '../../../util/Hilog';
import DialerPresenter from './../../../presenter/dialer/DialerPresenter';
import { DialerInitialPage } from '../../../component/dialer/DialerInitialPage';
import PreferencesUtil from './../../../util/PreferencesUtil'

const NUM_BUTTON_BASIC_LENGTH = 50;
const DIALER_BUTTON_MARGIN = 20;
const TAG = 'Dialer';
const DENSITY = 1.5;

@Component
struct DialButton {
  @Prop button_number: string
  @Prop button_char: string
  @Link mPresenter: DialerPresenter

  build() {
    Column() {
      Button() {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text(`${this.button_number}`)
            .fontSize(25 * DENSITY)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
          if ((this.button_char == 'ic')) {
            Image($r("app.media.ic_contacts_voicemail_mini"))
              .width(15 * DENSITY)
              .height(15 * DENSITY)
          } else {
            Text(`${this.button_char}`)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize(10 * DENSITY)
          }
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
      .width('100%')
      .onClick(() => {
        this.mPresenter.ifNeedSpace();
        this.mPresenter.tele_number += this.button_number
        this.mPresenter.all_number += this.button_number
        this.mPresenter.viewNumberTextProc();
        this.mPresenter.playAudio(this.button_number);
      })
    }
    .flexShrink(1)
  }
}

@Component
struct DialPad {
  @Link mPresenter: any;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '1', button_char: 'ic', mPresenter: $mPresenter, })

        DialButton({ button_number: '2', button_char: 'ABC', mPresenter: $mPresenter, })

        DialButton({ button_number: '3', button_char: 'DEF', mPresenter: $mPresenter, })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '4', button_char: 'GHI', mPresenter: $mPresenter, })

        DialButton({ button_number: '5', button_char: 'JKL', mPresenter: $mPresenter, })

        DialButton({ button_number: '6', button_char: 'MNO', mPresenter: $mPresenter, })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '7', button_char: 'PQRS', mPresenter: $mPresenter, })

        DialButton({ button_number: '8', button_char: 'TUV', mPresenter: $mPresenter, })

        DialButton({ button_number: '9', button_char: 'WXYZ', mPresenter: $mPresenter, })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '*', button_char: '(P)', mPresenter: $mPresenter, })

        DialButton({ button_number: '0', button_char: '+', mPresenter: $mPresenter, })

        DialButton({ button_number: '#', button_char: '(W)', mPresenter: $mPresenter, })
      }.margin({ top: DIALER_BUTTON_MARGIN })
    }.width("100%")
  }
}

@Component
export default struct Call {
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance()
  private menuRes: Resource[] = [$r("app.string.call_setting_type_paste"),
  $r("app.string.call_setting_type_batch_delete"),
  $r("app.string.call_setting_type_harassment_interception"),
  $r("app.string.call_setting_type_setting")];
  @State private callmenu: any = [{ value: "", action: () => {
  } }];

  private aboutToAppear(): void {
    let tmpPhoneMenu = [];
    this.menuRes.forEach(element => {
      tmpPhoneMenu.push({});
    });
    this.callmenu = tmpPhoneMenu;
    resourceManager.getResourceManager().then(result => {
      this.menuRes.forEach((element, i) => {
        result.getString(element.id, (err, typeName) => {
          HiLog.i(TAG, typeName);
          this.callmenu[i] = {
            value: typeName,
            action: () => {
            }
          };
        });
      });
    });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.mPresenter.tele_number.length > 0) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            Text(`${this.mPresenter.tele_number}`)
              .fontSize(this.mPresenter.tele_num_size * DENSITY)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .maxLines(1)
          }
          .width('100%')
          .height($r("app.float.dialer_telephone_number_height"))
        }
        if (this.mPresenter.tele_number.length === 0) {
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
              Button() {
                Image($r("app.media.ic_public_more"))
                  .width(25 * DENSITY)
                  .height(25 * DENSITY)
              }
              .width(35 * DENSITY)
              .height(35 * DENSITY)
              .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
              .margin({ right: 30 * DENSITY, top: 15 * DENSITY })
              .type(ButtonType.Normal)
              .visibility(Visibility.Hidden)
            }
            .width('100%')

            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
              Text($r("app.string.dialer"))
                .fontSize(25 * DENSITY)
                .height(35 * DENSITY)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .margin({ left: 25 * DENSITY })
            }
            .width('100%')

            if (PreferencesUtil.isUsed()) {
              Flex({
                direction: FlexDirection.Column,
                alignItems: ItemAlign.Center,
                justifyContent: FlexAlign.Center
              }) {
                CallRecord()
              }
              .height('100%')
              .zIndex(1)
              .onTouch(() => {
                this.mPresenter.btnShow = true;
                this.mPresenter.panelShow = false;
                animateTo({ duration: 500, curve: Curve.Linear }, () => {
                  this.mPresenter.dialer_w = 20 * DENSITY;
                  this.mPresenter.dialer_h = 20 * DENSITY;
                  this.mPresenter.call_w = 40 * DENSITY;
                  this.mPresenter.call_h = 40 * DENSITY;
                  this.mPresenter.call_p = 130 * DENSITY;
                  this.mPresenter.moveY = 500;
                  this.mPresenter.moveX = 0;
                })
              })
            } else {
              DialerInitialPage()
            }

          }
          .width('100%')
          .height('100%')
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')

      Column() {
        Blank()
        Button() {
          Image(this.mPresenter.btnShow ? $r("app.media.keypad_white") : $r("app.media.ic_public_phone_filled_white"))
            .width($r("app.float.id_card_margin_xxxxl"))
            .height($r("app.float.id_card_margin_xxxxl"))
        }
        .width($r("app.float.id_item_height_large"))
        .height($r("app.float.id_item_height_large"))
        .backgroundColor($r('sys.color.ohos_id_color_connected'))
        .translate({ x: this.mPresenter.call_p })
        .onClick(() => {
          if (this.mPresenter.btnShow) {
            animateTo({
              duration: 500,
              curve: Curve.Linear,
              onFinish: () => {
              }
            }, () => {
              this.mPresenter.call_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.mPresenter.call_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.mPresenter.dialer_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.mPresenter.dialer_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.mPresenter.call_p = 0;
              this.mPresenter.moveX = 0;
              this.mPresenter.moveY = 0
            })
            this.mPresenter.btnShow = false;
          } else {
            if (this.mPresenter.tele_number.length > 0) {
              this.mPresenter.dialing(this.mPresenter.all_number);
              this.mPresenter.tele_number = '';
              this.mPresenter.all_number = '';
            }
          }
        })

        Blank()
      }
      .width(60 * DENSITY)
      .height('10%')
      .zIndex(3)

      Stack({ alignContent: Alignment.Bottom }) {
        if (this.mPresenter.tele_number.length >= 3 && !this.mPresenter.btnShow) {
          Column() {
            Flex({
              direction: FlexDirection.Row,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Button() {
                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Center,
                  justifyContent: FlexAlign.Center
                }) {
                  Image($r("app.media.ic_public_add"))
                    .width(20 * DENSITY)
                    .height(20 * DENSITY)
                  Text($r("app.string.new_contact"))
                    .fontSize(10 * DENSITY)
                    .width(52 * DENSITY)
                }
              }
              .layoutWeight(1)
              .type(ButtonType.Normal)
              .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
              .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
              .onClick(() => {
                this.mPresenter.jumpToAccountants();
              })

              Button() {
                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Center,
                  justifyContent: FlexAlign.Center
                }) {
                  Image($r("app.media.people_black"))
                    .width(20 * DENSITY)
                    .height(20 * DENSITY)
                  Text($r("app.string.save_to_existing_contacts"))
                    .fontSize(10 * DENSITY)
                    .width(82 * DENSITY)
                }
              }
              .layoutWeight(1)
              .type(ButtonType.Normal)
              .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
              .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))

              Button() {
                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Center,
                  justifyContent: FlexAlign.Center
                }) {
                  Image($r("app.media.ic_public_message"))
                    .width(20 * DENSITY)
                    .height(20 * DENSITY)
                  Text($r("app.string.send_messages"))
                    .fontSize(10 * DENSITY)
                    .width(42 * DENSITY)
                }
              }
              .layoutWeight(1)
              .type(ButtonType.Normal)
              .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
              .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
              .onClick(() => {
                this.mPresenter.sendMessage();
              })
            }
            .margin({ top: 10 * DENSITY })

          }
          .width('100%')
          .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
          .offset({ x: 0, y: -470 })
          .zIndex(3)
          .borderRadius(20)
        }
        Column() {

          DialPad({ mPresenter: $mPresenter })

          Row() {
            Button() {
              Image($r("app.media.ic_contacts_dialer"))
                .width(25 * DENSITY)
                .height(25 * DENSITY)
            }
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
            .width(NUM_BUTTON_BASIC_LENGTH * DENSITY)
            .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
            .onClick(() => {
              this.mPresenter.tele_number.length < 0
              this.mPresenter.btnShow = true;
              animateTo({ duration: 500, curve: Curve.Linear }, () => {
                this.mPresenter.dialer_w = 20 * DENSITY;
                this.mPresenter.dialer_h = 20 * DENSITY;
                this.mPresenter.call_w = 40 * DENSITY;
                this.mPresenter.call_h = 40 * DENSITY;
                this.mPresenter.call_p = 130 * DENSITY;
                this.mPresenter.moveY = 500;
                this.mPresenter.moveX = 0
              })
            })

            Text().layoutWeight(1)
            Button() {
              Image($r("app.media.ic_contacts_Delete_m"))
                .width(25 * DENSITY)
                .height(25 * DENSITY)
            }
            .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
            .type(ButtonType.Normal)
            .width(NUM_BUTTON_BASIC_LENGTH * DENSITY)
            .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
            .layoutWeight(1)
            .opacity(this.mPresenter.tele_number.length > 0 ? 1 : 0.5)
            .enabled(this.mPresenter.tele_number.length > 0 ? true : false)
            .gesture(
            LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
              .onAction((event: GestureEvent) => {
                this.mPresenter.tele_number = '';
                this.mPresenter.all_number = '';
              })
            )
            .onClick(() => {
              this.mPresenter.pressVibrate();
              this.mPresenter.all_number = this.mPresenter.all_number.substr(0, this.mPresenter.all_number.length - 1)
              this.mPresenter.deleteTeleNum();
              this.mPresenter.deleteAddSpace();
              this.mPresenter.viewNumberTextProc();
            })
          }.margin({ bottom: 10 * DENSITY })
        }
        .zIndex(this.mPresenter.panelShow ? 2 : -1)
      }
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .width("100%")
      .borderRadius($r('app.float.id_corner_radius_card'))
      .zIndex(2)
      .offset({ x: this.mPresenter.moveX, y: this.mPresenter.moveY })
      .height(500)
      .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.Down, distance: 5 })
        .onActionStart(() => {
          this.mPresenter.moveY = 0
        })
      )
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
  }
}