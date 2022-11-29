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
 * The Delete dialog box is displayed at the bottom.
 */
@CustomDialog
export default struct DeleteDialogEx {
  controller: CustomDialogController;
  cancel: () => void;
  confirm: () => void;
  title: string | Resource;
  cancalText: string | Resource;
  confrimText: string | Resource;

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center
    }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Text(this.title)
          .fontSize(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .margin({ bottom: 10 })

      Row() {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          Text(this.cancalText).fontColor($r("sys.color.ohos_id_color_text_primary_activated")).fontSize(20)
        }
        .layoutWeight(1)
        .height(35)
        .onClick(() => {
          this.controller.close();
          this.cancel();
        })

        Line().width(1).height(25).backgroundColor($r("sys.color.ohos_id_color_list_separator"))

        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          Text(this.confrimText).fontColor(Color.Red).fontSize(20)
        }
        .layoutWeight(1)
        .height(35)
        .onClick(() => {
          this.controller.close();
          this.confirm();
        })
      }
      .height('30vp')
    }
    .width("90%")
    .height($r("app.float.DeleteDialogEx_height"))
    .borderRadius(20)
    .padding({
      bottom: $r("sys.float.ohos_id_dialog_margin_bottom"),
      right: $r("sys.float.ohos_id_notification_margin_start"),
      left: $r("sys.float.ohos_id_notification_margin_end")
    })
  }
}