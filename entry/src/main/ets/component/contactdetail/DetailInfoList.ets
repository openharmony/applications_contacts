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

import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { DataItemType } from '../../../../../../feature/contact/src/main/ets/contract/DataType';
import StringFormatUtil from '../../util/StringFormatUtil'
import { Birthday } from '../../../../../../feature/contact/src/main/ets/contract/Birthday';

@Component
export default struct DetailInfoList {
  private dataType: DataItemType;
  private List: string;
  private hasArrow: boolean;

  build() {
    Column() {
      if (!ArrayUtil.isEmpty(JSON.parse(this.List))) {
        Divider()
          .color($r("sys.color.ohos_id_color_list_separator"))
        List() {
          ForEach(JSON.parse(this.List), (item, index) => {
            ListItem() {
              DetailInfoListItem({
                title: this.dataType == DataItemType.EVENT ? StringFormatUtil.stringFormatDateResource(item.data, item?.type == Birthday.TYPE_LUNARBIRTHDAY) : item.data,
                content: item.labelName,
                hasArrow: this.hasArrow,
              });
            }
          }, item => JSON.stringify(item))
        }
        .divider({ strokeWidth: $r("app.float.id_divide_width"), color: $r("sys.color.ohos_id_color_list_separator") })
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

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(this.title)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
        Text(this.content)
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r("app.float.id_card_margin_sm") })
      }
      .flexShrink(1)

      Row() {
        Image($r('app.media.ic_arrow_right_grey'))
          .align(Alignment.Center)
          .width($r("app.float.id_card_image_xs"))
          .height($r("app.float.id_card_image_small"))
          .visibility(this.hasArrow ? Visibility.Visible : Visibility.Hidden)
          .opacity(0.2)
      }
      .flexShrink(0)
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
  }
}