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

import router from '@system.router';
import CallRecord from './callRecord/CallRecord'
import Utils from '../../../util/Utils';
import vibrator from '@system.vibrator';
import ContactsLog from '../../../util/ContactsLog';
import resourceManager from '@ohos.resourceManager';
import HiLog from '../../../util/Hilog';
import DialUtil from '../../../util/DialUtil';
import {UPDATE_RECORD} from './callRecord/allRecord'

// 号码编辑框最大可显示号码长度，依据p40为25个数字
const NUM_TEXT_MAX_LENGTH = 20;
// 号码编辑框 最大字体 70px时的最大长度
const NUM_TEXT_MAXSIZE_LENGTH = 14;
// 号码编辑框数字最大字体大小，单位px
const NUM_TEXT_FONT_SIZE_MAX = 40;
const NUM_BUTTON_BASIC_LENGTH = 50;
const DIALER_BUTTON_MARGIN = 20;

const TAG = 'Dialer';

const DENSITY = 1.5;

// 输入号码时检查是否需要添加格式化空格
function checkNeedNumberSpace(numText) {
  let isSpace = /[\+;,#\*]/g;
  let isRule = /^\+.*/;
  if (isSpace.test(numText)) { // 号码字符串中包含特殊字符则不添加空格
    if (isRule.test(numText)) {
      return true;
    } else {
      return false;
    }
  }
  return true;
}
// 按键振动
function pressVibrate() {
  vibrator.vibrate({
    mode: 'short',
    success: () => void {},
    fail: function (ret) {
      ContactsLog.info(TAG + 'vibrate is failed');
    },
    complete: () => void {}
  });
}
// 按键音
function setRingTone() {
  ContactsLog.info(TAG + 'keypad tone');
}

@Component
struct DialButton {
  // 按键数字
  @Prop button_number: string
  // 按键对应的字符
  @Prop button_char: string
  // 电话号码
  @Link tel_num: string
  @Link numTextSize: number

  // 输入号码时添加空格
  ifNeedSpace() {
    switch (this.tel_num.length) {
      case 3:
        if (checkNeedNumberSpace(this.tel_num)) {
          this.tel_num = this.tel_num + ' ';
        }
        break;
      case 8:
        this.tel_num = this.tel_num + ' ';
        break;
      default:
        break;
    }
  }
  // 输入号码超长处理
  viewNumberTextProc() {
    let numStringNoSpace = Utils.removeSpace(this.tel_num);
    // 超长后去除全部空格
    this.tel_num = numStringNoSpace.length > NUM_TEXT_MAX_LENGTH ?
    numStringNoSpace.substr(numStringNoSpace.length - NUM_TEXT_MAX_LENGTH) : this.tel_num;
    if (this.tel_num.length > NUM_TEXT_MAXSIZE_LENGTH) {
      this.tel_num = Utils.removeSpace(this.tel_num);
    }
    if (this.tel_num.length > NUM_TEXT_MAXSIZE_LENGTH) {
      this.numTextSize = NUM_TEXT_FONT_SIZE_MAX * NUM_TEXT_MAXSIZE_LENGTH / (this.tel_num.length); // 可视号码在16-25位时，适配font-size
    } else {
      this.numTextSize = NUM_TEXT_FONT_SIZE_MAX;
    }
  }

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
          if ((this.button_char == 'ic')) {
            Image($r("app.media.ic_contacts_voicemail_mini"))
              .width(15 * DENSITY)
              .height(15 * DENSITY)
          } else {
            Text(`${this.button_char}`)
              .fontColor($r("app.color.dialer_char_button_color"))
              .fontSize(10 * DENSITY)
          }
        }
      }
      .backgroundColor($r("app.color.basic_background"))
      .width(NUM_BUTTON_BASIC_LENGTH * DENSITY)
      .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
      .onClick(() => {
        pressVibrate();
        setRingTone();
        this.ifNeedSpace();
        this.tel_num += this.button_number
        this.viewNumberTextProc();
        ContactsLog.info(TAG + this.tel_num)
        if (this.tel_num.length > 0) {
          AppStorage.SetOrCreate<boolean>('number_show', true)
        }
      })
    }
  }
}

