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

import EnvironmentProp from '../../../feature/EnvironmentProp';

@Component
export struct ImageItemLeft {
  private mImage: Resource;
  private moreFlag?: Boolean = false;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    Column() {
      Image(this.mImage)
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .margin({ left: this.curBp === 'lg' ? $r("app.float.id_card_margin_max") : $r("app.float.id_card_margin_xl") })
        .fillColor(this.moreFlag
          ? $r("sys.color.ohos_id_color_connected")
          : $r("sys.color.ohos_id_color_secondary"))
    }
    .height($r("app.float.id_item_height_large"))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .flexShrink(0)
  }
}