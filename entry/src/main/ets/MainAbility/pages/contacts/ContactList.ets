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

import ContactListItemView from '../../component/contact/ContactListItemView';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import HiLog from '../../util/HiLog';
import EnvironmentProp from '../../feature/EnvironmentProp';
import StringUtil from '../../util/StringUtil';

const TAG = 'ContactList  ';

/**
 * Contact list page
 */
@Entry
@Component
export default struct ContactListPage {
  @State mContactPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  @State mSizeType: SizeType = EnvironmentProp.isTablet() ? SizeType.LG : SizeType.SM;
  @State mColumns: number = EnvironmentProp.isTablet() ? 12 : 4;
  @State mGutter: number = EnvironmentProp.isTablet() ? 12 : 24;
  @State mMargin: number = EnvironmentProp.isTablet() ? 12 : 24;

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.mContactPresenter.aboutToAppear();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    this.mContactPresenter.aboutToDisappear();
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow')
    this.mContactPresenter.onPageShow()
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageHide')
    this.mContactPresenter.onPageHide()
  }

  build() {
    Stack() {
      GridContainer({ columns: this.mColumns, sizeType: this.mSizeType, gutter: this.mGutter, margin: this.mMargin }) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
          if (this.mContactPresenter.contactList.length > 0) {
            ContactContent({ presenter: $mContactPresenter })
          } else {
            ContactEmptyPage({ presenter: $mContactPresenter })
          }
        }
        .useSizeType({
          xs: { span: 8, offset: 2 },
          sm: { span: 4, offset: 0 },
          md: { span: 8, offset: 2 },
          lg: { span: 8, offset: 2 }
        })
      }
    }
    .backgroundColor((EnvironmentProp.isTablet()) ? $r("sys.color.ohos_fa_sub_background") : Color.White)
    .width('100%')
    .height('100%')
  }
}

@Component
struct TitleGuide {
  presenter: ContactListPresenter = ContactListPresenter.getInstance();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
      Row() {
        Image($r("app.media.ic_public_add"))
          .width($r("app.float.id_card_image_small"))
          .height($r("app.float.id_card_image_small"))
          .objectFit(ImageFit.Contain)
      }
      .width($r("app.float.id_item_height_mid"))
      .height($r("app.float.id_item_height_large"))
      .onClick(() => {
        this.presenter.createContact();
      })

      Row() {
        Image($r("app.media.ic_public_more"))
          .width($r("app.float.id_card_image_small"))
          .height($r("app.float.id_card_image_small"))
          .objectFit(ImageFit.Contain)
          .visibility(Visibility.Hidden)
      }
      .width($r("app.float.id_item_height_mid"))
      .height($r("app.float.id_item_height_large"))
      .margin({ right: $r("app.float.id_card_margin_xl") })
    }
    .height($r("app.float.id_item_height_large"))
    .width('100%')
  }
}

@Component
struct ContactContent {
  @Link private presenter: ContactListPresenter;

  @Builder
  GroupsView(imageRes: Resource, title: string | Resource, showArrow: boolean) {
    Row() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Image(imageRes)
          .width($r("app.float.id_card_image_mid"))
          .height($r("app.float.id_card_image_mid"))
          .objectFit(ImageFit.Contain)
          .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_xxl") })

        Text(title)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Image($r("app.media.ic_arrow_right_grey"))
          .width(12)
          .height($r("app.float.id_card_image_small"))
          .objectFit(ImageFit.Contain)
          .margin({ right: $r("app.float.id_card_margin_max") })

      }
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
    .backgroundColor(Color.White)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Column() {
        TitleGuide()
      }
      .height($r("app.float.id_item_height_large"))
      .width('100%')
      .flexShrink(0)

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
        Text($r("app.string.contact"))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .margin({
            left: $r("app.float.id_card_margin_max"),
            right: $r("app.float.id_card_margin_max"),
            bottom: $r("app.float.id_card_margin_sm")
          })

