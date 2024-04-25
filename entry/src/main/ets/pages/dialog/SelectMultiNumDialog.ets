/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { HiLog, sharedPreferencesUtils } from '../../../../../../common';

const TAG = 'SelectMultiNumDialog';

@CustomDialog
export struct SelectMultiNumDialog {
  @Link builder: SelectNumDialogBuilder;
  private controller: CustomDialogController;
  private selectDefault: Boolean = false;

  aboutToAppear() {
    HiLog.i(TAG, JSON.stringify(this.builder));
    sharedPreferencesUtils.init(globalThis.getContext())
  }

  build() {
    Column() {
      Text(this.builder.title)
        .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
        .width('100%')
        .height('48vp')
        .padding({ left: '16vp', })
      List() {
        ForEach(this.builder.multiNumCardItems, (item, index) => {
          ListItem() {
            Row() {
              Image(item.img)
                .height('30vp')
                .width('30vp')
                .margin({ right: '8vp' })
                .onError((event => {
                  HiLog.e(TAG, 'Num:' + index + ' Image onError' + JSON.stringify(event))
                }))
              Column() {
                Text(item.number)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Lighter)
                Text(item.numType)
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontColor($r('sys.color.ohos_dialog_text_alert_transparent'))
                  .fontWeight(FontWeight.Lighter)
                  .margin({ top: '4vp' })
              }.alignItems(HorizontalAlign.Start)
            }.width('100%')
            .height('56vp')
            .justifyContent(FlexAlign.Start)
            .padding({ left: '16vp', })
          }.onClick(() => {
            this.confirm(item, this.builder.contactId);
          })
        })
      }.divider({
        strokeWidth: 0.8,
        startMargin: 56,
        endMargin: $r('app.float.id_card_margin_max'),
      })

      Row() {
        Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
          .select(false)
          .selectedColor(0x39a2db)
          .onChange((value: boolean) => {
            this.selectDefault = value
            console.info(' msz Checkbox2 change is' + value)
          })
        Column() {
          Text($r('app.string.set_default_values'))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_dialog_text_alert_transparent'))
            .fontWeight(FontWeight.Lighter)
        }.alignItems(HorizontalAlign.Start)
      }.width('100%')
      .height('56vp')
      .justifyContent(FlexAlign.Start)
      .padding({ left: '16vp', })

      Text($r('app.string.cancel'))
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .fontColor(0x39a2db)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .width('100%')
        .height('48vp')
        .onClick(() => {
          this.cancel()
        });
    }.backgroundColor(Color.White)
  }

  confirm(item, contactId) {
    this.controller.close()
    if (this.selectDefault) {
      sharedPreferencesUtils.saveToPreferences(contactId + '', item.number);
    }
    if (this.builder.callback) {
      this.builder.callback(item);
    }
  }

  cancel() {
    this.controller.close()
  }
}

class MultiNumCardItems {
  number: String;
  numType: Resource;
  img: Resource;
}

interface Controller {
  close();

  open();
}

export class SelectNumDialogBuilder {
  title: string | Resource;
  contactId: String
  multiNumCardItems: Array<MultiNumCardItems>;
  callback?: (item: MultiNumCardItems) => void;
  controller?: Controller;
}