@Component
struct DialPad {
  @Link tel_num: string
  @Link numTextSize: number

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '1', button_char: 'ic', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '2', button_char: 'ABC', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '3', button_char: 'DEF', tel_num: $tel_num, numTextSize: $numTextSize })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '4', button_char: 'GHI', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '5', button_char: 'JKL', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '6', button_char: 'MNO', tel_num: $tel_num, numTextSize: $numTextSize })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '7', button_char: 'PQRS', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '8', button_char: 'TUV', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '9', button_char: 'WXYZ', tel_num: $tel_num, numTextSize: $numTextSize })
      }.margin({ top: DIALER_BUTTON_MARGIN })

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        DialButton({ button_number: '*', button_char: '(P)', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '0', button_char: '+', tel_num: $tel_num, numTextSize: $numTextSize })

        DialButton({ button_number: '#', button_char: '(W)', tel_num: $tel_num, numTextSize: $numTextSize })
      }.margin({ top: DIALER_BUTTON_MARGIN })
    }.width("100%")
  }
}

@Entry
@Component
export default struct Call {

  // 默认显示拨号盘
  @State panelShow: boolean = false
  // 默认不显示收展键
  @State btnShow: boolean = true
  // 电话号码
  @State tele_number: string = ''
  @State tele_num_size: number = NUM_TEXT_FONT_SIZE_MAX;
  @State dialer_w: number = 50;
  @State dialer_h: number = 50;
  @State call_w: number = 50;
  @State call_h: number = 50;
  @State call_p: number = 150 * DENSITY;
  @State  moveX: number = 0
  @State  moveY: number = 800
  @State newHidden: Visibility= Visibility.None
  @StorageLink('number_show') number_show: boolean = false
  private menuRes: Resource[] = [$r("app.string.call_setting_type_paste"),
  $r("app.string.call_setting_type_batch_delete"),
  $r("app.string.call_setting_type_harassment_interception"),
  $r("app.string.call_setting_type_setting")];
  @State private callmenu: any = [{ value: "", action: () => {
  } }];

  private aboutToAppear(): void {
    AppStorage.SetOrCreate<boolean>('number_show', false)
    let tmpPhoneMenu = [];
    this.menuRes.forEach(element => {
      tmpPhoneMenu.push({});
    });
    this.callmenu = tmpPhoneMenu;
    resourceManager.getResourceManager().then(result => {
      this.menuRes.forEach((element, i) => {
        result.getString(element.id, (err, typeName) => {
          ContactsLog.info(TAG + typeName);
          this.callmenu[i] = {
            value: typeName,
            action: () => {
            }
          };
        });
      });
    });
  }

  // 删除号码时，改变字体大小
  deleteTeleNum() {
    if (this.tele_number.length > NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = NUM_TEXT_FONT_SIZE_MAX * NUM_TEXT_MAXSIZE_LENGTH / this.tele_number.length;
    } else if (this.tele_number.length <= NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = NUM_TEXT_FONT_SIZE_MAX;
    }
  }
  // 删除号码时，添加格式化空格
  deleteAddSpace() {
    let teleNumberNoSpace = Utils.removeSpace(this.tele_number);
    if (teleNumberNoSpace.length > NUM_TEXT_MAXSIZE_LENGTH - 2) {
      this.tele_number = teleNumberNoSpace;
      return;
    }
    if (checkNeedNumberSpace(this.tele_number)) {
      if (teleNumberNoSpace.length <= 3) {
        this.tele_number = teleNumberNoSpace;
        return;
      }
      if (teleNumberNoSpace.length > 3) {
        var split1 = teleNumberNoSpace.substr(0, 3);
        var split2 = teleNumberNoSpace.substr(3, teleNumberNoSpace.length - 3);
        this.tele_number = split1 + ' ' + split2;
      }
      if (teleNumberNoSpace.length > 7) {
        split2 = teleNumberNoSpace.substr(3, 4);
        var split3 = teleNumberNoSpace.substr(7, teleNumberNoSpace.length - 7);
        this.tele_number = split1 + ' ' + split2 + ' ' + split3;
      }
    } else {
      if (teleNumberNoSpace.length > 8) {
        var split4 = teleNumberNoSpace.substr(0, 8);
        let split5 = teleNumberNoSpace.substr(8, teleNumberNoSpace.length - 8);
        this.tele_number = split4 + ' ' + split5;
      }
    }
  }

