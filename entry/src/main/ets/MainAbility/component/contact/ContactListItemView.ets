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

import router from '@system.router';
import DeleteDialogEx from '../../pages/dialog/DeleteDialogEx';
import ShareDialogEx from '../../pages/dialog/ShareDialogEx';
import {ContactVo} from '../../model/bean/ContactVo';
import StringUtil from '../../util/StringUtil';
import HiLog from '../../util/HiLog';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import ContactRepository from '../../contact/repo/ContactRepository';
import ContactDelta from '../../contact/repo/ContactDelta';

const TAG = 'ContactListItemView ';

/**
 * The contact item component is used to display a single contact.
 */
@Component
export default struct ContactListItemView {
  private presenter: ContactListPresenter = ContactListPresenter.getInstance();
  @State item: any = {};
  @State private index: number = 0;
  shareDialogControler: CustomDialogController = new CustomDialogController({
    builder: ShareDialogEx({
      itemList: this.presenter.shareList,
      cancel: () => {
        this.presenter.onShareDialogCancel();
      },
      title: $r("app.string.dialog_share"),
      cancelText: $r("app.string.dialog_cancel")
    }),
    autoCancel: true,
    offset: { dx: 0, dy: -15 },
    alignment: DialogAlignment.Bottom
  });
  deleteDialogControler: CustomDialogController= new CustomDialogController({
    builder: DeleteDialogEx({
      cancel: () => {
        this.presenter.onDeleteDialogCancel();
      },
      confirm: () => {
        this.presenter.onDeleteDialogConfirm(this.index, this.item);
      },
      title: $r("app.string.delete_dialog_title"),
      cancalText: $r("app.string.dialog_cancel"),
      confrimText: $r("app.string.dialog_delete")
    }),
    autoCancel: true,
    offset: { dx: 0, dy: -15 },
    alignment: DialogAlignment.Bottom
  });

  onDeleteClick() {
    HiLog.i(TAG, 'onDeleteClick');
    this.deleteDialogControler.open();
  }

  onShareClick() {
    HiLog.i(TAG, 'onShareClick');
    this.shareDialogControler.open();
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start }) {

      if (this.item.title) {
        Text(this.item.title)
          .textAlign(TextAlign.Start)
          .fontSize($r("sys.float.ohos_id_text_size_headline8"))
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .height($r("app.float.id_item_height_max"))
      }

      Text($r("app.string.delete"))
        .width('100%')
        .height($r("app.float.id_item_height_mid"))
        .textAlign(TextAlign.Start)
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .fontWeight(FontWeight.Regular)
        .onClick(() => {
          this.presenter.setCurItem(this.item);
          ContextMenu.close();
          this.deleteDialogControler.open();
        })
    }
    .borderRadius($r("sys.float.ohos_id_corner_radius_card"))
    .width($r("app.float.contact_longpress_dialog_width"))
    .padding({
      left: $r("app.float.id_card_margin_max"),
      right: $r("app.float.id_card_margin_max"),
      top: $r("app.float.id_card_margin_mid"),
      bottom: $r("app.float.id_card_margin_mid")
    })
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Row() {
        if (StringUtil.isEmpty(this.item.nameSuffix)) {
          Image(StringUtil.isEmpty(this.item.portraitPath) ? $r("app.media.ic_user_portrait") : this.item.portraitPath)
            .width($r("app.float.id_card_image_mid"))
            .height($r("app.float.id_card_image_mid"))
            .objectFit(ImageFit.Contain)
            .borderRadius($r("app.float.id_card_image_mid"))
            .backgroundColor(this.item.portraitColor)
        } else {
          Text(this.item.nameSuffix.toUpperCase())
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(this.item.portraitColor)
            .height($r("app.float.id_card_image_mid"))
            .width($r("app.float.id_card_image_mid"))
            .textAlign(TextAlign.Center)
            .borderRadius($r("app.float.id_card_image_mid"))
        }
      }
      .height($r("app.float.id_card_image_mid"))
      .width($r("app.float.id_card_image_mid"))

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text(this.item.title)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r("app.float.id_card_margin_sm") })

        if (this.item.subTitle) {
          Text(this.item.subTitle)
            .width('100%')
            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontWeight(FontWeight.Regular)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }
      }
      .margin({ left: $r("app.float.id_card_margin_xl") })
    }
    .height($r("app.float.id_item_height_max"))
    .width('100%')
    .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
    .backgroundColor(Color.White)
    .onClick(() => {
      router.push(
        {
          uri: "pages/contacts/details/ContactDetail",
          params: {
            sourceHasId: true,
            contactId: this.item.contactId
          }
        }
      );
    })
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress)
  }
}