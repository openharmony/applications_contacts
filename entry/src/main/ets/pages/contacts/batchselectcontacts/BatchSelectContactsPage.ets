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
import BatchSelectRecentItemView from '../../../component/contact/batchselectcontacts/BatchSelectRecentItemView';
import BatchSelectContactItemView from '../../../component/contact/batchselectcontacts/BatchSelectContactItemView';
import BatchTabGuide from '../../../component/contact/batchselectcontacts/BatchTabGuide';

const TAG = 'BatchSelectContactsPage ';

/**
 * Selecting a contact list by SMS
 */
@Entry
@Component
export default struct BatchSelectContactsPage {
  @State mPresenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();
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
      GridRow({columns: {sm: 4, md: 8, lg: 12}, gutter: {x: {sm: 12, md: 12, lg: 24}, y: 0}}) {
        GridCol({span: {sm: 4, md: 6, lg: 8}, offset: {sm: 0, md: 1, lg: 2}}) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
            Flex({
              direction: FlexDirection.Row,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center }) {
              Image($r("app.media.ic_public_cancel"))
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
                .flexShrink(0)
                .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_xxl") })
                .onClick(() => {
                  this.mPresenter.cancel()
                })

              Text(this.mPresenter.selectCount == 0 ? $r('app.string.no_select') : $r('app.string.select_num', this.mPresenter.selectCount))
                .textAlign(TextAlign.Start)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .flexGrow(1)
                .flexShrink(1)

              Image($r("app.media.ic_public_ok"))
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
                .flexShrink(0)
                .margin({ right: $r("app.float.id_card_margin_max") })
                .enabled(!this.mPresenter.selectDisabled)
                .fillColor(this.mPresenter.selectDisabled ? $r("sys.color.ohos_id_color_tertiary") : $r("sys.color.ohos_id_color_primary"))
                .onClick(() => {
                  this.mPresenter.comfirm()
                })

              if (this.curBp === 'lg') {
                Image(this.mPresenter.icSelectAll)
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
                  .flexShrink(0)
                  .objectFit(ImageFit.Contain)
                  .fillColor(this.mPresenter.allSelectTextStyle)
                  .margin({ right: $r("app.float.id_card_margin_max") })
                  .onClick((event: ClickEvent) => {
                    HiLog.i(TAG, 'clickSelectAll clicked!');
                    this.mPresenter.clickSelectAll();
                  })
              }
            }
            .width('100%')
            .height($r("app.float.id_item_height_large"))
            .flexShrink(0)

            BatchTabGuide({ currentIndex: $currentIndex, controller: this.controller })

            Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
              TabContent() {
                if (ArrayUtil.isEmpty(this.mPresenter.callLogTemp)) {
                  NoContactsEmptyView()
                } else {
                  RecentList({
                    presenter: $mPresenter
                  })
                }
              }

              TabContent() {
                if (ArrayUtil.isEmpty(this.mPresenter.contactsList)) {
                  NoContactsEmptyView()
                } else {
                  ContactsList({
                    presenter: $mPresenter
                  })
                }
              }
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Fixed)
            .barWidth(0)
            .barHeight(0)
            .animationDuration(0)
            .onChange((index: number) => {
              this.currentIndex = index;
              this.mPresenter.onTabChange(index);
            })
            .flexShrink(1)
            .margin({ top: $r("app.float.id_card_margin_large") })

            if (this.curBp !== 'lg') {
              Flex({
                direction: FlexDirection.Column,
                justifyContent: FlexAlign.Center,
                alignItems: ItemAlign.Center
              }) {
                Image(this.mPresenter.icSelectAll)
                  .width($r("app.float.id_card_image_small"))
                  .height($r("app.float.id_card_image_small"))
                  .objectFit(ImageFit.Contain)
                  .fillColor(this.mPresenter.allSelectTextStyle)

                Text(this.mPresenter.allSelectMessage)
                  .height(14)
                  .margin({ top: $r("app.float.id_card_margin_mid") })
                  .fontSize(10)
                  .fontColor(this.mPresenter.allSelectTextStyle)
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .height($r("app.float.id_item_height_large"))
              .flexShrink(0)
              .onClick((event: ClickEvent) => {
                this.mPresenter.clickSelectAll();
              })
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
struct RecentList {
  @Link presenter: BatchSelectContactsPresenter;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        LazyForEach(this.presenter.recentSource, (item, index: number) => {
          ListItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              BatchSelectRecentItemView({
                item: item.calllog,
                index: item.index,
                onRecentItemClicked: (index) => this.presenter.onRecentItemClicked(index)
              })

              if (item.showDivifer) {
                Divider()
                  .color($r("sys.color.ohos_id_color_list_separator"))
                  .margin({ left: 76, right: $r("app.float.id_card_margin_max") })
              }
            }
          }
        }, (item) => JSON.stringify(item))
      }
      .width('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({ top: $r("app.float.id_card_margin_mid"), bottom: $r("app.float.id_card_margin_mid") })
    .borderRadius($r("sys.float.ohos_id_corner_radius_card"))
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

                BatchSelectContactItemView({
                  item: item.contact,
                  index: item.index,
                  onContactItemClicked: (index, indexChild) => this.presenter.onContactItemClicked(index, indexChild),
                  showIndex: item.showIndex,
                  showDivifer: item.showDivifer
                })
              }

              if (item.showDivifer) {
                Divider()
                  .color($r("sys.color.ohos_id_color_list_separator"))
                  .margin({ left: 76, right: $r("app.float.id_card_margin_max") })
              }
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