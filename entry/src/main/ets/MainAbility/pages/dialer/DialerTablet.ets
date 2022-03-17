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
import Utils from '../../util/Utils';
import vibrator from '@ohos.vibrator';
import resourceManager from '@ohos.resourceManager';
import media from '@ohos.multimedia.media';
import fileIO from '@ohos.fileio';
import HiLog from '../../util/Hilog';
import DialUtil from '../../util/DialUtil';
import appStorage from '../../util/AppStorageUtil';
import COMMON from '../../model/common';
import DialerPresenter from './../../presenter/dialer/DialerPresenter';

const TAG = 'DialerTablet'

@Component
struct DialButton {
  // 按键数字
  @Prop button_number: string
  // 按键对应的字符
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
          if (`${this.button_number}` == '*') {
            Image($r("app.media.symbol"))
              .width($r("app.float.dialer_keypad_height"))
              .height($r("app.float.dialer_keypad_width"))
          } else if (`${this.button_number}` == '#') {
            Image($r("app.media.symbols"))
              .width($r("app.float.dialer_keypad_height"))
              .height($r("app.float.dialer_keypad_width"))
          } else if (`${this.button_number}` == '0') {
            Text(`${this.button_number}`)
              .fontSize($r("app.float.dialer_button_number_fontSize"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ top: $r("app.float.dialer_common_very_small_margin1") })
          } else {
            Text(`${this.button_number}`)
              .fontSize($r("app.float.dialer_button_number_fontSize"))
              .fontColor($r('app.color.colorPrimary'))
          }

          if ((this.button_char == 'ic')) {
            Image($r("app.media.ic_contacts_voicemail_mini"))
              .width($r("app.float.dialer_keypad_margin2"))
              .height($r("app.float.dialer_keypad_margin2"))
          } else if ((this.button_char == '+')) {
            Image($r("app.media.ic_public_add"))
              .width($r("app.float.dialer_keypad_margin1"))
              .height($r("app.float.dialer_keypad_margin1"))
          } else {
            Text(`${this.button_char}`)
              .fontSize($r("app.float.dialer_button_char_fontSize"))
              .fontColor($r('app.color.light_colorPrimary'))
          }
        }
      }
      .backgroundColor(Color.White)
      .margin({ right: $r("app.float.dialer_common_margin") })
      .width($r("app.float.dialer_keypad_button_width"))
      .height($r("app.float.dialer_keypad_button_height"))
      .onClick(() => {
        this.mPresenter.pressVibrate();
        this.mPresenter.playAudio(this.button_number);
        this.mPresenter.ifNeedSpace();
        this.mPresenter.tele_number += this.button_number
        this.mPresenter.all_number += this.button_number
        this.mPresenter.viewNumberTextProc();
      })
    }
  }
}