        Text($r("app.string.contact_num", this.presenter.contactList.length))
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontWeight(FontWeight.Regular)
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
      }
      .height(81)
      .padding({ top: $r("app.float.id_card_margin_large"), bottom: $r("app.float.id_card_margin_xl") })
      .flexShrink(0)

      List({ space: 0, initialIndex: 0 }) {
        LazyForEach(this.presenter.contactListDataSource, (item, index: number) => {
          ListItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              Column() {
                if (item.showIndex && !StringUtil.isEmpty(item.contact.namePrefix)) {
                  Flex({ direction: FlexDirection.Column,
                    justifyContent: FlexAlign.End,
                    alignItems: ItemAlign.Start }) {
                    Text(item.contact.namePrefix)
                      .fontColor($r("sys.color.ohos_fa_text_secondary"))
                      .fontSize($r("sys.float.ohos_id_text_size_sub_title3"))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start)
                  }
                  .padding({ left: $r("app.float.id_card_margin_max"), bottom: $r("app.float.id_card_margin_large") })
                  .height($r("app.float.id_item_height_mid"))
                }

                ContactListItemView({ item: item.contact, index: index })
              }
              .alignItems(HorizontalAlign.Start)

              if (item.showDivifer) {
                Divider()
                  .color($r("sys.color.ohos_id_color_list_separator"))
                  .margin({ left: 76, right: $r("app.float.id_card_margin_max") })
              }
            }
          }
        }, (item) => item.contact.contactId.toString())
      }
      .width('100%')
      .flexShrink(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }

  }
}

@Component
export struct ContactEmptyPage {
  @Link presenter: ContactListPresenter;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Column() {
        TitleGuide()
      }
      .height($r("app.float.id_item_height_large"))
      .flexShrink(0)
      .width('100%')

      Text($r("app.string.contact"))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })
        .textAlign(TextAlign.Start)
        .width('100%')
        .height($r("app.float.id_item_height_large"))
        .flexShrink(0)

      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.End
      }) {
        Button($r("app.string.contact_login_in"), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .fontWeight(FontWeight.Medium)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .margin({ top: $r("app.float.id_card_margin_xxl") })
          .width('100%')
          .height($r("app.float.id_item_height_sm"))
          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
          .onClick(() => {
            this.presenter.loginAccount();
          })

        Button($r("app.string.contact_import_contacts"), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .fontWeight(FontWeight.Medium)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .margin({ top: $r("app.float.id_card_margin_xxl") })
          .width('100%')
          .height($r("app.float.id_item_height_sm"))
          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
          .onClick(() => {
            this.presenter.importContact();
          })

        Button($r("app.string.create_contact"), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .fontWeight(FontWeight.Medium)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .margin({ top: $r("app.float.id_card_margin_xxl") })
          .width('100%')
          .height($r("app.float.id_item_height_sm"))
          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
          .onClick(() => {
            this.presenter.createContact();
          })

        Button($r("app.string.contact_scan_card"), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .fontWeight(FontWeight.Medium)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .margin({ top: $r("app.float.id_card_margin_xxl") })
          .width('100%')
          .height($r("app.float.id_item_height_sm"))
          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
          .onClick(() => {
            this.presenter.scanCard();
          })
      }
      .flexShrink(1)
      .padding({ bottom: 32 })
      .width((EnvironmentProp.isTablet()) ? '37%' : '50%')

      Column() {
        Image($r('app.media.no_contacts_illustration'))
          .objectFit(ImageFit.Contain)
          .width($r("app.float.id_card_image_large"))
          .height($r("app.float.id_card_image_large"))
          .margin({ bottom: $r("app.float.id_card_margin_large") })

        Text($r("app.string.no_contacts"))
          .width($r("app.float.id_card_image_large"))
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontWeight(FontWeight.Regular)
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
      }
      .alignItems(HorizontalAlign.Center)
      .markAnchor({ x: 60, y: 60 })
      .position({ x: '50%', y: '40%' })
    }
  }
}