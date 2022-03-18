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

/**
 * 通话记录未接来电
 */
import router from '@system.router';
import COMMON from '../../../model/common'
import CONSTANTS from '../../../model/common/Constants'
import Calllog from '../../../model/calllog/CalllogModel'
import CallLogRepository from '../../../call/repo/CallLogRepository';
import HiLog from '../../../util/Hilog';
import DialUtil from '../../../util/DialUtil';
import dbChangeHelper from './../../../model/common/DbChangeHelper';

const TAG = "MissedRecord ";

@Component
export default struct MissedRecord {
  @State callLogTotalData: any = {
    callLogList: [],
    missedList: [],
    totalCount: 0,
    missedCount: 0
  };
  @State menuShow: boolean = false;
  @State currentMsg: string = '';
  @State offsetY: number = 0;

  aboutToAppear() {
    this.getCallLog();
    let DAHelper = COMMON.getDAHelper(CONSTANTS.uri.CALLLOG_DB_URI);
    dbChangeHelper.getInstance().registerDbChangeLister(DAHelper, CONSTANTS.uri.CALL_LOG_URI, (data) => {
      HiLog.i(TAG, 'refresh');
      this.getCallLog();
    });
    let DAHelper_Contact = COMMON.getDAHelper(CONSTANTS.uri.CONTACT_DB_URI);
    dbChangeHelper.getInstance().registerDbChangeLister(DAHelper_Contact, CONSTANTS.uri.CONTACT_DB_URI, (data) => {
      HiLog.i(TAG, 'refresh');
      this.getCallLog();
    });
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    let DAHelper = COMMON.getDAHelper(CONSTANTS.uri.CALLLOG_DB_URI);
    dbChangeHelper.getInstance().unRegisterDbChangeLister(DAHelper, CONSTANTS.uri.CALL_LOG_URI, (data) => {
      HiLog.i(TAG, 'Contact aboutToDisappear!');
    });
    let DAHelper_Contact = COMMON.getDAHelper(CONSTANTS.uri.CONTACT_DB_URI);
    dbChangeHelper.getInstance().unRegisterDbChangeLister(DAHelper_Contact, CONSTANTS.uri.CONTACT_DB_URI, (data) => {
      HiLog.i(TAG, 'Contact aboutToDisappear!');
    });
  }

  getCallLog() {
    let DAHelper = COMMON.getDAHelper(CONSTANTS.uri.CALLLOG_DB_URI);
    Calllog.getAllCalls(DAHelper, '', data => {
      this.callLogTotalData = data;
    })
  }

  build() {
    Stack() {
      if (this.callLogTotalData.missedList.length == 0) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
          Image($r('app.media.no_call_records'))
            .objectFit(ImageFit.Contain)
            .width($r("app.float.contact_emptyview_image_width_height"))
            .height($r("app.float.contact_emptyview_image_width_height"))
            .margin({
              top: $r("app.float.dialer_calllog_bindmenu_width1"),
              bottom: $r("app.float.dialer_common_very_small_margin1")
            })
          Text($r("app.string.no_dialer_missed_calllog"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.textColorTertiary'))
            .height($r("app.float.dialer_common_middle_margin"))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
      } else {
        List() {
          ForEach(this.callLogTotalData.missedList, (item) => {
            ListItem() {
              ContactItem({ msg: JSON.stringify(item), show: $menuShow, current: $currentMsg, offsetY: $offsetY });
            }
            .height($r("app.float.dialer_listitem_height"))
            .gesture(
              // 滑动手势
            PanGesture({ fingers: 1, direction: PanDirection.Up | PanDirection.Down, distance: 5 })
              .onActionStart((event: GestureEvent) => {
                // 关闭长按菜单
                this.menuShow = false;
              })
            )
          }, item => item.id)
        }
        .divider({
          strokeWidth: 1,
          color: $r('app.color.light_grey'),
          startMargin: $r("app.float.dialer_keypad_width"),
          endMargin: $r("app.float.dialer_common_margin"),
        })
        .margin({ bottom: $r("app.float.dialer_calllog_list_margin_bottom") })
      }

      if (this.menuShow) {
        Column() {
          Row() {
            Text(JSON.parse(this.currentMsg).displayName ?
              JSON.parse(this.currentMsg).displayName :
              JSON.parse(this.currentMsg).phoneNumber)
              .fontSize($r("app.float.dialer_font_size"))
              .fontColor($r('app.color.colorPrimary'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_small_button_width"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_listitem_height"))
          .borderRadius($r("app.float.dialer_common_small_margin"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
          })

          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_divider_width1"))
          Row() {
            Text($r("app.string.send_message"))
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_line_height"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_middle_button_width"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
          })

          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_divider_width1"))
          Row() {
            Text($r("app.string.copy_phoneNumber"))
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_line_height"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_middle_button_width"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
          })

          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_divider_width1"))
          Row() {
            Text($r("app.string.edit_beforeCall"))
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_line_height"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_middle_button_width"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
          })

          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_divider_width1"))
          Row() {
            Text($r("app.string.add_to_blockList"))
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_line_height"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_middle_button_width"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
          })

          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_divider_width1"))
          Row() {
            Text($r("app.string.delete_call_logs"))
              .fontSize($r("app.float.contact_text_size_body1"))
              .fontColor($r('app.color.colorPrimary'))
              .margin({ left: $r("app.float.dialer_common_small_margin") })
              .textAlign(TextAlign.Start)
              .lineHeight($r("app.float.dialer_line_height"))
          }
          .width($r("app.float.dialer_calllog_bindmenu_width1"))
          .height($r("app.float.dialer_middle_button_width"))
          .borderRadius($r("app.float.dialer_common_small_margin"))
          .backgroundColor(Color.White)
          .onClick(() => {
            this.menuShow = false;
            CallLogRepository.getInstance().deleteByIdIn(JSON.parse(this.currentMsg).ids).then(data => {
              this.getCallLog();
            });
          })
        }
        .borderRadius($r("app.float.dialer_common_small_margin"))
        .backgroundColor(Color.White)
        .shadow({ radius: 10, color: $r('app.color.dialer_shadow_color'), offsetX: 2, offsetY: 2 })
        .position({ x: 200, y: this.offsetY < 416 ? this.offsetY - 170 : 220 })
      }
    }
  }
}

