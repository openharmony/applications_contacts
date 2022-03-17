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
import COMMON from '../../../../model/common'
import CONSTANTS from '../../../../model/common/Constants'
import Calllog from '../../../../model/calllog/CalllogModel'
import CallLogRepository from '../../../../call/repo/CallLogRepository';
import call from '@ohos.telephony.call';
import HiLog from '../../../../util/Hilog';

const TAG = "MissedRecord ";

const DENSITY = 1.5

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
  }

  getCallLog() {
    var DAHelper = COMMON.getDAHelper(CONSTANTS.uri.CALLLOG_DB_URI);
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
            .margin({ top: 150 * DENSITY,bottom: 4 * DENSITY })
          Text($r("app.string.no_dialer_missed_calllog"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontWeight(FontWeight.Regular)
              //          .fontColor($r("app.color.textColorTertiary"))
            .fontColor('#66182431')
            .height(19 * DENSITY)
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
            .height($r("app.float.dialer_calllog_item_height"))
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
          startMargin: $r("app.float.dialer_common_little_margin"),
          endMargin: $r("app.float.dialer_common_little_margin"),
        })
        .gesture(
          // 长按手势
        LongPressGesture({ fingers: 1, duration: 500 })
          // 长按动作识别成功时触发
          .onAction(() => {
          })
        )
      }

      if (this.menuShow) {
        Column() {
          Button(JSON.parse(this.currentMsg)
                 .displayName ? JSON.parse(this.currentMsg)
                                .displayName : JSON.parse(this.currentMsg)
                                               .phoneNumber, { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width1"))
            .fontSize($r("app.float.contact_text_size_body1"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
            })
          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_calllog_bindmenu_divider_width"))
          Button($r("app.string.send_message"), { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width2"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
            })
          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_calllog_bindmenu_divider_width"))
          Button($r("app.string.copy_phoneNumber"), { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width2"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
            })
          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_calllog_bindmenu_divider_width"))
          Button($r("app.string.edit_beforeCall"), { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width2"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
            })
          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_calllog_bindmenu_divider_width"))
          Button($r("app.string.add_to_blockList"), { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width2"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
            })
          Divider()
            .vertical(false)
            .strokeWidth(1)
            .color($r('app.color.light_grey'))
            .lineCap(LineCapStyle.Square)
            .width($r("app.float.dialer_calllog_bindmenu_divider_width"))
          Button($r("app.string.delete_call_logs"), { type: ButtonType.Normal, stateEffect: true })
            .width($r("app.float.dialer_calllog_bindmenu_width2"))
            .fontSize($r("app.float.contact_text_size_body2"))
            .fontColor($r('app.color.colorPrimary'))
            .backgroundColor(Color.White)
            .borderRadius($r("app.float.dialer_common_little_margin"))
            .margin({ bottom: $r("app.float.dialer_common_very_small_margin1") })
            .onClick(() => {
              this.menuShow = false
              // 删除通话记录
              CallLogRepository.getInstance().deleteByIdIn(JSON.parse(this.currentMsg).ids).then(data => {
                this.getCallLog();
              });
            })
        }
        .height($r("app.float.dialer_calllog_bindmenu_height"))
        .padding($r("app.float.dialer_common_very_small_margin1"))
        .borderRadius($r("app.float.dialer_keypad_margin2"))
        .backgroundColor(Color.White)
        //        .border({ width: 1, color: '#999999', style: BorderStyle.Solid })
        .shadow({ radius: 10 * DENSITY, color: Color.Gray, offsetX: 5 * DENSITY, offsetY: 5 * DENSITY })
        .position({ x: 200 * DENSITY, y: this.offsetY < 416 * DENSITY ? (this.offsetY - 170) : 246 * DENSITY })
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
    if (phoneNumber == null || phoneNumber == '') {
      HiLog.i(TAG, 'call param is null');
      return;
    }
    if (phoneNumber.length > 0) {
      call.dial(phoneNumber).then((value) => {
        //        this.pageState = false;
        HiLog.i(TAG, 'call dial success ');
      }).catch((err) => {
        HiLog.e(TAG, 'call dial error, ');
      });
    }
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
              Blank(16 * DENSITY)
            }
          } else if (JSON.parse(this.msg).callType == 5) {
            // 拒接
            Image($r('app.media.ic_contacts_Reject'))
              .height($r("app.float.dialer_common_small_margin"))
              .width($r("app.float.dialer_common_small_margin"))
          } else {
            Row() {
              Blank(16 * DENSITY)
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

            if (JSON.parse(this.msg).displayName) {
              // 拒接标红
              if (JSON.parse(this.msg).callType == 5) {
                Text(JSON.parse(this.msg).displayName)
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                  .fontColor($r('app.color.error'))
              } else {
                Text(JSON.parse(this.msg).displayName)
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                  .fontColor($r('app.color.colorPrimary'))
              }
            } else {
              if (JSON.parse(this.msg).callType == 5) {
                Text(JSON.parse(this.msg).phoneNumber)
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                  .fontColor($r('app.color.error'))
              } else {
                Text(JSON.parse(this.msg).phoneNumber)
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .margin({ right: $r("app.float.dialer_common_very_small_margin2") })
                  .fontColor($r('app.color.colorPrimary'))
              }
            }

            // 通话次数一次以上才显示通话次数
            if (JSON.parse(this.msg).count != 1) {
              if (JSON.parse(this.msg).callType == 5) {
                Text('(' + JSON.parse(this.msg).count + ')')
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .fontColor($r('app.color.error'))
              } else {
                Text('(' + JSON.parse(this.msg).count + ')')
                  .fontSize($r("app.float.contact_text_size_body1"))
                  .fontColor($r('app.color.colorPrimary'))
              }
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
        .height($r("app.float.contact_listitem_height"))
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
        }

        Image($r('app.media.ic_public_detail'))
          .height($r("app.float.dialer_common_margin"))
          .width($r("app.float.dialer_common_margin"))
          .margin({ right: 36 })
          .onClick(() => {
            router.push(
              {
                uri: "pages/contacts/details/ContactDetail",
                params: {
                  sourceFromCallRecord: true,
                  isNewNumber: true,
                  phoneNumberShow: JSON.parse(this.msg).phoneNumber
                }
              }
            )
          })
      }
    }
    .width('100%')
    .height($r("app.float.contact_listitem_height"))
    .gesture(
      // 滑动手势
    PanGesture({ fingers: 1, direction: PanDirection.Left, distance: 5 })
      .onActionStart(() => {
      })
    )
    .gesture(
      // 长按手势
    LongPressGesture({ repeat: false, fingers: 1, duration: 500 })
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

