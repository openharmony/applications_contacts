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
import Utils from '../../util/Utils';
import HiLog from '../../util/HiLog';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import ContactRepository from '../../contact/repo/ContactRepository';
import ContactDelta from '../../contact/repo/ContactDelta';

const TAG = 'ContactListItemView ';

/**
 * 联系人item组件，主要负责单个联系人的显示;
 */
@Component
export default struct ContactListItemView {
  private presenter: ContactListPresenter = ContactListPresenter.getInstance();
  @State item: any = {};
  private index: number;
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
        this.presenter.onDeleteDialogConfirm(this.item);
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

      Text(Utils.isEmpty(this.item.showName) ? this.item.phoneNum : this.item.showName)
        .textAlign(TextAlign.Start)
        .fontSize($r("app.float.contact_text_size_headline8"))
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, bottom: 10 })
        .width('100%')
        .height($r("app.float.contact_listitem_height"))
        .visibility(Utils.isEmpty(this.item.showName) ? Visibility.None : Visibility.Visible)

      Text($r("app.string.delete"))
        .width('100%')
        .height($r("app.float.contact_listitem_index_height"))
        .textAlign(TextAlign.Start)
        .fontSize($r("app.float.contact_text_size_body1"))
        .fontColor('#182431')
        .fontWeight(FontWeight.Regular)
        .margin({ top: 5 })
        .onClick(() => {
          this.presenter.setCurItem(this.item);
          ContextMenu.close();
          this.deleteDialogControler.open();
        })
    }
    .borderRadius($r("app.float.contact_emptypage_button_radius"))
    .width($r("app.float.contact_longpress_dialog_width"))
    .padding({ top: 4, bottom: 4 })
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Row() {
        Text(this.item.emptyNameData.substr(this.item.emptyNameData.length - 1, 1))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(this.item.portraitColor)
          .height($r("app.float.contact_listpage_icon_width_height"))
          .width($r("app.float.contact_listpage_icon_width_height"))
          .textAlign(TextAlign.Center)
          .border({ width: 0, color: Color.White, radius: 40 })
          .visibility((!Utils.isEmpty(this.item.portraitPath) || (Utils.isEmpty(this.item.portraitPath) && Utils.isEmpty(this.item.showName) && Utils.isEmpty(this.item.phoneNum))) ? Visibility.None : Visibility.Visible)

        Image(Utils.isEmpty(this.item.portraitPath) ? $r("app.media.avatar_filled_honor") : this.item.portraitPath)
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
          .visibility((!Utils.isEmpty(this.item.portraitPath) || (Utils.isEmpty(this.item.portraitPath) && Utils.isEmpty(this.item.showName) && Utils.isEmpty(this.item.phoneNum))) ? Visibility.Visible : Visibility.None)
      }
      .margin({ left: $r("app.float.common_margin") })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text(Utils.isEmpty(this.item.showName) ? this.item.phoneNum : this.item.showName)
          //          .fontColor($r("app.color.textColorPrimary"))
          .fontColor('#182431')
          .fontSize($r("app.float.contact_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12, bottom: 2 })

        Text((Utils.isEmpty(this.item.company) ? '' : this.item.company + ' ') + (Utils.isEmpty(this.item.position) ? '' : this.item.position))
          //          .fontColor($r("app.color.textColorTertiary"))
          .fontColor('#66182431')
          .fontSize($r("app.float.contact_text_size_body1"))
          .fontWeight(FontWeight.Regular)
          .visibility((Utils.isEmpty(this.item.company) && Utils.isEmpty(this.item.position)) ? Visibility.None : Visibility.Visible)
          .margin({ left: 12 })
      }
    }
    .height($r("app.float.contact_listitem_height"))
    .width('100%')
    .backgroundColor(Color.White)
    .onClick(() => {
      router.push(
        {
          uri: "pages/contacts/details/ContactDetail",
          params: {
            contactId: this.item.contactId,
            isNewSource: true
          }
        }
      );
    })
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress)
  }
}