@Component
struct ContactItem {
  @Link show: boolean
  @Link current: string
  @Link offsetY: number
  @Prop msg: string

  // 拨号拨出
  dialing(phoneNumber) {
    DialUtil.getInstance().dial(phoneNumber, (data, err, value) => {
      HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
    });
  }

  build() {
    Flex({ direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center }) {

      // 左侧布局
      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Center }) {

          if (JSON.parse(this.msg).callType == 3) {
            // 未接
            Row() {
              Blank(16)
            }
          } else if (JSON.parse(this.msg).callType == 5) {
            // 拒接
            Image($r('app.media.ic_contacts_Reject'))
              .height($r("app.float.dialer_common_small_margin"))
              .width($r("app.float.dialer_common_small_margin"))
          } else {
            Row() {
              Blank(16)
            }
          }
        }
        .margin({
          right: $r("app.float.dialer_keypad_margin1"),
          top: $r("app.float.dialer_keypad_margin1"),
          left: $r("app.float.dialer_keypad_margin1")
        })
        .height($r("app.float.dialer_middle_button_width"))

        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Start }) {

          Flex({ direction: FlexDirection.Row,
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center }) {

            // 未接和拒接标红
            if (JSON.parse(this.msg).displayName) {
              Text(JSON.parse(this.msg).displayName)
                .fontSize($r("app.float.contact_text_size_body1"))
                .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                .fontColor($r('app.color.error'))
                .fontWeight(FontWeight.Medium)
            } else {
              Text(JSON.parse(this.msg).phoneNumber)
                .fontSize($r("app.float.contact_text_size_body1"))
                .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                .fontColor($r('app.color.error'))
                .fontWeight(FontWeight.Medium)
            }

            // 通话次数一次以上才显示通话次数
            if (JSON.parse(this.msg).count != 1) {
              Text('(' + JSON.parse(this.msg).count + ')')
                .fontSize($r("app.float.contact_text_size_body1"))
                .fontColor($r('app.color.error'))
                .fontWeight(FontWeight.Medium)
            }
          }

          // 标签
          if (JSON.parse(this.msg).numberLocation) {
            Text(JSON.parse(this.msg).numberLocation)
              .fontSize($r("app.float.dialer_text_size_body1"))
              .fontColor($r('app.color.more_light_colorPrimary'))
              .margin({ top: $r("app.float.dialer_common_very_small_margin1") })
          } else {
            Text($r("app.string.unknown"))
              .fontSize($r("app.float.dialer_text_size_body1"))
              .fontColor($r('app.color.more_light_colorPrimary'))
              .margin({ top: $r("app.float.dialer_common_very_small_margin1") })
          }

        }
        .height($r("app.float.dialer_listitem_height"))
      }

      // 右侧布局
      Row() {
        Flex({ direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center }) {
          Text(JSON.parse(this.msg).createTime)
            .fontSize($r("app.float.contact_text_size_body2"))
            .margin({ right: $r("app.float.dialer_keypad_margin1") })
            .fontColor($r('app.color.more_light_colorPrimary'))
            .width($r("app.float.dialer_time_width"))
            .textAlign(TextAlign.End)
        }

        Image($r('app.media.ic_public_detail'))
          .height($r("app.float.dialer_common_margin"))
          .width($r("app.float.dialer_common_margin"))
          .margin({ right: $r("app.float.dialer_time_width") })
          .onClick(() => {
            router.push(
              {
                uri: "pages/contacts/details/ContactDetail",
                params: {
                  sourceFromCallRecord: true,
                  isNewNumber: JSON.parse(this.msg).quickSearchKey ? false : true,
                  phoneNumberShow: JSON.parse(this.msg).phoneNumber
                }
              }
            )
          })
      }
    }
    .width('100%')
    .height($r("app.float.dialer_listitem_height"))
    .gesture(
      // 滑动手势
    PanGesture({ fingers: 1, direction: PanDirection.Left, distance: 5 })
      .onActionStart(() => {
      })
    )
    .gesture(
      // 长按手势
    LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
      // 长按动作识别成功时触发
      .onAction((event: GestureEvent) => {
        this.show = true;
        this.current = this.msg;
        this.offsetY = JSON.parse(JSON.stringify(event))
        .globalY;
      })
    )
    .onClick((event: ClickEvent) => {
      this.show = false
      // 跳转到拨打电话界面
      this.dialing(JSON.parse(this.msg).phoneNumber)
    })
  }
}

