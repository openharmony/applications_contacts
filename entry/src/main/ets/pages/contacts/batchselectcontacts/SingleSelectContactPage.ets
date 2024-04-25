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

import router from '@ohos.router';
import BatchSelectContactsPresenter from '../../../presenter/contact/batchselectcontacts/BatchSelectContactsPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import BatchSelectContactItemView from '../../../component/contact/batchselectcontacts/BatchSelectContactItemView';
import { AlphabetIndexerPage } from '../alphabetindex/AlphabetIndexerPage';
import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';

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
    let obj: any = router.getParams();
    this.mPresenter.editContact = obj?.editContact;
    this.mPresenter.contactId = obj?.contactId;
    this.mPresenter.callId = obj?.callId;
    this.mPresenter.phones = obj?.phones;
    this.mPresenter.phoneNumberShow = obj?.phoneNumberShow;
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
    this.mPresenter.singleBackCancel();
    return true;
  }

  build() {
    Column() {
        if (ArrayUtil.isEmpty(this.mPresenter.contactsList)) {
          NoContactsEmptyView()
        } else {
          ContactsList({
            presenter: $mPresenter
          })
        }
    }
    .padding({ left: 12, right: 12 })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}

@Component
struct TitleGuide {
  mPresenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();

  build() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .height($r('app.float.id_card_image_small'))
        .width($r('app.float.id_card_image_small'))
        .flexShrink(0)
        .margin({ left: $r('app.float.id_card_margin_max'), right: $r('app.float.id_card_margin_xxl') })
        .onClick(() => {
          this.mPresenter.singleBackCancel();
        })

      Text($r('app.string.select_contact'))
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .flexGrow(1)
        .flexShrink(1)
    }
    .width('100%')
    .height($r('app.float.id_item_height_large'))
    .flexShrink(0)
  }
}

@Component
struct ContactsList {
  @Link private presenter: BatchSelectContactsPresenter;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  private scroller: Scroller = new Scroller();
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = true;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;

  build() {
    Column() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            TitleGuide()
          }
        }
        .height('100%')
        .onBreakpointChange((breakpoint: string) => {
          this.curBp = breakpoint
        })

      Stack({ alignContent: Alignment.TopEnd }) {
        GridRow({columns: {sm: 4, md: 8, lg: 12}, gutter: {x: 12, y: 0}}) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            List({ initialIndex: this.presenter.initialIndex, scroller: this.scroller }) {
              LazyForEach(this.presenter.contactsSource, (item, index) => {
                ListItem() {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Column() {
                      if (item.showIndex) {
                        Column() {
                          Text(item.contact.namePrefix)
                            .fontColor($r('sys.color.ohos_fa_text_secondary'))
                            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                            .fontWeight(FontWeight.Medium)
                            .textAlign(TextAlign.Start)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .padding({ left: $r('app.float.id_card_margin_max'), bottom: $r('app.float.id_card_margin_large') })
                        .width('100%')
                        .height($r('app.float.id_item_height_mid'))
                      }
                    }

                    BatchSelectContactItemView({
                      single: item.single = true,
                      item: item.contact,
                      index: item.index,
                      onSingleContactItemClick: (num, name) => this.presenter.onSingleContactItemClick(num, name, item.contact),
                      showIndex: item.showIndex,
                    })
                  }
                }
              }, (item) => JSON.stringify(item))
            }
            .scrollBar(BarState.Off)
            .width('100%')
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring)
            .onScrollIndex((firstIndex: number, lastIndex: number) => {
              this.presenter.resetInitialIndex(firstIndex);
              if (!this.isAlphabetClicked) {
                this.alphabetSelected = this.alphabetIndexPresenter.getAlphabetSelected(firstIndex);
              }
            })
            .onScrollStart(() => {
              this.dragList = true;
            })
            .onScrollStop(() => {
              this.isAlphabetClicked = false;
            })
          }
        }
        .height('93%')
        AlphabetIndexerPage({scroller: this.scroller, presenter: $alphabetIndexPresenter, selected: this.alphabetSelected,
          isClicked: $isAlphabetClicked, drag: $dragList})
          .margin({ top: '10%', bottom: '10%' })
      }
      .height('100%')
      .flexShrink(1)
    }
    .width('100%')
    .padding({ top: $r('app.float.id_card_margin_mid'), bottom: $r('app.float.id_card_margin_mid') })
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
      Image($r('app.media.no_contacts_illustration'))
        .width($r('app.float.id_card_image_large'))
        .height($r('app.float.id_card_image_large'))
        .objectFit(ImageFit.Contain)
        .margin({ bottom: $r('app.float.id_card_margin_large') })

      Text(this.presenter.getEmptyText())
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: $r('app.float.id_card_margin_large') })
  }
}