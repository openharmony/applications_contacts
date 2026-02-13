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
import { HiLog } from '../../../../../../../feature/call/oh_modules/common';

import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';

@Component
export default struct ContactListDefaultPage {
  @StorageLink('breakpoint') curBp: string = 'sm';
  @State presenter: ContactListPresenter = ContactListPresenter.getInstance();
  @StorageLink('contactCount') contactCount: number = -1;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  build() {
    NavDestination() {
      if (this.contactCount > 0) {
        Column() {
          Column() {
            SymbolGlyph($r('sys.symbol.person_2_fill'))
              .fontSize(this.curBp !== 'lg' ? $r('app.float.account_listItem_text_common_width') : this.isTabletLandscape ? $r('app.float.id_card_image_large') : $r('app.float.account_ItemList_menu_select_width'))
              .fontColor([$r('app.color.skin_ohos_id_color_component_normal')])
          }
          .justifyContent(FlexAlign.Center)
          .width(this.isTabletLandscape ? $r('app.float.id_card_image_large') : $r('app.float.dialer_keypad_button_height'))
          .height(this.isTabletLandscape ? $r('app.float.id_card_image_large') : $r('app.float.dialer_keypad_button_height'))
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .width('100%')
      }
    }
    .focusable(false)
    .padding({
      top: px2vp(this.fullScreenPadding.top as number),
      bottom: px2vp(this.fullScreenPadding.bottom as number)
    })
    .backgroundColor($r('app.color.skin_background_primary'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}