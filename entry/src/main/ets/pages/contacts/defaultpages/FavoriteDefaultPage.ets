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
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';

@Component
export default struct FavoriteListDefaultPage {
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('favoriteListLength') favoriteListLength: number = -1;

  build() {
    NavDestination() {
      if (this.favoriteListLength > 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.star_fill'))
            .fontSize($r('app.float.account_listItem_text_common_width'))
            .fontColor([$r('app.color.skin_ohos_id_color_component_normal')])
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .backgroundColor($r('app.color.skin_background_primary'))
    .hideTitleBar(true)
  }
}