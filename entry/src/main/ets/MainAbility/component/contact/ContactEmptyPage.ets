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

import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import {ContactClickType} from '../../presenter/contact/ContactListPresenter';

const TAG = 'ContactEmptyPage ';

/**
 * 联系人没有查询到的空界面；
 */
@Entry
@Component
export default struct ContactEmptyPage {
  presenter: ContactListPresenter;
  /**
     * 底部四个buttonitem控件抽取
     */
  @Builder BottonItem(title: Resource, type: ContactClickType) {
    Button(title)
      .width(192)
      .height($r("app.float.contact_emptypage_button_item_height"))
      .borderRadius($r("app.float.contact_emptypage_button_radius"))
        //      .backgroundColor($r("app.color.colorControlNormal"))
      .backgroundColor("#19000000")
      .margin({ bottom: $r("app.float.contact_emptypage_bottom") })
        //      .fontColor($r("app.color.colorConnected"))
      .fontColor('#00CB87')
      .fontWeight(FontWeight.Medium)
        //      .fontSize($r("sys.float.id_text_size_body1"))
      .fontSize($r("app.float.contact_text_size_body1"))
      .onClick(() => {
        switch (type) {
          case ContactClickType.LOGIN_IN:
            this.presenter.loginAccount();
            break;
          case ContactClickType.IMPORT_CONTACT:
            this.presenter.importContact();
            break;
          case ContactClickType.CREATE_CONTACT:
            this.presenter.createContact();
            break;
          case ContactClickType.SCAN_CARD:
            this.presenter.scanCard();
            break;
          default:
            break;
        }
      })
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text($r("app.string.contact"))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
            //          .fontColor($r("app.color.textColorPrimary"))
          .fontColor('#182431')
          .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
      }
      .width('100%')
      .height($r("app.float.contact_title_height"))

      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        Image($r('app.media.no_contacts_illustration'))
          .objectFit(ImageFit.Contain)
          .width($r("app.float.contact_emptyview_image_width_height"))
          .height($r("app.float.contact_emptyview_image_width_height"))
          .margin({ bottom: 8 })
        Text($r("app.string.no_contacts"))
          .fontSize($r("app.float.contact_text_size_body2"))
          .fontWeight(FontWeight.Regular)
            //          .fontColor($r("app.color.textColorTertiary"))
          .fontColor('#66182431')
          .height(19)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)

      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center }) {

        this.BottonItem($r("app.string.create_contact"), ContactClickType.CREATE_CONTACT);
      }
      .width('100%')
      .height($r("app.float.contact_empty_list_all_bottom_height"))
    }
  }
}