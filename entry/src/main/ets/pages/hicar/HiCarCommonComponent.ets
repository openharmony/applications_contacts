/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { ImageType } from '../../data/HiCarConstants';

/**
 * hciar联系页面子标题组件
 */
@Component
export struct HiCarContactSubHeader {
  private subHeaderName: string | Resource = '';

  build() {
    Row() {
      Text(this.subHeaderName)
        .fontSize($r('app.float.id_text_size_body2_hicar'))
        .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.id_width_8') })
    }
    .alignItems(VerticalAlign.Bottom)
    .width('100%')
    .height($r('app.float.id_contact_list_item_height_hicar'))
  }
}

/**
 * 空白页组件
 */
@Component
export struct BlankPage {
  private headline: string | Resource = '';
  private imageType: number = ImageType.NO_CALL_RECORDS;

  private getImage(imageType: number): ResourceStr {
    let image: ResourceStr = $r('app.media.ic_empty_page_no_call_records');
    if (imageType === ImageType.NO_CONTACTS) {
      image = $r('app.media.ic_empty_page_no_contacts');
    } else if (imageType === ImageType.NO_RESULT) {
      // image = $r('app.media.no_result');
      image = $r('app.media.ic_empty_page_no_call_records');
    }
    return image;
  }

  build() {
    Column() {
      Image(this.getImage(this.imageType))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.id_card_image_large_hicar'))
        .height($r('app.float.id_card_image_large_hicar'))
        .margin({ bottom: $r('app.float.id_card_margin_large_hicar') })
      Text(this.headline)
        .fontSize($r('app.float.id_text_size_body2_hicar'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}