@Component
struct DialPad {
  @Link mPresenter: any;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({
          button_number: '1',
          button_char: 'ic',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '2',
          button_char: 'ABC',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '3',
          button_char: 'DEF',
          mPresenter: $mPresenter,
        })
      }

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({
          button_number: '4',
          button_char: 'GHI',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '5',
          button_char: 'JKL',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '6',
          button_char: 'MNO',
          mPresenter: $mPresenter,
        })
      }

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({
          button_number: '7',
          button_char: 'PQRS',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '8',
          button_char: 'TUV',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '9',
          button_char: 'WXYZ',
          mPresenter: $mPresenter,
        })
      }

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({
          button_number: '*',
          button_char: '(P)',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '0',
          button_char: '+',
          mPresenter: $mPresenter,
        })

        DialButton({
          button_number: '#',
          button_char: '(W)',
          mPresenter: $mPresenter,
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

@Entry
@Component
export default struct CallTablet {
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance()
  menuRes: Resource[] = [$r("app.string.call_setting_type_paste"),
  $r("app.string.call_setting_type_batch_delete"),
  $r("app.string.call_setting_type_harassment_interception"),
  $r("app.string.call_setting_type_setting")];
  @State private callmenu: any = [{ value: "", action: () => {
  } }];

  aboutToAppear() {
    this.getMenu();
    this.mPresenter.aboutToAppear();
  }

  onPageShow() {
    this.mPresenter.onPageShow();
  }

  aboutToDisappear() {
    this.mPresenter.onDestroy();
  }

  // bindMenu的文字
  getMenu() {
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
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {

      Column() {
        if (this.mPresenter.tele_number.length > 0) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              Text(`${this.mPresenter.tele_number}`)
                .fontSize(this.mPresenter.tele_num_size)
                .fontColor($r('app.color.colorPrimary'))
                .maxLines(1)
            }
            .width('100%')
            .height($r("app.float.dialer_telephone_number_height"))

            // 输入完整手机号码时
            if (this.mPresenter.tele_number.length >= 3) {
              Row() {
                Image($r("app.media.ic_public_add"))
                  .width($r("app.float.dialer_common_margin"))
                  .height($r("app.float.dialer_common_margin"))
                  .margin({
                    left: $r("app.float.dialer_common_margin"),
                    right: $r("app.float.dialer_common_small_margin")
                  })

                Text($r("app.string.new_contact"))
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .fontColor($r('app.color.colorPrimary'))
              }
              .width('100%')
              .height($r("app.float.dialer_button_height"))
              .onClick(() => {
                this.mPresenter.jumpToAccountants()
              })

              Divider()
                .vertical(false)
                .strokeWidth(1)
                .color($r('app.color.light_grey'))
                .lineCap(LineCapStyle.Square)
                .width($r("app.float.dialer_divider_width"))
                .margin({ left: $r("app.float.dialer_common_big_margin") })

              Row() {
                Image($r("app.media.ic_public_contacts"))
                  .width($r("app.float.dialer_common_margin"))
                  .height($r("app.float.dialer_common_margin"))
                  .margin({
                    left: $r("app.float.dialer_common_margin"),
                    right: $r("app.float.dialer_common_small_margin")
                  })

                Text($r("app.string.save_to_existing_contacts"))
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .fontColor($r('app.color.colorPrimary'))
              }
              .width('100%')
              .height($r("app.float.dialer_button_height"))
              .onClick(()=>{
              })

              Divider()
                .vertical(false)
                .strokeWidth(1)
                .color($r('app.color.light_grey'))
                .lineCap(LineCapStyle.Square)
                .width($r("app.float.dialer_divider_width"))
                .margin({ left: $r("app.float.dialer_common_big_margin") })

              Row() {
                Image($r("app.media.ic_public_message"))
                  .width($r("app.float.dialer_common_margin"))
                  .height($r("app.float.dialer_common_margin"))
                  .margin({
                    left: $r("app.float.dialer_common_margin"),
                    right: $r("app.float.dialer_common_small_margin")
                  })

                Text($r("app.string.send_messages"))
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .fontColor($r('app.color.colorPrimary'))
              }
              .width('100%')
              .height($r("app.float.dialer_button_height"))
              .onClick(()=>{
                this.mPresenter.sendMessage();
              })

              Divider()
                .vertical(false)
                .strokeWidth(1)
                .color($r('app.color.light_grey'))
                .lineCap(LineCapStyle.Square)
                .width($r("app.float.dialer_divider_width"))
                .margin({ left: $r("app.float.dialer_common_big_margin") })
            }

          }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.White)
        } else {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
            Button() {
              Image($r("app.media.ic_public_more"))
                .width($r("app.float.dialer_common_margin"))
                .height($r("app.float.dialer_common_margin"))
                .bindMenu(this.callmenu)
            }
            .width($r("app.float.dialer_middle_button_width"))
            .height($r("app.float.dialer_middle_button_width"))
            .backgroundColor(Color.White)
            .margin({ right: $r("app.float.dialer_keypad_margin1")})
            .type(ButtonType.Normal)
          }
          .width('100%')
          .height($r("app.float.dialer_button_height"))
          .backgroundColor(Color.White)
          .zIndex(3)

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Text($r("app.string.dialer"))
              .fontSize($r("app.float.dialer_phone_number_fontSize"))
              .fontWeight(FontWeight.Bold)
              .height($r("app.float.contact_title_height"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_margin") })
          }
          .width('100%')
          .height($r("app.float.dialer_button_height"))
          .backgroundColor(Color.White)
          .zIndex(3)

          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            CallRecord()
          }
          .height('100%')
          .zIndex(1)
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('40%')
      .height('100%')

      Column() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
          Column().width('73%').height($r("app.float.dialer_block_height"))

          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            DialPad({ mPresenter: $mPresenter })
          }
          .width('73%')
          .height($r("app.float.dialer_dialpad_height"))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Button()
              .backgroundColor(Color.White)
              .width($r("app.float.dialer_common_middle_margin"))
              .height($r("app.float.dialer_common_middle_margin"))

            // 拨打按钮，悬浮按钮
            Button() {
              Image($r("app.media.ic_public_phone_filled_white"))
                .width($r("app.float.dialer_dial_icon_width"))
                .height($r("app.float.dialer_dial_icon_width"))
            }
            .width($r("app.float.dialer_big_button_width"))
            .height($r("app.float.dialer_big_button_width"))
            .backgroundColor($r('app.color.colorConnected'))
            .onClick(() => {
              this.mPresenter.dialing(this.mPresenter.all_number);
              this.mPresenter.tele_number = '';
              this.mPresenter.all_number = '';
            })


            // 删除按钮
            Button() {
              Image($r("app.media.ic_public_dial_delete"))
                .width($r("app.float.dialer_small_button_width"))
                .height($r("app.float.dialer_small_button_width"))
            }
            .backgroundColor(Color.White)
            .width($r("app.float.dialer_middle_button_width"))
            .height($r("app.float.dialer_middle_button_width"))
            .opacity(this.mPresenter.tele_number.length > 0 ? 1 : 0.6)
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
              this.mPresenter.deleteAddSpace();
              this.mPresenter.deleteTeleNum();
            })
          }
          .width('52%')
          .height($r("app.float.dialer_keypad_button_height"))
        }
        .width('100%')
        .height('100%')
      }
      .width('60%')
      .height('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }
}