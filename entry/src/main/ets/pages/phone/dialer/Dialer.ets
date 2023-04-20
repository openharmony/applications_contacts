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

import CallRecord from '../../dialer/callRecord/CallRecord';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import DialerPresenter from './../../../presenter/dialer/DialerPresenter';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { DialerButtonView } from "../../../component/dialer/DialerButtonView";

const TAG = 'Dialer';

@Component
struct DialButton {
  @State button_number: string = ''
  @State button_char: string = ''
  @Link mPresenter: DialerPresenter

  build() {
    Column() {
      Button() {
        Column() {
          if (`${this.button_number}` == '*') {
            Image($r("app.media.symbol_phone"))
              .width(24)
              .height(24)
          } else if (`${this.button_number}` == '#') {
            Image($r("app.media.symbols_phone"))
              .width(24)
              .height(24)
          } else {
            Text(`${this.button_number}`)
              .fontSize(25)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
          }
          if ((this.button_char == 'ic')) {
            Image($r("app.media.ic_contacts_voicemail_mini"))
              .width(14)
              .height(14)
          } else if ((this.button_char == '+')) {
            Text(`${this.button_char}`)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize(17.5)
          } else {
            Text(`${this.button_char}`)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize($r("sys.float.ohos_id_text_size_chart1"))
          }
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .type(ButtonType.Circle)
      .height('100%')
      .width('100%')
      .onClick(() => {
        this.mPresenter.ifNeedSpace();
        AppStorage.SetOrCreate("tele_number", AppStorage.Get("tele_number") + this.button_number);
        this.mPresenter.all_number += this.button_number
        this.mPresenter.viewNumberTextProc();
        this.mPresenter.playAudio(this.button_number);
      })
    }.height($r("app.float.dialer_calllog_item_height"))
    .width('33.33%')
  }
}

@Component
struct DialPad {
  @Link mPresenter: DialerPresenter;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '1', button_char: 'ic', mPresenter: $mPresenter, })

        DialButton({ button_number: '2', button_char: 'ABC', mPresenter: $mPresenter, })

        DialButton({ button_number: '3', button_char: 'DEF', mPresenter: $mPresenter, })
      }.layoutWeight(1)

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '4', button_char: 'GHI', mPresenter: $mPresenter, })

        DialButton({ button_number: '5', button_char: 'JKL', mPresenter: $mPresenter, })

        DialButton({ button_number: '6', button_char: 'MNO', mPresenter: $mPresenter, })
      }.layoutWeight(1)

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '7', button_char: 'PQRS', mPresenter: $mPresenter, })

        DialButton({ button_number: '8', button_char: 'TUV', mPresenter: $mPresenter, })

        DialButton({ button_number: '9', button_char: 'WXYZ', mPresenter: $mPresenter, })
      }.layoutWeight(1)

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '*', button_char: '(P)', mPresenter: $mPresenter, })

        DialButton({ button_number: '0', button_char: '+', mPresenter: $mPresenter, })

        DialButton({ button_number: '#', button_char: '(W)', mPresenter: $mPresenter, })
      }.layoutWeight(1)
    }
    .width("100%")
    .height(240)
    .borderRadius(16)
  }
}

@Component
export default struct Call {
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance()
  @StorageLink("tele_number") tele_number: string = "";
  @StorageLink("haveMultiSimCard") @Watch("onSimChanged") haveMultiSimCard: boolean = false;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State panWidth: number = 0;
  @StorageLink("showDialBtn") @Watch('onShowDialBtnChange') showDialBtn: boolean = false;

  onSimChanged() {
    HiLog.i(TAG, "haveMultiSimCard change:" + JSON.stringify(this.haveMultiSimCard));
    this.mPresenter.dialerButtonWidth = this.haveMultiSimCard ? (this.mPresenter.btnShow ? 48 : 210) :
      (this.mPresenter.btnShow ? 48 : 56);
  }

