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

import { HiLog } from '../../../../../../common';

const TAG = "SelectSimIdDialog";

@CustomDialog
export struct SelectSimIdDialog {
  @Link builder: SelectDialogBuilder;
  private controller: CustomDialogController;

  aboutToAppear() {
    HiLog.i(TAG, JSON.stringify(this.builder));
  }

  build() {
    Column() {
      Text(this.builder.title)
        .fontSize($r("sys.float.ohos_id_text_size_dialog_tittle"))
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
        .width("100%")
        .height($r("app.float.id_item_height_mid"))
        .padding({ left: $r("app.float.id_card_margin_xxl"), })
      List() {
        ForEach(this.builder.multiSimCardItems, (item, index) => {
          ListItem() {
            Row() {
              Image(item.img)
                .height($r("app.float.id_card_image_mid"))
                .width($r("app.float.id_card_image_mid"))
                .margin({ right: $r("app.float.id_card_margin_large") })
                .onError((event => {
                  HiLog.e(TAG, "Sim:" + index + " Image onError" + JSON.stringify(event))
                }))
              Column() {
                Text(item.name)
                  .fontSize($r("sys.float.ohos_id_text_size_body1"))
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .fontWeight(FontWeight.Medium)
                Text($r("app.string.choose_sub_recommend"))
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r('sys.color.ohos_dialog_text_alert_transparent'))
                  .fontWeight(FontWeight.Lighter)
                  .visibility(this.builder.lastSimId == index ? Visibility.Visible : Visibility.None);
              }.alignItems(HorizontalAlign.Start)
            }.width('100%')
            .height($r("app.float.id_item_height_large"))
            .justifyContent(FlexAlign.Start)
            .padding({ left: $r("app.float.id_card_margin_xxl"), })
          }.onClick(() => {
            this.confirm(index);
          })
        })
      }.divider({
        strokeWidth: 1
      })

      Text($r("app.string.cancel"))
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Blue)
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .width("100%")
        .height($r("app.float.id_item_height_mid"))
        .onClick(() => {
          this.cancel()
        });
    }.backgroundColor(Color.White)
  }

  confirm(slotId: number) {
    this.controller.close()
    if (this.builder.callback) {
      this.builder.callback(slotId);
    }
  }

  cancel() {
    this.controller.close()
  }
}

class MultiSimCardItems {
  name: string | Resource;
  img: Resource;
}

interface Controller {
  close();
  open();
}

export class SelectDialogBuilder {
  title: string | Resource;
  multiSimCardItems: Array<MultiSimCardItems>;
  lastSimId?: number = -1;
  callback?: (simId: number) => void;
  controller?: Controller;
}