  dialing(phoneNumber) {
    DialUtil.getInstance().dial(phoneNumber, (data, err, value) => {
      HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
      AppStorage.SetOrCreate<boolean>('number_show', false);
    });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 号码，通话记录
      Column() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
          Text(`${this.tele_number}`)
            .fontSize(this.tele_num_size * DENSITY)
            .fontColor(Color.Black)
            .maxLines(1)
            .margin({ left: DIALER_BUTTON_MARGIN * DENSITY, right: 10 * DENSITY, bottom: 580 * DENSITY })
        }
        .width('100%')
        .visibility(this.number_show ? Visibility.Visible : Visibility.None)

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
            Button() {
              Image($r("app.media.menu"))
                .width(25 * DENSITY)
                .height(25 * DENSITY)
            }
            .width(35 * DENSITY)
            .height(35 * DENSITY)
            .backgroundColor(Color.White)
            .margin({ right: 30 * DENSITY, top: 15 * DENSITY })
            .type(ButtonType.Normal)
          }
          .width('100%')

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Text($r("app.string.dialer"))
              .fontSize(25 * DENSITY)
              .height(35 * DENSITY)
              .fontColor(Color.Black)
              .margin({ left: 25 * DENSITY })
          }
          .width('100%')

          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            if (true) {
              // 如果通话列表有数据
              Flex() {
                CallRecord()
              }
              .width('100%').height('100%')
            } else {
              // 如果通话列表没数据
              Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Image($r("app.media.phonebook"))
                  .width(40 * DENSITY)
                  .height(40 * DENSITY)
                Text($r("app.string.no_dialer_calllog"))
                  .fontSize(12 * DENSITY)
                  .fontColor(Color.Gray)
                  .margin({ top: DIALER_BUTTON_MARGIN * DENSITY })
              }
              .height('60%')
            }
          }
          .height('100%')
          .onTouch(() => {
            this.btnShow = true
            this.panelShow = false
            animateTo({ duration: 500, curve: Curve.Linear }, () => {
              this.dialer_w = 20 * DENSITY;
              this.dialer_h = 20 * DENSITY;
              this.call_w = 40 * DENSITY;
              this.call_h = 40 * DENSITY;
              this.call_p = 150 * DENSITY;
            })
          })
        }
        .width('100%')
        .height('100%')
        .visibility(this.number_show ? Visibility.None : Visibility.Visible)
        //        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')

      // 拨打按钮，悬浮按钮
      Column() {
        Button() {
          Image(this.btnShow ? $r("app.media.keypad_white") : $r("app.media.ic_public_phone_filled_white"))
            .width($r("app.float.dialer_common_big_margin"))
            .height($r("app.float.dialer_common_big_margin"))
        }
        .width($r("app.float.dialer_button_height"))
        .height($r("app.float.dialer_button_height"))
        .margin({ top: 30 })
        .backgroundColor($r("app.color.colorConnected"))
        .translate({ x: this.call_p })
        .onClick(() => {
          if (this.btnShow) {


            //          this.panelShow = true;
            animateTo({
              duration: 500,
              curve: Curve.Linear,
              onFinish: () => {
              }
            }, () => {
              this.call_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.call_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.dialer_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.dialer_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
              this.call_p = 0;
              this.moveX = 0;
              this.moveY = 0
            })
            this.btnShow = false;
          } else {
            if (this.tele_number.length > 0) {
              // 跳转到拨打电话界面
              this.dialing(this.tele_number)
              this.tele_number = '';
            }
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
      .width(60 * DENSITY)
      .height('10%')
      .zIndex(3)


      Column() {
        // 展示拨号盘
        Column() {
          Column() {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
              Stack({ alignContent: Alignment.Bottom }) {
                if (this.tele_number.length > 0 && !this.btnShow) {
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
                          Image($r("app.media.add_black"))
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
                      .backgroundColor($r("app.color.basic_background"))
                      .onClick(() => {
                        router.push({
                          uri: "pages/contacts/accountants/Accountants"
                        })
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
                      .backgroundColor($r("app.color.basic_background"))

                      Button() {
                        Flex({
                          direction: FlexDirection.Column,
                          alignItems: ItemAlign.Center,
                          justifyContent: FlexAlign.Center
                        }) {
                          Image($r("app.media.msg_black"))
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
                      .backgroundColor($r("app.color.basic_background"))
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

                  DialPad({ tel_num: $tele_number, numTextSize: $tele_num_size })

                  Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
                    Button() {
                      Image($r("app.media.ic_contacts_dialer"))
                        .width(25 * DENSITY)
                        .height(25 * DENSITY)
                    }
                    .margin({ top: 20 })
                    .layoutWeight(1)
                    .type(ButtonType.Normal)
                    .backgroundColor($r("app.color.basic_background"))
                    .width(NUM_BUTTON_BASIC_LENGTH * DENSITY)
                    .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
                    .onClick(() => {
                      this.tele_number.length < 0
                      this.btnShow = true;
                      animateTo({ duration: 500, curve: Curve.Linear }, () => {
                        this.dialer_w = 20 * DENSITY;
                        this.dialer_h = 20 * DENSITY;
                        this.call_w = 40 * DENSITY;
                        this.call_h = 40 * DENSITY;
                        this.call_p = 150 * DENSITY;
                        this.moveY = 500;
                        this.moveX = 0
                      })
                    })
                    //占位控件
                    Text().layoutWeight(1)
                    // 删除按钮
                    Button() {
                      Image($r("app.media.ic_contacts_Delete_m"))
                        .width(25 * DENSITY)
                        .height(25 * DENSITY)
                    }
                    .backgroundColor($r("app.color.basic_background"))
                    .type(ButtonType.Normal)
                    .width(NUM_BUTTON_BASIC_LENGTH * DENSITY)
                    .height(NUM_BUTTON_BASIC_LENGTH * DENSITY)
                    .margin({ top: DIALER_BUTTON_MARGIN })
                    .layoutWeight(1)
                    .opacity(this.tele_number.length > 0 ? 1 : 0.5)
                    .enabled(this.tele_number.length > 0 ? true : false)
                    .onClick(() => {
                      pressVibrate();
                      this.tele_number = this.tele_number.substr(0, this.tele_number.length - 1)
                      this.deleteAddSpace();
                      this.deleteTeleNum();
                      if (this.tele_number.length == 0) {
                        AppStorage.SetOrCreate<boolean>('number_show', false)
                      }
                    })
                  }
                }
                .zIndex(this.panelShow ? 2 : -1)
              }.width('100%')
            }

          }.width('100%')
        }
        .backgroundColor($r("app.color.basic_background"))
        .width("100%")
        .height("100%")
        .borderRadius(20)
      }
      .zIndex(2)
      .offset({ x: this.moveX, y: this.moveY })
      .width('100%')
      .height(500)
      .gesture(
        // 滑动手势
      PanGesture({ fingers: 1, direction: PanDirection.Down, distance: 5 })
        .onActionStart(() => {
          this.moveY = 0
        })
      )
    }
    .width('100%')
    .height('100%')
  }
}