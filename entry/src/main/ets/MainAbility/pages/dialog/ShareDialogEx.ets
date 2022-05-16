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
 * The sharing dialog box is displayed at the bottom.
 */
@CustomDialog
export default struct ShareDialogEx {
  controller: CustomDialogController;
  cancel: () => void;
  title: string | Resource;
  itemList: string[] | Resource[];
  cancelText: string | Resource;
  onItemClick: (item, index) => {};

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
      Text(this.title)
        .width('100%')
        .height(40)
        .fontSize(24)

      List() {
        ForEach(this.itemList, (item, index) => {
          ListItem() {
            Column() {
              Text(item).fontSize(20).margin({ top: 5, bottom: 5 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              this.onItemClick(item, index);
              this.controller.close();
            })
          }
        }, item => item);
      }
      .width('100%')
      .flexGrow(1)

      Column() {
        Text(this.cancelText).textAlign(TextAlign.Center)
          .width('100%')
          .fontSize(20)
          .fontColor($r("sys.color.ohos_id_color_text_primary_activated"))
      }
      .width('100%')
      .height(30)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        this.controller.close();
        this.cancel();
      })
    }
    .width('90%')
    .height(200)
    .borderRadius(20)
    .padding(10)
  }
}