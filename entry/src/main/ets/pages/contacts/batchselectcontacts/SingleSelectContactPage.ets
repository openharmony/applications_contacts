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

import BatchSelectContactsPresenter from '../../../presenter/contact/batchselectcontacts/BatchSelectContactsPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import BatchSelectContactItemView from '../../../component/contact/batchselectcontacts/BatchSelectContactItemView';

const TAG = 'BatchSelectContactsPage ';

/**
 * Selecting a contact list by SMS
 */
@Entry
@Component
export default struct SingleSelectContactPage {
  @State mPresenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();
  @State currentIndex: number = 0;
  @State curBp: string = 'sm';

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear')
    this.mPresenter.aboutToAppear()
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear')
    this.mPresenter.aboutToDisappear()
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow')
    this.mPresenter.onPageShow()
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageHide')
    this.mPresenter.onPageHide()
  }

  onBackPress() {
    HiLog.i(TAG, 'onBackPress')
    this.mPresenter.cancel();
    return true;
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
            Flex({
              direction: FlexDirection.Row,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center }) {
              Image($r("app.media.ic_public_back"))
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
                .flexShrink(0)
                .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_xxl") })
                .onClick(() => {
                  this.mPresenter.cancel()
                })

              Text($r('app.string.select_contact'))
                .textAlign(TextAlign.Start)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .flexGrow(1)
                .flexShrink(1)
            }
            .width('100%')
            .height($r("app.float.id_item_height_large"))
            .flexShrink(0)

            Row() {
              if (ArrayUtil.isEmpty(this.mPresenter.contactsList)) {
                NoContactsEmptyView()
              } else {
                ContactsList({
                  presenter: $mPresenter
                })
              }
            }
          }
          .height("100%")
        }
      }
      .height("100%")
      .onBreakpointChange((breakpoint: string) => {
        this.curBp = breakpoint
      })
    }
    .padding({ left: 12, right: 12 })
    .width('100%')
    .height('100%')
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
  }
}

@Component
struct ContactsList {
  @Link presenter: BatchSelectContactsPresenter;

  build() {
    Column() {
      List({ initialIndex: this.presenter.initialIndex }) {
        LazyForEach(this.presenter.contactsSource, (item, index) => {

          ListItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              Column() {
                if (item.showIndex) {
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
                  .width('100%')
                  .height($r("app.float.id_item_height_mid"))
                }
              }

              BatchSelectContactItemView({
                single: item.single = true,
                item: item.contact,
                index: item.index,
                onSingleContactItemClick: (num, name) => this.presenter.onSingleContactItemClick(num, name),
                showIndex: item.showIndex,
              })
            }
          }
        }, (item) => JSON.stringify(item))
      }
      .width('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.presenter.resetInitialIndex(firstIndex);
      })
    }
    .width('100%')
    .padding({ top: $r("app.float.id_card_margin_mid"), bottom: $r("app.float.id_card_margin_mid") })
  }
}

@Component
struct NoContactsEmptyView {
  @State presenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center }) {
      Image($r("app.media.no_contacts_illustration"))
        .width($r("app.float.id_card_image_large"))
        .height($r("app.float.id_card_image_large"))
        .objectFit(ImageFit.Contain)
        .margin({ bottom: $r("app.float.id_card_margin_large") })

      Text(this.presenter.getEmptyText())
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .fontWeight(FontWeight.Regular)
        .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: $r("app.float.id_card_margin_large") })
  }
}