  onShowDialBtnChange() {
    HiLog.i(TAG, 'onShowDialBtnChange ' + this.showDialBtn);
    if (this.showDialBtn) {
      HiLog.i(TAG, 'show DialBtn ');
      this.mPresenter.callBtnClick = true;
      animateTo({
        duration: 200,
        curve: Curve.Linear,
        onFinish: () => {
          this.mPresenter.callBtnClick = false;
        }
      }, () => {
        this.mPresenter.call_p = 0;
        this.mPresenter.call_y = 0;
        this.mPresenter.moveY = 0
        this.mPresenter.dialerButtonWidth = this.haveMultiSimCard ? 210 : 56;
        this.mPresenter.dialerButtonHeight = 56
      })
      this.mPresenter.btnShow = false;
    } else {
      HiLog.i(TAG, 'hide DialBtn ');
      this.mPresenter.btnShow = true;
      animateTo({ duration: 200, curve: Curve.Linear }, () => {
        this.mPresenter.call_p = 134;
        this.mPresenter.call_y = 6;
        this.mPresenter.moveY = 392;
        this.mPresenter.dialerButtonWidth = 48;
        this.mPresenter.dialerButtonHeight = 48;
      })
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear CallTablet ');
    this.showDialBtn = true;
    this.mPresenter.aboutToAppear();
  }

  aboutToDisappear() {
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.tele_number.length > 0) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            Text(`${this.tele_number}`)
              .fontSize(this.mPresenter.tele_num_size)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .maxLines(1)
          }
          .width('100%')
          .height($r("app.float.dialer_telephone_number_height"))
        }
        if (this.tele_number.length === 0) {
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
              Image($r("app.media.ic_public_more"))
                .width($r("app.float.id_card_image_small"))
                .height($r("app.float.id_card_image_small"))
                .margin({ right: $r("app.float.id_card_margin_max") })
                .opacity(0.4)
            }
            .width('100%')
            .height($r("app.float.id_item_height_large"))

            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
              Text($r("app.string.dialer"))
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .margin({ left: $r("app.float.id_card_margin_max") })
            }
            .width('100%')
            .height($r("app.float.id_item_height_large"))

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
              if (this.mPresenter.callBtnClick) {
                return;
              }
              this.mPresenter.panelShow = false;
              this.showDialBtn = false;
            })
          }
          .width('100%')
          .height('100%')
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')

      Column() {
        DialerButtonView({
          mPresenter: $mPresenter,
        }).visibility(this.mPresenter.btnShow ? Visibility.None : Visibility.Visible)
        Button() {
          Image($r("app.media.ic_contacts_dial"))
            .width($r("app.float.id_card_margin_max"))
            .height($r("app.float.id_card_margin_max"))
        }
        .width(this.mPresenter.dialerButtonWidth)
        .height(this.mPresenter.dialerButtonHeight)
        .backgroundColor($r('sys.color.ohos_id_color_connected'))
        .onClick(() => {
          this.showDialBtn = true;
        })
        .visibility(this.mPresenter.btnShow ? Visibility.Visible : Visibility.None);

      }
      .justifyContent(FlexAlign.Center)
      .width(this.haveMultiSimCard ? "210vp" : $r("app.float.dialer_calllog_item_height"))
      .height($r("app.float.dialer_calllog_item_height"))
      .margin({ bottom: 20 })
      .zIndex(3)
      .translate({ x: this.mPresenter.call_p === 0 ? 0 : this.panWidth / 2 - 48, y: this.mPresenter.call_y })

      Stack({ alignContent: Alignment.Bottom }) {
        if (this.tele_number.length >= 3 && !this.mPresenter.btnShow) {
          Row() {
            Button() {
              Column() {
                Image($r("app.media.ic_public_add"))
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
                  .margin({ bottom: this.curBp === 'lg' ? 0 : '3vp' })
                Text($r("app.string.new_contact"))
                  .fontSize($r("sys.float.ohos_id_text_size_caption1"))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
              }
            }
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .height($r("app.float.id_item_height_large"))
            .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
            .onClick(() => {
              this.mPresenter.jumpToAccountants();
            })

            //This component is temporarily shielded because there is no requirement currently.
            //            Button() {
            //              Column() {
            //                Image($r("app.media.ic_public_contacts_group"))
            //                  .width($r("app.float.id_card_image_small"))
            //                  .height($r("app.float.id_card_image_small"))
            //                  .margin({ bottom: this.curBp === 'lg' ? 0 : '3vp' })
            //                Text($r("app.string.save_to_existing_contacts"))
            //                  .fontSize($r("sys.float.ohos_id_text_size_caption1"))
            //                  .fontWeight(FontWeight.Medium)
            //                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
            //              }
            //            }
            //            .layoutWeight(1)
            //            .type(ButtonType.Normal)
            //            .height($r("app.float.id_item_height_large"))
            //            .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))

            Button() {
              Column() {
                Image($r("app.media.ic_public_message"))
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
                  .margin({ bottom: this.curBp === 'lg' ? 0 : '3vp' })
                Text($r("app.string.send_messages"))
                  .fontSize($r("sys.float.ohos_id_text_size_caption1"))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
              }
            }
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .height($r("app.float.id_item_height_large"))
            .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
            .onClick(() => {
              this.mPresenter.sendMessage();
            })
          }
          .width('100%')
          .height($r("app.float.id_item_height_large"))
          .offset({ x: 0, y: -336 })
          .zIndex(3)
          .padding({ top: 4 })
        }
        Column() {

          DialPad({ mPresenter: $mPresenter })

          Row() {
            Column() {
              Button() {
                Image($r("app.media.ic_contacts_dialer"))
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
              }
              .type(ButtonType.Normal)
              .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
              .width($r("app.float.dialer_calllog_item_height"))
              .height($r("app.float.dialer_calllog_item_height"))
              .onClick(() => {
                this.showDialBtn = false;
              })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Blank().layoutWeight(1)
            Blank().layoutWeight(1).visibility(this.haveMultiSimCard ? Visibility.Visible : Visibility.None)
            Column() {
              Button() {
                Image($r("app.media.ic_contacts_delete"))
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
              }
              .type(ButtonType.Normal)
              .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
              .width($r("app.float.dialer_calllog_item_height"))
              .height($r("app.float.dialer_calllog_item_height"))
              .opacity(this.tele_number.length > 0 ? 1 : 0.5)
              .enabled(this.tele_number.length > 0 ? true : false)
              .gesture(
              LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
                .onAction((event: GestureEvent) => {
                  AppStorage.SetOrCreate("tele_number", '');
                  this.mPresenter.all_number = '';
                  IndexPresenter.getInstance().editPhoneNumber = "";
                })
              )
              .onClick(() => {
                this.mPresenter.isClickDelete = true;
                this.mPresenter.pressVibrate();
                this.mPresenter.all_number = this.mPresenter.all_number.substr(0, this.mPresenter.all_number.length - 1)
                this.mPresenter.deleteTeleNum();
                this.mPresenter.deleteAddSpace();
                this.mPresenter.viewNumberTextProc();
              })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .alignItems(VerticalAlign.Top)
          .height(80)
        }
        .margin({ top: this.tele_number.length >= 3 ? 55.6 : 0 })
        .width('100%')
        .zIndex(this.mPresenter.panelShow ? 2 : -1)
      }
      .width("100%")
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .clip(new Rect(this.tele_number.length >= 3 ? {
                                                      width: '100%',
                                                      height: '392',
                                                      radius: [[24, 24], [24, 24], [0, 0], [0, 0]]
                                                    } : {
                                                          width: '100%',
                                                          height: '336',
                                                          radius: [[24, 24], [24, 24], [0, 0], [0, 0]]
                                                        }))
      .zIndex(2)
      .offset({ y: this.mPresenter.moveY })
      .height(this.tele_number.length >= 3 ? 392 : 336)
      .padding(this.curBp === 'lg' ? {} : { right: 24, left: 24 })
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
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.panWidth = newArea.width as number;
    })
  }
}