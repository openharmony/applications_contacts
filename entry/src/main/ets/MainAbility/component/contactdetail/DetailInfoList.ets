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

import ArrayUtil from '../../util/ArrayUtil';

@Component
export default struct DetailInfoList {
  @Prop List: string;
  @Prop hasArrow: boolean;
  setClick: () => void;
  setLongPress: () => void;

  @Builder ListDivider() {
    Divider()
      .color($r("sys.color.ohos_id_color_list_separator"))
  }

  build() {
    Column() {
      if (!ArrayUtil.isEmpty(JSON.parse(this.List))) {
        this.ListDivider()
        List() {
          ForEach(JSON.parse(this.List), (item, index) => {
            ListItem() {
              DetailInfoListItem({
                title: item.data,
                content: item.labelName,
                hasArrow: this.hasArrow,
                setClick: () => {
                  this.setClick();
                },
                setLongPress: () => {
                  this.setLongPress();
                }
              });
            }

            if (index < JSON.parse(this.List).length - 1) {
              ListItem() {
                this.ListDivider()
              }
            }
          }, item => item.id)
        }
      }
    }
    .width("100%")
  }
}

@Component
struct DetailInfoListItem {
  private title: string;
  private content: string;
  private hasArrow: boolean;
  setClick?: () => void;
  setLongPress?: () => void;

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(this.title)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontWeight(FontWeight.Medium)
        Text(this.content)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r("app.float.id_card_margin_sm") })
      }

      Blank();

      Image($r('app.media.ic_arrow_right_grey'))
        .align(Alignment.Center)
        .width($r("app.float.id_card_image_xs"))
        .height($r("app.float.id_card_image_small"))
        .visibility(this.hasArrow ? Visibility.Visible : Visibility.None)
        .opacity(0.2)
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .onClick(() => {
      this.setClick();
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
        this.setLongPress();
      }))
  }
}